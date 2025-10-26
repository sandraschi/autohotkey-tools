; ==============================================================================
; AI-Powered Code Assistant
; @name: AI-Powered Code Assistant
; @version: 1.0.0
; @description: Advanced AI-powered coding assistant with real-time suggestions
; @category: development
; @author: Sandra
; @hotkeys: ^!a, Ctrl+Alt+I
; @enabled: true
; ==============================================================================

#Requires AutoHotkey v2.0+
#SingleInstance Force

class AICodeAssistant {
    static gui := ""
    static codeEditor := ""
    static suggestions := ""
    static currentFile := ""
    static aiModel := "gpt-3.5-turbo"
    
    static Init() {
        this.CreateGUI()
        this.SetupHotkeys()
    }
    
    static CreateGUI() {
        this.gui := Gui("+Resize +MinSize800x600", "AI Code Assistant")
        this.gui.BackColor := "0x1a1a1a"
        this.gui.SetFont("s10 cWhite", "Segoe UI")
        
        ; Title
        this.gui.Add("Text", "x20 y20 w760 Center Bold", "🤖 AI-Powered Code Assistant")
        this.gui.Add("Text", "x20 y50 w760 Center c0xcccccc", "Advanced coding assistance with AI suggestions")
        
        ; File operations
        this.gui.Add("Text", "x20 y90 w760 Bold", "📁 File Operations")
        
        openBtn := this.gui.Add("Button", "x20 y120 w150 h40 Background0x4a4a4a", "📂 Open File")
        openBtn.SetFont("s10 cWhite", "Segoe UI")
        openBtn.OnEvent("Click", this.OpenFile.Bind(this))
        
        saveBtn := this.gui.Add("Button", "x190 y120 w150 h40 Background0x4a4a4a", "💾 Save File")
        saveBtn.SetFont("s10 cWhite", "Segoe UI")
        saveBtn.OnEvent("Click", this.SaveFile.Bind(this))
        
        newBtn := this.gui.Add("Button", "x360 y120 w150 h40 Background0x4a4a4a", "📄 New File")
        newBtn.SetFont("s10 cWhite", "Segoe UI")
        newBtn.OnEvent("Click", this.NewFile.Bind(this))
        
        ; Code editor
        this.gui.Add("Text", "x20 y180 w760 Bold", "✏️ Code Editor")
        
        this.codeEditor := this.gui.Add("Edit", "x20 y210 w760 h200 Multi VScroll", "")
        this.codeEditor.SetFont("s9 cWhite", "Consolas")
        this.codeEditor.BackColor := "0x2d2d2d"
        
        ; AI suggestions
        this.gui.Add("Text", "x20 y430 w760 Bold", "🧠 AI Suggestions")
        
        this.suggestions := this.gui.Add("ListBox", "x20 y460 w760 h100")
        this.suggestions.SetFont("s9 cWhite", "Consolas")
        this.suggestions.BackColor := "0x2d2d2d"
        
        ; AI actions
        this.gui.Add("Text", "x20 y580 w760 Bold", "⚡ AI Actions")
        
        analyzeBtn := this.gui.Add("Button", "x20 y610 w150 h40 Background0x4a4a4a", "🔍 Analyze Code")
        analyzeBtn.SetFont("s10 cWhite", "Segoe UI")
        analyzeBtn.OnEvent("Click", this.AnalyzeCode.Bind(this))
        
        optimizeBtn := this.gui.Add("Button", "x190 y610 w150 h40 Background0x4a4a4a", "⚡ Optimize")
        optimizeBtn.SetFont("s10 cWhite", "Segoe UI")
        optimizeBtn.OnEvent("Click", this.OptimizeCode.Bind(this))
        
        debugBtn := this.gui.Add("Button", "x360 y610 w150 h40 Background0x4a4a4a", "🐛 Debug")
        debugBtn.SetFont("s10 cWhite", "Segoe UI")
        debugBtn.OnEvent("Click", this.DebugCode.Bind(this))
        
        generateBtn := this.gui.Add("Button", "x530 y610 w150 h40 Background0x4a4a4a", "✨ Generate")
        generateBtn.SetFont("s10 cWhite", "Segoe UI")
        generateBtn.OnEvent("Click", this.GenerateCode.Bind(this))
        
        ; Status
        this.gui.Add("Text", "x20 y660 w760 Center c0x888888", "Press Ctrl+Alt+A to open • Ctrl+Alt+I for instant suggestions")
        
        this.gui.Show("w800 h700")
    }
    
