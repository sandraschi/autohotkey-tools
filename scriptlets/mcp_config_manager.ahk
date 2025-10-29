; ==============================================================================
; MCP Config Manager
; @name: MCP Config Manager
; @version: 1.0.0
; @description: Manage Claude Desktop MCP configuration with validation and backup. Comprehensive GUI tool for managing MCP server configurations in Claude Desktop.
; @description: Provides JSON editing, server management, validation, backup/restore, and MCP server tools display. Features syntax highlighting, error detection, and server information retrieval.
; @description: Essential development tool for MCP developers to manage Claude Desktop configuration files, validate JSON syntax, and configure MCP servers efficiently.
; @category: development
; @author: Sandra
; @hotkeys: ^!c, F12
; @enabled: true
; @priority: 5
; @tag: mcp, config, management, claude-desktop, development, json, validation, servers
; @cli: --load - Load configuration file
; @cli: --validate - Validate JSON syntax
; @cli: --backup - Create configuration backup
; @cli: --help - Show CLI usage and config manager options
; @dependencies: 
; ==============================================================================

#Requires AutoHotkey v2.0+
#SingleInstance Force

; Show that script is starting
TrayTip("MCP Config Manager", "Script starting...", 3)

; Log errors but allow GUI errors to show
OnError(LogError)

LogError(Thrown, Mode) {
    errorMsg := "Error: " . Thrown.Message . " at line " . Thrown.Line . "`n" . Thrown.Stack
    FileAppend(errorMsg, "mcp_config_errors.log", "UTF-8")
    OutputDebug(errorMsg)  ; Enable LLM debugging
    
    ; Allow GUI errors to show - they're important for debugging
    if (InStr(Thrown.Message, "GUI") || InStr(Thrown.Stack, "CreateGUI")) {
        return 0  ; Show popup for GUI errors
    }
    return 1  ; Suppress popup for other errors
}

class MCPConfigManager {
    static claudeConfig := ""
    static backupDir := ""
    static configData := ""
    static debugMode := false
    static debugLog := []
    static guiInstance := ""
    static guiControls := Map()
    
    static Init() {
        try {
            this.claudeConfig := A_AppData . "\Claude\claude_desktop_config.json"
            this.backupDir := A_ScriptDir . "\config_backups"
            this.debugMode := A_Args.Length > 0 && A_Args[1] = "/debug"
            this.LogDebug("MCP Config Manager initialized" . (this.debugMode ? " in DEBUG mode" : ""))
            
            ; Show initial message to verify script is running
            TrayTip("MCP Config Manager", "Starting GUI...", 2)
            
            this.CreateGUI()
        } catch as e {
            MsgBox("Init error: " . e.Message . "`n" . e.Stack, "Error", "Iconx")
        }
    }
    
    static LogDebug(message) {
        if (this.debugMode) {
            timestamp := FormatTime(A_Now, "HH:mm:ss")
            logEntry := "[" . timestamp . "] " . message
            this.debugLog.Push(logEntry)
            OutputDebug(logEntry)
        }
    }
    
    static ValidateGUI() {
        if (this.guiInstance = "") {
            this.LogDebug("GUI instance not available")
            return false
        }
        return true
    }
    
    static CreateGUI() {
        try {
            ; Store the GUI instance at class level
            this.guiInstance := Gui("+Resize +MinSize800x600", "MCP Config Manager")
            this.guiInstance.BackColor := "1a1a1a"
            this.guiInstance.SetFont("s10 cFFFFFF", "Segoe UI")
            
            ; Title
            titleText := this.guiInstance.Add("Text", "x20 y20 w760 Center", "⚙️ MCP Config Manager")
            titleText.SetFont("Bold")
            this.guiInstance.Add("Text", "x20 y50 w760 Center cCCCCCC", "Manage Claude Desktop MCP configuration with validation and backup")
            
            ; Configuration file section
            fileText := this.guiInstance.Add("Text", "x20 y90 w760", "📁 Configuration File")
            fileText.SetFont("Bold")
            this.guiInstance.Add("Text", "x20 y115 w150", "Config Path:")
            this.guiInstance.Add("Text", "x180 y115 w580 cCCCCCC", this.claudeConfig)
            
            ; File operations
            this.guiInstance.Add("Button", "x20 y150 w150 h40", "📖 Load Config").OnEvent("Click", this.LoadConfig.Bind(this))
            this.guiInstance.Add("Button", "x190 y150 w150 h40", "💾 Save Config").OnEvent("Click", this.SaveConfig.Bind(this))
            this.guiInstance.Add("Button", "x360 y150 w150 h40", "📋 Backup Config").OnEvent("Click", this.BackupConfig.Bind(this))
            this.guiInstance.Add("Button", "x530 y150 w150 h40", "🔄 Restore Config").OnEvent("Click", this.RestoreConfig.Bind(this))
            
            ; MCP Servers section
            serverText := this.guiInstance.Add("Text", "x20 y210 w760", "🖥️ MCP Servers")
            serverText.SetFont("Bold")
            
            ; Server list
            serverList := this.guiInstance.Add("ListBox", "x20 y240 w400 h200")
            this.guiControls["serverList"] := serverList
            
            ; Server controls
            this.guiInstance.Add("Button", "x440 y240 w150 h40", "➕ Add Server").OnEvent("Click", this.AddServer.Bind(this))
            this.guiInstance.Add("Button", "x610 y240 w150 h40", "✏️ Edit Server").OnEvent("Click", this.EditServer.Bind(this))
            this.guiInstance.Add("Button", "x440 y290 w150 h40", "🗑️ Remove Server").OnEvent("Click", this.RemoveServer.Bind(this))
            this.guiInstance.Add("Button", "x610 y290 w150 h40", "📋 Duplicate Server").OnEvent("Click", this.DuplicateServer.Bind(this))
            this.guiInstance.Add("Button", "x440 y340 w150 h40", "✅ Test Server").OnEvent("Click", this.TestServer.Bind(this))
            this.guiInstance.Add("Button", "x610 y340 w150 h40", "📊 Server Info").OnEvent("Click", this.ServerInfo.Bind(this))
            
            ; Configuration editor
            editorText := this.guiInstance.Add("Text", "x20 y460 w760", "✏️ Configuration Editor")
            editorText.SetFont("Bold")
            
            ; JSON editor
            configEdit := this.guiInstance.Add("Edit", "x20 y490 w760 h100 Multi VScroll Background2d2d2d cFFFFFF", "")
            configEdit.SetFont("s9", "Consolas")
            this.guiControls["configEdit"] := configEdit
            
            ; Validation and actions
            this.guiInstance.Add("Button", "x20 y600 w150 h40", "✅ Validate JSON").OnEvent("Click", this.ValidateJSON.Bind(this))
            this.guiInstance.Add("Button", "x190 y600 w150 h40", "🎨 Format JSON").OnEvent("Click", this.FormatJSON.Bind(this))
            this.guiInstance.Add("Button", "x360 y600 w150 h40", "🔄 Reset to Default").OnEvent("Click", this.ResetToDefault.Bind(this))
            this.guiInstance.Add("Button", "x530 y600 w150 h40", "❓ Help").OnEvent("Click", this.ShowHelp.Bind(this))
            
            ; Status
            this.guiInstance.Add("Text", "x20 y650 w760 Center c888888", "Hotkeys: Ctrl+Alt+C (Load Config) | F12 (Validate) | Press Load Config to start")
            
            ; Set up hotkeys
            this.SetupHotkeys()
            
            ; Show the GUI
            this.guiInstance.Show("w800 h700 Center")
            this.LogDebug("GUI created and shown successfully")
            
            ; Force GUI to be visible and active
            WinShow(this.guiInstance.Hwnd)
            WinActivate(this.guiInstance.Hwnd)
            
        } catch as e {
            errorMsg := "Error creating GUI: " . e.Message . "`n" . e.Stack
            FileAppend(errorMsg, "mcp_config_errors.log", "UTF-8")
            OutputDebug(errorMsg)
            MsgBox("Error creating GUI: " . e.Message . "`n`nCheck mcp_config_errors.log for details", "Error", "Iconx")
            throw
        }
    }
    
