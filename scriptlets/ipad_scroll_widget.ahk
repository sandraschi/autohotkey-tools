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
; @version: 1.6.0
; @description: Slim vertical touch widget for the OpenCode TUI (also great over RustDesk/iPad): PgUp, Up, Down, PgDn, Top, End, Menu.
; @description: Menu toggles a wide labeled quick-launch rail, bottom-aligned:
; @description: AHK dash, files, fleet, web, Claude, Antigravity, export current
; @description: chat to MD, OC webapp (starts stack if down), OC stack start.
; @description: Rail edited in a built-in config window (Config button),
; @description: persisted to scroll_widget.ini. Split transparency,
; @description: Electron-aware target scan, Top/End follow the working channel.
; @category: utilities
; @author: Sandra
; @hotkeys: ^!s toggle  ^!w pick target  ^!m snap  ^!k wheel/key  ^!a autohide  ^!q quick rail  ^!e export chat MD  ^!o rail config
; @tag: scroll, ipad, rustdesk, opencode, terminal, widget, games, touch, a11y
; ==============================================================================

; Why this exists: the OpenCode TUI scrollbar is a few px wide - near-invisible
; and unhittable over RustDesk + iPad touch. This gives 7 fat touch targets
; that post wheel deltas instead of dragging the thin bar.

; Config (touch-sized for RustDesk/iPad - 44px was too small to hit reliably)
; v1.2.1: narrowed to 48px, muted palette for lower contrast over dark TUIs.
; v1.3.0: split transparency - TRANSKEY frame keyed out, buttons at WIDGET_ALPHA.
; v1.4.0: Menu toggles a 6-slot quick-launch rail docked left of the widget.
global WIDGET_W := 48
global WIDGET_H := 236
global BTN_W := 36
global BTN_H := 26
global GAP := 3
global PAD := 6
global WIDGET_ALPHA := 100
global TRANSKEY := "FF00FF"
global QUICK_W := 150
global QUICK_H := 299
global QUICK_N := 10
global QUICK_GAP := 12
; Top/End keystrokes - overridable via scroll_widget.ini [widget] top_keys/end_keys.
; Default is a PgUp/PgDn burst: binding-independent, works in any scrollable TUI
; including ones that never see Ctrl+Home (terminal sequence never arrives).
; If your app binds jump-to-top (e.g. "gg", "{Home}"), set it in the INI.
global TOP_KEYS := "{PgUp 30}"
global END_KEYS := "{PgDn 30}"

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
global MyQuick := 0
global quickVisible := false
global QUICK := []
global MyCfg := 0
global CFG_EDITS := []
global SETTINGS_FILE := A_ScriptDir "\scroll_widget.ini"

; ==============================================================================
; Startup
; ==============================================================================
SetWorkingDir(A_ScriptDir)

LoadSettings()
Dbg("startup: scroll-widget v1.6.0")
targetHwnd := DetectTerminal()
if (targetHwnd) {
    targetName := WinGetProcessName("ahk_id " targetHwnd)
    Dbg("startup: target hwnd=" targetHwnd " exe=" targetName " title=" WinGetTitle("ahk_id " targetHwnd))
    OutputDebug("[scroll-widget] target: " WinGetTitle("ahk_id " targetHwnd))
} else {
    Dbg("startup: no target found")
}

BuildWidget()
Hotkey("^!s", ToggleWidget)
Hotkey("^!w", PickTarget)
Hotkey("^!m", SnapToTarget)
Hotkey("^!k", ToggleScrollMode)
Hotkey("^!a", ToggleAutoHide)
Hotkey("^!q", ToggleQuick)
Hotkey("^!e", (*) => ExportCurrentChat())
Hotkey("^!o", (*) => OpenConfigWindow())
SetTimer(AutoHideTick, 500)
OnExit(SaveOnExit)

; ==============================================================================
; Functions
; ==============================================================================

