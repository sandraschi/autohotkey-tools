#Requires AutoHotkey v2.0
#NoEnv
#SingleInstance Force
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
    Send {Volume_Mute}
    SoundGet, mute_status, , MUTE
    if (mute_status = "On")
        ShowOSD("Muted")
    else
        ShowOSD("Unmuted: " GetVolume() "%")
return

; Show Volume OSD
ShowOSD(message) {
    Progress, B1 W200 H80 WM400 WS400, %message%, , Volume, Arial
    SetTimer, RemoveOSD, -1000
}

RemoveOSD:
    Progress, Off
return

; Get current volume percentage
GetVolume() {
    SoundGet, volume
    return Round(volume)
}

