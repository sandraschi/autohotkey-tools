; ==============================================================================
; Window Manager Pro
; @name: Window Manager Pro
; @version: 2.0.0
; @description: Window snapping, tiling and quick layouts with logging and safe hotkeys.
; @category: utilities
; @author: Sandra
; @hotkeys: #Left, #Right, #Up, #Down, #Space, #Tab, F9
; @enabled: true
; @priority: 25
; @tag: windows, snapping, layout, productivity, gui
; ==============================================================================

#Requires AutoHotkey v2.0+
#SingleInstance Force
#Include %A_ScriptDir%\lib\ScriptletErrorHandler.ahk

OnError(LogError)

class WindowManagerPro {
    static gui := ""
    static listView := ""
    static statusBar := ""
    static searchBox := ""
    static history := []

    static hotkeysRegistered := false
    static logDir := ""
    static logFile := ""
    static progressTimer := 0
    static isVisible := false

    static Init() {
        WindowManagerPro.EnsureLogging()
        if (!WindowManagerPro.gui) {
            WindowManagerPro.CreateGui()
            WindowManagerPro.SetupHotkeys()
            WindowManagerPro.AppendLog("Window Manager Pro initialised.")
        }
        WindowManagerPro.ShowGui()
        WindowManagerPro.RefreshWindows()
    }

    static EnsureLogging() {
        if (WindowManagerPro.logDir) {
            return
        }
        logDirectory := A_ScriptDir . "\logs"
        if (!DirExist(logDirectory)) {
            DirCreate(logDirectory)
        }
        WindowManagerPro.logDir := logDirectory
        WindowManagerPro.logFile := logDirectory . "\window_manager_pro.log"
    }

    static AppendLog(message, level := "INFO") {
        timestamp := FormatTime(A_Now, "yyyy-MM-dd HH:mm:ss")
        line := "[" . timestamp . "] [" . level . "] " . message . "`n"
        try {
            FileAppend(line, WindowManagerPro.logFile, "UTF-8")
        } catch {
            ; ignore logging failures
        }
        OutputDebug("WindowManagerPro: " . message)
    }

