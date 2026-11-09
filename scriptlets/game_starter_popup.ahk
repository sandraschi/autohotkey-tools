; ==============================================================================
; Game Starter Popup
; @name: Game Starter Popup
; @version: 1.1.0
; @description: Compact game launcher popup on Ctrl+Win+P. Two-column game grid with quick actions.
; @description: Launches any depot game by absolute path (works regardless of working directory). Random pick and refresh included.
; @category: games
; @author: Sandra
; @hotkeys: ^#p, Ctrl+Win+P
; @enabled: true
; @priority: 80
; @tag: games, launcher, popup, gui, entertainment, quick-access
; @cli: --game <name> - Launch specific game directly
; @cli: --random - Launch random game
; @cli: --list - List all available games
; @cli: --help - Show CLI usage and launcher options
; @dependencies:
; ==============================================================================

#Requires AutoHotkey v2.0+
#SingleInstance Force
#Include %A_ScriptDir%\lib\ScriptletErrorHandler.ahk


; Suppress error popups - log to file instead
OnError(LogError)


class GameStarter {
    static gui := ""
    static guiControls := Map()
    static gameList := []
    static selectedGame := ""
    static debugMode := false

    static Init() {
        this.LoadGameList()
        this.SetupHotkeys()
    }

    static LogDebug(message) {
        if (this.debugMode) {
            OutputDebug("[GameStarter] " . message)
        }
    }

    static ValidateGUI() {
        if (this.gui = "") {
            this.LogDebug("GUI instance not available")
            return false
        }
        return true
    }

    static LoadGameList() {
        ; Bare filenames - resolved against A_ScriptDir at launch time so the
        ; popup works no matter which working directory started it.
        this.gameList := [
            {name: "15-Puzzle", script: "PuzzleGame.ahk", category: "puzzle", description: "Slide tiles into order"},
            {name: "Animations", script: "fun_animations.ahk", category: "visual", description: "Cool visual effects"},
            {name: "Chess", script: "chess_stockfish.ahk", category: "strategy", description: "Human vs human, legal moves"},
            {name: "Coding Music", script: "dev_context_music.ahk", category: "music", description: "Focus music player"},
            {name: "Frogger", script: "classic_frogger.ahk", category: "arcade", description: "Cross road and river"},
            {name: "Mini Games", script: "mini_games_collection.ahk", category: "collection", description: "Reaction timer, number guess"},
            {name: "Pac-Man", script: "pacman_classic.ahk", category: "arcade", description: "Eat dots, avoid ghosts"},
            {name: "Pong", script: "classic_pong.ahk", category: "arcade", description: "Retro paddle duel"},
            {name: "Q*bert", script: "qbert_game.ahk", category: "arcade", description: "Recolor every cube"},
            {name: "Snake", script: "fun_games.ahk", category: "arcade", description: "Eat apples, dodge yourself"},
            {name: "Sudoku", script: "sudoku.ahk", category: "puzzle", description: "Fill the 9x9 grid"},
            {name: "Tetris", script: "tetris_classic.ahk", category: "puzzle", description: "Falling blocks, clear lines"},
            {name: "Word Games", script: "word_games.ahk", category: "word", description: "Wordle, Anagrams, Hangman"}
        ]
    }

    static ResolveScript(script) {
        if (FileExist(script)) {
            return script
        }
        candidate := A_ScriptDir . "\" . script
        if (FileExist(candidate)) {
            return candidate
        }
        return script
    }