FindVisibleWindow(exeList) {
    ; Electron/CEF apps spawn headless helpers (gpu, renderer, crashpad) under
    ; the same exe name. WinExist grabs the first match - often a windowless
    ; helper you can neither focus nor send to. Scan all top-level windows and
    ; take the first with a real title; fall back to any existing hwnd.
    for _, exe in exeList {
        hwnds := WinGetList("ahk_exe " exe)
        fallback := 0
        for _, hwnd in hwnds {
            try {
                t := WinGetTitle("ahk_id " hwnd)
            } catch {
                continue
            }
            if (t != "") {
                return hwnd
            }
            if (!fallback) {
                fallback := hwnd
            }
        }
        if (fallback) {
            return fallback
        }
    }
    return 0
}

DetectTerminal() {
    ; Prefer OpenCode strictly - it is the primary scroll target.
    hwnd := FindVisibleWindow(["opencode.exe"])
    if (hwnd) {
        return hwnd
    }
    return FindVisibleWindow(["terminal.exe", "pwsh.exe", "cmd.exe", "conhost.exe", "WindowsTerminal.exe"])
}

Dbg(msg) {
    try FileAppend("[" A_Now "] " msg "`n", A_ScriptDir "\scroll_widget.log")
}

DefaultQuickSlot(i) {
    ; Ten quick-launch slots: "Label|target". Plain targets are Run()ed
    ; as-is (URLs, shell:AppsFolder IDs, exe paths, folders); "action:..."
    ; targets run built-in flows (export chat MD, OC webapp/stack).
    ; Edit in scroll_widget.ini [quick] q1..q10 - no recompile.
    ; %LOCALAPPDATA% / %USERPROFILE% expand at launch time.
    global DASHBOARD_URL
    switch i {
        case 1: return "AHK dash|" DASHBOARD_URL
        case 2: return "Files|explorer.exe"
        case 3: return "Fleet app|http://127.0.0.1:10947"
        case 4: return "Web|https://sandraschi.com"
        case 5: return "Claude|shell:AppsFolder\Claude_pzs8sxrjxfjjc!Claude"
        case 6: return "Antigravity|%LOCALAPPDATA%\Programs\Antigravity\Antigravity.exe"
        case 7: return "Export chat MD|action:export-md"
        case 8: return "OC webapp|action:oc-web"
        case 9: return "OC start|action:oc-start"
        case 10: return "Config|action:config"
        default: return ""
    }
}

ExpandTarget(t) {
    t := StrReplace(t, "%LOCALAPPDATA%", EnvGet("LOCALAPPDATA"))
    t := StrReplace(t, "%USERPROFILE%", EnvGet("USERPROFILE"))
    return t
}

LoadSettings() {
    ; Dumb persistence: INI wins, defaults fill gaps. No migrations, no
    ; version stamps - the rail's Config button is the editing story.
    global ScrollMode, AutoHide, WIDGET_ALPHA, TOP_KEYS, END_KEYS, QUICK, quickVisible, SETTINGS_FILE, QUICK_N
    QUICK := []
    try {
        m := IniRead(SETTINGS_FILE, "widget", "mode", "wheel")
        if (m = "keys" || m = "wheel") {
            ScrollMode := m
        }
        AutoHide := IniRead(SETTINGS_FILE, "widget", "autohide", 1) != 0
        quickVisible := IniRead(SETTINGS_FILE, "widget", "quick_visible", 0) != 0
        WIDGET_ALPHA := Integer(IniRead(SETTINGS_FILE, "widget", "alpha", WIDGET_ALPHA))
        if (WIDGET_ALPHA < 40 || WIDGET_ALPHA > 255) {
            WIDGET_ALPHA := 100
        }
        TOP_KEYS := IniRead(SETTINGS_FILE, "widget", "top_keys", TOP_KEYS)
        END_KEYS := IniRead(SETTINGS_FILE, "widget", "end_keys", END_KEYS)
        Loop QUICK_N {
            raw := IniRead(SETTINGS_FILE, "quick", "q" A_Index, DefaultQuickSlot(A_Index))
            if (raw != "" && InStr(raw, "|")) {
                parts := StrSplit(raw, "|", , 2)
                QUICK.Push(Map("label", parts[1], "target", parts[2]))
            }
        }
    } catch {
        ; Defaults stand on first run / corrupt INI.
    }
}

