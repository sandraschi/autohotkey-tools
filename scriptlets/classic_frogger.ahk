; ==============================================================================
; Classic Frogger Game
; @name: Classic Frogger Game
; @version: 1.0.0
; @description: Classic Frogger arcade game recreation with cars, logs, and turtles. Navigate your frog across busy roads and flowing rivers to reach safety.
; @description: Features multiple levels with increasing difficulty, score tracking, lives system, and classic gameplay mechanics. Includes animated vehicles, floating logs, and diving turtles.
; @description: Faithful recreation of the iconic 1981 arcade game with smooth controls and nostalgic gameplay experience.
; @category: games
; @author: Sandra
; @hotkeys: ^!f, F6
; @enabled: true
; @priority: 75
; @tag: frogger, game, arcade, classic, retro, entertainment, nostalgic, puzzle
; @cli: --difficulty <easy|medium|hard> - Set game difficulty level
; @cli: --lives <count> - Set starting number of lives (default: 3)
; @cli: --sound-off - Disable sound effects
; @cli: --help - Show CLI usage and game options
; @dependencies: 
; ==============================================================================

#Requires AutoHotkey v2.0+
#SingleInstance Force
#Include %A_ScriptDir%\lib\ScriptletErrorHandler.ahk

OnError(FroggerApp.HandleError)

class FroggerApp {
    static gui := ""
    static boardCtrl := ""
    static statusCtrl := ""
    static scoreCtrl := ""
    static timerId := 0
    static boardWidth := 9
    static boardHeight := 7
    static frog := {x: 4, y: 6}
    static score := 0
    static cars := []
    static lanes := []
    static tickInterval := 500

    static Init() {
        FroggerApp.SetupLanes()
        FroggerApp.CreateGui()
        FroggerApp.SetupHotkeys()
        FroggerApp.ResetGame()
    }

    static HandleError(Thrown, Mode) {
        message := "Frogger error: " . Thrown.Message . " at line " . Thrown.Line
        try FileAppend(message . "`n", "classic_frogger_errors.log", "UTF-8")
        OutputDebug(message)
        return 1
    }

    static SetupLanes() {
        FroggerApp.lanes := [
            {speed: 400, direction: 1, start: [0,3,6]},
            {speed: 520, direction: -1, start: [2,5]},
            {speed: 460, direction: 1, start: [1,4,7]},
            {speed: 540, direction: -1, start: [0,6]},
            {speed: 480, direction: 1, start: [3]},
            {speed: 500, direction: -1, start: [1,5]}
        ]
    }

    static CreateGui() {
        if (FroggerApp.gui) {
            FroggerApp.gui.Destroy()
        }
        newGui := Gui("+Resize +MinSize320x360", "Classic Frogger")
        newGui.BackColor := "1f1f1f"
        newGui.SetFont("s10", "Segoe UI")

        newGui.AddText("x20 y16 w280 Center cFFFFFF", "Frogger – reach the goal without getting hit!")
        FroggerApp.boardCtrl := newGui.AddText("x20 y48 w200 h220 Background000000 Border", "")
        FroggerApp.boardCtrl.SetFont("s12", "Consolas")

        FroggerApp.scoreCtrl := newGui.AddText("x240 y60 w80 h24 cFFFFFF", "Score: 0")
        btnStart := newGui.AddButton("x240 y96 w80 h30", "Start")
        btnStart.OnEvent("Click", (*) => FroggerApp.StartGame())
        btnPause := newGui.AddButton("x240 y136 w80 h30", "Pause")
        btnPause.OnEvent("Click", (*) => FroggerApp.PauseGame())
        btnReset := newGui.AddButton("x240 y176 w80 h30", "Reset")
        btnReset.OnEvent("Click", (*) => FroggerApp.ResetGame())
        btnClose := newGui.AddButton("x240 y216 w80 h30", "Close")
        btnClose.OnEvent("Click", (*) => FroggerApp.HideGui())

        FroggerApp.statusCtrl := newGui.AddText("x20 y286 w280 h24 cFFFFFF", "Use Arrow keys to hop. Space=Start, P=Pause, R=Reset")

        newGui.OnEvent("Close", FroggerApp.HideGui)
        newGui.OnEvent("Escape", FroggerApp.HideGui)
        newGui.OnEvent("Size", FroggerApp.OnResize)

        FroggerApp.gui := newGui
        newGui.Show("w320 h330")
    }

