@echo off
REM Batch script to run the AutoHotkey v2 Compatibility Scanner
REM This is a simple wrapper that calls the PowerShell script

echo.
echo =============================================
echo AutoHotkey v2 Compatibility Scanner
echo =============================================
echo.

REM Check if PowerShell is available
powershell.exe -Command "& { Write-Host 'Running compatibility scan...'; Get-Command autohotkey.exe -ErrorAction Stop | Out-Null; & '%~dp0run_compatibility_scan.ps1' }"

REM Check exit code
if %ERRORLEVEL% EQU 0 (
    echo.
    echo Scan completed successfully!
) else (
    echo.
    echo Scan completed with issues. Check the report file for details.
)

pause
