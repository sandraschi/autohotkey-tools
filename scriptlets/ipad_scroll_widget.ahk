#Requires AutoHotkey v2.0+
#SingleInstance Force

; === Guard: catch parse-time errors (BEFORE any class/func/global) ===
_CatchBootError(Thrown, Mode) {
    msg := Thrown && HasProp(Thrown, "Message") ? Thrown.Message : "Unknown"
    fPath := Thrown && HasProp(Thrown, "File") ? Thrown.File : A_ScriptFullPath
    line := Thrown && HasProp(Thrown, "Line") ? Thrown.Line : "?"
    try FileAppend("[" A_Now "] " fPath ":" line " — " msg "`n", A_ScriptDir "\crash.log")
    return 1
}
OnError(_CatchBootError)

; ==============================================================================
; @name: iPad Scroll Widget
; @version: 1.0.0
; @description: Slim vertical widget: PgUp, Up, Down, PgDn, Top, End, Play.
; @description: Top/End use keyboard, scroll uses PostMessage. Play launches
; @description: sudoku from the AHK scriptlet depot.
; @category: utilities
; @author: Sandra
; @hotkeys: ^!s toggle  ^!w pick target
; @tag: scroll, ipad, rustdesk, opencode, terminal, widget, games
; ==============================================================================

; Config
WIDGET_W := 44
WIDGET_H := 162
BTN_W := 36
BTN_H := 20
GAP := 2
PAD := 4

; Paths
global DEPOT := "D:\Dev\repos\autohotkey-test\scriptlets"
global DASHBOARD_URL := "http://127.0.0.1:10744/dashboard"

; State
targetHwnd := 0
MyGui := 0
widgetVisible := true

; ==============================================================================
; Startup
; ==============================================================================
SetWorkingDir(A_ScriptDir)

targetHwnd := DetectTerminal()
if targetHwnd {
    OutputDebug("[scroll-widget] target: " WinGetTitle("ahk_id " targetHwnd))
}

BuildWidget()
Hotkey("^!s", ToggleWidget)
Hotkey("^!w", PickTarget)

; ==============================================================================
; Functions
; ==============================================================================

DetectTerminal() {
    for _, exe in ["opencode.exe", "terminal.exe", "pwsh.exe", "cmd.exe", "conhost.exe"] {
        hwnd := WinExist("ahk_exe " exe)
        if hwnd {
            return hwnd
        }
    }
    return WinExist("A")
}

BuildWidget() {
    global MyGui
    MyGui := Gui("+AlwaysOnTop +ToolWindow -Caption +Border", "Scroll")
    MyGui.BackColor := "131320"
    MyGui.SetFont("s8 cWhite Bold", "Segoe UI")

    x := A_ScreenWidth - WIDGET_W - 20
    y := A_ScreenHeight - WIDGET_H - 86

    r0 := PAD
    r1 := PAD + BTN_H + GAP
    r2 := r1   + BTN_H + GAP
    r3 := r2   + BTN_H + GAP
    r4 := r3   + BTN_H + GAP
    r5 := r4   + BTN_H + GAP
    r6 := r5   + BTN_H + GAP

    b1 := MyGui.Add("Button", "x" PAD " y" r0 " w" BTN_W " h" BTN_H " Background2d2d44", Chr(0x25B2))
    b2 := MyGui.Add("Button", "x" PAD " y" r1 " w" BTN_W " h" BTN_H " Background2d2d44", Chr(0x25B3))
    b3 := MyGui.Add("Button", "x" PAD " y" r2 " w" BTN_W " h" BTN_H " Background2d2d44", Chr(0x25BD))
    b4 := MyGui.Add("Button", "x" PAD " y" r3 " w" BTN_W " h" BTN_H " Background2d2d44", Chr(0x25BC))
    b5 := MyGui.Add("Button", "x" PAD " y" r4 " w" BTN_W " h" BTN_H " Background2d2d44", "Top")
    b6 := MyGui.Add("Button", "x" PAD " y" r5 " w" BTN_W " h" BTN_H " Background2d2d44", "End")
    b7 := MyGui.Add("Button", "x" PAD " y" r6 " w" BTN_W " h" BTN_H " Background1a3a1a", "Menu")

    b1.OnEvent("Click", (*) => ScrollWheel("PgUp"))
    b2.OnEvent("Click", (*) => ScrollWheel("Up"))
    b3.OnEvent("Click", (*) => ScrollWheel("Down"))
    b4.OnEvent("Click", (*) => ScrollWheel("PgDn"))
    b5.OnEvent("Click", (*) => SendKey("^{Home}"))
    b6.OnEvent("Click", (*) => SendKey("^{End}"))
    b7.OnEvent("Click", (*) => OpenDashboard())

    MyGui.Show("x" x " y" y " w" WIDGET_W " h" WIDGET_H " NoActivate")
}

; --- Scroll via mouse wheel ---
ScrollWheel(keyName) {
    global targetHwnd
    if !targetHwnd || !WinExist("ahk_id " targetHwnd) {
        targetHwnd := DetectTerminal()
    }
    if !targetHwnd {
        return
    }
    WinGetPos(&wx, &wy, &ww, &wh, "ahk_id " targetHwnd)
    cx := wx + ww // 2
    cy := wy + wh // 2
    lParam := (cy << 16) | (cx & 0xFFFF)

    switch keyName {
        case "PgUp":  delta := 360
        case "Up":    delta := 120
        case "Down":  delta := -120
        case "PgDn":  delta := -360
        default:      return
    }
    wParam := delta << 16
    PostMessage(0x020A, wParam, lParam, , "ahk_id " targetHwnd)
}

; --- Send keyboard combo (Top/End) ---
SendKey(keys) {
    global targetHwnd
    if !targetHwnd || !WinExist("ahk_id " targetHwnd) {
        targetHwnd := DetectTerminal()
    }
    if !targetHwnd {
        return
    }
    WinActivate("ahk_id " targetHwnd)
    Send(keys)
}

; --- Open AHK dashboard ---
OpenDashboard() {
    try {
        Run(DASHBOARD_URL)
    } catch as e {
        ShowToast("Can't open: " e.Message)
    }
}

; --- Pick target window ---
PickTarget(*) {
    global targetHwnd
    hwnd := WinExist("A")
    if !hwnd {
        return
    }
    targetHwnd := hwnd
    title := WinGetTitle("ahk_id " hwnd)
    ShowToast("Scroll target: " SubStr(title, 1, 40))
}

; --- Toggle widget visibility ---
ToggleWidget(*) {
    global widgetVisible, MyGui
    widgetVisible := !widgetVisible
    if widgetVisible {
        MyGui.Show("NoActivate")
    } else {
        MyGui.Hide()
    }
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
    try FileAppend("[" A_Now "] " fPath ":" line " — " msg "`n", A_ScriptDir "\scroll_widget.log")
    return 1
}
OnError(LogError)
