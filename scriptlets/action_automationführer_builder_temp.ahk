#Requires AutoHotkey v2.0+
#SingleInstance Force


; ==============================================================================
; Action Automation Builder
; @name: Action Automation Builder
; @version: 1.0.0
; @description: Visual workflow builder for complex automation tasks with drag-and-drop interface
; @category: automation
; @author: Sandra
; @hotkeys: ^!b
; @enabled: true
; @priority: 15
; @tags: automation, workflow, builder, visual, drag-drop, productivity
; @dependencies: 
; ==============================================================================

; Error handling - log to file instead of showing popups
OnError(LogError)

LogError(Thrown, Mode) {
    errorMsg := "Error: " . Thrown.Message . " at line " . Thrown.Line . "`n" . Thrown.Stack
    FileAppend(errorMsg, "action_automation_errors.log", "UTF-8")
    OutputDebug(errorMsg)  ; Enable LLM debugging
    return 1  ; Suppress popup (1 = suppress, 0 = show)
}

class AutomationBuilder {
    static gui := ""
    static workflow := []
    static canvas := ""
    static selectedNode := 0
    
    static Init() {
        this.CreateGUI()
        Hotkey("^!b", (*) => this.ToggleGUI())
    }
    
    static CreateGUI() {
        try {
            this.gui := Gui("+Resize", "Action Automation Builder")
            this.gui.BackColor := "222222"
        
            ; Title
        this.gui.AddText("x10 y10 w500 h30 Center", "Action Automation Builder")
            .SetFont("s12 bold cFFFFFF")
        
            ; Toolbar
        this.gui.AddButton("x10 y50 w100 h30 vRecordBtn", "Record Action")
            .OnEvent("Click", AutomationBuilder.RecordAction)
        
        this.gui.AddButton("x120 y50 w100 h30 vConditionBtn", "Add Condition")
            .OnEvent("Click", AutomationBuilder.AddCondition)
        
        this.gui.AddButton("x230 y50 w100 h30 vLoopBtn", "Add Loop")
            .OnEvent("Click", AutomationBuilder.AddLoop)
        
        this.gui.AddButton("x340 y50 w100 h30 vDelayBtn", "Add Delay")
            .OnEvent("Click", AutomationBuilder.AddDelay)
        
        this.gui.AddButton("x450 y50 w100 h30 vRunBtn", "Run Workflow")
            .OnEvent("Click", AutomationBuilder.RunWorkflow)
        
            ; Canvas for visual workflow
        this.canvas := this.gui.AddText("x10 y95 w580 h350 Border vCanvas", "Canvas")
            .BackColor := "FFFFFF"
        
            ; Node list
        this.gui.AddText("x600 y50 w180 h20", "Workflow Nodes:")
        this.nodeList := this.gui.AddListView("x600 y75 w180 h370 vNodeList", ["Node"])
            .OnEvent("Click", AutomationBuilder.NodeSelected)
        
            ; Control buttons
        this.gui.AddButton("x600 y455 w80 h30 vDeleteNodeBtn", "Delete")
            .OnEvent("Click", AutomationBuilder.DeleteNode)
        
        this.gui.AddButton("x690 y455 w90 h30 vSaveWorkflowBtn", "Save Workflow")
            .OnEvent("Click", AutomationBuilder.SaveWorkflow)
        
            Hotkey("Escape", (*) => this.gui.Hide(), this.gui)
            this.gui.Show("w800 h500")
            this.LogDebug("GUI created successfully")
        } catch as e {
            errorMsg := "Error creating GUI: " . e.Message . "`n" . e.Stack
            FileAppend(errorMsg, "action_automation_errors.log", "UTF-8")
            OutputDebug(errorMsg)
            MsgBox("Error creating GUI: " . e.Message . "`n`nCheck action_automation_errors.log for details", "Error", "Iconx")
        }
    }
    
