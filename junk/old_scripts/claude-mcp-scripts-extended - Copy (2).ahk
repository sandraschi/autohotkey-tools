#Requires AutoHotkey v2.0+
; Enhanced AutoHotkey v2 Scripts for Claude Desktop MCP Development
; Version 2.0 - Complete Enhanced Edition - SYNTAX FIXED
; Compatible with AutoHotkey v2.0+
; 
; Author: Sandra (sandraschi)
; Date: 2025-09-09
; Purpose: Advanced MCP development automation with AI integration

; =============================================================================
; CONFIGURATION & GLOBALS
; =============================================================================

REPOS_DIR := "D:\Dev\repos"
CLAUDE_CONFIG := "C:\Users\sandr\AppData\Roaming\Claude\claude_desktop_config.json"
CLAUDE_LOGS := "C:\Users\sandr\AppData\Roaming\Claude\logs\"
CLAUDE_EXE := "C:\Users\sandr\AppData\Local\AnthropicClaude\app-0.12.129\claude.exe"
PYTHON_EXE := "C:\Users\sandr\AppData\Local\Programs\Python\Python313\python.exe"
TEMP_DIR := "C:\temp\"

global LastOperation := ""
global OperationTime := ""

; GUI Management Globals
global HelpGui := ""
global WelcomeGui := ""

; =============================================================================
; UTILITY FUNCTIONS
; =============================================================================

LogOperation(operation) {
    global LastOperation, OperationTime
    LastOperation := operation
    OperationTime := A_Now
    try {
        FileAppend A_Now . " - " . operation . "`n", TEMP_DIR . "ahk_operations.log"
    } catch {
        ; Ignore logging errors
    }
}

SendClaudeMessage(message) {
    try {
        WinActivate "Claude"
        Sleep 500
        SendText message
        Send "{Enter}"
    } catch {
        ; Ignore if Claude not active
    }
}

ShowStatus() {
    global LastOperation, OperationTime
    status := "Last Operation: " . LastOperation
    if (OperationTime != "")
        status .= "`nTime: " . OperationTime
    TrayTip "MCP Development Status", status, 3
}

ShowStartupNotification() {
    TrayTip "MCP Development Scripts", "AutoHotkey MCP Scripts loaded! Press Ctrl+Shift+H for help", 3
}

