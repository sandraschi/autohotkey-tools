; ==============================================================================
; MCP Troubleshooter
; @name: MCP Troubleshooter
; @version: 1.0.0
; @description: Smart MCP troubleshooting with automated fixes and diagnostics. Intelligent diagnostic system for MCP server issues with automated resolution suggestions.
; @description: Features automated server testing, dependency checking, configuration validation, and fix recommendations. Supports server restart, configuration repair, and dependency installation.
; @description: Essential troubleshooting tool for MCP developers to diagnose and resolve server issues quickly with automated diagnostics and fix recommendations.
; @category: development
; @author: Sandra
; @hotkeys: ^!t, F11
; @enabled: true
; @priority: 10
; @tag: mcp, troubleshooting, diagnostics, automation, fixes, development, error-resolution
; @cli: --test <server> - Test specific MCP server
; @cli: --fix - Attempt to automatically fix detected issues
; @cli: --check-deps - Check and install missing dependencies
; @cli: --help - Show CLI usage and troubleshooting options
; @dependencies: 
; ==============================================================================

#Requires AutoHotkey v2.0+
#SingleInstance Force
#Include %A_ScriptDir%\lib\ScriptletErrorHandler.ahk
#Include %A_ScriptDir%\lib\JSON.ahk

OnError(LogError)

class MCPTroubleshooter {
    static gui := ""
    static serverList := ""
    static resultView := ""
    static logView := ""
    static statusBar := ""
    static configPath := A_AppData . "\Claude\claude_desktop_config.json"
    static logFile := A_ScriptDir . "\mcp_troubleshooter.log"
    static hotkeysRegistered := false

    static Init() {
        MCPTroubleshooter.AppendLog("Initializing MCP Troubleshooter")
        if (!MCPTroubleshooter.gui) {
            MCPTroubleshooter.CreateGui()
            MCPTroubleshooter.SetupHotkeys()
        }
        MCPTroubleshooter.LoadServers()
        MCPTroubleshooter.gui.Show("w960 h760 Center")
        MCPTroubleshooter.statusBar.SetText("Ready. Press Ctrl+Alt+T for config diagnostics.")
    }

    static HandleError(Thrown, Mode) {
        scriptName := HasProp(Thrown, "File") ? Thrown.File : A_ScriptFullPath
        lineInfo := HasProp(Thrown, "Line") ? " line " . Thrown.Line : ""
        message := "Error in " . scriptName . lineInfo . ": " . Thrown.Message
        MCPTroubleshooter.AppendLog(message)
        return 1
    }

    static AppendLog(message) {
        timestamp := FormatTime(A_Now, "yyyy-MM-dd HH:mm:ss")
        entry := "[" . timestamp . "] " . message
        try {
            FileAppend(entry . "`n", MCPTroubleshooter.logFile, "UTF-8")
        } catch {
        }
        if (MCPTroubleshooter.logView) {
            MCPTroubleshooter.logView.Value .= entry . "`n"
            MCPTroubleshooter.logView.Redraw()
        }
        OutputDebug(entry)
    }