    static CreateGamePopup() {
        try {
            if (this.gui) {
                this.gui.Destroy()
                this.gui := ""
                this.guiControls.Clear()
            }

            this.gui := Gui("+AlwaysOnTop +ToolWindow -Caption", "Game Starter")
            this.gui.BackColor := "1a1a1a"
            this.gui.SetFont("s12 cFFFFFF Bold", "Segoe UI")

            ; Title bar
            titleBar := this.gui.Add("Text", "x0 y0 w400 h36 Center Background2d2d2d", "Game Starter")
            titleBar.SetFont("s13 cFFFFFF Bold", "Segoe UI")

            ; Close button
            closeBtn := this.gui.Add("Button", "x364 y4 w30 h28 Background444444", "X")
            closeBtn.SetFont("s10 cFFFFFF Bold", "Segoe UI")
            closeBtn.OnEvent("Click", this.ClosePopup.Bind(this))

            this.gui.SetFont("s10 cFFFFFF", "Segoe UI")

            ; Two-column compact grid - fits on small screens, no scrolling needed.
            yPos := 44
            colX := [20, 210]
            idx := 0
            for game in this.gameList {
                cx := colX[Mod(idx, 2) + 1]
                ry := yPos + (idx // 2) * 32
                gameBtn := this.gui.Add("Button", "x" . cx . " y" . ry . " w170 h28 Background2d2d2d", game.name)
                gameBtn.SetFont("s10 cFFFFFF", "Segoe UI")
                gameBtn.ToolTip := game.description . "  [" . game.category . "]"
                gameBtn.OnEvent("Click", this.LaunchGame.Bind(this, game))
                idx++
            }
            yPos += ((idx + 1) // 2) * 32 + 12

            ; Quick actions
            this.gui.Add("Text", "x20 y" . yPos . " w360 cGray", "QUICK ACTIONS")
            yPos += 20

            ; Random game button
            randomBtn := this.gui.Add("Button", "x20 y" . yPos . " w170 h34 Background4a4a4a", "Random Game")
            randomBtn.SetFont("s10 cFFFFFF Bold", "Segoe UI")
            randomBtn.OnEvent("Click", this.LaunchRandomGame.Bind(this))

            ; Refresh list button
            refreshBtn := this.gui.Add("Button", "x210 y" . yPos . " w170 h34 Background4a4a4a", "Refresh")
            refreshBtn.SetFont("s10 cFFFFFF Bold", "Segoe UI")
            refreshBtn.OnEvent("Click", this.RefreshList.Bind(this))

            yPos += 42

            ; Status bar
            this.gui.Add("Text", "x20 y" . yPos . " w360 Center cGray", "Ctrl+Win+P to open - Escape to close")
            yPos += 24

            ; Calculate height based on content
            totalHeight := yPos + 10

            ; Position in center of screen
            screenWidth := A_ScreenWidth
            screenHeight := A_ScreenHeight
            xPos := (screenWidth - 400) // 2
            yPos := (screenHeight - totalHeight) // 2

            this.gui.Show("x" . xPos . " y" . yPos . " w400 h" . totalHeight)

            ; Add fade-in animation
            this.AnimateIn()
            this.LogDebug("Game popup created successfully")

        } catch as e {
            this.LogDebug("Error creating game popup: " . e.Message)
            MsgBox("Error creating popup: " . e.Message, "Error", "Iconx")
        }
    }

    static AnimateIn() {
        ; Simple fade-in effect
        WinSetTransparent(0, this.gui)
        Loop 20 {
            WinSetTransparent(A_Index * 12, this.gui)
            Sleep(10)
        }
    }

    static AnimateOut() {
        ; Fade-out effect
        Loop 20 {
            WinSetTransparent(255 - (A_Index * 12), this.gui)
            Sleep(10)
        }
    }

    static LaunchGame(game, *) {
        try {
            this.AnimateOut()
            Sleep(200)

            scriptPath := this.ResolveScript(game.script)
            if (FileExist(scriptPath)) {
                ; Launch the game
                Run('"' . A_AhkPath . '" "' . scriptPath . '"')

                ; Show success message
                TrayTip("Game Launched!", "Starting " . game.name, 2)

                ; Log the launch
                this.LogGameLaunch(game)
            } else {
                MsgBox("Game file not found: " . scriptPath, "Error", "Iconx")
            }

            this.ClosePopup()
        } catch as e {
            MsgBox("Error launching game: " . e.Message, "Error", "Iconx")
        }
    }

    static LaunchRandomGame(*) {
        try {
            if (this.gameList.Length = 0) {
                MsgBox("No games available!", "Error", "Iconx")
                return
            }

            ; Pick random game
            randomIndex := Random(1, this.gameList.Length)
            randomGame := this.gameList[randomIndex]

            ; Show selection
            TrayTip("Random Game Selected!", "Launching " . randomGame.name, 2)

            ; Launch it
            this.LaunchGame(randomGame)
        } catch as e {
            MsgBox("Error launching random game: " . e.Message, "Error", "Iconx")
        }
    }

    static RefreshList(*) {
        try {
            this.LoadGameList()
            this.CreateGamePopup()
            TrayTip("Game List Refreshed!", "Updated " . this.gameList.Length . " games", 2)
        } catch as e {
            MsgBox("Error refreshing list: " . e.Message, "Error", "Iconx")
        }
    }

    static ClosePopup(*) {
        try {
            if (this.gui) {
                this.AnimateOut()
                Sleep(200)
                this.gui.Destroy()
                this.gui := ""
                this.guiControls.Clear()
                this.LogDebug("Game popup closed successfully")
            }
        } catch as e {
            this.LogDebug("Error closing popup: " . e.Message)
        }
    }

    static LogGameLaunch(game) {
        try {
            logFile := A_Temp . "\game_launcher.log"
            timestamp := FormatTime(A_Now, "yyyy-MM-dd HH:mm:ss")
            logEntry := "[" . timestamp . "] Launched: " . game.name . " (" . game.script . ")" . "`n"
            FileAppend(logEntry, logFile)
        } catch {
            ; Ignore logging errors
        }
    }

    static HandleEscape(*) {
        if !WinActive("Game Starter")
            return
        GameStarter.ClosePopup()
    }

    static HandleEnter(*) {
        if !WinActive("Game Starter")
            return
        GameStarter.ClosePopup()
    }

    static SetupHotkeys() {
        ; Ctrl+Win+P (documented ^#p - ^!g is taken by git tools, see BUGS_FIXED.md)
        Hotkey("^#p", (*) => this.CreateGamePopup())

        ; Close/confirm keys are window-scoped so Esc/Enter keep working
        ; everywhere else while the popup is closed.
        HotIf((*) => WinActive("Game Starter"))
        Hotkey("Escape", (*) => GameStarter.HandleEscape())
        Hotkey("Enter", (*) => GameStarter.HandleEnter())
        HotIf()
    }
}

; Initialize
GameStarter.Init()
