param (
    [Parameter(Mandatory = $true)]
    [string] $path
)

# Define paths
$logPath = 'C:\Logs\Task1'
$logFile = "$logPath\task1.log"
$destinationPath = 'C:\Backups\Task1'

# Create log directory and log file if they don't exist
try {
    if (-not (Test-Path -Path $logPath)) {
        New-Item -ItemType Directory -Path $logPath -Force | Out-Null
        New-Item -ItemType File -Path $logFile -Force | Out-Null
    }
}
catch {
    throw
}

# Backup process
try {
    # Step 1: Check if destination path exists
    if (-not (Test-Path -Path $destinationPath)) {
        Add-Content -Path $logFile -Value "$(Get-Date -Format 'dd/MM/yyyy HH:mm:ss') - [INFO] Creating Backup Directory"
        New-Item -ItemType Directory -Path $destinationPath -Force | Out-Null
        Add-Content -Path $logFile -Value "$(Get-Date -Format 'dd/MM/yyyy HH:mm:ss') - [INFO] Backup Directory Created Successfully"
    }

    # Step 2: Compress the directory
    $timestamp = Get-Date -Format 'yyyyMMdd_HHmmss'
    $zipName = "task1_$timestamp.zip"
    $zipFullPath = Join-Path -Path $destinationPath -ChildPath $zipName

    Add-Content -Path $logFile -Value "$(Get-Date -Format 'dd/MM/yyyy HH:mm:ss') - [INFO] Starting Compression"
    Compress-Archive -Path $path -DestinationPath $zipFullPath -Force
    Add-Content -Path $logFile -Value "$(Get-Date -Format 'dd/MM/yyyy HH:mm:ss') - [INFO] Compression Completed Successfully"
}
catch {
    Add-Content -Path $logFile -Value "$(Get-Date -Format 'dd/MM/yyyy HH:mm:ss') - [ERROR] Compression Failed: $($_.Exception.Message)"
    throw
}