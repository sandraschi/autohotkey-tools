#Requires AutoHotkey v2.0
#SingleInstance Force
#MaxHotkeysPerInterval 200
SetWorkingDir(A_ScriptDir)

; ========================================
; 1. ELEVATOR MUSIC PLAYER
; ========================================
static musicPlaying := false

PlayElevatorMusic(*) {
    ; This would be replaced with actual music playing code
    ; For now, we'll just play some random notes
    Random(&note, 1, 7)
    notes := [262, 294, 330, 349, 392, 440, 494]  ; C4 to B4
    SoundBeep(notes[note], 200)
}

ToggleElevatorMusic(*) {
    if (!musicPlaying) {
        ; Start playing elevator music (using system sounds as fallback)
        SoundPlay("*16")  ; Play the default beep sound
        SoundBeep(523, 300)  ; C
        SoundBeep(587, 300)  ; D
        SoundBeep(659, 300)  ; E
        
        ; Start the music loop in a separate thread
        SetTimer(PlayElevatorMusic, 5000)
        musicPlaying := true
        TrayTip("Now playing smooth elevator music...", "Elevator Music", 1)
    } else {
        ; Stop the music
        SetTimer(PlayElevatorMusic, 0)
        SoundPlay("*-1")  ; Stop any playing sound
        musicPlaying := false
        TrayTip("Music stopped", "Elevator Music", 1)
    }
    SetTimer(() => TrayTip(), -3000)
}

Hotkey("^!m", ToggleElevatorMusic)

; ========================================
; 2. RANDOM SOUND EFFECTS
; ========================================
static soundsOn := false

RandomSound(*) {
    Random(&soundType, 1, 5)
    
    if (soundType = 1) {
        ; Windows exclamation
        SoundPlay("*16")
    } else if (soundType = 2) {
        ; Beep
        Random(&freq, 200, 2000)
        Random(&dur, 100, 500)
        SoundBeep(freq, dur)
    } else if (soundType = 3) {
        ; System sound
        SoundPlay(A_WinDir . "\Media\Windows Notify.wav")
    } else if (soundType = 4) {
        ; Random note
        Random(&note, 1, 12)
        freq := 220 * (2 ** (note/12))  ; Equal temperament from A3
        SoundBeep(freq, 300)
    } else {
        ; Random system sound
        SoundPlay("*")
    }
}

ToggleRandomSounds(*) {
    soundsOn := !soundsOn
    
    if (soundsOn) {
        SetTimer(RandomSound, 5000)  ; Play a sound every 5 seconds
        TrayTip("Random sounds enabled!", "Sound Effects", 1)
    } else {
        SetTimer(RandomSound, 0)
        TrayTip("Random sounds disabled", "Sound Effects", 1)
    }
    SetTimer(() => TrayTip(), -3000)
}

Hotkey("^!s", ToggleRandomSounds)

; ========================================
; 3. ANNOYING BEEP GENERATOR
; ========================================
static beepOn := false

AnnoyingBeep(*) {
    Random(&freq, 100, 2000)
    Random(&dur, 50, 200)
    SoundBeep(freq, dur)
}

ToggleAnnoyingBeeps(*) {
    beepOn := !beepOn
    
    if (beepOn) {
        SetTimer(AnnoyingBeep, 1000)
        TrayTip("Annoying beeps enabled!", "Beep Generator", 1)
    } else {
        SetTimer(AnnoyingBeep, 0)
        TrayTip("Beeps disabled", "Beep Generator", 1)
    }
    SetTimer(() => TrayTip(), -3000)
}

Hotkey("^!b", ToggleAnnoyingBeeps)

; ========================================
; 4. RICKROLL (OF COURSE!)
; ========================================
Rickroll(*) {
    ; This would open the YouTube video in the default browser
    Run("https://www.youtube.com/watch?v=dQw4w9WgXcQ")
    
    ; Play a little preview
    SoundBeep(392, 200)  ; G
    Sleep(50)
    SoundBeep(440, 200)  ; A
    Sleep(50)
    SoundBeep(349, 400)  ; F
    Sleep(100)
    SoundBeep(349, 200)  ; F
    Sleep(50)
    SoundBeep(330, 200)  ; E
    Sleep(50)
    SoundBeep(294, 200)  ; D
    Sleep(50)
    SoundBeep(262, 400)  ; C
    
    TrayTip("Give you up!", "Never Gonna...", 1)
    SetTimer(() => TrayTip(), -3000)
}

