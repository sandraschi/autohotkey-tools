#NoEnv
#SingleInstance Force
#MaxHotkeysPerInterval 200
SendMode Input
SetWorkingDir %A_ScriptDir%

; Prank: Fake Typing
^!t::  ; Ctrl+Alt+T to toggle fake typing
    static typing := false
    typing := !typing
    if (typing) {
        SetTimer(FakeTyping,  1000
        TrayTip, Prank, Fake Typing: ON, , 1
    } else {
        SetTimer(FakeTyping,  Off
        TrayTip, Prank, Fake Typing: OFF, , 1
    }
    SetTimer(RemoveTrayTip,  -3000
    return

FakeTyping:
    Random, rand, 1, 10
    if (rand = 1) {
        SendInput {Backspace 5}
        Sleep, 100
        SendInput {Text}Oops!`n
    } else if (rand = 2) {
        SendInput {Text}Let me think...{Enter}
    } else if (rand = 3) {
        SendInput {Text}Hmm...{Space}
    } else {
        SendInput {Text}The quick brown fox jumps over the lazy dog. {Space}
    }
    return

; Prank: Random Mouse Clicks
^!m::  ; Ctrl+Alt+M to toggle random mouse clicks
    static clicking := false
    clicking := !clicking
    if (clicking) {
        SetTimer(RandomClick,  3000
        TrayTip, Prank, Random Clicks: ON, , 1
    } else {
        SetTimer(RandomClick,  Off
        TrayTip, Prank, Random Clicks: OFF, , 1
    }
    SetTimer(RemoveTrayTip,  -3000
    return

RandomClick:
    Random, x, 0, A_ScreenWidth
    Random, y, 0, A_ScreenHeight
    Click, %x%, %y%
    return

; Prank: Invert Mouse Buttons
^!i::  ; Ctrl+Alt+I to invert mouse buttons
    static inverted := false
    inverted := !inverted
    if (inverted) {
        DllCall("SwapMouseButton", "UInt", 1)
        TrayTip, Prank, Mouse Buttons Inverted!, , 1
    } else {
        DllCall("SwapMouseButton", "UInt", 0)
        TrayTip, Prank, Mouse Buttons Normal, , 1
    }
    SetTimer(RemoveTrayTip,  -3000
    return

; Prank: Fake BSOD
^!b::  ; Ctrl+Alt+B for fake BSOD
    Gui, BSOD:New, +AlwaysOnTop -Caption +ToolWindow
    Gui, Color, 0000AA
    Gui, Font, s12 cWhite, Lucida Console
    Gui, Add, Text, x20 y20 w600 h400, 
    (
    A problem has been detected and Windows has been shut down to prevent damage
    to your computer.
    
    DRIVER_IRQL_NOT_LESS_OR_EQUAL
    
    If this is the first time you've seen this stop error screen,
    restart your computer. If this screen appears again, follow
    these steps:
    
    Check to make sure any new hardware or software is properly installed.
    If this is a new installation, ask your hardware or software manufacturer
    for any Windows updates you might need.
    
    Technical information:
    *** STOP: 0x000000D1 (0x00000000,0x00000002,0x00000000,0x00000000)
    
    Beginning dump of physical memory
    Physical memory dump complete.
    Contact your system administrator or technical support group for further
    assistance.
    )
    Gui, Show, w640 h480, Windows - No Disk
    return

; Prank: Fake Windows Update
^!u::  ; Ctrl+Alt+U for fake Windows Update
    Gui, Update:New, +AlwaysOnTop -Caption +ToolWindow
    Gui, Color, 0078D7
    Gui, Font, s12 cWhite, Segoe UI
    Gui, Add, Text, x20 y20 w600 h30, Windows Update
    Gui, Font, s10
    Gui, Add, Text, x20 y60 w600 h30, Downloading updates 1 of 15...
    Gui, Add, Progress, x20 y100 w600 h30 cGreen vUpdateProgress, 0
    Gui, Show, w640 h200, Windows Update
    
    progress := 0
    SetTimer(UpdateProgress,  1000
    return

UpdateProgress:
    progress += 5
    if (progress >= 100) {
        SetTimer(UpdateProgress,  Off
        GuiControl,, UpdateProgress, 100
        GuiControl,, Static2, Installation complete! Restarting in 10 seconds...
        Sleep, 5000
        Gui, Hide
        return
    }
    GuiControl,, UpdateProgress, %progress%
    GuiControl,, Static2, Downloading updates 1 of 15... (%progress%`%)
    return

BSODGuiClose:
UpdateGuiClose:
    Gui, Destroy
    return

RemoveTrayTip:
    TrayTip
    return
