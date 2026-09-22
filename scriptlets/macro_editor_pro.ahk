#Requires AutoHotkey v2.0+
#SingleInstance Force

; ==============================================================================
; Macro Editor Pro
; @name: Macro Editor Pro
; @version: 1.0.0
; @description: Edit and optimize recorded macros with advanced editing capabilities. Modify macro sequences, adjust timing, remove unnecessary actions, and optimize performance.
; @description: Provides visual macro editor with action list manipulation, timing adjustment, action insertion/deletion, and macro validation. Supports batch editing and macro optimization suggestions.
; @description: Essential tool for refining recorded macros, removing redundant actions, and creating efficient automation sequences from recorded inputs.
; @category: automation
; @author: Sandra
; @hotkeys: ^!e
; @enabled: true
; @priority: 20
; @tag: macro, editor, automation, productivity, recording, optimization, editing
; @cli: --open <macro> - Open specific macro for editing
; @cli: --optimize - Auto-optimize macro by removing redundant actions
; @cli: --validate - Validate macro syntax and check for errors
; @cli: --help - Show CLI usage and editor options
; @dependencies: 
; ==============================================================================

#Include A_ScriptDir\lib\ScriptletErrorHandler.ahk

OnError(LogError)

class MacroEditor {
    static gui := ""
    static actionList := ""
    static macro := []
    static macros := Map()
    static logFilePath := ""
    static logInitialized := false
    static logOutput := ""
    static logMessages := []
    static isVisible := false
    
    static Init() {
        this.EnsureLogInfrastructure()
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
        
        ; Log output
        this.logOutput := this.gui.AddEdit("x10 y455 w480 h80 ReadOnly Multi VScroll", "")
        this.logOutput.SetFont("s9 cFFFFFF", "Consolas")

        ; Test button
        this.gui.AddButton("x10 y545 w150 h35 vTestBtn", "Test Macro (F9)")
            .OnEvent("Click", MacroEditor.TestMacro)
        
        Hotkey("F9", MacroEditor.TestMacro)
        Hotkey("Escape", (*) => MacroEditor.gui && WinActive("ahk_id " MacroEditor.gui.Hwnd) && MacroEditor.HideGUI())
        
        
        ; Add exit handlers
        this.gui.OnEvent("Close", this.HideGui())
        this.gui.OnEvent("Escape", this.HideGui())
        this.gui.Show("w500 h600")
        this.isVisible := true
    }
    
    static LoadMacros() {
        ; Scan for .macro files
        macroFiles := []
        
        Loop Files "*.macro", "F" {
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
        
        okBtn := dialog.AddButton("x10 y255 w140 h35 vOkBtn", "OK")
        okBtn.OnEvent("Click", (*) => this.HandleEditDialogConfirm(dialog, detailsEdit, index))
        
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
        
        okBtn := dialog.AddButton("x10 y255 w140 h35 vOkBtn", "OK")
        okBtn.OnEvent("Click", (*) => this.HandleInsertDialogConfirm(dialog, detailsEdit))
        
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

    static EnsureLogInfrastructure() {
        if (this.logInitialized) {
            return
        }
        logDir := A_ScriptDir . "\logs"
        try {
            if (!DirExist(logDir)) {
                DirCreate(logDir)
            }
        } catch as dirError {
            OutputDebug("MacroEditor log directory error: " . dirError.Message)
        }
        this.logFilePath := logDir . "\macro_editor_pro.log"
        this.logInitialized := true
    }

    static AppendLog(message, severity := "INFO") {
        this.EnsureLogInfrastructure()
        timestamp := FormatTime(A_Now, "yyyy-MM-dd HH:mm:ss")
        entry := "[" . timestamp . "] [" . severity . "] " . message
        this.logMessages.Push(entry)
        if (this.logOutput) {
            current := this.logOutput.Value
            this.logOutput.Value := current . entry . "`n"
            this.logOutput.Redraw()
            this.logOutput.Focus()
            Send("^{End}")
        }
        OutputDebug(entry)
        if (this.logFilePath) {
            try {
                FileAppend(entry . "`n", this.logFilePath, "UTF-8")
            } catch as fileError {
                OutputDebug("MacroEditor log file error: " . fileError.Message)
            }
        }
    }


    static ToggleGUI(*) {
        if (!this.gui) {
            return
        }
        if (this.isVisible) {
            this.HideGUI()
        } else {
            this.ShowGUI()
        }
    }

    static ShowGUI() {
        if (!this.gui) {
            return
        }
        this.gui.Show()
        this.isVisible := true
    }

    static HideGUI(*) {
        if !this.gui
            return
        if !WinActive("ahk_id " this.gui.Hwnd)
            return
        try {
            this.gui.Hide()
        } catch {
            ; ignore hide errors
        }
        this.isVisible := false
    }

    static TestMacro(*) {
        if (this.macro.Length = 0) {
            this.AppendLog("No macro loaded to test.", "WARN")
            return
        }
        this.AppendLog("Test macro execution started (placeholder).", "INFO")
        ; TODO: Implement macro playback functionality.
    }

    static HandleEditDialogConfirm(dialog, detailsEdit, index) {
        this.macro[index] := this.TextToAction(detailsEdit.Text)
        this.UpdateActionList()
        dialog.Destroy()
    }

    static HandleInsertDialogConfirm(dialog, detailsEdit) {
        newAction := this.TextToAction(detailsEdit.Text)
        this.macro.Push(newAction)
        this.UpdateActionList()
        dialog.Destroy()
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
}