; Enhanced Multi-Column Help System
ShowEnhancedHelp() {
    global HelpGui, LastOperation, OperationTime
    
    ; Close existing help window if open
    if (HelpGui != "" && IsSet(HelpGui) && HelpGui.Hwnd)
        HelpGui.Close()
    
    ; Create new help GUI
    HelpGui := Gui("+Resize +MinSize400x300", "MCP Development Scripts - Help Reference")
    HelpGui.BackColor := "White"
    HelpGui.MarginX := 15
    HelpGui.MarginY := 15
    
    ; Title
    HelpGui.Add("Text", "x15 y15 w560 Center", "AutoHotkey MCP Development Scripts - Complete Reference")
    HelpGui.Add("Text", "x15 y35 w560 Center c0x666666", "Version 2.1 Enhanced - Press any hotkey or ESC to close")
    
    ; Main content area with 3 columns
    yPos := 65
    colWidth := 180
    
    ; Column 1: Core Development
    HelpGui.Add("Text", "x15 y" . yPos . " w" . colWidth . " c0x0066CC +Bold", "CORE DEVELOPMENT")
    yPos += 25
    HelpGui.Add("Text", "x15 y" . yPos . " w" . colWidth, "Ctrl+Shift+M")
    HelpGui.Add("Text", "x15 y" . (yPos + 15) . " w" . colWidth . " c0x666666", "MCP Server Scaffolding")
    yPos += 40
    HelpGui.Add("Text", "x15 y" . yPos . " w" . colWidth, "Ctrl+Shift+C")
    HelpGui.Add("Text", "x15 y" . (yPos + 15) . " w" . colWidth . " c0x666666", "Standards Conformance Check")
    yPos += 40
    HelpGui.Add("Text", "x15 y" . yPos . " w" . colWidth, "Ctrl+Shift+L")
    HelpGui.Add("Text", "x15 y" . (yPos + 15) . " w" . colWidth . " c0x666666", "Advanced Log Analysis")
    
    ; Column 2: Advanced Workflows
    yPos := 90
    colX := 210
    HelpGui.Add("Text", "x" . colX . " y" . yPos . " w" . colWidth . " c0x009900 +Bold", "ADVANCED WORKFLOWS")
    yPos += 25
    HelpGui.Add("Text", "x" . colX . " y" . yPos . " w" . colWidth, "Ctrl+Shift+T")
    HelpGui.Add("Text", "x" . colX . " y" . (yPos + 15) . " w" . colWidth . " c0x666666", "AI Smart Troubleshooter")
    yPos += 40
    HelpGui.Add("Text", "x" . colX . " y" . yPos . " w" . colWidth, "Ctrl+Shift+D")
    HelpGui.Add("Text", "x" . colX . " y" . (yPos + 15) . " w" . colWidth . " c0x666666", "Development Lifecycle")
    yPos += 40
    HelpGui.Add("Text", "x" . colX . " y" . yPos . " w" . colWidth, "Ctrl+Shift+W")
    HelpGui.Add("Text", "x" . colX . " y" . (yPos + 15) . " w" . colWidth . " c0x666666", "File Monitoring System")
    yPos += 40
    HelpGui.Add("Text", "x" . colX . " y" . yPos . " w" . colWidth, "Ctrl+Shift+P")
    HelpGui.Add("Text", "x" . colX . " y" . (yPos + 15) . " w" . colWidth . " c0x666666", "DXT Package Validation")
    
    ; Column 3: System Management
    yPos := 90
    colX := 405
    HelpGui.Add("Text", "x" . colX . " y" . yPos . " w" . colWidth . " c0xCC6600 +Bold", "SYSTEM MANAGEMENT")
    yPos += 25
    HelpGui.Add("Text", "x" . colX . " y" . yPos . " w" . colWidth, "Ctrl+Alt+R")
    HelpGui.Add("Text", "x" . colX . " y" . (yPos + 15) . " w" . colWidth . " c0x666666", "Intelligent Restart")
    yPos += 40
    HelpGui.Add("Text", "x" . colX . " y" . yPos . " w" . colWidth, "Ctrl+Alt+X")
    HelpGui.Add("Text", "x" . colX . " y" . (yPos + 15) . " w" . colWidth . " c0x666666", "Emergency Restart")
    yPos += 40
    HelpGui.Add("Text", "x" . colX . " y" . yPos . " w" . colWidth, "Ctrl+Shift+R")
    HelpGui.Add("Text", "x" . colX . " y" . (yPos + 15) . " w" . colWidth . " c0x666666", "Hot Config Reload")
    
    ; Separator line
    HelpGui.Add("Text", "x15 y275 w560 0x10")
    
    ; Second row of categories
    yPos := 290
    
    ; Creative & Productivity
    HelpGui.Add("Text", "x15 y" . yPos . " w" . colWidth . " c0x9900CC +Bold", "CREATIVE & PRODUCTIVITY")
    yPos += 25
    HelpGui.Add("Text", "x15 y" . yPos . " w" . colWidth, "Ctrl+Shift+I")
    HelpGui.Add("Text", "x15 y" . (yPos + 15) . " w" . colWidth . " c0x666666", "AI MCP Idea Generator")
    yPos += 40
    HelpGui.Add("Text", "x15 y" . yPos . " w" . colWidth, "Ctrl+Shift+G")
    HelpGui.Add("Text", "x15 y" . (yPos + 15) . " w" . colWidth . " c0x666666", "Documentation Generator")
    yPos += 40
    HelpGui.Add("Text", "x15 y" . yPos . " w" . colWidth, "Ctrl+Shift+O")
    HelpGui.Add("Text", "x15 y" . (yPos + 15) . " w" . colWidth . " c0x666666", "Multi-MCP Orchestrator")
    
    ; Help & Status
    yPos := 315
    colX := 210
    HelpGui.Add("Text", "x" . colX . " y" . yPos . " w" . colWidth . " c0x666666 +Bold", "HELP & STATUS")
    yPos += 25
    HelpGui.Add("Text", "x" . colX . " y" . yPos . " w" . colWidth, "Ctrl+Shift+H")
    HelpGui.Add("Text", "x" . colX . " y" . (yPos + 15) . " w" . colWidth . " c0x666666", "Show This Help")
    yPos += 40
    HelpGui.Add("Text", "x" . colX . " y" . yPos . " w" . colWidth, "Ctrl+Shift+S")
    HelpGui.Add("Text", "x" . colX . " y" . (yPos + 15) . " w" . colWidth . " c0x666666", "Show Status")
    yPos += 40
    HelpGui.Add("Text", "x" . colX . " y" . yPos . " w" . colWidth, "Ctrl+F1")
    HelpGui.Add("Text", "x" . colX . " y" . (yPos + 15) . " w" . colWidth . " c0x666666", "Welcome Screen")
    
    ; Operation History Box
    yPos := 315
    colX := 405
    HelpGui.Add("Text", "x" . colX . " y" . yPos . " w" . colWidth . " c0x000000 +Bold", "OPERATION STATUS")
    yPos += 25
    statusText := "Last: " . (LastOperation != "" ? LastOperation : "None")
    if (OperationTime != "")
        statusText .= "`nTime: " . FormatTime(OperationTime, "HH:mm:ss")
    HelpGui.Add("Text", "x" . colX . " y" . yPos . " w" . colWidth . " c0x666666", statusText)
    
    ; Footer
    HelpGui.Add("Text", "x15 y450 w560 0x10")
    HelpGui.Add("Text", "x15 y465 w560 Center c0x666666", "FastMCP 2.12+ * Austrian Development Context * Press ESC or any hotkey to close")
    
    ; Event handlers
    HelpGui.OnEvent("Close", (*) => HelpGui := "")
    HelpGui.OnEvent("Escape", (*) => HelpGui.Close())
    
    ; Show the GUI
    HelpGui.Show("w600 h500")
}

