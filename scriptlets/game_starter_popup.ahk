; ==============================================================================
; Game Starter Popup
; @name: Game Starter Popup
; @version: 1.0.0
; @description: Beautiful game launcher popup with Ctrl+Alt+G hotkey
; @category: games
; @author: Sandra
; @hotkeys: ^!g, Ctrl+Alt+G
; @enabled: true
; ==============================================================================

#Requires AutoHotkey v2.0+
#SingleInstance Force


; Suppress error popups - log to file instead
OnError("LogError")

LogError(Exception, Mode) {
    FileAppend("Error: " . Exception.Message . " at line " . Exception.Line . "
", "errors.log", "UTF-8")
    return true  ; Suppress popup
}


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
        ; Define all available games
        this.gameList := [
            {name: "🎮 Tetris", script: "scriptlets/tetris_classic.ahk", category: "puzzle", description: "Classic falling blocks puzzle"},
            {name: "👻 Pacman", script: "scriptlets/pacman_classic.ahk", category: "arcade", description: "Eat dots, avoid ghosts!"},
            {name: "♟️ Chess vs Stockfish", script: "scriptlets/chess_stockfish.ahk", category: "strategy", description: "Play chess against AI"},
            {name: "🏓 Classic Pong", script: "scriptlets/classic_pong.ahk", category: "arcade", description: "Retro paddle game"},
            {name: "🐸 Classic Frogger", script: "scriptlets/classic_frogger.ahk", category: "arcade", description: "Cross the road safely"},
            {name: "🎯 Sudoku", script: "scriptlets/sudoku.ahk", category: "puzzle", description: "Number puzzle game"},
            {name: "🎲 Mini Games Collection", script: "scriptlets/mini_games_collection.ahk", category: "collection", description: "Snake, Breakout, and more"},
            {name: "🎪 Fun Games", script: "scriptlets/fun_games.ahk", category: "fun", description: "Various fun mini-games"},
            {name: "🎨 Fun Animations", script: "scriptlets/fun_animations.ahk", category: "visual", description: "Cool visual effects"},
            {name: "🎵 Dev Context Music", script: "scriptlets/dev_context_music.ahk", category: "music", description: "Coding music player"}
        ]
    }
    
    static CreateGamePopup() {
        try {
            if (this.gui) {
                this.gui.Destroy()
                this.gui := ""
                this.guiControls.Clear()
            }
        
        this.gui := Gui("+AlwaysOnTop +ToolWindow -Caption", "Game Starter")
        this.gui.BackColor := "0x1a1a1a"
        this.gui.SetFont("s12 cWhite Bold", "Segoe UI")
        
        ; Title bar
        titleBar := this.gui.Add("Text", "x0 y0 w400 h40 Center Background0x2d2d2d", "🎮 Game Starter")
        titleBar.SetFont("s14 cWhite Bold", "Segoe UI")
        
        ; Close button
        closeBtn := this.gui.Add("Button", "x360 y5 w30 h30 Background0x444444", "✕")
        closeBtn.SetFont("s10 cWhite Bold", "Segoe UI")
        closeBtn.OnEvent("Click", this.ClosePopup.Bind(this))
        
        ; Game list
        this.gui.SetFont("s10 cWhite", "Segoe UI")
        
        ; Categories
        categories := {}
        for game in this.gameList {
            if (!categories.Has(game.category)) {
                categories[game.category] := []
            }
            categories[game.category].Push(game)
        }
        
        yPos := 50
        for category, games in categories {
            ; Category header
            this.gui.Add("Text", "x20 y" . yPos . " w360 Bold c0x888888", "📁 " . StrUpper(category))
            yPos += 25
            
            ; Games in category
            for game in games {
                gameBtn := this.gui.Add("Button", "x20 y" . yPos . " w360 h35 Background0x2d2d2d", game.name)
                gameBtn.SetFont("s10 cWhite", "Segoe UI")
                gameBtn.OnEvent("Click", this.LaunchGame.Bind(this, game))
                
                ; Description
                this.gui.Add("Text", "x40 y" . (yPos + 25) . " w340 c0xaaaaaa", game.description)
                yPos += 60
            }
            yPos += 10
        }
        
        ; Quick actions
        yPos += 20
        this.gui.Add("Text", "x20 y" . yPos . " w360 Bold c0x888888", "⚡ Quick Actions")
        yPos += 25
        
        ; Random game button
        randomBtn := this.gui.Add("Button", "x20 y" . yPos . " w170 h40 Background0x4a4a4a", "🎲 Random Game")
        randomBtn.SetFont("s10 cWhite Bold", "Segoe UI")
        randomBtn.OnEvent("Click", this.LaunchRandomGame.Bind(this))
        
        ; Refresh list button
        refreshBtn := this.gui.Add("Button", "x210 y" . yPos . " w170 h40 Background0x4a4a4a", "🔄 Refresh")
        refreshBtn.SetFont("s10 cWhite Bold", "Segoe UI")
        refreshBtn.OnEvent("Click", this.RefreshList.Bind(this))
        
        yPos += 50
        
        ; Status bar
        this.gui.Add("Text", "x20 y" . yPos . " w360 Center c0x888888", "Press Ctrl+Alt+G to open • Escape to close")
        
        ; Calculate height based on content
        totalHeight := yPos + 40
        
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
            
            if (FileExist(game.script)) {
                ; Launch the game
                Run('"' . A_AhkPath . '" "' . game.script . '"')
                
                ; Show success message
                TrayTip("Game Launched!", "Starting " . game.name, 2)
                
                ; Log the launch
                this.LogGameLaunch(game)
            } else {
                MsgBox("Game file not found: " . game.script, "Error", "Iconx")
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
    
    static SetupHotkeys() {
        ; Main hotkey
        Hotkey("^!g", (*) => this.CreateGamePopup()
        
        ; Close with Escape
        Escape::{
            if (WinExist("Game Starter")) {
                GameStarter.ClosePopup()
            }
        }
        
        ; Close with Enter (launch selected)
        Hotkey("Enter", (*) => {
            if (WinExist("Game Starter")) {
                ; Could implement selection logic here
                GameStarter.ClosePopup()
            }
        }
    }
}

; Initialize
GameStarter.Init()








