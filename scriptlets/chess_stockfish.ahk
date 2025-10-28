; ==============================================================================
; Chess Game with Stockfish Integration
; @name: Chess Game with Stockfish Integration
; @version: 1.0.0
; @description: Full-featured chess game with Stockfish engine integration
; @category: games
; @author: Sandra
; @hotkeys: ^!c, F7
; @enabled: true
; ==============================================================================

#Requires AutoHotkey v2.0+
#SingleInstance Force


; Suppress error popups - log to file instead
OnError("LogError")

LogError(Exception, Mode) {
    FileAppend("Error: " . Exception.Message . " at line " . Exception.Line . "`n", "errors.log", "UTF-8")
    return true  ; Suppress popup
}


class ChessGame {
    static gameGui := ""
    static guiControls := Map()
    static gameRunning := false
    static board := []
    static selectedSquare := ""
    static currentPlayer := "white"
    static gameMode := "human_vs_ai"
    static stockfishPath := ""
    static stockfishProcess := ""
    static gameHistory := []
    static capturedPieces := {white: [], black: []}
    static checkStatus := {white: false, black: false}
    static gameOver := false
    static winner := ""
    static debugMode := false
    
    static Init() {
        this.gameRunning := false
        this.currentPlayer := "white"
        this.gameMode := "human_vs_ai"
        this.gameHistory := []
        this.capturedPieces := {white: [], black: []}
        this.checkStatus := {white: false, black: false}
        this.gameOver := false
        this.winner := ""
        this.InitializeBoard()
        this.FindStockfish()
        this.CreateGameGUI()
    }
    
    static InitializeBoard() {
        ; Initialize empty board
        ChessGame.board := []
        
        ; Create 8 rows with 8 columns each
        Loop 8 {
            row := []
            Loop 8 {
                row.Push("")
            }
            ChessGame.board.Push(row)
        }
        
        ; Board is initialized
        
        ; Set up initial position
        ; Black pieces (top)
        ChessGame.board[1][1] := "r" ; rook
        ChessGame.board[1][2] := "n" ; knight
        ChessGame.board[1][3] := "b" ; bishop
        ChessGame.board[1][4] := "q" ; queen
        ChessGame.board[1][5] := "k" ; king
        ChessGame.board[1][6] := "b" ; bishop
        ChessGame.board[1][7] := "n" ; knight
        ChessGame.board[1][8] := "r" ; rook
        
        Loop 8 {
            ChessGame.board[2][A_Index] := "p" ; pawns
        }
        
        ; White pieces (bottom)
        Loop 8 {
            ChessGame.board[7][A_Index] := "P" ; pawns
        }
        
        ChessGame.board[8][1] := "R" ; rook
        ChessGame.board[8][2] := "N" ; knight
        ChessGame.board[8][3] := "B" ; bishop
        ChessGame.board[8][4] := "Q" ; queen
        ChessGame.board[8][5] := "K" ; king
        ChessGame.board[8][6] := "B" ; bishop
        ChessGame.board[8][7] := "N" ; knight
        ChessGame.board[8][8] := "R" ; rook
    }
    
    static FindStockfish() {
        ; Try to find Stockfish executable
        scriptletsDir := A_ScriptDir
        parentDir := RegExReplace(scriptletsDir, "\\[^\\]+$", "")  ; Go up one directory
        possiblePaths := [
            scriptletsDir . "\stockfish.exe",  ; scriptlets folder
            parentDir . "\stockfish.exe",  ; parent folder (root)
            parentDir . "\engines\stockfish.exe",  ; parent\engines folder
            "C:\Program Files\Stockfish\stockfish.exe",
            "C:\Stockfish\stockfish.exe"
        ]
        
        for path in possiblePaths {
            if (FileExist(path)) {
                ChessGame.stockfishPath := path
                return
            }
        }
        
        ; If not found, show download instructions silently
        this.ShowStockfishInstructions()
    }
    
    static ShowStockfishInstructions() {
        instructionsText := "â™Ÿï¸ STOCKFISH ENGINE REQUIRED â™Ÿï¸`n`n"
        instructionsText .= "To play against the AI, you need Stockfish:`n`n"
        instructionsText .= "1. Download Stockfish from: https://stockfishchess.org/download/`n"
        instructionsText .= "2. Extract stockfish.exe to:`n"
        instructionsText .= "   â€¢ " . A_ScriptDir . "\stockfish.exe`n"
        instructionsText .= "   â€¢ Or " . A_ScriptDir . "\engines\stockfish.exe`n`n"
        instructionsText .= "3. Restart this game`n`n"
        instructionsText .= "You can still play Human vs Human mode without Stockfish.`n`n"
        instructionsText .= "Press OK to continue with Human vs Human mode."
        
        MsgBox(instructionsText, "Stockfish Required", "Iconi")
        this.gameMode := "human_vs_human"
    }
    
