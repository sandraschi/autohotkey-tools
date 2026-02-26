# Complete AutoHotkey v1 to v2 Migration Guide

## ⚠️ CRITICAL: Write v2 From The Start!

**DO NOT write v1 syntax and convert it later!** This creates technical debt and errors.

### ✅ CORRECT Approach for New Scripts:
1. **Write v2 syntax from the start** - Use the patterns below as reference
2. **Consult this guide** when unsure about v2 syntax
3. **Check the official v2 docs** (`AutoHotkeyDocs` repository) for function signatures
4. **Use the linter** to catch any v1 remnants immediately

### ❌ WRONG Approach (What We Did Before):
1. Write v1 syntax
2. Try to convert it later
3. Introduce bugs and incorrect conversions
4. Waste hours fixing conversion mistakes

### When Writing New Scripts:
- **Always start with:** `#Requires AutoHotkey v2.0+`
- **Use v2 syntax patterns** from this guide
- **If in doubt:** Consult `docs/Complete_V1_to_V2_Migration_Guide.md` or the official v2 documentation
- **Never use:** v1 command syntax, double-colon hotkeys, or any v1 patterns

---

## 🚨 ALL v1 Syntax Patterns That MUST Be Fixed (For Existing Scripts)

### 1. GUI COMMANDS

#### ❌ v1: Command Syntax
```autohotkey
Gui, Add, Text, x10 y10 w100 h20, Hello
Gui, Show, w300 h400
Gui, Color, 1E1E1E
Gui, Font, s12 Bold, Arial
GuiControl,, ControlName, NewValue
GuiControlGet, output,, ControlName
```

#### ✅ v2: Function & Method Syntax
```autohotkey
gui := Gui()
control := gui.Add("Text", "x10 y10 w100 h20", "Hello")
gui.Show("w300 h400")
gui.BackColor := "1E1E1E"
gui.SetFont("s12 Bold", "Arial")
control.Text := "NewValue"
value := control.Text
```

### 2. INPUTBOX

#### ❌ v1: Object with Properties
```autohotkey
result := InputBox("Prompt", "Title")
if (result.Result = "OK") {
    value := result.Value
}
```

#### ✅ v2: Direct String Return
```autohotkey
value := InputBox("Prompt", "Title")
if (value != "") {
    ; User entered value
}
```

### 3. MSGBOX

#### ❌ v1: Comma Separated
```autohotkey
MsgBox, 64, Title, Message
MsgBox, %text%, Option
```

#### ❌ WRONG v2 Conversion (Common Mistake!)
```autohotkey
MsgBox("Message", "Title", "Iconi Timeout10")  ; WRONG! Invalid option string
MsgBox("Message", "Title", "Iconi", 10)  ; WRONG! No 4th parameter in v2
MsgBox("Message", "Title", "T1024")  ; WRONG! Timeout option "T" not supported in v2
MsgBox("Message", "Title", "Iconi T10")  ; WRONG! Timeout not supported
```

#### ✅ v2: Function with 3 Parameters (NO TIMEOUT!)
```autohotkey
MsgBox("Message", "Title", "Icon!")  ; CORRECT - 3 parameters only
MsgBox(text, , "IconX")  ; CORRECT - empty title uses comma

; For timed/non-blocking messages, use TrayTip or ToolTip instead:
TrayTip("Title", "Message", 10)  ; 10 second timeout
ToolTip("Message", , , 10)  ; Tooltip with timeout
```

**Important:** AutoHotkey v2 `MsgBox` does NOT support timeout options. Any `T` followed by a number (like `T10`, `T1024`) in the options string is invalid and will be ignored or cause errors. Always use `TrayTip` or `ToolTip` for messages that should auto-dismiss.

### 4. FORMATTIME

#### ❌ v1: Command Syntax
```autohotkey
FormatTime, output,, yyyy-MM-dd
FormatTime, output, A_Now
```

#### ❌ WRONG v2 Conversion (Common Mistake!)
```autohotkey
FormatTime(timestamp, A_Now, "yyyy-MM-dd")  ; WARNING: Variable 'timestamp' not assigned
```

