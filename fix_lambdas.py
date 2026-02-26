#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""Fix lambda functions in AutoHotkey file by converting them to named functions."""

import re

file_path = "junk/old_scripts/claude-mcp-scripts-extended.ahk"

# Read the file
with open(file_path, "r", encoding="utf-8") as f:
    content = f.read()

# Dictionary of replacements: (hotkey_pattern, function_name, function_body_start_pattern, function_body_end_pattern)
replacements = [
    # Advanced Log Analyzer
    (
        "^+l",
        "AdvancedLogAnalyzer",
        r'LogOperation\("Log Analysis"\)',
        r"SendText\(prompt\)\s*\}",
        "ADVANCED WORKFLOW SCRIPTS",
    ),
    # Enhanced Development Cycle
    (
        "^+d",
        "EnhancedDevelopmentCycle",
        r'LogOperation\("Development Cycle"\)',
        r"SendText\(prompt\)\s*\}",
        "SYSTEM MANAGEMENT",
    ),
    # Intelligent Claude Restart
    (
        "^!r",
        "IntelligentClaudeRestart",
        r'LogOperation\("Claude Desktop Restart"\)',
        r"SendClaudeMessage\([^)]+\)\s*\}",
        "Emergency Restart",
    ),
    # Emergency Restart
    (
        "^!x",
        "EmergencyRestart",
        r'LogOperation\("Emergency Restart"\)',
        r'TrayTip\("Claude Desktop restarted fresh!",[^)]+\)\s*\}',
        "Hot Config Reload",
    ),
    # Hot Config Reload
    (
        "^+r",
        "HotConfigReload",
        r'LogOperation\("Config Hot Reload"\)',
        r'Send\("`^!r"\)\s*\}',
        "FILE & PROJECT MONITORING",
    ),
    # Advanced File Watcher
    (
        "^+w",
        "AdvancedFileWatcher",
        r'LogOperation\("File Watcher Setup"\)',
        r"SendText\(prompt\)\s*\}",
        "Enhanced DXT Package Management",
    ),
    # Enhanced DXT Package Management
    (
        "^+p",
        "EnhancedDXTPackageManagement",
        r'LogOperation\("DXT Package Validation"\)',
        r"SendText\(prompt\)\s*\}",
        "CREATIVE & PRODUCTIVITY TOOLS",
    ),
    # AI MCP Idea Generator
    (
        "^+i",
        "AIMCPIdeaGenerator",
        r'LogOperation\("MCP Idea Generation"\)',
        r"SendText\(prompt\)\s*\}",
        "Documentation Generator",
    ),
    # Documentation Generator
    (
        "^+g",
        "DocumentationGenerator",
        r'LogOperation\("Documentation Generation"\)',
        r"SendText\(prompt\)\s*\}",
        "Multi-MCP Orchestrator",
    ),
    # Multi-MCP Orchestrator
    (
        "^+o",
        "MultiMCPOrchestrator",
        r'LogOperation\("Multi-MCP Orchestration"\)',
        r"SendText\(prompt\)\s*\}",
        "UTILITY & HELP FUNCTIONS",
    ),
]

# Process each replacement
for hotkey, func_name, start_pattern, end_pattern, next_section in replacements:
    # Escape special regex characters in hotkey
    hotkey_escaped = hotkey.replace("^", r"\^").replace("+", r"\+").replace("!", r"\!")

    # Pattern to find the lambda function
    pattern = rf'Hotkey\("{hotkey_escaped}", \(\*\) => \{{(.*?)({end_pattern})\s*\}}\s*; =+.*?{next_section}'

    def replace_func(match):
        body = match.group(1)
        # Remove leading indentation from body (assuming 4 spaces)
        body_lines = body.split("\n")
        # Find the first non-empty line to determine base indentation
        base_indent = 0
        for line in body_lines:
            if line.strip():
                base_indent = len(line) - len(line.lstrip())
                break
        # Remove base_indent spaces from all lines
        fixed_body = "\n".join(
            line[base_indent:] if len(line) > base_indent else line
            for line in body_lines
        )
        # Create function definition
        result = f'{func_name}(*) {{{fixed_body}\n}}\nHotkey("{hotkey}", {func_name})\n\n; =============================================================================\n; {next_section}'
        return result

    # Apply replacement
    content = re.sub(pattern, replace_func, content, flags=re.DOTALL)

# Fix simple lambda wrappers
content = re.sub(
    r'Hotkey\("\^\+h", \(\*\) => ShowEnhancedHelp\(\)\)',
    'ShowHelpWrapper(*) {\n    ShowEnhancedHelp()\n}\nHotkey("^+h", ShowHelpWrapper)',
    content,
)
content = re.sub(
    r'Hotkey\("\^\+s", \(\*\) => ShowStatus\(\)\)',
    'ShowStatusWrapper(*) {\n    ShowStatus()\n}\nHotkey("^+s", ShowStatusWrapper)',
    content,
)
content = re.sub(
    r'Hotkey\("\^F1", \(\*\) => ShowElaborateWelcome\(\)\)',
    'ShowWelcomeWrapper(*) {\n    ShowElaborateWelcome()\n}\nHotkey("^F1", ShowWelcomeWrapper)',
    content,
)

# Write the fixed content back
with open(file_path, "w", encoding="utf-8") as f:
    f.write(content)

print(f"Fixed all lambda functions in {file_path}")
