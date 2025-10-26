@echo off
set SCRIPT_NAME=%1
set AHK_PATH="C:\Program Files\AutoHotkey\v2\AutoHotkey64.exe"
set SCRIPT_DIR=D:\Dev\repos\autohotkey-test\scriptlets
set SCRIPT_PATH=%SCRIPT_DIR%\%SCRIPT_NAME%

if exist %SCRIPT_PATH% (
    cd /d %SCRIPT_DIR%
    start "" %AHK_PATH% %SCRIPT_PATH%
    echo SUCCESS: Started %SCRIPT_NAME%
) else (
    echo ERROR: Script not found - %SCRIPT_NAME%
)
