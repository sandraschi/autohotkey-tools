#Requires AutoHotkey v2.0+
#SingleInstance Force

LogError(exception, mode) {
    try {
        msg := exception && HasProp(exception, "Message") ? exception.Message : "Unknown"
        FileAppend("[" A_Now "] " msg "`n", A_ScriptDir "\ScriptletLauncher.log")
    } catch {
    }
    return 1
}

; NOTE: the old `#Include %A_ScriptDir%\lib\ScriptletErrorHandler.ahk` was
; removed - v2 does not expand %vars% in #Include and scriptlets/lib does
; not exist, so the script died at load with nothing shown.
OnError(LogError)

; ==============================================================================
; Scriptlet Launcher
; @name: Scriptlet Launcher
; @version: 1.0.0
; @description: Main launcher GUI for all AutoHotkey scriptlets. Centralized launcher interface for browsing, launching, and managing scriptlets.
; @description: Features categorized scriptlet browsing, search functionality, quick launch, and scriptlet management. Provides organized access to all available scriptlets with descriptions and hotkeys.
; @description: Essential launcher tool for accessing and managing the complete scriptlet collection with intuitive GUI and search capabilities.
; @category: utilities
; @author: Sandra
; @hotkeys: (runs automatically on startup)
; @enabled: true
; @priority: 1
; @tag: launcher, scriptlets, management, gui, utilities, organization
; @cli: --script <name> - Launch specific scriptlet by name
; @cli: --category <cat> - Show only scriptlets in specific category
; @cli: --help - Show CLI usage and launcher options
; @dependencies: 
; ==============================================================================

; Suppress error popups - log to file instead
OnError(LogError)

class ScriptletLauncher {
    static gui := ""
    static statusBar := ""
    static tabControl := ""
    
    static Init() {
        ; Set working directory
        SetWorkingDir(A_ScriptDir)
        
        ; Create GUI
        this.CreateGUI()
        
        ; Setup tray menu
        this.SetupTrayMenu()
    }
    
