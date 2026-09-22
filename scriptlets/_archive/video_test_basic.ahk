#Requires AutoHotkey v2.0+
#SingleInstance Force
#Include %A_ScriptDir%\lib\ScriptletErrorHandler.ahk

OnError(LogError)

MsgBox("Test 1: Script loaded", "Test", "Icon!")

class Test {
    static Init() {
        MsgBox("Test 2: Init() called", "Test", "Icon!")
        this.CreateGUI()
    }
    
    static CreateGUI() {
        this.gui := Gui("+Resize", "Test")
        this.gui.Add("Text",, "GUI Test")
        this.gui.Add("Button", "Default", "Close").OnEvent("Click", (*) => ExitApp())
        this.gui.OnEvent("Close", (*) => ExitApp())
        this.gui.Show("w400 h200")
        MsgBox("Test 3: GUI shown", "Test", "Icon!")
    }
}

Test.Init()

