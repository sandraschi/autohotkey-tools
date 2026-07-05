; ==============================================================================
; ScriptletCOMBridge.ahk
; HTTP Bridge for HTML Launcher to execute AutoHotkey scriptlets
; Version: 1.0
; Author: Sandra (with Claude assistance)
; ==============================================================================

#Requires AutoHotkey v2.0+
#SingleInstance Force
#Warn All, Off
#Warn LocalSameAsGlobal, Off

SendMode "Input"
SetWorkingDir(A_ScriptDir)

; ==============================================================================
; INITIALIZATION
; ==============================================================================

; Setup tray menu
A_TrayMenu.Delete()  ; Clear standard menu
A_TrayMenu.Add("Show HTML Launcher", ShowLauncher)
A_TrayMenu.Add("Reload Bridge", ReloadBridge)
A_TrayMenu.Add("Exit Bridge", ExitBridge)
A_TrayMenu.Default := "Show HTML Launcher"
A_TrayMenu.Tip := "Scriptlet COM Bridge v1.0"

; Initialize server
StartHTTPServer()

; ==============================================================================
; HTTP SERVER FUNCTIONS
; ==============================================================================

StartHTTPServer() {
    try {
        ; Create helper batch files first
        CreateHelperScripts()
        
        ; Create PowerShell server script
        if (!CreatePowerShellServer()) {
            LogActivity("ERROR: Failed to create PowerShell server script")
            MsgBox("Failed to create PowerShell server script. Check bridge.log for details.", "Error", "0x10")
            return
        }
        
        ; Start PowerShell HTTP server
        tempPath := EnvGet("TEMP") '\scriptlet_server.ps1'
        LogActivity("Starting PowerShell server from: " . tempPath)
        
        ; Check if server is already running and kill it
        try {
            ; Kill any existing PowerShell processes running the server
            Run('taskkill /f /im powershell.exe /fi "WINDOWTITLE eq scriptlet_server*"', , 'Hide')
            
            ; Try to kill processes using port 10744 (with error handling for privilege issues)
            Run('powershell -Command "try { Get-NetTCPConnection -LocalPort 10744 | ForEach-Object { if ($_.OwningProcess -ne 4) { Stop-Process -Id $_.OwningProcess -Force -ErrorAction SilentlyContinue } } } catch { Write-Host \"Port cleanup completed with some errors\" }"', , 'Hide')
            
            Sleep(2000)
        } catch {
            ; Ignore kill errors
        }
        
        ; Start the server
        try {
            LogActivity("Executing PowerShell server script...")
            Run('powershell.exe -WindowStyle Hidden -ExecutionPolicy Bypass -File "' tempPath '"', , 'Hide')
            LogActivity("PowerShell server command executed")
        } catch as e {
            LogActivity("ERROR: Failed to start PowerShell server: " . e.Message)
            MsgBox("Failed to start PowerShell server: " . e.Message, "Error", "0x10")
            return
        }
        
        ; Wait a moment for server to start
        Sleep(2000)
        LogActivity("Waiting for server to start...")
        
        ; Check if server started successfully
        try {
            ; Test if server is responding
            Run('powershell.exe -Command "try { Invoke-WebRequest -Uri http://127.0.0.1:10744/scriptlets -TimeoutSec 5 | Out-Null; Write-Host SUCCESS } catch { Write-Host FAILED }"', , 'Hide')
        } catch {
            ; Server test failed, but continue
        }
        
        TrayTip('HTTP server started on port 10744', 'Scriptlet Bridge', '1')
        
    } catch as e {
        MsgBox('Failed to start HTTP server: ' . e.Message, 'Error', '0x10')
    }
}