; Elaborate Welcome Screen System
ShowElaborateWelcome() {
    global WelcomeGui
    
    ; Log the welcome screen access
    LogOperation("Welcome Screen Opened")
    
    ; Close existing welcome window if open
    if (WelcomeGui != "" && IsSet(WelcomeGui) && WelcomeGui.Hwnd)
        WelcomeGui.Close()
    
    ; Create main welcome GUI with tabs
    WelcomeGui := Gui("+Resize +MinSize600x400", "MCP Development Scripts - Welcome Center")
    WelcomeGui.BackColor := "White"
    WelcomeGui.MarginX := 15
    WelcomeGui.MarginY := 15
    
    ; Main title
    WelcomeGui.Add("Text", "x15 y15 w700 Center +Bold", "AutoHotkey MCP Development Scripts v2.1")
    WelcomeGui.Add("Text", "x15 y40 w700 Center c0x666666", "Advanced Claude Desktop MCP Development Automation")
    
    ; Create tab control
    tabControl := WelcomeGui.Add("Tab3", "x15 y70 w700 h420", ["Welcome", "MCP Dev", "System Mgmt", "Creative", "Settings"])
    
    ; TAB 1: WELCOME
    tabControl.UseTab(1)
    
    ; Welcome content
    WelcomeGui.Add("Text", "x35 y105 w660 +Bold c0x0066CC", "Welcome to Professional MCP Development Automation!")
    
    welcomeText := "This AutoHotkey script transforms Claude Desktop MCP development from manual tedium into orchestrated efficiency. "
    welcomeText .= "You now have access to 12+ sophisticated workflows that automate everything from project scaffolding to "
    welcomeText .= "AI-powered troubleshooting.`n`n"
    welcomeText .= "Perfect for Austrian developers working with:"
    WelcomeGui.Add("Text", "x35 y130 w660 +Wrap", welcomeText)
    
    ; Current environment display
    WelcomeGui.Add("Text", "x35 y200 w660 +Bold c0x009900", "Your Development Environment:")
    envText := "Repos: " . REPOS_DIR . "`n"
    envText .= "Claude Config: " . CLAUDE_CONFIG . "`n"
    envText .= "Log Directory: " . CLAUDE_LOGS . "`n"
    envText .= "Python: " . PYTHON_EXE
    WelcomeGui.Add("Text", "x35 y225 w660 +Wrap c0x666666", envText)
    
    ; Quick start section
    WelcomeGui.Add("Text", "x35 y320 w660 +Bold c0xCC6600", "Quick Start - Try These First:")
    quickStart := "1. Press Ctrl+Shift+H for the enhanced help system (multi-column, color-coded)`n"
    quickStart .= "2. Press Ctrl+Shift+M to scaffold a new MCP server with FastMCP 2.12+`n"
    quickStart .= "3. Press Ctrl+Shift+T for AI-powered troubleshooting of existing MCPs`n"
    quickStart .= "4. Press Ctrl+Alt+R for intelligent Claude Desktop restart (superior to GUI automation)"
    WelcomeGui.Add("Text", "x35 y345 w660 +Wrap", quickStart)
    
    ; TAB 2: MCP DEVELOPMENT
    tabControl.UseTab(2)
    
    WelcomeGui.Add("Text", "x35 y105 w660 +Bold c0x0066CC", "MCP Development Workflows - FastMCP 2.12+ Focus")
    
    ; Core workflows section
    WelcomeGui.Add("Text", "x35 y135 w660 +Bold", "Core Development Workflows:")
    mcpText := "• Ctrl+Shift+M - MCP Server Scaffolding: Generates complete project structure with FastMCP 2.12+, "
    mcpText .= "error handling, logging, type hints, documentation, and DXT packaging compatibility.`n`n"
    mcpText .= "• Ctrl+Shift+C - Standards Conformance: Automated quality assurance checklist including "
    mcpText .= "compatibility checks, security scans, and deployment validation.`n`n"
    mcpText .= "• Ctrl+Shift+L - Advanced Log Analysis: AI-powered troubleshooting that identifies error patterns, "
    mcpText .= "performance bottlenecks, and provides root cause analysis."
    WelcomeGui.Add("Text", "x35 y155 w660 +Wrap", mcpText)
    
    ; Advanced workflows
    WelcomeGui.Add("Text", "x35 y280 w660 +Bold c0x009900", "AI-Powered Advanced Features:")
    advancedText := "• Ctrl+Shift+T - Smart Troubleshooter: Progressive diagnostic approach with comprehensive reporting`n"
    advancedText .= "• Ctrl+Shift+D - Development Lifecycle: Complete pipeline from code quality to distribution`n"
    advancedText .= "• Ctrl+Shift+P - DXT Package Validation: Full packaging pipeline with security scanning"
    WelcomeGui.Add("Text", "x35 y300 w660 +Wrap", advancedText)
    
    ; Success metrics
    WelcomeGui.Add("Text", "x35 y380 w660 +Bold c0x9900CC", "Success Metrics: 2-3 hours to 30 seconds for MCP scaffolding!")
    
    ; TAB 3: SYSTEM MANAGEMENT
    tabControl.UseTab(3)
    
    WelcomeGui.Add("Text", "x35 y105 w660 +Bold c0xCC6600", "⚙️ System Management - The TaskKill Innovation")
    
    ; TaskKill explanation
    WelcomeGui.Add("Text", "x35 y135 w660 +Bold", "Why TaskKill is Superior for Claude Desktop:")
    taskKillText := "Claude Desktop has an unusual hamburger menu (top-left edge → hamburger → down×3 → enter) "
    taskKillText .= "instead of standard Alt+F4 responsive File menu. This makes GUI automation unreliable.`n`n"
    taskKillText .= "TaskKill advantages:`n"
    taskKillText .= "• No data loss risk (Claude Desktop doesn't have unsaved documents)`n"
    taskKillText .= "• 100% reliability vs fragile GUI automation race conditions`n"
    taskKillText .= "• Faster recovery (500ms vs 4-5 second GUI navigation)`n"
    taskKillText .= "• Complete process cleanup (kills orphaned Python MCP servers)`n"
    taskKillText .= "• Clean slate restart with proper resource management"
    WelcomeGui.Add("Text", "x35 y155 w660 +Wrap", taskKillText)
    
    ; Restart options
    WelcomeGui.Add("Text", "x35 y320 w660 +Bold c0x009900", "Restart Options Available:")
    restartText := "• Ctrl+Alt+R - Intelligent Restart: Tries graceful close, falls back to TaskKill`n"
    restartText .= "• Ctrl+Alt+X - Emergency Restart: Force kills Claude + Python processes, cleans temp files`n"
    restartText .= "• Ctrl+Shift+R - Hot Config Reload: Validates config, then triggers restart sequence"
    WelcomeGui.Add("Text", "x35 y340 w660 +Wrap", restartText)
    
    ; TAB 4: CREATIVE & PRODUCTIVITY
    tabControl.UseTab(4)
    
    WelcomeGui.Add("Text", "x35 y105 w660 +Bold c0x9900CC", "💡 AI-Powered Creative Features")
    
    ; AI integration features
    WelcomeGui.Add("Text", "x35 y135 w660 +Bold", "Innovation & Documentation Tools:")
    creativeText := "• Ctrl+Shift+I - AI MCP Idea Generator: Context-aware innovation engine that considers your "
    creativeText .= "Austrian/Vienna location, current projects (Ednaficator, local-llm-mcp, fastsearch, virtualbox), "
    creativeText .= "and technical preferences.`n`n"
    creativeText .= "• Ctrl+Shift+G - Documentation Generator: Creates comprehensive documentation suites including "
    creativeText .= "README, API docs, user guides, and troubleshooting sections.`n`n"
    creativeText .= "• Ctrl+Shift+O - Multi-MCP Orchestrator: Enterprise-level system management across all your "
    creativeText .= "MCP servers with health monitoring and optimization."
    WelcomeGui.Add("Text", "x35 y155 w660 +Wrap", creativeText)
    
    ; Austrian context
    WelcomeGui.Add("Text", "x35 y300 w660 +Bold c0x0066CC", "🇦🇹 Austrian Development Context Integration:")
    austrianText := "• Vienna-specific service integrations (ÖBB, city data, local APIs)`n"
    austrianText .= "• German language considerations in documentation`n"
    austrianText .= "• Budget-conscious development approaches (~€100/month AI tools)`n"
    austrianText .= "• Efficiency-focused workflows matching Austrian engineering culture"
    WelcomeGui.Add("Text", "x35 y320 w660 +Wrap", austrianText)
    
    ; TAB 5: SETTINGS
    tabControl.UseTab(5)
    
    WelcomeGui.Add("Text", "x35 y105 w660 +Bold c0x666666", "Configuration & Settings")
    
    ; Current paths display
    WelcomeGui.Add("Text", "x35 y135 w660 +Bold", "Current Configuration Paths:")
    pathsText := "Repositories: " . REPOS_DIR . "`n"
    pathsText .= "Claude Config: " . CLAUDE_CONFIG . "`n"
    pathsText .= "Log Directory: " . CLAUDE_LOGS . "`n"
    pathsText .= "Claude Executable: " . CLAUDE_EXE . "`n"
    pathsText .= "Python: " . PYTHON_EXE . "`n"
    pathsText .= "Temp Directory: " . TEMP_DIR
    WelcomeGui.Add("Text", "x35 y155 w660 +Wrap c0x666666", pathsText)
    
    ; Operation logging info
    WelcomeGui.Add("Text", "x35 y280 w660 +Bold c0x009900", "Operation Tracking & Logging:")
    loggingText := "All operations are logged to: " . TEMP_DIR . "ahk_operations.log`n`n"
    loggingText .= "Status tracking includes:`n"
    loggingText .= "• Last operation performed and timestamp`n"
    loggingText .= "• Success/failure status for each workflow`n"
    loggingText .= "• Performance metrics and timing data`n"
    loggingText .= "• Error details for troubleshooting"
    WelcomeGui.Add("Text", "x35 y300 w660 +Wrap", loggingText)
    
    ; Customization note
    WelcomeGui.Add("Text", "x35 y420 w660 +Bold c0xCC6600", "Note: Configuration externalization coming in Phase 3!")
    
    ; Footer and controls
    tabControl.UseTab()
    WelcomeGui.Add("Text", "x15 y500 w700 0x10")
    WelcomeGui.Add("Text", "x15 y515 w500 c0x666666", "Press Ctrl+F1 anytime to show this welcome screen again")
    
    ; Enhanced close button with keyboard shortcut indicator
    closeBtn := WelcomeGui.Add("Button", "x580 y510 w120 h25", "Close (ESC)")
    closeBtn.OnEvent("Click", (*) => WelcomeGui.Close())
    
    ; Quick action buttons
    helpBtn := WelcomeGui.Add("Button", "x450 y510 w120 h25", "Help (Ctrl+Shift+H)")
    helpBtn.OnEvent("Click", (*) => ShowEnhancedHelp())
    
    ; Event handlers
    WelcomeGui.OnEvent("Close", (*) => WelcomeGui := "")
    WelcomeGui.OnEvent("Escape", (*) => WelcomeGui.Close())
    
    ; Show the welcome screen
    WelcomeGui.Show("w730 h550")
}

