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
        this.gameGui.Add("Text", "w400 h40 Center", "ðŸŽ® Mini Games Collection")
        
        ; Game selection
        this.gameGui.Add("Text", "w400 h20 Center", "Choose a game:")
        
        ; Game buttons
        snakeBtn := this.gameGui.Add("Button", "x50 y60 w100 h60", "ðŸ Snake`nClassic Snake Game")
        tetrisBtn := this.gameGui.Add("Button", "x160 y60 w100 h60", "ðŸ§© Tetris`nBlock Puzzle Game")
        memoryBtn := this.gameGui.Add("Button", "x270 y60 w100 h60", "ðŸ§  Memory`nCard Matching Game")
        
        snakeBtn.OnEvent("Click", this.StartSnake.Bind(this))
        tetrisBtn.OnEvent("Click", this.StartTetris.Bind(this))
        memoryBtn.OnEvent("Click", this.StartMemory.Bind(this))
        
        ; Additional games
        pongBtn := this.gameGui.Add("Button", "x50 y130 w100 h60", "ðŸ“ Pong`nClassic Arcade Game")
        breakoutBtn := this.gameGui.Add("Button", "x160 y130 w100 h60", "ðŸ’¥ Breakout`nBrick Breaking Game")
        minesweeperBtn := this.gameGui.Add("Button", "x270 y130 w100 h60", "ðŸ’£ Minesweeper`nLogic Puzzle Game")
        
        pongBtn.OnEvent("Click", this.StartPong.Bind(this))
        breakoutBtn.OnEvent("Click", this.StartBreakout.Bind(this))
        minesweeperBtn.OnEvent("Click", this.StartMinesweeper.Bind(this))
        
        ; Instructions
        this.gameGui.Add("Text", "w400 h60", "Instructions:`nâ€¢ Use arrow keys to control`nâ€¢ Press ESC to return to main menu`nâ€¢ Press F1 for game-specific help")
        
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
        this.gameGui.Add("Text", "w400 h400 BackgroundBlack", "")
        
        ; Score
        this.gameGui.Add("Text", "w400 h30", "Score: 0")
        
        ; Controls
        this.gameGui.Add("Text", "w400 h30", "Controls: Arrow Keys | ESC: Menu | SPACE: Pause")
        
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
        ; Clear screen
        this.gameGui.Control["Text1"].Text := ""
        
        ; Draw snake
        for i, x in this.snakeX {
            y := this.snakeY[i]
            ; Draw snake segment (simplified)
        }
        
        ; Draw food
        ; Draw food (simplified)
        
        ; Update score
        this.gameGui.Control["Text2"].Text := "Score: " . this.score
    }
    
    static GenerateFood() {
        Random(this.foodX, 0, 19)
        this.foodX *= 20
        Random(this.foodY, 0, 19)
        this.foodY *= 20
    }
    
    static GameOver() {
        SetTimer(this.SnakeGameLoop.Bind(this), 0)
        MsgBox("Game Over! Score: " . this.score, "Snake Game", "0x40")
        this.Init()
    }
    
    static SetupSnakeHotkeys() {
        ; Arrow key handlers - these need to be global hotkeys
        ; Note: Hotkeys in static methods don't work in AutoHotkey v2
        ; This method is kept for compatibility but hotkeys are defined globally
    }
    
    static StartTetris(*) {
        this.currentGame := "Tetris"
        this.gameGui.Close()
        this.CreateTetrisGame()
    }
    
    static CreateTetrisGame() {
        this.gameGui := Gui("+Resize", "Tetris Game")
        
        ; Game area
        this.gameGui.Add("Text", "w300 h600 BackgroundBlack", "")
        
        ; Score and next piece
        this.gameGui.Add("Text", "w150 h100", "Score: 0`nLines: 0`nLevel: 1`n`nNext Piece:")
        
        ; Controls
        this.gameGui.Add("Text", "w300 h30", "Controls: Arrow Keys | SPACE: Drop | R: Rotate | ESC: Menu")
        
        this.gameGui.Show("w470 h650")
        
        ; Initialize game
        this.tetrisBoard := []
        this.score := 0
        this.lines := 0
        this.level := 1
        
        ; Initialize board
        Loop 20 {
            row := []
            Loop 10 {
                row.Push(0)
            }
            this.tetrisBoard.Push(row)
        }
        
        this.GeneratePiece()
        SetTimer(this.TetrisGameLoop.Bind(this), 500)
        this.SetupTetrisHotkeys()
    }
    
    static TetrisGameLoop() {
        ; Move piece down
        this.MovePieceDown()
        this.DrawTetris()
    }
    
    static MovePieceDown() {
        ; Tetris piece movement logic
    }
    
    static DrawTetris() {
        ; Draw tetris board
    }
    
    static GeneratePiece() {
        ; Generate new tetris piece
    }
    
    static SetupTetrisHotkeys() {
        ; Tetris controls
        Hotkey("Up", (*) => this.RotatePiece()
        Dow)Hotkey("n", (*) => this.MovePieceDow)n()
        Hotkey("Left", (*) => this.MovePieceLeft()
        Right::this.MovePieceRight()
        Space::this.DropPiece()
        Escape::this.I)nit()
    }
    
    static StartMemory(*) {
        this.currentGame := "Memory"
        this.gameGui.Close()
        this.CreateMemoryGame()
    }
    
    static CreateMemoryGame() {
        this.gameGui := Gui("+Resize", "Memory Game")
        
        ; Game grid
        this.gameGui.Add("Text", "w400 h400", "")
        
        ; Score and moves
        this.gameGui.Add("Text", "w400 h30", "Score: 0 | Moves: 0 | Time: 0s")
        
        ; Controls
        this.gameGui.Add("Text", "w400 h30", "Click cards to flip them. Match pairs to score points!")
        
        this.gameGui.Show("w420 h480")
        
        ; Initialize game
        this.memoryCards := []
        this.flippedCards := []
        this.score := 0
        this.moves := 0
        this.startTime := A_TickCount
        
        this.GenerateMemoryCards()
        this.DrawMemoryGame()
        SetTimer(this.UpdateMemoryTimer.Bind(this), 1000)
    }
    
    static GenerateMemoryCards() {
        ; Generate memory card pairs
        symbols := ["ðŸ¶", "ðŸ±", "ðŸ­", "ðŸ¹", "ðŸ°", "ðŸ¦Š", "ðŸ»", "ðŸ¼"]
        this.memoryCards := []
        
        ; Create pairs
        for symbol in symbols {
            this.memoryCards.Push(symbol)
            this.memoryCards.Push(symbol)
        }
        
        ; Shuffle
        for i := this.memoryCards.Length .. 2 {
            j := 0
            Random(j, 1, i)
            temp := this.memoryCards[i]
            this.memoryCards[i] := this.memoryCards[j]
            this.memoryCards[j] := temp
        }
    }
    
    static DrawMemoryGame() {
        ; Draw memory game grid
    }
    
    static UpdateMemoryTimer() {
        elapsed := (A_TickCount - this.startTime) // 1000
        this.gameGui.Control["Text2"].Text := "Score: " . this.score . " | Moves: " . this.moves . " | Time: " . elapsed . "s"
    }
    
    static StartPong(*) {
        this.currentGame := "Pong"
        this.gameGui.Close()
        this.CreatePongGame()
    }
    
    static CreatePongGame() {
        this.gameGui := Gui("+Resize", "Pong Game")
        
        ; Game area
        this.gameGui.Add("Text", "w600 h400 BackgroundBlack", "")
        
        ; Score
        this.gameGui.Add("Text", "w600 h30", "Player: 0 | Computer: 0")
        
        ; Controls
        this.gameGui.Add("Text", "w600 h30", "Controls: W/S for paddle | ESC: Menu")
        
        this.gameGui.Show("w620 h480")
        
        ; Initialize game
        this.ballX := 300
        this.ballY := 200
        this.ballDX := 5
        this.ballDY := 3
        this.playerY := 150
        this.computerY := 150
        this.playerScore := 0
        this.computerScore := 0
        
        SetTimer(this.PongGameLoop.Bind(this), 50)
        this.SetupPongHotkeys()
    }
    
    static PongGameLoop() {
        ; Move ball
        this.ballX += this.ballDX
        this.ballY += this.ballDY
        
        ; Ball collision with walls
        if (this.ballY <= 0 || this.ballY >= 400) {
            this.ballDY := -this.ballDY
        }
        
        ; Ball collision with paddles
        if (this.ballX <= 20 && this.ballY >= this.playerY && this.ballY <= this.playerY + 100) {
            this.ballDX := -this.ballDX
        }
        
        if (this.ballX >= 580 && this.ballY >= this.computerY && this.ballY <= this.computerY + 100) {
            this.ballDX := -this.ballDX
        }
        
        ; Score
        if (this.ballX < 0) {
            this.computerScore++
            this.ResetBall()
        }
        
        if (this.ballX > 600) {
            this.playerScore++
            this.ResetBall()
        }
        
        ; AI paddle
        if (this.computerY + 50 < this.ballY) {
            this.computerY += 3
        } else if (this.computerY + 50 > this.ballY) {
            this.computerY -= 3
        }
        
        this.DrawPong()
    }
    
    static DrawPong() {
        ; Draw pong game
        this.gameGui.Control["Text2"].Text := "Player: " . this.playerScore . " | Computer: " . this.computerScore
    }
    
    static ResetBall() {
        this.ballX := 300
        this.ballY := 200
        direction := 0
        Random(direction, 0, 1)
        this.ballDX := direction ? 5 : -5
        Random(direction, 0, 1)
        this.ballDY := direction ? 3 : -3
    }
    
    static SetupPongHotkeys() {
        Hotkey("w", (*) => this.playerY -= 20
        s::this.playerY += 20
        Escape::this.I)nit()
    }
    
    static StartBreakout(*) {
        this.currentGame := "Breakout"
        this.gameGui.Close()
        this.CreateBreakoutGame()
    }
    
    static CreateBreakoutGame() {
        this.gameGui := Gui("+Resize", "Breakout Game")
        
        ; Game area
        this.gameGui.Add("Text", "w500 h400 BackgroundBlack", "")
        
        ; Score and lives
        this.gameGui.Add("Text", "w500 h30", "Score: 0 | Lives: 3")
        
        ; Controls
        this.gameGui.Add("Text", "w500 h30", "Controls: A/D for paddle | SPACE: Launch ball | ESC: Menu")
        
        this.gameGui.Show("w520 h480")
        
        ; Initialize game
        this.ballX := 250
        this.ballY := 300
        this.ballDX := 0
        this.ballDY := 0
        this.paddleX := 200
        this.score := 0
        this.lives := 3
        this.ballLaunched := false
        
        this.GenerateBricks()
        this.DrawBreakout()
        this.SetupBreakoutHotkeys()
    }
    
    static GenerateBricks() {
        this.bricks := []
        Loop 5 {
            Loop 10 {
                this.bricks.Push({x: 50 + A_Index * 40, y: 50 + A_Index * 20, active: true})
            }
        }
    }
    
    static DrawBreakout() {
        ; Draw breakout game
    }
    
    static SetupBreakoutHotkeys() {
        Hotkey("a", (*) => this.paddleX -= 20
        d::this.paddleX += 20
        Space::this.Lau)nchBall()
        Hotkey("Escape", (*) => this.I)nit()
    }
    
    static LaunchBall() {
        if (!this.ballLaunched) {
            direction := 0
            Random(direction, 0, 1)
            this.ballDX := direction ? 5 : -5
            this.ballDY := -5
            this.ballLaunched := true
        }
    }
    
    static StartMinesweeper(*) {
        this.currentGame := "Minesweeper"
        this.gameGui.Close()
        this.CreateMinesweeperGame()
    }
    
    static CreateMinesweeperGame() {
        this.gameGui := Gui("+Resize", "Minesweeper Game")
        
        ; Game grid
        this.gameGui.Add("Text", "w400 h400", "")
        
        ; Game info
        this.gameGui.Add("Text", "w400 h30", "Mines: 10 | Time: 0s | Status: Playing")
        
        ; Controls
        this.gameGui.Add("Text", "w400 h30", "Left Click: Reveal | Right Click: Flag | ESC: Menu")
        
        this.gameGui.Show("w420 h480")
        
        ; Initialize game
        this.gridSize := 10
        this.mineCount := 10
        this.grid := []
        this.revealed := []
        this.flagged := []
        this.gameWon := false
        this.gameLost := false
        this.startTime := A_TickCount
        
        this.GenerateMinesweeperGrid()
        this.DrawMinesweeper()
        SetTimer(this.UpdateMinesweeperTimer.Bind(this), 1000)
    }
    
    static GenerateMinesweeperGrid() {
        ; Initialize grid
        Loop this.gridSize {
            row := []
            revealedRow := []
            flaggedRow := []
            Loop this.gridSize {
                row.Push(0)
                revealedRow.Push(false)
                flaggedRow.Push(false)
            }
            this.grid.Push(row)
            this.revealed.Push(revealedRow)
            this.flagged.Push(flaggedRow)
        }
        
        ; Place mines
        minesPlaced := 0
        while (minesPlaced < this.mineCount) {
            x := 0
            y := 0
            Random(x, 0, this.gridSize - 1)
            Random(y, 0, this.gridSize - 1)
            if (this.grid[y][x] != -1) {
                this.grid[y][x] := -1
                minesPlaced++
            }
        }
        
        ; Calculate numbers
        Loop this.gridSize {
            y := A_Index - 1
            Loop this.gridSize {
                x := A_Index - 1
                if (this.grid[y][x] != -1) {
                    count := 0
                    Loop 3 {
                        dy := A_Index - 2
                        Loop 3 {
                            dx := A_Index - 2
                            nx := x + dx
                            ny := y + dy
                            if (nx >= 0 && nx < this.gridSize && ny >= 0 && ny < this.gridSize) {
                                if (this.grid[ny][nx] = -1) {
                                    count++
                                }
                            }
                        }
                    }
                    this.grid[y][x] := count
                }
            }
        }
    }
    
    static DrawMinesweeper() {
        ; Draw minesweeper grid
    }
    
    static UpdateMinesweeperTimer() {
        elapsed := (A_TickCount - this.startTime) // 1000
        this.gameGui.Control["Text2"].Text := "Mines: " . this.mineCount . " | Time: " . elapsed . "s | Status: " . (this.gameWon ? "Won!" : this.gameLost ? "Lost!" : "Playing")
    }
}

