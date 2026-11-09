; ==============================================================================
; Chess Game with Stockfish Integration
; @name: Chess Game with Stockfish Integration
; @version: 1.1.0
; @description: Human vs human chess with legal-move validation, turn tracking, captures, and auto-queen promotion. Click a piece, then a destination square.
; @description: Not yet implemented: Stockfish engine play, check/checkmate detection, castling, en passant.
; @category: games
; @author: Sandra
; @hotkeys: ^!c, F7
; @enabled: true
; @priority: 70
; @tag: chess, stockfish, game, ai, strategy, puzzle, entertainment, board-game
; @cli: --stockfish-path <path> - Specify custom Stockfish executable path
; @cli: --skill-level <1-20> - Set Stockfish skill level (default: 10)
; @cli: --depth <1-20> - Set Stockfish search depth (default: 15)
; @cli: --mode <human_vs_ai|human_vs_human|analysis> - Set game mode
; @cli: --help - Show CLI usage and chess game options
; @dependencies: Stockfish chess engine
; ==============================================================================

#Requires AutoHotkey v2.0+
#SingleInstance Force
#Include %A_ScriptDir%\lib\ScriptletErrorHandler.ahk

OnError(LogError)

class ChessApp {
    static gui := ""
    static boardButtons := []
    static statusCtrl := ""
    static selectedSquare := ""
    static boardState := []
    static selRow := 0
    static selCol := 0
    static turn := "white"
    static lastMove := ""
    static pieceMap := Map(
        "r", "♜", "R", "♖",
        "n", "♞", "N", "♘",
        "b", "♝", "B", "♗",
        "q", "♛", "Q", "♕",
        "k", "♚", "K", "♔",
        "p", "♟", "P", "♙"
    )

    static Init() {
        ChessApp.BuildInitialBoard()
        ChessApp.CreateGui()
        ChessApp.SetupHotkeys()
        ChessApp.UpdateBoard()
    }


    static BuildInitialBoard() {
        ChessApp.boardState := []
        defaultRows := [
            ["r","n","b","q","k","b","n","r"],
            ["p","p","p","p","p","p","p","p"],
            ["","","","","","","",""],
            ["","","","","","","",""],
            ["","","","","","","",""],
            ["","","","","","","",""],
            ["P","P","P","P","P","P","P","P"],
            ["R","N","B","Q","K","B","N","R"]
        ]
        for row in defaultRows {
            ChessApp.boardState.Push(row.Clone())
        }
        ChessApp.selectedSquare := ""
        ChessApp.selRow := 0
        ChessApp.selCol := 0
        ChessApp.turn := "white"
        ChessApp.lastMove := ""
    }

    static CreateGui() {
        if (ChessApp.gui) {
            ChessApp.gui.Destroy()
        }
        newGui := Gui("+Resize +MinSize560x560", "Chess Board")
        newGui.BackColor := "1b1b1b"
        newGui.SetFont("s10 c4488FF", "Segoe UI")

        newGui.Add("Text", "x20 y16 w520 Center cFFFFFF", "Chess - White starts. Click a piece, then a destination square.")

        ChessApp.boardButtons := []
        squareSize := 56
        baseX := 40
        baseY := 48
        Loop 8 {
            rowIndex := A_Index
            ChessApp.boardButtons.Push([])
            Loop 8 {
                colIndex := A_Index
                posX := baseX + (colIndex - 1) * squareSize
                posY := baseY + (rowIndex - 1) * squareSize
                isLight := Mod(rowIndex + colIndex, 2) = 0
                backOpt := isLight ? "Background0xF0D9B5" : "Background0xB58863"
                btn := newGui.Add("Button", Format("x{} y{} w{} h{} {}", posX, posY, squareSize, squareSize, backOpt), "")
                btn.SetFont("s24", "Segoe UI Symbol")
                btn.OnEvent("Click", ChessApp.OnSquareClick.Bind(ChessApp, rowIndex, colIndex))
                ChessApp.boardButtons[rowIndex].Push(btn)
            }
        }

        ChessApp.statusCtrl := newGui.Add("Text", "x20 y520 w520 h24 cFFFFFF", "White to move.")
        btnBar := newGui.Add("Button", "x360 y520 w80 h28", "New Game")
        btnBar.OnEvent("Click", (*) => ChessApp.ResetBoard())
        closeBtn := newGui.Add("Button", "x460 y520 w80 h28", "Close")
        closeBtn.OnEvent("Click", (*) => ChessApp.HideGui())

        newGui.OnEvent("Close", ChessApp.HideGui)
        newGui.OnEvent("Escape", ChessApp.HideGui)
        newGui.OnEvent("Size", (gui, minMax, width, height) => ChessApp.OnResize(gui, minMax, width, height))

        ChessApp.gui := newGui
        newGui.Show("w560 h560")
    }

