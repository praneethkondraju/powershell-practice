param (
    [Parameter(Mandatory = $true)]
    [string]
    $serviceName
)

<#
Defining LogPath and LogFile
Checking whether folder and file exists. Else create it.
#>
$logPath = 'PATH\TO\DIRECTORY'
$logFile = "$LogPath\task2.log"
try {
    if (-not(Test-Path -Path $logPath -ErrorAction Stop )) {
        New-Item -ItemType Directory -Path $logPath -ErrorAction Stop | Out-Null
        New-Item -ItemType File -Path $logFile -ErrorAction Stop | Out-Null
        Write-Output "Log path created"
    }
}
catch {
    $errorMsg = $_.Exception.Message
    Write-Output $errorMsg
    throw
}

<#
Check whether service status.
Restart if it is not running.
If restart fails send email
#>
try {
    if ($(Get-Service -Name $serviceName).Status -ne 'Running') {
        Add-Content -Path $logFile -Value "$(Get-Date -Format 'dd/MM/yyyy HH:mm:ss') - [ERROR] $serviceName is not running."
        Add-Content -Path $logFile -Value "$(Get-Date -Format 'dd/MM/yyyy HH:mm:ss') - [INFO] Peforming restart of $serviceName."

        for ($i = 1; $i -le 2; $i++) {
            Start-Service -Name $serviceName -ErrorAction Stop

            Add-Content -Path $logFile -Value "$(Get-Date -Format 'dd/MM/yyyy HH:mm:ss') - [INFO] Attempting restart for $i time of $serviceName."
            Add-Content -Path $logFile -Value "$(Get-Date -Format 'dd/MM/yyyy HH:mm:ss') - [INFO] Status of $serviceName is $(Get-Service -Name $serviceName).Status."

            if ($(Get-Service -Name $serviceName).Status -eq 'Running') {
                Add-Content -Path $logFile -Value "$(Get-Date -Format 'dd/MM/yyyy HH:mm:ss') - [INFO] Restart is Successful for  $serviceName."
                break
            }

            else {
                Add-Content -Path $logFile -Value "$(Get-Date -Format 'dd/MM/yyyy HH:mm:ss') - [ERROR] Restart failed for $i time for $serviceName"
            }
        }
        
        if ($(Get-Service -Name $serviceName).Status -ne 'Running') {
            $smtpConfig = Get-Content -Path "path\to\your\settings.json" | ConvertFrom-Json
            $sendEmailSplat = @{
                From = $smtpConfig.EmailSettings.Host.From
                To = 'recepient@emailprovider.com'
                Subject = "$serviceName restart failed"
                Body = "$serviceName restart did not help the bringing up. Please act on the issue."
                SmtpServer = $smtpConfig.EmailSettings.Host
                Port = $smtpConfig.EmailSettings.Port
                Credential = New-Object System.Management.Automation.PSCredential ($smtpConfig.EmailSettings.Username, (ConvertTo-SecureString $smtpConfig.EmailSettings.Password -AsPlainText -Force))
                UseSsl = $true
                ErrorAction = 'Stop'
            }

            Send-MailMessage @sendEmailSplat
            Add-Content -Path $logFile -Value "$(Get-Date -Format 'dd/MM/yyyy HH:mm:ss') - [INFO] Email sent successfully."
        }

        Add-Content -Path $logFile -Value "$(Get-Date -Format 'dd/MM/yyyy HH:mm:ss') - [INFO] Restart is successful and $serviceName is running."
    }
}
catch {
    $errorMsg = $_.Exception.Message
    Add-Content -Path $logFile -Value "$(Get-Date -Format 'dd/MM/yyyy HH:mm:ss') - [ERROR] Script failed: $errorMsg"
    throw
}