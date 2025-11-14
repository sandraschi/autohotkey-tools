#Requires AutoHotkey v2.0+
#SingleInstance Force
#Warn

; ==============================================================================
; AutoHotkey Scriptlet Generator
; @name: Scriptlet Generator
; @version: 1.0.0
; @description: Generate new scriptlets with proper structure, auto-fix, and dashboard integration
; @category: development
; @author: Sandra
; @enabled: true
; ==============================================================================

class ScriptletGenerator {
    static templates := Map()
    
    static Init() {
        this.LoadTemplates()
    }
    
    static LoadTemplates() {
        ; Basic template
        this.templates["basic"] := this.GetBasicTemplate()
        this.templates["gui"] := this.GetGUITemplate()
        this.templates["automation"] := this.GetAutomationTemplate()
        this.templates["utility"] := this.GetUtilityTemplate()
    }
    
    static GetBasicTemplate() {
        return "
(
#Requires AutoHotkey v2.0+
#SingleInstance Force
#Warn

; ==============================================================================
; {NAME}
; @name: {NAME}
; @version: 1.0.0
; @description: {DESCRIPTION}
; @category: {CATEGORY}
; @author: Sandra
; @hotkeys: {HOTKEYS}
; @enabled: true
; ==============================================================================

; Error handling - log to file instead of showing popups
OnError(LogError)

LogError(Thrown, Mode) {
    errorMsg := ""Error: "" . Thrown.Message . "" at line "" . Thrown.Line . ""`n"" . Thrown.Stack
    FileAppend(errorMsg, ""SCRIPT_ERRORS.log"", ""UTF-8"")
    OutputDebug(errorMsg)  ; Enable LLM debugging
    return 1  ; Suppress popup (1 = suppress, 0 = show)
}

; =============================================================================
; MAIN SCRIPT
; =============================================================================
SetWorkingDir A_ScriptDir

; {CODE}

; Initialize
Initialize()

; =============================================================================
; FUNCTIONS
; =============================================================================
Initialize() {
    ; Add initialization code here
}

)"
    }
    
    static GetGUITemplate() {
        return "
(
#Requires AutoHotkey v2.0+
#SingleInstance Force
#Warn

; ==============================================================================
; {NAME}
; @name: {NAME}
; @version: 1.0.0
; @description: {DESCRIPTION}
; @category: {CATEGORY}
; @author: Sandra
; @hotkeys: {HOTKEYS}
; @enabled: true
; ==============================================================================

; Error handling - log to file instead of showing popups
OnError(LogError)

LogError(Thrown, Mode) {
    errorMsg := ""Error: "" . Thrown.Message . "" at line "" . Thrown.Line . ""`n"" . Thrown.Stack
    FileAppend(errorMsg, ""SCRIPT_ERRORS.log"", ""UTF-8"")
    OutputDebug(errorMsg)  ; Enable LLM debugging
    return 1  ; Suppress popup (1 = suppress, 0 = show)
}

; =============================================================================
; CONFIGURATION
; =============================================================================
global guiMain

; =============================================================================
; MAIN SCRIPT
; =============================================================================
SetWorkingDir A_ScriptDir

CreateGUI()

; =============================================================================
; GUI CREATION
; =============================================================================
CreateGUI() {
    global guiMain
    
    ; Create main window
    guiMain := Gui(""+Resize"", ""{NAME}"")
    guiMain.BackColor := ""1E1E1E""
    guiMain.MarginX := 10
    guiMain.MarginY := 10
    guiMain.SetFont(""s10 cFFFFFF"", ""Segoe UI"")
    
    ; Add controls here
    guiMain.Add(""Text"", , ""Hello World!"")
    
    guiMain.OnEvent(""Close"", (*) => ExitApp())
    guiMain.OnEvent(""Escape"", (*) => guiMain.Hide())
    
    guiMain.Show(""w600 h400"")
}

; Set up hotkeys
Hotkey(""Escape"", (*) => {
    if (WinExist(guiMain.Hwnd))
        guiMain.Hide()
})
)"
    }
    
