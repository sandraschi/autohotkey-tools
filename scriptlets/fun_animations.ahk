#Requires AutoHotkey v2.0+
#SingleInstance Force
#Include %A_ScriptDir%\lib\ScriptletErrorHandler.ahk

; ==============================================================================
; Fun Animations Collection
; @name: Fun Animations
; @version: 1.0.0
; @description: Collection of fun animated effects and visual pranks including self-destruct countdown, flying cows, and screen animations.
; @description: Provides entertaining visual effects for harmless pranks and amusement. Includes countdown timers, animated sprites, and screen overlays.
; @description: Perfect for adding humor to work environments or demonstrations. Use responsibly for entertainment purposes.
; @category: fun
; @author: Sandra
; @hotkeys: ^!d, ^!c
; @enabled: true
; @priority: 85
; @tag: animations, fun, pranks, entertainment, visual-effects, humor, harmless
; @cli: --animation <name> - Run specific animation (self-destruct, cows)
; @cli: --countdown <seconds> - Set countdown duration (default: 10)
; @cli: --help - Show CLI usage and animation options
; @dependencies: 
; ==============================================================================

SendMode "Input"
SetWorkingDir(A_ScriptDir)

; Error handling - log to file instead of showing popups
OnError(LogError)

class FunAnimations {
    static countdownGui := ""
    static countdownText := ""
    static count := 0
    static cowGui := ""
    static cowDisplay := ""
    static herd := []
    
    static Init() {
        Hotkey("^!d", (*) => this.SelfDestruct())
        Hotkey("^!c", (*) => this.ShowCows())
    }
    
    static SelfDestruct() {
        ; Destroy any existing GUI
        try {
            if (this.countdownGui) {
                this.countdownGui.Destroy()
            }
        } catch as e {
            ; Ignore errors
        }
        
        ; Create new GUI
        this.countdownGui := Gui("+AlwaysOnTop +ToolWindow -Caption", "SELF DESTRUCT SEQUENCE")
        this.countdownGui.BackColor := "000000"
        this.countdownGui.SetFont("s24 cRed", "Consolas")
        
        this.countdownText := this.countdownGui.Add("Text", "w400 h100 Center vCountdown", "")
        this.countdownGui.Show("w400 h100")
        
        ; Speak warning
        Speak("Warning! PC will self-destruct in 10 seconds")
        
        ; Start countdown
        this.count := 10
        SetTimer(() => this.UpdateCountdown(), 1000)
    }
    
    static UpdateCountdown() {
        if (this.count > 0) {
            if (this.countdownText) {
                this.countdownText.Text := "SELF DESTRUCT IN: " . this.count
            }
            if (this.count <= 5) {
                Speak(this.count)
            }
            this.count--
        } else {
            SetTimer(() => this.UpdateCountdown(), 0)  ; Stop timer
            if (this.countdownText) {
                this.countdownText.Text := "BOOM!"
            }
            Speak("Boom!")
            
            ; Explosion effect
            this.countdownGui.BackColor := "FFFF00"
            Sleep(500)
            this.countdownGui.BackColor := "FF0000"
            Sleep(500)
            this.countdownGui.Destroy()
            this.countdownGui := ""
            this.countdownText := ""
        }
    }
    
    static ShowCows() {
        ; Destroy any existing GUI
        try {
            if (this.cowGui) {
                this.cowGui.Destroy()
            }
        } catch as e {
            ; Ignore errors
        }
        
        ; Create new GUI
        this.cowGui := Gui("+AlwaysOnTop -Caption +ToolWindow", "ASCII Cows")
        this.cowGui.BackColor := "000000"
        this.cowGui.SetFont("s12 cLime", "Consolas")
        
        ; Cow ascii art
        cow1 := " (__)    "
        cow2 := " (oo)    "
        cow3 := "/----\/  "
        cow4 := "|    |   "
        cow5 := "^^  ^^   "
        
        ; Create herd
        this.herd := []
        Loop 3 {  ; 3 cows
            cow := Map("x", -100 * A_Index, "y", A_Index * 5, "speed", 2 + A_Index)
            cow["line1"] := cow1
            cow["line2"] := cow2
            cow["line3"] := cow3
            cow["line4"] := cow4
            cow["line5"] := cow5
            this.herd.Push(cow)
        }
        
        ; Create display
        this.cowDisplay := this.cowGui.Add("Edit", "x0 y0 w800 h300 ReadOnly vCowDisplay", "")
        this.cowDisplay.SetFont("s12 cLime")
        
        this.cowGui.OnEvent("Close", (*) => this.CloseCows())
        
        ; Start animation
        this.cowGui.Show("w800 h300")
        SetTimer(() => this.MoveCows(), 50)
    }
    
    static MoveCows() {
        if (!this.cowGui || !this.cowDisplay) {
            return
        }
        
        ; Update cow positions and draw
        displayText := ""
        
        for cow in this.herd {
            cow["x"] += cow["speed"]
            if (cow["x"] > 800) {
                cow["x"] := -100
            }
            
            ; Add spacing for position
            Loop cow["x"] {
                spacer .= " "
            }
            
            ; Add cow lines
            displayText .= spacer . cow["line1"] . "`n"
            displayText .= spacer . cow["line2"] . "`n"
            displayText .= spacer . cow["line3"] . "`n"
            displayText .= spacer . cow["line4"] . "`n"
            displayText .= spacer . cow["line5"] . "`n`n"
            
            spacer := ""
        }
        
        ; Update display
        this.cowDisplay.Text := displayText
    }
    
    static CloseCows() {
        SetTimer(() => this.MoveCows(), 0)  ; Stop timer
        if (this.cowGui) {
            this.cowGui.Destroy()
            this.cowGui := ""
            this.cowDisplay := ""
        }
    }
}

; Text-to-Speech function
Speak(text) {
    try {
        oVoice := ComObject("SAPI.SpVoice")
        oVoice.Speak(text, 1)
        oVoice := ""
    } catch as unused {
        ; Ignore TTS errors
    }
}

; Initialize
FunAnimations.Init()

; Keep running
Loop {
    Sleep(1000)
}
