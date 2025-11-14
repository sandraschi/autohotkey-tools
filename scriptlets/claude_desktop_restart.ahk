; ==============================================================================
; Claude Desktop Restart Helper
; @name: Claude Desktop Restart Helper
; @version: 1.0.0
; @description: Intelligent Claude Desktop restart with graceful shutdown and fallback mechanisms. Automatically detects Claude Desktop installation and restarts it safely.
; @description: Provides multiple restart methods including graceful shutdown, force termination, and process monitoring. Ensures Claude Desktop restarts cleanly for MCP server updates.
; @description: Essential development tool for MCP developers who need to restart Claude Desktop after server configuration changes or updates.
; @category: development
; @author: Sandra
; @hotkeys: ^!r, ^!x, F8
; @enabled: true
; @priority: 20
; @tag: claude, desktop, restart, mcp, development, automation, tools, productivity
; @cli: --graceful - Use graceful shutdown method (default)
; @cli: --force - Force terminate Claude Desktop process
; @cli: --wait <seconds> - Wait time before restart (default: 2)
; @cli: --detect-path - Auto-detect Claude Desktop installation path
; @cli: --help - Show CLI usage and restart options
; @dependencies: 
; ==============================================================================

#Requires AutoHotkey v2.0+
#SingleInstance Force
#Include %A_ScriptDir%\lib\ScriptletErrorHandler.ahk


; Suppress error popups - log to file instead
OnError(LogError)

class ClaudeRestart {
    static claudeExe := ""
    static configFile := ""
    static tempDir := ""
    
    static Init() {
        this.FindClaudeExecutable()
        this.configFile := A_AppData . "\Claude\claude_desktop_config.json"
        this.tempDir := A_Temp . "\"
        this.CreateGUI()
    }
    
    static FindClaudeExecutable() {
        ; Try to find Claude Desktop executable
        possiblePaths := [
            A_AppData . "\Local\AnthropicClaude\claude.exe",
            "C:\Users\" . A_UserName . "\AppData\Local\AnthropicClaude\claude.exe",
            "C:\Program Files\AnthropicClaude\claude.exe",
            "C:\Program Files (x86)\AnthropicClaude\claude.exe"
        ]
        
        for path in possiblePaths {
            if (FileExist(path)) {
                this.claudeExe := path
                return
            }
        }
        
        ; If not found, show instructions
        this.ShowClaudeInstructions()
    }
    
    static ShowClaudeInstructions() {
        instructionsText := "🚀 CLAUDE DESKTOP REQUIRED 🚀`n`n"
        instructionsText .= "Claude Desktop not found! Please install it:`n`n"
        instructionsText .= "1. Download from: https://claude.ai/download`n"
        instructionsText .= "2. Install Claude Desktop`n"
        instructionsText .= "3. Restart this scriptlet`n`n"
        instructionsText .= "Expected locations:`n"
        instructionsText .= "• " . A_AppData . "\Local\AnthropicClaude\claude.exe`n"
        instructionsText .= "• C:\Program Files\AnthropicClaude\claude.exe`n`n"
        instructionsText .= "Press OK to continue."
        
        ClaudeRestart.ShowNotification(instructionsText, "Claude Desktop Required")
    }
    
    static CreateGUI() {
        newGui := Gui("+Resize +MinSize600x400", "Claude Desktop Restart Helper")
        newGui.BackColor := "2d2d2d"
        newGui.SetFont("s10 cFFFFFF", "Segoe UI")
        
        ; Title
        newGui.Add("Text", "x20 y20 w560 Center Bold", "🚀 Claude Desktop Restart Helper")
        newGui.Add("Text", "x20 y50 w560 Center ", "Intelligent restart with graceful shutdown and fallback")
        
        ; Status section
        newGui.Add("Text", "x20 y90 w560 Bold", "📊 Status Information")
        newGui.Add("Text", "x20 y115 w560", "Claude Executable: " . (this.claudeExe ? this.claudeExe : "Not Found"))
        newGui.Add("Text", "x20 y140 w560", "Config File: " . this.configFile)
        newGui.Add("Text", "x20 y165 w560", "Temp Directory: " . this.tempDir)
        
        ; Restart options
        newGui.Add("Text", "x20 y200 w560 Bold", "🔄 Restart Options")
        
        ; Intelligent Restart
        newGui.Add("Button", "x20 y230 w200 h50", "Intelligent Restart").OnEvent("Click", this.IntelligentRestart.Bind(this))
        newGui.Add("Text", "x240 y240 w340 ", "Graceful shutdown → Force kill → Restart")
        
        ; Emergency Restart
        newGui.Add("Button", "x20 y290 w200 h50", "Emergency Restart").OnEvent("Click", this.EmergencyRestart.Bind(this))
        newGui.Add("Text", "x240 y300 w340 ", "Force kill all processes → Clean restart")
        
        ; Config Reload
        newGui.Add("Button", "x20 y350 w200 h50", "Config Reload").OnEvent("Click", this.ConfigReload.Bind(this))
        newGui.Add("Text", "x240 y360 w340 ", "Validate config → Restart Claude")
        
        ; Controls
        newGui.Add("Text", "x20 y420 w560 Center ", "Hotkeys: Ctrl+Alt+R (Intelligent) | Ctrl+Alt+X (Emergency) | F8 (Config Reload)")
        
        ; Set up hotkeys
        this.SetupHotkeys()
        
        newGui.Show("w600 h450")
    }
    
