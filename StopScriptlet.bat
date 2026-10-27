@echo off
set SCRIPT_NAME=%1
set PROCESS_NAME=%SCRIPT_NAME:.ahk=.exe%

taskkill /F /IM "%PROCESS_NAME%" 2>nul
if %ERRORLEVEL% EQU 0 (
    echo SUCCESS: Stopped %SCRIPT_NAME%
) else (
    echo INFO: %SCRIPT_NAME% was not running
)
