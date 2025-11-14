# PowerShell script to fix lambda functions in AutoHotkey file
$filePath = "junk/old_scripts/claude-mcp-scripts-extended.ahk"
$content = Get-Content -Path $filePath -Raw -Encoding UTF8

# Function to convert lambda to named function
# Replace Advanced Log Analyzer
$content = $content -replace 'Hotkey\("`^\+l", \(\*\) => \{', 'AdvancedLogAnalyzer(*) {'
$content = $content -replace '(?s)(    SendText\(prompt\)\s*\})\s*; =============================================================================\s*; ADVANCED WORKFLOW SCRIPTS', '$1`nHotkey("^+l", AdvancedLogAnalyzer)`n`n; =============================================================================`n; ADVANCED WORKFLOW SCRIPTS'

# Replace Enhanced Development Cycle
$content = $content -replace 'Hotkey\("`^\+d", \(\*\) => \{', 'EnhancedDevelopmentCycle(*) {'
$content = $content -replace '(?s)(    SendText\(prompt\)\s*\})\s*; =============================================================================\s*; SYSTEM MANAGEMENT', '$1`nHotkey("^+d", EnhancedDevelopmentCycle)`n`n; =============================================================================`n; SYSTEM MANAGEMENT'

# Replace Intelligent Claude Restart
$content = $content -replace 'Hotkey\("`^!r", \(\*\) => \{', 'IntelligentClaudeRestart(*) {'
$content = $content -replace '(?s)(    SendClaudeMessage\([^)]+\)\s*\})\s*; Emergency Restart', '$1`nHotkey("^!r", IntelligentClaudeRestart)`n`n; Emergency Restart'

# Replace Emergency Restart
$content = $content -replace 'Hotkey\("`^!x", \(\*\) => \{', 'EmergencyRestart(*) {'
$content = $content -replace '(?s)(    TrayTip\("Claude Desktop restarted fresh!",[^)]+\)\s*\})\s*; Hot Config Reload', '$1`nHotkey("^!x", EmergencyRestart)`n`n; Hot Config Reload'

# Replace Hot Config Reload
$content = $content -replace 'Hotkey\("`^\+r", \(\*\) => \{', 'HotConfigReload(*) {'
$content = $content -replace '(?s)(    Send\("`^!r"\)\s*\})\s*; =============================================================================\s*; FILE & PROJECT MONITORING', '$1`nHotkey("^+r", HotConfigReload)`n`n; =============================================================================`n; FILE & PROJECT MONITORING'

# Replace Advanced File Watcher
$content = $content -replace 'Hotkey\("`^\+w", \(\*\) => \{', 'AdvancedFileWatcher(*) {'
$content = $content -replace '(?s)(    SendText\(prompt\)\s*\})\s*; Enhanced DXT Package Management', '$1`nHotkey("^+w", AdvancedFileWatcher)`n`n; Enhanced DXT Package Management'

# Replace Enhanced DXT Package Management
$content = $content -replace 'Hotkey\("`^\+p", \(\*\) => \{', 'EnhancedDXTPackageManagement(*) {'
$content = $content -replace '(?s)(    SendText\(prompt\)\s*\})\s*; =============================================================================\s*; CREATIVE & PRODUCTIVITY TOOLS', '$1`nHotkey("^+p", EnhancedDXTPackageManagement)`n`n; =============================================================================`n; CREATIVE & PRODUCTIVITY TOOLS'

# Replace AI MCP Idea Generator
$content = $content -replace 'Hotkey\("`^\+i", \(\*\) => \{', 'AIMCPIdeaGenerator(*) {'
$content = $content -replace '(?s)(    SendText\(prompt\)\s*\})\s*; Documentation Generator', '$1`nHotkey("^+i", AIMCPIdeaGenerator)`n`n; Documentation Generator'

# Replace Documentation Generator
$content = $content -replace 'Hotkey\("`^\+g", \(\*\) => \{', 'DocumentationGenerator(*) {'
$content = $content -replace '(?s)(    SendText\(prompt\)\s*\})\s*; Multi-MCP Orchestrator', '$1`nHotkey("^+g", DocumentationGenerator)`n`n; Multi-MCP Orchestrator'

# Replace Multi-MCP Orchestrator
$content = $content -replace 'Hotkey\("`^\+o", \(\*\) => \{', 'MultiMCPOrchestrator(*) {'
$content = $content -replace '(?s)(    SendText\(prompt\)\s*\})\s*; =============================================================================\s*; UTILITY & HELP FUNCTIONS', '$1`nHotkey("^+o", MultiMCPOrchestrator)`n`n; =============================================================================`n; UTILITY & HELP FUNCTIONS'

# Replace simple lambda wrappers
$content = $content -replace 'Hotkey\("`^\+h", \(\*\) => ShowEnhancedHelp\(\)\)', 'ShowHelpWrapper(*) {`n    ShowEnhancedHelp()`n}`nHotkey("^+h", ShowHelpWrapper)'
$content = $content -replace 'Hotkey\("`^\+s", \(\*\) => ShowStatus\(\)\)', 'ShowStatusWrapper(*) {`n    ShowStatus()`n}`nHotkey("^+s", ShowStatusWrapper)'
$content = $content -replace 'Hotkey\("`^F1", \(\*\) => ShowElaborateWelcome\(\)\)', 'ShowWelcomeWrapper(*) {`n    ShowElaborateWelcome()`n}`nHotkey("^F1", ShowWelcomeWrapper)'

# Write the fixed content back
Set-Content -Path $filePath -Value $content -Encoding UTF8 -NoNewline
Write-Host "Fixed all lambda functions in $filePath"
