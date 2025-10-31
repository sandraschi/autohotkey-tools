# AutoHotkey v2 Syntax, Keywords & Usage Guide

## 🚀 AutoHotkey v2.0+ Syntax Reference

### Key Differences from v1

| Feature | v1 Syntax | v2 Syntax | Notes |
|---------|-----------|-----------|-------|
| **Function Calls** | `MsgBox text` | `MsgBox(text)` | Parentheses required |
| **String Concatenation** | `"text " variable` | `"text " . variable` | Use `.` operator |
| **Variable Declaration** | `local var := value` | `var := value` | `local` keyword removed |
| **Global Variables** | `global var` | `var := value` | `global` keyword optional |
| **Error Handling** | `catch Error as e` | `catch as e` | Simplified syntax |
| **File Operations** | `FileRead var, file` | `FileRead(var, file)` | Function syntax |
| **Loop Syntax** | `Loop, Files` | `Loop Files` | Simplified |

### Core Syntax Elements

#### 1. Variables and Assignment
```ahk
; Variable assignment
myVar := "Hello World"
number := 42
array := [1, 2, 3, 4, 5]
object := {name: "John", age: 30}

; String concatenation
message := "Hello " . name . "!"
result := "Value: " . myVar
```

#### 2. Functions and Methods
```ahk
; Function definition
MyFunction(param1, param2 := "default") {
    return param1 . " " . param2
}

; Function calls (parentheses required)
result := MyFunction("Hello", "World")
MsgBox("Result: " . result)

; Method calls
gui := Gui()
gui.Add("Text", "Hello World")
gui.Show()
```

#### 3. Control Structures
```ahk
; If statements
if (condition) {
    ; code
} else if (otherCondition) {
    ; code
} else {
    ; code
}

; Loops
Loop 10 {
    ; code
}

Loop Files, "*.txt" {
    ; code
}

for item in array {
    ; code
}

while (condition) {
    ; code
}
```

#### 4. Error Handling
```ahk
try {
    ; risky code
    FileRead(content, "file.txt")
} catch as e {
    MsgBox("Error: " . e.Message)
}

; Custom error throwing
if (errorCondition) {
    throw Error("Custom error message")
}
```

### Built-in Keywords and Functions

#### Core Keywords
```ahk
#Requires AutoHotkey v2.0+    ; Version requirement
#SingleInstance Force          ; Single instance
#NoTrayIcon                    ; No tray icon
#Include "file.ahk"            ; Include file

; Control flow
if, else, else if
switch, case, default
while, for, Loop
break, continue
return, throw

; Variable scope
static, global, local
```

#### Built-in Functions
```ahk
; Output and UI
MsgBox(text, title := "", options := "")
InputBox(&outputVar, title, prompt)
TrayTip(title, text, options)

; File operations
FileRead(&outputVar, filename)
FileWrite(text, filename)
FileAppend(text, filename)
FileDelete(filename)
FileExist(filename)

; String operations
StrLen(string)
SubStr(string, startPos, length)
InStr(haystack, needle)
RegExMatch(haystack, needle, &outputVar)
RegExReplace(haystack, needle, replacement)

; Array operations
Array.Length
Array.Push(item)
Array.Pop()
Array.Delete(index)

; Object operations
Object.Has(key)
Object.Get(key)
Object.Set(key, value)
Object.Delete(key)
```

#### Built-in Variables
```ahk
; System variables
A_ScriptDir          ; Script directory
A_ScriptName         ; Script filename
A_ScriptFullPath     ; Full script path
A_WorkingDir         ; Working directory
A_Temp               ; Temp directory
A_AppData            ; AppData directory

; Time variables
A_Now                ; Current timestamp
A_Year, A_Month, A_Day
A_Hour, A_Min, A_Sec

; System info
A_OSVersion          ; OS version
A_Is64bitOS          ; 64-bit OS
A_ComputerName       ; Computer name
A_UserName           ; Username

; Script info
A_LineNumber         ; Current line number
A_ThisFunc           ; Current function name
A_Args               ; Command line arguments
```

### Classes and Objects

#### Class Definition
```ahk
class MyClass {
    ; Static properties
    static className := "MyClass"
    static instances := 0
    
    ; Instance properties
    name := ""
    value := 0
    
    ; Constructor
    __New(name := "Default") {
        this.name := name
        MyClass.instances++
    }
    
    ; Methods
    GetName() {
        return this.name
    }
    
    SetValue(value) {
        this.value := value
    }
    
    ; Static methods
    static GetInstanceCount() {
        return this.instances
    }
}
```

#### Object Usage
```ahk
; Create instance
obj := MyClass("Test")
obj.SetValue(42)

; Access properties
name := obj.name
value := obj.value

; Call methods
result := obj.GetName()
count := MyClass.GetInstanceCount()
```

### GUI Development

#### Basic GUI
```ahk
; Create GUI
gui := Gui("+Resize", "My Window")
gui.BackColor := "0x2d2d2d"
gui.SetFont("s10 cWhite", "Segoe UI")

; Add controls
gui.Add("Text", "x20 y20", "Hello World")
edit := gui.Add("Edit", "x20 y50 w200")
button := gui.Add("Button", "x20 y80 w100", "Click Me")

; Event handlers
button.OnEvent("Click", ButtonClick)

; Show GUI
gui.Show("w300 h200")

ButtonClick(*) {
    MsgBox("Button clicked!")
}
```

