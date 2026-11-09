#Requires AutoHotkey v2.0
#SingleInstance Force
SetWorkingDir(A_ScriptDir)

_CatchBootError(Thrown, Mode) {
    msg := Thrown && HasProp(Thrown, "Message") ? Thrown.Message : "Unknown"
    try FileAppend("[" A_Now "] fungames: " msg "`n", A_ScriptDir "\fungames_crash.log")
    return 1
}
OnError(_CatchBootError)

#Include %A_ScriptDir%\lib\ScriptletErrorHandler.ahk
#Include %A_ScriptDir%\lib\GdipHelper.ahk
OnError(LogError)

; ========================================
; SNAKE GAME
; ========================================
snakeGui := ""
snake := []
snakeLength := 5
direction := "right"
foodX := 0
foodY := 0
gridWidth := 30
gridHeight := 20
gameCanvas := ""
snakeScoreCtrl := ""
snakeControlsEnabled := false
snakeGfx := 0
snakeBmp := 0
snakeBr := {}
snakeCW := 20
snakeCH := 20
snakeBW := 600
snakeBH := 400

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
    
    ; Place first food (never on the snake)
    PlaceFood()

    ; Create game canvas (GDI+ picture + score line)
    gameCanvas := snakeGui.Add("Picture", "x10 y36 w600 h400", "")
    snakeScoreCtrl := snakeGui.Add("Text", "x10 y10 w600 h20 Center cLime", "Score: 5")
    SetupSnakeGfx()
    DrawSnake()
    
    ; Game loop
    SetTimer(UpdateSnakeGame, 150)
    
    ; Show game window first to get HWND
    snakeGui.Show("w620 h446")
    
    ; Control snake with arrow keys - only when window is active
    ; Use a timer to check window focus and enable/disable hotkeys
    SetTimer(CheckWindowFocus, 100)
    CheckWindowFocus()  ; Initial check
    
    snakeGui.OnEvent("Close", CloseSnakeGame)
}

CheckWindowFocus(*) {
    ; Check if game window exists and is active
    if (!snakeGui || !snakeGui.Hwnd) {
        DisableSnakeControls()
        return
    }
    
    if (WinActive("ahk_id " . snakeGui.Hwnd)) {
        EnableSnakeControls()
    } else {
        DisableSnakeControls()
    }
}

snakeControlsEnabled := false

EnableSnakeControls() {
    ; Enable hotkeys only if not already enabled
    if (!snakeControlsEnabled) {
        Hotkey("Up", ChangeSnakeDirection, "On")
        Hotkey("Down", ChangeSnakeDirection, "On")
        Hotkey("Left", ChangeSnakeDirection, "On")
        Hotkey("Right", ChangeSnakeDirection, "On")
        snakeControlsEnabled := true
    }
}

DisableSnakeControls() {
    ; Disable hotkeys when window loses focus
    if (snakeControlsEnabled) {
        Hotkey("Up", "Off")
        Hotkey("Down", "Off")
        Hotkey("Left", "Off")
        Hotkey("Right", "Off")
        snakeControlsEnabled := false
    }
}

CloseSnakeGame(*) {
    SetTimer(UpdateSnakeGame, 0)
    SetTimer(CheckWindowFocus, 0)
    DisableSnakeControls()
    CleanupSnakeGfx()
    snakeGui.Destroy()
}

SnakeGameOver() {
    SetTimer(UpdateSnakeGame, 0)
    CleanupSnakeGfx()
    MsgBox("Game Over! Your score: " . snakeLength, "Snake Game")
    DisableSnakeControls()
    try snakeGui.Destroy()
}

PlaceFood() {
    ; Pick a free cell so food never spawns inside the snake.
    Loop {
        foodX := Random(1, gridWidth)
        foodY := Random(1, gridHeight)
        occupied := false
        for _, segment in snake {
            if (segment[1] = foodX && segment[2] = foodY) {
                occupied := true
                break
            }
        }
        if (!occupied) {
            break
        }
    }
}

ChangeSnakeDirection(key) {
    ; Double-check window is active before processing
    if (!snakeGui || !WinActive("ahk_id " . snakeGui.Hwnd))
        return
    
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
    
    ; Check collisions: walls + self
    if (head[1] < 1 || head[1] > gridWidth || head[2] < 1 || head[2] > gridHeight) {
        SnakeGameOver()
        return
    }
    for i, segment in snake {
        if (i > 1 && segment[1] = head[1] && segment[2] = head[2]) {
            SnakeGameOver()
            return
        }
    }

    ; Check if food eaten
    if (head[1] = foodX && head[2] = foodY) {
        snakeLength++
        PlaceFood()
    } else {
        snake.Pop()
    }

    ; Add new head

    snake.InsertAt(1, head)

    ; Draw game
    if (snakeScoreCtrl)
        snakeScoreCtrl.Text := "Score: " . snakeLength
    DrawSnake()
}