; Hotkeys
^!Hotkey("g", (*) => Mi)niGames.Init()
#Hotkey("s", (*) => Mi)niGames.StartSnake()
#Hotkey("t", (*) => Mi)niGames.StartTetris()
#Hotkey("m", (*) => Mi)niGames.StartMemory()

; Snake game controls (only active when snake game is running)
Hotkey("Up", (*) => {
    if (Mi)niGames.currentGame = "Snake") {
        MiniGames.direction := "up"
    }
}
Hotkey("Down", (*) => {
    if (Mi)niGames.currentGame = "Snake") {
        MiniGames.direction := "down"
    }
}
Hotkey("Left", (*) => {
    if (Mi)niGames.currentGame = "Snake") {
        MiniGames.direction := "left"
    }
}
Hotkey("Right", (*) => {
    if (Mi)niGames.currentGame = "Snake") {
        MiniGames.direction := "right"
    }
}
Hotkey("Escape", (*) => {
    if (Mi)niGames.currentGame = "Snake") {
        MiniGames.Init()
    }
}

; Initialize
MiniGames.Init()



    }

    

    static StartPong(*) {

        this.currentGame := "Pong"

        this.gameGui.Close()

        this.CreatePongGame()

    }

    

    static CreatePongGame() {

        this.gameGui := Gui("+Resize", "Pong Game")

        

        ; Game area

        this.gameGui.Add("Text", "w600 h400 BackgroundBlack", "")

        

        ; Score

        this.gameGui.Add("Text", "w600 h30", "Player: 0 | Computer: 0")

        

        ; Controls

        this.gameGui.Add("Text", "w600 h30", "Controls: W/S for paddle | ESC: Menu")

        

        this.gameGui.Show("w620 h480")

        

        ; Initialize game

        this.ballX := 300

        this.ballY := 200

        this.ballDX := 5

        this.ballDY := 3

        this.playerY := 150

        this.computerY := 150

        this.playerScore := 0

        this.computerScore := 0

        

        SetTimer(this.PongGameLoop.Bind(this), 50)

        this.SetupPongHotkeys()

    }

    

    static PongGameLoop() {

        ; Move ball

        this.ballX += this.ballDX

        this.ballY += this.ballDY

        

        ; Ball collision with walls

        if (this.ballY <= 0 || this.ballY >= 400) {

            this.ballDY := -this.ballDY

        }

        

        ; Ball collision with paddles

        if (this.ballX <= 20 && this.ballY >= this.playerY && this.ballY <= this.playerY + 100) {

            this.ballDX := -this.ballDX

        }

        

        if (this.ballX >= 580 && this.ballY >= this.computerY && this.ballY <= this.computerY + 100) {

            this.ballDX := -this.ballDX

        }

        

        ; Score

        if (this.ballX < 0) {

            this.computerScore++

            this.ResetBall()

        }

        

        if (this.ballX > 600) {

            this.playerScore++

            this.ResetBall()

        }

        

        ; AI paddle

        if (this.computerY + 50 < this.ballY) {

            this.computerY += 3

        } else if (this.computerY + 50 > this.ballY) {

            this.computerY -= 3

        }

        

        this.DrawPong()

    }

    

    static DrawPong() {

        ; Draw pong game

        this.gameGui.Control["Text2"].Text := "Player: " . this.playerScore . " | Computer: " . this.computerScore

    }

    

    static ResetBall() {

        this.ballX := 300

        this.ballY := 200

        this.ballDX := Random(0, 1) ? 5 : -5

        this.ballDY := Random(0, 1) ? 3 : -3

    }

    
    
    static SetupPongHotkeys() {

        Hotkey("w", (*) => this.playerY -= 20

        s::this.playerY += 20

        Escape::this.I)nit()

    }

    
    
    static StartBreakout(*) {

        this.currentGame := "Breakout"

        this.gameGui.Close()

        this.CreateBreakoutGame()

    }

    
    
    static CreateBreakoutGame() {

        this.gameGui := Gui("+Resize", "Breakout Game")

        
        
        ; Game area

        this.gameGui.Add("Text", "w500 h400 BackgroundBlack", "")

        
        
        ; Score and lives

        this.gameGui.Add("Text", "w500 h30", "Score: 0 | Lives: 3")

        
        
        ; Controls

        this.gameGui.Add("Text", "w500 h30", "Controls: A/D for paddle | SPACE: Launch ball | ESC: Menu")

        
        
        this.gameGui.Show("w520 h480")

        
        
        ; Initialize game

        this.ballX := 250

        this.ballY := 300

        this.ballDX := 0

        this.ballDY := 0

        this.paddleX := 200

        this.score := 0

        this.lives := 3

        this.ballLaunched := false

        
        
        this.GenerateBricks()

        this.DrawBreakout()

        this.SetupBreakoutHotkeys()

    }

    
    
    static GenerateBricks() {

        this.bricks := []

        Loop 5 {

            Loop 10 {

                this.bricks.Push({x: 50 + A_Index * 40, y: 50 + A_Index * 20, active: true})

            }

        }

    }

    
    
    static DrawBreakout() {

        ; Draw breakout game

    }

    
    
    static SetupBreakoutHotkeys() {

        Hotkey("a", (*) => this.paddleX -= 20

        d::this.paddleX += 20

        Space::this.Lau)nchBall()

        Hotkey("Escape", (*) => this.I)nit()

    }

    
    
    static LaunchBall() {

        if (!this.ballLaunched) {

            this.ballDX := Random(0, 1) ? 5 : -5

            this.ballDY := -5

            this.ballLaunched := true

        }

    }

    
    
    static StartMinesweeper(*) {

        this.currentGame := "Minesweeper"

        this.gameGui.Close()

        this.CreateMinesweeperGame()

    }

    
    
    static CreateMinesweeperGame() {

        this.gameGui := Gui("+Resize", "Minesweeper Game")

        
        
        ; Game grid

        this.gameGui.Add("Text", "w400 h400", "")

        
        
        ; Game info

        this.gameGui.Add("Text", "w400 h30", "Mines: 10 | Time: 0s | Status: Playing")

        
        
        ; Controls

        this.gameGui.Add("Text", "w400 h30", "Left Click: Reveal | Right Click: Flag | ESC: Menu")

        
        
        this.gameGui.Show("w420 h480")

        
        
        ; Initialize game

        this.gridSize := 10

        this.mineCount := 10

        this.grid := []

        this.revealed := []

        this.flagged := []

        this.gameWon := false

        this.gameLost := false

        this.startTime := A_TickCount

        
        
        this.GenerateMinesweeperGrid()

        this.DrawMinesweeper()

        SetTimer(this.UpdateMinesweeperTimer.Bind(this), 1000)

    }

    
    
    static GenerateMinesweeperGrid() {

        ; Initialize grid

        Loop this.gridSize {

            row := []

            revealedRow := []

            flaggedRow := []

            Loop this.gridSize {

                row.Push(0)

                revealedRow.Push(false)

                flaggedRow.Push(false)

            }

            this.grid.Push(row)

            this.revealed.Push(revealedRow)

            this.flagged.Push(flaggedRow)

        }

        
        
        ; Place mines

        minesPlaced := 0

        while (minesPlaced < this.mineCount) {

            x := Random(0, this.gridSize - 1)

            y := Random(0, this.gridSize - 1)

            if (this.grid[y][x] != -1) {

                this.grid[y][x] := -1

                minesPlaced++

            }

        }

        
        
        ; Calculate numbers

        Loop this.gridSize {

            y := A_Index - 1

            Loop this.gridSize {

                x := A_Index - 1

                if (this.grid[y][x] != -1) {

                    count := 0

                    Loop 3 {

                        dy := A_Index - 2

                        Loop 3 {

                            dx := A_Index - 2

                            nx := x + dx

                            ny := y + dy

                            if (nx >= 0 && nx < this.gridSize && ny >= 0 && ny < this.gridSize) {

                                if (this.grid[ny][nx] = -1) {

                                    count++

                                }

                            }

                        }

                    }

                    this.grid[y][x] := count

                }

            }

        }

    }

    
    
    static DrawMinesweeper() {

        ; Draw minesweeper grid

    }

    
    
    static UpdateMinesweeperTimer() {

        elapsed := (A_TickCount - this.startTime) // 1000

        this.gameGui.Control["Text2"].Text := "Mines: " . this.mineCount . " | Time: " . elapsed . "s | Status: " . (this.gameWon ? "Won!" : this.gameLost ? "Lost!" : "Playing")

    }

}



; Hotkeys

^!Hotkey("g", (*) => Mi)niGames.Init()

#Hotkey("s", (*) => Mi)niGames.StartSnake()

#Hotkey("t", (*) => Mi)niGames.StartTetris()

#Hotkey("m", (*) => Mi)niGames.StartMemory()



; Snake game controls (only active when snake game is running)

Hotkey("Up", (*) => {

    if (Mi)niGames.currentGame = "Snake") {

        MiniGames.direction := "up"

    }

}

Hotkey("Down", (*) => {

    if (Mi)niGames.currentGame = "Snake") {

        MiniGames.direction := "down"

    }

}

Hotkey("Left", (*) => {

    if (Mi)niGames.currentGame = "Snake") {

        MiniGames.direction := "left"

    }

}

Hotkey("Right", (*) => {

    if (Mi)niGames.currentGame = "Snake") {

        MiniGames.direction := "right"

    }

}

Hotkey("Escape", (*) => {

    if (Mi)niGames.currentGame = "Snake") {

        MiniGames.Init()

    }

}



; Initialize

MiniGames.Init()




