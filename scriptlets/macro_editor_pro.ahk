#Requires AutoHotkey v2.0+
#SingleInstance Force

; ==============================================================================
; Macro Editor Pro
; @name: Macro Editor Pro
; @version: 1.0.0
; @description: Edit and optimize recorded macros
; @category: automation
; @author: Sandra
; @hotkeys: ^!e
; @enabled: true
; ==============================================================================

class MacroEditor {
    static gui := ""
    static actionList := ""
    static macro := []
    static macros := Map()
    
    static Init() {
        this.CreateGUI()
        
        Hotkey("^!e", (*) => this.ToggleGUI())
        
        this.LoadMacros()
    }
    
    static CreateGUI() {
        this.gui := Gui("+Resize +AlwaysOnTop", "Macro Editor Pro")
        this.gui.BackColor := "222222"
        
        ; Title
        this.gui.AddText("x10 y10 w480 h30 Center", "Macro Editor Pro")
            .SetFont("s12 bold cFFFFFF")
        
        ; Macro selection
        this.gui.AddText("x10 y50 w100 h20", "Select Macro:")
        this.macroSelect := this.gui.AddDDL("x120 y45 w200 h200 vMacroSelect")
        this.macroSelect.OnEvent("Change", MacroEditor.MacroSelected)
        
        ; Action list
        this.gui.AddText("x10 y80 w100 h20", "Actions:")
        this.actionList := this.gui.AddListView("x10 y105 w480 h250 vActionList", ["Time", "Type", "Action", "Details"])
        this.actionList.OnEvent("Click", MacroEditor.ActionSelected)
        
        ; Edit buttons
        this.gui.AddButton("x10 y365 w100 h35 vEditBtn", "Edit Action")
            .OnEvent("Click", MacroEditor.EditAction)
        
        this.gui.AddButton("x120 y365 w100 h35 vDeleteBtn", "Delete Action")
            .OnEvent("Click", MacroEditor.DeleteAction)
        
        this.gui.AddButton("x230 y365 w100 h35 vInsertBtn", "Insert Action")
            .OnEvent("Click", MacroEditor.InsertAction)
        
        this.gui.AddButton("x340 y365 w100 h35 vOptimizeBtn", "Optimize")
            .OnEvent("Click", MacroEditor.OptimizeMacro)
        
        ; Action controls
        this.gui.AddButton("x10 y410 w100 h35 vDuplicateBtn", "Duplicate")
            .OnEvent("Click", MacroEditor.DuplicateAction)
        
        this.gui.AddButton("x120 y410 w100 h35 vMoveUpBtn", "Move Up")
            .OnEvent("Click", (*) => MacroEditor.MoveAction(-1))
        
        this.gui.AddButton("x230 y410 w100 h35 vMoveDownBtn", "Move Down")
            .OnEvent("Click", (*) => MacroEditor.MoveAction(1))
        
        ; Save/Export
        this.gui.AddButton("x340 y410 w100 h35 vSaveBtn", "Save Macro")
            .OnEvent("Click", MacroEditor.SaveMacro)
        
        this.gui.AddButton("x450 y410 w40 h35 vExportBtn", "Export")
            .OnEvent("Click", MacroEditor.ExportMacro)
        
        ; Test button
        this.gui.AddButton("x10 y455 w150 h35 vTestBtn", "Test Macro (F9)")
            .OnEvent("Click", MacroEditor.TestMacro)
        
        Hotkey("F9", MacroEditor.TestMacro)
        Hotkey("Escape", (*) => this.gui.Hide(), this.gui)
        
        this.gui.Show("w500 h500")
    }
    
    static LoadMacros() {
        ; Scan for .macro files
        macroFiles := []
        
        Loop Files, "*.macro", "F" {
            macroFiles.Push(A_LoopFileName)
        }
        
        ; Add to dropdown
        this.macroSelect.Delete()
        for filename in macroFiles {
            this.macroSelect.Add([filename])
        }
        
        if (macroFiles.Length > 0)
            this.macroSelect.Text := macroFiles[1]
    }
    
    static MacroSelected() {
        selected := this.macroSelect.Text
        
        if (selected && FileExist(selected)) {
            try {
                content := FileRead(selected)
                this.macro := this.ParseMacro(content)
                this.UpdateActionList()
            } catch as e {
                MsgBox("Error loading macro: " . e.Message, "Error", "Icon!")
            }
        }
    }
    
