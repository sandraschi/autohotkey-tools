; ==============================================================================
; MCP Log Analyzer
; @name: MCP Log Analyzer
; @version: 1.0.0
; @description: Analyze Claude Desktop MCP logs for startup issues and errors. Intelligent log parsing and error detection for MCP server troubleshooting.
; @description: Provides automated log analysis, error pattern detection, startup issue identification, and diagnostic reports. Supports filtering, searching, and exporting analysis results.
; @description: Essential debugging tool for MCP developers to quickly identify log errors, startup failures, and diagnostic issues from Claude Desktop logs.
; @category: development
; @author: Sandra
; @hotkeys: ^!l, F10
; @enabled: true
; @priority: 10
; @tag: mcp, log-analysis, debugging, troubleshooting, development, diagnostics, errors
; @cli: --analyze <log-file> - Analyze specific log file
; @cli: --filter <pattern> - Filter log entries by pattern
; @cli: --export <format> - Export analysis results (json, html, text)
; @cli: --help - Show CLI usage and analyzer options
; @dependencies: 
; ==============================================================================

#Requires AutoHotkey v2.0+
#SingleInstance Force
#Include %A_ScriptDir%\lib\ScriptletErrorHandler.ahk

OnError(LogError)

class MCPLogAnalyzer {
    static gui := ""
    static logDir := A_AppData . "\Claude\logs"
    static configPath := A_AppData . "\Claude\claude_desktop_config.json"
    static logView := ""
    static resultsView := ""
    static statusBar := ""
    static hotkeysRegistered := false
    static logFile := A_ScriptDir . "\mcp_log_analyzer.log"
    static results := []

    static Init() {
        MCPLogAnalyzer.AppendLog("Initializing MCP Log Analyzer")
        if (!MCPLogAnalyzer.gui) {
            MCPLogAnalyzer.CreateGui()
            MCPLogAnalyzer.SetupHotkeys()
        }
        MCPLogAnalyzer.RefreshFileList()
        MCPLogAnalyzer.gui.Show("w920 h780 Center")
        MCPLogAnalyzer.statusBar.SetText("Ready. Press Ctrl+Alt+L to analyze latest logs.")
    }

    static HandleError(Thrown, Mode) {
        scriptName := HasProp(Thrown, "File") ? Thrown.File : A_ScriptFullPath
        lineInfo := HasProp(Thrown, "Line") ? " line " . Thrown.Line : ""
        message := "Error in " . scriptName . lineInfo . ": " . Thrown.Message
        MCPLogAnalyzer.AppendLog(message)
        return 1
    }

    static AppendLog(message) {
        timestamp := FormatTime(A_Now, "yyyy-MM-dd HH:mm:ss")
        entry := "[" . timestamp . "] " . message
        try {
            FileAppend(entry . "`n", MCPLogAnalyzer.logFile, "UTF-8")
        } catch {
        }
        if (MCPLogAnalyzer.logView) {
            MCPLogAnalyzer.logView.Value .= entry . "`n"
            MCPLogAnalyzer.logView.Redraw()
        }
        OutputDebug(entry)
    }

    static CreateGui() {
        newGui := Gui("+Resize +MinSize920x720", "MCP Log Analyzer")
        newGui.BackColor := "1d1d1d"
        newGui.SetFont("s10 cFFFFFF", "Segoe UI")

        newGui.AddText("x20 y20 w880 Center Bold", "📊 MCP Log Analyzer")
        newGui.AddText("x20 y48 w880 Center cC0C0C0", "Scan Claude Desktop MCP logs for startup issues, errors, and performance regressions.")

        newGui.AddText("x20 y88 w880 Bold", "Log Sources")
        newGui.AddText("x20 y116 w120", "Log Directory:")
        newGui.AddEdit("x150 y110 w580 h26 ReadOnly", MCPLogAnalyzer.logDir)
        browseBtn := newGui.AddButton("x740 y110 w160 h26", "Browse...")
        browseBtn.OnEvent("Click", MCPLogAnalyzer.SelectLogDir)

        newGui.AddText("x20 y148 w120", "Config Path:")
        newGui.AddEdit("x150 y142 w580 h26 ReadOnly", MCPLogAnalyzer.configPath)
        cfgBtn := newGui.AddButton("x740 y142 w160 h26", "Open Config")
        cfgBtn.OnEvent("Click", MCPLogAnalyzer.OpenConfig)

        newGui.AddText("x20 y186 w400 Bold", "Detected Log Files")
        filesList := newGui.AddListView("x20 y214 w400 h300 -Hdr", ["Filename", "Modified"])
        filesList.OnEvent("ItemActivate", MCPLogAnalyzer.OnFileActivated)

        newGui.AddText("x440 y186 w460 Bold", "Analysis Settings")
        settings := [
            "Connection failures",
            "Import errors",
            "Tool registration",
            "Config validation",
            "Startup sequence",
            "Performance warnings"
        ]
        y := 214
        for label in settings {
            cb := newGui.AddCheckBox("x440 y" . y . " w240", label)
            cb.Value := 1
            y += 28
        }
        newGui.AddButton("x440 y380 w200 h40", "🔍 Analyze Latest").OnEvent("Click", MCPLogAnalyzer.AnalyzeLatest)
        newGui.AddButton("x660 y380 w200 h40", "📈 Analyze All").OnEvent("Click", MCPLogAnalyzer.AnalyzeAll)
        newGui.AddButton("x440 y430 w420 h36", "🧾 Generate Recommendations").OnEvent("Click", MCPLogAnalyzer.ShowRecommendations)

        newGui.AddText("x20 y530 w880 Bold", "Analysis Results")
        resultsView := newGui.AddListView("x20 y558 w880 h160", ["Severity", "Type", "File", "Message"])
        resultsView.ModifyCol(1, 80)
        resultsView.ModifyCol(2, 150)
        resultsView.ModifyCol(3, 200)
        resultsView.ModifyCol(4, 420)
        MCPLogAnalyzer.resultsView := resultsView

        newGui.AddText("x20 y728 w880 Bold", "Activity Log")
        logEdit := newGui.AddEdit("x20 y756 w880 h100 ReadOnly VScroll", "")
        logEdit.BackColor := "242424"
        logEdit.SetFont("s9", "Consolas")
        MCPLogAnalyzer.logView := logEdit

        status := newGui.AddStatusBar("Simple")
        status.SetText("Ready")
        MCPLogAnalyzer.statusBar := status

        newGui.OnEvent("Close", MCPLogAnalyzer.HideWindow)
        newGui.OnEvent("Escape", MCPLogAnalyzer.HideWindow)
        newGui.OnEvent("Size", MCPLogAnalyzer.OnResize)

        newGui.filesList := filesList
        MCPLogAnalyzer.gui := newGui
    }

