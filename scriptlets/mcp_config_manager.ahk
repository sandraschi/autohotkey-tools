#Requires AutoHotkey v2.0+
#SingleInstance Force
#Include %A_ScriptDir%\lib\ScriptletErrorHandler.ahk
#Include %A_ScriptDir%\lib\JSON.ahk

OnError(LogError)

class MCPConfigManager {
    static gui := ""
    static editor := ""
    static serverList := ""
    static statusBar := ""
    static logView := ""
    static configPath := A_AppData . "\Claude\claude_desktop_config.json"
    static backupDir := A_ScriptDir . "\config_backups"
    static logFile := A_ScriptDir . "\mcp_config_manager.log"
    static configObject := Map()
    static hotkeysRegistered := false
    
    static Init() {
        MCPConfigManager.AppendLog("Initializing MCP Config Manager")
        if (!MCPConfigManager.gui) {
            MCPConfigManager.CreateGui()
            MCPConfigManager.SetupHotkeys()
        }
        MCPConfigManager.ShowGui()
    }

    static HandleError(Thrown, Mode) {
        scriptName := HasProp(Thrown, "File") ? Thrown.File : A_ScriptFullPath
        lineInfo := HasProp(Thrown, "Line") ? " line " . Thrown.Line : ""
        message := "Error in " . scriptName . lineInfo . ": " . Thrown.Message
        MCPConfigManager.AppendLog(message)
        return 1
    }

    static CreateGui() {
        try {
            newGui := Gui("+Resize +MinSize820x700", "MCP Config Manager")
            newGui.BackColor := "1c1c1c"
            newGui.SetFont("s10 cFFFFFF", "Segoe UI")

            newGui.AddText("x20 y20 w780 Center Bold", "⚙️ MCP Config Manager")
            newGui.AddText("x20 y48 w780 Center cC0C0C0", "Manage Claude Desktop MCP servers, validate JSON, and back up configurations.")

            newGui.AddText("x20 y90 w780 Bold", "Configuration File")
            newGui.AddText("x20 y118 w110", "Path:")
            pathText := newGui.AddEdit("x140 y112 w660 h24 ReadOnly Center", MCPConfigManager.configPath)
            pathText.BackColor := "2b2b2b"

            loadBtn := newGui.AddButton("x20 y150 w150 h36", "📥 Load Config")
            loadBtn.OnEvent("Click", MCPConfigManager.LoadConfig)
            saveBtn := newGui.AddButton("x185 y150 w150 h36", "💾 Save Config")
            saveBtn.OnEvent("Click", MCPConfigManager.SaveConfig)
            backupBtn := newGui.AddButton("x350 y150 w150 h36", "📦 Backup Config")
            backupBtn.OnEvent("Click", MCPConfigManager.BackupConfig)
            restoreBtn := newGui.AddButton("x515 y150 w150 h36", "⤴️ Restore Backup")
            restoreBtn.OnEvent("Click", MCPConfigManager.RestoreConfig)
            refreshBtn := newGui.AddButton("x680 y150 w120 h36", "🔄 Refresh")
            refreshBtn.OnEvent("Click", MCPConfigManager.Refresh)

            newGui.AddText("x20 y205 w360 Bold", "Registered MCP Servers")
            serverList := newGui.AddListView("x20 y232 w360 h280 -Hdr", ["Server"])
            serverList.OnEvent("Click", MCPConfigManager.ShowServerDetails)
            MCPConfigManager.serverList := serverList

            addBtn := newGui.AddButton("x400 y232 w170 h32", "➕ Add Server")
            addBtn.OnEvent("Click", MCPConfigManager.AddServer)
            removeBtn := newGui.AddButton("x400 y272 w170 h32", "🗑️ Remove Server")
            removeBtn.OnEvent("Click", MCPConfigManager.RemoveServer)
            duplicateBtn := newGui.AddButton("x400 y312 w170 h32", "📋 Duplicate Server")
            duplicateBtn.OnEvent("Click", MCPConfigManager.DuplicateServer)
            infoBtn := newGui.AddButton("x400 y352 w170 h32", "ℹ️ Server Info")
            infoBtn.OnEvent("Click", MCPConfigManager.ShowServerInfoDialog)
            testBtn := newGui.AddButton("x400 y392 w170 h32", "🧪 Test Command")
            testBtn.OnEvent("Click", MCPConfigManager.TestServerCommand)

            newGui.AddText("x20 y530 w780 Bold", "Configuration JSON")
            editor := newGui.AddEdit("x20 y558 w780 h140 -Wrap VScroll", "")
            editor.BackColor := "282828"
            editor.SetFont("s10", "Consolas")
            MCPConfigManager.editor := editor

            validateBtn := newGui.AddButton("x20 y708 w150 h34", "✅ Validate JSON")
            validateBtn.OnEvent("Click", MCPConfigManager.ValidateJson)
            formatBtn := newGui.AddButton("x185 y708 w150 h34", "🎨 Format JSON")
            formatBtn.OnEvent("Click", MCPConfigManager.FormatJson)
            resetBtn := newGui.AddButton("x350 y708 w150 h34", "♻️ Reset Template")
            resetBtn.OnEvent("Click", MCPConfigManager.ResetTemplate)
            helpBtn := newGui.AddButton("x515 y708 w150 h34", "❓ Help")
            helpBtn.OnEvent("Click", MCPConfigManager.ShowHelp)

            logLabel := newGui.AddText("x20 y750 w780 Bold", "Activity Log")
            logView := newGui.AddEdit("x20 y778 w780 h110 ReadOnly VScroll", "")
            logView.BackColor := "242424"
            logView.SetFont("s9", "Consolas")
            MCPConfigManager.logView := logView

            status := newGui.AddStatusBar("Simple")
            status.SetText("Ready")
            MCPConfigManager.statusBar := status

            newGui.OnEvent("Close", MCPConfigManager.CloseGui)
            newGui.OnEvent("Escape", MCPConfigManager.CloseGui)
            MCPConfigManager.gui := newGui
        } catch as e {
            MsgBox("Error creating GUI: " . e.Message, "MCP Config Manager", "Iconx")
            MCPConfigManager.AppendLog("GUI creation failed: " . e.Message)
        }
    }

