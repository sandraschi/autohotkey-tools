#Requires AutoHotkey v2.0
#SingleInstance Force
#Warn

; =============================================================================
; CONFIGURATION
; =============================================================================
; Maximum number of items to keep in clipboard history
MAX_HISTORY := 50

; Maximum length of preview text (characters)
MAX_PREVIEW_LENGTH := 100

; Hotkeys
HOTKEY_SHOW_MENU := "#v"           ; Win+V to show clipboard menu
HOTKEY_PASTE_PREV := "^!v"         ; Ctrl+Alt+V to paste previous item
HOTKEY_CLEAR_HISTORY := "^!+c"     ; Ctrl+Alt+Shift+C to clear history

; UI Settings
MENU_WIDTH := 600
MENU_ITEM_HEIGHT := 22
MENU_ITEMS_VISIBLE := 10

; =============================================================================
; GLOBAL VARIABLES
; =============================================================================
; Clipboard history array (most recent first)
ClipboardHistory := []

; Last active window ID
LastActiveWindow := 0

; =============================================================================
; MAIN SCRIPT
; =============================================================================
; Set working directory
SetWorkingDir A_ScriptDir

; Initialize clipboard history from file
LoadClipboardHistory()

; Monitor clipboard changes
OnClipboardChange(ClipChanged, 1)

; Register hotkeys
Hotkey HOTKEY_SHOW_MENU, ShowClipboardMenu
Hotkey HOTKEY_PASTE_PREV, PastePreviousItem
Hotkey HOTKEY_CLEAR_HISTORY, ClearClipboardHistory

; Show notification on startup
TrayTip "Clipboard Manager", "Clipboard Manager is running`n" HOTKEY_SHOW_MENU ": Show history", "Iconi"
SetTimer () => TrayTip(), 3000

; =============================================================================
; FUNCTIONS
; =============================================================================
; Handle clipboard change events
ClipChanged(Type) {
    if (Type = 1) {  ; Text was put on clipboard
        ; Skip if the clipboard is empty or contains the same text as the last item
        if (ClipboardAll = "" || (ClipboardHistory.Length > 0 && Clipboard = ClipboardHistory[1].text)) {
            return
        }
        
        ; Create a new history item
        item := {
            text: Clipboard,
            timestamp: FormatTime(, "yyyy-MM-dd HH:mm:ss"),
            source: WinGetProcessName("A"),
            preview: GetPreviewText(Clipboard)
        }
        
        ; Add to history
        ClipboardHistory.InsertAt(1, item)
        
        ; Limit history size
        if (ClipboardHistory.Length > MAX_HISTORY) {
            ClipboardHistory.Pop()
        }
        
        ; Save to file
        SaveClipboardHistory()
    }
}

; Show clipboard history menu
ShowClipboardMenu() {
    if (ClipboardHistory.Length = 0) {
        TrayTip "Clipboard Manager", "Clipboard history is empty", "Iconi"
        SetTimer () => TrayTip(), 2000
        return
    }
    
    ; Save the current active window
    LastActiveWindow := WinExist("A")
    
    ; Create the GUI
    menuGui := Gui("+AlwaysOnTop +ToolWindow -SysMenu -Caption", "Clipboard History")
    menuGui.BackColor := "F0F0F0"
    menuGui.SetFont("s10", "Segoe UI")
    
    ; Add title bar
    titleBar := menuGui.Add("Text", "w" MENU_WIDTH " h30 0x200 Center Background2A4F7F cWhite vTitleBar", "Clipboard History (" ClipboardHistory.Length "/" MAX_HISTORY ")")
    titleBar.OnEvent("Click", MoveWindow)
    titleBar.OnEvent("DoubleClick", (*) => menuGui.Destroy())
    
    ; Add close button
    btnClose := menuGui.Add("Button", "x+0 w30 h30 BackgroundE81123", "X")
    btnClose.OnEvent("Click", (*) => menuGui.Destroy())
    
    ; Add list of clipboard items
    menuGui.SetFont("s9", "Consolas")
    lbItems := menuGui.Add("ListBox", 
        "w" MENU_WIDTH " h" (MENU_ITEM_HEIGHT * Min(MENU_ITEMS_VISIBLE, ClipboardHistory.Length + 1)) " vClipboardList")
    
    ; Add items to the list
    for i, item in ClipboardHistory {
        displayText := "[" item.timestamp "] " item.preview
        lbItems.Add([displayText])
    }
    
    ; Handle double-click to paste
    lbItems.OnEvent("DoubleClick", PasteSelectedItem.Bind(menuGui, lbItems))
    
    ; Add buttons
    btnPaste := menuGui.Add("Button", "w80 h30 Default", "&Paste")
    btnPaste.OnEvent("Click", PasteSelectedItem.Bind(menuGui, lbItems))
    
    btnDelete := menuGui.Add("Button", "x+10 wp h30", "&Delete")
    btnDelete.OnEvent("Click", DeleteSelectedItem.Bind(menuGui, lbItems))
    
    btnClear := menuGui.Add("Button", "x+10 wp h30", "C&lear All")
    btnClear.OnEvent("Click", ClearClipboardHistory)
    
    ; Show the menu at the cursor position
    menuGui.Show("AutoSize NoActivate")
    
    ; Position the window
    CoordMode "Mouse", "Screen"
    MouseGetPos &mouseX, &mouseY
    WinGetPos , , &width, &height, menuGui
    
    ; Adjust position to stay on screen
    screenWidth := A_ScreenWidth
    screenHeight := A_ScreenHeight
    
    if (mouseX + width > screenWidth) {
        xPos := screenWidth - width - 10
    } else {
        xPos := mouseX
    }
    
    if (mouseY + height > screenHeight) {
        yPos := screenHeight - height - 10
    } else {
        yPos := mouseY
    }
    
    menuGui.Show("x" xPos " y" yPos " NoActivate")
    
    ; Set focus to the list
    ControlFocus "ListBox1", menuGui
}

