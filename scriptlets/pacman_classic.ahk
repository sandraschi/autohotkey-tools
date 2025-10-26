; ==============================================================================
; Pacman Classic
; @name: Pacman Classic
; @version: 1.0.0
; @description: Classic Pacman arcade game with ghosts and dots
; @category: games
; @author: Sandra
; @hotkeys: Arrow keys, Space, P, R
; @enabled: true
; ==============================================================================

#Requires AutoHotkey v2.0+
#SingleInstance Force

class PacmanGame {
    static gui := ""
    static canvas := ""
    static gameBoard := []
    static pacman := {x: 0, y: 0, direction: "right", nextDirection: "right"}
    static ghosts := []
    static dots := []
    static score := 0
    static lives := 3
    static level := 1
    static gameRunning := false
    static gameSpeed := 200
    static timer := ""
    
    ; Game board layout (1 = wall, 0 = empty, 2 = dot, 3 = power pellet)
    static boardLayout := [
        [1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1],
        [1,2,2,2,2,2,2,2,2,1,1,2,2,2,2,2,2,2,2,1],
        [1,2,1,1,2,1,1,1,2,1,1,2,1,1,1,2,1,1,2,1],
        [1,3,1,1,2,1,1,1,2,1,1,2,1,1,1,2,1,1,3,1],
        [1,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,1],
        [1,2,1,1,2,1,1,2,1,1,1,1,2,1,1,2,1,1,2,1],
        [1,2,2,2,2,1,1,2,2,2,2,2,2,1,1,2,2,2,2,1],
        [1,1,1,1,2,1,1,1,1,1,1,1,1,1,1,2,1,1,1,1],
        [0,0,0,1,2,1,1,0,0,0,0,0,0,1,1,2,1,0,0,0],
        [1,1,1,1,2,1,1,1,1,0,0,1,1,1,1,2,1,1,1,1],
        [1,2,2,2,2,2,2,2,2,0,0,2,2,2,2,2,2,2,2,1],
        [1,1,1,1,2,1,1,1,1,0,0,1,1,1,1,2,1,1,1,1],
        [0,0,0,1,2,1,1,0,0,0,0,0,0,1,1,2,1,0,0,0],
        [1,1,1,1,2,1,1,1,1,1,1,1,1,1,1,2,1,1,1,1],
        [1,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,1],
        [1,2,1,1,2,1,1,1,2,1,1,2,1,1,1,2,1,1,2,1],
        [1,2,2,2,2,1,1,2,2,2,2,2,2,1,1,2,2,2,2,1],
        [1,1,1,1,2,1,1,2,1,1,1,1,2,1,1,2,1,1,1,1],
        [1,2,2,2,2,2,2,2,2,1,1,2,2,2,2,2,2,2,2,1],
        [1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1]
    ]
    
    static Init() {
        this.InitializeGame()
        this.CreateGUI()
        this.SetupHotkeys()
    }
    
    static InitializeGame() {
        ; Initialize game board
        this.gameBoard := []
        this.dots := []
        
        for row in this.boardLayout {
            boardRow := []
            for cell in row {
                boardRow.Push(cell)
                if (cell = 2 || cell = 3) {
                    this.dots.Push({x: A_Index - 1, y: A_Index - 1})
                }
            }
            this.gameBoard.Push(boardRow)
        }
        
        ; Initialize Pacman
        this.pacman := {x: 9, y: 15, direction: "right", nextDirection: "right"}
        
        ; Initialize ghosts
        this.ghosts := [
            {x: 9, y: 8, direction: "up", color: "red"},
            {x: 8, y: 8, direction: "left", color: "pink"},
            {x: 10, y: 8, direction: "right", color: "cyan"},
            {x: 9, y: 9, direction: "down", color: "orange"}
        ]
        
        this.score := 0
        this.lives := 3
        this.level := 1
    }
    