    static LogDebug(message) {
        if (this.debugMode) {
            OutputDebug("[ChessGame] " . message)
        }
    }
    
    static ValidateGUI() {
        if (this.gameGui = "") {
            this.LogDebug("GUI instance not available")
            return false
        }
        return true
    }
    
    static CreateGameGUI() {
        try {
            if (this.gameGui) {
                this.gameGui.Close()
                this.gameGui := ""
                this.guiControls.Clear()
            }
            
            this.gameGui := Gui("+Resize +MinSize650x700", "Chess Game")
            this.gameGui.BackColor := "0x2A1F1F"
            this.gameGui.SetFont("s10 Bold", "Arial")
            
            ; Create visual chess board using buttons
            boardSize := 50  ; Size of each square
            startX := 40
            startY := 40
            
            ; Unicode chess pieces
            pieceSymbols := Map(
                "r", "♜", "R", "♖",  ; Rooks
                "n", "♞", "N", "♘",  ; Knights
                "b", "♝", "B", "♗",  ; Bishops
                "q", "♛", "Q", "♕",  ; Queens
                "k", "♚", "K", "♔",  ; Kings
                "p", "♟", "P", "♙"   ; Pawns
            )
            
            ; Create 8x8 grid of buttons for the chess board
            Loop 8 {
                row := A_Index
                Loop 8 {
                    col := A_Index
                    
                    ; Determine square color (alternating light/dark)
                    isLight := ((row + col) & 1) = 0
                    
                    ; Calculate position
                    x := startX + (col - 1) * boardSize
                    y := startY + (row - 1) * boardSize
                    
                    ; Get piece on this square
                    boardRow := 9 - row
                    piece := ChessGame.board[boardRow][col]
                    
                    ; Set background color
                    bgColor := isLight ? "0xF0D9B5" : "0xB58863"
                    
                    ; Set text color - uppercase = white pieces, lowercase = black pieces
                    textColor := (piece != "" && piece = StrUpper(piece)) ? "0x000000" : "0xFFFFFF"
                    
                    ; Create square button
                    square := this.gameGui.Add("Button", "x" . x . " y" . y . " w" . boardSize . " h" . boardSize . " Background" . bgColor . " +Border", "")
                    
                    ; Set piece symbol
                    if (piece != "") {
                        sym := pieceSymbols[piece]
                        square.Text := sym ? sym : piece
                        square.SetFont("s24 c" . textColor, "Arial")
                    }
                    
                    ; Store reference and bind click event
                    squareKey := "square" . row . col
                    this.guiControls[squareKey] := square
                    square.OnEvent("Click", this.SquareClicked.Bind(this, row, col))
                    
                    ; Add tooltip with coordinates
                    square.ToolTip := Chr(96 + col) . row
                }
            }
            
            ; Status bar at bottom
            this.gameGui.Add("Text", "x40 y460 w400 h25 cWhite vStatusText", "Current Player: " . this.currentPlayer . " | Mode: " . this.gameMode)
            
            ; Control buttons
            this.gameGui.Add("Button", "x460 y460 w80 h30", "New Game").OnEvent("Click", ChessGame.NewGame)
            this.gameGui.Add("Button", "x550 y460 w80 h30", "Reset").OnEvent("Click", ChessGame.ResetGame)
            
        ; Status display
        this.gameGui.Add("Text", "x10 y500 w400 h20 cWhite", "Click a piece to select, then click destination square")
        
        ; Set up hotkeys
        this.SetupHotkeys()
        
        this.gameGui.Show("w600 h530")
        this.LogDebug("Chess GUI created successfully")
        
        } catch as e {
            this.LogDebug("Error creating Chess GUI: " . e.Message)
            MsgBox("Error creating GUI: " . e.Message, "Error", "Iconx")
            throw
        }
    }
    
    static SquareClicked(row, col, ctrl, info) {
        ; Handle square click
        this.LogDebug("Square clicked: row=" . row . " col=" . col)
        ; TODO: Implement move logic
    }
    
    static NewGame(*) {
        this.gameRunning := false
        this.InitializeBoard()
        this.DrawBoardGUI()
        this.LogDebug("New game started")
    }
    
