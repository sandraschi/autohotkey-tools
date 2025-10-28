; ==============================================================================
; Claude Desktop Restart Helper
; @name: Claude Desktop Restart Helper
; @version: 1.0.0
; @description: Intelligent Claude Desktop restart with graceful shutdown and fallback
; @category: development
; @author: Sandra
; @hotkeys: ^!r, ^!x, F8
; @enabled: true
; ==============================================================================

#Requires AutoHotkey v2.0+
#SingleInstance Force


; Suppress error popups - log to file instead
OnError("LogError")

LogError(Exception, Mode) {
    FileAppend("Error: " . Exception.Message . " at line " . Exception.Line . "
", "errors.log", "UTF-8")
    return true  ; Suppress popup
}


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
        
        MsgBox(instructionsText, "Claude Desktop Required", "Iconi")
    }
    
    static CreateGUI() {
        gui := Gui("+Resize +MinSize600x400", "Claude Desktop Restart Helper")
        gui.BackColor := "0x2d2d2d"
        gui.SetFont("s10 cWhite", "Segoe UI")
        
        ; Title
        gui.Add("Text", "x20 y20 w560 Center Bold", "🚀 Claude Desktop Restart Helper")
        gui.Add("Text", "x20 y50 w560 Center c0xcccccc", "Intelligent restart with graceful shutdown and fallback")
        
        ; Status section
        gui.Add("Text", "x20 y90 w560 Bold", "📊 Status Information")
        gui.Add("Text", "x20 y115 w560", "Claude Executable: " . (this.claudeExe ? this.claudeExe : "Not Found"))
        gui.Add("Text", "x20 y140 w560", "Config File: " . this.configFile)
        gui.Add("Text", "x20 y165 w560", "Temp Directory: " . this.tempDir)
        
        ; Restart options
        gui.Add("Text", "x20 y200 w560 Bold", "🔄 Restart Options")
        
        ; Intelligent Restart
        gui.Add("Button", "x20 y230 w200 h50", "Intelligent Restart").OnEvent("Click", this.IntelligentRestart.Bind(this))
        gui.Add("Text", "x240 y240 w340 c0xcccccc", "Graceful shutdown → Force kill → Restart")
        
        ; Emergency Restart
        gui.Add("Button", "x20 y290 w200 h50", "Emergency Restart").OnEvent("Click", this.EmergencyRestart.Bind(this))
        gui.Add("Text", "x240 y300 w340 c0xcccccc", "Force kill all processes → Clean restart")
        
        ; Config Reload
        gui.Add("Button", "x20 y350 w200 h50", "Config Reload").OnEvent("Click", this.ConfigReload.Bind(this))
        gui.Add("Text", "x240 y360 w340 c0xcccccc", "Validate config → Restart Claude")
        
        ; Controls
        gui.Add("Text", "x20 y420 w560 Center c0x888888", "Hotkeys: Ctrl+Alt+R (Intelligent) | Ctrl+Alt+X (Emergency) | F8 (Config Reload)")
        
        ; Set up hotkeys
        this.SetupHotkeys()
        
        gui.Show("w600 h450")
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
            MsgBox("Cannot restart Claude Desktop - executable not found!", "Error", "Iconx")
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
            MsgBox("Cannot restart Claude Desktop - executable not found!", "Error", "Iconx")
        }
    }
    
    static ConfigReload(*) {
        this.LogOperation("Config Reload")
        
        ; Validate config file
        if (!FileExist(this.configFile)) {
            MsgBox("Claude config file not found: " . this.configFile, "Error", "Iconx")
            return
        }
        
        try {
            ; Read and validate JSON
            configContent := FileRead(this.configFile)
            ; Basic JSON validation (could be enhanced)
            if (!InStr(configContent, "mcpServers")) {
                MsgBox("Warning: Config file may not contain MCP servers configuration", "Warning", "Icon!")
            }
            
            TrayTip("Config Validated", "Restarting Claude Desktop...", 2)
            
            ; Trigger restart
            Sleep(2000)
            this.IntelligentRestart()
            
        } catch as e {
            MsgBox("Error validating config: " . e.Message, "Error", "Iconx")
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
            logEntry := FormatTime(A_Now, "yyyy-MM-dd HH:mm:ss") . " - " . operation . "`n"
            FileAppend(logEntry, logFile)
        } catch {
            ; Ignore logging errors
        }
    }
    
    static SetupHotkeys() {
        ; Intelligent restart
        Hotkey("^!r", (*) => this.IntelligentRestart()
        
        ; Emergency restart
        Hotkey("^!x", (*) => this.EmergencyRestart()
        
        ; Config reload
        Hotkey("F8", (*) => this.ConfigReload()
        
        ; Escape to close
        Hotkey("Escape", (*) => {
            if (WinExist("Claude Desktop Restart Helper")) {
                WinClose("Claude Desktop Restart Helper")
            }
        }
    }
}

; Hotkeys
Hotkey("^!r", (*) => ClaudeRestart.IntelligentRestart()
Hotkey("^!x", (*) => ClaudeRestart.EmergencyRestart()
Hotkey("F8", (*) => ClaudeRestart.ConfigReload()

; Initialize
ClaudeRestart.Init()


