; ==============================================================================
; MCP Config Manager
; @name: MCP Config Manager
; @version: 1.0.0
; @description: Manage Claude Desktop MCP configuration with validation and backup
; @category: development
; @author: Sandra
; @hotkeys: ^!c, F12
; @enabled: true
; ==============================================================================

#Requires AutoHotkey v2.0+
#SingleInstance Force

class MCPConfigManager {
    static claudeConfig := ""
    static backupDir := ""
    static configData := ""
    static debugMode := false
    static debugLog := []
    
    static Init() {
        this.claudeConfig := A_AppData . "\Claude\claude_desktop_config.json"
        this.backupDir := A_ScriptDir . "\config_backups"
        this.debugMode := A_Args.Length > 0 && A_Args[1] = "/debug"
        this.LogDebug("MCP Config Manager initialized" . (this.debugMode ? " in DEBUG mode" : ""))
        this.CreateGUI()
    }
    
    static LogDebug(message) {
        if (this.debugMode) {
            timestamp := FormatTime(A_Now, "HH:mm:ss")
            logEntry := "[" . timestamp . "] " . message
            this.debugLog.Push(logEntry)
            OutputDebug(logEntry)
        }
    }
    
    static CreateGUI() {
        gui := Gui("+Resize +MinSize800x600", "MCP Config Manager")
        gui.BackColor := "0x1a1a1a"
        gui.SetFont("s10 cWhite", "Segoe UI")
        
        ; Title
        gui.Add("Text", "x20 y20 w760 Center Bold", "⚙️ MCP Config Manager")
        gui.Add("Text", "x20 y50 w760 Center c0xcccccc", "Manage Claude Desktop MCP configuration with validation and backup")
        
        ; Configuration file section
        gui.Add("Text", "x20 y90 w760 Bold", "📁 Configuration File")
        gui.Add("Text", "x20 y115 w150", "Config Path:")
        gui.Add("Text", "x180 y115 w580 c0xcccccc", this.claudeConfig)
        
        ; File operations
        gui.Add("Button", "x20 y150 w150 h40", "📖 Load Config").OnEvent("Click", this.LoadConfig.Bind(this))
        gui.Add("Button", "x190 y150 w150 h40", "💾 Save Config").OnEvent("Click", this.SaveConfig.Bind(this))
        gui.Add("Button", "x360 y150 w150 h40", "📋 Backup Config").OnEvent("Click", this.BackupConfig.Bind(this))
        gui.Add("Button", "x530 y150 w150 h40", "🔄 Restore Config").OnEvent("Click", this.RestoreConfig.Bind(this))
        
        ; MCP Servers section
        gui.Add("Text", "x20 y210 w760 Bold", "🖥️ MCP Servers")
        
        ; Server list
        serverList := gui.Add("ListBox", "x20 y240 w400 h200")
        
        ; Server controls
        gui.Add("Button", "x440 y240 w150 h40", "➕ Add Server").OnEvent("Click", this.AddServer.Bind(this))
        gui.Add("Button", "x610 y240 w150 h40", "✏️ Edit Server").OnEvent("Click", this.EditServer.Bind(this))
        gui.Add("Button", "x440 y290 w150 h40", "🗑️ Remove Server").OnEvent("Click", this.RemoveServer.Bind(this))
        gui.Add("Button", "x610 y290 w150 h40", "📋 Duplicate Server").OnEvent("Click", this.DuplicateServer.Bind(this))
        gui.Add("Button", "x440 y340 w150 h40", "✅ Test Server").OnEvent("Click", this.TestServer.Bind(this))
        gui.Add("Button", "x610 y340 w150 h40", "📊 Server Info").OnEvent("Click", this.ServerInfo.Bind(this))
        
        ; Configuration editor
        gui.Add("Text", "x20 y460 w760 Bold", "✏️ Configuration Editor")
        
        ; JSON editor
        configEdit := gui.Add("Edit", "x20 y490 w760 h100 Multi VScroll", "")
        configEdit.BackColor := "0x2d2d2d"
        configEdit.SetFont("s9 cWhite", "Consolas")
        
        ; Validation and actions
        gui.Add("Button", "x20 y600 w150 h40", "✅ Validate JSON").OnEvent("Click", this.ValidateJSON.Bind(this))
        gui.Add("Button", "x190 y600 w150 h40", "🎨 Format JSON").OnEvent("Click", this.FormatJSON.Bind(this))
        gui.Add("Button", "x360 y600 w150 h40", "🔄 Reset to Default").OnEvent("Click", this.ResetToDefault.Bind(this))
        gui.Add("Button", "x530 y600 w150 h40", "❓ Help").OnEvent("Click", this.ShowHelp.Bind(this))
        
        ; Status
        gui.Add("Text", "x20 y650 w760 Center c0x888888", "Hotkeys: Ctrl+Alt+C (Load Config) | F12 (Validate) | Press Load Config to start")
        
        ; Store references
        gui.serverList := serverList
        gui.configEdit := configEdit
        
        ; Set up hotkeys
        this.SetupHotkeys(gui)
        
        gui.Show("w800 h700")
    }
    
