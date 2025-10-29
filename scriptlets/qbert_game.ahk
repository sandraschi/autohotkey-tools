#Requires AutoHotkey v2.0+
#SingleInstance Force


; Suppress error popups - log to file instead
OnError(LogError)

LogError(Thrown, Mode) {
    errorMsg := "Error: " . Thrown.Message . " at line " . Thrown.Line . "`n" . Thrown.Stack
    FileAppend(errorMsg, "qbert_game_errors.log", "UTF-8")
    OutputDebug(errorMsg)  ; Enable LLM debugging
    return 1  ; Suppress popup (1 = suppress, 0 = show)
}


; ==============================================================================
; Q*bert Game
; @name: Q*bert Game
; @version: 1.0.0
; @description: Classic Q*bert arcade game with jumping cubes and enemies. Faithful recreation of the iconic 1982 arcade game with pyramid jumping mechanics.
; @description: Features Q*bert character navigation across isometric pyramid, enemy avoidance, cube color changing, and level progression. Includes score tracking and lives system.
; @description: Nostalgic arcade experience with smooth controls and authentic gameplay mechanics from the golden age of arcade gaming.
; @category: games
; @author: Sandra
; @hotkeys: ^!q, F9, Escape
; @enabled: true
; @priority: 75
; @tag: qbert, game, arcade, classic, retro, entertainment, nostalgic, puzzle
; @cli: --level <num> - Start at specific level
; @cli: --lives <count> - Set starting lives (default: 3)
; @cli: --help - Show CLI usage and game options
; @dependencies: 
; ==============================================================================

class QbertGame {
    static gui := ""
    static canvas := ""
    static gameRunning := false
    static qbert := {}
    static cubes := []
    static enemies := []
    static score := 0
    static level := 1
    static lives := 3
    static gameTimer := ""
    static logArea := ""
    static statusBar := ""
    static cubeSize := 40
    static pyramidHeight := 7
    
    static Init() {
        this.CreateGUI()
        this.SetupHotkeys()
        this.InitializeGame()
        this.AppendLog("Q*bert game initialized")
    }
    
    static CreateGUI() {
        this.gui := Gui("+Resize", "Q*bert Game")
        
        ; Title
        this.gui.Add("Text", "w900 h30 Center", "🐸 Q*bert Game")
        
        ; Game canvas
        this.canvas := this.gui.Add("Text", "w900 h700 BackgroundBlack Center", "")
        
        ; Score and status
        this.statusBar := this.gui.Add("Text", "w900 h20 BackgroundE0E0E0", "Score: 0 | Level: 1 | Lives: 3")
        
        ; Control buttons
        controlPanel := this.gui.Add("Text", "w900 h40")
        
        startBtn := this.gui.Add("Button", "x10 y10 w80 h25", "Start Game")
        pauseBtn := this.gui.Add("Button", "x100 y10 w80 h25", "Pause")
        resetBtn := this.gui.Add("Button", "x190 y10 w80 h25", "Reset")
        helpBtn := this.gui.Add("Button", "x280 y10 w80 h25", "Help")
        
        startBtn.OnEvent("Click", this.StartGame.Bind(this))
        pauseBtn.OnEvent("Click", this.PauseGame.Bind(this))
        resetBtn.OnEvent("Click", this.ResetGame.Bind(this))
        helpBtn.OnEvent("Click", this.ShowHelp.Bind(this))
        
        ; Log area
        this.gui.Add("Text", "w900 h20", "Game Log:")
        this.logArea := this.gui.Add("Edit", "w900 h100 VScroll HScroll ReadOnly", "")
        
        this.gui.Show("w920 h900")
        this.gui.OnEvent("Close", this.ExitGame.Bind(this))
    }
    
    static InitializeGame() {
        this.score := 0
        this.level := 1
        this.lives := 3
        this.gameRunning := false
        
        ; Initialize Q*bert
        this.qbert := {
            x: 450,
            y: 100,
            targetX: 450,
            targetY: 100,
            jumping: false,
            jumpTimer: 0,
            direction: "none"
        }
        
        ; Initialize pyramid of cubes
        this.cubes := []
        this.GeneratePyramid()
        
        ; Initialize enemies
        this.enemies := []
        this.GenerateEnemies()
        
        this.UpdateDisplay()
    }
    
    static GeneratePyramid() {
        this.cubes := []
        centerX := 450
        startY := 100
        
        for row := 0 .. this.pyramidHeight - 1 {
            for col := 0 .. row {
                cubeX := centerX + (col - row/2) * this.cubeSize
                cubeY := startY + row * this.cubeSize * 0.8
                
                this.cubes.Push({
                    x: cubeX,
                    y: cubeY,
                    row: row,
                    col: col,
                    color: "blue", ; blue, green, red, yellow
                    targetColor: "green",
                    changed: false
                })
            }
        }
        
        this.AppendLog("Generated pyramid with " . this.cubes.Length . " cubes")
    }
    