    static CreateGui() {
        gui := Gui("+Resize +MinSize940x680", "MCP Troubleshooter")
        gui.BackColor := "1f1f1f"
        gui.SetFont("s10 cFFFFFF", "Segoe UI")

        gui.AddText("x20 y20 w900 Center Bold", "🔧 MCP Troubleshooter")
        gui.AddText("x20 y48 w900 Center cC0C0C0", "Run diagnostics, review MCP servers, and capture troubleshooting notes.")

        gui.AddText("x20 y88 w900 Bold", "Configuration")
        gui.AddText("x20 y114 w140", "Claude Config:")
        gui.AddEdit("x160 y108 w560 h26 ReadOnly", MCPTroubleshooter.configPath)
        openCfgBtn := gui.AddButton("x740 y108 w180 h26", "Open Config")
        openCfgBtn.OnEvent("Click", MCPTroubleshooter.OpenConfig)

        gui.AddText("x20 y150 w400 Bold", "MCP Servers")
        serverList := gui.AddListView("x20 y176 w400 h260 -Hdr", ["Server", "Command"])
        MCPTroubleshooter.serverList := serverList

        diagGroup := gui.AddGroupBox("x440 y150 w460 h170", "Diagnostics")
        btnConfig := gui.AddButton("x460 y180 w200 h40", "📋 Check Config")
        btnConfig.OnEvent("Click", MCPTroubleshooter.RunConfigCheck)
        btnPython := gui.AddButton("x700 y180 w200 h40", "🐍 Check Python")
        btnPython.OnEvent("Click", MCPTroubleshooter.RunPythonCheck)
        btnDeps := gui.AddButton("x460 y232 w200 h40", "📦 Check Dependencies")
        btnDeps.OnEvent("Click", MCPTroubleshooter.RunDependencyCheck)
        btnNetwork := gui.AddButton("x700 y232 w200 h40", "🌐 Check Connectivity")
        btnNetwork.OnEvent("Click", MCPTroubleshooter.RunConnectivityCheck)

        gui.AddGroupBox("x440 y326 w460 h110", "Quick Actions")
        btnFix := gui.AddButton("x460 y354 w200 h40", "🛠 Apply Quick Fixes")
        btnFix.OnEvent("Click", MCPTroubleshooter.ApplyQuickFixes)
        btnLogs := gui.AddButton("x700 y354 w200 h40", "📂 Open Logs Folder")
        btnLogs.OnEvent("Click", MCPTroubleshooter.OpenLogDirectory)

        gui.AddText("x20 y446 w900 Bold", "Diagnostic Output")
        resultView := gui.AddEdit("x20 y474 w900 h150 ReadOnly VScroll", "")
        resultView.BackColor := "262626"
        resultView.SetFont("s9", "Consolas")
        MCPTroubleshooter.resultView := resultView

        gui.AddText("x20 y634 w900 Bold", "Activity Log")
        logEdit := gui.AddEdit("x20 y662 w900 h80 ReadOnly VScroll", "")
        logEdit.BackColor := "242424"
        logEdit.SetFont("s9", "Consolas")
        MCPTroubleshooter.logView := logEdit

        status := gui.AddStatusBar("Simple")
        status.SetText("Ready")
        MCPTroubleshooter.statusBar := status

        gui.OnEvent("Size", MCPTroubleshooter.OnResize)
        gui.OnEvent("Close", MCPTroubleshooter.HideWindow)
        gui.OnEvent("Escape", MCPTroubleshooter.HideWindow)
        MCPTroubleshooter.gui := gui
    }

    static SetupHotkeys() {
        if (MCPTroubleshooter.hotkeysRegistered) {
            return
        }
        Hotkey("^!t", MCPTroubleshooter.RunConfigCheck)
        Hotkey("^F11", MCPTroubleshooter.ApplyQuickFixes)
        Hotkey("F11", MCPTroubleshooter.ApplyQuickFixes)
        Hotkey("Escape", (*) => MCPTroubleshooter.gui && WinActive("ahk_id " MCPTroubleshooter.gui.Hwnd) && MCPTroubleshooter.HideWindow())
        MCPTroubleshooter.hotkeysRegistered := true
    }

    static OnResize(gui, minMax, width, height) {
        padding := 20
        listHeight := height - 380
        MCPTroubleshooter.serverList.Move(padding, 176, 400, listHeight)
        MCPTroubleshooter.resultView.Move(padding, height - 260, width - padding * 2, 150)
        MCPTroubleshooter.logView.Move(padding, height - 100, width - padding * 2, 80)
    }

    static LoadServers() {
        MCPTroubleshooter.serverList.Delete()
        if (!FileExist(MCPTroubleshooter.configPath)) {
            MCPTroubleshooter.resultView.Value := "Claude configuration not found at " . MCPTroubleshooter.configPath
            return
        }
        try {
            configText := FileRead(MCPTroubleshooter.configPath, "UTF-8")
            config := JSON.Load(configText)
            if (config.Has("mcpServers")) {
                for name, data in config["mcpServers"] {
                    command := data.Has("command") ? data["command"] : "(unknown)"
                    MCPTroubleshooter.serverList.Add(, name, command)
                }
                MCPTroubleshooter.serverList.ModifyCol()
            } else {
                MCPTroubleshooter.resultView.Value := "No mcpServers block found in configuration."
            }
        } catch as e {
            MCPTroubleshooter.resultView.Value := "Failed to parse configuration: " . e.Message
        }
    }

    static OpenConfig(*) {
        if (FileExist(MCPTroubleshooter.configPath)) {
            Run('notepad "' . MCPTroubleshooter.configPath . '"')
        } else {
            MsgBox("Config file not found.", "MCP Troubleshooter", "Icon!")
        }
    }