CreatePowerShellServer() {
    ; Delete existing server script
    tempPath := EnvGet("TEMP") '\scriptlet_server.ps1'
    try {
        FileDelete(tempPath)
        LogActivity("Deleted existing PowerShell script: " . tempPath)
    } catch as e {
        LogActivity("Warning: Could not delete existing script: " . e.Message)
    }
    
    ; Define the PowerShell script content using a continuation section
    psScript := ''
    psScript .= "`$port = 10744`n"
    psScript .= "`$listener = New-Object System.Net.HttpListener`n"
    psScript .= "`$listener.Prefixes.Add('http://127.0.0.1:' + `$port + '/')`n"
    psScript .= "try { `$listener.Start(); Write-Host 'HTTP server started on port ' + `$port } catch { Write-Host 'Failed to bind port ' + `$port + ': ' + `$_.Exception.Message; exit 1 }`n"
    psScript .= "while (`$listener.IsListening) {`n"
    psScript .= "    try {`n"
    psScript .= "        `$context = `$listener.GetContext()`n"
    psScript .= "        `$request = `$context.Request`n"
    psScript .= "        `$response = `$context.Response`n`n"
    psScript .= "        # Enable CORS`n"
    psScript .= "        `$response.Headers.Add('Access-Control-Allow-Origin', '*')`n"
    psScript .= "        `$response.Headers.Add('Access-Control-Allow-Methods', 'GET, POST, OPTIONS')`n"
    psScript .= "        `$response.Headers.Add('Access-Control-Allow-Headers', 'Content-Type')`n`n"
    psScript .= "        if (`$request.HttpMethod -eq 'OPTIONS') {`n"
    psScript .= "            `$response.StatusCode = 200`n"
    psScript .= "            `$response.Close()`n"
    psScript .= "            continue`n"
    psScript .= "        }`n`n"
    psScript .= "        `$url = `$request.Url.AbsolutePath`n"
    psScript .= "        `$result = 'Unknown command'`n`n"
    psScript .= "        if (`$url -match '/run/(.+)') {`n"
    psScript .= "            `$scriptName = `$matches[1]`n"
    psScript .= "            `$scriptPath = Join-Path '" . A_ScriptDir . "\scriptlets' `$scriptName`n"
    psScript .= "            `$ahkExe = '" . A_AhkPath . "'`n"
    psScript .= "            if (Test-Path `$scriptPath) {`n"
    psScript .= "                Start-Process -FilePath `$ahkExe -ArgumentList `$scriptPath`n"
    psScript .= "                `$result = 'SUCCESS: Started ' + `$scriptName`n"
    psScript .= "            } else {`n"
    psScript .= "                `$result = 'ERROR: Scriptlet not found - ' + `$scriptName`n"
    psScript .= "            }`n"
    psScript .= "        } elseif (`$url -match '/stop/(.+)') {`n"
    psScript .= "            `$scriptName = `$matches[1]`n"
    psScript .= "            `$killed = 0`n"
    psScript .= "            Get-CimInstance Win32_Process -Filter " . Chr(34) . "Name='AutoHotkey64.exe'" . Chr(34) . " -ErrorAction SilentlyContinue | Where-Object { `$_.CommandLine -match `$scriptName } | ForEach-Object {`n"
    psScript .= "                Stop-Process -Id `$_.ProcessId -Force -ErrorAction SilentlyContinue`n"
    psScript .= "                `$killed++`n"
    psScript .= "            }`n"
    psScript .= "            `$result = if (`$killed -gt 0) { 'SUCCESS: Stopped ' + `$scriptName } else { 'INFO: ' + `$scriptName + ' was not running' }`n"
        psScript .= "        } elseif (`$url -eq '/') {`n"
        psScript .= "            `$result = 'Scriptlet Bridge Server v2.0 - Use /status, /scriptlets, /exit endpoints'`n"
        psScript .= "        } elseif (`$url -eq '/dashboard') {`n"
        psScript .= "            `$htmlPath = '" . A_ScriptDir . "\dashboard.html'`n"
        psScript .= "            try {`n"
        psScript .= "                `$html = Get-Content -Path `$htmlPath -Raw -Encoding UTF8`n"
        psScript .= "                `$htmlBytes = [System.Text.Encoding]::UTF8.GetBytes(`$html)`n"
        psScript .= "                `$response.ContentType = 'text/html; charset=utf-8'`n"
        psScript .= "                `$response.ContentLength64 = `$htmlBytes.Length`n"
        psScript .= "                `$response.OutputStream.Write(`$htmlBytes, 0, `$htmlBytes.Length)`n"
        psScript .= "                `$response.Close()`n"
        psScript .= "            } catch {`n"
        psScript .= "                `$result = 'ERROR: Could not read dashboard.html'`n"
        psScript .= "            }`n"
        psScript .= "            continue`n"
    psScript .= "        } elseif (`$url -eq '/status') {`n"
    psScript .= "            `$result = 'Server running'`n"
        psScript .= "        } elseif (`$url -eq '/exit') {`n"
        psScript .= "            `$result = 'Server shutting down...'`n"
        psScript .= "            Write-Host 'Received exit command - shutting down server'`n"
        psScript .= "            `$listener.Stop()`n"
        psScript .= "            break`n"
        psScript .= "        } elseif (`$url -eq '/restart') {`n"
        psScript .= "            `$result = 'Restarting bridge...'`n"
        psScript .= "            try {`n"
        psScript .= "                `$rb = [System.Text.Encoding]::UTF8.GetBytes(`$result)`n"
        psScript .= "                `$response.ContentLength64 = `$rb.Length`n"
        psScript .= "                `$response.OutputStream.Write(`$rb, 0, `$rb.Length)`n"
        psScript .= "                `$response.Close()`n"
        psScript .= "            } catch {}`n"
        psScript .= "            Set-Content -Path ([System.IO.Path]::Combine(`$env:TEMP, 'ahk_bridge_restart.flag')) -Value '1' -Encoding UTF8`n"
        psScript .= "            `$listener.Stop()`n"
        psScript .= "            break`n"
        psScript .= "        } elseif (`$url -eq '/scriptlets') {`n"
    psScript .= "            `$scriptletsDir = '" . A_ScriptDir . "\scriptlets'`n"
    psScript .= "            `$scriptlets = @()`n"
    psScript .= "            # Get all running AutoHotkey processes once`n"
    psScript .= "            `$runningScripts = @()`n"
    psScript .= "            try {`n"
    psScript .= "                `$ahkProcesses = Get-WmiObject Win32_Process -Filter 'name=''AutoHotkey64.exe''' -ErrorAction SilentlyContinue`n"
    psScript .= "                if (`$ahkProcesses) {`n"
    psScript .= "                    foreach (`$proc in `$ahkProcesses) {`n"
    psScript .= "                        if (`$proc.CommandLine) {`n"
    psScript .= "                            `$runningScripts += `$proc.CommandLine`n"
    psScript .= "                        }`n"
    psScript .= "                    }`n"
    psScript .= "                }`n"
    psScript .= "            } catch {`n"
    psScript .= "                # If WMI fails, continue without running status`n"
    psScript .= "            }`n"
    psScript .= "            if (Test-Path `$scriptletsDir) {`n"
    psScript .= "                `$files = Get-ChildItem `$scriptletsDir -Filter '*.ahk' -Recurse | Where-Object { `$_.FullName -notlike '*\v1\*' -and `$_.FullName -notlike '*\lib\*' }`n"
    psScript .= "                foreach (`$file in `$files) {`n"
    psScript .= "                    `$category = 'utilities'`n"
    psScript .= "                    `$description = ''`n"
    psScript .= "                    `$filename = `$file.BaseName.ToLower()`n"
    psScript .= "                    `n"
    psScript .= "                    # Extract description from file header`n"
    psScript .= "                    try {`n"
    psScript .= "                        `$lines = Get-Content `$file.FullName -TotalCount 50`n"
    psScript .= "                        `$content = `$lines -join [Environment]::NewLine`n"
    psScript .= "                        `$description = ''`n"
    psScript .= "                        # Match all @description lines (with semicolon prefix)`n"
    psScript .= "                        if (`$content -match '(?m);\s*@description:\s*(.+?)(?:\r?\n|$)') {`n"
    psScript .= "                            `$allMatches = [regex]::Matches(`$content, '(?m);\s*@description:\s*(.+?)(?:\r?\n|$)')`n"
    psScript .= "                            `$descriptionParts = @()`n"
    psScript .= "                            foreach (`$match in `$allMatches) {`n"
    psScript .= "                                `$descriptionParts += `$match.Groups[1].Value.Trim()`n"
    psScript .= "                            }`n"
    psScript .= "                            `$description = (`$descriptionParts -join ' ')`n"
    psScript .= "                        }`n"
    psScript .= "                        # Fallback: try without semicolon`n"
    psScript .= "                        if ([string]::IsNullOrWhiteSpace(`$description) -and `$content -match '@description:\s*(.+)') {`n"
    psScript .= "                            `$description = `$matches[1].Trim()`n"
    psScript .= "                        }`n"
    psScript .= "                        # If still empty, create from filename`n"
    psScript .= "                        if ([string]::IsNullOrWhiteSpace(`$description)) {`n"
    psScript .= "                            `$description = 'Run ' + `$file.BaseName.Replace('_', ' ').Replace('-', ' ')`n"
    psScript .= "                        }`n"
    psScript .= "                    } catch {`n"
    psScript .= "                        `$description = 'Run ' + `$file.BaseName.Replace('_', ' ').Replace('-', ' ')`n"
    psScript .= "                    }`n`n"
    psScript .= "                    if (`$filename -like '*office*' -or `$filename -like '*outlook*' -or `$filename -like '*onenote*' -or `$filename -like '*teams*' -or `$filename -like '*word*' -or `$filename -like '*excel*') { `$category = 'office' }`n"
    psScript .= "                    elseif (`$filename -like '*game*' -or `$filename -like '*chess*' -or `$filename -like '*snake*' -or `$filename -like '*tetris*' -or `$filename -like '*pong*' -or `$filename -like '*minesweeper*' -or `$filename -like '*sudoku*' -or `$filename -like '*pacman*' -or `$filename -like '*frogger*' -or `$filename -like '*qbert*' -or `$filename -like '*mini_games*' -or `$filename -like '*breakout*' -or `$filename -like '*memory*' -or `$filename -like '*classic_*' -or `$filename -like '*fun_games*' -or `$filename -like '*game_starter*') { `$category = 'games' }`n"
    psScript .= "                    elseif (`$filename -like '*prank*' -or `$filename -like '*corporate*' -or `$filename -like '*fun*' -or `$filename -like '*annoying*' -or `$filename -like '*sound*') { `$category = 'fun' }`n"
    psScript .= "                    elseif (`$filename -like '*git*' -or `$filename -like '*repo*' -or `$filename -like '*code*' -or `$filename -like '*debug*' -or `$filename -like '*linter*' -or `$filename -like '*dev*' -or `$filename -like '*mcp*') { `$category = 'development' }`n"
    psScript .= "                    elseif (`$filename -like '*system*' -or `$filename -like '*window*' -or `$filename -like '*clipboard*' -or `$filename -like '*volume*' -or `$filename -like '*media*' -or `$filename -like '*monitor*') { `$category = 'system' }`n"
    psScript .= "                    elseif (`$filename -like '*note*' -or `$filename -like '*quick*' -or `$filename -like '*text*' -or `$filename -like '*launch*' -or `$filename -like '*clipboard*' -or `$filename -like '*workflow*') { `$category = 'productivity' }`n"
    psScript .= "                    # Check if this script is running`n"
    psScript .= "                    `$isRunning = `$false`n"
    psScript .= "                    `$scriptPath = `$file.FullName`n"
    psScript .= "                    foreach (`$cmdLine in `$runningScripts) {`n"
    psScript .= "                        if (`$cmdLine -like '*`$scriptPath*') {`n"
    psScript .= "                            `$isRunning = `$true`n"
    psScript .= "                            break`n"
    psScript .= "                        }`n"
    psScript .= "                    }`n"
    psScript .= "                    `$scriptlets += @{`n"
    psScript .= "                        id = `$file.BaseName`n"
    psScript .= "                        name = `$file.BaseName -replace '_', ' ' -replace '-', ' '`n"
    psScript .= "                        description = `$description`n"
    psScript .= "                        path = `$file.FullName`n"
    psScript .= "                        category = `$category`n"
    psScript .= "                        enabled = `$true`n"
    psScript .= "                        running = `$isRunning`n"
    psScript .= "                    }`n"
    psScript .= "                }`n"
    psScript .= "            }`n"
    psScript .= "            `$scriptlets = `$scriptlets | Sort-Object -Property name`n"
    psScript .= "            `$response.ContentType = 'application/json; charset=utf-8'`n"
    psScript .= "            `$result = (`$scriptlets | ConvertTo-Json -Depth 3 -Compress)`n"
    psScript .= "        }`n`n"
    psScript .= "        `$buffer = [System.Text.Encoding]::UTF8.GetBytes(`$result)`n"
    psScript .= "        `$response.ContentLength64 = `$buffer.Length`n"
    psScript .= "        `$response.OutputStream.Write(`$buffer, 0, `$buffer.Length)`n"
    psScript .= "        `$response.Close()`n"
    psScript .= "    } catch {`n"
    psScript .= "        Write-Host 'Error: `$(`$_)'`n"
    psScript .= "        if (`$response) { `$response.Close() }`n"
    psScript .= "    }`n"
    psScript .= "}`n`n"
    psScript .= "`$listener.Stop()`n"
    
    ; Write the PowerShell script to file
    tempPath := EnvGet("TEMP") '\scriptlet_server.ps1'
    try {
        FileAppend(psScript, tempPath)
        LogActivity("Successfully created PowerShell script: " . tempPath)
        LogActivity("Script size: " . StrLen(psScript) . " characters")
    } catch as e {
        LogActivity("ERROR: Failed to create PowerShell script: " . e.Message)
        LogActivity("Temp path: " . tempPath)
        MsgBox("Failed to create PowerShell server script: " . e.Message, "Error", "0x10")
        return false
    }
    return true
}

