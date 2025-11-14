#Requires AutoHotkey v2.0+
#SingleInstance Force
#Warn

; ==============================================================================
; AutoFix Engine - Unified autofix system for AutoHotkey v2
; @name: AutoFix Engine
; @version: 1.0.0
; @description: Comprehensive autofix system with silent execution and safety checks
; @category: development
; @author: Sandra
; @enabled: true
; ==============================================================================

class AutoFixEngine {
    static fixes := []
    static enabled := true
    static dryRun := false
    static backupDir := A_ScriptDir . "\backups"
    
    static Init() {
        this.LoadPatterns()
        this.SetupBackupDir()
    }
    
    static SetupBackupDir() {
        if (!DirExist(this.backupDir)) {
            DirCreate(this.backupDir)
        }
    }
    
    static LoadPatterns() {
        ; Register all fix patterns
        this.RegisterPattern("FormatTime", 
            "FormatTime\s+(\w+),\s*,", 
            "$1 := FormatTime(A_Now,", 
            "High")
        
        this.RegisterPattern("MsgBox", 
            "MsgBox\s*,", 
            "MsgBox(", 
            "High")
        
        this.RegisterPattern("FileRead", 
            "FileRead\s+(\w+),\s*(\w+)", 
            "$1 := FileRead($2)", 
            "High")
        
        this.RegisterPattern("FileDelete", 
            "FileDelete\s+(\w+)", 
            "try FileDelete($1)", 
            "Medium")
        
        this.RegisterPattern("StringReplace", 
            "StringReplace\s*\(", 
            "StrReplace(", 
            "High")
        
        this.RegisterPattern("StringSplit", 
            "StringSplit\s*\(", 
            "StrSplit(", 
            "High")
        
        this.RegisterPattern("StringLen", 
            "StringLen\s*\(", 
            "StrLen(", 
            "High")
        
        this.RegisterPattern("ToUpper", 
            "\.ToUpper\(\)", 
            "StrUpper()", 
            "High")
        
        this.RegisterPattern("ToLower", 
            "\.ToLower\(\)", 
            "StrLower()", 
            "High")
        
        this.RegisterPattern("Random", 
            "(\w+)\s*:=\s*Random\s*\(\s*(\d+)\s*,\s*(\d+)\s*\)", 
            "Random($1, $2, $3)", 
            "High")
        
        this.RegisterPattern("LoopSyntax", 
            "Loop\s*,", 
            "Loop", 
            "High")
        
        this.RegisterPattern("GuiCommand", 
            "Gui\s*,", 
            "Gui(", 
            "High")
        
        this.RegisterPattern("GuiAdd", 
            "GuiAdd\s*,", 
            "Add(", 
            "High")
        
        this.RegisterPattern("GuiShow", 
            "GuiShow\s*,", 
            "Show(", 
            "High")
        
        this.RegisterPattern("GuiClose", 
            "GuiClose\s*,", 
            "Close()", 
            "High")
    }
    
    static RegisterPattern(name, pattern, replacement, confidence) {
        this.fixes.Push({
            name: name,
            pattern: pattern,
            replacement: replacement,
            confidence: confidence,
            applied: 0
        })
    }
    
    static ApplyFixes(filePath, dryRun := false) {
        result := {
            success: false,
            fixesApplied: 0,
            issuesFixed: [],
            errors: [],
            backupPath: ""
        }
        
        try {
            ; Create backup
            backupPath := this.CreateBackup(filePath)
            result.backupPath := backupPath
            
            ; Read file content
            content := FileRead(filePath)
            if (!content) {
                result.errors.Push("Failed to read file")
                return result
            }
            
            originalContent := content
            fixesApplied := 0
            
            ; Apply each fix pattern
            for fix in this.fixes {
                oldContent := content
                content := RegExReplace(content, fix.pattern, fix.replacement)
                
                if (oldContent != content) {
                    fixesApplied++
                    result.issuesFixed.Push(fix.name)
                    fix.applied++
                }
            }
            
            ; If changes were made and not dry run, save file
            if (fixesApplied > 0 && !dryRun) {
                FileAppend(content, filePath, "UTF-8")
            }
            
            result.fixesApplied := fixesApplied
            result.success := true
            
            ; Validate syntax if changes were made
            if (fixesApplied > 0) {
                validation := SilentExecutor.ValidateSyntax(filePath)
                if (!validation.valid) {
                    ; Restore backup on validation failure
                    this.RestoreBackup(filePath, backupPath)
                    result.errors.Push("Syntax validation failed after fixes")
                    result.fixesApplied := 0
                    result.success := false
                }
            }
            
        } catch as e {
            result.errors.Push("Error: " . e.Message)
        }
        
        return result
    }
    
