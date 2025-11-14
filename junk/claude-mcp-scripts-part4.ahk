#Requires AutoHotkey v2.0+

; =============================================================================
; CONFIGURATION & GLOBALS
; =============================================================================

; Global configuration (if not already defined in part2)
if (!IsSet(CLAUDE_EXE)) {
    CLAUDE_EXE := "C:\Users\sandr\AppData\Local\AnthropicClaude\app-0.12.129\claude.exe"
}
if (!IsSet(TEMP_DIR)) {
    TEMP_DIR := "C:\temp\"
}

; =============================================================================
; ADVANCED FEATURES
; =============================================================================

; Stubs for functions from part1 (if not already defined)
; These will be overridden if part1 is included first
LogOperation(operation) {
    OutputDebug("LogOperation: " . operation . "`n")
}

ShowStatus() {
    TrayTip("Status", "MCP Development Status", 2)
}

; 12. Multi-MCP Orchestration Dashboard (Ctrl+Shift+O)
MCPOrchestration(*) {
    LogOperation("MCP Orchestration")
    
    prompt := "🎛️ Multi-MCP Orchestration Dashboard`n"
    prompt .= "====================================`n`n"
    prompt .= "System Analysis:`n"
    prompt .= "1. 📊 Inventory all configured MCP servers`n"
    prompt .= "2. 🔍 Check individual health status`n"
    prompt .= "3. 📈 Resource usage profiling`n"
    prompt .= "4. 🔗 Identify inter-dependencies`n"
    prompt .= "5. ⚡ Performance benchmarking`n"
    prompt .= "6. 🚨 Conflict detection`n`n"
    prompt .= "Optimization Tasks:`n"
    prompt .= "• 🆙 Upgrade all to FastMCP 2.12+`n"
    prompt .= "• 🛡️ Standardize error handling patterns`n"
    prompt .= "• 🎯 Optimize resource allocation`n"
    prompt .= "• 📚 Create unified documentation`n"
    prompt .= "• 🔒 Implement security best practices`n"
    prompt .= "• 🚀 Performance tuning recommendations`n`n"
    prompt .= "Create comprehensive MCP ecosystem management plan?"
    
    SendText(prompt)
}
Hotkey("^+o", MCPOrchestration)

; 13. MCP Performance Profiler (Ctrl+Shift+F)
PerformanceProfiler(*) {
    LogOperation("Performance Profiling")
    
    prompt := "📊 MCP Performance Profiling Suite`n"
    prompt .= "=================================`n`n"
    prompt .= "Profiling Scope:`n"
    prompt .= "🚀 Startup Performance`n"
    prompt .= "- Server initialization time`n"
    prompt .= "- Tool registration latency`n"
    prompt .= "- Memory allocation patterns`n`n"
    prompt .= "⚡ Runtime Performance`n"
    prompt .= "- Tool execution benchmarks`n"
    prompt .= "- Request/response latencies`n"
    prompt .= "- Resource utilization metrics`n`n"
    prompt .= "🔍 Bottleneck Analysis`n"
    prompt .= "- CPU usage profiling`n"
    prompt .= "- Memory leak detection`n"
    prompt .= "- I/O operation analysis`n"
    prompt .= "- Network latency measurement`n`n"
    prompt .= "Generate detailed performance report with actionable insights."
    
    SendText(prompt)
}
Hotkey("^+f", PerformanceProfiler)

; 14. MCP Security Auditor (Ctrl+Shift+S)
SecurityAuditor(*) {
    LogOperation("Security Audit")
    
    prompt := "🔒 MCP Security Audit Framework`n"
    prompt .= "==============================`n`n"
    prompt .= "Security Assessment Areas:`n`n"
    prompt .= "🛡️ Code Security`n"
    prompt .= "- Static analysis with bandit`n"
    prompt .= "- Dependency vulnerability scan`n"
    prompt .= "- Input validation review`n"
    prompt .= "- Output sanitization check`n`n"
    prompt .= "🔐 Configuration Security`n"
    prompt .= "- Credential management review`n"
    prompt .= "- Permission and access controls`n"
    prompt .= "- Network security configuration`n`n"
    prompt .= "🚨 Runtime Security`n"
    prompt .= "- Process isolation verification`n"
    prompt .= "- Resource access limitations`n"
    prompt .= "- Error information disclosure`n`n"
    prompt .= "Generate comprehensive security report with remediation steps."
    
    SendText(prompt)
}
Hotkey("^+s", SecurityAuditor)

; 15. MCP Testing Automation (Ctrl+Shift+A)
TestingAutomation(*) {
    LogOperation("Testing Automation")
    
    prompt := "🧪 MCP Testing Automation Suite`n"
    prompt .= "==============================`n`n"
    prompt .= "Test Coverage Analysis:`n`n"
    prompt .= "🔬 Unit Testing`n"
    prompt .= "- Individual tool function tests`n"
    prompt .= "- Error handling validation`n"
    prompt .= "- Edge case coverage`n"
    prompt .= "- Mock data testing`n`n"
    prompt .= "🔗 Integration Testing`n"
    prompt .= "- Claude Desktop connectivity`n"
    prompt .= "- Tool chain execution`n"
    prompt .= "- Configuration loading`n"
    prompt .= "- Inter-tool communication`n`n"
    prompt .= "⚡ Performance Testing`n"
    prompt .= "- Load testing scenarios`n"
    prompt .= "- Stress testing limits`n"
    prompt .= "- Concurrent user simulation`n`n"
    prompt .= "Create comprehensive testing strategy with automated execution?"
    
    SendText(prompt)
}
Hotkey("^+a", TestingAutomation)

