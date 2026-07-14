#Requires AutoHotkey v2.0+
#SingleInstance Force
#Include %A_ScriptDir%\lib\ScriptletErrorHandler.ahk

OnError(LogError)

class MCPDevelopmentCycle {
    static phases := []
    static gui := ""
    static phaseList := ""
    static detailEdit := ""
    static logEdit := ""
    static statusBar := ""
    static projectNameEdit := ""
    static descriptionEdit := ""
    static projectRoot := A_ScriptDir . "\mcp_projects"
    static logFile := A_ScriptDir . "\mcp_development_cycle.log"
    static hotkeysRegistered := false

    static Init() {
        MCPDevelopmentCycle.AppendLog("Initializing MCP Development Cycle")
        MCPDevelopmentCycle.BuildPhaseModel()
        if (!MCPDevelopmentCycle.gui) {
            MCPDevelopmentCycle.CreateGui()
            MCPDevelopmentCycle.SetupHotkeys()
        }
        MCPDevelopmentCycle.RefreshPhaseList()
        MCPDevelopmentCycle.gui.Show("w1020 h860 Center")
        MCPDevelopmentCycle.statusBar.SetText("Ready. Press Ctrl+Alt+D to start the development cycle.")
    }


    static AppendLog(message) {
        timestamp := FormatTime(A_Now, "yyyy-MM-dd HH:mm:ss")
        entry := "[" . timestamp . "] " . message
        try {
            FileAppend(entry . "`n", MCPDevelopmentCycle.logFile, "UTF-8")
        } catch {
        }
        if (MCPDevelopmentCycle.logEdit) {
            MCPDevelopmentCycle.logEdit.Value .= entry . "`n"
            MCPDevelopmentCycle.logEdit.Redraw()
        }
        OutputDebug(entry)
    }

    static BuildPhaseModel() {
        phases := []
        phases.Push(MCPDevelopmentCycle.CreatePhase("Phase 1: Planning", "Define requirements and architecture", [
            "Gather MCP server requirements",
            "Outline server architecture and interfaces",
            "List required FastMCP tools",
            "Prepare project repository",
            "Confirm Claude Desktop integration plan"
        ]))
        phases.Push(MCPDevelopmentCycle.CreatePhase("Phase 2: Development", "Implement core functionality", [
            "Bootstrap FastMCP server",
            "Register tool handlers",
            "Implement error handling and validation",
            "Add configuration management",
            "Create logging and observability hooks"
        ]))
        phases.Push(MCPDevelopmentCycle.CreatePhase("Phase 3: Testing", "Validate behaviour and performance", [
            "Unit test each tool",
            "Run integration tests with Claude Desktop",
            "Exercise error scenarios",
            "Capture performance metrics",
            "Document test evidence"
        ]))
        phases.Push(MCPDevelopmentCycle.CreatePhase("Phase 4: Deployment", "Package and release server", [
            "Build deployment artefacts",
            "Update Claude Desktop MCP configuration",
            "Deploy to staging/production environment",
            "Verify deployment health",
            "Prepare release notes"
        ]))
        phases.Push(MCPDevelopmentCycle.CreatePhase("Phase 5: Maintenance", "Sustain and evolve server", [
            "Monitor telemetry and logs",
            "Capture user feedback",
            "Plan enhancements",
            "Triaging bug reports",
            "Refresh documentation"
        ]))
        MCPDevelopmentCycle.phases := phases
    }

    static CreatePhase(name, description, tasks) {
        return Map(
            "name", name,
            "description", description,
            "tasks", tasks,
            "status", "pending",
            "started", "",
            "completed", ""
        )
    }

