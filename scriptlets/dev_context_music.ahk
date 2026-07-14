#Requires AutoHotkey v2.0+
#SingleInstance Force
#Include %A_ScriptDir%\lib\ScriptletErrorHandler.ahk

; ==============================================================================
; Dev Context Music (System Sounds Edition)
; @name: Dev Context Music
; @version: 1.0.0
; @description: Context-aware sound effects for development workflows using Windows system sounds and beep patterns. Plays appropriate sounds based on build status, Git operations, and development events.
; @description: Provides audio feedback for build success/failure, repository status changes, test results, and deployment events. Enhances developer productivity with non-intrusive audio cues.
; @description: Uses Windows built-in system sounds and customizable beep patterns to create a rich audio development environment without requiring external audio files.
; @category: development
; @author: Sandra
; @hotkeys: 
; @enabled: true
; @priority: 25
; @tag: development, sounds, audio, feedback, build, git, productivity, workflow
; @cli: --context <context> - Play sound for specific context (build_success, build_failure, repo_bad, test_pass, deploy)
; @cli: --mute - Disable all sounds
; @cli: --volume <0-100> - Set sound volume (0-100)
; @cli: --help - Show CLI usage and available contexts
; @dependencies: 
; ==============================================================================

; Error handling - log to file instead of showing popups
OnError(LogError)

; ========================================
; CONFIGURATION
; ========================================

; System sound mappings - using Windows built-in sounds and beep patterns
; Each sound type has different beep patterns and system sounds

; ========================================
; SOUND FUNCTIONS
; ========================================

; Play a beep pattern for different contexts
PlayContextSound(context) {
    switch context {
        case "build_success":
            ; Happy ascending beeps
            SoundBeep(800, 100)
            Sleep(50)
            SoundBeep(1000, 100)
            Sleep(50)
            SoundBeep(1200, 200)
            SoundPlay("*64")  ; Asterisk (success sound)
            
        case "build_failure":
            ; Sad descending beeps
            SoundBeep(600, 200)
            Sleep(100)
            SoundBeep(400, 200)
            Sleep(100)
            SoundBeep(200, 300)
            SoundPlay("*16")  ; Hand (stop/error sound)
            
        case "repo_bad":
            ; Dramatic low beeps
            SoundBeep(100, 500)
            Sleep(200)
            SoundBeep(150, 500)
            SoundPlay("*48")  ; Exclamation
            
        case "repo_dirty":
            ; Busy rapid beeps
            Loop 5 {
                SoundBeep(800, 50)
                Sleep(50)
            }
            SoundPlay("*32")  ; Question
            
        case "test_failure":
            ; Funeral march pattern
            SoundBeep(300, 400)
            Sleep(200)
            SoundBeep(250, 400)
            Sleep(200)
            SoundBeep(200, 600)
            SoundPlay("*16")  ; Hand (error)
            
        case "test_success":
            ; Victory fanfare
            SoundBeep(523, 200)  ; C
            SoundBeep(659, 200)  ; E
            SoundBeep(784, 200)  ; G
            SoundBeep(1047, 400) ; C high
            SoundPlay("*64")  ; Success
            
        case "late_night":
            ; Slow, tired beeps
            SoundBeep(400, 300)
            Sleep(500)
            SoundBeep(350, 300)
            Sleep(500)
            SoundBeep(300, 400)
            
        case "early_morning":
            ; Cheerful wake-up beeps
            SoundBeep(600, 150)
            SoundBeep(800, 150)
            SoundBeep(1000, 150)
            SoundBeep(1200, 200)
            SoundPlay("*64")
            
        case "sad_march":
            ; Classic funeral march rhythm
            SoundBeep(200, 600)
            Sleep(100)
            SoundBeep(180, 600)
            Sleep(100)
            SoundBeep(160, 800)
            Sleep(300)
            SoundBeep(140, 1000)
            
        case "triumphant":
            ; Royal fanfare
            SoundBeep(1000, 200)
            SoundBeep(1200, 200)
            SoundBeep(1500, 200)
            Sleep(100)
            SoundBeep(1000, 200)
            SoundBeep(1200, 200)
            SoundBeep(1500, 400)
            SoundPlay("*64")
            
        case "betty_boop":
            ; Playful cartoon-like beeps
            SoundBeep(800, 100)
            SoundBeep(1000, 100)
            SoundBeep(800, 100)
            SoundBeep(600, 100)
            SoundBeep(800, 200)
            
        case "classical":
            ; Simple classical melody pattern
            SoundBeep(523, 200)  ; C
            SoundBeep(587, 200)  ; D
            SoundBeep(659, 200)  ; E
            SoundBeep(698, 200)  ; F
            SoundBeep(784, 400)  ; G
            
        default:
            ; Default system beep
            SoundPlay("*64")
    }
}

; ========================================
; CONTEXT-AWARE MUSIC TRIGGERS
; ========================================

; Check build status (example implementation)
CheckBuildStatus() {
    ; This would check your build system
    ; For now, we'll just return a random status
    status := Random(1, 10)
    if (status > 7) {
        PlayContextSound("build_failure")
        TrayTip("Build failed! Playing sad music...", "Build Status", 1)
    } else {
        PlayContextSound("build_success")
        TrayTip("Build succeeded! Celebrating...", "Build Status", 1)
    }
    SetTimer(() => TrayTip(), -3000)
}

