#Requires AutoHotkey v2.0+
#SingleInstance Force
#Include %A_ScriptDir%\lib\ScriptletErrorHandler.ahk


; Suppress error popups - log to file instead
OnError(LogError)


; ==============================================================================
; Smart Clipboard Manager
; @name: Smart Clipboard Manager
; @version: 1.0.0
; @description: Advanced clipboard management with history, formatting, and automation. Enhanced clipboard manager with intelligent history tracking and text transformation capabilities.
; @description: Provides clipboard history, text formatting tools, automation triggers, and smart paste features. Includes search, filtering, and quick formatting options for improved productivity.
; @description: Essential productivity tool for power users who frequently copy and paste content with advanced formatting and automation needs.
; @category: productivity
; @author: Sandra
; @hotkeys: ^!c, ^!v, ^!h, ^!f
; @enabled: true
; @priority: 10
; @tag: clipboard, productivity, history, formatting, automation, paste, copy, workflow
; @cli: --history - Show clipboard history
; @cli: --format <type> - Apply formatting to clipboard (upper, lower, title, sentence)
; @cli: --clear - Clear clipboard history
; @cli: --help - Show CLI usage and clipboard manager options
; @dependencies: 
; ==============================================================================

class SmartClipboard {
    static history := []
    static maxHistory := 50
    static gui := ""
    static historyList := ""
    static formatButtons := []
    static isMonitoring := false
    
    static Init() {
        this.StartMonitoring()
        this.CreateGUI()
        this.SetupHotkeys()
    }
        
    static StartMonitoring() {
        OnClipboardChange((type) => this.OnClipboardChange(type))
        this.isMonitoring := true
    }
    
    static OnClipboardChange(type) {
        if (type = 1) { ; Text
            text := ClipboardAll()
            if (text && text != this.GetLastClipboard()) {
                this.AddToHistory(text)
                this.AppendLog("Clipboard updated: " . SubStr(text, 1, 50))
            }
        }
    }
    
    static AddToHistory(text) {
        timestamp := FormatTime(A_Now, "yyyy-MM-dd HH:mm:ss")
        this.history.Push({
            text: text,
            timestamp: timestamp,
            length: StrLen(text),
            type: this.DetectType(text)
        })
        
        ; Keep only maxHistory items
                if (this.history.Length > this.maxHistory) {
                    this.history.RemoveAt(1)
                }
        
        this.UpdateHistoryList()
            }
    
    static DetectType(text) {
        if (RegExMatch(text, "^https?://")) {
            return "URL"
        } else if (RegExMatch(text, "^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$")) {
            return "Email"
        } else if (RegExMatch(text, "^\d{4}-\d{2}-\d{2}$")) {
            return "Date"
        } else if (RegExMatch(text, "^\d+$")) {
            return "Number"
        } else if (StrLen(text) > 100) {
            return "Long Text"
        } else {
            return "Text"
        }
    }
    
    static CreateGUI() {
        this.gui := Gui("+Resize", "Smart Clipboard Manager")
        
        ; Title
        this.gui.Add("Text", "w800 h30 Center", "?? Smart Clipboard Manager")
        
        ; History list
        this.gui.Add("Text", "w800 h20", "Clipboard History:")
        this.historyList := this.gui.Add("ListView", "w800 h300", ["Time", "Type", "Preview", "Length"])
        this.historyList.OnEvent("DoubleClick", this.PasteFromHistory.Bind(this))
        
        ; Control buttons
        controlPanel := this.gui.Add("Text", "w800 h40")
        
        pasteBtn := this.gui.Add("Button", "x10 y10 w80 h25", "Paste")
        copyBtn := this.gui.Add("Button", "x100 y10 w80 h25", "Copy")
        clearBtn := this.gui.Add("Button", "x190 y10 w80 h25", "Clear")
        formatBtn := this.gui.Add("Button", "x280 y10 w80 h25", "Format")
        
        pasteBtn.OnEvent("Click", this.PasteFromHistory.Bind(this))
        copyBtn.OnEvent("Click", this.CopySelected.Bind(this))
        clearBtn.OnEvent("Click", this.ClearHistory.Bind(this))
        formatBtn.OnEvent("Click", this.FormatSelected.Bind(this))
        
        ; Formatting options
        this.gui.Add("Text", "w800 h20", "Quick Format:")
        formatPanel := this.gui.Add("Text", "w800 h60")
        
        upperBtn := this.gui.Add("Button", "x10 y10 w80 h25", "UPPER")
        lowerBtn := this.gui.Add("Button", "x100 y10 w80 h25", "lower")
        titleBtn := this.gui.Add("Button", "x190 y10 w80 h25", "Title")
        trimBtn := this.gui.Add("Button", "x280 y10 w80 h25", "Trim")
        
        upperBtn.OnEvent("Click", (*) => SmartClipboard.ApplyFormat("upper"))
        lowerBtn.OnEvent("Click", (*) => SmartClipboard.ApplyFormat("lower"))
        titleBtn.OnEvent("Click", (*) => SmartClipboard.ApplyFormat("title"))
        trimBtn.OnEvent("Click", (*) => SmartClipboard.ApplyFormat("trim"))
        
        ; Log area
        this.gui.Add("Text", "w800 h20", "Activity Log:")
        this.logArea := this.gui.Add("Edit", "w800 h150 VScroll HScroll ReadOnly", "")
        
        ; Status bar
        this.statusBar := this.gui.Add("Text", "w800 h20 BackgroundE0E0E0", "Ready - Monitoring clipboard changes")
        
        
        ; Add exit handlers
        this.gui.OnEvent("Close", (*) => ExitApp())
        this.gui.OnEvent("Escape", (*) => ExitApp())
        this.gui.Show("w820 h700")
        this.UpdateHistoryList()
    }
    
