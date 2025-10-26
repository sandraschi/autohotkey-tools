; AutoHotkey v2 Script
; Enhanced Hello World example
; Created: 2025-09-10
; Updated: 2025-09-10 - Added interactive GUI and function examples

#Requires AutoHotkey v2.0
#SingleInstance Force
#Warn

; Set working directory and initialize
SetWorkingDir A_ScriptDir

; =============================================================================
; GLOBAL VARIABLES
; =============================================================================
AppName := "AHK v2 Demo"
AppVersion := "1.0.0"

; =============================================================================
; MAIN GUI
; =============================================================================
; Create the main window
MainGui := Gui("+Resize +MinSize640x480", AppName " v" AppVersion)
MainGui.OnEvent("Close", GuiClose)
MainGui.OnEvent("Escape", GuiClose)
MainGui.SetFont("s10", "Segoe UI")

; Add controls
MainGui.Add("Text", "w600 Center", "Welcome to AutoHotkey v2!")
MainGui.Add("Text", "yp+30 w600", "This script demonstrates:")
MainGui.Add("Text", "xp+20 y+5 w560", "• Basic GUI creation and layout")
MainGui.Add("Text", "xp y+2 w560", "• Event handling")
MainGui.Add("Text", "xp y+2 w560", "• Functions and hotkeys")
MainGui.Add("Text", "xp y+2 w560", "• System integration")

; Add interactive elements
EditBox := MainGui.Add("Edit", "w400 h100 vUserInput", "Type something here...")

; Button to show a message
BtnShowMessage := MainGui.Add("Button", "w200", "&Show Message")
BtnShowMessage.OnEvent("Click", ShowMessage)

; Button to copy to clipboard
BtnCopy := MainGui.Add("Button", "x+10 w200", "&Copy to Clipboard")
BtnCopy.OnEvent("Click", CopyToClipboard)

; Status bar
StatusBar := MainGui.Add("StatusBar", "", "Ready")

; Menu
MenuBar := Menu()
MenuBar.Add("&File")
MenuBar.Add("&Help")
MainGui.MenuBar := MenuBar

; Show the window
MainGui.Show("w640 h480")
UpdateStatusBar("Application started")

; =============================================================================
; FUNCTIONS
; =============================================================================
; Show a message box with the current text
ShowMessage(*) {
    try {
        userText := MainGui["UserInput"].Value
        if (userText = "" || userText = "Type something here...") {
            MsgBox "Please enter some text first!", AppName, "Icon!"
        } else {
            MsgBox "You entered:`n`n" userText, AppName, "Iconi"
            UpdateStatusBar("Message shown: " (StrLen(userText) > 20 ? SubStr(userText, 1, 20) "..." : userText))
        }
    } catch Error as e {
        MsgBox "An error occurred:`n" e.Message, AppName, "Iconx"
    }
}

; Copy text to clipboard
CopyToClipboard(*) {
    try {
        userText := MainGui["UserInput"].Value
        if (userText = "" || userText = "Type something here...") {
            MsgBox "No text to copy!", AppName, "Icon!"
            return
        }
        A_Clipboard := userText
        if (A_Clipboard = userText) {
            UpdateStatusBar("Text copied to clipboard!")
            ToolTip "Copied!"
            SetTimer () => ToolTip(), -1000  ; Hide tooltip after 1 second
        } else {
            throw Error("Failed to access clipboard")
        }
    } catch Error as e {
        MsgBox "Failed to copy to clipboard: " e.Message, AppName, "Iconx"
    }
}

; Update status bar
UpdateStatusBar(message) {
    try {
        StatusBar.Text := message
    }
}

; Handle window close
GuiClose(*) {
    MsgBox "Thank you for trying AutoHotkey v2!", AppName, "Iconi"
    ExitApp
}

; =============================================================================
; HOTKEYS
; =============================================================================
; Toggle window always on top with Ctrl+Space
^Space:: {
    currentState := WinGetAlwaysOnTop("A")
    WinSetAlwaysOnTop !currentState, "A"
    UpdateStatusBar("Always on top: " (currentState ? "Off" : "On"))
}

; Reload script with Ctrl+R
^r::Reload

; =============================================================================
; AUTO-EXECUTE SECTION
; =============================================================================
; Any code here runs when the script starts
OnMessage 0x200, WM_MOUSEMOVE  ; Track mouse movement for status bar updates

; Example of a message handler
WM_MOUSEMOVE(wParam, lParam, msg, hwnd) {
    static prevControl := ""
    currControl := A_GuiControl
    if (currControl != prevControl) {
        prevControl := currControl
        if (currControl != "") {
            SetTimer UpdateStatusBar, -100
        } else {
            UpdateStatusBar("Ready")
        }
    }
}

; Clean up on exit
OnExit(ExitFunc)
ExitFunc(ExitReason, ExitCode) {
    if (ExitReason != "Menu") {
        MsgBox "Goodbye!", AppName
    }
    return 0
}
MyGui.Add("Text", "w300", "Hello, World! This is an AutoHotkey v2 script.")
MyGui.Add("Button", "Default", "OK").OnEvent("Click", (*) => ExitApp())
MyGui.Show("w320 h120")

; A simple hotkey that shows a message box when Win+H is pressed
#h:: {
    MsgBox "Hello, World!`nThis is a message from your AutoHotkey script.", "Greetings"
}

; Display a tooltip when the script starts
ToolTip "AutoHotkey Script is Running!`nPress Win+H to test", 100, 100
SetTimer () => ToolTip(), -3000  ; Remove the tooltip after 3 seconds

; Function to handle script exit
OnExit(ExitReason, ExitCode) {
    if (ExitReason = "Exit") {
        MsgBox "Goodbye! Thanks for using this script.", "Farewell"
    }
    return 0  ; Call the default exit routine
}
