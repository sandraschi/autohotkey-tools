; ==============================================================================
; AutoHotkey Debug Helper
; @name: AutoHotkey Debug Helper
; @version: 1.0.0
; @description: Comprehensive debugging tools for AutoHotkey v2 scripts including variable inspection, line tracing, key history, and debug logging.
; @description: Provides real-time debugging GUI with variable listing, active line monitoring, hotkey tracking, and system information display.
; @description: Essential tool for AutoHotkey developers to troubleshoot scripts, inspect runtime state, and track execution flow.
; @category: development
; @author: Sandra
; @hotkeys: ^!d, F3, ^!v, ^!l, ^!k
; @enabled: true
; @priority: 5
; @tag: debugging, development, tools, inspection, troubleshooting, variables, hotkeys
; @cli: --debug-mode - Start in debug mode (verbose logging)
; @cli: --log-file <path> - Specify custom log file path
; @cli: --trace-lines - Enable line-by-line execution tracing
; @cli: --variable-watch <var> - Watch specific variable changes
; @cli: --help - Show CLI usage and debugging options
; @dependencies: 
; ==============================================================================

#Requires AutoHotkey v2.0+
#SingleInstance Force
#Include %A_ScriptDir%\lib\ScriptletErrorHandler.ahk

OnError(LogError)

HandleScriptError(Thrown, Mode) {
    return AHDebugHelper.HandleScriptError(Thrown, Mode)
}

class AHDebugHelper {
    static mainGui := ""
    static debugOutput := ""
    static scriptPathEdit := ""
    static errorStdOutCheck := ""
    static noTrayIconCheck := ""
    static forceReloadCheck := ""
    static debugLog := []
    static isVisible := false
    static logDir := ""
    static logFilePath := ""
    static logInitialized := false

    static Init() {
        AHDebugHelper.EnsureLogInfrastructure()
        if (!AHDebugHelper.mainGui) {
            AHDebugHelper.CreateGUI()
            AHDebugHelper.SetupHotkeys()
            AHDebugHelper.AddDebugOutput("Debug helper initialized.")
        }
    }

