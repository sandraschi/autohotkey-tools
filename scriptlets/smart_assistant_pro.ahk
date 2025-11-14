#Requires AutoHotkey v2.0+
#SingleInstance Force

; ==============================================================================
; Smart Assistant Pro
; @name: Smart Assistant Pro
; @version: 2.0.0
; @description: Productivity palette with quick commands, simulated workflows, and logging.
; @description: Offers single-click utilities, workflow automation, voice-toggle simulation,
; @description: and an activity log suitable for dashboards.
; @category: productivity
; @author: Sandra
; @hotkeys: ^!a, ^!s, ^!v
; @enabled: true
; @priority: 15
; @tag: assistant, productivity, workflows, automation, dashboard
; @cli: --workflow <name> - Run workflow (morning|work|break|end)
; @cli: --command <text> - Execute command (time|date|weather|note:<text>)
; ==============================================================================

class SmartAssistantPro {
    static gui := ""
    static statusText := ""
    static outputEdit := ""
    static commandEdit := ""
    static runButton := ""
    static voiceButton := ""
    static voiceEnabled := false

    static quickCommands := Map(
        "time", SmartAssistantPro.ShowTime,
        "date", SmartAssistantPro.ShowDate,
        "weather", SmartAssistantPro.ShowWeather,
        "screenshot", SmartAssistantPro.TakeScreenshot,
        "browser", (*) => Run("msedge.exe", , "Hide"),
        "calculator", (*) => Run("calc.exe", , "Hide"),
        "notepad", (*) => Run("notepad.exe", , "Hide"),
        "focus", SmartAssistantPro.EnableFocusMode,
        "unfocus", SmartAssistantPro.DisableFocusMode,
        "pause", SmartAssistantPro.StartBreak
    )

    static workflows := Map(
        "morning", ["time", "date", "weather", "note:Morning reflections"],
        "work", ["browser", "notepad", "focus"],
        "break", ["pause"],
        "end", ["note:Wrap-up summary", "unfocus"]
    )

    static Init() {
        SmartAssistantPro.CreateGui()
        SmartAssistantPro.RegisterHotkeys()
        SmartAssistantPro.AppendLog("Assistant ready.")
    }

    static CreateGui() {
        if (SmartAssistantPro.gui) {
            SmartAssistantPro.gui.Show()
            SmartAssistantPro.gui.Activate()
            return
        }

        newGui := Gui("+Resize +MinSize600x520", "Smart Assistant Pro")
        newGui.BackColor := "F4F6F8"
        newGui.OnEvent("Close", SmartAssistantPro.HideWindow.Bind(SmartAssistantPro))
        newGui.OnEvent("Size", SmartAssistantPro.HandleResize.Bind(SmartAssistantPro))

        newGui.SetFont("s12 Bold", "Segoe UI")
        newGui.Add("Text", "x20 y15 w560 h25 Center", "Smart Assistant Pro")
        newGui.SetFont("s10", "Segoe UI")

        SmartAssistantPro.voiceButton := newGui.Add("Button", "x20 y55 w160 h28", "Enable Voice Input")
        SmartAssistantPro.voiceButton.OnEvent("Click", SmartAssistantPro.ToggleVoice.Bind(SmartAssistantPro))

        SmartAssistantPro.statusText := newGui.Add("Text", "x200 y60 w380 h20", "Status: Ready")

        newGui.SetFont("s10 Bold", "Segoe UI")
        newGui.Add("Text", "x20 y100 w560 h20", "Quick Commands")
        newGui.SetFont("s10", "Segoe UI")
        layout := [["Time","time"],["Date","date"],["Weather","weather"],["Screenshot","screenshot"],
                   ["Browser","browser"],["Calculator","calculator"],["Notepad","notepad"]]
        x := 20, y := 130
        for _, entry in layout {
            label := entry[1]
            command := entry[2]
            btn := newGui.Add("Button", Format("x{} y{} w120 h28", x, y), label)
            btn.OnEvent("Click", SmartAssistantPro.ExecuteCommand.Bind(SmartAssistantPro, command))
            x += 130
            if (x > 520) {
                x := 20
                y += 35
            }
        }

        newGui.SetFont("s10 Bold", "Segoe UI")
        newGui.Add("Text", "x20 y220 w560 h20", "Workflows")
        newGui.SetFont("s10", "Segoe UI")
        workflows := [["Morning Routine","morning"],["Work Setup","work"],["Break Time","break"],["End of Day","end"]]
        x := 20, y := 250
        for _, entry in workflows {
            btn := newGui.Add("Button", Format("x{} y{} w140 h32", x, y), entry[1])
            btn.OnEvent("Click", SmartAssistantPro.RunWorkflow.Bind(SmartAssistantPro, entry[2]))
            x += 150
        }

        newGui.SetFont("s10 Bold", "Segoe UI")
        newGui.Add("Text", "x20 y300 w560 h20", "Custom Command")
        newGui.SetFont("s10", "Segoe UI")
        SmartAssistantPro.commandEdit := newGui.Add("Edit", "x20 y325 w420 h26")
        SmartAssistantPro.runButton := newGui.Add("Button", "x450 y325 w120 h26", "Execute")
        SmartAssistantPro.runButton.OnEvent("Click", SmartAssistantPro.RunCustomCommand.Bind(SmartAssistantPro))

        newGui.SetFont("s10 Bold", "Segoe UI")
        newGui.Add("Text", "x20 y365 w560 h20", "Activity Log")
        newGui.SetFont("s10", "Segoe UI")
        SmartAssistantPro.outputEdit := newGui.Add("Edit", "x20 y390 w560 h120 ReadOnly VScroll -Wrap")

        SmartAssistantPro.gui := newGui
        newGui.Show()
    }

