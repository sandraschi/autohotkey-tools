#Requires AutoHotkey v2.0+
#SingleInstance Force

; ==============================================================================
; Pac-Man Game
; @name: Pac-Man Game
; @version: 1.0.0
; @description: Classic Pac-Man game with ghosts, pellets, and power-ups
; @category: games
; @author: Sandra
; @hotkeys: ^!p, F9, Escape
; @enabled: true
; ==============================================================================

class PacManGame {
    static gui := ""
    static canvas := ""
    static gameRunning := false
    static pacman := {}
    static ghosts := []
    static pellets := []
    static powerPellets := []
    static score := 0
    static level := 1
    static lives := 3
    static gameTimer := ""
    static logArea := ""
    static statusBar := ""
    
    static Init() {
        this.CreateGUI()
        this.SetupHotkeys()
        this.InitializeGame()
        this.AppendLog("Pac-Man game initialized")
    }
    
    static CreateGUI() {
        this.gui := Gui("+Resize", "Pac-Man Game")
        
        ; Title
        this.gui.Add("Text", "w800 h30 Center", "🟡 Pac-Man Game")
        
        ; Game canvas
        this.canvas := this.gui.Add("Text", "w800 h600 BackgroundBlack Center", "")
        
        ; Score and status
        this.statusBar := this.gui.Add("Text", "w800 h20 Background0xE0E0E0", "Score: 0 | Level: 1 | Lives: 3")
        
        ; Control buttons
        controlPanel := this.gui.Add("Text", "w800 h40")
        
        startBtn := this.gui.Add("Button", "x10 y10 w80 h25", "Start Game")
        pauseBtn := this.gui.Add("Button", "x100 y10 w80 h25", "Pause")
        resetBtn := this.gui.Add("Button", "x190 y10 w80 h25", "Reset")
        helpBtn := this.gui.Add("Button", "x280 y10 w80 h25", "Help")
        
        startBtn.OnEvent("Click", this.StartGame.Bind(this))
        pauseBtn.OnEvent("Click", this.PauseGame.Bind(this))
        resetBtn.OnEvent("Click", this.ResetGame.Bind(this))
        helpBtn.OnEvent("Click", this.ShowHelp.Bind(this))
        
        ; Log area
        this.gui.Add("Text", "w800 h20", "Game Log:")
        this.logArea := this.gui.Add("Edit", "w800 h100 +VScroll +HScroll ReadOnly", "")
        
        this.gui.Show("w820 h800")
        this.gui.OnEvent("Close", this.ExitGame.Bind(this))
    }
    
    static InitializeGame() {
        this.score := 0
        this.level := 1
        this.lives := 3
        this.gameRunning := false
        
        ; Initialize Pac-Man
        this.pacman := {
            x: 400,
            y: 300,
            direction: "right",
            speed: 5,
            powerUp: false,
            powerUpTimer: 0
        }
        
        ; Initialize ghosts
        this.ghosts := []
        ghostColors := ["red", "pink", "cyan", "orange"]
        for i := 1 .. 4 {
            Random(x, 50, 750)
            Random(y, 50, 550)
            this.ghosts.Push({
                x: x,
                y: y,
                color: ghostColors[i],
                direction: "up",
                speed: 3,
                mode: "chase", ; chase, scatter, frightened
                modeTimer: 0
            })
        }
        
        ; Initialize pellets
        this.pellets := []
        this.powerPellets := []
        this.GeneratePellets()
        
        this.UpdateDisplay()
    }
    
    static GeneratePellets() {
        this.pellets := []
        this.powerPellets := []
        
        ; Generate regular pellets
        for x := 50 .. 750 {
            for y := 50 .. 550 {
                if (Mod(x, 40) = 0 && Mod(y, 40) = 0) {
                    this.pellets.Push({x: x, y: y})
                }
            }
        }
        
        ; Generate power pellets (corners)
        powerPositions := [{x: 100, y: 100}, {x: 700, y: 100}, {x: 100, y: 500}, {x: 700, y: 500}]
        for pos in powerPositions {
            this.powerPellets.Push(pos)
        }
        
        this.AppendLog("Generated " . this.pellets.Length . " pellets and " . this.powerPellets.Length . " power pellets")
    }
    
    static StartGame(*) {
        if (!this.gameRunning) {
            this.gameRunning := true
            this.gameTimer := SetTimer(() => this.GameLoop(), 50) ; 20 FPS
            this.AppendLog("Game started")
            this.UpdateStatus()
        }
    }
    
    static PauseGame(*) {
        if (this.gameRunning) {
            this.gameRunning := false
            try {
                SetTimer(this.gameTimer, 0)
            } catch as e {
                this.AppendLog("Error pausing game: " . e.Message)
            }
            this.AppendLog("Game paused")
        } else {
            this.StartGame()
        }
    }
    