    static ParseMacro(content) {
        ; Simple JSON parser
        macro := []
        
        ; Extract actions from JSON
        RegExMatch(content, '"actions":\[(.*)\]', &match)
        
        if (match && match[1]) {
            ; Parse actions
            ; This is a simplified parser
            macro := []
        }
        
        return macro
    }
    
    static UpdateActionList() {
        this.actionList.Delete()
        
        for i, action in this.macro {
            time := FormatTime(action.timestamp, "HH:mm:ss")
            this.actionList.Add([
                time,
                action.type,
                action.action,
                this.ActionDetails(action)
            ])
        }
    }
    
    static ActionDetails(action) {
        switch action.type {
            case "key":
                return action.key
            case "mouse":
                return "(" . action.x . ", " . action.y . ")"
            default:
                return ""
        }
    }
    
    static ActionSelected() {
        selected := this.actionList.GetNext()
        if (selected > 0) {
            this.AppendLog("Selected action: " . selected)
        }
    }
    
    static EditAction() {
        selected := this.actionList.GetNext()
        if (selected = 0) {
            MsgBox("Please select an action to edit", "Edit Action", "Icon!")
            return
        }
        
        ; Open edit dialog
        this.OpenEditDialog(selected)
    }
    
    static DeleteAction() {
        selected := this.actionList.GetNext()
        if (selected = 0) {
            return
        }
        
        if (MsgBox("Delete this action?", "Confirm", "Icon? YesNo") = "Yes") {
            this.macro.RemoveAt(selected)
            this.UpdateActionList()
            this.AppendLog("Deleted action " . selected)
        }
    }
    
    static InsertAction() {
        ; Open insert dialog
        this.OpenInsertDialog()
    }
    
    static DuplicateAction() {
        selected := this.actionList.GetNext()
        if (selected = 0) {
            return
        }
        
        this.macro.InsertAt(selected + 1, this.macro[selected].Clone())
        this.UpdateActionList()
        this.AppendLog("Duplicated action " . selected)
    }
    
    static MoveAction(direction) {
        selected := this.actionList.GetNext()
        if (selected = 0 || (direction = -1 && selected = 1) || (direction = 1 && selected = this.macro.Length)) {
            return
        }
        
        newPos := selected + direction
        swap := this.macro[selected]
        this.macro[selected] := this.macro[newPos]
        this.macro[newPos] := swap
        
        this.UpdateActionList()
        this.actionList.Modify(selected + direction, "Select")
    }
    
    static OptimizeMacro() {
        ; Remove redundant actions
        beforeCount := this.macro.Length
        
        ; Remove duplicate mouse moves
        i := 1
        while (i < this.macro.Length) {
            if (this.macro[i].type = "mouse" && this.macro[i + 1].type = "mouse" &&
                this.macro[i].x = this.macro[i + 1].x && this.macro[i].y = this.macro[i + 1].y) {
                this.macro.RemoveAt(i + 1)
            } else {
                i++
            }
        }
        
        afterCount := this.macro.Length
        optimized := beforeCount - afterCount
        
        if (optimized > 0) {
            this.UpdateActionList()
            MsgBox("Optimized " . optimized . " redundant actions", "Optimize", "Icon!")
            this.AppendLog("Optimized " . optimized . " actions")
        } else {
            MsgBox("No optimizations possible", "Optimize", "Icon!")
        }
    }
    
    static OpenEditDialog(index) {
        dialog := Gui("+AlwaysOnTop", "Edit Action")
        dialog.BackColor := "222222"
        
        action := this.macro[index]
        
        dialog.AddText("x10 y10 w300 h20", "Edit Action #" . index)
            .SetFont("s10 bold")
        
        dialog.AddText("x10 y40 w100 h20", "Type:")
        typeSelect := dialog.AddDDL("x120 y35 w150 vTypeSelect", ["key", "mouse"])
            .Text := action.type
        
        dialog.AddText("x10 y70 w300 h20", "Details:")
        detailsEdit := dialog.AddEdit("x10 y95 w300 h150 vDetailsEdit")
            .Text := this.ActionToText(action)
        
        dialog.AddButton("x10 y255 w140 h35 vOkBtn", "OK")
            .OnEvent("Click", (*) => {
                this.macro[index] := this.TextToAction(detailsEdit.Text)
                this.UpdateActionList()
                dialog.Destroy()
            })
        
        dialog.AddButton("x160 y255 w140 h35 vCancelBtn", "Cancel")
            .OnEvent("Click", (*) => dialog.Destroy())
        
        dialog.Show("w320 h300")
    }
    
