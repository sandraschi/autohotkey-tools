#Requires AutoHotkey v2.0+
#SingleInstance Force

; Tetris v2: GDI+ block rendering (beveled color tetrominoes + next preview)
; via lib\GdipHelper. Game logic (spawn/lock/clear/rotate/levels) unchanged.

_CatchBootError(Thrown, Mode) {
    msg := Thrown && HasProp(Thrown, "Message") ? Thrown.Message : "Unknown"
    try FileAppend("[" A_Now "] tetris: " msg "`n", A_ScriptDir "\tetris_crash.log")
    return 1
}
OnError(_CatchBootError)

#Include %A_ScriptDir%\lib\ScriptletErrorHandler.ahk
#Include %A_ScriptDir%\lib\GdipHelper.ahk
OnError(LogError)

; ==============================================================================
; Tetris Classic
; @name: Tetris Classic
; @version: 1.1.0
; @description: Classic Tetris falling blocks puzzle game. GDI+ rendered board with beveled color tetrominoes and a live next-piece preview.
; @description: Features 7 tetromino pieces, level progression, increasing speed, and score tracking. Up rotates, Down soft-drops, Space starts, P pauses, R resets.
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

class TetrisApp {
    static g := ""
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
    static tickFn := 0
    static running := false
    static gfx := 0
    static bmp := 0
    static nGfx := 0
    static nBmp := 0
    static br := {}
    static CW := 22
    static CH := 22
    static BW := 220
    static BH := 440
    static NW := 96
    static NH := 96

    static pieceSet := [
        {name: "I", color: 0xFF00E5FF, shape: [[1,1,1,1]]},
        {name: "O", color: 0xFFFFD600, shape: [[1,1],[1,1]]},
        {name: "T", color: 0xFFAA00FF, shape: [[0,1,0],[1,1,1]]},
        {name: "S", color: 0xFF00E676, shape: [[0,1,1],[1,1,0]]},
        {name: "Z", color: 0xFFFF3D00, shape: [[1,1,0],[0,1,1]]},
        {name: "J", color: 0xFF2979FF, shape: [[1,0,0],[1,1,1]]},
        {name: "L", color: 0xFFFF9100, shape: [[0,0,1],[1,1,1]]}
    ]

    static Init() {
        TetrisApp.ResetBoard()
        TetrisApp.CreateGui()
        TetrisApp.SetupGfx()
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
        if (TetrisApp.g) {
            TetrisApp.g.Destroy()
        }
        newGui := Gui("+Resize +MinSize400x540", "Tetris Classic")
        newGui.BackColor := "1f1f1f"
        newGui.SetFont("s10", "Segoe UI")

        newGui.Add("Text", "x20 y16 w360 Center cFFFFFF", "Tetris - clear lines, climb levels")
        TetrisApp.boardCtrl := newGui.Add("Picture", "x20 y48 w220 h440", "")

        newGui.Add("Text", "x260 y48 w120 Center cFFFFFF", "Next")
        TetrisApp.nextCtrl := newGui.Add("Picture", "x272 y72 w96 h96", "")

        TetrisApp.scoreCtrl := newGui.Add("Text", "x260 y190 w120 h60 cFFFFFF Center", "Score: 0`nLevel: 1")
        TetrisApp.statusCtrl := newGui.Add("Text", "x20 y496 w360 h24 cFFFFFF", "")

        btnStart := newGui.Add("Button", "x260 y260 w120 h32", "Start")
        btnStart.OnEvent("Click", (*) => TetrisApp.StartGame())
        btnPause := newGui.Add("Button", "x260 y300 w120 h32", "Pause")
        btnPause.OnEvent("Click", (*) => TetrisApp.PauseGame())
        btnReset := newGui.Add("Button", "x260 y340 w120 h32", "Reset")
        btnReset.OnEvent("Click", (*) => TetrisApp.ResetGame())
        btnClose := newGui.Add("Button", "x260 y380 w120 h32", "Close")
        btnClose.OnEvent("Click", (*) => TetrisApp.HideGui())

        newGui.OnEvent("Close", TetrisApp.HideGui)
        newGui.OnEvent("Escape", TetrisApp.HideGui)
        newGui.OnEvent("Size", (gui, minMax, width, height) => TetrisApp.OnResize(gui, minMax, width, height))

        TetrisApp.g := newGui
        newGui.Show("w400 h540")
    }

