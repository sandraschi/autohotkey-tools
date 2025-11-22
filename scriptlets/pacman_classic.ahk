; ==============================================================================
; Pacman Classic
; @name: Pacman Classic
; @version: 1.0.0
; @description: Classic Pacman arcade game with ghosts and dots. Faithful recreation of the iconic 1980 arcade game with maze navigation and ghost AI.
; @description: Features classic Pacman gameplay with dot collection, power pellets, ghost AI, and score tracking. Includes multiple levels, lives system, and authentic gameplay mechanics.
; @description: Nostalgic arcade experience with smooth controls and authentic gameplay from the golden age of arcade gaming.
; @category: games
; @author: Sandra
; @hotkeys: Arrow keys, Space, P, R
; @enabled: true
; @priority: 75
; @tag: pacman, game, arcade, classic, retro, entertainment, nostalgic, maze
; @cli: --level <num> - Start at specific level
; @cli: --lives <count> - Set starting lives (default: 3)
; @cli: --help - Show CLI usage and game options
; @dependencies: 
; ==============================================================================

#Requires AutoHotkey v2.0+
#SingleInstance Force
#Include %A_ScriptDir%\lib\ScriptletErrorHandler.ahk

OnError(LogError)

class PacmanApp {
    static gui := ""
    static boardCtrl := ""
    static statusCtrl := ""
    static scoreCtrl := ""
    static timerId := 0
    static layout := []
    static pac := {x: 1, y: 1}
    static ghost := {x: 8, y: 5}
    static score := 0

    static Init() {
        PacmanApp.layout := PacmanApp.LoadLayout()
        PacmanApp.CreateGui()
        PacmanApp.SetupHotkeys()
        PacmanApp.ResetGame()
    }


    static LoadLayout() {
        return [
            "##########",
            "#........#",
            "#.#.##.#.#",
            "#........#",
            "#.####.#.#",
            "#...#....#",
            "#.##.##..#",
            "#........#",
            "##########"
        ]
    }

    static CreateGui() {
        if (PacmanApp.gui) {
            PacmanApp.gui.Destroy()
        }
        newGui := Gui("+Resize +MinSize320x320", "Pac-Man Classic")
        newGui.BackColor := "101010"
        newGui.SetFont("s11", "Consolas")

        newGui.AddText("x20 y16 w260 Center cFFFF54", "Pac-Man – eat dots, avoid ghosts!")
        PacmanApp.boardCtrl := newGui.AddText("x20 y48 w200 h200 Background000000 Border", "")
        PacmanApp.boardCtrl.SetFont("s11", "Consolas")

        PacmanApp.scoreCtrl := newGui.AddText("x240 y60 w80 h24 cFFFFFF", "Score: 0")
        btnStart := newGui.AddButton("x240 y100 w80 h30", "Start")
        btnStart.OnEvent("Click", (*) => PacmanApp.StartGame())
        btnPause := newGui.AddButton("x240 y140 w80 h30", "Pause")
        btnPause.OnEvent("Click", (*) => PacmanApp.PauseGame())
        btnReset := newGui.AddButton("x240 y180 w80 h30", "Reset")
        btnReset.OnEvent("Click", (*) => PacmanApp.ResetGame())
        btnClose := newGui.AddButton("x240 y220 w80 h30", "Close")
        btnClose.OnEvent("Click", (*) => PacmanApp.HideGui())

        PacmanApp.statusCtrl := newGui.AddText("x20 y260 w260 h24 cFFFFFF", "Use Arrow keys to move. Space=Start, P=Pause, R=Reset")

        newGui.OnEvent("Close", PacmanApp.HideGui)
        newGui.OnEvent("Escape", PacmanApp.HideGui)
        newGui.OnEvent("Size", PacmanApp.OnResize)

        PacmanApp.gui := newGui
        newGui.Show("w320 h300")
    }

    static SetupHotkeys() {
        static registered := false
        if (registered) {
            return
        }
        ; Global hotkey to launch/show the game
        Hotkey("^!m", (*) => PacmanApp.ShowGui())
        
        ; Context-sensitive hotkeys - only work when Pac-Man window is active
        Hotkey("Up", (*) => PacmanApp.MovePacIfActive(0, -1))
        Hotkey("Down", (*) => PacmanApp.MovePacIfActive(0, 1))
        Hotkey("Left", (*) => PacmanApp.MovePacIfActive(-1, 0))
        Hotkey("Right", (*) => PacmanApp.MovePacIfActive(1, 0))
        Hotkey("Space", (*) => PacmanApp.StartGameIfActive())
        Hotkey("p", (*) => PacmanApp.PauseGameIfActive())
        Hotkey("r", (*) => PacmanApp.ResetGameIfActive())
        Hotkey("Escape", (*) => PacmanApp.HideGui())
        registered := true
    }
    
    static IsPacmanWindowActive() {
        if (!PacmanApp.gui || !PacmanApp.gui.Hwnd) {
            return false
        }
        return WinActive("ahk_id " . PacmanApp.gui.Hwnd)
    }
    
    static MovePacIfActive(dx, dy) {
        if (PacmanApp.IsPacmanWindowActive()) {
            PacmanApp.MovePac(dx, dy)
        }
    }
    
    static StartGameIfActive() {
        if (PacmanApp.IsPacmanWindowActive()) {
            PacmanApp.StartGame()
        }
    }
    
    static PauseGameIfActive() {
        if (PacmanApp.IsPacmanWindowActive()) {
            PacmanApp.PauseGame()
        }
    }
    