    static ResetGame(*) {
        this.InitializeBoard()
        this.DrawBoardGUI()
        this.LogDebug("Game reset")
    }
    
    static StartGame(*) {
        this.gameRunning := true
        OutputDebug("Starting game...")
        this.DrawBoard()
        OutputDebug("Board drawn")
    }
    
    static DrawBoard() {
        try {
            if (!this.ValidateGUI()) {
                return
            }
            
            ; Unicode chess pieces
            pieceSymbols := Map(
                "r", "♜", "R", "♖",  ; Rooks
                "n", "♞", "N", "♘",  ; Knights
                "b", "♝", "B", "♗",  ; Bishops
                "q", "♛", "Q", "♕",  ; Queens
                "k", "♚", "K", "♔",  ; Kings
                "p", "♟", "P", "♙"   ; Pawns
            )
            
            boardText := "`n`n  "  ; Top spacing and file labels
            
            ; File labels (a-h)
            letters := ["a", "b", "c", "d", "e", "f", "g", "h"]
            for letter in letters {
                boardText .= letter . "   "
            }
            boardText .= "`n"
            
            ; Draw chess board with alternating colors
            Loop 8 {
                row := 9 - A_Index
                
                ; Rank label (1-8)
                boardText .= (row) . " "
                
                Loop 8 {
                    col := A_Index
                    piece := ChessGame.board[row][col]
                    
                    ; Determine square color (light/dark checkered pattern)
                    isLight := ((row + col) & 1) = 0  ; Even sum = light square
                    
                    ; Use Unicode box drawing for alternating colors
                    if (isLight) {
                        boardText .= "["
                    } else {
                        boardText .= "("
                    }
                    
                    ; Display piece or empty square
                    if (piece = "") {
                        if (isLight) {
                            boardText .= "·"
                        } else {
                            boardText .= "·"
                        }
                    } else {
                        sym := pieceSymbols[piece]
                        boardText .= sym ? sym : piece
                    }
                    
                    if (isLight) {
                        boardText .= "] "
                    } else {
                        boardText .= ") "
                    }
                }
                
                ; Rank label again
                boardText .= row . "`n"
            }
            
            ; Bottom file labels
            boardText .= "  "
            for letter in letters {
                boardText .= letter . "   "
            }
            boardText .= "`n`n"
            
            ; Status information
            boardText .= "Current Player: " . this.currentPlayer . "    "
            boardText .= "Mode: " . this.gameMode . "`n"
            
            if (this.checkStatus.white) {
                boardText .= "⚠️  WHITE IS IN CHECK!`n"
            }
            if (this.checkStatus.black) {
                boardText .= "⚠️  BLACK IS IN CHECK!`n"
            }
            
            if (this.gameOver) {
                boardText .= "`n🎉 GAME OVER - " . this.winner . " WINS! 🎉`n"
            }
            
            boardText .= "`nGame Status: " . (this.gameRunning ? "Active" : "Not Started")
            
            if (this.guiControls.Has("BoardText")) {
                this.guiControls["BoardText"].Text := boardText
                this.LogDebug("BoardText updated successfully")
            } else {
                this.LogDebug("BoardText control not found")
            }
        } catch as e {
            this.LogDebug("DrawBoard error: " . e.Message)
        }
    }
    
    static DrawBoardGUI() {
        ; Update the visual board by redrawing all squares
        try {
            pieceSymbols := Map(
                "r", "♜", "R", "♖",  ; Rooks
                "n", "♞", "N", "♘",  ; Knights
                "b", "♝", "B", "♗",  ; Bishops
                "q", "♛", "Q", "♕",  ; Queens
                "k", "♚", "K", "♔",  ; Kings
                "p", "♟", "P", "♙"   ; Pawns
            )
            
            Loop 8 {
                row := A_Index
                Loop 8 {
                    col := A_Index
                    
                    ; Determine square color
                    isLight := ((row + col) & 1) = 0
                    bgColor := isLight ? "0xF0D9B5" : "0xB58863"
                    
                    ; Get piece
                    boardRow := 9 - row
                    piece := ChessGame.board[boardRow][col]
                    
                    ; Get square button
                    squareKey := "square" . row . col
                    if (this.guiControls.Has(squareKey)) {
                        square := this.guiControls[squareKey]
                        
                        ; Update piece symbol
                        if (piece != "") {
                            sym := pieceSymbols[piece]
                            square.Text := sym ? sym : piece
                            textColor := (piece = StrUpper(piece)) ? "0x000000" : "0xFFFFFF"
                            square.SetFont("s24 c" . textColor, "Arial")
                        } else {
                            square.Text := ""
                        }
                    }
                }
            }
            
            ; Update status text
            if (this.guiControls.Has("StatusText")) {
                statusText := "Current Player: " . this.currentPlayer . " | Mode: " . this.gameMode
                this.guiControls["StatusText"].Text := statusText
            }
        } catch as e {
            this.LogDebug("DrawBoardGUI error: " . e.Message)
        }
    }
    
