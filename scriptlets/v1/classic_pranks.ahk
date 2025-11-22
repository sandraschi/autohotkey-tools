#NoEnv
#SingleInstance Force
#MaxHotkeysPerInterval 200
#Persistent
SetWorkingDir %A_ScriptDir%

; ========================================
; 1. BUGS CRAWLING SCREEN
; ========================================
^!b::  ; Ctrl+Alt+B for bugs
    static bugCount := 0
    bugCount := bugCount >= 10 ? 10 : bugCount + 1
    
    ; Create bug GUI
    Gui, BugGui%bugCount%:New, +AlwaysOnTop -Caption +ToolWindow +E0x20
    Gui, Color, 000000
    
    ; Random bug position and speed
    Random, x, 0, % A_ScreenWidth - 50
    Random, y, 0, % A_ScreenHeight - 50
    Random, xSpeed, 1, 5
    Random, ySpeed, 1, 5
    
    ; Create bug (simple circle for now)
    Gui, Add, Text, x0 y0 w50 h50 cLime, 🐞
    Gui, Show, x%x% y%y% w50 h50, Bug%bugCount%
    WinSet, Transparent, 200, Bug%bugCount%
    
    ; Start bug movement
    SetTimer, MoveBug%bugCount%, 50
    
    ; Store bug data
    bug%bugCount%_x := x
    bug%bugCount%_y := y
    bug%bugCount%_xSpeed := xSpeed
    bug%bugCount%_ySpeed := ySpeed
    
    ; Speak when first bug appears
    if (bugCount = 1) {
        Speak("Eek! Bugs!")
    }
    return

; Bug movement handler
MoveBug1:
MoveBug2:
MoveBug3:
MoveBug4:
MoveBug5:
MoveBug6:
MoveBug7:
MoveBug8:
MoveBug9:
MoveBug10:
    bugNum := SubStr(A_ThisLabel, 8)
    if (!bugNum)
        return
        
    ; Update position
    bug%bugNum%_x += bug%bugNum%_xSpeed
    bug%bugNum%_y += bug%bugNum%_ySpeed
    
    ; Bounce off edges
    if (bug%bugNum%_x <= 0 || bug%bugNum%_x >= A_ScreenWidth - 50)
        bug%bugNum%_xSpeed *= -1
    if (bug%bugNum%_y <= 0 || bug%bugNum%_y >= A_ScreenHeight - 50)
        bug%bugNum%_ySpeed *= -1
    
    ; Move window
    WinMove, Bug%bugNum%,, % bug%bugNum%_x, % bug%bugNum%_y
    
    ; Random direction changes
    Random, rand, 1, 100
    if (rand = 1) {
        Random, bug%bugNum%_xSpeed, -5, 5
        Random, bug%bugNum%_ySpeed, -5, 5
    }
    return

; ========================================
; 2. FUNNY FAKE BSOD
; ========================================
^!f::  ; Ctrl+Alt+F for funny BSOD
    Gui, BSOD:New, +AlwaysOnTop -Caption +ToolWindow
    Gui, Color, 0000FF
    Gui, Font, s12 cWhite, Lucida Console
    
    funnyMessages := ["SYSTEM_CRITICAL_ERROR: Too many cookies in the cookie jar!"
                    , "KERNEL_PANIC: Missing semicolon on line 42"
                    , "ERROR 0xCAFEBABE: Coffee not found"
                    , "PAGE_FAULT_IN_NONPAGED_AREA: It's not you, it's me"
                    , "CRITICAL_PROCESS_DIED: Your cat walked on the keyboard"]
    
    Random, rand, 1, % funnyMessages.MaxIndex()
    errorMsg := funnyMessages[rand]
    
    Gui, Add, Text, x20 y20 w600 h400, 
    (
    A problem has been detected and Windows has been shut down to prevent damage
    to your computer.
    
    %errorMsg%
    
    If this is the first time you've seen this stop error screen,
    restart your computer. If this screen appears again, follow
    these steps:
    
    Check to make sure your chair is plugged in.
    If this is a new installation, ask your cat for assistance.
    
    Technical information:
    *** STOP: 0xDEADBEEF (0x00000000,0x00000000,0x00000000,0x00000000)
    
    Beginning dump of physical memory
    Memory dump complete.
    Contact your system administrator or technical support group for further
    assistance.
    )
    Gui, Show, w640 h480, Windows - No Disk
    
    ; Make it look more real by making it hard to close
    WinSet, Style, -0xC00000, A  ; Remove close button
    return

