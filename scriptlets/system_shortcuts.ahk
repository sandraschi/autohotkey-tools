#Requires AutoHotkey v2.0+
#SingleInstance Force

; ==============================================================================
; System Shortcuts
; @name: System Shortcuts
; @version: 1.0.0
; @description: Essential system management shortcuts for power management, system toggles, and administrative tools. Quick access to common system operations and settings.
; @description: Provides hotkeys for shutdown, restart, hibernate, lock workstation, system property access, task manager, and various system toggle functions. Includes help screen with all available shortcuts.
; @description: Essential productivity tool for system administrators and power users who frequently access system tools and perform administrative tasks.
; @category: system
; @author: Sandra
; @hotkeys: ^!+s, ^!+r, ^!+l, ^!h, ^!e, #l, ^+h
; @enabled: true
; @priority: 20
; @tag: system, shortcuts, power-management, admin, utilities, productivity, hotkeys
; @cli: --help - Show all available system shortcuts
; @cli: --list - List configured shortcuts
; @dependencies: 
; ==============================================================================

; Error handling - log to file instead of showing popups
OnError(LogError)

LogError(Thrown, Mode) {
    errorMsg := "Error: " . Thrown.Message . " at line " . Thrown.Line . "`n" . Thrown.Stack
    FileAppend(errorMsg, "system_shortcuts_errors.log", "UTF-8")
    OutputDebug(errorMsg)  ; Enable LLM debugging
    return 1  ; Suppress popup (1 = suppress, 0 = show)
}

; =============================================================================
; CONFIGURATION
; =============================================================================
; Power Management
POWER_SHUTDOWN := "^!+s"      ; Ctrl+Alt+Shift+S - Shutdown
POWER_RESTART := "^!+r"       ; Ctrl+Alt+Shift+R - Restart
POWER_LOGOFF := "^!+l"        ; Ctrl+Alt+Shift+L - Logoff
POWER_HIBERNATE := "^!+h"     ; Ctrl+Alt+Shift+H - Hibernate
POWER_SLEEP := "^!+x"         ; Ctrl+Alt+Shift+X - Sleep
POWER_LOCK := "#l"            ; Win+L - Lock Workstation

; System Toggles
TOGGLE_HIDDEN_FILES := "^!h"  ; Ctrl+Alt+H - Toggle hidden files
TOGGLE_FILE_EXT := "^!e"      ; Ctrl+Alt+E - Toggle file extensions
TOGGLE_TASKBAR_AUTO_HIDE := "^!t"  ; Ctrl+Alt+T - Toggle taskbar auto-hide
FIX_TASKBAR := "^!+u"         ; Ctrl+Alt+Shift+U - Fix stuck taskbar

; System Actions
EMPTY_RECYCLE_BIN := "^!+e"  ; Ctrl+Alt+Shift+E - Empty Recycle Bin
OPEN_SYSTEM_PROPERTIES := "^!+p"  ; Ctrl+Alt+Shift+P - System Properties
OPEN_TASK_MANAGER := "^!+del"     ; Ctrl+Alt+Shift+Del - Task Manager
OPEN_DEVICE_MANAGER := "^!+m"     ; Ctrl+Alt+Shift+M - Device Manager
OPEN_DISK_CLEANUP := "^!+d"       ; Ctrl+Alt+Shift+D - Disk Cleanup