    static SetupHotkeys() {
        static hotkeysRegistered := false
        if (hotkeysRegistered) {
            return
        }
        ; Global hotkey to launch/show the game (dg: Ctrl+Win+C - ^!c collides with other tools)
        Hotkey("^#c", (*) => ChessApp.ShowGui())

        ; Gameplay keys are window-scoped so n/Escape keep working
        ; in other apps while Chess runs in the background.
        HotIf((*) => WinActive("ahk_id " . ChessApp.gui.Hwnd))
        Hotkey("n", (*) => ChessApp.ResetBoard())
        Hotkey("Escape", (*) => ChessApp.HideGui())
        HotIf()
        hotkeysRegistered := true
    }

    static IsChessWindowActive() {
        if (!ChessApp.gui || !ChessApp.gui.Hwnd) {
            return false
        }
        return WinActive("ahk_id " . ChessApp.gui.Hwnd)
    }

    static ResetBoardIfActive() {
        if (ChessApp.IsChessWindowActive()) {
            ChessApp.ResetBoard()
        }
    }

    static ShowGui(*) {
        if (ChessApp.gui) {
            ChessApp.gui.Show()
            WinActivate(ChessApp.gui.Hwnd)
        } else {
            ChessApp.Init()
        }
    }

    static UpdateBoard() {
        Loop ChessApp.boardState.Length {
            rowIndex := A_Index
            row := ChessApp.boardState[rowIndex]
            Loop row.Length {
                colIndex := A_Index
                piece := row[colIndex]
                button := ChessApp.boardButtons[rowIndex][colIndex]
                button.Text := piece = "" ? "" : (ChessApp.pieceMap.Has(piece) ? ChessApp.pieceMap[piece] : piece)
                ; Selected square gets a larger glyph so the selection is visible.
                if (ChessApp.selRow = rowIndex && ChessApp.selCol = colIndex) {
                    button.SetFont("s30", "Segoe UI Symbol")
                } else {
                    button.SetFont("s24", "Segoe UI Symbol")
                }
            }
        }
        ChessApp.UpdateStatus()
    }

    static UpdateStatus(extra := "") {
        if (!ChessApp.statusCtrl) {
            return
        }
        status := (ChessApp.turn = "white" ? "White" : "Black") . " to move."
        if (ChessApp.lastMove != "") {
            status .= " Last: " . ChessApp.lastMove
        }
        if (ChessApp.selRow) {
            status .= " Selected: " . ChessApp.SquareName(ChessApp.selRow, ChessApp.selCol)
        }
        if (extra != "") {
            status .= " - " . extra
        }
        ChessApp.statusCtrl.Text := status
    }

    static SquareName(r, c) {
        ranks := ["8","7","6","5","4","3","2","1"]
        files := ["a","b","c","d","e","f","g","h"]
        return files[c] . ranks[r]
    }

    static IsOwnPiece(piece) {
        if (piece = "") {
            return false
        }
        if (ChessApp.turn = "white") {
            return piece == StrUpper(piece)
        }
        return piece == StrLower(piece)
    }

    static OnSquareClick(rowIndex, colIndex, ctrl, info) {
        piece := ChessApp.boardState[rowIndex][colIndex]
        ; Nothing selected: pick up one of the side-to-move's pieces.
        if (!ChessApp.selRow) {
            if (piece = "") {
                ChessApp.UpdateStatus("Empty square - select a " . ChessApp.turn . " piece.")
                return
            }
            if (!ChessApp.IsOwnPiece(piece)) {
                ChessApp.UpdateStatus("That's not yours - " . ChessApp.turn . " to move.")
                return
            }
            ChessApp.selRow := rowIndex
            ChessApp.selCol := colIndex
            ChessApp.selectedSquare := ChessApp.SquareName(rowIndex, colIndex)
            ChessApp.UpdateBoard()
            return
        }
        ; Clicked the selected square again: put the piece back down.
        if (rowIndex = ChessApp.selRow && colIndex = ChessApp.selCol) {
            ChessApp.selRow := 0
            ChessApp.selCol := 0
            ChessApp.selectedSquare := ""
            ChessApp.UpdateBoard()
            return
        }
        ; Clicked another own piece: switch selection to it.
        if (piece != "" && ChessApp.IsOwnPiece(piece)) {
            ChessApp.selRow := rowIndex
            ChessApp.selCol := colIndex
            ChessApp.selectedSquare := ChessApp.SquareName(rowIndex, colIndex)
            ChessApp.UpdateBoard()
            return
        }
        ; Otherwise: attempt the move.
        if (!ChessApp.IsLegalMove(ChessApp.selRow, ChessApp.selCol, rowIndex, colIndex)) {
            ChessApp.UpdateStatus("Illegal move for that piece.")
            return
        }
        ChessApp.DoMove(ChessApp.selRow, ChessApp.selCol, rowIndex, colIndex)
    }

