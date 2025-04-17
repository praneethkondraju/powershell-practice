param (
    [Parameter(Mandatory = $true)]
    [string] $serviceName
)

# Timestamp Function
function Get-Timestamp {
    return (Get-Date -Format "yyyy-MM-dd HH:mm:ss")
}

# Log Setup
$logPath = 'C:\Scripts\Logs\Task2'
$logFile = "$logPath\task2.log"

try {
    if (-not (Test-Path -Path $logPath)) {
        New-Item -ItemType Directory -Path $logPath -ErrorAction Stop | Out-Null
        New-Item -ItemType File -Path $logFile -ErrorAction Stop | Out-Null
    }
}
catch {
    throw "[$(Get-Timestamp)] - [FATAL] Could not initialize logging: $($_.Exception.Message)"
}

# Logging Helper
function Write-Log {
    param ([string]$level, [string]$message)
    Add-Content -Path $logFile -Value "[$level] $(Get-Timestamp) - $message"
}

# Validate Service
try {
    $service = Get-Service -Name $serviceName -ErrorAction Stop
}
catch {
    Write-Log -level "ERROR" -message "Service '$serviceName' not found. Exiting."
    exit 1
}

# Check and Restart Logic
try {
    if ($service.Status -ne 'Running') {
        Write-Log "WARN" "$serviceName is not running. Attempting restart."

        $restartSuccess = $false
        for ($i = 1; $i -le 2; $i++) {
            try {
                Start-Service -Name $serviceName -ErrorAction Stop
                Start-Sleep -Seconds 3
                $currentStatus = (Get-Service -Name $serviceName).Status

                if ($currentStatus -eq 'Running') {
                    Write-Log "INFO" "$serviceName restarted successfully on attempt $i."
                    $restartSuccess = $true
                    break
                } else {
                    Write-Log "ERROR" "Attempt $i: Restart failed. Status is $currentStatus."
                }
            }
            catch {
                Write-Log "ERROR" "Attempt $i failed: $($_.Exception.Message)"
            }
        }

        # Email alert if failed
        if (-not $restartSuccess) {
            $smtpConfig = Get-Content -Path "C:\Scripts\Config\smtp.json" | ConvertFrom-Json

            $mailParams = @{
                From       = $smtpConfig.EmailSettings.From
                To         = $smtpConfig.EmailSettings.To
                Subject    = "[$serviceName] Restart Failure"
                Body       = "[$serviceName] failed to restart on $(Get-Date). Please investigate."
                SmtpServer = $smtpConfig.EmailSettings.Host
                Port       = $smtpConfig.EmailSettings.Port
                Credential = New-Object System.Management.Automation.PSCredential ($smtpConfig.EmailSettings.Username, (ConvertTo-SecureString $smtpConfig.EmailSettings.Password -AsPlainText -Force))
                UseSsl     = $true
            }

            Send-MailMessage @mailParams
            Write-Log "ALERT" "Restart failed. Email alert sent."
        }
    } else {
        Write-Log "INFO" "$serviceName is running normally."
    }
}
catch {
    Write-Log "ERROR" "Unhandled exception: $($_.Exception.Message)"
    throw
}