    static UpdateHistoryList() {
        if (!this.historyList)
            return
        
        this.historyList.Delete()
        
        ; Add items in reverse order (newest first)
        loop this.history.Length {
            i := this.history.Length - A_Index + 1
            item := this.history[i]
            preview := SubStr(item.text, 1, 50)
            if (StrLen(item.text) > 50) {
                preview .= "..."
            }
            this.historyList.Add("", item.timestamp, item.type, preview, item.length)
        }
    }
    
    static PasteFromHistory(*) {
        selected := this.historyList.GetNext()
        if (selected > 0) {
            item := this.history[this.history.Length - selected + 1]
            Clipboard := item.text
            Send("^v")
            this.AppendLog("Pasted from history: " . SubStr(item.text, 1, 30))
        }
    }
    
    static CopySelected(*) {
        selected := this.historyList.GetNext()
        if (selected > 0) {
            item := this.history[this.history.Length - selected + 1]
            Clipboard := item.text
            this.AppendLog("Copied to clipboard: " . SubStr(item.text, 1, 30))
        }
    }
    
    static ClearHistory(*) {
        this.history := []
        this.UpdateHistoryList()
        this.AppendLog("Clipboard history cleared")
    }
    
    static FormatSelected(*) {
        selected := this.historyList.GetNext()
        if (selected > 0) {
            item := this.history[this.history.Length - selected + 1]
            formatted := this.FormatText(item.text)
            Clipboard := formatted
            this.AppendLog("Formatted and copied: " . SubStr(formatted, 1, 30))
        }
    }
    
    static ApplyFormat(formatType) {
        currentText := ClipboardAll()
        if (currentText) {
            formatted := this.FormatText(currentText, formatType)
            Clipboard := formatted
            this.AppendLog("Applied " . formatType . " format")
        }
    }
    
    static FormatText(text, formatType := "smart") {
        switch formatType {
            case "upper":
                return StrUpper(text)
            case "lower":
                return StrLower(text)
            case "title":
                return this.ToTitleCase(text)
            case "trim":
                return Trim(text)
            default:
                return this.SmartFormat(text)
        }
    }
    
    static ToTitleCase(text) {
        words := StrSplit(text, " ")
        result := ""
        for word in words {
            if (word) {
                result .= StrUpper(SubStr(word, 1, 1)) . StrLower(SubStr(word, 2)) . " "
            }
        }
        return Trim(result)
    }
    
    static SmartFormat(text) {
        ; Auto-detect and format based on content type
        if (RegExMatch(text, "^https?://")) {
            return text ; URLs don't need formatting
        } else if (RegExMatch(text, "^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$")) {
            return StrLower(text) ; Emails to lowercase
        } else if (RegExMatch(text, "^\d{4}-\d{2}-\d{2}$")) {
            return text ; Dates are fine as-is
        } else {
            return this.ToTitleCase(text) ; Default to title case
        }
    }
    
    static GetLastClipboard() {
        if (this.history.Length > 0) {
            return this.history[this.history.Length].text
        }
        return ""
    }
    
    static SetupHotkeys() {
        Hotkey("^!c", (*) => this.ShowGUI())
        Hotkey("^!v", (*) => this.QuickPaste())
        Hotkey("^!h", (*) => this.ShowHistory())
        Hotkey("^!f", (*) => this.QuickFormat())
    }
    
    static ShowGUI(*) {
        this.gui.Show()
        this.gui.Activate()
    }
    
    static QuickPaste(*) {
        if (this.history.Length > 0) {
            this.PasteFromHistory()
        }
    }
    
    static ShowHistory(*) {
        this.gui.Show()
        this.historyList.Focus()
    }
    
    static QuickFormat(*) {
        this.ApplyFormat("smart")
    }
    
    static AppendLog(message) {
        if (!this.logArea)
            return
        
        timestamp := FormatTime(A_Now, "HH:mm:ss")
        this.logArea.Text .= "[" . timestamp . "] " . message . "`n"
        
        ; Auto-scroll to bottom
        this.logArea.Focus()
        Send("^{End}")
    }
}

; Initialize the clipboard manager
SmartClipboard.Init()
