#Requires AutoHotkey v2.0+
#SingleInstance Force


; Suppress error popups - log to file instead
OnError("LogError")

LogError(Exception, Mode) {
    FileAppend("Error: " . Exception.Message . " at line " . Exception.Line . "
", "errors.log", "UTF-8")
    return true  ; Suppress popup
}


; Snake Game
^!s:: {
    snake := SnakeGame()
    snake.Start()
}

class SnakeGame {
    gridSize := 20
    gridWidth := 30
    gridHeight := 20
    snake := []
    snakeLength := 5
    direction := "right"
    foodX := 0
    foodY := 0
    gui := ""
    canvas := ""
    
    Start() {
        this.snake := []
        this.snakeLength := 5
        this.direction := "right"
        
        ; Initialize snake
        Loop this.snakeLength {
            this.snake.Push({x: A_Index, y: 1})
        }
        
        ; Place first food
        Random(&this.foodX, 1, this.gridWidth)
        Random(&this.foodY, 1, this.gridHeight)
        
        ; Create GUI
        this.gui := Gui("+AlwaysOnTop -Caption +ToolWindow")
        this.gui.BackColor := "000000"
        this.canvas := this.gui.AddText("w600 h400 vCanvas", "")
        
        ; Create timer
        SetTimer (this.GameLoop.Bind(this)), 150
        
        ; Show game window
        this.gui.Show("w600 h400", "Snake Game")
        
        ; Control snake with arrow keys
        Hotkey("Up", (this) => this.SetDirection("up"), "On")
        Hotkey("Down", (this) => this.SetDirection("down"), "On")
        Hotkey("Left", (this) => this.SetDirection("left"), "On")
        Hotkey("Right", (this) => this.SetDirection("right"), "On")
        
        this.gui.OnEvent("Close", (*) => this.Cleanup())
    }
    
    SetDirection(dir) {
        if ((dir = "up" && this.direction != "down") ||
            (dir = "down" && this.direction != "up") ||
            (dir = "left" && this.direction != "right") ||
            (dir = "right" && this.direction != "left")) {
            this.direction := dir
        }
    }
    
    GameLoop() {
        ; Move snake
        headX := this.snake[1].x
        headY := this.snake[1].y
        
        switch this.direction {
            case "right": headX++
            case "left": headX--
            case "up": headY--
            case "down": headY++
        }
        
        ; Check collisions
        if (headX < 1 || headX > this.gridWidth || headY < 1 || headY > this.gridHeight) {
            this.GameOver()
            return
        }
        
        ; Check if food eaten
        if (headX = this.foodX && headY = this.foodY) {
            this.snakeLength++
            Random(&this.foodX, 1, this.gridWidth)
            Random(&this.foodY, 1, this.gridHeight)
        } else {
            this.snake.Pop()
        }
        
        ; Add new head
        this.snake.InsertAt(1, {x: headX, y: headY})
        
        ; Draw game
        this.Draw()
    }
    
    Draw() {
        grid := ""
        Loop this.gridHeight {
            y := A_Index
            row := ""
            Loop this.gridWidth {
                x := A_Index
                cell := " "
                
                ; Check if cell contains snake or food
                for i, segment in this.snake {
                    if (segment.x = x && segment.y = y) {
                        cell := (i = 1) ? "O" : "o"
                        break
                    }
                }
                
                if (x = this.foodX && y = this.foodY)
                    cell := "@"
                    
                row .= cell " "
            }
            grid .= row "`n"
        }
        
        this.canvas.Value := "Score: " this.snakeLength "`n`n" grid
    }
    
    GameOver() {
        this.Cleanup()
        MsgBox("Game Over! Your score: " . this.snakeLength, "Snake Game", "Icon!")
    }
    
    Cleanup() {
        SetTimer (this.GameLoop.Bind(this)), 0
        Hotkey("Up", "Off")
        Hotkey("Down", "Off")
        Hotkey("Left", "Off")
        Hotkey("Right", "Off")
        try {
            this.gui.Destroy()
        }
    }
}

; Prank: Mouse Jiggler
^!j:: {
    static jigglerOn := false
    jigglerOn := !jigglerOn
    if (jigglerOn) {
        SetTimer JiggleMouse, 60000  ; Jiggle every minute
        TrayTip("Mouse Jiggler", "Mouse Jiggler: ON")
    } else {
        SetTimer JiggleMouse, 0
        TrayTip("Mouse Jiggler", "Mouse Jiggler: OFF")
    }
}

JiggleMouse(*) {
    MouseMove(10, 0, 1, "R")
    Sleep(50)
    MouseMove(-10, 0, 1, "R")
}

; Prank: Fake Error Message
^!e:: {
    MsgBox("Windows has encountered a critical error!`nError Code: 0x80070002`n`nYour computer will now explode in 10 seconds...", "Critical Error", "Icon! T10")
}

; Prank: Toggle Screen Orientation
^!f:: {
    static flipped := false
    if (!flipped) {
        ; Try to rotate screen
        try {
            Run("DisplaySwitch.exe /internal")
            flipped := true
        } catch {
            MsgBox("Display rotation failed", "Prank", "Icon!")
        }
    } else {
        try {
            Run("DisplaySwitch.exe /internal")
            flipped := false
        } catch {
            ; Ignore
        }
    }
}