    static ResetGame(*) {
        this.gameRunning := false
        try {
            SetTimer(this.gameTimer, 0)
        } catch as e {
            this.AppendLog("Error stopping game: " . e.Message)
        }
        this.InitializeGame()
        this.AppendLog("Game reset")
    }
    
    static GameLoop() {
        if (!this.gameRunning) return
        
        try {
            this.UpdatePacMan()
            this.UpdateGhosts()
            this.CheckCollisions()
            this.UpdateDisplay()
            this.UpdateStatus()
            
            ; Check win condition
            if (this.pellets.Length = 0 && this.powerPellets.Length = 0) {
                this.LevelComplete()
            }
            
        } catch as e {
            this.AppendLog("Game loop error: " . e.Message)
            this.PauseGame()
        }
    }
    
    static UpdatePacMan() {
        ; Handle input
        if (GetKeyState("w", "P") || GetKeyState("Up", "P")) {
            this.pacman.direction := "up"
        } else if (GetKeyState("s", "P") || GetKeyState("Down", "P")) {
            this.pacman.direction := "down"
        } else if (GetKeyState("a", "P") || GetKeyState("Left", "P")) {
            this.pacman.direction := "left"
        } else if (GetKeyState("d", "P") || GetKeyState("Right", "P")) {
            this.pacman.direction := "right"
        }
        
        ; Move Pac-Man
        switch this.pacman.direction {
            case "up":
                this.pacman.y -= this.pacman.speed
            case "down":
                this.pacman.y += this.pacman.speed
            case "left":
                this.pacman.x -= this.pacman.speed
            case "right":
                this.pacman.x += this.pacman.speed
        }
        
        ; Wrap around screen
        if (this.pacman.x < 0) this.pacman.x := 800
        if (this.pacman.x > 800) this.pacman.x := 0
        if (this.pacman.y < 0) this.pacman.y := 600
        if (this.pacman.y > 600) this.pacman.y := 0
        
        ; Update power-up timer
        if (this.pacman.powerUp) {
            this.pacman.powerUpTimer--
            if (this.pacman.powerUpTimer <= 0) {
                this.pacman.powerUp := false
                this.AppendLog("Power-up expired")
            }
        }
    }
    
    static UpdateGhosts() {
        for ghost in this.ghosts {
            ; Simple AI - move towards Pac-Man
            dx := this.pacman.x - ghost.x
            dy := this.pacman.y - ghost.y
            
            if (Abs(dx) > Abs(dy)) {
                ghost.direction := dx > 0 ? "right" : "left"
            } else {
                ghost.direction := dy > 0 ? "down" : "up"
            }
            
            ; Move ghost
            switch ghost.direction {
                case "up":
                    ghost.y -= ghost.speed
                case "down":
                    ghost.y += ghost.speed
                case "left":
                    ghost.x -= ghost.speed
                case "right":
                    ghost.x += ghost.speed
            }
            
            ; Wrap around screen
            if (ghost.x < 0) ghost.x := 800
            if (ghost.x > 800) ghost.x := 0
            if (ghost.y < 0) ghost.y := 600
            if (ghost.y > 600) ghost.y := 0
            
            ; Update mode timer
            ghost.modeTimer--
            if (ghost.modeTimer <= 0) {
                ghost.mode := ghost.mode = "chase" ? "scatter" : "chase"
                ghost.modeTimer := 300
            }
        }
    }
    
    static CheckCollisions() {
        ; Check pellet collisions
        for i := this.pellets.Length .. 1 {
            pellet := this.pellets[i]
            if (this.Distance(this.pacman.x, this.pacman.y, pellet.x, pellet.y) < 15) {
                this.pellets.RemoveAt(i)
                this.score += 10
                this.AppendLog("Pac-Man ate pellet (+10 points)")
            }
        }
        
        ; Check power pellet collisions
        for i := this.powerPellets.Length .. 1 {
            powerPellet := this.powerPellets[i]
            if (this.Distance(this.pacman.x, this.pacman.y, powerPellet.x, powerPellet.y) < 15) {
                this.powerPellets.RemoveAt(i)
                this.score += 50
                this.pacman.powerUp := true
                this.pacman.powerUpTimer := 300
                this.AppendLog("Pac-Man ate power pellet (+50 points, power-up!)")
            }
        }
        
        ; Check ghost collisions
        for ghost in this.ghosts {
            if (this.Distance(this.pacman.x, this.pacman.y, ghost.x, ghost.y) < 20) {
                if (this.pacman.powerUp) {
                    ; Eat ghost
                    this.score += 200
                    this.AppendLog("Pac-Man ate ghost (+200 points)")
                    ; Respawn ghost
                    Random(ghost.x, 50, 750)
                    Random(ghost.y, 50, 550)
                } else {
                    ; Pac-Man dies
                    this.LoseLife()
                }
            }
        }
    }
    
