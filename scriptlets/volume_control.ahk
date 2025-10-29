#Requires AutoHotkey v2.0
#NoEnv
#SingleInstance Force


; Suppress error popups - log to file instead
OnError(LogError)

LogError(Thrown, Mode) {
    FileAppend("Error: " . Thrown.Message . " at line " . Thrown.Line . "
", "errors.log", "UTF-8")
    return 1  ; Suppress popup (1 = suppress, 0 = show)
}

#MaxHotkeysPerInterval 200
SendMode Input
SetWorkingDir %A_ScriptDir%

; Volume Up/Down with Win+Up/Down
#Hotkey("Up", (*) => 
    Send {Volume_Up}
    ShowOSD("Volume: " GetVolume() "%")
return

#Hotkey("Down", (*) => 
    Send {Volume_Down}
    ShowOSD("Volume: " GetVolume() "%")
return

; Mute with Win+M
#Hotkey("m", (*) => 
    Send("{Volume_Mute}")
    SoundGet(&mute_status, , , "MUTE")
    if (mute_status = "On")
        ShowOSD("Muted")
    else
        ShowOSD("Unmuted: " GetVolume() "%")
return

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

