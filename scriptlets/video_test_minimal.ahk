#Requires AutoHotkey v2.0+
#SingleInstance Force
#Include %A_ScriptDir%\lib\ScriptletErrorHandler.ahk

OnError(LogError)

TrayTip("Test", "Starting...", 2)

class Test {
    static guiInstance := ""
    
    static Init() {
        try {
            this.CreateGUI()
        } catch as e {
            MsgBox("Error: " . e.Message, "Error", "Iconx")
        }
    }
    
    static CreateGUI() {
        this.guiInstance := Gui("+Resize", "Test Window")
        this.guiInstance.Add("Text", "x20 y20", "TEST WINDOW - IF YOU SEE THIS IT WORKS")
        this.guiInstance.Show("w400 h300")
    }
}

Test.Init()

Loop {
    Sleep(1000)
}
