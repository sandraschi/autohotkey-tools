#NoEnv
#SingleInstance Force
SendMode Input
SetWorkingDir %A_ScriptDir%

; Toggle Always On Top
^!T::  ; Ctrl+Alt+T
    WinSet, AlwaysOnTop, Toggle, A
    WinGet, ExStyle, ExStyle, A
    if (ExStyle & 0x8)  ; 0x8 is WS_EX_TOPMOST
        ToolTip, Window is now always on top
    else
        ToolTip, Window is no longer always on top
    SetTimer(RemoveToolTip,  2000
return

; Center Active Window
^!C::  ; Ctrl+Alt+C
    WinGetPos,,, Width, Height, A
    WinMove, A,, (A_ScreenWidth/2)-(Width/2), (A_ScreenHeight/2)-(Height/2)
return

; Remove ToolTip
RemoveToolTip:
    SetTimer(RemoveToolTip,  Off
    ToolTip
return
