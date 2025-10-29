#Requires AutoHotkey v2.0+
#SingleInstance Force

; ==============================================================================
; Window Management
; @name: Window Management
; @version: 1.0.0
; @description: Basic window management with snapping and organization. Simple window control with edge snapping and window switching.
; @description: Provides window snapping to screen edges, window switching, and basic window organization. Lightweight alternative to advanced window managers.
; @description: Essential productivity tool for users who want basic window management without complex features.
; @category: utilities
; @author: Sandra
; @hotkeys: (configurable)
; @enabled: true
; @priority: 30
; @tag: window-management, productivity, utilities, snapping, basic
; @cli: --snap <direction> - Snap active window (left, right, top, bottom)
; @cli: --help - Show CLI usage and window management options
; @dependencies: 
; ==============================================================================

; Error handling - log to file instead of showing popups
OnError(LogError)

LogError(Thrown, Mode) {
    errorMsg := "Error: " . Thrown.Message . " at line " . Thrown.Line . "`n" . Thrown.Stack
    FileAppend(errorMsg, "window_management_errors.log", "UTF-8")
    OutputDebug(errorMsg)  ; Enable LLM debugging
    return 1  ; Suppress popup (1 = suppress, 0 = show)
}

; =============================================================================
; CONFIGURATION
; =============================================================================
; Hotkeys
TOGGLE_ALWAYS_ON_TOP := "^!t"      ; Ctrl+Alt+T - Toggle always on top
CENTER_WINDOW := "^!c"             ; Ctrl+Alt+C - Center window
MOVE_TO_NEXT_MONITOR := "^!n"      ; Ctrl+Alt+N - Move to next monitor
TOGGLE_MAXIMIZE := "^!m"           ; Ctrl+Alt+M - Toggle maximize/restore
MINIMIZE_WINDOW := "^!Down"        ; Ctrl+Alt+Down - Minimize window
RESTORE_WINDOW := "^!Up"           ; Ctrl+Alt+Up - Restore window
CLOSE_WINDOW := "^!w"              ; Ctrl+Alt+W - Close window
TOGGLE_TRANSPARENCY := "^!+t"      ; Ctrl+Alt+Shift+T - Toggle transparency

; Snap hotkeys (Win + Arrow keys)
SNAP_LEFT := "#Left"               ; Win+Left - Snap to left half
SNAP_RIGHT := "#Right"             ; Win+Right - Snap to right half
SNAP_TOP := "#Up"                  ; Win+Up - Snap to top half
SNAP_BOTTOM := "#Down"             ; Win+Down - Snap to bottom half

; Quarter-snap hotkeys (Win+Shift+Arrow or Win+Ctrl+Arrow)
QUARTER_TOP_LEFT := "#^Left"       ; Win+Ctrl+Left - Top-left quarter
QUARTER_TOP_RIGHT := "#^Right"     ; Win+Ctrl+Right - Top-right quarter
QUARTER_BOTTOM_LEFT := "#+Left"    ; Win+Shift+Left - Bottom-left quarter
QUARTER_BOTTOM_RIGHT := "#+Right"  ; Win+Shift+Right - Bottom-right quarter
CENTER_WINDOW_KEY := "#c"          ; Win+C - Center window on screen

; Snap margin (pixels from edge to trigger snap)
SNAP_MARGIN := 20

; Default transparency level (0-255, where 255 is fully opaque)
DEFAULT_TRANSPARENCY := 200

; =============================================================================
; MAIN SCRIPT
; =============================================================================
; Set working directory
SetWorkingDir A_ScriptDir

; Register hotkeys
Hotkey TOGGLE_ALWAYS_ON_TOP, ToggleAlwaysOnTop
Hotkey CENTER_WINDOW, CenterWindow
Hotkey MOVE_TO_NEXT_MONITOR, MoveToNextMonitor
Hotkey TOGGLE_MAXIMIZE, ToggleMaximize
Hotkey MINIMIZE_WINDOW, MinimizeWindow
Hotkey RESTORE_WINDOW, RestoreWindow
Hotkey CLOSE_WINDOW, CloseWindow
Hotkey TOGGLE_TRANSPARENCY, ToggleTransparency

