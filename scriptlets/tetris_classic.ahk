; ==============================================================================
; Tetris Classic
; @name: Tetris Classic
; @version: 1.0.0
; @description: Classic Tetris falling blocks puzzle game
; @category: games
; @author: Sandra
; @hotkeys: Arrow keys, Space, P, R
; @enabled: true
; ==============================================================================

#Requires AutoHotkey v2.0+
#SingleInstance Force


; Suppress error popups - log to file instead
OnError(LogError)

LogError(Thrown, Mode) {
    FileAppend("Error: " . Thrown.Message . " at line " . Thrown.Line . "
", "errors.log", "UTF-8")`n        OutputDebug(errorMsg)  ; Enable LLM debugging
    return 1  ; Suppress popup (1 = suppress, 0 = show)
}


class TetrisGame {
    static gui := ""
    static canvas := ""
    static gameBoard := []
    static currentPiece := ""
    static nextPiece := ""
    static score := 0
    static level := 1
    static lines := 0
    static gameRunning := false
    static gameSpeed := 500
    static timer := ""
    
    ; Tetris pieces
    static pieces := [
        ; I piece
        {shape: [[1,1,1,1]], color: "0x00FFFF", name: "I"},
        ; O piece
        {shape: [[1,1],[1,1]], color: "0xFFFF00", name: "O"},
        ; T piece
        {shape: [[0,1,0],[1,1,1]], color: "0x800080", name: "T"},
        ; S piece
        {shape: [[0,1,1],[1,1,0]], color: "0x00FF00", name: "S"},
        ; Z piece
        {shape: [[1,1,0],[0,1,1]], color: "0xFF0000", name: "Z"},
        ; J piece
        {shape: [[1,0,0],[1,1,1]], color: "0x0000FF", name: "J"},
        ; L piece
        {shape: [[0,0,1],[1,1,1]], color: "0xFFA500", name: "L"}
    ]
    
    static Init() {
        this.InitializeBoard()
        this.CreateGUI()
        this.SetupHotkeys()
    }
    
    static InitializeBoard() {
        ; Create 20x10 game board
        this.gameBoard := []
        Loop 20 {
            row := []
            Loop 10 {
                row.Push(0)
            }
            this.gameBoard.Push(row)
        }
    }
    
    static CreateGUI() {
        this.gui := Gui("+Resize -MaximizeBox", "Tetris Classic")
        this.gui.BackColor := "1a1a1a"
        this.gui.SetFont("s12 cFFFFFF Bold", "Segoe UI")
        
        ; Title
        this.gui.Add("Text", "x20 y20 w400 Center Bold", "🎮 Tetris Classic")
        
        ; Game area
        this.canvas := this.gui.Add("Text", "x20 y60 w200 h400 Background000000 Border", "")
        this.canvas.SetFont("s8 cFFFFFF", "Courier New")
        
        ; Next piece area
        this.gui.Add("Text", "x240 y60 w120 h80 Background000000 Border", "Next:")
        this.gui.Add("Text", "x250 y90 w100 h50 Background000000", "")
        
        ; Score area
        this.gui.Add("Text", "x240 y160 w120 h200 Background2d2d2d", "")
        scoreText := this.gui.Add("Text", "x250 y180 w100 Center", "Score: 0")
        levelText := this.gui.Add("Text", "x250 y210 w100 Center", "Level: 1")
        linesText := this.gui.Add("Text", "x250 y240 w100 Center", "Lines: 0")
        
        ; Controls
        this.gui.Add("Text", "x250 y280 w100 Center Bold", "Controls:")
        this.gui.Add("Text", "x250 y310 w100", "← → Move")
        this.gui.Add("Text", "x250 y330 w100", "↓ Soft Drop")
        this.gui.Add("Text", "x250 y350 w100", "Space Hard Drop")
        this.gui.Add("Text", "x250 y370 w100", "↑ Rotate")
        this.gui.Add("Text", "x250 y390 w100", "P Pause")
        this.gui.Add("Text", "x250 y410 w100", "R Restart")
        
        ; Start button
        startBtn := this.gui.Add("Button", "x250 y450 w100 h40 Background4a4a4a", "Start Game")
        startBtn.SetFont("s10 cFFFFFF Bold", "Segoe UI")
        startBtn.OnEvent("Click", this.StartGame.Bind(this))
        
        ; Store references
        this.gui.scoreText := scoreText
        this.gui.levelText := levelText
        this.gui.linesText := linesText
        
        this.gui.Show("w400 h550")
    }
    
    static StartGame(*) {
        if (this.gameRunning) {
            return
        }
        
        this.gameRunning := true
        this.score := 0
        this.level := 1
        this.lines := 0
        this.gameSpeed := 500
        
        this.InitializeBoard()
        this.SpawnNewPiece()
        this.SpawnNextPiece()
        this.UpdateDisplay()
        
        ; Start game timer
        this.timer := SetTimer(this.GameTick.Bind(this), this.gameSpeed)
        
        TrayTip("Tetris Started!", "Use arrow keys to play", 2)
    }
    
    static GameTick() {
        if (!this.gameRunning) {
            return
        }
        
        ; Move piece down
        if (this.CanMovePiece(this.currentPiece, 0, 1)) {
            this.MovePiece(0, 1)
        } else {
            ; Piece can't move down, place it
            this.PlacePiece()
            this.ClearLines()
            this.SpawnNewPiece()
            
            ; Check game over
            if (!this.CanMovePiece(this.currentPiece, 0, 0)) {
                this.GameOver()
                return
            }
        }
        
        this.UpdateDisplay()
    }
    
    static SpawnNewPiece() {
        if (this.nextPiece) {
            this.currentPiece := this.nextPiece
        } else {
            this.currentPiece := this.GetRandomPiece()
        }
        
        ; Position at top center
        this.currentPiece.x := 4
        this.currentPiece.y := 0
        
        this.SpawnNextPiece()
    }
    
    static SpawnNextPiece() {
        this.nextPiece := this.GetRandomPiece()
    }
    
    static GetRandomPiece() {
        pieceIndex := Random(1, this.pieces.Length)
        basePiece := this.pieces[pieceIndex]
        
        return {
            shape: basePiece.shape,
            color: basePiece.color,
            name: basePiece.name,
            x: 0,
            y: 0
        }
    }
    
    static CanMovePiece(piece, dx, dy) {
        newX := piece.x + dx
        newY := piece.y + dy
        
        ; Check bounds
        for row in piece.shape {
            for col, cell in row {
                if (cell) {
                    boardX := newX + col - 1
                    boardY := newY + row - 1
                    
                    ; Check boundaries
                    if (boardX < 0 || boardX >= 10 || boardY >= 20) {
                        return false
                    }
                    
                    ; Check collision with placed pieces
                    if (boardY >= 0 && this.gameBoard[boardY + 1][boardX + 1]) {
                        return false
                    }
                }
            }
        }
        
        return true
    }
    
    static MovePiece(dx, dy) {
        if (this.CanMovePiece(this.currentPiece, dx, dy)) {
            this.currentPiece.x += dx
            this.currentPiece.y += dy
            return true
        }
        return false
    }
    
    static RotatePiece() {
        if (!this.currentPiece) {
            return
        }
        
        ; Create rotated shape
        rotatedShape := []
        for i, row in this.currentPiece.shape {
            rotatedShape.Push([])
            for j, cell in row {
                rotatedShape[i].Push(0)
            }
        }
        
        ; Rotate 90 degrees clockwise
        for i, row in this.currentPiece.shape {
            for j, cell in row {
                rotatedShape[j][this.currentPiece.shape.Length - i] := cell
            }
        }
        
        ; Check if rotation is valid
        originalShape := this.currentPiece.shape
        this.currentPiece.shape := rotatedShape
        
        if (!this.CanMovePiece(this.currentPiece, 0, 0)) {
            ; Revert if invalid
            this.currentPiece.shape := originalShape
        }
    }
    
    static PlacePiece() {
        for row in this.currentPiece.shape {
            for col, cell in row {
                if (cell) {
                    boardX := this.currentPiece.x + col - 1
                    boardY := this.currentPiece.y + row - 1
                    
                    if (boardY >= 0) {
                        this.gameBoard[boardY + 1][boardX + 1] := this.currentPiece.color
                    }
                }
            }
        }
    }
    
    static ClearLines() {
        linesCleared := 0
        
        ; Check each row
        for y in this.gameBoard {
            rowIndex := A_Index
            isFull := true
            
            for x in y {
                if (!x) {
                    isFull := false
                    break
                }
            }
            
            if (isFull) {
                ; Remove the line
                this.gameBoard.RemoveAt(rowIndex)
                
                ; Add new empty line at top
                newRow := []
                Loop 10 {
                    newRow.Push(0)
                }
                this.gameBoard.InsertAt(1, newRow)
                
                linesCleared++
            }
        }
        
        if (linesCleared > 0) {
            this.lines += linesCleared
            this.score += linesCleared * 100 * this.level
            
            ; Level up every 10 lines
            newLevel := (this.lines // 10) + 1
            if (newLevel > this.level) {
                this.level := newLevel
                this.gameSpeed := Max(50, 500 - (this.level - 1) * 50)
                SetTimer(this.timer, this.gameSpeed)
            }
            
            this.UpdateScore()
        }
    }
    
    static UpdateDisplay() {
        if (!this.canvas) {
            return
        }
        
        ; Create display string
        display := ""
        
        ; Draw game board
        for row in this.gameBoard {
            for cell in row {
                if (cell) {
                    display .= "█"
                } else {
                    display .= "·"
                }
            }
            display .= "`n"
        }
        
        ; Draw current piece
        if (this.currentPiece) {
            for row in this.currentPiece.shape {
                for col, cell in row {
                    if (cell) {
                        boardX := this.currentPiece.x + col - 1
                        boardY := this.currentPiece.y + row - 1
                        
                        if (boardY >= 0 && boardY < 20 && boardX >= 0 && boardX < 10) {
                            ; Replace the character at this position
                            pos := (boardY * 11) + boardX + 1
                            display := SubStr(display, 1, pos - 1) . "█" . SubStr(display, pos + 1)
                        }
                    }
                }
            }
        }
        
        this.canvas.Text := display
    }
    
    static UpdateScore() {
        if (this.gui.scoreText) {
            this.gui.scoreText.Text := "Score: " . this.score
        }
        if (this.gui.levelText) {
            this.gui.levelText.Text := "Level: " . this.level
        }
        if (this.gui.linesText) {
            this.gui.linesText.Text := "Lines: " . this.lines
        }
    }
    
    static GameOver() {
        this.gameRunning := false
        SetTimer(this.timer, 0)
        
        MsgBox("Game Over!`n`nFinal Score: " . this.score . "`nLevel: " . this.level . "`nLines: " . this.lines, "Tetris Game Over", "Iconi")
        
        ; Reset for new game
        this.InitializeBoard()
        this.UpdateDisplay()
    }
    
    static PauseGame() {
        if (!this.gameRunning) {
            return
        }
        
        this.gameRunning := false
        SetTimer(this.timer, 0)
        TrayTip("Game Paused", "Press P to resume", 2)
    }
    
    static ResumeGame() {
        if (this.gameRunning) {
            return
        }
        
        this.gameRunning := true
        SetTimer(this.timer, this.gameSpeed)
        TrayTip("Game Resumed", "Tetris continues!", 2)
    }
    
    static SetupHotkeys() {
        ; Movement
        Hotkey("Left", (*) => this.MovePiece(-1, 0)
        Right::this.MovePiece(1, 0)
        Down::this.MovePiece(0, 1)
        Up::this.RotatePiece()
        
        ; Hard drop
        Space::{
            while (this.MovePiece(0, 1)) {
                ; Keep moving down
            }
        }
        
        ; Pause/Resume
        Hotkey("p", (*) => {
            if (this.gameRunning) {
                this.PauseGame()
            } else {
                this.ResumeGame()
            }
        }
        
        ; Restart
        Hotkey("r", (*) => this.StartGame()
        
        ; Close with Escape
        Escape::{
            if (WinExist("Tetris Classic")) {
                WinClose("Tetris Classic")
            }
        }
    }
}

; Initialize
TetrisGame.Init()