; =============================================================================
; CORE MCP DEVELOPMENT SCRIPTS
; =============================================================================

; Advanced MCP Server Scaffolding (Ctrl+Shift+M)
^+m::
{
    LogOperation("MCP Server Scaffolding")
    projectName := InputBox("New MCP Server", "Enter MCP server name (without -mcp suffix):", "w350 h130").value
    if (projectName == "") 
        return
    
    description := InputBox("MCP Server Description", "Brief description:", "w400 h130").value
    if (description == "") 
        description := "A Claude MCP server for " . projectName
    
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
    Sleep 2000
    Send "{Enter}"
    Sleep 1000
    SendText "Write to basic memory: Created " . projectName . "-mcp scaffolding at " . A_Now . " [" . projectName . "-mcp, scaffold, created, high]"
}

; Standards Conformance Checker (Ctrl+Shift+C)
^+c::
{
    LogOperation("Standards Conformance Check")
    projectPath := InputBox("Project Path", "Enter project path (relative to D:\Dev\repos\):", "w400 h130").value
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
    prompt .= "Generate detailed compliance report with specific fixes and optimizations."
    
    SendText prompt
}

; Advanced Log Analyzer (Ctrl+Shift+L)
^+l::
{
    LogOperation("Log Analysis")
    mcpServer := InputBox("MCP Server", "Enter MCP server name (leave empty for all):", "w350 h130").value
    
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
    prompt .= "Error Categories:`n"
    prompt .= "🔴 Critical: Connection failures, crashes`n"
    prompt .= "🟡 Warning: Timeouts, retries, deprecations`n"
    prompt .= "🔵 Info: Performance metrics, usage stats`n`n"
    prompt .= "Provide root cause analysis and specific fix recommendations."
    
    SendText prompt
}

