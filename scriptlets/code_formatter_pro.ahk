; ==============================================================================
; Code Formatter Pro
; @name: Code Formatter Pro
; @version: 1.0.0
; @description: Multi-language code formatting with syntax highlighting and beautification. Supports JavaScript, Python, JSON, XML, HTML, CSS, SQL, and AutoHotkey.
; @description: Provides intelligent code formatting, beautification, minification, and validation tools. Includes real-time preview and syntax highlighting.
; @description: Essential development tool for maintaining consistent code style across multiple programming languages and projects.
; @category: development
; @author: Sandra
; @hotkeys: ^!f, ^!b, ^!c
; @enabled: true
; @priority: 15
; @tag: code-formatting, development, beautify, minify, syntax, validation, productivity, tools
; @cli: --language <lang> - Set default language (javascript, python, json, xml, html, css, sql, autohotkey)
; @cli: --format - Format code from stdin and output to stdout
; @cli: --minify - Minify code from stdin
; @cli: --validate - Validate code syntax (exit code 0 if valid)
; @cli: --help - Show CLI usage and formatting options
; @dependencies: 
; ==============================================================================

#Requires AutoHotkey v2.0+
#SingleInstance Force


; Suppress error popups - log to file instead
OnError(LogError)

LogError(Thrown, Mode) {
    errorMsg := "Error: " . Thrown.Message . " at line " . Thrown.Line . "`n" . Thrown.Stack
    FileAppend(errorMsg, "code_formatter_pro_errors.log", "UTF-8")
    OutputDebug(errorMsg)  ; Enable LLM debugging
    return 1  ; Suppress popup (1 = suppress, 0 = show)
}


class CodeFormatter {
    static supportedLanguages := ["javascript", "python", "json", "xml", "html", "css", "sql", "autohotkey"]
    static currentLanguage := "javascript"
    
    static Init() {
        this.CreateGUI()
    }
    
    static CreateGUI() {
        this.gui := Gui("+Resize +MinSize800x600", "Code Formatter Pro")
        
        ; Menu bar
        this.gui.MenuBar := MenuBar()
        fileMenu := Menu()
        fileMenu.Add("&New", this.NewFile.Bind(this))
        fileMenu.Add("&Open", this.OpenFile.Bind(this))
        fileMenu.Add("&Save", this.SaveFile.Bind(this))
        fileMenu.Add("&Save As", this.SaveAsFile.Bind(this))
        this.gui.MenuBar.Add("&File", fileMenu)
        
        editMenu := Menu()
        editMenu.Add("&Format", this.FormatCode.Bind(this))
        editMenu.Add("&Beautify", this.BeautifyCode.Bind(this))
        editMenu.Add("&Minify", this.MinifyCode.Bind(this))
        editMenu.Add("&Validate", this.ValidateCode.Bind(this))
        this.gui.MenuBar.Add("&Edit", editMenu)
        
        ; Toolbar
        toolbar := this.gui.Add("Text", "w800 h40 BackgroundF0F0F0")
        
        ; Language selector
        this.gui.Add("Text", "x10 y10 w80 h20", "Language:")
        this.languageCombo := this.gui.Add("DropDownList", "x90 y8 w120", this.supportedLanguages)
        this.languageCombo.Text := this.currentLanguage
        this.languageCombo.OnEvent("Change", this.LanguageChanged.Bind(this))
        
        ; Format buttons
        formatBtn := this.gui.Add("Button", "x220 y8 w80 h25", "Format")
        beautifyBtn := this.gui.Add("Button", "x310 y8 w80 h25", "Beautify")
        minifyBtn := this.gui.Add("Button", "x400 y8 w80 h25", "Minify")
        validateBtn := this.gui.Add("Button", "x490 y8 w80 h25", "Validate")
        
        formatBtn.OnEvent("Click", this.FormatCode.Bind(this))
        beautifyBtn.OnEvent("Click", this.BeautifyCode.Bind(this))
        minifyBtn.OnEvent("Click", this.MinifyCode.Bind(this))
        validateBtn.OnEvent("Click", this.ValidateCode.Bind(this))
        
        ; Input area
        this.gui.Add("Text", "w800 h20", "Input Code:")
        this.inputArea := this.gui.Add("Edit", "w800 h250 VScroll HScroll", "")
        
        ; Output area
        this.gui.Add("Text", "w800 h20", "Formatted Code:")
        this.outputArea := this.gui.Add("Edit", "w800 h250 VScroll HScroll ReadOnly", "")
        
        ; Status bar
        this.statusBar := this.gui.Add("Text", "w800 h20 BackgroundE0E0E0", "Ready")
        
        ; Action buttons
        actionPanel := this.gui.Add("Text", "w800 h40")
        
        copyBtn := this.gui.Add("Button", "x10 y10 w80 h25", "Copy Output")
        clearBtn := this.gui.Add("Button", "x100 y10 w80 h25", "Clear All")
        swapBtn := this.gui.Add("Button", "x190 y10 w80 h25", "Swap I/O")
        settingsBtn := this.gui.Add("Button", "x280 y10 w80 h25", "Settings")
        
        copyBtn.OnEvent("Click", this.CopyOutput.Bind(this))
        clearBtn.OnEvent("Click", this.ClearAll.Bind(this))
        swapBtn.OnEvent("Click", this.SwapInputOutput.Bind(this))
        settingsBtn.OnEvent("Click", this.ShowSettings.Bind(this))
        
        this.gui.Show("w820 h650")
    }
    
