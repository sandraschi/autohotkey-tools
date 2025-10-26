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

## Notes

- All three issues were found in actual debugging sessions
- These patterns cause runtime errors in AutoHotkey v2
- The linter now prevents these issues from being committed
- When in doubt, extract lambda logic to named methods for clarity

