#Requires AutoHotkey v2.0
; AutoHotkey v2 Scripts for Claude Desktop MCP Development
; Compatible with AutoHotkey v2.0+
#SingleInstance Force

; Show help when script starts
ShowHelp()

; Keep the script running with a timer that does nothing
SetTimer () => 0, 1000

; Hotkeys and other code follow...

; =============================================================================
; CORE MCP DEVELOPMENT SCRIPTS
; =============================================================================

; 1. MCP Server Scaffolding (Ctrl+Shift+M)
Hotkey("^+m", MCPServerScaffold)

MCPServerScaffold(*) {
    SendText "Create new MCP server with fastmcp 2.12.1. Name: "
    ; Wait for user input, then continue with full scaffold
    Sleep 2000
    SendText "`nInclude these components:`n- Basic server setup with proper error handling`n- Standard tool registration`n- Config validation`n- Logging setup`n- README with installation instructions"
}

; 2. Standards Conformance Checker (Ctrl+Shift+C)
Hotkey("^+c", StandardsConformanceCheck)

StandardsConformanceCheck(*) {
    SendText "Run MCP standards conformance check on current project:`n"
    SendText "1. Validate fastmcp 2.12+ compatibility`n"
    SendText "2. Check tool registration patterns`n"
    SendText "3. Verify error handling standards`n"
    SendText "4. Validate config schema`n"
    SendText "5. Check logging implementation`n"
    SendText "6. Test startup sequence`n"
    SendText "7. Validate Claude Desktop integration`n"
    SendText "Generate compliance report with fixes needed."
}

; 3. Claude Desktop Log Analyzer (Ctrl+Shift+L)
Hotkey("^+l", LogAnalyzer)

LogAnalyzer(*) {
    SendText "Analyze Claude Desktop MCP logs for startup issues:`n"
    SendText "Read logs from: C:\Users\sandr\AppData\Roaming\Claude\logs\`n"
    SendText "Focus on latest mcp-server-*.log files`n"
    SendText "Look for:`n- Connection failures`n- Import errors`n- Tool registration issues`n- Config validation problems`n"
    SendText "Provide specific fixes with code examples."
}

; =============================================================================
; ADVANCED WORKFLOW SCRIPTS
; =============================================================================

; 4. Smart MCP Troubleshooter (Ctrl+Shift+T)
Hotkey("^+t", MCPTroubleshooter)

MCPTroubleshooter(*) {
    ; Step 1: Gather system state
    SendText "Start MCP troubleshooting sequence:`n1. Check current MCP server status"
    Sleep 1000
    Send "{Enter}"
    WinWaitActive "Claude"
    Sleep 3000

    ; Step 2: Analyze logs
    SendText "`n2. Analyze latest MCP logs for errors"
    Sleep 1000
    Send "{Enter}"
    Sleep 5000

    ; Step 3: Test fix
    SendText "`n3. Apply most likely fix and test restart"
    Sleep 1000
    Send "{Enter}"
}

; 5. MCP Development Cycle (Ctrl+Shift+D)
Hotkey("^+d", MCPDevelopmentCycle)

MCPDevelopmentCycle(*) {
    SendText "Execute full MCP development cycle:`n"
    SendText "Phase 1: Code Analysis`n- Review current MCP server code`n- Check fastmcp 2.12+ patterns"
    Sleep 2000
    SendText "`nPhase 2: Testing`n- Test tool registration`n- Validate error handling"
    Sleep 2000
    SendText "`nPhase 3: Integration`n- Update Claude Desktop config`n- Test MCP connection"
    Sleep 2000
    SendText "`nPhase 4: Validation`n- Run full test suite`n- Generate status report"
}

; =============================================================================
; SYSTEM MANAGEMENT SCRIPTS
; =============================================================================

; 6. Claude Desktop Restart (Ctrl+Alt+R)
Hotkey("^!r", RestartClaudeDesktop)

RestartClaudeDesktop(*) {
    Run "taskkill /f /im Claude.exe",, "Hide"
    Sleep 2000
    Run "C:\Users\sandr\AppData\Local\AnthropicClaude\app-0.12.129\claude.exe"
}

Hotkey("^!x", CleanRestartClaudeDesktop)

CleanRestartClaudeDesktop(*) {
    ; Find Claude Desktop window
    try {
        WinActivate "Claude"
        Sleep 500

        ; Use File menu to exit cleanly
        Send "!f" ; Alt+F for File menu
        Sleep 300
        Send "x" ; Exit option
        Sleep 1000

        ; Wait for process to fully close
        WinWaitClose "Claude",, 5

        ; Restart Claude Desktop
        Run "C:\Users\sandr\AppData\Local\AnthropicClaude\app-0.12.129\claude.exe"
    } catch {
        ; Fallback: Force restart
        Run "taskkill /f /im Claude.exe",, "Hide"
        Sleep 2000
        Run "C:\Users\sandr\AppData\Local\AnthropicClaude\app-0.12.129\claude.exe"
    }
}

; 7. MCP Config Hot Reload (Ctrl+Shift+R)
Hotkey("^+r", MCPConfigHotReload)