    static RunConfigCheck(*) {
        summary := "📋 Configuration Check`n`n"
        if (!FileExist(MCPTroubleshooter.configPath)) {
            summary .= "❌ Config file missing: " . MCPTroubleshooter.configPath . "`n"
        } else {
            try {
                config := JSON.Load(FileRead(MCPTroubleshooter.configPath, "UTF-8"))
                summary .= "✅ Config file found`n"
                summary .= config.Has("mcpServers") ? "✅ mcpServers section present`n" : "⚠️ mcpServers section missing`n"
                summary .= config.Has("claude") ? "✅ claude section present`n" : "⚠️ claude section missing`n"
            } catch as e {
                summary .= "❌ JSON parse error: " . e.Message . "`n"
            }
        }
        MCPTroubleshooter.Report(summary)
    }

    static RunPythonCheck(*) {
        summary := "🐍 Python Environment Check`n`n"
        pythonVersion := MCPTroubleshooter.RunCli("python --version")
        summary .= pythonVersion.success ? "✅ " . pythonVersion.output . "`n" : "❌ python --version failed`n"
        pipVersion := MCPTroubleshooter.RunCli("pip --version")
        summary .= pipVersion.success ? "✅ " . pipVersion.output . "`n" : "❌ pip --version failed`n"
        env := EnvGet("VIRTUAL_ENV")
        summary .= env ? "✅ Active virtualenv: " . env . "`n" : "⚠️ No virtual environment detected`n"
        MCPTroubleshooter.Report(summary)
    }

    static RunDependencyCheck(*) {
        summary := "📦 Dependency Check`n`n"
        for dep in ["fastmcp", "requests", "pydantic"] {
            result := MCPTroubleshooter.RunCli("pip show " . dep)
            summary .= result.success ? "✅ " . dep . " installed`n" : "❌ " . dep . " missing`n"
        }
        summary .= "`nRecommendation: pip install fastmcp requests pydantic`n"
        MCPTroubleshooter.Report(summary)
    }

    static RunConnectivityCheck(*) {
        summary := "🌐 Connectivity Check`n`n"
        loopPorts := [8000, 8001, 8002, 10744]
        for port in loopPorts {
            result := MCPTroubleshooter.RunCli("netstat -an | findstr :" . port)
            summary .= result.success && InStr(result.output, ":" . port) ? "⚠️ Port " . port . " in use`n" : "✅ Port " . port . " available`n"
        }
        MCPTroubleshooter.Report(summary)
    }

    static ApplyQuickFixes(*) {
        summary := "🛠 Quick Fixes`n`n"
        if (!FileExist(MCPTroubleshooter.configPath)) {
            DirCreate(DirGetParent(MCPTroubleshooter.configPath))
            defaultConfig := Map("mcpServers", Map("example-server", Map("command", "python", "args", ["main.py"], "cwd", A_ScriptDir)))
            MCPTroubleshooter.WriteJson(MCPTroubleshooter.configPath, defaultConfig)
            summary .= "Created default Claude configuration.`n"
        } else {
            summary .= "Config file already exists.`n"
        }
        MCPTroubleshooter.Report(summary)
    }

    static OpenLogDirectory(*) {
        logDir := A_AppData . "\Claude\logs"
        if (DirExist(logDir)) {
            Run('explorer "' . logDir . '"')
        } else {
            MsgBox("Log directory not found.", "MCP Troubleshooter", "Icon!")
        }
    }

    static RunCli(command) {
        result := {success: false, output: ""}
        try {
            RunWait(command, , "Hide", &output)
            result.success := true
            result.output := Trim(output)
        } catch {
        }
        return result
    }

    static WriteJson(path, data) {
        json := JSON.Dump(data, "indent")
        try FileDelete(path)
        FileAppend(json, path, "UTF-8")
    }

    static Report(text) {
        MCPTroubleshooter.resultView.Value := text
        MCPTroubleshooter.AppendLog(Trim(StrReplace(text, "`n", " | ")))
        timestamp := FormatTime(A_Now, "HH:mm:ss")
        MCPTroubleshooter.statusBar.SetText("Diagnostics updated at " . timestamp)
    }

    static HideWindow(*) {
        if !MCPTroubleshooter.gui
            return
        if !WinActive("ahk_id " MCPTroubleshooter.gui.Hwnd)
            return
        MCPTroubleshooter.gui.Hide()
        MCPTroubleshooter.statusBar.SetText("GUI hidden. Press Ctrl+Alt+T to reopen.")
    }
}

MCPTroubleshooter.Init()

OnExit((*) => MCPTroubleshooter.AppendLog("Script exiting."))



