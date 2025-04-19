<#
This function is used to the check the Disk usage.
If Disk usage is more than the threshold then email will be triggered.
#>

function Get-DiskUsage {
    param (
        # Drive Name
        [Parameter(
            Position = 0,
            Mandatory = $true,
            HelpMessage = "Enter Drive Name for checking the usage:"
        )]
        [string]
        $driveName,

        # Threshold
        [Parameter(
            Position = 1,
            Mandatory = $true,
            HelpMessage = "Enter the threshold in either GB or %. End the value with suffix:"
        )]
        [string]
        $threshold
    )
    
    <#
    Defining LogPath and LogFile
    Checking whether folder and file exists. Else create it.
    #>
    $logPath = 'PATH\TO\DIRECTORY'
    $global:logFile = "$LogPath\task3.log"
    try {
        if (-not(Test-Path -Path $logPath -ErrorAction Stop )) {
            New-Item -ItemType Directory -Path $logPath -ErrorAction Stop | Out-Null
            New-Item -ItemType File -Path $global:logFile -ErrorAction Stop | Out-Null
            Write-Output "Log path created"
        }
    }
    catch {
        $errorMsg = $_.Exception.Message
        Write-Output $errorMsg
        throw
    }

    <#
    Check Disk usage.
    If greather than threshold then find top five large folders or files then add them to a text file.
    Output that text file as a attachment in the email.
    #>
    try {
        Add-Content -Path $global:logFile -Value "$(Get-Date -Format 'dd/MM/yyyy HH:mm:ss') - [INFO] Calculating Disk Usage for $driveName."

        # Get free and used disk values
        $usedSpace = $(Get-PSDrive $driveName).used
        $freeSpace = $(Get-PSDrive $driveName).free
        $totalSpace = $usedSpace + $freeSpace
        $usedPercent = [math]::Round(($usedSpace / $totalSpace) * 100, 2)
        $freePercent = [math]::Round(($freeSpace / $totalSpace) * 100, 2)
        
        Add-Content -Path $global:logFile -Value "$(Get-Date -Format 'dd/MM/yyyy HH:mm:ss') - [INFO] Used % in $driveName : $usedPercent"
        Add-Content -Path $global:logFile -Value "$(Get-Date -Format 'dd/MM/yyyy HH:mm:ss') - [INFO] Free % in $driveName : $freePercent"

        # Check with threshold
        if ($threshold.EndsWith("GB")) {
            [int]$value = $threshold -replace "[^0-9.]", ""
            $usedSpaceGB = $(Get-PSDrive -Name $driveName | Select-Object @{Name="Used";Expression={$_.Used / 1GB}}).Used
            
            if ($usedSpaceGB -ge $value) {
                Add-Content -Path $global:logFile -Value "$(Get-Date -Format 'dd/MM/yyyy HH:mm:ss') - [ERROR] Used Space (GB) in $driveName : $usedSpaceGB GB is above or equal to $value GB."
                Add-Content -Path $global:logFile -Value "$(Get-Date -Format 'dd/MM/yyyy HH:mm:ss') - [INFO] Getting top 5 folders and files consuming the space."

                # Get the top space consumers
                Get-TopSpaceConsumers -driveName "$driveName" -topN 5 -outputFile 'PATH\TO\DIRECTORY\TopSpaceConsumers.txt'
                
                # Send email with attachement
                Send-Email -usedSpace "$usedPercent" -attachmentPath 'PATH\TO\DIRECTORY\TopSpaceConsumers.txt'
            }

            else {
                Add-Content -Path $global:logFile -Value "$(Get-Date -Format 'dd/MM/yyyy HH:mm:ss') - [INFO] Free Space (GB) in $driveName : $freeSpaceGB is below $threshold."
            }
        }

        elseif ($threshold.EndsWith("%")) {
            [int]$value = $threshold -replace "[^0-9.]", ""

            if ($usedPercent -ge $value) {
                Add-Content -Path $global:logFile -Value "$(Get-Date -Format 'dd/MM/yyyy HH:mm:ss') - [ERROR] Used Space (%) in $driveName : $usedPercent % is above or equal to $value %."
                Add-Content -Path $global:logFile -Value "$(Get-Date -Format 'dd/MM/yyyy HH:mm:ss') - [INFO] Getting top 5 folders and files consuming the space."

                # Get the top space consumers
                Get-TopSpaceConsumers -driveName "$driveName" -topN 5 -outputFile 'PATH\TO\DIRECTORY\TopSpaceConsumers.txt'
                
                # Send email with attachement
                Send-Email -usedSpace "$usedPercent" -attachmentPath 'PATH\TO\DIRECTORY\TopSpaceConsumers.txt'
            }

            else {
                Add-Content -Path $global:logFile -Value "$(Get-Date -Format 'dd/MM/yyyy HH:mm:ss') - [INFO] Free Space (%) in $driveName : $freeSpacePercent is below $threshold."
            }
        } 
    }
    catch {
        $errorMsg = $_.Exception.Message
        Add-Content -Path $global:logFile -Value "$(Get-Date -Format 'dd/MM/yyyy HH:mm:ss') - [ERROR] Script failed: $errorMsg"
        throw
    }
}

