# 💾 PowerShell Task 1 – Directory Backup Script

This PowerShell script automates the process of backing up a specified directory by compressing it into a `.zip` file and storing it in a backup location. The backup file is named using a timestamp for easy identification, and all operations are logged in a structured log file.

## 🛠️ Use Case

- Automate **backup creation** for important directories.
- Maintain an **audit log** of when backups were created.
- Use within **Tidal Workload Automation** for scheduled jobs.
- Useful for **Disaster Recovery (DR)** scenarios.
- Applies to **Site Reliability Engineering (SRE)** and **automation-first** approaches.

---

## 📁 Script Files

| File Name                | Description                                |
|-------------------------|--------------------------------------------|
| `task1.ps1`   | My version                |
| `task1_chatgpt.ps1`     | ChatGPT version aligned strictly with task   |
| `task1_chatgptEnhanced.ps1` | ChatGPT SRE-focused version with cleanup logic |

---

## ⚙️ Parameters

| Name    | Description                              | Required | Example                  |
|---------|------------------------------------------|----------|--------------------------|
| `path`  | Full path of the directory to be backed up | ✅ Yes   | `C:\Projects\MyApp`     |

---

## 📦 Output

- **Backup File**: ZIP archive named as `task1_yyyyMMdd_HHmmss.zip`
- **Backup Location**: `C:\Backups\Task1\` (you can change this in the script)
- **Log File**: `task1.log` saved at `C:\Logs\Task1\`

---

## 🚀 Example Usage

### Run from PowerShell
``` 
.\task1_chatgpt.ps1 -path "C:\Projects\MyApp" 
```

## 📓 Sample Log Output
```
16-04-2025 09:34:11 - [INFO] Creating Backup Directory
16-04-2025 09:34:11 - [INFO] Backup Directory Created Successfully
16-04-2025 09:34:11 - [INFO] Starting Compression
16-04-2025 09:34:16 - [INFO] Compression Completed Successfully
```

## 🧠 What You Learn from This Task
✅ Accepting input parameters in PowerShell

✅ Creating and verifying directories/files

✅ Using timestamps for naming backups

✅ Writing logs with structured info and error handling

✅ Using Compress-Archive for zipping directories

## 🤖 About
This task was part of a PowerShell scripting learning roadmap focused on:

- Automation

- Disaster Recovery

- Tidal Workload Automation Integration

- SRE Mindset & Best Practices

## 👥 Credits

- ✍️ Script: Praneeth Kondraju

- 🤖 AI-Powered Review & Enhancements: ChatGPT

## ⚖️ License

This project is licensed under the MIT License.