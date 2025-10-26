#Requires AutoHotkey v2.0
#SingleInstance Force
#Warn All, Off
SetWorkingDir(A_ScriptDir)

; Global variables
musicPlaying := false
soundsOn := false
beepOn := false
kbSoundsOn := false
currentModel := "llama3"

; ========================================
; 1. ELEVATOR MUSIC PLAYER
; ========================================
^!m:: {  ; Ctrl+Alt+M for elevator music
    static musicPlaying := false
    
    if (!musicPlaying) {
        ; Start playing elevator music (using system sounds as fallback)
        SoundPlay("*16")  ; Play the default beep sound
        SoundBeep(523, 300)  ; C
        SoundBeep(587, 300)  ; D
        SoundBeep(659, 300)  ; E
        
        ; Start the music loop in a separate thread
        SetTimer(PlayElevatorMusic, 5000)
        musicPlaying := true
        TrayTip("Elevator Music", "Now playing smooth elevator music...", "P1")
    } else {
        ; Stop the music
        SetTimer(PlayElevatorMusic, 0)
        SoundPlay("*-1")  ; Stop any playing sound
        musicPlaying := false
        TrayTip("Elevator Music", "Music stopped", "P1")
    }
    SetTimer(RemoveTrayTip, -3000)
}

PlayElevatorMusic() {
    ; This would be replaced with actual music playing code
    ; For now, we'll just play some random notes
    static notes := [262, 294, 330, 349, 392, 440, 494]  ; C4 to B4
    SoundBeep(notes[Random(1, notes.Length)], 200)
}

; ========================================
; 2. RANDOM SOUND EFFECTS
; ========================================
^!s:: {  ; Ctrl+Alt+S for random sound effects
    static soundsOn := false
    soundsOn := !soundsOn
    
    if (soundsOn) {
        SetTimer(RandomSound, 5000)  ; Play a sound every 5 seconds
        TrayTip("Sound Effects", "Random sounds enabled!", "P1")
    } else {
        SetTimer(RandomSound, 0)
        TrayTip("Sound Effects", "Random sounds disabled", "P1")
    }
    SetTimer(RemoveTrayTip, -3000)
}

RandomSound() {
    soundType := Random(1, 5)
    
    switch soundType {
        case 1:
            ; Windows exclamation
            SoundPlay("*16")
        case 2:
            ; Beep
            SoundBeep(Random(200, 2000), Random(100, 500))
        case 3:
            ; System sound
            SoundPlay(A_WinDir "\Media\Windows Notify.wav")
        case 4:
            ; Random note
            freq := 220 * (2 ** (Random(1, 12)/12))  ; Equal temperament from A3
            SoundBeep(freq, 300)
        default:
            ; Random system sound
            SoundPlay("*")
    }
}

; ========================================
; 3. ANNOYING BEEP GENERATOR
; ========================================
^!b:: {  ; Ctrl+Alt+B for annoying beeps
    static beepOn := false
    beepOn := !beepOn
    
    if (beepOn) {
        SetTimer(AnnoyingBeep, 1000)
        TrayTip("Beep Generator", "Annoying beeps enabled!", "P1")
    } else {
        SetTimer(AnnoyingBeep, 0)
        TrayTip("Beep Generator", "Beeps disabled", "P1")
    }
    SetTimer(RemoveTrayTip, -3000)
}

AnnoyingBeep() {
    SoundBeep(Random(100, 2000), Random(50, 200))
}

; ========================================
; 4. RICKROLL (OF COURSE!)
; ========================================
^!r:: {  ; Ctrl+Alt+R for Rickroll
    ; Open the YouTube video in the default browser
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
    
    TrayTip("Never Gonna...", "Give you up!", "P1")
    SetTimer(RemoveTrayTip, -3000)
}