    static SetupHotkeys() {
        if (MCPLogAnalyzer.hotkeysRegistered) {
            return
        }
        Hotkey("^!l", MCPLogAnalyzer.AnalyzeLatest)
        Hotkey("^F10", MCPLogAnalyzer.ShowRecommendations)
        Hotkey("F9", MCPLogAnalyzer.HideWindow)
        Hotkey("Escape", (*) => MCPLogAnalyzer.gui && WinActive("ahk_id " MCPLogAnalyzer.gui.Hwnd) && MCPLogAnalyzer.HideWindow())
        MCPLogAnalyzer.hotkeysRegistered := true
    }

    static OnResize(gui, minMax, width, height) {
        padding := 20
        listHeight := height - 340
        gui.filesList.Move(padding, 214, 400, listHeight)
        MCPLogAnalyzer.resultsView.Move(padding, height - 220, width - padding * 2, 160)
        MCPLogAnalyzer.logView.Move(padding, height - 50, width - padding * 2, 80)
    }

    static RefreshFileList() {
        if (!MCPLogAnalyzer.gui) {
            return
        }
        list := MCPLogAnalyzer.gui.filesList
        list.Delete()
        if (!DirExist(MCPLogAnalyzer.logDir)) {
            MCPLogAnalyzer.statusBar.SetText("Log directory not found: " . MCPLogAnalyzer.logDir)
            return
        }
        files := []
        Loop Files MCPLogAnalyzer.logDir . "\*.log" {
            files.Push({path: A_LoopFileFullPath, time: A_LoopFileTimeModified})
        }
        files.Sort((a, b) => a.time > b.time ? -1 : 1)
        for file in files {
            list.Add(, RegExReplace(file.path, ".*\\", ""), file.time)
        }
        if (files.Length = 0) {
            MCPLogAnalyzer.statusBar.SetText("No log files found in " . MCPLogAnalyzer.logDir)
        } else {
            MCPLogAnalyzer.statusBar.SetText(files.Length . " log file(s) available")
        }
    }

    static SelectLogDir(*) {
        dir := DirSelect("Select Claude Desktop log directory", 1, MCPLogAnalyzer.logDir)
        if (dir != "") {
            MCPLogAnalyzer.logDir := dir
            MCPLogAnalyzer.gui.controls[4].Value := dir
            MCPLogAnalyzer.RefreshFileList()
            MCPLogAnalyzer.AppendLog("Log directory set to " . dir)
        }
    }

    static OpenConfig(*) {
        if (FileExist(MCPLogAnalyzer.configPath)) {
            Run('notepad "' . MCPLogAnalyzer.configPath . '"')
        } else {
            MsgBox("Config file not found: " . MCPLogAnalyzer.configPath, "MCP Log Analyzer", "Icon!")
        }
    }

    static OnFileActivated(listView, row) {
        fPath := MCPLogAnalyzer.GetFilePath(row)
        if (fPath != "" && FileExist(fPath)) {
            Run('notepad "' . fPath . '"')
        }
    }

    static GetFilePath(row) {
        if (!row) {
            row := MCPLogAnalyzer.gui.filesList.GetNext()
        }
        if (row = 0) {
            return ""
        }
        fileName := MCPLogAnalyzer.gui.filesList.GetText(row)
        return MCPLogAnalyzer.logDir . "\" . fileName
    }

    static AnalyzeLatest(*) {
        files := MCPLogAnalyzer.GetRecentFiles(5)
        MCPLogAnalyzer.RunAnalysis(files)
    }