; 16. MCP Deployment Manager (Ctrl+Shift+Y)
DeploymentManager(*) {
    LogOperation("Deployment Management")
    
    prompt := "🚀 MCP Deployment Management System`n"
    prompt .= "==================================`n`n"
    prompt .= "Deployment Pipeline:`n`n"
    prompt .= "📋 Pre-deployment Checks`n"
    prompt .= "- Code quality verification`n"
    prompt .= "- Test suite execution`n"
    prompt .= "- Security scan completion`n"
    prompt .= "- Documentation updates`n`n"
    prompt .= "📦 Package Preparation`n"
    prompt .= "- DXT package generation`n"
    prompt .= "- Version increment and tagging`n"
    prompt .= "- Changelog generation`n`n"
    prompt .= "🌐 Distribution Strategy`n"
    prompt .= "- GitHub release creation`n"
    prompt .= "- Package registry publication`n"
    prompt .= "- Documentation deployment`n`n"
    prompt .= "Execute deployment pipeline with full automation?"
    
    SendText(prompt)
}
Hotkey("^+y", DeploymentManager)

; =============================================================================
; UTILITY HOTKEYS
; =============================================================================

; Quick Status Check (Ctrl+Shift+Q)
Hotkey("^+q", (*) => ShowStatus())

; Basic Memory Quick Note (Ctrl+Shift+N)
QuickNote(*) {
    LogOperation("Quick Note")
    
    noteContent := ""
    InputBox(&noteContent, "Quick MCP Note", "Enter note content:", , 400, 130)
    if (noteContent == "") {
        return
    }
    
    ; Generate timestamped note command
    SendText("Write to basic memory: " . noteContent . " - " . A_Now . " [mcp, note, " . A_YYYY . "-" . A_MM . "-" . A_DD . ", medium]")
}
Hotkey("^+n", QuickNote)

; Emergency Claude Desktop Kill & Restart (Ctrl+Alt+X)
EmergencyRestart(*) {
    LogOperation("Emergency Restart")
    
    TrayTip("Emergency Restart", "Force killing Claude Desktop and restarting...", 2)
    
    ; Force kill all Claude processes
    Run("taskkill /f /im Claude.exe /t",, "Hide")
    Run("taskkill /f /im python.exe /f",, "Hide") ; Kill any hanging MCP servers
    
    Sleep(3000)
    
    ; Clear temp files
    try {
        FileDelete(TEMP_DIR . "claude_*.lock")
        FileDelete(TEMP_DIR . "mcp_*.tmp")
    } catch {
        ; Ignore cleanup errors
    }
    
    ; Restart Claude Desktop
    Run(CLAUDE_EXE)
    
    TrayTip("Emergency Restart Complete", "Claude Desktop restarted fresh!", 3)
}
Hotkey("^!x", EmergencyRestart)

; =============================================================================
; ENHANCED HELP SYSTEM
; =============================================================================

; Enhanced help display (Ctrl+Shift+H)
ShowEnhancedHelp(*) {
    helpText := "
    (LTrim
    Enhanced AutoHotkey MCP Development Scripts v2.0
    ================================================
    
    🔧 CORE DEVELOPMENT:
    Ctrl+Shift+M - Advanced MCP scaffolding with interactive prompts
    Ctrl+Shift+C - Standards conformance check with detailed report
    Ctrl+Shift+L - AI-powered log analysis with pattern recognition
    
    🚀 ADVANCED WORKFLOWS:
    Ctrl+Shift+T - AI smart troubleshooting (7-phase analysis)
    Ctrl+Shift+D - Enhanced development cycle with CI/CD pipeline
    
    🎛️ SYSTEM MANAGEMENT:
    Ctrl+Alt+R   - Intelligent Claude restart with graceful shutdown
    Ctrl+Alt+X   - Emergency restart with process cleanup
    Ctrl+Shift+R - Hot config reload with validation
    
    📁 FILE & PROJECT OPS:
    Ctrl+Shift+W - Advanced file watcher with AI monitoring
    Ctrl+Shift+P - Enhanced DXT packaging with full pipeline
    
    💡 CREATIVE TOOLS:
    Ctrl+Shift+I - AI idea generator with context awareness
    Ctrl+Shift+G - Comprehensive documentation generation
    Ctrl+Shift+O - Multi-MCP orchestration dashboard
    
    🔍 ADVANCED FEATURES:
    Ctrl+Shift+F - Performance profiler with bottleneck analysis
    Ctrl+Shift+S - Security auditor with vulnerability scanning
    Ctrl+Shift+A - Testing automation with coverage analysis
    Ctrl+Shift+Y - Deployment manager with full pipeline
    
    ⚡ UTILITIES:
    Ctrl+Shift+Q - Quick status display
    Ctrl+Shift+N - Basic memory quick note
    Ctrl+Shift+H - Show this enhanced help
    
    All scripts include:
    - Interactive input dialogs for customization
    - Basic memory integration for project tracking
    - Comprehensive AI-powered prompts
    - Error handling and graceful fallbacks
    - Austrian development context awareness
    )"
    MsgBox(helpText, "Enhanced MCP Development Scripts v2.0", 0)
}
Hotkey("^+h", ShowEnhancedHelp)

; =============================================================================
; STARTUP NOTIFICATION
; =============================================================================

; Show enhanced startup notification (F1 on startup)
ShowStartupNotification(*) {
    message := "🚀 Ready for advanced Claude Desktop MCP development!`n" 
    message .= "Press Ctrl+Shift+H for complete hotkey reference`n" 
    message .= "New features: Interactive prompts, AI analysis, Basic Memory integration"
    TrayTip("Enhanced AutoHotkey MCP Scripts v2.0 Loaded!", message, 5)
}
Hotkey("F1", ShowStartupNotification)