; Override Windows snap hotkeys for more control
Hotkey SNAP_LEFT, SnapLeft
Hotkey SNAP_RIGHT, SnapRight
Hotkey SNAP_TOP, SnapTop
Hotkey SNAP_BOTTOM, SnapBottom
Hotkey QUARTER_TOP_LEFT, SnapTopLeft
Hotkey QUARTER_TOP_RIGHT, SnapTopRight
Hotkey QUARTER_BOTTOM_LEFT, SnapBottomLeft
Hotkey QUARTER_BOTTOM_RIGHT, SnapBottomRight
Hotkey CENTER_WINDOW_KEY, SnapCenter

; Show notification on startup
TrayTip "Window Manager", "Window management hotkeys are active", "Iconi"
SetTimer () => TrayTip(), 3000

; =============================================================================
; WINDOW MANAGEMENT FUNCTIONS
; =============================================================================
; Toggle always on top for the active window
ToggleAlwaysOnTop(*) {
    hwnd := WinExist("A")
    if (!hwnd) {
        ShowToolTip("No active window found")
        return
    }
    
    ; Toggle the always on top state
    style := WinGetExStyle(hwnd)
    if (style & 0x8) {  ; 0x8 is WS_EX_TOPMOST
        WinSetAlwaysOnTop(false, hwnd)
        ShowToolTip("Window is no longer always on top")
    } else {
        WinSetAlwaysOnTop(true, hwnd)
        ShowToolTip("Window is now always on top")
    }
}

; Center the active window on the screen
CenterWindow(*) {
    hwnd := WinExist("A")
    if (!hwnd) {
        ShowToolTip("No active window found")
        return
    }
    
    ; Get window size and position
    WinGetPos(, , &width, &height, hwnd)
    
    ; Get the monitor the window is on
    monitor := GetMonitorFromWindow(hwnd)
    monInfo := GetMonitorInfo(monitor)
    
    ; Calculate center position
    xPos := monInfo.Left + (monInfo.Right - monInfo.Left - width) // 2
    yPos := monInfo.Top + (monInfo.Bottom - monInfo.Top - height) // 2
    
    ; Move the window
    WinMove(xPos, yPos, , , hwnd)
    ShowToolTip("Window centered on screen")
}

; Move window to next monitor
MoveToNextMonitor(*) {
    hwnd := WinExist("A")
    if (!hwnd) {
        ShowToolTip("No active window found")
        return
    }
    
    ; Get current monitor and window position
    currentMonitor := GetMonitorFromWindow(hwnd)
    WinGetPos(&x, &y, &width, &height, hwnd)
    
    ; Get all monitors
    monitors := GetMonitorCount()
    if (monitors <= 1) {
        ShowToolTip("Only one monitor detected")
        return
    }
    
    ; Find next monitor
    nextMonitor := (currentMonitor + 1) > monitors ? 1 : currentMonitor + 1
    
    ; Get next monitor info
    monInfo := GetMonitorInfo(nextMonitor)
    
    ; Calculate new position (center on new monitor)
    newX := monInfo.Left + (monInfo.Right - monInfo.Left - width) // 2
    newY := monInfo.Top + (monInfo.Bottom - monInfo.Top - height) // 2
    
    ; Move the window
    WinMove(newX, newY, , , hwnd)
    ShowToolTip("Moved to monitor " nextMonitor)
}

; Toggle window between maximized and normal state
ToggleMaximize(*) {
    hwnd := WinExist("A")
    if (!hwnd) {
        ShowToolTip("No active window found")
        return
    }
    
    if (WinGetMinMax(hwnd) = 1) {
        WinRestore(hwnd)
        ShowToolTip("Window restored")
    } else {
        WinMaximize(hwnd)
        ShowToolTip("Window maximized")
    }
}

; Minimize window
MinimizeWindow(*) {
    hwnd := WinExist("A")
    if (hwnd) {
        WinMinimize(hwnd)
    }
}

; Restore window
RestoreWindow(*) {
    hwnd := WinExist("A")
    if (hwnd) {
        if (WinGetMinMax(hwnd) = -1) {  ; Minimized
            WinRestore(hwnd)
        } else {
            WinMaximize(hwnd)
        }
    }
}

; Close window
CloseWindow(*) {
    hwnd := WinExist("A")
    if (hwnd) {
        WinClose(hwnd)
    }
}

