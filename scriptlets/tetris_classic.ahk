; ==============================================================================
; Tetris Classic
; @name: Tetris Classic
; @version: 1.0.0
; @description: Classic Tetris falling blocks puzzle game. Faithful recreation of the iconic 1984 puzzle game with rotating tetrominoes and line clearing mechanics.
; @description: Features classic Tetris gameplay with 7 different tetromino pieces, level progression, increasing speed, and score tracking. Includes pause, restart, and classic controls.
; @description: Nostalgic puzzle game experience with authentic gameplay mechanics and addictive line-clearing action from the golden age of puzzle games.
; @category: games
; @author: Sandra
; @hotkeys: Arrow keys, Space, P, R
; @enabled: true
; @priority: 75
; @tag: tetris, game, puzzle, arcade, classic, retro, entertainment, nostalgic
; @cli: --level <num> - Start at specific level
; @cli: --speed <1-10> - Set game speed multiplier
; @cli: --help - Show CLI usage and game options
; @dependencies: 
; ==============================================================================

#Requires AutoHotkey v2.0+
#SingleInstance Force
#Include %A_ScriptDir%\lib\ScriptletErrorHandler.ahk

OnError(LogError)

class TetrisApp {
    static gui := ""
    static boardCtrl := ""
    static nextCtrl := ""
    static scoreCtrl := ""
    static statusCtrl := ""
    static timerId := 0
    static board := []
    static currentPiece := ""
    static nextPiece := ""
    static score := 0
    static level := 1
    static dropInterval := 600

    static pieceSet := [
        {name: "I", color: "█", shape: [[1,1,1,1]]},
        {name: "O", color: "█", shape: [[1,1],[1,1]]},
        {name: "T", color: "█", shape: [[0,1,0],[1,1,1]]},
        {name: "S", color: "█", shape: [[0,1,1],[1,1,0]]},
        {name: "Z", color: "█", shape: [[1,1,0],[0,1,1]]},
        {name: "J", color: "█", shape: [[1,0,0],[1,1,1]]},
        {name: "L", color: "█", shape: [[0,0,1],[1,1,1]]}
    ]

    static Init() {
        TetrisApp.ResetBoard()
        TetrisApp.CreateGui()
        TetrisApp.SetupHotkeys()
        TetrisApp.UpdateBoardView()
        TetrisApp.UpdateStatus("Press Start to begin.")
    }


    static ResetBoard() {
        TetrisApp.board := []
        Loop 20 {
            row := []
            Loop 10 {
                row.Push(0)
            }
            TetrisApp.board.Push(row)
        }
        TetrisApp.currentPiece := ""
        TetrisApp.nextPiece := TetrisApp.RandomPiece()
        TetrisApp.score := 0
        TetrisApp.level := 1
        TetrisApp.dropInterval := 600
    }

    static CreateGui() {
        if (TetrisApp.gui) {
            TetrisApp.gui.Destroy()
        }
        newGui := Gui("+Resize +MinSize380x520", "Tetris Classic")
        newGui.BackColor := "1f1f1f"
        newGui.SetFont("s10", "Segoe UI")

        newGui.AddText("x20 y16 w340 Center cFFFFFF", "Tetris – simple falling block demo")
        TetrisApp.boardCtrl := newGui.AddText("x20 y48 w200 h400 Background000000 Border", "")
        TetrisApp.boardCtrl.SetFont("s10", "Consolas")

        newGui.AddText("x240 y60 w120 Center cFFFFFF", "Next")
        TetrisApp.nextCtrl := newGui.AddText("x240 y88 w120 h80 Background000000 Border", "")
        TetrisApp.nextCtrl.SetFont("s12", "Consolas")

        TetrisApp.scoreCtrl := newGui.AddText("x240 y180 w120 h60 cFFFFFF Center", "Score: 0`nLevel: 1")
        TetrisApp.statusCtrl := newGui.AddText("x20 y460 w340 h24 cFFFFFF", "")

        btnStart := newGui.AddButton("x240 y260 w120 h32", "Start")
        btnStart.OnEvent("Click", (*) => TetrisApp.StartGame())
        btnPause := newGui.AddButton("x240 y300 w120 h32", "Pause")
        btnPause.OnEvent("Click", (*) => TetrisApp.PauseGame())
        btnReset := newGui.AddButton("x240 y340 w120 h32", "Reset")
        btnReset.OnEvent("Click", (*) => TetrisApp.ResetGame())
        btnClose := newGui.AddButton("x240 y380 w120 h32", "Close")
        btnClose.OnEvent("Click", (*) => TetrisApp.HideGui())

        newGui.OnEvent("Close", TetrisApp.HideGui)
        newGui.OnEvent("Escape", TetrisApp.HideGui)
        newGui.OnEvent("Size", TetrisApp.OnResize)

        TetrisApp.gui := newGui
        newGui.Show("w380 h520")
    }

