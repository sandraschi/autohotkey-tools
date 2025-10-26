#Requires AutoHotkey v2.0+
#SingleInstance Force

class CompatibilityScanner {
    static scanDirs := [A_ScriptDir . "\..\scriptlets", A_ScriptDir . "\..\tests"]
    static outputFile := A_ScriptDir . "\..\compatibility_scan_report.txt"
    static patterns := []
    static issues := []
    
    static Init() {
        this.LoadPatterns()
        if (A_Args.Length > 0 && A_Args[1] = "--fix") {
            this.FixAllIssues()
        } else {
            this.ScanAllScripts()
        }
    }
    
    static LoadPatterns() {
        try {
            jsonContent := FileRead(A_ScriptDir . "\scanner_patterns.json")
            if (!jsonContent) {
                this.AppendLog("Failed to load patterns file")
                return
            }
            this.patterns := JSON.Load(jsonContent)
            this.AppendLog("Loaded " . this.patterns.Length . " patterns")
        } catch as e {
            this.AppendLog("Error loading patterns: " . e.Message)
        }
    }
    
    static ScanAllScripts() {
        this.issues := []
        scannedCount := 0
        
        this.AppendLog("Starting compatibility scan...")
        
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
        for pattern in this.patterns {
            if (RegExMatch(content, pattern.pattern)) {
                this.issues.Push({
                    file: filePath,
                    pattern: pattern.pattern,
                    message: pattern.message,
                    severity: pattern.severity,
                    category: pattern.category,
                    fixable: pattern.Has("fixable") ? pattern.fixable : false
                })
            }
        }
    }
    
    static GenerateReport() {
        try {
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
        ; Placeholder for fix functionality
        this.AppendLog("Fix mode not yet implemented")
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
