param (
    [Parameter(Mandatory = $true)]
    [string]
    $path
)
<#
Defining LogPath and LogFile
Checking whether folder and file exists. Else create it.
#>
$logPath = 'PATH\TO\DIRECTORY'
$logFile = "$LogPath\task1.log"
try {
    if (-not(Test-Path -Path $logPath -ErrorAction Stop )) {
        New-Item -ItemType Directory -Path $logPath -ErrorAction Stop | Out-Null
        New-Item -ItemType File -Path $logFile -ErrorAction Stop | Out-Null
    }
}
catch {
    throw
}

<#
Check Backup directory is available of not else create it
Compress the directory
filename should end with timestamp
#>
$destinationPath = 'BACKUP\DIRECTORY\PATH'
try {
    #Check Backup directory availability
    if (-not(Test-Path -Path $destinationPath)) {
        Add-Content -Path $logFile -Value "$(Get-Date -Format 'dd/MM/yyyy HH:mm:ss') - [INFO] Creating Backup Directory"
        New-Item -ItemType Directory -Path $destinationPath -ErrorAction Stop | Out-Null
        Add-Content -Path $logFile -Value "$(Get-Date -Format 'dd/MM/yyyy HH:mm:ss') - [INFO] Backup Directory Created Successfully"
    }

    # Peform Compression
    Add-Content -Path $logFile -Value "$(Get-Date -Format 'dd/MM/yyyy HH:mm:ss') - [INFO] Starting Compression"
    Compress-Archive -Path $path -DestinationPath "$destinationPath\task1_$((Get-Date).ToString('yyyyMMdd_HHmmss')).zip"
    Add-Content -Path $logFile -Value "$(Get-Date -Format 'dd/MM/yyyy HH:mm:ss') - [INFO] Compression Completed Successfully"
}
catch {
    Add-Content -Path $logFile -Value "$(Get-Date -Format 'dd/MM/yyyy HH:mm:ss') - [ERROR] Compression Failed due to $_"
    throw
}
