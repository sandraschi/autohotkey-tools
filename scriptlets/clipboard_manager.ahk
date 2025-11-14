#Requires AutoHotkey v2.0+
#SingleInstance Force
#Include %A_ScriptDir%\lib\ScriptletErrorHandler.ahk

; ==============================================================================
; Clipboard Manager (AutoHotkey v2)
; ==============================================================================

OnError(LogError)

class ClipboardManager {
    static history := []
    static historyFile := A_ScriptDir "\clipboard_history.txt"
    static maxHistory := 50
    static maxPreview := 100
    static menuGui := ""
    static listBox := ""
    static lastActiveWindow := 0

    static Init() {
SetWorkingDir(A_ScriptDir)
        ClipboardManager.LoadHistory()
        OnClipboardChange(ClipboardManager.OnClipboardChange)
        Hotkey("#v", (*) => ClipboardManager.ShowMenu())
        Hotkey("^!v", (*) => ClipboardManager.PastePreviousItem())
        Hotkey("^!+c", (*) => ClipboardManager.ClearHistoryPrompt())
        ClipboardManager.ShowTrayTip("Clipboard Manager", "Running – Win+V shows history")
        SetTimer(() => TrayTip(), -2000)
        OnExit(ClipboardManager.OnExit)
    }

    static OnClipboardChange(Type) {
        if (Type != 1) {
            return
        }
        clipText := A_Clipboard
        if (clipText = "") {
            return
        }
        if (ClipboardManager.history.Length > 0 && ClipboardManager.history[1]["text"] = clipText) {
            return
        }
        timestamp := ""
        timestamp := FormatTime(, "yyyy-MM-dd HH:mm:ss")
        source := ""
        try {
            source := WinGetProcessName("A")
        } catch {
            source := "Unknown"
        }
        item := Map()
        item["text"] := clipText
        item["timestamp"] := timestamp
        item["source"] := source
        item["preview"] := ClipboardManager.BuildPreview(clipText)
        ClipboardManager.history.InsertAt(1, item)
        while (ClipboardManager.history.Length > ClipboardManager.maxHistory) {
            ClipboardManager.history.Pop()
        }
        ClipboardManager.SaveHistory()
    }

    static ShowMenu() {
        if (ClipboardManager.history.Length = 0) {
            ClipboardManager.ShowTrayTip("Clipboard Manager", "Clipboard history is empty")
            SetTimer(() => TrayTip(), -2000)
            return
        }
        ClipboardManager.lastActiveWindow := WinExist("A")
        ClipboardManager.CloseMenu()
        gui := Gui("+AlwaysOnTop +ToolWindow -SysMenu", "Clipboard History")
        gui.BackColor := "F0F0F0"
        gui.SetFont("s10", "Segoe UI")
        title := gui.AddText("w600 h28 Center Background2A4F7F cWhite", "Clipboard History (" . ClipboardManager.history.Length . "/" . ClipboardManager.maxHistory . ")")
        title.OnEvent("Click", (*) => ClipboardManager.BeginMoveWindow(gui))
        closeBtn := gui.AddButton("x+0 w28 h28 BackgroundE81123 cWhite", "X")
        closeBtn.OnEvent("Click", (*) => ClipboardManager.CloseMenu())
        gui.SetFont("s9", "Consolas")
        visibleCount := Min(10, ClipboardManager.history.Length)
        ClipboardManager.listBox := gui.AddListBox("w600 h" . (visibleCount * 22), [])
        for item in ClipboardManager.history {
            display := "[" . item["timestamp"] . "] " . item["preview"]
            ClipboardManager.listBox.Add(display)
        }
        ClipboardManager.listBox.OnEvent("DoubleClick", (*) => ClipboardManager.PasteSelectedItem())
        gui.SetFont("s9", "Segoe UI")
        pasteBtn := gui.AddButton("w80 h28", "&Paste")
        pasteBtn.OnEvent("Click", (*) => ClipboardManager.PasteSelectedItem())
        deleteBtn := gui.AddButton("x+8 w80 h28", "&Delete")
        deleteBtn.OnEvent("Click", (*) => ClipboardManager.DeleteSelectedItem())
        clearBtn := gui.AddButton("x+8 w80 h28", "C&lear")
        clearBtn.OnEvent("Click", (*) => ClipboardManager.ClearHistoryPrompt())
        gui.OnEvent("Close", (*) => ClipboardManager.CloseMenu())
        gui.Show("AutoSize NoActivate")
        CoordMode("Mouse", "Screen")
        MouseGetPos(&mx, &my)
        WinGetPos(&wx, &wy, &ww, &wh, gui)
        if (mx + ww > A_ScreenWidth) {
            mx := A_ScreenWidth - ww - 10
        }
        if (my + wh > A_ScreenHeight) {
            my := A_ScreenHeight - wh - 10
        }
        gui.Show("x" . mx . " y" . my . " NoActivate")
        ControlFocus("ListBox1", gui)
        ClipboardManager.menuGui := gui
    }

    static CloseMenu() {
        if (ClipboardManager.menuGui) {
            try {
                ClipboardManager.menuGui.Destroy()
            } catch {
            }
            ClipboardManager.menuGui := ""
            ClipboardManager.listBox := ""
        }
    }