; ==============================================================================
; HELPER SCRIPT CREATION
; ==============================================================================

CreateHelperScripts() {
    ; Create RunScriptlet.bat
    CreateRunScript()
    
    ; Create StopScriptlet.bat  
    CreateStopScript()
}

CreateRunScript() {
    batPath := A_ScriptDir '\RunScriptlet.bat'
    scriptContent := ''
    scriptContent .= '@echo off`r`n'
    scriptContent .= 'set SCRIPT_NAME=%1`r`n'
    scriptContent .= 'set AHK_PATH="' . A_AhkPath . '"`r`n'
    scriptContent .= 'set SCRIPT_PATH="' . A_ScriptDir . '\scriptlets\%SCRIPT_NAME%"`r`n`r`n'
    scriptContent .= 'if exist %SCRIPT_PATH% (`r`n'
    scriptContent .= '    start "" %AHK_PATH% %SCRIPT_PATH%`r`n'
    scriptContent .= '    echo SUCCESS: Started %SCRIPT_NAME%`r`n'
    scriptContent .= ') else (`r`n'
    scriptContent .= '    echo ERROR: Script not found - %SCRIPT_NAME%`r`n'
    scriptContent .= ')`r`n'
    
    try {
        ; Ensure we have write permissions
        if (FileExist(batPath)) {
            FileDelete(batPath)
        }
        FileAppend(scriptContent, batPath)
        
        ; Verify the file was created
        if (FileExist(batPath)) {
            LogActivity("Successfully created RunScriptlet.bat")
        } else {
            throw Error("File was not created successfully")
        }
    } catch as e {
        LogActivity("Failed to create RunScriptlet.bat: " . e.Message)
        MsgBox('Failed to create RunScriptlet.bat: ' . e.Message . '`n`nPath: ' . batPath, 'Error', '0x10')
    }
}