    static SetupHotkeys() {
        if (MCPConfigManager.hotkeysRegistered) {
                    return
                }
        Hotkey("^!c", MCPConfigManager.LoadConfig)
        Hotkey("^!s", MCPConfigManager.SaveConfig)
        Hotkey("^!b", MCPConfigManager.BackupConfig)
        Hotkey("^!r", MCPConfigManager.RestoreConfig)
        Hotkey("F9", MCPConfigManager.CloseGui)
        Hotkey("Escape", (*) => MCPConfigManager.gui && WinActive("ahk_id " MCPConfigManager.gui.Hwnd) && MCPConfigManager.CloseGui())
        MCPConfigManager.hotkeysRegistered := true
    }

    static ShowGui() {
        if (MCPConfigManager.gui) {
            MCPConfigManager.gui.Show("w820 h920 Center")
            MCPConfigManager.statusBar.SetText("GUI ready. Press Ctrl+Alt+C to load config.")
        }
    }

    static AppendLog(message) {
        timestamp := FormatTime(A_Now, "yyyy-MM-dd HH:mm:ss")
        entry := "[" . timestamp . "] " . message
        try {
            FileAppend(entry . "`n", MCPConfigManager.logFile, "UTF-8")
        } catch {
        }
        if (MCPConfigManager.logView) {
            MCPConfigManager.logView.Value .= entry . "`n"
            MCPConfigManager.logView.Redraw()
        }
        OutputDebug(entry)
    }

    static LoadConfig(*) {
        try {
            MCPConfigManager.AppendLog("LoadConfig invoked")
            if (!FileExist(MCPConfigManager.configPath)) {
                MCPConfigManager.AppendLog("Config not found. Generating template.")
                MCPConfigManager.WriteTemplate()
            }
            content := FileRead(MCPConfigManager.configPath, "UTF-8")
            MCPConfigManager.editor.Value := content
            MCPConfigManager.statusBar.SetText("Configuration loaded from " . MCPConfigManager.configPath)
            MCPConfigManager.ParseConfig(content)
            TrayTip("MCP Config Manager", "Configuration loaded")
        } catch as e {
            MCPConfigManager.AppendLog("LoadConfig error: " . e.Message)
            MsgBox("Failed to load configuration: " . e.Message, "MCP Config Manager", "Iconx")
        }
    }