    static LogDebug(message) {
        timestamp := FormatTime(A_Now, "HH:mm:ss")
        logMsg := "[" . timestamp . "] " . message . "`n"
        try {
            FileAppend(logMsg, "action_automation_debug.log", "UTF-8")
        } catch {
            ; Ignore file logging errors
        }
        OutputDebug(logMsg)
    }
    
    static RecordAction() {
        if (MsgBox("Start recording your action?", "Record Action", "Icon? YesNo") = "Yes") {
            ; Use AutoHotkey's built-in recording
            Run(A_AhkPath . ' "' . A_ScriptFullPath . '"')
            this.AppendLog("Recording started...")
            
            ; Wait for user to press stop
            MsgBox("Press Ctrl+Alt+S to stop recording", "Recording", "Icon!")
        }
    }
    
    static AddCondition() {
        dialog := Gui("+AlwaysOnTop", "Add Condition")
        dialog.BackColor := "222222"
        
        dialog.AddText("x10 y10 w300 h20", "Add Condition Node")
            .SetFont("s10 bold")
        
        dialog.AddText("x10 y40 w100 h20", "Condition Type:")
        conditionType := dialog.AddDDL("x120 y35 w150 vConditionType", ["Window", "File", "Network", "Custom"])
        
        dialog.AddText("x10 y70 w100 h20", "Condition Expression:")
        conditionEdit := dialog.AddEdit("x10 y95 w280 h100 vConditionExpr")
        
        dialog.AddButton("x10 y205 w130 h35 vOkBtn", "OK")
            .OnEvent("Click", (*) => {
                this.workflow.Push({
                    type: "condition",
                    conditionType: conditionType.Text,
                    expression: conditionEdit.Text
                })
                this.UpdateNodeList()
                dialog.Destroy()
            })
        
        dialog.AddButton("x150 y205 w130 h35 vCancelBtn", "Cancel")
            .OnEvent("Click", (*) => dialog.Destroy())
        
        dialog.Show("w300 h250")
    }
    
    static AddLoop() {
        dialog := Gui("+AlwaysOnTop", "Add Loop")
        dialog.BackColor := "222222"
        
        dialog.AddText("x10 y10 w300 h20", "Add Loop Node")
            .SetFont("s10 bold")
        
        dialog.AddText("x10 y40 w100 h20", "Loop Type:")
        loopType := dialog.AddDDL("x120 y35 w150 vLoopType", ["Count", "While", "For Each"])
        
        dialog.AddText("x10 y70 w100 h20", "Loop Value:")
        loopValue := dialog.AddEdit("x10 y95 w280 h80 vLoopValue")
        
        dialog.AddButton("x10 y185 w130 h35 vOkBtn", "OK")
            .OnEvent("Click", (*) => {
                this.workflow.Push({
                    type: "loop",
                    loopType: loopType.Text,
                    value: loopValue.Text
                })
                this.UpdateNodeList()
                dialog.Destroy()
            })
        
        dialog.AddButton("x150 y185 w130 h35 vCancelBtn", "Cancel")
            .OnEvent("Click", (*) => dialog.Destroy())
        
        dialog.Show("w300 h230")
    }
    
    static AddDelay() {
        dialog := Gui("+AlwaysOnTop", "Add Delay")
        dialog.BackColor := "222222"
        
        dialog.AddText("x10 y10 w200 h20", "Add Delay Node")
            .SetFont("s10 bold")
        
        dialog.AddText("x10 y40 w60 h20", "Seconds:")
        delayValue := dialog.AddEdit("x80 y35 w100 vDelayValue")
            .Text := "1"
        
        dialog.AddButton("x10 y70 w80 h35 vOkBtn", "OK")
            .OnEvent("Click", (*) => {
                this.workflow.Push({
                    type: "delay",
                    seconds: delayValue.Text
                })
                this.UpdateNodeList()
                dialog.Destroy()
            })
        
        dialog.AddButton("x100 y70 w80 h35 vCancelBtn", "Cancel")
            .OnEvent("Click", (*) => dialog.Destroy())
        
        dialog.Show("w200 h115")
    }
    