; Paste the selected item
PasteSelectedItem(menuGui, lbItems, *) {
    selectedIndex := lbItems.Value
    if (selectedIndex > 0 && selectedIndex <= ClipboardHistory.Length) {
        selectedItem := ClipboardHistory[selectedIndex]
        
        ; Move the selected item to the top of the history
        ClipboardHistory.RemoveAt(selectedIndex)
        ClipboardHistory.InsertAt(1, selectedItem)
        
        ; Copy to clipboard
        A_Clipboard := selectedItem.text
        
        ; Paste to the last active window
        if (LastActiveWindow) {
            WinActivate "ahk_id " LastActiveWindow
            Sleep 100
            Send "^v"
        }
        
        ; Save the updated history
        SaveClipboardHistory()
    }
    
    menuGui.Destroy()
}

; Delete the selected item
DeleteSelectedItem(menuGui, lbItems, *) {
    selectedIndex := lbItems.Value
    if (selectedIndex > 0 && selectedIndex <= ClipboardHistory.Length) {
        ClipboardHistory.RemoveAt(selectedIndex)
        
        ; Update the list
        lbItems.Delete()
        for i, item in ClipboardHistory {
            displayText := "[" item.timestamp "] " item.preview
            lbItems.Add([displayText])
        }
        
        ; Resize the list if needed
        if (ClipboardHistory.Length < MENU_ITEMS_VISIBLE) {
            lbItems.Opt("h" (MENU_ITEM_HEIGHT * (ClipboardHistory.Length + 1)))
        }
        
        ; Save the updated history
        SaveClipboardHistory()
    }
}

; Paste the previous clipboard item
PastePreviousItem(*) {
    if (ClipboardHistory.Length >= 2) {
        ; Get the previous item (index 2 because index 1 is the current clipboard)
        previousItem := ClipboardHistory[2]
        
        ; Copy to clipboard
        A_Clipboard := previousItem.text
        
        ; Paste to the active window
        Send "^v"
        
        ; Move the item to the top of the history
        ClipboardHistory.RemoveAt(2)
        ClipboardHistory.InsertAt(1, previousItem)
        
        ; Save the updated history
        SaveClipboardHistory()
    } else {
        TrayTip "Clipboard Manager", "No previous item in history", "Iconi"
        SetTimer () => TrayTip(), 2000
    }
}

; Clear clipboard history
ClearClipboardHistory(*) {
    if (MsgBox("Are you sure you want to clear the clipboard history?", "Clipboard Manager", "YesNo Icon!") = "Yes") {
        ClipboardHistory := []
        SaveClipboardHistory()
        
        if (WinExist("Clipboard History")) {
            WinClose
        }
        
        TrayTip "Clipboard Manager", "Clipboard history cleared", "Iconi"
        SetTimer () => TrayTip(), 2000
    }
}

; Load clipboard history from file
LoadClipboardHistory() {
    historyFile := A_ScriptDir "\clipboard_history.json"
    
    if (FileExist(historyFile)) {
        try {
            fileContents := FileRead(historyFile)
            if (fileContents != "") {
                ClipboardHistory := JSON.parse(fileContents)
                
                ; Ensure we don't exceed the maximum history size
                while (ClipboardHistory.Length > MAX_HISTORY) {
                    ClipboardHistory.Pop()
                }
            }
        } catch as e {
            ; If there's an error loading the file, start with an empty history
            ClipboardHistory := []
            FileDelete historyFile
        }
    }
}

; Save clipboard history to file
SaveClipboardHistory() {
    historyFile := A_ScriptDir "\clipboard_history.json"
    
    try {
        fileContents := JSON.stringify(ClipboardHistory, , 2)
        FileOpen(historyFile, "w").Write(fileContents)
    } catch as e {
        ; If there's an error saving the file, just continue
    }
}

; Get preview text (first line, truncated)
GetPreviewText(text) {
    ; Get the first line
    firstLine := RegExReplace(text, "`am)^(.*?)(`r`n|`r|`n|$).*", "$1")
    
    ; Trim whitespace
    firstLine := Trim(firstLine)
    
    ; Truncate if necessary
    if (StrLen(firstLine) > MAX_PREVIEW_LENGTH) {
        firstLine := SubStr(firstLine, 1, MAX_PREVIEW_LENGTH - 3) "..."
    }
    
    return firstLine
}

; Move window by dragging the title bar
MoveWindow(*) {
    PostMessage 0xA1, 2
}

; =============================================================================
; HOTKEYS
; =============================================================================
; Win+V: Show clipboard history
#Hotkey("v", (*) =>  ShowClipboardMe)nu()

; Ctrl+Alt+V: Paste previous clipboard item
^!Hotkey("v", (*) =>  PastePreviousItem()

; Ctrl+Alt+Shift+C: Clear clipboard history
^!+c:: ClearClipboardHistory()

; =============================================================================
; EXIT HA)NDLER
; =============================================================================nOnExit(ExitFunc)
ExitFunc(ExitReason, ExitCode) {
    ; Save clipboard history on exit
    SaveClipboardHistory()
    return 0
}

