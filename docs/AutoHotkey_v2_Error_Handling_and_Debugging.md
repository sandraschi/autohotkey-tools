# AutoHotkey v2 Error Handling and Debugging Guide
## How to Avoid Going Insane While Debugging

### ⚠️ CRITICAL: Suppressing Error Popups

**Problem:** By default, AutoHotkey v2 shows error popup dialogs that BLOCK execution and make debugging impossible.

**Solution:** Use `OnError()` at the TOP of your script.

```autohotkey
#Requires AutoHotkey v2.0+
#SingleInstance Force

; MUST be at the very top before any code that might error
OnError("LogError")

LogError(Exception, Mode) {
    ; Exception object contains:
    ; .Message - the error message
    ; .Line - line number where error occurred
    ; .What - what threw the error
    ; .File - file path (if available)
    ; .Extra - additional error information
    
    ; Log to file with timestamp
    timestamp := FormatTime(A_Now, "yyyy-MM-dd HH:mm:ss")
    logEntry := "[" . timestamp . "] Error at line " . Exception.Line . ": " . Exception.Message . "`n"
    FileAppend(logEntry, "script_errors.log", "UTF-8")
    
    ; Return true to suppress popup
    ; Return false to show default popup
    return true
}

; Your code starts here...
```

**Key Points:**
- `OnError()` MUST be called at the top of your script
- The handler function MUST accept TWO parameters: `(Exception, Mode)`
- Return `true` to suppress the popup, `false` to show it
- Mode parameter is usually ignored but required in signature
- Exception has properties: `.Message`, `.Line`, `.What`, `.File`, `.Extra`

---

### 🔍 Debugging Strategies

#### 1. Use Structured Logging

Instead of just suppressing errors, create a comprehensive logging system:

```autohotkey
#Requires AutoHotkey v2.0+

OnError("ErrorHandler")

class Logger {
    static logFile := "debug.log"
    static enabled := true
    
    static Log(level, message) {
        if (!this.enabled) {
            return
        }
        
        timestamp := FormatTime(A_Now, "HH:mm:ss")
        logEntry := "[" . timestamp . "] [" . level . "] " . message . "`n"
        FileAppend(logEntry, this.logFile, "UTF-8")
    }
    
    static Debug(message) {
        this.Log("DEBUG", message)
    }
    
    static Info(message) {
        this.Log("INFO", message)
    }
    
    static Error(message) {
        this.Log("ERROR", message)
    }
}

ErrorHandler(Exception, Mode) {
    Logger.Error("Exception at line " . Exception.Line . ": " . Exception.Message)
    Logger.Error("File: " . Exception.File)
    Logger.Error("What: " . Exception.What)
    Logger.Error("Extra: " . Exception.Extra)
    return true  ; Suppress popup
}

; Usage in your code:
Logger.Debug("Starting initialization...")
Logger.Info("Configuration loaded")
Logger.Error("Failed to connect to server")
```

#### 2. Use OutputDebug for Real-Time Monitoring

OutputDebug sends output to AutoHotkey DebugView (sysinternals) or AHK_EXE console:

```autohotkey
OutputDebug("DEBUG: Starting function call")
OutputDebug("DEBUG: Variable value: " . myVar)
OutputDebug("DEBUG: Array length: " . myArray.Length)
```

To view OutputDebug messages:
- Download DebugView from Microsoft Sysinternals
- Run DebugView as administrator
- Filter for "AutoHotkey" processes
- See real-time debug output

#### 3. Create Debug Mode

Enable/disable debug logging based on command line parameter:

```autohotkey
#Requires AutoHotkey v2.0+

class ScriptName {
    static debugMode := false
    
    static Init() {
        ; Check for /debug parameter
        this.debugMode := A_Args.Length > 0 && A_Args[1] = "/debug"
        
        if (this.debugMode) {
            this.Log("Debug mode enabled")
        }
    }
    
    static Log(message) {
        if (this.debugMode) {
            timestamp := FormatTime(A_Now, "HH:mm:ss")
            logMessage := "[" . timestamp . "] " . message . "`n"
            FileAppend(logMessage, "debug.log", "UTF-8")
            OutputDebug(logMessage)
        }
    }
}

