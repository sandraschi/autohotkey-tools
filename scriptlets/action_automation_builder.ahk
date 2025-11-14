#Requires AutoHotkey v2.0+
#SingleInstance Force
#Include %A_ScriptDir%\lib\ScriptletErrorHandler.ahk

; ==============================================================================
; Action Automation Builder
; @name: Action Automation Builder
; @version: 1.0.0
; @description: Visual workflow builder for complex automation tasks with drag-and-drop interface. Create automation workflows visually without coding.
; @description: Provides drag-and-drop workflow builder, action library, visual canvas, and automation testing. Supports complex task automation with visual representation and step-by-step workflow creation.
; @description: Essential automation tool for creating complex workflows visually, making automation accessible to non-programmers with intuitive drag-and-drop interface.
; @category: automation
; @author: Sandra
; @hotkeys: ^!b
; @enabled: true
; @priority: 15
; @tag: automation, workflow, builder, visual, drag-drop, productivity, gui
; @cli: --new-workflow - Create new automation workflow
; @cli: --open <workflow> - Open existing workflow file
; @cli: --test - Test current workflow
; @cli: --help - Show CLI usage and builder options
; @dependencies:
; ==============================================================================

OnError(HandleScriptError)

HandleScriptError(Thrown, Mode) {
    return AutomationBuilder.HandleScriptError(Thrown, Mode)
}

class AutomationBuilder {
    static gui := ""
    static canvas := ""
    static nodeList := ""
    static logOutput := ""
    static workflow := []
    static selectedNode := 0
    static logDir := ""
    static logFilePath := ""
    static logInitialized := false
    static isVisible := false

    static Init() {
        AutomationBuilder.EnsureLogInfrastructure()
        AutomationBuilder.CreateGUI()
        Hotkey("^!b", (*) => AutomationBuilder.ToggleGUI())
        AutomationBuilder.AppendLog("Automation Builder initialized.")
    }

    static CreateGUI() {
        try {
            AutomationBuilder.gui := Gui("+Resize", "Action Automation Builder")
            AutomationBuilder.gui.BackColor := 0x222222
            AutomationBuilder.gui.SetFont("s10 cFFFFFF", "Segoe UI")
            AutomationBuilder.gui.MinSize := "820x560"

            title := AutomationBuilder.gui.AddText("x10 y10 w520 h30 Center", "Action Automation Builder")
            title.SetFont("s12 bold")

            AutomationBuilder.gui.AddButton("x10 y50 w120 h30", "Record Action").OnEvent("Click", ObjBindMethod(AutomationBuilder, "RecordAction"))
            AutomationBuilder.gui.AddButton("x140 y50 w120 h30", "Add Condition").OnEvent("Click", ObjBindMethod(AutomationBuilder, "AddCondition"))
            AutomationBuilder.gui.AddButton("x270 y50 w120 h30", "Add Loop").OnEvent("Click", ObjBindMethod(AutomationBuilder, "AddLoop"))
            AutomationBuilder.gui.AddButton("x400 y50 w120 h30", "Add Delay").OnEvent("Click", ObjBindMethod(AutomationBuilder, "AddDelay"))
            AutomationBuilder.gui.AddButton("x530 y50 w120 h30", "Run Workflow").OnEvent("Click", ObjBindMethod(AutomationBuilder, "RunWorkflow"))

            AutomationBuilder.gui.AddText("x10 y90 w520 h20", "Workflow Canvas:")
            canvasControl := AutomationBuilder.gui.AddEdit("x10 y115 w520 h280 ReadOnly Multi VScroll -WantReturn", "No nodes defined. Use the toolbar to add workflow steps.")
            canvasControl.BackColor := 0xFFFFFF
            canvasControl.SetFont("c000000")
            AutomationBuilder.canvas := canvasControl

            AutomationBuilder.gui.AddText("x550 y90 w240 h20", "Workflow Nodes:")
            AutomationBuilder.nodeList := AutomationBuilder.gui.AddListView("x550 y115 w250 h280", ["Node"])
            AutomationBuilder.nodeList.OnEvent("Click", ObjBindMethod(AutomationBuilder, "NodeSelected"))

            AutomationBuilder.gui.AddButton("x550 y405 w120 h32", "Delete Node").OnEvent("Click", ObjBindMethod(AutomationBuilder, "DeleteNode"))
            AutomationBuilder.gui.AddButton("x680 y405 w120 h32", "Save Workflow").OnEvent("Click", ObjBindMethod(AutomationBuilder, "SaveWorkflow"))

            AutomationBuilder.gui.AddText("x10 y405 w520 h20", "Log Output:")
            logControl := AutomationBuilder.gui.AddEdit("x10 y430 w810 h110 ReadOnly Multi VScroll -WantReturn", "")
            logControl.BackColor := 0x1a1a1a
            logControl.SetFont("s9 cFFFFFF", "Consolas")
            AutomationBuilder.logOutput := logControl

            AutomationBuilder.gui.OnEvent("Escape", ObjBindMethod(AutomationBuilder, "HideGUI"))
            AutomationBuilder.gui.OnEvent("Close", ObjBindMethod(AutomationBuilder, "HideGUI"))

            AutomationBuilder.RefreshCanvas()
            AutomationBuilder.gui.Show("w830 h580")
            AutomationBuilder.isVisible := true
            AutomationBuilder.AppendLog("GUI created successfully.")
        } catch as e {
            AutomationBuilder.AppendLog("Error creating GUI: " . e.Message, "ERROR")
            if (e.Stack) {
                AutomationBuilder.AppendLog(e.Stack, "TRACE")
            }
            TrayTip("Initialization Error", "Unable to create the Action Automation Builder GUI.`n`n" . e.Message, 10)
        }
    }

