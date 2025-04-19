## 📁 Task 3 - PowerShell Script: Disk Usage Monitor with Email Alert
🔧 Description
This PowerShell script monitors disk usage on a specified drive and sends an alert email if the usage crosses a specified threshold (either in GB or %). It also captures the top space-consuming files and folders, logs the activity, and is designed to be compatible with Windows Task Scheduler for automation.

## 📁 Script Files

| File Name                | Description                                |
|-------------------------|--------------------------------------------|
| `task3.ps1`   | My version                |
| `task3_chatgptEnhanced.ps1` | ChatGPT SRE-focused version with cleanup logic |

## 🚀 Features
✅ Threshold-based monitoring (in GB or %)

✅ Automatic email alerts with top space consumers attached

✅ Detailed logging

✅ Modular functions for scalability

✅ Customizable via parameters and JSON config

✅ Scheduler-friendly design (supports headless/automated execution)

## 📦 Prerequisites
PowerShell 5.0+

SMTP credentials for sending email

Administrator privileges (for full disk access in some environments)

## 👥 Credits

- ✍️ Script: Praneeth Kondraju

- 🤖 AI-Powered Review & Enhancements: ChatGPT

## ⚖️ License
This project is licensed under the MIT License