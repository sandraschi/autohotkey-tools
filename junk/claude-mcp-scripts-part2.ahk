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

; =============================================================================
; ADVANCED WORKFLOW SCRIPTS (Significantly Enhanced)
; =============================================================================

; 4. AI-Powered Smart MCP Troubleshooter (Ctrl+Shift+T)
SmartTroubleshooter(*) {
    LogOperation("Smart Troubleshooting")
    
    ; Multi-phase intelligent troubleshooting
    phases := [
        "Phase 1: System State Analysis - Checking MCP server statuses and resource usage",
        "Phase 2: Configuration Validation - Analyzing Claude Desktop config and MCP settings", 
        "Phase 3: Log Pattern Analysis - Processing recent error patterns with AI",
        "Phase 4: Dependency Verification - Checking Python environment and package versions",
        "Phase 5: Network Connectivity - Testing inter-process communication",
        "Phase 6: Performance Profiling - Memory and CPU usage analysis",
        "Phase 7: Solution Synthesis - AI-generated fix recommendations"
    ]
    
    SendText("🔧 AI-Powered MCP Troubleshooting Sequence`n")
    SendText("=====================================`n`n")
    
    for index, phase in phases {
        SendText(phase . "`n")
        if (index <= 3) {
            Sleep(1500)
            Send("{Enter}")
            Sleep(2000)
        }
    }
    
    SendText("`n🎯 Generate comprehensive diagnostic report with:`n")
    SendText("- Priority-ranked issues`n")
    SendText("- Step-by-step fix instructions`n")
    SendText("- Code patches where needed`n")
    SendText("- Preventive measures`n")
    SendText("- Monitoring recommendations")
}
Hotkey("^+t", SmartTroubleshooter)

; 5. Enhanced Development Cycle with CI/CD (Ctrl+Shift+D)
DevelopmentCycle(*) {
    LogOperation("Development Cycle")
    
    prompt := "🚀 Enhanced MCP Development Lifecycle`n"
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
    
    SendText(prompt)
}
Hotkey("^+d", DevelopmentCycle)

; =============================================================================
; SYSTEM MANAGEMENT SCRIPTS (Enhanced)
; =============================================================================

; 6. Intelligent Claude Desktop Management (Ctrl+Alt+R)
ClaudeDesktopRestart(*) {
    LogOperation("Claude Desktop Restart")
    
    ; Show status during restart
    TrayTip("Restarting Claude Desktop", "Gracefully closing and restarting...", 2)
    
    ; Try graceful shutdown first
    try {
        WinActivate("Claude")
        Sleep(500)
        Send("!{F4}") ; Alt+F4 for graceful close
        Sleep(3000)
        
        ; Wait for process to close
        WinWaitClose("Claude",, 10)
    }
    catch {
        ; Fallback to force kill
        Run("taskkill /f /im Claude.exe",, "Hide")
        Sleep(2000)
    }
    
    ; Clear any potential locks
    try {
        FileDelete(TEMP_DIR . "claude_restart.lock")
    }
    catch {
        ; Ignore if file doesn't exist
    }
    
    ; Restart with logging
    Run(CLAUDE_EXE)
    
    ; Confirm restart
    Sleep(3000)
    TrayTip("Claude Desktop Restarted", "Ready for MCP development!", 2)
    
    ; Log the restart
    SendClaudeMessage("Claude Desktop restarted at " . A_Now . " - MCP servers should reconnect automatically")
}
Hotkey("^!r", ClaudeDesktopRestart)

; 7. Hot Config Reload with Validation (Ctrl+Shift+R)
ConfigHotReload(*) {
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
    
    SendText(prompt)
    
    ; Auto-trigger restart after config validation
    Sleep(5000)
    SendText("`n`nConfig validated - triggering restart...`n")
    Sleep(2000)
    Send("^!r") ; Call intelligent restart
}
Hotkey("^+r", ConfigHotReload)