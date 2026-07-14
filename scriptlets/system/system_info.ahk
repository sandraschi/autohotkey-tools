#Requires AutoHotkey v2.0+
#SingleInstance Force
#Include ..\lib\ScriptletErrorHandler.ahk

OnError(LogError)

class SystemInfo {
    static name := "System Information"
    static description := "Displays detailed system information"
    static category := "System"
    static hotkey := "^!s"
    
    static Run() {
        try {
            ; Get system information
            SysGet(monitorCount, "MonitorCount")
            SysGet(primaryMonitor, "MonitorPrimary")
            freeSpace := DriveGetSpace("C:")
            
            ; Format information
            info := "=== System Information ===`n"
            info .= "Computer Name: " . A_ComputerName . "`n"
            info .= "OS Version: " . A_OSVersion . " (" . (A_Is64bitOS ? "64" : "32") . "-bit)`n"
            info .= "Username: " . A_UserName . "`n"
            info .= "IP Address: " . A_IPAddress1 . "`n"
            info .= "Monitor Count: " . monitorCount . " (Primary: " . primaryMonitor . ")`n"
            info .= "Screen Resolution: " . A_ScreenWidth . "x" . A_ScreenHeight . "@" . A_ScreenDPI . " DPI`n"
            info .= "Free Disk Space (C:): " . Round(freeSpace, 1) . " GB"
            
            ; Display in a GUI
            gui := Gui("+AlwaysOnTop", "System Information")
            gui.SetFont("s10", "Consolas")
            gui.Add("Text", "w600", info)
            gui.Add("Button", "Default w80", "OK").OnEvent("Click", (*) => gui.Destroy())
            
        ; Add exit handlers
        gui.OnEvent("Close", (*) => ExitApp())
        gui.OnEvent("Escape", (*) => ExitApp())
        gui.Show()
        } catch as e {
            OutputDebug("SystemInfo error: " . e.Message)
        }
    }
    
    static Init() {
        SystemInfo.Run()
    }
}

SystemInfo.Init()
