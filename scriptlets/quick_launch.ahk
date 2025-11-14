#Requires AutoHotkey v2.0+
#SingleInstance Force
#Include %A_ScriptDir%\lib\ScriptletErrorHandler.ahk

; ==============================================================================
; Quick Launch
; @name: Quick Launch
; @version: 1.0.0
; @description: Fast application and folder launcher with customizable hotkeys. Launch applications and open folders instantly with simple keyboard shortcuts.
; @description: Provides configurable application shortcuts (Win+Key), folder shortcuts (Ctrl+Alt+Key), and system tools shortcuts (Win+Shift+Key). Easy to customize for your specific applications and workflows.
; @description: Essential productivity tool for quick access to frequently used applications and folders without navigating menus or desktop icons.
; @category: utilities
; @author: Sandra
; @hotkeys: (configurable - see CONFIGURATION section)
; @enabled: true
; @priority: 25
; @tag: launcher, shortcuts, applications, folders, productivity, utilities, quick-access
; @cli: --add-app <key> <path> - Add application shortcut
; @cli: --add-folder <key> <path> - Add folder shortcut
; @cli: --list - List all configured shortcuts
; @cli: --help - Show CLI usage and launcher options
; @dependencies: 
; ==============================================================================

; Error handling - log to file instead of showing popups
OnError(LogError)

#Warn

; =============================================================================
; CONFIGURATION - EDIT THESE TO MATCH YOUR SYSTEM
; =============================================================================
; Application Shortcuts (Win+Key)
APPS := Map(
    "#n", "notepad.exe",
    "#c", "calc.exe",
    "#e", "explorer.exe",
    "#f", "C:\Program Files\Mozilla Firefox\firefox.exe",
    "#v", A_AppData "\Local\Programs\Microsoft VS Code\Code.exe",
    "#b", "msedge.exe",
    "#t", "wt.exe"
)

; Folder Shortcuts (Ctrl+Alt+Key)
FOLDERS := Map(
    "^!d", A_MyDocuments,
    "^!D", A_MyDocuments "\..\Downloads",
    "^!p", A_MyPictures,
    "^!m", A_MyMusic,
    "^!v", A_MyVideos,
    "^!s", A_MyPictures "\Screenshots"
)

; System Tools (Win+Shift+Key)
TOOLS := Map(
    "#+d", "devmgmt.msc",
    "#+e", "eventvwr.msc",
    "#+m", "compmgmt.msc",
    "#+t", "taskmgr"
)

; =============================================================================
; MAIN SCRIPT - NO NEED TO EDIT BELOW THIS LINE
; =============================================================================
; Set working directory
SetWorkingDir A_ScriptDir

; Register hotkeys
for hotkey, target in APPS {
    Hotkey hotkey, (*) => RunTarget(target)
}

for hotkey, folder in FOLDERS {
    Hotkey hotkey, (*) => OpenFolder(folder)
}

for hotkey, tool in TOOLS {
    Hotkey hotkey, (*) => RunTarget(tool)
}

; Show notification on startup
TrayTip "Quick Launch", "Quick launch hotkeys are active"
SetTimer () => TrayTip(), 3000

; =============================================================================
; FUNCTIONS
; =============================================================================
; Run a target (app or tool)
RunTarget(target) {
    try {
        Run target
        ShowTooltip("Launched: " target)
    } catch as e {
        ShowTooltip("Failed to launch: " e.Message, true)
    }
}

; Open a folder
OpenFolder(path) {
    try {
        Run "explorer.exe " path
        ShowTooltip("Opened: " path)
    } catch as e {
        ShowTooltip("Failed to open folder: " e.Message, true)
    }
}

; Show a tooltip message
ShowTooltip(message, isError := false) {
    Tooltip(message)
    SetTimer(() => Tooltip(), -2000)
}

; Clean up on exit
OnExit(ExitFunc)
ExitFunc(ExitReason, ExitCode) {
    return 0
}
