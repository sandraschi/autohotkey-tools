#Requires AutoHotkey v2.0+
#SingleInstance Force
#Include %A_ScriptDir%\lib\ScriptletErrorHandler.ahk

; ==============================================================================
; Text Expander
; @name: Text Expander
; @version: 1.0.0
; @description: Text snippet expander with abbreviations and templates. Expand short abbreviations into full text snippets for faster typing.
; @description: Features customizable snippets, variable substitution, date/time placeholders, and hotkey-based expansion. Supports dynamic content like timestamps and user names.
; @description: Essential productivity tool for users who frequently type repetitive text, email signatures, code snippets, or standard responses.
; @category: productivity
; @author: Sandra
; @hotkeys: ^+s
; @enabled: true
; @priority: 15
; @tag: text-expander, snippets, productivity, typing, shortcuts, templates, utilities
; @cli: --add-snippet <abbrev> <text> - Add new text snippet
; @cli: --list-snippets - List all configured snippets
; @cli: --edit-snippets - Open snippet editor
; @cli: --help - Show CLI usage and text expander options
; @dependencies: 
; ==============================================================================

; Error handling - log to file instead of showing popups
OnError(LogError)


; Global variables
Global snippetsFile := A_ScriptDir "\snippets.json"
Global HOTKEY_SHOW_MENU := "^+s"  ; Ctrl+Shift+S
Global DefaultSnippets := Map()
Global Snippets := Map()

; Initialize default snippets
DefaultSnippets := Map(
    "now", "{time:yyyy-MM-dd HH:mm:ss}",
    "date", "{time:yyyy-MM-dd}",
    "time", "{time:HH:mm}",
    "hi", "Hello! How can I assist you today?",
    "ty", "Thank you!",
    "br", "Best regards,`n" A_UserName,
    "email", "Dear {cursor},`n`n`nBest regards,`n" A_UserName,
    "fori", "for (i := 1; i <= {cursor}; i++) {`n    `n}",
    "if", "if ({cursor}) {`n    `n}",
    "mdlink", "[text](url)",
    "mdimg", "![alt text](image.jpg)"
)

; Initialize snippets map
Snippets := Map()

; Load user snippets or create default ones
if (!FileExist(snippetsFile)) {
    ; If no snippets file exists, save default snippets and use them
    SaveSnippets(DefaultSnippets)
    for key, value in DefaultSnippets {
        Snippets[key] := value
    }
} else {
    ; Load snippets from file
    loadedSnippets := LoadSnippets()
    
    ; First add all default snippets
    for key, value in DefaultSnippets {
        Snippets[key] := value
    }
    
    ; Then add/override with user snippets from file
    for key, value in loadedSnippets {
        Snippets[key] := value
    }
}

; Main script
SetWorkingDir(A_ScriptDir)
Hotkey HOTKEY_SHOW_MENU, ShowSnippetsMenu
TrayTip "Text Expander", "Press " HOTKEY_SHOW_MENU " to show snippets"
SetTimer () => TrayTip(), 3000

; Show snippets menu
ShowSnippetsMenu(*) {
    try {
        menuSnippets := Menu()
        
        ; Add custom snippets first (non-default)
        hasCustomSnippets := false
        for key, value in Snippets {
            if (!DefaultSnippets.Has(key)) {
                menuSnippets.Add(key, (*) => InsertSnippet(key))
                hasCustomSnippets := true
            }
        }
        
        ; Add a separator if we have both types of snippets
        if (hasCustomSnippets && DefaultSnippets.Count > 0) {
            menuSnippets.Add()
        }
        
        ; Add default snippets
        for key, value in DefaultSnippets {
            menuSnippets.Add(key, (*) => InsertSnippet(key))
        }
        
        ; Add the "Add New..." option
        menuSnippets.Add()
        menuSnippets.Add("Add New...", (*) => ShowSnippetEditor())
        
        ; Show the menu
        menuSnippets.Show()
    } catch as e {
        MsgBox("Error showing snippets menu: " . e.Message, "Text Expander", "Iconx")
    }
}