    static LoseLife() {
        this.lives--
        this.AppendLog("Pac-Man died! Lives remaining: " . this.lives)
        
        if (this.lives <= 0) {
            this.GameOver()
        } else {
            ; Respawn Pac-Man
            this.pacman.x := 400
            this.pacman.y := 300
            this.pacman.direction := "right"
        }
    }
    
    static GameOver() {
        this.gameRunning := false
        try {
            SetTimer(this.gameTimer, 0)
        } catch as e {
            this.AppendLog("Error stopping game: " . e.Message)
        }
        this.AppendLog("GAME OVER! Final Score: " . this.score)
        MsgBox("Game Over!`nFinal Score: " . this.score, "Pac-Man Game", "0x30")
    }
    
    static LevelComplete() {
        this.level++
        this.AppendLog("Level " . (this.level - 1) . " complete! Starting level " . this.level)
        this.GeneratePellets()
        this.AppendLog("New level started")
    }
    
    static UpdateDisplay() {
        if (!this.canvas) return
        
        display := ""
        
        ; Draw Pac-Man
        pacmanChar := this.pacman.powerUp ? "🟡" : "🟨"
        display .= "Pac-Man: " . pacmanChar . " at (" . this.pacman.x . ", " . this.pacman.y . ")`n"
        
        ; Draw ghosts
        for i, ghost in this.ghosts {
            ghostChar := ghost.color = "red" ? "🔴" : ghost.color = "pink" ? "🟣" : ghost.color = "cyan" ? "🔵" : "🟠"
            display .= "Ghost " . i . ": " . ghostChar . " at (" . ghost.x . ", " . ghost.y . ")`n"
        }
        
        ; Draw pellets count
        display .= "Pellets remaining: " . this.pellets.Length . "`n"
        display .= "Power pellets remaining: " . this.powerPellets.Length . "`n"
        
        this.canvas.Text := display
    }
    
    static UpdateStatus() {
        if (!this.statusBar) return
        
        status := "Score: " . this.score . " | Level: " . this.level . " | Lives: " . this.lives
        if (this.pacman.powerUp) {
            status .= " | POWER-UP!"
        }
        this.statusBar.Text := status
    }
    
    static Distance(x1, y1, x2, y2) {
        return Sqrt((x2 - x1) ** 2 + (y2 - y1) ** 2)
    }
    
    static ShowHelp(*) {
        helpText := "Pac-Man Game Controls:`n`n"
        helpText .= "WASD or Arrow Keys: Move Pac-Man`n"
        helpText .= "Eat pellets (10 points) and power pellets (50 points)`n"
        helpText .= "Power pellets make ghosts edible for 300 frames`n"
        helpText .= "Eating ghosts gives 200 points`n"
        helpText .= "Avoid ghosts when not powered up!`n`n"
        helpText .= "Hotkeys:`n"
        helpText .= "Ctrl+Alt+P: Start/Show game`n"
        helpText .= "F9: Emergency stop`n"
        helpText .= "Escape: Close game"
        
        MsgBox(helpText, "Pac-Man Help", "0x40")
    }
    
    static ExitGame(*) {
        this.gameRunning := false
        try {
            SetTimer(this.gameTimer, 0)
        } catch as e {
            this.AppendLog("Error stopping game: " . e.Message)
        }
        this.AppendLog("Game exited")
        ExitApp()
    }
    
    static SetupHotkeys() {
        Hotkey("^!p", (*) => this.ShowGUI())
        Hotkey("F9", (*) => this.EmergencyStop())
        Hotkey("Escape", (*) => this.ExitGame())
    }
    
    static ShowGUI(*) {
        this.gui.Show()
        this.gui.Activate()
    }
    
    static EmergencyStop(*) {
        this.gameRunning := false
        try {
            SetTimer(this.gameTimer, 0)
        } catch as e {
            this.AppendLog("Error in emergency stop: " . e.Message)
        }
        this.AppendLog("Emergency stop activated")
        MsgBox("Emergency stop activated!", "Pac-Man Game", "0x30")
    }
    
    static AppendLog(message) {
        if (!this.logArea return
        
        timestamp := FormatTime(A_Now, "HH:mm:ss")
        logMessage := "[" . timestamp . "] " . message . "`n"
        
        try {
            this.logArea.Text .= logMessage
            this.logArea.Focus()
            Send("^{End}")
        } catch as e {
            ; Ignore GUI errors
        }
        
        ; Also log to file
        try {
            FileAppend(logMessage, "pacman.log", "UTF-8")
        } catch {
            ; Ignore file logging errors
        }
    }
}

; Initialize the Pac-Man game
PacManGame.Init()
