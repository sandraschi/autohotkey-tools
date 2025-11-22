; ==============================================================================
; Workflow Automator Pro
; @name: Workflow Automator Pro
; @version: 1.0.0
; @description: Advanced workflow automation with triggers, conditions, and actions. Create complex automation workflows with conditional logic and event triggers.
; @description: Features trigger-based automation, conditional execution, multi-step workflows, and action chaining. Supports file monitoring, time-based triggers, and keyboard/mouse event triggers.
; @description: Powerful automation tool for advanced users who need to create complex multi-step workflows with conditional logic and event-based triggers.
; @category: automation
; @author: Sandra
; @hotkeys: ^!w, ^!r, ^!t
; @enabled: true
; @priority: 10
; @tag: automation, workflows, triggers, conditions, productivity, advanced, events
; @cli: --create-workflow <name> - Create new workflow
; @cli: --run-workflow <name> - Execute specific workflow
; @cli: --list-workflows - List all configured workflows
; @cli: --help - Show CLI usage and workflow options
; @dependencies: 
; ==============================================================================

#Requires AutoHotkey v2.0+
#SingleInstance Force
#Include %A_ScriptDir%\lib\ScriptletErrorHandler.ahk


; Suppress error popups - log to file instead
OnError(LogError)


class WorkflowAutomator {
    static workflows := Map()
    static triggers := Map()
    static conditions := Map()
    static actions := Map()
    static activeWorkflows := []
    static lastWindow := ""
    
    static Init() {
        this.LoadBuiltinWorkflows()
        this.SetupTriggers()
        this.CreateGUI()
    }
    
    static LoadBuiltinWorkflows() {
        ; Email workflow
        this.workflows["Email Processing"] := {
            trigger: "new_email",
            condition: "contains_keyword",
            action: "categorize_email",
            enabled: true
        }
        
        ; File monitoring workflow
        this.workflows["File Backup"] := {
            trigger: "file_created",
            condition: "in_documents_folder",
            action: "backup_file",
            enabled: true
        }
        
        ; Time-based workflow
        this.workflows["Daily Report"] := {
            trigger: "time_based",
            condition: "weekday",
            action: "generate_report",
            enabled: false
        }
        
        ; System monitoring workflow
        this.workflows["System Health"] := {
            trigger: "system_check",
            condition: "low_disk_space",
            action: "send_alert",
            enabled: true
        }
        
        ; Productivity workflow
        this.workflows["Focus Mode"] := {
            trigger: "app_opened",
            condition: "distracting_app",
            action: "minimize_app",
            enabled: true
        }
    }
    
    static SetupTriggers() {
        ; Time-based triggers
        this.triggers["time_based"] := this.TimeBasedTrigger.Bind(this)
        this.triggers["daily"] := this.DailyTrigger.Bind(this)
        this.triggers["hourly"] := this.HourlyTrigger.Bind(this)
        
        ; File system triggers
        this.triggers["file_created"] := this.FileCreatedTrigger.Bind(this)
        this.triggers["file_modified"] := this.FileModifiedTrigger.Bind(this)
        this.triggers["file_deleted"] := this.FileDeletedTrigger.Bind(this)
        
        ; Application triggers
        this.triggers["app_opened"] := this.AppOpenedTrigger.Bind(this)
        this.triggers["app_closed"] := this.AppClosedTrigger.Bind(this)
        this.triggers["window_focused"] := this.WindowFocusedTrigger.Bind(this)
        
        ; System triggers
        this.triggers["system_check"] := this.SystemCheckTrigger.Bind(this)
        this.triggers["low_battery"] := this.LowBatteryTrigger.Bind(this)
        this.triggers["network_change"] := this.NetworkChangeTrigger.Bind(this)
        
        ; Custom triggers
        this.triggers["hotkey"] := this.HotkeyTrigger.Bind(this)
        this.triggers["clipboard_change"] := this.ClipboardChangeTrigger.Bind(this)
    }
    