    static CreateGUI() {
        try {
            newGui := Gui("+Resize +MinSize800x650", "AutoHotkey Debug Helper")
            newGui.BackColor := "1a1a1a"
            newGui.SetFont("s10 cFFFFFF", "Segoe UI")

            newGui.AddText("x20 y20 w760 Center Bold", "🔧 AutoHotkey Debug Helper")
            newGui.AddText("x20 y50 w760 Center", "Comprehensive debugging tools for AutoHotkey v2 scripts")

            newGui.AddText("x20 y90 w760 Bold", "🎯 Debug Controls")
            newGui.AddButton("x20 y120 w150 h40", "📊 List Variables").OnEvent("Click", (*) => AHDebugHelper.ListVariables())
            newGui.AddButton("x190 y120 w150 h40", "📝 List Lines").OnEvent("Click", (*) => AHDebugHelper.ListLines())
            newGui.AddButton("x360 y120 w150 h40", "⌨️ Key History").OnEvent("Click", (*) => AHDebugHelper.KeyHistory())
            newGui.AddButton("x530 y120 w150 h40", "📋 Debug Log").OnEvent("Click", (*) => AHDebugHelper.ShowDebugLog())

            newGui.AddText("x20 y180 w760 Bold", "🔍 Script Analysis")
            newGui.AddButton("x20 y210 w150 h40", "🔍 Analyze Script").OnEvent("Click", (*) => AHDebugHelper.AnalyzeScript())
            newGui.AddButton("x190 y210 w150 h40", "⚠️ Check Syntax").OnEvent("Click", (*) => AHDebugHelper.CheckSyntax())
            newGui.AddButton("x360 y210 w150 h40", "🔗 Dependencies").OnEvent("Click", (*) => AHDebugHelper.FindDependencies())
            newGui.AddButton("x530 y210 w150 h40", "📊 Performance").OnEvent("Click", (*) => AHDebugHelper.PerformanceAnalysis())

            newGui.AddText("x20 y270 w760 Bold", "💻 Command Line Debugging")
            newGui.AddText("x20 y300 w150", "Script Path:")
            scriptPathEdit := newGui.AddEdit("x180 y295 w400 h25", A_ScriptDir . "\test_script.ahk")
            newGui.AddButton("x600 y295 w150 h40", "🚀 Run with Debug").OnEvent("Click", (*) => AHDebugHelper.RunWithDebug())

            errorStdOutCheck := newGui.AddCheckBox("x20 y330 w200", "ErrorStdOut")
            errorStdOutCheck.Value := 1
            noTrayIconCheck := newGui.AddCheckBox("x240 y330 w200", "NoTrayIcon")
            noTrayIconCheck.Value := 1
            forceReloadCheck := newGui.AddCheckBox("x460 y330 w200", "Restart (Force reload)")
            forceReloadCheck.Value := 0

            newGui.AddText("x20 y370 w760 Bold", "📋 Debug Output")
            debugOutput := newGui.AddEdit("x20 y400 w760 h170 ReadOnly Multi VScroll", "")
            debugOutput.BackColor := "2d2d2d"
            debugOutput.SetFont("s9 cFFFFFF", "Consolas")

            newGui.AddButton("x20 y580 w150 h40", "💾 Save Log").OnEvent("Click", (*) => AHDebugHelper.SaveDebugLog())
            newGui.AddButton("x190 y580 w150 h40", "📋 Copy Output").OnEvent("Click", (*) => AHDebugHelper.CopyOutput())
            newGui.AddButton("x360 y580 w150 h40", "🧹 Clear Output").OnEvent("Click", (*) => AHDebugHelper.ClearOutput())
            newGui.AddButton("x530 y580 w150 h40", "❓ Help").OnEvent("Click", (*) => AHDebugHelper.ShowHelp())

            newGui.AddText("x20 y630 w760 Center", "Hotkeys: Ctrl+Alt+D (Toggle) • F3 (List Vars) • Ctrl+Alt+V (List Lines) • Ctrl+Alt+K (Key History)")

            newGui.OnEvent("Close", (*) => AHDebugHelper.CloseGUI())

            AHDebugHelper.mainGui := newGui
            AHDebugHelper.debugOutput := debugOutput
            AHDebugHelper.scriptPathEdit := scriptPathEdit
            AHDebugHelper.errorStdOutCheck := errorStdOutCheck
            AHDebugHelper.noTrayIconCheck := noTrayIconCheck
            AHDebugHelper.forceReloadCheck := forceReloadCheck
        } catch as e {
            errorMsg := "Error creating GUI: " . e.Message . "`n" . e.Stack
            try {
                FileAppend(errorMsg, "autohotkey_debug_helper_errors.log", "UTF-8")
            } catch {
                ; Ignore file logging errors
            }
            OutputDebug(errorMsg)
            MsgBox("Error creating GUI: " . e.Message, "AutoHotkey Debug Helper", "Iconx")
        }
    }

    static SetupHotkeys() {
        Hotkey("^!d", (*) => AHDebugHelper.ToggleGUI())
        Hotkey("F3", (*) => AHDebugHelper.ListVariables())
        Hotkey("^!v", (*) => AHDebugHelper.ListLines())
        Hotkey("^!k", (*) => AHDebugHelper.KeyHistory())
        Hotkey("Escape", (*) => AHDebugHelper.CloseGUI())
    }

    static ToggleGUI() {
        if (!AHDebugHelper.mainGui) {
            return
        }
        if (!AHDebugHelper.isVisible) {
            AHDebugHelper.mainGui.Show("w800 h650")
            AHDebugHelper.isVisible := true
        } else {
            AHDebugHelper.mainGui.Hide()
            AHDebugHelper.isVisible := false
        }
    }

    static CloseGUI(*) {
        if (AHDebugHelper.mainGui) {
            AHDebugHelper.mainGui.Hide()
            AHDebugHelper.isVisible := false
        }
    }

    static ListVariables(*) {
        AHDebugHelper.AddDebugOutput("=== VARIABLES DEBUG ===")
        ListVars()
        AHDebugHelper.AddDebugOutput("ListVars window opened.")
    }

    static ListLines(*) {
        AHDebugHelper.AddDebugOutput("=== LINES DEBUG ===")
        ListLines()
        AHDebugHelper.AddDebugOutput("ListLines window opened.")
    }

    static KeyHistory(*) {
        AHDebugHelper.AddDebugOutput("=== KEY HISTORY DEBUG ===")
        KeyHistory()
        AHDebugHelper.AddDebugOutput("KeyHistory window opened.")
    }