    static RegisterHotkeys() {
        Hotkey("^!a", SmartAssistantPro.ShowWindow.Bind(SmartAssistantPro), "On")
        Hotkey("^!s", SmartAssistantPro.RunWorkflow.Bind(SmartAssistantPro, "work"), "On")
        Hotkey("^!v", SmartAssistantPro.ToggleVoice.Bind(SmartAssistantPro), "On")
    }

    static ShowWindow(*) {
        SmartAssistantPro.CreateGui()
        SmartAssistantPro.statusText.Text := "Status: Window shown."
        SmartAssistantPro.AppendLog("Window shown via hotkey.")
    }

    static HideWindow(*) {
        SmartAssistantPro.gui.Hide()
        SmartAssistantPro.AppendLog("Window hidden - script still running.")
        SmartAssistantPro.statusText.Text := "Status: Hidden."
    }

    static HandleResize(gui, minMax, width, height) {
        if (!SmartAssistantPro.outputEdit) {
            return
        }
        SmartAssistantPro.outputEdit.Move(20, height - 150, width - 40, 120)
        SmartAssistantPro.commandEdit.Move(20, height - 200, width - 180, 26)
        SmartAssistantPro.runButton.Move(width - 140, height - 200, 120, 26)
        SmartAssistantPro.statusText.Move(200, 60, width - 220, 20)
    }

    static ToggleVoice(*) {
        SmartAssistantPro.voiceEnabled := !SmartAssistantPro.voiceEnabled
        SmartAssistantPro.voiceButton.Text := SmartAssistantPro.voiceEnabled ? "Disable Voice Input" : "Enable Voice Input"
        SmartAssistantPro.statusText.Text := "Status: Voice " . (SmartAssistantPro.voiceEnabled ? "enabled" : "disabled")
        SmartAssistantPro.AppendLog("Voice input " . (SmartAssistantPro.voiceEnabled ? "enabled" : "disabled") . ".")
    }

    static RunCustomCommand(*) {
        input := Trim(SmartAssistantPro.commandEdit.Text)
        if (!input) {
            SmartAssistantPro.statusText.Text := "Status: enter a command."
            return
        }
        SmartAssistantPro.commandEdit.Text := ""
        SmartAssistantPro.ExecuteCommand(input)
    }

