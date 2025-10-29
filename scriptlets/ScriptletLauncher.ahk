#Requires AutoHotkey v2.0+
#SingleInstance Force

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

LogError(Thrown, Mode) {
    errorMsg := "Error: " . Thrown.Message . " at line " . Thrown.Line . "`n" . Thrown.Stack
    FileAppend(errorMsg, "scriptlet_launcher_errors.log", "UTF-8")
    OutputDebug(errorMsg)  ; Enable LLM debugging
    return 1  ; Suppress popup (1 = suppress, 0 = show)
}

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
        
        ; Header
        this.gui.Add("Picture", "x10 y10 w48 h48", A_WinDir . "\System32\SHELL32.dll")
        title := this.gui.Add("Text", "x68 y15 w300 h30 Center", "Scriptlet Launcher")
        title.SetFont("s16 Bold cFFFFFF")
        this.gui.Add("Text", "x70 y45 w300 h20 Center cSilver", "v1.0 - Manage your AHK scripts")
        
        ; Create tab control
        this.tabControl := this.gui.Add("Tab3", "x0 y80 w400 h400", ["Utilities", "Games", "Pranks", "About"])
        
        ; Utilities tab
        this.gui.Add("Tab")
        
        utilitiesFrame := this.gui.Add("GroupBox", "x10 y110 w380 h150", "Window Management")
        
        this.gui.Add("Button", "x20 y130 w170 h30", "&Window Management").OnEvent("Click", (*) => this.LaunchScript("window_management.ahk"))
        this.gui.Add("Button", "x200 y130 w170 h30", "Window &Snapping").OnEvent("Click", (*) => this.LaunchScript("window_snapping.ahk"))
        this.gui.Add("Button", "x20 y170 w170 h30", "&Quick Launch").OnEvent("Click", (*) => this.LaunchScript("quick_launch.ahk"))
        this.gui.Add("Button", "x200 y170 w170 h30", "&Clipboard Manager").OnEvent("Click", (*) => this.LaunchScript("clipboard_manager.ahk"))
        this.gui.Add("Button", "x20 y210 w170 h30", "&Volume Control").OnEvent("Click", (*) => this.LaunchScript("volume_control.ahk"))
        this.gui.Add("Button", "x200 y210 w170 h30", "IDE &Shortcuts").OnEvent("Click", (*) => this.LaunchScript("ide_shortcuts.ahk"))
        
        ; Games tab
        this.gui.Add("Tab")
        
        this.gui.Add("GroupBox", "x10 y110 w380 h100", "Games")
        snakeBtn := this.gui.Add("Button", "x20 y130 w350 h40", "Play &Snake Game`nCtrl+Alt+S when running")
        snakeBtn.OnEvent("Click", (*) => this.LaunchSnakeGame())
        
        ; Pranks tab
        this.gui.Add("Tab")
        
        this.gui.Add("GroupBox", "x10 y110 w380 h150", "Harmless Pranks")
        this.gui.Add("Button", "x20 y130 w170 h30", "&Fake Typing`n(Ctrl+Alt+T)").OnEvent("Click", (*) => this.LaunchScript("pranks.ahk"))
        this.gui.Add("Button", "x200 y130 w170 h30", "&Mouse Jiggler`n(Ctrl+Alt+J)").OnEvent("Click", (*) => this.LaunchScript("fun_games.ahk"))
        this.gui.Add("Button", "x20 y170 w170 h30", "&Invert Mouse`n(Ctrl+Alt+I)").OnEvent("Click", (*) => this.LaunchScript("pranks.ahk"))
        this.gui.Add("Button", "x200 y170 w170 h30", "Fake &BSOD`n(Ctrl+Alt+B)").OnEvent("Click", (*) => this.LaunchScript("pranks.ahk"))
        this.gui.Add("Button", "x20 y210 w170 h30", "Fake &Update`n(Ctrl+Alt+U)").OnEvent("Click", (*) => this.LaunchScript("pranks.ahk"))
        
        ; About tab
        this.gui.Add("Tab")
        
        this.gui.Add("Picture", "x150 y120 w100 h100", A_WinDir . "\System32\SHELL32.dll")
        this.gui.Add("Text", "x20 y230 w360 h60 Center", "Scriptlet Launcher v1.0`nCreated with AutoHotkey`n`nSelect a script from the tabs above to get started.")
        
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
            MsgBox("Error", "Script not found:`n" . scriptPath, "0x10")
        } else {
            Run('"' . A_AhkPath . '" "' . scriptPath . '"')
            this.statusBar.Text := "Launched: " . scriptName
        }
    }
    
    static LaunchSnakeGame() {
        this.LaunchScript("fun_games.ahk")
        this.statusBar.Text := "Press Ctrl+Alt+S in any window to start Snake!"
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
        TrayTip("Scriptlet Launcher", "Running in the system tray", , 1)
    }
}

; Initialize
ScriptletLauncher.Init()

; Keep running
Loop {
    Sleep(1000)
}
