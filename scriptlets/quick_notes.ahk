#Requires AutoHotkey v2.0
#SingleInstance Force
#Warn

; =============================================================================
; CONFIGURATION
; =============================================================================
; File settings
global notesFile := A_MyDocuments "\QuickNotes.md"  ; Using markdown format
global backupDir := A_MyDocuments "\QuickNotes_Backups"

; UI Settings
global appTitle := "Quick Notes"
global appVersion := "2.0"
global fontName := "Segoe UI"
global fontSize := 11

; Color scheme (dark theme)
global colors := Map(
    "bg", "0x1E1E1E",
    "bg2", "0x252526",
    "text", "0xE0E0E0",
    "accent", "0x4EC9B0",
    "button", "0x3C3C3C",
    "buttonHover", "0x4F4F4F",
    "buttonText", "0xFFFFFF",
    "editBg", "0x252526",
    "editText", "0xE0E0E0"
)

; Global variables
global guiMain
global editNotes
global statusBar
global currentFile := ""

; =============================================================================
; MAIN SCRIPT
; =============================================================================
; Set working directory
SetWorkingDir A_ScriptDir

; Create backup directory if it doesn't exist
if !DirExist(backupDir) {
    try {
        DirCreate(backupDir)
    } catch as err {
        MsgBox("Failed to create backup directory: " . err.Message . "`n`n" . err.Stack)
    }
}

; Create the GUI
CreateGUI()

; Set up auto-save timer (every 30 seconds)
SetTimer(AutoSave, 30000)

; Global hotkey to show/hide the window
Hotkey("^!n", ToggleWindow)

; =============================================================================
; GUI CREATION
; =============================================================================
CreateGUI() {
    global guiMain, editNotes, statusBar, currentFile, appTitle, appVersion, fontSize, fontName, colors
    
    ; Create main window
    guiMain := Gui("+Resize +MinSize400x300", appTitle " v" appVersion)
    guiMain.BackColor := colors["bg"]
    guiMain.MarginX := 10
    guiMain.MarginY := 10
    
    ; Set font
    guiMain.SetFont("s" fontSize " c" StrReplace(colors["text"], "0x", ""), fontName)
    
    ; Toolbar background
    toolbar := guiMain.Add("Text", "x0 y0 w800 h40 Background" StrReplace(colors["bg2"], "0x", ""))
    
    ; Buttons
    btnSave := CreateButton(guiMain, "&Save", "x10 y5 w80 h30", "Save (Ctrl+S)")
    btnSave.OnEvent("Click", SaveNotes)
    
    btnNew := CreateButton(guiMain, "&New", "x95 y5 w70 h30", "New Note (Ctrl+N)")
    btnNew.OnEvent("Click", NewNote)
    
    btnFormat := CreateButton(guiMain, "&Format", "x170 y5 w80 h30", "Format Text (F2)")
    btnFormat.OnEvent("Click", FormatText)
    
    btnSettings := CreateButton(guiMain, "&Settings", "x255 y5 w80 h30", "Settings")
    btnSettings.OnEvent("Click", ShowSettings)
    
    ; Notes edit control
    editNotes := guiMain.Add("Edit", 
        "x10 y50 w780 h480 +Multi +VScroll +HScroll -Wrap " 
        "Background" StrReplace(colors["editBg"], "0x", "") 
        " c" StrReplace(colors["editText"], "0x", ""))
    
    ; Status bar
    statusBar := guiMain.Add("StatusBar", , "Ready")
    
    ; Set up events
    guiMain.OnEvent("Close", (*) => ExitApp())
    guiMain.OnEvent("Escape", (*) => guiMain.Hide())
    guiMain.OnEvent("Size", GuiSize)
    
    ; Set up keyboard shortcuts
    SetupHotkeys()
    
    ; Load last saved notes
    LoadNotes()
    
    ; Show the window
    guiMain.Show("w800 h600")
}