; Help Screen
Hotkey("^+h", (*) => ShowHelp()  ; Ctrl+Shift+H - Show help screen

; =============================================================================
; FUNCTIONS
; =============================================================================

; Show help screen with all available shortcuts
ShowHelp() {
    helpText := "System Shortcuts Help`n"
            . "=====================`n`n"
            
            . "Power Management:`n"
            . "-----------------`n"
            . "Shutdown:         " . GetHotkeyString(POWER_SHUTDOWN) . "`n"
            . "Restart:          " . GetHotkeyString(POWER_RESTART) . "`n"
            . "Logoff:           " . GetHotkeyString(POWER_LOGOFF) . "`n"
            . "Hibernate:        " . GetHotkeyString(POWER_HIBERNATE) . "`n"
            . "Sleep:            " . GetHotkeyString(POWER_SLEEP) . "`n"
            . "Lock Workstation: " . GetHotkeyString(POWER_LOCK) . "`n`n"
            
            . "System Toggles:`n"
            . "---------------`n"
            . "Toggle Hidden Files:      " . GetHotkeyString(TOGGLE_HIDDEN_FILES) . "`n"
            . "Toggle File Extensions:   " . GetHotkeyString(TOGGLE_FILE_EXT) . "`n"
            . "Toggle Taskbar Auto-Hide: " . GetHotkeyString(TOGGLE_TASKBAR_AUTO_HIDE) . "`n"
            . "Fix Stuck Taskbar:        " . GetHotkeyString(FIX_TASKBAR) . "`n`n"
            
            . "System Actions:`n"
            . "---------------`n"
            . "Empty Recycle Bin:    " . GetHotkeyString(EMPTY_RECYCLE_BIN) . "`n"
            . "System Properties:    " . GetHotkeyString(OPEN_SYSTEM_PROPERTIES) . "`n"
            . "Task Manager:         " . GetHotkeyString(OPEN_TASK_MANAGER) . "`n"
            . "Device Manager:       " . GetHotkeyString(OPEN_DEVICE_MANAGER) . "`n"
            . "Disk Cleanup:         " . GetHotkeyString(OPEN_DISK_CLEANUP) . "`n`n"
            
            . "Help:                Ctrl+Shift+H`n"
            
    MsgBox(helpText, "System Shortcuts Help", "T1024")
}

; Helper function to convert hotkey strings to readable format
GetHotkeyString(hotkey) {
    str := StrReplace(hotkey, "^", "Ctrl+")
    str := StrReplace(str, "!", "Alt+")
    str := StrReplace(str, "+", "Shift+")
    str := StrReplace(str, "#", "Win+")
    str := StrReplace(str, "del", "Del")
    return StrReplace(str, " ", "")  ; Remove any spaces
}

; =============================================================================
; MAIN SCRIPT
; =============================================================================
; Set working directory
SetWorkingDir A_ScriptDir

; Show notification on startup
TrayTip "System Shortcuts", "System shortcuts are active", "Iconi"
SetTimer () => TrayTip(), 3000

; =============================================================================
; POWER MANAGEMENT
; =============================================================================
; Lock Workstation
Hotkey POWER_LOCK, (*) => DllCall("LockWorkStation")

; Shutdown
Hotkey POWER_SHUTDOWN, (*) => Shutdown(1)  ; Shutdown (Power off)

; Restart
Hotkey POWER_RESTART, (*) => Shutdown(2)  ; Reboot

; Logoff
Hotkey POWER_LOGOFF, (*) => Shutdown(0)  ; Logoff

; Hibernate
Hotkey POWER_HIBERNATE, (*) => DllCall("PowrProf\SetSuspendState", "Int", 1, "Int", 0, "Int", 0)  ; Hibernate

; Sleep
Hotkey POWER_SLEEP, (*) => DllCall("PowrProf\SetSuspendState", "Int", 0, "Int", 0, "Int", 0)  ; Sleep

; =============================================================================
; SYSTEM TOGGLES
; =============================================================================
; Toggle Hidden Files
Hotkey TOGGLE_HIDDEN_FILES, ToggleHiddenFiles

; Toggle File Extensions
Hotkey TOGGLE_FILE_EXT, ToggleFileExtensions

; Taskbar Management
Hotkey TOGGLE_TASKBAR_AUTO_HIDE, ToggleTaskbarAutoHide
Hotkey FIX_TASKBAR, FixStuckTaskbar

; =============================================================================
; SYSTEM ACTIONS
; =============================================================================
; Empty Recycle Bin
Hotkey EMPTY_RECYCLE_BIN, EmptyRecycleBin

; Open System Properties
Hotkey OPEN_SYSTEM_PROPERTIES, OpenSystemProperties

; Open Task Manager
Hotkey OPEN_TASK_MANAGER, OpenTaskManager

; Open Device Manager
Hotkey OPEN_DEVICE_MANAGER, OpenDeviceManager

; Open Disk Cleanup
Hotkey OPEN_DISK_CLEANUP, OpenDiskCleanup

; =============================================================================
; FUNCTIONS
; =============================================================================
; Toggle Hidden Files
ToggleHiddenFiles(*) {
    try {
        ; Read current state
        HiddenFilesStatus := RegRead("HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced", "Hidden")
        
        ; Toggle the state
        if (HiddenFilesStatus = 2) {
            RegWrite "1", "REG_DWORD", "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced", "Hidden"
            ShowToolTip("Showing hidden files")
        } else {
            RegWrite "2", "REG_DWORD", "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced", "Hidden"
            ShowToolTip("Hiding hidden files")
        }
        
        ; Notify Explorer to refresh
        RefreshExplorer()
    } catch as e {
        ShowError("Failed to toggle hidden files", e)
    }
}

; Toggle File Extensions
ToggleFileExtensions(*) {
    try {
        ; Read current state
        FileExtStatus := RegRead("HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced", "HideFileExt")
        
        ; Toggle the state
        if (FileExtStatus = 1) {
            RegWrite "0", "REG_DWORD", "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced", "HideFileExt"
            ShowToolTip("Showing file extensions")
        } else {
            RegWrite "1", "REG_DWORD", "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced", "HideFileExt"
            ShowToolTip("Hiding file extensions")
        }
        
        ; Notify Explorer to refresh
        RefreshExplorer()
    } catch as e {
        ShowError("Failed to toggle file extensions", e)
    }
}

; Toggle Taskbar Auto-Hide
ToggleTaskbarAutoHide(*) {
    try {
        ; Read current state
        TaskbarAutoHide := RegRead("HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\StuckRects3\Settings", "")
        
        ; Toggle the auto-hide flag (bit 8 of the first byte)
        if (NumGet(TaskbarAutoHide, 8, "UChar") & 0x01) {
            ; Disable auto-hide
            NumPut "UChar", NumGet(TaskbarAutoHide, 8, "UChar") & ~0x01, TaskbarAutoHide, 8
            ShowToolTip("Taskbar: Auto-hide disabled")
        } else {
            ; Enable auto-hide
            NumPut "UChar", NumGet(TaskbarAutoHide, 8, "UChar") | 0x01, TaskbarAutoHide, 8
            ShowToolTip("Taskbar: Auto-hide enabled")
        }
        
        ; Write back the modified binary data
        RegWrite TaskbarAutoHide, "REG_BINARY", "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\StuckRects3", "Settings"
        
        ; Restart Explorer to apply changes
        RestartExplorer()
    } catch as e {
        ShowError("Failed to toggle taskbar auto-hide", e)
    }
}

; Empty Recycle Bin
EmptyRecycleBin(*) {
    if (MsgBox("Are you sure you want to empty the Recycle Bin?", "Empty Recycle Bin", "YesNo Icon!") = "Yes") {
        try {
            FileRecycleEmpty()
            ShowToolTip("Recycle Bin has been emptied")
        } catch as e {
            ShowError("Failed to empty Recycle Bin", e)
        }
    }
}

; Open System Properties
OpenSystemProperties(*) {
    try {
        Run "control.exe sysdm.cpl"
    } catch as e {
        ShowError("Failed to open System Properties", e)
    }
}

; Open Task Manager
OpenTaskManager(*) {
    try {
        Run "taskmgr.exe"
    } catch as e {
        ShowError("Failed to open Task Manager", e)
    }
}

; Open Device Manager
OpenDeviceManager(*) {
    try {
        Run "devmgmt.msc"
    } catch as e {
        ShowError("Failed to open Device Manager", e)
    }
}

; Open Disk Cleanup
OpenDiskCleanup(*) {
    try {
        Run "cleanmgr.exe"
    } catch as e {
        ShowError("Failed to open Disk Cleanup", e)
    }
}

; =============================================================================
; HELPER FUNCTIONS
; =============================================================================
; Refresh Explorer windows
RefreshExplorer() {
    ; Notify all Explorer windows to refresh
    for wnd in WinGetList("ahk_class CabinetWClass ahk_exe explorer.exe") {
        PostMessage(0x111, 0x1A3B, 0, , "ahk_id " wnd)  ; WM_COMMAND, ID: 6711 (0x1A37)
    }
    ; Also refresh the desktop
    PostMessage(0x111, 0x1A3B, 0, , "ahk_class Progman")
}

; Restart Windows Explorer
RestartExplorer(showNotification := true) {
    try {
        if (showNotification) {
            ShowToolTip("Restarting Explorer...")
        }
        
        ; Kill Explorer
        Run "taskkill /f /im explorer.exe", , "Hide"
        Sleep 1000
        
        ; Restart Explorer
        Run "explorer.exe"
        
        if (showNotification) {
            ShowToolTip("Explorer restarted successfully")
        }
        return true
    } catch as e {
        if (showNotification) {
            ShowError("Failed to restart Explorer", e)
        }
        return false
    }
}

; Fix stuck taskbar (when it refuses to auto-hide)
FixStuckTaskbar(*) {
    ShowToolTip("Attempting to fix stuck taskbar...")
    
    ; Method 1: Toggle auto-hide setting
    try {
        ; Get current taskbar state
        taskbarState := RegRead("HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\StuckRects3\Settings", "")
        if (taskbarState != "") {
            ; Toggle the auto-hide flag
            autoHideFlag := NumGet(taskbarState, 8, "UChar")
            NumPut("UChar", autoHideFlag ^ 0x01, taskbarState, 8)  ; Toggle the bit
            
            ; Write back the modified binary data
            RegWrite taskbarState, "REG_BINARY", "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\StuckRects3", "Settings"
        }
    } catch as e {
        ; Continue with other methods if this fails
    }
    
    ; Method 2: Restart the Windows Shell
    if (!RestartExplorer(false)) {
        ; If restarting Explorer failed, try alternative methods
        try {
            ; Method 3: Use taskkill to end explorer and let Windows restart it
            Run "taskkill /f /im explorer.exe", , "Hide"
            Sleep 2000
            Run "explorer.exe", , "Hide"
            
            ; Method 4: If still not working, try using PowerShell to reset the taskbar
            RunWait('powershell -NoProfile -Command "' 
                . '$ErrorActionPreference="Stop"; ' 
                . '$shell = New-Object -ComObject "Shell.Application"; ' 
                . '$shell.ToggleDesktop()"', , 'Hide')
                
            ; Method 5: As a last resort, reset the taskbar position completely
            try {
                RegDelete("HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\StuckRects3")
                RegDelete("HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\StuckRects2")
            }
            
            ; Final restart
            Run "explorer.exe", , "Hide"
            
        } catch as e {
            ShowError("Failed to fix taskbar automatically", e)
            return
        }
    }
    
    ; Reset taskbar position
    try {
        taskbarHwnd := WinExist("ahk_class Shell_TrayWnd")
        if (taskbarHwnd) {
            ; Force taskbar to update
            PostMessage(0x111, 0x1A3B, 0, , "ahk_id " taskbarHwnd)
            
            ; Toggle the taskbar to force a refresh
            WinHide "ahk_id " taskbarHwnd
            Sleep 100
            WinShow "ahk_id " taskbarHwnd
        }
    }
    
    ShowToolTip("Taskbar should be fixed now. If not, try pressing the hotkey again.")
}

; Show a tooltip message
ShowToolTip(message, duration := 2000) {
    ToolTip message
    SetTimer () => ToolTip(), -%duration%
}

; Show an error message
ShowError(message, error) {
    errorMsg := message "`n`nError: " error.Message
    if (error.Extra {
        errorMsg .= "`n" error.Extra
    }
    MsgBox(errorMsg, "Error", "Iconx")
}

; =============================================================================
; EXIT HANDLER
; =============================================================================
OnExit(ExitFunc)
ExitFunc(ExitReason, ExitCode) {
    ; Clean up any resources if needed
    return 0
}