; =============================================================================
; ADVANCED WORKFLOW SCRIPTS
; =============================================================================

; AI Smart Troubleshooter (Ctrl+Shift+T)
^+t::
{
    LogOperation("Smart Troubleshooting")
    
    SendText "AI-Powered MCP Troubleshooting Sequence`n"
    SendText "=====================================`n`n"
    SendText "Phase 1: System State Analysis - Checking MCP server statuses`n"
    Sleep 1500
    Send "{Enter}"
    Sleep 2000
    SendText "Phase 2: Configuration Validation - Analyzing Claude Desktop config`n"
    Sleep 1500
    Send "{Enter}"
    Sleep 2000
    SendText "Phase 3: Log Pattern Analysis - Processing recent error patterns`n"
    Sleep 1500
    Send "{Enter}"
    Sleep 2000
    SendText "`nGenerate comprehensive diagnostic report with:`n"
    SendText "- Priority-ranked issues`n"
    SendText "- Step-by-step fix instructions`n"
    SendText "- Code patches where needed`n"
    SendText "- Preventive measures`n"
    SendText "- Monitoring recommendations"
}

; Enhanced Development Cycle (Ctrl+Shift+D)
^+d::
{
    LogOperation("Development Cycle")
    
    prompt := "Enhanced MCP Development Lifecycle`n"
    prompt .= "======================================`n`n"
    prompt .= "Phase 1: Code Quality Analysis`n"
    prompt .= "- Static analysis with ruff and mypy`n"
    prompt .= "- Security scan with bandit`n"
    prompt .= "- FastMCP 2.12+ compatibility check`n"
    prompt .= "- Performance profiling`n`n"
    prompt .= "Phase 2: Automated Testing`n"
    prompt .= "- Unit test execution with pytest`n"
    prompt .= "- Integration testing with Claude Desktop`n"
    prompt .= "- Error handling validation`n"
    prompt .= "- Load testing for tool performance`n`n"
    prompt .= "Phase 3: Documentation Generation`n"
    prompt .= "- Auto-generate API docs from docstrings`n"
    prompt .= "- Update README with latest features`n"
    prompt .= "- Create troubleshooting guides`n`n"
    prompt .= "Phase 4: Packaging & Distribution`n"
    prompt .= "- DXT package validation`n"
    prompt .= "- Version bump and changelog`n"
    prompt .= "- GitHub release creation`n`n"
    prompt .= "Execute full pipeline and report results."
    
    SendText prompt
}

