#Requires AutoHotkey v2.0+
#SingleInstance Force
#Include %A_ScriptDir%\lib\ScriptletErrorHandler.ahk

OnError(LogError)

; Show that script is starting
TrayTip("Video Filename Scrubber", "Script starting...", 3)

class VideoFilenameScrubber {
    static gui := ""
    
    static Init() {
        try {
            TrayTip("Video Filename Scrubber", "Starting GUI...", 2)
            this.CreateGUI()
        } catch as e {
            MsgBox("Init error: " . e.Message . "`n" . e.Stack, "Error", "Iconx")
        }
    }
    
    static CreateGUI() {
        try {
            this.gui := Gui("+Resize +MinSize800x600", "Video Filename Scrubber")
            this.gui.BackColor := "1a1a1a"
            this.gui.SetFont("s10 cFFFFFF", "Segoe UI")
            
            titleText := this.gui.Add("Text", "x20 y20 w760 Center", "🎬 Video Filename Scrubber")
            titleText.SetFont("Bold")
            
            this.gui.Add("Text", "x20 y50 w760 Center cYellow", "🔍 DRY RUN MODE - No changes will be made")
            this.gui.Add("Text", "x20 y80 w760 Center cGray", "Target: L:\Tixati")
            
            this.gui.OnEvent("Close", (*) => ExitApp())
            this.gui.OnEvent("Escape", (*) => this.gui.Close())
            
            this.gui.Show("w800 h600 Center")
            WinShow(this.gui.Hwnd)
            WinActivate(this.gui.Hwnd)
        } catch as e {
            errorMsg := "Error creating GUI: " . e.Message . "`n" . e.Stack
            FileAppend(errorMsg, "video_filename_scrubber_errors.log", "UTF-8")
            OutputDebug(errorMsg)
            MsgBox("Error creating GUI: " . e.Message, "Error", "Iconx")
            throw
        }
    }
}

; Hotkeys
Hotkey("^!v", (*) => VideoFilenameScrubber.Init())

; Initialize
VideoFilenameScrubber.Init()

; Keep script running
Loop {
    Sleep(1000)
}

