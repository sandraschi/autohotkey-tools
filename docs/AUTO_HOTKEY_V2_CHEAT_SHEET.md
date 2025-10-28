# AutoHotkey v2 Cheat Sheet - How to NOT Use Shitty v1 Patterns

## 🚨 CRITICAL RULES - NEVER USE THESE v1 PATTERNS

### ❌ FORBIDDEN: v1 Command Syntax (Everything with Commas)
```autohotkey
# ❌ NEVER DO THIS (v1 syntax):
MsgBox, 64, Title, Text
Gui, Add, Button, x10 y10 w100 h30, Click Me
SetTimer, MyFunction, 1000
Random, myVar, 1, 100
FileRead, content, myfile.txt
```

### ✅ REQUIRED: v2 Function Syntax (Parentheses + Commas Separating Arguments)
```autohotkey
# ✅ ALWAYS DO THIS (v2 syntax):
MsgBox("Text", "Title", "Iconi")
myGui.Add("Button", "x10 y10 w100 h30", "Click Me")
SetTimer(MyFunction, 1000)
Random(myVar, 1, 100)
content := FileRead("myfile.txt")
```

---

## 📝 Variable Assignment

### ❌ v1: Single `=`
```autohotkey
myVar = value
```

### ✅ v2: `:=` (Always!)
```autohotkey
myVar := "value"
```

---

## 📢 MsgBox

### ❌ v1: Comma-Separated Parameters
```autohotkey
MsgBox, 64, My Title, My message text
MsgBox, 16, Error, Something went wrong
MsgBox, My simple message
```

### ✅ v2: Parentheses with Quotes
```autohotkey
MsgBox("My message text", "My Title", "Iconi")    ; Info icon
MsgBox("Something went wrong", "Error", "Iconx")  ; Error icon
MsgBox("My simple message")
```

**Icon Codes:**
- `16` → `"Iconx"` (Error)
- `64` → `"Iconi"` (Information)
- `48` → `"Icon!"` (Warning)
- `32` → `"Icon?"` (Question)
- `256` → `"Icon2"` (Second icon)

---

## 🖼️ GUI Creation

### ❌ v1: Commas Everywhere
```autohotkey
Gui, Color, 1E1E1E
Gui, Font, s10 cWhite, Segoe UI
Gui, Add, Text, x10 y10 w200 h30, Hello
Gui, Add, Button, x10 y50 w100 h30 gMyButton, Click
Gui, Show, w400 h300, My Window
```

### ✅ v2: Object-Oriented Approach
```autohotkey
myGui := Gui("", "My Window")
myGui.BackColor := "1E1E1E"
myGui.SetFont("s10 cWhite", "Segoe UI")
myGui.Add("Text", "x10 y10 w200 h30", "Hello")
myBtn := myGui.Add("Button", "x10 y50 w100 h30", "Click")
myBtn.OnEvent("Click", MyFunction)
myGui.Show("w400 h300")
```

---

## 🎯 Hotkeys

### ❌ v1: Double Colon
```autohotkey
^!c::MyFunction()
F7::SomeClass.Method()
```

### ✅ v2: Hotkey() Function
```autohotkey
Hotkey("^!c", (*) => MyFunction())
Hotkey("F7", (*) => SomeClass.Method())
```

**Why the `(*)`?** It's a variadic parameter that discards all arguments. Hotkey callbacks receive 1 parameter (the hotkey itself), and this discards it.

---

## 🔄 Loops

### ❌ v1: `Loop, 10` or `for i := 1 to 10`
```autohotkey
Loop, 10 {
    ; do something
}

for i := 1 to 10 {
    ; do something
}
```

### ✅ v2: Range Operator `..` or Array Iteration
```autohotkey
; Counted loop
Loop 10 {
    ; do something
}

; Range loop
for i in 1..10 {
    ; do something
}

; Reverse range
for i in 10..1 {
    ; do something
}

; Array iteration
for item in myArray {
    ; do something with item
}
```

---

## 🎲 Random Numbers

### ❌ v1: Comma After Random
```autohotkey
Random, myVar, 1, 100
Random, myVar, 0, 1
```

### ✅ v2: Random OUT Parameter
```autohotkey
Random(myVar, 1, 100)
Random(myVar, 0, 1)
```

**Key Difference:** In v2, `Random()` outputs to the first parameter.

---

## 📁 File Operations

### ❌ v1: Comma Separation
```autohotkey
FileRead, content, myfile.txt
FileAppend, new content, myfile.txt
```