SaveSettings() {
    global ScrollMode, AutoHide, WIDGET_ALPHA, TOP_KEYS, END_KEYS, QUICK, quickVisible, MyGui, SETTINGS_FILE, QUICK_N
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
        IniWrite(quickVisible ? 1 : 0, SETTINGS_FILE, "widget", "quick_visible")
        IniWrite(WIDGET_ALPHA, SETTINGS_FILE, "widget", "alpha")
        IniWrite(TOP_KEYS, SETTINGS_FILE, "widget", "top_keys")
        IniWrite(END_KEYS, SETTINGS_FILE, "widget", "end_keys")
        Loop QUICK_N {
            if (A_Index <= QUICK.Length) {
                q := QUICK[A_Index]
                IniWrite(q["label"] "|" q["target"], SETTINGS_FILE, "quick", "q" A_Index)
            } else {
                IniWrite("", SETTINGS_FILE, "quick", "q" A_Index)
            }
        }
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
    b7.ToolTip := "Quick-launch rail (click again to hide, ^!q)"

    b1.OnEvent("Click", (*) => ScrollWheel("PgUp"))
    b2.OnEvent("Click", (*) => ScrollWheel("Up"))
    b3.OnEvent("Click", (*) => ScrollWheel("Down"))
    b4.OnEvent("Click", (*) => ScrollWheel("PgDn"))
    b5.OnEvent("Click", (*) => TopJump())
    b6.OnEvent("Click", (*) => EndJump())
    b7.OnEvent("Click", (*) => ToggleQuick())

    ; Click target label toggles wheel/key mode - fat enough for touch.
    TargetLbl := MyGui.Add("Text", "x" PAD " y" r6 + BTN_H + GAP " w" BTN_W " h16 Center cGray", "")
    TargetLbl.ToolTip := "Click toggles wheel/key mode (^!k)"
    TargetLbl.OnEvent("Click", (*) => ToggleScrollMode())
    UpdateTargetLabel()

    MyGui.Show(Format("x{1} y{2} w{3} h{4} NoActivate", x, y, WIDGET_W, WIDGET_H))
    ApplyAlpha()
    RefreshVisibility()
    if (quickVisible) {
        BuildQuick()
        PositionQuick()
        try MyQuick.Show("NoActivate")
        ApplyAlpha(MyQuick)
    }
}

ApplyAlpha(targetGui := 0) {
    ; Split transparency: TRANSKEY gaps fully see-through, buttons at WIDGET_ALPHA.
    global MyGui, WIDGET_ALPHA
    g := targetGui ? targetGui : MyGui
    if (!g) {
        return
    }
    try {
        g.Opt("+E0x80000")
        ; COLORREF for FF00FF is 0x00FF00FF (R=FF G=00 B=FF).
        DllCall("SetLayeredWindowAttributes", "Ptr", g.Hwnd, "UInt", 0x00FF00FF, "UChar", WIDGET_ALPHA, "UInt", 0x3)
    } catch {
        ; Transparency unsupported - widget stays opaque.
    }
}

BuildQuick() {
    ; Wide labeled rail, docked left of the main widget, bottom-aligned.
    ; Created once on first toggle (or boot restore); PositionQuick places
    ; it before every show. Empty targets are skipped, height follows rows.
    global MyQuick, QUICK, QUICK_H, QUICK_W, BTN_W, BTN_H, GAP, PAD, TRANSKEY
    if (MyQuick) {
        return
    }
    rows := 0
    Loop QUICK.Length {
        if (QUICK[A_Index]["target"] != "") {
            rows++
        }
    }
    if (rows = 0) {
        return
    }
    QUICK_H := 2 * PAD + rows * BTN_H + (rows - 1) * GAP
    MyQuick := Gui("+AlwaysOnTop +ToolWindow -Caption +Border", "Quick")
    MyQuick.BackColor := TRANSKEY
    MyQuick.SetFont("s9 c8a8fa3", "Segoe UI")
    r := 0
    Loop QUICK.Length {
        q := QUICK[A_Index]
        if (q["target"] = "") {
            continue
        }
        y := PAD + r * (BTN_H + GAP)
        r++
        bw := QUICK_W - 2 * PAD
        btn := MyQuick.Add("Button", Format("x{1} y{2} w{3} h{4} Background232433", PAD, y, bw, BTN_H), q["label"])
        btn.ToolTip := q["label"] " -> " q["target"]
        btn.OnEvent("Click", QuickLaunch.Bind(q["label"], q["target"]))
    }
}

