#Requires AutoHotkey v2.0+
#SingleInstance Force

; ==============================================================================
; Pranks Collection
; @name: Pranks Collection
; @version: 1.0.0
; @description: Collection of harmless prank features for entertainment. Includes fake typing, mouse jiggling, and other harmless prank effects.
; @description: Provides harmless prank features like fake typing sounds, mouse jiggling, and screen effects. All pranks are reversible and designed for harmless fun.
; @description: Entertainment tool for harmless pranks and fun interactions. Use responsibly and only with consenting participants.
; @category: fun
; @author: Sandra
; @hotkeys: ^!t, ^!j
; @enabled: false
; @priority: 90
; @tag: pranks, fun, entertainment, harmless, jokes
; @cli: --enable <prank> - Enable specific prank feature
; @cli: --list - List all available prank features
; @cli: --help - Show CLI usage and prank options
; @dependencies: 
; ==============================================================================

; Error handling - log to file instead of showing popups
OnError(LogError)

LogError(Thrown, Mode) {
    errorMsg := "Error: " . Thrown.Message . " at line " . Thrown.Line . "`n" . Thrown.Stack
    FileAppend(errorMsg, "pranks_errors.log", "UTF-8")
    OutputDebug(errorMsg)  ; Enable LLM debugging
    return 1  ; Suppress popup (1 = suppress, 0 = show)
}