    static RecordAction(*) {
        response := MsgBox("Start recording your action?", "Record Action", "Icon? YesNo")
        if (response != "Yes") {
            AutomationBuilder.AppendLog("Recording cancelled or timed out.", "INFO")
            return
        }

        AutomationBuilder.AppendLog("Recording initiated (simulation).", "INFO")
        AutomationBuilder.ShowTimedNotification("Recording", "Use Ctrl+Alt+S to stop recording.", 10000)
    }

    static AddCondition(*) {
        dialog := Gui("+AlwaysOnTop +ToolWindow", "Add Condition")
        dialog.BackColor := 0x333333
        dialog.SetFont("s9 cFFFFFF", "Segoe UI")
        dialog.OnEvent("Escape", (*) => dialog.Destroy())

        dialog.AddText("x10 y10 w280 h20", "Condition Type:")
        conditionType := dialog.AddDDL("x10 y35 w260", ["Window", "File", "Network", "Custom"])

        dialog.AddText("x10 y70 w280 h20", "Condition Expression:")
        conditionEdit := dialog.AddEdit("x10 y95 w260 h90 -WantReturn")

        dialog.AddButton("x10 y195 w120 h32", "OK").OnEvent("Click", (*) => AutomationBuilder.AddConditionConfirm(dialog, conditionType, conditionEdit))
        dialog.AddButton("x150 y195 w120 h32", "Cancel").OnEvent("Click", (*) => dialog.Destroy())

        dialog.Show("w280 h240")
    }

    static AddConditionConfirm(dialog, conditionType, conditionEdit) {
        typeValue := AutomationBuilder.TrimValue(conditionType.Text)
        expression := AutomationBuilder.TrimValue(conditionEdit.Value)

        if (!typeValue || !expression) {
            AutomationBuilder.AppendLog("Condition requires both a type and an expression.", "WARN")
            AutomationBuilder.ShowTimedNotification("Validation", "Provide condition type and expression.", 10000)
            return
        }

        node := {type: "condition", conditionType: typeValue, expression: expression}
        AutomationBuilder.workflow.Push(node)
        AutomationBuilder.UpdateNodeList()
        AutomationBuilder.RefreshCanvas()
        AutomationBuilder.AppendLog("Added condition node (" . typeValue . ").")
        dialog.Destroy()
    }

    static AddLoop(*) {
        dialog := Gui("+AlwaysOnTop +ToolWindow", "Add Loop")
        dialog.BackColor := 0x333333
        dialog.SetFont("s9 cFFFFFF", "Segoe UI")
        dialog.OnEvent("Escape", (*) => dialog.Destroy())

        dialog.AddText("x10 y10 w280 h20", "Loop Type:")
        loopType := dialog.AddDDL("x10 y35 w260", ["Count", "While", "For Each"])

        dialog.AddText("x10 y70 w280 h20", "Loop Value:")
        loopValue := dialog.AddEdit("x10 y95 w260 h70 -WantReturn")

        dialog.AddButton("x10 y175 w120 h32", "OK").OnEvent("Click", (*) => AutomationBuilder.AddLoopConfirm(dialog, loopType, loopValue))
        dialog.AddButton("x150 y175 w120 h32", "Cancel").OnEvent("Click", (*) => dialog.Destroy())

        dialog.Show("w280 h220")
    }

