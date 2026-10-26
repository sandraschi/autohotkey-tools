#Requires AutoHotkey v2.0+
#SingleInstance Force

; === Guard: catch parse-time errors (BEFORE any class/func/global) ===
_CatchBootError(Thrown, Mode) {
    msg := Thrown && HasProp(Thrown, "Message") ? Thrown.Message : "Unknown"
    fPath := Thrown && HasProp(Thrown, "File") ? Thrown.File : A_ScriptFullPath
    line := Thrown && HasProp(Thrown, "Line") ? Thrown.Line : "?"
    try FileAppend("[" A_Now "] " fPath ":" line " - " msg "`n", A_ScriptDir "\crash.log")
    return 1
}
OnError(_CatchBootError)

; ==============================================================================
; @name: iPad Scroll Widget
; @version: 1.3.1
; @description: Slim vertical touch widget: PgUp, Up, Down, PgDn, Top, End, Menu.
; @description: Split transparency - frame keyed out, buttons stay opaque at
; @description: WIDGET_ALPHA. Wheel mode posts WM_MOUSEWHEEL, Key mode sends keys.
; @description: Top/End activate target then Send (TUIs drop unfocused ControlSend).
; @description: Auto-hides when OpenCode not active. Settings in scroll_widget.ini.
; @category: utilities
; @author: Sandra
; @hotkeys: ^!s toggle  ^!w pick target  ^!m snap  ^!k wheel/key  ^!a autohide
; @tag: scroll, ipad, rustdesk, opencode, terminal, widget, games, touch, a11y
; ==============================================================================

; Why this exists: the OpenCode TUI scrollbar is a few px wide - near-invisible
; and unhittable over RustDesk + iPad touch. This gives 7 fat touch targets
; that post wheel deltas instead of dragging the thin bar.

; Config (touch-sized for RustDesk/iPad - 44px was too small to hit reliably)
; v1.2.1: narrowed to 48px, muted palette for lower contrast over dark TUIs.
; v1.3.0: split transparency - TRANSKEY frame keyed out, buttons at WIDGET_ALPHA.
global WIDGET_W := 48
global WIDGET_H := 236
global BTN_W := 36
global BTN_H := 26
global GAP := 3
global PAD := 6
global WIDGET_ALPHA := 100
global TRANSKEY := "FF00FF"
; Top/End keystrokes - overridable via scroll_widget.ini [widget] top_keys/end_keys.
; Defaults suit most TUIs; if OpenCode rebinds, change INI, no recompile.
global TOP_KEYS := "^{Home}"
global END_KEYS := "^{End}"

; Paths - derived, never hardcoded. Override dashboard via env AHK_DASHBOARD_URL.
global DEPOT := A_ScriptDir
global DASHBOARD_URL := EnvGet("AHK_DASHBOARD_URL")
if (DASHBOARD_URL = "") {
    DASHBOARD_URL := "http://127.0.0.1:10764/dashboard"
}

; State
global targetHwnd := 0
global targetName := ""
global MyGui := 0
global TargetLbl := 0
global widgetVisible := true
global ScrollMode := "wheel"
global AutoHide := true
global autoHidden := false
global SETTINGS_FILE := A_ScriptDir "\scroll_widget.ini"

; ==============================================================================
; Startup
; ==============================================================================
SetWorkingDir(A_ScriptDir)

LoadSettings()
targetHwnd := DetectTerminal()
if (targetHwnd) {
    targetName := WinGetProcessName("ahk_id " targetHwnd)
    OutputDebug("[scroll-widget] target: " WinGetTitle("ahk_id " targetHwnd))
}

BuildWidget()
Hotkey("^!s", ToggleWidget)
Hotkey("^!w", PickTarget)
Hotkey("^!m", SnapToTarget)
Hotkey("^!k", ToggleScrollMode)
Hotkey("^!a", ToggleAutoHide)
SetTimer(AutoHideTick, 500)
OnExit(SaveOnExit)

; ==============================================================================
; Functions
; ==============================================================================

DetectTerminal() {
    ; Prefer OpenCode strictly - it is the primary scroll target.
    hwnd := WinExist("ahk_exe opencode.exe")
    if (hwnd) {
        return hwnd
    }
    for _, exe in ["terminal.exe", "pwsh.exe", "cmd.exe", "conhost.exe", "WindowsTerminal.exe"] {
        hwnd := WinExist("ahk_exe " exe)
        if (hwnd) {
            return hwnd
        }
    }
    return 0
}