ScriptName.Init()
ScriptName.Log("Initialization complete")
```

Run with: `AutoHotkey.exe script.ahk /debug`

---

### 🚫 Common Error Popup Causes

#### 1. Missing Try-Catch Blocks

**Bad:**
```autohotkey
FileRead(fileContent, "nonexistent.txt")  ; Will show popup if file doesn't exist
```

**Good:**
```autohotkey
try {
    content := FileRead("nonexistent.txt")
} catch as e {
    Logger.Error("Failed to read file: " . e.Message)
    content := ""
}
```

#### 2. Empty Catch Blocks (v2 REQUIRES variable)

**Bad:**
```autohotkey
try {
    DoSomething()
} catch {  ; ERROR: v2 requires variable
    ; Ignore
}
```

**Good:**
```autohotkey
try {
    DoSomething()
} catch as unused {  ; CORRECT: Use 'unused' if you don't need the exception
    ; Ignore
}
```

**Also Good:**
```autohotkey
try {
    DoSomething()
} catch as e {
    ; Log or handle the error
    Logger.Error("Error in DoSomething: " . e.Message)
}
```

#### 3. Improper Variable Declaration

**Bad:**
```autohotkey
var = value  ; v1 syntax, causes error in v2
```

**Good:**
```autohotkey
var := "value"  ; v2 syntax
```

#### 4. Calling Non-Existent Methods

**Bad:**
```autohotkey
text.ToUpper()  ; DOES NOT EXIST in v2
text.ToLower()  ; DOES NOT EXIST in v2
```

**Good:**
```autohotkey
StrUpper(text)
StrLower(text)
```

---

### 🔧 Running Scripts Without Popups

#### Method 1: Use OnError (RECOMMENDED)

This is the BEST way to suppress popups:

```autohotkey
#Requires AutoHotkey v2.0+
#SingleInstance Force

OnError("LogError")

LogError(Exception, Mode) {
    FileAppend("ERROR: " . Exception.Message . " at line " . Exception.Line . "`n", "errors.log", "UTF-8")
    return true  ; Suppress popup
}

; Your script code
```

#### Method 2: Use /ErrorStdOut Flag (UNRELIABLE)

**Command Line:**
```powershell
AutoHotkey.exe '/ErrorStdOut' script.ahk
```

**Problems:**
- Doesn't always suppress popups for syntax errors
- Error output may not be captured properly
- Not reliable for all error types

**Recommendation:** Use OnError() instead.

---

### 🛠️ Debugging Workflow

#### Step 1: Add OnError Handler

```autohotkey
#Requires AutoHotkey v2.0+
#SingleInstance Force

OnError("ErrorHandler")

ErrorHandler(Exception, Mode) {
    ; Log to file
    FileAppend("ERROR: " . Exception.Message . " at line " . Exception.Line . "`n", "errors.log", "UTF-8")
    ; Log to OutputDebug
    OutputDebug("ERROR: " . Exception.Message . " at line " . Exception.Line)
    ; Return true to suppress popup
    return true
}

; Your code
```

#### Step 2: Add Debug Logging

```autohotkey
class YourClass {
    static debugMode := true
    
    static Log(level, message) {
        if (this.debugMode) {
            timestamp := FormatTime(A_Now, "HH:mm:ss")
            logMsg := "[" . timestamp . "] [" . level . "] " . message . "`n"
            FileAppend(logMsg, "debug.log", "UTF-8")
            OutputDebug(logMsg)
        }
    }
}

YourClass.Log("INFO", "Script starting")
YourClass.Log("DEBUG", "Variable value: " . myVar)
```

#### Step 3: Test Incrementally

```autohotkey
; Test one function at a time
static TestFunction() {
    Logger.Log("DEBUG", "Entering TestFunction")
    try {
        ; Your code here
        Logger.Log("DEBUG", "Function completed successfully")
    } catch as e {
        Logger.Log("ERROR", "Function failed: " . e.Message)
    }
}
```

#### Step 4: Check Log Files

```powershell
# View error log
Get-Content errors.log

# View debug log
Get-Content debug.log

# Follow logs in real-time
Get-Content debug.log -Wait
```

---

### 📋 Error Handling Checklist

Before running ANY script, verify:

- [ ] `OnError("HandlerName")` is called at the top
- [ ] Handler function accepts TWO parameters: `(Exception, Mode)`
- [ ] Handler returns `true` to suppress popup
- [ ] All file operations wrapped in try-catch
- [ ] All GUI operations wrapped in try-catch
- [ ] All system calls wrapped in try-catch
- [ ] No empty catch blocks (use `catch as unused`)
- [ ] All catch blocks have `as variable`
- [ ] Using correct v2 syntax (no v1 leftovers)

---

### 🎯 Quick Reference

#### OnError Signature (v2)

```autohotkey
OnError("HandlerName")

