#NoEnv
#SingleInstance Force
#Persistent
SetWorkingDir %A_ScriptDir%
SetBatchLines -1

; Configuration
notesFile := A_MyDocuments . "\QuickNotes.txt"
fontSize := 12
fontName := "Segoe UI"

; Create the GUI
Gui( +AlwaysOnTop +Resize
Gui( Font, s%fontSize%, %fontName%

; Title
Gui( Add, Text, x10 y10 w200 h20, Quick Notes

; Date/Time button
Gui( Add, Button, x220 y5 w80 h25 gInsertDateTime, &Now

; Notes edit control
Gui( Add, Edit, x10 y40 w380 h300 vNotesEdit +Multi +WantTab

; Buttons
Gui( Add, Button, x10 y350 w80 h30 gSaveNotes, &Save
Gui( Add, Button, x100 y350 w80 h30 gClearNotes, C&lear
Gui( Add, Button, x190 y350 w100 h30 gToggleAlwaysOnTop, &Always on Top
Gui( Add, Button, x300 y350 w90 h30 gExitApp, E&xit

; Status bar
Gui( Add, StatusBar,, Ready

; Load existing notes
LoadNotes()

; Show the GUI
Gui( Show, w400 h400, Quick Notes
return

; Hotkey to show/hide the notes window
^!N::  ; Ctrl+Alt+N
    if (WinExist("Quick Notes")) {
        if (WinActive("Quick Notes")) {
            WinHide, Quick Notes
        } else {
            WinShow, Quick Notes
            WinActivate, Quick Notes
        }
    }
return

LoadNotes() {
    global notesFile, NotesEdit
    
    if (FileExist(notesFile)) {
        FileRead, notes, %notesFile%
        GuiControl,, NotesEdit, %notes%
        SB_SetText("Notes loaded from " . notesFile)
    } else {
        GuiControl,, NotesEdit, 
        SB_SetText("New notes file will be created at " . notesFile)
    }
}

SaveNotes:
    Gui( Submit, NoHide
    
    ; Create backup of existing file if it exists
    if (FileExist(notesFile)) {
        FileCopy, %notesFile%, %notesFile%.bak, 1
    }
    
    ; Save to file
    FileDelete, %notesFile%
    FileAppend, %NotesEdit%, %notesFile%
    
    ; Show status
    FormatTime, timeNow,, HH:mm:ss
    SB_SetText("Notes saved at " . timeNow)
    
    ; Show notification
    TrayTip, Quick Notes, Notes saved successfully!, 2, 1
    SetTimer, HideTrayTip, 2000
return

ClearNotes:
    MsgBox( Clear Notes, Are you sure you want to clear all notes?
    IfMsgBox Yes
    {
        GuiControl,, NotesEdit, 
        SB_SetText("Notes cleared")
    }
return

InsertDateTime:
    FormatTime, currentDateTime,, yyyy-MM-dd HH:mm:ss
    SendInput, %currentDateTime%{Space}
    SB_SetText("Date/Time inserted")
return

ToggleAlwaysOnTop:
    WinGet, ExStyle, ExStyle, A
    if (ExStyle & 0x8) {  ; 0x8 is WS_EX_TOPMOST
        Winset, AlwaysOnTop, off, A
        SB_SetText("Always on Top: Off")
    } else {
        WinSet, AlwaysOnTop, on, A
        SB_SetText("Always on Top: On")
    }
return

HideTrayTip:
    SetTimer, HideTrayTip, Off
    TrayTip
return

GuiSize:
    if (A_EventInfo = 1)  ; The window has been minimized
        return
    
    ; Resize the edit control to fill the window
    GuiControl, Move, NotesEdit, % "w" . (A_GuiWidth - 20) . " h" . (A_GuiHeight - 100)
    
    ; Reposition buttons at the bottom
    buttonY := A_GuiHeight - 40
    GuiControl, Move, SaveNotes, y%buttonY%
    GuiControl, Move, ClearNotes, y%buttonY%
    GuiControl, Move, ToggleAlwaysOnTop, y%buttonY%
    GuiControl, Move, Exit, y%buttonY%
return

GuiClose:
    ; Ask to save before closing
    Gui( Submit, NoHide
    if (NotesEdit != "") {
        MsgBox, 4, Save Changes?, Do you want to save your changes before exiting?
        IfMsgBox Yes
        {
            GoSub, SaveNotes
        }
    }
    ExitApp
return
