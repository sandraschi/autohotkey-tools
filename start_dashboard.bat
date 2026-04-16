@echo off
cd /d "%~dp0"
echo AHK Control Tower - Starting dashboard...
powershell -ExecutionPolicy Bypass -File "%~dp0start_dashboard.ps1"
pause