    static ParseConfig(content) {
        MCPConfigManager.serverList.Delete()
        try {
            data := MCPConfigManager.TryParseJson(content)
            if (!IsObject(data)) {
                MCPConfigManager.AppendLog("JSON parse failed; data is not object")
                MCPConfigManager.statusBar.SetText("Invalid JSON. Validate before continuing.")
                return
            }
            MCPConfigManager.configObject := data
            if (data.Has("mcpServers") && IsObject(data["mcpServers"])) {
                for name, _ in data["mcpServers"] {
                    MCPConfigManager.serverList.Add([name])
                }
                count := MCPConfigManager.serverList.GetCount()
                MCPConfigManager.statusBar.SetText(count . " MCP server(s) loaded")
                MCPConfigManager.AppendLog("Loaded " . count . " MCP server entries")
            } else {
                MCPConfigManager.statusBar.SetText("No mcpServers block found.")
            }
        } catch as e {
            MCPConfigManager.AppendLog("ParseConfig error: " . e.Message)
        }
    }

    static TryParseJson(content) {
        try {
            return JSON.Load(content)
        } catch as e {
            MCPConfigManager.AppendLog("JSON.Load failed: " . e.Message)
            return ""
        }
    }

    static SaveConfig(*) {
        try {
            current := MCPConfigManager.editor.Value
            if (!MCPConfigManager.ValidateJsonText(current)) {
                MsgBox("Configuration JSON is invalid. Please fix errors before saving.", "MCP Config Manager", "Iconx")
                return
            }
            MCPConfigManager.CreateBackupCopy()
            FileDelete(MCPConfigManager.configPath)
            FileAppend(current, MCPConfigManager.configPath, "UTF-8")
            MCPConfigManager.statusBar.SetText("Configuration saved.")
            TrayTip("MCP Config Manager", "Configuration saved")
            MCPConfigManager.AppendLog("Configuration saved successfully")
        } catch as e {
            MCPConfigManager.AppendLog("SaveConfig error: " . e.Message)
            MsgBox("Failed to save configuration: " . e.Message, "MCP Config Manager", "Iconx")
        }
    }

    static BackupConfig(*) {
        try {
            MCPConfigManager.CreateBackupCopy()
            MCPConfigManager.statusBar.SetText("Backup created in " . MCPConfigManager.backupDir)
            TrayTip("MCP Config Manager", "Backup created")
        } catch as e {
            MCPConfigManager.AppendLog("Backup error: " . e.Message)
            MsgBox("Backup failed: " . e.Message, "MCP Config Manager", "Iconx")
        }
    }

    static CreateBackupCopy() {
        try {
            if (!DirExist(MCPConfigManager.backupDir)) {
                DirCreate(MCPConfigManager.backupDir)
            }
            if (!FileExist(MCPConfigManager.configPath)) {
                return
            }
            stamp := FormatTime(A_Now, "yyyyMMdd_HHmmss")
            target := MCPConfigManager.backupDir . "\claude_config_" . stamp . ".json"
            FileCopy(MCPConfigManager.configPath, target, true)
            MCPConfigManager.AppendLog("Backup saved: " . target)
        } catch as e {
            MCPConfigManager.AppendLog("CreateBackupCopy failure: " . e.Message)
        }
    }
    
    static RestoreConfig(*) {
        try {
            if (!DirExist(MCPConfigManager.backupDir)) {
                MsgBox("No backup directory found.", "MCP Config Manager", "Icon!")
                return
            }
            backups := []
            Loop Files MCPConfigManager.backupDir . "\*.json" {
                backups.Push(A_LoopFileFullPath)
            }
            if (backups.Length = 0) {
                MsgBox("No backup files available.", "MCP Config Manager", "Icon!")
                return
            }
            choice := MCPConfigManager.SelectBackup(backups)
            if (choice = "") {
                return
            }
            MCPConfigManager.CreateBackupCopy()
            FileCopy(choice, MCPConfigManager.configPath, true)
            MCPConfigManager.AppendLog("Restored from backup: " . choice)
            MCPConfigManager.LoadConfig()
        } catch as e {
            MCPConfigManager.AppendLog("Restore error: " . e.Message)
            MsgBox("Restore failed: " . e.Message, "MCP Config Manager", "Iconx")
        }
    }

    static SelectBackup(backups) {
        list := "Available backups:`n`n"
        for index, filePath in backups {
            list .= index . ") " . RegExReplace(filePath, ".*\\", "") . "`n"
        }
        list .= "`nEnter number to restore:"
        response := InputBox(list, "Restore Backup")
        if (response.Result != "OK") {
        return ""
    }
        number := Integer(response.Value)
        if (number < 1 || number > backups.Length) {
        return ""
    }
        return backups[number]
    }

    static Refresh(*) {
        if (MCPConfigManager.editor) {
            MCPConfigManager.ParseConfig(MCPConfigManager.editor.Value)
        }
    }

    static ShowServerDetails(*) {
        selected := MCPConfigManager.GetSelectedServer()
        if (selected = "") {
            return
        }
        MCPConfigManager.statusBar.SetText("Selected server: " . selected)
    }