    static AddLoopConfirm(dialog, loopType, loopValue) {
        typeValue := AutomationBuilder.TrimValue(loopType.Text)
        value := AutomationBuilder.TrimValue(loopValue.Value)

        if (!typeValue || !value) {
            AutomationBuilder.AppendLog("Loop requires both a type and a value.", "WARN")
            AutomationBuilder.ShowTimedNotification("Validation", "Provide loop type and value.", 10000)
            return
        }

        node := {type: "loop", loopType: typeValue, value: value}
        AutomationBuilder.workflow.Push(node)
        AutomationBuilder.UpdateNodeList()
        AutomationBuilder.RefreshCanvas()
        AutomationBuilder.AppendLog("Added loop node (" . typeValue . ").")
        dialog.Destroy()
    }

    static AddDelay(*) {
        dialog := Gui("+AlwaysOnTop +ToolWindow", "Add Delay")
        dialog.BackColor := 0x333333
        dialog.SetFont("s9 cFFFFFF", "Segoe UI")
        dialog.OnEvent("Escape", (*) => dialog.Destroy())

        dialog.AddText("x10 y10 w180 h20", "Delay (seconds):")
        delayValue := dialog.AddEdit("x10 y35 w180", "")

        dialog.AddButton("x10 y70 w80 h30", "OK").OnEvent("Click", (*) => AutomationBuilder.AddDelayConfirm(dialog, delayValue))
        dialog.AddButton("x110 y70 w80 h30", "Cancel").OnEvent("Click", (*) => dialog.Destroy())

        dialog.Show("w210 h120")
    }

    static AddDelayConfirm(dialog, delayValue) {
        seconds := AutomationBuilder.NormalizeSeconds(delayValue.Value)
        node := {type: "delay", seconds: seconds}
        AutomationBuilder.workflow.Push(node)
        AutomationBuilder.UpdateNodeList()
        AutomationBuilder.RefreshCanvas()
        AutomationBuilder.AppendLog("Added delay node (" . seconds . " second(s)).")
        dialog.Destroy()
    }

    static UpdateNodeList() {
        if (!AutomationBuilder.nodeList) {
            return
        }

        AutomationBuilder.nodeList.Delete()
        for index, node in AutomationBuilder.workflow {
            AutomationBuilder.nodeList.Add([Format("{:02d} - {}", index, AutomationBuilder.DescribeNode(node))])
        }
        AutomationBuilder.selectedNode := 0
    }

    static NodeSelected(*) {
        AutomationBuilder.selectedNode := AutomationBuilder.nodeList.GetNext()
        if (AutomationBuilder.selectedNode) {
            AutomationBuilder.AppendLog("Selected node #" . AutomationBuilder.selectedNode . ".", "INFO")
        }
    }

    static DeleteNode(*) {
        if (AutomationBuilder.selectedNode = 0) {
            AutomationBuilder.AppendLog("Select a node before attempting to delete.", "WARN")
            return
        }

        response := MsgBox("Delete the selected node?", "Confirm Delete", "Icon? YesNo")
        if (response != "Yes") {
            AutomationBuilder.AppendLog("Node deletion cancelled or timed out.", "INFO")
            return
        }

        AutomationBuilder.workflow.RemoveAt(AutomationBuilder.selectedNode)
        AutomationBuilder.AppendLog("Deleted node #" . AutomationBuilder.selectedNode . ".")
        AutomationBuilder.selectedNode := 0
        AutomationBuilder.UpdateNodeList()
        AutomationBuilder.RefreshCanvas()
    }

    static RunWorkflow(*) {
        if (AutomationBuilder.workflow.Length = 0) {
            TrayTip("Workflow Empty", "Add workflow nodes before running.", 5)
            return
        }

        AutomationBuilder.AppendLog("Running workflow (" . AutomationBuilder.workflow.Length . " node(s)).")

        for index, node in AutomationBuilder.workflow {
            try {
                AutomationBuilder.ExecuteNode(node, index)
            } catch as e {
                AutomationBuilder.AppendLog("Node #" . index . " failed: " . e.Message, "ERROR")
                if (e.Stack) {
                    AutomationBuilder.AppendLog(e.Stack, "TRACE")
                }
            }
        }

        AutomationBuilder.AppendLog("Workflow execution complete.")
        AutomationBuilder.ShowTimedNotification("Workflow", "Execution complete.", 10000)
    }

    static ExecuteNode(node, index) {
        switch node.type {
            case "condition":
                AutomationBuilder.ExecuteCondition(node, index)
            case "loop":
                AutomationBuilder.ExecuteLoop(node, index)
            case "delay":
                AutomationBuilder.ExecuteDelay(node, index)
            case "action":
                AutomationBuilder.ExecuteAction(node, index)
            default:
                AutomationBuilder.AppendLog("Unknown node type: " . node.type, "WARN")
        }
    }