; =============================================================================
; SYSTEM MANAGEMENT
; =============================================================================

; Intelligent Claude Desktop Restart (Ctrl+Alt+R)
^!r::
{
    LogOperation("Claude Desktop Restart")
    TrayTip "Restarting Claude Desktop", "Gracefully closing and restarting...", 2
    
    try {
        WinActivate "Claude"
        Sleep 500
        Send "!{F4}"
        Sleep 3000
        WinWaitClose "Claude",, 10
    } catch {
        Run "taskkill /f /im Claude.exe",, "Hide"
        Sleep 2000
    }
    
    try {
        FileDelete TEMP_DIR . "claude_restart.lock"
    } catch {
    }
    
    Run CLAUDE_EXE
    Sleep 3000
    TrayTip "Claude Desktop Restarted", "Ready for MCP development!", 2
    SendClaudeMessage("Claude Desktop restarted at " . A_Now . " - MCP servers should reconnect automatically")
}

; Emergency Restart (Ctrl+Alt+X)
^!x::
{
    LogOperation("Emergency Restart")
    TrayTip "Emergency Restart", "Force killing and restarting...", 2
    
    Run "taskkill /f /im Claude.exe /t",, "Hide"
    Run "taskkill /f /im python.exe /f",, "Hide"
    
    Sleep 3000
    
    try {
        FileDelete TEMP_DIR . "claude_*.lock"
        FileDelete TEMP_DIR . "mcp_*.tmp"
    } catch {
    }
    
    Run CLAUDE_EXE
    TrayTip "Emergency Restart Complete", "Claude Desktop restarted fresh!", 3
}

; Hot Config Reload (Ctrl+Shift+R)
^+r::
{
    LogOperation("Config Hot Reload")
    
    prompt := "🔄 Claude Desktop Config Hot Reload`n"
    prompt .= "================================`n`n"
    prompt .= "Operations:`n"
    prompt .= "1. Backup current config: " . CLAUDE_CONFIG . "`n"
    prompt .= "2. Validate JSON syntax and MCP server configs`n"
    prompt .= "3. Check Python executable paths`n"
    prompt .= "4. Verify MCP server availability`n"
    prompt .= "5. Test configuration compatibility`n"
    prompt .= "6. Apply changes and restart Claude Desktop`n`n"
    prompt .= "Safety features:`n"
    prompt .= "- Config rollback on failure`n"
    prompt .= "- Syntax validation before apply`n"
    prompt .= "- MCP server health checks`n`n"
    prompt .= "Proceed with hot reload sequence?"
    
    SendText prompt
    Sleep 5000
    SendText "`n`nConfig validated - triggering restart...`n"
    Sleep 2000
    Send "^!r"
}