    static SetupGfx() {
        GdipHelper.Startup()
        TetrisApp.bmp := GdipHelper.CreateBitmap(TetrisApp.BW, TetrisApp.BH)
        TetrisApp.gfx := GdipHelper.GraphicsFromImage(TetrisApp.bmp)
        GdipHelper.SetSmoothingMode(TetrisApp.gfx, 4)
        TetrisApp.nBmp := GdipHelper.CreateBitmap(TetrisApp.NW, TetrisApp.NH)
        TetrisApp.nGfx := GdipHelper.GraphicsFromImage(TetrisApp.nBmp)
        GdipHelper.SetSmoothingMode(TetrisApp.nGfx, 4)
        mk := (c) => GdipHelper.BrushCreateSolid(c)
        TetrisApp.br := Map(
            "FF00E5FF", mk(0xFF00E5FF), "FF00E5FFhi", mk(0xFF8FF5FF), "FF00E5FFlo", mk(0xFF0090A8),
            "FFFFD600", mk(0xFFFFD600), "FFFFD600hi", mk(0xFFFFEA70), "FFFFD600lo", mk(0xFFA88F00),
            "FFAA00FF", mk(0xFFAA00FF), "FFAA00FFhi", mk(0xFFD07AFF), "FFAA00FFlo", mk(0xFF6A00A8),
            "FF00E676", mk(0xFF00E676), "FF00E676hi", mk(0xFF7BFFB2), "FF00E676lo", mk(0xFF00944A),
            "FFFF3D00", mk(0xFFFF3D00), "FFFF3D00hi", mk(0xFFFF8A66), "FFFF3D00lo", mk(0xFFA82800),
            "FF2979FF", mk(0xFF2979FF), "FF2979FFhi", mk(0xFF82B1FF), "FF2979FFlo", mk(0xFF17479E),
            "FFFF9100", mk(0xFFFF9100), "FFFF9100hi", mk(0xFFFFC46B), "FFFF9100lo", mk(0xFFA85E00))
    }

    static SetupHotkeys() {
        static registered := false
        if (registered)
            return
        Hotkey("^#t", (*) => TetrisApp.ShowGui())
        HotIf((*) => WinActive("ahk_id " . TetrisApp.g.Hwnd))
        Hotkey("Left",  (*) => TetrisApp.MovePiece(-1, 0))
        Hotkey("Right", (*) => TetrisApp.MovePiece(1, 0))
        Hotkey("Down",  (*) => TetrisApp.SoftDrop())
        Hotkey("Up",    (*) => TetrisApp.RotatePiece())
        Hotkey("Space", (*) => TetrisApp.StartGame())
        Hotkey("p",     (*) => TetrisApp.PauseGame())
        Hotkey("r",     (*) => TetrisApp.ResetGame())
        HotIf()
        registered := true
    }

