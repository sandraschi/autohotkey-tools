; ==============================================================================
; GUI Test
; @name: GUI Test
; @version: 1.0.0
; @description: Minimal GUI test
; @category: test
; @author: Sandra
; @hotkeys: ^!t
; @enabled: true
; ==============================================================================

#Requires AutoHotkey v2.0+
#SingleInstance Force
#Include %A_ScriptDir%\lib\ScriptletErrorHandler.ahk

; Show that script is starting
TrayTip("GUI Test", "Script starting...", 3)

; Log errors but allow GUI errors to show
OnError(LogError)

GuiTestLogError(Thrown, Mode) {
    ScriptletErrorHandler.Handle(Thrown, Mode)
    if (Thrown && (InStr(Thrown.Message, "GUI") || (HasProp(Thrown, "Stack") && InStr(Thrown.Stack, "CreateGUI")))) {
        return 0
    }
    return 1
}
OnError(GuiTestLogError)

class GUITest {
    static guiInstance := ""
    
    static Init() {
        try {
            TrayTip("GUI Test", "Starting GUI...", 2)
            this.CreateGUI()
        } catch as e {
            MsgBox("Init error: " . e.Message . "`n" . e.Stack, "Error", "Iconx")
        }
    }
    
    static CreateGUI() {
        try {
            this.guiInstance := Gui("+Resize +MinSize800x600", "GUI Test")
            this.guiInstance.BackColor := "1a1a1a"
            this.guiInstance.SetFont("s10 cFFFFFF", "Segoe UI")
            
            titleText := this.guiInstance.Add("Text", "x20 y20 w760 Center", "GUI Test Window")
            titleText.SetFont("Bold")
            
            this.guiInstance.Add("Text", "x20 y50 w760 Center cYellow", "If you see this, the GUI system works!")
            
            btnClose := this.guiInstance.Add("Button", "x20 y100 w120 h30", "&Close")
            btnClose.OnEvent("Click", (*) => this.guiInstance.Close())
            
            this.guiInstance.OnEvent("Close", (*) => ExitApp())
            this.guiInstance.OnEvent("Escape", (*) => this.guiInstance.Close())
            
            this.guiInstance.Show("w800 h600 Center")
            WinShow(this.guiInstance.Hwnd)
            WinActivate(this.guiInstance.Hwnd)
        } catch as e {
            errorMsg := "Error creating GUI: " . e.Message . "`n" . e.Stack
            FileAppend(errorMsg, "gui_test_errors.log", "UTF-8")
            OutputDebug(errorMsg)
            MsgBox("Error creating GUI: " . e.Message, "Error", "Iconx")
            throw
        }
    }
}

; Hotkeys
Hotkey("^!t", (*) => GUITest.Init())

; Initialize
GUITest.Init()

; Keep script running
Loop {
    Sleep(1000)
}