; =============================================================================
; FILE & PROJECT MONITORING
; =============================================================================

; Advanced File Watcher (Ctrl+Shift+W)
^+w::
{
    LogOperation("File Watcher Setup")
    
    prompt := "🔍 Advanced MCP File Monitoring System`n"
    prompt .= "=====================================`n`n"
    prompt .= "Monitoring Targets:`n"
    prompt .= "MCP Projects: " . REPOS_DIR . "\\*-mcp\\`n"
    prompt .= "⚙️  Claude Config: " . CLAUDE_CONFIG . "`n"
    prompt .= "📋 Log Directory: " . CLAUDE_LOGS . "`n"
    prompt .= "🐍 Python Environment: " . PYTHON_EXE . "`n`n"
    prompt .= "Smart Triggers:`n"
    prompt .= "• Code Changes → Auto-validation & testing`n"
    prompt .= "• Config Changes → Syntax check & restart prompt`n"
    prompt .= "• New Errors → AI troubleshooting activation`n"
    prompt .= "• Performance Issues → Resource analysis`n`n"
    prompt .= "AI Features:`n"
    prompt .= "- Pattern recognition for common issues`n"
    prompt .= "- Predictive problem detection`n"
    prompt .= "- Auto-fix suggestions for simple issues`n"
    prompt .= "- Performance optimization recommendations`n`n"
    prompt .= "Start comprehensive monitoring with AI analysis?"
    
    SendText prompt
}

; Enhanced DXT Package Management (Ctrl+Shift+P)
^+p::
{
    LogOperation("DXT Package Validation")
    
    projectDir := InputBox("Project Directory", "Enter project directory name:", "w350 h130").value
    if (projectDir == "") 
        projectDir := "[current project]"
    
    prompt := "📦 Enhanced DXT Package Management`n"
    prompt .= "================================`n"
    prompt .= "Project: " . projectDir . "`n`n"
    prompt .= "Validation Pipeline:`n"
    prompt .= "1. 🔍 Run 'dxt validate' with detailed reporting`n"
    prompt .= "2. 📋 Analyze package.json structure and metadata`n"
    prompt .= "3. 🔗 Verify all dependencies and versions`n"
    prompt .= "4. 🧪 Test installation in clean environment`n"
    prompt .= "5. Validate tool exports and functionality`n"
    prompt .= "6. 📖 Check documentation completeness`n"
    prompt .= "7. 🔒 Security scan for vulnerabilities`n"
    prompt .= "8. 📊 Performance benchmarking`n`n"
    prompt .= "Execute complete packaging pipeline?"
    
    SendText prompt
}

; =============================================================================
; CREATIVE & PRODUCTIVITY TOOLS
; =============================================================================

; AI MCP Idea Generator (Ctrl+Shift+I)
^+i::
{
    LogOperation("MCP Idea Generation")
    
    context := InputBox("Development Context", "Enter current focus area (optional):", "w400 h130").value
    if (context == "") 
        context := "general MCP development"
    
    prompt := "💡 AI-Powered MCP Server Innovation Engine`n"
    prompt .= "========================================`n`n"
    prompt .= "Context: " . context . "`n`n"
    prompt .= "Analysis Framework:`n"
    prompt .= "Current Projects: Ednaficator, local-llm-mcp, fastsearch MCP, virtualbox MCP`n"
    prompt .= "🌍 Austrian/Vienna Context: Local services, ÖBB, city data, German language`n"
    prompt .= "Tech Stack: FastMCP 2.12+, Python 3.13, Claude Desktop, DXT packaging`n"
    prompt .= "👤 User Profile: Advanced dev, weeb, academic, budget-conscious, efficiency-focused`n`n"
    prompt .= "Generate 5 innovative MCP server concepts with:`n"
    prompt .= "- Unique value proposition`n"
    prompt .= "- Technical architecture overview`n"
    prompt .= "- Implementation complexity (1-10)`n"
    prompt .= "- Expected development time`n"
    prompt .= "- Integration opportunities`n"
    prompt .= "- Risk assessment`n`n"
    prompt .= "Prioritize by: Impact × Feasibility ÷ Time Investment"
    
    SendText prompt
}

