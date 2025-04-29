# Parameters
param(
    [Parameter(
         HelpMessage = 'Provide Custom Log Path value'
    )]
    [string]
    $logPath = 'PATH\TO\DIRECTORY',

    # Parameter help description
    [Parameter(
        HelpMessage = 'Provide custom Log file name value'
    )]
    [string]
    $logFile = "$logPath\Orphaned_Scheduled_Tasks_Log.log"
)


function Ensure-LogPath {
    if (-not (Test-Path -Path $logPath)) {
        New-Item -ItemType Directory -Path $logPath -Force | Out-Null
    }
    if (-not (Test-Path -Path $logFile)) {
        New-Item -ItemType File -Path $logFile -Force | Out-Null
    }
}

function Log {
    param ([string]$message, [string]$type = "INFO")
    $timestamp = Get-Date -Format "dd/MM/yyyy HH:mm:ss"
    Add-Content -Path $logFile -Value "$timestamp - [$type] $message"
}

function Send-EmailAlert {
    param (
        [string]$attachmentPath,
        [string]$settingsFile
    )

    $smtp = Get-Content $SettingsFile | ConvertFrom-Json

    $params = @{
        From       = $smtp.EmailSettings.From
        To         = $smtp.EmailSettings.To
        Subject    = "[ALERT] Orphaned Tasks Found"
        Body       = "Orphaned Tasks found and Please find attached for details."
        SmtpServer = $smtp.EmailSettings.Host
        Port       = $smtp.EmailSettings.Port
        Credential = New-Object PSCredential ($smtp.EmailSettings.Username, (ConvertTo-SecureString $smtp.EmailSettings.Password -AsPlainText -Force))
        UseSsl     = $true
        Attachments = $AttachmentPath
    }

    Send-MailMessage @params
    Log "Alert email sent to $($smtp.EmailSettings.To)."
}

function Get-Orphaned-Tasks {
    
    try {
        Ensure-LogPath

        Log -message "Inside Get-Orphaned-Tasks"

        $excludedTasks = @("\Microsoft")
        Log -message "Excluded Task Paths: $excludedTasks"

        $scheduledTasks = Get-ScheduledTask | Where-Object { $excludedTasks -notcontains $_.TaskPath } -ErrorAction Stop

        $orphanedTaskArray = @()
        $isOrphanedTaskAvailable = $false
        $orphanedTaskArray += "TaskPath of Orphaned Tasks`n" 
        $orphanedTaskArray += "TaskName ----------> TaskPath" 
        
        foreach ($task in $scheduledTasks) {

            $taskPath = $($task).Actions.Execute

            if (![string]::IsNullOrWhiteSpace($taskPath)) {
                # Expand environment variables if any exist
                $ExpandedPath = [Environment]::ExpandEnvironmentVariables($taskPath)

                if (-not(Test-Path $ExpandedPath -ErrorAction SilentlyContinue)) {
                    $taskName = $($task).TaskName
                    $orphanedTaskArray += "$taskName ---------> $taskPath"
                    if ($isOrphanedTaskAvailable -eq $false) {
                        $isOrphanedTaskAvailable = $true
                    }
                }
            }
        }

        if ($isOrphanedTaskAvailable) {
            Log -message "Orphaned Tasks are available"
            $orphanedTaskArray | Out-File -FilePath "$logPath\OrphanedTasks.txt" -Encoding utf8
            Send-EmailAlert -attachmentPath "$logPath\OrphanedTasks.txt" -settingsFile "PATH_TO_THE_FILE"
        }

        Log -message "Exiting Get-Orphaned-Tasks"
        Log -message "Task Completed!!!"
    }
    catch {
        $errorMsg = $_.Exception.Message
        Log "Exception caught in Get-Orphaned-Task function: $errorMsg" -type "ERROR"
        throw
    }
}

Get-Orphaned-Tasks