# InputBox v1 vs v2 Syntax

## CRITICAL DIFFERENCE

### ❌ v1: Returns Object with .Result and .Value Properties
```autohotkey
# v1 Syntax (WRONG IN V2):
result := InputBox("Prompt text", "Title")
if (result.Result = "OK") {
    userInput := result.Value
}
```

### ✅ v2: Returns String Directly
```autohotkey
# v2 Syntax (CORRECT):
userInput := InputBox("Prompt text", "Title")
if (userInput = "") {
    ; User pressed Cancel or OK with empty input
    return
}
```

## Key Points

1. **v2 InputBox returns the VALUE directly**, not an object
2. **Empty string = Cancel** or empty input
3. **No .Result property** in v2
4. **No .Value property** in v2
5. **Simple string comparison** for validation

## Migration Pattern

### Before (v1 style - WRONG):
```autohotkey
name := InputBox("Enter name:", "Name").Value
if (name = "") return

# Or even worse:
result := InputBox("Enter name:", "Name")
if (result.Result = "OK") {
    name := result.Value
}
```

### After (v2 - CORRECT):
```autohotkey
name := InputBox("Enter name:", "Name")
if (name = "") return
```

## Examples

### Single Input Box
```autohotkey
# v2 correct usage
name := InputBox("Enter your name:", "Name Entry")
if (name != "") {
    MsgBox("Hello, " . name)
}
```

### Multiple Input Boxes
```autohotkey
# Get username
username := InputBox("Enter username:", "Login")
if (username = "") {
    MsgBox("Username required!")
    return
}

# Get password
password := InputBox("Enter password:", "Login")
if (password = "") {
    MsgBox("Password required!")
    return
}

# Use the values
Login(username, password)
```

### Optional Input
```autohotkey
# Optional note field
note := InputBox("Enter note (optional):", "Add Note")
if (note = "") {
    note := "No note"  ; Default value
}

SaveNote(note)
```

## Migration Checklist

When fixing InputBox in v2 scripts:

- [ ] Remove `.Result` property access
- [ ] Remove `.Value` property access
- [ ] Remove object-style result handling
- [ ] Use direct string return
- [ ] Change `result.Result = "OK"` to check for empty string
- [ ] Change `result.Value` to just use the returned value directly

## Common Patterns to Fix

### Pattern 1: Result Property
```autohotkey
# WRONG:
result := InputBox("Prompt", "Title")
if (result.Result = "OK") {
    value := result.Value
}

# CORRECT:
value := InputBox("Prompt", "Title")
if (value != "") {
    ; Use value
}
```

### Pattern 2: Value Property
```autohotkey
# WRONG:
name := InputBox("Prompt", "Title").Value
if (name = "") return

# CORRECT:
name := InputBox("Prompt", "Title")
if (name = "") return
```

### Pattern 3: Multiple Checks
```autohotkey
# WRONG:
result := InputBox("Prompt", "Title")
if (result.Result = "OK" && result.Value != "") {
    Process(result.Value)
}

# CORRECT:
value := InputBox("Prompt", "Title")
if (value != "") {
    Process(value)
}
```

## Files Fixed

- ✅ `mcp_config_manager.ahk` - Fixed 5 InputBox calls
- ✅ `smart_assistant_pro.ahk` - Fixed 3 InputBox calls
- ✅ `quick_notes.ahk` - Fixed 2 InputBox calls
- ✅ `music_controller_pro.ahk` - Fixed 1 InputBox call

## Summary

**InputBox in v2:**
- Returns: **String** (the input value)
- Returns empty string ("") if cancelled or no input
- NO object properties (.Result, .Value)
- Simple string validation: `if (input = "")`

This is a common v1 holdover that causes runtime errors in v2!