    static CreateBackup(filePath) {
        SplitPath(filePath, &filename, &dir)
        timestamp := FormatTime(A_Now, "yyyyMMddHHmmss")
        backupPath := this.backupDir . "\" . filename . "." . timestamp . ".bak"
        FileCopy(filePath, backupPath)
        return backupPath
    }
    
    static RestoreBackup(filePath, backupPath) {
        FileCopy(backupPath, filePath, true)
    }
    
    static GetStatistics() {
        stats := {
            totalPatterns: this.fixes.Length,
            totalApplied: 0
        }
        
        for fix in this.fixes {
            stats.totalApplied += fix.applied
        }
        
        return stats
    }
}

class SilentExecutor {
    static Execute(scriptPath, args := "") {
        ; CRITICAL: Quote scriptPath to prevent /ErrorStdOut being misinterpreted
        ; /ErrorStdOut must be a CLI flag, NOT interpreted as a filename
        quotedScript := """" . scriptPath . """"
        cmd := "autohotkey.exe /ErrorStdOut " . quotedScript . " " . args
        
        try {
            RunWait(cmd, , , "UTF-8", &stdout, &stderr)
            exitCode := 0
        } catch as e {
            exitCode := 1
            stderr := e.Message
            stdout := ""
        }
        
        ; Capture output without blocking user
        return {
            exitCode: exitCode,
            stdout: stdout,
            stderr: stderr
        }
    }
    
    static ValidateSyntax(scriptPath) {
        ; Syntax check with no popups
        ; ALWAYS quote script path to avoid misinterpretation
        quotedScript := """" . scriptPath . """"
        cmd := "autohotkey.exe /ErrorStdOut " . quotedScript
        
        try {
            RunWait(cmd, , , "UTF-8", &stdout, &stderr)
            exitCode := 0
        } catch as e {
            exitCode := 1
            stderr := e.Message
            stdout := ""
        }
        
        return {
            valid: exitCode = 0,  ; 0 = no errors
            exitCode: exitCode,
            stderr: stderr,
            stdout: stdout
        }
    }
    
    static Lint(scriptPath) {
        ; Run linter silently
        quotedScript := """" . scriptPath . """"
        cmd := "autohotkey.exe /ErrorStdOut " . A_ScriptDir . "\linter.ahk " . quotedScript
        
        try {
            RunWait(cmd, , , "UTF-8", &stdout, &stderr)
            exitCode := 0
        } catch as e {
            exitCode := 1
            stderr := e.Message
            stdout := ""
        }
        
        return {
            pass: exitCode = 0,
            exitCode: exitCode,
            stdout: stdout,
            stderr: stderr
        }
    }
}

; Initialize
AutoFixEngine.Init()

; Command line interface
if (A_Args.Length > 0) {
    filePath := A_Args[1]
    dryRun := A_Args.Length > 1 && A_Args[2] = "--dry-run"
    
    if (!FileExist(filePath)) {
        OutputDebug("Error: File not found: " . filePath)
        ExitApp 1
    }
    
    result := AutoFixEngine.ApplyFixes(filePath, dryRun)
    
    if (result.success) {
        if (result.fixesApplied > 0) {
            OutputDebug("Applied " . result.fixesApplied . " fixes to " . filePath)
            for fix in result.issuesFixed {
                OutputDebug("  - Fixed: " . fix)
            }
        } else {
            OutputDebug("No fixes needed for " . filePath)
        }
        ExitApp 0
    } else {
        for error in result.errors {
            OutputDebug("Error: " . error)
        }
        ExitApp 1
    }
}