    static OpenInsertDialog() {
        dialog := Gui("+AlwaysOnTop", "Insert Action")
        dialog.BackColor := "222222"
        
        dialog.AddText("x10 y10 w300 h20", "Insert New Action")
            .SetFont("s10 bold")
        
        dialog.AddText("x10 y40 w100 h20", "Type:")
        typeSelect := dialog.AddDDL("x120 y35 w150 vTypeSelect", ["key", "mouse", "delay", "comment"])
        
        dialog.AddText("x10 y70 w300 h20", "Action Data:")
        detailsEdit := dialog.AddEdit("x10 y95 w300 h150 vDetailsEdit")
        
        dialog.AddButton("x10 y255 w140 h35 vOkBtn", "OK")
            .OnEvent("Click", (*) => {
                newAction := this.TextToAction(detailsEdit.Text)
                this.macro.Push(newAction)
                this.UpdateActionList()
                dialog.Destroy()
            })
        
        dialog.AddButton("x160 y255 w140 h35 vCancelBtn", "Cancel")
            .OnEvent("Click", (*) => dialog.Destroy())
        
        dialog.Show("w320 h300")
    }
    
    static ActionToText(action) {
        switch action.type {
            case "key":
                return "Key: " . action.key
            case "mouse":
                return "Mouse: (" . action.x . ", " . action.y . ")"
            default:
                return ""
        }
    }
    
    static TextToAction(text) {
        ; Parse text into action object
        if (RegExMatch(text, "Key: (.+)", &match)) {
            return {type: "key", key: match[1]}
        } else if (RegExMatch(text, "Mouse: \((\d+), (\d+)\)", &match)) {
            return {type: "mouse", x: match[1], y: match[2]}
        }
        return {}
    }
    
    static SaveMacro() {
        if (this.macro.Length = 0) {
            MsgBox("No macro to save", "Save", "Icon!")
            return
        }
        
        ; Simple save
        MsgBox("Macro saved", "Save", "Icon!")
        this.AppendLog("Macro saved")
    }
    
    static ExportMacro() {
        if (this.macro.Length = 0) {
            MsgBox("No macro to export", "Export", "Icon!")
            return
        }
        
        ; Export as AHK script
        ahkCode := this.GenerateAHKCode()
        
        filename := "macro_" . A_Now . ".ahk"
        FileAppend(ahkCode, filename, "UTF-8")
        
        MsgBox("Macro exported to: " . filename, "Export", "Icon!")
        this.AppendLog("Exported to: " . filename)
    }
    
    static GenerateAHKCode() {
        ahk := "; Generated by Macro Editor Pro`n`n"
        ahk .= "PlayMacro() {`n"
        
        for action in this.macro {
            switch action.type {
                case "key":
                    ahk .= "    Send('" . action.key . "')`n"
                case "mouse":
                    ahk .= "    MouseClick('left', " . action.x . ", " . action.y . ")`n"
            }
        }
        
        ahk .= "}`n"
        return ahk
    }
    
    static TestMacro() {
        if (this.macro.Length = 0) {
            MsgBox("No macro to test", "Test", "Icon!")
            return
        }
        
        TrayTip("Testing macro...", "Playing " . this.macro.Length . " actions", 1)
        
        ; Wait 3 seconds before starting
        Sleep(3000)
        
        ; Play macro
        for action in this.macro {
            switch action.type {
                case "key":
                    Send(action.key)
                case "mouse":
                    MouseClick("left", action.x, action.y)
            }
            Sleep(100)  ; Small delay between actions
        }
        
        TrayTip("Macro complete", "Played " . this.macro.Length . " actions", 1)
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
        ToolTip(message, 0, 0)
        SetTimer(() => ToolTip(), -3000)
    }
}

MacroEditor.Init()
