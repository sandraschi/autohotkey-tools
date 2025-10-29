; ==============================================================================
; MCP Development Cycle
; @name: MCP Development Cycle
; @version: 1.0.0
; @description: Orchestrate complete MCP development workflow from idea to deployment. Manages the full development lifecycle for MCP servers with phase tracking and automation.
; @description: Features phase management (planning, development, testing, deployment), progress tracking, automated commands, and workflow orchestration. Supports skipping phases, resetting progress, and comprehensive development oversight.
; @description: Essential tool for MCP developers who need structured workflow management and automated development cycle tracking from initial concept to production deployment.
; @category: development
; @author: Sandra
; @hotkeys: ^!d, Ctrl+F12
; @enabled: true
; @priority: 5
; @tag: mcp, development, workflow, automation, lifecycle, orchestration, productivity
; @cli: --phase <num> - Jump to specific development phase
; @cli: --skip - Skip current phase
; @cli: --reset - Reset all phases to initial state
; @cli: --help - Show CLI usage and workflow options
; @dependencies: 
; ==============================================================================

#Requires AutoHotkey v2.0+
#SingleInstance Force


; Suppress error popups - log to file instead
OnError(LogError)

LogError(Thrown, Mode) {
    errorMsg := "Error: " . Thrown.Message . " at line " . Thrown.Line . "`n" . Thrown.Stack
    FileAppend(errorMsg, "mcp_development_cycle_errors.log", "UTF-8")
    OutputDebug(errorMsg)  ; Enable LLM debugging
    return 1  ; Suppress popup (1 = suppress, 0 = show)
}


class MCPDevelopmentCycle {
    static projectDir := ""
    static currentPhase := 1
    static phases := []
    
    static Init() {
        this.projectDir := A_ScriptDir . "\mcp_projects"
        this.InitializePhases()
        this.CreateGUI()
    }
    
    static InitializePhases() {
        this.phases := [
            {
                name: "Phase 1: Planning",
                description: "Define requirements and architecture",
                tasks: [
                    "Define MCP server purpose and scope",
                    "Identify required tools and capabilities", 
                    "Plan data models and interfaces",
                    "Create project structure",
                    "Set up development environment"
                ],
                status: "pending"
            },
            {
                name: "Phase 2: Development",
                description: "Implement core functionality",
                tasks: [
                    "Create main server file with FastMCP",
                    "Implement tool registration",
                    "Add error handling and validation",
                    "Create configuration management",
                    "Add logging and monitoring"
                ],
                status: "pending"
            },
            {
                name: "Phase 3: Testing",
                description: "Validate functionality and performance",
                tasks: [
                    "Unit test individual tools",
                    "Integration test with Claude Desktop",
                    "Performance testing and optimization",
                    "Error scenario testing",
                    "User acceptance testing"
                ],
                status: "pending"
            },
            {
                name: "Phase 4: Deployment",
                description: "Package and deploy MCP server",
                tasks: [
                    "Create deployment package",
                    "Update Claude Desktop configuration",
                    "Deploy to target environment",
                    "Monitor initial usage",
                    "Document deployment process"
                ],
                status: "pending"
            },
            {
                name: "Phase 5: Maintenance",
                description: "Ongoing support and improvements",
                tasks: [
                    "Monitor server performance",
                    "Collect user feedback",
                    "Plan feature enhancements",
                    "Handle bug reports",
                    "Update documentation"
                ],
                status: "pending"
            }
        ]
    }
    