PositionQuick() {
    global MyGui, MyQuick, QUICK_W, QUICK_H, QUICK_GAP, WIDGET_H
    if (!MyGui || !MyQuick) {
        return
    }
    try {
        MyGui.GetPos(&mx, &my)
        ; Docked left of main with a gap, bottoms aligned: the rail is a
        ; temporary overlay, so it may cover content - just not the widget.
        qx := mx - QUICK_W - QUICK_GAP
        qy := my + WIDGET_H - QUICK_H
        if (qx < 0) {
            qx := 0
        }
        if (qy < 0) {
            qy := 0
        }
        if (qy + QUICK_H > A_ScreenHeight) {
            qy := A_ScreenHeight - QUICK_H - 8
        }
        DllCall("SetLastError", "UInt", 0)
        ok := DllCall("SetWindowPos", "Ptr", MyQuick.Hwnd, "Ptr", 0
            , "Int", qx, "Int", qy, "Int", QUICK_W, "Int", QUICK_H
            , "UInt", 0x0014, "Int")  ; SWP_NOACTIVATE|SWP_NOZORDER
        err := DllCall("GetLastError", "UInt")
        ax := "?"
        ay := "?"
        aw := "?"
        ah := "?"
        try {
            WinGetPos(&ax, &ay, &aw, &ah, "ahk_id " MyQuick.Hwnd)
        } catch {
        }
        Dbg("PositionQuick: main=" mx "," my " want=" qx "," qy " actual=" ax "," ay " " aw "x" ah " ok=" ok " err=" err)
    } catch as e {
        Dbg("PositionQuick FAILED: " e.Message)
    }
}

ToggleQuick(*) {
    global MyQuick, quickVisible
    quickVisible := !quickVisible
    if (quickVisible) {
        BuildQuick()
        PositionQuick()
        try MyQuick.Show("NoActivate")
        ApplyAlpha(MyQuick)
        try {
            MyQuick.GetPos(&qx2, &qy2, &qw2, &qh2)
            Dbg("ToggleQuick: shown hwnd=" MyQuick.Hwnd " pos=" qx2 "," qy2 " size=" qw2 "x" qh2 " exists=" WinExist("ahk_id " MyQuick.Hwnd))
        } catch as e2 {
            Dbg("ToggleQuick: verify FAILED " e2.Message)
        }
    } else if (MyQuick) {
        try MyQuick.Hide()
    }
    SaveSettings()
    Dbg("ToggleQuick: visible=" quickVisible)
}

QuickLaunch(label, target, *) {
    if (SubStr(target, 1, 7) = "action:") {
        QuickAction(SubStr(target, 8), label)
        return
    }
    t := ExpandTarget(target)
    Dbg("QuickLaunch: " label " -> " t)
    try {
        Run(t)
    } catch as e {
        ShowToast("Launch failed (" label "): " e.Message)
    }
}

QuickAction(name, label) {
    Dbg("QuickAction: " name)
    switch name {
        case "export-md": ExportCurrentChat()
        case "oc-web": OpenOCWebapp()
        case "oc-start": StartOCStack()
        case "config": OpenConfigWindow()
        default: ShowToast("Unknown action (" label "): " name)
    }
}

