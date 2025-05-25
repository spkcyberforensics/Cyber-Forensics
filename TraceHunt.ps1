# Set the backup location (Change the drive letter if needed)
$drive = "E:"
$backupFolder = "$drive\System_Logs"

# Check if USB drive is connected
if (!(Test-Path $drive)) {
    Write-Host "USB drive not found! Please insert a USB drive."
    Pause
    Exit
}

# Create backup folder if it doesn't exist
if (!(Test-Path $backupFolder)) {
    New-Item -Path $backupFolder -ItemType Directory
}

# Get current timestamp for filenames
$timestamp = Get-Date -Format "yyyy-MM-dd_HH-mm-ss"

### ---- 1. Windows Event Logs ----
Write-Host "Backing up Windows Event Logs..."
wevtutil epl System "$backupFolder\SystemLog_$timestamp.evtx"
wevtutil epl Application "$backupFolder\ApplicationLog_$timestamp.evtx"
wevtutil epl Security "$backupFolder\SecurityLog_$timestamp.evtx"

### ---- 2. Chrome Browser History ----
Write-Host "Backing up Chrome history..."
$chromeUserData = "$env:LOCALAPPDATA\Google\Chrome\User Data\Default"
$chromeHistory = Join-Path $chromeUserData "History"
if (Test-Path $chromeHistory) {
    Copy-Item $chromeHistory -Destination "$backupFolder\Chrome_History_$timestamp" -Force
}
$chromeCrashReports = "$env:LOCALAPPDATA\Google\Chrome\User Data\Crash Reports"
if (Test-Path $chromeCrashReports) {
    Copy-Item $chromeCrashReports -Destination "$backupFolder\ChromeCrashReports_$timestamp" -Recurse -Force
}

### ---- 3. Edge Browser History ----
$edgeHistory = "$env:LOCALAPPDATA\Microsoft\Edge\User Data\Default\History"
if (Test-Path $edgeHistory) {
    Copy-Item $edgeHistory -Destination "$backupFolder\Edge_History_$timestamp" -Force
}

### ---- 4. Registry Snapshots ----
reg export HKLM\SYSTEM "$backupFolder\HKLM_SYSTEM_$timestamp.reg" /y
reg export HKLM\SOFTWARE "$backupFolder\HKLM_SOFTWARE_$timestamp.reg" /y
reg export HKCU "$backupFolder\HKCU_$timestamp.reg" /y

### ---- 5. Recent Files ----
$recentFolder = "$env:APPDATA\Microsoft\Windows\Recent"
Copy-Item $recentFolder -Destination "$backupFolder\RecentFiles_$timestamp" -Recurse -Force

### ---- 6. Prefetch Files ----
$prefetchPath = "C:\Windows\Prefetch"
if (Test-Path $prefetchPath) {
    Copy-Item $prefetchPath -Destination "$backupFolder\Prefetch_$timestamp" -Recurse -Force
}

### ---- 7. Jump Lists ----
$jumpListsPath = "$env:APPDATA\Microsoft\Windows\Recent\AutomaticDestinations"
if (Test-Path $jumpListsPath) {
    Copy-Item $jumpListsPath -Destination "$backupFolder\JumpLists_$timestamp" -Recurse -Force
}

### ---- 8. Autoruns ----
reg query HKCU\Software\Microsoft\Windows\CurrentVersion\Run > "$backupFolder\Run_HKCU_$timestamp.txt"
reg query HKLM\Software\Microsoft\Windows\CurrentVersion\Run > "$backupFolder\Run_HKLM_$timestamp.txt"

$startupPath = "$env:APPDATA\Microsoft\Windows\Start Menu\Programs\Startup"
if (Test-Path $startupPath) {
    Copy-Item $startupPath -Destination "$backupFolder\StartupFolder_$timestamp" -Recurse -Force
}

### ---- 9. Firewall Logs ----
$fwLogPath = "C:\Windows\System32\LogFiles\Firewall\pfirewall.log"
if (Test-Path $fwLogPath) {
    Copy-Item $fwLogPath -Destination "$backupFolder\FirewallLog_$timestamp.log" -Force
}

### ---- 10. Malware Indicators (Suspicious Files) ----
$tempPaths = @("$env:TEMP", "C:\Temp", "C:\Users\*\AppData\Local\Temp")
$suspicious = foreach ($path in $tempPaths) {
    Get-ChildItem -Path $path -Recurse -Include *.exe, *.dll -ErrorAction SilentlyContinue |
    Where-Object { $_.Name -match '^[a-z]{5,}\d{3,}\.exe$' -or $_.LastWriteTime -gt (Get-Date).AddDays(-2) }
}
$suspicious | Select-Object FullName, LastWriteTime |
Export-Csv "$backupFolder\SuspiciousFiles_$timestamp.csv" -NoTypeInformation

### ---- 11. RAM Indicators (Running Processes) ----
Get-Process | Sort-Object CPU -Descending | Select-Object Name, Id, CPU, StartTime |
Export-Csv "$backupFolder\RunningProcesses_$timestamp.csv" -NoTypeInformation

### ---- 12. Windows Mail App ----
$mailAppPath = "$env:LOCALAPPDATA\Packages\microsoft.windowscommunicationsapps*"
if (Test-Path $mailAppPath) {
    Copy-Item $mailAppPath -Destination "$backupFolder\MailAppData_$timestamp" -Recurse -Force
}

### ---- 13. WhatsApp Desktop Data ----
$whatsappPath = "$env:APPDATA\WhatsApp"
if (Test-Path $whatsappPath) {
    Copy-Item $whatsappPath -Destination "$backupFolder\WhatsApp_$timestamp" -Recurse -Force
    Write-Host "WhatsApp data backed up."
}


Write-Host "`nAll forensic artifacts collected successfully!"
Pause