SetupHotkeys() {
    ; Window-specific hotkeys
    HotIf WinActive(appTitle)
    Hotkey "^s", SaveNotes
    Hotkey "^n", NewNote  
    Hotkey "F2", FormatText
    HotIf ; Reset context
}

; =============================================================================
; NOTE MANAGEMENT FUNCTIONS
; =============================================================================
LoadNotes() {
    global notesFile, editNotes, statusBar, currentFile
    
    try {
        if FileExist(notesFile) {
            fileContent := notesFile := FileRead("UTF-8")
            editNotes.Value := fileContent
            statusBar.Text := "Loaded notes from " notesFile
            currentFile := notesFile
        } else {
            ; Create a new file with a template
            FormatTime(currentDate, , "yyyy-MM-dd")
            template := "# Quick Notes`n`n"
                      . "## " currentDate "`n"
                      . "- [ ] Task 1`n- [ ] Task 2`n`n"
                      . "## Ideas`n- First idea`n- Second idea"
            
            editNotes.Value := template
            currentFile := ""
            statusBar.Text := "Created new notes"
        }
    } catch as err {
        MsgBox("Failed to load notes: " . err.Message . "`n`n" . err.Stack, "Error", "Iconx")
        statusBar.Text := "Error loading notes"
    }
}

SaveNotes(*) {
    global notesFile, editNotes, statusBar, backupDir
    
    try {
        ; Create backup if file exists
        if FileExist(notesFile) {
            ; Create backup directory if it doesn't exist
            if !DirExist(backupDir) {
                DirCreate(backupDir)
            }
            
            ; Create timestamped backup
            FormatTime(timestamp, , "yyyyMMdd_HHmmss")
            backupFile := backupDir "\notes_backup_" timestamp ".md"
            FileCopy(notesFile, backupFile, 1)
        }
        
        ; Save current content
        if FileExist(notesFile) {
            try FileDelete(notesFile)
        }
        FileAppend(editNotes.Value, notesFile, "UTF-8")
        
        ; Update status
        FormatTime(timeNow, , "HH:mm:ss")
        statusBar.Text := "Saved at " timeNow
        
        ; Show notification
        TrayTip("Notes saved successfully!", "Quick Notes", "Iconi")
        SetTimer(() => TrayTip(), -2000)
        
        return true
    } catch as saveErr {
        MsgBox("Failed to save notes: " . saveErr.Message . "`n`n" . saveErr.Stack, "Error", "Iconx")
        statusBar.Text := "Error saving notes"
        return false
    }
}

AutoSave(*) {
    global editNotes, statusBar
    
    if (editNotes.Value != "") {
        if SaveNotes() {
            FormatTime(timeNow, , "HH:mm:ss")
            statusBar.Text := "Auto-saved at " timeNow
        }
    }
}

NewNote(*) {
    global editNotes, statusBar, currentFile
    
    if (editNotes.Value != "") {
        result := MsgBox("Save current note?", "New Note", "YesNoCancel Icon?")
        if (result = "Yes") {
            if !SaveNotes() {
                return  ; Don't create new note if save failed
            }
        } else if (result = "Cancel") {
            return  ; User cancelled
        }
    }
    
    ; Create a new note with template
    FormatTime(currentDate, , "yyyy-MM-dd")
    FormatTime(currentTime, , "HH:mm")
    template := "# New Note - " currentDate "`n`n"
              . "## " currentTime "`n"
              . "- [ ] Task 1`n- [ ] Task 2`n`n"
              . "## Notes`n"
    
    editNotes.Value := template
    currentFile := ""
    statusBar.Text := "Created new note"
    editNotes.Focus()
}

