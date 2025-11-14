#Requires AutoHotkey v2.0+
#SingleInstance Force

OnError(HandleScriptError)

HandleScriptError(Thrown, Mode) {
    return SnakeApp.HandleScriptError(Thrown, Mode)
}

class SnakeApp {
    static gui := ""
    static boardCtrl := ""
    static statusCtrl := ""
    static timerId := 0
    static width := 20
    static height := 12
    static snake := []
    static direction := {x: 1, y: 0}
    static food := {x: 5, y: 5}
    static alive := false
    static logInitialized := false
    static logPath := ""

    static Init() {
        SnakeApp.EnsureLogging()
        SnakeApp.CreateGui()
        SnakeApp.SetupHotkeys()
        SnakeApp.ResetGame()
        SnakeApp.AppendLog("Snake game initialized.")
    }

    static HandleScriptError(Thrown, Mode) {
        message := "Unhandled exception (" . Mode . "): " . Thrown.Message
        location := "File: " . (ObjHasOwnProp(Thrown, "File") && Thrown.File ? Thrown.File : A_ScriptFullPath) . " | Line: " . (ObjHasOwnProp(Thrown, "Line") && Thrown.Line ? Thrown.Line : "unknown")
        SnakeApp.AppendLog(message, "ERROR")
        SnakeApp.AppendLog(location, "ERROR")
        if (Thrown.Stack) {
            SnakeApp.AppendLog("Stack trace:`n" . Thrown.Stack, "TRACE")
        }
        SnakeApp.ShowNotification("Snake Error", Thrown.Message)
        SnakeApp.PauseGame()
        if (SnakeApp.gui) {
            try {
                SnakeApp.gui.Hide()
            } catch {
            }
        }
        return 1
    }

    static CreateGui() {
        SnakeApp.gui := Gui("+Resize +MinSize320x280", "Snake Game")
        SnakeApp.gui.BackColor := 0x101010
        SnakeApp.gui.SetFont("s10", "Consolas")

        SnakeApp.gui.AddText("x20 y16 w260 Center c00FF00", "Snake – eat food, avoid crashing")
        SnakeApp.boardCtrl := SnakeApp.gui.AddText("x20 y48 w200 h180 Background000000 Border", "")
        startBtn := SnakeApp.gui.AddButton("x240 y60 w80 h30", "Start")
        startBtn.OnEvent("Click", (*) => SnakeApp.StartGame())
        pauseBtn := SnakeApp.gui.AddButton("x240 y100 w80 h30", "Pause")
        pauseBtn.OnEvent("Click", (*) => SnakeApp.PauseGame())
        resetBtn := SnakeApp.gui.AddButton("x240 y140 w80 h30", "Reset")
        resetBtn.OnEvent("Click", (*) => SnakeApp.ResetGame())
        closeBtn := SnakeApp.gui.AddButton("x240 y180 w80 h30", "Close")
        closeBtn.OnEvent("Click", (*) => SnakeApp.HideGui())

        SnakeApp.statusCtrl := SnakeApp.gui.AddText("x20 y240 w260 h24 cFFFFFF", "Use Ctrl+Alt+Arrow keys to steer.")

        SnakeApp.gui.OnEvent("Close", ObjBindMethod(SnakeApp, "HideGui"))
        SnakeApp.gui.OnEvent("Escape", ObjBindMethod(SnakeApp, "HideGui"))
        SnakeApp.gui.OnEvent("Size", ObjBindMethod(SnakeApp, "OnResize"))

        SnakeApp.gui.Show("w320 h280")
        SnakeApp.AppendLog("GUI created successfully.")
    }

    static EnsureLogging() {
        if (SnakeApp.logInitialized) {
            return
        }
        logDir := A_ScriptDir . "\logs"
        try {
            if (!DirExist(logDir)) {
                DirCreate(logDir)
            }
        } catch as dirError {
            OutputDebug("Snake log dir error: " . dirError.Message)
        }
        SnakeApp.logPath := logDir . "\fun_games.log"
        SnakeApp.logInitialized := true
    }