CreateStopScript() {
    batPath := A_ScriptDir '\StopScriptlet.bat'
    scriptContent := ''
    scriptContent .= '@echo off`r`n'
    scriptContent .= 'set SCRIPT_NAME=%1`r`n'
    scriptContent .= 'set PROCESS_NAME=%SCRIPT_NAME:.ahk=.exe%`r`n`r`n'
    scriptContent .= 'taskkill /F /IM "%PROCESS_NAME%" 2>nul`r`n'
    scriptContent .= 'if %ERRORLEVEL% EQU 0 (`r`n'
    scriptContent .= '    echo SUCCESS: Stopped %SCRIPT_NAME%`r`n'
    scriptContent .= ') else (`r`n'
    scriptContent .= '    echo INFO: %SCRIPT_NAME% was not running`r`n'
    scriptContent .= ')`r`n'
    
    try {
        ; Ensure we have write permissions
        if (FileExist(batPath)) {
            FileDelete(batPath)
        }
        FileAppend(scriptContent, batPath)
        
        ; Verify the file was created
        if (FileExist(batPath)) {
            LogActivity("Successfully created StopScriptlet.bat")
        } else {
            throw Error("File was not created successfully")
        }
    } catch as e {
        LogActivity("Failed to create StopScriptlet.bat: " . e.Message)
        MsgBox('Failed to create StopScriptlet.bat: ' . e.Message . '`n`nPath: ' . batPath, 'Error', '0x10')
    }
}