; Toggle window transparency
ToggleTransparency(*) {
    static transparentWindows := Map()
    
    hwnd := WinExist("A")
    if (!hwnd) {
        ShowToolTip("No active window found")
        return
    }
    
    ; Toggle transparency
    if (transparentWindows.Has(hwnd)) {
        WinSetTransparent("OFF", hwnd)
        transparentWindows.Delete(hwnd)
        ShowToolTip("Window opacity restored")
    } else {
        WinSetTransparent(DEFAULT_TRANSPARENCY, hwnd)
        transparentWindows[hwnd] := true
        ShowToolTip("Window made " DEFAULT_TRANSPARENCY "% opaque")
    }
}

; =============================================================================
; SNAPPING FUNCTIONS
; =============================================================================
; Snap window to left half of the screen
SnapLeft(*) {
    if (GetKeyState("Shift", "P")) {
        SnapWindow("top-left")
    } else if (GetKeyState("Ctrl", "P")) {
        SnapWindow("bottom-left")
    } else {
        SnapWindow("left")
    }
}

; Snap window to right half of the screen
SnapRight(*) {
    if (GetKeyState("Shift", "P")) {
        SnapWindow("top-right")
    } else if (GetKeyState("Ctrl", "P")) {
        SnapWindow("bottom-right")
    } else {
        SnapWindow("right")
    }
}

; Snap window to top half of the screen
SnapTop(*) {
    if (GetKeyState("Shift", "P") || GetKeyState("Ctrl", "P")) {
        SnapWindow("top-left")
    } else {
        SnapWindow("top")
    }
}

; Snap window to bottom half of the screen
SnapBottom(*) {
    if (GetKeyState("Shift", "P") || GetKeyState("Ctrl", "P")) {
        SnapWindow("bottom-left")
    } else {
        SnapWindow("bottom")
    }
}

; Snap window to top-left quarter of the screen
SnapTopLeft(*) {
    SnapWindow("top-left")
}

; Snap window to top-right quarter of the screen
SnapTopRight(*) {
    SnapWindow("top-right")
}

; Snap window to bottom-left quarter of the screen
SnapBottomLeft(*) {
    SnapWindow("bottom-left")
}

; Snap window to bottom-right quarter of the screen
SnapBottomRight(*) {
    SnapWindow("bottom-right")
}

; Center window on screen
SnapCenter(*) {
    SnapWindow("center")
}

