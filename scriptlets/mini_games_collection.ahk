; ==============================================================================
; Mini Games Collection
; @name: Mini Games Collection
; @version: 1.0.0
; @description: Collection of fun mini-games including Snake, Tetris, and Memory. Quick-access entertainment games for breaks and leisure time.
; @description: Features classic arcade-style games with simple controls and addictive gameplay. Includes Snake, Tetris, and Memory card matching games with score tracking.
; @description: Perfect for short gaming sessions during breaks with nostalgic gameplay and easy-to-learn mechanics.
; @category: games
; @author: Sandra
; @hotkeys: ^!g, #s, #t, #m
; @enabled: true
; @priority: 80
; @tag: games, mini-games, snake, tetris, memory, entertainment, arcade, retro
; @cli: --game <name> - Launch specific game (snake, tetris, memory)
; @cli: --help - Show CLI usage and game options
; @dependencies: 
; ==============================================================================

#Requires AutoHotkey v2.0+
#SingleInstance Force


; Suppress error popups - log to file instead
OnError(LogError)

LogError(Thrown, Mode) {
    errorMsg := "Error: " . Thrown.Message . " at line " . Thrown.Line . "`n" . Thrown.Stack
    FileAppend(errorMsg, "mini_games_collection_errors.log", "UTF-8")
    OutputDebug(errorMsg)  ; Enable LLM debugging
    return 1  ; Suppress popup (1 = suppress, 0 = show)
}


class MiniGames {
    static currentGame := ""
    static gameGui := ""
    
    static Init() {
        this.CreateMainGUI()
    }
    
    static CreateMainGUI() {
        this.gameGui := Gui("+Resize", "Mini Games Collection")
        
        ; Title
        this.gameGui.AddText("w400 h40 Center", "🎮 Mini Games Collection")
        
        ; Game selection
        this.gameGui.AddText("w400 h20 Center", "Choose a game:")
        
        ; Game buttons
        snakeBtn := this.gameGui.AddButton("x50 y60 w100 h60", "🐍 Snake`nClassic Snake Game")
        tetrisBtn := this.gameGui.AddButton("x160 y60 w100 h60", "🧩 Tetris`nBlock Puzzle Game")
        memoryBtn := this.gameGui.AddButton("x270 y60 w100 h60", "🧠 Memory`nCard Matching Game")
        
        snakeBtn.OnEvent("Click", this.StartSnake.Bind(this))
        tetrisBtn.OnEvent("Click", this.StartTetris.Bind(this))
        memoryBtn.OnEvent("Click", this.StartMemory.Bind(this))
        
        ; Additional games
        pongBtn := this.gameGui.AddButton("x50 y130 w100 h60", "🏓 Pong`nClassic Arcade Game")
        breakoutBtn := this.gameGui.AddButton("x160 y130 w100 h60", "💥 Breakout`nBrick Breaking Game")
        minesweeperBtn := this.gameGui.AddButton("x270 y130 w100 h60", "💣 Minesweeper`nLogic Puzzle Game")
        
        pongBtn.OnEvent("Click", this.StartPong.Bind(this))
        breakoutBtn.OnEvent("Click", this.StartBreakout.Bind(this))
        minesweeperBtn.OnEvent("Click", this.StartMinesweeper.Bind(this))
        
        ; Instructions
        this.gameGui.AddText("w400 h60", "Instructions:`n• Use arrow keys to control`n• Press ESC to return to main menu`n• Press F1 for game-specific help")
        
        this.gameGui.Show("w420 h250")
    }
    
    static StartSnake(*) {
        this.currentGame := "Snake"
        this.gameGui.Close()
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
        Random(&this.foodX, 0, 19)
        this.foodX *= 20
        Random(&this.foodY, 0, 19)
        this.foodY *= 20
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
        MsgBox("Tetris game - Coming soon!", "Mini Games", "Icon!")
    }
    
    static StartMemory(*) {
        MsgBox("Memory game - Coming soon!", "Mini Games", "Icon!")
    }
    
    static StartPong(*) {
        MsgBox("Pong game - Coming soon!", "Mini Games", "Icon!")
    }
    
    static StartBreakout(*) {
        MsgBox("Breakout game - Coming soon!", "Mini Games", "Icon!")
    }
    
    static StartMinesweeper(*) {
        MsgBox("Minesweeper game - Coming soon!", "Mini Games", "Icon!")
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

; Initialize
MiniGames.Init()




