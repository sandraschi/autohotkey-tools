; ==============================================================================
; Help System Pro
; @name: Help System Pro
; @version: 1.0.0
; @description: Comprehensive help system explaining AutoHotkey, the bridge, UI, and all features. Interactive documentation and user guide for the scriptlet collection.
; @description: Provides detailed explanations of AutoHotkey concepts, scriptlet features, usage instructions, and troubleshooting guides. Includes searchable content with topic navigation.
; @description: Essential reference tool for users learning AutoHotkey or exploring the scriptlet collection features and capabilities.
; @category: utilities
; @author: Sandra
; @hotkeys: F1, ^!h, ^!?
; @enabled: true
; @priority: 5
; @tag: help, documentation, guide, reference, utilities, learning, education
; @cli: --topic <name> - Open specific help topic
; @cli: --search <query> - Search help content
; @cli: --list-topics - List all available help topics
; @cli: --help - Show CLI usage and help system options
; @dependencies:
; ==============================================================================

#Requires AutoHotkey v2.0+
#SingleInstance Force
#Include %A_ScriptDir%\lib\ScriptletErrorHandler.ahk

OnError(LogError)

HelpSystemLogError(Thrown, Mode) {
    return ScriptletErrorHandler.Handle(Thrown, Mode)
}

class HelpSystem {
    static gui := ""
    static listView := ""
    static contentArea := ""
    static statusBar := ""
    static helpData := Map()
    static topicIndex := Map()
    static currentTopicId := ""

    static Init() {
        HelpSystem.LoadHelpData()
        HelpSystem.CreateGUI()
        HelpSystem.SetupHotkeys()
        HelpSystem.ShowTopic("overview")
    }

    static LoadHelpData() {
        helpFiles := Map(
            "overview", "docs\help_topics\overview.md",
            "autohotkey", "docs\help_topics\autohotkey.md",
            "bridge", "docs\help_topics\bridge.md",
            "webui", "docs\help_topics\webui.md",
            "scriptlets", "docs\help_topics\scriptlets.md",
            "installation", "docs\help_topics\installation.md",
            "faq", "docs\help_topics\faq.md"
        )

        for id, filePath in helpFiles {
            fullPath := A_ScriptDir . "\..\" . filePath
            if (FileExist(fullPath)) {
                content := FileRead(fullPath)
                ; Extract title from first H1 tag if available, otherwise use ID
                titleMatch := RegExMatch(content, "#\s*(.*?)\n", &match)
                title := titleMatch ? Trim(match[1]) : Format("Topic: {}", id)

                HelpSystem.helpData[id] := {title: title, content: content}
                HelpSystem.topicIndex[id] := {title: title, content: content}
            } else {
                HelpSystem.AppendLog("Warning: Help file not found: " . fullPath, "WARN")
                HelpSystem.helpData[id] := {title: Format("Error: Topic '{}' not found", id), content: "Help content for this topic could not be loaded."}
                HelpSystem.topicIndex[id] := {title: Format("Error: Topic '{}' not found", id), content: "Help content for this topic could not be loaded."}
            }
        }
    }

    static CreateGUI() {
        HelpSystem.gui := Gui("+Resize +MinSize800x600", "Help System Pro")
        HelpSystem.gui.SetFont("s9", "Segoe UI")

        ; Left pane for topic list
        HelpSystem.listView := HelpSystem.gui.Add("ListView", "x10 y10 w200 h540 -Hdr", ["Topic"])
        HelpSystem.listView.OnEvent("Click", HelpSystem.HandleTopicClick)
        HelpSystem.listView.OnEvent("ItemActivate", HelpSystem.HandleTopicActivate)

        ; Right pane for content
        HelpSystem.contentArea := HelpSystem.gui.Add("Edit", "x220 y10 w570 h540 ReadOnly VScroll HScroll -Wrap", "")
        HelpSystem.contentArea.SetFont("s10", "Consolas")

        ; Status bar
        HelpSystem.statusBar := HelpSystem.gui.Add("StatusBar", "", "Help System Ready")

        HelpSystem.gui.OnEvent("Close", HelpSystem.HideGUI)
        HelpSystem.gui.OnEvent("Escape", HelpSystem.HideGUI)
        HelpSystem.gui.OnEvent("Size", HelpSystem.OnResize)

        ; Populate list view
        for id, data in HelpSystem.helpData {
            HelpSystem.listView.Add(, data.title, id)
        }

        HelpSystem.gui.Show("w800 h600 Center")
    }