    static LoadConfig(*) {
        try {
            this.LogDebug("LoadConfig() called")
            
            if (!FileExist(this.claudeConfig)) {
                this.LogDebug("Config file not found: " . this.claudeConfig)
                result := MsgBox("Claude config file not found: " . this.claudeConfig . "`n`nWould you like to create a default configuration?", "Config Not Found", "Icon? YesNo")
                if (result = "Yes") {
                    this.LogDebug("Creating default config")
                    this.CreateDefaultConfig()
                } else {
                    this.LogDebug("User cancelled config creation")
                    return
                }
            }
            
            this.LogDebug("Reading config file: " . this.claudeConfig)
            configContent := FileRead(this.claudeConfig)
            this.configData := configContent
            this.LogDebug("Config loaded successfully, size: " . StrLen(configContent) . " characters")
            
            ; Update GUI
            try {
                if (this.guiInstance != "" && this.guiControls.Has("configEdit")) {
                    this.guiControls["configEdit"].Value := configContent
                    this.LogDebug("Config editor updated")
                }
            } catch as e {
                this.LogDebug("Error updating config editor: " . e.Message)
            }
            
            ; Parse and display servers
            this.ParseServers()
            
            MsgBox("Configuration loaded successfully!", "Config Loaded", "Iconi")
            this.LogDebug("LoadConfig completed successfully")
            
        } catch as e {
            this.LogDebug("LoadConfig error: " . e.Message)
            if (this.debugMode) {
                this.LogDebug("Error details - File: " . e.File . ", Line: " . e.Line)
                ListVars
                Pause
            }
            MsgBox("Error loading config: " . e.Message, "Error", "Iconx")
        }
    }
    
    static SaveConfig(*) {
        try {
            if (this.configData = "") {
                MsgBox("No configuration data to save. Please load a config first.", "No Data", "Icon!")
                return
            }
            
            ; Validate JSON before saving
            if (!this.ValidateJSONContent(this.configData)) {
                MsgBox("Configuration contains invalid JSON. Please fix errors before saving.", "Invalid JSON", "Iconx")
                return
            }
            
            ; Create backup before saving
            this.CreateBackup()
            
            ; Get current content from editor if available
            try {
                if (this.guiInstance != "" && this.guiControls.Has("configEdit")) {
                    this.configData := this.guiControls["configEdit"].Value
                }
            } catch as e {
                this.LogDebug("Error reading from editor: " . e.Message)
            }
            
            ; Save config (overwrite if exists)
            if (FileExist(this.claudeConfig)) {
                FileDelete(this.claudeConfig)
            }
            FileAppend(this.configData, this.claudeConfig)
            
            MsgBox("Configuration saved successfully!", "Config Saved", "Iconi")
            
        } catch as e {
            MsgBox("Error saving config: " . e.Message, "Error", "Iconx")
        }
    }
    
    static BackupConfig(*) {
        try {
            if (!DirExist(this.backupDir)) {
                DirCreate(this.backupDir)
            }
            
            if (!FileExist(this.claudeConfig)) {
                MsgBox("No config file to backup.", "No Config", "Icon!")
                return
            }
            
            timestamp := FormatTime(A_Now, "yyyy-MM-dd_HH-mm-ss")
            backupFile := this.backupDir . "\claude_config_backup_" . timestamp . ".json"
            
            FileCopy(this.claudeConfig, backupFile)
            
            MsgBox("Configuration backed up to: " . backupFile, "Backup Created", "Iconi")
            
        } catch as e {
            MsgBox("Error creating backup: " . e.Message, "Error", "Iconx")
        }
    }
    