    static CreateGui() {
        WindowManagerPro.gui := Gui("+Resize +MinSize420x360", "Window Manager Pro")
        WindowManagerPro.gui.SetFont("s10", "Segoe UI")
        WindowManagerPro.gui.OnEvent("Close", WindowManagerPro.HideGui.Bind(WindowManagerPro))
        WindowManagerPro.gui.OnEvent("Escape", WindowManagerPro.HideGui.Bind(WindowManagerPro))
        WindowManagerPro.gui.OnEvent("Size", WindowManagerPro.HandleResize.Bind(WindowManagerPro))

        WindowManagerPro.gui.Add("Text", "x12 y10 w180 h22", "Search windows:")
        WindowManagerPro.searchBox := WindowManagerPro.gui.Add("Edit", "x12 y32 w180 h24")
        WindowManagerPro.searchBox.OnEvent("Change", WindowManagerPro.HandleSearch.Bind(WindowManagerPro))

        buttonPanel := WindowManagerPro.gui.Add("GroupBox", "x210 y10 w190 h150", "Quick layouts")

        WindowManagerPro.AddButton(WindowManagerPro.gui, "Snap Left", 224, 35, (*) => WindowManagerPro.SnapActive("left"))
        WindowManagerPro.AddButton(WindowManagerPro.gui, "Snap Right", 304, 35, (*) => WindowManagerPro.SnapActive("right"))
        WindowManagerPro.AddButton(WindowManagerPro.gui, "Snap Top", 224, 70, (*) => WindowManagerPro.SnapActive("top"))
        WindowManagerPro.AddButton(WindowManagerPro.gui, "Snap Bottom", 304, 70, (*) => WindowManagerPro.SnapActive("bottom"))
        WindowManagerPro.AddButton(WindowManagerPro.gui, "Snap Center", 224, 105, (*) => WindowManagerPro.SnapActive("center"))
        WindowManagerPro.AddButton(WindowManagerPro.gui, "Cascade", 304, 105, (*) => WindowManagerPro.CascadeLayout())
        WindowManagerPro.AddButton(WindowManagerPro.gui, "Grid", 224, 140, (*) => WindowManagerPro.GridLayout())
        WindowManagerPro.AddButton(WindowManagerPro.gui, "Tile", 304, 140, (*) => WindowManagerPro.TileLayout())

        WindowManagerPro.gui.Add("Text", "x12 y68 w380 h20", "Active windows:")
        WindowManagerPro.listView := WindowManagerPro.gui.Add("ListView", "x12 y92 w388 h200 -Multi", ["Title", "Process", "State"])
        WindowManagerPro.listView.OnEvent("DoubleClick", WindowManagerPro.FocusSelected.Bind(WindowManagerPro))
        WindowManagerPro.listView.ModifyCol(1, 200)
        WindowManagerPro.listView.ModifyCol(2, 110)
        WindowManagerPro.listView.ModifyCol(3, 60)

        actionPanel := WindowManagerPro.gui.Add("GroupBox", "x12 y298 w388 h52", "Actions")
        WindowManagerPro.AddButton(WindowManagerPro.gui, "Refresh", 24, 322, (*) => WindowManagerPro.RefreshWindows())
        WindowManagerPro.AddButton(WindowManagerPro.gui, "Minimize All", 114, 322, WindowManagerPro.MinimizeAll.Bind(WindowManagerPro))
        WindowManagerPro.AddButton(WindowManagerPro.gui, "Restore All", 224, 322, WindowManagerPro.RestoreAll.Bind(WindowManagerPro))
        WindowManagerPro.AddButton(WindowManagerPro.gui, "History", 324, 322, WindowManagerPro.ShowHistory.Bind(WindowManagerPro))

        WindowManagerPro.statusBar := WindowManagerPro.gui.Add("StatusBar")
        WindowManagerPro.UpdateStatus("Ready. Use Win+Space to show or hide.")
    }

    static AddButton(gui, text, x, y, callback) {
        btn := gui.Add("Button", Format("x{} y{} w80 h26", x, y), text)
        btn.OnEvent("Click", callback)
        return btn
    }

    static SetupHotkeys() {
        if (WindowManagerPro.hotkeysRegistered) {
            return
        }
        Hotkey("#Left", (*) => WindowManagerPro.SnapActive("left"), "On")
        Hotkey("#Right", (*) => WindowManagerPro.SnapActive("right"), "On")
        Hotkey("#Up", (*) => WindowManagerPro.SnapActive("top"), "On")
        Hotkey("#Down", (*) => WindowManagerPro.SnapActive("bottom"), "On")
        Hotkey("#Space", (*) => WindowManagerPro.ToggleGui(), "On")
        Hotkey("#Tab", (*) => WindowManagerPro.GridLayout(), "On")
        Hotkey("F9", (*) => WindowManagerPro.EmergencyStop(), "On")
        WindowManagerPro.hotkeysRegistered := true
    }

    static ToggleGui(*) {
        if (!WindowManagerPro.gui) {
            WindowManagerPro.Init()
            return
        }
        if (WindowManagerPro.isVisible) {
            WindowManagerPro.HideGui()
        } else {
            WindowManagerPro.ShowGui()
            WindowManagerPro.RefreshWindows()
        }
    }

    static ShowGui() {
        WindowManagerPro.gui.Show("Center")
        WindowManagerPro.isVisible := true
    }

    static HideGui(*) {
        if (WindowManagerPro.gui) {
            WindowManagerPro.gui.Hide()
        }
        WindowManagerPro.isVisible := false
    }

    static EmergencyStop(*) {
        WindowManagerPro.HideGui()
        WindowManagerPro.UpdateStatus("Emergency stop triggered. GUI hidden.")
        WindowManagerPro.AppendLog("Emergency stop triggered by F9.", "WARN")
    }