; Snap window to the specified position with enhanced options
SnapWindow(position) {
    hwnd := WinExist("A")
    if (!hwnd) {
        return
    }
    
    ; Get monitor info
    monitor := GetMonitorFromWindow(hwnd)
    monInfo := GetMonitorInfo(monitor)
    
    ; Get window style to check if it's maximized
    style := WinGetStyle(hwnd)
    wasMaximized := style & 0x1000000  ; WS_MAXIMIZE
    
    ; Restore window if it was maximized
    if (wasMaximized) {
        WinRestore(hwnd)
    }
    
    ; Calculate dimensions
    monWidth := monInfo.Right - monInfo.Left
    monHeight := monInfo.Bottom - monInfo.Top
    
    ; Position window based on snap position
    switch position {
        case "left":
            x := monInfo.Left
            y := monInfo.Top
            w := monWidth // 2
            h := monHeight
        case "right":
            x := monInfo.Left + (monWidth // 2)
            y := monInfo.Top
            w := monWidth // 2
            h := monHeight
        case "top":
            x := monInfo.Left
            y := monInfo.Top
            w := monWidth
            h := monHeight // 2
        case "bottom":
            x := monInfo.Left
            y := monInfo.Top + (monHeight // 2)
            w := monWidth
            h := monHeight // 2
        case "top-left":
            x := monInfo.Left
            y := monInfo.Top
            w := monWidth // 2
            h := monHeight // 2
        case "top-right":
            x := monInfo.Left + (monWidth // 2)
            y := monInfo.Top
            w := monWidth // 2
            h := monHeight // 2
        case "bottom-left":
            x := monInfo.Left
            y := monInfo.Top + (monHeight // 2)
            w := monWidth // 2
            h := monHeight // 2
        case "bottom-right":
            x := monInfo.Left + (monWidth // 2)
            y := monInfo.Top + (monHeight // 2)
            w := monWidth // 2
            h := monHeight // 2
        case "center":
            WinGetPos(, , &width, &height, hwnd)
            x := monInfo.Left + ((monWidth - width) // 2)
            y := monInfo.Top + ((monHeight - height) // 2)
            w := width
            h := height
        default:
            return
    }
    
    ; Move and size the window with animation
    AnimateWindowMove(hwnd, x, y, w, h)
    ShowToolTip("Window snapped to " position)
}

; =============================================================================
; HELPER FUNCTIONS
; =============================================================================
; Animate window movement
AnimateWindowMove(hwnd, targetX, targetY, targetW, targetH) {
    ; Get current window position and size
    WinGetPos(&currentX, &currentY, &currentW, &currentH, hwnd)
    
    ; Calculate steps for animation
    steps := 10
    stepX := (targetX - currentX) / steps
    stepY := (targetY - currentY) / steps
    stepW := (targetW - currentW) / steps
    stepH := (targetH - currentH) / steps
    
    ; Animate the movement
    Loop steps {
        currentX += stepX
        currentY += stepY
        currentW += stepW
        currentH += stepH
        WinMove(Round(currentX), Round(currentY), Round(currentW), Round(currentH), hwnd)
        Sleep 10
    }
    
    ; Ensure final position is exact
    WinMove(targetX, targetY, targetW, targetH, hwnd)
}

; Show a tooltip message
ShowToolTip(message, duration := 2000) {
    ToolTip(message)
    SetTimer(() => ToolTip(), -duration)
}

; Get monitor index that contains the specified window
GetMonitorFromWindow(hwnd) {
    ; Get window position
    WinGetPos(&x, &y, , , hwnd)
    
    ; Get monitor that contains the window
    monitor := 0
    SysGet(&monitorCount, 80)  ; SM_CMONITORS
    
    Loop monitorCount {
        SysGet(&monitorInfo, 0, A_Index)  ; SM_MONITORINFO
        if (x >= monitorInfo.Left && x < monitorInfo.Right && 
            y >= monitorInfo.Top && y < monitorInfo.Bottom) {
            monitor := A_Index
            break
        }
    }
    
    return monitor ? monitor : 1  ; Default to primary monitor
}

; Get information about a monitor
GetMonitorInfo(monitorNum) {
    static MONITOR_DEFAULTTONEAREST := 0x00000002
    static MONITORINFOEX_SIZE := 104  ; Size of MONITORINFOEX structure
    
    ; Get monitor handle
    hMonitor := DllCall("MonitorFromPoint", "int64", 0, "uint", MONITOR_DEFAULTTONEAREST)
    
    ; Get monitor info
    VarSetStrCapacity(&monitorInfo, MONITORINFOEX_SIZE)
    NumPut("uint", MONITORINFOEX_SIZE, monitorInfo, 0)
    
    if (DllCall("GetMonitorInfo", "ptr", hMonitor, "ptr", &monitorInfo)) {
        return {
            Left: NumGet(monitorInfo, 4, "int"),
            Top: NumGet(monitorInfo, 8, "int"),
            Right: NumGet(monitorInfo, 12, "int"),
            Bottom: NumGet(monitorInfo, 16, "int"),
            WorkLeft: NumGet(monitorInfo, 20, "int"),
            WorkTop: NumGet(monitorInfo, 24, "int"),
            WorkRight: NumGet(monitorInfo, 28, "int"),
            WorkBottom: NumGet(monitorInfo, 32, "int"),
            Flags: NumGet(monitorInfo, 36, "uint"),
            Name: StrGet(&monitorInfo + 40, 32)
        }
    }
    
    ; Return primary monitor info if we couldn't get the specific monitor
    return {
        Left: 0,
        Top: 0,
        Right: A_ScreenWidth,
        Bottom: A_ScreenHeight,
        WorkLeft: 0,
        WorkTop: 0,
        WorkRight: A_ScreenWidth,
        WorkBottom: A_ScreenHeight,
        Flags: 1,  ; Primary monitor
        Name: "\\\.\DISPLAY1"
    }
}

; Get the number of monitors
GetMonitorCount() {
    SysGet(&count, 80)  ; SM_CMONITORS
    return count
}

; =============================================================================
; EXIT HANDLER
; =============================================================================
OnExit(ExitFunc)
ExitFunc(ExitReason, ExitCode) {
    ; Clean up any resources if needed
    return 0
}
