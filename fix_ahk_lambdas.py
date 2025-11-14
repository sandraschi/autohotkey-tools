#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""Fix lambda functions in AutoHotkey file."""

file_path = "junk/old_scripts/claude-mcp-scripts-extended.ahk"

# Read the file
with open(file_path, 'r', encoding='utf-8') as f:
    lines = f.readlines()

# Convert to string for easier manipulation
content = ''.join(lines)

# Function mappings: (hotkey, lambda_start, lambda_end_marker, function_name, next_section)
# We'll find the lambda block and replace it

# Replace Advanced Log Analyzer (^+l)
content = content.replace(
    '; Advanced Log Analyzer (Ctrl+Shift+L)\nHotkey("^+l", (*) => {',
    '; Advanced Log Analyzer (Ctrl+Shift+L)\nAdvancedLogAnalyzer(*) {'
)
# Find the closing })} and replace with } followed by Hotkey declaration
idx = content.find('    SendText(prompt)\n})\n\n; =============================================================================\n; ADVANCED WORKFLOW SCRIPTS')
if idx != -1:
    content = content[:idx] + '    SendText(prompt)\n}\nHotkey("^+l", AdvancedLogAnalyzer)\n\n; =============================================================================\n; ADVANCED WORKFLOW SCRIPTS' + content[idx + len('    SendText(prompt)\n})\n\n; =============================================================================\n; ADVANCED WORKFLOW SCRIPTS'):]

# Replace Enhanced Development Cycle (^+d)
content = content.replace(
    '; Enhanced Development Cycle (Ctrl+Shift+D)\nHotkey("^+d", (*) => {',
    '; Enhanced Development Cycle (Ctrl+Shift+D)\nEnhancedDevelopmentCycle(*) {'
)
idx = content.find('    SendText(prompt)\n})\n\n; =============================================================================\n; SYSTEM MANAGEMENT')
if idx != -1:
    content = content[:idx] + '    SendText(prompt)\n}\nHotkey("^+d", EnhancedDevelopmentCycle)\n\n; =============================================================================\n; SYSTEM MANAGEMENT' + content[idx + len('    SendText(prompt)\n})\n\n; =============================================================================\n; SYSTEM MANAGEMENT'):]

# Replace Intelligent Claude Restart (^!r)
content = content.replace(
    '; Intelligent Claude Desktop Restart (Ctrl+Alt+R)\nHotkey("^!r", (*) => {',
    '; Intelligent Claude Desktop Restart (Ctrl+Alt+R)\nIntelligentClaudeRestart(*) {'
)
idx = content.find('    SendClaudeMessage("Claude Desktop restarted at " . A_Now . " - MCP servers should reconnect automatically")\n})\n\n; Emergency Restart')
if idx != -1:
    content = content[:idx] + '    SendClaudeMessage("Claude Desktop restarted at " . A_Now . " - MCP servers should reconnect automatically")\n}\nHotkey("^!r", IntelligentClaudeRestart)\n\n; Emergency Restart' + content[idx + len('    SendClaudeMessage("Claude Desktop restarted at " . A_Now . " - MCP servers should reconnect automatically")\n})\n\n; Emergency Restart'):]

# Replace Emergency Restart (^!x)
content = content.replace(
    '; Emergency Restart (Ctrl+Alt+X)\nHotkey("^!x", (*) => {',
    '; Emergency Restart (Ctrl+Alt+X)\nEmergencyRestart(*) {'
)
idx = content.find('    TrayTip("Claude Desktop restarted fresh!", "Emergency Restart Complete", 3)\n})\n\n; Hot Config Reload')
if idx != -1:
    content = content[:idx] + '    TrayTip("Claude Desktop restarted fresh!", "Emergency Restart Complete", 3)\n}\nHotkey("^!x", EmergencyRestart)\n\n; Hot Config Reload' + content[idx + len('    TrayTip("Claude Desktop restarted fresh!", "Emergency Restart Complete", 3)\n})\n\n; Hot Config Reload'):]

# Replace Hot Config Reload (^+r)
content = content.replace(
    '; Hot Config Reload (Ctrl+Shift+R)\nHotkey("^+r", (*) => {',
    '; Hot Config Reload (Ctrl+Shift+R)\nHotConfigReload(*) {'
)
idx = content.find('    Send("^!r")\n})\n\n; =============================================================================\n; FILE & PROJECT MONITORING')
if idx != -1:
    content = content[:idx] + '    Send("^!r")\n}\nHotkey("^+r", HotConfigReload)\n\n; =============================================================================\n; FILE & PROJECT MONITORING' + content[idx + len('    Send("^!r")\n})\n\n; =============================================================================\n; FILE & PROJECT MONITORING'):]

