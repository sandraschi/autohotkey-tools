# AutoHotkey Debugging Guide

## 🔧 AutoHotkey Debug Flags & Command Line Parameters

### Command Line Switches

```bash
# Basic syntax
AutoHotkey.exe [switches] [scriptfile] [parameters]

# Common debug-related switches:
AutoHotkey.exe /ErrorStdOut script.ahk          # Send errors to stdout
AutoHotkey.exe /NoTrayIcon script.ahk          # No tray icon
AutoHotkey.exe /Force script.ahk               # Force reload
AutoHotkey.exe /ErrorStdOut /NoTrayIcon script.ahk  # Combined
```

### Built-in Debug Commands

#### 1. ListVars - Variable Inspector
```ahk
ListVars  ; Shows ALL variables and their current values
Pause     ; Pauses execution so you can read them
```

#### 2. ListLines - Execution Tracker
```ahk
ListLines  ; Shows recently executed lines
Pause      ; Pauses execution
```

#### 3. KeyHistory - Input Logger
```ahk
KeyHistory  ; Shows recent keystrokes and mouse clicks
Pause       ; Pauses execution
```

#### 4. OutputDebug - Debug Output
```ahk
OutputDebug("Debug message: " . variable)
OutputDebug("Error at line " . A_LineNumber)
```

### Debug Integration Patterns

#### Method 1: Command Line Debugging
```bash
# Run script with error output to console
AutoHotkey.exe /ErrorStdOut my_script.ahk

# Run without tray icon (cleaner for debugging)
AutoHotkey.exe /NoTrayIcon my_script.ahk

# Force reload for testing
AutoHotkey.exe /Force my_script.ahk

# Combined flags
AutoHotkey.exe /ErrorStdOut /NoTrayIcon /Force my_script.ahk
```

#### Method 2: Debug Mode Detection
```ahk
class MyScript {
    static debugMode := false
    
    static Init() {
        ; Detect debug mode from command line
        this.debugMode := A_Args.Length > 0 && A_Args[1] = "/debug"
        this.LogDebug("Script initialized" . (this.debugMode ? " in DEBUG mode" : ""))
    }
    
    static LogDebug(message) {
        if (this.debugMode) {
            timestamp := FormatTime(A_Now, "HH:mm:ss")
            logEntry := "[" . timestamp . "] " . message
            OutputDebug(logEntry)
        }
    }
}
```

#### Method 3: Debug Points in Code
```ahk
try {
    this.LogDebug("Function started: " . A_ThisFunc)
    this.LogDebug("Variable value: " . myVariable)
    
    ; Your code here
    
    this.LogDebug("Function completed successfully")
} catch as e {
    this.LogDebug("Error: " . e.Message)
    if (this.debugMode) {
        this.LogDebug("Error details - File: " . e.File . ", Line: " . e.Line)
        ListVars  ; Show all variables when error occurs
        Pause
    }
    throw e
}
```

### Advanced Debugging Techniques

#### Using DebugView (Sysinternals)
1. Download DebugView from Microsoft Sysinternals
2. Run DebugView
3. Use `OutputDebug()` in your scripts
4. See real-time debug output in DebugView

#### VSCode Integration
- Install `vscode-autohotkey-debug` extension
- Set breakpoints in VSCode
- Debug directly in the editor

#### SciTE4AutoHotkey
- Built-in debugging features
- Breakpoints, step execution, variable inspection
- Call stack viewing

### Debug Helper Scriptlet

The **AutoHotkey Debug Helper** provides:
- **📊 List Variables** - Shows all variables and values
- **📝 List Lines** - Shows recent execution
- **⌨️ Key History** - Shows input history
- **🔍 Script Analysis** - Analyzes script structure
- **💻 Command Line Debugging** - Runs scripts with debug flags
- **📋 Debug Logging** - Comprehensive logging system

**Hotkeys:**
- `Ctrl+Alt+D` - Open debug helper
- `F3` - List variables
- `Ctrl+Alt+V` - List lines  
- `Ctrl+Alt+K` - Key history

### Best Practices

1. **Use OutputDebug for logging** - Doesn't interrupt execution
2. **Add debug mode detection** - Enable/disable debugging via command line
3. **Log function entry/exit** - Track execution flow
4. **Use ListVars on errors** - Inspect variable states
5. **Add timestamps to logs** - Track timing issues
6. **Use try-catch with debug info** - Capture error context

### Example Integration

```ahk
class MCPConfigManager {
    static debugMode := false
    static debugLog := []
    
    static Init() {
        this.debugMode := A_Args.Length > 0 && A_Args[1] = "/debug"
        this.LogDebug("MCP Config Manager initialized" . (this.debugMode ? " in DEBUG mode" : ""))
    }
    
    static LogDebug(message) {
        if (this.debugMode) {
            timestamp := FormatTime(A_Now, "HH:mm:ss")
            logEntry := "[" . timestamp . "] " . message
            this.debugLog.Push(logEntry)
            OutputDebug(logEntry)
        }
    }
    
    static LoadConfig(*) {
        try {
            this.LogDebug("LoadConfig() called")
            
            if (!FileExist(this.claudeConfig)) {
                this.LogDebug("Config file not found: " . this.claudeConfig)
                ; Handle error...
            }
            
            this.LogDebug("Reading config file: " . this.claudeConfig)
            configContent := FileRead(this.claudeConfig)
            this.LogDebug("Config loaded successfully, size: " . StrLen(configContent) . " characters")
            
        } catch as e {
            this.LogDebug("LoadConfig error: " . e.Message)
            if (this.debugMode) {
                this.LogDebug("Error details - File: " . e.File . ", Line: " . e.Line)
                ListVars
                Pause
            }
            throw e
        }
    }
}
```

### Running with Debug Flags

```bash
# Debug the MCP Config Manager
AutoHotkey.exe /ErrorStdOut /NoTrayIcon scriptlets/mcp_config_manager.ahk /debug

# Debug with force reload
AutoHotkey.exe /Force scriptlets/claude_desktop_restart.ahk /debug
```

This comprehensive debugging approach provides:
- **Real-time logging** via OutputDebug
- **Variable inspection** via ListVars
- **Execution tracking** via ListLines
- **Error context** via try-catch with debug info
- **Command line control** via debug flags
- **Professional debugging tools** via the Debug Helper scriptlet




