OpenConfigWindow() {
    ; Rail slot editor: one row per slot (label + target). Save rebuilds
    ; the rail live, Reset loads stock defaults into the edits (Save still
    ; required). This window IS the config story - the INI is just
    ; persistence, never hand-edited.
    global MyCfg, CFG_EDITS, QUICK, QUICK_N
    if (MyCfg) {
        try MyCfg.Show()
        return
    }
    MyCfg := Gui(, "Quick Rail Config")
    MyCfg.SetFont("s9", "Segoe UI")
    MyCfg.Add("Text", "x12 y10 w556", "Label = button text. Target = URL, path, shell:AppsFolder ID, or action:export-md / oc-web / oc-start / config. Empty target = row skipped.")
    CFG_EDITS := []
    Loop QUICK_N {
        i := A_Index
        lab := ""
        tgt := ""
        if (i <= QUICK.Length) {
            lab := QUICK[i]["label"]
            tgt := QUICK[i]["target"]
        }
        yy := 34 + (i - 1) * 28
        MyCfg.Add("Text", Format("x12 y{1} w24", yy + 3), "q" i)
        eLab := MyCfg.Add("Edit", Format("x40 y{1} w150 h23", yy), lab)
        eTgt := MyCfg.Add("Edit", Format("x196 y{1} w360 h23", yy), tgt)
        CFG_EDITS.Push(Map("label", eLab, "target", eTgt))
    }
    by := 34 + QUICK_N * 28 + 6
    bSave := MyCfg.Add("Button", Format("x40 y{1} w120 h28 Default", by), "Save")
    bSave.OnEvent("Click", (*) => SaveConfigWindow())
    bReset := MyCfg.Add("Button", Format("x170 y{1} w120 h28", by), "Reset defaults")
    bReset.OnEvent("Click", (*) => ResetConfigWindow())
    bCancel := MyCfg.Add("Button", Format("x300 y{1} w120 h28", by), "Cancel")
    bCancel.OnEvent("Click", (*) => CloseConfigWindow())
    MyCfg.OnEvent("Close", (*) => CloseConfigWindow())
    MyCfg.OnEvent("Escape", (*) => CloseConfigWindow())
    MyCfg.Show(Format("w{1} h{2}", 580, by + 40))
    Dbg("Config: opened with " QUICK.Length " slots")
}

CloseConfigWindow() {
    global MyCfg
    if (MyCfg) {
        try MyCfg.Destroy()
    }
    MyCfg := 0
    Dbg("Config: closed")
}

ResetConfigWindow() {
    ; Refill the edits with stock defaults; Save still required to apply.
    global CFG_EDITS, QUICK_N
    Loop QUICK_N {
        raw := DefaultQuickSlot(A_Index)
        if (raw != "" && InStr(raw, "|")) {
            parts := StrSplit(raw, "|", , 2)
            CFG_EDITS[A_Index]["label"].Value := parts[1]
            CFG_EDITS[A_Index]["target"].Value := parts[2]
        } else {
            CFG_EDITS[A_Index]["label"].Value := ""
            CFG_EDITS[A_Index]["target"].Value := ""
        }
    }
    ShowToast("Defaults loaded - Save to apply")
}

SaveConfigWindow() {
    ; Harvest edits -> QUICK -> INI -> destroy + rebuild rail live.
    global CFG_EDITS, QUICK, MyQuick, quickVisible
    QUICK := []
    Loop CFG_EDITS.Length {
        lab := Trim(CFG_EDITS[A_Index]["label"].Value)
        tgt := Trim(CFG_EDITS[A_Index]["target"].Value)
        if (tgt != "") {
            if (lab = "") {
                lab := tgt
            }
            QUICK.Push(Map("label", lab, "target", tgt))
        }
    }
    SaveSettings()
    CloseConfigWindow()
    if (MyQuick) {
        try MyQuick.Destroy()
    }
    MyQuick := 0
    if (quickVisible) {
        BuildQuick()
        PositionQuick()
        if (MyQuick) {
            try MyQuick.Show("NoActivate")
            ApplyAlpha(MyQuick)
        }
    }
    Dbg("Config: saved " QUICK.Length " slots, rail rebuilt")
    ShowToast("Rail rebuilt: " QUICK.Length " buttons")
}