function Get-TopSpaceConsumers {
    param (
        # Parameter help description
        [Parameter(Position = 0)]
        [string]
        $driveName,

        [Parameter(Position = 1)]
        [int]
        $topN,

        [Parameter(Position = 2)]
        [string]
        $outputFile
    )

    # Ensure the DriveName ends with a backslash
    if (-Not $driveName.EndsWith(":\")) {
        $driveName += ":\"
    }

    Add-Content -Path $global:logFile -Value "$(Get-Date -Format 'dd/MM/yyyy HH:mm:ss') - [INFO] Inside Get-TopSpaceConsumers function"
    Add-Content -Path $global:logFile -Value "$(Get-Date -Format 'dd/MM/yyyy HH:mm:ss') - [INFO] Getting files and folders"

    # Get all files and folders in the specified drive
    $items = Get-ChildItem -Path "$driveName" -Recurse -Force -ErrorAction SilentlyContinue | Where-Object { $_.PSIsContainer -or $_.Length -gt 0 }

    Add-Content -Path $global:logFile -Value "$(Get-Date -Format 'dd/MM/yyyy HH:mm:ss') - [INFO] Calculating size of each item."
    
    # Calculate the size of each item
    $sizeInfo = $items | ForEach-Object {
        $size = if ($_.PSIsContainer) {
            Get-FolderSize -path $_.FullName
        } else {
            $_.Length
        }
        [PSCustomObject]@{
            Name     = $_.FullName
            Size     = $size
            IsFolder = $_.PSIsContainer
        }
    }

    Add-Content -Path $global:logFile -Value "$(Get-Date -Format 'dd/MM/yyyy HH:mm:ss') - [INFO] Separation of files and folders."
    # Separate files and folders
    $topFiles = $sizeInfo | Where-Object { -Not $_.IsFolder } | Sort-Object -Property Size -Descending | Select-Object -First $TopN
    $topFolders = $sizeInfo | Where-Object { $_.IsFolder } | Sort-Object -Property Size -Descending | Select-Object -First $TopN

    Add-Content -Path $global:logFile -Value "$(Get-Date -Format 'dd/MM/yyyy HH:mm:ss') - [INFO] Preparing Output."
    
    # Prepare output
    $output = @()
    $output += "Top $topN Files:`n"
    $output += $topFiles | ForEach-Object { "{0,-50} {1}" -f $_.Name, (Convert-SizeToReadableFormat -SizeInBytes $_.Size) }
    $output += "`nTop $topN Folders:`n"
    $output += $topFolders | ForEach-Object { "{0,-50} {1}" -f $_.Name, (Convert-SizeToReadableFormat -SizeInBytes $_.Size) }

    Add-Content -Path $global:logFile -Value "$(Get-Date -Format 'dd/MM/yyyy HH:mm:ss') - [INFO] Saving Output to a text file."
    # Save the results to a text file
    $output | Out-File -FilePath $outputFile -Encoding UTF8

    Add-Content -Path $global:logFile -Value "$(Get-Date -Format 'dd/MM/yyyy HH:mm:ss') - [INFO] Saved Output to a text file."
    Add-Content -Path $global:logFile -Value "$(Get-Date -Format 'dd/MM/yyyy HH:mm:ss') - [INFO] Exiting Get-TopSpaceConsumers function."
}

function Get-FolderSize {
    param (
        [Parameter(Position = 0)]
        [string]
        $path
    )

    # Calculate total size of files in the folder and return it
    $totalSize = (Get-ChildItem -Path $path -Recurse -Force -ErrorAction SilentlyContinue | 
                   Where-Object { -Not $_.PSIsContainer } | 
                   Measure-Object -Property Length -Sum).Sum

    return $totalSize  # Return the total size
    # $totalSize = 0
    # $items = Get-ChildItem -Path $path -Recurse -Force -ErrorAction SilentlyContinue

    # foreach ($item in $items) {
    #     if (-Not $item.PSIsContainer) {
    #         $totalSize += $item.Length
    #     }
    # }

    # return $totalSize
}

function Convert-SizeToReadableFormat {
    param (
        [long]$SizeInBytes
    )

    if ($SizeInBytes -ge 1GB) {
        return "{0:N2} GB" -f ($SizeInBytes / 1GB)
    } elseif ($SizeInBytes -ge 1MB) {
        return "{0:N2} MB" -f ($SizeInBytes / 1MB)
    } elseif ($SizeInBytes -ge 1KB) {
        return "{0:N2} KB" -f ($SizeInBytes / 1KB)
    } else {
        return "$SizeInBytes Bytes"
    }
}

function Send-Email {
    param (
        [Parameter(Position = 0)]
        [string]
        $usedSpace,

        [Parameter(Position = 1)]
        [string]
        $attachmentPath
    )

    try {
        Add-Content -Path $global:logFile -Value "$(Get-Date -Format 'dd/MM/yyyy HH:mm:ss') - [INFO] Inside Send-Email function."

        $smtpConfig = Get-Content -Path "path\to\your\settings.json" | ConvertFrom-Json
        $sendEmailSplat = @{
            From = $smtpConfig.EmailSettings.From
            To = 'recepient@emailprovider.com'
            Subject = "Disk Usage is High"
            Body = "Disk Usage is $usedSpace % and please find attached text file for revealing top 5 space consumers."
            SmtpServer = $smtpConfig.EmailSettings.Host
            Port = $smtpConfig.EmailSettings.Port
            Credential = New-Object System.Management.Automation.PSCredential ($smtpConfig.EmailSettings.Username, (ConvertTo-SecureString $smtpConfig.EmailSettings.Password -AsPlainText -Force))
            UseSsl = $true
            Attachment = $attachmentPath
            ErrorAction = 'Stop'
        }

        Send-MailMessage @sendEmailSplat

        Add-Content -Path $global:logFile -Value "$(Get-Date -Format 'dd/MM/yyyy HH:mm:ss') - [INFO] Email sent successfully."
        Add-Content -Path $global:logFile -Value "$(Get-Date -Format 'dd/MM/yyyy HH:mm:ss') - [INFO] Exiting Send-Email function."
    }
    catch {
        $errorMsg = $_.Exception.Message
        Add-Content -Path $global:logFile -Value "$(Get-Date -Format 'dd/MM/yyyy HH:mm:ss') - [ERROR] Script failed in Send-Email function: $errorMsg"
        throw
    }
}