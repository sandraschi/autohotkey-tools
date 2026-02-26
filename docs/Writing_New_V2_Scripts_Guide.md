# Writing New AutoHotkey v2 Scripts - Quick Reference

## 🎯 Core Principle: Write v2 From The Start

**NEVER write v1 syntax and convert it later.** Always write v2 syntax directly.

---

## 📋 Essential v2 Patterns for New Scripts

### 1. Script Header (ALWAYS Required)
```autohotkey
#Requires AutoHotkey v2.0+
#SingleInstance Force

; ==============================================================================
; Script Name
; @name: Script Name
; @version: 1.0.0
; @description: Brief description
; @category: category
; @author: Sandra
; @hotkeys: ^!c, ^!v
; @enabled: true
; ==============================================================================
```

### 2. Error Handling (ALWAYS Required)
```autohotkey
#Include %A_ScriptDir%\lib\ScriptletErrorHandler.ahk
OnError(LogError)
```

### 3. GUI Creation (v2 Syntax)
```autohotkey
class MyScript {
    static gui := ""
    
    static CreateGUI() {
        newGui := Gui("+Resize +MinSize600x400", "My Script")
        newGui.BackColor := "F4F6F8"
        
        ; Set font for headings
        newGui.SetFont("s12 Bold", "Segoe UI")
        newGui.Add("Text", "x20 y15 w560 h25 Center", "My Script Title")
        
        ; Reset font for body
        newGui.SetFont("s10", "Segoe UI")
        
        ; Add controls
        editControl := newGui.Add("Edit", "x20 y50 w560 h200 Multi", "")
        button := newGui.Add("Button", "x20 y260 w100 h30", "Click Me")
        
        ; Bind events
        button.OnEvent("Click", ObjBindMethod(MyScript, "HandleClick"))
        newGui.OnEvent("Close", ObjBindMethod(MyScript, "HideGUI"))
        newGui.OnEvent("Escape", ObjBindMethod(MyScript, "HideGUI"))
        
        MyScript.gui := newGui
    }
    
    static HandleClick(*) {
        MsgBox("Button clicked!", "My Script", "Icon!")
    }
    
    static HideGUI(*) {
        MyScript.gui.Hide()
    }
    
    static Init() {
        MyScript.CreateGUI()
        MyScript.gui.Show()
    }
}

MyScript.Init()
```

### 4. Hotkeys (v2 Syntax)
```autohotkey
; Single statement - arrow function OK
Hotkey("^!c", (*) => MyScript.DoSomething())

; Multiple statements - use named function (RECOMMENDED)
Hotkey("^!v", MyScript.HandleHotkey)

MyScript.HandleHotkey(*) {
    MyScript.DoSomething()
    MyScript.DoSomethingElse()
    TrayTip("Done", "Action completed", 2)
}
```

**Important:** For hotkeys with try/catch blocks or complex control flow, ALWAYS use named functions. Arrow functions can cause parser errors:
```autohotkey
; ❌ WRONG - May cause parser errors with try/catch
Hotkey("^+l", (*) => {
    try {
        DoSomething()
    } catch {
        HandleError()
    }
})

; ✅ CORRECT - Use named function
MyHotkeyHandler(*) {
    try {
        DoSomething()
    } catch {
        HandleError()
    }
}
Hotkey("^+l", MyHotkeyHandler)
```

### 5. Common Functions (v2 Syntax)
```autohotkey
; Random number
value := Random(1, 100)  ; NOT Random(value, 1, 100)

; FormatTime
timestamp := ""
FormatTime(timestamp, A_Now, "yyyy-MM-dd HH:mm:ss")

; MsgBox (3 parameters only, NO timeout!)
MsgBox("Message", "Title", "Icon!")  ; Use TrayTip/ToolTip for timed messages
; ❌ NEVER use: MsgBox("Message", "Title", "T10") or MsgBox("Message", "Title", "T1024")
; Timeout options are NOT supported in v2 MsgBox!

; File operations
content := FileRead("file.txt")
FileOpen("file.txt", "w", "UTF-8").Write(content)

; Directory selection
folder := DirSelect(, 3, "Select Folder")  ; NOT FileSelectFolder

; String operations
upper := StrUpper(text)  ; NOT text.ToUpper()
lower := StrLower(text)  ; NOT text.ToLower()
replaced := StrReplace(text, "old", "new")
length := StrLen(text)
```