; Insert snippet at cursor position
InsertSnippet(snippetKey) {
    try {
        if (!Snippets.Has(snippetKey)) {
            MsgBox("Snippet not found: " . snippetKey, "Text Expander", "Iconx")
            return
        }
        
        snippet := Snippets[snippetKey]
        
        ; Process placeholders
        dateStr := FormatTime(A_Now, "yyyy-MM-dd")
        timeStr := FormatTime(A_Now, "HH:mm:ss")
        snippet := StrReplace(snippet, "{date}", dateStr)
        snippet := StrReplace(snippet, "{time}", timeStr)
        snippet := StrReplace(snippet, "{user}", A_UserName)
        snippet := StrReplace(snippet, "{computer}", A_ComputerName)
        
        ; Handle cursor position
        cursorPos := InStr(snippet, "{cursor}")
        if (cursorPos) {
            snippet := StrReplace(snippet, "{cursor}", "")
        }
        
        ; Save clipboard and paste
        savedClip := A_Clipboard
        A_Clipboard := snippet
        Send "^v"
        
        ; Position cursor if needed
        if (cursorPos) {
            Send "{Left " (StrLen(SubStr(snippet, cursorPos)) + 1) "}"
        }
        
        SetTimer () => A_Clipboard := savedClip, -100
        
    } catch as e {
        MsgBox("Error inserting snippet: " . e.Message, "Text Expander", "Iconx")
    }
}

; Show snippet editor
ShowSnippetEditor(key := "", value := "") {
    try {
        isNew := (key = "")
        
        guiEditor := Gui("+Owner +ToolWindow", (isNew ? "Add New Snippet" : "Edit Snippet"))
        guiEditor.OnEvent("Close", (*) => guiEditor.Destroy())
        guiEditor.OnEvent("Escape", (*) => guiEditor.Destroy())
        
        guiEditor.SetFont("s9", "Segoe UI")
        
        ; Trigger
        guiEditor.Add("Text", "x10 y10 w80 h20", "Trigger:")
        editTrigger := guiEditor.Add("Edit", "x100 y10 w300 h20 vTrigger", key)
        
        ; Snippet
        guiEditor.Add("Text", "x10 y40 w80 h20", "Snippet:")
        editSnippet := guiEditor.Add("Edit", "x10 y60 w480 h200 vSnippet +Multi", value)
        
        ; Placeholders info
        guiEditor.Add("Text", "x10 y270 w480 h40", "Placeholders: {date}, {time}, {user}, {computer}, {cursor}")
        
        ; Buttons
        btnSave := guiEditor.Add("Button", "x300 y320 w90 h25 Default", "&Save")
        btnSave.OnEvent("Click", (*) => SaveSnippet(guiEditor, editTrigger, editSnippet, isNew))
        
        btnCancel := guiEditor.Add("Button", "x400 y320 w90 h25", "Cancel")
        btnCancel.OnEvent("Click", (*) => guiEditor.Destroy())
        
        guiEditor.Show()
        
    } catch as e {
        MsgBox("Error: " . e.Message, "Text Expander", "Iconx")
    }
}

; Save snippet
SaveSnippet(guiEditor, editTrigger, editSnippet, isNew) {
    key := editTrigger.Value
    value := editSnippet.Value
    
    if (key = "") {
        MsgBox("Please enter a trigger", "Text Expander", "Iconx")
        return
    }
    
    try {
        ; Update in-memory map
        Snippets[key] := value
        
        ; Save to file
        SaveSnippets(Snippets)
        
        guiEditor.Destroy()
        TrayTip "Snippet saved", "Trigger: " key
        SetTimer () => TrayTip(), 3000
        
    } catch as e {
        MsgBox("Error saving snippet: " . e.Message, "Text Expander", "Iconx")
    }
}