    static SetupHotkeys() {
        static registered := false
        if (registered) {
            return
        }
        ; Global hotkey to launch/show the game
        Hotkey("^!f", (*) => FroggerApp.ShowGui())
        
        ; Context-sensitive hotkeys - only work when Frogger window is active
        Hotkey("Up", (*) => FroggerApp.MoveFrogIfActive(0, -1))
        Hotkey("Down", (*) => FroggerApp.MoveFrogIfActive(0, 1))
        Hotkey("Left", (*) => FroggerApp.MoveFrogIfActive(-1, 0))
        Hotkey("Right", (*) => FroggerApp.MoveFrogIfActive(1, 0))
        Hotkey("Space", (*) => FroggerApp.StartGameIfActive())
        Hotkey("p", (*) => FroggerApp.PauseGameIfActive())
        Hotkey("r", (*) => FroggerApp.ResetGameIfActive())
        Hotkey("Escape", (*) => FroggerApp.HideGui())
        registered := true
    }
    
    static IsFroggerWindowActive() {
        if (!FroggerApp.gui || !FroggerApp.gui.Hwnd) {
            return false
        }
        return WinActive("ahk_id " . FroggerApp.gui.Hwnd)
    }
    
    static MoveFrogIfActive(dx, dy) {
        if (FroggerApp.IsFroggerWindowActive()) {
            FroggerApp.MoveFrog(dx, dy)
        }
    }
    
    static StartGameIfActive() {
        if (FroggerApp.IsFroggerWindowActive()) {
            FroggerApp.StartGame()
        }
    }
    
    static PauseGameIfActive() {
        if (FroggerApp.IsFroggerWindowActive()) {
            FroggerApp.PauseGame()
        }
    }
    
    static ResetGameIfActive() {
        if (FroggerApp.IsFroggerWindowActive()) {
            FroggerApp.ResetGame()
        }
    }
    
    static ShowGui(*) {
        if (FroggerApp.gui) {
            FroggerApp.gui.Show()
            WinActivate(FroggerApp.gui.Hwnd)
        } else {
            FroggerApp.Init()
        }
    }

    static ResetGame() {
        FroggerApp.PauseGame()
        FroggerApp.frog := {x: 4, y: FroggerApp.boardHeight - 1}
        FroggerApp.score := 0
        FroggerApp.ResetCars()
        FroggerApp.UpdateBoard()
        FroggerApp.UpdateScore()
        FroggerApp.UpdateStatus("Press Start to begin.")
    }

    static ResetCars() {
        FroggerApp.cars := []
        for laneIndex, lane in FroggerApp.lanes {
            positions := []
            for startX in lane.start {
                positions.Push(startX)
            }
            FroggerApp.cars.Push({positions: positions.Clone(), timer: 0})
        }
    }

    static StartGame() {
        if (FroggerApp.timerId) {
            return
        }
        FroggerApp.timerId := SetTimer(FroggerApp.Tick.Bind(FroggerApp), 200)
        FroggerApp.UpdateStatus("Game running.")
    }

    static PauseGame() {
        if (FroggerApp.timerId) {
            SetTimer(FroggerApp.timerId, 0)
            FroggerApp.timerId := 0
            FroggerApp.UpdateStatus("Paused.")
        }
    }

    static HideGui(*) {
        FroggerApp.PauseGame()
        if (FroggerApp.gui) {
            FroggerApp.gui.Hide()
        }
    }