    static PasteSelectedItem() {
        if (!ClipboardManager.listBox) {
            return
        }
        index := ClipboardManager.listBox.Value
        if (index < 1 || index > ClipboardManager.history.Length) {
            return
        }
        item := ClipboardManager.history[index]
        ClipboardManager.history.RemoveAt(index)
        ClipboardManager.history.InsertAt(1, item)
        A_Clipboard := item["text"]
        if (ClipboardManager.lastActiveWindow) {
            try {
                WinActivate("ahk_id " . ClipboardManager.lastActiveWindow)
                Sleep(50)
            } catch {
            }
        }
        Send("^v")
        ClipboardManager.SaveHistory()
        ClipboardManager.CloseMenu()
    }

    static DeleteSelectedItem() {
        if (!ClipboardManager.listBox) {
            return
        }
        index := ClipboardManager.listBox.Value
        if (index < 1 || index > ClipboardManager.history.Length) {
            return
        }
        ClipboardManager.history.RemoveAt(index)
        ClipboardManager.RefreshList()
        ClipboardManager.SaveHistory()
    }

    static RefreshList() {
        if (!ClipboardManager.menuGui || !ClipboardManager.listBox) {
            return
        }
        ClipboardManager.listBox.Delete()
        for item in ClipboardManager.history {
            display := "[" . item["timestamp"] . "] " . item["preview"]
            ClipboardManager.listBox.Add(display)
        }
        visibleCount := Min(10, ClipboardManager.history.Length)
        ClipboardManager.listBox.Opt("h" . (visibleCount * 22))
    }

    static PastePreviousItem() {
        if (ClipboardManager.history.Length < 2) {
            ClipboardManager.ShowTrayTip("Clipboard Manager", "No previous item available")
            SetTimer(() => TrayTip(), -2000)
            return
        }
        prev := ClipboardManager.history[2]
        ClipboardManager.history.RemoveAt(2)
        ClipboardManager.history.InsertAt(1, prev)
        A_Clipboard := prev["text"]
        Send("^v")
        ClipboardManager.SaveHistory()
    }

    static ClearHistoryPrompt() {
        response := MsgBox("Clear the clipboard history?", "Clipboard Manager", "YesNo Icon!")
        if (response = "Yes") {
            ClipboardManager.history := []
            ClipboardManager.SaveHistory()
            ClipboardManager.CloseMenu()
            ClipboardManager.ShowTrayTip("Clipboard Manager", "History cleared")
            SetTimer(() => TrayTip(), -2000)
        }
    }

    static LoadHistory() {
        file := ClipboardManager.historyFile
        if (!FileExist(file)) {
            ClipboardManager.history := []
            return
        }
        try {
            reader := FileOpen(file, "r", "UTF-8")
            if (!reader) {
                ClipboardManager.history := []
                return
            }
            localHistory := []
            while (!reader.AtEOF) {
                line := reader.ReadLine()
                if (line = "") {
                    continue
                }
                item := ClipboardManager.Deserialize(line)
                if (item) {
                    localHistory.Push(item)
                }
            }
            reader.Close()
            ClipboardManager.history := localHistory
        } catch {
            ClipboardManager.history := []
        }
    }

    static SaveHistory() {
        try {
            writer := FileOpen(ClipboardManager.historyFile, "w", "UTF-8")
            if (!writer) {
                return
            }
            for item in ClipboardManager.history {
                writer.WriteLine(ClipboardManager.Serialize(item))
            }
            writer.Close()
        } catch {
        }
    }

    static Serialize(item) {
        return ClipboardManager.Escape(item["timestamp"]) . "|" . ClipboardManager.Escape(item["source"]) . "|" . ClipboardManager.Escape(item["preview"]) . "|" . ClipboardManager.Escape(item["text"])
    }

    static Deserialize(line) {
        parts := []
        current := ""
        escape := false
        for char in StrSplit(line, "") {
            if (escape) {
                current .= ClipboardManager.UnescapeChar(char)
                escape := false
                continue
            }
            if (char = "\\") {
                escape := true
                continue
            }
            if (char = "|") {
                parts.Push(current)
                current := ""
                continue
            }
            current .= char
        }
        parts.Push(current)
        if (parts.Length != 4) {
            return ""
        }
        item := Map()
        item["timestamp"] := parts[1]
        item["source"] := parts[2]
        item["preview"] := parts[3]
        item["text"] := parts[4]
        return item
    }

    static Escape(text) {
        text := StrReplace(text, "\\", "\\\\")
        text := StrReplace(text, "|", "\\|")
        text := StrReplace(text, "`r", "\\r")
        text := StrReplace(text, "`n", "\\n")
        return text
    }

    static UnescapeChar(char) {
        switch char {
            case "n":
                return "`n"
            case "r":
                return "`r"
            case "|":
                return "|"
            case "\\":
                return "\\"
            default:
                return char
        }
    }

    static BuildPreview(text) {
        firstLine := RegExReplace(text, "`am)^(.*?)(`r`n|`r|`n|$).*", "$1")
        firstLine := Trim(firstLine)
        if (StrLen(firstLine) > ClipboardManager.maxPreview) {
            firstLine := SubStr(firstLine, 1, ClipboardManager.maxPreview - 3) . "..."
        }
    return firstLine
}

    static BeginMoveWindow(gui) {
        PostMessage(0xA1, 2, , , gui)
    }

    static ShowTrayTip(title, message) {
        TrayTip(title, message)
    }

    static OnExit(ExitReason, ExitCode) {
        ClipboardManager.CloseMenu()
        ClipboardManager.SaveHistory()
    }
}

ClipboardManager.Init()