    static ShowDebugLog(*) {
        AHDebugHelper.AddDebugOutput("=== DEBUG LOG ===")
        if (AHDebugHelper.debugLog.Length = 0) {
            AHDebugHelper.AddDebugOutput("No debug messages logged yet.")
            return
        }
        for index, message in AHDebugHelper.debugLog {
            AHDebugHelper.AddDebugOutput(index . ": " . message)
        }
    }

    static AnalyzeScript(*) {
        scriptPath := AHDebugHelper.scriptPathEdit.Value
        if (!FileExist(scriptPath)) {
            AHDebugHelper.AddDebugOutput("Script file not found: " . scriptPath)
            return
        }
        AHDebugHelper.AddDebugOutput("=== SCRIPT ANALYSIS ===")
        AHDebugHelper.AddDebugOutput("Analyzing: " . scriptPath)
        try {
            scriptContent := FileRead(scriptPath, "UTF-8")
            lines := StrSplit(scriptContent, "`n")
            AHDebugHelper.AddDebugOutput("Total lines: " . lines.Length)
            functions := 0
            classes := 0
            hotkeys := 0
            assignments := 0
            for , line in lines {
                trimmed := Trim(line)
                if (RegExMatch(trimmed, "^\w+\s*\(.*\)\s*\{")) {
                    functions += 1
                } else if (RegExMatch(trimmed, "^class\s+\w+")) {
                    classes += 1
                } else if (RegExMatch(trimmed, "^[^;]*::")) {
                    hotkeys += 1
                } else if (RegExMatch(trimmed, "^\w+\s*:=")) {
                    assignments += 1
                }
            }
            AHDebugHelper.AddDebugOutput("Functions: " . functions)
            AHDebugHelper.AddDebugOutput("Classes: " . classes)
            AHDebugHelper.AddDebugOutput("Hotkeys: " . hotkeys)
            AHDebugHelper.AddDebugOutput("Assignments: " . assignments)
        } catch as e {
            AHDebugHelper.AddDebugOutput("Error reading script: " . e.Message)
        }
    }

    static CheckSyntax(*) {
        scriptPath := AHDebugHelper.scriptPathEdit.Value
        if (!FileExist(scriptPath)) {
            AHDebugHelper.AddDebugOutput("Script file not found: " . scriptPath)
            return
        }
        AHDebugHelper.AddDebugOutput("=== SYNTAX CHECK ===")
        try {
            RunWait('"' . A_AhkPath . '" /ErrorStdOut /iLib "' . scriptPath . '"', "", "Hide")
            AHDebugHelper.AddDebugOutput("✅ Syntax command executed (check console output)")
        } catch as e {
            AHDebugHelper.AddDebugOutput("❌ Syntax check failed: " . e.Message)
        }
    }

    static FindDependencies(*) {
        scriptPath := AHDebugHelper.scriptPathEdit.Value
        if (!FileExist(scriptPath)) {
            AHDebugHelper.AddDebugOutput("Script file not found: " . scriptPath)
            return
        }
        AHDebugHelper.AddDebugOutput("=== DEPENDENCIES ANALYSIS ===")
        includes := []
        try {
            for , line in StrSplit(FileRead(scriptPath, "UTF-8"), "`n") {
                if (RegExMatch(line, "i)#Include\s+(.+)", &match)) {
                    includes.Push(Trim(match[1]))
                }
            }
            AHDebugHelper.AddDebugOutput("Found " . includes.Length . " include statements:")
            for , includePath in includes {
                AHDebugHelper.AddDebugOutput("  - " . includePath)
            }
        } catch as e {
            AHDebugHelper.AddDebugOutput("Error reading script: " . e.Message)
        }
    }

    static PerformanceAnalysis(*) {
        AHDebugHelper.AddDebugOutput("=== PERFORMANCE ANALYSIS ===")
        AHDebugHelper.AddDebugOutput("Uptime: " . A_TickCount . " ms")
        if (IsSet(A_WorkingSet) && A_WorkingSet !== "") {
            workingSetMb := Round((A_WorkingSet + 0) / 1024 / 1024, 2)
            AHDebugHelper.AddDebugOutput("Working Set: " . workingSetMb . " MB")
        } else {
            AHDebugHelper.AddDebugOutput("Working Set: unavailable")
        }
        if (IsSet(A_CPUUsage)) {
            AHDebugHelper.AddDebugOutput("CPU Usage: " . A_CPUUsage . "%")
        } else {
            AHDebugHelper.AddDebugOutput("CPU Usage: unavailable")
        }
    }