    static GetSelectedServer() {
        if (!MCPConfigManager.serverList) {
                return ""
            }
        row := MCPConfigManager.serverList.GetNext(0)
        if (row = 0) {
            return ""
        }
        return MCPConfigManager.serverList.GetText(row)
    }

    static AddServer(*) {
        result := InputBox("Enter new server identifier (e.g., my-server):", "Add MCP Server")
        if (result.Result != "OK" || result.Value = "") {
            return
        }
        name := Trim(result.Value)
        data := MCPConfigManager.editor.Value
        json := MCPConfigManager.TryParseJson(data)
        if (!IsObject(json)) {
            MsgBox("Load or fix configuration before adding a server.", "MCP Config Manager", "Icon!")
            return
        }
        if (!json.Has("mcpServers")) {
            json["mcpServers"] := Map()
        }
        if (json["mcpServers"].Has(name)) {
            MsgBox("Server already exists.", "MCP Config Manager", "Icon!")
            return
        }
        json["mcpServers"][name] := Map("command", "python", "args", ["main.py"], "cwd", "./" . name)
        MCPConfigManager.editor.Value := MCPConfigManager.DumpJson(json)
        MCPConfigManager.ParseConfig(MCPConfigManager.editor.Value)
        MCPConfigManager.statusBar.SetText("Server '" . name . "' added to configuration.")
        MCPConfigManager.AppendLog("Server added: " . name)
    }

    static RemoveServer(*) {
        name := MCPConfigManager.GetSelectedServer()
        if (name = "") {
            MsgBox("Select a server before removing.", "MCP Config Manager", "Icon!")
            return
        }
        confirm := MsgBox("Remove server '" . name . "'?", "Confirm Removal", "Icon? YesNo")
        if (confirm != "Yes") {
            return
        }
        json := MCPConfigManager.TryParseJson(MCPConfigManager.editor.Value)
        if (!IsObject(json) || !json.Has("mcpServers") || !json["mcpServers"].Has(name)) {
            return
        }
        json["mcpServers"].Delete(name)
        MCPConfigManager.editor.Value := MCPConfigManager.DumpJson(json)
        MCPConfigManager.ParseConfig(MCPConfigManager.editor.Value)
        MCPConfigManager.AppendLog("Server removed: " . name)
    }

    static DuplicateServer(*) {
        source := MCPConfigManager.GetSelectedServer()
        if (source = "") {
            MsgBox("Select a server to duplicate.", "MCP Config Manager", "Icon!")
            return
        }
        newNameInput := InputBox("Enter duplicate server name:", "Duplicate Server")
        if (newNameInput.Result != "OK" || newNameInput.Value = "") {
            return
        }
        target := Trim(newNameInput.Value)
        json := MCPConfigManager.TryParseJson(MCPConfigManager.editor.Value)
        if (!IsObject(json) || !json.Has("mcpServers") || !json["mcpServers"].Has(source)) {
            MsgBox("Source server not found in configuration.", "MCP Config Manager", "Iconx")
            return
        }
        json["mcpServers"][target] := json["mcpServers"][source].Clone()
        MCPConfigManager.editor.Value := MCPConfigManager.DumpJson(json)
        MCPConfigManager.ParseConfig(MCPConfigManager.editor.Value)
        MCPConfigManager.AppendLog("Server duplicated: " . source . " -> " . target)
    }

    static ShowServerInfoDialog(*) {
        name := MCPConfigManager.GetSelectedServer()
        if (name = "") {
            MsgBox("Select a server first.", "MCP Config Manager", "Icon!")
            return
        }
        info := MCPConfigManager.GetServerSummary(name)
        MsgBox(info, "Server Info - " . name, "Iconi")
    }

    static GetServerSummary(name) {
        json := MCPConfigManager.TryParseJson(MCPConfigManager.editor.Value)
        if (!IsObject(json) || !json.Has("mcpServers") || !json["mcpServers"].Has(name)) {
            return "Server not found in configuration."
        }
        server := json["mcpServers"][name]
        summary := "Command: " . (server.Has("command") ? server["command"] : "(missing)") . "`n"
        summary .= "Args: " . (server.Has("args") ? MCPConfigManager.JoinArray(server["args"]) : "(none)") . "`n"
        summary .= "CWD: " . (server.Has("cwd") ? server["cwd"] : "(not set)") . "`n"
        if (server.Has("env")) {
            summary .= "Environment:`n"
            for key, value in server["env"] {
                summary .= "  " . key . "=" . value . "`n"
            }
        }
        if (server.Has("alwaysAllow")) {
            summary .= "Always Allow: " . server["alwaysAllow"] . "`n"
        }
        return summary
    }

