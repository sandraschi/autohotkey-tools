; ==============================================================================
; Macro Expander
; @name: Macro Expander
; @version: 1.0.0
; @description: Type //name arg1 arg2 then Tab or Enter, anywhere, to expand into a full prompt template loaded from sop/macros.md. Positional {1} {2} substitution. Auto-reloads within 4s of any edit (Ctrl+Alt+R forces it immediately).
; @category: productivity
; @author: Sandra
; @hotkeys: none fixed (trigger string is //); Ctrl+Alt+R reloads sop/macros.md
; @enabled: true
; @priority: 20
; @tag: macros, text-expansion, sop, prompts, ai
; ==============================================================================

#Requires AutoHotkey v2.0+
#SingleInstance Force
#Warn

OnError(LogError)
try
    #Include %A_ScriptDir%\lib\ScriptletErrorHandler.ahk
catch
    LogError(*) {
    }

Global MacroSOP := Map()
Global SOPPath := A_ScriptDir "\..\sop\macros.md"
Global SOPLastMod := ""

LoadMacros()
SOPLastMod := FileExist(SOPPath) ? FileGetTime(SOPPath, "M") : ""
Hotkey "^!r", ReloadMacros

; Auto-reload: poll the SOP file's mtime every 4s so edits made via the
; macro_upsert/macro_delete MCP tools (or hand edits) go live without a
; restart or manual Ctrl+Alt+R.
SetTimer(CheckSOPChanged, 4000)

CheckSOPChanged(*) {
    Global SOPLastMod
    if !FileExist(SOPPath)
        return
    mod := FileGetTime(SOPPath, "M")
    if (mod != SOPLastMod) {
        SOPLastMod := mod
        LoadMacros()
    }
}

; Fires the instant "//" is typed - "*" means no ending character required,
; "X" means execute the following expression instead of replacing text.
:X*:// ::OnSlashSlash()

OnSlashSlash(*) {
    Global ih := InputHook("V", "{Tab}{Enter}")
    ih.KeyOpt("{Backspace}", "N")
    ih.OnEnd := HandleMacroInput
    ih.Start()
}

HandleMacroInput(ih) {
    text := Trim(ih.Input, " `t")
    if (text = "")
        return

    parts := StrSplit(text, " ")
    name := parts.RemoveAt(1)

    if !MacroSOP.Has(name) {
        ToolTip("Unknown macro: //" name)
        SetTimer(() => ToolTip(), -1500)
        return
    }

    template := MacroSOP[name]
    for i, val in parts
        template := StrReplace(template, "{" i "}", val)
    template := RegExReplace(template, "\{\d+\}", "")

    ; Erase the typed "//" + captured text before pasting the expansion.
    ; NOTE: verify this count once by testing - X-option hotstrings may or
    ; may not auto-erase the "//" trigger depending on AHK build. If "//"
    ; is still on screen after expansion runs, this is right; if the
    ; expansion appears with a stray leftover "//", drop the "2 +" below.
    Loop (2 + StrLen(ih.Input))
        Send("{Backspace}")

    SendText(template)
}

ReloadMacros(*) {
    LoadMacros()
    TrayTip("Macro Expander", "Reloaded " MacroSOP.Count " macros", 1)
    SetTimer(() => TrayTip(), -2000)
}

LoadMacros() {
    Global MacroSOP := Map()
    if !FileExist(SOPPath) {
        TrayTip("Macro Expander", "SOP file not found: " SOPPath, 2)
        SetTimer(() => TrayTip(), -2000)
        return
    }
    content := FileRead(SOPPath, "UTF-8")
    sections := StrSplit(content, "`n## ")
    for block in sections {
        block := Trim(block, "`r`n `t")
        if (block = "" || SubStr(block, 1, 1) = "#")
            continue
        lines := StrSplit(block, "`n", , 2)
        name := Trim(lines[1])
        body := lines.Length >= 2 ? Trim(lines[2]) : ""
        if (name != "")
            MacroSOP[name] := body
    }
}

LogError(*) {
    ; no-op if no ScriptletErrorHandler
}