    static CreateGUI() {
        gui := Gui("+Resize +MinSize1000x800", "MCP Development Cycle")
        gui.BackColor := "1a1a1a"
        gui.SetFont("s10 cFFFFFF", "Segoe UI")
        
        ; Title
        gui.Add("Text", "x20 y20 w960 Center Bold", "🚀 MCP Development Cycle")
        gui.Add("Text", "x20 y50 w960 Center ", "Orchestrate complete MCP development workflow from idea to deployment")
        
        ; Project section
        gui.Add("Text", "x20 y90 w960 Bold", "📋 Project Information")
        
        ; Project name
        gui.Add("Text", "x20 y120 w150", "Project Name:")
        projectNameEdit := gui.Add("Edit", "x180 y115 w300 h25", "my-mcp-project")
        
        ; Project description
        gui.Add("Text", "x500 y120 w150", "Description:")
        descriptionEdit := gui.Add("Edit", "x660 y115 w300 h25", "A comprehensive MCP server")
        
        ; Project directory
        gui.Add("Text", "x20 y155 w150", "Project Directory:")
        gui.Add("Text", "x180 y155 w780 ", this.projectDir . "\my-mcp-project")
        
        ; Development phases
        gui.Add("Text", "x20 y190 w960 Bold", "🔄 Development Phases")
        
        ; Phase list
        phaseList := gui.Add("ListBox", "x20 y220 w400 h400")
        
        ; Phase details
        gui.Add("Text", "x440 y220 w540 Bold", "Phase Details")
        phaseDetailsEdit := gui.Add("Edit", "x440 y250 w540 h200 ReadOnly Multi VScroll", "")
        phaseDetailsEdit.BackColor := "2d2d2d"
        
        ; Phase controls
        gui.Add("Button", "x440 y460 w150 h40", "▶️ Start Phase").OnEvent("Click", this.StartPhase.Bind(this))
        gui.Add("Button", "x610 y460 w150 h40", "✅ Complete Phase").OnEvent("Click", this.CompletePhase.Bind(this))
        gui.Add("Button", "x780 y460 w150 h40", "⏭️ Skip Phase").OnEvent("Click", this.SkipPhase.Bind(this))
        gui.Add("Button", "x440 y510 w150 h40", "🔄 Reset Phase").OnEvent("Click", this.ResetPhase.Bind(this))
        gui.Add("Button", "x610 y510 w150 h40", "📋 Generate Tasks").OnEvent("Click", this.GenerateTasks.Bind(this))
        gui.Add("Button", "x780 y510 w150 h40", "📊 Phase Report").OnEvent("Click", this.PhaseReport.Bind(this))
        
        ; Workflow controls
        gui.Add("Text", "x20 y640 w960 Bold", "🎯 Workflow Controls")
        
        gui.Add("Button", "x20 y670 w200 h50", "🚀 Start Development").OnEvent("Click", this.StartDevelopment.Bind(this))
        gui.Add("Button", "x240 y670 w200 h50", "⏸️ Pause Development").OnEvent("Click", this.PauseDevelopment.Bind(this))
        gui.Add("Button", "x460 y670 w200 h50", "🔄 Reset All Phases").OnEvent("Click", this.ResetAllPhases.Bind(this))
        gui.Add("Button", "x680 y670 w200 h50", "📈 Progress Report").OnEvent("Click", this.ProgressReport.Bind(this))
        
        ; Status
        gui.Add("Text", "x20 y730 w960 Center ", "Hotkeys: Ctrl+Alt+D (Start Development) | Ctrl+F12 (Progress Report) | Select phase to view details")
        
        ; Store references
        gui.projectNameEdit := projectNameEdit
        gui.descriptionEdit := descriptionEdit
        gui.phaseList := phaseList
        gui.phaseDetailsEdit := phaseDetailsEdit
        
        ; Populate phase list
        this.PopulatePhaseList(gui)
        
        ; Set up hotkeys
        this.SetupHotkeys(gui)
        
        gui.Show("w1000 h800")
    }
    
    static PopulatePhaseList(gui) {
        phaseText := ""
        for i, phase in this.phases {
            statusIcon := phase.status = "completed" ? "✅" : (phase.status = "in_progress" ? "🔄" : "⏳")
            phaseText .= statusIcon . " " . phase.name . "`n"
        }
        gui.phaseList.Text := phaseText
    }
    
    static StartPhase(*) {
        try {
            selectedPhase := this.GetSelectedPhase()
            if (selectedPhase = 0) {
                MsgBox("Please select a phase to start.", "No Phase Selected", "Icon!")
                return
            }
            
            phase := this.phases[selectedPhase]
            phase.status := "in_progress"
            this.currentPhase := selectedPhase
            
            ; Update GUI
            this.PopulatePhaseList(GuiFromHwnd(WinGetID("MCP Development Cycle")))
            this.UpdatePhaseDetails(GuiFromHwnd(WinGetID("MCP Development Cycle")))
            
            ; Show phase start message
            startText := "🚀 Starting Phase: " . phase.name . "`n`n"
            startText .= "Description: " . phase.description . "`n`n"
            startText .= "Tasks to complete:`n"
            for task in phase.tasks {
                startText .= "• " . task . "`n"
            }
            startText .= "`nPress Complete Phase when finished."
            
            MsgBox(startText, "Phase Started", "Iconi")
            
        } catch as e {
            MsgBox("Error starting phase: " . e.Message, "Error", "Iconx")
        }
    }
    
