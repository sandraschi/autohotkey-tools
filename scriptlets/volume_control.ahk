#Requires AutoHotkey v2.0+
#SingleInstance Force
#Include %A_ScriptDir%\lib\ScriptletErrorHandler.ahk

; ==============================================================================
; Volume Control
; @name: Volume Control
; @version: 1.0.0
; @description: System volume control with keyboard shortcuts and on-screen display. Quick volume adjustment with visual feedback.
; @description: Provides volume up/down, mute toggle, and on-screen display (OSD) for current volume level. Supports keyboard shortcuts and visual feedback.
; @description: Essential productivity tool for quick volume control without opening system settings or reaching for volume buttons.
; @category: utilities
; @author: Sandra
; @hotkeys: #Up, #Down, #M
; @enabled: true
; @priority: 30
; @tag: volume, control, utilities, audio, system, productivity, osd
; @cli: --volume <0-100> - Set volume percentage
; @cli: --mute - Toggle mute state
; @cli: --help - Show CLI usage and volume control options
; @dependencies: 
; ==============================================================================

; Error handling - log to file instead of showing popups
OnError(LogError)

; Volume Up/Down with Win+Up/Down
Hotkey("#Up", VolumeUp)

VolumeUp(*) {
    Send("{Volume_Up}")
    ShowOSD("Volume: " . GetVolume() . "%")
}

Hotkey("#Down", VolumeDown)

VolumeDown(*) {
    Send("{Volume_Down}")
    ShowOSD("Volume: " . GetVolume() . "%")
}

; Mute with Win+M
Hotkey("#M", ToggleMute)

ToggleMute(*) {
    Send("{Volume_Mute}")
    SoundGet(&mute_status, , , "MUTE")
    if (mute_status = "On") {
        ShowOSD("Muted")
    } else {
        ShowOSD("Unmuted: " . GetVolume() . "%")
    }
}

; Show Volume OSD
ShowOSD(message) {
    ToolTip(message, A_ScreenWidth / 2 - 100, A_ScreenHeight / 2 - 50)
    SetTimer(() => ToolTip(), -1000)
}

; Get current volume percentage
GetVolume() {
    SoundGet(&volume, , "MASTER", "VOLUME")
    return Round(volume)
}

