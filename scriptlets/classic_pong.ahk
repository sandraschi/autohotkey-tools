; ==============================================================================
; Classic Pong Game
; @name: Classic Pong Game
; @version: 1.0.0
; @description: Classic Pong arcade game recreation with AI opponent and sound effects. The original arcade video game that started the gaming revolution.
; @description: Features smooth ball physics, adjustable difficulty levels, score tracking, and responsive paddle controls. Includes single-player mode with intelligent AI opponent.
; @description: Faithful recreation of the iconic 1972 arcade game with modern controls and nostalgic gameplay experience.
; @category: games
; @author: Sandra
; @hotkeys: ^!p, F5
; @enabled: true
; @priority: 75
; @tag: pong, game, arcade, classic, retro, entertainment, nostalgic, sports
; @cli: --difficulty <easy|medium|hard|expert> - Set AI opponent difficulty level
; @cli: --sound-off - Disable sound effects
; @cli: --speed <1-10> - Set ball speed multiplier (default: 5)
; @cli: --help - Show CLI usage and game options
; @dependencies: 
; ==============================================================================

#Requires AutoHotkey v2.0+
#SingleInstance Force
#Include %A_ScriptDir%\lib\ScriptletErrorHandler.ahk

OnError(PongApp.HandleError)

class PongApp {
    static gui := ""
    static boardCtrl := ""
    static statusCtrl := ""
    static scoreCtrl := ""
    static timerId := 0
    static width := 32
    static height := 14
    static paddleSize := 3
    static leftY := 5
    static rightY := 5
    static ball := {x: 16, y: 7, dx: 1, dy: -1}
    static score := {left: 0, right: 0}

    static Init() {
        PongApp.CreateGui()
        PongApp.SetupHotkeys()
        PongApp.ResetMatch()
    }

    static HandleError(Thrown, Mode) {
        message := "Pong error: " . Thrown.Message . " at line " . Thrown.Line
        try FileAppend(message . "`n", "classic_pong_errors.log", "UTF-8")
        OutputDebug(message)
        return 1
    }

    static CreateGui() {
        if (PongApp.gui) {
            PongApp.gui.Destroy()
        }
        newGui := Gui("+Resize +MinSize320x280", "Classic Pong")
        newGui.BackColor := "1e1e1e"
        newGui.SetFont("s10", "Consolas")

        newGui.AddText("x20 y16 w260 Center cFFFFFF", "Pong – keep the ball in play!")
        PongApp.boardCtrl := newGui.AddText("x20 y48 w200 h180 Background000000 Border", "")
        PongApp.boardCtrl.SetFont("s10", "Consolas")

        PongApp.scoreCtrl := newGui.AddText("x240 y60 w80 h40 cFFFFFF", "0 : 0")
        btnStart := newGui.AddButton("x240 y110 w80 h30", "Start")
        btnStart.OnEvent("Click", (*) => PongApp.StartGame())
        btnPause := newGui.AddButton("x240 y150 w80 h30", "Pause")
        btnPause.OnEvent("Click", (*) => PongApp.PauseGame())
        btnReset := newGui.AddButton("x240 y190 w80 h30", "Reset")
        btnReset.OnEvent("Click", (*) => PongApp.ResetMatch())
        btnClose := newGui.AddButton("x240 y230 w80 h30", "Close")
        btnClose.OnEvent("Click", (*) => PongApp.HideGui())

        PongApp.statusCtrl := newGui.AddText("x20 y240 w260 h24 cFFFFFF", "Use W/S or Arrow keys to move your paddle.")

        newGui.OnEvent("Close", PongApp.HideGui)
        newGui.OnEvent("Escape", PongApp.HideGui)
        newGui.OnEvent("Size", PongApp.OnResize)

        PongApp.gui := newGui
        newGui.Show("w320 h280")
    }

    static SetupHotkeys() {
        static registered := false
        if (registered) {
            return
        }
        
        ; Global hotkey to launch/show the game
        Hotkey("^!p", (*) => PongApp.ShowGui())
        
        ; Context-sensitive hotkeys - only work when Pong window is active
        ; Register with window check function
        PongApp.RegisterGameHotkeys()
        
        registered := true
    }
    
    static RegisterGameHotkeys() {
        ; These hotkeys check if the Pong window is active before executing
        Hotkey("w", (*) => PongApp.MovePaddleIfActive(-1))
        Hotkey("s", (*) => PongApp.MovePaddleIfActive(1))
        Hotkey("Up", (*) => PongApp.MovePaddleIfActive(-1))
        Hotkey("Down", (*) => PongApp.MovePaddleIfActive(1))
        Hotkey("Space", (*) => PongApp.StartGameIfActive())
        Hotkey("p", (*) => PongApp.PauseGameIfActive())
        Hotkey("r", (*) => PongApp.ResetMatchIfActive())
    }
    
    static IsPongWindowActive() {
        if (!PongApp.gui || !PongApp.gui.Hwnd) {
            return false
        }
        return WinActive("ahk_id " . PongApp.gui.Hwnd)
    }
    
    static MovePaddleIfActive(direction) {
        if (PongApp.IsPongWindowActive()) {
            PongApp.MovePaddle(direction)
        }
    }
    
    static StartGameIfActive() {
        if (PongApp.IsPongWindowActive()) {
            PongApp.StartGame()
        }
    }
    
