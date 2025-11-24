#Requires AutoHotkey v2.0
#SingleInstance Force
#MaxHotkeysPerInterval 200
SetWorkingDir(A_ScriptDir)

; ========================================
; SNAKE GAME
; ========================================
static snakeGui := ""
static snake := []
static snakeLength := 5
static direction := "right"
static foodX := 0
static foodY := 0
static gridWidth := 30
static gridHeight := 20
static gameCanvas := ""

StartSnakeGame(*) {
    snakeGui := Gui("+AlwaysOnTop -Caption +ToolWindow", "Snake Game")
    snakeGui.BackColor := "000000"
    snakeGui.SetFont("s12 cLime", "Consolas")
    
    ; Game variables
    snake := []
    snakeLength := 5
    direction := "right"
    
    ; Initialize snake
    Loop snakeLength {
        snake.Push([A_Index, 1])
    }
    
    ; Place first food
    Random(&foodX, 1, gridWidth)
    Random(&foodY, 1, gridHeight)
    
    ; Create game canvas
    gameCanvas := snakeGui.Add("Text", "x10 y10 w580 h380", DrawSnakeGame())
    
    ; Game loop
    SetTimer(UpdateSnakeGame, 150)
    
    ; Control snake with arrow keys
    Hotkey("Up", ChangeSnakeDirection, "On")
    Hotkey("Down", ChangeSnakeDirection, "On")
    Hotkey("Left", ChangeSnakeDirection, "On")
    Hotkey("Right", ChangeSnakeDirection, "On")
    
    ; Show game window
    snakeGui.Show("w600 h400")
    
    snakeGui.OnEvent("Close", (*) => {
        SetTimer(UpdateSnakeGame, 0)
        Hotkey("Up", "Off")
        Hotkey("Down", "Off")
        Hotkey("Left", "Off")
        Hotkey("Right", "Off")
        snakeGui.Destroy()
    })
}

ChangeSnakeDirection(key) {
    if (key = "Up" && direction != "down")
        direction := "up"
    else if (key = "Down" && direction != "up")
        direction := "down"
    else if (key = "Left" && direction != "right")
        direction := "left"
    else if (key = "Right" && direction != "left")
        direction := "right"
}

UpdateSnakeGame(*) {
    ; Move snake
    head := snake[1].Clone()
    if (direction = "right")
        head[1] += 1
    else if (direction = "left")
        head[1] -= 1
    else if (direction = "up")
        head[2] -= 1
    else if (direction = "down")
        head[2] += 1
    
    ; Check collisions
    if (head[1] < 1 || head[1] > gridWidth || head[2] < 1 || head[2] > gridHeight) {
        SetTimer(UpdateSnakeGame, 0)
        MsgBox("Game Over! Your score: " . snakeLength, "Snake Game")
        snakeGui.Destroy()
        return
    }
    
    ; Check if food eaten
    if (head[1] = foodX && head[2] = foodY) {
        snakeLength++
        Random(&foodX, 1, gridWidth)
        Random(&foodY, 1, gridHeight)
    } else {
        snake.Pop()
    }
    
    ; Add new head
    snake.InsertAt(1, head)
    
    ; Draw game
    if (gameCanvas)
        gameCanvas.Text := DrawSnakeGame()
}

DrawSnakeGame() {
    ; Create game grid
    grid := ""
    Loop gridHeight {
        y := A_Index
        row := ""
        Loop gridWidth {
            x := A_Index
            cell := " "
            
            ; Check if cell contains snake or food
            for i, segment in snake {
                if (segment[1] = x && segment[2] = y) {
                    cell := (i = 1) ? "O" : "o"
                    break
                }
            }
            
            if (x = foodX && y = foodY)
                cell := "@"
                
            row .= cell . " "
        }
        grid .= row . "`n"
    }
    
    return "Score: " . snakeLength . "`n`n" . grid
}

Hotkey("^!s", StartSnakeGame)

; ========================================
; MOUSE JIGGLER
; ========================================
static jigglerOn := false

JiggleMouse(*) {
    MouseMove(10, 0, 1, "R")
    Sleep(50)
    MouseMove(-10, 0, 1, "R")
}

ToggleMouseJiggler(*) {
    jigglerOn := !jigglerOn
    if (jigglerOn) {
        SetTimer(JiggleMouse, 60000)  ; Jiggle every minute
        TrayTip("Mouse Jiggler: ON", "Mouse Jiggler", 1)
    } else {
        SetTimer(JiggleMouse, 0)
        TrayTip("Mouse Jiggler: OFF", "Mouse Jiggler", 1)
    }
    SetTimer(() => TrayTip(), -3000)
}

Hotkey("^!j", ToggleMouseJiggler)

; ========================================
; FAKE ERROR MESSAGE
; ========================================
ShowFakeError(*) {
    MsgBox("Windows has encountered a critical error!`nError Code: 0x80070002`n`nYour computer will now explode in 10 seconds...", "Critical Error", "Iconx T10")
}

Hotkey("^!e", ShowFakeError)

; ========================================
; FLIP SCREEN
; ========================================
static flipped := false

FlipScreen(*) {
    if (!flipped) {
        DllCall("user32.dll\SetDisplayConfig", "UInt", 0, "UInt", 0, "UInt", 0, "UInt", 0, "UInt", 0x00000003)
        flipped := true
    } else {
        DllCall("user32.dll\SetDisplayConfig", "UInt", 0, "UInt", 0, "UInt", 0, "UInt", 0, "UInt", 0x00000000)
        flipped := false
    }
}

Hotkey("^!f", FlipScreen)