### ✅ v2: Return Values or Function Parameters
```autohotkey
content := FileRead("myfile.txt")
FileAppend("new content", "myfile.txt")

; Or with encoding
FileRead(content, "myfile.txt", "UTF-8")
FileAppend("new content", "myfile.txt", "UTF-8")
```

---

## ⏰ FormatTime

### ❌ v1: Missing First Parameter
```autohotkey
FormatTime, timestamp,, "yyyy-MM-dd HH:mm:ss"
```

### ✅ v2: Specify Target Variable First
```autohotkey
FormatTime(timestamp, A_Now, "yyyy-MM-dd HH:mm:ss")
```

**Parameter Order:** `FormatTime(outVar, timestamp, format)`

---

## 🕐 SetTimer

### ❌ v1: Label Name as String
```autohotkey
SetTimer, UpdateUI, 1000
SetTimer, MyFunction, Off
```

### ✅ v2: Function Reference
```autohotkey
SetTimer(UpdateUI, 1000)
SetTimer(UpdateUI, 0)  ; Stop the timer
SetTimer(UpdateUI, -1000)  ; Run once after delay
```

---

## 🔤 String Functions

### ❌ v1: StringXxxx Functions
```autohotkey
StringReplace, newStr, oldStr, old, new, All
StringSplit, array, myString, "`n"
StringLen, length, myString
```

### ✅ v2: StrXxx Functions (Return Values)
```autohotkey
newStr := StrReplace(oldStr, "old", "new", -1)  ; -1 = all
array := StrSplit(myString, "`n")
length := StrLen(myString)
```

---

## 🎮 GUI Control Updates

### ❌ v1: GuiControl Command
```autohotkey
GuiControl,, MyButton, New Text
GuiControl,, MyEdit, New Value
```

### ✅ v2: Direct Property Access
```autohotkey
myButton.Text := "New Text"
myEdit.Value := "New Value"
```

---

## 📊 Array Syntax

### ❌ v1: Commas in Array Creation
```autohotkey
myArray := ["item1", "item2", "item3"]
myArray[1] := "new value"
```

### ✅ v2: Same Syntax (Arrays Are Same in v2!)
```autohotkey
myArray := ["item1", "item2", "item3"]
myArray[1] := "new value"  ; This is still valid!
```

**Note:** Arrays are the same in v1 and v2, so don't worry about changing these.

---

## 🔄 Loop Syntax Details

### v1 vs v2 Loop Differences

| v1 Syntax | v2 Syntax | Notes |
|-----------|-----------|-------|
| `Loop, 10` | `Loop 10` | No comma in v2 |
| `Loop, Parse, str, delim` | `Loop Parse str, delim` | Parse as separate parameter |
| `for i := 1 to 10` | `for i in 1..10` | Use range operator |
| `while condition` | `while condition` | Same in v2 |

---

## 💡 Quick Reference: Common Mistakes

### 1. **MsgBox Comma vs Function**
```autohotkey
# ❌ WRONG:
MsgBox, 64, Title, Message

# ✅ RIGHT:
MsgBox("Message", "Title", "Iconi")
```

### 2. **Variable Assignment**
```autohotkey
# ❌ WRONG:
myVar = some value

# ✅ RIGHT:
myVar := "some value"
```

### 3. **Random Numbers**
```autohotkey
# ❌ WRONG:
Random, myVar, 1, 100

# ✅ RIGHT:
Random(myVar, 1, 100)
```

### 4. **Hotkeys**
```autohotkey
# ❌ WRONG:
^!c::MyFunction()

# ✅ RIGHT:
Hotkey("^!c", (*) => MyFunction())
```

### 5. **GUI Commands**
```autohotkey
# ❌ WRONG:
Gui, Add, Button, x10 y10 w100 h30 gMyFunction, Click