MCPConfigHotReload(*) {
    SendText "Update Claude Desktop MCP configuration:`n"
    SendText "1. Backup current config`n"
    SendText "2. Update claude_desktop_config.json`n"
    SendText "3. Validate JSON syntax`n"
    SendText "4. Restart Claude Desktop"
    Sleep 2000
    Send "{Enter}"
    ; Trigger restart sequence
    Sleep 3000
    Send "^!r" ; Call restart hotkey
}

; =============================================================================
; FILESYSTEM MONITORING SCRIPTS
; =============================================================================

; 8. MCP File Watcher (Ctrl+Shift+W)
Hotkey("^+w", MCPFileWatcher)

MCPFileWatcher(*) {
    SendText "Start MCP file monitoring:`n"
    SendText "Watch for changes in:`n"
    SendText "- D:\Dev\repos\*-mcp\`n"
    SendText "- Claude config: C:\Users\sandr\AppData\Roaming\Claude\claude_desktop_config.json`n"
    SendText "- Log directory: C:\Users\sandr\AppData\Roaming\Claude\logs\`n"
    SendText "`nAuto-trigger actions on file changes:`n"
    SendText "- Config changes → Suggest restart`n"
    SendText "- Code changes → Run validation`n"
    SendText "- New errors in logs → Start troubleshooting"
}

; 9. DXT Package Validator (Ctrl+Shift+P)
Hotkey("^+p", DXTPackageValidator)

DXTPackageValidator(*) {
    SendText "Validate MCP package for DXT:`n"
    SendText "1. Run 'dxt validate' on current project`n"
    SendText "2. Check package.json structure`n"
    SendText "3. Verify all dependencies`n"
    SendText "4. Test installation process`n"
    SendText "5. Validate tool exports`n"
    SendText "6. Generate DXT package if validation passes`n"
    SendText "7. Create GitHub release notes"
}

; =============================================================================
; CREATIVE WORKFLOW ENHANCEMENTS
; =============================================================================

; 10. MCP Idea Generator (Ctrl+Shift+I)
Hotkey("^+i", MCPIdeaGenerator)

MCPIdeaGenerator(*) {
    SendText "Generate MCP server ideas for current development context:`n"
    SendText "Based on:`n- Recent projects: "
    Sleep 1000
    SendText "`n- Current tech stack`n- Austrian/Vienna specific needs`n"
    SendText "- Integration opportunities with existing MCPs`n"
    SendText "`nSuggest 5 practical MCP server concepts with:`n"
    SendText "- Clear use cases`n- Technical feasibility`n- Implementation timeline`n"
    SendText "- Integration points"
}

; 11. Documentation Generator (Ctrl+Shift+G)
Hotkey("^+g", DocumentationGenerator)

DocumentationGenerator(*) {
    SendText "Generate complete MCP documentation:`n"
    SendText "1. README.md with installation & usage`n"
    SendText "2. API documentation for all tools`n"
    SendText "3. Configuration examples`n"
    SendText "4. Troubleshooting guide`n"
    SendText "5. Development setup instructions`n"
    SendText "6. Claude Desktop integration guide`n"
    SendText "7. DXT packaging instructions"
}

; 12. Multi-MCP Orchestrator (Ctrl+Shift+O)
Hotkey("^+o", MultiMCPOrchestrator)

MultiMCPOrchestrator(*) {
    SendText "Orchestrate multiple MCP servers:`n"
    SendText "Current active MCPs:`n"
    SendText "- Check status of all configured MCPs`n"
    SendText "- Identify conflicts or dependencies`n"
    SendText "- Suggest optimization opportunities`n"
    SendText "`nCoordination tasks:`n"
    SendText "- Update all to fastmcp 2.12+`n"
    SendText "- Standardize error handling`n"
    SendText "- Optimize resource usage`n"
    SendText "- Create unified documentation"
}

; =============================================================================
; UTILITY FUNCTIONS
; =============================================================================

; Help hotkey (Ctrl+Shift+H)
Hotkey("^+h", (*) => ShowHelp())

; Show help window
ShowHelp() {
    MsgBox "
    (
    AutoHotkey MCP Development Scripts - Hotkeys:
    
    Core Development:
    Ctrl+Shift+M - New MCP scaffolding
    Ctrl+Shift+C - Standards conformance check  
    Ctrl+Shift+L - Log analysis
    
    Advanced Workflows:
    Ctrl+Shift+T - Smart troubleshooting
    Ctrl+Shift+D - Full development cycle
    
    Help:
    Ctrl+Shift+H - Show this help window
    
    System Management:
    Ctrl+Alt+R - Restart Claude Desktop
    Ctrl+Shift+R - Config hot reload
    
    File Operations:
    Ctrl+Shift+W - File watcher
    Ctrl+Shift+P - DXT package validation
    
    Creative Tools:
    Ctrl+Shift+I - Idea generator
    Ctrl+Shift+G - Documentation generator
    Ctrl+Shift+O - Multi-MCP orchestrator
    
    This Help:
    Ctrl+Shift+H - Show this help
    )", "MCP Development Scripts", 0
}

; =============================================================================
; STARTUP MESSAGE
; =============================================================================

; Show startup notification
Hotkey("^+F1", ShowStartupNotification)

ShowStartupNotification(*) {
    TrayTip "AutoHotkey MCP Scripts Loaded", "Ready for Claude Desktop MCP development!`nPress Ctrl+Shift+H for hotkey help.", 16
}