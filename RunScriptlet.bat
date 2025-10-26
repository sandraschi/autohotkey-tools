@echo off
set SCRIPT_NAME=%1
set AHK_PATH="C:\Program Files\AutoHotkey\AutoHotkey.exe"
set SCRIPT_PATH="D:\Dev\repos\autohotkey-test\scriptlets\%SCRIPT_NAME%"

if exist %SCRIPT_PATH% (
    start "" %AHK_PATH% %SCRIPT_PATH%
    echo SUCCESS: Started %SCRIPT_NAME%
) else (
    echo ERROR: Script not found - %SCRIPT_NAME%
)
