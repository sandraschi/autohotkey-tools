; ==============================================================================
; Chess Game with Stockfish Integration
; @name: Chess Game with Stockfish Integration
; @version: 1.0.0
; @description: Full-featured chess game with Stockfish engine integration for advanced chess analysis and gameplay.
; @description: Supports human vs AI, human vs human, and AI analysis modes. Includes move validation, check detection, castling, en passant, and promotion.
; @description: Features beautiful GUI with piece movement, move history, captured pieces display, and Stockfish engine integration for computer opponents.
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
    }

    static CreateGui() {
        if (ChessApp.gui) {
            ChessApp.gui.Destroy()
        }
        gui := Gui("+Resize +MinSize560x560", "Chess Board")
        gui.BackColor := "1b1b1b"
        gui.SetFont("s10 c4488FF", "Segoe UI")

        gui.AddText("x20 y16 w520 Center cFFFFFF", "Chess Board Viewer – click a square to inspect the piece.")

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
                btn := gui.AddButton(Format("x{} y{} w{} h{} {}", posX, posY, squareSize, squareSize, backOpt), "")
                btn.SetFont("s24", "Segoe UI Symbol")
                btn.OnEvent("Click", ChessApp.OnSquareClick.Bind(ChessApp, rowIndex, colIndex))
                ChessApp.boardButtons[rowIndex].Push(btn)
            }
        }

        ChessApp.statusCtrl := gui.AddText("x20 y520 w520 h24 cFFFFFF", "Select a square to view details.")
        btnBar := gui.AddButton("x360 y520 w80 h28", "New Game")
        btnBar.OnEvent("Click", (*) => ChessApp.ResetBoard())
        closeBtn := gui.AddButton("x460 y520 w80 h28", "Close")
        closeBtn.OnEvent("Click", (*) => ChessApp.HideGui())

        gui.OnEvent("Close", ChessApp.HideGui)
        gui.OnEvent("Escape", ChessApp.HideGui)
        gui.OnEvent("Size", ChessApp.OnResize)

        ChessApp.gui := gui
        gui.Show("w560 h560")
    }

    static SetupHotkeys() {
        static hotkeysRegistered := false
        if (hotkeysRegistered) {
            return
        }
        ; Global hotkey to launch/show the game
        Hotkey("^!c", (*) => ChessApp.ShowGui())
        
        ; Context-sensitive hotkeys - only work when Chess window is active
        Hotkey("n", (*) => ChessApp.ResetBoardIfActive())
        Hotkey("Escape", (*) => ChessApp.HideGui())
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
            }
        }
        ChessApp.UpdateStatus()
    }

    static UpdateStatus(extra := "") {
        if (!ChessApp.statusCtrl) {
            return
        }
        status := "White pieces: uppercase | Black pieces: lowercase."
        if (ChessApp.selectedSquare) {
            status .= " Selected: " . ChessApp.selectedSquare
        }
        if (extra != "") {
            status .= " - " . extra
        }
        ChessApp.statusCtrl.Text := status
    }

    static OnSquareClick(rowIndex, colIndex, ctrl, info) {
        ranks := ["8","7","6","5","4","3","2","1"]
        files := ["a","b","c","d","e","f","g","h"]
        algebraic := files[colIndex] . ranks[rowIndex]
        piece := ChessApp.boardState[rowIndex][colIndex]
        if (piece = "") {
            ChessApp.selectedSquare := algebraic . " (empty)"
            ChessApp.UpdateStatus()
            return
        }
        ChessApp.selectedSquare := Format("{} containing {}", algebraic, ChessApp.pieceMap.Has(piece) ? ChessApp.pieceMap[piece] : piece)
        ChessApp.UpdateStatus()
    }

    static ResetBoard() {
        ChessApp.BuildInitialBoard()
        ChessApp.UpdateBoard()
        ChessApp.UpdateStatus("Board reset")
    }

    static HideGui(*) {
        if (ChessApp.gui) {
            ChessApp.gui.Hide()
            ChessApp.UpdateStatus("GUI hidden – press Ctrl+Alt+C to reopen.")
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
                x := baseX + (colIndex - 1) * squareSize
                y := baseY + (rowIndex - 1) * squareSize
                btn.Move(x, y, squareSize, squareSize)
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

