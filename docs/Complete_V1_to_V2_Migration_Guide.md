# Complete AutoHotkey v1 to v2 Migration Guide

## 🚨 ALL v1 Syntax Patterns That MUST Be Fixed

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

#### ✅ v2: Function with Parentheses
```autohotkey
MsgBox("Message", "Title", "Iconi")
MsgBox(text, , option)
```

### 4. FORMATTIME

#### ❌ v1: Command Syntax
```autohotkey
FormatTime, output,, yyyy-MM-dd
FormatTime, output, A_Now
```

#### ✅ v2: Function Syntax
```autohotkey
FormatTime(output, , "yyyy-MM-dd")
timestamp := FormatTime(A_Now, "yyyy-MM-dd")
```

### 5. RANDOM

#### ❌ v1: Returns Value Directly
```autohotkey
randomValue := Random(1, 100)
```

#### ✅ v2: Output Parameter First
```autohotkey
Random(randomValue, 1, 100)
```

### 6. HOTKEYS

#### ❌ v1: Double Colon Syntax
```autohotkey
^!c::
    DoSomething()
return

F7::Function()
```

#### ✅ v2: Hotkey() Function
```autohotkey
Hotkey("^!c", (*) => DoSomething())
Hotkey("F7", (*) => Function())
```

### 7. FOR LOOPS

#### ❌ v1: "to" Keyword
```autohotkey
Loop, 10
Loop Files, C:\*.*
for i := 1 to 10
```

#### ✅ v2: Methods and Ranges
```autohotkey
Loop 10
Loop Files "C:\*.*"
for i in Range(1, 10)
for i, item in array
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

---

## 📋 COMPLETE CHECKLIST

Before pushing any script, verify:

- [ ] No `Gui,` commands (use `gui.Add()`)
- [ ] No `GuiControl,` (use `control.Text`)
- [ ] No `InputBox().Result/.Value` (use direct return)
- [ ] No `MsgBox,` (use `MsgBox()`)
- [ ] No `FormatTime,` (use `FormatTime()`)
- [ ] No `Random()` without output param (use `Random(var, min, max)`)
- [ ] No `^!c::` hotkeys (use `Hotkey()`)
- [ ] No `for i := 1 to 10` (use `for i in Range()`)
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