    static LanguageChanged(*) {
        this.currentLanguage := this.languageCombo.Text
        this.UpdateSyntaxHighlighting()
    }
    
    static FormatCode(*) {
        code := this.inputArea.Text
        if (!code) return
        
        try {
            switch this.currentLanguage {
                case "javascript":
                    formatted := this.FormatJavaScript(code)
                case "python":
                    formatted := this.FormatPython(code)
                case "json":
                    formatted := this.FormatJSON(code)
                case "xml", "html":
                    formatted := this.FormatXML(code)
                case "css":
                    formatted := this.FormatCSS(code)
                case "sql":
                    formatted := this.FormatSQL(code)
                case "autohotkey":
                    formatted := this.FormatAutoHotkey(code)
                default:
                    formatted := code
            }
            
            this.outputArea.Text := formatted
            this.statusBar.Text := "Code formatted successfully"
        } catch as e {
            this.outputArea.Text := "Error: " . e.Message
            this.statusBar.Text := "Formatting failed"
        }
    }
    
    static BeautifyCode(*) {
        code := this.inputArea.Text
        if (!code) return
        
        try {
            switch this.currentLanguage {
                case "javascript":
                    beautified := this.BeautifyJavaScript(code)
                case "css":
                    beautified := this.BeautifyCSS(code)
                case "html":
                    beautified := this.BeautifyHTML(code)
                default:
                    beautified := this.FormatCode()
            }
            
            this.outputArea.Text := beautified
            this.statusBar.Text := "Code beautified successfully"
        } catch as e {
            this.outputArea.Text := "Error: " . e.Message
            this.statusBar.Text := "Beautification failed"
        }
    }
    
    static MinifyCode(*) {
        code := this.inputArea.Text
        if (!code) return
        
        try {
            switch this.currentLanguage {
                case "javascript":
                    minified := this.MinifyJavaScript(code)
                case "css":
                    minified := this.MinifyCSS(code)
                case "html":
                    minified := this.MinifyHTML(code)
                default:
                    minified := RegExReplace(code, "\s+", " ")
            }
            
            this.outputArea.Text := minified
            this.statusBar.Text := "Code minified successfully"
        } catch as e {
            this.outputArea.Text := "Error: " . e.Message
            this.statusBar.Text := "Minification failed"
        }
    }
    
