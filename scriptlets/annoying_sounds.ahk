#Requires AutoHotkey v2.0+
#SingleInstance Force
SendMode "Input"
SetWorkingDir(A_ScriptDir)

; Suppress error popups - log to file AND stdout for LLM debugging
OnError(LogError)

LogError(Thrown, Mode) {
    errorMsg := "Error: " . Thrown.Message . " at line " . Thrown.Line . "`n" . Thrown.Stack
    FileAppend(errorMsg, "errors.log", "UTF-8")
    OutputDebug(errorMsg)  ; Enable LLM debugging
    return 1  ; Suppress popup (1 = suppress, 0 = show)
}

#MaxHotkeysPerInterval 200
#Persistent

; ========================================
; 1. ELEVATOR MUSIC PLAYER
; ========================================
class AnnoyingSounds {
    static musicPlaying := false
    static soundsOn := false
    static beepOn := false
    static kbSoundsOn := false
    static progress := 0
    static scanText := ""
    static virusGui := ""
    
    static Init() {
        Hotkey("^!m", (*) => this.PlayElevatorMusic())
        Hotkey("^!s", (*) => this.RandomSoundEffects())
        Hotkey("^!b", (*) => this.AnnoyingBeep())
        Hotkey("^!r", (*) => this.Rickroll())
        Hotkey("^!v", (*) => this.FakeVirusScan())
        Hotkey("^!k", (*) => this.KeyboardSounds())
        
        ; TrayTip removal
        SetTimer(() => this.RemoveTrayTip(), -3000)
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
            TrayTip("Elevator Music", "Now playing smooth elevator music...", , 1)
        } else {
            ; Stop the music
            SetTimer(() => this.PlayElevatorNote(), 0)  ; Stop timer
            SoundPlay("*-1")  ; Stop any playing sound
            this.musicPlaying := false
            TrayTip("Elevator Music", "Music stopped", , 1)
        }
    }
    
    static PlayElevatorNote() {
        ; Play some random notes
        Random(note, 1, 7)
        notes := [262, 294, 330, 349, 392, 440, 494]  ; C4 to B4
        SoundBeep(notes[note], 200)
    }
    
    static RandomSoundEffects(*) {
        this.soundsOn := !this.soundsOn
        
        if (this.soundsOn) {
            this.soundTimer := SetTimer(() => this.RandomSound(), 5000)
            TrayTip("Sound Effects", "Random sounds enabled!", , 1)
        } else {
            SetTimer(() => this.RandomSound(), 0)
            TrayTip("Sound Effects", "Random sounds disabled", , 1)
        }
    }
    
    static RandomSound() {
        Random(soundType, 1, 5)
        
        switch soundType {
            case 1:
                SoundPlay("*16")
            case 2:
                Random(freq, 200, 2000)
                Random(dur, 100, 500)
                SoundBeep(freq, dur)
            case 3:
                SoundPlay(A_WinDir "\Media\Windows Notify.wav")
            case 4:
                Random(note, 1, 12)
                freq := 220 * (2 ** (note/12))  ; Equal temperament from A3
                SoundBeep(freq, 300)
            default:
                SoundPlay("*")
        }
    }
    
    static AnnoyingBeep(*) {
        this.beepOn := !this.beepOn
        
        if (this.beepOn) {
            this.beepTimer := SetTimer(() => this.DoBeep(), 1000)
            TrayTip("Beep Generator", "Annoying beeps enabled!", , 1)
        } else {
            SetTimer(() => this.DoBeep(), 0)
            TrayTip("Beep Generator", "Beeps disabled", , 1)
        }
    }
    
    static DoBeep() {
        Random(freq, 100, 2000)
        Random(dur, 50, 200)
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
        
        TrayTip("Never Gonna...", "Give you up!", , 1)
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
            scanLogCtrl.Text := this.scanText . "`nScan complete! 1 threat found.`n`nThreat: Win32.Prank.AHK`nLocation: C:\Windows\System32\prank.dll`nStatus: Quarantined"
            this.progress := 0
            return
        }
        
        ; Update progress
        Random(increment, 1, 5)
        this.progress += increment
        if (this.progress > 100)
            this.progress := 100
        
        scanProgressCtrl := this.virusGui["ScanProgress"]
        scanProgressCtrl.Value := this.progress
        
        ; Add fake log entries
        if (Mod(this.progress, 10) = 0) {
            files := ["C:\Windows\System32\kernel32.dll", "C:\Program Files\Common Files\system.ini", "C:\Users\Public\Documents\passwords.txt", "C:\Windows\Temp\tempfile.tmp", "C:\ProgramData\Microsoft\Windows\Start Menu\startup\suspicious.exe"]
            Random(rand, 1, files.Length)
            lastFile := files[rand]
            this.scanText .= "Scanning: " . lastFile . "`n"
            
            ; Occasionally find a fake virus
            if (Random(1, 10) = 1) {
                this.scanText .= "  -> THREAT FOUND: Win32.Prank.AHK`n"
            } else {
                this.scanText .= "  -> Clean`n"
            }
            
            scanLogCtrl := this.virusGui["ScanLog"]
            scanLogCtrl.Text := this.scanText
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
            TrayTip("Keyboard Sounds", "Typewriter mode enabled!", , 1)
        } else {
            Hotkey("*~a", "Off")
            Hotkey("*~b", "Off")
            Hotkey("*~c", "Off")
            TrayTip("Keyboard Sounds", "Typewriter mode disabled", , 1)
        }
    }
    
    static PlayKeySound(*) {
        Random(pitch, 100, 1000)
        Random(duration, 10, 30)
        SoundBeep(pitch, duration)
    }
    
    static RemoveTrayTip() {
        TrayTip()
    }
    
    static Cleanup(*) {
        ; Stop all sounds and timers
        SoundPlay("*-1")
        SetTimer(() => this.PlayElevatorNote(), 0)
        SetTimer(() => this.RandomSound(), 0)
        SetTimer(() => this.DoBeep(), 0)
        SetTimer(() => this.UpdateVirusScan(), 0)
        
        ; Close all GUIs
        if (this.virusGui)
            this.virusGui.Destroy()
        
        ; Turn off keyboard sounds
        Hotkey("*~a", "Off")
        Hotkey("*~b", "Off")
        Hotkey("*~c", "Off")
        
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