#### ✅ v2: Initialize Output Variable First
```autohotkey
timestamp := ""  ; Initialize to suppress linter warning
FormatTime(timestamp, A_Now, "yyyy-MM-dd")  ; CORRECT - variable initialized

; Or use direct return (if supported):
timestamp := FormatTime(A_Now, "yyyy-MM-dd")  ; Alternative syntax
```

### 5. RANDOM

#### ❌ v1: Command Syntax
```autohotkey
Random, outputVar, 1, 100
Random, increment, 1, 5
```

#### ❌ WRONG v2 Conversion (Common Mistake!)
```autohotkey
Random(outputVar, 1, 100)  ; WRONG! This is NOT v2 syntax
Random(increment, 1, 5)    ; WRONG! This is NOT v2 syntax
```

#### ✅ v2: Function Returns Value Directly
```autohotkey
outputVar := Random(1, 100)  ; CORRECT - assignment operator
increment := Random(1, 5)    ; CORRECT - assignment operator
```

### 6. HOTKEYS

#### ❌ v1: Double Colon Syntax
```autohotkey
^!c::
    DoSomething()
    ShowOSD("Done")
return

F7::Function()
```

#### ❌ WRONG v2 Conversion (Common Mistake!)
```autohotkey
Hotkey("^!c", (*) => { DoSomething() ShowOSD("Done") })  ; WRONG! Missing propertyname in object literal
Hotkey("#Up", (*) => { Send("{Volume_Up}") ShowOSD("Volume: " . GetVolume() . "%") })  ; WRONG!
```

#### ✅ v2: Use Named Functions for Multi-Statement Callbacks
```autohotkey
; For single statements, arrow functions work:
Hotkey("^!c", (*) => DoSomething())
Hotkey("F7", (*) => Function())

; For multiple statements, use named functions:
Hotkey("^!c", MyHotkeyHandler)

MyHotkeyHandler(*) {
    DoSomething()
    ShowOSD("Done")
}

; Or use ObjBindMethod for class methods:
Hotkey("^!c", ObjBindMethod(MyClass, "HandleHotkey"))
```

### 7. FOR LOOPS

#### ❌ v1: "to" Keyword
```autohotkey
Loop, 10
Loop Files, C:\*.*
for i := 1 to 10
for i := StrLen(text) to 1  ; Reverse iteration
```

#### ❌ WRONG v2 Conversion (Common Mistake!)
```autohotkey
for i := 1 to 10  ; WRONG! "to" keyword doesn't exist in v2
for i := StrLen(text) to 1  ; WRONG! This syntax is invalid
```

#### ✅ v2: Loop with A_Index or Range
```autohotkey
Loop 10  ; Simple count
Loop Files "C:\*.*"  ; File loop
for i in Range(1, 10)  ; Range iteration
for i, item in array  ; Array iteration

; Forward iteration (1 to N)
Loop StrLen(text) {
    i := A_Index  ; A_Index starts at 1
}

; Reverse iteration (N to 1)
Loop StrLen(text) {
    i := StrLen(text) - A_Index + 1  ; Calculate reverse index
}
```

### 8. SETTIMER

#### ❌ v1: Label References
```autohotkey
SetTimer, UpdateLabel, 1000
SetTimer, UpdateLabel, -1000
SetTimer, UpdateLabel, Off
```

#### ✅ v2: Function References
```autohotkey
SetTimer(() => Update(), 1000)
SetTimer(() => Update(), -1000)
SetTimer(() => Update(), 0)  ; Disable
```

### 9. GUI EVENTS

#### ❌ v1: Labels
```autohotkey
ButtonOK:
    MsgBox OK pressed
return

GuiClose:
    ExitApp
return
```

#### ✅ v2: OnEvent Handlers
```autohotkey
button.OnEvent("Click", (*) => MsgBox("OK pressed"))
gui.OnEvent("Close", (*) => ExitApp())
```

### 10. MENU COMMANDS

#### ❌ v1: Menu Command Syntax
```autohotkey
Menu, Tray, NoStandard
Menu, Tray, Add, Item, Label
Menu, Tray, Default, Item
Menu, Context, Add, Item, Subroutine
```