### 6. Loops (v2 Syntax)
```autohotkey
; Simple count
Loop 10 {
    ; A_Index starts at 1
}

; Forward iteration (1 to N)
Loop StrLen(text) {
    i := A_Index
    char := SubStr(text, i, 1)
}

; Reverse iteration (N to 1)
Loop StrLen(text) {
    i := StrLen(text) - A_Index + 1
    char := SubStr(text, i, 1)
}

; Array iteration
for i, item in array {
    ; i is index, item is value
}

; Range iteration
for i in Range(1, 10) {
    ; i goes from 1 to 10
}
```

### 7. Timers (v2 Syntax)
```autohotkey
; Start timer
SetTimer(() => MyScript.Update(), 1000)

; Run once after delay
SetTimer(() => MyScript.DoSomething(), -5000)

; Stop timer
SetTimer(() => MyScript.Update(), 0)
```

### 8. Non-Blocking Notifications
```autohotkey
; TrayTip (timed)
TrayTip("Title", "Message", 10)  ; 10 second timeout

; ToolTip (timed)
ToolTip("Message", , , 10)  ; 10 second timeout

; NEVER use MsgBox with timeout - it doesn't exist in v2!
```

---

## 🚫 Common Mistakes to Avoid

### ❌ WRONG (v1 patterns):
```autohotkey
Gui, Add, Text, x10 y10, Hello
MsgBox, 64, Title, Message
Random, value, 1, 100
for i := 1 to 10
^!c::DoSomething()
FileSelectFolder, folder
FileWrite, content, file.txt
gui.Add("Text", "... +Bold", "...")
```

### ✅ CORRECT (v2 patterns):
```autohotkey
gui.Add("Text", "x10 y10", "Hello")
MsgBox("Message", "Title", "Icon!")
value := Random(1, 100)
Loop 10 { i := A_Index }
Hotkey("^!c", (*) => DoSomething())
folder := DirSelect()
FileOpen("file.txt", "w", "UTF-8").Write(content)
gui.SetFont("s12 Bold", "Segoe UI")
gui.Add("Text", "...", "...")
```

---

## 📚 Reference Documents

1. **This Guide:** `docs/Writing_New_V2_Scripts_Guide.md` - Quick reference for new scripts
2. **Conversion Guide:** `docs/Complete_V1_to_V2_Migration_Guide.md` - Complete v1→v2 patterns
3. **Official Docs:** `AutoHotkeyDocs` repository - Canonical v2 documentation
4. **Standards:** `.cursorrules` - Repository-specific rules

---

## ✅ Checklist for New Scripts

Before finishing a new script, verify:

- [ ] `#Requires AutoHotkey v2.0+` at top
- [ ] Error handler included (`#Include %A_ScriptDir%\lib\ScriptletErrorHandler.ahk`)
- [ ] All GUI uses `gui.Add()` not `Gui, Add`
- [ ] All hotkeys use `Hotkey()` not `^!c::`
- [ ] All `Random()` calls use assignment: `value := Random(1, 100)`
- [ ] All loops use `Loop` or `for ... in` not `for i := 1 to 10`
- [ ] All `MsgBox` calls have 3 parameters only (no timeout)
- [ ] All `FormatTime` calls initialize output variable first
- [ ] All file operations use v2 functions (`FileRead`, `FileOpen().Write()`, `DirSelect`)
- [ ] All string operations use functions (`StrUpper`, `StrLower`, `StrReplace`)
- [ ] No v1 command syntax anywhere
- [ ] Linter passes with no errors

---

**Remember:** When in doubt, consult the official v2 documentation or the conversion guide. It's faster to write v2 correctly from the start than to fix conversion mistakes later!

