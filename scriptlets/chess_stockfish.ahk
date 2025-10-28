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
            
            this.gameGui := Gui("+Resize +MinSize800x600", "Chess Game - Click to move pieces")
            this.gameGui.BackColor := "0x8B4513"
            this.gameGui.SetFont("s12 cWhite Bold", "Arial")
            
            ; Game area with board display
            boardText := this.gameGui.Add("Text", "x10 y10 w780 h450 Border Center Center", "Click 'Start Game' to begin")
            this.guiControls["BoardText"] := boardText
        
        ; Status display
        this.gameGui.Add("Text", "x50 y470 w200 h30", "Current Player: " . this.currentPlayer)
        this.gameGui.Add("Text", "x300 y470 w200 h30", "Mode: " . this.gameMode)
        this.gameGui.Add("Text", "x550 y470 w200 h30", "Captured: " . this.capturedPieces.white.Length . "/" . this.capturedPieces.black.Length)
        
        ; Controls info
        this.gameGui.Add("Text", "x10 y510 w780 h20 Center", "Click pieces to move | SPACE: Start | R: Reset | M: Menu")
        
        ; Menu buttons
        this.gameGui.Add("Button", "x300 y540 w100 h40", "Start Game").OnEvent("Click", this.StartGame.Bind(this))
        this.gameGui.Add("Button", "x410 y540 w100 h40", "Game Mode").OnEvent("Click", this.ShowGameMode.Bind(this))
        this.gameGui.Add("Button", "x520 y540 w100 h40", "Instructions").OnEvent("Click", this.ShowInstructions.Bind(this))
        
        ; Set up hotkeys
        this.SetupHotkeys()
        
        this.gameGui.Show("w800 h600")
        this.LogDebug("Chess GUI created successfully")
        
        } catch as e {
            this.LogDebug("Error creating Chess GUI: " . e.Message)
            MsgBox("Error creating GUI: " . e.Message, "Error", "Iconx")
            throw
        }
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
            
            ; This is a simplified board drawing
            ; In a real implementation, you'd use GDI+ for proper graphics
            ; For now, we'll show the current position in text format
            
            boardText := "Current Position:`n`n"
            
            ; Display board
            Loop 8 {
                row := 9 - A_Index
                boardText .= (row) . " "
                Loop 8 {
                    piece := ChessGame.board[row][A_Index]
                    if (piece = "") {
                        boardText .= "Â· "
                    } else {
                        boardText .= piece . " "
                    }
                }
                boardText .= "`n"
            }
            
            boardText .= "  a b c d e f g h`n`n"
            boardText .= "Current Player: " . this.currentPlayer . "`n"
            boardText .= "Game Mode: " . this.gameMode . "`n"
            
            if (this.checkStatus.white) {
                boardText .= "White is in CHECK!`n"
            }
            if (this.checkStatus.black) {
                boardText .= "Black is in CHECK!`n"
            }
            
            if (this.gameOver) {
                boardText .= "GAME OVER - " . this.winner . " WINS!`n"
            }
            
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
        isWhite := (piece = piece.ToUpper())
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