    static AnalyzeAll(*) {
        files := MCPLogAnalyzer.GetRecentFiles(0)
        MCPLogAnalyzer.RunAnalysis(files)
    }

    static GetRecentFiles(limit) {
        fileList := []
        if (!DirExist(MCPLogAnalyzer.logDir)) {
            MsgBox("Log directory not found: " . MCPLogAnalyzer.logDir, "MCP Log Analyzer", "Iconx")
            return fileList
        }
        Loop Files MCPLogAnalyzer.logDir . "\*.log" {
            fileList.Push({path: A_LoopFileFullPath, time: A_LoopFileTimeModified})
        }
        fileList.Sort((a, b) => a.time > b.time ? -1 : 1)
        if (limit && fileList.Length > limit) {
            fileList := fileList.Slice(1, limit)
        }
        return fileList
    }

    static RunAnalysis(files) {
        MCPLogAnalyzer.results := []
        MCPLogAnalyzer.resultsView.Delete()
        if (files.Length = 0) {
            MCPLogAnalyzer.statusBar.SetText("No logs available for analysis")
            return
        }
        for item in files {
            MCPLogAnalyzer.AnalyzeFile(item.path)
        }
        for result in MCPLogAnalyzer.results {
            MCPLogAnalyzer.resultsView.Add(, result.severity, result.type, result.file, result.message)
        }
        summary := MCPLogAnalyzer.results.Length ? MCPLogAnalyzer.results.Length . " issue(s) detected" : "No issues detected"
        MCPLogAnalyzer.statusBar.SetText(summary)
        MCPLogAnalyzer.AppendLog("Analysis complete: " . summary)
        TrayTip("MCP Log Analyzer", summary)
    }

    static AnalyzeFile(path) {
        try {
            content := FileRead(path, "UTF-8")
            fileName := RegExReplace(path, ".*\\", "")
            MCPLogAnalyzer.ScanPatterns(fileName, content)
        } catch as e {
            MCPLogAnalyzer.results.Push({
                severity: "High",
                type: "Read Error",
                file: RegExReplace(path, ".*\\", ""),
                message: "Unable to read file: " . e.Message,
                recommendation: "Verify file permissions and availability"
            })
        }
    }

    static ScanPatterns(fileName, content) {
        checks := [
            {severity: "High", type: "Connection", pattern: "connection (failed|refused|timeout)", recommendation: "Confirm MCP server is running and reachable."},
            {severity: "High", type: "Import", pattern: "(ModuleNotFoundError|ImportError)", recommendation: "Install missing Python dependencies."},
            {severity: "Medium", type: "Tool Registration", pattern: "tool registration (failed|error)", recommendation: "Verify tool definitions and decorators."},
            {severity: "High", type: "Config", pattern: "config(uration)? (invalid|error|failed)", recommendation: "Validate Claude Desktop config JSON."},
            {severity: "High", type: "Startup", pattern: "(startup|initialization) (failed|error)", recommendation: "Review server initialization logic."},
            {severity: "Low", type: "Performance", pattern: "(slow response|timeout|high latency)", recommendation: "Profile server performance and optimize."}
        ]
        for check in checks {
            if (RegExMatch(content, "i)" . check.pattern, &match)) {
                contextLine := MCPLogAnalyzer.GetLineContext(content, match.Pos)
                MCPLogAnalyzer.results.Push({
                    severity: check.severity,
                    type: check.type,
                    file: fileName,
                    message: Trim(contextLine),
                    recommendation: check.recommendation
                })
            }
        }
    }

    static GetLineContext(content, pos) {
        start := InStr(content, "`n", false, pos, -1)
        end := InStr(content, "`n", false, pos)
        if (!start) {
            start := 1
        }
        if (!end) {
            end := StrLen(content)
        }
        return SubStr(content, start, end - start)
    }

    static ShowRecommendations(*) {
        if (MCPLogAnalyzer.results.Length = 0) {
            MsgBox("Run an analysis before requesting recommendations.", "MCP Log Analyzer", "Icon!")
            return
        }
        report := "🧾 MCP Log Analyzer Recommendations`n`n"
        seen := Map()
        for result in MCPLogAnalyzer.results {
            key := result.type . result.recommendation
            if (!seen.Has(key)) {
                seen[key] := true
                report .= result.type . " (" . result.severity . ")" . "`n"
                report .= "File: " . result.file . "`n"
                report .= "Finding: " . result.message . "`n"
                report .= "Recommended Action: " . result.recommendation . "`n`n"
            }
        }
        MsgBox(report, "MCP Log Analyzer", "Icon!")
    }

    static HideWindow(*) {
        if !MCPLogAnalyzer.gui
            return
        if !WinActive("ahk_id " MCPLogAnalyzer.gui.Hwnd)
            return
        MCPLogAnalyzer.gui.Hide()
        MCPLogAnalyzer.statusBar.SetText("GUI hidden. Press Ctrl+Alt+L to reopen.")
    }
}

MCPLogAnalyzer.Init()

OnExit((*) => MCPLogAnalyzer.AppendLog("Script exiting."))

