# AutoHotkey v2 Common Incompatibilities

This document describes common incompatibilities found when migrating or fixing AutoHotkey v2 scriptlets.

## Hotkey Function Syntax

### Issue 1: Missing Closing Parentheses

**Error Pattern:**
```autohotkey
Hotkey("F10", (*) => this.Function()  ; Missing )
```

**Correct Pattern:**
```autohotkey
Hotkey("F10", (*) => this.Function())  ; Note the double closing ))
```

**Why:** The `Hotkey()` function call needs two closing parentheses - one for the lambda function and one for the Hotkey function.

**Detection:** Linter checks for lines ending with lambda but missing the final `)`

### Issue 2: Prefix Modifiers with Hotkey()

**Incorrect Pattern:**
```autohotkey
^!Hotkey("l", (*) => this.Function())
#Hotkey("x", (*) => this.Function())
```

**Correct Pattern:**
```autohotkey
Hotkey("^!l", (*) => this.Function())  ; Modifiers inside the key string
Hotkey("#x", (*) => this.Function())
```

**Why:** In AutoHotkey v2, the `Hotkey()` function expects modifiers (`^`, `#`, `!`, `+`) to be part of the key string parameter, not as a prefix to the function call.

**Common Modifiers:**
- `^` = Ctrl
- `#` = Win
- `!` = Alt
- `+` = Shift

**Detection:** Linter checks for patterns like `^!Hotkey(`, `#Hotkey(`, etc.

### Issue 3: Multi-line Lambda Blocks

**Incorrect Pattern:**
```autohotkey
Hotkey("Escape", (*) => {
    if (WinExist("Window")) {
        WinClose("Window")
    }
})  ; This fails in v2
```

**Correct Pattern 1: Extract to Function**
```autohotkey
static CloseWindow(*) {
    if (WinExist("Window")) {
        WinClose("Window")
    }
}

Hotkey("Escape", (*) => this.CloseWindow())
```

**Correct Pattern 2: Single Line Lambda**
```autohotkey
Hotkey("Escape", (*) => WinClose("Window"))
```

**Why:** AutoHotkey v2 doesn't support multi-line block syntax `{ ... }` after `=>` in lambda functions. You must either use a single expression or extract the logic to a separate function.

**Detection:** Linter checks for `=> {` patterns.

## Summary of Changes

The three most common hotkey-related incompatibilities are:

1. **Missing closing parenthesis** - Always end with `))` for Hotkey() with lambdas
2. **Prefix modifiers** - Put modifiers in the string: `Hotkey("^!l", ...)`
3. **Multi-line lambdas** - Extract to separate functions or use single expressions

## Quick Reference

| Incorrect | Correct |
|-----------|---------|
| `Hotkey("F10", (*) => func()` | `Hotkey("F10", (*) => func())` |
| `^!Hotkey("l", ...)` | `Hotkey("^!l", ...)` |
| `Hotkey("Esc", (*) => { ... })` | Extract to function or use single line |

## Linter Checks

The linter now catches all three issues:
- Check 5a: Missing closing parenthesis
- Check 5b: Incorrect hotkey prefix modifiers
- Check 5c: Multi-line lambda blocks

Run the linter with:
```autohotkey
autohotkey.exe utils/linter.ahk path/to/scriptlet.ahk
```

## Real Example: mcp_log_analyzer.ahk

**Before (broken):**
```autohotkey
static SetupHotkeys(gui) {
    ^!Hotkey("l", (*) => this.AnalyzeLatestLogs()  ; ❌ Wrong prefix, missing closing )
    Hotkey("F10", (*) => this.GenerateFixes()     ; ❌ Missing closing )
    
    Hotkey("Escape", (*) => {                     ; ❌ Multi-line lambda
        if (WinExist("MCP Log Analyzer")) {
            WinClose("MCP Log Analyzer")
        }
    })
}
```

**After (fixed):**
```autohotkey
static CloseGUI(*) {                              ; ✅ Separate function
    if (WinExist("MCP Log Analyzer")) {
        WinClose("MCP Log Analyzer")
    }
}

static SetupHotkeys(gui) {
    Hotkey("^!l", (*) => this.AnalyzeLatestLogs()) ; ✅ Modifiers in string, proper closing
    Hotkey("F10", (*) => this.GenerateFixes())     ; ✅ Proper closing
    Hotkey("Escape", (*) => this.CloseGUI())       ; ✅ Call to separate function
}
```

## InputBox Function Syntax

### Issue 4: InputBox Variable Reference

**Incorrect Pattern (v1):**
```autohotkey
InputBox(&outputVar, "Title", "Prompt")
if (outputVar = "") return
```

**Correct Pattern (v2):**
```autohotkey
result := InputBox("Prompt", "Title")
if (result.Result != "OK" || result.Value = "") return
outputVar := result.Value
```

**Why:** AutoHotkey v2 changed `InputBox` from using output variable references to returning an object.

**v2 InputBox returns an InputBoxObject with:**
- `.Result` - "OK" or "Cancel"
- `.Value` - The text entered by the user

**Parameter Order (CRITICAL):**
- v1: `InputBox(&Var, Title, Prompt, Options, Default)`
- v2: `InputBox(Prompt, Title, Options, Default)`

**Important:** The parameter order is reversed! In v2, Prompt comes FIRST.

**Example Fix:**
```autohotkey
; v1 (wrong)
name := InputBox(&output, "Enter Name:", "What is your name?")
if (output = "") return

; v2 (correct)
result := InputBox("What is your name?", "Enter Name:")
if (result.Result != "OK" || result.Value = "") return
name := result.Value
```

## Loop Files Syntax

### Issue 5: Loop Files Comma

**Incorrect Pattern (v1):**
```autohotkey
Loop Files, "*.ahk" {
    ; code
}
```

**Correct Pattern (v2):**
```autohotkey
Loop Files "*.ahk" {
    ; code
}
```

**Why:** AutoHotkey v2 removed the comma separator from Loop Files syntax.

**Change:**
- v1: `Loop Files, Pattern [, Mode]`
- v2: `Loop Files Pattern [, Mode]`

**Example:**
```autohotkey
; v1 (wrong)
Loop Files, A_ScriptDir . "\*.json" {
    files.Push(A_LoopFilePath)
}

; v2 (correct)
Loop Files A_ScriptDir . "\*.json" {
    files.Push(A_LoopFilePath)
}
```

## Notes

- All issues were found in actual debugging sessions
- These patterns cause runtime errors in AutoHotkey v2
- The linter now prevents these issues from being committed
- When in doubt, extract lambda logic to named methods for clarity

