#Requires AutoHotkey v2.0+
#SingleInstance Force

; ==============================================================================
; @name: AHK Launcher
; @version: 1.0.0
; @description: Searchable launcher for all scriptlets. Ctrl+Alt+A toggle.
; @category: utilities
; @author: Sandra
; @hotkeys: ^!a toggle
; @tag: launcher, dashboard, scripts, depot
; ==============================================================================

AHK_EXE := "C:\Program Files\AutoHotkey\v2\AutoHotkey64.exe"
CONFIG_DIR := A_AppData "\autohotkey-depot\launcher"
favs := Map()
allScr := []
filtScr := []
w := ""
ed := ""
lb := ""
st := ""

DirCreate(CONFIG_DIR)

; Load favorites
favFile := CONFIG_DIR "\favorites.ini"
if FileExist(favFile) {
    for line in StrSplit(FileRead(favFile), "`n", "`r") {
        if (line != "")
            favs[line] := true
    }
}

; Scan depot
Scan() {
    global allScr
    result := []
    for dir in [A_ScriptDir, A_ScriptDir "\ai_generated"] {
        if !DirExist(dir)
            continue
        Loop Files dir "\*.ahk", "F" {
            if (A_LoopFileName ~= "^_|^\.|ahk_launcher|ScriptletLauncher|^test|\.bak")
                continue
            result.Push({name: A_LoopFileName, path: A_LoopFileFullPath})
        }
    }
    allScr := result
}
Scan()

; Refresh list
Refresh(*) {
    global ed, lb, allScr, filtScr, st
    q := Trim(ed.Text)
    if (q = "") {
        f := []
        for s in allScr
            f.Push(s)
        filtScr := f
    } else {
        q := StrLower(q)
        f := []
        for s in allScr {
            if InStr(StrLower(s.name), q)
                f.Push(s)
        }
        filtScr := f
    }
    lb.Delete()
    for s in filtScr {
        star := favs.Has(s.name) ? Chr(0x2605) " " : "  "
        lb.Add([star . s.name])
    }
    if (filtScr.Length > 0)
        lb.Choose(1)
    st.Text := filtScr.Length " scripts"
}

; Launch selected
Launch(*) {
    global w, lb, filtScr
    row := lb.Value
    if (row < 1 || row > filtScr.Length)
        return
    s := filtScr[row]
    w.Hide()
    try {
        Run('"' AHK_EXE '" "' s.path '"')
    } catch as e {
        MsgBox("Failed: " e.Message)
    }
    SetTimer(ShowAfter, -1500)
}

ShowAfter(*) {
    global w
    w.Show("NoActivate")
}

; Toggle favorite
ToggleFav(*) {
    global lb, filtScr
    row := lb.Value
    if (row < 1 || row > filtScr.Length)
        return
    name := filtScr[row].name
    if (favs.Has(name))
        favs.Delete(name)
    else
        favs[name] := true
    SaveFavs()
    Refresh()
}

SaveFavs() {
    global favs
    lines := []
    for k, _ in favs
        lines.Push(k)
    s := ""
    for i, v in lines {
        if (i > 1)
            s .= "`n"
        s .= v
    }
    try FileDelete(CONFIG_DIR "\favorites.ini")
    FileAppend(s, CONFIG_DIR "\favorites.ini")
}

; Toggle GUI
Toggle(*) {
    global w
    if (w.Visible)
        w.Hide()
    else
        w.Show("NoActivate")
}

; Build GUI
w := Gui("+AlwaysOnTop +Resize +MinSize380x280", "AHK Launcher")
w.BackColor := "131320"
    w.SetFont("s9 c4488FF", "Segoe UI")

ed := w.Add("Edit", "x6 y6 w368 h22 -WantTab", "")
ed.OnEvent("Change", Refresh)

lb := w.Add("ListBox", "x6 y32 w368 h220 Choose1", [])
lb.SetFont("s8 c4488FF", "Consolas")
lb.OnEvent("DoubleClick", Launch)

w.Add("Button", "x6 y258 w60 h22", "Run").OnEvent("Click", Launch)
w.Add("Button", "x72 y258 w50 h22", Chr(0x2605)).OnEvent("Click", ToggleFav)
st := w.Add("Text", "x132 y260 w242 h20 cGray", "")

w.OnEvent("Close", (*) => w.Hide())
w.OnEvent("Size", OnResize)
Hotkey("^!a", Toggle)

OnResize(*) {
    global w, ed, lb, st
    try {
        ww := w.ClientPos.W - 12
        h := w.ClientPos.H
        ed.Move(, , ww)
        lb.Move(, 32, ww, h - 70)
        st.Move(132, h - 27, ww - 140)
    }
}

Refresh()
w.Show("w380 h285")