# ✅ RIGHT:
myBtn := myGui.Add("Button", "x10 y10 w100 h30", "Click")
myBtn.OnEvent("Click", MyFunction)
```

---

## 🛡️ Remember This Mantra

> **"If it has a comma after a keyword, it's probably v1 syntax!"**

### Command Pattern (v1) ❌
```autohotkey
Command, param1, param2, param3
```

### Function Pattern (v2) ✅
```autohotkey
Command(param1, param2, param3)
```

---

## 📚 Exception: Some v1 Commands Still Work

These v1-style commands **DO still work in v2** (but consider modernizing):

- `Sleep, 1000` → Works, but `Sleep(1000)` is preferred
- `Clipboard := "text"` → Works, but `A_Clipboard := "text"` is preferred
- `ExitApp` → Works, but `ExitApp()` is preferred

**Recommendation:** Use the v2 function syntax for consistency.

---

## 🎯 Mental Model for v2

**v1:** Commands that take comma-separated parameters  
**v2:** Functions that return values or modify objects

### The Shift
```
v1: "Do this with these things"
v2: "Get a result from doing this with these things"
```

### Examples

**v1 Thinking:**
```autohotkey
FileRead the content from this file
Gui add this control to the GUI
SetTimer run this function every 1000ms
```

**v2 Thinking:**
```autohotkey
I got this content by reading this file
The GUI has this control that I added to it
Timer calls this function every 1000ms
```

---

## 🔍 How to Spot v1 Patterns

Look for these red flags:
- ✅ Commas after commands (`Gui,`, `FileRead,`, `MsgBox,`)
- ✅ Variable assignment with `=` (not `:=`)
- ✅ Hotkeys with `::` (not `Hotkey()`)
- ✅ Loops with `to` (not `..`)
- ✅ String functions starting with `String` (not `Str`)

---

## 💾 Quick Copy-Paste Templates

### Function Template
```autohotkey
MyFunction(param1, param2) {
    local result := ""
    ; Your code here
    return result
}
```

### Class Template
```autohotkey
class MyClass {
    static myStatic := ""
    
    __New() {
        this.myProperty := ""
    }
    
    static StaticMethod() {
        ; Static method code
    }
    
    InstanceMethod() {
        ; Instance method code
    }
}
```

### GUI Template
```autohotkey
myGui := Gui("+Resize", "My App")
myGui.SetFont("s10", "Segoe UI")

myGui.Add("Text", "w200", "Hello World")
myBtn := myGui.Add("Button", "w100 h30", "Click Me")
myBtn.OnEvent("Click", (*) => MsgBox("Clicked!"))

myGui.Show()
```

---

## 🚀 Final Checklist Before Writing Code

Before you write ANY code, ask:
1. ✅ Am I using `:=` for assignment?
2. ✅ Am I using function syntax `()` for commands?
3. ✅ Am I NOT using comma after commands like `MsgBox,`?
4. ✅ Am I using `Hotkey()` for hotkeys?
5. ✅ Am I using `Gui()` and object methods for GUI?
6. ✅ Am I using `..` for ranges instead of `to`?
7. ✅ Am I checking return values from functions?
8. ✅ Am I using `static` for class-wide variables?

If any answer is NO, fix it before continuing! 🎯

---

## 📝 InputBox - User Input

### ❌ v1: Returns Object with Properties
```autohotkey
# WRONG (v1 syntax):
result := InputBox("Enter name:", "Name")
if (result.Result = "OK") {
    name := result.Value
}

# WRONG:
name := InputBox("Enter name:", "Name").Value
```

### ✅ v2: Returns String Directly
```autohotkey
# CORRECT (v2 syntax):
name := InputBox("Enter name:", "Name")
if (name = "") {
    ; User cancelled or entered nothing
    return
}

# Empty string means cancelled or no input
userInput := InputBox("Prompt text", "Title")
if (userInput != "") {
    ; Process input
}
```

**Key Points:**
- InputBox returns the string value directly (not an object)
- Empty string ("") = user cancelled or empty input
- No .Result property in v2
- No .Value property in v2
- Simple string comparison for validation

---

## 🛡️ ERROR HANDLING - OnError

### ❌ v1: No OnError Function
AutoHotkey v1 did not have OnError() function.

### ✅ v2: OnError with TWO Parameters
```autohotkey
# REQUIRED: OnError signature in v2 takes TWO parameters
OnError("ErrorHandler")

ErrorHandler(Exception, Mode) {
    ; Exception object has properties: Message, Line, What, File, Extra
    FileAppend("Error at line " . Exception.Line . ": " . Exception.Message . "`n", "errors.log", "UTF-8")
    return true  ; Returning true suppresses the default error popup
}

# CRITICAL: The function MUST accept two parameters: (Exception, Mode)
# Do NOT use: ErrorHandler(Exception) - WRONG!
# Use: ErrorHandler(Exception, Mode) - CORRECT!
```

**Key Points:**
- First parameter: `Exception` object with `.Message`, `.Line`, `.What`, `.File`, `.Extra` properties
- Second parameter: `Mode` (usually ignored but required in signature)
- Return `true` to suppress popup, return `false` to show default popup
- Must be called at the TOP of your script before any code that might error

**Example for suppressing all error popups:**
```autohotkey
#Requires AutoHotkey v2.0+

OnError("LogError")

LogError(Exception, Mode) {
    ; Log to file
    FileAppend("[" . A_Now . "] " . Exception.Message . " at line " . Exception.Line . "`n", "error.log", "UTF-8")
    return true  ; Suppress popup
}

; Your code here...
```