    static OpenFile(*) {
        try {
            filePath := FileSelect("1",, "Select Code File", "AutoHotkey (*.ahk);;All Files (*.*)")
            if (filePath) {
                this.currentFile := filePath
                content := FileRead(filePath)
                this.codeEditor.Text := content
                this.AnalyzeCode()
            }
        } catch as e {
            MsgBox("Error opening file: " . e.Message, "Error", "Iconx")
        }
    }
    
    static SaveFile(*) {
        try {
            if (this.currentFile) {
                FileWrite(this.codeEditor.Text, this.currentFile)
                TrayTip("File Saved!", "Code saved successfully", 2)
            } else {
                this.SaveAsFile()
            }
        } catch as e {
            MsgBox("Error saving file: " . e.Message, "Error", "Iconx")
        }
    }
    
    static SaveAsFile(*) {
        try {
            filePath := FileSelect("S16",, "Save Code File", "AutoHotkey (*.ahk);;All Files (*.*)")
            if (filePath) {
                this.currentFile := filePath
                FileWrite(this.codeEditor.Text, filePath)
                TrayTip("File Saved!", "Code saved successfully", 2)
            }
        } catch as e {
            MsgBox("Error saving file: " . e.Message, "Error", "Iconx")
        }
    }
    
    static NewFile(*) {
        this.currentFile := ""
        this.codeEditor.Text := ""
        this.suggestions.Text := ""
    }
    
    static AnalyzeCode(*) {
        try {
            code := this.codeEditor.Text
            if (!code) {
                MsgBox("No code to analyze!", "Error", "Iconx")
                return
            }
            
            ; Simulate AI analysis
            suggestions := this.GenerateSuggestions(code)
            this.suggestions.Text := suggestions
            
            TrayTip("Code Analyzed!", "AI suggestions generated", 2)
        } catch as e {
            MsgBox("Error analyzing code: " . e.Message, "Error", "Iconx")
        }
    }
    
    static OptimizeCode(*) {
        try {
            code := this.codeEditor.Text
            if (!code) {
                MsgBox("No code to optimize!", "Error", "Iconx")
                return
            }
            
            ; Simulate AI optimization
            optimizedCode := this.ApplyOptimizations(code)
            this.codeEditor.Text := optimizedCode
            
            TrayTip("Code Optimized!", "AI optimizations applied", 2)
        } catch as e {
            MsgBox("Error optimizing code: " . e.Message, "Error", "Iconx")
        }
    }
    
    static DebugCode(*) {
        try {
            code := this.codeEditor.Text
            if (!code) {
                MsgBox("No code to debug!", "Error", "Iconx")
                return
            }
            
            ; Simulate AI debugging
            debugSuggestions := this.FindBugs(code)
            this.suggestions.Text := debugSuggestions
            
            TrayTip("Code Debugged!", "Potential issues found", 2)
        } catch as e {
            MsgBox("Error debugging code: " . e.Message, "Error", "Iconx")
        }
    }
    
    static GenerateCode(*) {
        try {
            ; Show code generation dialog
            inputGui := Gui("+AlwaysOnTop", "Generate Code")
            inputGui.BackColor := "0x2d2d2d"
            inputGui.SetFont("s10 cWhite", "Segoe UI")
            
            inputGui.Add("Text", "x20 y20 w300 Center Bold", "✨ AI Code Generator")
            inputGui.Add("Text", "x20 y60 w300", "Describe what you want to create:")
            
            description := inputGui.Add("Edit", "x20 y90 w300 h100 Multi")
            description.SetFont("s9 cWhite", "Segoe UI")
            
            generateBtn := inputGui.Add("Button", "x20 y210 w140 h40 Background0x4a4a4a", "Generate")
            generateBtn.SetFont("s10 cWhite", "Segoe UI")
            generateBtn.OnEvent("Click", () => {
                desc := description.Text
                inputGui.Destroy()
                this.GenerateCodeFromDescription(desc)
            })
            
            cancelBtn := inputGui.Add("Button", "x180 y210 w140 h40 Background0x4a4a4a", "Cancel")
            cancelBtn.SetFont("s10 cWhite", "Segoe UI")
            cancelBtn.OnEvent("Click", () => inputGui.Destroy())
            
            inputGui.Show("w340 h270")
            
        } catch as e {
            MsgBox("Error generating code: " . e.Message, "Error", "Iconx")
        }
    }
    
