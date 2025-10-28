; ==============================================================================
; Window Manager Pro
; @name: Window Manager Pro
; @version: 1.0.0
; @description: Advanced window management with snapping, tiling, and organization
; @category: utilities
; @author: Sandra
; @hotkeys: #Left, #Right, #Up, #Down, #Space, #Tab
; @enabled: true
; ==============================================================================

#Requires AutoHotkey v2.0+
#SingleInstance Force


; Suppress error popups - log to file instead
OnError("LogError")

LogError(Exception, Mode) {
    FileAppend("Error: " . Exception.Message . " at line " . Exception.Line . "
", "errors.log", "UTF-8")
    return true  ; Suppress popup
}


class WindowManager {
    static snapZones := Map()
    static windowHistory := []
    static currentLayout := "grid"
    
    static Init() {
        this.SetupSnapZones()
        this.CreateGUI()
    }
    
    static SetupSnapZones() {
        ; Get screen dimensions
        SysGet(&monitor, "Monitor")
        screenWidth := monitor.Right - monitor.Left
        screenHeight := monitor.Bottom - monitor.Top
        
        ; Define snap zones
        this.snapZones["left"] := {x: monitor.Left, y: monitor.Top, w: screenWidth//2, h: screenHeight}
        this.snapZones["right"] := {x: monitor.Left + screenWidth//2, y: monitor.Top, w: screenWidth//2, h: screenHeight}
        this.snapZones["top"] := {x: monitor.Left, y: monitor.Top, w: screenWidth, h: screenHeight//2}
        this.snapZones["bottom"] := {x: monitor.Left, y: monitor.Top + screenHeight//2, w: screenWidth, h: screenHeight//2}
        this.snapZones["top-left"] := {x: monitor.Left, y: monitor.Top, w: screenWidth//2, h: screenHeight//2}
        this.snapZones["top-right"] := {x: monitor.Left + screenWidth//2, y: monitor.Top, w: screenWidth//2, h: screenHeight//2}
        this.snapZones["bottom-left"] := {x: monitor.Left, y: monitor.Top + screenHeight//2, w: screenWidth//2, h: screenHeight//2}
        this.snapZones["bottom-right"] := {x: monitor.Left + screenWidth//2, y: monitor.Top + screenHeight//2, w: screenWidth//2, h: screenHeight//2}
        this.snapZones["center"] := {x: monitor.Left + screenWidth//4, y: monitor.Top + screenHeight//4, w: screenWidth//2, h: screenHeight//2}
    }
    
    static CreateGUI() {
        this.gui := Gui("+AlwaysOnTop +ToolWindow", "Window Manager")
        
        ; Title
        this.gui.Add("Text", "w300 h20 Center", "ðŸªŸ Window Manager Pro")
        
        ; Quick snap buttons
        snapPanel := this.gui.Add("Text", "w300 h80")
        
        leftBtn := this.gui.Add("Button", "x10 y10 w60 h25", "â† Left")
        rightBtn := this.gui.Add("Button", "x80 y10 w60 h25", "Right â†’")
        topBtn := this.gui.Add("Button", "x150 y10 w60 h25", "â†‘ Top")
        bottomBtn := this.gui.Add("Button", "x220 y10 w60 h25", "â†“ Bottom")
        
        tlBtn := this.gui.Add("Button", "x10 y40 w60 h25", "â†– TL")
        trBtn := this.gui.Add("Button", "x80 y40 w60 h25", "TR â†—")
        blBtn := this.gui.Add("Button", "x150 y40 w60 h25", "â†™ BL")
        brBtn := this.gui.Add("Button", "x220 y40 w60 h25", "BR â†˜")
        
        leftBtn.OnEvent("Click", this.SnapWindow.Bind(this, "left"))
        rightBtn.OnEvent("Click", this.SnapWindow.Bind(this, "right"))
        topBtn.OnEvent("Click", this.SnapWindow.Bind(this, "top"))
        bottomBtn.OnEvent("Click", this.SnapWindow.Bind(this, "bottom"))
        tlBtn.OnEvent("Click", this.SnapWindow.Bind(this, "top-left"))
        trBtn.OnEvent("Click", this.SnapWindow.Bind(this, "top-right"))
        blBtn.OnEvent("Click", this.SnapWindow.Bind(this, "bottom-left"))
        brBtn.OnEvent("Click", this.SnapWindow.Bind(this, "bottom-right"))
        
        ; Layout buttons
        layoutPanel := this.gui.Add("Text", "w300 h40")
        
        gridBtn := this.gui.Add("Button", "x10 y10 w80 h25", "Grid Layout")
        cascadeBtn := this.gui.Add("Button", "x100 y10 w80 h25", "Cascade")
        tileBtn := this.gui.Add("Button", "x190 y10 w80 h25", "Tile")
        
        gridBtn.OnEvent("Click", this.GridLayout.Bind(this))
        cascadeBtn.OnEvent("Click", this.CascadeLayout.Bind(this))
        tileBtn.OnEvent("Click", this.TileLayout.Bind(this))
        
        ; Window list
        this.gui.Add("Text", "w300 h20", "Active Windows:")
        this.windowList := this.gui.Add("ListView", "w300 h150", ["Title", "Process", "State"])
        this.windowList.OnEvent("DoubleClick", this.FocusWindow.Bind(this))
        
        ; Action buttons
        actionPanel := this.gui.Add("Text", "w300 h40")
        
        refreshBtn := this.gui.Add("Button", "x10 y10 w80 h25", "Refresh")
        minimizeBtn := this.gui.Add("Button", "x100 y10 w80 h25", "Minimize All")
        restoreBtn := this.gui.Add("Button", "x190 y10 w80 h25", "Restore All")
        
        refreshBtn.OnEvent("Click", this.RefreshWindows.Bind(this))
        minimizeBtn.OnEvent("Click", this.MinimizeAll.Bind(this))
        restoreBtn.OnEvent("Click", this.RestoreAll.Bind(this))
        
        this.gui.Show("w320 h350")
        this.RefreshWindows()
    }
    
    static SnapWindow(zone) {
        activeWin := WinGetID("A")
        if (activeWin && this.snapZones.Has(zone)) {
            zone := this.snapZones[zone]
            WinMove(zone.x, zone.y, zone.w, zone.h, activeWin)
            this.AddToHistory(activeWin)
        }
    }
    
    static GridLayout(*) {
        windows := this.GetVisibleWindows()
        if (windows.Length = 0) return
        
        ; Calculate grid dimensions
        cols := Ceil(Sqrt(windows.Length))
        rows := Ceil(windows.Length / cols)
        
        SysGet(&monitor, "Monitor")
        cellWidth := (monitor.Right - monitor.Left) // cols
        cellHeight := (monitor.Bottom - monitor.Top) // rows
        
        for i, winId in windows {
            row := Floor((i - 1) / cols)
            col := (i - 1) % cols
            
            x := monitor.Left + col * cellWidth
            y := monitor.Top + row * cellHeight
            
            WinMove(x, y, cellWidth, cellHeight, winId)
        }
    }
    
    static CascadeLayout(*) {
        windows := this.GetVisibleWindows()
        if (windows.Length = 0) return
        
        SysGet(&monitor, "Monitor")
        offset := 30
        
        for i, winId in windows {
            x := monitor.Left + (i - 1) * offset
            y := monitor.Top + (i - 1) * offset
            w := 800
            h := 600
            
            WinMove(x, y, w, h, winId)
        }
    }
    
    static TileLayout(*) {
        windows := this.GetVisibleWindows()
        if (windows.Length = 0) return
        
        SysGet(&monitor, "Monitor")
        screenWidth := monitor.Right - monitor.Left
        screenHeight := monitor.Bottom - monitor.Top
        
        if (windows.Length = 1) {
            WinMove(monitor.Left, monitor.Top, screenWidth, screenHeight, windows[1])
        } else if (windows.Length = 2) {
            WinMove(monitor.Left, monitor.Top, screenWidth//2, screenHeight, windows[1])
            WinMove(monitor.Left + screenWidth//2, monitor.Top, screenWidth//2, screenHeight, windows[2])
        } else {
            ; Tile remaining windows
            remaining := windows[3:]
            this.GridLayout()
        }
    }
    
    static GetVisibleWindows() {
        windows := []
        WinGet(&winList, "List")
        
        Loop winList.Length {
            winId := winList[A_Index]
            if (WinGetMinMax(winId) != -1) { ; Not minimized
                windows.Push(winId)
            }
        }
        
        return windows
    }
    
    static RefreshWindows(*) {
        this.windowList.Delete()
        WinGet(&winList, "List")
        
        Loop winList.Length {
            winId := winList[A_Index]
            try {
                title := WinGetTitle(winId)
                process := WinGetProcessName(winId)
                state := WinGetMinMax(winId) = -1 ? "Minimized" : "Active"
                
                this.windowList.Add("", title, process, state)
            } catch {
                ; Skip invalid windows
            }
        }
    }
    
    static FocusWindow(*) {
        selected := this.windowList.GetNext()
        if (selected > 0) {
            title := this.windowList.GetText(selected, 1)
            WinActivate(title)
        }
    }
    
    static MinimizeAll(*) {
        WinGet(&winList, "List")
        Loop winList.Length {
            winId := winList[A_Index]
            if (WinGetMinMax(winId) != -1) {
                WinMinimize(winId)
            }
        }
        this.RefreshWindows()
    }
    
    static RestoreAll(*) {
        WinGet(&winList, "List")
        Loop winList.Length {
            winId := winList[A_Index]
            if (WinGetMinMax(winId) = -1) {
                WinRestore(winId)
            }
        }
        this.RefreshWindows()
    }
    
    static AddToHistory(winId) {
        this.windowHistory.Push(winId)
        if (this.windowHistory.Length > 10) {
            this.windowHistory.RemoveAt(1)
        }
    }
}

; Hotkeys
#Hotkey("Left", (*) => WindowManager.SnapWindow("left")
#Hotkey("Right", (*) => WindowManager.SnapWindow("right")
#Hotkey("Up", (*) => WindowManager.SnapWindow("top")
#Hotkey("Down", (*) => WindowManager.SnapWindow("bottom")
#Hotkey("Space", (*) => WindowManager.Init()
#Hotkey("Tab", (*) => WindowManager.GridLayout()

; Initialize
WindowManager.Init()

