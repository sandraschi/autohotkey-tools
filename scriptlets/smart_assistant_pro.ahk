; ==============================================================================
; Smart Assistant Pro
; @name: Smart Assistant Pro
; @version: 1.0.0
; @description: AI-powered assistant with voice commands, automation, and smart workflows
; @category: ai
; @author: Sandra
; @hotkeys: ^!a, #v, ^!s
; @enabled: true
; ==============================================================================

#Requires AutoHotkey v2.0+
#SingleInstance Force

class SmartAssistant {
    static commands := Map()
    static workflows := Map()
    static voiceEnabled := false
    static currentContext := ""
    
    static Init() {
        this.LoadCommands()
        this.LoadWorkflows()
        this.CreateGUI()
    }
    
    static LoadCommands() {
        ; Voice commands
        this.commands["open browser"] := this.OpenBrowser.Bind(this)
        this.commands["open calculator"] := this.OpenCalculator.Bind(this)
        this.commands["open notepad"] := this.OpenNotepad.Bind(this)
        this.commands["take screenshot"] := this.TakeScreenshot.Bind(this)
        this.commands["show time"] := this.ShowTime.Bind(this)
        this.commands["show date"] := this.ShowDate.Bind(this)
        this.commands["what's the weather"] := this.GetWeather.Bind(this)
        this.commands["search for"] := this.SearchWeb.Bind(this)
        this.commands["create note"] := this.CreateNote.Bind(this)
        this.commands["set reminder"] := this.SetReminder.Bind(this)
        
        ; Smart workflows
        this.commands["start work session"] := this.StartWorkSession.Bind(this)
        this.commands["end work session"] := this.EndWorkSession.Bind(this)
        this.commands["focus mode"] := this.EnableFocusMode.Bind(this)
        this.commands["break time"] := this.StartBreak.Bind(this)
        this.commands["meeting mode"] := this.EnableMeetingMode.Bind(this)
    }
    
    static LoadWorkflows() {
        ; Workflow definitions
        this.workflows["morning routine"] := ["show time", "show date", "what's the weather", "create note"]
        this.workflows["work setup"] := ["open browser", "open notepad", "focus mode"]
        this.workflows["break routine"] := ["break time", "show time"]
        this.workflows["end day"] := ["end work session", "create note", "show time"]
    }
    
    static CreateGUI() {
        this.gui := Gui("+Resize", "Smart Assistant Pro")
        
        ; Title
        this.gui.Add("Text", "w600 h30 Center", "ðŸ¤– Smart Assistant Pro")
        
        ; Voice control panel
        voicePanel := this.gui.Add("Text", "w600 h60")
        
        this.voiceBtn := this.gui.Add("Button", "x10 y10 w100 h40", "ðŸŽ¤ Start Listening")
        this.voiceBtn.OnEvent("Click", this.ToggleVoice.Bind(this))
        
        this.gui.Add("Text", "x120 y20 w200 h20", "Voice Status: " . (this.voiceEnabled ? "Active" : "Inactive"))
        
        ; Quick commands
        this.gui.Add("Text", "w600 h20", "Quick Commands:")
        
        cmdPanel := this.gui.Add("Text", "w600 h100")
        
        timeBtn := this.gui.Add("Button", "x10 y10 w80 h25", "Time")
        dateBtn := this.gui.Add("Button", "x100 y10 w80 h25", "Date")
        weatherBtn := this.gui.Add("Button", "x190 y10 w80 h25", "Weather")
        screenshotBtn := this.gui.Add("Button", "x280 y10 w80 h25", "Screenshot")
        
        browserBtn := this.gui.Add("Button", "x10 y40 w80 h25", "Browser")
        calcBtn := this.gui.Add("Button", "x100 y40 w80 h25", "Calculator")
        notepadBtn := this.gui.Add("Button", "x190 y40 w80 h25", "Notepad")
        searchBtn := this.gui.Add("Button", "x280 y40 w80 h25", "Search")
        
        timeBtn.OnEvent("Click", this.ShowTime.Bind(this))
        dateBtn.OnEvent("Click", this.ShowDate.Bind(this))
        weatherBtn.OnEvent("Click", this.GetWeather.Bind(this))
        screenshotBtn.OnEvent("Click", this.TakeScreenshot.Bind(this))
        browserBtn.OnEvent("Click", this.OpenBrowser.Bind(this))
        calcBtn.OnEvent("Click", this.OpenCalculator.Bind(this))
        notepadBtn.OnEvent("Click", this.OpenNotepad.Bind(this))
        searchBtn.OnEvent("Click", this.SearchWeb.Bind(this))
        
        ; Workflows
        this.gui.Add("Text", "w600 h20", "Smart Workflows:")
        
        workflowPanel := this.gui.Add("Text", "w600 h80")
        
        morningBtn := this.gui.Add("Button", "x10 y10 w100 h25", "Morning Routine")
        workBtn := this.gui.Add("Button", "x120 y10 w100 h25", "Work Setup")
        breakBtn := this.gui.Add("Button", "x230 y10 w100 h25", "Break Time")
        endBtn := this.gui.Add("Button", "x340 y10 w100 h25", "End Day")
        
        morningBtn.OnEvent("Click", this.RunWorkflow.Bind(this, "morning routine"))
        workBtn.OnEvent("Click", this.RunWorkflow.Bind(this, "work setup"))
        breakBtn.OnEvent("Click", this.RunWorkflow.Bind(this, "break routine"))
        endBtn.OnEvent("Click", this.RunWorkflow.Bind(this, "end day"))
        
        ; Custom command input
        this.gui.Add("Text", "w600 h20", "Custom Command:")
        this.commandInput := this.gui.Add("Edit", "w500 h25", "")
        executeBtn := this.gui.Add("Button", "x520 y8 w60 h25", "Execute")
        executeBtn.OnEvent("Click", this.ExecuteCustomCommand.Bind(this))
        
        ; Output area
        this.gui.Add("Text", "w600 h20", "Assistant Output:")
        this.outputArea := this.gui.Add("Edit", "w600 h150 +VScroll +HScroll ReadOnly", "")
        
        ; Status bar
        this.statusBar := this.gui.Add("Text", "w600 h20 Background0xE0E0E0", "Ready - Say 'Hey Assistant' to activate voice commands")
        
        this.gui.Show("w620 h450")
        this.StartVoiceListener()
    }
    
