; ==============================================================================
; Prompt Snippets Bank
; @name: Prompt Snippets Bank
; @version: 1.0.0
; @description: Bank of text snippets for IDE and AI prompting. Avoid repetitive typing: scaffold MCP server, FastMCP 3.1 upgrade, PR template, commit message, code review checklist, Cursor rules. ASCII-only compact UI, hotkey to show table, copy prompt to clipboard.
; @category: productivity
; @author: Sandra
; @hotkeys: ^!p
; @enabled: true
; @priority: 20
; @tag: prompts, snippets, ide, cursor, mcp, productivity
; ==============================================================================

#Requires AutoHotkey v2.0+
#SingleInstance Force
#Warn

OnError(LogError)
try
    #Include A_ScriptDir\lib\ScriptletErrorHandler.ahk
catch
    LogError(*) {}

; --- Prompt definitions (key, short desc, full body) ---
Global PROMPTS := [
    Map("key", "new_mcp_server", "desc", "Scaffold new MCP server", "body",
        "Create a new MCP server with FastMCP 3.1: pyproject.toml (fastmcp>=3.1, fastapi, uvicorn, httpx), src/<name>_mcp/server.py with FastMCP app, GET /health and POST /tool, stdio-only when stdin is not a TTY. Include a tools module with one example tool. README with run instructions and env (PORT)."),
    Map("key", "fastmcp_31_upgrade", "desc", "Repo scan -> FastMCP 3.1", "body",
        "Scan this repo for MCP server code. Update to FastMCP 3.1: replace deprecated APIs, ensure stdio-only when stdin is a pipe (no uvicorn bind in IDE), add/update GET /health and POST /tool for bridge compatibility. Check pyproject.toml and entry point."),
    Map("key", "pr_template", "desc", "PR description template", "body",
        "## What\n\n## Why\n\n## How (optional)\n\n## Checklist\n- [ ] Tests / no regressions\n- [ ] Docs updated if needed"),
    Map("key", "commit_conventional", "desc", "Conventional commit", "body",
        "Use conventional commits: type(scope): message. Types: feat, fix, docs, style, refactor, test, chore. Scope optional. Example: feat(mcp): add stdio-only mode for Cursor."),
    Map("key", "cursor_rule_concise", "desc", "Cursor rule: concise", "body",
        "Reply in a concise style. Avoid unnecessary repetition or filler. No sycophancy or gaslighting."),
    Map("key", "code_review_checklist", "desc", "Code review checklist", "body",
        "Review for: correctness, edge cases, error handling, security (no secrets, safe inputs), performance (N+1, big O), style and naming, tests covering changes, docs if user-facing."),
    Map("key", "refactor_extract_test", "desc", "Refactor + add tests", "body",
        "Refactor the indicated code: extract a clear function/module, keep single responsibility. Add or extend tests to cover the extracted logic and main paths. Run tests and fix any failures."),
    Map("key", "powershell_no_linux", "desc", "PowerShell: no Linux syntax", "body",
        "Use PowerShell syntax only. No && or ||, no mkdir/rmdir/ls/head/tail; use New-Item, Remove-Item, Get-ChildItem, Select-Object -First/-Last. No pipe to bash. Quote paths with spaces."),
]

Global guiBank := ""
Global listView := ""

Hotkey "^!p", ShowPromptBank
TrayTip "Prompt Snippets Bank", "Press Ctrl+Alt+P to open", 1
SetTimer () => TrayTip(), 2000

ShowPromptBank(*) {
    if (guiBank && WinExist("ahk_id " . guiBank.Hwnd)) {
        guiBank.Show()
        guiBank.Restore()
        return
    }

    guiBank := Gui("+AlwaysOnTop -MaximizeBox", "Prompt Snippets Bank")
    guiBank.BackColor := "0x1e1e1e"
    guiBank.SetFont("s9 cSilver", "Consolas")
    guiBank.MarginX := 8
    guiBank.MarginY := 6

    ; ASCII header
    guiBank.Add("Text", "w500", "+------------------------------------------------------------------+")
    guiBank.Add("Text", "w500", "|  KEY                  |  DESCRIPTION                           |")
    guiBank.Add("Text", "w500", "+------------------------------------------------------------------+")
    guiBank.Add("Text", "w500", "|  Double-click or Enter -> copy prompt body to clipboard          |")
    guiBank.Add("Text", "w500", "+------------------------------------------------------------------+")

    listView := guiBank.Add("ListView", "w500 r12 -Multi AltSubmit", "Key|Description")
    listView.OnEvent("DoubleClick", (*) => CopySelectedPrompt())
    for p in PROMPTS {
        listView.Add("", p["key"], p["desc"])
    }
    listView.ModifyCol(1, 120)
    listView.ModifyCol(2, 370)

    guiBank.Add("Text", "w500", "+------------------------------------------------------------------+")
    btnCopy := guiBank.Add("Button", "w120 Default", "Copy selected")
    btnCopy.OnEvent("Click", (*) => CopySelectedPrompt())
    guiBank.Add("Button", "x+8 w80", "Close").OnEvent("Click", (*) => guiBank.Hide())

    guiBank.OnEvent("Close", (*) => guiBank.Hide())
    guiBank.OnEvent("Escape", (*) => guiBank.Hide())
    guiBank.Show()
}

CopySelectedPrompt() {
    row := listView.GetNext(0, "F")
    if (!row)
        return
    key := listView.GetText(row, 1)
    for p in PROMPTS {
        if (p["key"] = key) {
            A_Clipboard := p["body"]
            TrayTip "Copied", "Prompt: " key, 1
            SetTimer () => TrayTip(), 1500
            return
        }
    }
}

LogError(*) {
    ; no-op if no ScriptletErrorHandler
}