FormatText(*) {
    global editNotes
    
    try {
        ; Get selected text using ControlGetSelected (v2 method)
        selectedText := ""
        try {
            selectedText := ControlGetSelected(editNotes)
        } catch {
            ; Fallback if no selection
            selectedText := ""
        }
        
        if (selectedText != "") {
            ; Apply formatting based on content
            newText := selectedText
            
            if (InStr(selectedText, "- [ ]") = 1) {
                ; Toggle checkbox to checked
                newText := StrReplace(selectedText, "- [ ]", "- [x]", , 1)
            } else if (InStr(selectedText, "- [x]") = 1) {
                ; Toggle checkbox to unchecked  
                newText := StrReplace(selectedText, "- [x]", "- [ ]", , 1)
            } else if (InStr(selectedText, "###") = 1) {
                ; Reduce heading level
                newText := StrReplace(selectedText, "###", "##", , 1)
            } else if (InStr(selectedText, "##") = 1) {
                ; Reduce heading level
                newText := StrReplace(selectedText, "##", "#", , 1)
            } else if (InStr(selectedText, "#") = 1) {
                ; Remove heading
                newText := StrReplace(selectedText, "#", "", , 1)
                newText := LTrim(newText)
            } else {
                ; Make it a heading
                newText := "# " selectedText
            }
            
            ; Replace selected text
            ControlSetText(newText, editNotes)
        } else {
            ; No selection, insert current date/time
            FormatTime(currentDateTime, , "yyyy-MM-dd HH:mm:ss")
            ControlSend(editNotes, "{Text}" currentDateTime)
        }
    } catch as formatErr {
        MsgBox("Formatting error: " . formatErr.Message, "Error", "Iconx")
    }
}

ShowSettings(*) {
    global appTitle, fontSize, fontName, colors
    
    ; Create settings GUI
    settingsGui := Gui("+ToolWindow", "Settings - " appTitle)
    settingsGui.BackColor := colors["bg"]
    settingsGui.SetFont("s10 c" StrReplace(colors["text"], "0x", ""), fontName)
    
    ; Font settings
    settingsGui.Add("Text", "x10 y10", "Font Size:")
    fontSizeEdit := settingsGui.Add("Edit", "x80 y8 w50", fontSize)
    settingsGui.Add("UpDown", "Range8-24", fontSize)
    
    settingsGui.Add("Text", "x150 y10", "Font:")
    fontDropdown := settingsGui.Add("DropDownList", "x190 y8 w120 Choose1", ["Segoe UI", "Consolas", "Arial", "Courier New"])
    
    ; Theme selection
    settingsGui.Add("Text", "x10 y40", "Theme:")
    themeDropdown := settingsGui.Add("DropDownList", "x80 y38 w100 Choose1", ["Dark", "Light"])
    
    ; OK and Cancel buttons
    okBtn := settingsGui.Add("Button", "x10 y70 w80 h30", "&OK")
    cancelBtn := settingsGui.Add("Button", "x100 y70 w80 h30", "&Cancel")
    
    okBtn.OnEvent("Click", (*) => (
        fontSize := fontSizeEdit.Value,
        fontName := fontDropdown.Text,
        settingsGui.Close()
    ))
    
    cancelBtn.OnEvent("Click", (*) => settingsGui.Close())
    
    settingsGui.Show("w320 h110")
}

; =============================================================================
; HELPER FUNCTIONS
; =============================================================================
CreateButton(guiObj, text, options, tooltip := "") {
    global colors
    
    btn := guiObj.Add("Button", options 
        " Background" StrReplace(colors["button"], "0x", "") 
        " c" StrReplace(colors["buttonText"], "0x", ""))
    btn.Text := text
    
    if (tooltip != "") {
        btn.ToolTip := tooltip
    }
    
    return btn
}

ToggleWindow(*) {
    global appTitle, guiMain
    
    try {
        if WinExist(appTitle) {
            if WinActive(appTitle) {
                guiMain.Hide()
            } else {
                guiMain.Show()
                guiMain.Focus()
            }
        } else {
            CreateGUI()
        }
    } catch as toggleErr {
        ; If window doesn't exist, create it
        CreateGUI()
    }
}