    static RunWithDebug(*) {
        scriptPath := AHDebugHelper.scriptPathEdit.Value
        if (!FileExist(scriptPath)) {
            AHDebugHelper.AddDebugOutput("Script file not found: " . scriptPath)
            return
        }
        cmdParts := [A_AhkPath]
        if (AHDebugHelper.errorStdOutCheck.Value) {
            cmdParts.Push("/ErrorStdOut")
        }
        if (AHDebugHelper.noTrayIconCheck.Value) {
            cmdParts.Push("/NoTrayIcon")
        }
        if (AHDebugHelper.forceReloadCheck.Value) {
            cmdParts.Push("/restart")
        }
        cmdParts.Push(scriptPath)
        command := '"' . cmdParts[1] . '"'
        for index, part in cmdParts {
            if (index = 1) {
                continue
            }
            command .= ' "' . part . '"'
        }
        AHDebugHelper.AddDebugOutput("Command: " . command)
        try {
            Run(command)
            AHDebugHelper.AddDebugOutput("✅ Script launched with selected debug flags")
        } catch as e {
            AHDebugHelper.AddDebugOutput("Error launching script: " . e.Message)
        }
    }

    static AddDebugOutput(message) {
        AHDebugHelper.AppendLog(message, "INFO")
    }

    static SaveDebugLog(*) {
        try {
            logFile := A_Temp . "\autohotkey_debug_log.txt"
            writer := FileOpen(logFile, "w", "UTF-8")
            if (!writer) {
                AHDebugHelper.AddDebugOutput("Unable to open log file for writing.")
                return
            }
            writer.WriteLine("AutoHotkey Debug Log")
            timestamp := FormatTime(A_Now, "yyyy-MM-dd HH:mm:ss")
            writer.WriteLine("Generated: " . timestamp)
            writer.WriteLine("")
            for message in AHDebugHelper.debugLog {
                writer.WriteLine(message)
            }
            writer.Close()
            AHDebugHelper.AddDebugOutput("Debug log saved to: " . logFile)
        } catch as e {
            AHDebugHelper.AddDebugOutput("Error saving debug log: " . e.Message)
        }
    }

    static CopyOutput(*) {
        if (!AHDebugHelper.debugOutput) {
            return
        }
        A_Clipboard := AHDebugHelper.debugOutput.Value
        AHDebugHelper.AddDebugOutput("Output copied to clipboard")
    }

    static ClearOutput(*) {
        if (AHDebugHelper.debugOutput) {
            AHDebugHelper.debugOutput.Value := ""
        }
        AHDebugHelper.debugLog := []
        AHDebugHelper.AddDebugOutput("Output cleared")
    }

    static ShowHelp(*) {
        helpText := "🔧 AutoHotkey Debug Helper" . "`n`n"
        helpText .= "Provides quick access to common debugging tasks:" . "`n`n"
        helpText .= "🎯 Debug Controls" . "`n"
        helpText .= "  • List Variables" . "`n"
        helpText .= "  • List Lines" . "`n"
        helpText .= "  • Key History" . "`n"
        helpText .= "  • Debug Log" . "`n`n"
        helpText .= "🔍 Script Analysis" . "`n"
        helpText .= "  • Analyze Script" . "`n"
        helpText .= "  • Check Syntax" . "`n"
        helpText .= "  • Dependencies" . "`n"
        helpText .= "  • Performance" . "`n`n"
        helpText .= "💻 Command Line Debugging" . "`n"
        helpText .= "  • Toggle ErrorStdOut, NoTrayIcon, Restart" . "`n`n"
        helpText .= "Hotkeys:" . "`n"
        helpText .= "  Ctrl+Alt+D – Toggle GUI" . "`n"
        helpText .= "  F3 – List variables" . "`n"
        helpText .= "  Ctrl+Alt+V – List lines" . "`n"
        helpText .= "  Ctrl+Alt+K – Key history" . "`n"
        helpText .= "  Escape – Hide GUI"
        MsgBox(helpText, "AutoHotkey Debug Helper Help", "Iconi")
    }