; ==============================================================================
; UTILITY FUNCTIONS
; ==============================================================================

LogActivity(message) {
    timestamp := FormatTime(A_Now, 'yyyy-MM-dd HH:mm:ss')
    try {
        FileAppend('[' timestamp '] ' message '`n', A_ScriptDir '\bridge.log')
    } catch as e {
        ; If we can't log, show a message box
        MsgBox('Failed to write to log: ' e.Message, 'Error', '0x10')
    }
}

CheckScriptRunning(scriptName) {
    processName := StrReplace(scriptName, ".ahk", ".exe")
    return ProcessExist(processName) > 0
}

; ==============================================================================
; EVENT HANDLERS
; ==============================================================================

ShowLauncher(*) {
    launcherPath := A_ScriptDir '\launcher.html'
    if (FileExist(launcherPath)) {
        try {
            Run(launcherPath)
        } catch as e {
            MsgBox('Failed to open launcher: ' e.Message, 'Error', '0x10')
        }
    } else {
        MsgBox('Launcher file not found: ' launcherPath, 'Error', '0x10')
    }
}

ReloadBridge(*) {
    LogActivity("Bridge reloaded by user")
    Reload()
}

ExitBridge(*) {
    LogActivity("Bridge shutdown by user")
    
    ; Clean up temporary files
    try {
        tempPath := EnvGet("TEMP") '\scriptlet_server.ps1'
        FileDelete(tempPath)
        FileDelete(A_ScriptDir '\RunScriptlet.bat')
        FileDelete(A_ScriptDir '\StopScriptlet.bat')
    } catch as e {
        MsgBox('Failed to clean up temporary files: ' e.Message, 'Warning', '0x30')
    }
    
    ; Stop PowerShell server processes
    try {
        RunWait('taskkill /F /IM "powershell.exe" /FI "WINDOWTITLE eq *scriptlet_server*"', , 'Hide')
    } catch as e {
        ; Continue shutdown even if we can't kill the process
    }
    
    ExitApp()
}