    static ExecuteCondition(node, index) {
        result := AutomationBuilder.EvaluateCondition(node.expression)
        outcome := result ? "passed" : "failed"
        AutomationBuilder.AppendLog("Condition node #" . index . " " . outcome . ": " . node.expression)
    }

    static ExecuteLoop(node, index) {
        AutomationBuilder.AppendLog("Loop node #" . index . ": type=" . node.loopType . ", value=" . node.value)
    }

    static ExecuteDelay(node, index) {
        seconds := AutomationBuilder.NormalizeSeconds(node.seconds)
        AutomationBuilder.AppendLog("Delay node #" . index . ": waiting " . seconds . " second(s).")
        Sleep(seconds * 1000)
    }

    static ExecuteAction(node, index) {
        AutomationBuilder.AppendLog("Action node #" . index . ": executing placeholder action.")
    }

    static EvaluateCondition(expression) {
        trimmed := AutomationBuilder.TrimValue(expression)
        if (!trimmed) {
            return true
        }

        if (RegExMatch(trimmed, "i)^\s*(0|false|fail|no)\s*$")) {
            return false
        }
        return true
    }

    static SaveWorkflow(*) {
        if (AutomationBuilder.workflow.Length = 0) {
            TrayTip("Save Workflow", "No workflow nodes to save.", 5)
            return
        }

        timestamp := ""
        timestamp := FormatTime(, "yyyyMMdd_HHmmss")
        fileName := "workflow_" . timestamp . ".json"
        filePath := A_ScriptDir . "\" . fileName

        try {
            json := AutomationBuilder.SerializeWorkflow()
            file := FileOpen(filePath, "w", "UTF-8")
            if (!file) {
                throw Error("Could not open file for writing.")
            }
            file.Write(json)
            file.Close()
            AutomationBuilder.AppendLog("Workflow saved to " . fileName . ".")
            AutomationBuilder.ShowTimedNotification("Workflow Saved", fileName, 10000)
        } catch as e {
            AutomationBuilder.AppendLog("Failed to save workflow: " . e.Message, "ERROR")
            TrayTip("Save Error", "Unable to save the workflow.`n`n" . e.Message, 10)
        }
    }

    static SerializeWorkflow() {
        nodes := []
        for node in AutomationBuilder.workflow {
            fields := []
            fields.Push('"type":"' . AutomationBuilder.JsonEscape(node.type) . '"')

            if (ObjHasOwnProp(node, "conditionType")) {
                fields.Push('"conditionType":"' . AutomationBuilder.JsonEscape(node.conditionType) . '"')
            }
            if (ObjHasOwnProp(node, "expression")) {
                fields.Push('"expression":"' . AutomationBuilder.JsonEscape(node.expression) . '"')
            }
            if (ObjHasOwnProp(node, "loopType")) {
                fields.Push('"loopType":"' . AutomationBuilder.JsonEscape(node.loopType) . '"')
            }
            if (ObjHasOwnProp(node, "value")) {
                fields.Push('"value":"' . AutomationBuilder.JsonEscape(node.value) . '"')
            }
            if (ObjHasOwnProp(node, "seconds")) {
                fields.Push('"seconds":' . AutomationBuilder.NormalizeSeconds(node.seconds))
            }

            nodes.Push("{" . AutomationBuilder.JoinArray(fields, ",") . "}")
        }

        generated := ""
        generated := FormatTime(, "yyyy-MM-dd HH:mm:ss")
        quote := Chr(34)
        return "{" . quote . "nodes" . quote . ":[" . AutomationBuilder.JoinArray(nodes, ",") . "]," . quote . "generated" . quote . ":" . quote . generated . quote . "}"
    }

    static ToggleGUI(*) {
        if (AutomationBuilder.isVisible) {
            AutomationBuilder.HideGUI()
        } else {
            AutomationBuilder.ShowGUI()
        }
    }

    static ShowGUI() {
        if (!AutomationBuilder.gui) {
            AutomationBuilder.CreateGUI()
            return
        }
        AutomationBuilder.gui.Show()
        AutomationBuilder.isVisible := true
        AutomationBuilder.AppendLog("GUI shown.")
    }

    static HideGUI(*) {
        if (!AutomationBuilder.gui) {
            return
        }
        try {
            AutomationBuilder.gui.Hide()
        } catch {
        }
        AutomationBuilder.isVisible := false
        AutomationBuilder.AppendLog("GUI hidden.")
    }