; Handle window resizing
GuiSize(thisGui, MinMax, Width, Height) {
    global editNotes, statusBar
    
    if (MinMax = -1)  ; Window is minimized
        return
    
    ; Calculate new dimensions
    editHeight := Height - 100  ; Account for toolbar and status bar
    editWidth := Width - 20     ; Account for margins
    
    try {
        ; Update edit control size
        editNotes.Move(10, 50, editWidth, editHeight)
        
        ; Update toolbar width if needed
        ; (Status bar resizes automatically)
    } catch as resizeErr {
        ; Ignore errors during window creation
        OutputDebug("Resize error: " resizeErr.Message "`n")
    }
}

; Clean up on exit
OnExit(ExitFunc)
ExitFunc(ExitReason, ExitCode) {
    ; Auto-save on exit if there are unsaved changes
    global editNotes
    try {
        if (editNotes.Value != "") {
            SaveNotes()
        }
    } catch {
        ; Ignore errors during exit
    }
    return 0
}

; =============================================================================
; ADDITIONAL FEATURES
; =============================================================================

; Search function
SearchNotes() {
    global editNotes
    
    searchTerm := InputBox("Enter search term:", "Search Notes").Value
    if (searchTerm = "") {
        return
    }
    
    content := editNotes.Value
    pos := InStr(content, searchTerm, 1)
    
    if (pos > 0) {
        ; Select the found text
        editNotes.Focus()
        ; Move cursor and select text (simplified)
        SendMessage(0x00B1, pos-1, pos-1+StrLen(searchTerm), editNotes)  ; EM_SETSEL
    } else {
        MsgBox("Text not found: " searchTerm, "Search Result", "Iconi")
    }
}

; Word count function
GetWordCount() {
    global editNotes
    
    text := editNotes.Value
    if (text = "") {
        return {chars: 0, words: 0, lines: 0}
    }
    
    chars := StrLen(text)
    lines := StrSplit(text, "`n").Length
    
    ; Count words (split by spaces and filter empty)
    words := 0
    wordArray := StrSplit(RegExReplace(text, "\s+", " "), " ")
    for word in wordArray {
        if (Trim(word) != "") {
            words++
        }
    }
    
    return {chars: chars, words: words, lines: lines}
}

; Export to different formats
ExportNotes(format := "txt") {
    global editNotes, notesFile
    
    if (editNotes.Value = "") {
        MsgBox("No content to export!", "Export", "Iconx")
        return
    }
    
    ; Get export filename
    SplitPath(notesFile, , &dir, &name)
    exportFile := dir "\" name "." format
    
    try {
        switch format {
            case "txt":
                ; Plain text export
                try FileDelete(exportFile)
                FileAppend(editNotes.Value, exportFile, "UTF-8")
            case "html":
                ; Simple HTML export (basic markdown conversion)
                html := ConvertMarkdownToHtml(editNotes.Value)
                try FileDelete(exportFile) 
                FileAppend(html, exportFile, "UTF-8")
        }
        
        MsgBox("Exported to: " exportFile, "Export Complete", "Iconi")
    } catch as exportErr {
        MsgBox("Export failed: " exportErr.Message, "Export Error", "Iconx")
    }
}

