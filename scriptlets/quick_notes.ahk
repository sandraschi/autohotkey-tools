#Requires AutoHotkey v2.0
#SingleInstance Force
#Warn

; =============================================================================
; CONFIGURATION
; =============================================================================
; File settings
global notesFile := A_MyDocuments "\QuickNotes.md"  ; Using markdown format
global backupDir := A_MyDocuments "\QuickNotes_Backups"

; App settings
global appTitle := "Quick Notes"
global appVersion := "2.0"
global fontSize := 11
global fontName := "Segoe UI"

; Color scheme (dark theme)
global colors := Map(
    "bg", "0x1e1e1e",
    "text", "0xd4d4d4",
    "button", "0x0078d4",
    "buttonText", "0xffffff"
)

; =============================================================================
; INITIALIZATION
; =============================================================================
; Create backup directory if it doesn't exist
if (!DirExist(backupDir)) {
    DirCreate(backupDir)
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
    guiMain.SetFont("s" fontSize " c" StrReplace(colors["text"], "0x", ""), fontName)
    guiMain.MarginX := 10
    guiMain.MarginY := 10
    
    ; Menu bar
    menuBar := Menu()
    menuBar.Add("&File", ["&New", "&Open", "&Save", "Save &As", "", "E&xit"])
    menuBar.Add("&Edit", ["&Undo", "&Redo", "", "Cu&t", "&Copy", "&Paste", "", "&Find"])
    menuBar.Add("&Format", ["&Bold", "&Italic", "", "&Heading", "&List", "&Checkbox"])
    menuBar.Add("&Tools", ["&Word Count", "&Export", "&Settings"])
    menuBar.Add("&Help", "&About")
    guiMain.MenuBar := menuBar
    
    ; Toolbar
    toolbar := guiMain.Add("Text", "x10 y10 w780 h30 Background" StrReplace(colors["button"], "0x", ""))
    
    ; Main edit control
    editNotes := guiMain.Add("Edit", "x10 y50 w780 h500 Multi VScroll WantTab", "")
    editNotes.BackColor := colors["bg"]
    editNotes.SetFont("s" fontSize, fontName)
    
    ; Status bar
    statusBar := guiMain.Add("StatusBar",, "Ready | Lines: 0 | Words: 0")
    
    ; Event handlers
    guiMain.OnEvent("Close", (*) => ExitApp())
    guiMain.OnEvent("Size", GuiSize)
    
    ; Menu event handlers
    menuBar["File"]["New"].OnEvent("Click", NewNotes)
    menuBar["File"]["Open"].OnEvent("Click", OpenNotes)
    menuBar["File"]["Save"].OnEvent("Click", SaveNotes)
    menuBar["File"]["Save As"].OnEvent("Click", SaveNotesAs)
    menuBar["File"]["Exit"].OnEvent("Click", (*) => ExitApp())
    
    menuBar["Edit"]["Undo"].OnEvent("Click", (*) => Send("^z"))
    menuBar["Edit"]["Redo"].OnEvent("Click", (*) => Send("^y"))
    menuBar["Edit"]["Cut"].OnEvent("Click", (*) => Send("^x"))
    menuBar["Edit"]["Copy"].OnEvent("Click", (*) => Send("^c"))
    menuBar["Edit"]["Paste"].OnEvent("Click", (*) => Send("^v"))
    menuBar["Edit"]["Find"].OnEvent("Click", SearchNotes)
    
    menuBar["Format"]["Bold"].OnEvent("Click", (*) => FormatText())
    menuBar["Format"]["Heading"].OnEvent("Click", (*) => FormatText())
    menuBar["Format"]["List"].OnEvent("Click", (*) => FormatText())
    menuBar["Format"]["Checkbox"].OnEvent("Click", (*) => FormatText())
    
    menuBar["Tools"]["Word Count"].OnEvent("Click", ShowWordCount)
    menuBar["Tools"]["Export"].OnEvent("Click", (*) => ExportNotes("html"))
    menuBar["Tools"]["Settings"].OnEvent("Click", ShowSettings)
    
    menuBar["Help"]["About"].OnEvent("Click", ShowAbout)
    
    ; Load existing notes
    LoadNotes()
    
    ; Show window
    guiMain.Show("w800 h600")
    editNotes.Focus()
}