    static ExecuteCommand(commandText) {
        cmd := StrLower(Trim(commandText))
        if (InStr(cmd, "note:") = 1) {
            text := Trim(SubStr(cmd, 6))
            SmartAssistantPro.CreateNote(text)
            return
        }

        if (SmartAssistantPro.quickCommands.Has(cmd)) {
            SmartAssistantPro.quickCommands[cmd].Call(SmartAssistantPro)
            SmartAssistantPro.statusText.Text := "Status: Executed '" . cmd . "'."
            SmartAssistantPro.AppendLog("Command executed: " . cmd)
            return
        }

        SmartAssistantPro.statusText.Text := "Status: Unknown command (" . cmd . ")."
        SmartAssistantPro.AppendLog("Unknown command: " . cmd)
    }

    static RunWorkflow(name) {
        key := StrLower(name)
        if (!SmartAssistantPro.workflows.Has(key)) {
            SmartAssistantPro.statusText.Text := "Status: Workflow '" . key . "' not found."
            SmartAssistantPro.AppendLog("Workflow not found: " . key)
            return
        }
        SmartAssistantPro.AppendLog("Workflow started: " . key)
        for _, action in SmartAssistantPro.workflows[key] {
            SmartAssistantPro.ExecuteCommand(action)
            Sleep(250)
        }
        SmartAssistantPro.statusText.Text := "Status: Workflow '" . key . "' complete."
        SmartAssistantPro.AppendLog("Workflow completed: " . key)
    }

    static ShowTime() {
        timeStr := ""
        timeStr := FormatTime(, "HH:mm:ss")
        SmartAssistantPro.AppendLog("Current time: " . timeStr)
    }

    static ShowDate() {
        dateStr := ""
        dateStr := FormatTime(, "dddd, MMMM dd, yyyy")
        SmartAssistantPro.AppendLog("Today's date: " . dateStr)
    }

    static ShowWeather() {
        SmartAssistantPro.AppendLog("Weather (simulated): Sunny, 72°F / 22°C.")
    }

    static TakeScreenshot() {
        SmartAssistantPro.AppendLog("Screenshot captured (placeholder).")
    }

    static CreateNote(text := "") {
        content := text
        if (!content) {
            result := InputBox("Enter note text:", "Create Note")
            if (result.Result != "OK") {
                SmartAssistantPro.AppendLog("Note creation cancelled.")
                return
            }
            content := Trim(result.Value)
            if (!content) {
                SmartAssistantPro.AppendLog("Empty note ignored.")
                return
            }
        }
        timestamp := ""
        timestamp := FormatTime(, "yyyy-MM-dd HH:mm:ss")
        line := "[" . timestamp . "] " . content . "`n"
        try {
            FileAppend(line, A_ScriptDir . "\smart_assistant_notes.txt", "UTF-8")
            SmartAssistantPro.AppendLog("Note saved: " . content)
        } catch as err {
            SmartAssistantPro.AppendLog("Failed to save note: " . err.Message)
        }
    }

    static EnableFocusMode() {
        SmartAssistantPro.AppendLog("Focus mode enabled (simulation).")
    }

    static DisableFocusMode() {
        SmartAssistantPro.AppendLog("Focus mode disabled (simulation).")
    }

    static StartBreak() {
        SmartAssistantPro.AppendLog("Break timer started (simulation).")
    }

    static AppendLog(text) {
        if (!SmartAssistantPro.outputEdit) {
            return
        }
        timestamp := ""
        timestamp := FormatTime(, "HH:mm:ss")
        SmartAssistantPro.outputEdit.Value .= "[" . timestamp . "] " . text . "`n"
        SmartAssistantPro.outputEdit.SendMessage(0x00B7, 0, 0)  ; scroll to bottom
    }
}

; ------------------------------------------------------------------------------
; CLI support and script entry
if (A_Args.Length > 0) {
    SmartAssistantPro.Init()
    for index, arg in A_Args {
        if (arg = "--workflow" && index < A_Args.Length) {
            SmartAssistantPro.RunWorkflow(A_Args[index + 1])
        } else if (arg = "--command" && index < A_Args.Length) {
            SmartAssistantPro.ExecuteCommand(A_Args[index + 1])
        }
    }
} else {
    SmartAssistantPro.Init()
}