; Prank: Fake Typing
Hotkey("^!t", (*) =>  {  ; Ctrl+Alt+T to toggle fake typing
    static typing := false
    typing := !typing
    if (typing) {
        SetTimer FakeTyping, 1000
        TrayTip "Prank", "Fake Typing: ON", , 1
    } else {
        SetTimer FakeTyping, 0
        TrayTip "Prank", "Fake Typing: OFF", , 1
    }
    SetTimer RemoveTrayTip.Bind(, 3000), -3000
}

FakeTyping() {
    Random rand, 1, 10
    if (rand = 1) {
        SendInput("{Backspace 5}")
        Sleep 100
        SendInput("{Text}Oops!`n")
    } else if (rand = 2) {
        SendInput("{Text}Let me think...{Enter}")
    } else if (rand = 3) {
        SendInput("{Text}Hmm...{Space}")
    } else {
        SendInput("{Text}The quick brown fox jumps over the lazy dog. {Space}")
    }
}

; Prank: Random Mouse Clicks
Hotkey("^!m", (*) =>  {  ; Ctrl+Alt+M to toggle random mouse clicks
    static clicking := false
    clicking := !clicking
    if (clicking) {
        SetTimer RandomClick, 3000
        TrayTip "Prank", "Random Clicks: ON", , 1
    } else {
        SetTimer RandomClick, 0
        TrayTip "Prank", "Random Clicks: OFF", , 1
    }
    SetTimer RemoveTrayTip.Bind(, 3000), -3000
}

RandomClick() {
    Random x, 0, A_ScreenWidth
    Random y, 0, A_ScreenHeight
    Click x " " y
}

; Prank: Invert Mouse Buttons
Hotkey("^!i", (*) =>  {  ; Ctrl+Alt+I to invert mouse buttons
    static inverted := false
    inverted := !inverted
    if (inverted) {
        DllCall("SwapMouseButton", "UInt", 1)
        TrayTip "Prank", "Mouse Buttons Inverted!", , 1
    } else {
        DllCall("SwapMouseButton", "UInt", 0)
        TrayTip "Prank", "Mouse Buttons Normal", , 1
    }
    SetTimer RemoveTrayTip.Bind(, 3000), -3000
}

; Prank: Fake BSOD
Hotkey("^!b", (*) =>  {  ; Ctrl+Alt+B for fake BSOD
    bsod := Gui("+AlwaysOnTop -Caption +ToolWindow", "Windows - No Disk")
    bsod.BackColor := "0000AA"
    bsod.SetFont("s12 cFFFFFF", "Lucida Console")
    
    bsodText := ""
    bsodText .= "A problem has been detected and Windows has been shut down to prevent damage`n"
    bsodText .= "to your computer.`n`n"
    bsodText .= "DRIVER_IRQL_NOT_LESS_OR_EQUAL`n`n"
    bsodText .= "If this is the first time you've seen this stop error screen,`n"
    bsodText .= "restart your computer. If this screen appears again, follow`n"
    bsodText .= "these steps:`n`n"
    bsodText .= "Check to make sure any new hardware or software is properly installed.`n"
    bsodText .= "If this is a new installation, ask your hardware or software manufacturer`n"
    bsodText .= "for any Windows updates you might need.`n`n"
    bsodText .= "Technical information:`n"
    bsodText .= "*** STOP: 0x000000D1 (0x00000000,0x00000002,0x00000000,0x00000000)`n`n"
    bsodText .= "Beginning dump of physical memory`n"
    bsodText .= "Physical memory dump complete.`n"
    bsodText .= "Contact your system administrator or technical support group for further`n"
    bsodText .= "assistance."
    
    bsod.Add("Text", "x20 y20 w600 h400", bsodText)
    bsod.Show("w640 h480")
}

; Prank: Fake Update
Hotkey("^!u", (*) =>  {  ; Ctrl+Alt+U for fake Windows update
    updateGui := Gui("-Caption +ToolWindow +AlwaysOnTop", "Windows Update")
    updateGui.BackColor := "0078D7"
    updateGui.SetFont("s12 cFFFFFF", "Segoe UI")
    
    updateGui.Add("Text", "x20 y20 w600 h30", "Windows is installing updates...")
    progress := updateGui.Add("Progress", "x20 y60 w600 h30 cGreen vProgress", 0)
    updateGui.Add("Text", "x20 y100 w600 h30 vStatus", "Preparing to install updates...")
    
    updateGui.Show("w640 h200")
    
    ; Simulate update progress
    SetTimer UpdateProgress, 1000
    
    UpdateProgress() {
        static progressValue := 0
        if (progressValue >= 100) {
            SetTimer , 0
            Sleep 1000
            updateGui.Destroy()
            return
        }
        
        progressValue += Random(1, 5)
        if (progressValue > 100) progressValue := 100
        
        progress.Value := progressValue
        
        switch {
            case progressValue < 20:
                updateGui["Status"].Text := "Preparing to install updates..."
            case progressValue < 40:
                updateGui["Status"].Text := "Downloading updates 1 of 3..."
            case progressValue < 60:
                updateGui["Status"].Text := "Installing Windows 11 (1/3)..."
            case progressValue < 80:
                updateGui["Status"].Text := "Installing security updates..."
            case progressValue < 100:
                updateGui["Status"].Text := "Finishing up..."
            default:
                updateGui["Status"].Text := "Update complete! Restarting in 10 seconds..."
        }
    }
}

; Prank: Fake Error Message
Hotkey("^!e", (*) =>  {  ; Ctrl+Alt+E for fake error
    MsgBox("Error 0x80070002: The system cannot find the file specified.",  "Windows - Application Error",  "Icon!"
}

; Prank: Fake Shutdown
Hotkey("^!s", (*) =>  {  ; Ctrl+Alt+S for fake shutdown
    shutdownGui := Gui("-Caption +ToolWindow +AlwaysOnTop", "Windows")
    shutdownGui.BackColor := "000000"
    shutdownGui.SetFont("s12 cFFFFFF", "Segoe UI")
    
    shutdownGui.Add("Text", "x20 y20 w600 h30", "Shutting down...")
    shutdownGui.Show("w640 h480")
    
    ; Make it fullscreen
    WinSetStyle "-0xC00000", "Windows"  ; Remove title bar
    WinSetStyle "-0x40000", "Windows"  ; Remove thick frame
    WinSetStyle "-0x800000", "Windows"  ; Remove dialog frame
    WinSetStyle "-0x400000", "Windows"  ; Remove sizebox
    WinSetStyle "-0x20000", "Windows"  ; Remove minimize box
    WinSetStyle "-0x10000", "Windows"  ; Remove maximize box
    WinSetStyle "-0x40000", "Windows"  ; Remove sysmenu
    
    WinMove 0, 0, A_ScreenWidth, A_ScreenHeight, "Windows"
    
    ; Add shutdown message
    shutdownGui.Add("Text", "x0 y200 w" A_ScreenWidth " h100 Center", "Shutting down...")
    
    ; Wait a bit then close
    SetTimer () => ExitApp(), -3000
}

; Helper function to remove tray tips
RemoveTrayTip() {
    TrayTip
}

; Make sure to clean up when script exits
OnExit(ExitFunc)
ExitFunc(ExitReason, ExitCode) {
    ; Restore mouse buttons if they were inverted
    DllCall("SwapMouseButton", "UInt", 0)
    return 0
}


