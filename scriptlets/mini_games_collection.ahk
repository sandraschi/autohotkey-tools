; ==============================================================================
; Mini Games Collection
; @name: Mini Games Collection
; @version: 1.0.0
; @description: Collection of fun mini-games including Snake, Tetris, and Memory
; @category: games
; @author: Sandra
; @hotkeys: ^!g, #s, #t, #m
; @enabled: true
; ==============================================================================

#Requires AutoHotkey v2.0+
#SingleInstance Force

class MiniGames {
    static currentGame := ""
    static gameGui := ""
    
    static Init() {
        this.CreateMainGUI()
    }
    
    static CreateMainGUI() {
        this.gameGui := Gui("+Resize", "Mini Games Collection")
        
        ; Title
        this.gameGui.AddText("w550 h40 Center", "🎮 Mini Games Collection")
        
        ; Game selection
        this.gameGui.AddText("w550 h20 Center", "Choose a game:")
        
        ; Row 1
        snakeBtn := this.gameGui.AddButton("x20 y60 w100 h60", "🐍 Snake`nClassic")
        pongBtn := this.gameGui.AddButton("x130 y60 w100 h60", "🏓 Pong`nClassic")
        pacmanBtn := this.gameGui.AddButton("x240 y60 w100 h60", "👻 Pac-Man`nArcade")
        froggerBtn := this.gameGui.AddButton("x350 y60 w100 h60", "🐸 Frogger`nArcade")
        sudokuBtn := this.gameGui.AddButton("x460 y60 w100 h60", "🔢 Sudoku`nPuzzle")
        
        snakeBtn.OnEvent("Click", this.StartSnake.Bind(this))
        pongBtn.OnEvent("Click", this.StartPong.Bind(this))
        pacmanBtn.OnEvent("Click", this.StartPacman.Bind(this))
        froggerBtn.OnEvent("Click", this.StartFrogger.Bind(this))
        sudokuBtn.OnEvent("Click", this.StartSudoku.Bind(this))
        
        ; Row 2
        tetrisBtn := this.gameGui.AddButton("x20 y130 w100 h60", "🧩 Tetris`nPuzzle")
        qbertBtn := this.gameGui.AddButton("x130 y130 w100 h60", "🐸 Q*bert`nArcade")
        chessBtn := this.gameGui.AddButton("x240 y130 w100 h60", "♟️ Chess`nStrategy")
        memoryBtn := this.gameGui.AddButton("x350 y130 w100 h60", "🧠 Memory`nCard")
        breakoutBtn := this.gameGui.AddButton("x460 y130 w100 h60", "💥 Breakout`nComing Soon")
        
        tetrisBtn.OnEvent("Click", this.StartTetris.Bind(this))
        qbertBtn.OnEvent("Click", this.StartQbert.Bind(this))
        chessBtn.OnEvent("Click", this.StartChess.Bind(this))
        memoryBtn.OnEvent("Click", this.StartMemory.Bind(this))
        breakoutBtn.OnEvent("Click", this.StartBreakout.Bind(this))
        
        ; Instructions
        this.gameGui.AddText("w550 h40 x20 y200", "Instructions:`n• Most games open in new windows`n• Use game-specific controls`n• Press Ctrl+Alt+G to reopen this menu")
        
        this.gameGui.Show("w590 h260")
    }
    
    static StartSnake(*) {
        this.currentGame := "Snake"
        if (this.gameGui) {
            this.gameGui.Hide()
        }
        this.CreateSnakeGame()
    }
    
    static CreateSnakeGame() {
        this.gameGui := Gui("+Resize", "Snake Game")
        
        ; Game area
        this.gameGui.AddText("w400 h400 BackgroundBlack", "")
        
        ; Score
        this.gameGui.AddText("w400 h30", "Score: 0")
        
        ; Controls
        this.gameGui.AddText("w400 h30", "Controls: Arrow Keys | ESC: Menu | SPACE: Pause")
        
        this.gameGui.Show("w420 h500")
        
        ; Initialize game variables
        this.snakeX := [200]
        this.snakeY := [200]
        this.direction := "right"
        this.foodX := 100
        this.foodY := 100
        this.score := 0
        
        ; Start game loop
        SetTimer(this.SnakeGameLoop.Bind(this), 150)
        
        ; Set up hotkeys
        this.SetupSnakeHotkeys()
    }
    
    static SnakeGameLoop() {
        ; Move snake
        headX := this.snakeX[1]
        headY := this.snakeY[1]
        
        switch this.direction {
            case "up": headY -= 20
            case "down": headY += 20
            case "left": headX -= 20
            case "right": headX += 20
        }
        
        ; Check boundaries
        if (headX < 0 || headX >= 400 || headY < 0 || headY >= 400) {
            this.GameOver()
            return
        }
        
        ; Check collision with self
        for i, x in this.snakeX {
            if (x = headX && this.snakeY[i] = headY) {
                this.GameOver()
                return
            }
        }
        
        ; Add new head
        this.snakeX.InsertAt(1, headX)
        this.snakeY.InsertAt(1, headY)
        
        ; Check food collision
        if (headX = this.foodX && headY = this.foodY) {
            this.score += 10
            this.GenerateFood()
        } else {
            ; Remove tail
            this.snakeX.Pop()
            this.snakeY.Pop()
        }
        
        this.DrawSnake()
    }
    