; Documentation Generator (Ctrl+Shift+G)
^+g::
{
    LogOperation("Documentation Generation")
    
    docType := InputBox("Documentation Type", "Enter doc type (api|user|dev|troubleshooting|all):", "w400 h130").value
    if (docType == "") 
        docType := "all"
    
    prompt := "📚 AI Documentation Generation Suite`n"
    prompt .= "==================================`n`n"
    prompt .= "Documentation Type: " . docType . "`n`n"
    prompt .= "Generation Pipeline:`n`n"
    prompt .= "📖 README.md (Enhanced)`n"
    prompt .= "- Project overview with compelling description`n"
    prompt .= "- Feature highlights with examples`n"
    prompt .= "- Installation guide (multiple methods)`n"
    prompt .= "- Quick start tutorial`n"
    prompt .= "- Configuration examples`n"
    prompt .= "- Troubleshooting FAQ`n`n"
    prompt .= "API Documentation`n"
    prompt .= "- Auto-generated from docstrings`n"
    prompt .= "- Interactive examples`n"
    prompt .= "- Error codes and handling`n"
    prompt .= "- Type definitions`n`n"
    prompt .= "👥 User Guide`n"
    prompt .= "- Step-by-step tutorials`n"
    prompt .= "- Use case scenarios`n"
    prompt .= "- Best practices`n"
    prompt .= "- Performance tips`n`n"
    prompt .= "🛠️ Developer Documentation`n"
    prompt .= "- Architecture overview`n"
    prompt .= "- Extension guidelines`n"
    prompt .= "- Testing procedures`n"
    prompt .= "- Contribution guide`n`n"
    prompt .= "Troubleshooting Guide`n"
    prompt .= "- Common issues and solutions`n"
    prompt .= "- Log analysis instructions`n"
    prompt .= "- Performance debugging`n"
    prompt .= "- Recovery procedures`n`n"
    prompt .= "Generate comprehensive documentation suite with Austrian/Vienna context where relevant."
    
    SendText prompt
}

; Multi-MCP Orchestrator (Ctrl+Shift+O)
^+o::
{
    LogOperation("Multi-MCP Orchestration")
    
    prompt := "🎭 Multi-MCP Server Orchestration Center`n"
    prompt .= "======================================`n`n"
    prompt .= "Current MCP Ecosystem Analysis:`n"
    prompt .= "- Ednaficator (AI concierge)`n"
    prompt .= "- local-llm-mcp (local LLM integration)`n"
    prompt .= "- fastsearch-mcp (advanced search)`n"
    prompt .= "- virtualbox-mcp (VM management)`n"
    prompt .= "- All other configured MCPs`n`n"
    prompt .= "Orchestration Tasks:`n`n"
    prompt .= "🔍 Health Check All MCPs`n"
    prompt .= "- Connection status verification`n"
    prompt .= "- Resource usage analysis`n"
    prompt .= "- Performance metrics collection`n"
    prompt .= "- Error rate monitoring`n`n"
    prompt .= "⚙️ Configuration Optimization`n"
    prompt .= "- Identify conflicting configurations`n"
    prompt .= "- Optimize memory usage`n"
    prompt .= "- Load balancing recommendations`n"
    prompt .= "- Port conflict resolution`n`n"
    prompt .= "Standardization Initiative`n"
    prompt .= "- Update all to FastMCP 2.12+`n"
    prompt .= "- Standardize error handling patterns`n"
    prompt .= "- Unify logging formats`n"
    prompt .= "- Consistent configuration schemas`n`n"
    prompt .= "📊 Cross-MCP Analytics`n"
    prompt .= "- Usage pattern analysis`n"
    prompt .= "- Tool interaction mapping`n"
    prompt .= "- Performance bottleneck identification`n"
    prompt .= "- Optimization opportunities`n`n"
    prompt .= "Execute comprehensive MCP ecosystem analysis and optimization?"
    
    SendText prompt
}

; =============================================================================
; UTILITY & HELP FUNCTIONS
; =============================================================================

; Enhanced Help Display (Ctrl+Shift+H)
^+h::
{
    ShowEnhancedHelp()
}

; Status Display (Ctrl+Shift+S)
^+s::
{
    ShowStatus()
}

; =============================================================================
; STARTUP & INITIALIZATION
; =============================================================================

; Welcome Screen Display (Ctrl+F1)
^F1::
{
    ShowElaborateWelcome()
}

; =============================================================================
; AUTO-INITIALIZATION
; =============================================================================

; Ensure temp directory exists and log startup
if !DirExist(TEMP_DIR) {
    try {
        DirCreate TEMP_DIR
    } catch {
        ; Continue if can't create temp dir
    }
}

; Log script startup
LogOperation("AutoHotkey MCP Scripts Loaded - v2.0 SYNTAX FIXED")

; Show startup notification after brief delay
SetTimer ShowStartupNotification, -2000

; =============================================================================
; ERROR HANDLING & CLEANUP
; =============================================================================

OnExit ExitFunc

ExitFunc(ExitReason, ExitCode) {
    LogOperation("AutoHotkey MCP Scripts Exiting - Reason: " . ExitReason)
}