    static CreateGUI() {
        this.gui := Gui("+Resize", "Scriptlet Launcher")
        this.gui.BackColor := "1E1E1E"
        this.gui.SetFont("s10 cFFFFFF", "Segoe UI")
        
        ; Header (pictures are decorative - skip silently if the icon fails)
        try this.gui.Add("Picture", "x10 y10 w48 h48 Icon1", A_WinDir . "\System32\SHELL32.dll")
        title := this.gui.Add("Text", "x68 y15 w300 h30 Center", "Scriptlet Launcher")
        title.SetFont("s16 Bold cFFFFFF")
        this.gui.Add("Text", "x70 y45 w300 h20 Center cSilver", "v1.0 - Manage your AHK scripts")
        
        ; Create tab control
        this.tabControl := this.gui.Add("Tab3", "x0 y80 w400 h400", ["Utilities", "Games", "Pranks", "About"])
        
        ; Utilities tab (page 1)
        this.tabControl.UseTab(1)
        
        utilitiesFrame := this.gui.Add("GroupBox", "x10 y110 w380 h150", "Window Management")
        
        this.gui.Add("Button", "x20 y130 w170 h30", "&Window Management").OnEvent("Click", (*) => this.LaunchScript("window_management.ahk"))
        this.gui.Add("Button", "x200 y130 w170 h30", "Window &Snapping").OnEvent("Click", (*) => this.LaunchScript("window_snapping.ahk"))
        this.gui.Add("Button", "x20 y170 w170 h30", "&Quick Launch").OnEvent("Click", (*) => this.LaunchScript("quick_launch.ahk"))
        this.gui.Add("Button", "x200 y170 w170 h30", "&Clipboard Manager").OnEvent("Click", (*) => this.LaunchScript("clipboard_manager.ahk"))
        this.gui.Add("Button", "x20 y210 w170 h30", "&Volume Control").OnEvent("Click", (*) => this.LaunchScript("volume_control.ahk"))
        this.gui.Add("Button", "x200 y210 w170 h30", "IDE &Shortcuts").OnEvent("Click", (*) => this.LaunchScript("ide_shortcuts.ahk"))
        
        ; Games tab (page 2) - every game in the depot, launched by file name.
        ; New games appear here by adding one button row; the bridge
        ; dashboard (/scriptlets) always reflects the live directory scan.
        this.tabControl.UseTab(2)
        
        this.gui.Add("GroupBox", "x10 y110 w380 h240", "Games")
        this.gui.Add("Button", "x20 y130 w170 h30", "Chess (Stockfish)").OnEvent("Click", (*) => this.LaunchScript("chess_stockfish.ahk"))
        this.gui.Add("Button", "x200 y130 w170 h30", "Frogger").OnEvent("Click", (*) => this.LaunchScript("classic_frogger.ahk"))
        this.gui.Add("Button", "x20 y165 w170 h30", "Pong").OnEvent("Click", (*) => this.LaunchScript("classic_pong.ahk"))
        this.gui.Add("Button", "x200 y165 w170 h30", "Pac-Man").OnEvent("Click", (*) => this.LaunchScript("pacman_classic.ahk"))
        this.gui.Add("Button", "x20 y200 w170 h30", "Q*Bert").OnEvent("Click", (*) => this.LaunchScript("qbert_game.ahk"))
        this.gui.Add("Button", "x200 y200 w170 h30", "Tetris").OnEvent("Click", (*) => this.LaunchScript("tetris_classic.ahk"))
        this.gui.Add("Button", "x20 y235 w170 h30", "Sudoku").OnEvent("Click", (*) => this.LaunchScript("sudoku.ahk"))
        this.gui.Add("Button", "x200 y235 w170 h30", "15-Puzzle").OnEvent("Click", (*) => this.LaunchScript("PuzzleGame.ahk"))
        this.gui.Add("Button", "x20 y270 w170 h30", "Wordle && Co").OnEvent("Click", (*) => this.LaunchScript("word_games.ahk"))
        this.gui.Add("Button", "x200 y270 w170 h30", "Mini Games").OnEvent("Click", (*) => this.LaunchScript("mini_games_collection.ahk"))
        this.gui.Add("Button", "x20 y305 w170 h30", "Fun Games").OnEvent("Click", (*) => this.LaunchScript("fun_games.ahk"))
        this.gui.Add("Button", "x200 y305 w170 h30", "Game Popup").OnEvent("Click", (*) => this.LaunchScript("game_starter_popup.ahk"))
        
        ; Pranks tab (page 3)
        this.tabControl.UseTab(3)
        
        this.gui.Add("GroupBox", "x10 y110 w380 h150", "Harmless Pranks")
        this.gui.Add("Button", "x20 y130 w170 h30", "&Fake Typing`n(Ctrl+Alt+T)").OnEvent("Click", (*) => this.LaunchScript("pranks.ahk"))
        this.gui.Add("Button", "x200 y130 w170 h30", "&Mouse Jiggler`n(Ctrl+Alt+J)").OnEvent("Click", (*) => this.LaunchScript("fun_games.ahk"))
        this.gui.Add("Button", "x20 y170 w170 h30", "&Invert Mouse`n(Ctrl+Alt+I)").OnEvent("Click", (*) => this.LaunchScript("pranks.ahk"))
        this.gui.Add("Button", "x200 y170 w170 h30", "Fake &BSOD`n(Ctrl+Alt+B)").OnEvent("Click", (*) => this.LaunchScript("pranks.ahk"))
        this.gui.Add("Button", "x20 y210 w170 h30", "Fake &Update`n(Ctrl+Alt+U)").OnEvent("Click", (*) => this.LaunchScript("pranks.ahk"))
        
        ; About tab (page 4)
        this.tabControl.UseTab(4)
        
        try this.gui.Add("Picture", "x150 y120 w100 h100 Icon1", A_WinDir . "\System32\SHELL32.dll")
        this.gui.Add("Text", "x20 y230 w360 h60 Center", "Scriptlet Launcher v1.0`nCreated with AutoHotkey`n`nSelect a script from the tabs above to get started.")
        
        ; Release tab context so the status bar lands on the window, not a page
        this.tabControl.UseTab(0)
        
        ; Status bar
        this.statusBar := this.gui.Add("StatusBar")
        this.statusBar.Text := "Ready"
        
        ; Event handlers
        this.gui.OnEvent("Close", (*) => this.OnClose())
        this.gui.OnEvent("Escape", (*) => this.OnClose())
        
        ; Show GUI
        this.gui.Show("w400 h500")
    }
    
    static LaunchScript(scriptName) {
        scriptPath := A_ScriptDir . "\" . scriptName
        
        if (!FileExist(scriptPath)) {
            this.statusBar.Text := "Error: " . scriptName . " not found!"
            MsgBox("Script not found:`n" . scriptPath, "Error", "0x10")
        } else {
            Run('"' . A_AhkPath . '" "' . scriptPath . '"')
            this.statusBar.Text := "Launched: " . scriptName
        }
    }
    
    static SetupTrayMenu() {
        A_TrayMenu.Delete()
        A_TrayMenu.Add("Open Launcher", (*) => this.ShowGUI())
        A_TrayMenu.Add()
        A_TrayMenu.Add("Reload", (*) => Reload())
        A_TrayMenu.Add("Exit", (*) => ExitApp())
        A_IconTip := "Scriptlet Launcher"
    }
    
    static ShowGUI() {
        if (this.gui) {
            this.gui.Show()
        }
    }
    
    static OnClose() {
        if (this.gui) {
            this.gui.Hide()
        }
        TrayTip("Scriptlet Launcher", "Running in the system tray", 1)
    }
}

; Initialize
ScriptletLauncher.Init()

; Keep running
Loop {
    Sleep(1000)
}