SetupSnakeGfx() {
    GdipHelper.Startup()
    snakeBmp := GdipHelper.CreateBitmap(snakeBW, snakeBH)
    snakeGfx := GdipHelper.GraphicsFromImage(snakeBmp)
    GdipHelper.SetSmoothingMode(snakeGfx, 4)
    mk := (c) => GdipHelper.BrushCreateSolid(c)
    snakeBr := Map(
        "grid", mk(0xFF161616),
        "head", mk(0xFF7CFF00),
        "body", mk(0xFF2E8B2E),
        "food", mk(0xFFFF4444),
        "eye",  mk(0xFFFFFFFF))
}

CleanupSnakeGfx() {
    try {
        for _, b in snakeBr
            GdipHelper.DisposeBrush(b)
        snakeBr := {}
        if (snakeGfx) {
            GdipHelper.DisposeGraphics(snakeGfx)
            snakeGfx := 0
        }
        if (snakeBmp) {
            GdipHelper.DisposeImage(snakeBmp)
            snakeBmp := 0
        }
    }
}

DrawSnake() {
    g := snakeGfx
    if (!g || !gameCanvas) {
        return
    }
    GdipHelper.Clear(g, 0xFF0A0A0A)
    ; Faint grid backdrop.
    x := 0
    while (x < snakeBW) {
        GdipHelper.FillRectangle(g, snakeBr["grid"], x, 0, 1, snakeBH)
        x += snakeCW
    }
    y := 0
    while (y < snakeBH) {
        GdipHelper.FillRectangle(g, snakeBr["grid"], 0, y, snakeBW, 1)
        y += snakeCH
    }
    ; Food: red apple dot.
    fx := (foodX - 1) * snakeCW
    fy := (foodY - 1) * snakeCH
    GdipHelper.FillEllipse(g, snakeBr["food"], fx + 3, fy + 3, snakeCW - 6, snakeCH - 6)
    ; Snake: bright head, darker body.
    for i, segment in snake {
        bx := (segment[1] - 1) * snakeCW
        by := (segment[2] - 1) * snakeCH
        b := (i = 1) ? snakeBr["head"] : snakeBr["body"]
        GdipHelper.FillRectangle(g, b, bx + 1, by + 1, snakeCW - 2, snakeCH - 2)
    }
    ; Eyes on the head, facing the direction of travel.
    h := snake[1]
    hx := (h[1] - 1) * snakeCW
    hy := (h[2] - 1) * snakeCH
    if (direction = "right") {
        ex := hx + snakeCW - 8
        GdipHelper.FillEllipse(g, snakeBr["eye"], ex, hy + 4, 5, 5)
        GdipHelper.FillEllipse(g, snakeBr["eye"], ex, hy + snakeCH - 9, 5, 5)
    } else if (direction = "left") {
        ex := hx + 3
        GdipHelper.FillEllipse(g, snakeBr["eye"], ex, hy + 4, 5, 5)
        GdipHelper.FillEllipse(g, snakeBr["eye"], ex, hy + snakeCH - 9, 5, 5)
    } else if (direction = "up") {
        ey := hy + 3
        GdipHelper.FillEllipse(g, snakeBr["eye"], hx + 4, ey, 5, 5)
        GdipHelper.FillEllipse(g, snakeBr["eye"], hx + snakeCW - 9, ey, 5, 5)
    } else {
        ey := hy + snakeCH - 8
        GdipHelper.FillEllipse(g, snakeBr["eye"], hx + 4, ey, 5, 5)
        GdipHelper.FillEllipse(g, snakeBr["eye"], hx + snakeCW - 9, ey, 5, 5)
    }
    GdipHelper.UpdatePicture(gameCanvas, snakeBmp, snakeBW, snakeBH)
}

Hotkey("^#n", StartSnakeGame)

; ========================================
; MOUSE JIGGLER
; ========================================
jigglerOn := false

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

Hotkey("^#j", ToggleMouseJiggler)

; ========================================
; FAKE ERROR MESSAGE
; ========================================
ShowFakeError(*) {
    MsgBox("Windows has encountered a critical error!`nError Code: 0x80070002`n`nYour computer will now explode in 10 seconds...", "Critical Error", "Iconx T10")
}

Hotkey("^#e", ShowFakeError)

; ========================================
; FLIP SCREEN
; ========================================
flipped := false

FlipScreen(*) {
    if (!flipped) {
        DllCall("user32.dll\SetDisplayConfig", "UInt", 0, "UInt", 0, "UInt", 0, "UInt", 0, "UInt", 0x00000003)
        flipped := true
    } else {
        DllCall("user32.dll\SetDisplayConfig", "UInt", 0, "UInt", 0, "UInt", 0, "UInt", 0, "UInt", 0x00000000)
        flipped := false
    }
}

Hotkey("^#f", FlipScreen)