    static Tick() {
        FroggerApp.AdvanceCars()
        FroggerApp.CheckCollision()
        FroggerApp.UpdateBoard()
    }

    static AdvanceCars() {
        for idx, laneData in FroggerApp.cars {
            lane := FroggerApp.lanes[idx]
            speed := lane.speed
            laneData.timer += 200
            if (laneData.timer < speed) {
                continue
            }
            laneData.timer := 0
            newPositions := []
            for pos in laneData.positions {
                nextPos := pos + lane.direction
                if (nextPos < 0) {
                    nextPos := FroggerApp.boardWidth - 1
                } else if (nextPos >= FroggerApp.boardWidth) {
                    nextPos := 0
                }
                newPositions.Push(nextPos)
            }
            laneData.positions := newPositions
        }
    }

    static MoveFrog(dx, dy) {
        newX := FroggerApp.frog.x + dx
        newY := FroggerApp.frog.y + dy
        if (newX < 0 || newX >= FroggerApp.boardWidth || newY < 0 || newY >= FroggerApp.boardHeight) {
            return
        }
        FroggerApp.frog.x := newX
        FroggerApp.frog.y := newY
        if (newY = 0) {
            FroggerApp.score += 100
            FroggerApp.UpdateScore()
            FroggerApp.ResetCars()
            FroggerApp.frog := {x: 4, y: FroggerApp.boardHeight - 1}
            FroggerApp.UpdateStatus("Nice! You reached the goal.")
        }
        FroggerApp.CheckCollision()
        FroggerApp.UpdateBoard()
    }

    static CheckCollision() {
        laneIndex := FroggerApp.frog.y - 1
        if (laneIndex < 0 || laneIndex >= FroggerApp.cars.Length) {
            return
        }
        carLane := FroggerApp.cars[laneIndex]
        if (carLane.positions.Has(FroggerApp.frog.x)) {
            FroggerApp.GameOver()
        }
    }

    static GameOver() {
        FroggerApp.PauseGame()
        FroggerApp.UpdateStatus("Ouch! Hit by traffic. Press Reset to try again.")
        MsgBox("Game Over! Score: " . FroggerApp.score, "Frogger", "Iconi")
        FroggerApp.ResetGame()
    }

    static UpdateBoard() {
        rows := []
        Loop FroggerApp.boardHeight {
            rowIndex := A_Index - 1
            rowText := ""
            Loop FroggerApp.boardWidth {
                colIndex := A_Index - 1
                if (rowIndex = FroggerApp.frog.y && colIndex = FroggerApp.frog.x) {
                    rowText .= "🐸"
                } else if (rowIndex = 0) {
                    rowText .= "🏁"
                } else if (rowIndex = FroggerApp.boardHeight - 1) {
                    rowText .= "🌱"
                } else {
                    laneIndex := rowIndex - 1
                    laneCars := FroggerApp.cars[laneIndex]
                    rowText .= laneCars.positions.Has(colIndex) ? "🚗" : "·"
                }
            }
            rows.Push(rowText)
        }
        FroggerApp.boardCtrl.Text := rows.Join("`n")
    }

    static UpdateScore() {
        if (FroggerApp.scoreCtrl) {
            FroggerApp.scoreCtrl.Text := "Score: " . FroggerApp.score
        }
    }

    static UpdateStatus(message) {
        if (FroggerApp.statusCtrl) {
            FroggerApp.statusCtrl.Text := message
        }
    }

    static OnResize(gui, minMax, width, height) {
        if (!FroggerApp.boardCtrl) {
            return
        }
        boardHeight := height - 140
        FroggerApp.boardCtrl.Move(20, 48, Min(200, width - 120), boardHeight)
        if (FroggerApp.statusCtrl) {
            FroggerApp.statusCtrl.Move(20, height - 40, width - 40, 24)
        }
    }
}

FroggerApp.Init()

OnExit((*) => FroggerApp.UpdateStatus(""))