LoadSettings() {
    global ScrollMode, AutoHide, WIDGET_ALPHA, TOP_KEYS, END_KEYS, SETTINGS_FILE
    try {
        m := IniRead(SETTINGS_FILE, "widget", "mode", "wheel")
        if (m = "keys" || m = "wheel") {
            ScrollMode := m
        }
        AutoHide := IniRead(SETTINGS_FILE, "widget", "autohide", 1) != 0
        WIDGET_ALPHA := Integer(IniRead(SETTINGS_FILE, "widget", "alpha", WIDGET_ALPHA))
        if (WIDGET_ALPHA < 40 || WIDGET_ALPHA > 255) {
            WIDGET_ALPHA := 100
        }
        TOP_KEYS := IniRead(SETTINGS_FILE, "widget", "top_keys", TOP_KEYS)
        END_KEYS := IniRead(SETTINGS_FILE, "widget", "end_keys", END_KEYS)
    } catch {
        ; Defaults stand on first run / corrupt INI.
    }
}

SaveSettings() {
    global ScrollMode, AutoHide, WIDGET_ALPHA, TOP_KEYS, END_KEYS, MyGui, SETTINGS_FILE
    try {
        if (MyGui) {
            try {
                MyGui.GetPos(&sx, &sy)
                IniWrite(sx, SETTINGS_FILE, "widget", "x")
                IniWrite(sy, SETTINGS_FILE, "widget", "y")
            } catch {
                ; Headless / never shown - skip position.
            }
        }
        IniWrite(ScrollMode, SETTINGS_FILE, "widget", "mode")
        IniWrite(AutoHide ? 1 : 0, SETTINGS_FILE, "widget", "autohide")
        IniWrite(WIDGET_ALPHA, SETTINGS_FILE, "widget", "alpha")
        IniWrite(TOP_KEYS, SETTINGS_FILE, "widget", "top_keys")
        IniWrite(END_KEYS, SETTINGS_FILE, "widget", "end_keys")
    } catch as e {
        OutputDebug("[scroll-widget] save failed: " e.Message)
    }
}

SaveOnExit(*) {
    SaveSettings()
}

BuildWidget() {
    global MyGui, TargetLbl, SETTINGS_FILE, TRANSKEY
    MyGui := Gui("+AlwaysOnTop +ToolWindow -Caption +Border", "Scroll")
    MyGui.BackColor := TRANSKEY
    MyGui.SetFont("s8 c8a8fa3", "Segoe UI")

    x := A_ScreenWidth - WIDGET_W - 20
    y := (A_ScreenHeight - WIDGET_H) // 2
    try {
        x := IniRead(SETTINGS_FILE, "widget", "x", x)
        y := IniRead(SETTINGS_FILE, "widget", "y", y)
    } catch {
    }

    ; Drag handle - borderless GUI cannot be moved otherwise.
    ; Click-drag this label to reposition; double-click snaps to target.
    drag := MyGui.Add("Text", "x" PAD " y" PAD " w" BTN_W " h16 Center Background1e1e2e cGray", "= drag =")
    drag.OnEvent("Click", (*) => SnapToTarget())

    r0 := PAD + 18
    r1 := r0 + BTN_H + GAP
    r2 := r1 + BTN_H + GAP
    r3 := r2 + BTN_H + GAP
    r4 := r3 + BTN_H + GAP
    r5 := r4 + BTN_H + GAP
    r6 := r5 + BTN_H + GAP

    b1 := MyGui.Add("Button", "x" PAD " y" r0 " w" BTN_W " h" BTN_H " Background232433", Chr(0x25B2))
    b2 := MyGui.Add("Button", "x" PAD " y" r1 " w" BTN_W " h" BTN_H " Background232433", Chr(0x25B3))
    b3 := MyGui.Add("Button", "x" PAD " y" r2 " w" BTN_W " h" BTN_H " Background232433", Chr(0x25BD))
    b4 := MyGui.Add("Button", "x" PAD " y" r3 " w" BTN_W " h" BTN_H " Background232433", Chr(0x25BC))
    b5 := MyGui.Add("Button", "x" PAD " y" r4 " w" BTN_W " h" BTN_H " Background232433", "Top")
    b6 := MyGui.Add("Button", "x" PAD " y" r5 " w" BTN_W " h" BTN_H " Background232433", "End")
    b7 := MyGui.Add("Button", "x" PAD " y" r6 " w" BTN_W " h" BTN_H " Background233026", "Menu")

    b1.ToolTip := "Page Up"
    b2.ToolTip := "Line Up"
    b3.ToolTip := "Line Down"
    b4.ToolTip := "Page Down"
    b5.ToolTip := "Top - activates target then sends (" TOP_KEYS ")"
    b6.ToolTip := "End - activates target then sends (" END_KEYS ")"
    b7.ToolTip := "Open AHK dashboard"

    b1.OnEvent("Click", (*) => ScrollWheel("PgUp"))
    b2.OnEvent("Click", (*) => ScrollWheel("Up"))
    b3.OnEvent("Click", (*) => ScrollWheel("Down"))
    b4.OnEvent("Click", (*) => ScrollWheel("PgDn"))
    b5.OnEvent("Click", (*) => SendKey(TOP_KEYS))
    b6.OnEvent("Click", (*) => SendKey(END_KEYS))
    b7.OnEvent("Click", (*) => OpenDashboard())

    ; Click target label toggles wheel/key mode - fat enough for touch.
    TargetLbl := MyGui.Add("Text", "x" PAD " y" r6 + BTN_H + GAP " w" BTN_W " h16 Center cGray", "")
    TargetLbl.ToolTip := "Click toggles wheel/key mode (^!k)"
    TargetLbl.OnEvent("Click", (*) => ToggleScrollMode())
    UpdateTargetLabel()

    MyGui.Show(Format("x{1} y{2} w{3} h{4} NoActivate", x, y, WIDGET_W, WIDGET_H))
    ApplyAlpha()
    RefreshVisibility()
}

