#Requires AutoHotkey v2.0
#Warn

; AutoHotkey v2 Scriptlet Linter - COMPLETELY REWRITTEN FOR V2
; Usage: linter.ahk [path_to_scriptlet]

; Set up logging
logFile := A_ScriptDir "\linter.log"
try FileDelete(logFile)

; Check if a file was provided
if (A_Args.Length = 0) {
    MsgBox("Please provide a scriptlet file to lint.", "Scriptlet Linter", "Icon!")
    ExitApp 1
}

fileToCheck := A_Args[1]
if (!FileExist(fileToCheck)) {
    MsgBox("File not found: " . fileToCheck, "Scriptlet Linter", "Icon!")
    ExitApp 1
}

; Read the file content
fileContent := FileRead(fileToCheck)
if (!fileContent) {
    LogError("Failed to read file: " . fileToCheck)
    ExitApp 1
}

; Initialize results
issues := []
hasErrors := false
hasWarnings := false

; Enhanced checks for AutoHotkey v2 compliance
Log("Starting lint analysis for: " . fileToCheck)

; Check 1: AutoHotkey v2 requirement
if (!InStr(fileContent, "#Requires AutoHotkey v2")) {
    AddIssue("Missing #Requires AutoHotkey v2.0 directive", "Error", 1)
    hasErrors := true
}

; Check 2: FormatTime syntax (common v1/v2 issue)
lines := StrSplit(fileContent, "`n")
for i, line in lines {
    if (RegExMatch(line, "FormatTime\s+\w+,\s*,")) {
        AddIssue("Incorrect FormatTime syntax - use FormatTime(var, , format)", "Error", i)
        hasErrors := true
    }
}

; Check 3: FileRead syntax
for i, line in lines {
    if (RegExMatch(line, "FileRead\s+\w+,\s*\w+")) {
        AddIssue("Incorrect FileRead syntax - use FileRead(content, file)", "Error", i)
        hasErrors := true
    }
}

; Check 4: MsgBox syntax
for i, line in lines {
    if (RegExMatch(line, "MsgBox\s+\w+")) {
        AddIssue("Incorrect MsgBox syntax - use MsgBox(text, title, options)", "Error", i)
        hasErrors := true
    }
}

; Check 5: Hotkey syntax
for i, line in lines {
    if (RegExMatch(line, "^\w+::")) {
        AddIssue("Incorrect hotkey syntax - use Hotkey(key, callback)", "Error", i)
    hasErrors := true
}
}

; Check 6: String functions (v1 to v2 migration)
for i, line in lines {
    if (RegExMatch(line, "StringReplace\s*\(")) {
        AddIssue("Found StringReplace - use StrReplace() instead", "Error", i)
        hasErrors := true
    }
    if (RegExMatch(line, "StringSplit\s*\(")) {
        AddIssue("Found StringSplit - use StrSplit() instead", "Error", i)
        hasErrors := true
    }
    if (RegExMatch(line, "StringLen\s*\(")) {
        AddIssue("Found StringLen - use StrLen() instead", "Error", i)
        hasErrors := true
    }
}

; Check 7: GUI commands (v1 to v2 migration)
for i, line in lines {
    if (RegExMatch(line, "Gui,\s*")) {
        AddIssue("Found Gui, command - use Gui() constructor instead", "Error", i)
        hasErrors := true
    }
    if (RegExMatch(line, "GuiAdd,\s*")) {
        AddIssue("Found GuiAdd, command - use gui.Add() method instead", "Error", i)
        hasErrors := true
    }
    if (RegExMatch(line, "GuiShow,\s*")) {
        AddIssue("Found GuiShow, command - use gui.Show() method instead", "Error", i)
        hasErrors := true
    }
    if (RegExMatch(line, "GuiClose,\s*")) {
        AddIssue("Found GuiClose, command - use gui.Close() method instead", "Error", i)
        hasErrors := true
    }
    if (RegExMatch(line, "GuiControl,\s*")) {
        AddIssue("Found GuiControl, command - use gui control methods instead", "Error", i)
    hasErrors := true
}
}

; Check 8: Class definition (for scriptlets that should have classes)
if (!RegExMatch(fileContent, "class\s+\w+")) {
    AddIssue("No class definition found - consider using class-based structure", "Warning")
    hasWarnings := true
}

; Check 9: Init method
if (!RegExMatch(fileContent, "static\s+Init\s*\(")) {
    AddIssue("Missing Init() method - recommended for scriptlets", "Warning")
    hasWarnings := true
}

; Check 10: Error handling
if (!InStr(fileContent, "try") && !InStr(fileContent, "catch")) {
    AddIssue("Consider adding error handling with try/catch blocks", "Suggestion")
}

; Check 11: Global variables (v1 pattern)
for i, line in lines {
    if (RegExMatch(line, "global\s+\w+")) {
        AddIssue("Found global variable declaration - consider using static or local variables", "Warning", i)
        hasWarnings := true
    }
}

; Check 12: Loop syntax
for i, line in lines {
    if (RegExMatch(line, "Loop\s*,\s*")) {
        AddIssue("Found Loop, syntax - use Loop or For loop instead", "Error", i)
        hasErrors := true
    }
}

; Check 13: Random function syntax (v1 to v2 migration)
for i, line in lines {
    if (RegExMatch(line, "\w+\s*:=\s*Random\s*\(")) {
        AddIssue("Incorrect Random() syntax - use Random(var, min, max) instead of var := Random(min, max)", "Error", i)
        hasErrors := true
    }
    if (RegExMatch(line, "Random\s*\(\s*\d+\s*,\s*\d+\s*\)")) {
        AddIssue("Found Random(min, max) - use Random(var, min, max) to assign to variable", "Error", i)
        hasErrors := true
    }
}

