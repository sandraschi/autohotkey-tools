#Requires AutoHotkey v2.0
#SingleInstance Force


; Suppress error popups - log to file instead
OnError("LogError")

LogError(Exception, Mode) {
    FileAppend("Error: " . Exception.Message . " at line " . Exception.Line . "
", "errors.log", "UTF-8")
    return true  ; Suppress popup
}

#Warn

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
SetWorkingDir A_ScriptDir
Hotkey HOTKEY_SHOW_MENU, ShowSnippetsMenu
TrayTip "Text Expander", "Press " HOTKEY_SHOW_MENU " to show snippets", "Iconi"
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
        snippet := StrReplace(snippet, "{date}", FormatTime(, "yyyy-MM-dd"))
        snippet := StrReplace(snippet, "{time}", FormatTime(, "HH:mm:ss"))
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
        TrayTip "Snippet saved", "Trigger: " key, "Iconi"
        SetTimer () => TrayTip(), 3000
        
    } catch as e {
        MsgBox("Error saving snippet: " . e.Message, "Text Expander", "Iconx")
    }
}

; Save snippets to file
SaveSnippets(snippets) {
    try {
        json := JSON.stringify(snippets, 4)  ; Pretty-print with 4-space indentation
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
        obj := JSON.parse(json)
        if (!IsObject(obj)) {
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
                        key := Trim(pair[1], " `t\"")
                        value := Trim(pair[2], " `t\"")
                        obj[key] := value
                    }
                }
            }
            
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
        str := StrReplace(str, "\", "\\\\")
        str := StrReplace(str, "`"", "\\\"")
        str := StrReplace(str, "`n", "\\n")
        str := StrReplace(str, "`r", "\\r")
        str := StrReplace(str, "`t", "\\t")
        
        return str
    }
}
        
        ; First escape backslashes
        str := StrReplace(str, "\\", "\\\\")
        ; Then escape double quotes
        str := StrReplace(str, "`"", "\\`"")
        ; Handle special characters
        str := StrReplace(str, "`n", "\\n")
        str := StrReplace(str, "`r", "\\r")
        str := StrReplace(str, "`t", "\\t")
        return str
    }
}

