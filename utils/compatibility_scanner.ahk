#Requires AutoHotkey v2.0+
#SingleInstance Force

class CompatibilityScanner {
    static scanDirs := [A_ScriptDir . "\..\scriptlets", A_ScriptDir . "\..\tests"]
    static outputFile := A_ScriptDir . "\..\compatibility_scan_report.txt"
    static patterns := []
    static issues := []
    
    static Init() {
        ; Load patterns directly
        this.patterns.Push(Map("pattern", "MsgBox,", "message", "v1 syntax", "severity", "ERROR", "category", "v1"))
        this.patterns.Push(Map("pattern", "Gui,", "message", "v1 syntax", "severity", "ERROR", "category", "v1"))
        this.patterns.Push(Map("pattern", "Loop,", "message", "v1 syntax", "severity", "ERROR", "category", "v1"))
        this.patterns.Push(Map("pattern", "Random,", "message", "v1 syntax", "severity", "ERROR", "category", "v1"))
        
        if (A_Args.Length > 0 && A_Args[1] = "--fix") {
            this.FixAllIssues()
        } else {
            this.ScanAllScripts()
        }
    }
    
    static LoadPatterns() {
        try {
            patternFile := A_ScriptDir . "\scanner_patterns.json"
            TrayTip("Loading: " . patternFile, "Scanner", "Icon!")
            content := FileRead(patternFile)
            if (!content) {
                TrayTip("Failed to load patterns", "Scanner", "Icon!")
                return
            }
            lines := StrSplit(content, "`n")
            for line in lines {
                pattern := Trim(line)
                if (pattern != "" && SubStr(pattern, 1, 1) != ";") {
                    this.patterns.Push(Map("pattern", pattern, "message", "v1 syntax", "severity", "ERROR", "category", "v1"))
                }
            }
            TrayTip("Loaded " . this.patterns.Length . " patterns", "Scanner", "Icon!")
        } catch as e {
            TrayTip("Error: " . e.Message, "Scanner", "Icon!")
        }
    }
    
    static ScanAllScripts() {
        this.issues := []
        scannedCount := 0
        
        this.AppendLog("Starting compatibility scan...")
        this.AppendLog("Patterns count: " . this.patterns.Length)
        
        for scanDir in this.scanDirs {
            if (DirExist(scanDir)) {
                Loop Files, scanDir . "\*.ahk", "R" {
                    filePath := A_LoopFileFullPath
                    try {
                        content := FileRead(filePath)
                        if (content) {
                            scannedCount++
                            this.ScanFile(filePath, content)
                        }
                    } catch as e {
                        this.AppendLog("Error reading: " . filePath)
                    }
                }
            }
        }
        
        this.AppendLog("Scanned " . scannedCount . " files, found " . this.issues.Length . " issues")
        this.GenerateReport()
    }
    
    static ScanFile(filePath, content) {
        for i, pattern in this.patterns {
            searchTerm := pattern["pattern"]
            if (InStr(content, searchTerm)) {
                this.issues.Push({
                    file: filePath,
                    pattern: searchTerm,
                    message: pattern["message"],
                    severity: pattern["severity"],
                    category: pattern["category"]
                })
            }
        }
    }
    
    static GenerateReport() {
        try {
            ; Delete old report
            if (FileExist(this.outputFile)) {
                FileDelete(this.outputFile)
            }
            
            report := "Compatibility Scan Report`n"
            report .= "Generated: " . FormatTime(A_Now, "yyyy-MM-dd HH:mm:ss") . "`n`n"
            report .= "Total Issues: " . this.issues.Length . "`n`n"
            
            for issue in this.issues {
                report .= "File: " . issue.file . "`n"
                report .= "Message: " . issue.message . "`n"
                report .= "Severity: " . issue.severity . "`n"
                report .= "---`n"
            }
            
            FileAppend(report, this.outputFile, "UTF-8")
            this.AppendLog("Report saved to: " . this.outputFile)
        } catch as e {
            this.AppendLog("Error generating report: " . e.Message)
        }
    }
    
    static FixAllIssues() {
        this.ScanAllScripts()
        
        fixedCount := 0
        lastFile := ""
        
        for issue in this.issues {
            file := issue.file
            if (file != lastFile) {
                try {
                    content := FileRead(file)
                    if (!content) {
                        this.AppendLog("Failed to read: " . file)
                        lastFile := file
                        continue
                    }
                    
                    ; Create backup
                    backupFile := file . ".bak"
                    FileCopy(file, backupFile, true)
                    
                    ; Apply fixes
                    newContent := content
                    
                    ; Fix MsgBox patterns
                    newContent := RegExReplace(newContent, "MsgBox,\s*64\s*,", "MsgBox(", , 1)
                    newContent := RegExReplace(newContent, "MsgBox,\s*16\s*,", "MsgBox(", , 1)
                    newContent := RegExReplace(newContent, "MsgBox,\s*0\s*,", "MsgBox(", , 1)
                    newContent := RegExReplace(newContent, "MsgBox,\s*48\s*,", "MsgBox(", , 1)
                    newContent := RegExReplace(newContent, "MsgBox,\s*1\s*,", "MsgBox(", , 1)
                    newContent := RegExReplace(newContent, "MsgBox,\s*4\s*,", "MsgBox(", , 1)
                    newContent := RegExReplace(newContent, "MsgBox,\s*5\s*,", "MsgBox(", , 1)
                    
                    ; Fix other v1 patterns
                    newContent := StrReplace(newContent, "Gui,", "Gui(")
                    newContent := StrReplace(newContent, "Loop,", "Loop ")
                    newContent := StrReplace(newContent, "Random,", "Random(")
                    
                    if (content != newContent) {
                        FileDelete(file)
                        FileAppend(newContent, file, "UTF-8")
                        this.AppendLog("Fixed: " . file)
                        fixedCount++
                    }
                } catch as e {
                    this.AppendLog("Error fixing: " . file . " - " . e.Message)
                }
                lastFile := file
            }
        }
        
        this.AppendLog("Fixed " . fixedCount . " files")
        MsgBox("Fixed " . fixedCount . " files with v1 syntax", "Scanner", "Icon!")
    }
    
    static AppendLog(message) {
        timestamp := FormatTime(A_Now, "HH:mm:ss")
        logMessage := "[" . timestamp . "] " . message
        TrayTip(logMessage, "Scanner")
        OutputDebug("SCANNER: " . logMessage . "`n")
    }
}

; JSON parser
class JSON {
    static Load(json) {
        if (!InStr(json, "[")) {
            return []
        }
        json := Trim(json, "[]")
        items := []
        while (json != "") {
            json := Trim(json, " ,")
            if (json = "") {
                break
            }
            ; Simple extraction
            if (RegExMatch(json, 'O){"pattern":"([^"]+)",.*?}', &m)) {
                item := Map("pattern", m[1])
                ; Try to get other fields
                if (RegExMatch(json, '"message":"([^"]+)"', &msg)) {
                    item["message"] := msg[1]
                }
                if (RegExMatch(json, '"severity":"([^"]+)"', &sev)) {
                    item["severity"] := sev[1]
                }
                if (RegExMatch(json, '"category":"([^"]+)"', &cat)) {
                    item["category"] := cat[1]
                }
                if (RegExMatch(json, '"fixable":true')) {
                    item["fixable"] := true
                }
                items.Push(item)
                json := SubStr(json, m.Pos + m.Len)
            } else {
                break
            }
        }
        return items
    }
}

CompatibilityScanner.Init()