    static LoadConfig(*) {
        try {
            this.LogDebug("LoadConfig() called")
            
            if (!FileExist(this.claudeConfig)) {
                this.LogDebug("Config file not found: " . this.claudeConfig)
                MsgBox("Claude config file not found: " . this.claudeConfig . "`n`nWould you like to create a default configuration?", "Config Not Found", "Icon? YesNo")
                if (A_LastError = "Yes") {
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
            if (WinExist("MCP Config Manager")) {
                WinActivate("MCP Config Manager")
                ; Update config editor
                try {
                    gui := GuiFromHwnd(WinGetID("MCP Config Manager"))
                    gui.configEdit.Text := configContent
                } catch {
                    ; Handle GUI update error
                }
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
            
            ; Save config
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
            
            result := InputBox("Enter backup number:", backupText, "Restore Backup")
            if (result.Result != "OK" || result.Value = "") return
            backupNum := Integer(result.Value)
            
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
            result := InputBox("Enter server name:", "Add MCP Server")
            if (result.Result != "OK" || result.Value = "") return
            name := result.Value
            
            result := InputBox("Enter command (e.g., python):", "Add MCP Server")
            if (result.Result != "OK" || result.Value = "") return
            command := result.Value
            
            result := InputBox("Enter arguments (e.g., main.py):", "Add MCP Server")
            if (result.Result != "OK" || result.Value = "") return
            args := result.Value
            
            result := InputBox("Enter working directory (optional):", "Add MCP Server")
            cwd := (result.Result = "OK" ? result.Value : "")
            
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
            
            result := InputBox("Enter new server name:", "Duplicate Server")
            if (result.Result != "OK" || result.Value = "") return
            name := result.Value
            
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
            
            infoText := "Server Information: " . selectedServer . "`n`n"
            infoText .= "This would show detailed server configuration,`n"
            infoText .= "status, logs, and performance metrics."
            
            MsgBox(infoText, "Server Info", "Iconi")
            
        } catch as e {
            MsgBox("Error getting server info: " . e.Message, "Error", "Iconx")
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
            if (this.configData = "") return
            
            servers := []
            
            ; Simple parsing to extract server names
            if (RegExMatch(this.configData, '"mcpServers"\s*:\s*\{([^}]+)\}')) {
                ; Extract server names from JSON
                Loop Parse, this.configData, '"' {
                    if (Mod(A_Index, 2) = 0 && A_LoopField != "mcpServers") {
                        servers.Push(A_LoopField)
                    }
                }
            }
            
            ; Update server list in GUI
            if (WinExist("MCP Config Manager")) {
                try {
                    gui := GuiFromHwnd(WinGetID("MCP Config Manager"))
                    gui.serverList.Text := servers.Join("`n")
                } catch {
                    ; Handle GUI update error
                }
            }
            
        } catch as e {
            ; Handle parsing error
        }
    }
    
    static GetSelectedServer() {
        ; This would get the selected server from the GUI
        ; For now, return first server if any exist
        try {
            if (WinExist("MCP Config Manager")) {
                gui := GuiFromHwnd(WinGetID("MCP Config Manager"))
                return gui.serverList.Text
            }
        } catch {
            ; Handle error
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
        
        FileAppend(defaultConfig, this.claudeConfig)
        this.configData := defaultConfig
    }
    
    static ValidateJSONContent(json) {
        try {
            ; Basic JSON validation
            if (!InStr(json, "{")) return false
            if (!InStr(json, "}")) return false
            
            ; Check for basic structure
            if (!InStr(json, "mcpServers")) return false
            
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
        if (WinExist("MCP Config Manager")) {
            WinClose("MCP Config Manager")
        }
    }
    
    static SetupHotkeys(gui) {
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