# Replace Advanced File Watcher (^+w)
content = content.replace(
    '; Advanced File Watcher (Ctrl+Shift+W)\nHotkey("^+w", (*) => {',
    '; Advanced File Watcher (Ctrl+Shift+W)\nAdvancedFileWatcher(*) {'
)
idx = content.find('    SendText(prompt)\n})\n\n; Enhanced DXT Package Management')
if idx != -1:
    content = content[:idx] + '    SendText(prompt)\n}\nHotkey("^+w", AdvancedFileWatcher)\n\n; Enhanced DXT Package Management' + content[idx + len('    SendText(prompt)\n})\n\n; Enhanced DXT Package Management'):]

# Replace Enhanced DXT Package Management (^+p)
content = content.replace(
    '; Enhanced DXT Package Management (Ctrl+Shift+P)\nHotkey("^+p", (*) => {',
    '; Enhanced DXT Package Management (Ctrl+Shift+P)\nEnhancedDXTPackageManagement(*) {'
)
idx = content.find('    SendText(prompt)\n})\n\n; =============================================================================\n; CREATIVE & PRODUCTIVITY TOOLS')
if idx != -1:
    content = content[:idx] + '    SendText(prompt)\n}\nHotkey("^+p", EnhancedDXTPackageManagement)\n\n; =============================================================================\n; CREATIVE & PRODUCTIVITY TOOLS' + content[idx + len('    SendText(prompt)\n})\n\n; =============================================================================\n; CREATIVE & PRODUCTIVITY TOOLS'):]

# Replace AI MCP Idea Generator (^+i)
content = content.replace(
    '; AI MCP Idea Generator (Ctrl+Shift+I)\nHotkey("^+i", (*) => {',
    '; AI MCP Idea Generator (Ctrl+Shift+I)\nAIMCPIdeaGenerator(*) {'
)
idx = content.find('    SendText(prompt)\n})\n\n; Documentation Generator')
if idx != -1:
    content = content[:idx] + '    SendText(prompt)\n}\nHotkey("^+i", AIMCPIdeaGenerator)\n\n; Documentation Generator' + content[idx + len('    SendText(prompt)\n})\n\n; Documentation Generator'):]

# Replace Documentation Generator (^+g)
content = content.replace(
    '; Documentation Generator (Ctrl+Shift+G)\nHotkey("^+g", (*) => {',
    '; Documentation Generator (Ctrl+Shift+G)\nDocumentationGenerator(*) {'
)
idx = content.find('    SendText(prompt)\n})\n\n; Multi-MCP Orchestrator')
if idx != -1:
    content = content[:idx] + '    SendText(prompt)\n}\nHotkey("^+g", DocumentationGenerator)\n\n; Multi-MCP Orchestrator' + content[idx + len('    SendText(prompt)\n})\n\n; Multi-MCP Orchestrator'):]

# Replace Multi-MCP Orchestrator (^+o) - THIS IS THE ONE ON LINE 819
content = content.replace(
    '; Multi-MCP Orchestrator (Ctrl+Shift+O)\nHotkey("^+o", (*) => {',
    '; Multi-MCP Orchestrator (Ctrl+Shift+O)\nMultiMCPOrchestrator(*) {'
)
idx = content.find('    SendText(prompt)\n})\n\n; =============================================================================\n; UTILITY & HELP FUNCTIONS')
if idx != -1:
    content = content[:idx] + '    SendText(prompt)\n}\nHotkey("^+o", MultiMCPOrchestrator)\n\n; =============================================================================\n; UTILITY & HELP FUNCTIONS' + content[idx + len('    SendText(prompt)\n})\n\n; =============================================================================\n; UTILITY & HELP FUNCTIONS'):]

# Replace simple lambda wrappers
content = content.replace(
    'Hotkey("^+h", (*) => ShowEnhancedHelp())',
    'ShowHelpWrapper(*) {\n    ShowEnhancedHelp()\n}\nHotkey("^+h", ShowHelpWrapper)'
)
content = content.replace(
    'Hotkey("^+s", (*) => ShowStatus())',
    'ShowStatusWrapper(*) {\n    ShowStatus()\n}\nHotkey("^+s", ShowStatusWrapper)'
)
content = content.replace(
    'Hotkey("^F1", (*) => ShowElaborateWelcome())',
    'ShowWelcomeWrapper(*) {\n    ShowElaborateWelcome()\n}\nHotkey("^F1", ShowWelcomeWrapper)'
)

# Write the fixed content back
with open(file_path, 'w', encoding='utf-8') as f:
    f.write(content)

print(f"Fixed all lambda functions in {file_path}")
print("All lambda functions have been converted to named functions.")