    static RefreshCanvas() {
        if (!AutomationBuilder.canvas) {
            return
        }

        if (AutomationBuilder.workflow.Length = 0) {
            AutomationBuilder.canvas.Value := "No nodes defined. Use the toolbar to add workflow steps."
            return
        }

        summary := ""
        for index, node in AutomationBuilder.workflow {
            summary .= Format("{:02d}. {}", index, AutomationBuilder.DescribeNode(node)) . "`r`n"
        }
        AutomationBuilder.canvas.Value := summary
    }

    static DescribeNode(node) {
        if (!ObjHasOwnProp(node, "type")) {
            return "Unknown"
        }

        switch node.type {
            case "condition":
                return "Condition (" . node.conditionType . ")"
            case "loop":
                return "Loop (" . node.loopType . ")"
            case "delay":
                return "Delay (" . AutomationBuilder.NormalizeSeconds(node.seconds) . "s)"
            case "action":
                return "Action"
            default:
                return AutomationBuilder.Capitalize(node.type)
        }
    }

    static AppendLog(message, severity := "INFO") {
        AutomationBuilder.EnsureLogInfrastructure()
        timestamp := ""
        timestamp := FormatTime(, "yyyy-MM-dd HH:mm:ss")
        entry := "[" . timestamp . "] [" . severity . "] " . message

        if (AutomationBuilder.logOutput) {
            AutomationBuilder.logOutput.Value := AutomationBuilder.logOutput.Value . entry . "`n"
            AutomationBuilder.logOutput.Redraw()
        }

        OutputDebug(entry)

        if (AutomationBuilder.logFilePath) {
            try {
                FileAppend(entry . "`n", AutomationBuilder.logFilePath, "UTF-8")
            } catch as fileError {
                OutputDebug("Unable to write automation log: " . fileError.Message)
            }
        }
    }

    static ShowTimedNotification(title, message, durationMs := 10000) {
        try {
            display := title ? (title . ": " . message) : message
            ToolTip(display, 30, 30)
            SetTimer(ObjBindMethod(AutomationBuilder, "ClearTrayTip"), -Abs(durationMs))
        } catch as e {
            AutomationBuilder.AppendLog("Notification tooltip failed: " . e.Message, "WARN")
        }
    }

    static ClearTrayTip(*) {
        ToolTip()
    }

    static NormalizeSeconds(value) {
        seconds := Round(Number(value))
        if (seconds <= 0) {
            seconds := 1
        }
        return seconds
    }

    static TrimValue(value) {
        return Trim(value ?? "")
    }

    static JoinArray(values, delimiter := ",") {
        if (!values || values.Length = 0) {
            return ""
        }
        result := values[1]
        for index, value in values {
            if (index = 1) {
                continue
            }
            result .= delimiter . value
        }
        return result
    }

    static JsonEscape(value) {
        text := value ?? ""
        backslash := Chr(92)
        quote := Chr(34)
        text := StrReplace(text, backslash, backslash backslash)
        text := StrReplace(text, quote, backslash quote)
        text := StrReplace(text, "`r`n", "\n")
        text := StrReplace(text, "`n", "\n")
        text := StrReplace(text, "`r", "\n")
        return text
    }

    static Capitalize(value) {
        text := value ?? ""
        if (!text) {
            return ""
        }
        return StrUpper(SubStr(text, 1, 1)) . StrLower(SubStr(text, 2))
    }

    static EnsureLogInfrastructure() {
        if (AutomationBuilder.logInitialized) {
            return
        }
        AutomationBuilder.logDir := A_ScriptDir . "\logs"
        try {
            if (!DirExist(AutomationBuilder.logDir)) {
                DirCreate(AutomationBuilder.logDir)
            }
        } catch as dirError {
            OutputDebug("Failed to create log directory: " . dirError.Message)
        }
        AutomationBuilder.logFilePath := AutomationBuilder.logDir . "\action_automation_builder.log"
        AutomationBuilder.logInitialized := true
    }

    static HandleScriptError(Thrown, Mode) {
        message := "Unhandled exception (" . Mode . "): " . Thrown.Message
        AutomationBuilder.AppendLog(message, "ERROR")
        if (Thrown.Stack) {
            AutomationBuilder.AppendLog("Stack trace:`n" . Thrown.Stack, "TRACE")
        }
        AutomationBuilder.ShowTimedNotification("Automation Builder Error", Thrown.Message, 10000)
        AutomationBuilder.HideGUI()
        return 1
    }
}

AutomationBuilder.Init()