HttpGet(url, timeoutMs := 5000) {
    ; Synchronous GET via WinHTTP. Returns body on HTTP 200, "" otherwise.
    ; Short timeouts: depot calls can block 20s+ on a cold 11 GB opencode.db,
    ; so callers that need patience pass their own timeoutMs.
    try {
        req := ComObject("WinHttp.WinHttpRequest.5.1")
        req.SetTimeouts(timeoutMs, timeoutMs, timeoutMs, timeoutMs)
        req.Open("GET", url, false)
        req.Send()
        if (req.Status = 200) {
            return req.ResponseText
        }
        Dbg("HttpGet: " url " -> HTTP " req.Status)
    } catch as e {
        Dbg("HttpGet FAILED " url " : " e.Message)
    }
    return ""
}

ExportCurrentChat() {
    ; Exports the most recently updated session as markdown via the
    ; opencode-cli-mcp backend (:10951). File lands in ~/Downloads as
    ; opencode-<slug>-<id8>.md (exporter default) - toast shows the path.
    base := "http://127.0.0.1:10951"
    ShowToast("Export: contacting backend...")
    list := HttpGet(base "/api/depot/sessions?sort=updated&limit=1", 15000)
    if (list = "") {
        ShowToast("Backend :10951 down - tap OC Start first")
        return
    }
    if (!RegExMatch(list, '"id"\s*:\s*"(ses_[^"]+)"', &m)) {
        ShowToast("No sessions found")
        Dbg("ExportCurrentChat: no ses_ id in list (" StrLen(list) " chars)")
        return
    }
    sid := m[1]
    ShowToast("Exporting " SubStr(sid, 1, 12) "...")
    resp := HttpGet(base "/api/depot/sessions/" sid "/export?format=md", 60000)
    if (resp = "") {
        ShowToast("Export failed (backend error)")
        return
    }
    if (RegExMatch(resp, '"path"\s*:\s*"((?:[^"\\]|\\.)*)"', &p)) {
        path := StrReplace(p[1], "\\", "\")
        ShowToast("Saved: " path)
    } else {
        ShowToast("Exported " SubStr(sid, 1, 12) " (path unknown)")
    }
    Dbg("ExportCurrentChat: done " sid)
}

OpenOCWebapp() {
    ; Opens the OC webapp (:10950) when the backend answers, else offers
    ; the stack start instead of a dead browser tab.
    base := "http://127.0.0.1:10951"
    if (HttpGet(base "/api/v1/health", 2000) != "") {
        Run("http://127.0.0.1:10950")
    } else {
        ShowToast("Backend down - starting OC stack...")
        StartOCStack()
    }
}

StartOCStack() {
    ; Full stack: opencode serve :4097 + backend :10951 + frontend :10950.
    ; Takes ~30s; progress shows in the opened PowerShell window.
    try {
        Run('powershell.exe -NoExit -File "D:\Dev\repos\opencode-cli-mcp\start.ps1"', "D:\Dev\repos\opencode-cli-mcp")
        ShowToast("OC stack starting - webapp in ~30s")
    } catch as e {
        ShowToast("Start failed: " e.Message)
    }
    Dbg("StartOCStack")
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
    global MyGui, MyQuick, widgetVisible, quickVisible, AutoHide, autoHidden
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
        if (quickVisible && MyQuick) {
            PositionQuick()
            try MyQuick.Show("NoActivate")
            ApplyAlpha(MyQuick)
        }
    } else {
        if (widgetVisible) {
            ; User wants it visible but autohide says hide - soft hide.
            try MyGui.Hide()
            autoHidden := true
        }
        if (MyQuick) {
            ; Rail follows the main widget; intent lives in quickVisible.
            try MyQuick.Hide()
        }
    }
}

AutoHideTick() {
    RefreshVisibility()
    ; Re-dock every tick: RustDesk viewport/display changes can move the main
    ; widget (snap, resolution switch) while the rail keeps stale coords.
    ; Cheap Move on an already-correct position is a no-op visually.
    global MyQuick, quickVisible
    if (quickVisible && MyQuick) {
        PositionQuick()
    }
}