HandlerName(Exception, Mode) {
    ; Log error
    FileAppend(Exception.Message, "errors.log", "UTF-8")
    
    ; Return true to suppress popup
    return true
}
```

#### Try-Catch (v2)

```autohotkey
try {
    ; Code that might fail
    DoSomething()
} catch as e {
    ; Handle error
    Logger.Error("Failed: " . e.Message)
}
```

#### OutputDebug (Real-time Debugging)

```autohotkey
OutputDebug("Debug: Variable = " . myVar)
OutputDebug("Debug: Array length = " . arr.Length)
```

#### FileAppend Logging

```autohotkey
timestamp := FormatTime(A_Now, "HH:mm:ss")
logMsg := "[" . timestamp . "] " . message . "`n"
FileAppend(logMsg, "debug.log", "UTF-8")
```

---

### 💡 Pro Tips

1. **Always use OnError at the top** - Prevents popups from syntax errors during development

2. **Use OutputDebug liberally** - View in DebugView without cluttering the log file

3. **Create a Logger class** - Reusable logging across all scripts

4. **Test with /debug parameter** - Enable debug mode only when needed

5. **Wrap everything risky in try-catch** - File operations, GUI, network calls

6. **Log BEFORE operations** - "Attempting to read file..." then "File read successful"

7. **Check error logs BEFORE trying to run** - Read errors.log to see what failed

8. **Use meaningful log messages** - Include context, variable values, operation being performed

---

### 🚨 Emergency Debugging

If you're stuck with a popup that won't go away:

1. **Task Manager** - Kill AutoHotkey processes
2. **Check error log** - Read errors.log to see what failed
3. **Comment out sections** - Isolate the problem code
4. **Add more logging** - Log BEFORE each operation
5. **Test minimal examples** - Strip down to bare minimum

---

### 📝 Example: Complete Error Handling Template

```autohotkey
#Requires AutoHotkey v2.0+
#SingleInstance Force

; ==============================================================================
; Error Suppression - MUST be at top
; ==============================================================================
OnError("ErrorHandler")

ErrorHandler(Exception, Mode) {
    timestamp := FormatTime(A_Now, "yyyy-MM-dd HH:mm:ss")
    logEntry := "[" . timestamp . "] " . 
                "Line " . Exception.Line . ": " . 
                Exception.Message . 
                " (File: " . Exception.File . 
                ", What: " . Exception.What . ")`n"
    
    FileAppend(logEntry, "script_errors.log", "UTF-8")
    OutputDebug("ERROR: " . Exception.Message)
    
    return true  ; Suppress popup
}

; ==============================================================================
; Logger Class
; ==============================================================================
class Logger {
    static enabled := true
    static logFile := "debug.log"
    
    static Log(level, message) {
        if (!this.enabled) {
            return
        }
        
        timestamp := FormatTime(A_Now, "HH:mm:ss")
        logMsg := "[" . timestamp . "] [" . level . "] " . message . "`n"
        FileAppend(logMsg, this.logFile, "UTF-8")
        OutputDebug(logMsg)
    }
    
    static Debug(msg) { this.Log("DEBUG", msg) }
    static Info(msg) { this.Log("INFO", msg) }
    static Error(msg) { this.Log("ERROR", msg) }
}

; ==============================================================================
; Your Script Class
; ==============================================================================
class MyScript {
    static Init() {
        Logger.Debug("Script starting")
        
        try {
            this.DoSomething()
            Logger.Info("Initialization complete")
        } catch as e {
            Logger.Error("Failed to initialize: " . e.Message)
        }
    }
    
    static DoSomething() {
        Logger.Debug("Entering DoSomething")
        
        try {
            ; Your code here
            Logger.Debug("DoSomething completed")
        } catch as e {
            Logger.Error("DoSomething failed: " . e.Message)
            throw e  ; Re-throw if needed
        }
    }
}

; Initialize
MyScript.Init()
```

---

### 🎓 Key Takeaways

1. **OnError() is MANDATORY** - Without it, error popups will drive you insane
2. **Two parameters required** - `(Exception, Mode)` - don't forget Mode
3. **Return true to suppress** - The popup won't show if you return true
4. **Log everything** - FileAppend for persistence, OutputDebug for real-time
5. **Try-catch everything risky** - Never assume operations will succeed
6. **No empty catch blocks** - Always use `catch as unused`
7. **Test incrementally** - Don't write entire script then test
8. **Read the logs** - Errors are logged, so read them!

---

**Remember:** The goal is to catch errors EARLY and log them CLEARLY, so you can fix them QUICKLY without losing your sanity. 🧠💪

