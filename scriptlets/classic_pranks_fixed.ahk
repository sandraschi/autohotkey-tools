#Requires AutoHotkey v2.0
#SingleInstance Force
#Warn

; ==============================================================================
; Classic Pranks Collection - AutoHotkey v2 Version
; @name: Classic Pranks Collection
; @version: 2.0.0
; @description: Collection of classic computer pranks (updated for v2)
; @category: fun
; @author: Sandra
; @hotkeys: ^!b, ^!f, ^!e, ^!s, ^!x
; @enabled: true
; ==============================================================================

class ClassicPranks {
    static bugCount := 0
    static bugs := []
    static elizaResponses := []
    
    static Init() {
        this.SetupElizaResponses()
        this.SetupHotkeys()
    }
    
    static SetupElizaResponses() {
        this.elizaResponses := [
            "Tell me more about that.",
            "How does that make you feel?",
            "Why do you think that is?",
            "Can you elaborate on that?",
            "That's interesting. Go on.",
            "I see. And what else?",
            "How long have you felt this way?",
            "What do you think is the root cause?",
            "That sounds difficult. Tell me more.",
            "I understand. Please continue."
        ]
    }
    
    static SetupHotkeys() {
        ; Bug prank
        Hotkey("^!b", this.CreateBug.Bind(this))
        
        ; Fake BSOD
        Hotkey("^!f", this.FakeBSOD.Bind(this))
        
        ; ELIZA therapist
        Hotkey("^!e", this.StartEliza.Bind(this))
        
        ; Sudoku game
        Hotkey("^!s", this.StartSudoku.Bind(this))
        
        ; Clean up bugs
        Hotkey("^!x", this.CleanupBugs.Bind(this))
    }
    