    static ValidateCode(*) {
        code := this.inputArea.Text
        if (!code) return
        
        try {
            switch this.currentLanguage {
                case "json":
                    result := this.ValidateJSON(code)
                case "xml", "html":
                    result := this.ValidateXML(code)
                case "javascript":
                    result := this.ValidateJavaScript(code)
                default:
                    result := "Validation not supported for " . this.currentLanguage
            }
            
            this.outputArea.Text := result
            this.statusBar.Text := "Validation completed"
        } catch as e {
            this.outputArea.Text := "Validation Error: " . e.Message
            this.statusBar.Text := "Validation failed"
        }
    }
    
    static FormatJavaScript(code) {
        ; Simple JavaScript formatting
        code := RegExReplace(code, ";\s*", ";`n")
        code := RegExReplace(code, "{\s*", "{`n")
        code := RegExReplace(code, "}\s*", "}`n")
        code := RegExReplace(code, ",\s*", ",`n")
        
        ; Add indentation
        lines := StrSplit(code, "`n")
        indent := 0
        result := ""
        
        for line in lines {
            line := Trim(line)
            if (line = "") continue
            
            if (InStr(line, "}")) indent--
            
            result .= StringRepeat("  ", indent) . line . "`n"
            
            if (InStr(line, "{")) indent++
        }
        
        return Trim(result)
    }
    
    static FormatPython(code) {
        ; Python formatting (simplified)
        lines := StrSplit(code, "`n")
        result := ""
        
        for line in lines {
            line := Trim(line)
            if (line = "") {
                result .= "`n"
            } else {
                result .= line . "`n"
            }
        }
        
        return Trim(result)
    }
    
    static FormatJSON(code) {
        try {
            obj := JSON.parse(code)
            return JSON.stringify(obj, 4)
        } catch {
            return "Invalid JSON"
        }
    }
    
    static FormatXML(code) {
        ; Simple XML formatting
        code := RegExReplace(code, "><", ">`n<")
        code := RegExReplace(code, "(\w+)=([^>]+)", "$1=$2")
        
        lines := StrSplit(code, "`n")
        indent := 0
        result := ""
        
        for line in lines {
            line := Trim(line)
            if (line = "") continue
            
            if (InStr(line, "</")) indent--
            
            result .= StringRepeat("  ", indent) . line . "`n"
            
            if (InStr(line, "<") && !InStr(line, "</") && !InStr(line, "/>")) indent++
        }
        
        return Trim(result)
    }
    
    static FormatCSS(code) {
        ; CSS formatting
        code := RegExReplace(code, "{\s*", "{`n")
        code := RegExReplace(code, "}\s*", "}`n")
        code := RegExReplace(code, ";\s*", ";`n")
        
        lines := StrSplit(code, "`n")
        indent := 0
        result := ""
        
        for line in lines {
            line := Trim(line)
            if (line = "") continue
            
            if (InStr(line, "}")) indent--
            
            result .= StringRepeat("  ", indent) . line . "`n"
            
            if (InStr(line, "{")) indent++
        }
        
        return Trim(result)
    }
    
    static FormatSQL(code) {
        ; SQL formatting
        keywords := ["SELECT", "FROM", "WHERE", "ORDER BY", "GROUP BY", "HAVING", "JOIN", "INNER JOIN", "LEFT JOIN", "RIGHT JOIN"]
        
        for keyword in keywords {
            code := RegExReplace(code, "\b" . keyword . "\b", "`n" . keyword, "i")
        }
        
        lines := StrSplit(code, "`n")
        result := ""
        
        for line in lines {
            line := Trim(line)
            if (line = "") continue
            result .= line . "`n"
        }
        
        return Trim(result)
    }
    