    static TestServerCommand(*) {
        name := MCPConfigManager.GetSelectedServer()
        if (name = "") {
            MsgBox("Select a server to test.", "MCP Config Manager", "Icon!")
                return
            }
        json := MCPConfigManager.TryParseJson(MCPConfigManager.editor.Value)
        if (!IsObject(json) || !json.Has("mcpServers") || !json["mcpServers"].Has(name)) {
            MsgBox("Server not defined in configuration.", "MCP Config Manager", "Iconx")
                return
            }
        server := json["mcpServers"][name]
        command := server.Has("command") ? server["command"] : ""
        args := server.Has("args") ? server["args"] : []
        cwd := server.Has("cwd") ? server["cwd"] : ""
        details := "Command: " . command . "`nArgs: " . MCPConfigManager.JoinArray(args) . "`nCWD: " . cwd
        MsgBox("Test command preview:`n`n" . details . "`n`nUse manual terminal testing for execution.", "MCP Config Manager", "Iconi")
    }

    static JoinArray(arr) {
        if (!IsObject(arr)) {
            return ""
        }
        out := ""
        for index, item in arr {
            if (index > 1) {
                out .= ", "
            }
            out .= item
        }
        return out
    }

    static ShowHelp(*) {
        info := "⚙️ MCP Config Manager Help`n`n"
        info .= "Ctrl+Alt+C – Load configuration`n"
        info .= "Ctrl+Alt+S – Save configuration`n"
        info .= "Ctrl+Alt+B – Backup configuration`n"
        info .= "Ctrl+Alt+R – Restore from backup`n"
        info .= "F9 / Escape – Close GUI`n`n"
        info .= "Use Validate JSON before saving to ensure Claude accepts the file." 
        MsgBox(info, "MCP Config Manager Help", "Iconi")
    }

    static ValidateJson(*) {
        text := MCPConfigManager.editor.Value
        if (MCPConfigManager.ValidateJsonText(text)) {
            MCPConfigManager.statusBar.SetText("JSON validation passed.")
            TrayTip("MCP Config Manager", "JSON is valid")
                    } else {
            MCPConfigManager.statusBar.SetText("JSON is invalid – check syntax.")
            MsgBox("Configuration JSON is invalid. Fix syntax errors.", "MCP Config Manager", "Iconx")
        }
    }

    static ValidateJsonText(text) {
        if (Trim(text) = "") {
        return false
    }
        try {
            data := JSON.Load(text)
            return IsObject(data)
                } catch {
            return false
        }
    }

    static FormatJson(*) {
        text := MCPConfigManager.editor.Value
        try {
            data := JSON.Load(text)
            MCPConfigManager.editor.Value := MCPConfigManager.DumpJson(data)
            MCPConfigManager.statusBar.SetText("JSON formatted.")
        } catch as e {
            MsgBox("Cannot format invalid JSON: " . e.Message, "MCP Config Manager", "Iconx")
        }
    }

    static DumpJson(data) {
        try {
            return JSON.Dump(data, "indent")
        } catch {
            return MCPConfigManager.editor.Value
        }
    }

    static ResetTemplate(*) {
        confirm := MsgBox("Replace configuration with default template?", "MCP Config Manager", "Icon? YesNo")
        if (confirm != "Yes") {
            return
        }
        MCPConfigManager.WriteTemplate()
        MCPConfigManager.LoadConfig()
    }

    static WriteTemplate() {
        templateData := Map()
        exampleServer := Map("command", "python", "args", ["main.py"], "cwd", "./mcp/example-server")
        templateData["mcpServers"] := Map("example-server", exampleServer)
        template := JSON.Dump(templateData, "indent")
        FileDelete(MCPConfigManager.configPath)
        FileAppend(template, MCPConfigManager.configPath, "UTF-8")
        MCPConfigManager.AppendLog("Default template written to " . MCPConfigManager.configPath)
    }

    static CloseGui(*) {
        if !MCPConfigManager.gui
            return
        if !WinActive("ahk_id " MCPConfigManager.gui.Hwnd)
            return
        MCPConfigManager.gui.Hide()
        MCPConfigManager.statusBar.SetText("GUI hidden. Press Ctrl+Alt+C to reopen.")
    }
}

MCPConfigManager.Init()

OnExit((*) => MCPConfigManager.AppendLog("Script exiting."))