; --- Scroll: wheel posts WM_MOUSEWHEEL, keys Send PgUp/PgDn ---
; Wheel is hover-based: works wherever the cursor sits, regardless of which
; control has keyboard focus. Keys need the right control focused (in OpenCode
; the input box eats PgUp). Top/End follow the same rule via WheelBurst.
PostWheel(delta) {
    global targetHwnd
    if (!targetHwnd || !WinExist("ahk_id " targetHwnd)) {
        targetHwnd := DetectTerminal()
        UpdateTargetLabel()
    }
    if (!targetHwnd) {
        ShowToast("No scroll target - WinExist found nothing. Press ^!w over target.")
        return false
    }
    try {
        WinGetPos(&wx, &wy, &ww, &wh, "ahk_id " targetHwnd)
    } catch {
        ShowToast("Target lost - pick again with ^!w")
        targetHwnd := 0
        UpdateTargetLabel()
        return false
    }
    cx := wx + ww // 2
    cy := wy + wh // 2
    lParam := (cy << 16) | (cx & 0xFFFF)
    wParam := delta << 16
    try {
        PostMessage(0x020A, wParam, lParam, , "ahk_id " targetHwnd)
        return true
    } catch as e {
        ShowToast("Scroll post failed: " e.Message)
        return false
    }
}

ScrollWheel(keyName) {
    global ScrollMode
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
    switch keyName {
        case "PgUp": delta := 360
        case "Up": delta := 120
        case "Down": delta := -120
        case "PgDn": delta := -360
        default: return
    }
    PostWheel(delta)
}

WheelBurst(delta, count := 30) {
    ; Jump-to-extent on the wheel channel: N posts, small gap so Electron
    ; processes each instead of coalescing. No focus needed (hover-based).
    global targetHwnd
    Dbg("WheelBurst: delta=" delta " count=" count " hwnd=" targetHwnd)
    sent := 0
    Loop count {
        if (!PostWheel(delta)) {
            break
        }
        sent++
        Sleep(15)
    }
    Dbg("WheelBurst: posted " sent "/" count)
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
        Dbg("SendKey: no target, keys=" keys)
        ShowToast("No target - press ^!w over OpenCode first")
        return
    }
    try {
        alive := WinExist("ahk_id " targetHwnd) != 0
        Dbg("SendKey: keys=" keys " hwnd=" targetHwnd " alive=" alive)
        WinActivate("ahk_id " targetHwnd)
        if (!WinWaitActive("ahk_id " targetHwnd, , 1)) {
            Dbg("SendKey: focus FAILED hwnd=" targetHwnd)
            ShowToast("Target won't focus - press ^!w over OpenCode")
            return
        }
        Sleep(50)
        Send(keys)
        Dbg("SendKey: sent OK keys=" keys " hwnd=" targetHwnd)
        OutputDebug("[scroll-widget] sent: " keys)
    } catch as e {
        Dbg("SendKey: EXCEPTION " e.Message)
        ShowToast("Send failed: " e.Message)
    }
}

; --- Top/End jumps: follow ScrollMode so they use the working channel ---
; Wheel mode: burst of wheel posts (hover-based, input focus irrelevant).
; Keys mode (terminal targets): key burst via SendKey (focus handled there).
TopJump() {
    global ScrollMode, TOP_KEYS
    ShowToast("Top")
    if (ScrollMode = "keys") {
        SendKey(TOP_KEYS)
    } else {
        WheelBurst(360)
    }
}

EndJump() {
    global ScrollMode, END_KEYS
    ShowToast("End")
    if (ScrollMode = "keys") {
        SendKey(END_KEYS)
    } else {
        WheelBurst(-360)
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
        Dbg("PickTarget: hwnd=" hwnd " exe=" targetName " title=" SubStr(title, 1, 60))
        ShowToast("Scroll target: " SubStr(title, 1, 40))
    } catch {
        Dbg("PickTarget: hwnd=" hwnd " (title unreadable)")
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