    static CompletePhase(*) {
        try {
            selectedPhase := this.GetSelectedPhase()
            if (selectedPhase = 0) {
                MsgBox("Please select a phase to complete.", "No Phase Selected", "Icon!")
                return
            }
            
            phase := this.phases[selectedPhase]
            phase.status := "completed"
            
            ; Update GUI
            this.PopulatePhaseList(GuiFromHwnd(WinGetID("MCP Development Cycle")))
            
            ; Show completion message
            completionText := "✅ Phase Completed: " . phase.name . "`n`n"
            completionText .= "Great work! This phase has been marked as complete.`n`n"
            
            ; Check if there's a next phase
            if (selectedPhase < this.phases.Length) {
                nextPhase := this.phases[selectedPhase + 1]
                completionText .= "Next phase: " . nextPhase.name . "`n"
                completionText .= "Description: " . nextPhase.description
            } else {
                completionText .= "🎉 All phases completed! Your MCP development cycle is finished."
            }
            
            MsgBox(completionText, "Phase Completed", "Iconi")
            
        } catch as e {
            MsgBox("Error completing phase: " . e.Message, "Error", "Iconx")
        }
    }
    
    static SkipPhase(*) {
        try {
            selectedPhase := this.GetSelectedPhase()
            if (selectedPhase = 0) {
                MsgBox("Please select a phase to skip.", "No Phase Selected", "Icon!")
                return
            }
            
            result := MsgBox("Are you sure you want to skip this phase?`n`nThis will mark it as completed without doing the work.", "Confirm Skip", "Icon? YesNo")
            if (result = "Yes") {
                phase := this.phases[selectedPhase]
                phase.status := "completed"
                
                ; Update GUI
                this.PopulatePhaseList(GuiFromHwnd(WinGetID("MCP Development Cycle")))
                
                MsgBox("Phase skipped successfully.", "Phase Skipped", "Iconi")
            }
            
        } catch as e {
            MsgBox("Error skipping phase: " . e.Message, "Error", "Iconx")
        }
    }
    
    static ResetPhase(*) {
        try {
            selectedPhase := this.GetSelectedPhase()
            if (selectedPhase = 0) {
                MsgBox("Please select a phase to reset.", "No Phase Selected", "Icon!")
                return
            }
            
            result := MsgBox("Are you sure you want to reset this phase?`n`nThis will mark it as pending and clear any progress.", "Confirm Reset", "Icon? YesNo")
            if (result = "Yes") {
                phase := this.phases[selectedPhase]
                phase.status := "pending"
                
                ; Update GUI
                this.PopulatePhaseList(GuiFromHwnd(WinGetID("MCP Development Cycle")))
                
                MsgBox("Phase reset successfully.", "Phase Reset", "Iconi")
            }
            
        } catch as e {
            MsgBox("Error resetting phase: " . e.Message, "Error", "Iconx")
        }
    }
    
    static GenerateTasks(*) {
        try {
            selectedPhase := this.GetSelectedPhase()
            if (selectedPhase = 0) {
                MsgBox("Please select a phase to generate tasks for.", "No Phase Selected", "Icon!")
                return
            }
            
            phase := this.phases[selectedPhase]
            
            ; Generate detailed task breakdown
            taskText := "📋 Detailed Tasks for " . phase.name . "`n`n"
            taskText .= "Description: " . phase.description . "`n`n"
            taskText .= "Task Breakdown:`n`n"
            
            for i, task in phase.tasks {
                taskText .= (i) . ". " . task . "`n"
                taskText .= "   Status: Not Started`n"
                taskText .= "   Estimated Time: 30-60 minutes`n"
                taskText .= "   Dependencies: None`n`n"
            }
            
            taskText .= "Additional Recommendations:`n"
            taskText .= "• Use version control (Git) for all code changes`n"
            taskText .= "• Document all decisions and changes`n"
            taskText .= "• Test frequently during development`n"
            taskText .= "• Keep Claude Desktop configuration updated`n"
            
            MsgBox(taskText, "Generated Tasks", "Iconi")
            
        } catch as e {
            MsgBox("Error generating tasks: " . e.Message, "Error", "Iconx")
        }
    }
    