; Save snippets to file
 SaveSnippets(snippets) {
     try {
         json := JSON_Stringify(snippets)
        try FileDelete(snippetsFile)
        FileAppend(json, snippetsFile, "UTF-8")
    } catch as e {
        MsgBox("Error saving snippets: " . e.Message, "Text Expander", "Iconx")
        throw e
    }
}

; Load snippets from file
LoadSnippets() {
    snippets := Map()
    try {
        if (!FileExist(snippetsFile)) {
            return snippets
        }
        
        json := FileRead(snippetsFile)
        if (json = "") {
            return snippets
        }
        
        ; Parse JSON string to object
        try {
            obj := JSON_Parse(json)
            if (!IsObject(obj)) {
                return snippets
            }
        } catch as e {
            ; If JSON parsing fails, return empty snippets
            return snippets
        }
        
        ; Convert object properties to Map entries
        for key, value in obj.OwnProps() {
            if (Type(key) = 'String') {
                snippets[key] := value
            }
        }
    } catch as e {
        MsgBox("Error loading snippets: " . e.Message, "Text Expander", "Iconx")
    }
    
    ; Ensure we always return a Map
    if (!IsObject(snippets)) {
        snippets := Map()
    }
    
    return snippets
}

; Simple JSON handler for AutoHotkey v2.0
class JSON {
    static parse(json) {
        if (!json) {
            return {}
        }
        
        try {
            ; Simple parser that handles basic JSON objects
            obj := {}
            json := Trim(json, " `t\r\n")
            
            ; Only handle simple objects for now
            if (SubStr(json, 1, 1) = "{" && SubStr(json, 0) = "}") {
                json := SubStr(json, 2, -1)
                Loop Parse, json, "," {
                    pair := StrSplit(Trim(A_LoopField), ":")
                    if (pair.Length() >= 2) {
                        key := Trim(pair[1], ' `t"')
                        value := Trim(pair[2], ' `t"')
                        obj[key] := value
    }
}

JSON_Stringify(obj, indent := "") {
    if (Type(obj) = "Map") {
        items := []
        for k, v in obj {
            items.Push(indent . "  """ . k . """: " . JSON_Stringify(v, indent . "  "))
        }
        return "{" . "`n" . Join("`,", items) . "`n" . indent . "}"
    }
    if (Type(obj) = "Array") {
        items := []
        for v in obj {
            items.Push(indent . "  " . JSON_Stringify(v, indent . "  "))
        }
        return "[" . "`n" . Join("`,", items) . "`n" . indent . "]"
    }
    if (Type(obj) = "String") {
        s := StrReplace(obj, "\", "\\")
        s := StrReplace(s, """", "\""")
        s := StrReplace(s, "`n", "\n")
        s := StrReplace(s, "`t", "\t")
        return """" . s . """"
    }
    if (Type(obj) = "Integer" || Type(obj) = "Float") {
        return obj
    }
    return "null"
}

Join(sep, arr) {
    out := ""
    for i, v in arr {
        if (i > 1)
            out .= sep
        out .= v
    }
    return out
}

JSON_Parse(text) {            }
            
            return obj
        } catch as e {
            MsgBox("Error parsing JSON: " . e.Message)
            return {}
        }
    }
    
    static stringify(obj, space := "") {
        if (!IsObject(obj)) {
            return obj = "" ? '""' : obj
        }
        
        result := "{"
        first := true
        
        ; Simple stringifier for Maps
        for key, value in obj {
            if (!first) {
                result .= ","
            }
            result .= "`"" key "`": " (IsNumber(value) ? value : "`"" value "`"")
            first := false
        }
        
        result .= "}"
        return result
    }
    
    static _escapeString(str) {
        ; Handle empty string
        if (str = "") {
            return ""
        }
        
        ; Simple escaping for quotes and backslashes
        str := StrReplace(str, "\", "\\")
        str := StrReplace(str, '"', '\"')
        str := StrReplace(str, "`n", "\n")
        str := StrReplace(str, "`r", "\r")
        str := StrReplace(str, "`t", "\t")
        
        return str
    }
}

JSON_Stringify(obj, indent := "") {
    if (Type(obj) = "Map") {
        items := []
        for k, v in obj {
            items.Push(indent . "  """ . k . """: " . JSON_Stringify(v, indent . "  "))
        }
        return "{`n" . Join(",`n", items) . "`n" . indent . "}"
    }
    if (Type(obj) = "String") {
        s := StrReplace(obj, "\", "\\")
        s := StrReplace(StrReplace(s, """", "\"""), "`n", "\n")
        return """" . s . """"
    }
    if (Type(obj) = "Integer" || Type(obj) = "Float")
        return obj
    return "null"
}

JSON_Parse(text) {
    text := Trim(text)
    if (SubStr(text, 1, 1) = "{")
        return JSON_ParseMap(text, 2)
    if (SubStr(text, 1, 1) = "[")
        return JSON_ParseArr(text, 2)
    return text
}

JSON_EatWS(text, pos) {
    while (pos <= StrLen(text)) {
        c := SubStr(text, pos, 1)
        if (c = " " || c = "`t" || c = "`n" || c = "`r")
            pos++
        else
            break
    }
    return pos
}

JSON_ParseMap(text, pos) {
    m := Map()
    pos := JSON_EatWS(text, pos)
    while (pos <= StrLen(text)) {
        c := SubStr(text, pos, 1)
        if (c = "}") { return m }
        if (c = ",") { pos := JSON_EatWS(text, pos + 1); continue }
        kr := JSON_ParseStr(text, pos)
        k := kr.val
        pos := JSON_EatWS(text, kr.pos)
        if (SubStr(text, pos, 1) = ":") { pos := JSON_EatWS(text, pos + 1) }
        vr := JSON_ParseVal(text, pos)
        m[k] := vr.val
        pos := JSON_EatWS(text, vr.pos)
    }
    return m
}

JSON_ParseArr(text, pos) {
    arr := []
    pos := JSON_EatWS(text, pos)
    while (pos <= StrLen(text)) {
        c := SubStr(text, pos, 1)
        if (c = "]") { return arr }
        if (c = ",") { pos := JSON_EatWS(text, pos + 1); continue }
        vr := JSON_ParseVal(text, pos)
        arr.Push(vr.val)
        pos := JSON_EatWS(text, vr.pos)
    }
    return arr
}

JSON_ParseVal(text, pos) {
    pos := JSON_EatWS(text, pos)
    c := SubStr(text, pos, 1)
    if (c = """") { return JSON_ParseStr(text, pos) }
    if (c = "{") { r := JSON_ParseMap(text, pos + 1); return {val: r, pos: pos + 2} }
    if (c = "t") { return {val: true, pos: pos + 4} }
    if (c = "f") { return {val: false, pos: pos + 5} }
    if (c = "n") { return {val: "", pos: pos + 4} }
    end := pos
    while (end <= StrLen(text)) {
        d := SubStr(text, end, 1)
        if ((d >= "0" && d <= "9") || d = "-" || d = "+" || d = "." || d = "e" || d = "E")
            end++
        else
            break
    }
    n := SubStr(text, pos, end - pos)
    if (InStr(n, "."))
        return {val: Float(n), pos: end}
    return {val: Integer(n), pos: end}
}

JSON_ParseStr(text, pos) {
    pos++
    out := ""
    while (pos <= StrLen(text)) {
        c := SubStr(text, pos, 1)
        if (c = """") { return {val: out, pos: pos + 1} }
        if (c = "\") {
            pos++
            e := SubStr(text, pos, 1)
            if (e = "n")      out .= "`n"
            else if (e = "t") out .= "`t"
            else if (e = "\") out .= "\"
            else if (e = """") out .= """"
            else              out .= e
            pos++
            continue
        }
        out .= c
        pos++
    }
    return {val: out, pos: pos}
}

Join(sep, parts) {
    s := ""
    for i, v in parts {
        if (i > 1)
            s .= sep
        s .= v
    }
    return s
}
