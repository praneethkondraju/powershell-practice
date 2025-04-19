# File: Monitor-DiskUsage.ps1

param (
    [Parameter(Mandatory)]
    [string]$DriveName,

    [Parameter(Mandatory)]
    [string]$Threshold,

    [Parameter()]
    [string]$LogPath = "$PSScriptRoot\Logs",

    [Parameter()]
    [string]$TopConsumerOutput = "$PSScriptRoot\TopSpaceConsumers.txt",

    [Parameter()]
    [string]$SettingsJson = "$PSScriptRoot\settings.json"
)

$global:LogFile = "$LogPath\DiskMonitor.log"

function Ensure-LogPath {
    if (-not (Test-Path -Path $LogPath)) {
        New-Item -ItemType Directory -Path $LogPath -Force | Out-Null
    }
    if (-not (Test-Path -Path $global:LogFile)) {
        New-Item -ItemType File -Path $global:LogFile -Force | Out-Null
    }
}

function Log {
    param ([string]$message, [string]$type = "INFO")
    $timestamp = Get-Date -Format "dd/MM/yyyy HH:mm:ss"
    Add-Content -Path $global:LogFile -Value "$timestamp - [$type] $message"
}

function Convert-SizeToReadableFormat {
    param ([long]$SizeInBytes)
    if ($SizeInBytes -ge 1GB) { return "{0:N2} GB" -f ($SizeInBytes / 1GB) }
    elseif ($SizeInBytes -ge 1MB) { return "{0:N2} MB" -f ($SizeInBytes / 1MB) }
    elseif ($SizeInBytes -ge 1KB) { return "{0:N2} KB" -f ($SizeInBytes / 1KB) }
    else { return "$SizeInBytes Bytes" }
}

function Get-FolderSize {
    param ([string]$Path)
    return (Get-ChildItem -Path $Path -Recurse -Force -ErrorAction SilentlyContinue | Where-Object { -not $_.PSIsContainer } | Measure-Object Length -Sum).Sum
}

function Get-TopSpaceConsumers {
    param (
        [string]$Drive,
        [int]$TopN = 5,
        [string]$OutputPath
    )

    $DrivePath = if ($Drive.EndsWith(":\")) { $Drive } else { "$Drive:\" }

    $items = Get-ChildItem -Path $DrivePath -Recurse -Force -ErrorAction SilentlyContinue | 
             Where-Object { $_.PSIsContainer -or $_.Length -gt 0 }

    $sizes = $items | ForEach-Object {
        $size = if ($_.PSIsContainer) { Get-FolderSize -Path $_.FullName } else { $_.Length }
        [PSCustomObject]@{ Name = $_.FullName; Size = $size; IsFolder = $_.PSIsContainer }
    }

    $topFiles = $sizes | Where-Object { -not $_.IsFolder } | Sort-Object Size -Descending | Select-Object -First $TopN
    $topFolders = $sizes | Where-Object { $_.IsFolder } | Sort-Object Size -Descending | Select-Object -First $TopN

    $output = @()
    $output += "Top $TopN Files:`n"
    $output += $topFiles | ForEach-Object { "{0,-50} {1}" -f $_.Name, (Convert-SizeToReadableFormat $_.Size) }
    $output += "`nTop $TopN Folders:`n"
    $output += $topFolders | ForEach-Object { "{0,-50} {1}" -f $_.Name, (Convert-SizeToReadableFormat $_.Size) }

    $output | Out-File -FilePath $OutputPath -Encoding UTF8
}

function Send-EmailAlert {
    param (
        [string]$UsedPercent,
        [string]$AttachmentPath,
        [string]$SettingsFile
    )

    $smtp = Get-Content $SettingsFile | ConvertFrom-Json

    $params = @{
        From       = $smtp.EmailSettings.From
        To         = $smtp.EmailSettings.To
        Subject    = "Disk Usage Alert: $DriveName"
        Body       = "Current disk usage is $UsedPercent%. Attached are the top space consumers."
        SmtpServer = $smtp.EmailSettings.Host
        Port       = $smtp.EmailSettings.Port
        Credential = New-Object PSCredential ($smtp.EmailSettings.Username, (ConvertTo-SecureString $smtp.EmailSettings.Password -AsPlainText -Force))
        UseSsl     = $true
        Attachments = $AttachmentPath
    }

    Send-MailMessage @params
    Log "Alert email sent to $($smtp.EmailSettings.To)."
}

function Monitor-DiskUsage {
    Ensure-LogPath
    Log "Starting disk usage monitoring for $DriveName."

    $disk = Get-PSDrive -Name $DriveName
    $usedGB = [math]::Round($disk.Used / 1GB, 2)
    $usedPercent = [math]::Round(($disk.Used / ($disk.Used + $disk.Free)) * 100, 2)

    Log "Used GB: $usedGB GB, Used Percent: $usedPercent%"

    $value = [int]($Threshold -replace "[^0-9.]", "")
    $isThresholdBreached = $false

    if ($Threshold.EndsWith("GB") -and $usedGB -ge $value) {
        $isThresholdBreached = $true
    } elseif ($Threshold.EndsWith("%") -and $usedPercent -ge $value) {
        $isThresholdBreached = $true
    }

    if ($isThresholdBreached) {
        Log "Threshold breached. Gathering top space consumers.", "ERROR"
        Get-TopSpaceConsumers -Drive $DriveName -OutputPath $TopConsumerOutput
        Send-EmailAlert -UsedPercent $usedPercent -AttachmentPath $TopConsumerOutput -SettingsFile $SettingsJson
    } else {
        Log "Disk usage within acceptable limits."
    }

    Log "Monitoring complete for $DriveName."
}

Monitor-DiskUsage