    static GenerateCodeFromDescription(description) {
        try {
            ; Simulate AI code generation
            generatedCode := this.CreateCodeFromDescription(description)
            this.codeEditor.Text := generatedCode
            
            TrayTip("Code Generated!", "AI-generated code created", 2)
        } catch as e {
            MsgBox("Error generating code: " . e.Message, "Error", "Iconx")
        }
    }
    
    static GenerateSuggestions(code) {
        suggestions := "AI Code Analysis Results:`n`n"
        
        ; Analyze code structure
        if (InStr(code, "class ")) {
            suggestions .= "✓ Object-oriented code detected`n"
        }
        if (InStr(code, "try")) {
            suggestions .= "✓ Error handling present`n"
        }
        if (InStr(code, "Loop")) {
            suggestions .= "✓ Loops detected`n"
        }
        
        suggestions .= "`nSuggestions:`n"
        suggestions .= "• Consider adding comments for complex logic`n"
        suggestions .= "• Use consistent variable naming`n"
        suggestions .= "• Add error handling for file operations`n"
        suggestions .= "• Consider breaking large functions into smaller ones`n"
        
        return suggestions
    }
    
    static ApplyOptimizations(code) {
        ; Simple optimizations
        optimized := code
        
        ; Remove unnecessary spaces
        optimized := RegExReplace(optimized, "  +", " ")
        
        ; Add performance suggestions
        optimized := "/* AI Optimization Applied */`n" . optimized
        
        return optimized
    }
    
    static FindBugs(code) {
        bugs := "🐛 Potential Issues Found:`n`n"
        
        ; Check for common issues
        if (InStr(code, "MsgBox") && !InStr(code, "MsgBox(")) {
            bugs .= "• MsgBox(syntax may need parentheses`n"
        }
        if (InStr(code,  "FileRead") && !InStr(code,  "FileRead(")) {
            bugs .= "• FileRead syntax may need parentheses`n"
        }
        if (InStr(code, "catch Error as")) {
            bugs .= "• Catch syntax should be 'catch as e'`n"
        }
        
        bugs .= "`nRecommendations:`n"
        bugs .= "• Test error handling paths`n"
        bugs .= "• Validate input parameters`n"
        bugs .= "• Check file existence before operations`n"
        
        return bugs
    }
    
    static CreateCodeFromDescription(description) {
        ; Simple code generation based on description
        code := "; Generated by AI Code Assistant`n"
        code .= "; Description: " . description . "`n`n"
        
        if (InStr(description, "gui") || InStr(description, "window")) {
            code .= "gui := Gui()`n"
            code .= "gui.Add(`"Text`", `"Hello World`")`n"
            code .= "gui.Show()`n"
        } else if (InStr(description, "file") || InStr(description, "read")) {
            code .= "filePath := FileSelect(`"1`")`n"
            code .= "if (filePath) {`n"
            code .= "    content := FileRead(filePath)`n"
            code .= "    MsgBox(content)`n"
            code .= "}`n"
        } else {
            code .= "; Your code here`n"
            code .= "MsgBox(`"Hello from AI-generated code!`")`n"
        }
        
        return code
    }
    
    static SetupHotkeys() {
        ; Main hotkey
        Hotkey("^!a", (*) => this.CreateGUI()
        
        ; Instant suggestions
        Hotkey("^!i", (*) => this.AnalyzeCode()
        
        ; Close with Escape
        Hotkey("Escape", (*) => {
            if (WinExist("AI Code Assistant")) {
                WinClose("AI Code Assistant")
            }
        }
    }
}

; Initialize
AICodeAssistant.Init()