    static CreateGui() {
        newGui := Gui("+Resize +MinSize1020x760", "MCP Development Cycle")
        newGui.BackColor := "1b1b1b"
        newGui.SetFont("s10 cFFFFFF", "Segoe UI")

        newGui.AddText("x20 y20 w980 Center Bold", "🚀 MCP Development Cycle")
        newGui.AddText("x20 y48 w980 Center cC0C0C0", "Guide MCP projects from planning through maintenance with structured phases and logging.")

        newGui.AddText("x20 y90 w980 Bold", "Project Overview")
        newGui.AddText("x20 y118 w120", "Project Name:")
        projectName := newGui.AddEdit("x150 y112 w280 h26", "my-mcp-project")
        newGui.AddText("x460 y118 w120", "Description:")
        description := newGui.AddEdit("x590 y112 w410 h26", "Comprehensive MCP server")

        newGui.AddText("x20 y150 w980", "Project Root: " . MCPDevelopmentCycle.projectRoot)

        newGui.AddText("x20 y188 w420 Bold", "Development Phases")
        phaseList := newGui.AddListView("x20 y216 w420 h360 -Hdr", ["Phase", "Status"])
        phaseList.OnEvent("ItemSelect", MCPDevelopmentCycle.OnPhaseSelected)
        MCPDevelopmentCycle.phaseList := phaseList

        newGui.AddText("x460 y188 w540 Bold", "Phase Details")
        detailEdit := newGui.AddEdit("x460 y216 w540 h360 ReadOnly Multi VScroll", "")
        detailEdit.BackColor := "262626"
        detailEdit.SetFont("s10", "Consolas")
        MCPDevelopmentCycle.detailEdit := detailEdit

        btnStart := newGui.AddButton("x20 y594 w200 h40", "▶️ Start Phase")
        btnStart.OnEvent("Click", MCPDevelopmentCycle.StartPhase)
        btnComplete := newGui.AddButton("x230 y594 w200 h40", "✅ Complete Phase")
        btnComplete.OnEvent("Click", MCPDevelopmentCycle.CompletePhase)
        btnSkip := newGui.AddButton("x440 y594 w200 h40", "⏭️ Skip Phase")
        btnSkip.OnEvent("Click", MCPDevelopmentCycle.SkipPhase)
        btnReset := newGui.AddButton("x650 y594 w200 h40", "🔄 Reset Phase")
        btnReset.OnEvent("Click", MCPDevelopmentCycle.ResetPhase)
        btnReport := newGui.AddButton("x860 y594 w140 h40", "📊 Phase Report")
        btnReport.OnEvent("Click", MCPDevelopmentCycle.ShowPhaseReport)

        newGui.AddText("x20 y646 w980 Bold", "Workflow Controls")
        btnDevStart := newGui.AddButton("x20 y676 w230 h44", "🚀 Start Development")
        btnDevStart.OnEvent("Click", MCPDevelopmentCycle.StartDevelopment)
        btnPause := newGui.AddButton("x260 y676 w230 h44", "⏸️ Pause Development")
        btnPause.OnEvent("Click", MCPDevelopmentCycle.PauseDevelopment)
        btnResetAll := newGui.AddButton("x500 y676 w230 h44", "♻️ Reset All Phases")
        btnResetAll.OnEvent("Click", MCPDevelopmentCycle.ResetAllPhases)
        btnProgress := newGui.AddButton("x740 y676 w230 h44", "📈 Progress Report")
        btnProgress.OnEvent("Click", MCPDevelopmentCycle.ShowProgressReport)

        newGui.AddText("x20 y730 w980 Bold", "Activity Log")
        logEdit := newGui.AddEdit("x20 y758 w980 h120 ReadOnly VScroll", "")
        logEdit.BackColor := "242424"
        logEdit.SetFont("s9", "Consolas")
        MCPDevelopmentCycle.logEdit := logEdit

        status := newGui.AddStatusBar("Simple")
        status.SetText("Ready")
        MCPDevelopmentCycle.statusBar := status

        MCPDevelopmentCycle.projectNameEdit := projectName
        MCPDevelopmentCycle.descriptionEdit := description

        newGui.OnEvent("Close", MCPDevelopmentCycle.HideGui)
        newGui.OnEvent("Escape", MCPDevelopmentCycle.HideGui)
        newGui.OnEvent("Size", MCPDevelopmentCycle.OnResize)
        MCPDevelopmentCycle.gui := newGui
    }

    static SetupHotkeys() {
        if (MCPDevelopmentCycle.hotkeysRegistered) {
            return
        }
        Hotkey("^!d", MCPDevelopmentCycle.StartDevelopment)
        Hotkey("^F12", MCPDevelopmentCycle.ShowProgressReport)
        Hotkey("F9", MCPDevelopmentCycle.HideGui)
        Hotkey("Escape", (*) => MCPDevelopmentCycle.gui && WinActive("ahk_id " MCPDevelopmentCycle.gui.Hwnd) && MCPDevelopmentCycle.HideGui())
        MCPDevelopmentCycle.hotkeysRegistered := true
    }

    static OnResize(gui, minMax, width, height) {
        if (!MCPDevelopmentCycle.gui) {
            return
        }
        padding := 20
        phaseWidth := 420
        listHeight := height - 320
        MCPDevelopmentCycle.phaseList.Move(padding, 216, phaseWidth, listHeight)
        MCPDevelopmentCycle.detailEdit.Move(padding + phaseWidth + 20, 216, width - phaseWidth - (padding * 2) - 20, listHeight)
        MCPDevelopmentCycle.logEdit.Move(padding, height - 140, width - padding * 2, 110)
    }