; ========================================
; 3. ELIZA THERAPIST
; ========================================
^!e::  ; Ctrl+Alt+E for ELIZA
    Gui, Eliza:New, +AlwaysOnTop +Resize -MaximizeBox, ELIZA Therapist
    Gui, Color, F0F0F0
    Gui, Font, s10, Consolas
    
    ; Chat display
    Gui, Add, Edit, x10 y10 w580 h300 vChatDisplay ReadOnly, ELIZA: Hello, I am ELIZA, your virtual therapist.`nELIZA: How are you feeling today?`n`n
    ; User input
    Gui, Add, Edit, x10 w500 h80 vUserInput gElizaRespond
    Gui, Add, Button, x520 y330 w70 h25 gElizaSend, &Send
    
    Gui, Show, w600 h400
    
    ; Initialize ELIZA responses
    responses := []
    responses["i feel"] := ["Why do you feel that way?", "Do you often feel this way?", "Can you tell me more about this feeling?"]
    responses["i need"] := ["Why do you need that?", "What would it mean to you if you got that?", "Have you always needed this?"]
    responses["i can't"] := ["Do you think you should be able to?", "Have you tried?", "What would happen if you could?"]
    responses["i am"] := ["How long have you been {0}?", "Why are you {0}?", "What makes you think you're {0}?"]
    responses["i'm"] := responses["i am"]
    responses["why don't you"] := ["Do you think I should {0}?", "Would you like me to {0}?", "What if I {0}?"]
    responses["i want"] := ["What would it mean to you if you got {0}?", "Why do you want {0}?", "What would you do if you got {0}?"]
    responses["what"] := ["Why do you ask?", "What do you think?", "What comes to mind when you ask that?"]
    responses["how"] := responses["what"]
    responses["because"] := ["Is that the real reason?", "What other reasons might there be?", "What else comes to mind?"]
    responses["yes"] := ["I see.", "I understand.", "Please continue."]
    responses["no"] := ["Why not?", "Are you sure?", "What if you said yes?"]
    
    ; Default responses
    defaultResponses := ["Please go on.", "Tell me more.", "How does that make you feel?", "Can you elaborate on that?", "I see. And what does that tell you?", "How do you feel when you say that?"]
    
    return

ElizaSend:
    Gui, Submit, NoHide
    GuiControl,, UserInput
    GuiControlGet, chat,, ChatDisplay
    GuiControl,, ChatDisplay, %chat%You: %UserInput%`n
    Gosub, ElizaRespond
    return

ElizaRespond:
    Gui, Submit, NoHide
    if (UserInput = "")
        return
    
    ; Convert to lowercase for matching
    inputLower := Format("{:L}", UserInput)
    
    ; Check for patterns
    responseFound := false
    for pattern, responseArray in responses {
        if (InStr(inputLower, pattern)) {
            ; If pattern has a placeholder, extract the text after the pattern
            if (InStr(responseArray[1], "{0}")) {
                rest := SubStr(UserInput, InStr(inputLower, pattern) + StrLen(pattern))
                rest := Trim(rest, " .!?")
                response := Format(responseArray[1], rest)
            } else {
                Random, rand, 1, % responseArray.MaxIndex()
                response := responseArray[rand]
            }
            
            GuiControlGet, chat,, ChatDisplay
            GuiControl,, ChatDisplay, %chat%ELIZA: %response%`n`n
            responseFound := true
            break
        }
    }
    
    ; If no pattern matched, use default response
    if (!responseFound) {
        Random, rand, 1, % defaultResponses.MaxIndex()
        response := defaultResponses[rand]
        GuiControlGet, chat,, ChatDisplay
        GuiControl,, ChatDisplay, %chat%ELIZA: %response%`n`n
    }
    
    ; Auto-scroll to bottom
    SendMessage, 0x115, 7, 0,, ahk_id %hChatDisplay%
    return

