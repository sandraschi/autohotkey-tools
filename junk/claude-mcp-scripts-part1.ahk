#Requires AutoHotkey v2.0+
; Enhanced AutoHotkey v2 Scripts for Claude Desktop MCP Development
; Version 2.0 - Extended and Improved
; Compatible with AutoHotkey v2.0+

; =============================================================================
; CONFIGURATION & GLOBALS
; =============================================================================

; Global configuration
REPOS_DIR := "D:\Dev\repos"
CLAUDE_CONFIG := "C:\Users\sandr\AppData\Roaming\Claude\claude_desktop_config.json"
CLAUDE_LOGS := "C:\Users\sandr\AppData\Roaming\Claude\logs\"
CLAUDE_EXE := "C:\Users\sandr\AppData\Local\AnthropicClaude\app-0.12.129\claude.exe"
PYTHON_EXE := "C:\Users\sandr\AppData\Local\Programs\Python\Python313\python.exe"
TEMP_DIR := "C:\temp\"

; Status tracking
global LastOperation := ""
global OperationTime := ""

; =============================================================================
; UTILITY FUNCTIONS
; =============================================================================

; Operation logging function
LogOperation(operation) {
    global LastOperation, OperationTime
    LastOperation := operation
    OperationTime := A_Now
    
    ; Optional: Write to log file
    try {
        FileAppend(A_Now . " - " . operation . "`n", TEMP_DIR . "ahk_operations.log")
    }
    catch {
        ; Ignore logging errors
    }
}

; Helper function to send message to Claude (if active)
SendClaudeMessage(message) {
    try {
        WinActivate "Claude"
        Sleep 500
        SendText message
        Send "{Enter}"
    }
    catch {
        ; Ignore if Claude not active
    }
}

; Status display function
ShowStatus() {
    global LastOperation, OperationTime
    
    status := "Last Operation: " . LastOperation
    if (OperationTime != "")
        status .= "`nTime: " . OperationTime
    
    TrayTip "MCP Development Status", status, 3
}

; =============================================================================
; CORE MCP DEVELOPMENT SCRIPTS (Enhanced)
; =============================================================================

; 1. Advanced MCP Server Scaffolding (Ctrl+Shift+M)
MCPScaffolding(*) {
    LogOperation("MCP Server Scaffolding")
    
    ; First get project details
    InputBox(&projectName, "New MCP Server", "Enter MCP server name (without -mcp suffix):")
    if (projectName == "")
        return
    
    InputBox(&description, "MCP Server Description", "Brief description of the MCP server:")
    if (description == "")
        description := "A Claude MCP server for " . projectName
    
    ; Generate comprehensive scaffolding prompt
    prompt := "Create new MCP server: " . projectName . "-mcp`n"
    prompt .= "Description: " . description . "`n`n"
    prompt .= "Requirements:`n"
    prompt .= "- Use fastmcp 2.12.1+ (latest stable)`n"
    prompt .= "- Create in: D:\Dev\repos\" . projectName . "-mcp`n"
    prompt .= "- Include comprehensive error handling`n"
    prompt .= "- Implement proper logging with timestamps`n"
    prompt .= "- Add config validation with schemas`n"
    prompt .= "- Create README with installation guide`n"
    prompt .= "- Include pyproject.toml for DXT packaging`n"
    prompt .= "- Add proper type hints throughout`n"
    prompt .= "- Include example usage and troubleshooting`n"
    prompt .= "- Create GitHub Actions workflow`n"
    prompt .= "- Add comprehensive test suite`n`n"
    prompt .= "Generate complete project structure with all files."
    
    SendText prompt
    
    ; Save to basic memory for tracking
    Sleep 2000
    Send "{Enter}"
    Sleep 1000
    SendText "Write to basic memory: Created " . projectName . "-mcp scaffolding at " . A_Now . " [" . projectName . "-mcp, scaffold, created, high]"
}
Hotkey("^+m", MCPScaffolding)

; 2. Enhanced Standards Conformance Checker (Ctrl+Shift+C)
StandardsConformanceCheck(*) {
    LogOperation("Standards Conformance Check")
    
    ; Check for active project
    InputBox(&projectPath, "Project Path", "Enter project path (relative to D:\Dev\repos\):")
    if (projectPath == "")
        projectPath := "current directory"
    
    prompt := "Run comprehensive MCP standards conformance check`n"
    prompt .= "Project: " . projectPath . "`n`n"
    prompt .= "Validation Checklist:`n"
    prompt .= "✅ FastMCP 2.12+ compatibility`n"
    prompt .= "✅ Proper tool registration patterns`n"
    prompt .= "✅ Comprehensive error handling`n"
    prompt .= "✅ Config schema validation`n"
    prompt .= "✅ Structured logging implementation`n"
    prompt .= "✅ Startup sequence validation`n"
    prompt .= "✅ Claude Desktop integration test`n"
    prompt .= "✅ Memory leak prevention`n"
    prompt .= "✅ Resource cleanup on shutdown`n"
    prompt .= "✅ Type safety and hints`n"
    prompt .= "✅ Documentation completeness`n"
    prompt .= "✅ DXT packaging compatibility`n`n"
    prompt .= "Generate detailed compliance report with:`n"
    prompt .= "- Specific issues found`n"
    prompt .= "- Code fixes with examples`n"
    prompt .= "- Performance optimization suggestions`n"
    prompt .= "- Security review results`n"
    prompt .= "- Upgrade path recommendations"
    
    SendText prompt
}
Hotkey("^+c", StandardsConformanceCheck)

; 3. Advanced Log Analyzer with AI Processing (Ctrl+Shift+L)
LogAnalyzer(*) {
    LogOperation("Log Analysis")
    
    ; Check for specific MCP server or analyze all
    InputBox(&mcpServer, "MCP Server", "Enter MCP server name (leave empty for all):")
    
    logPattern := mcpServer != "" ? "mcp-server-" . mcpServer . "-mcp.log" : "mcp-server-*.log"
    
    prompt := "Advanced Claude Desktop MCP log analysis`n"
    prompt .= "Log location: " . CLAUDE_LOGS . "`n"
    prompt .= "Pattern: " . logPattern . "`n`n"
    prompt .= "Analysis Tasks:`n"
    prompt .= "1. Read and parse latest log files`n"
    prompt .= "2. Identify error patterns and frequency`n"
    prompt .= "3. Track connection stability metrics`n"
    prompt .= "4. Detect performance bottlenecks`n"
    prompt .= "5. Find resource usage anomalies`n"
    prompt .= "6. Check tool execution success rates`n`n"
    prompt .= "Error Categories to Analyze:`n"
    prompt .= "🔴 Critical: Connection failures, crashes`n"
    prompt .= "🟡 Warning: Timeouts, retries, deprecations`n"
    prompt .= "🔵 Info: Performance metrics, usage stats`n`n"
    prompt .= "Provide:`n"
    prompt .= "- Root cause analysis`n"
    prompt .= "- Specific fix recommendations`n"
    prompt .= "- Code examples for solutions`n"
    prompt .= "- Prevention strategies`n"
    prompt .= "- Performance optimization tips"
    
    SendText prompt
}
Hotkey("^+l", LogAnalyzer)