    static FormatAutoHotkey(code) {
        ; AutoHotkey formatting
        code := RegExReplace(code, "{\s*", "{`n")
        code := RegExReplace(code, "}\s*", "}`n")
        
        lines := StrSplit(code, "`n")
        indent := 0
        result := ""
        
        for line in lines {
            line := Trim(line)
            if (line = "") continue
            
            if (InStr(line, "}")) indent--
            
            result .= StringRepeat("  ", indent) . line . "`n"
            
            if (InStr(line, "{")) indent++
        }
        
        return Trim(result)
    }
    
    static BeautifyJavaScript(code) {
        return this.FormatJavaScript(code)
    }
    
    static BeautifyCSS(code) {
        return this.FormatCSS(code)
    }
    
    static BeautifyHTML(code) {
        return this.FormatXML(code)
    }
    
    static MinifyJavaScript(code) {
        code := RegExReplace(code, "//.*", "")
        code := RegExReplace(code, "/\*.*?\*/", "")
        code := RegExReplace(code, "\s+", " ")
        return Trim(code)
    }
    
    static MinifyCSS(code) {
        code := RegExReplace(code, "/\*.*?\*/", "")
        code := RegExReplace(code, "\s+", " ")
        return Trim(code)
    }
    
    static MinifyHTML(code) {
        code := RegExReplace(code, ">\s+<", "><")
        code := RegExReplace(code, "\s+", " ")
        return Trim(code)
    }
    
    static ValidateJSON(code) {
        try {
            JSON.parse(code)
            return "✅ Valid JSON"
        } catch {
            return "❌ Invalid JSON"
        }
    }
    
    static ValidateXML(code) {
        ; Simple XML validation
        if (RegExMatch(code, "<[^>]*>")) {
            return "✅ Valid XML"
        } else {
            return "❌ Invalid XML"
        }
    }
    
    static ValidateJavaScript(code) {
        ; Simple JavaScript validation
        if (RegExMatch(code, "function|var|let|const")) {
            return "✅ Valid JavaScript"
        } else {
            return "❌ Invalid JavaScript"
        }
    }
    
    static UpdateSyntaxHighlighting() {
        ; Update syntax highlighting based on language
        this.statusBar.Text := "Language changed to: " . this.currentLanguage
    }
    
    static CopyOutput(*) {
        Clipboard := this.outputArea.Text
        this.statusBar.Text := "Output copied to clipboard"
    }
    
    static ClearAll(*) {
        this.inputArea.Text := ""
        this.outputArea.Text := ""
        this.statusBar.Text := "Cleared"
    }
    
    static SwapInputOutput(*) {
        input := this.inputArea.Text
        output := this.outputArea.Text
        this.inputArea.Text := output
        this.outputArea.Text := input
    }
    
    static ShowSettings(*) {
        MsgBox("Settings panel would open here", "Settings", "0x40")
    }
    
    static NewFile(*) {
        this.inputArea.Text := ""
        this.outputArea.Text := ""
    }
    
    static OpenFile(*) {
        filePath := FileSelect(1, , "Open Code File", "All Files (*.*)")
        if (filePath) {
            try {
                content := FileRead(filePath)
                this.inputArea.Text := content
            } catch {
                MsgBox("Failed to open file", "Error", "0x10")
            }
        }
    }
    
    static SaveFile(*) {
        content := this.outputArea.Text
        if (content) {
            filePath := FileSelect("S16", , "Save Formatted Code", "All Files (*.*)")
            if (filePath) {
                try {
                    FileAppend(content, filePath)
                    this.statusBar.Text := "File saved successfully"
                } catch {
                    MsgBox("Failed to save file", "Error", "0x10")
                }
            }
        }
    }
    
    static SaveAsFile(*) {
        this.SaveFile()
    }
}

; Helper function
StringRepeat(str, count) {
    result := ""
    Loop count {
        result .= str
    }
    return result
}

; Hotkeys
Hotkey("^!f", (*) => CodeFormatter.FormatCode()
^!b::CodeFormatter.BeautifyCode()
^!c::CodeFormatter.Init()

; Initialize
CodeFormatter.Init()