ApplyAlpha() {
    ; Split transparency: TRANSKEY gaps fully see-through, buttons at WIDGET_ALPHA.
    global MyGui, WIDGET_ALPHA
    try {
        MyGui.Opt("+E0x80000")
        ; COLORREF for FF00FF is 0x00FF00FF (R=FF G=00 B=FF).
        DllCall("SetLayeredWindowAttributes", "Ptr", MyGui.Hwnd, "UInt", 0x00FF00FF, "UChar", WIDGET_ALPHA, "UInt", 0x3)
    } catch {
        ; Transparency unsupported - widget stays opaque.
    }
}

ModeSuffix() {
    global ScrollMode
    return (ScrollMode = "keys") ? " [K]" : " [W]"
}

UpdateTargetLabel() {
    global TargetLbl, targetName, targetHwnd
    if (!TargetLbl) {
        return
    }
    try {
        if (targetHwnd && WinExist("ahk_id " targetHwnd)) {
            targetName := WinGetProcessName("ahk_id " targetHwnd)
            TargetLbl.Value := SubStr(targetName, 1, 9) ModeSuffix()
        } else {
            TargetLbl.Value := "(none)" ModeSuffix()
        }
    } catch {
        TargetLbl.Value := "(none)" ModeSuffix()
    }
}

ToggleScrollMode(*) {
    global ScrollMode
    ScrollMode := (ScrollMode = "keys") ? "wheel" : "keys"
    SaveSettings()
    UpdateTargetLabel()
    ShowToast("Scroll mode: " ScrollMode)
}

ToggleAutoHide(*) {
    global AutoHide
    AutoHide := !AutoHide
    SaveSettings()
    RefreshVisibility()
    ShowToast(AutoHide ? "Autohide on" : "Autohide off")
}

IsTargetActive() {
    global targetHwnd
    if (WinActive("ahk_exe opencode.exe")) {
        return true
    }
    if (targetHwnd && WinExist("ahk_id " targetHwnd)) {
        return WinActive("ahk_id " targetHwnd) != 0
    }
    return false
}

RefreshVisibility() {
    global MyGui, widgetVisible, AutoHide, autoHidden
    if (!MyGui) {
        return
    }
    want := widgetVisible
    if (want && AutoHide) {
        want := IsTargetActive()
    }
    if (want) {
        if (autoHidden || !WinExist(MyGui.Hwnd)) {
            try MyGui.Show("NoActivate")
        }
        autoHidden := false
        ApplyAlpha()
    } else {
        if (widgetVisible) {
            ; User wants it visible but autohide says hide - soft hide.
            try MyGui.Hide()
            autoHidden := true
        }
    }
}

AutoHideTick() {
    RefreshVisibility()
}

