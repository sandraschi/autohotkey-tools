#Requires AutoHotkey v2.0
#SingleInstance Force


; Suppress error popups - log to file instead
OnError("LogError")

LogError(Exception, Mode) {
    FileAppend("Error: " . Exception.Message . " at line " . Exception.Line . "
", "errors.log", "UTF-8")
    return true  ; Suppress popup
}

#Warn

; =============================================================================
; CONFIGURATION
; =============================================================================
; Media Control Hotkeys
MEDIA_PLAY_PAUSE := "#Media_Play_Pause"     ; Win+Media Play/Pause
MEDIA_NEXT := "#Media_Next"                ; Win+Media Next
MEDIA_PREV := "#Media_Prev"                ; Win+Media Previous
MEDIA_STOP := "#Media_Stop"                ; Win+Media Stop

; Volume Control Hotkeys
VOLUME_UP := "^#Up"                        ; Ctrl+Win+Up - Volume Up
VOLUME_DOWN := "^#Down"                    ; Ctrl+Win+Down - Volume Down
VOLUME_MUTE := "^#Left"                    ; Ctrl+Win+Left - Toggle Mute
VOLUME_OSD := "^#Right"                    ; Ctrl+Win+Right - Show Volume Mixer

; Brightness Control (Requires additional software like Monitorian)
BRIGHTNESS_UP := "#+Up"                    ; Win+Shift+Up - Increase Brightness
BRIGHTNESS_DOWN := "#+Down"                ; Win+Shift+Down - Decrease Brightness

; Media Player Control (Global Hotkeys)
PLAYER_PLAY_PAUSE := "^!p"                 ; Ctrl+Alt+P - Play/Pause
PLAYER_NEXT := "^!Right"                   ; Ctrl+Alt+Right - Next Track
PLAYER_PREV := "^!Left"                    ; Ctrl+Alt+Left - Previous Track
PLAYER_STOP := "^!s"                       ; Ctrl+Alt+S - Stop
PLAYER_VOL_UP := "^!Up"                    ; Ctrl+Alt+Up - Volume Up
PLAYER_VOL_DOWN := "^!Down"                ; Ctrl+Alt+Down - Volume Down
PLAYER_MUTE := "^!m"                       ; Ctrl+Alt+M - Toggle Mute

; OSD (On-Screen Display) Settings
OSD_DURATION := 1500                       ; Duration in milliseconds
OSD_FONT := "Arial"
OSD_FONT_SIZE := 12
OSD_BG_COLOR := "1E1E1E"
OSD_TEXT_COLOR := "FFFFFF"
OSD_OPACITY := 230                         ; 0-255 (0=transparent, 255=opaque)

; =============================================================================
; MAIN SCRIPT
; =============================================================================
; Set working directory
SetWorkingDir A_ScriptDir

; Register media control hotkeys
Hotkey MEDIA_PLAY_PAUSE, (*) => Send("{Media_Play_Pause}")
Hotkey MEDIA_NEXT, (*) => Send("{Media_Next}")
Hotkey MEDIA_PREV, (*) => Send("{Media_Prev}")
Hotkey MEDIA_STOP, (*) => Send("{Media_Stop}")

; Volume control hotkeys
Hotkey VOLUME_UP, VolumeUp
Hotkey VOLUME_DOWN, VolumeDown
Hotkey VOLUME_MUTE, (*) => Send("{Volume_Mute}")
Hotkey VOLUME_OSD, ShowVolumeMixer

; Brightness control hotkeys (requires external software)
Hotkey BRIGHTNESS_UP, (*) => AdjustBrightness(10)
Hotkey BRIGHTNESS_DOWN, (*) => AdjustBrightness(-10)

; Media player control hotkeys
Hotkey PLAYER_PLAY_PAUSE, (*) => Send("{Media_Play_Pause}")
Hotkey PLAYER_NEXT, (*) => Send("{Media_Next}")
Hotkey PLAYER_PREV, (*) => Send("{Media_Prev}")
Hotkey PLAYER_STOP, (*) => Send("{Media_Stop}")
Hotkey PLAYER_VOL_UP, VolumeUp
Hotkey PLAYER_VOL_DOWN, VolumeDown
Hotkey PLAYER_MUTE, (*) => Send("{Volume_Mute}")

; Show notification on startup
TrayTip "Media Controls", "Media control hotkeys are active", "Iconi"
SetTimer () => TrayTip(), 3000

; =============================================================================
; FUNCTIONS
; =============================================================================
; Volume control with OSD feedback
VolumeUp(*) {
    Send "{Volume_Up}"
    ShowOSD("Volume: " GetVolume() "%", "VolumeUp.ico")
}

VolumeDown(*) {
    Send "{Volume_Down}"
    ShowOSD("Volume: " GetVolume() "%", "VolumeDown.ico")
}

; Get current volume level (0-100)
GetVolume() {
    static IAudioEndpointVolume := ""
    
    if (!IAudioEndpointVolume) {
        try {
            ; Initialize COM if not already done
            if (!ComObjCreate) {
                return "??"
            }
            
            ; Get audio endpoint
            IMMDeviceEnumerator := ComObject("{BCDE0395-E52F-467C-8E3D-C4579291692E}", "{A95664D2-9614-4F35-A746-DE8DB63617E6}")
            IMMDevice := ComObjQuery(IMMDeviceEnumerator, "{A95664D2-9614-4F35-A746-DE8DB63617E6}")
            IMMDeviceEnumerator := ""
            
            ; Get audio endpoint volume
            IAudioEndpointVolume := ComObjQuery(IMMDevice, "{5CDF2C82-841E-4546-9722-0CF74078229A}")
            IMMDevice := ""
        } catch {
            return "??"
        }
    }
    
    ; Get volume level
    try {
        VarSetCapacity(volume, 4, 0)
        DllCall(NumGet(NumGet(IAudioEndpointVolume+0) + 12*A_PtrSize, "ptr"), "ptr", IAudioEndpointVolume, "float*", &volume)
        return Round(volume * 100)
    } catch {
        return "??"
    }
}

; Show Windows Volume Mixer
ShowVolumeMixer(*) {
    try {
        Run "sndvol.exe -f"
    } catch {
        ShowOSD("Failed to open Volume Mixer")
    }
}

; Adjust brightness (requires external software like nircmd.exe or Monitorian)
AdjustBrightness(amount) {
    static brightness := 100
    
    ; Update brightness value (0-100)
    brightness := Min(Max(brightness + amount, 0), 100)
    
    ; Try to use nircmd if available
    if (FileExist("nircmd.exe")) {
        try {
            Run "nircmd.exe changebrightness " amount, , "Hide"
            ShowOSD("Brightness: " brightness "%", brightness > 50 ? "Sun.ico" : "Moon.ico")
            return
        }
    }
    
    ; Fallback to sending volume keys (visual feedback only)
    if (amount > 0) {
        Send "{Volume_Up}"
    } else {
        Send "{Volume_Down}"
    }
    ShowOSD("Brightness: " brightness "% (Install nircmd.exe for actual control)", brightness > 50 ? "Sun.ico" : "Moon.ico")
}

; Show On-Screen Display
ShowOSD(message, icon := "") {
    static OSD_GUI := ""
    
    ; Create OSD GUI if it doesn't exist
    if (!IsObject(OSD_GUI)) {
        OSD_GUI := Gui("+AlwaysOnTop -Caption +ToolWindow +E0x20")
        OSD_GUI.BackColor := OSD_BG_COLOR
        OSD_GUI.SetFont("s" OSD_FONT_SIZE " c" OSD_TEXT_COLOR, OSD_FONT)
        OSD_GUI.Add("Text", "w300 Center vOSDText", message)
        
        ; Set window transparency
        WinSetTransparent(OSD_OPACITY, OSD_GUI.Hwnd)
        
        ; Position at bottom of screen with some margin
        WinGetPos(, , &width, &height, OSD_GUI.Hwnd)
        xPos := (A_ScreenWidth - width) // 2
        yPos := A_ScreenHeight - height - 50
        OSD_GUI.Show("x" xPos " y" yPos " NoActivate")
    } else {
        ; Update existing OSD
        try {
            ctrl := OSD_GUI["OSDText"]
            if (IsObject(ctrl)) {
                ctrl.Text := message
            }
            OSD_GUI.Show()
        }
    }
    
    ; Remove OSD after delay
    SetTimer () => OSD_GUI.Hide(), -OSD_DURATION
}

; Clean up on exit
OnExit(ExitFunc)
ExitFunc(ExitReason, ExitCode) {
    ; Clean up COM objects if they exist
    try {
        if (IsObject(IAudioEndpointVolume)) {
            ObjRelease(IAudioEndpointVolume)
        }
    }
    return 0
}
