#Requires AutoHotkey v2.0+
#SingleInstance Force
#Include %A_ScriptDir%\lib\ScriptletErrorHandler.ahk

OnError(LogError)

class PacmanLauncher {
    static gui := ""

    static Init() {
        PacmanLauncher.CreateGui()
        PacmanLauncher.SetupHotkeys()
    }

    static HandleError(Thrown, Mode) {
        message := "Pacman launcher error: " . Thrown.Message . " at line " . Thrown.Line
        try FileAppend(message . "`n", "pacman_game_errors.log", "UTF-8")
        OutputDebug(message)
        return 1
    }

    static CreateGui() {
        newGui := Gui("+Resize +MinSize260x180", "Pac-Man Game Selector")
        newGui.BackColor := "111122"
        newGui.SetFont("s10", "Segoe UI")

        newGui.AddText("x20 y20 w220 Center cFFFF54", "Pac-Man Game Launcher")
        newGui.AddText("x20 y56 w220 h40 cFFFFFF", "Launch the lightweight Pac-Man demo built into this repository.")
        launchBtn := newGui.AddButton("x60 y100 w140 h32", "Launch Pac-Man")
        launchBtn.OnEvent("Click", (*) => PacmanLauncher.RunDemo())
        closeBtn := newGui.AddButton("x60 y140 w140 h28", "Close")
        closeBtn.OnEvent("Click", (*) => PacmanLauncher.HideGui())

        newGui.OnEvent("Close", PacmanLauncher.HideGui)
        newGui.OnEvent("Escape", PacmanLauncher.HideGui)
        newGui.OnEvent("Size", PacmanLauncher.OnResize)

        PacmanLauncher.gui := newGui
        newGui.Show("w260 h200")
    }

    static SetupHotkeys() {
        static registered := false
        if (registered) {
            return
        }
        Hotkey("^!p", (*) => PacmanLauncher.ShowGui())
        Hotkey("^!q", (*) => PacmanLauncher.HideGui())
        registered := true
    }

    static ShowGui() {
        if (!PacmanLauncher.gui) {
            PacmanLauncher.CreateGui()
        }
        PacmanLauncher.gui.Show()
    }

    static HideGui(*) {
        if (PacmanLauncher.gui) {
            PacmanLauncher.gui.Hide()
        }
    }

    static RunDemo() {
        scriptPath := A_ScriptDir . "\pacman_classic.ahk"
        if (!FileExist(scriptPath)) {
            MsgBox("Unable to locate pacman_classic.ahk", "Pac-Man", "Iconx")
            return
        }
        Run(Format('"{}" /ErrorStdOut "{}"', A_AhkPath, scriptPath))
    }

    static OnResize(gui, minMax, width, height) {
        if (!PacmanLauncher.gui) {
            return
        }
    }
}

PacmanLauncher.Init()

OnExit((*) => PacmanLauncher.HideGui())