    static DoMove(sr, sc, dr, dc) {
        piece := ChessApp.boardState[sr][sc]
        target := ChessApp.boardState[dr][dc]
        move := ChessApp.SquareName(sr, sc) . "-" . ChessApp.SquareName(dr, dc)
        if (target != "") {
            move .= " x" . target
        }
        ChessApp.boardState[dr][dc] := piece
        ChessApp.boardState[sr][sc] := ""
        ; Pawn promotion: auto-queen (no promotion dialog yet).
        if ((piece = "P" && dr = 1) || (piece = "p" && dr = 8)) {
            ChessApp.boardState[dr][dc] := (piece = "P") ? "Q" : "q"
            move .= "=Q"
        }
        ChessApp.lastMove := move
        ChessApp.turn := (ChessApp.turn = "white") ? "black" : "white"
        ChessApp.selRow := 0
        ChessApp.selCol := 0
        ChessApp.selectedSquare := ""
        ChessApp.UpdateBoard()
    }

    ; Pseudo-legal move check per piece (movement rules only:
    ; no check detection, no castling, no en passant yet).
    static IsLegalMove(sr, sc, dr, dc) {
        if (sr = dr && sc = dc) {
            return false
        }
        piece := ChessApp.boardState[sr][sc]
        target := ChessApp.boardState[dr][dc]
        if (piece = "") {
            return false
        }
        white := (piece == StrUpper(piece))
        if (target != "") {
            targetWhite := (target == StrUpper(target))
            if (targetWhite = white) {
                return false
            }
        }
        dRow := dr - sr
        dCol := dc - sc
        aRow := Abs(dRow)
        aCol := Abs(dCol)
        pl := StrLower(piece)
        if (pl = "p") {
            dir := white ? -1 : 1
            startRow := white ? 7 : 2
            if (dCol = 0) {
                if (dRow = dir && target = "") {
                    return true
                }
                if (dRow = 2 * dir && sr = startRow && target = "" && ChessApp.boardState[sr + dir][sc] = "") {
                    return true
                }
                return false
            }
            if (aCol = 1 && dRow = dir && target != "") {
                return true
            }
            return false
        }
        if (pl = "n") {
            return (aRow = 1 && aCol = 2) || (aRow = 2 && aCol = 1)
        }
        if (pl = "b") {
            return aRow = aCol && ChessApp.PathClear(sr, sc, dr, dc)
        }
        if (pl = "r") {
            return (dRow = 0 || dCol = 0) && ChessApp.PathClear(sr, sc, dr, dc)
        }
        if (pl = "q") {
            return (dRow = 0 || dCol = 0 || aRow = aCol) && ChessApp.PathClear(sr, sc, dr, dc)
        }
        if (pl = "k") {
            return aRow <= 1 && aCol <= 1
        }
        return false
    }

    static PathClear(sr, sc, dr, dc) {
        if (dr > sr) {
            stepR := 1
        } else if (dr < sr) {
            stepR := -1
        } else {
            stepR := 0
        }
        if (dc > sc) {
            stepC := 1
        } else if (dc < sc) {
            stepC := -1
        } else {
            stepC := 0
        }
        rr := sr + stepR
        cc := sc + stepC
        while (rr != dr || cc != dc) {
            if (ChessApp.boardState[rr][cc] != "") {
                return false
            }
            rr += stepR
            cc += stepC
        }
        return true
    }

    static ResetBoard() {
        ChessApp.BuildInitialBoard()
        ChessApp.UpdateBoard()
        ChessApp.UpdateStatus("Board reset")
    }

    static HideGui(*) {
        if (ChessApp.gui) {
            ChessApp.gui.Hide()
            ChessApp.UpdateStatus("GUI hidden – press Ctrl+Win+C to reopen.")
        }
    }

    static OnResize(gui, minMax, newW, newH) {
        if (!ChessApp.boardButtons.Length) {
            return
        }
        padding := 80
        usableW := newW - padding
        usableH := newH - padding
        squareSize := Min(usableW, usableH) // 8
        baseX := (newW - (squareSize * 8)) // 2
        baseY := 48

        Loop ChessApp.boardButtons.Length {
            rowIndex := A_Index
            row := ChessApp.boardButtons[rowIndex]
            Loop row.Length {
                colIndex := A_Index
                btn := row[colIndex]
                px := baseX + (colIndex - 1) * squareSize
                py := baseY + (rowIndex - 1) * squareSize
                btn.Move(px, py, squareSize, squareSize)
            }
        }
        if (ChessApp.statusCtrl) {
            ChessApp.statusCtrl.Move(baseX, baseY + squareSize * 8 + 10, squareSize * 8, 24)
        }
    }

    static AppendLog(message) {
        timestamp := FormatTime(A_Now, "HH:mm:ss")
        logMsg := "[" . timestamp . "] " . message . "`n"
        try {
            FileAppend(logMsg, "chess_stockfish.log", "UTF-8")
        } catch {
            ; Ignore file logging errors
        }
        OutputDebug(logMsg)
    }
}

ChessApp.Init()

OnExit((*) => ChessApp.AppendLog("Script exiting."))