    static EnsureLogInfrastructure() {
        if (AHDebugHelper.logInitialized) {
            return
        }
        AHDebugHelper.logDir := A_ScriptDir . "\logs"
        try {
            if (!DirExist(AHDebugHelper.logDir)) {
                DirCreate(AHDebugHelper.logDir)
            }
        } catch as dirError {
            OutputDebug("Failed to create log directory: " . dirError.Message)
        }
        AHDebugHelper.logFilePath := AHDebugHelper.logDir . "\autohotkey_debug_helper.log"
        AHDebugHelper.logInitialized := true
    }

    static AppendLog(message, severity := "INFO") {
        AHDebugHelper.EnsureLogInfrastructure()
        timestamp := FormatTime(A_Now, "yyyy-MM-dd HH:mm:ss")
        entry := "[" . timestamp . "] [" . severity . "] " . message
        AHDebugHelper.debugLog.Push(entry)
        if (AHDebugHelper.debugOutput) {
            currentText := AHDebugHelper.debugOutput.Value
            AHDebugHelper.debugOutput.Value := currentText . entry . "`n"
            AHDebugHelper.debugOutput.Redraw()
            AHDebugHelper.debugOutput.Focus()
            Send("^{End}")
        }
        OutputDebug(entry)
        if (AHDebugHelper.logFilePath) {
            try {
                FileAppend(entry . "`n", AHDebugHelper.logFilePath, "UTF-8")
            } catch as fileError {
                OutputDebug("Failed to append to log file: " . fileError.Message)
            }
        }
    }

    static HandleScriptError(Thrown, Mode) {
        description := "Unhandled exception (" . Mode . "): " . Thrown.Message
        fileName := ""
        if (ObjHasOwnProp(Thrown, "File") && Thrown.File) {
            fileName := Thrown.File
        } else {
            fileName := A_ScriptFullPath
        }
        lineInfo := ObjHasOwnProp(Thrown, "Line") && Thrown.Line ? Thrown.Line : "unknown"
        location := "File: " . fileName . " | Line: " . lineInfo
        AHDebugHelper.AppendLog(description, "ERROR")
        AHDebugHelper.AppendLog(location, "ERROR")
        if (Thrown.Stack) {
            AHDebugHelper.AppendLog("Stack trace:`n" . Thrown.Stack, "TRACE")
        }
        if (AHDebugHelper.mainGui) {
            try {
                AHDebugHelper.mainGui.Hide()
                AHDebugHelper.isVisible := false
            } catch {
                ; ignore GUI hide errors
            }
        }
        return 1
    }

    static ReverseMouseStep(*) {
        x := 0
        y := 0
        MouseGetPos(&x, &y)
        MouseMove(A_ScreenWidth - x, A_ScreenHeight - y, 0)
    }

    static MouseJitterStep(*) {
        x := 0
        y := 0
        MouseGetPos(&x, &y)
        Random(&jitterX, -5, 5)
        Random(&jitterY, -5, 5)
        MouseMove(x + jitterX, y + jitterY, 0)
    }

    static MouseTrailStep(*) {
        x := 0
        y := 0
        MouseGetPos(&x, &y)
        trailGui := Gui("+AlwaysOnTop -Caption +ToolWindow", "")
        trailGui.BackColor := "00ff00"
        trailGui.Show("x" . x . " y" . y . " w4 h4")
        AHDebugHelper.RegisterOneShot(1000, (*) => trailGui.Destroy())
    }

    static RandomClicksStep(*) {
        Random(&x, 0, A_ScreenWidth)
        Random(&y, 0, A_ScreenHeight)
        Click(x, y)
    }

    static FakeTypingStep(*) {
        fakeText := "Hello World! This is fake typing. "
        Send(fakeText)
    }

    static RegisterOneShot(delayMs, callback) {
        SetTimer(callback, -Abs(delayMs))
    }

    static BeginMoveWindow(gui) {
        PostMessage(0xA1, 2, , , gui)
    }

    static ShowTrayTip(title, message) {
        TrayTip(title, message)
    }
}

AHDebugHelper.Init()

OnExit((*) => AHDebugHelper.CloseGUI())

