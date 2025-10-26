#Requires AutoHotkey v2.0
#NoEnv
#SingleInstance Force
SendMode Input
SetWorkingDir %A_ScriptDir%

; Snap to Left Half
#Hotkey("Left", (*) => {  ; Win+Left
    WinGet, active_id, ID, A
    WinRestore, ahk_id %active_id%
    WinGetPos, X, Y, Width, Height, ahk_id %active_id%
    WinMove, ahk_id %active_id%,, 0, 0, A_ScreenWidth/2, A_ScreenHeight
return

; Snap to Right Half
#Hotkey("Right", (*) => {  ; Win+Right
    WinGet, active_id, ID, A
    WinRestore, ahk_id %active_id%
    WinGetPos, X, Y, Width, Height, ahk_id %active_id%
    WinMove, ahk_id %active_id%,, A_ScreenWidth/2, 0, A_ScreenWidth/2, A_ScreenHeight
return

; Snap to Top Half
#Hotkey("Up", (*) => {  ; Win+Up
    WinGet, active_id, ID, A
    WinRestore, ahk_id %active_id%
    WinGetPos, X, Y, Width, Height, ahk_id %active_id%
    WinMove, ahk_id %active_id%,, 0, 0, A_ScreenWidth, A_ScreenHeight/2
return

; Snap to Bottom Half
#Hotkey("Down", (*) => {  ; Win+Down
    WinGet, active_id, ID, A
    WinRestore, ahk_id %active_id%
    WinGetPos, X, Y, Width, Height, ahk_id %active_id%
    WinMove, ahk_id %active_id%,, 0, A_ScreenHeight/2, A_ScreenWidth, A_ScreenHeight/2
return

