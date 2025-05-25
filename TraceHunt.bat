@echo off
title Run Forensic Data Collector
echo Collecting system and user artifacts...

powershell -ExecutionPolicy Bypass -File "E:\TraceHunt.ps1"

echo.
echo Collection complete. Press any key to close.
pause