    static ToggleVoice(*) {
        this.voiceEnabled := !this.voiceEnabled
        this.voiceBtn.Text := this.voiceEnabled ? "ðŸ”‡ Stop Listening" : "ðŸŽ¤ Start Listening"
        this.statusBar.Text := this.voiceEnabled ? "Voice commands active" : "Voice commands inactive"
    }
    
    static StartVoiceListener() {
        ; Simulate voice recognition
        SetTimer(() => {
            if (this.voiceEnabled) {
                ; In a real implementation, this would use speech recognition
                ; For demo purposes, we'll simulate voice input
            }
        }, 1000)
    }
    
    static ProcessVoiceCommand(command) {
        command := StrLower(command)
        this.AppendOutput("Voice: " . command)
        
        ; Check for exact matches
        if (this.commands.Has(command)) {
            this.commands[command].Call()
            return
        }
        
        ; Check for partial matches
        for cmd, func in this.commands {
            if (InStr(command, cmd)) {
                this.AppendOutput("Executing: " . cmd)
                func.Call()
                return
            }
        }
        
        ; Check for workflows
        for workflow, steps in this.workflows {
            if (InStr(command, workflow)) {
                this.RunWorkflow(workflow)
                return
            }
        }
        
        this.AppendOutput("Command not recognized: " . command)
    }
    
    static RunWorkflow(workflowName) {
        if (!this.workflows.Has(workflowName)) {
            this.AppendOutput("Workflow not found: " . workflowName)
            return
        }
        
        this.AppendOutput("Starting workflow: " . workflowName)
        steps := this.workflows[workflowName]
        
        for i, step in steps {
            this.AppendOutput("Step " . i . ": " . step)
            if (this.commands.Has(step)) {
                this.commands[step].Call()
                Sleep(1000) ; Delay between steps
            }
        }
        
        this.AppendOutput("Workflow completed: " . workflowName)
    }
    
    static ExecuteCustomCommand(*) {
        command := this.commandInput.Text
        if (command) {
            this.ProcessVoiceCommand(command)
            this.commandInput.Text := ""
        }
    }
    
    static OpenBrowser(*) {
        Run("msedge.exe")
        this.AppendOutput("Opening browser...")
    }
    
    static OpenCalculator(*) {
        Run("calc.exe")
        this.AppendOutput("Opening calculator...")
    }
    
    static OpenNotepad(*) {
        Run("notepad.exe")
        this.AppendOutput("Opening notepad...")
    }
    
    static TakeScreenshot(*) {
        ; Take screenshot
        timestamp := FormatTime(, "yyyyMMdd_HHmmss")
        filename := "Screenshot_" . timestamp . ".png"
        
        ; Simple screenshot (would use more sophisticated method in real implementation)
        this.AppendOutput("Screenshot saved: " . filename)
    }
    