    static SetupHotkeys() {
        static registered := false
        if (registered) {
            return
        }
        ; Global hotkey to launch/show the game
        Hotkey("^!s", (*) => SnakeApp.ShowGui())
        
        ; Context-sensitive hotkeys - only work when Snake window is active
        Hotkey("Up", (*) => SnakeApp.SetDirectionIfActive(0, -1))
        Hotkey("Down", (*) => SnakeApp.SetDirectionIfActive(0, 1))
        Hotkey("Left", (*) => SnakeApp.SetDirectionIfActive(-1, 0))
        Hotkey("Right", (*) => SnakeApp.SetDirectionIfActive(1, 0))
        Hotkey("Space", (*) => SnakeApp.ToggleStartIfActive())
        Hotkey("p", (*) => SnakeApp.PauseGameIfActive())
        Hotkey("r", (*) => SnakeApp.ResetGameIfActive())
        Hotkey("Escape", (*) => SnakeApp.HideGui())
        registered := true
    }
    
    static IsSnakeWindowActive() {
        if (!SnakeApp.gui || !SnakeApp.gui.Hwnd) {
            return false
        }
        return WinActive("ahk_id " . SnakeApp.gui.Hwnd)
    }
    
    static SetDirectionIfActive(dx, dy) {
        if (SnakeApp.IsSnakeWindowActive()) {
            SnakeApp.SetDirection(dx, dy)
        }
    }
    
    static ToggleStartIfActive() {
        if (SnakeApp.IsSnakeWindowActive()) {
            SnakeApp.ToggleStart()
        }
    }
    
    static PauseGameIfActive() {
        if (SnakeApp.IsSnakeWindowActive()) {
            SnakeApp.PauseGame()
        }
    }
    
    static ResetGameIfActive() {
        if (SnakeApp.IsSnakeWindowActive()) {
            SnakeApp.ResetGame()
        }
    }
    
    static ShowGui(*) {
        if (SnakeApp.gui) {
            SnakeApp.gui.Show()
            WinActivate(SnakeApp.gui.Hwnd)
        } else {
            SnakeApp.Init()
        }
    }

    static ToggleStart() {
        if (SnakeApp.alive && SnakeApp.timerId) {
            SnakeApp.PauseGame()
        } else {
            SnakeApp.StartGame()
        }
    }

    static StartGame() {
        if (SnakeApp.timerId) {
            return
        }
        SnakeApp.alive := true
        SnakeApp.timerId := SetTimer(SnakeApp.Tick.Bind(SnakeApp), 200)
        SnakeApp.UpdateStatus("Game running.")
        SnakeApp.AppendLog("Game started.")
    }

    static PauseGame() {
        if (SnakeApp.timerId) {
            SetTimer(SnakeApp.timerId, 0)
            SnakeApp.timerId := 0
            SnakeApp.UpdateStatus("Paused.")
            SnakeApp.AppendLog("Game paused.")
        }
    }

    static HideGui(*) {
        SnakeApp.PauseGame()
        if (SnakeApp.gui) {
            SnakeApp.gui.Hide()
            SnakeApp.AppendLog("GUI hidden.")
        }
    }

    static ResetGame() {
        SnakeApp.PauseGame()
        SnakeApp.snake := [{x: 4, y: 6}, {x: 3, y: 6}, {x: 2, y: 6}]
        SnakeApp.direction := {x: 1, y: 0}
        SnakeApp.food := SnakeApp.RandomEmptyCell()
        SnakeApp.alive := true
        SnakeApp.UpdateBoard()
        SnakeApp.UpdateStatus("Press Start or Ctrl+Alt+S to play.")
        SnakeApp.AppendLog("Game reset.")
    }

    static SetDirection(dx, dy) {
        if (!SnakeApp.alive) {
            return
        }
        ; Prevent reversing
        if (SnakeApp.snake.Length >= 2) {
            head := SnakeApp.snake[1]
            neck := SnakeApp.snake[2]
            if (head.x + dx = neck.x && head.y + dy = neck.y) {
                return
            }
        }
        SnakeApp.direction := {x: dx, y: dy}
    }

