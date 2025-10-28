# GUI Handling Best Practices for AutoHotkey v2

## Overview
This guide documents the standard pattern for handling GUI objects in AutoHotkey v2 scriptlets to prevent errors like "gui has no method close" and improve stability.

## Problem Statement
Without proper GUI instance management, AutoHotkey v2 scriptlets encounter errors such as:
- "gui has no method close"
- Lost context when accessing GUI controls
- Fragile `GuiFromHwnd()` usage
- No error handling for GUI operations

## Solution Pattern

### 1. Class-Level Storage
Store GUI instances and controls at the class level:

```autohotkey
class YourClass {
    ; Store GUI instance
    static guiInstance := ""
    
    ; Store GUI controls
    static guiControls := Map()
    
    ; Debug mode
    static debugMode := false
}
```

### 2. Helper Methods
Add validation and logging methods:

```autohotkey
static LogDebug(message) {
    if (this.debugMode) {
        OutputDebug("[YourClass] " . message)
    }
}

static ValidateGUI() {
    if (this.guiInstance = "") {
        this.LogDebug("GUI instance not available")
        return false
    }
    return true
}
```

### 3. Creating GUI with Error Handling
Wrap GUI creation in try-catch blocks:

```autohotkey
static CreateGUI() {
    try {
        ; Check if GUI already exists
        if (this.guiInstance) {
            this.guiInstance.Close()
            this.guiInstance := ""
            this.guiControls.Clear()
        }
        
        ; Create GUI instance
        this.guiInstance := Gui("+Resize +MinSize800x600", "Window Title")
        this.guiInstance.BackColor := "0x1a1a1a"
        this.guiInstance.SetFont("s10 cWhite", "Segoe UI")
        
        ; Create controls and store references
        myControl := this.guiInstance.Add("Text", "x10 y10", "Example")
        this.guiControls["myControl"] := myControl
        
        ; Show the GUI
        this.guiInstance.Show("w800 h600")
        this.LogDebug("GUI created successfully")
        
    } catch as e {
        this.LogDebug("Error creating GUI: " . e.Message)
        MsgBox("Error creating GUI: " . e.Message, "Error", "Iconx")
        throw
    }
}
```

### 4. Accessing GUI Controls
Always use stored references with validation:

```autohotkey
static UpdateGUI() {
    try {
        if (this.guiInstance != "" && this.guiControls.Has("myControl")) {
            this.guiControls["myControl"].Text := "New text"
            this.LogDebug("GUI updated successfully")
        } else {
            this.LogDebug("GUI or control not available")
        }
    } catch as e {
        this.LogDebug("Error updating GUI: " . e.Message)
    }
}
```

### 5. Closing GUI with Cleanup
Properly clean up resources:

```autohotkey
static CloseGUI(*) {
    try {
        if (this.guiInstance) {
            this.guiInstance.Close()
            this.guiInstance := ""
            this.guiControls.Clear()
            this.LogDebug("GUI closed successfully")
        } else {
            ; Fallback to WindowClose if instance not available
            if (WinExist("Window Title")) {
                WinClose("Window Title")
            }
        }
    } catch as e {
        this.LogDebug("Error closing GUI: " . e.Message)
    }
}
```

## Implementation Examples

### Example: MCP Config Manager

```autohotkey
class MCPConfigManager {
    static guiInstance := ""
    static guiControls := Map()
    static debugMode := false
    
    static CreateGUI() {
        try {
            this.guiInstance := Gui("+Resize +MinSize800x600", "MCP Config Manager")
            ; ... GUI setup ...
            configEdit := this.guiInstance.Add("Edit", ...)
            this.guiControls["configEdit"] := configEdit
            this.guiInstance.Show("w800 h700")
            this.LogDebug("MCP Config Manager initialized")
        } catch as e {
            this.LogDebug("Error: " . e.Message)
            throw
        }
    }
    
    static CloseGUI(*) {
        try {
            if (this.guiInstance != "") {
                this.guiInstance.Close()
                this.guiInstance := ""
                this.guiControls.Clear()
            }
        } catch as e {
            this.LogDebug("Error closing: " . e.Message)
        }
    }
}
```

