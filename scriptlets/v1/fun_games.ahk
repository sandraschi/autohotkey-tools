#NoEnv
#SingleInstance Force
#MaxHotkeysPerInterval 200
SendMode Input
SetWorkingDir %A_ScriptDir%

; Snake Game
^!s::  ; Ctrl+Alt+S to start Snake
    Gui( Snake:New, +AlwaysOnTop -Caption +ToolWindow
    Gui( Color, 000000
    Gui( Font, s12 cLime, Consolas
    
    ; Game variables
    gridSize := 20
    gridWidth := 30
    gridHeight := 20
    snake := []
    snakeLength := 5
    direction := "right"
    
    ; Initialize snake
    Loop  %snakeLength% {
        snake.Insert({x: A_Index, y: 1})
    }
    
    ; Place first food
    Random( foodX, 1, %gridWidth%
    Random( foodY, 1, %gridHeight%
    
    ; Game loop
    SetTimer, SnakeGameLoop  150
    
    ; Show game window
    Gui( Show, w600 h400, Snake Game
    return

SnakeGameLoop:
    ; Move snake
    headX := snake[1].x
    headY := snake[1].y
    
    if (direction = "right")
        headX++
    else if (direction = "left")
        headX--
    else if (direction = "up")
        headY--
    else if (direction = "down")
        headY++
    
    ; Check collisions
    if (headX < 1 || headX > gridWidth || headY < 1 || headY > gridHeight) {
        MsgBox, Game Over! Your score: %snakeLength%
        Reload
    }
    
    ; Check if food eaten
    if (headX = foodX && headY = foodY) {
        snakeLength++
        Random( foodX, 1, %gridWidth%
        Random( foodY, 1, %gridHeight%
    } else {
        snake.Pop()
    }
    
    ; Add new head
    snake.InsertAt(1, {x: headX, y: headY})
    
    ; Draw game
    GuiControl,, GameCanvas, % DrawSnakeGame()
    return

DrawSnakeGame() {
    global snake, foodX, foodY, gridWidth, gridHeight, snakeLength
    
    ; Create game grid
    grid := ""
    Loop  %gridHeight% {
        y := A_Index
        row := ""
        Loop  %gridWidth% {
            x := A_Index
            cell := " "
            
            ; Check if cell contains snake or food
            for i, segment in snake {
                if (segment.x = x && segment.y = y) {
                    cell := (i = 1) ? "O" : "o"
                    break
                }
            }
            
            if (x = foodX && y = foodY)
                cell := "@"
                
            row .= cell " "
        }
        grid .= row "`n"
    }
    
    return "Score: " snakeLength "`n`n" grid
}

; Control snake with arrow keys
#IfWinActive Snake Game
Up::direction := (direction != "down") ? "up" : direction
Down::direction := (direction != "up") ? "down" : direction
Left::direction := (direction != "right") ? "left" : direction
Right::direction := (direction != "left") ? "right" : direction
#IfWinActive

; Prank: Mouse Jiggler
^!j::  ; Ctrl+Alt+J to toggle mouse jiggler
    static jigglerOn := false
    jigglerOn := !jigglerOn
    if (jigglerOn) {
        SetTimer(JiggleMouse,  60000  ; Jiggle every minute
        TrayTip, Mouse Jiggler, Mouse Jiggler: ON, , 1
    } else {
        SetTimer(JiggleMouse,  Off
        TrayTip, Mouse Jiggler, Mouse Jiggler: OFF, , 1
    }
    SetTimer(RemoveTrayTip,  -3000
    return

JiggleMouse:
    MouseMove, 10, 0, 1, R
    Sleep, 50
    MouseMove, -10, 0, 1, R
    return

; Prank: Fake Error Message
^!e::  ; Ctrl+Alt+E for fake error
    MsgBox, 16, Critical Error, Windows has encountered a critical error!`nError Code: 0x80070002`n`nYour computer will now explode in 10 seconds..., 10
    return

; Prank: Flip Screen
^!f::  ; Ctrl+Alt+F to flip screen
    static flipped := false
    if (!flipped) {
        DllCall("user32.dll\SetDisplayConfig", "UInt",0, "UInt",0, "UInt",0, "UInt",0, "UInt",0x00000003)
        flipped := true
    } else {
        DllCall("user32.dll\SetDisplayConfig", "UInt",0, "UInt",0, "UInt",0, "UInt",0, "UInt",0x00000000)
        flipped := false
    }
    return

RemoveTrayTip:
    TrayTip
    return