    static RefreshPhaseList() {
        if (!MCPDevelopmentCycle.phaseList) {
            return
        }
        MCPDevelopmentCycle.phaseList.Delete()
        for phase in MCPDevelopmentCycle.phases {
            status := phase["status"]
            symbol := status = "completed" ? "✅" : (status = "in_progress" ? "🔄" : "⏳")
            MCPDevelopmentCycle.phaseList.Add(, phase["name"], symbol . " " . status)
        }
        MCPDevelopmentCycle.phaseList.ModifyCol()
    }

    static OnPhaseSelected(*) {
        MCPDevelopmentCycle.UpdateDetails()
    }

    static UpdateDetails() {
        row := MCPDevelopmentCycle.phaseList.GetNext()
        if (row = 0) {
            MCPDevelopmentCycle.detailEdit.Value := "Select a phase to view details."
            return
        }
        phase := MCPDevelopmentCycle.phases[row]
        text := "Phase: " . phase["name"] . "`n"
        text .= "Status: " . phase["status"] . "`n"
        if (phase["started"]) {
            text .= "Started: " . phase["started"] . "`n"
        }
        if (phase["completed"]) {
            text .= "Completed: " . phase["completed"] . "`n"
        }
        text .= "`nDescription:`n" . phase["description"] . "`n`nTasks:`n"
        for index, task in phase["tasks"] {
            text .= index . ". " . task . "`n"
        }
        MCPDevelopmentCycle.detailEdit.Value := text
    }

    static StartPhase(*) {
        row := MCPDevelopmentCycle.GetSelectedRow()
        if (row = 0) {
            MsgBox("Select a phase first.", "MCP Development Cycle", "Icon!")
            return
        }
        phase := MCPDevelopmentCycle.phases[row]
        phase["status"] := "in_progress"
        started := FormatTime(A_Now, "yyyy-MM-dd HH:mm")
        phase["started"] := started
        MCPDevelopmentCycle.AppendLog("Phase started: " . phase["name"])
        MCPDevelopmentCycle.RefreshPhaseList()
        MCPDevelopmentCycle.UpdateDetails()
    }

    static CompletePhase(*) {
        row := MCPDevelopmentCycle.GetSelectedRow()
        if (row = 0) {
            MsgBox("Select a phase first.", "MCP Development Cycle", "Icon!")
            return
        }
        phase := MCPDevelopmentCycle.phases[row]
        phase["status"] := "completed"
        completed := FormatTime(A_Now, "yyyy-MM-dd HH:mm")
        phase["completed"] := completed
        MCPDevelopmentCycle.AppendLog("Phase completed: " . phase["name"])
        MCPDevelopmentCycle.RefreshPhaseList()
        MCPDevelopmentCycle.UpdateDetails()
    }

    static SkipPhase(*) {
        row := MCPDevelopmentCycle.GetSelectedRow()
        if (row = 0) {
            MsgBox("Select a phase first.", "MCP Development Cycle", "Icon!")
            return
        }
        confirm := MsgBox("Skip this phase and mark it completed?", "MCP Development Cycle", "Icon? YesNo")
        if (confirm != "Yes") {
            return
        }
        phase := MCPDevelopmentCycle.phases[row]
        phase["status"] := "completed"
        completed := FormatTime(A_Now, "yyyy-MM-dd HH:mm")
        phase["completed"] := completed
        MCPDevelopmentCycle.AppendLog("Phase skipped and marked complete: " . phase["name"])
        MCPDevelopmentCycle.RefreshPhaseList()
        MCPDevelopmentCycle.UpdateDetails()
    }

    static ResetPhase(*) {
        row := MCPDevelopmentCycle.GetSelectedRow()
        if (row = 0) {
            MsgBox("Select a phase first.", "MCP Development Cycle", "Icon!")
            return
        }
        confirm := MsgBox("Reset this phase to pending?", "MCP Development Cycle", "Icon? YesNo")
        if (confirm != "Yes") {
            return
        }
        phase := MCPDevelopmentCycle.phases[row]
        phase["status"] := "pending"
        phase["started"] := ""
        phase["completed"] := ""
        MCPDevelopmentCycle.AppendLog("Phase reset: " . phase["name"])
        MCPDevelopmentCycle.RefreshPhaseList()
        MCPDevelopmentCycle.UpdateDetails()
    }

