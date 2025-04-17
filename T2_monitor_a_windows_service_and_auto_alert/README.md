# 🔧 Task 2 - Windows Service Monitor & Auto-Restart Script (PowerShell)

## 🗂️ Description

This PowerShell script monitors a given Windows service. If the service is not running, it attempts to restart the service twice. If both attempts fail, an email alert is sent to notify administrators.

## 📁 Script Files

| File Name                | Description                                |
|-------------------------|--------------------------------------------|
| `task2.ps1`   | My version                |
| `task2_chatgptEnhanced.ps1` | ChatGPT SRE-focused version with cleanup logic |

## 💡 Features

- Accepts service name as a parameter
- Logs all actions with timestamps to a log file
- Automatically creates log folder and file if not present
- Retries restarting the service up to 2 times
- Sends email if the restart fails
- Externalizes SMTP settings via JSON config file
- Production-friendly design for DR and SRE scenarios

## 🚀 Usage

```
.\task2.ps1 -serviceName 'YourServiceName'
```
🔐 Ensure the script is run with administrative privileges.

## 🧪 Sample Log Output
```
17-04-2025 21:53:53 - [ERROR] WMPNetworkSvc is not running.
17-04-2025 21:53:53 - [INFO] Peforming restart of WMPNetworkSvc.
17-04-2025 21:53:53 - [INFO] Attempted restart of WMPNetworkSvc.
17-04-2025 21:53:53 - [INFO] Checking status of WMPNetworkSvc.
17-04-2025 21:53:53 - [INFO] Restart is successful and WMPNetworkSvc is running.
```
## 🧠 What You Learn from This Task

✅ How to use `param()` in PowerShell to make scripts reusable and user-friendly

✅ Creating structured log files with timestamped entries for observability

✅ Writing conditional logic to validate and manage Windows services

✅ Implementing retry logic for fault-tolerance

✅ Sending email alerts using external SMTP configurations (secure design)

✅ Using `ConvertFrom-Json` and `SecureString` for handling credentials

✅ Designing real-world scripts that align with Disaster Recovery (DR) and Site Reliability Engineering (SRE) principles


## 👥 Credits

- ✍️ Script: Praneeth Kondraju

- 🤖 AI-Powered Review & Enhancements: ChatGPT

## ⚖️ License
This project is licensed under the MIT License

