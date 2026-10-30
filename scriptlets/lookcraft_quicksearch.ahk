#Requires AutoHotkey v2.0+
#SingleInstance Force

; =============================================================================
; LookCraft Quick Search
; @name: LookCraft Quick Search
; @version: 1.0.0
; @description: Instant mail search over the lookcraft Rust CLI (JSON API).
;   Hotkey prompts for a query (empty = latest inbox), results list with
;   sender/date/subject, double-click reads the full body, button marks read.
; @description: First of the fleet-CLI scriptlets: wraps tools we actually ship
;   (lookcraft-cli mail-search/mail-list/mail-read/mail-mark-read) instead of
;   last year's generic Windows helpers.
; @category: productivity
; @author: Sandra
; @hotkeys: ^!j search, Enter/double-click read, Esc close
; @tag: lookcraft, mail, search, fleet-cli, productivity
; =============================================================================

; Crash net: log unhandled errors with timestamp instead of silent death.
_CatchBootError(Thrown, Mode) {
    try {
        msg := Thrown && HasProp(Thrown, "Message") ? Thrown.Message : "Unknown"
        extra := Thrown && HasProp(Thrown, "File") ? (" " Thrown.File ":" (HasProp(Thrown, "Line") ? Thrown.Line : "?")) : ""
        FileAppend("[" A_Now "] " msg extra "`n", A_ScriptDir "\lookcraft_quicksearch.log")
    } catch {
    }
    return 1
}
OnError(_CatchBootError)

; lookcraft-cli location: env override wins, else the fleet release build.
global LOOKCRAFT_EXE := EnvGet("LOOKCRAFT_CLI")
if (LOOKCRAFT_EXE = "") {
    LOOKCRAFT_EXE := "D:\Dev\repos\lookcraft\target\release\lookcraft-cli.exe"
}

global QSGui := 0
global QSLV := 0
global QSReader := 0
global QSStatus := 0
global QSResults := []
global QSCurrentId := ""
global QSLastQuery := ""

Hotkey("^!j", (*) => QuickSearchPrompt())

QuickSearchPrompt() {
    q := ""
    try {
        ib := InputBox("Mail search (empty = latest inbox):", "LookCraft Quick Search", "w400 h130")
        if (ib.Result != "OK") {
            return
        }
        q := ib.Value
    } catch {
        return
    }
    QuickSearchRun(q)
}

; Runs the CLI and captures stdout directly (no temp files, no cmd
; redirect quoting). Returns the stdout text, or "" on any failure.
RunCli(args, timeoutMs := 15000) {
    exe := LOOKCRAFT_EXE
    if (!FileExist(exe)) {
        ShowQSToast("lookcraft-cli not found: " exe)
        return ""
    }
    try {
        shell := ComObject("WScript.Shell")
        exec := shell.Exec('"' exe '" ' args)
        waited := 0
        while (exec.Status = 0 && waited < timeoutMs) {
            Sleep(50)
            waited += 50
        }
        if (exec.Status = 0) {
            try exec.Terminate()
            ShowQSToast("CLI timed out")
            return ""
        }
        out := ""
        try out := exec.StdOut.ReadAll()
        return out
    } catch as e {
        ShowQSToast("CLI failed: " e.Message)
        return ""
    }
}

QuickSearchRun(query) {
    global QSLastQuery
    QSLastQuery := query
    q := StrReplace(Trim(query), '"', "")
    args := (q = "") ? "mail-list --limit 20" : 'mail-search "' q '" --limit 20'
    resp := RunCli(args)
    if (resp = "") {
        return
    }
    if (InStr(resp, '"success":false') || InStr(resp, '"success": false')) {
        ShowQSToast("Backend error: " . SubStr(Trim(resp), 1, 120))
        return
    }
    hits := ParseQSRecords(resp)
    BuildOrShowQSGui()
    FillQSList(hits)
}

ParseQSRecords(json) {
    out := []
    starts := []
    ids := []
    pos := 1
    while (RegExMatch(json, '"id"\s*:\s*"([^"]+)"', &m, pos)) {
        ids.Push(m[1])
        starts.Push(m.Pos)
        pos := m.Pos + StrLen(m[0])
    }
    Loop ids.Length {
        i := A_Index
        fromPos := starts[i]
        toPos := (i < ids.Length) ? starts[i + 1] : StrLen(json) + 1
        chunk := SubStr(json, fromPos, toPos - fromPos)
        rec := Map("id", ids[i]
            , "from", QSField(chunk, "from", "?")
            , "subject", QSField(chunk, "subject", "(no subject)")
            , "date", QSDate(chunk)
            , "snippet", QSField(chunk, "snippet", ""))
        out.Push(rec)
    }
    return out
}