    static PhaseReport(*) {
        try {
            selectedPhase := this.GetSelectedPhase()
            if (selectedPhase = 0) {
                MsgBox("Please select a phase to generate report for.", "No Phase Selected", "Icon!")
                return
            }
            
            phase := this.phases[selectedPhase]
            
            reportText := "📊 Phase Report: " . phase.name . "`n`n"
            reportText .= "Status: " . phase.status . "`n"
            reportText .= "Description: " . phase.description . "`n`n"
            reportText .= "Tasks (" . phase.tasks.Length . " total):`n"
            
            for i, task in phase.tasks {
                reportText .= "• " . task . "`n"
            }
            
            reportText .= "`nPhase Metrics:`n"
            reportText .= "• Total Tasks: " . phase.tasks.Length . "`n"
            reportText .= "• Estimated Duration: 2-4 hours`n"
            reportText .= "• Complexity: Medium`n"
            reportText .= "• Dependencies: Previous phases`n"
            
            MsgBox(reportText, "Phase Report", "Iconi")
            
        } catch as e {
            MsgBox("Error generating phase report: " . e.Message, "Error", "Iconx")
        }
    }
    
    static StartDevelopment(*) {
        try {
            projectName := GuiFromHwnd(WinGetID("MCP Development Cycle")).projectNameEdit.Text
            description := GuiFromHwnd(WinGetID("MCP Development Cycle")).descriptionEdit.Text
            
            if (projectName = "") {
                MsgBox("Please enter a project name.", "No Project Name", "Icon!")
                return
            }
            
            ; Create project directory
            projectPath := this.projectDir . "\" . projectName
            if (!DirExist(projectPath)) {
                DirCreate(projectPath)
            }
            
            ; Start with Phase 1
            this.phases[1].status := "in_progress"
            this.currentPhase := 1
            
            ; Update GUI
            this.PopulatePhaseList(GuiFromHwnd(WinGetID("MCP Development Cycle")))
            
            startText := "🚀 MCP Development Started!`n`n"
            startText .= "Project: " . projectName . "`n"
            startText .= "Description: " . description . "`n"
            startText .= "Location: " . projectPath . "`n`n"
            startText .= "Starting with Phase 1: Planning`n"
            startText .= "Select the phase in the list to view details and begin work."
            
            MsgBox(startText, "Development Started", "Iconi")
            
        } catch as e {
            MsgBox("Error starting development: " . e.Message, "Error", "Iconx")
        }
    }
    
    static PauseDevelopment(*) {
        try {
            pauseText := "⏸️ Development Paused`n`n"
            pauseText .= "Current phase: " . this.phases[this.currentPhase].name . "`n"
            pauseText .= "Status: " . this.phases[this.currentPhase].status . "`n`n"
            pauseText .= "You can resume development at any time by selecting`n"
            pauseText .= "the current phase and continuing with tasks."
            
            MsgBox(pauseText, "Development Paused", "Iconi")
            
        } catch as e {
            MsgBox("Error pausing development: " . e.Message, "Error", "Iconx")
        }
    }
    
    static ResetAllPhases(*) {
        try {
            result := MsgBox("Are you sure you want to reset ALL phases?`n`nThis will mark all phases as pending and clear all progress.", "Confirm Reset All", "Icon? YesNo")
            if (result = "Yes") {
                for phase in this.phases {
                    phase.status := "pending"
                }
                this.currentPhase := 1
                
                ; Update GUI
                this.PopulatePhaseList(GuiFromHwnd(WinGetID("MCP Development Cycle")))
                
                MsgBox("All phases reset successfully.", "All Phases Reset", "Iconi")
            }
            
        } catch as e {
            MsgBox("Error resetting all phases: " . e.Message, "Error", "Iconx")
        }
    }
    