    static DrawSnake() {
        ; Clear screen (simplified)
        ; Update score
        this.gameGui.Control["Text2"].Text := "Score: " . this.score
    }
    
    static GenerateFood() {
        this.foodX := Random(0, 19) * 20
        this.foodY := Random(0, 19) * 20
    }
    
    static GameOver() {
        SetTimer(this.SnakeGameLoop.Bind(this), 0)
        MsgBox("Game Over! Score: " . this.score, "Snake Game", "0x40")
        this.Init()
    }
    
    static SetupSnakeHotkeys() {
        ; Hotkeys will be defined globally at module level
    }
    
    static StartTetris(*) {
        if (this.gameGui) {
            this.gameGui.Hide()
        }
        try {
            Run(A_AhkPath . " `"" . A_ScriptDir . "\tetris_classic.ahk`"")
        } catch as e {
            MsgBox("Error launching Tetris: " . e.Message, "Error", "Icon!")
            this.Init()
        }
    }
    
    static StartMemory(*) {
        if (this.gameGui) {
            this.gameGui.Hide()
        }
        MsgBox("Memory game not implemented yet.`n`nTry one of the other games!", "Mini Games", "Icon!")
        this.Init()
    }
    
    static StartPong(*) {
        if (this.gameGui) {
            this.gameGui.Hide()
        }
        try {
            Run(A_AhkPath . " `"" . A_ScriptDir . "\classic_pong.ahk`"")
        } catch as e {
            MsgBox("Error launching Pong: " . e.Message, "Error", "Icon!")
            this.Init()
        }
    }
    
    static StartBreakout(*) {
        if (this.gameGui) {
            this.gameGui.Hide()
        }
        MsgBox("Breakout game not implemented yet.`n`nTry one of the other games!", "Mini Games", "Icon!")
        this.Init()
    }
    
    static StartMinesweeper(*) {
        if (this.gameGui) {
            this.gameGui.Hide()
        }
        MsgBox("Minesweeper game not implemented yet.`n`nTry one of the other games!", "Mini Games", "Icon!")
        this.Init()
    }
    
    static StartPacman(*) {
        if (this.gameGui) {
            this.gameGui.Hide()
        }
        try {
            Run(A_AhkPath . " `"" . A_ScriptDir . "\pacman_game.ahk`"")
        } catch as e {
            MsgBox("Error launching Pac-Man: " . e.Message, "Error", "Icon!")
            this.Init()
        }
    }
    
    static StartFrogger(*) {
        if (this.gameGui) {
            this.gameGui.Hide()
        }
        try {
            Run(A_AhkPath . " `"" . A_ScriptDir . "\classic_frogger.ahk`"")
        } catch as e {
            MsgBox("Error launching Frogger: " . e.Message, "Error", "Icon!")
            this.Init()
        }
    }
    
    static StartSudoku(*) {
        if (this.gameGui) {
            this.gameGui.Hide()
        }
        try {
            Run(A_AhkPath . " `"" . A_ScriptDir . "\sudoku.ahk`"")
        } catch as e {
            MsgBox("Error launching Sudoku: " . e.Message, "Error", "Icon!")
            this.Init()
        }
    }
    
    static StartQbert(*) {
        if (this.gameGui) {
            this.gameGui.Hide()
        }
        try {
            Run(A_AhkPath . " `"" . A_ScriptDir . "\qbert_game.ahk`"")
        } catch as e {
            MsgBox("Error launching Q*bert: " . e.Message, "Error", "Icon!")
            this.Init()
        }
    }
    
    static StartChess(*) {
        if (this.gameGui) {
            this.gameGui.Hide()
        }
        try {
            Run(A_AhkPath . " `"" . A_ScriptDir . "\chess_stockfish.ahk`"")
        } catch as e {
            MsgBox("Error launching Chess: " . e.Message, "Error", "Icon!")
            this.Init()
        }
    }
}

; Global hotkeys
^!g:: MiniGames.Init()
#s:: MiniGames.StartSnake()

; Snake game controls
Up:: {
    if (MiniGames.currentGame = "Snake") {
        MiniGames.direction := "up"
    }
}

Down:: {
    if (MiniGames.currentGame = "Snake") {
        MiniGames.direction := "down"
    }
}

Left:: {
    if (MiniGames.currentGame = "Snake") {
        MiniGames.direction := "left"
    }
}

Right:: {
    if (MiniGames.currentGame = "Snake") {
        MiniGames.direction := "right"
    }
}

Esc:: {
    if (MiniGames.currentGame = "Snake") {
        MiniGames.Init()
    }
}

; Initialize - removed duplicate call
; The GUI is initialized by the hotkeys