    static SetupHotkeys() {
        static registered := false
        if (registered) {
            return
        }
        ; Global hotkey to launch/show the game
        Hotkey("^!t", (*) => TetrisApp.ShowGui())
        
        ; Context-sensitive hotkeys - only work when Tetris window is active
        Hotkey("Left", (*) => TetrisApp.MovePieceIfActive(-1, 0))
        Hotkey("Right", (*) => TetrisApp.MovePieceIfActive(1, 0))
        Hotkey("Down", (*) => TetrisApp.SoftDropIfActive())
        Hotkey("Up", (*) => TetrisApp.RotatePieceIfActive())
        Hotkey("Space", (*) => TetrisApp.StartGameIfActive())
        Hotkey("p", (*) => TetrisApp.PauseGameIfActive())
        Hotkey("r", (*) => TetrisApp.ResetGameIfActive())
        Hotkey("Escape", (*) => TetrisApp.HideGui())
        registered := true
    }
    
    static IsTetrisWindowActive() {
        if (!TetrisApp.gui || !TetrisApp.gui.Hwnd) {
            return false
        }
        return WinActive("ahk_id " . TetrisApp.gui.Hwnd)
    }
    
    static MovePieceIfActive(dx, dy) {
        if (TetrisApp.IsTetrisWindowActive()) {
            TetrisApp.MovePiece(dx, dy)
        }
    }
    
    static SoftDropIfActive() {
        if (TetrisApp.IsTetrisWindowActive()) {
            TetrisApp.SoftDrop()
        }
    }
    
    static RotatePieceIfActive() {
        if (TetrisApp.IsTetrisWindowActive()) {
            TetrisApp.RotatePiece()
        }
    }
    
    static StartGameIfActive() {
        if (TetrisApp.IsTetrisWindowActive()) {
            TetrisApp.StartGame()
        }
    }
    
    static PauseGameIfActive() {
        if (TetrisApp.IsTetrisWindowActive()) {
            TetrisApp.PauseGame()
        }
    }
    
    static ResetGameIfActive() {
        if (TetrisApp.IsTetrisWindowActive()) {
            TetrisApp.ResetBoard()
            TetrisApp.UpdateBoardView()
            TetrisApp.UpdateNextView()
            TetrisApp.UpdateScore()
            TetrisApp.UpdateStatus("Press Start to begin.")
        }
    }
    
    static ShowGui(*) {
        if (TetrisApp.gui) {
            TetrisApp.gui.Show()
            WinActivate(TetrisApp.gui.Hwnd)
        } else {
            TetrisApp.Init()
        }
    }

    static StartGame() {
        if (TetrisApp.timerId) {
            return
        }
        if (!TetrisApp.currentPiece) {
            TetrisApp.SpawnPiece()
        }
        TetrisApp.UpdateStatus("Game running – use Arrow keys to control. Up=Rotate, Down=Drop, P=Pause")
        TetrisApp.timerId := SetTimer(TetrisApp.Tick.Bind(TetrisApp), TetrisApp.dropInterval)
    }

