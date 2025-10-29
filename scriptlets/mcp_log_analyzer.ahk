; ==============================================================================
; MCP Log Analyzer
; @name: MCP Log Analyzer
; @version: 1.0.0
; @description: Analyze Claude Desktop MCP logs for startup issues and errors
; @category: development
; @author: Sandra
; @hotkeys: ^!l, F10
; @enabled: true
; ==============================================================================

#Requires AutoHotkey v2.0+
#SingleInstance Force


; Suppress error popups - log to file instead
OnError(LogError)

LogError(Thrown, Mode) {
    FileAppend("Error: " . Thrown.Message . " at line " . Thrown.Line . "
", "errors.log", "UTF-8")`n        OutputDebug(errorMsg)  ; Enable LLM debugging
    return 1  ; Suppress popup (1 = suppress, 0 = show)
}


class MCPLogAnalyzer {
    static logDir := ""
    static claudeConfig := ""
    static analysisResults := []
    
    static Init() {
        this.logDir := A_AppData . "\Claude\logs\"
        this.claudeConfig := A_AppData . "\Claude\claude_desktop_config.json"
        this.CreateGUI()
    }
    
    static CreateGUI() {
        gui := Gui("+Resize +MinSize800x600", "MCP Log Analyzer")
        gui.BackColor := "1a1a1a"
        gui.SetFont("s10 cFFFFFF", "Segoe UI")
        
        ; Title
        gui.Add("Text", "x20 y20 w760 Center Bold", "📊 MCP Log Analyzer")
        gui.Add("Text", "x20 y50 w760 Center ", "Analyze Claude Desktop MCP logs for startup issues and errors")
        
        ; Configuration section
        gui.Add("Text", "x20 y90 w760 Bold", "⚙️ Configuration")
        gui.Add("Text", "x20 y115 w150", "Log Directory:")
        gui.Add("Text", "x180 y115 w580 ", this.logDir)
        gui.Add("Text", "x20 y140 w150", "Claude Config:")
        gui.Add("Text", "x180 y140 w580 ", this.claudeConfig)
        
        ; Analysis options
        gui.Add("Text", "x20 y180 w760 Bold", "🔍 Analysis Options")
        
        ; Checkboxes for analysis types
        gui.Add("CheckBox", "x20 y210 w200", "Connection Failures").Value := 1
        gui.Add("CheckBox", "x240 y210 w200", "Import Errors").Value := 1
        gui.Add("CheckBox", "x460 y210 w200", "Tool Registration Issues").Value := 1
        gui.Add("CheckBox", "x20 y240 w200", "Config Validation Problems").Value := 1
        gui.Add("CheckBox", "x240 y240 w200", "Performance Issues").Value := 1
        gui.Add("CheckBox", "x460 y240 w200", "Startup Sequence Errors").Value := 1
        
        ; Analysis buttons
        gui.Add("Button", "x20 y280 w200 h50", "🔍 Analyze Latest Logs").OnEvent("Click", this.AnalyzeLatestLogs.Bind(this))
        gui.Add("Button", "x240 y280 w200 h50", "📈 Analyze All Logs").OnEvent("Click", this.AnalyzeAllLogs.Bind(this))
        gui.Add("Button", "x460 y280 w200 h50", "🔧 Generate Fixes").OnEvent("Click", this.GenerateFixes.Bind(this))
        
        ; Results section
        gui.Add("Text", "x20 y350 w760 Bold", "📋 Analysis Results")
        
        ; Results list
        resultsList := gui.Add("ListBox", "x20 y380 w760 h150")
        
        ; Export buttons
        gui.Add("Button", "x20 y540 w150 h40", "💾 Export Report").OnEvent("Click", this.ExportReport.Bind(this))
        gui.Add("Button", "x190 y540 w150 h40", "📋 Copy to Clipboard").OnEvent("Click", this.CopyToClipboard.Bind(this))
        gui.Add("Button", "x360 y540 w150 h40", "❓ Help").OnEvent("Click", this.ShowHelp.Bind(this))
        
        ; Status
        gui.Add("Text", "x20 y590 w760 Center ", "Hotkeys: Ctrl+Alt+L (Analyze) | F10 (Generate Fixes) | Press Analyze to start")
        
        ; Store references for later use
        gui.resultsList := resultsList
        
        ; Set up hotkeys
        this.SetupHotkeys(gui)
        
        gui.Show("w800 h650")
    }
    
    static AnalyzeLatestLogs(*) {
        try {
            if (!DirExist(this.logDir)) {
                MsgBox("Log directory not found: " . this.logDir, "Error", "Iconx")
                return
            }
            
            ; Find latest log files
            logFiles := this.FindLatestLogFiles()
            
            if (logFiles.Length = 0) {
                MsgBox("No MCP log files found in: " . this.logDir, "Warning", "Icon!")
                return
            }
            
            ; Analyze each log file
            this.analysisResults := []
            for logFile in logFiles {
                this.AnalyzeLogFile(logFile)
            }
            
            ; Display results
            this.DisplayResults()
            
        } catch as e {
            MsgBox("Error analyzing logs: " . e.Message, "Error", "Iconx")
        }
    }
    
    static AnalyzeAllLogs(*) {
        try {
            if (!DirExist(this.logDir)) {
                MsgBox("Log directory not found: " . this.logDir, "Error", "Iconx")
                return
            }
            
            ; Find all log files
            logFiles := this.FindAllLogFiles()
            
            if (logFiles.Length = 0) {
                MsgBox("No log files found in: " . this.logDir, "Warning", "Icon!")
                return
            }
            
            ; Analyze each log file
            this.analysisResults := []
            for logFile in logFiles {
                this.AnalyzeLogFile(logFile)
            }
            
            ; Display results
            this.DisplayResults()
            
        } catch as e {
            MsgBox("Error analyzing logs: " . e.Message, "Error", "Iconx")
        }
    }
    
    static FindLatestLogFiles() {
        logFiles := []
        
        try {
            ; Look for MCP-related log files
            Loop Files this.logDir . "*.log" {
                if (InStr(A_LoopFileName, "mcp") || InStr(A_LoopFileName, "server")) {
                    logFiles.Push(A_LoopFileFullPath)
                }
            }
            
            ; Sort by modification time (newest first)
            logFiles := this.SortByModificationTime(logFiles)
            
            ; Return only the 5 most recent
            if (logFiles.Length > 5) {
                logFiles := logFiles.Slice(1, 5)
            }
            
        } catch {
            ; Fallback: look for any .log files
            Loop Files this.logDir . "*.log" {
                logFiles.Push(A_LoopFileFullPath)
            }
        }
        
        return logFiles
    }
    
    static FindAllLogFiles() {
        logFiles := []
        
        try {
            Loop Files this.logDir . "*.log" {
                logFiles.Push(A_LoopFileFullPath)
            }
        } catch {
            ; Handle error
        }
        
        return logFiles
    }
    
    static SortByModificationTime(files) {
        ; Simple bubble sort by modification time
        for i in files {
            for j in files {
                if (j < files.Length && FileGetTime(files[j], "M") < FileGetTime(files[j+1], "M")) {
                    temp := files[j]
                    files[j] := files[j+1]
                    files[j+1] := temp
                }
            }
        }
        return files
    }
    
    static AnalyzeLogFile(logFile) {
        try {
            logContent := FileRead(logFile)
            fileName := RegExReplace(logFile, ".*\\", "")
            
            ; Analyze for different types of issues
            this.AnalyzeConnectionFailures(logContent, fileName)
            this.AnalyzeImportErrors(logContent, fileName)
            this.AnalyzeToolRegistration(logContent, fileName)
            this.AnalyzeConfigValidation(logContent, fileName)
            this.AnalyzePerformance(logContent, fileName)
            this.AnalyzeStartupErrors(logContent, fileName)
            
        } catch as e {
            this.analysisResults.Push({
                type: "Error",
                severity: "High",
                file: RegExReplace(logFile, ".*\\", ""),
                message: "Failed to read log file: " . e.Message,
                suggestion: "Check file permissions and disk space"
            })
        }
    }
    
    static AnalyzeConnectionFailures(content, fileName) {
        patterns := [
            "connection.*failed",
            "unable.*connect",
            "connection.*refused",
            "timeout.*connection",
            "network.*error"
        ]
        
        for pattern in patterns {
            if (RegExMatch(content, "i)" . pattern)) {
                this.analysisResults.Push({
                    type: "Connection Failure",
                    severity: "High",
                    file: fileName,
                    message: "Connection issue detected",
                    suggestion: "Check MCP server is running and accessible"
                })
                break
            }
        }
    }
    
    static AnalyzeImportErrors(content, fileName) {
        patterns := [
            "import.*error",
            "module.*not.*found",
            "import.*failed",
            "no.*module.*named"
        ]
        
        for pattern in patterns {
            if (RegExMatch(content, "i)" . pattern)) {
                this.analysisResults.Push({
                    type: "Import Error",
                    severity: "Medium",
                    file: fileName,
                    message: "Python import issue detected",
                    suggestion: "Check Python dependencies and virtual environment"
                })
                break
            }
        }
    }
    
    static AnalyzeToolRegistration(content, fileName) {
        patterns := [
            "tool.*registration.*failed",
            "unable.*register.*tool",
            "tool.*error",
            "registration.*error"
        ]
        
        for pattern in patterns {
            if (RegExMatch(content, "i)" . pattern)) {
                this.analysisResults.Push({
                    type: "Tool Registration",
                    severity: "Medium",
                    file: fileName,
                    message: "Tool registration issue detected",
                    suggestion: "Check tool definitions and MCP server implementation"
                })
                break
            }
        }
    }
    
    static AnalyzeConfigValidation(content, fileName) {
        patterns := [
            "config.*validation.*failed",
            "invalid.*config",
            "config.*error",
            "json.*parse.*error"
        ]
        
        for pattern in patterns {
            if (RegExMatch(content, "i)" . pattern)) {
                this.analysisResults.Push({
                    type: "Config Validation",
                    severity: "High",
                    file: fileName,
                    message: "Configuration validation issue detected",
                    suggestion: "Check Claude Desktop configuration JSON syntax"
                })
                break
            }
        }
    }
    
    static AnalyzePerformance(content, fileName) {
        patterns := [
            "slow.*response",
            "timeout",
            "performance.*issue",
            "memory.*error"
        ]
        
        for pattern in patterns {
            if (RegExMatch(content, "i)" . pattern)) {
                this.analysisResults.Push({
                    type: "Performance Issue",
                    severity: "Low",
                    file: fileName,
                    message: "Performance issue detected",
                    suggestion: "Consider optimizing MCP server code or increasing resources"
                })
                break
            }
        }
    }
    
    static AnalyzeStartupErrors(content, fileName) {
        patterns := [
            "startup.*failed",
            "initialization.*error",
            "server.*start.*failed",
            "mcp.*server.*error"
        ]
        
        for pattern in patterns {
            if (RegExMatch(content, "i)" . pattern)) {
                this.analysisResults.Push({
                    type: "Startup Error",
                    severity: "High",
                    file: fileName,
                    message: "MCP server startup issue detected",
                    suggestion: "Check server code and dependencies"
                })
                break
            }
        }
    }
    
    static DisplayResults() {
        ; This would update the GUI results list
        ; For now, show a summary
        summary := "📊 Analysis Complete!`n`n"
        summary .= "Total Issues Found: " . this.analysisResults.Length . "`n`n"
        
        ; Count by severity
        highCount := 0
        mediumCount := 0
        lowCount := 0
        
        for result in this.analysisResults {
            switch result.severity {
                case "High": highCount++
                case "Medium": mediumCount++
                case "Low": lowCount++
            }
        }
        
        summary .= "Severity Breakdown:`n"
        summary .= "• High: " . highCount . "`n"
        summary .= "• Medium: " . mediumCount . "`n"
        summary .= "• Low: " . lowCount . "`n`n"
        
        if (this.analysisResults.Length > 0) {
            summary .= "Top Issues:`n"
            for i, result in this.analysisResults {
                if (i > 5) break
                summary .= "• " . result.type . " (" . result.severity . "): " . result.message . "`n"
            }
        } else {
            summary .= "✅ No issues detected! Your MCP setup looks healthy."
        }
        
        MsgBox(summary, "MCP Log Analysis Results", "Iconi")
    }
    
    static GenerateFixes(*) {
        if (this.analysisResults.Length = 0) {
            MsgBox("No analysis results available. Please run analysis first.", "Warning", "Icon!")
            return
        }
        
        fixesText := "🔧 MCP Issue Fixes`n`n"
        
        for result in this.analysisResults {
            fixesText .= "Issue: " . result.type . "`n"
            fixesText .= "Severity: " . result.severity . "`n"
            fixesText .= "File: " . result.file . "`n"
            fixesText .= "Fix: " . result.suggestion . "`n`n"
        }
        
        fixesText .= "General Recommendations:`n"
        fixesText .= "• Ensure all Python dependencies are installed`n"
        fixesText .= "• Check Claude Desktop configuration syntax`n"
        fixesText .= "• Verify MCP server is running and accessible`n"
        fixesText .= "• Review server logs for detailed error messages`n"
        fixesText .= "• Test MCP server independently before Claude integration"
        
        MsgBox(fixesText, "MCP Issue Fixes", "Iconi")
    }
    
    static ExportReport(*) {
        if (this.analysisResults.Length = 0) {
            MsgBox("No analysis results to export. Please run analysis first.", "Warning", "Icon!")
            return
        }
        
        try {
            reportFile := A_Temp . "\mcp_log_analysis_report.txt"
            
            reportContent := "MCP Log Analysis Report`n"
            reportContent .= "Generated: " . FormatTime(A_Now, "yyyy-MM-dd HH:mm:ss") . "`n"
            reportContent .= "Log Directory: " . this.logDir . "`n`n"
            
            for result in this.analysisResults {
                reportContent .= "Type: " . result.type . "`n"
                reportContent .= "Severity: " . result.severity . "`n"
                reportContent .= "File: " . result.file . "`n"
                reportContent .= "Message: " . result.message . "`n"
                reportContent .= "Suggestion: " . result.suggestion . "`n`n"
            }
            
            FileAppend(reportContent, reportFile)
            
            MsgBox("Report exported to: " . reportFile, "Export Complete", "Iconi")
            Run("notepad " . reportFile)
            
        } catch as e {
            MsgBox("Error exporting report: " . e.Message, "Error", "Iconx")
        }
    }
    
    static CopyToClipboard(*) {
        if (this.analysisResults.Length = 0) {
            MsgBox("No analysis results to copy. Please run analysis first.", "Warning", "Icon!")
            return
        }
        
        clipboardText := "MCP Log Analysis Results`n`n"
        
        for result in this.analysisResults {
            clipboardText .= result.type . " (" . result.severity . "): " . result.message . "`n"
            clipboardText .= "Fix: " . result.suggestion . "`n`n"
        }
        
        A_Clipboard := clipboardText
        MsgBox("Analysis results copied to clipboard!", "Copy Complete", "Iconi")
    }
    
    static ShowHelp(*) {
        helpText := "📊 MCP Log Analyzer Help`n`n"
        helpText .= "This tool analyzes Claude Desktop MCP logs to identify:`n`n"
        helpText .= "🔍 Analysis Types:`n"
        helpText .= "• Connection Failures: Network and connectivity issues`n"
        helpText .= "• Import Errors: Python module and dependency problems`n"
        helpText .= "• Tool Registration: MCP tool registration failures`n"
        helpText .= "• Config Validation: Configuration file syntax errors`n"
        helpText .= "• Performance Issues: Slow responses and timeouts`n"
        helpText .= "• Startup Errors: MCP server initialization problems`n`n"
        helpText .= "📋 Features:`n"
        helpText .= "• Analyze Latest Logs: Check most recent log files`n"
        helpText .= "• Analyze All Logs: Comprehensive analysis of all logs`n"
        helpText .= "• Generate Fixes: Get specific fix recommendations`n"
        helpText .= "• Export Report: Save analysis to text file`n"
        helpText .= "• Copy to Clipboard: Copy results for sharing`n`n"
        helpText .= "Hotkeys:`n"
        helpText .= "• Ctrl+Alt+L: Analyze latest logs`n"
        helpText .= "• F10: Generate fixes`n"
        helpText .= "• Escape: Close tool"
        
        MsgBox(helpText, "MCP Log Analyzer Help", "Iconi")
    }
    
    static CloseGUI(*) {
        if (WinExist("MCP Log Analyzer")) {
            WinClose("MCP Log Analyzer")
        }
    }
    
    static SetupHotkeys(gui) {
        Hotkey("^!l", (*) => this.AnalyzeLatestLogs())
        Hotkey("F10", (*) => this.GenerateFixes())
        Hotkey("Escape", (*) => this.CloseGUI())
    }
}

; Hotkeys
Hotkey("^!l", (*) => MCPLogAnalyzer.Init())
Hotkey("F10", (*) => MCPLogAnalyzer.Init())

; Initialize
MCPLogAnalyzer.Init()