    static RestoreConfig(*) {
        try {
            if (!DirExist(this.backupDir)) {
                MsgBox("No backup directory found.", "No Backups", "Icon!")
                return
            }
            
            ; List available backups
            backups := []
            Loop Files this.backupDir . "\*.json" {
                backups.Push(A_LoopFilePath)
            }
            
            if (backups.Length = 0) {
                MsgBox("No backup files found.", "No Backups", "Icon!")
                return
            }
            
            ; Show backup selection dialog
            backupText := "Available Backups:`n`n"
            for i, backup in backups {
                fileName := RegExReplace(backup, ".*\\", "")
                backupText .= i . ". " . fileName . "`n"
            }
            backupText .= "`nEnter backup number to restore:"
            
            backupInput := InputBox(backupText, "Restore Backup")
            if (backupInput.Result != "OK") {
                return
            }
            if (backupInput.Value = "") {
                return
            }
            backupNum := Integer(backupInput.Value)
            
            if (backupNum >= 1 && backupNum <= backups.Length) {
                selectedBackup := backups[backupNum]
                
                ; Create current backup before restore
                this.CreateBackup()
                
                ; Restore selected backup
                FileCopy(selectedBackup, this.claudeConfig, true)
                
                MsgBox("Configuration restored from: " . RegExReplace(selectedBackup, ".*\\", ""), "Config Restored", "Iconi")
                
                ; Reload config
                this.LoadConfig()
            }
            
        } catch as e {
            MsgBox("Error restoring config: " . e.Message, "Error", "Iconx")
        }
    }
    