    static ShowPhaseReport(*) {
        row := MCPDevelopmentCycle.GetSelectedRow()
        if (row = 0) {
            MsgBox("Select a phase first.", "MCP Development Cycle", "Icon!")
            return
        }
        phase := MCPDevelopmentCycle.phases[row]
        report := "📊 Phase Report`n`n"
        report .= "Name: " . phase["name"] . "`n"
        report .= "Status: " . phase["status"] . "`n"
        if (phase["started"]) {
            report .= "Started: " . phase["started"] . "`n"
        }
        if (phase["completed"]) {
            report .= "Completed: " . phase["completed"] . "`n"
        }
        report .= "`nTasks:`n"
        for task in phase["tasks"] {
            report .= "• " . task . "`n"
        }
        MsgBox(report, "MCP Development Cycle", "Iconi")
    }

    static StartDevelopment(*) {
        name := MCPDevelopmentCycle.projectNameEdit.Value
        if (Trim(name) = "") {
            MsgBox("Enter a project name before starting.", "MCP Development Cycle", "Icon!")
            return
        }
        target := MCPDevelopmentCycle.projectRoot . "\" . name
        try {
            if (!DirExist(MCPDevelopmentCycle.projectRoot)) {
                DirCreate(MCPDevelopmentCycle.projectRoot)
            }
            if (!DirExist(target)) {
                DirCreate(target)
            }
        } catch as e {
            MsgBox("Failed to prepare project directory: " . e.Message, "MCP Development Cycle", "Iconx")
            return
        }
        started := FormatTime(A_Now, "yyyy-MM-dd HH:mm")
        MCPDevelopmentCycle.phases[1]["status"] := "in_progress"
        MCPDevelopmentCycle.phases[1]["started"] := started
        MCPDevelopmentCycle.RefreshPhaseList()
        MCPDevelopmentCycle.phaseList.Modify(1, "Select")
        MCPDevelopmentCycle.UpdateDetails()
        TrayTip("MCP Development Cycle", "Development cycle started")
        MCPDevelopmentCycle.AppendLog("Development cycle started for project " . name)
        MCPDevelopmentCycle.statusBar.SetText("Development cycle in progress for " . name)
    }

    static PauseDevelopment(*) {
        row := MCPDevelopmentCycle.GetSelectedRow()
        phaseName := row ? MCPDevelopmentCycle.phases[row]["name"] : "(none selected)"
        MsgBox("Development paused." . "`nCurrent focus: " . phaseName, "MCP Development Cycle", "Iconi")
        MCPDevelopmentCycle.AppendLog("Development paused at phase " . phaseName)
    }

    static ResetAllPhases(*) {
        confirm := MsgBox("Reset all phases to pending?", "MCP Development Cycle", "Icon? YesNo")
        if (confirm != "Yes") {
            return
        }
        for phase in MCPDevelopmentCycle.phases {
            phase["status"] := "pending"
            phase["started"] := ""
            phase["completed"] := ""
        }
        MCPDevelopmentCycle.RefreshPhaseList()
        MCPDevelopmentCycle.detailEdit.Value := "Phases reset. Select a phase to view details."
        MCPDevelopmentCycle.AppendLog("All phases reset to pending")
    }

    static ShowProgressReport(*) {
        total := MCPDevelopmentCycle.phases.Length
        completed := 0
        inProgress := 0
        for phase in MCPDevelopmentCycle.phases {
            switch phase["status"] {
                case "completed": completed += 1
                case "in_progress": inProgress += 1
            }
        }
        pending := total - completed - inProgress
        percent := total ? Round((completed / total) * 100) : 0
        report := "📈 MCP Development Progress`n`n"
        report .= "Completed: " . completed . "`n"
        report .= "In Progress: " . inProgress . "`n"
        report .= "Pending: " . pending . "`n"
        report .= "Overall Progress: " . percent . "%"
        MsgBox(report, "MCP Development Cycle", "Iconi")
        MCPDevelopmentCycle.AppendLog("Progress report viewed")
    }

    static GetSelectedRow() {
        row := MCPDevelopmentCycle.phaseList.GetNext()
        return row
    }

    static HideGui(*) {
        if !MCPDevelopmentCycle.gui
            return
        if !WinActive("ahk_id " MCPDevelopmentCycle.gui.Hwnd)
            return
        MCPDevelopmentCycle.gui.Hide()
        MCPDevelopmentCycle.statusBar.SetText("GUI hidden. Press Ctrl+Alt+D to resume.")
    }
        }
    }
}

MCPDevelopmentCycle.Init()

OnExit((*) => MCPDevelopmentCycle.AppendLog("Script exiting."))