    static IntelligentRestart(*) {
        this.LogOperation("Intelligent Restart")
        TrayTip("Restarting Claude Desktop", "Gracefully closing and restarting...", 2)
        
        try {
            ; Try graceful shutdown first
            WinActivate("Claude")
            Sleep(500)
            Send("!{F4}")  ; Alt+F4 for graceful close
            Sleep(3000)
            
            ; Wait for process to close
            WinWaitClose("Claude",, 10)
        } catch {
            ; Fallback to force kill
            Run("taskkill /f /im Claude.exe", , "Hide")
            Sleep(2000)
        }
        
        ; Clear any potential locks
        try {
            try FileDelete(this.tempDir . "claude_restart.lock")
        } catch {
            ; Ignore if file doesn't exist
        }
        
        ; Restart Claude Desktop
        if (this.claudeExe) {
            Run(this.claudeExe)
            Sleep(3000)
            TrayTip("Claude Desktop Restarted", "Ready for MCP development!", 2)
            this.SendClaudeMessage("Claude Desktop restarted at " . A_Now . " - MCP servers should reconnect automatically")
        } else {
            ClaudeRestart.ShowNotification("Cannot restart Claude Desktop - executable not found!", "Restart Error")
        }
    }
    
    static EmergencyRestart(*) {
        this.LogOperation("Emergency Restart")
        TrayTip("Emergency Restart", "Force killing and restarting...", 2)
        
        ; Force kill all related processes
        Run("taskkill /f /im Claude.exe /t", , "Hide")
        Run("taskkill /f /im python.exe /f", , "Hide")
        
        Sleep(3000)
        
        ; Clean up temp files
        try {
            try FileDelete(this.tempDir . "claude_*.lock")
            try FileDelete(this.tempDir . "mcp_*.tmp")
        } catch {
            ; Ignore cleanup errors
        }
        
        ; Restart Claude Desktop
        if (this.claudeExe) {
            Run(this.claudeExe)
            TrayTip("Emergency Restart Complete", "Claude Desktop restarted fresh!", 3)
        } else {
            ClaudeRestart.ShowNotification("Cannot restart Claude Desktop - executable not found!", "Restart Error")
        }
    }
    
    static ConfigReload(*) {
        this.LogOperation("Config Reload")
        
        ; Validate config file
        if (!FileExist(this.configFile)) {
            ClaudeRestart.ShowNotification("Claude config file not found: " . this.configFile, "Configuration Error")
            return
        }
        
        try {
            ; Read and validate JSON
            configContent := FileRead(this.configFile)
            ; Basic JSON validation (could be enhanced)
            if (!InStr(configContent, "mcpServers")) {
                ClaudeRestart.ShowNotification("Warning: Config file may not contain MCP servers configuration", "Configuration Warning")
            }
            
            TrayTip("Config Validated", "Restarting Claude Desktop...", 2)
            
            ; Trigger restart
            Sleep(2000)
            this.IntelligentRestart()
            
        } catch as e {
            ClaudeRestart.ShowNotification("Error validating config: " . e.Message, "Validation Error")
        }
    }
    
    static SendClaudeMessage(message) {
        try {
            WinActivate("Claude")
            Sleep(500)
            SendText(message)
            Send("{Enter}")
        } catch {
            ; Ignore if Claude not active
        }
    }
    
    static LogOperation(operation) {
        try {
            logFile := this.tempDir . "claude_restart.log"
            timestamp := ""
            timestamp := FormatTime(, "yyyy-MM-dd HH:mm:ss")
            logEntry := timestamp . " - " . operation . "`n"
            FileAppend(logEntry, logFile)
        } catch {
            ; Ignore logging errors
        }
    }
    
    static SetupHotkeys() {
        ; Intelligent restart
        Hotkey("^!r", (*) => this.IntelligentRestart())
        
        ; Emergency restart
        Hotkey("^!x", (*) => this.EmergencyRestart())
        
        ; Config reload
        Hotkey("F8", (*) => this.ConfigReload())
        
        ; Escape to close
        Hotkey("Escape", (*) => this.CloseHelper())
    }

    static CloseHelper() {
        if (WinExist("Claude Desktop Restart Helper")) {
            WinClose("Claude Desktop Restart Helper")
        }
    }
}

; Hotkeys
Hotkey("^!r", (*) => ClaudeRestart.IntelligentRestart())
Hotkey("^!x", (*) => ClaudeRestart.EmergencyRestart())
Hotkey("F8", (*) => ClaudeRestart.ConfigReload())

; Initialize
ClaudeRestart.Init()


