#Requires AutoHotkey v2.0+
#SingleInstance Force
#Include %A_ScriptDir%\lib\ScriptletErrorHandler.ahk
SendMode "Input"
SetWorkingDir(A_ScriptDir)

; ==============================================================================
; Annoying Sounds Collection
; @name: Annoying Sounds Collection
; @version: 2.0.0
; @description: Collection of annoying sound effects including sirens, farts, tittering, beeps, elevator music, keyboard sounds, and prank features.
; @description: Supports custom sound files from a "sounds" folder. Auto-detects external .wav/.mp3 files or synthesizes sounds using system beeps.
; @description: Perfect for harmless pranks and entertainment. Includes fake virus scanner GUI for maximum annoyance.
; @category: fun
; @author: Sandra
; @hotkeys: ^!m, ^!s, ^!b, ^!r, ^!v, ^!k, ^!f, ^!t, ^!w
; @enabled: false
; @priority: 90
; @tag: sounds, pranks, fun, annoying, entertainment, effects, siren, fart, tittering
; @cli: --sound-dir <path> - Set custom sound files directory (default: ./sounds)
; @cli: --enable <feature> - Enable specific feature: siren, fart, tittering, beep, music, keyboard
; @cli: --disable <feature> - Disable specific feature
; @cli: --list-sounds - List available sound files in the sounds directory
; @cli: --help - Show CLI usage information
; @dependencies: 
; ==============================================================================
; Sound file sources:
; - Freesound.org (https://freesound.org) - Free CC0/CC BY sounds
; - Zapsplat (https://zapsplat.com) - Free with account
; - Pixabay (https://pixabay.com/music/search/sound%20effects/) - Free sounds
; - YouTube Audio Library - Free to use sounds
; - Windows System Sounds: A_WinDir "\Media\*.wav"
; 
; Recommended sound file locations:
; - Create a "sounds" folder in the script directory
; - Place .wav or .mp3 files there (fart.wav, siren.wav, tittering.wav, etc.)
; - Script will auto-detect if files exist, otherwise uses synthesized sounds
; ==============================================================================

; Error handling - log to file instead of showing popups
OnError(LogError)

A_MaxHotkeysPerInterval := 200
Persistent(true)

class AnnoyingSounds {
    static musicPlaying := false
    static soundsOn := false
    static beepOn := false
    static kbSoundsOn := false
    static progress := 0
    static scanText := ""
    static virusGui := ""
    static sirenPlaying := false
    static titteringPlaying := false
    static soundFilesPath := A_ScriptDir "\sounds"
    
    static Init() {
        ; Create sounds directory if it doesn't exist
        if (!DirExist(this.soundFilesPath)) {
            try {
                DirCreate(this.soundFilesPath)
                this.LogDebug("Created sounds directory: " . this.soundFilesPath)
            } catch as e {
                this.LogDebug("Could not create sounds directory: " . e.Message)
            }
        }
        
        Hotkey("^!m", (*) => this.PlayElevatorMusic())
        Hotkey("^!s", (*) => this.RandomSoundEffects())
        Hotkey("^!b", (*) => this.AnnoyingBeep())
        Hotkey("^!r", (*) => this.Rickroll())
        Hotkey("^!v", (*) => this.FakeVirusScan())
        Hotkey("^!k", (*) => this.KeyboardSounds())
        Hotkey("^!f", (*) => this.PlayFart())          ; Ctrl+Alt+F for fart
        Hotkey("^!t", (*) => this.PlayTittering())     ; Ctrl+Alt+T for tittering
        Hotkey("^!w", (*) => this.PlaySiren())         ; Ctrl+Alt+W for siren (warning)
        
        ; TrayTip removal
        SetTimer(() => this.RemoveTrayTip(), -3000)
        
        this.LogDebug("Annoying Sounds initialized")
    }
    
    static LogDebug(message) {
        timestamp := ""
        timestamp := FormatTime(, "HH:mm:ss")
        logMsg := "[" . timestamp . "] " . message . "`n"
        try {
            FileAppend(logMsg, "annoying_sounds_debug.log", "UTF-8")
        } catch {
            ; Ignore file logging errors
        }
        OutputDebug(logMsg)
    }
    
    static PlayElevatorMusic(*) {
        this.musicPlaying := !this.musicPlaying
        
        if (this.musicPlaying) {
            ; Start playing elevator music
            SoundPlay("*16")
            SoundBeep(523, 300)  ; C
            SoundBeep(587, 300)  ; D
            SoundBeep(659, 300)  ; E
            
            ; Start the music loop
            this.musicTimer := SetTimer(() => this.PlayElevatorNote(), 5000)
            this.ShowTrayTip("Elevator Music", "Now playing smooth elevator music...")
        } else {
            ; Stop the music
            SetTimer(() => this.PlayElevatorNote(), 0)  ; Stop timer
            SoundPlay("*-1")  ; Stop any playing sound
            this.musicPlaying := false
            this.ShowTrayTip("Elevator Music", "Music stopped")
        }
    }
    
    static PlayElevatorNote() {
        ; Play some random notes
        note := Random(1, 7)
        notes := [262, 294, 330, 349, 392, 440, 494]  ; C4 to B4
        SoundBeep(notes[note], 200)
    }
    
    static RandomSoundEffects(*) {
        this.soundsOn := !this.soundsOn
        
        if (this.soundsOn) {
            this.soundTimer := SetTimer(() => this.RandomSound(), 5000)
            this.ShowTrayTip("Sound Effects", "Random sounds enabled!")
        } else {
            SetTimer(() => this.RandomSound(), 0)
            this.ShowTrayTip("Sound Effects", "Random sounds disabled")
        }
    }
    
    static RandomSound() {
        soundType := Random(1, 8)
        
        switch soundType {
            case 1:
                SoundPlay("*16")
            case 2:
                freq := Random(200, 2000)
                dur := Random(100, 500)
                SoundBeep(freq, dur)
            case 3:
                SoundPlay(A_WinDir "\Media\Windows Notify.wav")
            case 4:
                note := Random(1, 12)
                freq := 220 * (2 ** (note/12))  ; Equal temperament from A3
                SoundBeep(freq, 300)
            case 5:
                this.PlayFartSound()
            case 6:
                this.PlaySirenSound(false)
            case 7:
                this.PlayTitteringSound(false)
            default:
                SoundPlay("*")
        }
    }
    
    static PlayFart() {
        this.PlayFartSound()
        this.ShowTrayTip("Fart Sound", "💨 Toot toot!")
    }
    
    static PlayFartSound() {
        ; Try to play custom fart sound file, otherwise use system sound
        fartFiles := [this.soundFilesPath "\fart.wav", this.soundFilesPath "\fart.mp3", this.soundFilesPath "\fart1.wav"]
        
        for file in fartFiles {
            if (FileExist(file)) {
                try {
                    SoundPlay(file)
                    this.LogDebug("Played fart sound: " . file)
                    return
                } catch as e {
                    this.LogDebug("Error playing fart sound: " . e.Message)
                }
            }
        }
        
        ; Fallback: Synthesize a fart-like sound
        type := Random(1, 3)
        switch type {
            case 1:
                ; Low rumble
                SoundBeep(50, 200)
                Sleep(50)
                SoundBeep(60, 150)
            case 2:
                ; Quick toot
                SoundBeep(100, 80)
                Sleep(30)
                SoundBeep(120, 60)
            default:
                SoundPlay("*48")  ; Windows error sound as fallback
        }
    }
    
    static PlaySiren() {
        this.sirenPlaying := !this.sirenPlaying
        
        if (this.sirenPlaying) {
            this.sirenTimer := SetTimer(() => this.PlaySirenSound(true), 500)
            this.ShowTrayTip("Siren", "🚨 Siren activated!")
        } else {
            SetTimer(() => this.PlaySirenSound(true), 0)
            SoundPlay("*-1")  ; Stop all sounds
            this.ShowTrayTip("Siren", "Siren stopped")
        }
    }
    
    static PlaySirenSound(loopMode := true) {
        ; Try to play custom siren sound file
        sirenFiles := [this.soundFilesPath "\siren.wav", this.soundFilesPath "\siren.mp3", 
                       this.soundFilesPath "\police_siren.wav", this.soundFilesPath "\ambulance.wav"]
        
        for file in sirenFiles {
            if (FileExist(file)) {
                try {
                    SoundPlay(file, (loopMode ? "Wait" : ""))
                    this.LogDebug("Played siren sound: " . file)
                    return
                } catch as e {
                    this.LogDebug("Error playing siren sound: " . e.Message)
                }
            }
        }
        
        ; Fallback: Synthesize siren sound (alternating high/low tones)
        static sirenState := 0
        sirenState := !sirenState
        
        if (sirenState) {
            SoundBeep(800, 200)  ; High tone
        } else {
            SoundBeep(400, 200)  ; Low tone
        }
    }
    
    static PlayTittering() {
        this.titteringPlaying := !this.titteringPlaying
        
        if (this.titteringPlaying) {
            this.titterTimer := SetTimer(() => this.PlayTitteringSound(true), 800)
            this.ShowTrayTip("Tittering", "😄 Giggle mode activated!")
        } else {
            SetTimer(() => this.PlayTitteringSound(true), 0)
            this.ShowTrayTip("Tittering", "Giggles stopped")
        }
    }
    
    static PlayTitteringSound(loopMode := true) {
        ; Try to play custom tittering/laugh sound file
        titterFiles := [this.soundFilesPath "\tittering.wav", this.soundFilesPath "\tittering.mp3",
                        this.soundFilesPath "\giggle.wav", this.soundFilesPath "\laugh.wav",
                        this.soundFilesPath "\giggle1.wav", this.soundFilesPath "\titter.wav"]
        
        for file in titterFiles {
            if (FileExist(file)) {
                try {
                    SoundPlay(file, (loopMode ? "" : "Wait"))
                    this.LogDebug("Played tittering sound: " . file)
                    return
                } catch as e {
                    this.LogDebug("Error playing tittering sound: " . e.Message)
                }
            }
        }
        
        ; Fallback: Synthesize tittering sound (high-pitched giggles)
        giggleType := Random(1, 3)
        switch giggleType {
            case 1:
                ; Quick giggle
                SoundBeep(800, 50)
                Sleep(30)
                SoundBeep(1000, 60)
                Sleep(40)
                SoundBeep(900, 50)
            case 2:
                ; Longer laugh
                SoundBeep(700, 80)
                Sleep(50)
                SoundBeep(950, 100)
                Sleep(60)
                SoundBeep(850, 80)
            default:
                ; Silly sound
                SoundBeep(1200, 40)
                Sleep(20)
                SoundBeep(1100, 40)
                Sleep(20)
                SoundBeep(1000, 40)
        }
    }
    
    static AnnoyingBeep(*) {
        this.beepOn := !this.beepOn
        
        if (this.beepOn) {
            this.beepTimer := SetTimer(() => this.DoBeep(), 1000)
            this.ShowTrayTip("Beep Generator", "Annoying beeps enabled!")
        } else {
            SetTimer(() => this.DoBeep(), 0)
            this.ShowTrayTip("Beep Generator", "Beeps disabled")
        }
    }
    
    static DoBeep() {
        freq := Random(100, 2000)
        dur := Random(50, 200)
        SoundBeep(freq, dur)
    }
    
    static Rickroll(*) {
        ; Open the YouTube video
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
        
        this.ShowTrayTip("Never Gonna...", "Give you up!")
    }
    
    static FakeVirusScan(*) {
        ; Create virus scan GUI
        this.virusGui := Gui("+AlwaysOnTop -Caption +ToolWindow", "Windows Defender")
        this.virusGui.BackColor := "000000"
        this.virusGui.SetFont("s12 cLime", "Consolas")
        
        this.virusGui.Add("Text", "x10 y10 w380 h20", "Scanning for viruses...")
        
        scanProgress := this.virusGui.Add("Progress", "x10 y40 w380 h20 cRed vScanProgress", "Range0-100")
        scanProgress.Value := 0
        
        scanLog := this.virusGui.Add("Edit", "x10 y70 w380 h300 ReadOnly vScanLog", "Starting system scan...`n")
        scanLog.SetFont("s10 cLime")
        
        this.virusGui.OnEvent("Close", (*) => this.CloseVirusScan())
        
        this.virusGui.Show("w400 h400")
        
        ; Reset progress
        this.progress := 0
        this.scanText := "Starting system scan...`n"
        
        ; Start fake scan
        this.scanTimer := SetTimer(() => this.UpdateVirusScan(), 500)
    }
    
    static UpdateVirusScan() {
        if (this.progress >= 100) {
            SetTimer(() => this.UpdateVirusScan(), 0)
            ; Get the scan log control
            scanLogCtrl := this.virusGui["ScanLog"]
            scanLogCtrl.Value := this.scanText . "`nScan complete! 1 threat found.`n`nThreat: Win32.Prank.AHK`nLocation: C:\Windows\System32\prank.dll`nStatus: Quarantined"
            this.progress := 0
            return
        }
        
        ; Update progress
        increment := Random(1, 5)
        this.progress += increment
        if (this.progress > 100)
            this.progress := 100
        
        scanProgressCtrl := this.virusGui["ScanProgress"]
        scanProgressCtrl.Value := this.progress
        
        ; Add fake log entries
        if (Mod(this.progress, 10) = 0) {
            files := ["C:\Windows\System32\kernel32.dll", "C:\Program Files\Common Files\system.ini", "C:\Users\Public\Documents\passwords.txt", "C:\Windows\Temp\tempfile.tmp", "C:\ProgramData\Microsoft\Windows\Start Menu\startup\suspicious.exe"]
            rand := Random(1, files.Length)
            lastFile := files[rand]
            this.scanText .= "Scanning: " . lastFile . "`n"
            
            ; Occasionally find a fake virus
            if (Random(1, 10) = 1) {
                this.scanText .= "  -> THREAT FOUND: Win32.Prank.AHK`n"
            } else {
                this.scanText .= "  -> Clean`n"
            }
            
            scanLogCtrl := this.virusGui["ScanLog"]
            scanLogCtrl.Value := this.scanText
        }
    }
    
    static CloseVirusScan(*) {
        if (this.virusGui) {
            SetTimer(() => this.UpdateVirusScan(), 0)
            this.virusGui.Destroy()
            this.virusGui := ""
            this.progress := 0
            this.scanText := ""
        }
    }
    
    static KeyboardSounds(*) {
        this.kbSoundsOn := !this.kbSoundsOn
        
        if (this.kbSoundsOn) {
            Hotkey("*~a", (*) => this.PlayKeySound(), "On")
            Hotkey("*~b", (*) => this.PlayKeySound(), "On")
            Hotkey("*~c", (*) => this.PlayKeySound(), "On")
            this.ShowTrayTip("Keyboard Sounds", "Typewriter mode enabled!")
        } else {
            Hotkey("*~a", "Off")
            Hotkey("*~b", "Off")
            Hotkey("*~c", "Off")
            this.ShowTrayTip("Keyboard Sounds", "Typewriter mode disabled")
        }
    }
    
    static PlayKeySound(*) {
        pitch := Random(100, 1000)
        duration := Random(10, 30)
        SoundBeep(pitch, duration)
    }
    
    static RemoveTrayTip() {
        TrayTip()
    }

    static ShowTrayTip(title, message) {
        TrayTip(title, message)
    }
    
    static Cleanup(*) {
        ; Stop all sounds and timers
        SoundPlay("*-1")
        SetTimer(() => this.PlayElevatorNote(), 0)
        SetTimer(() => this.RandomSound(), 0)
        SetTimer(() => this.DoBeep(), 0)
        SetTimer(() => this.UpdateVirusScan(), 0)
        SetTimer(() => this.PlaySirenSound(true), 0)
        SetTimer(() => this.PlayTitteringSound(true), 0)
        
        ; Close all GUIs
        if (this.virusGui) {
            try {
                this.virusGui.Destroy()
            } catch {
                ; Ignore GUI cleanup errors
            }
        }
        
        ; Turn off keyboard sounds
        Hotkey("*~a", "Off")
        Hotkey("*~b", "Off")
        Hotkey("*~c", "Off")
        
        this.LogDebug("Cleanup completed")
        ExitApp()
    }
}

; Initialize
AnnoyingSounds.Init()

; Handle GUI close events
OnExit((*) => AnnoyingSounds.Cleanup())

; Keep running
Loop {
    Sleep(1000)
}