; Check 14: For loop 'to' syntax (v1 to v2 migration)
for i, line in lines {
    if (RegExMatch(line, "for\s+\w+\s*:=\s*\w+.*\s+to\s+")) {
        AddIssue("Found 'to' in for loop - use '..' instead (v2 syntax)", "Error", i)
        hasErrors := true
    }
}

; Check 15: FormatTime missing first parameter (v1 to v2 migration)
for i, line in lines {
    if (RegExMatch(line, "FormatTime\s*\(\s*,\s*")) {
        AddIssue("FormatTime missing first parameter - use FormatTime(var, , format) or FormatTime(var, A_Now, format)", "Error", i)
        hasErrors := true
    }
}

; Check 16: Malformed hotkey syntax (v1 to v2 migration)
for i, line in lines {
    if (InStr(line, "^!Hotkey") || InStr(line, "^+Hotkey") || RegExMatch(line, "[\^!+#]+Hotkey\s*\(")) {
        AddIssue("Malformed hotkey syntax - use Hotkey('^!w', (*) => Function()) instead of ^!Hotkey()", "Error", i)
        hasErrors := true
    }
}

; Check 18: SetWorkingDir syntax
for i, line in lines {
    if (RegExMatch(line, "SetWorkingDir\s+\w+")) {
        AddIssue("Incorrect SetWorkingDir syntax - use SetWorkingDir(path)", "Error", i)
        hasErrors := true
    }
}

; Generate comprehensive report
report := "Lint Report for: " . fileToCheck . "`n"
report .= "Generated: " . FormatTime(A_Now, "yyyy-MM-dd HH:mm:ss") . "`n"
report .= "Total Lines: " . lines.Length . "`n"
report .= "`nIssues found:`n"

if (issues.Length = 0) {
    report .= "  No issues found! 🎉`n"
} else {
    ; Group issues by severity
    errors := []
    warnings := []
    suggestions := []
    
    for issue in issues {
        switch issue.severity {
            case "Error":
                errors.Push(issue)
            case "Warning":
                warnings.Push(issue)
            case "Suggestion":
                suggestions.Push(issue)
        }
    }
    
    if (errors.Length > 0) {
        report .= "`nERRORS (" . errors.Length . "):`n"
        for issue in errors {
            report .= Format("  [{1}] Line {2:-4} - {3}`n", 
                            issue.severity, 
                            issue.line ? issue.line : "N/A", 
                            issue.message)
        }
    }
    
    if (warnings.Length > 0) {
        report .= "`nWARNINGS (" . warnings.Length . "):`n"
        for issue in warnings {
            report .= Format("  [{1}] Line {2:-4} - {3}`n", 
                            issue.severity, 
                        issue.line ? issue.line : "N/A", 
                        issue.message)
        }
    }
    
    if (suggestions.Length > 0) {
        report .= "`nSUGGESTIONS (" . suggestions.Length . "):`n"
        for issue in suggestions {
            report .= Format("  [{1}] Line {2:-4} - {3}`n", 
                            issue.severity, 
                            issue.line ? issue.line : "N/A", 
                            issue.message)
        }
    }
}

; Save report to file
reportFile := A_ScriptDir "\lint_report.txt"
try FileDelete(reportFile)
FileAppend(report, reportFile, "UTF-8")

; Show completion popup with script name
scriptName := RegExReplace(fileToCheck, ".*\\", "")  ; Extract filename from path
if (issues.Length = 0) {
    TrayTip("Linting Complete: " . scriptName, "✅ No issues found!", "Iconi")
} else {
    errorCount := 0
    warningCount := 0
    suggestionCount := 0
    
    for issue in issues {
        switch issue.severity {
            case "Error":
                errorCount++
            case "Warning":
                warningCount++
            case "Suggestion":
                suggestionCount++
        }
    }
    
    statusText := "Found " . errorCount . " errors"
    if (warningCount > 0) {
        statusText .= ", " . warningCount . " warnings"
    }
    if (suggestionCount > 0) {
        statusText .= ", " . suggestionCount . " suggestions"
    }
    
    TrayTip("Linting Complete: " . scriptName, statusText, "Icon!")
}

; Show summary
if (hasErrors) {
    result := "❌ Lint failed with errors"
} else if (hasWarnings) {
    result := "⚠️  Lint completed with warnings"
} else {
    result := "✅ Lint passed successfully"
}

MsgBox(result . ": " . issues.Length . " issues found.`n`nSee " . reportFile . " for details.", "Scriptlet Linter", hasErrors ? "Icon!" : "Iconi")

Log("Lint analysis completed. Issues found: " . issues.Length)
ExitApp hasErrors ? 1 : 0

; Helper functions
AddIssue(message, severity, line := "") {
    issues.Push({message: message, severity: severity, line: line})
    Log(severity . ": " . message . " (Line: " . (line ? line : "N/A") . ")")
}

Log(message) {
    static logMutex := 0
    while (DllCall("User32\InSendMessage")) {
        if (logMutex)
            return
        logMutex := 1
        Sleep 10
    }
    
    ; FIXED: Use correct AutoHotkey v2 FormatTime syntax
    timestamp := FormatTime(A_Now, "yyyy-MM-dd HH:mm:ss")
    logMessage := "[" . timestamp . "] " . message . "`n"
    FileAppend(logMessage, logFile, "UTF-8")
    logMutex := 0
}

LogError(message) {
    Log("ERROR: " . message)
}