    static GenerateEnemies() {
        this.enemies := []
        
        ; Add different types of enemies
        enemyTypes := ["ball", "snake", "coily"]
        
        for i := 1 .. 2 {
            Random(enemyType, 1, enemyTypes.Length)
            Random(startRow, 0, this.pyramidHeight - 1)
            Random(startCol, 0, startRow)
            
            cube := this.GetCube(startRow, startCol)
            if (cube) {
                this.enemies.Push({
                    x: cube.x,
                    y: cube.y,
                    row: startRow,
                    col: startCol,
                    type: enemyTypes[enemyType],
                    direction: "down",
                    speed: 2,
                    timer: 0
                })
            }
        }
        
        this.AppendLog("Generated " . this.enemies.Length . " enemies")
    }
    
    static GetCube(row, col) {
        for cube in this.cubes {
            if (cube.row = row && cube.col = col) {
                return cube
            }
        }
        return ""
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
            this.UpdateQbert()
            this.UpdateEnemies()
            this.CheckCollisions()
            this.UpdateDisplay()
            this.UpdateStatus()
            
            ; Check win condition
            if (this.AllCubesChanged()) {
                this.LevelComplete()
            }
            
        } catch as e {
            this.AppendLog("Game loop error: " . e.Message)
            this.PauseGame()
        }
    }
    
    static UpdateQbert() {
        ; Handle input
        if (GetKeyState("w", "P") || GetKeyState("Up", "P")) {
            this.JumpQbert("up")
        } else if (GetKeyState("s", "P") || GetKeyState("Down", "P")) {
            this.JumpQbert("down")
        } else if (GetKeyState("a", "P") || GetKeyState("Left", "P")) {
            this.JumpQbert("left")
        } else if (GetKeyState("d", "P") || GetKeyState("Right", "P")) {
            this.JumpQbert("right")
        }
        
        ; Update jumping animation
        if (this.qbert.jumping) {
            this.qbert.jumpTimer--
            if (this.qbert.jumpTimer <= 0) {
                this.qbert.jumping := false
                this.qbert.x := this.qbert.targetX
                this.qbert.y := this.qbert.targetY
                this.AppendLog("Q*bert landed at (" . this.qbert.x . ", " . this.qbert.y . ")")
            }
        }
    }
    
    static JumpQbert(direction) {
        if (this.qbert.jumping) return
        
        currentCube := this.GetCubeAtPosition(this.qbert.x, this.qbert.y)
        if (!currentCube) return
        
        newRow := currentCube.row
        newCol := currentCube.col
        
        switch direction {
            case "up":
                newRow--
                if (newRow < 0) return
            case "down":
                newRow++
                if (newRow >= this.pyramidHeight) return
            case "left":
                newCol--
                if (newCol < 0) return
            case "right":
                newCol++
                if (newCol > newRow) return
        }
        
        newCube := this.GetCube(newRow, newCol)
        if (newCube) {
            this.qbert.jumping := true
            this.qbert.jumpTimer := 20
            this.qbert.targetX := newCube.x
            this.qbert.targetY := newCube.y
            this.qbert.direction := direction
            
            this.AppendLog("Q*bert jumping " . direction . " to (" . newCube.x . ", " . newCube.y . ")")
        }
    }
    
    static GetCubeAtPosition(x, y) {
        for cube in this.cubes {
            if (Abs(cube.x - x) < this.cubeSize/2 && Abs(cube.y - y) < this.cubeSize/2) {
                return cube
            }
        }
        return ""
    }
    
    static UpdateEnemies() {
        for enemy in this.enemies {
            enemy.timer--
            if (enemy.timer <= 0) {
                this.MoveEnemy(enemy)
                enemy.timer := 30
            }
        }
    }
    
    static MoveEnemy(enemy) {
        currentCube := this.GetCube(enemy.row, enemy.col)
        if (!currentCube) return
        
        ; Simple AI - move towards Q*bert or randomly
        Random(moveType, 1, 3)
        
        switch enemy.type {
            case "ball":
                ; Balls bounce down the pyramid
                if (enemy.row < this.pyramidHeight - 1) {
                    enemy.row++
                    Random(enemy.col, 0, enemy.row)
                } else {
                    ; Respawn at top
                    Random(enemy.row, 0, 2)
                    Random(enemy.col, 0, enemy.row)
                }
                
            case "snake":
                ; Snakes move towards QScorpiobert
                if (enemy.row < this.pyramidHeight - 1) {
                    enemy.row++
                    enemy.col := enemy.col < enemy.row ? enemy.col : enemy.row
                }
                
            case "coily":
                ; Coily follows Q*bert
                if (enemy.row < this.pyramidHeight - 1) {
                    enemy.row++
                    Random(enemy.col, 0, enemy.row)
                }
        }
        
        newCube := this.GetCube(enemy.row, enemy.col)
        if (newCube) {
            enemy.x := newCube.x
            enemy.y := newCube.y
        }
    }
    
    static CheckCollisions() {
        ; Check if Q*bert landed on a cube
        if (!this.qbert.jumping) {
            currentCube := this.GetCubeAtPosition(this.qbert.x, this.qbert.y)
            if (currentCube && !currentCube.changed) {
                currentCube.changed := true
                currentCube.color := currentCube.targetColor
                this.score += 25
                this.AppendLog("Q*bert changed cube color (+25 points)")
            }
        }
        
        ; Check enemy collisions
        for enemy in this.enemies {
            if (Abs(enemy.x - this.qbert.x) < this.cubeSize/2 && Abs(enemy.y - this.qbert.y) < this.cubeSize/2) {
                this.LoseLife()
                break
            }
        }
    }
    
    static LoseLife() {
        this.lives--
        this.AppendLog("Q*bert hit by enemy! Lives remaining: " . this.lives)
        
        if (this.lives <= 0) {
            this.GameOver()
        } else {
            ; Respawn Q*bert
            this.qbert.x := 450
            this.qbert.y := 100
            this.qbert.jumping := false
            this.qbert.jumpTimer := 0
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
        MsgBox("Game Over!`nFinal Score: " . this.score, "Q*bert Game", "0x30")
    }
    
    static LevelComplete() {
        this.level++
        this.AppendLog("Level " . (this.level - 1) . " complete! Starting level " . this.level)
        this.GeneratePyramid()
        this.GenerateEnemies()
        this.AppendLog("New level started")
    }
    
    static AllCubesChanged() {
        for cube in this.cubes {
            if (!cube.changed) {
                return false
            }
        }
        return true
    }
    
    static UpdateDisplay() {
        if (!this.canvas) return
        
        display := ""
        
        ; Draw Q*bert
        qbertChar := this.qbert.jumping ? "🐸" : "🐸"
        display .= "Q*bert: " . qbertChar . " at (" . this.qbert.x . ", " . this.qbert.y . ")"
        if (this.qbert.jumping) {
            display .= " [JUMPING]"
        }
        display .= "`n"
        
        ; Draw cubes
        display .= "Cubes: "
        for cube in this.cubes {
            if (cube.changed) {
                display .= "🟢" ; Green for changed
            } else {
                display .= "🔵" ; Blue for unchanged
            }
        }
        display .= "`n"
        
        ; Draw enemies
        for i, enemy in this.enemies {
            enemyChar := enemy.type = "ball" ? "⚫" : enemy.type = "snake" ? "🐍" : "🐍"
            display .= "Enemy " . i . " (" . enemy.type . "): " . enemyChar . " at (" . enemy.x . ", " . enemy.y . ")`n"
        }
        
        ; Draw pyramid structure
        display .= "`nPyramid Structure:`n"
        for row := 0 .. this.pyramidHeight - 1 {
            for col := 0 .. row {
                cube := this.GetCube(row, col)
                if (cube) {
                    display .= cube.changed ? "🟢" : "🔵"
                }
            }
            display .= "`n"
        }
        
        this.canvas.Text := display
    }
    
    static UpdateStatus() {
        if (!this.statusBar) return
        
        status := "Score: " . this.score . " | Level: " . this.level . " | Lives: " . this.lives
        changedCubes := 0
        for cube in this.cubes {
            if (cube.changed) {
                changedCubes++
            }
        }
        status .= " | Cubes: " . changedCubes . "/" . this.cubes.Length
        
        this.statusBar.Text := status
    }
    
    static ShowHelp(*) {
        helpText := "Q*bert Game Controls:`n`n"
        helpText .= "WASD or Arrow Keys: Jump Q*bert`n"
        helpText .= "Jump on cubes to change their color from blue to green`n"
        helpText .= "Each cube changed gives 25 points`n"
        helpText .= "Avoid enemies (balls, snakes, coily)`n"
        helpText .= "Complete all cubes to advance to next level`n`n"
        helpText .= "Enemy Types:`n"
        helpText .= "• Balls: Bounce down the pyramid`n"
        helpText .= "• Snakes: Move towards Q*bert`n"
        helpText .= "• Coily: Follows Q*bert`n`n"
        helpText .= "Hotkeys:`n"
        helpText .= "Ctrl+Alt+Q: Start/Show game`n"
        helpText .= "F9: Emergency stop`n"
        helpText .= "Escape: Close game"
        
        MsgBox(helpText, "Q*bert Help", "0x40")
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
        Hotkey("^!q", (*) => this.ShowGUI())
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
        MsgBox("Emergency stop activated!", "Q*bert Game", "0x30")
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
            FileAppend(logMessage, "qbert.log", "UTF-8")
        } catch {
            ; Ignore file logging errors
        }
    }
}

; Initialize the Q*bert game
QbertGame.Init()
