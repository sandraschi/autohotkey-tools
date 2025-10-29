#Requires AutoHotkey v2.0
#SingleInstance Force


; Suppress error popups - log to file instead
OnError(LogError)

LogError(Thrown, Mode) {
    FileAppend("Error: " . Thrown.Message . " at line " . Thrown.Line . "
", "errors.log", "UTF-8")`n        OutputDebug(errorMsg)  ; Enable LLM debugging
    return 1  ; Suppress popup (1 = suppress, 0 = show)
}

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
TrayTip "Quick Launch", "Quick launch hotkeys are active", "Iconi"
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