### Example: Chess Game

```autohotkey
class ChessGame {
    static gameGui := ""
    static guiControls := Map()
    static debugMode := false
    
    static DrawBoard() {
        try {
            if (!this.ValidateGUI()) return
            
            boardText := "Current Position...`n"
            
            if (this.guiControls.Has("BoardText")) {
                this.guiControls["BoardText"].Text := boardText
                this.LogDebug("Board updated")
            }
        } catch as e {
            this.LogDebug("DrawBoard error: " . e.Message)
        }
    }
}
```

## Key Benefits

### 1. **Error Prevention**
- No more "gui has no method close" errors
- Proper validation before operations
- Safe control access with Map.Has()

### 2. **Better Debugging**
- Debug logging throughout
- Clear error messages
- Stack trace preservation

### 3. **Resource Management**
- Proper cleanup on close
- No memory leaks
- Control references maintained

### 4. **Maintainability**
- Consistent pattern across all scriptlets
- Easy to understand and modify
- Self-documenting code

## Common Pitfalls to Avoid

### ❌ Don't Use GuiFromHwnd()
```autohotkey
; BAD - Fragile and error-prone
gui := GuiFromHwnd(WinGetID("Window"))
gui.Control["Text1"].Text := "value"
```

### ✅ Use Stored Instances
```autohotkey
; GOOD - Reliable and maintainable
if (this.guiControls.Has("Text1")) {
    this.guiControls["Text1"].Text := "value"
}
```

### ❌ Don't Check GUI Existence with WinExist()
```autohotkey
; BAD - Can be unreliable
if (WinExist("MCP Config Manager")) {
    ; Perform GUI operations
}
```

### ✅ Store Instance Reference
```autohotkey
; GOOD - Direct and reliable
if (this.guiInstance != "") {
    ; Perform GUI operations
}
```

### ❌ Don't Access Controls Directly
```autohotkey
; BAD - No error handling
this.guiInstance.Control["myControl"].Text := value
```

### ✅ Validate Before Access
```autohotkey
; GOOD - Safe and validated
if (this.guiControls.Has("myControl")) {
    this.guiControls["myControl"].Text := value
}
```

## Testing Your Implementation

### Enable Debug Mode
```autohotkey
static debugMode := true  ; Enable for testing
```

### Test Scenarios
1. **GUI Creation**: Verify no errors on startup
2. **Control Access**: Verify controls accessible
3. **Update Operations**: Verify updates work
4. **Close Operations**: Verify proper cleanup
5. **Error Recovery**: Verify error handling

### Debug Log Output
With debug mode enabled, you'll see:
```
[YourClass] GUI created successfully
[YourClass] GUI updated successfully
[YourClass] GUI closed successfully
```

## Migration Checklist

When updating an existing scriptlet:

- [ ] Add `static guiInstance := ""`
- [ ] Add `static guiControls := Map()`
- [ ] Add `static debugMode := false`
- [ ] Add `LogDebug()` method
- [ ] Add `ValidateGUI()` method
- [ ] Wrap `CreateGUI()` in try-catch
- [ ] Store all controls in `guiControls` Map
- [ ] Update `CloseGUI()` with proper cleanup
- [ ] Replace all `GuiFromHwnd()` usage
- [ ] Add validation before control access
- [ ] Test all GUI operations
- [ ] Enable linter and fix errors
- [ ] Run with debug mode to verify logging

## Summary

This pattern provides:
- **Reliable** GUI operations without errors
- **Safe** control access with validation
- **Clean** resource management
- **Debuggable** code with logging
- **Maintainable** consistent structure

All scriptlets in the repository should follow this pattern for GUI handling.