FormatText(*) {
    global editNotes
    
    try {
        ; Get selected text using v2 method
        selectedText := ""
        try {
            ; Get selection range using EM_GETSEL
            ; Returns: low word = start, high word = end
            selResult := SendMessage(0x00B0, 0, 0, editNotes)
            selStartPos := selResult & 0xFFFF
            selEndPos := (selResult >> 16) & 0xFFFF
            
            ; Get selected text if there's a selection
            if (selStartPos != selEndPos) {
                fullText := editNotes.Value
                selectedText := SubStr(fullText, selStartPos + 1, selEndPos - selStartPos)
            }
        } catch {
            ; Fallback if no selection
            selectedText := ""
        }
        
        if (selectedText != "") {
            ; Apply formatting based on content
            newText := selectedText
            
            if (InStr(selectedText, "- [ ]") = 1) {
                ; Toggle checkbox to checked
                newText := "- [x]" . SubStr(selectedText, 7)
            } else if (InStr(selectedText, "- [x]") = 1) {
                ; Toggle checkbox to unchecked
                newText := "- [ ]" . SubStr(selectedText, 7)
            } else if (InStr(selectedText, "###") = 1) {
                ; Reduce heading level
                newText := "##" . SubStr(selectedText, 4)
            } else if (InStr(selectedText, "##") = 1) {
                ; Reduce heading level
                newText := "#" . SubStr(selectedText, 3)
            } else if (InStr(selectedText, "#") = 1) {
                ; Remove heading
                newText := LTrim(SubStr(selectedText, 2))
            } else {
                ; Make it a heading
                newText := "# " . selectedText
            }
            
            ; Replace selected text
            ControlSetText(newText, editNotes)
        } else {
            ; No selection, insert current date/time
            currentDateTime := FormatTime(A_Now, "yyyy-MM-dd HH:mm:ss")
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
                try {
                    try FileDelete(exportFile)
                    FileAppend(editNotes.Value, exportFile, "UTF-8")
                } catch as e {
                    throw Error("Failed to export text file: " . e.Message)
                }
            case "html":
                ; Simple HTML export (basic markdown conversion)
                html := ConvertMarkdownToHtml(editNotes.Value)
                try {
                    try FileDelete(exportFile)
                    FileAppend(html, exportFile, "UTF-8")
                } catch as e {
                    throw Error("Failed to export HTML file: " . e.Message)
                }
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
            html .= "<p>☐ " SubStr(line, 7) "</p>"
        } else if (InStr(line, "- [x]") = 1) {
            html .= "<p>☑ " SubStr(line, 7) "</p>"
        } else if (InStr(line, "- ") = 1) {
            html .= "<li>" SubStr(line, 3) "</li>"
        } else {
            html .= "<p>" line "</p>"
        }
    }
    
    html .= "</body></html>"
    return html
}

; =============================================================================
; FILE OPERATIONS
; =============================================================================
LoadNotes() {
    global notesFile, editNotes, statusBar, currentFile
    
    try {
        if (FileExist(notesFile)) {
            fileContent := FileRead(notesFile, "UTF-8")
            editNotes.Value := fileContent
            statusBar.Text := "Loaded notes from " . notesFile
            currentFile := notesFile
        } else {
            ; Create a new file with a template
            currentDate := FormatTime(A_Now, "yyyy-MM-dd")
            template := "# Quick Notes`n`n"
                      . "## " . currentDate . "`n"
                      . "- [ ] Task 1`n- [ ] Task 2`n`n"
                      . "## Ideas`n- First idea`n- Second idea"
            
            editNotes.Value := template
            currentFile := ""
            statusBar.Text := "Created new notes"
        }
    } catch as err {
        MsgBox("Failed to load notes: " . err.Message, "Error", "Iconx")
        statusBar.Text := "Error loading notes"
    }
}