#### Advanced GUI Controls
```ahk
; Text controls
gui.Add("Text", "x20 y20 w200", "Static Text")
gui.Add("Text", "x20 y50 w200 cRed", "Colored Text")

; Input controls
edit := gui.Add("Edit", "x20 y80 w200 h25")
combo := gui.Add("DropDownList", "x20 y110 w200", ["Option 1", "Option 2"])
list := gui.Add("ListBox", "x20 y140 w200 h100")

; Buttons
gui.Add("Button", "x20 y250 w100 h30", "OK")
gui.Add("Button", "x130 y250 w100 h30", "Cancel")

; Checkboxes and radio buttons
gui.Add("CheckBox", "x20 y290 w200", "Check me")
gui.Add("Radio", "x20 y320 w200", "Option A")
gui.Add("Radio", "x20 y350 w200", "Option B")
```

### Hotkeys and Hotstrings

#### Hotkeys
```ahk
; Basic hotkeys
^!r::MyFunction()           ; Ctrl+Alt+R
F1::MsgBox("Help!")        ; F1 key
#Space::Send("Hello")       ; Win+Space

; Hotkey with parameters
^!s::
{
    Send("^s")  ; Ctrl+S
    Sleep(100)
    Send("My text")
}

; Context-sensitive hotkeys
#If WinActive("Notepad")
^s::MsgBox("Notepad save!")
#If
```

#### Hotstrings
```ahk
; Basic hotstrings
::btw::by the way
::omg::oh my god
::addr::123 Main Street

; Hotstrings with functions
::date::
{
    Send(FormatTime(A_Now, "yyyy-MM-dd"))
}

; Case-sensitive hotstrings
:*:AHK::AutoHotkey
```

### File and Directory Operations

#### File Operations
```ahk
; Read file
content := FileRead("file.txt")

; Write file
FileWrite("Hello World", "output.txt")

; Append to file
FileAppend("New line`n", "log.txt")

; Check if file exists
if (FileExist("config.ini")) {
    ; file exists
}

; Delete file
FileDelete("temp.txt")

; Copy file
FileCopy("source.txt", "destination.txt")
```

#### Directory Operations
```ahk
; Create directory
DirCreate("new_folder")

; Check if directory exists
if (DirExist("folder")) {
    ; directory exists
}

; Delete directory
DirDelete("folder", true)  ; true = delete recursively

; List files
Loop Files, "*.txt" {
    MsgBox("Found: " . A_LoopFileName)
}

; List directories
Loop Files, "*", "D" {
    MsgBox("Directory: " . A_LoopFileName)
}
```

### Regular Expressions

#### Basic Regex
```ahk
; Simple match
if (RegExMatch("Hello World", "World")) {
    MsgBox("Found World!")
}

; Capture groups
if (RegExMatch("John Doe", "(\w+) (\w+)", &match)) {
    firstName := match[1]  ; "John"
    lastName := match[2]   ; "Doe"
}

; Replace
newText := RegExReplace("Hello World", "World", "Universe")
; Result: "Hello Universe"
```

#### Advanced Regex
```ahk
; Email validation
email := "user@example.com"
if (RegExMatch(email, "^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$")) {
    MsgBox("Valid email!")
}

; Extract numbers
text := "Price: $123.45"
if (RegExMatch(text, "\$(\d+\.\d+)", &match)) {
    price := match[1]  ; "123.45"
}
```

### Common Patterns and Best Practices

#### Error Handling Pattern
```ahk
try {
    ; risky operation
    FileRead(content, "file.txt")
    ProcessContent(content)
} catch as e {
    LogError("Failed to process file: " . e.Message)
    ShowErrorMessage("File processing failed")
}
```

#### Configuration Pattern
```ahk
class Config {
    static Load() {
        try {
            if (FileExist("config.json")) {
                content := FileRead("config.json")
                return JSON.parse(content)
            }
        } catch {
            return this.GetDefaults()
        }
    }
    
    static GetDefaults() {
        return {
            theme: "dark",
            fontSize: 12,
            autoSave: true
        }
    }
}
```

#### Singleton Pattern
```ahk
class Singleton {
    static instance := ""
    
    static GetInstance() {
        if (!this.instance) {
            this.instance := Singleton()
        }
        return this.instance
    }
}
```

### Performance Tips

1. **Use static methods** when possible
2. **Avoid unnecessary string concatenation** in loops
3. **Use arrays instead of objects** for simple data
4. **Cache frequently accessed values**
5. **Use `#Include`** for code organization
6. **Minimize GUI updates** - batch operations

### Debugging Tips

1. **Use `OutputDebug()`** for logging
2. **Add `ListVars`** at error points
3. **Use `A_LineNumber`** for error tracking
4. **Enable debug mode** via command line
5. **Use try-catch** for error handling
6. **Log function entry/exit** for flow tracking

This comprehensive guide covers the essential syntax, keywords, and usage patterns for AutoHotkey v2.0+ development.
