    static ProgressReport(*) {
        try {
            completedPhases := 0
            inProgressPhases := 0
            pendingPhases := 0
            
            for phase in this.phases {
                switch phase.status {
                    case "completed": completedPhases++
                    case "in_progress": inProgressPhases++
                    case "pending": pendingPhases++
                }
            }
            
            totalPhases := this.phases.Length
            progressPercent := Round((completedPhases / totalPhases) * 100)
            
            reportText := "📈 MCP Development Progress Report`n`n"
            reportText .= "Overall Progress: " . progressPercent . "%`n`n"
            reportText .= "Phase Status:`n"
            reportText .= "✅ Completed: " . completedPhases . "`n"
            reportText .= "🔄 In Progress: " . inProgressPhases . "`n"
            reportText .= "⏳ Pending: " . pendingPhases . "`n`n"
            
            if (this.currentPhase <= totalPhases) {
                currentPhase := this.phases[this.currentPhase]
                reportText .= "Current Phase: " . currentPhase.name . "`n"
                reportText .= "Status: " . currentPhase.status . "`n`n"
            }
            
            reportText .= "Next Steps:`n"
            if (inProgressPhases > 0) {
                reportText .= "• Complete current phase tasks`n"
            } else if (pendingPhases > 0) {
                reportText .= "• Start next pending phase`n"
            } else {
                reportText .= "• 🎉 All phases completed!`n"
            }
            
            MsgBox(reportText, "Progress Report", "Iconi")
            
        } catch as e {
            MsgBox("Error generating progress report: " . e.Message, "Error", "Iconx")
        }
    }
    
    static GetSelectedPhase() {
        try {
            if (WinExist("MCP Development Cycle")) {
                gui := GuiFromHwnd(WinGetID("MCP Development Cycle"))
                selectedText := gui.phaseList.Text
                
                ; Find which phase is selected (simplified)
                for i, phase in this.phases {
                    if (InStr(selectedText, phase.name)) {
                        return i
                    }
                }
            }
        } catch {
            ; Handle error
        }
        return 0
    }
    
    static UpdatePhaseDetails(gui) {
        try {
            selectedPhase := this.GetSelectedPhase()
            if (selectedPhase > 0) {
                phase := this.phases[selectedPhase]
                
                detailsText := "Phase: " . phase.name . "`n"
                detailsText .= "Status: " . phase.status . "`n"
                detailsText .= "Description: " . phase.description . "`n`n"
                detailsText .= "Tasks:`n"
                
                for i, task in phase.tasks {
                    detailsText .= (i) . ". " . task . "`n"
                }
                
                gui.phaseDetailsEdit.Text := detailsText
            }
        } catch {
            ; Handle error
        }
    }
    
    static ShowHelp(*) {
        helpText := "🚀 MCP Development Cycle Help`n`n"
        helpText .= "This tool orchestrates complete MCP development:`n`n"
        helpText .= "🔄 Development Phases:`n"
        helpText .= "1. Planning: Define requirements and architecture`n"
        helpText .= "2. Development: Implement core functionality`n"
        helpText .= "3. Testing: Validate functionality and performance`n"
        helpText .= "4. Deployment: Package and deploy MCP server`n"
        helpText .= "5. Maintenance: Ongoing support and improvements`n`n"
        helpText .= "🎯 Workflow Controls:`n"
        helpText .= "• Start Development: Begin the complete cycle`n"
        helpText .= "• Pause Development: Temporarily stop work`n"
        helpText .= "• Reset All Phases: Clear all progress`n"
        helpText .= "• Progress Report: View overall status`n`n"
        helpText .= "📋 Phase Management:`n"
        helpText .= "• Start Phase: Begin working on selected phase`n"
        helpText .= "• Complete Phase: Mark phase as finished`n"
        helpText .= "• Skip Phase: Mark as complete without work`n"
        helpText .= "• Reset Phase: Clear phase progress`n"
        helpText .= "• Generate Tasks: Get detailed task breakdown`n"
        helpText .= "• Phase Report: View phase status and metrics`n`n"
        helpText .= "Hotkeys:`n"
        helpText .= "• Ctrl+Alt+D: Start development`n"
        helpText .= "• Ctrl+F12: Progress report`n"
        helpText .= "• Escape: Close tool"
        
        MsgBox(helpText, "MCP Development Cycle Help", "Iconi")
    }
    
    static SetupHotkeys(gui) {
        Hotkey("^!d", (*) => this.StartDevelopment()
        Hotkey("^F12", (*) => this.ProgressReport()
        
        Escape::{
            if (WinExist("MCP Development Cycle")) {
                WinClose("MCP Development Cycle")
            }
        }
    }
}

; Hotkeys
Hotkey("^!d", (*) => MCPDevelopmentCycle.Init()
Hotkey("^F12", (*) => MCPDevelopmentCycle.Init()

; Initialize
MCPDevelopmentCycle.Init()


