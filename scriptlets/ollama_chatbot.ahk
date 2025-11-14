#Requires AutoHotkey v2.0+
#SingleInstance Force

OnError(OllamaChat.HandleError)

class OllamaChat {
    static gui := ""
    static historyCtrl := ""
    static inputCtrl := ""
    static statusCtrl := ""
    static endpoint := "http://localhost:11434"
    static model := "llama3"

    static Init() {
        OllamaChat.CreateGui()
        OllamaChat.SetupHotkeys()
        OllamaChat.AppendText("System", "Welcome to the Ollama chatstub. Configure a real endpoint to connect to your local model.")
    }

    static HandleError(Thrown, Mode) {
        message := "Ollama chat error: " . Thrown.Message . " at line " . Thrown.Line
        try FileAppend(message . "`n", "ollama_chatbot_errors.log", "UTF-8")
        OutputDebug(message)
        return 1
    }

    static CreateGui() {
        newGui := Gui("+Resize +MinSize420x400", "Ollama Chat")
        newGui.BackColor := "101820"
        newGui.SetFont("s10", "Segoe UI")

        header := newGui.AddText("x20 y16 w380 h24 c87CEFA", "Ollama Chat – local LLM interface")
        header.SetFont("s11", "Segoe UI")

        OllamaChat.historyCtrl := newGui.AddEdit("x20 y48 w380 h240 ReadOnly -Wrap VScroll", "")
        OllamaChat.historyCtrl.BackColor := "181818"
        OllamaChat.historyCtrl.SetFont("s10", "Consolas")

        OllamaChat.inputCtrl := newGui.AddEdit("x20 y300 w300 h80 -Wrap", "")
        sendBtn := newGui.AddButton("x330 y300 w70 h32", "Send")
        sendBtn.OnEvent("Click", (*) => OllamaChat.SendMessage())
        cfgBtn := newGui.AddButton("x330 y346 w70 h32", "Config")
        cfgBtn.OnEvent("Click", (*) => OllamaChat.OpenSettings())

        OllamaChat.statusCtrl := newGui.AddText("x20 y360 w380 h24 cFFFFFF", "Model: " . OllamaChat.model . " @ " . OllamaChat.endpoint)

        newGui.OnEvent("Close", OllamaChat.HideGui)
        newGui.OnEvent("Escape", OllamaChat.HideGui)
        newGui.OnEvent("Size", OllamaChat.OnResize)

        OllamaChat.gui := newGui
        newGui.Show("w420 h400")
    }

    static SetupHotkeys() {
        static registered := false
        if (registered) {
            return
        }
        Hotkey("^!o", (*) => OllamaChat.ShowGui())
        Hotkey("^!Enter", (*) => OllamaChat.SendMessage())
        Hotkey("^!q", (*) => OllamaChat.HideGui())
        registered := true
    }

    static ShowGui() {
        if (!OllamaChat.gui) {
            OllamaChat.CreateGui()
        }
        OllamaChat.gui.Show()
        OllamaChat.inputCtrl.Focus()
    }

    static HideGui(*) {
        if (OllamaChat.gui) {
            OllamaChat.gui.Hide()
        }
    }

    static AppendText(role, text) {
        if (!OllamaChat.historyCtrl) {
            return
        }
        prefix := Format("[{:%H:%M:%S}] {}: ", A_Now, role)
        OllamaChat.historyCtrl.Append(prefix . text . "`r`n")
        OllamaChat.historyCtrl.LineScroll(OllamaChat.historyCtrl.GetLineCount())
    }

    static SendMessage() {
        msg := Trim(OllamaChat.inputCtrl.Value)
        if (msg = "") {
            return
        }
        OllamaChat.AppendText("You", msg)
        OllamaChat.inputCtrl.Value := ""

        ; Placeholder response – mirror user input
        response := OllamaChat.GeneratePlaceholderReply(msg)
        OllamaChat.AppendText("Bot", response)
    }

    static GeneratePlaceholderReply(message) {
        if (StrLen(message) > 120) {
            return "I heard quite a lot from you! The Ollama backend is not configured, so here's a brief reflection: " . SubStr(message, 1, 120) . "..."
        }
        return "Echo: " . message . " (configure Ollama in settings for real responses)."
    }

    static OpenSettings() {
        dlg := Gui("+Owner" . OllamaChat.gui.Hwnd, "Ollama Settings")
        dlg.BackColor := "202830"
        dlg.SetFont("s10", "Segoe UI")

        dlg.AddText("x20 y20 w260 h24 cFFFFFF", "Ollama endpoint (http://host:port)")
        urlEdit := dlg.AddEdit("x20 y48 w260 h24", OllamaChat.endpoint)
        dlg.AddText("x20 y88 w260 h24 cFFFFFF", "Model name")
        modelEdit := dlg.AddEdit("x20 y116 w260 h24", OllamaChat.model)
        saveBtn := dlg.AddButton("x20 y156 w80 h28", "Save")
        cancelBtn := dlg.AddButton("x120 y156 w80 h28", "Cancel")

        saveBtn.OnEvent("Click", OllamaChat.SaveSettings.Bind(OllamaChat, dlg, urlEdit, modelEdit))
        cancelBtn.OnEvent("Click", OllamaChat.CloseDialog.Bind(OllamaChat, dlg))
        dlg.Show("w300 h210")
    }

    static UpdateStatus() {
        if (OllamaChat.statusCtrl) {
            OllamaChat.statusCtrl.Text := "Model: " . OllamaChat.model . " @ " . OllamaChat.endpoint
        }
    }

    static OnResize(gui, minMax, width, height) {
        if (!OllamaChat.historyCtrl) {
            return
        }
        OllamaChat.historyCtrl.Move(20, 48, width - 40, height - 160)
        OllamaChat.inputCtrl.Move(20, height - 100, width - 140, 80)
        if (OllamaChat.statusCtrl) {
            OllamaChat.statusCtrl.Move(20, height - 40, width - 40, 24)
        }
    }

    static SaveSettings(dlg, urlEdit, modelEdit, *) {
        OllamaChat.endpoint := Trim(urlEdit.Value)
        OllamaChat.model := Trim(modelEdit.Value)
        OllamaChat.UpdateStatus()
        dlg.Destroy()
    }

    static CloseDialog(dlg, *) {
        dlg.Destroy()
    }
}

OllamaChat.Init()

OnExit((*) => OllamaChat.HideGui())

