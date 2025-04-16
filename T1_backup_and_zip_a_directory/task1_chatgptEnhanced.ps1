param (
    [Parameter(Mandatory = $true)]
    [string] $path,

    [string] $destinationPath = "C:\Backups",
    [string] $logPath = "C:\Logs"
)

# Create log file with timestamp if not exists
$timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
$logFile = Join-Path -Path $logPath -ChildPath "task1.log"

try {
    # Ensure log directory and file exists
    if (-not (Test-Path -Path $logPath)) {
        New-Item -ItemType Directory -Path $logPath -Force | Out-Null
    }
    if (-not (Test-Path -Path $logFile)) {
        New-Item -ItemType File -Path $logFile -Force | Out-Null
    }

    Add-Content -Path $logFile -Value "$timestamp - [INFO] Script started for path: $path"

    # Ensure destination directory exists
    if (-not (Test-Path -Path $destinationPath)) {
        Add-Content -Path $logFile -Value "$timestamp - [INFO] Creating destination directory: $destinationPath"
        New-Item -ItemType Directory -Path $destinationPath -Force | Out-Null
    }

    # Compose output filename
    $folderName = Split-Path -Path $path -Leaf
    $zipFileName = "${folderName}_Backup_$timestamp.zip"
    $zipPath = Join-Path -Path $destinationPath -ChildPath $zipFileName

    # Perform compression
    Add-Content -Path $logFile -Value "$timestamp - [INFO] Compressing directory: $path"
    Compress-Archive -Path $path -DestinationPath $zipPath -Force
    Add-Content -Path $logFile -Value "$timestamp - [INFO] Compression completed: $zipPath"

    # Optional: Clean up old backups (older than 7 days)
    Get-ChildItem -Path $destinationPath -Filter "*_Backup_*.zip" |
        Where-Object { $_.LastWriteTime -lt (Get-Date).AddDays(-7) } |
        ForEach-Object {
            Add-Content -Path $logFile -Value "$timestamp - [INFO] Removing old backup: $($_.FullName)"
            Remove-Item $_.FullName -Force
        }

    Add-Content -Path $logFile -Value "$timestamp - [INFO] Script completed successfully"
    exit 0
}
catch {
    $errorMsg = $_.Exception.Message
    Add-Content -Path $logFile -Value "$timestamp - [ERROR] Script failed: $errorMsg"
    exit 1
}