; ==============================================================================
; SCRIPTLET MANAGEMENT CLASS
; ==============================================================================

class ScriptletManager {
    static scriptletPath := A_ScriptDir '\scriptlets\'
    
    RunScript(scriptName, parameters := '') {
        fullPath := this.scriptletPath . scriptName
        
        if (!FileExist(fullPath)) {
            errorMsg := 'ERROR: Script not found - ' . scriptName
            LogActivity(errorMsg)
            return errorMsg
        }
        
        try {
            if (parameters != '') {
                Run('"' A_AhkPath '" "' fullPath '" ' parameters, A_ScriptDir)
            } else {
                Run('"' A_AhkPath '" "' fullPath '"', A_ScriptDir)
            }
            
            successMsg := 'SUCCESS: Started ' . scriptName
            LogActivity(successMsg)
            return successMsg
            
        } catch as e {
            errorMsg := 'ERROR: Failed to start ' . scriptName . ' - ' . e.Message
            LogActivity(errorMsg)
            return errorMsg
        }
    }
    
    StopScript(scriptName) {
        processName := StrReplace(scriptName, '.ahk', '.exe')
        
        try {
            if (ProcessExist(processName)) {
                ProcessClose(processName)
                successMsg := 'SUCCESS: Stopped ' . scriptName
                LogActivity(successMsg)
                return successMsg
            } else {
                infoMsg := 'INFO: ' . scriptName . ' was not running'
                LogActivity(infoMsg)
                return infoMsg
            }
        } catch as e {
            errorMsg := 'ERROR: Failed to stop ' . scriptName . ' - ' . e.Message
            LogActivity(errorMsg)
            return errorMsg
        }
    }
    