    static Tick() {
        if (!SnakeApp.alive) {
            SnakeApp.PauseGame()
            return
        }
        head := SnakeApp.snake[1]
        newHead := {x: head.x + SnakeApp.direction.x, y: head.y + SnakeApp.direction.y}
        if (newHead.x < 0 || newHead.x >= SnakeApp.width || newHead.y < 0 || newHead.y >= SnakeApp.height || SnakeApp.IsBody(newHead)) {
            SnakeApp.GameOver()
            return
        }
        SnakeApp.snake.InsertAt(1, newHead)
        if (newHead.x = SnakeApp.food.x && newHead.y = SnakeApp.food.y) {
            SnakeApp.food := SnakeApp.RandomEmptyCell()
        } else {
            SnakeApp.snake.Pop()
        }
        SnakeApp.UpdateBoard()
    }

    static IsBody(point) {
        for seg in SnakeApp.snake {
            if (point.x = seg.x && point.y = seg.y) {
                return true
            }
        }
        return false
    }

    static RandomEmptyCell() {
        attempts := 0
        Loop 100 {
            attempts++
            x := Random(0, SnakeApp.width - 1)
            y := Random(0, SnakeApp.height - 1)
            if (!SnakeApp.IsBody({x: x, y: y})) {
                SnakeApp.AppendLog("Food placed after " . attempts . " attempt(s).")
                return {x: x, y: y}
            }
        }
        SnakeApp.AppendLog("Failed to find empty cell after 100 attempts.", "WARN")
        return {x: 0, y: 0}
    }

    static UpdateBoard() {
        rows := []
        Loop SnakeApp.height {
            y := A_Index - 1
            row := ""
            Loop SnakeApp.width {
                x := A_Index - 1
                if (SnakeApp.snake[1].x = x && SnakeApp.snake[1].y = y) {
                    row .= "🟡"
                } else if (SnakeApp.IsBody({x: x, y: y})) {
                    row .= "🟢"
                } else if (SnakeApp.food.x = x && SnakeApp.food.y = y) {
                    row .= "🍒"
                } else {
                    row .= "·"
                }
            }
            rows.Push(row)
        }
        SnakeApp.boardCtrl.Text := SnakeApp.JoinArray(rows, "`n")
    }

    static GameOver() {
        SnakeApp.alive := false
        SnakeApp.PauseGame()
        SnakeApp.UpdateStatus("Game over! Reset to play again.")
        SnakeApp.AppendLog("Game over. Score: " . (SnakeApp.snake.Length - 3), "INFO")
        SnakeApp.ShowNotification("Snake", "Game over! Score: " . (SnakeApp.snake.Length - 3))
    }

    static UpdateStatus(message) {
        if (SnakeApp.statusCtrl) {
            SnakeApp.statusCtrl.Text := message
        }
    }

    static OnResize(gui, minMax, width, height) {
        if (!SnakeApp.boardCtrl) {
            return
        }
        SnakeApp.boardCtrl.Move(20, 48, Min(200, width - 120), height - 120)
        if (SnakeApp.statusCtrl) {
            SnakeApp.statusCtrl.Move(20, height - 40, width - 40, 24)
        }
    }

    static AppendLog(message, severity := "INFO") {
        SnakeApp.EnsureLogging()
        timestamp := ""
        timestamp := FormatTime(, "yyyy-MM-dd HH:mm:ss")
        entry := "[" . timestamp . "] [" . severity . "] " . message
        OutputDebug(entry)
        if (SnakeApp.logPath) {
            try {
                FileAppend(entry . "`n", SnakeApp.logPath, "UTF-8")
            } catch as fileError {
                OutputDebug("Snake log append failed: " . fileError.Message)
            }
        }
        if (SnakeApp.statusCtrl && severity = "ERROR") {
            SnakeApp.statusCtrl.Text := message
        }
    }

    static JoinArray(values, delimiter := "`n") {
        if (!values || values.Length = 0) {
            return ""
        }
        result := values[1]
        for index, value in values {
            if (index = 1) {
                continue
            }
            result .= delimiter . value
        }
        return result
    }

    static ShowNotification(title, message, durationMs := 10000) {
        try {
            display := title ? (title . ": " . message) : message
            ToolTip(display, 30, 30)
            SetTimer((*) => ToolTip(), -Abs(durationMs))
        } catch as e {
            SnakeApp.AppendLog("Notification failed: " . e.Message, "WARN")
        }
    }
}

SnakeApp.Init()

OnExit((*) => SnakeApp.UpdateStatus(""))

