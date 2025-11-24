; AutoHotkey v2 Script - Scriptlet Launcher
; A menu of useful scriptlets that can be launched with number keys
; Created: 2025-09-08

#Requires AutoHotkey v2.0
#SingleInstance Force
#Warn

; Set working directory to the script's location
SetWorkingDir(A_ScriptDir)

; Create the main GUI
MyGui := Gui(, "Scriptlet Launcher")
MyGui.SetFont("s10", "Segoe UI")
MyGui.MarginX := 20
MyGui.MarginY := 15

; Add title and instructions
MyGui.Add("Text", "w400", "Scriptlet Launcher - Press a number key to run a scriptlet")
MyGui.Add("Text", "w400 cGray", "--------------------------------------------")

; Define scriptlets (name: function)
scriptlets := Map(
    "1", Array("Quick Note", QuickNote),
    "2", Array("Screenshot to Clipboard", ScreenshotToClipboard),
    "3", Array("Toggle Hidden Files", ToggleHiddenFiles),
    "4", Array("Open CMD Here", OpenCmdHere),
    "5", Array("Eject USB Drives", EjectUSB),
    "6", Array("System Info", ShowSystemInfo),
    "7", Array("Empty Recycle Bin", EmptyRecycleBin),
    "8", Array("Toggle Dark Mode", ToggleDarkMode),
    "9", Array("Window Opacity", ToggleWindowOpacity),
    "0", Array("Exit Script", (*) => ExitApp())
)

; Add scriptlet buttons to the GUI
for key, value in scriptlets {
    btn := MyGui.Add("Button", "w400 y+5", key ". " value[1])
    btn.OnEvent("Click", value[2])
}

; Add status bar
statusBar := MyGui.Add("StatusBar",, "Ready")

; Show the GUI
MyGui.Show("w440 h500")

; Register hotkeys for number keys
for key in scriptlets {
    Hotkey "~" key, (*) => scriptlets[key][2].Call()
}

; Scriptlet functions
QuickNote(*) {
    noteGui := Gui("+AlwaysOnTop -SysMenu", "Quick Note")
    noteGui.Add("Edit", "w300 h200 vNoteText")
    noteGui.Add("Button", "Default w80", "Save").OnEvent("Click", SaveNote)
    noteGui.OnEvent("Close", (*) => noteGui.Destroy())
    noteGui.Show()
    
    SaveNote(*) {
        savedNote := noteGui["NoteText"].Value
        if (savedNote != "") {
            FormatTime timestamp, "yyyyMMdd_HHmmss"
            noteFile := A_ScriptDir "\notes\note_" timestamp ".txt"
            DirCreate(A_ScriptDir "\notes")
            FileAppend(savedNote, noteFile, "UTF-8")
            statusBar.Text := "Note saved to: " noteFile
        }
        noteGui.Destroy()
    }
}

ScreenshotToClipboard(*) {
    try {
        A_Clipboard := "" ; Clear clipboard
        Send("#+S") ; Windows 10/11 Snip & Sketch
        statusBar.Text := "Select area to capture (screenshot)"
    } catch as e {
        statusBar.Text := "Error taking screenshot: " e.Message
    }
}

ToggleHiddenFiles(*) {
    static hiddenVisible := false
    RegRead current, "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced", "Hidden"
    hiddenVisible := !hiddenVisible
    RegWrite "DWORD", "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced", "Hidden", hiddenVisible ? 1 : 2
    Send "{F5}"
    statusBar.Text := "Hidden files " (hiddenVisible ? "shown" : "hidden")
}

OpenCmdHere(*) {
    try {
        Run "cmd.exe", A_Desktop
        statusBar.Text := "Opened CMD at Desktop"
    } catch as e {
        statusBar.Text := "Error opening CMD: " e.Message
    }
}

EjectUSB(*) {
    try {
        Run "RunDll32.exe shell32.dll,Control_RunDLL hotplug.dll"
        statusBar.Text := "Safely Remove Hardware dialog opened"
    } catch as e {
        statusBar.Text := "Error opening eject dialog: " e.Message
    }
}

ShowSystemInfo(*) {
    try {
        Run "msinfo32"
        statusBar.Text := "Opened System Information"
    } catch as e {
        statusBar.Text := "Error opening System Information: " e.Message
    }
}

EmptyRecycleBin(*) {
    try {
        if (MsgBox("Are you sure you want to empty the Recycle Bin?", "Confirm", "YesNo 33") = "Yes") {
            FileRecycleEmpty
            statusBar.Text := "Recycle Bin emptied"
        }
    } catch as e {
        statusBar.Text := "Error emptying Recycle Bin: " e.Message
    }
}

ToggleDarkMode(*) {
    static darkMode := false
    darkMode := !darkMode
    
    ; Toggle dark mode for apps
    RegWrite "DWORD", "HKCU\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize", "AppsUseLightTheme", darkMode ? 0 : 1
    
    ; Toggle dark mode for system
    RegWrite "DWORD", "HKCU\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize", "SystemUsesLightTheme", darkMode ? 0 : 1
    
    statusBar.Text := "Dark mode " (darkMode ? "enabled" : "disabled") ". Restart apps to see changes."
}

ToggleWindowOpacity(*) {
    static opacity := 255
    activeWin := WinExist("A")
    if (opacity = 255) {
        opacity := 150
        WinSetTransparent(opacity, activeWin)
        statusBar.Text := "Window transparency set to " opacity "/255"
    } else {
        opacity := 255
        WinSetTransparent("Off", activeWin)
        statusBar.Text := "Window opacity reset to normal"
    }
}

; Clean up on exit
OnExit(ExitReason, ExitCode) {
    ; Reset window transparency if any window was made transparent
    WinSetTransparent("Off", "A")
    return 0
}

; Show help when F1 is pressed
ShowHelpF1(*) {
    MsgBox("Scriptlet Launcher Help`n`n"
        . "Press the number keys (1-0) to run scriptlets.`n"
        . "1. Quick Note - Create and save quick notes`n"
        . "2. Screenshot - Take a screenshot to clipboard`n"
        . "3. Toggle Hidden Files - Show/hide hidden files`n"
        . "4. Open CMD Here - Open Command Prompt at Desktop`n"
        . "5. Eject USB - Open safe removal dialog`n"
        . "6. System Info - Show system information`n"
        . "7. Empty Recycle Bin - Clear the Recycle Bin`n"
        . "8. Toggle Dark Mode - Switch between light/dark theme`n"
        . "9. Window Opacity - Toggle active window transparency`n"
        . "0. Exit - Close the script", "Scriptlet Launcher Help")
}
Hotkey("F1", ShowHelpF1)

; Show a tooltip with the script's status when hovering over the tray icon
TraySetToolTip "Scriptlet Launcher`nPress F1 for help"