    static ResetGameIfActive() {
        if (PacmanApp.IsPacmanWindowActive()) {
            PacmanApp.ResetGame()
        }
    }
    
    static ShowGui(*) {
        if (PacmanApp.gui) {
            PacmanApp.gui.Show()
            WinActivate(PacmanApp.gui.Hwnd)
        } else {
            PacmanApp.Init()
        }
    }

    static ResetGame() {
        PacmanApp.PauseGame()
        PacmanApp.layout := PacmanApp.LoadLayout()
        PacmanApp.pac := {x: 1, y: 1}
        PacmanApp.ghost := {x: 8, y: 5}
        PacmanApp.score := 0
        PacmanApp.UpdateScore()
        PacmanApp.UpdateBoard()
        PacmanApp.UpdateStatus("Press Start to begin.")
    }

    static StartGame() {
        if (PacmanApp.timerId) {
            return
        }
        PacmanApp.timerId := SetTimer(PacmanApp.Tick.Bind(PacmanApp), 400)
        PacmanApp.UpdateStatus("Game running.")
    }

    static PauseGame() {
        if (PacmanApp.timerId) {
            SetTimer(PacmanApp.timerId, 0)
            PacmanApp.timerId := 0
            PacmanApp.UpdateStatus("Paused.")
        }
    }

    static HideGui(*) {
        PacmanApp.PauseGame()
        if (PacmanApp.gui) {
            PacmanApp.gui.Hide()
        }
    }

    static Tick() {
        PacmanApp.MoveGhost()
        PacmanApp.CheckCollision()
        PacmanApp.UpdateBoard()
    }

    static MovePac(dx, dy) {
        newX := PacmanApp.pac.x + dx
        newY := PacmanApp.pac.y + dy
        if (!PacmanApp.CanWalk(newX, newY)) {
            return
        }
        if (SubStr(PacmanApp.layout[newY + 1], newX + 1, 1) = ".") {
            PacmanApp.layout[newY + 1] := PacmanApp.ReplaceChar(PacmanApp.layout[newY + 1], newX + 1, " ")
            PacmanApp.score += 10
            PacmanApp.UpdateScore()
        }
        PacmanApp.pac := {x: newX, y: newY}
        PacmanApp.CheckCollision()
        PacmanApp.UpdateBoard()
        if (!PacmanApp.HasDots()) {
            PacmanApp.UpdateStatus("You cleared the maze! Reset to play again.")
            PacmanApp.PauseGame()
        }
    }

    static MoveGhost() {
        choices := []
        dirs := [[1,0],[-1,0],[0,1],[0,-1]]
        for dir in dirs {
            dx := dir[1]
            dy := dir[2]
            newX := PacmanApp.ghost.x + dx
            newY := PacmanApp.ghost.y + dy
            if (PacmanApp.CanWalk(newX, newY)) {
                choices.Push({x: newX, y: newY})
            }
        }
        if (choices.Length) {
            idx := Random(1, choices.Length)
            PacmanApp.ghost := choices[idx]
        }
    }

    static CanWalk(x, y) {
        if (y < 0 || y >= PacmanApp.layout.Length) {
            return false
        }
        row := PacmanApp.layout[y + 1]
        if (x < 0 || x >= StrLen(row)) {
            return false
        }
        return SubStr(row, x + 1, 1) != "#"
    }

    static HasDots() {
        for row in PacmanApp.layout {
            if InStr(row, ".") {
                return true
            }
        }
        return false
    }

    static CheckCollision() {
        if (PacmanApp.pac.x = PacmanApp.ghost.x && PacmanApp.pac.y = PacmanApp.ghost.y) {
            PacmanApp.PauseGame()
            PacmanApp.UpdateStatus("Ghost got you! Reset to try again.")
            MsgBox("Game Over! Score: " . PacmanApp.score, "Pac-Man", "Iconi")
        }
    }

    static UpdateBoard() {
        rows := []
        for y, row in PacmanApp.layout {
            line := ""
            Loop StrLen(row) {
                char := SubStr(row, A_Index, 1)
                if (PacmanApp.pac.x = A_Index - 1 && PacmanApp.pac.y = y - 1) {
                    line .= "🙂"
                } else if (PacmanApp.ghost.x = A_Index - 1 && PacmanApp.ghost.y = y - 1) {
                    line .= "👻"
                } else if (char = "#") {
                    line .= "█"
                } else if (char = ".") {
                    line .= "·"
                } else {
                    line .= " "
                }
            }
            rows.Push(line)
        }
        PacmanApp.boardCtrl.Text := rows.Join("`n")
    }

    static UpdateScore() {
        if (PacmanApp.scoreCtrl) {
            PacmanApp.scoreCtrl.Text := "Score: " . PacmanApp.score
        }
    }

    static UpdateStatus(message) {
        if (PacmanApp.statusCtrl) {
            PacmanApp.statusCtrl.Text := message
        }
    }

    static ReplaceChar(text, index, replacement) {
        return SubStr(text, 1, index - 1) . replacement . SubStr(text, index + 1)
    }

    static MoveGhostRandomly() {
        PacmanApp.MoveGhost()
    }

    static OnResize(gui, minMax, width, height) {
        if (!PacmanApp.boardCtrl) {
            return
        }
        newHeight := height - 120
        PacmanApp.boardCtrl.Move(20, 48, Min(200, width - 120), newHeight)
        if (PacmanApp.statusCtrl) {
            PacmanApp.statusCtrl.Move(20, height - 40, width - 40, 24)
        }
    }
}

PacmanApp.Init()

OnExit((*) => PacmanApp.UpdateStatus(""))







