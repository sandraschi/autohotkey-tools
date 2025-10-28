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

; Check 5a: Hotkey with missing closing parenthesis
for i, line in lines {
    if (RegExMatch(line, "Hotkey\([^\)]+\)\s*$") && !InStr(line, "))")) {
        ; Check if the line doesn't have proper closing
        if (RegExMatch(line, "Hotkey\([^\)]+\(\s*$")) {
            AddIssue("Missing closing parenthesis in Hotkey() call - should end with ``))``", "Error", i)
            hasErrors := true
        }
    }
}

; Check 5b: Using prefix modifiers with Hotkey()
for i, line in lines {
    if (RegExMatch(line, "[\^#!+]+Hotkey\(")) {
        AddIssue("Incorrect hotkey prefix - use Hotkey with key string in quotes instead of prefixing Hotkey()", "Error", i)
        hasErrors := true
    }
}

; Check 5c: Multi-line lambda blocks (detect => followed by { on same line)
for i, line in lines {
    if (RegExMatch(line, "=\>\s*\{") && !RegExMatch(line, "\)\s*\)\s*$")) {
        AddIssue("Multi-line lambda block detected - extract to separate function or use single-line lambda", "Error", i)
        hasErrors := true
    }
}

; Check 5d: InputBox v1 syntax (detect & variable reference)
for i, line in lines {
    if (RegExMatch(line, "InputBox\(&")) {
        AddIssue("Incorrect InputBox syntax - use InputBox(Prompt, Title) returning object with .Result and .Value", "Error", i)
        hasErrors := true
    }
}

; Check 5d2: InputBox parameter order (check for title-like strings before prompt-like strings)
for i, line in lines {
    if (InStr(line, "InputBox``")) {
        ; Just warn about potential parameter order issues
        AddIssue("Check InputBox parameter order - v2 order is InputBox(Prompt, Title)", "Warning", i)
    }
}

; Check 5e: Loop Files v1 syntax (detect comma after Files)
for i, line in lines {
    if (RegExMatch(line, "Loop Files,")) {
        AddIssue("Incorrect Loop Files syntax - remove comma after 'Files' - use 'Loop Files Pattern' not 'Loop Files, Pattern'", "Error", i)
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

; Check 19: Arrow function event handler issues (this.Method in arrow functions)
for i, line in lines {
    if (RegExMatch(line, "\.OnEvent\([^\)]+\(\s*\)\s*=>\s*this\.")) {
        AddIssue("Arrow function using 'this' - change 'this.Method()' to 'ClassName.Method()' or use bound method", "Error", i)
        hasErrors := true
    }
}

; Check 20: FileDelete syntax
for i, line in lines {
    if (RegExMatch(line, "FileDelete\s+.*,.*true")) {
        AddIssue("FileDelete with Recycle parameter - in v2 use FileRecycle() instead", "Warning", i)
        hasWarnings := true
    }
}

; Check 21: Clipboard operations
for i, line in lines {
    if (RegExMatch(line, "Clipboard\s*:=\s*")) {
        AddIssue("Clipboard assignment - use ClipboardAll or Clipboard := text", "Warning", i)
    }
}

; Check 22: Mouse operations with v1 syntax
for i, line in lines {
    if (RegExMatch(line, "MouseMove\s*,\s*\w+\s*,\s*\w+")) {
        AddIssue("Old MouseMove syntax - use MouseMove(x, y, speed, relative)", "Error", i)
        hasErrors := true
    }
}

; Check 23: KeyWait syntax
for i, line in lines {
    if (RegExMatch(line, "KeyWait\s+\w+,.*,.*")) {
        AddIssue("KeyWait with options - use KeyWait(key, options)", "Warning", i)
    }
}

; Check 24: Check for missing class structure (should have class for complex scriptlets)
lineCount := lines.Length
classCount := 0
methodCount := 0

for i, line in lines {
    if (RegExMatch(line, "^class\s+\w+")) {
        classCount++
    }
    if (RegExMatch(line, "static\s+\w+\s*\(")) {
        methodCount++
    }
}

if (lineCount > 50 && classCount = 0) {
    AddIssue("Large script without class structure - consider using class-based organization", "Suggestion")
}

; Check 25: Detect potential null variable dereference
for i, line in lines {
    if (RegExMatch(line, "\.\w+\s*\.\w+\s*\.\w+\s*\.\w+")) {
        AddIssue("Deep chaining detected - consider adding null checks", "Warning", i)
    }
}

; Check 26: Check for deprecated Sleep syntax
for i, line in lines {
    if (RegExMatch(line, "Sleep\s+\w+\s*,")) {
        AddIssue("Sleep with comma - use Sleep(ms) not Sleep(ms,)", "Error", i)
        hasErrors := true
    }
}

; Check 27: Detect potential infinite loops
for i, line in lines {
    if (RegExMatch(line, "Loop\s*$")) {
        ; Check next few lines for break condition
        hasBreak := false
        endLine := Min(i+20, lines.Length)
        Loop (endLine - i) {
            j := i + A_Index
            if (j > lines.Length)
                break
            if (InStr(lines[j], "break")) {
                hasBreak := true
                break
            }
        }
        if (!hasBreak) {
            AddIssue("Loop without break condition detected - check for infinite loop", "Warning", i)
        }
    }
}

; Check 28: Check for proper error handling in file operations
for i, line in lines {
    if (RegExMatch(line, "FileRead\s*\(|FileAppend\s*\(|FileDelete\s*\(")) {
        ; Check if surrounded by try-catch
        hasTry := false
        startLine := Max(1, i-5)
        Loop (i - startLine) {
            j := startLine + A_Index - 1
            if (j >= i)
                break
            if (InStr(lines[j], "try")) {
                hasTry := true
                break
            }
        }
        if (!hasTry) {
            AddIssue("File operation without try-catch - consider adding error handling", "Suggestion", i)
        }
    }
}

; Check 29: Check for proper GUI event handlers
for i, line in lines {
    if (RegExMatch(line, "\.Add.*OnEvent")) {
        if (RegExMatch(line, "\(\*\s*\)\s*=>\s*[\w\.]+\(")) {
            ; Check if it's using proper class reference
            if (!RegExMatch(line, "ClassName\.") && !RegExMatch(line, "this\.")) {
                AddIssue("OnEvent callback should use class name or proper binding", "Warning", i)
            }
        }
    }
}

; Check 30: Check for variable naming consistency
for i, line in lines {
    if (RegExMatch(line, "^\s*[a-zA-Z_][a-zA-Z0-9_]*\s*:=\s*")) {
        varName := RegExReplace(line, "^\s*([a-zA-Z_][a-zA-Z0-9_]*).*", "$1")
        if (StrLen(varName) < 2) {
            AddIssue("Very short variable name - consider using more descriptive names", "Suggestion", i)
        }
    }
}

; Check 31: Check for problematic hotkeys (undecorated single chars, common system combos)
for i, line in lines {
    ; Check for undecorated single character hotkeys like "a::", "b::" (must use ^a, !b, etc.)
    if (RegExMatch(line, "^[a-z]::", &match)) {
        AddIssue("Undecorated single character hotkey detected - use modifiers like ^a, !b, +c instead of a::", "Error", i)
        hasErrors := true
    }
    
    ; Check for common system hotkeys that should not be overridden
    commonHotkeys := ["^c", "^v", "^x", "^z", "^a", "^f", "^s", "^p", "!f4", "^!del", "^esc"]
    for idx, hkey in commonHotkeys {
        ; Simple check for the hotkey string in the line
        if (InStr(line, hkey) && !InStr(line, "Off")) {
            AddIssue("Warning: Possibly overriding common system hotkey: " . hkey . " - may interfere with normal operation", "Warning", i)
            hasWarnings := true
        }
    }
}

; Check 32: Check for ToUpper() method (invalid in AutoHotkey v2)
for i, line in lines {
    if (RegExMatch(line, "\.ToUpper\(\)")) {
        AddIssue("Found .ToUpper() method - use StrUpper() instead of .ToUpper()", "Error", i)
        hasErrors := true
    }
    if (RegExMatch(line, "\.ToLower\(\)")) {
        AddIssue("Found .ToLower() method - use StrLower() instead of .ToLower()", "Error", i)
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