Hotkey("^!r", Rickroll)

; ========================================
; 5. FAKE VIRUS SCAN
; ========================================
static scanProgress := 0
static scanText := ""
static lastFile := ""

UpdateVirusScan(*) {
    if (scanProgress >= 100) {
        SetTimer(UpdateVirusScan, 0)
        scanLog.Text := scanText . "`nScan complete! 1 threat found.`n`nThreat: Win32.Prank.AHK`nLocation: C:\Windows\System32\prank.dll`nStatus: Quarantined"
        scanProgress := 0
        return
    }
    
    ; Update progress
    Random(&inc, 1, 5)
    scanProgress += inc
    if (scanProgress > 100)
        scanProgress := 100
    
    scanProgressBar.Value := scanProgress
    
    ; Add fake log entries
    if (Mod(scanProgress, 10) = 0) {
        files := ["C:\Windows\System32\kernel32.dll", "C:\Program Files\Common Files\system.ini", "C:\Users\Public\Documents\passwords.txt", "C:\Windows\Temp\tempfile.tmp", "C:\ProgramData\Microsoft\Windows\Start Menu\startup\suspicious.exe"]
        Random(&rand, 1, files.Length)
        lastFile := files[rand]
        scanText .= "Scanning: " . lastFile . "`n"
        
        ; Occasionally find a fake virus
        Random(&threat, 1, 10)
        if (threat = 1) {
            scanText .= "  -> THREAT FOUND: Win32.Prank.AHK`n"
        } else {
            scanText .= "  -> Clean`n"
        }
        
        scanLog.Text := scanText
    }
}

static virusScanGui := ""
static scanProgressBar := ""
static scanLog := ""

ShowFakeVirusScan(*) {
    virusScanGui := Gui("+AlwaysOnTop -Caption +ToolWindow", "Windows Defender")
    virusScanGui.BackColor := "000000"
    virusScanGui.SetFont("s12 cLime", "Consolas")
    
    virusScanGui.Add("Text", "x10 y10 w380 h20", "Scanning for viruses...")
    scanProgressBar := virusScanGui.Add("Progress", "x10 y40 w380 h20 cRed", 0)
    scanLog := virusScanGui.Add("Text", "x10 y70 w380 h300", "Starting system scan...`n")
    
    virusScanGui.Show("w400 h400")
    
    ; Fake scan in progress
    scanText := ""
    scanProgress := 0
    SetTimer(UpdateVirusScan, 500)
    
    virusScanGui.OnEvent("Close", (*) => virusScanGui.Destroy())
}

Hotkey("^!v", ShowFakeVirusScan)

; ========================================
; 6. KEYBOARD SOUNDS
; ========================================
static kbSoundsOn := false

KeySound(*) {
    Random(&pitch, 100, 1000)
    Random(&duration, 10, 30)
    SoundBeep(pitch, duration)
}

ToggleKeyboardSounds(*) {
    kbSoundsOn := !kbSoundsOn
    
    if (kbSoundsOn) {
        Hotkey("*~$a", KeySound)
        Hotkey("*~$b", KeySound)
        Hotkey("*~$c", KeySound)
        ; Add more keys as needed...
        TrayTip("Typewriter mode enabled!", "Keyboard Sounds", 1)
    } else {
        Hotkey("*~$a", "Off")
        Hotkey("*~$b", "Off")
        Hotkey("*~$c", "Off")
        ; Turn off other keys...
        TrayTip("Typewriter mode disabled", "Keyboard Sounds", 1)
    }
    SetTimer(() => TrayTip(), -3000)
}

Hotkey("^!k", ToggleKeyboardSounds)

CleanupOnExit(*) {
    ; Stop all sounds and timers
    SoundPlay("*-1")
    SetTimer(PlayElevatorMusic, 0)
    SetTimer(RandomSound, 0)
    SetTimer(AnnoyingBeep, 0)
    
    ; Close all GUIs
    if (virusScanGui)
        virusScanGui.Destroy()
    
    ; Turn off keyboard sounds
    Hotkey("*~$a", "Off")
    Hotkey("*~$b", "Off")
    Hotkey("*~$c", "Off")
}

OnExit(CleanupOnExit)