    static CreateGUI() {
        this.gui := Gui("+Resize -MaximizeBox", "Pacman Classic")
        this.gui.BackColor := "0x000000"
        this.gui.SetFont("s12 cWhite Bold", "Segoe UI")
        
        ; Title
        this.gui.Add("Text", "x20 y20 w400 Center Bold cYellow", "ðŸ‘» Pacman Classic")
        
        ; Game area
        this.canvas := this.gui.Add("Text", "x20 y60 w400 h400 Background0x000000 Border", "")
        this.canvas.SetFont("s8 cWhite", "Courier New")
        
        ; Score area
        this.gui.Add("Text", "x20 y480 w400 h60 Background0x2d2d2d", "")
        scoreText := this.gui.Add("Text", "x30 y490 w100", "Score: 0")
        livesText := this.gui.Add("Text", "x150 y490 w100", "Lives: 3")
        levelText := this.gui.Add("Text", "x270 y490 w100", "Level: 1")
        
        ; Controls
        this.gui.Add("Text", "x30 y510 w350 c0xaaaaaa", "Controls: Arrow Keys = Move | Space = Start | P = Pause | R = Restart")
        
        ; Store references
        this.gui.scoreText := scoreText
        this.gui.livesText := livesText
        this.gui.levelText := levelText
        
        this.gui.Show("w460 h580")
    }
    
    static StartGame(*) {
        if (this.gameRunning) {
            return
        }
        
        this.gameRunning := true
        this.timer := SetTimer(this.GameTick.Bind(this), this.gameSpeed)
        
        TrayTip("Pacman Started!", "Use arrow keys to move", 2)
    }
    
    static GameTick() {
        if (!this.gameRunning) {
            return
        }
        
        ; Move Pacman
        this.MovePacman()
        
        ; Move ghosts
        this.MoveGhosts()
        
        ; Check collisions
        this.CheckCollisions()
        
        ; Check win condition
        if (this.dots.Length = 0) {
            this.NextLevel()
        }
        
        this.UpdateDisplay()
    }
    
    static MovePacman() {
        ; Try to change direction
        if (this.CanMove(this.pacman.x, this.pacman.y, this.pacman.nextDirection)) {
            this.pacman.direction := this.pacman.nextDirection
        }
        
        ; Move in current direction
        if (this.CanMove(this.pacman.x, this.pacman.y, this.pacman.direction)) {
            switch this.pacman.direction {
                case "up":
                    this.pacman.y--
                case "down":
                    this.pacman.y++
                case "left":
                    this.pacman.x--
                case "right":
                    this.pacman.x++
            }
            
            ; Wrap around screen
            if (this.pacman.x < 0) this.pacman.x := 19
            if (this.pacman.x > 19) this.pacman.x := 0
            
            ; Eat dots
            this.EatDot()
        }
    }
    
    static MoveGhosts() {
        for ghost in this.ghosts {
            ; Simple AI - move towards Pacman
            dx := this.pacman.x - ghost.x
            dy := this.pacman.y - ghost.y
            
            ; Choose direction
            if (Abs(dx) > Abs(dy)) {
                if (dx > 0) {
                    newDirection := "right"
                } else {
                    newDirection := "left"
                }
            } else {
                if (dy > 0) {
                    newDirection := "down"
                } else {
                    newDirection := "up"
                }
            }
            
            ; Try to move in chosen direction
            if (this.CanMove(ghost.x, ghost.y, newDirection)) {
                ghost.direction := newDirection
            }
            
            ; Move ghost
            if (this.CanMove(ghost.x, ghost.y, ghost.direction)) {
                switch ghost.direction {
                    case "up":
                        ghost.y--
                    case "down":
                        ghost.y++
                    case "left":
                        ghost.x--
                    case "right":
                        ghost.x++
                }
                
                ; Wrap around screen
                if (ghost.x < 0) ghost.x := 19
                if (ghost.x > 19) ghost.x := 0
            }
        }
    }
    
    static CanMove(x, y, direction) {
        newX := x
        newY := y
        
        switch direction {
            case "up":
                newY--
            case "down":
                newY++
            case "left":
                newX--
            case "right":
                newX++
        }
        
        ; Check bounds
        if (newX < 0 || newX > 19 || newY < 0 || newY > 19) {
            return false
        }
        
        ; Check walls
        return this.gameBoard[newY + 1][newX + 1] != 1
    }
    
    static EatDot() {
        ; Check if Pacman is on a dot
        for i, dot in this.dots {
            if (dot.x = this.pacman.x && dot.y = this.pacman.y) {
                ; Remove dot
                this.dots.RemoveAt(i)
                
                ; Add score
                this.score += 10
                this.UpdateScore()
                
                ; Check for power pellet
                if (this.gameBoard[this.pacman.y + 1][this.pacman.x + 1] = 3) {
                    this.score += 50
                    this.UpdateScore()
                    ; Could add power pellet effect here
                }
                
                break
            }
        }
    }
    