; Basic markdown to HTML conversion
ConvertMarkdownToHtml(markdown) {
    html := "<html><head><title>Quick Notes Export</title></head><body>"
    
    lines := StrSplit(markdown, "`n")
    for line in lines {
        line := Trim(line)
        if (line = "") {
            html .= "<br>"
        } else if (InStr(line, "###") = 1) {
            html .= "<h3>" SubStr(line, 5) "</h3>"
        } else if (InStr(line, "##") = 1) {
            html .= "<h2>" SubStr(line, 4) "</h2>"
        } else if (InStr(line, "#") = 1) {
            html .= "<h1>" SubStr(line, 3) "</h1>"
        } else if (InStr(line, "- [ ]") = 1) {
            html .= "<p>â˜ " SubStr(line, 7) "</p>"
        } else if (InStr(line, "- [x]") = 1) {
            html .= "<p>â˜‘ " SubStr(line, 7) "</p>"
        } else if (InStr(line, "- ") = 1) {
            html .= "<li>" SubStr(line, 3) "</li>"
        } else {
            html .= "<p>" line "</p>"
        }
    }
    
    html .= "</body></html>"
    return html
}

                ; Toggle checkbox to unchecked  

                newText := StrReplace(selectedText, "- [x]", "- [ ]", , 1)

            } else if (InStr(selectedText, "###") = 1) {

                ; Reduce heading level

                newText := StrReplace(selectedText, "###", "##", , 1)

            } else if (InStr(selectedText, "##") = 1) {

                ; Reduce heading level

                newText := StrReplace(selectedText, "##", "#", , 1)

            } else if (InStr(selectedText, "#") = 1) {

                ; Remove heading

                newText := StrReplace(selectedText, "#", "", , 1)

                newText := LTrim(newText)

            } else {

                ; Make it a heading

                newText := "# " selectedText

            }

            

            ; Replace selected text

            ControlSetText(newText, editNotes)

        } else {

            ; No selection, insert current date/time

            FormatTime currentDateTime, , "yyyy-MM-dd HH:mm:ss"

            ControlSend(editNotes, "{Text}" currentDateTime)

        }

    } catch as formatErr {

        MsgBox("Formatting error: " . formatErr.Message, "Error", "Iconx")

    }

}



ShowSettings(*) {

    global appTitle, fontSize, fontName, colors

    

    ; Create settings GUI

    settingsGui := Gui("+ToolWindow", "Settings - " appTitle)

    settingsGui.BackColor := colors["bg"]

    settingsGui.SetFont("s10 c" StrReplace(colors["text"], "0x", ""), fontName)

    

    ; Font settings

    settingsGui.Add("Text", "x10 y10", "Font Size:")

    fontSizeEdit := settingsGui.Add("Edit", "x80 y8 w50", fontSize)

    settingsGui.Add("UpDown", "Range8-24", fontSize)

    

    settingsGui.Add("Text", "x150 y10", "Font:")

    fontDropdown := settingsGui.Add("DropDownList", "x190 y8 w120 Choose1", ["Segoe UI", "Consolas", "Arial", "Courier New"])

    

    ; Theme selection

    settingsGui.Add("Text", "x10 y40", "Theme:")

    themeDropdown := settingsGui.Add("DropDownList", "x80 y38 w100 Choose1", ["Dark", "Light"])

    

    ; OK and Cancel buttons

    okBtn := settingsGui.Add("Button", "x10 y70 w80 h30", "&OK")

    cancelBtn := settingsGui.Add("Button", "x100 y70 w80 h30", "&Cancel")

    

    okBtn.OnEvent("Click", (*) => (

        fontSize := fontSizeEdit.Value,

        fontName := fontDropdown.Text,

        settingsGui.Close()

    ))

    

    cancelBtn.OnEvent("Click", (*) => settingsGui.Close())

    

    settingsGui.Show("w320 h110")

}



; =============================================================================

; HELPER FUNCTIONS

; =============================================================================

CreateButton(guiObj, text, options, tooltip := "") {

    global colors

    

    btn := guiObj.Add("Button", options 

        " Background" StrReplace(colors["button"], "0x", "") 

        " c" StrReplace(colors["buttonText"], "0x", ""))

    btn.Text := text

    

    if (tooltip != "") {

        btn.ToolTip := tooltip

    }

    

    return btn

}



ToggleWindow(*) {

    global appTitle, guiMain

    

    try {

        if WinExist(appTitle) {

            if WinActive(appTitle) {

                guiMain.Hide()

            } else {

                guiMain.Show()

                guiMain.Focus()

            }

        } else {

            CreateGUI()

        }

    } catch as toggleErr {

        ; If window doesn't exist, create it

        CreateGUI()

    }

}



; Handle window resizing

GuiSize(thisGui, MinMax, Width, Height) {

    global editNotes, statusBar

    

    if (MinMax = -1)  ; Window is minimized

        return

    

    ; Calculate new dimensions

    editHeight := Height - 100  ; Account for toolbar and status bar

    editWidth := Width - 20     ; Account for margins

    

    try {

        ; Update edit control size

        editNotes.Move(10, 50, editWidth, editHeight)

        

        ; Update toolbar width if needed

        ; (Status bar resizes automatically)

    } catch as resizeErr {

        ; Ignore errors during window creation

        OutputDebug("Resize error: " resizeErr.Message "`n")

    }

}