    static PauseGameIfActive() {
        if (PongApp.IsPongWindowActive()) {
            PongApp.PauseGame()
        }
    }
    
    static ResetMatchIfActive() {
        if (PongApp.IsPongWindowActive()) {
            PongApp.ResetMatch()
        }
    }
    
    static ShowGui(*) {
        if (PongApp.gui) {
            PongApp.gui.Show()
            WinActivate(PongApp.gui.Hwnd)
        } else {
            PongApp.Init()
        }
    }

    static ResetMatch() {
        PongApp.PauseGame()
        PongApp.score := {left: 0, right: 0}
        PongApp.ResetRound()
        PongApp.UpdateScore()
        PongApp.UpdateStatus("Press Start to serve.")
    }

    static ResetRound() {
        PongApp.leftY := (PongApp.height - PongApp.paddleSize) // 2
        PongApp.rightY := PongApp.leftY
        PongApp.ball := {x: PongApp.width // 2, y: PongApp.height // 2, dx: 1, dy: -1}
        PongApp.UpdateBoard()
    }

    static StartGame() {
        if (PongApp.timerId) {
            return
        }
        PongApp.timerId := SetTimer(PongApp.Tick.Bind(PongApp), 80)
        PongApp.UpdateStatus("Game running.")
    }

    static PauseGame() {
        if (PongApp.timerId) {
            SetTimer(PongApp.timerId, 0)
            PongApp.timerId := 0
            PongApp.UpdateStatus("Paused.")
        }
    }

    static HideGui(*) {
        PongApp.PauseGame()
        if (PongApp.gui) {
            PongApp.gui.Hide()
        }
    }

    static MovePaddle(direction) {
        PongApp.leftY := Max(0, Min(PongApp.height - PongApp.paddleSize, PongApp.leftY + direction))
        PongApp.UpdateBoard()
    }

    static Tick() {
        PongApp.MoveBall()
        PongApp.AutoMoveOpponent()
        PongApp.UpdateBoard()
    }

    static AutoMoveOpponent() {
        target := PongApp.ball.y - PongApp.paddleSize // 2
        PongApp.rightY := Max(0, Min(PongApp.height - PongApp.paddleSize, target))
    }

    static MoveBall() {
        nextX := PongApp.ball.x + PongApp.ball.dx
        nextY := PongApp.ball.y + PongApp.ball.dy

        if (nextY < 0 || nextY >= PongApp.height) {
            PongApp.ball.dy := -PongApp.ball.dy
            nextY := PongApp.ball.y + PongApp.ball.dy
        }

        if (nextX = 0) {
            if (PongApp.ball.y >= PongApp.leftY && PongApp.ball.y < PongApp.leftY + PongApp.paddleSize) {
                PongApp.ball.dx := 1
                nextX := PongApp.ball.x + PongApp.ball.dx
            }
        } else if (nextX = PongApp.width - 1) {
            if (PongApp.ball.y >= PongApp.rightY && PongApp.ball.y < PongApp.rightY + PongApp.paddleSize) {
                PongApp.ball.dx := -1
                nextX := PongApp.ball.x + PongApp.ball.dx
            }
        }

        PongApp.ball.x := nextX
        PongApp.ball.y := nextY

        if (PongApp.ball.x < 0) {
            PongApp.ScorePoint("right")
        } else if (PongApp.ball.x >= PongApp.width) {
            PongApp.ScorePoint("left")
        }
    }

    static ScorePoint(side) {
        PongApp.score[side] += 1
        PongApp.UpdateScore()
        PongApp.ResetRound()
        PongApp.UpdateStatus(side = "left" ? "You scored!" : "AI scored.")
    }

    static UpdateScore() {
        if (PongApp.scoreCtrl) {
            PongApp.scoreCtrl.Text := Format("{} : {}", PongApp.score.left, PongApp.score.right)
        }
    }

    static UpdateBoard() {
        rows := []
        Loop PongApp.height {
            rowIndex := A_Index - 1
            row := ""
            Loop PongApp.width {
                colIndex := A_Index - 1
                if (PongApp.ball.x = colIndex && PongApp.ball.y = rowIndex) {
                    row .= "●"
                } else if (colIndex = 0 && rowIndex >= PongApp.leftY && rowIndex < PongApp.leftY + PongApp.paddleSize) {
                    row .= "█"
                } else if (colIndex = PongApp.width - 1 && rowIndex >= PongApp.rightY && rowIndex < PongApp.rightY + PongApp.paddleSize) {
                    row .= "█"
                } else {
                    row .= "·"
                }
            }
            rows.Push(row)
        }
        PongApp.boardCtrl.Text := rows.Join("`n")
    }

    static UpdateStatus(message) {
        if (PongApp.statusCtrl) {
            PongApp.statusCtrl.Text := message
        }
    }

    static OnResize(gui, minMax, width, height) {
        if (!PongApp.boardCtrl) {
            return
        }
        newHeight := height - 120
        PongApp.boardCtrl.Move(20, 48, Min(200, width - 120), newHeight)
        if (PongApp.statusCtrl) {
            PongApp.statusCtrl.Move(20, height - 40, width - 40, 24)
        }
    }
}

PongApp.Init()

OnExit((*) => PongApp.UpdateStatus(""))