; Check repository health (example implementation)
CheckRepoHealth() {
    ; This would check git status, number of changes, etc.
    ; For now, we'll just return a random status
    status := Random(1, 10)
    if (status > 8) {
        PlayContextSound("repo_bad")
        TrayTip("Critical issues found! Playing dramatic music...", "Repository Health", 1)
    } else if (status > 5) {
        PlayContextSound("repo_dirty")
        TrayTip("Many uncommitted changes. Time to commit!", "Repository Health", 1)
    }
    SetTimer(() => TrayTip(), -3000)
}

; ========================================
; MANUAL TRIGGERS
; ========================================

; Play a sad march
Hotkey("^!s", (*) => PlaySadMarch())  ; Ctrl+Alt+S for sad march

; Play a triumphant piece
Hotkey("^!t", (*) => PlayTriumphant())  ; Ctrl+Alt+T for triumphant music

; Play a random Betty Boop cartoon
Hotkey("^!b", (*) => PlayBettyBoop())  ; Ctrl+Alt+B for Betty Boop

; Play a classical piece
Hotkey("^!c", (*) => PlayClassical())  ; Ctrl+Alt+C for classical

; ========================================
; TIME-BASED TRIGGERS
; ========================================

; Check time and play appropriate music
CheckTime() {
    hourStr := FormatTime(A_Now, "H")
    hour := Integer(hourStr)  ; 24-hour format
    
    if (hour >= 22 || hour < 6) {
        ; Late night coding
        chance := Random(1, 3)
        if (chance = 1) {  ; 1 in 3 chance
            PlayContextSound("late_night")
            TrayTip("Playing some late night coding music... 🌙", "Late Night", 1)
            SetTimer(() => TrayTip(), -3000)
        }
    } else if (hour >= 5 && hour < 9) {
        ; Early morning
        chance := Random(1, 4)
        if (chance = 1) {  ; 1 in 4 chance
            PlayContextSound("early_morning")
            TrayTip("Rise and shine! ☀️", "Good Morning", 1)
            SetTimer(() => TrayTip(), -3000)
        }
    }
}

; ========================================
; AUTOMATIC CHECKS
; ========================================

; Check time every 30 minutes
SetTimer(CheckTime, 1800000)

; Check repository health every hour
SetTimer(CheckRepoHealth, 3600000)

; ========================================
; TRAY MENU
; ========================================

A_TrayMenu.Delete()
A_TrayMenu.Add("🎵 &Open Launcher", (*) => ShowLauncher())
A_TrayMenu.Add()
A_TrayMenu.Add("😢 &Sad March (Ctrl+Alt+S)", (*) => PlaySadMarch())
A_TrayMenu.Add("🎺 &Triumphant Music (Ctrl+Alt+T)", (*) => PlayTriumphant())
A_TrayMenu.Add("🎭 &Betty Boop (Ctrl+Alt+B)", (*) => PlayBettyBoop())
A_TrayMenu.Add("🎼 &Classical (Ctrl+Alt+C)", (*) => PlayClassical())
A_TrayMenu.Add()
A_TrayMenu.Add("🔧 &Check Build Status", (*) => CheckBuildStatus())
A_TrayMenu.Add("📁 Check &Repository Health", (*) => CheckRepoHealth())
A_TrayMenu.Add()
A_TrayMenu.Add("🔄 &Reload", (*) => Reload())
A_TrayMenu.Add("❌ E&xit", (*) => ExitApp())
A_TrayMenu.Default := "🎵 &Open Launcher"

PlaySadMarch() {
    PlayContextSound("sad_march")
    TrayTip("Playing a sad march... 😢", "Mood Music", 1)
    SetTimer(() => TrayTip(), -3000)
}

PlayTriumphant() {
    PlayContextSound("triumphant")
    TrayTip("Playing something triumphant! 🎺", "Mood Music", 1)
    SetTimer(() => TrayTip(), -3000)
}

PlayBettyBoop() {
    PlayContextSound("betty_boop")
    TrayTip("Betty Boop beep-a-boop! 🎭", "Plex", 1)
    SetTimer(() => TrayTip(), -3000)
}

PlayClassical() {
    PlayContextSound("classical")
    TrayTip("Playing a classical piece... 🎼", "Classical Music", 1)
    SetTimer(() => TrayTip(), -3000)
}

ShowLauncher() {
    MsgBox("Dev Context Music - System Beeper Edition`n`nHotkeys:`n- Ctrl+Alt+S: Sad March`n- Ctrl+Alt+T: Triumphant Music`n- Ctrl+Alt+B: Betty Boop`n- Ctrl+Alt+C: Classical Music`n`nAuto Features:`n- Build status sounds`n- Repository health alerts`n- Time-based ambiance`n`nAll sounds use system beeper!", "Dev Context Music", 64)
}

; ========================================
; INITIALIZATION
; ========================================

; Show welcome message with startup fanfare
PlayContextSound("early_morning")
TrayTip("🎵 Music system ready! Press Ctrl+Alt+S/T/B/C to test!", "Dev Context Music", 1)
SetTimer(() => TrayTip(), -4000)

; Initial time check
CheckTime()


