# TraceHunt

**TraceHunt** is a lightweight, real-time cyber forensics tool for artifact tracking, log monitoring, and court-ready evidence reporting—without requiring complex setup or programming.

## Project Contents
- `TraceHunt.bat` — Launch script for TraceHunt
- `TraceHunt.ps1` — PowerShell script that performs the forensic analysis

## 🛠 Requirements
- Windows 10 or later  
- PowerShell (v5.0 or later)  
- Administrator privileges  
- Internet connection (if external tools or updates are needed)  

##  How to Run

1. **Download or clone the repository.**

2. **Right-click `TraceHunt.bat` and select _Run as Administrator_**

   This will automatically invoke `TraceHunt.ps1` with the required permissions.

> If execution policies block the script, you may need to enable PowerShell scripts:
```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