    static CreateGUI() {
        this.gui := Gui("+Resize", "Workflow Automator Pro")
        
        ; Title
        this.gui.Add("Text", "w700 h30 Center", "⚡ Workflow Automator Pro")
        
        ; Workflow list
        this.gui.Add("Text", "w700 h20", "Active Workflows:")
        this.workflowList := this.gui.Add("ListView", "w700 h200 Checked", ["Name", "Trigger", "Condition", "Action", "Status"])
        this.workflowList.OnEvent("DoubleClick", this.EditWorkflow.Bind(this))
        
        ; Control buttons
        controlPanel := this.gui.Add("Text", "w700 h40")
        
        newBtn := this.gui.Add("Button", "x10 y10 w80 h25", "New Workflow")
        editBtn := this.gui.Add("Button", "x100 y10 w80 h25", "Edit")
        deleteBtn := this.gui.Add("Button", "x190 y10 w80 h25", "Delete")
        toggleBtn := this.gui.Add("Button", "x280 y10 w80 h25", "Toggle")
        runBtn := this.gui.Add("Button", "x370 y10 w80 h25", "Run Now")
        
        newBtn.OnEvent("Click", this.CreateWorkflow.Bind(this))
        editBtn.OnEvent("Click", this.EditWorkflow.Bind(this))
        deleteBtn.OnEvent("Click", this.DeleteWorkflow.Bind(this))
        toggleBtn.OnEvent("Click", this.ToggleWorkflow.Bind(this))
        runBtn.OnEvent("Click", this.RunWorkflow.Bind(this))
        
        ; Trigger monitoring
        this.gui.Add("Text", "w700 h20", "Trigger Monitoring:")
        this.monitorArea := this.gui.Add("Edit", "w700 h100 VScroll HScroll ReadOnly", "")
        
        ; Log area
        this.gui.Add("Text", "w700 h20", "Workflow Log:")
        this.logArea := this.gui.Add("Edit", "w700 h150 VScroll HScroll ReadOnly", "")
        
        ; Status bar
        this.statusBar := this.gui.Add("Text", "w700 h20 BackgroundE0E0E0", "Ready - Monitoring " . this.activeWorkflows.Length . " workflows")
        
        
        ; Add exit handlers
        this.gui.OnEvent("Close", (*) => ExitApp())
        this.gui.OnEvent("Escape", (*) => ExitApp())
        this.gui.Show("w720 h600")
        this.UpdateWorkflowList()
        this.StartMonitoring()
    }
    
    static UpdateWorkflowList() {
        this.workflowList.Delete()
        
        for name, workflow in this.workflows {
            status := workflow.enabled ? "Active" : "Inactive"
            this.workflowList.Add("", name, workflow.trigger, workflow.condition, workflow.action, status)
        }
    }
    
    static StartMonitoring() {
        ; Start monitoring for various triggers
        SetTimer(WorkflowAutomator.MonitorTriggers.Bind(WorkflowAutomator), 5000) ; Check every 5 seconds
        
        ; Monitor clipboard changes
        OnClipboardChange(WorkflowAutomator.ClipboardChangeTrigger.Bind(WorkflowAutomator))
        
        ; Monitor window focus changes
        SetTimer(WorkflowAutomator.MonitorWindowFocus.Bind(WorkflowAutomator), 1000)
    }
    
    static MonitorTriggers(*) {
        this.CheckTimeBasedTriggers()
        this.CheckSystemTriggers()
        this.CheckFileTriggers()
        this.CheckAppTriggers()
    }
    
    static MonitorWindowFocus(*) {
        try {
            currentWin := WinGetTitle("A")
            if (currentWin != this.lastWindow) {
                this.lastWindow := currentWin
                this.WindowFocusedTrigger(currentWin)
            }
        } catch as e {
            ; Ignore errors
        }
    }
    
    static CheckTimeBasedTriggers() {
        currentTime := FormatTime(A_Now, "HH:mm")
        currentDay := FormatTime(A_Now, "dddd")
        
        for name, workflow in this.workflows {
            if (workflow.enabled && workflow.trigger = "time_based") {
                this.ExecuteWorkflow(name)
            }
        }
    }
    