    static HandleResize(gui, minMax, width, height) {
        if (!WindowManagerPro.gui) {
            return
        }
        padding := 12
        listTop := 92
        listHeight := Max(120, height - 160)
        WindowManagerPro.listView.Move(padding, listTop, width - padding * 2, listHeight)
        WindowManagerPro.statusBar.SetParts([width - padding * 2])
    }

    static HandleSearch(*) {
        term := StrLower(Trim(WindowManagerPro.searchBox.Value))
        WindowManagerPro.RefreshWindows(term)
    }

    static UpdateStatus(text) {
        if (WindowManagerPro.statusBar) {
            WindowManagerPro.statusBar.SetText(text, 1)
        }
    }

    static RefreshWindows(term := "") {
        if (!WindowManagerPro.listView) {
            return
        }
        WindowManagerPro.listView.Delete()
        windows := WindowManagerPro.GetVisibleWindows()
        filtered := 0
        for entry in windows {
            title := entry.title
            if (term && !InStr(StrLower(title), term)) {
                continue
            }
            WindowManagerPro.listView.Add("", title, entry.process, entry.state)
            WindowManagerPro.listView.SetRowData(WindowManagerPro.listView.GetCount(), entry.id)
            filtered++
        }
        WindowManagerPro.UpdateStatus(Format("Tracking {1} window(s). Showing {2}.", windows.Length, filtered))
    }

    static GetVisibleWindows() {
        result := []
        ids := WinGetList()
        for hwnd in ids {
            if (WinGetMinMax("ahk_id " . hwnd) = -1) {
                continue
            }
            title := WinGetTitle("ahk_id " . hwnd)
            if (!title) {
                continue
            }
            process := WinGetProcessName("ahk_id " . hwnd)
            state := WinGetMinMax("ahk_id " . hwnd) = 1 ? "Max" : "Normal"
            result.Push(Map("id", hwnd, "title", title, "process", process, "state", state))
        }
        return result
    }

    static FocusSelected(*) {
        row := WindowManagerPro.listView.GetNext()
        if (!row) {
            return
        }
        hwnd := WindowManagerPro.listView.GetRowData(row)
        if (hwnd) {
            WinActivate("ahk_id " . hwnd)
            WindowManagerPro.AppendLog("Activated window id " . hwnd)
        }
    }

    static SnapActive(direction) {
        hwnd := WinGetID("A")
        if (!hwnd) {
            WindowManagerPro.UpdateStatus("No active window to snap.")
            return
        }
        workArea := WindowManagerPro.GetWorkArea()
        rect := WindowManagerPro.GetSnapRect(direction, workArea)
        if (!rect) {
            WindowManagerPro.UpdateStatus("Unknown snap direction: " . direction)
            return
        }
        WinMove("ahk_id " . hwnd, , rect.x, rect.y, rect.w, rect.h)
        WindowManagerPro.AppendLog("Snapped window to " . direction)
        WindowManagerPro.PushHistory(hwnd, direction)
    }

    static GetWorkArea() {
        MonitorGet(, &left, &top, &right, &bottom)
        return Map("left", left, "top", top, "right", right, "bottom", bottom, "width", right - left, "height", bottom - top)
    }

