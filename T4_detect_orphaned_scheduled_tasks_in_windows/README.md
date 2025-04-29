# PowerShell Script - Detect Orphaned Scheduled Tasks

## 📜 Description
This PowerShell script proactively identifies **Scheduled Tasks** in Windows where the configured **Action executable path** (script, batch file, or EXE) no longer exists on disk, commonly called "**Orphaned Tasks**".  
It logs the details and sends an **email alert** if orphaned tasks are found, aligning with best practices for **Site Reliability Engineering (SRE)** and **Disaster Recovery (DR)**.

---

## ⚙️ Features
- Detects tasks with missing script/executable paths
- Skips system tasks like Microsoft default entries
- Logs findings with timestamps
- Sends an email alert with orphaned tasks as attachment
- Modular design with error handling
- Expandable exclusions and settings

---

## 🛠 Parameters

| Name           | Description                             | Default Value        |
|----------------|-----------------------------------------|----------------------|
| `logPath`      | Directory where log files will be stored | `'PATH\TO\DIRECTORY'` |
| `logFile`      | Full path for the log file               | `"$logPath\Orphaned_Scheduled_Tasks_Log.log"` |
---

## 📂 SMTP Settings (settings.json)
Sample JSON file for email configuration:

```json
{
  "EmailSettings": {
    "From": "you@example.com",
    "To": "receiver@example.com",
    "Host": "smtp.example.com",
    "Port": 587,
    "Username": "smtp-user",
    "Password": "smtp-password"
  }
}
```
## 🚀 Usage Example
```
.\Detect-OrphanedTasks.ps1 -logPath "C:\Logs" -logFile "C:\Logs\Orphaned_Scheduled_Tasks_Log.log"
```

## 🧠 Key Learnings
- Scheduled Task Management with PowerShell
- File existence validation
- Modular logging and structured output
- Secure credential handling for emails
- Proactive monitoring strategy for SRE and DR

## 📦 Prerequisites
- PowerShell 5.0+

- SMTP credentials for sending email

- Administrator privileges (for full disk access in some environments)

## 👥 Credits

- ✍️ Script: Praneeth Kondraju

- 🤖 AI-Powered Review: ChatGPT

## ⚖️ License
This project is licensed under the MIT License