    static SetupHotkeys() {
        Hotkey("F1", (*) => HelpSystem.ToggleGUI())
        Hotkey("^!h", (*) => HelpSystem.ToggleGUI())
        Hotkey("^!?", (*) => HelpSystem.ToggleGUI())
    }

    static ToggleGUI() {
        if (HelpSystem.gui.Visible) {
            HelpSystem.HideGUI()
        } else {
            HelpSystem.ShowGUI()
        }
    }

    static ShowGUI() {
        if (!HelpSystem.gui) {
            HelpSystem.Init()
        }
        HelpSystem.gui.Show()
        HelpSystem.gui.Activate()
        HelpSystem.UpdateStatus("Help System Active")
    }

    static HideGUI() {
        if (HelpSystem.gui) {
            HelpSystem.gui.Hide()
            HelpSystem.UpdateStatus("Help System Hidden")
        }
    }

    static OnResize(gui, minMax, width, height) {
        if (!HelpSystem.listView || !HelpSystem.contentArea || !HelpSystem.statusBar) {
            return
        }
        padding := 10
        listViewWidth := 200
        contentAreaX := listViewWidth + padding * 2
        contentAreaWidth := width - contentAreaX - padding
        contentAreaHeight := height - HelpSystem.statusBar.H - padding * 2

        HelpSystem.listView.Move(padding, padding, listViewWidth, contentAreaHeight)
        HelpSystem.contentArea.Move(contentAreaX, padding, contentAreaWidth, contentAreaHeight)
        HelpSystem.statusBar.Move(0, height - HelpSystem.statusBar.H, width, HelpSystem.statusBar.H)
    }

    static UpdateStatus(message) {
        if (HelpSystem.statusBar) {
            HelpSystem.statusBar.SetText(message)
        }
        HelpSystem.AppendLog(message, "INFO")
    }

    static AppendLog(message, level := "INFO") {
        timestamp := FormatTime(A_Now, "yyyy-MM-dd HH:mm:ss")
        OutputDebug(Format("[{}] [{}] {}", timestamp, level, message))
    }

    static SelectRowById(id) {
        rowCount := HelpSystem.listView.GetCount()
        loop rowCount {
            row := A_Index
            if (HelpSystem.listView.GetRowData(row) = id) {
                HelpSystem.listView.Modify(row, "Select Focus")
                return row
            }
        }
        return 0
    }

    static ShowTopic(id) {
        if (!HelpSystem.topicIndex.Has(id)) {
            HelpSystem.contentArea.Value := "Topic not found: " . id
            HelpSystem.UpdateStatus("Topic not found: " . id)
            return
        }
        topic := HelpSystem.topicIndex[id]
        HelpSystem.currentTopicId := id
        HelpSystem.SelectRowById(id)
        HelpSystem.contentArea.Value := topic.content
        HelpSystem.gui.Title := "Help System Pro – " . topic.title
        HelpSystem.UpdateStatus("Showing: " . topic.title)
    }

    static HandleTopicClick(ctrl, row) {
        if (!row) {
            row := ctrl.GetNext(0, "F")
        }
        HelpSystem.ShowTopicByRow(row)
    }

    static HandleTopicActivate(ctrl, row) {
        HelpSystem.ShowTopicByRow(row)
    }

    static ShowTopicByRow(row) {
        if (!row) {
            return
        }
        id := HelpSystem.listView.GetRowData(row)
        if (!id) {
            return
        }
        HelpSystem.ShowTopic(id)
    }
}


; Register exit handler
OnExit((*) => HelpSystem.HideGui())

HelpSystem.Init()