    static GetAutomationTemplate() {
        return "
(
#Requires AutoHotkey v2.0+
#SingleInstance Force
#Warn

; ==============================================================================
; {NAME}
; @name: {NAME}
; @version: 1.0.0
; @description: {DESCRIPTION}
; @category: {CATEGORY}
; @author: Sandra
; @hotkeys: {HOTKEYS}
; @enabled: true
; ==============================================================================

; Error handling - log to file instead of showing popups
OnError(LogError)

LogError(Thrown, Mode) {
    errorMsg := ""Error: "" . Thrown.Message . "" at line "" . Thrown.Line . ""`n"" . Thrown.Stack
    FileAppend(errorMsg, ""SCRIPT_ERRORS.log"", ""UTF-8"")
    OutputDebug(errorMsg)  ; Enable LLM debugging
    return 1  ; Suppress popup (1 = suppress, 0 = show)
}

; =============================================================================
; MAIN SCRIPT
; =============================================================================
SetWorkingDir A_ScriptDir

; {CODE}

; =============================================================================
; FUNCTIONS
; =============================================================================
)"
    }
    
    static GetUtilityTemplate() {
        return "
(
#Requires AutoHotkey v2.0+
#SingleInstance Force
#Warn

; ==============================================================================
; {NAME}
; @name: {NAME}
; @version: 1.0.0
; @description: {DESCRIPTION}
; @category: {CATEGORY}
; @author: Sandra
; @hotkeys: {HOTKEYS}
; @enabled: true
; ==============================================================================

; Error handling - log to file instead of showing popups
OnError(LogError)

LogError(Thrown, Mode) {
    errorMsg := ""Error: "" . Thrown.Message . "" at line "" . Thrown.Line . ""`n"" . Thrown.Stack
    FileAppend(errorMsg, ""SCRIPT_ERRORS.log"", ""UTF-8"")
    OutputDebug(errorMsg)  ; Enable LLM debugging
    return 1  ; Suppress popup (1 = suppress, 0 = show)
}

; =============================================================================
; MAIN SCRIPT
; =============================================================================
SetWorkingDir A_ScriptDir

; {CODE}

; =============================================================================
; FUNCTIONS
; =============================================================================
)"
    }
    
    static Generate(name, description, category := "utility", templateType := "basic", code := "", hotkeys := "") {
        ; Load template
        template := this.templates[templateType]
        if (!template) {
            template := this.templates["basic"]
        }
        
        ; Replace placeholders
        content := template
        content := StrReplace(content, "{NAME}", name)
        content := StrReplace(content, "{DESCRIPTION}", description)
        content := StrReplace(content, "{CATEGORY}", category)
        content := StrReplace(content, "{HOTKEYS}", hotkeys ? hotkeys : "")
        content := StrReplace(content, "{CODE}", code ? "`n" . code . "`n" : "")
        
        ; Generate filename
        filename := this.GenerateFilename(name)
        filePath := A_ScriptDir . "\..\scriptlets\" . filename
        
        ; Delete file if exists (FileAppend appends, doesn't overwrite)
        if (FileExist(filePath)) {
            try FileDelete(filePath)
        }
        
        ; Write file
        try {
            FileAppend(content, filePath, "UTF-8")
            
            ; Auto-fix the generated script
            this.AutoFixScript(filePath)
            
            ; Lint and validate
            this.ValidateScript(filePath)
        } catch as e {
            OutputDebug("Error writing file: " . e.Message . " at " . filePath)
            return ""
        }
        
        return filePath
    }
    
    static GenerateFilename(name) {
        ; Convert to lowercase, replace spaces with underscores
        filename := name
        filename := StrLower(filename)
        filename := StrReplace(filename, " ", "_")
        filename := filename . ".ahk"
        return filename
    }
    
    static AutoFixScript(filePath) {
        ; Apply autofix by running autofix_engine
        quotedPath := """" . filePath . """"
        cmd := "autohotkey.exe /ErrorStdOut " . A_ScriptDir . "\autofix_engine.ahk " . quotedPath
        RunWait(cmd, , "Hide")
    }
    
    static ValidateScript(filePath) {
        ; Validate syntax
        quotedPath := """" . filePath . """"
        cmd := "autohotkey.exe /ErrorStdOut " . quotedPath
        result := RunWait(cmd, , "Hide")
        
        if (result != 0) {
            OutputDebug("Validation failed: " . filePath)
        }
        
        ; Lint the script
        cmd := "autohotkey.exe /ErrorStdOut " . A_ScriptDir . "\linter.ahk " . quotedPath
        result := RunWait(cmd, , "Hide")
        
        if (result != 0) {
            OutputDebug("Linting issues found in " . filePath)
        }
    }
}

; Initialize
ScriptletGenerator.Init()

; Command line interface
if (A_Args.Length >= 2) {
    name := A_Args[1]
    description := A_Args[2]
    category := A_Args.Length > 2 ? A_Args[3] : "utility"
    templateType := A_Args.Length > 3 ? A_Args[4] : "basic"
    code := A_Args.Length > 4 ? A_Args[5] : ""
    
    filePath := ScriptletGenerator.Generate(name, description, category, templateType, code)
    OutputDebug("Generated scriptlet: " . filePath)
} else {
    OutputDebug("Usage: script_generator.ahk <name> <description> [category] [template] [code]")
    OutputDebug("Templates: basic, gui, automation, utility")
    ExitApp 1
}