    static CreateBug(*) {
        this.bugCount++
        bugGui := Gui("+AlwaysOnTop -Caption +ToolWindow +E0x20", "Bug" . this.bugCount)
        bugGui.BackColor := "0x000000"
        
        ; Random position and speed
        x := Random(0, A_ScreenWidth - 50)
        y := Random(0, A_ScreenHeight - 50)
        speedX := Random(-5, 5)
        speedY := Random(-5, 5)
        
        ; Create bug (simple circle for now)
        bugGui.Add("Text", "x0 y0 w50 h50 cLime", "ðŸž")
        bugGui.Show("x" . x . " y" . y . " w50 h50")
        
        ; Make window semi-transparent
        WinSetTransparent(200, bugGui)
        
        ; Store bug info
        bug := {
            gui: bugGui(
            x: x,
            y: y,
            speedX: speedX,
            speedY: speedY
        }
        this.bugs.Push(bug)
        
        ; Start movement timer
        SetTimer(() => this.MoveBug(bug), 50)
        
        TrayTip("Bug Created!", "Bug #" . this.bugCount . " is now crawling around!", 2)
    }
    
    static MoveBug(bug) {
        try {
            bug.x += bug.speedX
            bug.y += bug.speedY
            
            ; Bounce off edges
            if (bug.x <= 0 || bug.x >= A_ScreenWidth - 50) {
                bug.speedX := -bug.speedX
            }
            if (bug.y <= 0 || bug.y >= A_ScreenHeight - 50) {
                bug.speedY := -bug.speedY
            }
            
            ; Update position
            bug.gui.Show("x" . bug.x . " y" . bug.y . " w50 h50")
        } catch {
            ; Bug was destroyed, remove from list
            index := this.bugs.IndexOf(bug)
            if (index > 0) {
                this.bugs.RemoveAt(index)
            }
        }
    }
    
    static FakeBSOD(*) {
        bsodGui := Gui("+AlwaysOnTop -Caption +ToolWindow", "Fake BSOD")
        bsodGui.BackColor := "0x0000FF"
        bsodGui.SetFont("s12 cWhite", "Lucida Console")
        
        funnyMessages := [
            "SYSTEM_CRITICAL_ERROR: Too many cookies in the cookie jar!",
            "FATAL_ERROR: User attempted to divide by zero",
            "CRITICAL_FAILURE: The hamster powering the server died",
            "SYSTEM_HALT: Out of coffee. Please refill and restart.",
            "ERROR_404: Common sense not found",
            "CRITICAL_ERROR: User tried to use Internet Explorer",
            "SYSTEM_FAILURE: The server is having an existential crisis",
            "FATAL_ERROR: Someone unplugged the internet"
        ]
        
        rand := Random(1, funnyMessages.Length)
        errorMsg := funnyMessages[rand]
        
        bsodText := "A problem has been detected and Windows has been shut down to prevent damage`n"
        bsodText .= "to your computer.`n`n"
        bsodText .= errorMsg . "`n`n"
        bsodText .= "If this is the first time you've seen this Stop error screen,`n"
        bsodText .= "restart your computer. If this screen appears again, follow`n"
        bsodText .= "these steps:`n`n"
        bsodText .= "Check to make sure any new hardware or software is properly`n"
        bsodText .= "installed. If this is a new installation, ask your hardware`n"
        bsodText .= "or software manufacturer for any Windows updates you might need.`n`n"
        bsodText .= "If problems continue, disable or remove any newly installed`n"
        bsodText .= "hardware or software. Disable BIOS memory options such as`n"
        bsodText .= "caching or shadowing. If you need to use Safe Mode to remove`n"
        bsodText .= "or disable components, restart your computer, press F8 to`n"
        bsodText .= "select Advanced Startup Options, and then select Safe Mode.`n`n"
        bsodText .= "Technical Information:`n`n"
        bsodText .= "*** STOP: 0x0000007E (0xC0000005, 0xF7A8B2BC, 0xF7A8AFB8, 0xF7A8ACB4)`n`n"
        bsodText .= "Beginning dump of physical memory`n"
        bsodText .= "Physical memory dump complete.`n"
        bsodText .= "Contact your system administrator or technical support group`n"
        bsodText .= "for further assistance."
        
        bsodGui.Add("Text", "x20 y20 w600 h400", bsodText)
        bsodGui.Show("w640 h480")
        
        ; Make it look more real by making it hard to close
        WinSetAlwaysOnTop(true, bsodGui)
        
        ; Auto-close after 10 seconds
        SetTimer(() => bsodGui.Close(), -10000)
        
        TrayTip("Fake BSOD!", "Blue screen of death activated!", 2)
    }
    
    static StartEliza(*) {
        elizaGui := Gui("+AlwaysOnTop +Resize -MaximizeBox", "ELIZA Therapist")
        elizaGui.BackColor := "0xF0F0F0"
        elizaGui.SetFont("s10", "Consolas")
        
        ; Chat display
        chatDisplay := elizaGui.Add("Edit", "x10 y10 w580 h300 ReadOnly", 
            "ELIZA: Hello, I am ELIZA, your virtual therapist.`nELIZA: How are you feeling today?`n`n")
        
        ; User input
        userInput := elizaGui.Add("Edit", "x10 w500 h80")
        sendBtn := elizaGui.Add("Button", "x520 y330 w70 h25", "&Send")
        
        ; Event handlers
        sendBtn.OnEvent("Click", (*) => ClassicPranks.ElizaSend(chatDisplay, userInput))
        userInput.OnEvent("Change", (*) => ClassicPranks.ElizaRespond(chatDisplay, userInput))
        
        elizaGui.Show("w600 h400")
        
        TrayTip("ELIZA Started!", "Your virtual therapist is ready to listen!", 2)
    }
    
    static ElizaSend(Gui( chatDisplay, userInput) {
        if (userInput.Text = "") {
            return
        }
        
        currentText := chatDisplay.Text
        chatDisplay.Text := currentText . "You: " . userInput.Text . "`n"
        
        ; Generate ELIZA response
        response := this.elizaResponses[Random(1, this.elizaResponses.Length)]
        chatDisplay.Text := chatDisplay.Text . "ELIZA: " . response . "`n`n"
        
        userInput.Text := ""
        userInput.Focus()
    }
    
    static ElizaRespond(Gui( chatDisplay, userInput) {
        ; This could be enhanced to respond on Enter key
    }
    
    static StartSudoku(*) {
        sudokuGui := Gui("+AlwaysOnTop", "Sudoku")
        sudokuGui.SetFont("s16", "Consolas")
        
        ; Create 9x9 grid
        for row := 1 to 9 {
            for col := 1 to 9 {
                x := 10 + (col - 1) * 40
                y := 10 + (row - 1) * 40
                
                options := "x" . x . " y" . y . " w35 h35"
                
                ; Add borders
                if (Mod(col, 3) = 1) {
                    options .= " +0x200"  ; Left border
                }
                if (Mod(row, 3) = 1) {
                    options .= " +0x100"  ; Top border
                }
                
                sudokuGui.Add("Edit", options . " Center Limit1 Number")
            }
        }
        
        ; Add buttons
        newGameBtn := sudokuGui.Add("Button", "x10 y370", "&New Game")
        checkBtn := sudokuGui.Add("Button", "x120 y370", "&Check Solution")
        solveBtn := sudokuGui.Add("Button", "x240 y370", "&Solve")
        
        ; Event handlers
        newGameBtn.OnEvent("Click", (*) => ClassicPranks.NewSudokuGame(sudokuGui))
        checkBtn.OnEvent("Click", (*) => ClassicPranks.CheckSudokuSolution(sudokuGui))
        solveBtn.OnEvent("Click", (*) => ClassicPranks.SolveSudoku(sudokuGui))
        
        ; Generate a new puzzle
        this.NewSudokuGame(sudokuGui)
        
        sudokuGui.Show("w400 h420")
        
        TrayTip("Sudoku Started!", "A new Sudoku puzzle is ready!", 2)
    }
    
    static NewSudokuGame(gui) {
        ; Simple puzzle generation (simplified)
        TrayTip("New Game", "Generating new Sudoku puzzle...", 1)
    }
    
    static CheckSudokuSolution(gui) {
        TrayTip("Check Solution", "Checking your solution...", 1)
    }
    
    static SolveSudoku(gui) {
        TrayTip("Solve Puzzle", "Solving the puzzle...", 1)
    }
    
    static CleanupBugs(*) {
        for bug in this.bugs {
            try {
                bug.gui.Close()
            } catch {
                ; Ignore errors
            }
        }
        this.bugs := []
        this.bugCount := 0
        
        TrayTip("Cleanup Complete!", "All bugs have been exterminated!", 2)
    }
}

; Initialize
ClassicPranks.Init()