    static CheckCollisions() {
        ; Check ghost collisions
        for ghost in this.ghosts {
            if (ghost.x = this.pacman.x && ghost.y = this.pacman.y) {
                this.PacmanCaught()
                return
            }
        }
    }
    
    static PacmanCaught() {
        this.lives--
        this.UpdateScore()
        
        if (this.lives <= 0) {
            this.GameOver()
        } else {
            ; Reset Pacman position
            this.pacman.x := 9
            this.pacman.y := 15
            this.pacman.direction := "right"
            this.pacman.nextDirection := "right"
            
            TrayTip("Pacman Caught!", "Lives remaining: " . this.lives, 2)
        }
    }
    
    static NextLevel() {
        this.level++
        this.gameSpeed := Max(100, this.gameSpeed - 20)
        SetTimer(this.timer, this.gameSpeed)
        
        ; Reset for next level
        this.InitializeGame()
        
        TrayTip("Level Complete!", "Starting Level " . this.level, 2)
    }
    
    static GameOver() {
        this.gameRunning := false
        SetTimer(this.timer, 0)
        
        MsgBox("Game Over!`n`nFinal Score: " . this.score . "`nLevel: " . this.level, "Pacman Game Over", "Iconi")
        
        ; Reset for new game
        this.InitializeGame()
        this.UpdateDisplay()
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
                switch cell {
                    case 1:
                        display .= "â–ˆ"  ; Wall
                    case 2:
                        display .= "Â·"  ; Dot
                    case 3:
                        display .= "â—"  ; Power pellet
                    default:
                        display .= " "  ; Empty
                }
            }
            display .= "`n"
        }
        
        ; Draw Pacman
        pacmanChar := "C"
        switch this.pacman.direction {
            case "up":
                pacmanChar := "C"
            case "down":
                pacmanChar := "C"
            case "left":
                pacmanChar := "C"
            case "right":
                pacmanChar := "C"
        }
        
        ; Replace character at Pacman position
        pos := (this.pacman.y * 21) + this.pacman.x + 1
        display := SubStr(display, 1, pos - 1) . pacmanChar . SubStr(display, pos + 1)
        
        ; Draw ghosts
        for ghost in this.ghosts {
            ghostChar := "G"
            switch ghost.color {
                case "red":
                    ghostChar := "R"
                case "pink":
                    ghostChar := "P"
                case "cyan":
                    ghostChar := "C"
                case "orange":
                    ghostChar := "O"
            }
            
            pos := (ghost.y * 21) + ghost.x + 1
            display := SubStr(display, 1, pos - 1) . ghostChar . SubStr(display, pos + 1)
        }
        
        this.canvas.Text := display
    }
    
    static UpdateScore() {
        if (this.gui.scoreText) {
            this.gui.scoreText.Text := "Score: " . this.score
        }
        if (this.gui.livesText) {
            this.gui.livesText.Text := "Lives: " . this.lives
        }
        if (this.gui.levelText) {
            this.gui.levelText.Text := "Level: " . this.level
        }
    }
    
    static SetDirection(direction) {
        this.pacman.nextDirection := direction
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
        TrayTip("Game Resumed", "Pacman continues!", 2)
    }
    
    static SetupHotkeys() {
        ; Movement
        Hotkey("Up", (*) => this.SetDirectio)n("up")
        Hotkey("Down", (*) => this.SetDirectio)n("down")
        Hotkey("Left", (*) => this.SetDirectio)n("left")
        Hotkey("Right", (*) => this.SetDirectio)n("right")
        
        ; Start game
        Hotkey("Space", (*) => this.StartGame()
        
        ; Pause/Resume
        p::{
            if (this.gameRu)nning) {
                this.PauseGame()
            } else {
                this.ResumeGame()
            }
        }
        
        ; Restart
        Hotkey("r", (*) => this.StartGame()
        
        ; Close with Escape
        Escape::{
            if (Wi)nExist("Pacman Classic")) {
                WinClose("Pacman Classic")
            }
        }
    }
}

; Initialize
PacmanGame.Init()