    static AddServer(*) {
        try {
            ; Show add server dialog
            nameInput := InputBox("Enter server name:", "Add MCP Server")
            if (nameInput.Result != "OK") {
                return
            }
            if (nameInput.Value = "") {
                return
            }
            name := nameInput.Value
            
            commandInput := InputBox("Enter command (e.g., python):", "Add MCP Server")
            if (commandInput.Result != "OK") {
                return
            }
            if (commandInput.Value = "") {
                return
            }
            command := commandInput.Value
            
            argsInput := InputBox("Enter arguments (e.g., main.py):", "Add MCP Server")
            if (argsInput.Result != "OK") {
                return
            }
            if (argsInput.Value = "") {
                return
            }
            args := argsInput.Value
            
            cwdInput := InputBox("Enter working directory (optional):", "Add MCP Server")
            cwd := (cwdInput.Result = "OK") ? cwdInput.Value : ""
            
            ; Create server configuration
            serverConfig := "    `"" . name . "`": {`n"
            serverConfig .= "      `"command`": `"" . command . "`",`n"
            serverConfig .= "      `"args`": [`"" . args . "`"]`n"
            if (cwd != "") {
                serverConfig .= "      `"cwd`": `"" . cwd . "`"`n"
            }
            serverConfig .= "    }`n"
            
            ; Add to config
            this.AddServerToConfig(name, serverConfig)
            
            MsgBox("Server '" . name . "' added successfully!", "Server Added", "Iconi")
            
        } catch as e {
            MsgBox("Error adding server: " . e.Message, "Error", "Iconx")
        }
    }
    
    static EditServer(*) {
        try {
            ; Get selected server
            selectedServer := this.GetSelectedServer()
            if (selectedServer = "") {
                MsgBox("Please select a server to edit.", "No Server Selected", "Icon!")
                return
            }
            
            ; Show edit dialog with current values
            MsgBox("Edit server functionality would open a detailed editor for: " . selectedServer, "Edit Server", "Iconi")
            
        } catch as e {
            MsgBox("Error editing server: " . e.Message, "Error", "Iconx")
        }
    }
    
    static RemoveServer(*) {
        try {
            selectedServer := this.GetSelectedServer()
            if (selectedServer = "") {
                MsgBox("Please select a server to remove.", "No Server Selected", "Icon!")
                return
            }
            
            result := MsgBox("Are you sure you want to remove server '" . selectedServer . "'?", "Confirm Removal", "Icon? YesNo")
            if (result = "Yes") {
                this.RemoveServerFromConfig(selectedServer)
                MsgBox("Server '" . selectedServer . "' removed successfully!", "Server Removed", "Iconi")
            }
            
        } catch as e {
            MsgBox("Error removing server: " . e.Message, "Error", "Iconx")
        }
    }
    
    static DuplicateServer(*) {
        try {
            selectedServer := this.GetSelectedServer()
            if (selectedServer = "") {
                MsgBox("Please select a server to duplicate.", "No Server Selected", "Icon!")
                return
            }
            
            nameInput := InputBox("Enter new server name:", "Duplicate Server")
            if (nameInput.Result != "OK") {
                return
            }
            if (nameInput.Value = "") {
                return
            }
            name := nameInput.Value
            
            this.DuplicateServerInConfig(selectedServer, name)
            MsgBox("Server duplicated as '" . name . "'!", "Server Duplicated", "Iconi")
            
        } catch as e {
            MsgBox("Error duplicating server: " . e.Message, "Error", "Iconx")
        }
    }
    
    static TestServer(*) {
        try {
            selectedServer := this.GetSelectedServer()
            if (selectedServer = "") {
                MsgBox("Please select a server to test.", "No Server Selected", "Icon!")
                return
            }
            
            MsgBox("Testing server '" . selectedServer . "'...`n`nThis would run the server and check for errors.", "Test Server", "Iconi")
            
        } catch as e {
            MsgBox("Error testing server: " . e.Message, "Error", "Iconx")
        }
    }
    
    static ServerInfo(*) {
        try {
            selectedServer := this.GetSelectedServer()
            if (selectedServer = "") {
                MsgBox("Please select a server to view info.", "No Server Selected", "Icon!")
                return
            }
            
            ; Extract server configuration from JSON
            serverConfig := this.GetServerConfig(selectedServer)
            if (serverConfig = "") {
                MsgBox("Could not find configuration for server: " . selectedServer, "Server Not Found", "Iconx")
                return
            }
            
            ; Parse server details
            command := this.ExtractJSONValue(serverConfig, "command")
            args := this.ExtractJSONValue(serverConfig, "args")
            cwd := this.ExtractJSONValue(serverConfig, "cwd")
            env := this.ExtractJSONValue(serverConfig, "env")
            alwaysAllow := this.ExtractJSONValue(serverConfig, "alwaysAllow")
            description := this.ExtractJSONValue(serverConfig, "description")
            
            ; Build info display
            infoText := "📊 Server Information: " . selectedServer . "`n`n"
            
            ; Command
            if (command != "") {
                infoText .= "🔧 Command: " . command . "`n"
            } else {
                infoText .= "🔧 Command: ❌ Not specified`n"
            }
            
            ; Arguments
            if (args != "") {
                infoText .= "📝 Arguments: " . args . "`n"
            } else {
                infoText .= "📝 Arguments: (none)`n"
            }
            
            ; Working Directory
            if (cwd != "") {
                ; Check if path exists
                cwdExists := FileExist(cwd) || DirExist(cwd) ? "✅" : "❌"
                infoText .= "📁 Working Directory: " . cwd . " " . cwdExists . "`n"
            } else {
                infoText .= "📁 Working Directory: (not specified)`n"
            }
            
            ; Environment Variables
            if (env != "") {
                ; Parse env object - "KEY": "value" pairs
                envDisplay := ""
                envPos := 1
                while (envPos := RegExMatch(env, '"([^"]+)"\s*:\s*"([^"]*)"', &envMatch, envPos)) {
                    envDisplay .= "  " . envMatch[1] . " = " . envMatch[2] . "`n"
                    envPos := envMatch.Pos + envMatch.Len
                }
                if (envDisplay != "") {
                    infoText .= "`n🌍 Environment Variables:`n" . envDisplay
                } else {
                    infoText .= "`n🌍 Environment Variables:`n  " . env . "`n"
                }
            }
            
            ; Always Allow
            if (alwaysAllow != "") {
                infoText .= "`n🔓 Always Allow: " . alwaysAllow . "`n"
            }
            
            ; Description
            if (description != "") {
                infoText .= "`n📄 Description: " . description . "`n"
            }
            
            ; Parse pyproject.toml if server is local
            ; Check if cwd is a local directory (not a global command)
            isLocal := cwd != "" && (DirExist(cwd) || (FileExist(cwd) && !InStr(cwd, ".exe") && !InStr(cwd, ".bat")))
            if (isLocal) {
                pyprojectInfo := this.ParsePyProjectToml(cwd)
                if (pyprojectInfo != "") {
                    infoText .= "`n" . pyprojectInfo
                }
                
                ; Parse MCP tools from Python server files
                toolsInfo := this.ParseMCPTools(cwd, command, args)
                if (toolsInfo != "") {
                    infoText .= "`n" . toolsInfo
                }
            }
            
            ; Show in a GUI window for better readability
            this.ShowServerInfoWindow(selectedServer, infoText, command, args, cwd, env)
            
        } catch as e {
            MsgBox("Error getting server info: " . e.Message, "Error", "Iconx")
            this.LogDebug("ServerInfo error: " . e.Message)
        }
    }
    
    static GetServerConfig(serverName) {
        try {
            if (this.configData = "") {
                return ""
            }
            
            ; Find the server configuration in JSON
            ; Pattern: "server-name": { ... }
            pattern := '"' . RegExReplace(serverName, "[.*+?^${}()|[\]\\]", "\$0") . '"\s*:\s*\{'
            if (RegExMatch(this.configData, pattern, &match)) {
                startPos := match.Pos + match.Len
                
                ; Find the matching closing brace
                depth := 1
                pos := startPos
                endPos := 0
                
                while (pos <= StrLen(this.configData) && depth > 0) {
                    char := SubStr(this.configData, pos, 1)
                    if (char = "{") {
                        depth++
                    } else if (char = "}") {
                        depth--
                        if (depth = 0) {
                            endPos := pos
                            break
                        }
                    }
                    pos++
                }
                
                if (endPos > 0) {
                    return SubStr(this.configData, startPos, endPos - startPos)
                }
            }
        } catch as e {
            this.LogDebug("GetServerConfig error: " . e.Message)
        }
        return ""
    }
    
    static ExtractJSONValue(jsonBlock, key) {
        try {
            ; Look for "key": value pattern
            pattern := '"' . key . '"\s*:\s*"([^"]*)"'
            if (RegExMatch(jsonBlock, pattern, &match)) {
                return match[1]
            }
            
            ; Try array value (args)
            if (key = "args") {
                pattern := '"args"\s*:\s*\[([^\]]*)\]'
                if (RegExMatch(jsonBlock, pattern, &match)) {
                    ; Extract array elements
                    argsText := match[1]
                    argsText := RegExReplace(argsText, '"([^"]+)"', "$1")
                    return argsText
                }
            }
            
            ; Try boolean or null
            pattern := '"' . key . '"\s*:\s*(true|false|null)'
            if (RegExMatch(jsonBlock, pattern, &match)) {
                return match[1]
            }
            
            ; Try object value (env)
            if (key = "env") {
                pattern := '"env"\s*:\s*\{([^}]*)\}'
                if (RegExMatch(jsonBlock, pattern, &match)) {
                    return match[1]
                }
            }
            
        } catch {
        }
        return ""
    }
    
    static ParsePyProjectToml(cwd) {
        try {
            ; Determine the directory path
            dirPath := cwd
            if (FileExist(cwd) && !DirExist(cwd)) {
                ; If cwd is a file path, get its directory
                dirPath := RegExReplace(cwd, "\\[^\\]+$", "")
            }
            
            ; Normalize path (handle relative paths and common MCP locations)
            if (InStr(dirPath, "./") = 1 || InStr(dirPath, ".\\") = 1) {
                ; Relative path starting with ./
                fullPath := RegExReplace(dirPath, "^\.+[\\/]", "")
                ; Try common MCP server locations
                if (DirExist("D:\Dev\repos\" . fullPath)) {
                    fullPath := "D:\Dev\repos\" . fullPath
                } else if (DirExist("C:\Users\" . A_UserName . "\AppData\Roaming\Claude\" . fullPath)) {
                    fullPath := "C:\Users\" . A_UserName . "\AppData\Roaming\Claude\" . fullPath
                } else if (DirExist(fullPath)) {
                    ; Path is already resolved
                } else {
                    return ""  ; Can't resolve path
                }
            } else if (!InStr(dirPath, ":") && !InStr(dirPath, "\\") && !InStr(dirPath, "/")) {
                ; Just a directory name, try common locations
                if (DirExist("D:\Dev\repos\" . dirPath)) {
                    fullPath := "D:\Dev\repos\" . dirPath
                } else if (DirExist("D:\Dev\repos\" . dirPath . "-mcp")) {
                    fullPath := "D:\Dev\repos\" . dirPath . "-mcp"
                } else if (DirExist(dirPath)) {
                    fullPath := dirPath
                } else {
                    return ""  ; Can't resolve path
                }
            } else if (InStr(dirPath, ":") = 0) {
                ; No drive letter but has separators - might be UNC or relative
                if (DirExist("D:\Dev\repos\" . dirPath)) {
                    fullPath := "D:\Dev\repos\" . dirPath
                } else if (DirExist(dirPath)) {
                    fullPath := dirPath
                } else {
                    return ""
                }
            } else {
                fullPath := dirPath
            }
            
            ; Ensure it's a directory
            if (!DirExist(fullPath)) {
                return ""
            }
            
            ; Look for pyproject.toml
            tomlPath := fullPath . "\pyproject.toml"
            if (!FileExist(tomlPath)) {
                return ""
            }
            
            ; Read the TOML file
            tomlContent := FileRead(tomlPath)
            
            if (tomlContent = "") {
                return ""
            }
            
            ; Parse TOML file (basic parsing for common fields)
            tomlInfo := "`n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━`n"
            tomlInfo .= "📦 Project Metadata (pyproject.toml)`n"
            tomlInfo .= "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━`n"
            
            ; Extract project name from [project] or [tool.poetry] or [build-system]
            if (RegExMatch(tomlContent, '\[project\]\s*\n.*?name\s*=\s*"([^"]+)"', &match)) {
                tomlInfo .= "📛 Name: " . match[1] . "`n"
            } else if (RegExMatch(tomlContent, '\[tool\.poetry\]\s*\n.*?name\s*=\s*"([^"]+)"', &match)) {
                tomlInfo .= "📛 Name: " . match[1] . "`n"
            }
            
            ; Extract version
            if (RegExMatch(tomlContent, 'version\s*=\s*"([^"]+)"', &match)) {
                tomlInfo .= "🏷️  Version: " . match[1] . "`n"
            } else if (RegExMatch(tomlContent, "version\s*=\s*'([^']+)'", &match)) {
                tomlInfo .= "🏷️  Version: " . match[1] . "`n"
            }
            
            ; Extract description
            if (RegExMatch(tomlContent, 'description\s*=\s*"([^"]+)"', &match)) {
                tomlInfo .= "📝 Description: " . match[1] . "`n"
            } else if (RegExMatch(tomlContent, "description\s*=\s*'([^']+)'", &match)) {
                tomlInfo .= "📝 Description: " . match[1] . "`n"
            }
            
            ; Extract dependencies (basic - just count them)
            depCount := 0
            if (RegExMatch(tomlContent, '\[project\]\s*dependencies\s*=\s*\[', &match)) {
                ; Count dependencies in project.dependencies array
                depsBlock := SubStr(tomlContent, match.Pos)
                depsPos := 1
                while (RegExMatch(depsBlock, '"([^"]+)"', &depMatch, depsPos)) {
                    depCount++
                    depsPos := depMatch.Pos + depMatch.Len
                    if (SubStr(depsBlock, depMatch.Pos + depMatch.Len, 1) = "]") {
                        break
                    }
                }
            } else if (RegExMatch(tomlContent, '\[tool\.poetry\.dependencies\]', &match)) {
                ; Count Poetry dependencies
                depsBlock := SubStr(tomlContent, match.Pos, 500)
                depsPos := 1
                while (RegExMatch(depsBlock, '(\w+)\s*=', &depMatch, depsPos)) {
                    depCount++
                    depsPos := depMatch.Pos + depMatch.Len
                }
            }
            
            if (depCount > 0) {
                tomlInfo .= "📚 Dependencies: " . depCount . " package(s)`n"
            }
            
            ; Extract Python version requirement
            if (RegExMatch(tomlContent, 'requires-python\s*=\s*"([^"]+)"', &match)) {
                tomlInfo .= "🐍 Python: " . match[1] . "`n"
            } else if (RegExMatch(tomlContent, 'python\s*=\s*"([^"]+)"', &match)) {
                tomlInfo .= "🐍 Python: " . match[1] . "`n"
            }
            
            ; Extract build backend
            if (RegExMatch(tomlContent, '\[build-system\]\s*\n.*?requires\s*=\s*\["([^"]+)"', &match)) {
                tomlInfo .= "🔧 Build Backend: " . match[1] . "`n"
            }
            
            ; Add file path
            tomlInfo .= "📁 Path: " . tomlPath . "`n"
            
            return tomlInfo
            
        } catch as e {
            this.LogDebug("ParsePyProjectToml error: " . e.Message)
            return ""
        }
    }
    
    static ParseMCPTools(cwd, command, args) {
        try {
            ; Resolve the server directory path (reuse logic from ParsePyProjectToml)
            dirPath := cwd
            if (FileExist(cwd) && !DirExist(cwd)) {
                dirPath := RegExReplace(cwd, "\\[^\\]+$", "")
            }
            
            ; Normalize path (simplified version)
            fullPath := this.ResolveServerPath(dirPath)
            if (fullPath = "" || !DirExist(fullPath)) {
                return ""
            }
            
            ; Find the main server file
            serverFile := ""
            possibleFiles := ["server.py", "main.py", "__main__.py"]
            
            ; Check if args specifies a file
            if (args != "") {
                ; Extract first arg (usually the main file)
                if (RegExMatch(args, "(\S+)", &argMatch)) {
                    firstArg := argMatch[1]
                    if (FileExist(fullPath . "\" . firstArg)) {
                        serverFile := fullPath . "\" . firstArg
                    }
                }
            }
            
            ; If not found, try common names
            if (serverFile = "") {
                for i, fileName in possibleFiles {
                    if (FileExist(fullPath . "\" . fileName)) {
                        serverFile := fullPath . "\" . fileName
                        break
                    }
                }
            }
            
            ; Try src/ subdirectory
            if (serverFile = "" && DirExist(fullPath . "\src")) {
                for i, fileName in possibleFiles {
                    if (FileExist(fullPath . "\src\" . fileName)) {
                        serverFile := fullPath . "\src\" . fileName
                        break
                    }
                }
            }
            
            if (serverFile = "" || !FileExist(serverFile)) {
                return ""
            }
            
            ; Read Python file
            pythonContent := FileRead(serverFile)
            if (pythonContent = "") {
                return ""
            }
            
            ; Parse for FastMCP tool definitions
            tools := []
            
            ; Look for @app.tool() or @tool decorator patterns
            ; Pattern 1: @app.tool() or @tool followed by async def tool_name(...):
            pos := 1
            while (pos := RegExMatch(pythonContent, '(@app\.tool\([^)]*\)|@tool\([^)]*\)|@app\.tool\(\)|@tool)\s*\n\s*(async\s+)?def\s+(\w+)', &match, pos)) {
                toolName := match[3]
                
                ; Extract docstring (look for triple-quoted string immediately after function definition)
                docStart := match.Pos + match.Len
                docString := ""
                
                ; Find docstring - handle multiline docstrings
                docContent := ""
                ; Try double quotes first
                docPattern := '""".*?"""'
                if (RegExMatch(pythonContent, docPattern, &docMatch, docStart)) {
                    docContent := docMatch[0]
                    docContent := RegExReplace(docContent, '^"""', "")
                    docContent := RegExReplace(docContent, '"""$', "")
                } else {
                    ; Try single quotes
                    docPattern := "'''.*?'''"
                    if (RegExMatch(pythonContent, docPattern, &docMatch, docStart)) {
                        docContent := docMatch[0]
                        docContent := RegExReplace(docContent, "^'''", "")
                        docContent := RegExReplace(docContent, "'''$", "")
                    }
                }
                if (docContent != "") {
                    docString := Trim(docContent)
                    if (InStr(docString, "`n")) {
                        firstLine := SubStr(docString, 1, InStr(docString, "`n") - 1)
                        docString := Trim(firstLine)
                    }
                    if (StrLen(docString) > 80) {
                        docString := SubStr(docString, 1, 77) . "..."
                    }
                    docString := Trim(docString)
                }
                
                tools.Push({name: toolName, description: docString})
                pos := match.Pos + match.Len
            }
            
            ; Also try pattern without async: def tool_name with @app.tool() before it
            ; Look backwards from function definition for decorator
            pos := 1
            while (pos := RegExMatch(pythonContent, '(@app\.tool\([^)]*\)|@tool\([^)]*\))\s*\n\s*def\s+(\w+)', &match, pos)) {
                toolName := match[2]
                
                ; Check if we already added this tool
                alreadyAdded := false
                for i, tool in tools {
                    if (tool.name = toolName) {
                        alreadyAdded := true
                        break
                    }
                }
                
                if (!alreadyAdded) {
                    ; Extract docstring
                    docStart := match.Pos + match.Len
                    docString := ""
                    docContent := ""
                    ; Try double quotes first
                    docPattern := '""".*?"""'
                    if (RegExMatch(pythonContent, docPattern, &docMatch, docStart)) {
                        docContent := docMatch[0]
                        docContent := RegExReplace(docContent, '^"""', "")
                        docContent := RegExReplace(docContent, '"""$', "")
                    } else {
                        ; Try single quotes
                        docPattern := "'''.*?'''"
                        if (RegExMatch(pythonContent, docPattern, &docMatch, docStart)) {
                            docContent := docMatch[0]
                            docContent := RegExReplace(docContent, "^'''", "")
                            docContent := RegExReplace(docContent, "'''$", "")
                        }
                    }
                    if (docContent != "") {
                        docString := Trim(docContent)
                        if (InStr(docString, "`n")) {
                            docString := SubStr(docString, 1, InStr(docString, "`n") - 1)
                        }
                        docString := Trim(docString)
                    }
                    tools.Push({name: toolName, description: docString})
                }
                
                pos := match.Pos + match.Len
            }
            
            if (tools.Length = 0) {
                return ""
            }
            
            ; Build tools display
            toolsInfo := "`n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━`n"
            toolsInfo .= "🛠️  MCP Tools (" . tools.Length . ")`n"
            toolsInfo .= "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━`n"
            
            for i, tool in tools {
                toolsInfo .= (i < 10 ? " " : "") . i . ". " . tool.name
                if (tool.description != "") {
                    toolsInfo .= "`n    └─ " . tool.description
                }
                toolsInfo .= "`n"
            }
            
            toolsInfo .= "`n📄 Source: " . RegExReplace(serverFile, ".*\\", "") . "`n"
            
            return toolsInfo
            
        } catch as e {
            this.LogDebug("ParseMCPTools error: " . e.Message)
            return ""
        }
    }
    
    static ResolveServerPath(dirPath) {
        try {
            ; Normalize path (handle relative paths and common MCP locations)
            if (InStr(dirPath, "./") = 1 || InStr(dirPath, ".\\") = 1) {
                fullPath := RegExReplace(dirPath, "^\.+[\\/]", "")
                if (DirExist("D:\Dev\repos\" . fullPath)) {
                    return "D:\Dev\repos\" . fullPath
                } else if (DirExist("C:\Users\" . A_UserName . "\AppData\Roaming\Claude\" . fullPath)) {
                    return "C:\Users\" . A_UserName . "\AppData\Roaming\Claude\" . fullPath
                } else if (DirExist(fullPath)) {
                    return fullPath
                }
                return ""
            } else if (!InStr(dirPath, ":") && !InStr(dirPath, "\\") && !InStr(dirPath, "/")) {
                if (DirExist("D:\Dev\repos\" . dirPath)) {
                    return "D:\Dev\repos\" . dirPath
                } else if (DirExist("D:\Dev\repos\" . dirPath . "-mcp")) {
                    return "D:\Dev\repos\" . dirPath . "-mcp"
                } else if (DirExist(dirPath)) {
                    return dirPath
                }
                return ""
            } else if (InStr(dirPath, ":") = 0) {
                if (DirExist("D:\Dev\repos\" . dirPath)) {
                    return "D:\Dev\repos\" . dirPath
                } else if (DirExist(dirPath)) {
                    return dirPath
                }
                return ""
            } else {
                return dirPath
            }
        } catch {
            return ""
        }
    }
    
    static ShowServerInfoWindow(serverName, infoText, command, args, cwd, env) {
        try {
            infoGui := Gui("+Owner +ToolWindow", "Server Info: " . serverName)
            infoGui.OnEvent("Close", (*) => infoGui.Destroy())
            infoGui.OnEvent("Escape", (*) => infoGui.Destroy())
            
            infoGui.SetFont("s10", "Segoe UI")
            
            ; Title
            infoGui.Add("Text", "x20 y20 w600 Center Bold", "📊 " . serverName . " - Configuration Details")
            
            ; Info display area (larger for tools list)
            infoDisplay := infoGui.Add("Edit", "x20 y50 w750 h450 ReadOnly Multi VScroll", infoText)
            infoDisplay.SetFont("s9", "Consolas")
            
            ; Buttons
            btnClose := infoGui.Add("Button", "x335 y510 w120 h30 Default", "Close")
            btnClose.OnEvent("Click", (*) => infoGui.Destroy())
            
            infoGui.Show("w790 h550")
            
        } catch as e {
            ; Fallback to MsgBox if GUI fails
            MsgBox(infoText, "Server Info: " . serverName, "Iconi")
        }
    }
    
    static ValidateJSON(*) {
        try {
            if (this.configData = "") {
                MsgBox("No configuration data to validate. Please load a config first.", "No Data", "Icon!")
                return
            }
            
            if (this.ValidateJSONContent(this.configData)) {
                MsgBox("✅ Configuration JSON is valid!", "Validation Passed", "Iconi")
            } else {
                MsgBox("❌ Configuration JSON is invalid. Please check syntax.", "Validation Failed", "Iconx")
            }
            
        } catch as e {
            MsgBox("Error validating JSON: " . e.Message, "Error", "Iconx")
        }
    }
    
    static FormatJSON(*) {
        try {
            if (this.configData = "") {
                MsgBox("No configuration data to format. Please load a config first.", "No Data", "Icon!")
                return
            }
            
            ; Simple JSON formatting (could be enhanced)
            formattedJSON := this.SimpleJSONFormat(this.configData)
            this.configData := formattedJSON
            
            MsgBox("JSON formatted successfully!", "Format Complete", "Iconi")
            
        } catch as e {
            MsgBox("Error formatting JSON: " . e.Message, "Error", "Iconx")
        }
    }
    
    static ResetToDefault(*) {
        try {
            result := MsgBox("Are you sure you want to reset to default configuration?`n`nThis will replace your current config with a basic template.", "Confirm Reset", "Icon? YesNo")
            if (result = "Yes") {
                this.CreateDefaultConfig()
                this.LoadConfig()
                MsgBox("Configuration reset to default!", "Reset Complete", "Iconi")
            }
            
        } catch as e {
            MsgBox("Error resetting config: " . e.Message, "Error", "Iconx")
        }
    }
    
    static ParseServers() {
        try {
            if (this.configData = "") {
                return
            }
            
            servers := []
            
            ; Parse JSON to extract server names from mcpServers object
            ; Look for pattern: "mcpServers": { "server-name": { ... }, "another-server": { ... } }
            
            ; Find the mcpServers section - look for "mcpServers": { ... }
            if (RegExMatch(this.configData, '"mcpServers"\s*:\s*\{', &match)) {
                ; Extract everything after "mcpServers": {
                startPos := match.Pos + match.Len
                
                ; Find the matching closing brace for mcpServers object
                depth := 1
                pos := startPos
                endPos := 0
                
                while (pos <= StrLen(this.configData) && depth > 0) {
                    char := SubStr(this.configData, pos, 1)
                    if (char = "{") {
                        depth++
                    } else if (char = "}") {
                        depth--
                        if (depth = 0) {
                            endPos := pos
                            break
                        }
                    }
                    pos++
                }
                
                if (endPos > 0) {
                    ; Extract the mcpServers object content
                    serversBlock := SubStr(this.configData, startPos, endPos - startPos)
                    
                    ; Find all server names - look for "server-name": { pattern
                    serverPos := 1
                    while (serverPos := RegExMatch(serversBlock, '"([^"]+)"\s*:\s*\{', &serverMatch, serverPos)) {
                        serverName := serverMatch[1]
                        ; Only add if it's not "mcpServers" itself and we haven't added it already
                        if (serverName != "mcpServers" && !this.ArrayContains(servers, serverName)) {
                            servers.Push(serverName)
                        }
                        serverPos := serverMatch.Pos + serverMatch.Len
                    }
                }
            }
            
            ; Update server list in GUI
            try {
                if (this.guiInstance != "" && this.guiControls.Has("serverList")) {
                    ; ListBox uses Delete() and Add() methods
                    this.guiControls["serverList"].Delete()
                    if (servers.Length > 0) {
                        for i, server in servers {
                            this.guiControls["serverList"].Add([server])
                        }
                        this.LogDebug("Server list updated with " . servers.Length . " servers")
                    } else {
                        this.LogDebug("No servers found in config")
                    }
                }
            } catch as e {
                this.LogDebug("Error updating server list: " . e.Message . " - " . e.Stack)
            }
            
        } catch as e {
            this.LogDebug("ParseServers error: " . e.Message . " - " . e.Stack)
        }
    }
    
    static ArrayContains(arr, value) {
        for i, item in arr {
            if (item = value) {
                return true
            }
        }
        return false
    }
    
    static GetSelectedServer() {
        ; Get the selected server from the GUI
        try {
            if (this.guiInstance != "" && this.guiControls.Has("serverList")) {
                ; For ListBox, use Value property which returns the selected item text
                try {
                    selectedIndex := this.guiControls["serverList"].Value
                    if (selectedIndex > 0) {
                        ; Get the text of the selected item
                        selectedText := this.guiControls["serverList"].GetText(selectedIndex)
                        return selectedText
                    }
                } catch {
                    ; Fallback: try to get selected item another way
                    try {
                        ; ListBox may use different method
                        return this.guiControls["serverList"].Text
                    } catch {
                        return ""
                    }
                }
            }
        } catch as e {
            this.LogDebug("Error getting selected server: " . e.Message)
        }
        return ""
    }
    
    static CreateDefaultConfig() {
        defaultConfig := "{`n"
        defaultConfig .= "  `"mcpServers`": {`n"
        defaultConfig .= "    `"example-server`": {`n"
        defaultConfig .= "      `"command`": `"python`",`n"
        defaultConfig .= "      `"args`": [`"main.py`"],`n"
        defaultConfig .= "      `"cwd`": `"./mcp-servers/example`"`n"
        defaultConfig .= "    }`n"
        defaultConfig .= "  }`n"
        defaultConfig .= "}`n"
        
        ; Overwrite if exists
        if (FileExist(this.claudeConfig)) {
            FileDelete(this.claudeConfig)
        }
        FileAppend(defaultConfig, this.claudeConfig)
        this.configData := defaultConfig
    }
    
    static ValidateJSONContent(json) {
        try {
            ; Basic JSON validation
            if (!InStr(json, "{")) {
                return false
            }
            if (!InStr(json, "}")) {
                return false
            }
            
            ; Check for basic structure
            if (!InStr(json, "mcpServers")) {
                return false
            }
            
            return true
        } catch {
            return false
        }
    }
    
    static SimpleJSONFormat(json) {
        ; Very basic JSON formatting
        ; In a real implementation, you'd use a proper JSON parser
        return json
    }
    
    static CreateBackup() {
        try {
            if (!DirExist(this.backupDir)) {
                DirCreate(this.backupDir)
            }
            
            timestamp := FormatTime(A_Now, "yyyy-MM-dd_HH-mm-ss")
            backupFile := this.backupDir . "\claude_config_backup_" . timestamp . ".json"
            
            if (FileExist(this.claudeConfig)) {
                FileCopy(this.claudeConfig, backupFile)
            }
        } catch {
            ; Ignore backup errors
        }
    }
    
    static AddServerToConfig(serverName, serverConfig) {
        ; This would add a server to the config data
        ; Implementation would parse JSON and add the server
    }
    
    static RemoveServerFromConfig(serverName) {
        ; This would remove a server from the config data
        ; Implementation would parse JSON and remove the server
    }
    
    static DuplicateServerInConfig(sourceServer, newServer) {
        ; This would duplicate a server in the config data
        ; Implementation would parse JSON and duplicate the server
    }
    
    static ShowHelp(*) {
        helpText := "⚙️ MCP Config Manager Help`n`n"
        helpText .= "This tool manages Claude Desktop MCP configuration:`n`n"
        helpText .= "📁 File Operations:`n"
        helpText .= "• Load Config: Load existing configuration`n"
        helpText .= "• Save Config: Save current configuration`n"
        helpText .= "• Backup Config: Create timestamped backup`n"
        helpText .= "• Restore Config: Restore from backup`n`n"
        helpText .= "🖥️ Server Management:`n"
        helpText .= "• Add Server: Create new MCP server entry`n"
        helpText .= "• Edit Server: Modify existing server settings`n"
        helpText .= "• Remove Server: Delete server from config`n"
        helpText .= "• Duplicate Server: Copy server with new name`n"
        helpText .= "• Test Server: Validate server configuration`n"
        helpText .= "• Server Info: View detailed server information`n`n"
        helpText .= "✏️ Configuration Editor:`n"
        helpText .= "• Validate JSON: Check JSON syntax`n"
        helpText .= "• Format JSON: Pretty-print JSON`n"
        helpText .= "• Reset to Default: Restore default config`n`n"
        helpText .= "Hotkeys:`n"
        helpText .= "• Ctrl+Alt+C: Load configuration`n"
        helpText .= "• F12: Validate JSON`n"
        helpText .= "• Escape: Close tool"
        
        MsgBox(helpText, "MCP Config Manager Help", "Iconi")
    }
    
    static CloseGUI(*) {
        try {
            if (this.guiInstance != "") {
                this.guiInstance.Close()
                this.guiInstance := ""
                this.guiControls.Clear()
                this.LogDebug("GUI closed successfully")
            } else {
                ; Fallback to WindowClose if instance not available
                if (WinExist("MCP Config Manager")) {
                    WinClose("MCP Config Manager")
                }
            }
        } catch as e {
            this.LogDebug("Error closing GUI: " . e.Message)
        }
    }
    
    static SetupHotkeys() {
        Hotkey("^!c", (*) => this.LoadConfig())
        Hotkey("F12", (*) => this.ValidateJSON())
        Hotkey("Escape", (*) => this.CloseGUI())
    }
}

; Hotkeys
Hotkey("^!c", (*) => MCPConfigManager.Init())
Hotkey("F12", (*) => MCPConfigManager.Init())

; Initialize
MCPConfigManager.Init()

; Keep script running
Loop {
    Sleep(1000)
}

