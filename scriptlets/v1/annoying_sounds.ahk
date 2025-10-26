#NoEnv
#SingleInstance Force
#MaxHotkeysPerInterval 200
#Persistent
SetWorkingDir %A_ScriptDir%

; ========================================
; 1. ELEVATOR MUSIC PLAYER
; ========================================
^!m::  ; Ctrl+Alt+M for elevator music
    static musicPlaying := false
    
    if (!musicPlaying) {
        ; Start playing elevator music (using system sounds as fallback)
        SoundPlay, *16  ; Play the default beep sound
        SoundBeep, 523, 300  ; C
        SoundBeep, 587, 300  ; D
        SoundBeep, 659, 300  ; E
        
        ; Start the music loop in a separate thread
        SetTimer, PlayElevatorMusic, 5000
        musicPlaying := true
        TrayTip, Elevator Music, Now playing smooth elevator music..., , 1
    } else {
        ; Stop the music
        SetTimer, PlayElevatorMusic, Off
        SoundPlay, *-1  ; Stop any playing sound
        musicPlaying := false
        TrayTip, Elevator Music, Music stopped, , 1
    }
    SetTimer, RemoveTrayTip, -3000
    return

PlayElevatorMusic:
    ; This would be replaced with actual music playing code
    ; For now, we'll just play some random notes
    Random( note, 1, 7
    notes := [262, 294, 330, 349, 392, 440, 494]  ; C4 to B4
    SoundBeep, % notes[note], 200
    return

; ========================================
; 2. RANDOM SOUND EFFECTS
; ========================================
^!s::  ; Ctrl+Alt+S for random sound effects
    static soundsOn := false
    soundsOn := !soundsOn
    
    if (soundsOn) {
        SetTimer, RandomSound, 5000  ; Play a sound every 5 seconds
        TrayTip, Sound Effects, Random sounds enabled!, , 1
    } else {
        SetTimer, RandomSound, Off
        TrayTip, Sound Effects, Random sounds disabled, , 1
    }
    SetTimer, RemoveTrayTip, -3000
    return

RandomSound:
    Random( soundType, 1, 5
    
    if (soundType = 1) {
        ; Windows exclamation
        SoundPlay, *16
    } else if (soundType = 2) {
        ; Beep
        Random( freq, 200, 2000
        Random( dur, 100, 500
        SoundBeep, %freq%, %dur%
    } else if (soundType = 3) {
        ; System sound
        SoundPlay, %A_WinDir%\Media\Windows Notify.wav
    } else if (soundType = 4) {
        ; Random note
        Random( note, 1, 12
        freq := 220 * (2 ** (note/12))  ; Equal temperament from A3
        SoundBeep, %freq%, 300
    } else {
        ; Random system sound
        SoundPlay, *
    }
    return

; ========================================
; 3. ANNOYING BEEP GENERATOR
; ========================================
^!b::  ; Ctrl+Alt+B for annoying beeps
    static beepOn := false
    beepOn := !beepOn
    
    if (beepOn) {
        SetTimer, AnnoyingBeep, 1000
        TrayTip, Beep Generator, Annoying beeps enabled!, , 1
    } else {
        SetTimer, AnnoyingBeep, Off
        TrayTip, Beep Generator, Beeps disabled, , 1
    }
    SetTimer, RemoveTrayTip, -3000
    return

AnnoyingBeep:
    Random( freq, 100, 2000
    Random( dur, 50, 200
    SoundBeep, %freq%, %dur%
    return

; ========================================
; 4. RICKROLL (OF COURSE!)
; ========================================
^!r::  ; Ctrl+Alt+R for Rickroll
    ; This would open the YouTube video in the default browser
    Run, https://www.youtube.com/watch?v=dQw4w9WgXcQ
    
    ; Play a little preview
    SoundBeep, 392, 200  ; G
    Sleep, 50
    SoundBeep, 440, 200  ; A
    Sleep, 50
    SoundBeep, 349, 400  ; F
    Sleep, 100
    SoundBeep, 349, 200  ; F
    Sleep, 50
    SoundBeep, 330, 200  ; E
    Sleep, 50
    SoundBeep, 294, 200  ; D
    Sleep, 50
    SoundBeep, 262, 400  ; C
    
    TrayTip, Never Gonna..., Give you up!, , 1
    SetTimer, RemoveTrayTip, -3000
    return

; ========================================
; 5. FAKE VIRUS SCAN
; ========================================
^!v::  ; Ctrl+Alt+V for fake virus scan
    Gui( VirusScan:New, +AlwaysOnTop -Caption +ToolWindow
    Gui( Color, 000000
    Gui( Font, s12 cLime, Consolas
    
    Gui( Add, Text, x10 y10 w380 h20, Scanning for viruses...
    Gui( Add, Progress, x10 y40 w380 h20 cRed vScanProgress, 0
    Gui( Add, Text, x10 y70 w380 h300 vScanLog, Starting system scan...`n
    
    Gui( Show, w400 h400, Windows Defender
    
    ; Fake scan in progress
    scanText := ""
    SetTimer, UpdateVirusScan, 500
    return

UpdateVirusScan:
    static progress := 0
    static lastFile := ""
    
    if (progress >= 100) {
        SetTimer, UpdateVirusScan, Off
        GuiControl,, ScanLog, % scanText . "`nScan complete! 1 threat found.`n`nThreat: Win32.Prank.AHK`nLocation: C:\Windows\System32\prank.dll`nStatus: Quarantined"
        progress := 0
        return
    }
    
    ; Update progress
    progress += Random(1, 5)
    if (progress > 100)
        progress := 100
    
    GuiControl,, ScanProgress, %progress%
    
    ; Add fake log entries
    if (Mod(progress, 10) = 0) {
        files := ["C:\Windows\System32\kernel32.dll", "C:\Program Files\Common Files\system.ini", "C:\Users\Public\Documents\passwords.txt", "C:\Windows\Temp\tempfile.tmp", "C:\ProgramData\Microsoft\Windows\Start Menu\startup\suspicious.exe"]
        Random( rand, 1, files.MaxIndex()
        lastFile := files[rand]
        scanText .= "Scanning: " lastFile "`n"
        
        ; Occasionally find a fake virus
        if (Random(1, 10) = 1) {
            scanText .= "  -> THREAT FOUND: Win32.Prank.AHK`n"
        } else {
            scanText .= "  -> Clean`n"
        }
        
        GuiControl,, ScanLog, %scanText%
    }
    return

VirusScanGuiClose:
    Gui( VirusScan:Destroy
    return

; ========================================
; 6. KEYBOARD SOUNDS
; ========================================
^!k::  ; Ctrl+Alt+K for keyboard sounds
    static kbSoundsOn := false
    kbSoundsOn := !kbSoundsOn
    
    if (kbSoundsOn) {
        ; Register hotkeys for all alphanumeric keys and special keys
        keys := "abcdefghijklmnopqrstuvwxyz1234567890!@#$%^&*()_+`-=\`|[]{};':\"",<.>/?"
        Loop  Parse, keys
            Hotkey, *~$%A_LoopField%, KeySound
            
        ; Special keys
        Hotkey, *~$Space, KeySound
        Hotkey, *~$Enter, KeySound
        Hotkey, *~$Backspace, KeySound
        Hotkey, *~$Delete, KeySound
        Hotkey, *~$Tab, KeySound
        Hotkey, *~$Up, KeySound
        Hotkey, *~$Down, KeySound
        Hotkey, *~$Left, KeySound
        Hotkey, *~$Right, KeySound
        
        TrayTip, Keyboard Sounds, Keyboard sounds enabled!, , 1
    } else {
        ; Unregister all hotkeys
        keys := "abcdefghijklmnopqrstuvwxyz1234567890!@#$%^&*()_+`-=\`|[]{};':\"",<.>/?"
        Loop  Parse, keys
            Hotkey, *~$%A_LoopField%, Off
            
        Hotkey, *~$Space, Off
        Hotkey, *~$Enter, Off
        Hotkey, *~$Backspace, Off
        Hotkey, *~$Delete, Off
        Hotkey, *~$Tab, Off
        Hotkey, *~$Up, Off
        Hotkey, *~$Down, Off
        Hotkey, *~$Left, Off
        Hotkey, *~$Right, Off
        
        TrayTip, Keyboard Sounds, Keyboard sounds disabled, , 1
    }
    SetTimer, RemoveTrayTip, -3000
    return

KeySound:
    ; Skip if this is an auto-repeat (key being held down)
    if (A_ThisHotkey = A_PriorHotkey && A_TimeSincePriorHotkey < 100)
        return
        
    ; Different sounds for different key types
    key := SubStr(A_ThisHotkey, 4)  ; Remove *~$
    
    ; Special keys get special sounds
    if (key = "Backspace" || key = "Delete") {
        SoundBeep, 100, 50
    } else if (key = "Enter" || key = "Space") {
        SoundBeep, 200, 20
    } else if (key = "Tab") {
        SoundBeep, 300, 30
    } else if (key = "Up" || key = "Down" || key = "Left" || key = "Right") {
        SoundBeep, 400, 20
    } else {
        ; Alphanumeric keys - use their ASCII value to generate a tone
        asc := Asc(key)
        if (asc >= 65 && asc <= 90)  ; A-Z
            freq := 300 + (asc - 65) * 20
        else if (asc >= 97 && asc <= 122)  ; a-z
            freq := 300 + (asc - 97) * 20
        else if (asc >= 48 && asc <= 57)  ; 0-9
            freq := 500 + (asc - 48) * 30
        else
            freq := 300 + Mod(asc, 500)  ; Other characters
            
        SoundBeep, %freq%, 20
    }
    return
    }
    SetTimer, RemoveTrayTip, -3000
    return

KeySound:
    Random( pitch, 100, 1000
    Random( duration, 10, 30
    SoundBeep, %pitch%, %duration%
    return

; ========================================
; HELPER FUNCTIONS
; ========================================

; Generate random number between min and max
Random(min, max) {
    Random( r, min, max
    return r
}

RemoveTrayTip:
    SetTimer, RemoveTrayTip, Off
    TrayTip
    return

; Clean up
GuiClose:
    ; Stop all sounds and timers
    SoundPlay, *-1
    SetTimer, PlayElevatorMusic, Off
    SetTimer, RandomSound, Off
    SetTimer, AnnoyingBeep, Off
    
    ; Close all GUIs
    Gui( VirusScan:Destroy
    
    ; Turn off keyboard sounds
    Hotkey, *~$a, Off
    Hotkey, *~$b, Off
    Hotkey, *~$c, Off
    ; Turn off other keys...
    
    ExitApp
    return