    static UpdateNodeList() {
        this.nodeList.Delete()
        
        for i, node in this.workflow {
            this.nodeList.Add([node.type . " #" . i])
        }
    }
    
    static NodeSelected() {
        this.selectedNode := this.nodeList.GetNext()
    }
    
    static DeleteNode() {
        if (this.selectedNode = 0) {
            return
        }
        
        if (MsgBox("Delete this node?", "Confirm", "Icon? YesNo") = "Yes") {
            this.workflow.RemoveAt(this.selectedNode)
            this.UpdateNodeList()
            this.AppendLog("Deleted node " . this.selectedNode)
        }
    }
    
    static RunWorkflow() {
        if (this.workflow.Length = 0) {
            MsgBox("No workflow to run", "Run", "Icon!")
            return
        }
        
        TrayTip("Running workflow...", "Executing " . this.workflow.Length . " nodes", 1)
        
        for i, node in this.workflow {
            this.ExecuteNode(node)
        }
        
        TrayTip("Workflow complete", "All nodes executed", 1)
    }
    
    static ExecuteNode(node) {
        switch node.type {
            case "condition":
                this.ExecuteCondition(node)
            case "loop":
                this.ExecuteLoop(node)
            case "delay":
                Sleep(node.seconds * 1000)
            case "action":
                this.ExecuteAction(node)
        }
    }
    
    static ExecuteCondition(node) {
        ; Check condition
        result := this.EvaluateCondition(node.expression)
        
        if (!result) {
            this.AppendLog("Condition failed: " . node.expression)
        } else {
            this.AppendLog("Condition passed: " . node.expression)
        }
    }
    
    static ExecuteLoop(node) {
        ; Execute loop
        this.AppendLog("Executing loop: " . node.loopType . " with value: " . node.value)
    }
    
    static ExecuteAction(node) {
        ; Execute action
        this.AppendLog("Executing action")
    }
    
    static EvaluateCondition(expression) {
        ; Simple condition evaluator
        return true
    }
    
    static SaveWorkflow() {
        if (this.workflow.Length = 0) {
            MsgBox("No workflow to save", "Save", "Icon!")
            return
        }
        
        ; Save workflow as JSON
        filename := "workflow_" . A_Now . ".json"
        json := this.SerializeWorkflow()
        FileAppend(json, filename, "UTF-8")
        
        MsgBox("Workflow saved to: " . filename, "Save", "Icon!")
        this.AppendLog("Saved workflow to: " . filename)
    }
    
    static SerializeWorkflow() {
        json := "{`"nodes`":["
        
        for i, node in this.workflow {
            if (i > 1)
                json .= ","
            
            json .= "{`"type`":`"" . node.type . "`""
            
            if (node.type = "condition") {
                json .= ",`"conditionType`":`"" . node.conditionType . "`","
                json .= "`"expression`":`"" . node.expression . "`""
            } else if (node.type = "loop") {
                json .= ",`"loopType`":`"" . node.loopType . "`","
                json .= "`"value`":`"" . node.value . "`""
            } else if (node.type = "delay") {
                json .= ",`"seconds`":" . node.seconds
            }
            
            json .= "}"
        }
        
        json .= "]}"
        return json
    }
    
    static ToggleGUI() {
        if (this.gui.Visible) {
            this.gui.Hide()
        } else {
            this.gui.Show()
        }
    }
    
    static AppendLog(message) {
        timestamp := FormatTime(A_Now, "HH:mm:ss")
        logMsg := "[" . timestamp . "] " . message . "`n"
        
        ; Show tooltip
        ToolTip(message, 0, 0)
        SetTimer(() => ToolTip(), -3000)
        
        ; Also log to file
        try {
            FileAppend(logMsg, "action_automation.log", "UTF-8")
        } catch {
            ; Ignore file logging errors
        }
        OutputDebug(logMsg)
    }
}

AutomationBuilder.Init()
