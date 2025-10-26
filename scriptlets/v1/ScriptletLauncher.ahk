#NoEnv
#SingleInstance Force
#Warn
#MaxHotkeysPerInterval 200

; Set working directory to script location
SetWorkingDir %A_ScriptDir%

; GUI Settings
Gui( Color, 1E1E1E
Gui( Font, s10 cWhite, Segoe UI

; Header
Gui( Add, Picture, x10 y10 w48 h48, %A_WinDir%\System32\SHELL32.dll,14
Gui( Font, s16 cWhite, Segoe UI
Gui( Add, Text, x68 y15 w300 h30 +0x200, Scriptlet Launcher
Gui( Font, s9 cSilver, Segoe UI
Gui( Add, Text, x70 y45 w300 h20 +0x200, v1.0 - Manage your AHK scripts

; Create tab control
Gui( Add, Tab3, x0 y80 w400 h400 vTabControl, Utilities|Games|Pranks|About

; ===== UTILITIES TAB =====
Gui( Tab, 1
Gui( Add, GroupBox, x10 y110 w380 h150, Window Management
Gui( Add, Button, x20 y130 w170 h30 gLaunchScript vBtnWindowMgmt, &Window Management
Gui( Add, Button, x200 y130 w170 h30 gLaunchScript vBtnWindowSnap, Window &Snapping
Gui( Add, Button, x20 y170 w170 h30 gLaunchScript vBtnQuickLaunch, &Quick Launch
Gui( Add, Button, x200 y170 w170 h30 gLaunchScript vBtnClipboard, &Clipboard Manager
Gui( Add, Button, x20 y210 w170 h30 gLaunchScript vBtnVolume, &Volume Control
Gui( Add, Button, x200 y210 w170 h30 gLaunchScript vBtnIDEShortcuts, IDE &Shortcuts

; ===== GAMES TAB =====
Gui( Tab, 2
Gui( Add, GroupBox, x10 y110 w380 h100, Games
Gui( Add, Button, x20 y130 w350 h40 gLaunchScript vBtnSnake, Play &Snake Game`nCtrl+Alt+S when running

; ===== PRANKS TAB =====
Gui( Tab, 3
Gui( Add, GroupBox, x10 y110 w380 h150, Harmless Pranks
Gui( Add, Button, x20 y130 w170 h30 gLaunchScript vBtnFakeTyping, &Fake Typing`n(Ctrl+Alt+T)
Gui( Add, Button, x200 y130 w170 h30 gLaunchScript vBtnMouseJiggle, &Mouse Jiggler`n(Ctrl+Alt+J)
Gui( Add, Button, x20 y170 w170 h30 gLaunchScript vBtnInvertMouse, &Invert Mouse`n(Ctrl+Alt+I)
Gui( Add, Button, x200 y170 w170 h30 gLaunchScript vBtnFakeBSOD, Fake &BSOD`n(Ctrl+Alt+B)
Gui( Add, Button, x20 y210 w170 h30 gLaunchScript vBtnFakeUpdate, Fake &Update`n(Ctrl+Alt+U)

; ===== ABOUT TAB =====
Gui( Tab, 4
Gui( Add, Picture, x150 y120 w100 h100, %A_WinDir%\System32\SHELL32.dll,14
Gui( Add, Text, x20 y230 w360 h60 Center, Scriptlet Launcher v1.0`nCreated with AutoHotkey`n`nSelect a script from the tabs above to get started.

; Status bar
Gui( Add, StatusBar,, Ready

; Show the GUI
Gui( Show, w400 h500, Scriptlet Launcher
return

; Button handler
LaunchScript:
    Gui( Submit, NoHide
    button := A_GuiControl
    script := ""
    
    ; Map buttons to scripts
    if (button = "BtnWindowMgmt") {
        script := "window_management.ahk"
    } else if (button = "BtnWindowSnap") {
        script := "window_snapping.ahk"
    } else if (button = "BtnQuickLaunch") {
        script := "quick_launch.ahk"
    } else if (button = "BtnClipboard") {
        script := "clipboard_manager.ahk"
    } else if (button = "BtnVolume") {
        script := "volume_control.ahk"
    } else if (button = "BtnIDEShortcuts") {
        script := "ide_shortcuts.ahk"
    } else if (button = "BtnSnake") {
        script := "fun_games.ahk"
    } else if (button = "BtnFakeTyping") {
        script := "pranks.ahk"
    } else if (button = "BtnMouseJiggle") {
        script := "fun_games.ahk"
    } else if (button = "BtnInvertMouse") {
        script := "pranks.ahk"
    } else if (button = "BtnFakeBSOD") {
        script := "pranks.ahk"
    } else if (button = "BtnFakeUpdate") {
        script := "pranks.ahk"
    }
    
    ; Launch the script
    if (script != "") {
        if (!FileExist(script)) {
            SB_SetText("Error: " script " not found!")
            MsgBox( Error, Script not found:`n%script%
        } else {
            Run, %A_AhkPath% "%A_ScriptDir%\%script%"
            SB_SetText("Launched: " script)
        }
    }
    
    ; Special handling for games
    if (button = "BtnSnake") {
        SB_SetText("Press Ctrl+Alt+S in any window to start Snake!")
    }
return

; Tray menu
Menu, Tray, NoStandard
Menu, Tray, Add, Open Launcher, ShowLauncher
Menu, Tray, Add
Menu, Tray, Add, Reload, ReloadLauncher
Menu, Tray, Add, Exit, ExitLauncher
Menu, Tray, Default, Open Launcher
Menu, Tray, Tip, Scriptlet Launcher

ShowLauncher:
    Gui( Show
return

ReloadLauncher:
    Reload
return

ExitLauncher:
    ExitApp

GuiClose:
    Gui( Hide
    TrayTip, Scriptlet Launcher, Running in the system tray, , 1
    return

; Function to check if a process is running
IsProcessRunning(processName) {
    Process, Exist, %processName%
    return ErrorLevel
}