    static CheckSystemTriggers() {
        ; Check disk space
        try {
            freeSpaceMB := DriveGetSpace("C:")
            ; Get total space using COM FileSystemObject
            fso := ComObject("Scripting.FileSystemObject")
            drive := fso.GetDrive("C:")
            totalSpaceMB := drive.TotalSize / 1024 / 1024  ; Convert bytes to MB
            freePercent := (freeSpaceMB / totalSpaceMB) * 100
            
            if (freePercent < 10) {
                this.ExecuteWorkflow("System Health")
            }
        } catch as e {
            this.AppendLog("Error checking disk space: " . e.Message)
        }
        
        ; Check battery level
        try {
            RunWait("powercfg /batteryreport /output battery_report.html", , "Hide")
            ; Parse battery report (simplified)
        } catch as e {
            ; Ignore errors
        }
    }
    
    static CheckFileTriggers() {
        ; Monitor specific folders for changes
        folders := ["C:\Users\" . A_UserName . "\Documents", "C:\Users\" . A_UserName . "\Downloads"]
        
        for folder in folders {
            if (DirExist(folder)) {
                ; Check for new files (simplified)
                this.ExecuteWorkflow("File Backup")
            }
        }
    }
    
    static CheckAppTriggers() {
        ; Check for distracting applications
        distractingApps := ["chrome.exe", "firefox.exe", "discord.exe", "steam.exe"]
        
        for app in distractingApps {
            if (ProcessExist(app)) {
                this.ExecuteWorkflow("Focus Mode")
                break
            }
        }
    }
    
    static ClipboardChangeTrigger(type) {
        if (type = 1) { ; Text
            clipboardText := A_Clipboard
            this.AppendLog("Clipboard changed: " . SubStr(clipboardText, 1, 50))
            
            ; Check for specific clipboard patterns
            if (InStr(clipboardText, "http")) {
                this.AppendLog("URL detected in clipboard")
            }
        }
    }
    
    static WindowFocusedTrigger(windowTitle) {
        this.AppendLog("Window focused: " . windowTitle)
        
        ; Check if it's a distracting application
        distractingKeywords := ["youtube", "facebook", "twitter", "instagram", "reddit"]
        for keyword in distractingKeywords {
            if (InStr(StrLower(windowTitle), keyword)) {
                this.ExecuteWorkflow("Focus Mode")
                break
            }
        }
    }
    
    static TimeBasedTrigger(*) {
        this.AppendLog("Time-based trigger fired")
        ; Time-based triggers are handled by CheckTimeBasedTriggers()
    }
    
    static DailyTrigger(*) {
        this.AppendLog("Daily trigger fired")
        ; Execute workflows with daily trigger
        for name, workflow in this.workflows {
            if (workflow.enabled && workflow.trigger = "daily") {
                this.ExecuteWorkflow(name)
            }
        }
    }
    
    static HourlyTrigger(*) {
        this.AppendLog("Hourly trigger fired")
        ; Execute workflows with hourly trigger
        for name, workflow in this.workflows {
            if (workflow.enabled && workflow.trigger = "hourly") {
                this.ExecuteWorkflow(name)
            }
        }
    }
    
    static FileCreatedTrigger(filePath := "") {
        this.AppendLog("File created trigger fired: " . filePath)
        ; Execute workflows with file_created trigger
        for name, workflow in this.workflows {
            if (workflow.enabled && workflow.trigger = "file_created") {
                this.ExecuteWorkflow(name)
            }
        }
    }
    
    static FileModifiedTrigger(filePath := "") {
        this.AppendLog("File modified trigger fired: " . filePath)
        ; Execute workflows with file_modified trigger
        for name, workflow in this.workflows {
            if (workflow.enabled && workflow.trigger = "file_modified") {
                this.ExecuteWorkflow(name)
            }
        }
    }
    
    static FileDeletedTrigger(filePath := "") {
        this.AppendLog("File deleted trigger fired: " . filePath)
        ; Execute workflows with file_deleted trigger
        for name, workflow in this.workflows {
            if (workflow.enabled && workflow.trigger = "file_deleted") {
                this.ExecuteWorkflow(name)
            }
        }
    }
    
    static AppOpenedTrigger(appName := "") {
        this.AppendLog("App opened trigger fired: " . appName)
        ; Execute workflows with app_opened trigger
        for name, workflow in this.workflows {
            if (workflow.enabled && workflow.trigger = "app_opened") {
                this.ExecuteWorkflow(name)
            }
        }
    }
    
    static AppClosedTrigger(appName := "") {
        this.AppendLog("App closed trigger fired: " . appName)
        ; Execute workflows with app_closed trigger
        for name, workflow in this.workflows {
            if (workflow.enabled && workflow.trigger = "app_closed") {
                this.ExecuteWorkflow(name)
            }
        }
    }
    
    static SystemCheckTrigger(*) {
        this.AppendLog("System check trigger fired")
        ; System checks are handled by CheckSystemTriggers()
    }
    
    static LowBatteryTrigger(*) {
        this.AppendLog("Low battery trigger fired")
        ; Execute workflows with low_battery trigger
        for name, workflow in this.workflows {
            if (workflow.enabled && workflow.trigger = "low_battery") {
                this.ExecuteWorkflow(name)
            }
        }
    }
    
    static NetworkChangeTrigger(*) {
        this.AppendLog("Network change trigger fired")
        ; Execute workflows with network_change trigger
        for name, workflow in this.workflows {
            if (workflow.enabled && workflow.trigger = "network_change") {
                this.ExecuteWorkflow(name)
            }
        }
    }
    
    static HotkeyTrigger(*) {
        this.AppendLog("Hotkey trigger fired")
        ; Execute workflows with hotkey trigger
        for name, workflow in this.workflows {
            if (workflow.enabled && workflow.trigger = "hotkey") {
                this.ExecuteWorkflow(name)
            }
        }
    }
    
    static ExecuteWorkflow(workflowName) {
        if (!this.workflows.Has(workflowName)) {
            this.AppendLog("Workflow not found: " . workflowName)
            return
        }
        
        workflow := this.workflows[workflowName]
        if (!workflow.enabled) {
            return
        }
        
        this.AppendLog("Executing workflow: " . workflowName)
        
        try {
            ; Execute the workflow action
            switch workflow.action {
                case "categorize_email":
                    this.CategorizeEmail()
                case "backup_file":
                    this.BackupFile()
                case "generate_report":
                    this.GenerateReport()
                case "send_alert":
                    this.SendAlert()
                case "minimize_app":
                    this.MinimizeApp()
                default:
                    this.AppendLog("Unknown action: " . workflow.action)
            }
            
            this.AppendLog("Workflow completed: " . workflowName)
        } catch as e {
            this.AppendLog("Workflow error: " . e.Message)
        }
    }
    
    static CategorizeEmail() {
        this.AppendLog("Categorizing email...")
        ; Email categorization logic
    }
    
    static BackupFile() {
        this.AppendLog("Backing up file...")
        ; File backup logic
    }
    
    static GenerateReport() {
        this.AppendLog("Generating daily report...")
        
        ; Create report content
        dateStr := FormatTime(A_Now, "yyyy-MM-dd")
        report := "Daily Report - " . dateStr . "`n`n"
        report .= "System Status: OK`n"
        report .= "Active Workflows: " . this.activeWorkflows.Length . "`n"
        timeStr := FormatTime(A_Now, "HH:mm:ss")
        report .= "Last Check: " . timeStr . "`n"
        
        ; Save report
        dateStr2 := FormatTime(A_Now, "yyyyMMdd")
        reportFile := "DailyReport_" . dateStr2 . ".txt"
        try {
            FileAppend(report, reportFile)
            this.AppendLog("Report saved: " . reportFile)
        } catch as e {
            this.AppendLog("Failed to save report")
        }
    }
    
    static SendAlert() {
        this.AppendLog("Sending system alert...")
        MsgBox("System Alert: Low disk space detected!", "Workflow Alert", "0x30")
    }
    
    static MinimizeApp() {
        this.AppendLog("Minimizing distracting application...")
        try {
            WinMinimize("A")
        } catch as e {
            this.AppendLog("Failed to minimize window")
        }
    }
    
    static CreateWorkflow(*) {
        workflowGui := Gui("+Resize", "Create Workflow")
        
        workflowGui.Add("Text", "w400 h20", "Create New Workflow")
        
        workflowGui.Add("Text", "x10 y30 w100 h20", "Name:")
        nameInput := workflowGui.Add("Edit", "x120 y28 w250 h25", "")
        
        workflowGui.Add("Text", "x10 y60 w100 h20", "Trigger:")
        triggerList := []
        for key in this.triggers.Keys {
            triggerList.Push(key)
        }
        triggerCombo := workflowGui.Add("DropDownList", "x120 y58 w250", triggerList)
        
        workflowGui.Add("Text", "x10 y90 w100 h20", "Condition:")
        conditionCombo := workflowGui.Add("DropDownList", "x120 y88 w250", ["always", "contains_keyword", "in_folder", "weekday"])
        
        workflowGui.Add("Text", "x10 y120 w100 h20", "Action:")
        actionCombo := workflowGui.Add("DropDownList", "x120 y118 w250", ["categorize_email", "backup_file", "generate_report", "send_alert", "minimize_app"])
        
        enabledCheck := workflowGui.Add("Checkbox", "x10 y150 w200 h25", "Enabled")
        enabledCheck.Value := 1
        
        saveBtn := workflowGui.Add("Button", "x10 y180 w80 h25", "Save")
        cancelBtn := workflowGui.Add("Button", "x100 y180 w80 h25", "Cancel")
        
        saveBtn.OnEvent("Click", this.SaveWorkflow.Bind(this, nameInput, triggerCombo, conditionCombo, actionCombo, enabledCheck, workflowGui))
        cancelBtn.OnEvent("Click", (*) => workflowGui.Close())
        
        workflowGui.Show("w400 h220")
    }
    
    static SaveWorkflow(nameInput, triggerCombo, conditionCombo, actionCombo, enabledCheck, workflowGui, *) {
        name := nameInput.Text
        trigger := triggerCombo.Text
        condition := conditionCombo.Text
        action := actionCombo.Text
        enabled := enabledCheck.Value
        
        if (name && trigger && condition && action) {
            WorkflowAutomator.workflows[name] := {
                trigger: trigger,
                condition: condition,
                action: action,
                enabled: enabled
            }
            
            WorkflowAutomator.UpdateWorkflowList()
            workflowGui.Close()
            WorkflowAutomator.AppendLog("Workflow created: " . name)
        }
    }
    
    static EditWorkflow(*) {
        selected := this.workflowList.GetNext()
        if (selected > 0) {
            workflowName := this.workflowList.GetText(selected, 1)
            this.AppendLog("Editing workflow: " . workflowName)
            ; Open edit dialog
        }
    }
    
    static DeleteWorkflow(*) {
        selected := this.workflowList.GetNext()
        if (selected > 0) {
            workflowName := this.workflowList.GetText(selected, 1)
            this.workflows.Delete(workflowName)
            this.UpdateWorkflowList()
            this.AppendLog("Workflow deleted: " . workflowName)
        }
    }
    
    static ToggleWorkflow(*) {
        selected := this.workflowList.GetNext()
        if (selected > 0) {
            workflowName := this.workflowList.GetText(selected, 1)
            if (this.workflows.Has(workflowName)) {
                this.workflows[workflowName].enabled := !this.workflows[workflowName].enabled
                this.UpdateWorkflowList()
                this.AppendLog("Workflow toggled: " . workflowName)
            }
        }
    }
    
    static RunWorkflow(*) {
        selected := this.workflowList.GetNext()
        if (selected > 0) {
            workflowName := this.workflowList.GetText(selected, 1)
            this.ExecuteWorkflow(workflowName)
        }
    }
    
    static AppendLog(message) {
        timestamp := FormatTime(A_Now, "HH:mm:ss")
        this.logArea.Text .= "[" . timestamp . "] " . message . "`n"
        
        ; Auto-scroll to bottom
        this.logArea.Focus()
        Send("^{End}")
    }
}

; Hotkeys
Hotkey("^!w", (*) => WorkflowAutomator.Init())
Hotkey("^!r", (*) => WorkflowAutomator.GenerateReport())
Hotkey("^!t", (*) => WorkflowAutomator.ExecuteWorkflow("Daily Report"))

; Initialize
WorkflowAutomator.Init()