#### ✅ v2: Menu Object
```autohotkey
A_TrayMenu.Delete()
A_TrayMenu.Add("Item", (*) => Function())
A_TrayMenu.Default := "Item"
contextMenu := Menu()
contextMenu.Add("Item", (*) => Function())
```

### 11. FILEREAD

#### ❌ v1: Command Syntax
```autohotkey
FileRead, content, file.txt
FileRead, content, C:\path\file.txt
```

#### ✅ v2: Function with Return
```autohotkey
content := FileRead("file.txt")
content := FileRead("C:\path\file.txt")
```

### 12. STRING OPERATIONS

#### ❌ v1: Command Syntax
```autohotkey
StringReplace, output, input, find, replace
StringSplit, array, input, delimiter
StringLen, length, string
```

#### ✅ v2: Function Syntax
```autohotkey
output := StrReplace(input, "find", "replace")
array := StrSplit(input, "delimiter")
length := StrLen(string)
```

### 13. .ToUpper()/.ToLower()

#### ❌ v1/v2 Mismatch: Methods Don't Exist
```autohotkey
upper := text.ToUpper()  ; DOESN'T EXIST
lower := text.ToLower()  ; DOESN'T EXIST
```

#### ✅ v2: Use Functions
```autohotkey
upper := StrUpper(text)
lower := StrLower(text)
```

### 14. SOUND OPERATIONS

#### ❌ v1: Command Syntax
```autohotkey
SoundGet, volume
SoundGet, mute, , MUTE
SoundSet, 50
```

#### ✅ v2: Function Syntax
```autohotkey
SoundGet(&volume, , , "VOLUME")
SoundGet(&mute, , , "MUTE")
SoundSet(50)
```

### 15. VARIABLE ASSIGNMENT

#### ❌ v1: Single Equals
```autohotkey
var = value
```

#### ✅ v2: Colon Equals
```autohotkey
var := "value"
```

### 16. VARIABLE REFERENCES

#### ❌ v1: Percent Signs
```autohotkey
%variable%
%A_Var%
```

#### ✅ v2: Direct or { } for Dynamic
```autohotkey
%variable%  ; Expression only
{expression}  ; For dynamic references
```

### 17. IF STATEMENTS

#### ❌ v1: Legacy Syntax
```autohotkey
if var = value
if var contains text
```

#### ✅ v2: Expression Syntax Only
```autohotkey
if (var = "value")
if (InStr(var, "text"))
```

### 18. TRY-CATCH

#### ❌ v1: No Try-Catch
```autohotkey
; No error handling in v1
```

#### ❌ v2: Empty Catch Block
```autohotkey
try {
    code
} catch {  ; ERROR!
```

#### ✅ v2: Proper Catch
```autohotkey
try {
    code
} catch as e {
    HandleError(e)
}
```

### 19. ONERROR

#### ❌ v1: No OnError Function
```autohotkey
; Doesn't exist in v1
```

#### ❌ v2: Wrong Signature
```autohotkey
OnError("Handler")
Handler(exception) {  ; WRONG - missing Mode
    return true
}
```

#### ✅ v2: Correct Signature
```autohotkey
OnError("Handler")
Handler(Exception, Mode) {  ; CORRECT - TWO parameters
    return true
}
```

### 20. LABEL HANDLERS

#### ❌ v1: Colon Labels
```autohotkey
ButtonClick:
    MsgBox Clicked
return

SomeFunction() {
    ; Function code
}
```

#### ✅ v2: No Labels - Use Functions & OnEvent
```autohotkey
button.OnEvent("Click", (*) => DoClick())

DoClick(*) {
    MsgBox("Clicked")
}
```

### 21. FILESELECTFOLDER → DIRSELECT

#### ❌ v1: FileSelectFolder Command
```autohotkey
FileSelectFolder, outputVar, , 3, Select Folder
```

#### ❌ WRONG v2 Conversion (Common Mistake!)
```autohotkey
FileSelectFolder(outputVar, , 3, "Select Folder")  ; WRONG! Function doesn't exist
```