; ========================================
; 5. FAKE VIRUS SCAN
; ========================================
^!v:: {  ; Ctrl+Alt+V for fake virus scan
    scanGui := Gui("+AlwaysOnTop -Caption +ToolWindow", "Windows Defender")
    scanGui.BackColor := "000000"
    scanGui.SetFont("s12 cLime", "Consolas")
    
    scanGui.Add("Text", "x10 y10 w380 h20", "Scanning for viruses...")
    progressBar := scanGui.Add("Progress", "x10 y40 w380 h20 cRed vScanProgress", 0)
    logText := scanGui.Add("Text", "x10 y70 w380 h300 vScanLog", "Starting system scan...`n")
    
    scanGui.Show("w400 h400")
    
    ; Fake scan in progress
    scanText := ""
    scanGui.OnEvent("Close", (*) => scanGui.Destroy())
    SetTimer(UpdateVirusScan.Bind(scanGui( progressBar, logText, scanText), 500)
}

UpdateVirusScan(scanGui( progressBar, logText, &scanText) {
    static progress := 0
    static lastFile := ""
    
    if (progress >= 100) {
        SetTimer(, 0)
        logText.Value := scanText . "`nScan complete! 1 threat found.`n`nThreat: Win32.Prank.AHK`nLocation: C:\Windows\System32\prank.dll`nStatus: Quarantined"
        progress := 0
        return
    }
    
    ; Update progress
    progress += Random(1, 5)
    if (progress > 100)
        progress := 100
    
    progressBar.Value := progress
    
    ; Add fake log entries
    if (Mod(progress, 10) = 0) {
        files := [
            "C:\Windows\System32\kernel32.dll",
            "C:\Program Files\Common Files\system.ini",
            "C:\Users\Public\Documents\passwords.txt",
            "C:\Windows\Temp\tempfile.tmp",
            "C:\ProgramData\Microsoft\Windows\Start Menu\startup\suspicious.exe"
        ]
        
        lastFile := files[Random(1, files.Length)]
        scanText .= "Scanning: " lastFile "`n"
        
        ; Occasionally find a fake virus
        if (Random(1, 10) = 1) {
            scanText .= "  -> THREAT FOUND: Win32.Prank.AHK`n"
        } else {
            scanText .= "  -> Clean`n"
        }
        
        logText.Value := scanText
    }
}

; ========================================
; 6. KEYBOARD SOUNDS
; ========================================
^!k:: {  ; Ctrl+Alt+K for keyboard sounds
    static kbSoundsOn := false
    kbSoundsOn := !kbSoundsOn
    
    if (kbSoundsOn) {
        ; Register hotkeys for all alphanumeric keys and special characters
        keys := []
        
        ; Add a-z
        Loop 26 {
            keys.Push(Chr(A_Index + 96))  ; a-z
        }
        
        ; Add A-Z
        Loop 26 {
            keys.Push(Chr(A_Index + 64))  ; A-Z
        }
        
        ; Add 0-9
        Loop 10 {
            keys.Push(Chr(A_Index + 47))  ; 0-9
        }
        
        ; Add special characters
        specialChars := "!@#$%^&*()_+``-=\|[]{};':`",<.>/"
        Loop Parse, specialChars {
            keys.Push(A_LoopField)
        }
        ; Register hotkeys for all keys in the array
        for key in keys {
            Hotkey("*~$" key, KeySound.Bind(key))
        }
            
        ; Special keys
        Hotkey("*~$Space", KeySound.Bind("Space"))
        Hotkey("*~$Enter", KeySound.Bind("Enter"))
        Hotkey("*~$Backspace", KeySound.Bind("Backspace"))
        Hotkey("*~$Delete", KeySound.Bind("Delete"))
        Hotkey("*~$Tab", KeySound.Bind("Tab"))
        Hotkey("*~$Up", KeySound.Bind("Up"))
        Hotkey("*~$Down", KeySound.Bind("Down"))
        Hotkey("*~$Left", KeySound.Bind("Left"))
        Hotkey("*~$Right", KeySound.Bind("Right"))
        
        TrayTip("Keyboard Sounds", "Keyboard sounds enabled!", "P1")
    } else {
        ; Unregister all key hotkeys
        for key in keys {
            try Hotkey("*~$" key, "Off")
        }
        
        ; Unregister special keys
        for key in ["Space", "Enter", "Backspace", "Delete", "Tab", "Up", "Down", "Left", "Right"] {
            try Hotkey("*~$" key, "Off")
        }
        
        TrayTip("Keyboard Sounds", "Keyboard sounds disabled", "P1")
    }
    SetTimer(RemoveTrayTip, -3000)
}

KeySound(key) {
    static lastKey := ""
    static lastTime := 0
    
    ; Skip if this is an auto-repeat (key being held down)
    currentTime := A_TickCount
    if (A_ThisHotkey = A_PriorHotkey && (currentTime - lastTime) < 100) {
        lastTime := currentTime
        return
    }
    lastKey := key
    lastTime := currentTime
    
    ; Different sounds for different key types
    if (key = "Backspace" || key = "Delete") {
        SoundBeep(100, 50)
    } else if (key = "Enter" || key = "Space") {
        SoundBeep(200, 20)
    } else if (key = "Tab") {
        SoundBeep(300, 30)
    } else if (key = "Up" || key = "Down" || key = "Left" || key = "Right") {
        SoundBeep(400, 20)
    } else {
        ; Alphanumeric keys - use their ASCII value to generate a tone
        asc := Ord(key)
        if (asc >= 65 && asc <= 90)  ; A-Z
            freq := 300 + (asc - 65) * 20
        else if (asc >= 97 && asc <= 122)  ; a-z
            freq := 300 + (asc - 97) * 20
        else if (asc >= 48 && asc <= 57)  ; 0-9
            freq := 500 + (asc - 48) * 30
        else
            freq := 300 + Mod(asc, 500)  ; Other characters
            
        SoundBeep(freq, 20)
    }
}

; ========================================
; 7. SOUNDBOARD
; ========================================
^!p:: {  ; Ctrl+Alt+P for soundboard
    ; Create the soundboard GUI
    sbGui := Gui("+AlwaysOnTop +ToolWindow", "Sound Board")
    sbGui.BackColor := "F0F0F0"
    sbGui.SetFont("s10", "Segoe UI")
    
    ; Add sound buttons
    sbGui.Add("Button", "x10 y10 w120 h50", "Windows XP Error").OnEvent("Click", (*) => SoundPlay(A_WinDir "\\Media\\Windows Error.wav"))
    sbGui.Add("Button", "x140 y10 w120 h50", "Windows Notify").OnEvent("Click", (*) => SoundPlay(A_WinDir "\Media\Windows Notify.wav"))
    sbGui.Add("Button", "x270 y10 w120 h50", "Windows Logoff").OnEvent("Click", (*) => SoundPlay(A_WinDir "\\Media\\Windows Logoff Sound.wav"))
    sbGui.Add("Button", "x10 y70 w120 h50", "Windows Startup").OnEvent("Click", (*) => SoundPlay(A_WinDir "\\Media\\Windows Startup.wav"))
    sbGui.Add("Button", "x140 y70 w120 h50", "Windows Shutdown").OnEvent("Click", (*) => SoundPlay(A_WinDir "\\Media\\Windows Shutdown.wav"))
    sbGui.Add("Button", "x270 y70 w120 h50", "Tada").OnEvent("Click", (*) => SoundPlay(A_WinDir "\\Media\\tada.wav"))
    sbGui.Add("Button", "x10 y130 w120 h50", "Chimes").OnEvent("Click", (*) => SoundPlay(A_WinDir "\\Media\\chimes.wav"))
    sbGui.Add("Button", "x140 y130 w120 h50", "Ding").OnEvent("Click", (*) => SoundPlay(A_WinDir "\\Media\\ding.wav"))
    sbGui.Add("Button", "x270 y130 w120 h50", "Battery Low").OnEvent("Click", (*) => SoundPlay(A_WinDir "\\Media\\Windows Battery Low.wav"))
    
    ; Volume control
    sbGui.Add("Text", "x10 y190 w80 h20", "Volume:")
    volSlider := sbGui.Add("Slider", "x90 y190 w200 h20 Range0-100", 100)
    sbGui.Add("Button", "x300 y185 w90 h30", "Set Volume").OnEvent("Click", (*) => SetVolume(volSlider.Value, sbGui))
    
    sbGui.Show("w400 h230")
}

SetVolume(level, guiObj) {
    SoundSetVolume(level)
    TrayTip("Sound Board", "Volume set to " level "%", "P1")
    SetTimer(RemoveTrayTip, -2000)
}

; ========================================
; HELPER FUNCTIONS
; ========================================
RemoveTrayTip() {
    TrayTip()
}

; Clean up
OnExit(ExitFunc)

ExitFunc(ExitReason, ExitCode) {
    ; Stop all sounds and timers
    SoundPlay("*-1")
    SetTimer(, 0)  ; Stop all timers
}