    static GetSnapRect(direction, area) {
        padding := 8
        left := area.left + padding
        top := area.top + padding
        width := area.width - padding * 2
        height := area.height - padding * 2
        switch direction {
            case "left":
                return Map("x", left, "y", top, "w", width // 2, "h", height)
            case "right":
                return Map("x", left + width // 2, "y", top, "w", width // 2, "h", height)
            case "top":
                return Map("x", left, "y", top, "w", width, "h", height // 2)
            case "bottom":
                return Map("x", left, "y", top + height // 2, "w", width, "h", height // 2)
            case "center":
                return Map("x", left + width // 4, "y", top + height // 4, "w", width // 2, "h", height // 2)
            default:
                return 0
        }
    }

    static GridLayout(*) {
        windows := WindowManagerPro.GetVisibleWindows()
        count := windows.Length
        if (count = 0) {
            WindowManagerPro.UpdateStatus("No windows to arrange.")
            return
        }
        cols := Ceil(Sqrt(count))
        rows := Ceil(count / cols)
        area := WindowManagerPro.GetWorkArea()
        cellWidth := area.width // cols
        cellHeight := area.height // rows
        for index, entry in windows {
            row := Floor((index - 1) / cols)
            col := Mod(index - 1, cols)
            x := area.left + col * cellWidth
            y := area.top + row * cellHeight
            WinMove("ahk_id " . entry.id, , x, y, cellWidth, cellHeight)
        }
        WindowManagerPro.AppendLog("Applied grid layout for " . count . " window(s).")
        WindowManagerPro.UpdateStatus("Grid layout applied.")
    }

    static CascadeLayout(*) {
        windows := WindowManagerPro.GetVisibleWindows()
        count := windows.Length
        if (count = 0) {
            WindowManagerPro.UpdateStatus("No windows to cascade.")
            return
        }
        area := WindowManagerPro.GetWorkArea()
        offset := 32
        width := Max(400, area.width - offset * count)
        height := Max(260, area.height - offset * count)
        step := 0
        for entry in windows {
            x := area.left + step * offset
            y := area.top + step * offset
            WinMove("ahk_id " . entry.id, , x, y, width, height)
            step++
        }
        WindowManagerPro.AppendLog("Applied cascade layout for " . count . " window(s).")
        WindowManagerPro.UpdateStatus("Cascade layout applied.")
    }

    static TileLayout(*) {
        windows := WindowManagerPro.GetVisibleWindows()
        count := windows.Length
        if (count = 0) {
            WindowManagerPro.UpdateStatus("No windows to tile.")
            return
        }
        area := WindowManagerPro.GetWorkArea()
        if (count = 1) {
            WinMove("ahk_id " . windows[1].id, , area.left, area.top, area.width, area.height)
            WindowManagerPro.UpdateStatus("Single window maximised.")
            return
        }
        if (count = 2) {
            WinMove("ahk_id " . windows[1].id, , area.left, area.top, area.width // 2, area.height)
            WinMove("ahk_id " . windows[2].id, , area.left + area.width // 2, area.top, area.width // 2, area.height)
            WindowManagerPro.UpdateStatus("Two windows tiled side by side.")
            WindowManagerPro.AppendLog("Tile layout applied for 2 windows.")
            return
        }
        WindowManagerPro.GridLayout()
    }

    static MinimizeAll(*) {
        ids := WinGetList()
        for hwnd in ids {
            if (WinGetMinMax("ahk_id " . hwnd) != -1) {
                WinMinimize("ahk_id " . hwnd)
            }
        }
        WindowManagerPro.AppendLog("All windows minimised.")
        WindowManagerPro.RefreshWindows()
    }

    static RestoreAll(*) {
        ids := WinGetList()
        for hwnd in ids {
            if (WinGetMinMax("ahk_id " . hwnd) = -1) {
                WinRestore("ahk_id " . hwnd)
            }
        }
        WindowManagerPro.AppendLog("All windows restored.")
        WindowManagerPro.RefreshWindows()
    }

    static PushHistory(hwnd, action) {
        WindowManagerPro.history.Push(Map("id", hwnd, "action", action, "time", A_Now))
        if (WindowManagerPro.history.Length > 20) {
            WindowManagerPro.history.RemoveAt(1)
        }
    }

    static ShowHistory(*) {
        if (WindowManagerPro.history.Length = 0) {
            WindowManagerPro.UpdateStatus("No snap history available.")
            return
        }
        summary := ""
        for entry in WindowManagerPro.history.Clone().Reverse() {
            when := FormatTime(entry.time, "HH:mm:ss")
            summary .= when . " -> " . entry.action . "`n"
        }
        A_Clipboard := summary
        WindowManagerPro.UpdateStatus("Snap history copied to clipboard.")
        ToolTip("Snap history copied to clipboard.")
        SetTimer(() => ToolTip(), -1500)
    }
}
; Register exit handler
OnExit((*) => WindowManagerPro.HideGui())

WindowManagerPro.Init()