SaveNotes(*) {
    global notesFile, editNotes, statusBar, backupDir, currentFile
    
    try {
        ; Create backup if file exists
        if (FileExist(notesFile)) {
            ; Create backup directory if it doesn't exist
            if (!DirExist(backupDir)) {
                DirCreate(backupDir)
            }
            
            ; Create timestamped backup
            timestamp := FormatTime(A_Now, "yyyyMMdd_HHmmss")
            backupFile := backupDir . "\notes_backup_" . timestamp . ".md"
            try {
                FileCopy(notesFile, backupFile, 1)
            } catch as e {
                ; Log backup failure but continue with save
                OutputDebug("Backup failed: " . e.Message)
            }
        }
        
        ; Save current content
        if (FileExist(notesFile)) {
            try FileDelete(notesFile)
        }
        FileAppend(editNotes.Value, notesFile, "UTF-8")
        
        ; Update status
        timeNow := FormatTime(A_Now, "HH:mm:ss")
        statusBar.Text := "Saved at " . timeNow
        currentFile := notesFile
        
        ; Show notification
        TrayTip("Notes saved successfully!", "Quick Notes", "Iconi")
        SetTimer(() => TrayTip(), -2000)
        
        return true
    } catch as saveErr {
        MsgBox("Failed to save notes: " . saveErr.Message, "Error", "Iconx")
        statusBar.Text := "Error saving notes"
        return false
    }
}

SaveNotesAs(*) {
    global editNotes, statusBar, currentFile
    
    try {
        filePath := FileSelect("S16", A_MyDocuments, "Save Notes As", "Markdown (*.md)")
        if (filePath = "") {
            return
        }
        
        ; Ensure .md extension
        if (!InStr(filePath, ".md")) {
            filePath .= ".md"
        }
        
        ; Save to new location
        if (FileExist(filePath)) {
            try FileDelete(filePath)
        }
        FileAppend(editNotes.Value, filePath, "UTF-8")
        
        currentFile := filePath
        timeNow := FormatTime(A_Now, "HH:mm:ss")
        statusBar.Text := "Saved as " . filePath . " at " . timeNow
        
        TrayTip("Notes saved successfully!", "Quick Notes", "Iconi")
        SetTimer(() => TrayTip(), -2000)
    } catch as saveErr {
        MsgBox("Failed to save notes: " . saveErr.Message, "Error", "Iconx")
    }
}

OpenNotes(*) {
    global editNotes, statusBar, currentFile
    
    try {
        filePath := FileSelect("1", A_MyDocuments, "Open Notes", "Markdown (*.md)")
        if (filePath = "") {
            return
        }
        
        fileContent := FileRead(filePath, "UTF-8")
        editNotes.Value := fileContent
        currentFile := filePath
        statusBar.Text := "Opened " . filePath
    } catch as openErr {
        MsgBox("Failed to open notes: " . openErr.Message, "Error", "Iconx")
    }
}

NewNotes(*) {
    global editNotes, statusBar, currentFile
    
    if (editNotes.Value != "") {
        result := MsgBox("Save current note?", "New Note", "YesNoCancel Icon?")
        if (result = "Yes") {
            if (!SaveNotes()) {
                return  ; Don't create new note if save failed
            }
        } else if (result = "Cancel") {
            return  ; User cancelled
        }
    }
    
    ; Create a new note with template
    currentDate := FormatTime(A_Now, "yyyy-MM-dd")
    currentTime := FormatTime(A_Now, "HH:mm")
    template := "# New Note - " . currentDate . "`n`n"
              . "## " . currentTime . "`n"
              . "- [ ] Task 1`n- [ ] Task 2`n`n"
              . "## Notes`n"
    
    editNotes.Value := template
    currentFile := ""
    statusBar.Text := "Created new note"
    editNotes.Focus()
}

AutoSave(*) {
    global editNotes, statusBar
    
    if (editNotes.Value != "") {
        if (SaveNotes()) {
            timeNow := FormatTime(A_Now, "HH:mm:ss")
            statusBar.Text := "Auto-saved at " . timeNow
        }
    }
}

ShowWordCount(*) {
    global editNotes
    
    stats := GetWordCount()
    msg := "Word Count`n`n"
          . "Characters: " . stats.chars . "`n"
          . "Words: " . stats.words . "`n"
          . "Lines: " . stats.lines
    
    MsgBox(msg, "Word Count", "Iconi")
}

ShowAbout(*) {
    global appTitle, appVersion
    
    aboutText := appTitle . " v" . appVersion . "`n`n"
              . "A quick note-taking application`n"
              . "with markdown support.`n`n"
              . "Press Ctrl+Alt+N to show/hide.`n`n"
              . "Created with AutoHotkey v2"
    
    MsgBox(aboutText, "About " . appTitle, "Iconi")
}