    static IsTetrisWindowActive() {
        if (!TetrisApp.g || !TetrisApp.g.Hwnd) {
            return false
        }
        return WinActive("ahk_id " . TetrisApp.g.Hwnd)
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

    static StartGameIfActive(*) {
        if (TetrisApp.IsTetrisWindowActive()) {
            TetrisApp.StartGame()
        }
    }

    static PauseGameIfActive(*) {
        if (TetrisApp.IsTetrisWindowActive()) {
            TetrisApp.PauseGame()
        }
    }

    static ResetGameIfActive(*) {
        if (TetrisApp.IsTetrisWindowActive()) {
            TetrisApp.ResetBoard()
            TetrisApp.UpdateBoardView()
            TetrisApp.UpdateNextView()
            TetrisApp.UpdateScore()
            TetrisApp.UpdateStatus("Press Start to begin.")
        }
    }

    static ShowGui(*) {
        if (TetrisApp.g) {
            TetrisApp.g.Show()
            WinActivate(TetrisApp.g.Hwnd)
        } else {
            TetrisApp.Init()
        }
    }

    static StartGame(*) {
        if (TetrisApp.running) {
            return
        }
        if (!TetrisApp.currentPiece) {
            TetrisApp.SpawnPiece()
        }
        TetrisApp.running := true
        TetrisApp.tickFn := (*) => TetrisApp.Tick()
        SetTimer(TetrisApp.tickFn, TetrisApp.dropInterval)
        TetrisApp.UpdateStatus("Game running - arrows move, Up rotates, Down drops, P pauses")
    }

    static PauseGame(*) {
        if (TetrisApp.running) {
            SetTimer(TetrisApp.tickFn, 0)
            TetrisApp.running := false
            TetrisApp.tickFn := 0
            TetrisApp.UpdateStatus("Paused. Press Start to resume.")
        }
    }

    static ResetGame(*) {
        TetrisApp.PauseGame()
        TetrisApp.ResetBoard()
        TetrisApp.UpdateBoardView()
        TetrisApp.UpdateNextView()
        TetrisApp.UpdateScore()
        TetrisApp.UpdateStatus("Board cleared. Press Start to play.")
    }

    static HideGui(*) {
        TetrisApp.PauseGame()
        if (TetrisApp.g) {
            TetrisApp.g.Hide()
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
                if (TetrisApp.running) {
                    SetTimer(TetrisApp.tickFn, TetrisApp.dropInterval)
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
            rr := A_Index
            Loop cols {
                cc := A_Index
                rotated[cc].Push(oldShape[rows - rr + 1][cc])
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

    static DrawBlock(g, px, py, cw, ch, argb) {
        hex := Format("{:08X}", argb)
        GdipHelper.FillRectangle(g, TetrisApp.br[hex], px + 1, py + 1, cw - 2, ch - 2)
        GdipHelper.FillRectangle(g, TetrisApp.br[hex . "hi"], px + 1, py + 1, cw - 2, 4)
        GdipHelper.FillRectangle(g, TetrisApp.br[hex . "lo"], px + 1, py + ch - 5, cw - 2, 4)
    }

    static UpdateBoardView() {
        g := TetrisApp.gfx
        if (!g || !TetrisApp.boardCtrl) {
            return
        }
        cw := TetrisApp.CW
        ch := TetrisApp.CH
        GdipHelper.Clear(g, 0xFF050508)
        Loop 20 {
            yy := A_Index
            row := TetrisApp.board[yy]
            Loop 10 {
                xx := A_Index
                cell := row[xx]
                if (cell) {
                    TetrisApp.DrawBlock(g, (xx - 1) * cw, (yy - 1) * ch, cw, ch, cell)
                }
            }
        }
        if (TetrisApp.currentPiece) {
            for rowIndex, row in TetrisApp.currentPiece.shape {
                for colIndex, cell in row {
                    if (!cell) {
                        continue
                    }
                    bx := TetrisApp.currentPiece.x + colIndex - 1
                    by := TetrisApp.currentPiece.y + rowIndex - 1
                    if (by >= 0 && by < 20 && bx >= 0 && bx < 10) {
                        TetrisApp.DrawBlock(g, bx * cw, by * ch, cw, ch, TetrisApp.currentPiece.color)
                    }
                }
            }
        }
        GdipHelper.UpdatePicture(TetrisApp.boardCtrl, TetrisApp.bmp, TetrisApp.BW, TetrisApp.BH)
    }

    static UpdateNextView() {
        g := TetrisApp.nGfx
        if (!g || !TetrisApp.nextCtrl) {
            return
        }
        GdipHelper.Clear(g, 0xFF050508)
        piece := TetrisApp.nextPiece
        if (piece && IsObject(piece)) {
            w := piece.shape[1].Length
            h := piece.shape.Length
            ox := (4 - w) // 2
            oy := (4 - h) // 2
            cw := 24
            for rr, row in piece.shape {
                for cc, cell in row {
                    if (!cell) {
                        continue
                    }
                    TetrisApp.DrawBlock(g, (ox + cc - 1) * cw, (oy + rr - 1) * cw, cw, cw, piece.color)
                }
            }
        }
        GdipHelper.UpdatePicture(TetrisApp.nextCtrl, TetrisApp.nBmp, TetrisApp.NW, TetrisApp.NH)
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
        TetrisApp.UpdateStatus("Game over - press Reset to try again.")
        MsgBox("Game Over!`nScore: " . TetrisApp.score . "`nLevel: " . TetrisApp.level, "Tetris", "Iconi")
    }

    static OnResize(g, minMax, width, height) {
        if (!TetrisApp.boardCtrl) {
            return
        }
        margin := 180
        boardHeight := height - 100
        boardWidth := Min(220, width - margin)
        TetrisApp.boardCtrl.Move(20, 48, boardWidth, boardHeight)
        if (TetrisApp.statusCtrl) {
            TetrisApp.statusCtrl.Move(20, height - 44, width - 40, 24)
        }
    }
}

TetrisApp.Init()

OnExit((*) => TetrisApp.UpdateStatus(""))