QSField(chunk, name, fallback) {
    if (RegExMatch(chunk, '"' name '"\s*:\s*"((?:[^"\\]|\\.)*)"', &m)) {
        return QSUnescapeLine(m[1])
    }
    return fallback
}

QSDate(chunk) {
    if (RegExMatch(chunk, '"date"\s*:\s*(?:"([^"]*)"|null)', &m)) {
        d := m[1]
        return (d = "") ? "?" : SubStr(d, 1, 16)
    }
    return "?"
}

QSUnescapeLine(s) {
    s := StrReplace(s, "\\", Chr(1))
    s := StrReplace(s, '\"', '"')
    s := StrReplace(s, "\n", " ")
    s := StrReplace(s, "\t", " ")
    s := StrReplace(s, Chr(1), "\")
    return s
}

QSUnescapeFull(s) {
    s := StrReplace(s, "\\", Chr(1))
    s := StrReplace(s, '\"', '"')
    s := StrReplace(s, "\n", "`r`n")
    s := StrReplace(s, "\t", " ")
    s := StrReplace(s, Chr(1), "\")
    return s
}

BuildOrShowQSGui() {
    global QSGui, QSLV, QSReader, QSStatus
    if (QSGui) {
        try QSGui.Show()
        return
    }
    QSGui := Gui(, "LookCraft Quick Search")
    QSGui.SetFont("s9", "Segoe UI")
    QSLV := QSGui.Add("ListView", "x10 y10 w680 h210 Grid", ["From", "Date", "Subject"])
    QSLV.ModifyCol(1, 180)
    QSLV.ModifyCol(2, 130)
    QSLV.ModifyCol(3, 350)
    QSLV.OnEvent("DoubleClick", (*) => QSReadSelected())
    QSReader := QSGui.Add("Edit", "x10 y230 w680 h200 ReadOnly Multi VScroll -WantTab", "")
    QSReader.SetFont("s9", "Consolas")
    bRead := QSGui.Add("Button", "x10 y440 w110 h28", "&Read")
    bRead.OnEvent("Click", (*) => QSReadSelected())
    bMark := QSGui.Add("Button", "x130 y440 w110 h28", "&Mark read")
    bMark.OnEvent("Click", (*) => QSMarkRead())
    bNew := QSGui.Add("Button", "x250 y440 w110 h28", "&New search")
    bNew.OnEvent("Click", (*) => QuickSearchPrompt())
    bClose := QSGui.Add("Button", "x580 y440 w110 h28", "&Close")
    bClose.OnEvent("Click", (*) => QSGui.Hide())
    QSStatus := QSGui.Add("Text", "x370 y445 w200 h20", "Ready")
    QSGui.OnEvent("Close", (*) => QSGui.Hide())
    QSGui.OnEvent("Escape", (*) => QSGui.Hide())
    QSGui.Show("w700 h480")
}

FillQSList(hits) {
    global QSLV, QSResults, QSReader, QSStatus
    QSResults := hits
    try QSLV.Delete()
    if (hits.Length = 0) {
        try QSStatus.Text := "No mail found - import or sync first"
        try QSReader.Value := ""
        return
    }
    for _, h in hits {
        QSLV.Add(, h["from"], h["date"], h["subject"])
    }
    try QSLV.Modify(1, "Select")
    try QSStatus.Text := hits.Length . " hit(s)"
}

QSReadSelected() {
    global QSLV, QSResults, QSReader, QSStatus, QSCurrentId
    row := 0
    try row := QSLV.GetNext()
    if (!row || row > QSResults.Length) {
        return
    }
    id := QSResults[row]["id"]
    QSCurrentId := id
    resp := RunCli('mail-read "' id '"', 30000)
    if (resp = "") {
        return
    }
    subj := QSField(resp, "subject", "(no subject)")
    from := QSField(resp, "from", "?")
    body := ""
    if (RegExMatch(resp, '"body_text"\s*:\s*"((?:[^"\\]|\\.)*)"', &m)) {
        body := QSUnescapeFull(m[1])
    } else {
        body := QSField(resp, "snippet", "(empty body)")
    }
    try QSReader.Value := "From: " from "`r`nSubject: " subj "`r`n`r`n" body
    try QSStatus.Text := "Reading: " SubStr(id, 1, 16)
}

QSMarkRead() {
    global QSCurrentId
    if (QSCurrentId = "") {
        ShowQSToast("Read a mail first")
        return
    }
    resp := RunCli('mail-mark-read "' QSCurrentId '"')
    if (resp != "") {
        ShowQSToast("Marked read")
    }
}

ShowQSToast(msg) {
    try TrayTip(msg, "LookCraft", "Iconi")
    try SetTimer(() => TrayTip(), -2500)
}