#### ✅ v2: Use DirSelect Function
```autohotkey
outputVar := DirSelect(, 3, "Select Folder")  ; CORRECT - returns path directly
if (outputVar != "") {
    ; User selected a folder
}
```

### 22. FILEWRITE → FILEOPEN().WRITE()

#### ❌ v1: FileWrite Command
```autohotkey
FileWrite, content, file.txt
```

#### ❌ WRONG v2 Conversion (Common Mistake!)
```autohotkey
FileWrite(content, "file.txt")  ; WRONG! Function doesn't exist
```

#### ✅ v2: Use FileOpen().Write()
```autohotkey
FileOpen("file.txt", "w", "UTF-8").Write(content)  ; CORRECT - explicit encoding
```

### 23. GUI TEXT OPTIONS (+Bold, etc.)

#### ❌ v1: Inline Options
```autohotkey
Gui, Add, Text, x10 y10 w100 h20 +Bold, Heading
```

#### ❌ WRONG v2 Conversion (Common Mistake!)
```autohotkey
gui.Add("Text", "x10 y10 w100 h20 +Bold", "Heading")  ; WRONG! +Bold not valid in Add()
```

#### ✅ v2: Use SetFont Before Adding Text
```autohotkey
gui.SetFont("s12 Bold", "Segoe UI")  ; Set font first
gui.Add("Text", "x10 y10 w100 h20", "Heading")  ; Then add text
gui.SetFont("s10", "Segoe UI")  ; Reset font for subsequent controls
```

---

## 🚨 CRITICAL CONVERSION MISTAKES SUMMARY

### Patterns That Were INCORRECTLY Converted (Found in This Codebase)

1. **Random() - WRONG:** `Random(outputVar, min, max)`  
   **CORRECT:** `outputVar := Random(min, max)`

2. **for loops with "to" - WRONG:** `for i := 1 to 10`  
   **CORRECT:** `Loop 10 { i := A_Index }` or `for i in Range(1, 10)`

3. **MsgBox timeout - WRONG:** `MsgBox("text", "title", "Iconi Timeout10")` or `MsgBox(..., ..., ..., 10)`  
   **CORRECT:** `MsgBox("text", "title", "Icon!")` (no timeout - use TrayTip/ToolTip for timed messages)

4. **FormatTime warnings - WRONG:** `FormatTime(timestamp, ...)` without initialization  
   **CORRECT:** `timestamp := ""` then `FormatTime(timestamp, ...)`

5. **Multi-statement hotkey callbacks - WRONG:** `Hotkey("key", (*) => { stmt1 stmt2 })`  
   **CORRECT:** Use named functions or `ObjBindMethod`

6. **FileSelectFolder - WRONG:** `FileSelectFolder(...)`  
   **CORRECT:** `DirSelect(...)`

7. **FileWrite - WRONG:** `FileWrite(...)`  
   **CORRECT:** `FileOpen(..., "w", "UTF-8").Write(...)`

8. **GUI +Bold option - WRONG:** `gui.Add("Text", "... +Bold", "...")`  
   **CORRECT:** `gui.SetFont("s12 Bold", ...)` before adding text

---

## 📋 COMPLETE CHECKLIST

Before pushing any script, verify:

- [ ] No `Gui,` commands (use `gui.Add()`)
- [ ] No `GuiControl,` (use `control.Text`)
- [ ] No `InputBox().Result/.Value` (use direct return)
- [ ] No `MsgBox,` (use `MsgBox()`)
- [ ] No `MsgBox(..., ..., ..., timeout)` (v2 has NO 4th parameter - use TrayTip/ToolTip for timed messages)
- [ ] No `MsgBox(..., ..., "Iconi Timeout10")` (invalid option string)
- [ ] No `FormatTime,` (use `FormatTime()`)
- [ ] All `FormatTime()` calls initialize output variable first: `timestamp := ""` then `FormatTime(timestamp, ...)`
- [ ] No `Random(outputVar, min, max)` (use `outputVar := Random(min, max)`)
- [ ] No `^!c::` hotkeys (use `Hotkey()`)
- [ ] No `for i := 1 to 10` (use `Loop N { i := A_Index }` or `for i in Range()`)
- [ ] No `for i := N to 1` (use `Loop N { i := N - A_Index + 1 }`)
- [ ] No `SetTimer, Label` (use `SetTimer(() => Func(), period)`)
- [ ] No label handlers (use `OnEvent()`)
- [ ] No `Menu,` commands (use `A_TrayMenu` or `Menu()` object)
- [ ] No `FileRead, var, file` (use `var := FileRead()`)
- [ ] No `StringReplace/Split/Len` (use `StrReplace/Split/Len()`)
- [ ] No `.ToUpper()/.ToLower()` (use `StrUpper/Lower()`)
- [ ] No `SoundGet,` (use `SoundGet(&var, ...)`)
- [ ] No `var = value` (use `var := "value"`)
- [ ] No legacy `if var = value` (use `if (var = "value")`)
- [ ] No empty `catch {}` (use `catch as unused`)
- [ ] OnError with TWO parameters: `(Exception, Mode)`
- [ ] No label handlers (convert to functions)
- [ ] No multi-statement arrow functions in hotkeys (use named functions or `ObjBindMethod`)
- [ ] No `FileSelectFolder()` (use `DirSelect()`)
- [ ] No `FileWrite()` (use `FileOpen(..., "w", "UTF-8").Write()`)
- [ ] No `+Bold` in `gui.Add("Text", ...)` (use `gui.SetFont("s12 Bold", ...)` before adding)

---

## 🎯 CONVERSION EXAMPLES

### Example 1: Complete GUI Conversion

**v1:**
```autohotkey
#Requires AutoHotkey v1.0

Gui, Add, Button, x10 y10 w100 h30 gButtonClick, Click Me
Gui, Add, Edit, x10 y50 w200 h20 vUserName
Gui, Show, w300 h400, My App
return

ButtonClick:
    GuiControlGet, userName,, UserName
    MsgBox, 64, Info, Hello %userName%
    Gui, Submit
return
```

**v2:**
```autohotkey
#Requires AutoHotkey v2.0+

OnError("LogError")

gui := Gui("w300 h400", "My App")
userNameEdit := gui.Add("Edit", "x10 y50 w200 h20")
button := gui.Add("Button", "x10 y10 w100 h30", "Click Me")

button.OnEvent("Click", (*) => {
    userName := userNameEdit.Text
    MsgBox("Hello " . userName, "Info", "Iconi")
})

gui.Show()

Loop {
    Sleep(1000)
}
```

### Example 2: Menu Conversion

**v1:**
```autohotkey
Menu, Tray, NoStandard
Menu, Tray, Add, Open, ShowGUI
Menu, Tray, Default, Open
Menu, Tray, Tip, My App

ShowGUI:
    Gui, Show
return
```

**v2:**
```autohotkey
A_TrayMenu.Delete()
A_TrayMenu.Add("Open", (*) => ShowGUI())
A_TrayMenu.Default := "Open"
A_IconTip := "My App"

ShowGUI(*) {
    gui.Show()
}
```

### Example 3: Timer Conversion

**v1:**
```autohotkey
SetTimer, UpdateDisplay, 1000

UpdateDisplay:
    GuiControl,, StatusBar, Updated
return
```

**v2:**
```autohotkey
SetTimer(() => UpdateDisplay(), 1000)

UpdateDisplay() {
    statusBar.Text := "Updated"
}
```

---

## 🚀 MIGRATION STRATEGY

1. **Add OnError handler** at top
2. **Replace Gui commands** with gui object
3. **Replace label handlers** with OnEvent or functions
4. **Replace SetTimer labels** with arrow functions
5. **Replace Menu commands** with Menu objects
6. **Fix all InputBox** usage (remove .Result/.Value)
7. **Fix all variable assignments** (:= not =)
8. **Fix all command syntax** to function syntax
9. **Add Loop at end** to keep script running
10. **Test thoroughly** before committing

---

**Remember:** When in doubt, check the v2 documentation for function signatures!