    ListRunningScripts() {
        running := ''
        loop files this.scriptletPath '*.ahk' {
            if (CheckScriptRunning(A_LoopFileName)) {
                running .= A_LoopFileName '|'
            }
        }
        return running
    }
    
    GetScriptInfo(scriptName) {
        fullPath := this.scriptletPath . scriptName
        
        if (!FileExist(fullPath)) {
            return 'ERROR: Script not found'
        }
        
        ; Read script for description
        try {
            content := FileRead(fullPath)
            description := 'AutoHotkey Script'
            
            ; Extract description from comments
            if (RegExMatch(content, 'i)^\s*;\s*(.+)', &match)) {
                description := match[1]
            }
            
            ; Check if running
            isRunning := CheckScriptRunning(scriptName) ? 'true' : 'false'
            
            return scriptName '|' description '|' isRunning
            
        } catch as e {
            errorMsg := 'ERROR: Failed to read script - ' . e.Message
            LogActivity(errorMsg)
            return errorMsg
        }
    }
}

; ==============================================================================
; STARTUP MESSAGE
; ==============================================================================

LogActivity("Scriptlet COM Bridge v1.0 started")
TrayTip("Bridge started successfully!`nClick tray icon to open launcher.", "Scriptlet Bridge", '1')

; Watchdog: detect restart flag written by the /restart endpoint
SetTimer(WatchdogBridge, 8000)

WatchdogBridge() {
    flagPath := EnvGet("TEMP") "\ahk_bridge_restart.flag"
    if (!FileExist(flagPath))
        return
    try {
        FileDelete(flagPath)
    } catch {
    }
    LogActivity("Restart flag detected — relaunching PS server")
    TrayTip("Restarting bridge server…", "Scriptlet Bridge", '1')
    ; Brief pause so the old listener has time to close
    Sleep(1500)
    ; Recreate the PS script and relaunch
    if (CreatePowerShellServer()) {
        tempPath := EnvGet("TEMP") "\scriptlet_server.ps1"
        Run('powershell.exe -WindowStyle Hidden -ExecutionPolicy Bypass -File "' tempPath '"', , 'Hide')
        LogActivity("PS server relaunched by watchdog")
        TrayTip("Bridge restarted successfully", "Scriptlet Bridge", '1')
    } else {
        LogActivity("Watchdog: failed to recreate PS server script")
    }
}

; ==============================================================================
; HOTKEYS
; ==============================================================================

; Exit server gracefully (Ctrl+Alt+E)
Hotkey("^!e", (*) => ExitServer())

ExitServer() {
    try {
        ; Call the exit endpoint
        Run('powershell -Command "try { Invoke-WebRequest -Uri http://127.0.0.1:10744/exit -TimeoutSec 5 | Out-Null } catch { Write-Host \"Server exit command sent\" }"', , 'Hide')
        LogActivity("Exit command sent to server")
        TrayTip("Server exit command sent", "Scriptlet Bridge", '1')
    } catch as e {
        LogActivity("Failed to send exit command: " . e.Message)
        MsgBox("Failed to send exit command: " . e.Message, "Error", "0x10")
    }
}