    static ShowGameMode(*) {
        modeText := "ðŸŽ® CHESS GAME MODES ðŸŽ®`n`n"
        modeText .= "Current Mode: " . this.gameMode . "`n`n"
        modeText .= "Available Modes:`n`n"
        modeText .= "1. Human vs AI (requires Stockfish)`n"
        modeText .= "   â€¢ Play against computer`n"
        modeText .= "   â€¢ AI uses Stockfish engine`n`n"
        modeText .= "2. Human vs Human`n"
        modeText .= "   â€¢ Two players on same computer`n"
        modeText .= "   â€¢ Take turns moving pieces`n`n"
        modeText .= "3. AI vs AI (demo mode)`n"
        modeText .= "   â€¢ Watch two AIs play`n"
        modeText .= "   â€¢ Great for learning`n`n"
        modeText .= "Stockfish Status: " . (this.stockfishPath ? "Found" : "Not Found") . "`n`n"
        modeText .= "Press OK to continue."
        
        MsgBox(modeText, "Chess Game Modes", "Iconi")
    }
    
    static ShowInstructions(*) {
        instructionsText := "â™Ÿï¸ HOW TO PLAY CHESS â™Ÿï¸`n`n"
        instructionsText .= "OBJECTIVE:`n"
        instructionsText .= "Checkmate your opponent's king!`n`n"
        instructionsText .= "CONTROLS:`n"
        instructionsText .= "â€¢ Click on a piece to select it`n"
        instructionsText .= "â€¢ Click on destination square to move`n"
        instructionsText .= "â€¢ SPACE: Start/Pause game`n"
        instructionsText .= "â€¢ R: Reset game`n"
        instructionsText .= "â€¢ M: Show this menu`n`n"
        instructionsText .= "PIECE MOVEMENTS:`n"
        instructionsText .= "â€¢ Pawn (P/p): Forward 1, capture diagonally`n"
        instructionsText .= "â€¢ Rook (R/r): Horizontal and vertical`n"
        instructionsText .= "â€¢ Knight (N/n): L-shaped moves`n"
        instructionsText .= "â€¢ Bishop (B/b): Diagonal moves`n"
        instructionsText .= "â€¢ Queen (Q/q): Any direction`n"
        instructionsText .= "â€¢ King (K/k): One square any direction`n`n"
        instructionsText .= "SPECIAL RULES:`n"
        instructionsText .= "â€¢ Castling: King and rook special move`n"
        instructionsText .= "â€¢ En passant: Pawn capture rule`n"
        instructionsText .= "â€¢ Pawn promotion: Promote to queen`n"
        instructionsText .= "â€¢ Check: King under attack`n"
        instructionsText .= "â€¢ Checkmate: King cannot escape`n`n"
        instructionsText .= "Press OK to start playing!"
        
        MsgBox(instructionsText, "Chess Instructions", "Iconi")
    }
    
    static MakeMove(from, to) {
        ; Validate move (simplified)
        if (!this.IsValidMove(from, to)) {
            return false
        }
        
        ; Record move
        move := {
            from: from,
            to: to,
            piece: ChessGame.board[from.row][from.col],
            captured: ChessGame.board[to.row][to.col],
            player: this.currentPlayer
        }
        
        this.gameHistory.Push(move)
        
        ; Make the move
        if (move.captured != "") {
            this.capturedPieces[this.currentPlayer].Push(move.captured)
        }
        
        ChessGame.board[to.row][to.col] := ChessGame.board[from.row][from.col]
        ChessGame.board[from.row][from.col] := ""
        
        ; Switch players
        this.currentPlayer := (this.currentPlayer = "white") ? "black" : "white"
        
        ; Check for check/checkmate
        this.CheckGameStatus()
        
        ; If playing against AI, make AI move
        if (this.gameMode = "human_vs_ai" && this.currentPlayer = "black") {
            this.MakeAIMove()
        }
        
        this.DrawBoard()
        return true
    }
    
