#Requires AutoHotkey v2.0
#Warn

; AutoHotkey v2 Scriptlet Linter - HEADLESS VERSION
; Usage: linter_headless.ahk [path_to_scriptlet]

; Set up logging
logFile := A_ScriptDir "\linter.log"
; try FileDelete(logFile) ; Don't delete log file in batch mode

; Check if a file was provided
if (A_Args.Length = 0) {
    FileAppend("Please provide a scriptlet file to lint.`n", "*")
    ExitApp 1
}

fileToCheck := A_Args[1]
if (!FileExist(fileToCheck)) {
    FileAppend("File not found: " . fileToCheck . "`n", "*")
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

; List of known AutoHotkey v2 built-in functions (to suppress false warnings)
v2BuiltInFunctions := [
    "TraySetToolTip", "TraySetIcon", "TrayTip", "TrayIcon", "TrayMenu",
    "MsgBox", "InputBox", "FileSelect", "DirSelect", "ToolTip",
    "FormatTime", "FileRead", "FileAppend", "FileDelete", "FileExist",
    "DirCreate", "DirDelete", "DirExist", "SetWorkingDir", "Run",
    "RunWait", "RunAs", "ProcessWait", "ProcessWaitClose", "WinWait",
    "WinWaitActive", "WinWaitClose", "WinActivate", "WinClose", "WinMinimize",
    "WinMaximize", "WinRestore", "WinHide", "WinShow", "WinMove",
    "WinGetPos", "WinGetTitle", "WinGetText", "WinGetClass", "WinGetID",
    "WinGetIDLast", "WinGetCount", "WinGetList", "WinGetMinMax", "WinGetStyle",
    "WinGetExStyle", "WinGetTransparent", "WinGetTransColor", "WinSetTitle",
    "WinSetStyle", "WinSetExStyle", "WinSetTransparent", "WinSetTransColor",
    "WinSetRegion", "WinSetAlwaysOnTop", "WinSetTop", "WinSetBottom",
    "WinSetEnabled", "WinSetRedraw", "ControlGetPos", "ControlGetText",
    "ControlGetFocus", "ControlGetEnabled", "ControlGetVisible", "ControlGetHwnd",
    "ControlGetClassNN", "ControlGetItems", "ControlGetChecked", "ControlGetChoice",
    "ControlGetCurrentCol", "ControlGetCurrentLine", "ControlGetLine",
    "ControlGetLineCount", "ControlGetSelected", "ControlGetTab", "ControlSetText",
    "ControlSetEnabled", "ControlSetStyle", "ControlSetExStyle", "ControlSetChecked",
    "ControlSetChoice", "ControlChooseString", "ControlChooseIndex", "ControlFocus",
    "ControlClick", "ControlSend", "ControlSendText", "ControlMove", "ControlGet",
    "ControlSet", "Send", "SendText", "SendInput", "SendPlay", "SendRaw",
    "SendEvent", "SendMode", "SetKeyDelay", "SetMouseDelay", "SetDefaultMouseSpeed",
    "SetWinDelay", "SetControlDelay", "SetBatchLines", "SetTitleMatchMode",
    "SetTitleMatchMode", "SetDetectHiddenWindows", "SetDetectHiddenText",
    "SetStoreCapslockMode", "SetNumScrollCapsLockState", "SetCapsLockState",
    "SetNumLockState", "SetScrollLockState", "GetKeyState", "GetKeyName",
    "GetKeyVK", "GetKeySC", "KeyWait", "KeyHistory", "KeyHistory", "ListHotkeys",
    "ListLines", "ListVars", "ListFunctions", "ListThreads", "PixelGetColor",
    "PixelSearch", "ImageSearch", "MouseGetPos", "MouseMove", "MouseClick",
    "MouseClickDrag", "MouseWheel", "Click", "Sleep", "SetTimer", "SetTimer",
    "IsSet", "HasMethod", "HasBase", "HasProp", "Type", "IsObject", "IsNumber",
    "IsInteger", "IsFloat", "IsString", "IsTime", "IsDate", "IsLabel", "IsFunc",
    "Func", "BoundFunc", "VarRef", "ObjAddRef", "ObjRelease", "ComObjActive",
    "ComObjArray", "ComObjConnect", "ComObjCreate", "ComObjEnwrap", "ComObjError",
    "ComObjFlags", "ComObjGet", "ComObjMissing", "ComObjParameter", "ComObjQuery",
    "ComObjType", "ComObjUnwrap", "ComObjValue", "ComValue", "DllCall", "NumGet",
    "NumPut", "StrGet", "StrPut", "StrLen", "StrUpper", "StrLower", "StrTitle",
    "SubStr", "InStr", "StrReplace", "StrSplit", "RegExMatch", "RegExReplace",
    "Format", "Round", "Floor", "Ceil", "Abs", "Mod", "Min", "Max", "Sin", "Cos",
    "Tan", "ASin", "ACos", "ATan", "Exp", "Log", "Ln", "Sqrt", "Random", "Random",
    "FileOpen", "FileReadLine", "FileWriteLine", "FileGetSize", "FileGetTime",
    "FileGetAttrib", "FileGetVersion", "FileSetTime", "FileSetAttrib", "FileRecycle",
    "FileRecycleEmpty", "FileCopy", "FileMove", "FileCreateShortcut", "FileGetShortcut",
    "IniRead", "IniWrite", "IniDelete", "IniReadSection", "IniReadSectionNames",
    "RegRead", "RegWrite", "RegDelete", "RegCreateKey", "RegDeleteKey",
    "SoundBeep", "SoundGet", "SoundGetWaveVolume", "SoundPlay", "SoundSet",
    "SoundSetWaveVolume", "SplashTextOn", "SplashTextOff", "SplashImage", "Progress",
    "SplashImage", "OnMessage", "OnClipboardChange", "OnExit", "OnError",
    "RegisterCallback", "CallbackCreate", "PostMessage", "SendMessage",
    "ClipWait", "ClipboardAll", "Clipboard", "A_Clipboard", "A_TimeIdle",
    "A_TimeIdlePhysical", "A_TimeIdleKeyboard", "A_TimeIdleMouse", "A_TickCount",
    "A_Now", "A_NowUTC", "A_YYYY", "A_MM", "A_DD", "A_MMMM", "A_MMM", "A_DDDD",
    "A_DDD", "A_WDay", "A_YDay", "A_YWeek", "A_Hour", "A_Min", "A_Sec", "A_MSec",
    "A_IsAdmin", "A_IsCompiled", "A_IsCritical", "A_IsPaused", "A_IsSuspended",
    "A_IsUnicode", "A_OSVersion", "A_OSType", "A_PtrSize", "A_Language",
    "A_ComputerName", "A_UserName", "A_WinDir", "A_ProgramFiles", "A_AppData",
    "A_AppDataCommon", "A_Desktop", "A_DesktopCommon", "A_StartMenu", "A_StartMenuCommon",
    "A_Programs", "A_ProgramsCommon", "A_Startup", "A_StartupCommon", "A_MyDocuments",
    "A_Is64bitOS", "A_PtrSize", "A_ScreenWidth", "A_ScreenHeight", "A_ScreenDPI",
    "A_IPAddress1", "A_IPAddress2", "A_IPAddress3", "A_IPAddress4", "A_Temp",
    "A_WorkingDir", "A_ScriptDir", "A_ScriptName", "A_ScriptFullPath", "A_ScriptHwnd",
    "A_LineNumber", "A_LineFile", "A_ThisFunc", "A_ThisLabel", "A_ThisHotkey",
    "A_ThisMenuItem", "A_ThisMenu", "A_ThisMenuItemPos", "A_ThisHotkeyMod",
    "A_EndChar", "A_IsUnicode", "A_IsCompiled", "A_AhkVersion", "A_AhkPath",
    "Gui", "GuiCtrl", "GuiFromHwnd", "Menu", "MenuBar", "StatusBar", "ListView",
    "TreeView", "ComboBox", "ListBox", "Edit", "Text", "Button", "Checkbox",
    "Radio", "GroupBox", "Picture", "ActiveX", "Custom", "Hotkey", "Hotkey",
    "Hotstring", "Hotstring", "InputHook", "Buffer", "File", "Map", "Array",
    "Object", "Error", "Any", "Type", "Class", "Super", "Base", "Prototype",
    "GetMethod", "SetMethod", "GetProp", "SetProp", "DefineProp", "DeleteProp",
    "HasProp", "OwnProps", "OwnMethods", "HasBase", "HasMethod", "Call",
    "Bind", "IsVariadic", "MinParams", "MaxParams", "Name", "IsBuiltIn",
    "IsOptional", "IsByRef", "Default", "Length", "Capacity", "Push", "Pop",
    "InsertAt", "RemoveAt", "Delete", "Clear", "Clone", "Has", "Get", "Set",
    "CaseSense", "Default", "Clone", "Count", "SetCapacity", "GetCapacity",
    "Delete", "Clear", "Clone", "Has", "Get", "Set", "OwnProps", "OwnMethods"
]

; Check 1: AutoHotkey v2 requirement
if (!InStr(fileContent, "#Requires AutoHotkey v2")) {
    AddIssue("Missing #Requires AutoHotkey v2.0 directive", "Error", 1)
    hasErrors := true
}

; Check 2: FormatTime syntax (common v1/v2 issue)
lines := StrSplit(fileContent, "`n")
for i, line in lines {
    ; Flag v1 command syntax (no parentheses): FormatTime var,, format
    if (RegExMatch(line, "FormatTime\s+\w+,\s*,")) {
        AddIssue("Incorrect FormatTime syntax (v1 command) - use FormatTime(OutputVar, A_Now, format) or var := FormatTime(A_Now, format)", "Error", i)
        hasErrors := true
    }
    ; Flag v1 command syntax with parentheses but wrong pattern: FormatTime(var, , format) - missing second param
    ; But allow valid v2 patterns: FormatTime(OutputVar, A_Now, format) and FormatTime(A_Now, format)
    if (RegExMatch(line, "FormatTime\s*\(\s*\w+\s*,\s*,\s*")) {
        AddIssue("FormatTime missing second parameter - use FormatTime(OutputVar, A_Now, format) or var := FormatTime(A_Now, format)", "Error", i)
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
        AddIssue("Incorrect hotkey prefix - use Hotkey with key string in quotes instead of prefixing Hotkey()",
            "Error", i)
        hasErrors := true
    }
}

; Check 5c: Multi-line lambda blocks (detect => followed by { that spans multiple lines)
inLambdaBlock := false
lambdaStartLine := 0
for i, line in lines {
    ; Skip comments
    if (RegExMatch(line, "^\s*;"))
        continue
    
    ; Detect lambda block start: => { on same line
    ; Pattern: (*) => { or (params) => { 
    if (RegExMatch(line, "=\>\s*\{") && !RegExMatch(line, "\}\s*\)\s*\)?\s*$")) {
        ; Lambda with brace starts but doesn't close on same line - this is a multi-line lambda
        inLambdaBlock := true
        lambdaStartLine := i
    }
    
    ; If we're in a lambda block, look for closing pattern on subsequent lines
    if (inLambdaBlock) {
        ; Check if this line closes the lambda (pattern: } followed by ) or ))
        if (RegExMatch(line, "\}\s*\)\s*\)?\s*$")) {
            ; Lambda block spans multiple lines - this is an error in v2
            AddIssue("Multi-line lambda block detected (lines " . lambdaStartLine . "-" . i . ") - extract to separate function or use single-line lambda", "Error", lambdaStartLine)
            hasErrors := true
            inLambdaBlock := false
        }
        ; Also check if we see a closing brace without the closing paren
        else if (RegExMatch(line, "^\s*\}$")) {
            ; Just a closing brace - likely part of multi-line lambda
            ; Check next line for closing paren
            if (i < lines.Length && RegExMatch(lines[i+1], "^\s*\)")) {
                AddIssue("Multi-line lambda block detected (lines " . lambdaStartLine . "-" . (i+1) . ") - extract to separate function or use single-line lambda", "Error", lambdaStartLine)
                hasErrors := true
                inLambdaBlock := false
            }
        }
    }
}

; Check 5d: InputBox v1 syntax (detect & variable reference)
for i, line in lines {
    if (RegExMatch(line, "InputBox\(&")) {
        AddIssue("Incorrect InputBox syntax - use InputBox(Prompt, Title) returning object with .Result and .Value",
            "Error", i)
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
        AddIssue(
            "Incorrect Loop Files syntax - remove comma after 'Files' - use 'Loop Files Pattern' not 'Loop Files, Pattern'",
            "Error", i)
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

; Check 11a: Top-level static declarations (invalid in v2)
braceLevel := 0
for i, line in lines {
    ; Skip comments
    if (RegExMatch(line, "^\s*;"))
        continue
    
    ; Count braces to track nesting level
    openCount := 0
    closeCount := 0
    loop Parse, line {
        if (A_LoopField = "{")
            openCount++
        else if (A_LoopField = "}")
            closeCount++
    }
    braceLevel += (openCount - closeCount)
    
    ; Check for static declarations at top level (braceLevel = 0 means top level)
    if (braceLevel = 0) {
        ; Match static declarations like "static var := value" or "static var" 
        ; But exclude function definitions like "static FunctionName(...)"
        if (RegExMatch(line, "^\s*static\s+\w+\s*[^\(]") || RegExMatch(line, "^\s*static\s+\w+\s*:=\s*")) {
            AddIssue("Top-level static declaration - static can only be used inside functions or classes in v2", "Error", i)
            hasErrors := true
        }
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
    ; Flag v1 syntax: Random(&variable, min, max) - output variable with &
    if (RegExMatch(line, "Random\s*\(\s*&\w+")) {
        AddIssue("Incorrect Random() syntax (v1) - use var := Random(min, max) instead of Random(&var, min, max)", "Error", i)
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
    ; Flag FormatTime(, format) - completely missing first parameter
    ; But allow valid v2 patterns: FormatTime(OutputVar, A_Now, format) and FormatTime(A_Now, format)
    if (RegExMatch(line, "FormatTime\s*\(\s*,\s*[^\)]")) {
        AddIssue("FormatTime missing first parameter - use FormatTime(OutputVar, A_Now, format) or var := FormatTime(A_Now, format)",
            "Error", i)
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
        AddIssue("Arrow function using 'this' - change 'this.Method()' to 'ClassName.Method()' or use bound method",
            "Error", i)
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
        endLine := Min(i + 20, lines.Length)
        loop (endLine - i) {
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
        startLine := Max(1, i - 5)
        loop (i - startLine) {
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
        AddIssue("Undecorated single character hotkey detected - use modifiers like ^a, !b, +c instead of a::", "Error",
            i)
        hasErrors := true
    }

    ; Check for common system hotkeys that should not be overridden
    ; Only check in Hotkey() calls, not in Send() commands or strings
    commonHotkeys := ["^c", "^v", "^x", "^z", "^a", "^f", "^s", "^p", "!f4", "^!del", "^esc"]
    for idx, hkey in commonHotkeys {
        ; Only flag if it's in a Hotkey() call and not already decorated with extra modifiers
        ; Check for Hotkey("^x" or Hotkey "^x" pattern (not in Send, not in comments, not already decorated)
        ; Build regex pattern to match Hotkey("^x") or Hotkey("^x", ...)
        ; Use character class ["'] to match either single or double quotes"
        ; Build regex pattern - escape quotes properly
        hotkeyPattern := "Hotkey\s*\(\s*[" . Chr(34) . Chr(39) . "]" . hkey . "[" . Chr(34) . Chr(39) . "]"
        if (RegExMatch(line, hotkeyPattern) && !InStr(line, "Off") && !InStr(line, "Send") && !InStr(line, ";")) {
            ; Check if it already has extra decorators (like ^+c for Ctrl+Shift+C)
            ; Check if it already has extra decorators (like ^+c for Ctrl+Shift+C)
            hkeyChar := SubStr(hkey, 2)  ; Get character after ^ or !
            extraDecoratorPattern := "Hotkey\s*\(\s*[" . Chr(34) . Chr(39) . "][\^!+#]+\+" . hkeyChar
            if (!RegExMatch(line, extraDecoratorPattern)) {
                AddIssue("Warning: Possibly overriding common system hotkey: " . hkey .
                    " - may interfere with normal operation. Add extra decorator like Shift (^+c instead of ^c)", "Warning", i)
                hasWarnings := true
            }
        }
    }
}

; Check 31a: Check for arrow keys, navigation keys, and alphanumeric keys without context restrictions
arrowKeys := ["Up", "Down", "Left", "Right", "Home", "End", "PgUp", "PgDn"]
navigationKeys := ["Enter", "Space", "Tab", "Escape", "Backspace", "Delete"]
problematicKeys := arrowKeys
problematicKeys.Push(navigationKeys*)

for i, line in lines {
    ; Skip comments
    if (RegExMatch(line, "^\s*;"))
        continue
    
    ; Check for Hotkey() calls with single alphanumeric characters (a-z, A-Z, 0-9)
    ; Pattern: Hotkey("a", ...) or Hotkey('w', ...) - single character keys
    alphanumPattern := "Hotkey\s*\(\s*[" . Chr(34) . Chr(39) . "]([a-zA-Z0-9])[" . Chr(34) . Chr(39) . "]"
    if (RegExMatch(line, alphanumPattern, &alphanumMatch)) {
        keyChar := alphanumMatch[1]
        
        ; Check if this is being disabled (Hotkey("a", "Off"))
        disablePattern := "Hotkey\s*\(\s*[" . Chr(34) . Chr(39) . "]" . keyChar . "[" . Chr(34) . Chr(39) . "]\s*,\s*[" . Chr(34) . Chr(39) . "]Off[" . Chr(34) . Chr(39) . "]"
        if (RegExMatch(line, disablePattern))
            continue
        
        ; Check for context restrictions (same logic as below)
        hasContextCheck := false
        startCheck := Max(1, i - 10)
        endCheck := Min(lines.Length, i + 10)
        
        ; Look for window focus checks
        Loop (endCheck - startCheck + 1) {
            checkLineNum := startCheck + A_Index - 1
            checkLine := lines[checkLineNum]
            
            if (RegExMatch(checkLine, "WinActive|WinExist|CheckWindowFocus|snakeGui\.Hwnd|gui\.Hwnd") || 
                RegExMatch(checkLine, "if\s*\(.*Hwnd.*\)") ||
                RegExMatch(checkLine, "#HotIf.*WinActive") ||
                InStr(checkLine, "window is active") ||
                InStr(checkLine, "window has focus")) {
                hasContextCheck := true
                break
            }
        }
        
        ; Check callback function
        callbackPattern := "Hotkey\s*\(\s*[" . Chr(34) . Chr(39) . "]" . keyChar . "[" . Chr(34) . Chr(39) . "]\s*,\s*(\w+)"
        if (RegExMatch(line, callbackPattern, &callbackMatch)) {
            callbackFunc := callbackMatch[1]
            Loop lines.Length {
                funcStart := A_Index
                funcLine := lines[funcStart]
                if (RegExMatch(funcLine, callbackFunc . "\s*\(")) {
                    funcEnd := Min(lines.Length, funcStart + 20)
                    Loop (funcEnd - funcStart) {
                        checkLineNum := funcStart + A_Index
                        if (checkLineNum > lines.Length)
                            break
                        checkLine := lines[checkLineNum]
                        if (RegExMatch(checkLine, "WinActive|WinExist|CheckWindowFocus|snakeGui\.Hwnd|gui\.Hwnd") ||
                            RegExMatch(checkLine, "if\s*\(.*Hwnd.*\)") ||
                            RegExMatch(checkLine, "if\s*\(!.*WinActive")) {
                            hasContextCheck := true
                            break
                        }
                        if (RegExMatch(checkLine, "^\w+\s*\(") && !RegExMatch(checkLine, callbackFunc))
                            break
                    }
                    break
                }
            }
        }
        
        if (!hasContextCheck) {
            AddIssue("Hotkey for '" . keyChar . "' lacks context restrictions - single alphanumeric keys (a-z, A-Z, 0-9) should only work when specific window is active (add WinActive check)", "Error", i)
            hasErrors := true
        }
        continue
    }
    
    ; Check for Hotkey() calls with problematic keys
    for idx, keyName in problematicKeys {
        ; Pattern: Hotkey("Up", ...) or Hotkey('Up', ...)
        pattern := "Hotkey\s*\(\s*[" . Chr(34) . Chr(39) . "]" . keyName . "[" . Chr(34) . Chr(39) . "]"
        if (RegExMatch(line, pattern)) {
            ; Check if this is being disabled (Hotkey("Up", "Off"))
            disablePattern := "Hotkey\s*\(\s*[" . Chr(34) . Chr(39) . "]" . keyName . "[" . Chr(34) . Chr(39) . "]\s*,\s*[" . Chr(34) . Chr(39) . "]Off[" . Chr(34) . Chr(39) . "]"
            if (RegExMatch(line, disablePattern))
                continue
            
            ; Check if there's context restriction nearby (check surrounding lines for window focus checks)
            hasContextCheck := false
            startCheck := Max(1, i - 10)
            endCheck := Min(lines.Length, i + 10)
            
            ; Look for window focus checks, WinActive, context restrictions
            Loop (endCheck - startCheck + 1) {
                checkLineNum := startCheck + A_Index - 1
                checkLine := lines[checkLineNum]
                
                ; Check for window focus validation patterns
                if (RegExMatch(checkLine, "WinActive|WinExist|CheckWindowFocus|snakeGui\.Hwnd|gui\.Hwnd") || 
                    RegExMatch(checkLine, "if\s*\(.*Hwnd.*\)") ||
                    RegExMatch(checkLine, "#HotIf.*WinActive") ||
                    InStr(checkLine, "window is active") ||
                    InStr(checkLine, "window has focus")) {
                    hasContextCheck := true
                    break
                }
            }
            
            ; Also check if the callback function validates window state
            callbackPattern := "Hotkey\s*\(\s*[" . Chr(34) . Chr(39) . "]" . keyName . "[" . Chr(34) . Chr(39) . "]\s*,\s*(\w+)"
            if (RegExMatch(line, callbackPattern, &match)) {
                callbackFunc := match[1]
                ; Search for the callback function definition
                Loop lines.Length {
                    funcStart := A_Index
                    funcLine := lines[funcStart]
                    if (RegExMatch(funcLine, callbackFunc . "\s*\(")) {
                        ; Check next 20 lines of the function for window validation
                        funcEnd := Min(lines.Length, funcStart + 20)
                        Loop (funcEnd - funcStart) {
                            checkLineNum := funcStart + A_Index
                            if (checkLineNum > lines.Length)
                                break
                            checkLine := lines[checkLineNum]
                            if (RegExMatch(checkLine, "WinActive|WinExist|CheckWindowFocus|snakeGui\.Hwnd|gui\.Hwnd") ||
                                RegExMatch(checkLine, "if\s*\(.*Hwnd.*\)") ||
                                RegExMatch(checkLine, "if\s*\(!.*WinActive")) {
                                hasContextCheck := true
                                break
                            }
                            ; If we hit another function definition, stop
                            if (RegExMatch(checkLine, "^\w+\s*\(") && !RegExMatch(checkLine, callbackFunc))
                                break
                        }
                        break
                    }
                }
            }
            
            if (!hasContextCheck) {
                AddIssue("Hotkey for '" . keyName . "' lacks context restrictions - arrow/navigation keys should only work when specific window is active (add WinActive check)", "Error", i)
                hasErrors := true
            }
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

; Check 33: Recognize v2 built-in functions (suppress false warnings)
; This check identifies known v2 functions to prevent false "undefined variable" warnings
; Note: This is informational and doesn't add issues, but helps the linter understand v2 functions
for i, line in lines {
    ; Skip comments and strings
    if (RegExMatch(line, "^\s*;") || RegExMatch(line, "^\s*/\*") || RegExMatch(line, "^\s*\*"))
        continue
    
    ; Check if line contains a known v2 built-in function call
    for idx, funcName in v2BuiltInFunctions {
        ; Match function calls like FuncName( or FuncName (with optional whitespace)
        pattern := "\b" . funcName . "\s*\("
        if (RegExMatch(line, pattern)) {
            ; Function is recognized - this prevents false warnings
            ; No issue added, just recognized for internal processing
            break
        }
    }
}

; Filter out false warnings for known v2 built-in functions
; AutoHotkey's #Warn may flag these, but they are valid v2 functions
filteredIssues := []
for issue in issues {
    ; Check if this is a warning about a known v2 function
    isKnownFunction := false
    for idx, funcName in v2BuiltInFunctions {
        ; Check if the issue message mentions this function as undefined
        if (InStr(issue.message, funcName) && InStr(issue.message, "never be assigned")) {
            isKnownFunction := true
            Log("Filtered out false warning for known v2 function: " . funcName)
            break
        }
    }
    if (!isKnownFunction) {
        filteredIssues.Push(issue)
    }
}

; Use filtered issues for reporting
issues := filteredIssues

; Generate comprehensive report
report := "Lint Report for: " . fileToCheck . "`n"
report .= "Generated: " . FormatTime(A_Now, "yyyy-MM-dd HH:mm:ss") . "`n"
report .= "Total Lines: " . lines.Length . "`n"
report .= "`nIssues found:`n"

if (issues.Length = 0) {
    report .= "  No issues found! `n"
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

; Output report to file
reportFile := A_ScriptDir "\lint_report.txt"
try FileDelete(reportFile)
try FileAppend(report, reportFile, "UTF-8")

Log("Lint analysis completed. Issues found: " . issues.Length)
ExitApp hasErrors ? 1 : 0

; Helper functions
AddIssue(message, severity, line := "") {
    issues.Push({ message: message, severity: severity, line: line })
    Log(severity . ": " . message . " (Line: " . (line ? line : "N/A") . ")")
}

Log(message) {
    global logFile
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
    try FileAppend(logMessage, logFile, "UTF-8")
    logMutex := 0
}

LogError(message) {
    global logFile
    Log("ERROR: " . message)
}