    static PauseGame() {
        if (TetrisApp.timerId) {
            SetTimer(TetrisApp.timerId, 0)
            TetrisApp.timerId := 0
            TetrisApp.UpdateStatus("Paused. Press Start or Ctrl+Alt+T to resume.")
        }
    }

    static ResetGame() {
        TetrisApp.PauseGame()
        TetrisApp.ResetBoard()
        TetrisApp.UpdateBoardView()
        TetrisApp.UpdateNextView()
        TetrisApp.UpdateScore()
        TetrisApp.UpdateStatus("Board cleared. Press Start to play.")
    }

    static HideGui(*) {
        TetrisApp.PauseGame()
        if (TetrisApp.gui) {
            TetrisApp.gui.Hide()
        }
    }

    static Tick() {
        if (!TetrisApp.currentPiece) {
            TetrisApp.SpawnPiece()
        }
        if (!TetrisApp.MovePiece(0, 1)) {
            TetrisApp.LockPiece()
            cleared := TetrisApp.ClearLines()
            if (cleared) {
                TetrisApp.score += cleared * 100 * TetrisApp.level
                TetrisApp.level := (TetrisApp.score // 500) + 1
                TetrisApp.dropInterval := Max(120, 600 - (TetrisApp.level - 1) * 40)
                if (TetrisApp.timerId) {
                    SetTimer(TetrisApp.timerId, TetrisApp.dropInterval)
                }
            }
            TetrisApp.UpdateScore()
            if (!TetrisApp.SpawnPiece()) {
                TetrisApp.GameOver()
                return
            }
        }
        TetrisApp.UpdateBoardView()
    }

    static SpawnPiece() {
        piece := TetrisApp.nextPiece ? TetrisApp.nextPiece : TetrisApp.RandomPiece()
        piece.x := 3
        piece.y := 0
        piece.shape := TetrisApp.CloneMatrix(piece.shape)
        TetrisApp.currentPiece := piece
        TetrisApp.nextPiece := TetrisApp.RandomPiece()
        TetrisApp.UpdateNextView()
        return TetrisApp.CanPlace(piece, piece.x, piece.y)
    }

    static RandomPiece() {
        idx := Random(1, TetrisApp.pieceSet.Length)
        base := TetrisApp.pieceSet[idx]
        return {name: base.name, color: base.color, shape: base.shape, x: 0, y: 0}
    }

    static CloneMatrix(mat) {
        clone := []
        for row in mat {
            newRow := []
            for cell in row {
                newRow.Push(cell)
            }
            clone.Push(newRow)
        }
        return clone
    }

    static CanPlace(piece, posX, posY) {
        for rowIndex, row in piece.shape {
            for colIndex, cell in row {
                if (!cell) {
                    continue
                }
                boardX := posX + colIndex - 1
                boardY := posY + rowIndex - 1
                if (boardX < 0 || boardX >= 10 || boardY >= 20) {
                    return false
                }
                if (boardY >= 0 && TetrisApp.board[boardY + 1][boardX + 1]) {
                    return false
                }
            }
        }
        return true
    }

    static MovePiece(dx, dy) {
        if (!TetrisApp.currentPiece) {
            return false
        }
        newX := TetrisApp.currentPiece.x + dx
        newY := TetrisApp.currentPiece.y + dy
        if (!TetrisApp.CanPlace(TetrisApp.currentPiece, newX, newY)) {
            return false
        }
        TetrisApp.currentPiece.x := newX
        TetrisApp.currentPiece.y := newY
        TetrisApp.UpdateBoardView()
        return true
    }

    static SoftDrop() {
        if (!TetrisApp.currentPiece) {
            return
        }
        if (!TetrisApp.MovePiece(0, 1)) {
            TetrisApp.Tick()
        }
    }

    static RotatePiece() {
        if (!TetrisApp.currentPiece) {
            return
        }
        oldShape := TetrisApp.CloneMatrix(TetrisApp.currentPiece.shape)
        rotated := []
        cols := oldShape[1].Length
        rows := oldShape.Length
        Loop cols {
            rotated.Push([])
        }
        Loop rows {
            r := A_Index
            Loop cols {
                c := A_Index
                rotated[c].Push(oldShape[rows - r + 1][c])
            }
        }
        TetrisApp.currentPiece.shape := rotated
        if (!TetrisApp.CanPlace(TetrisApp.currentPiece, TetrisApp.currentPiece.x, TetrisApp.currentPiece.y)) {
            TetrisApp.currentPiece.shape := oldShape
        } else {
            TetrisApp.UpdateBoardView()
        }
    }

    static LockPiece() {
        for rowIndex, row in TetrisApp.currentPiece.shape {
            for colIndex, cell in row {
                if (!cell) {
                    continue
                }
                boardX := TetrisApp.currentPiece.x + colIndex - 1
                boardY := TetrisApp.currentPiece.y + rowIndex - 1
                if (boardY >= 0 && boardY < 20 && boardX >= 0 && boardX < 10) {
                    TetrisApp.board[boardY + 1][boardX + 1] := TetrisApp.currentPiece.color
                }
            }
        }
        TetrisApp.currentPiece := ""
    }

    static ClearLines() {
        cleared := 0
        index := 1
        while (index <= TetrisApp.board.Length) {
            row := TetrisApp.board[index]
            if (!row.Has(0)) {
                TetrisApp.board.RemoveAt(index)
                newRow := []
                Loop 10 {
                    newRow.Push(0)
                }
                TetrisApp.board.InsertAt(1, newRow)
                cleared++
            } else {
                index++
            }
        }
        return cleared
    }

    static UpdateBoardView() {
        text := ""
        for y, row in TetrisApp.board {
            for x, cell in row {
                char := cell ? "█" : "·"
                text .= char
            }
            text .= "`n"
        }
        if (TetrisApp.currentPiece) {
            for rowIndex, row in TetrisApp.currentPiece.shape {
                for colIndex, cell in row {
                    if (!cell) {
                        continue
                    }
                    boardX := TetrisApp.currentPiece.x + colIndex - 1
                    boardY := TetrisApp.currentPiece.y + rowIndex - 1
                    if (boardY >= 0 && boardY < 20 && boardX >= 0 && boardX < 10) {
                        pos := boardY * 11 + boardX + 1
                        text := SubStr(text, 1, pos - 1) . "█" . SubStr(text, pos + 1)
                    }
                }
            }
        }
        TetrisApp.boardCtrl.Text := text
    }

    static UpdateNextView() {
        if (!TetrisApp.nextCtrl) {
            return
        }
        preview := ""
        piece := TetrisApp.nextPiece
        if (piece) {
            for row in piece.shape {
                for cell in row {
                    preview .= cell ? "█" : " "
                }
                preview .= "`n"
            }
        }
        TetrisApp.nextCtrl.Text := Trim(preview)
    }

    static UpdateScore() {
        if (TetrisApp.scoreCtrl) {
            TetrisApp.scoreCtrl.Text := Format("Score: {}`nLevel: {}", TetrisApp.score, TetrisApp.level)
        }
    }

    static UpdateStatus(message) {
        if (TetrisApp.statusCtrl) {
            TetrisApp.statusCtrl.Text := message
        }
    }

    static GameOver() {
        TetrisApp.PauseGame()
        TetrisApp.UpdateStatus("Game over – press Reset to try again.")
        MsgBox("Game Over!`nScore: " . TetrisApp.score . "`nLevel: " . TetrisApp.level, "Tetris", "Iconi")
    }

    static OnResize(gui, minMax, width, height) {
        if (!TetrisApp.boardCtrl) {
            return
        }
        margin := 200
        boardHeight := height - 140
        boardWidth := Min(200, width - margin)
        TetrisApp.boardCtrl.Move(20, 48, boardWidth, boardHeight)
        if (TetrisApp.statusCtrl) {
            TetrisApp.statusCtrl.Move(20, height - 40, width - 40, 24)
        }
    }
}

TetrisApp.Init()

OnExit((*) => TetrisApp.UpdateStatus(""))