; Clean up on exit

OnExit(ExitFunc)

ExitFunc(ExitReason, ExitCode) {

    ; Auto-save on exit if there are unsaved changes

    global editNotes

    try {

        if (editNotes.Value != "") {

            SaveNotes()

        }

    } catch {

        ; Ignore errors during exit

    }

    return 0

}



; =============================================================================

; ADDITIONAL FEATURES

; =============================================================================



; Search function

SearchNotes() {

    global editNotes

    

    searchTerm := InputBox("Enter search term:", "Search Notes").Value

    if (searchTerm = "") {

        return

    }

    

    content := editNotes.Value

    pos := InStr(content, searchTerm, 1)

    

    if (pos > 0) {

        ; Select the found text

        editNotes.Focus()

        ; Move cursor and select text (simplified)

        SendMessage(0x00B1, pos-1, pos-1+StrLen(searchTerm), editNotes)  ; EM_SETSEL

    } else {

        MsgBox("Text not found: " searchTerm, "Search Result", "Iconi")

    }

}



; Word count function

GetWordCount() {

    global editNotes

    

    text := editNotes.Value

    if (text = "") {

        return {chars: 0, words: 0, lines: 0}

    }

    

    chars := StrLen(text)

    lines := StrSplit(text, "`n").Length

    

    ; Count words (split by spaces and filter empty)

    words := 0

    wordArray := StrSplit(RegExReplace(text, "\s+", " "), " ")

    for word in wordArray {

        if (Trim(word) != "") {

            words++

        }

    }

    

    return {chars: chars, words: words, lines: lines}

}



; Export to different formats

ExportNotes(format := "txt") {

    global editNotes, notesFile

    

    if (editNotes.Value = "") {

        MsgBox("No content to export!", "Export", "Iconx")

        return

    }

    

    ; Get export filename

    SplitPath(notesFile, , &dir, &name)

    exportFile := dir "\" name "." format

    

    try {

        switch format {

            case "txt":

                ; Plain text export

                try FileDelete(exportFile)

                FileAppend(editNotes.Value, exportFile, "UTF-8")

            case "html":

                ; Simple HTML export (basic markdown conversion)

                html := ConvertMarkdownToHtml(editNotes.Value)

                try FileDelete(exportFile) 

                FileAppend(html, exportFile, "UTF-8")

        }

        

        MsgBox("Exported to: " exportFile, "Export Complete", "Iconi")

    } catch as exportErr {

        MsgBox("Export failed: " exportErr.Message, "Export Error", "Iconx")

    }

}



; Basic markdown to HTML conversion

ConvertMarkdownToHtml(markdown) {

    html := "<html><head><title>Quick Notes Export</title></head><body>"

    

    lines := StrSplit(markdown, "`n")

    for line in lines {

        line := Trim(line)

        if (line = "") {

            html .= "<br>"

        } else if (InStr(line, "###") = 1) {

            html .= "<h3>" SubStr(line, 5) "</h3>"

        } else if (InStr(line, "##") = 1) {

            html .= "<h2>" SubStr(line, 4) "</h2>"

        } else if (InStr(line, "#") = 1) {

            html .= "<h1>" SubStr(line, 3) "</h1>"

        } else if (InStr(line, "- [ ]") = 1) {

            html .= "<p>â˜ " SubStr(line, 7) "</p>"

        } else if (InStr(line, "- [x]") = 1) {

            html .= "<p>â˜‘ " SubStr(line, 7) "</p>"

        } else if (InStr(line, "- ") = 1) {

            html .= "<li>" SubStr(line, 3) "</li>"

        } else {

            html .= "<p>" line "</p>"

        }

    }

    

    html .= "</body></html>"

    return html

}