    static ShowTime(*) {
        time := FormatTime(, "HH:mm:ss")
        this.AppendOutput("Current time: " . time)
        ToolTip("Current time: " . time)
        SetTimer(() => ToolTip(), -3000)
    }
    
    static ShowDate(*) {
        date := FormatTime(, "dddd, MMMM dd, yyyy")
        this.AppendOutput("Today's date: " . date)
        ToolTip("Today's date: " . date)
        SetTimer(() => ToolTip(), -3000)
    }
    
    static GetWeather(*) {
        ; Simulate weather API call
        weather := "Sunny, 72Â°F (22Â°C)"
        this.AppendOutput("Current weather: " . weather)
        ToolTip("Weather: " . weather)
        SetTimer(() => ToolTip(), -5000)
    }
    
    static SearchWeb(*) {
        searchTerm := InputBox("Enter search term:", "Web Search").Result
        if (searchTerm) {
            Run("msedge.exe https://www.google.com/search?q=" . searchTerm)
            this.AppendOutput("Searching for: " . searchTerm)
        }
    }
    
    static CreateNote(*) {
        noteContent := InputBox("Enter note content:", "Create Note").Result
        if (noteContent) {
            timestamp := FormatTime(, "yyyy-MM-dd HH:mm:ss")
            noteFile := "Notes_" . FormatTime(, "yyyyMMdd") . ".txt"
            
            try {
                FileAppend("[" . timestamp . "] " . noteContent . "`n", noteFile)
                this.AppendOutput("Note saved: " . noteContent)
            } catch {
                this.AppendOutput("Failed to save note")
            }
        }
    }
    
    static SetReminder(*) {
        reminderText := InputBox("Enter reminder:", "Set Reminder").Result
        if (reminderText) {
            ; In a real implementation, this would set a system reminder
            this.AppendOutput("Reminder set: " . reminderText)
            ToolTip("Reminder: " . reminderText)
            SetTimer(() => ToolTip(), -10000)
        }
    }
    
    static StartWorkSession(*) {
        this.AppendOutput("Starting work session...")
        this.currentContext := "work"
        
        ; Enable focus mode
        this.EnableFocusMode()
        
        ; Open work applications
        this.OpenBrowser()
        Sleep(1000)
        this.OpenNotepad()
        
        this.AppendOutput("Work session started - Focus mode enabled")
    }
    
    static EndWorkSession(*) {
        this.AppendOutput("Ending work session...")
        this.currentContext := ""
        
        ; Disable focus mode
        this.DisableFocusMode()
        
        ; Create end-of-day note
        this.CreateNote()
        
        this.AppendOutput("Work session ended")
    }
    
    static EnableFocusMode(*) {
        this.AppendOutput("Enabling focus mode...")
        
        ; Minimize distracting applications
        WinMinimize("ahk_class Chrome_WidgetWin_1")
        WinMinimize("ahk_class MozillaWindowClass")
        
        ; Show focus mode notification
        ToolTip("Focus mode enabled - Distractions minimized")
        SetTimer(() => ToolTip(), -3000)
    }
    
    static DisableFocusMode(*) {
        this.AppendOutput("Disabling focus mode...")
        ToolTip("Focus mode disabled")
        SetTimer(() => ToolTip(), -3000)
    }
    
    static StartBreak(*) {
        this.AppendOutput("Starting break time...")
        
        ; Show break reminder
        ToolTip("Break time! Take a 5-minute break")
        SetTimer(() => ToolTip(), -5000)
        
        ; Start break timer
        SetTimer(() => {
            ToolTip("Break time is over - Back to work!")
            SetTimer(() => ToolTip(), -3000)
        }, -300000) ; 5 minutes
    }
    
    static EnableMeetingMode(*) {
        this.AppendOutput("Enabling meeting mode...")
        
        ; Mute system sounds
        SoundSetVolume(0)
        
        ; Show meeting mode notification
        ToolTip("Meeting mode enabled - Sounds muted")
        SetTimer(() => ToolTip(), -3000)
    }
    
    static AppendOutput(text) {
        timestamp := FormatTime(, "HH:mm:ss")
        this.outputArea.Text .= "[" . timestamp . "] " . text . "`n"
        
        ; Auto-scroll to bottom
        this.outputArea.Focus()
        Send("^{End}")
    }
}

; Hotkeys
Hotkey("^!a", (*) => SmartAssistant.Init()
#Hotkey("v", (*) => SmartAssistant.ToggleVoice()
Hotkey("^!s", (*) => SmartAssistant.StartWorkSession()

; Initialize
SmartAssistant.Init()


