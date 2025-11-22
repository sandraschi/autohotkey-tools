#NoEnv
#SingleInstance Force
#MaxHotkeysPerInterval 200
SendMode Input
SetWorkingDir %A_ScriptDir%

; Media Controls with Win+Media Keys
#Media_Play_Pause::Send {Media_Play_Pause}
#Media_Next::Send {Media_Next}
#Media_Prev::Send {Media_Prev}
#Media_Stop::Send {Media_Stop}

; Volume Control with Win+Ctrl+Arrow Keys
^#Up::Send {Volume_Up}
^#Down::Send {Volume_Down}
^#Left::Send {Volume_Mute}

; Brightness Control (Requires additional software like Monitorian)
#+Up::  ; Increase brightness
    Send {Volume_Up}  ; Replace with actual brightness up command
    ShowOSD("Brightness: Increased")
return

#+Down::  ; Decrease brightness
    Send {Volume_Down}  ; Replace with actual brightness down command
    ShowOSD("Brightness: Decreased")
return

; Show OSD for media actions
ShowOSD(message) {
    Progress, B1 W200 H80 WM400 WS400, %message%, , Media Control, Arial
    SetTimer(RemoveOSD,  -1000
}

RemoveOSD:
    Progress, Off
return
