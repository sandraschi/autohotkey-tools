#NoEnv
#SingleInstance Force
#MaxHotkeysPerInterval 200
SendMode Input
SetWorkingDir %A_ScriptDir%

; Self Destruct Sequence
^!d::  ; Ctrl+Alt+D for self-destruct
    ; Create GUI for countdown
    Gui( Destroy
    Gui( Color, 000000
    Gui( Font, s24 cRed, Consolas
    Gui( Add, Text, vCountdown w400 h100 Center, 
    Gui( +AlwaysOnTop +ToolWindow -Caption
    Gui( Show, w400 h100, SELF DESTRUCT SEQUENCE
    
    ; Speak the warning
    Speak("Warning! PC will self-destruct in 10 seconds")
    
    ; Start countdown
    count := 10
    SetTimer, UpdateCountdown, 1000
    return

UpdateCountdown:
    if (count > 0) {
        GuiControl,, Countdown, % "SELF DESTRUCT IN: " count
        if (count <= 5) {
            Speak(count)
        }
        count--
    } else {
        SetTimer, UpdateCountdown, Off
        GuiControl,, Countdown, BOOM!
        Speak("Boom!")
        ; Create explosion effect
        Gui( Color, FFFF00
        Sleep, 500
        Gui( Color, FF0000
        Sleep, 500
        Gui( Destroy
    }
    return

; ASCII Cows
^!c::  ; Ctrl+Alt+C for ASCII cows
    Gui( CowGui:New, +AlwaysOnTop -Caption +ToolWindow
    Gui( Color, 000000
    Gui( Font, s12 cLime, Consolas
    
    ; Cow ascii art
    cow1 := " (__)    "
    cow2 := " (oo)    "
    cow3 := "/----\/  "
    cow4 := "|    |   "
    cow5 := "^^  ^^   "
    
    ; Create herd of cows
    herd := []
    Loop  3 {  ; 3 cows
        cow := {x: -100 * A_Index, y: A_Index * 5, speed: 2 + A_Index}
        herd.Push(cow)
    }
    
    ; Animation loop
    SetTimer, MoveCows, 50
    
    ; Show the window
    Gui( Show, w800 h300, ASCII Cows
    return

MoveCows:
    static cows := herd.Clone()
    
    ; Clear previous frame
    GuiControl,, CowDisplay, 
    
    ; Update cow positions and draw
    displayText := ""
    for i, cow in cows {
        cow.x += cow.speed
        if (cow.x > 100) {
            cow.x := -100
        }
        
        ; Add cow at current position
        Loop  5 {
            line := cow%A_Index%
            Loop  % cow.x
                line := " " line
            displayText .= line "`n"
        }
        displayText .= "`n"
    }
    
    ; Update display
    GuiControl,, CowDisplay, %displayText%
    return

CowGuiClose:
    SetTimer, MoveCows, Off
    Gui( Destroy
    return

; Text-to-Speech function
Speak(text) {
    oVoice := ComObjCreate("SAPI.SpVoice")
    oVoice.Speak(text, 1)  ; 1 = SVSFlagsAsync + SVSFPurgeBeforeSpeak
    oVoice := ""  ; Release the COM object
}

; Clean up
GuiClose:
    ExitApp