; ========================================
; 4. SUDOKU GAME
; ========================================
^!s::  ; Ctrl+Alt+S for Sudoku
    Gui, Sudoku:New, +AlwaysOnTop, Sudoku
    Gui, Font, s16, Consolas
    
    ; Create 9x9 grid
    gridSize := 40
    loop 9 {
        row := A_Index
        loop 9 {
            col := A_Index
            ; Add thicker borders for 3x3 boxes
            options := "x" (col-1)*gridSize " y" (row-1)*gridSize " w" gridSize " h" gridSize " vCell" row col " gCellClick"
            if (Mod(col-1, 3) = 0)
                options .= " +Border"
            if (Mod(row-1, 3) = 0)
                options .= " +0x100"  ; Top border
            
            Gui, Add, Edit, %options% Center Limit1 Number
        }
    }
    
    ; Add buttons
    Gui, Add, Button, x10 y370 gNewGame, &New Game
    Gui, Add, Button, x120 y370 gCheckSolution, &Check Solution
    Gui, Add, Button, x240 y370 gSolvePuzzle, &Solve
    
    ; Generate a new puzzle
    Gosub, NewGame
    
    Gui, Show, w400 h420
    return

NewGame:
    ; Clear the board
    loop 9 {
        row := A_Index
        loop 9 {
            GuiControl,, Cell%row%%col%, 
            GuiControl, +BackgroundWhite, Cell%row%%col%
        }
    }
    
    ; Add some starting numbers (this would be replaced with puzzle generation logic)
    ; For now, just add a few numbers as an example
    GuiControl,, Cell11, 5
    GuiControl,, Cell24, 3
    GuiControl,, Cell37, 7
    GuiControl,, Cell42, 6
    GuiControl,, Cell55, 9
    GuiControl,, Cell68, 1
    GuiControl,, Cell73, 9
    GuiControl,, Cell86, 8
    GuiControl,, Cell99, 4
    
    ; Make starting numbers read-only and gray
    startingCells := ["11", "24", "37", "42", "55", "68", "73", "86", "99"]
    for _, cell in startingCells {
        GuiControl, +ReadOnly, Cell%cell%
        GuiControl, +BackgroundE6E6E6, Cell%cell%
    }
    return

CheckSolution:
    ; This would check if the current board is a valid solution
    MsgBox, 64, Sudoku, Solution checking not implemented yet!
    return

SolvePuzzle:
    ; This would solve the current puzzle
    MsgBox, 64, Sudoku, Auto-solve not implemented yet!
    return

CellClick:
    ; Highlight the clicked cell
    GuiControlGet, focused, FocusV
    Gui, Font, s16 cBlue
    GuiControl, Font, %focused%
    return

; ========================================
; HELPER FUNCTIONS
; ========================================

; Text-to-Speech function
Speak(text) {
    oVoice := ComObjCreate("SAPI.SpVoice")
    oVoice.Speak(text, 1)  ; 1 = SVSFlagsAsync + SVSFPurgeBeforeSpeak
    oVoice := ""  ; Release the COM object
}

; Clean up
GuiClose:
    Gui, Destroy
    return

ElizaGuiClose:
    Gui, Eliza:Destroy
    return

SudokuGuiClose:
    Gui, Sudoku:Destroy
    return

BSODGuiClose:
    Gui, BSOD:Destroy
    return

; Close all bug windows
^!x::  ; Ctrl+Alt+X to clean up all bugs
    loop 10 {
        Gui, BugGui%A_Index%:Destroy
        SetTimer, MoveBug%A_Index%, Off
    }
    bugCount := 0
    return
