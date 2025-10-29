#Requires AutoHotkey v2.0+
#SingleInstance Force

; Suppress error popups - log to file instead
OnError(LogError)

LogError(Thrown, Mode) {
    errorMsg := "Error: " . Thrown.Message . " at line " . Thrown.Line . "`n", "puzzle_errors.log", "UTF-8"`n        FileAppend(errorMsg`n        OutputDebug(errorMsg)  ; Enable LLM debugging
    return 1  ; Suppress popup (1 = suppress, 0 = show)
}

; ==============================================================================
; Puzzle Game - Sliding Tile Puzzle
; @name: Puzzle Game
; @version: 1.0.0
; @description: Full-featured sliding tile puzzle game
; @category: game
; @author: Sandra
; @hotkeys: ^!p (open puzzle), F9 (emergency stop)
; @enabled: true
; ==============================================================================

class PuzzleGame {
    static gui := ""
    static grid := []
    static gridSize := 4
    static moves := 0
    static emptyRow := 0
    static emptyCol := 0
    static buttons := Map()
    static isRunning := false
    static logArea := ""
    
    static Init() {
        Hotkey("^!p", (*) => this.ShowPuzzle(), "On")
        Hotkey("F9", (*) => this.EmergencyStop(), "On")
        this.isRunning := true
    }
    
    static ShowPuzzle() {
        if (this.gui) {
            try {
                this.gui.Show()
                return
            } catch as unused {
                this.gui := ""
            }
        }
        this.CreateGUI()
        this.NewGame()
    }
    
    static CreateGUI() {
        try {
            this.gui := Gui("+Resize +MinSize400x300", "Puzzle Game")
            this.gui.BackColor := "Black"
            this.gui.SetFont("s10 Bold", "Segoe UI")
            
            ; Title
            title := this.gui.AddText("x10 y10 w380 Center cYellow", "🎮 SLIDING TILE PUZZLE 🎮")
            title.SetFont("s14 Bold")
            
            ; Buttons
            btnFrame := this.gui.AddGroupBox("x10 y45 w380 h60", "Controls")
            this.gui.AddButton("x20 y70 w110 h25", "New Game").OnEvent("Click", (*) => this.NewGame())
            this.gui.AddButton("x140 y70 w110 h25", "Shuffle").OnEvent("Click", (*) => this.Shuffle(30))
            this.gui.AddButton("x260 y70 w120 h25", "Close").OnEvent("Click", (*) => this.Close())
            
            ; Stats
            statsFrame := this.gui.AddGroupBox("x10 y115 w380 h50", "Statistics")
            this.gui.AddText("x20 y135", "Moves:")
            this.movesText := this.gui.AddText("x80 y135 w100 cYellow", "0")
            this.gui.AddText("x200 y135", "Size:")
            this.sizeText := this.gui.AddText("x240 y135 w100 cLime", "4x4")
            
            ; Game grid
            gridFrame := this.gui.AddGroupBox("x10 y175 w380 h300", "Game")
            
            ; Instructions
            this.gui.AddText("x10 y485 w380 Center cSilver", "Click tiles to move them! Solve the puzzle!")
            
            ; Event handlers
            this.gui.OnEvent("Close", (*) => this.Close())
            
            ; Store references
            this.gui["movesText"] := this.movesText
            this.gui["sizeText"] := this.sizeText
            this.gui["gridFrame"] := gridFrame
            
        } catch as e {
            MsgBox("Error creating GUI: " . e.Message, "Error", "0x10")
        }
    }
    
    static NewGame() {
        this.moves := 0
        this.grid := []
        this.buttons := Map()
        this.GenerateGrid()
        this.Shuffle(20)
        this.UpdateGUI()
    }
    
    static GenerateGrid() {
        this.grid := []
        loop this.gridSize {
            row := []
            loop this.gridSize {
                idx := (A_Index - 1) + (A_LoopCount - 1) * this.gridSize + 1
                if (idx = this.gridSize * this.gridSize) {
                    row.Push(0)
                    this.emptyRow := A_LoopCount - 1
                    this.emptyCol := A_Index - 1
                } else {
                    row.Push(idx)
                }
            }
            this.grid.Push(row)
        }
    }
    