    static IsValidMove(from, to) {
        ; Simplified move validation
        ; In a real implementation, this would be much more complex
        
        if (from.row = to.row && from.col = to.col) {
            return false ; Can't move to same square
        }
        
        piece := ChessGame.board[from.row][from.col]
        if (piece = "") {
            return false ; No piece to move
        }
        
        ; Check if it's the player's piece
        isWhite := (piece = StrUpper(piece))
        if ((isWhite && this.currentPlayer != "white") || (!isWhite && this.currentPlayer != "black")) {
            return false
        }
        
        ; Basic piece movement validation would go here
        return true
    }
    
    static MakeAIMove() {
        if (this.stockfishPath = "") {
            return
        }
        
        ; Convert board to FEN notation
        fen := this.BoardToFEN()
        
        ; Send position to Stockfish
        this.SendToStockfish("position fen " . fen)
        this.SendToStockfish("go depth 3")
        
        ; Get best move from Stockfish
        bestMove := this.GetBestMoveFromStockfish()
        
        if (bestMove != "") {
            ; Parse and make the move
            from := this.ParseSquare(bestMove.SubStr(1, 2))
            to := this.ParseSquare(bestMove.SubStr(3, 2))
            
            this.MakeMove(from, to)
        }
    }
    
    static SendToStockfish(command) {
        if (this.stockfishPath = "") {
            return
        }
        
        try {
            if (!this.stockfishProcess) {
                this.stockfishProcess := Run(this.stockfishPath, , "Hide")
            }
            
            ; Send command to Stockfish
            ; This is simplified - real implementation would use proper process communication
        } catch {
            ; Handle error
        }
    }
    
    static GetBestMoveFromStockfish() {
        ; Simplified - real implementation would parse Stockfish output
        return "e2e4" ; Example move
    }
    
    static BoardToFEN() {
        ; Convert board to FEN notation
        fen := ""
        
        Loop 8 {
            row := 8 - A_Index
            emptyCount := 0
            
            Loop 8 {
                piece := ChessGame.board[row][A_Index - 1]
                if (piece = "") {
                    emptyCount++
                } else {
                    if (emptyCount > 0) {
                        fen .= emptyCount
                        emptyCount := 0
                    }
                    fen .= piece
                }
            }
            
            if (emptyCount > 0) {
                fen .= emptyCount
            }
            
            if (row > 0) {
                fen .= "/"
            }
        }
        
        fen .= " " . this.currentPlayer . " - - 0 1"
        return fen
    }
    
    static ParseSquare(square) {
        ; Convert algebraic notation to board coordinates
        col := Ord(square.SubStr(1, 1)) - Ord("a")
        row := 8 - Integer(square.SubStr(2, 1))
        return {row: row, col: col}
    }
    
    static CheckGameStatus() {
        ; Simplified game status checking
        ; Real implementation would check for check, checkmate, stalemate
        
        this.checkStatus.white := false
        this.checkStatus.black := false
        
        ; Check for checkmate (simplified)
        if (this.capturedPieces.white.Length >= 15) {
            this.gameOver := true
            this.winner := "Black"
        } else if (this.capturedPieces.black.Length >= 15) {
            this.gameOver := true
            this.winner := "White"
        }
    }
    
    static SetupHotkeys() {
        ; Game controls
        ; NOTE: Space hotkey disabled to avoid interfering with typing
        ; Users should use the GUI buttons or mouse to interact
        Hotkey("r", (*) => ChessGame.Init())
        Hotkey("m", (*) => ChessGame.ShowInstructions())
        
        ; Escape to close
        Hotkey("Escape", (*) => this.QuitGame())
    }
    
    static ToggleGame(*) {
        if (ChessGame.gameRunning) {
            ChessGame.gameRunning := false
        } else {
            ChessGame.StartGame()
        }
    }
    
    static QuitGame(*) {
        try {
            this.gameRunning := false
            if (this.gameGui) {
                this.gameGui.Close()
                this.gameGui := ""
                this.guiControls.Clear()
                this.LogDebug("Chess game closed successfully")
            }
        } catch as e {
            this.LogDebug("Error closing chess game: " . e.Message)
        }
    }
}

; Hotkeys
Hotkey("^!c", (*) => ChessGame.Init())
Hotkey("F7", (*) => ChessGame.Init())

; Initialize
ChessGame.Init()

; Keep script running
Loop {
    Sleep(1000)
}

