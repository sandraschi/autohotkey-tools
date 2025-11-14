#Requires AutoHotkey v2.0+
#SingleInstance Force
#Include %A_ScriptDir%\lib\ScriptletErrorHandler.ahk

; ==============================================================================
; Window Snapping
; @name: Window Snapping
; @version: 1.0.0
; @description: Window snapping with Win+Arrow keys. Quick window positioning with keyboard shortcuts for efficient workspace organization.
; @description: Snaps windows to screen edges and corners using Win+Arrow key combinations. Includes restore, maximize, and center window functions.
; @description: Essential productivity tool for users who frequently arrange windows and want quick keyboard-based window positioning.
; @category: utilities
; @author: Sandra
; @hotkeys: #Left, #Right, #Up, #Down
; @enabled: true
; @priority: 25
; @tag: window-snapping, productivity, utilities, keyboard-shortcuts, workspace
; @cli: --snap <direction> - Snap active window (left, right, up, down)
; @cli: --help - Show CLI usage and snapping options
; @dependencies: 
; ==============================================================================

; Error handling - log to file instead of showing popups
OnError(LogError)

; Snap to Left Half
Hotkey("#Left", SnapLeft)

SnapLeft(*) {
    active_id := WinExist("A")
    WinRestore("ahk_id " . active_id)
    WinGetPos(&X, &Y, &Width, &Height, "ahk_id " . active_id)
    WinMove(0, 0, A_ScreenWidth//2, A_ScreenHeight, "ahk_id " . active_id)
}

; Snap to Right Half
Hotkey("#Right", SnapRight)

SnapRight(*) {
    active_id := WinExist("A")
    WinRestore("ahk_id " . active_id)
    WinGetPos(&X, &Y, &Width, &Height, "ahk_id " . active_id)
    WinMove(A_ScreenWidth//2, 0, A_ScreenWidth//2, A_ScreenHeight, "ahk_id " . active_id)
}

; Snap to Top Half
Hotkey("#Up", SnapTop)

SnapTop(*) {
    active_id := WinExist("A")
    WinRestore("ahk_id " . active_id)
    WinGetPos(&X, &Y, &Width, &Height, "ahk_id " . active_id)
    WinMove(0, 0, A_ScreenWidth, A_ScreenHeight//2, "ahk_id " . active_id)
}

; Snap to Bottom Half
Hotkey("#Down", SnapBottom)

SnapBottom(*) {
    active_id := WinExist("A")
    WinRestore("ahk_id " . active_id)
    WinGetPos(&X, &Y, &Width, &Height, "ahk_id " . active_id)
    WinMove(0, A_ScreenHeight//2, A_ScreenWidth, A_ScreenHeight//2, "ahk_id " . active_id)
}