    static Shuffle(moves) {
        directions := [[-1,0], [1,0], [0,-1], [0,1]]
        loop moves {
            validMoves := []
            for dir in directions {
                newRow := this.emptyRow + dir[1]
                newCol := this.emptyCol + dir[2]
                if (newRow >= 0 and newRow < this.gridSize and newCol >= 0 and newCol < this.gridSize) {
                    validMoves.Push(dir)
                }
            }
            if (validMoves.Length > 0) {
                Random(idx, 1, validMoves.Length)
                dir := validMoves[idx]
                this.Swap(this.emptyRow + dir[1], this.emptyCol + dir[2])
            }
        }
        this.moves := 0
    }
    
    static Swap(row, col) {
        val := this.grid[row][col]
        this.grid[row][col] := 0
        this.grid[this.emptyRow][this.emptyCol] := val
        this.emptyRow := row
        this.emptyCol := col
    }
    
    static UpdateGUI() {
        if (!this.gui) {
            return
        }
        
        ; Update stats
        if (IsObject(this.gui["movesText"])) {
            this.gui["movesText"].Text := this.moves
        }
        if (IsObject(this.gui["sizeText"])) {
            this.gui["sizeText"].Text := this.gridSize . "x" . this.gridSize
        }
        
        ; Clear old buttons
        for btn in this.buttons {
            try {
                btn.Destroy()
            } catch as e {
                ; Ignore destroy errors
            }
        }
        this.buttons := Map()
        
        ; Create new buttons
        gridFrame := this.gui["gridFrame"]
        btnSize := 70
        spacing := 5
        startX := 20
        startY := 200
        
        loop this.gridSize {
            row := this.grid[A_Index]
            loop this.gridSize {
                val := row[A_Index]
                if (val = 0) {
                    continue
                }
                xPos := startX + (A_Index - 1) * (btnSize + spacing)
                yPos := startY + (A_LoopCount - 1) * (btnSize + spacing)
                
                btn := this.gui.AddButton("x" . xPos . " y" . yPos . " w" . btnSize . " h" . btnSize, val)
                btn.SetFont("s10 Bold")
                
                ; Color by value
                hue := Mod(val * 20, 360)
                btn.BackColor := this.HSVtoRGB(hue, 70, 60)
                
                ; Store coords
                btn["row"] := A_LoopCount - 1
                btn["col"] := A_Index - 1
                btn.OnEvent("Click", (*) => this.OnClick(btn))
                
                key := (A_LoopCount - 1) * this.gridSize + (A_Index - 1)
                this.buttons[key] := btn
            }
        }
        
        ; Check win
        if (this.CheckWin()) {
            this.ShowWin()
        }
    }
    
    static OnClick(btn) {
        row := btn["row"]
        col := btn["col"]
        
        if (Abs(row - this.emptyRow) + Abs(col - this.emptyCol) = 1) {
            this.Swap(row, col)
            this.moves++
            this.UpdateGUI()
        }
    }
    
    static CheckWin() {
        expected := 1
        loop this.gridSize {
            row := this.grid[A_Index]
            loop this.gridSize {
                val := row[A_Index]
                if (A_Index = this.gridSize and A_LoopCount = this.gridSize) {
                    if (val != 0) {
                        return false
                    }
                } else {
                    if (val != expected) {
                        return false
                    }
                    expected++
                }
            }
        }
        return true
    }
    
    static ShowWin() {
        MsgBox("🎉 YOU WIN! 🎉`nSolved in " . this.moves . " moves!", "Victory!", "0x40")
    }
    
    static HSVtoRGB(h, s, v) {
        h := h / 360
        s := s / 100
        v := v / 100
        
        i := Floor(h * 6)
        f := (h * 6) - i
        p := v * (1 - s)
        q := v * (1 - f * s)
        t := v * (1 - (1 - f) * s)
        
        switch Mod(i, 6) {
            case 0: r := v, g := t, b := p
            case 1: r := q, g := v, b := p
            case 2: r := p, g := v, b := t
            case 3: r := p, g := q, b := v
            case 4: r := t, g := p, b := v
            case 5: r := v, g := p, b := q
        }
        
        rHex := Format("{:02X}", Round(r * 255))
        gHex := Format("{:02X}", Round(g * 255))
        bHex := Format("{:02X}", Round(b * 255))
        return "0x" . rHex . gHex . bHex
    }
    
    static Close() {
        if (this.gui) {
            this.gui.Hide()
        }
    }
    
    static EmergencyStop() {
        ExitApp 0
    }
}

PuzzleGame.Init()

Loop {
    Sleep(1000)
}