; --- Scroll: wheel posts WM_MOUSEWHEEL, keys ControlSend PgUp/PgDn ---
ScrollWheel(keyName) {
    global targetHwnd, ScrollMode
    if (!targetHwnd || !WinExist("ahk_id " targetHwnd)) {
        targetHwnd := DetectTerminal()
        UpdateTargetLabel()
    }
    if (!targetHwnd) {
        ShowToast("No scroll target - WinExist found nothing. Press ^!w over target.")
        return
    }
    if (ScrollMode = "keys") {
        switch keyName {
            case "PgUp": SendKey("{PgUp}")
            case "PgDn": SendKey("{PgDn}")
            case "Up": SendKey("{Up}")
            case "Down": SendKey("{Down}")
            default: return
        }
        return
    }
    try {
        WinGetPos(&wx, &wy, &ww, &wh, "ahk_id " targetHwnd)
    } catch {
        ShowToast("Target lost - pick again with ^!w")
        targetHwnd := 0
        UpdateTargetLabel()
        return
    }
    cx := wx + ww // 2
    cy := wy + wh // 2
    lParam := (cy << 16) | (cx & 0xFFFF)

    switch keyName {
        case "PgUp": delta := 360
        case "Up": delta := 120
        case "Down": delta := -120
        case "PgDn": delta := -360
        default: return
    }
    wParam := delta << 16
    try {
        PostMessage(0x020A, wParam, lParam, , "ahk_id " targetHwnd)
    } catch as e {
        ShowToast("Scroll post failed: " e.Message)
    }
}

; --- Send keyboard combo: activate target first, then Send ---
; Clicking a widget button focuses the widget, so a focusless ControlSend
; to a TUI top-level window silently drops. Explicit tap = explicit intent,
; so activating the target here is correct (unlike background automation).
SendKey(keys) {
    global targetHwnd
    if (!targetHwnd || !WinExist("ahk_id " targetHwnd)) {
        targetHwnd := DetectTerminal()
        UpdateTargetLabel()
    }
    if (!targetHwnd) {
        ShowToast("No target - press ^!w over OpenCode first")
        return
    }
    try {
        WinActivate("ahk_id " targetHwnd)
        if (!WinWaitActive("ahk_id " targetHwnd, , 1)) {
            ShowToast("Target won't focus - press ^!w over OpenCode")
            return
        }
        Sleep(50)
        Send(keys)
    } catch as e {
        ShowToast("Send failed: " e.Message)
    }
}

; --- Open AHK dashboard ---
OpenDashboard() {
    try {
        Run(DASHBOARD_URL)
    } catch as e {
        ShowToast("Can't open: " e.Message)
    }
}

; --- Pick target window under cursor (A) ---
PickTarget(*) {
    global targetHwnd, targetName
    hwnd := WinExist("A")
    if (!hwnd) {
        return
    }
    targetHwnd := hwnd
    try {
        title := WinGetTitle("ahk_id " hwnd)
        targetName := WinGetProcessName("ahk_id " hwnd)
        ShowToast("Scroll target: " SubStr(title, 1, 40))
    } catch {
        ShowToast("Scroll target set")
    }
    UpdateTargetLabel()
    RefreshVisibility()
}

; --- Snap widget to right edge of current target ---
SnapToTarget(*) {
    global targetHwnd, MyGui, widgetVisible
    if (!targetHwnd || !WinExist("ahk_id " targetHwnd)) {
        targetHwnd := DetectTerminal()
        UpdateTargetLabel()
    }
    if (!targetHwnd) {
        ShowToast("No target to snap to")
        return
    }
    try {
        WinGetPos(&wx, &wy, &ww, &wh, "ahk_id " targetHwnd)
        bx := wx + ww - WIDGET_W - 8
        by := wy + (wh - WIDGET_H) // 2
        ; Keep on-screen on small / scaled displays, clear tab strip.
        if (by < wy + 8) {
            by := wy + 8
        }
        if (bx < 0) {
            bx := 0
        }
        if (by + WIDGET_H > A_ScreenHeight) {
            by := A_ScreenHeight - WIDGET_H - 8
        }
        MyGui.Move(bx, by)
        if (!widgetVisible) {
            widgetVisible := true
        }
        RefreshVisibility()
        SaveSettings()
    } catch as e {
        ShowToast("Snap failed: " e.Message)
    }
}

; --- Toggle widget visibility (user intent; autohide may soft-hide) ---
ToggleWidget(*) {
    global widgetVisible, MyGui
    widgetVisible := !widgetVisible
    RefreshVisibility()
    SaveSettings()
}

; --- Toast notification ---
ShowToast(msg) {
    ToolTip(msg)
    SetTimer(() => ToolTip(), -2000)
}

; --- Error logging (overrides boot guard after parse completes) ---
LogError(exception, mode) {
    msg := exception && HasProp(exception, "Message") ? exception.Message : "Unknown"
    fPath := exception && HasProp(exception, "File") ? exception.File : A_ScriptFullPath
    line := exception && HasProp(exception, "Line") ? exception.Line : "?"
    try FileAppend("[" A_Now "] " fPath ":" line " - " msg "`n", A_ScriptDir "\scroll_widget.log")
    return 1
}
OnError(LogError)
