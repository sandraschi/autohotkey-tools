# Repository Health Improvement Plan
**Created**: 2025-01-XX  
**Current Status**: POOR (11/75 scriptlets passing - 15%)  
**Target**: GOOD (70+/75 scriptlets passing - 93%+)

## 🎯 Executive Summary

The repository currently has **64 failing scriptlets** out of 75 tested. This plan provides a systematic approach to fix the most common issues and improve repository health from **POOR** to **GOOD** within 2-3 weeks.

## 📊 Current Failure Breakdown

- **11 scriptlets passing** (15%) ✅
- **38 scriptlets crashing** (51%) ❌ - Syntax errors, missing functions
- **26 scriptlets timing out** (35%) ⏱️ - GUIs that don't exit, infinite loops

## 🔧 Priority Fix Categories

### Category 1: Syntax Errors (38 crashes) - **HIGHEST PRIORITY**

#### 1.1 Invalid Object Literals
**Problem**: Using v1-style object syntax or incorrect v2 object literals
**Fix Pattern**:
```autohotkey
# WRONG (v1 or broken v2):
obj := {key: value}
obj := {key = value}

# CORRECT (v2):
obj := Map("key", "value")
obj := {key: "value"}  ; Only if value is literal
```

**Action**: Search for `{.*:` patterns and convert to proper v2 syntax

#### 1.2 JSON.parse() Calls
**Problem**: `JSON.parse()` doesn't exist in AutoHotkey v2
**Fix Pattern**:
```autohotkey
# WRONG:
data := JSON.parse(jsonString)

# CORRECT:
data := JSON.Load(jsonString)  ; Requires JSON.ahk library
# OR use built-in:
data := Map()  ; Parse manually or use library
```

**Action**: Replace all `JSON.parse()` with `JSON.Load()` or manual parsing

#### 1.3 Block Arrow Functions
**Problem**: Arrow functions with blocks `(*) => { code }` causing object literal errors
**Fix Pattern**:
```autohotkey
# WRONG:
Hotkey("F1", (*) => {
    DoSomething()
})

# CORRECT:
Hotkey("F1", DoSomething)
# OR:
Hotkey("F1", (*) => DoSomething())
```

**Action**: Convert all block arrow functions to named functions or single-expression arrows

#### 1.4 SetTimer Label Syntax
**Problem**: Using v1 `SetTimer LabelName` instead of v2 function references
**Fix Pattern**:
```autohotkey
# WRONG:
SetTimer UpdateStatus, 1000

# CORRECT:
SetTimer(UpdateStatus, 1000)
```

**Action**: Convert all `SetTimer` calls to function syntax

### Category 2: Timeout Issues (26 timeouts) - **HIGH PRIORITY**

#### 2.1 GUIs Without Exit Routes
**Problem**: GUIs that don't close properly, no Escape key handler
**Fix Pattern**:
```autohotkey
# ADD TO EVERY GUI:
gui.OnEvent("Close", (*) => ExitApp())
gui.OnEvent("Escape", (*) => ExitApp())

# OR add Escape hotkey:
Hotkey("Escape", (*) => gui.Destroy())
```

**Action**: Add Escape/Close handlers to all GUI scriptlets

#### 2.2 Timers Never Stopped
**Problem**: `SetTimer` calls without cleanup
**Fix Pattern**:
```autohotkey
# ADD Cleanup:
class MyScriptlet {
    static timerId := 0
    
    static Stop() {
        if (this.timerId) {
            SetTimer(this.timerId, 0)  ; Stop timer
            this.timerId := 0
        }
    }
    
    static OnExit() {
        this.Stop()
    }
}

OnExit(MyScriptlet.OnExit)
```

**Action**: Add `Stop()` methods and cleanup to all scriptlets with timers

#### 2.3 Hotkeys Never Removed
**Problem**: Hotkeys registered but never cleaned up
**Fix Pattern**:
```autohotkey
# ADD Cleanup:
class MyScriptlet {
    static hotkeys := []
    
    static Init() {
        hk := Hotkey("F1", (*) => this.DoSomething())
        this.hotkeys.Push(hk)
    }
    
    static Stop() {
        for hk in this.hotkeys {
            try Hotkey(hk, "Off")
        }
        this.hotkeys := []
    }
}
```

**Action**: Track and cleanup all registered hotkeys

### Category 3: Configuration Debt - **MEDIUM PRIORITY**

#### 3.1 Hard-coded Paths
**Problem**: Paths like `D:\Dev\...` and `C:\Program Files\...` hard-coded everywhere
**Solution**: Create `ConfigManager.ahk` utility

**Implementation**:
```autohotkey
class ConfigManager {
    static GetAutoHotkeyPath() {
        ; Try common locations
        paths := [
            A_ProgramFiles "\AutoHotkey\v2\AutoHotkey.exe",
            A_ProgramFiles "\AutoHotkey\AutoHotkey.exe",
            "C:\Program Files\AutoHotkey\v2\AutoHotkey.exe"
        ]
        for path in paths {
            if (FileExist(path))
                return path
        }
        return "AutoHotkey.exe"  ; Fallback to PATH
    }
    
    static GetScriptletsDir() {
        return A_ScriptDir "\scriptlets"
    }
}
```

**Action**: Replace all hard-coded paths with `ConfigManager` calls

## 📋 2-Week Action Plan

### Week 1: Fix Syntax Errors (Target: 20 scriptlets)

**Day 1-2: Object Literals & JSON.parse**
- [ ] Search for all `JSON.parse()` calls → Replace with `JSON.Load()`
- [ ] Fix invalid object literals (10 scriptlets)
- [ ] Test fixes with linter
- [ ] Run bugbash on fixed scriptlets

**Day 3-4: Arrow Functions & SetTimer**
- [ ] Convert block arrow functions to named functions (10 scriptlets)
- [ ] Fix `SetTimer` label syntax → function syntax
- [ ] Test fixes
- [ ] Run bugbash

**Day 5: Validation**
- [ ] Re-run full bugbash
- [ ] Document progress
- [ ] Update status report

### Week 2: Fix Timeouts (Target: 20 scriptlets)

**Day 1-2: GUI Exit Routes**
- [ ] Add Escape/Close handlers to GUI scriptlets (10 scriptlets)
- [ ] Test GUI exit behavior
- [ ] Run bugbash

**Day 3-4: Timer & Hotkey Cleanup**
- [ ] Add `Stop()` methods to scriptlets with timers (10 scriptlets)
- [ ] Add hotkey cleanup
- [ ] Test cleanup behavior
- [ ] Run bugbash

**Day 5: Configuration & Final Validation**
- [ ] Create `ConfigManager.ahk`
- [ ] Replace hard-coded paths in 5 high-priority scriptlets
- [ ] Full bugbash run
- [ ] Update documentation

## 🛠️ Quick Fix Scripts

### Script 1: Find All JSON.parse() Calls
```powershell
# Run in PowerShell:
Get-ChildItem -Path scriptlets -Filter *.ahk -Recurse | Select-String "JSON\.parse" | Select-Object Path, LineNumber, Line
```

### Script 2: Find All Block Arrow Functions
```powershell
Get-ChildItem -Path scriptlets -Filter *.ahk -Recurse | Select-String "\(\*\)\s*=>\s*\{" | Select-Object Path, LineNumber, Line
```

### Script 3: Find All SetTimer Label Syntax
```powershell
Get-ChildItem -Path scriptlets -Filter *.ahk -Recurse | Select-String "SetTimer\s+\w+," | Select-Object Path, LineNumber, Line
```

### Script 4: Find GUIs Without Escape Handlers
```powershell
Get-ChildItem -Path scriptlets -Filter *.ahk -Recurse | Select-String "Gui\(\)" | Select-Object Path, LineNumber, Line
# Then manually check each for OnEvent("Escape")
```

## 📈 Success Metrics

### Target Goals (2-3 weeks)
- **Week 1 End**: 30+ scriptlets passing (40%+)
- **Week 2 End**: 50+ scriptlets passing (67%+)
- **Week 3 End**: 70+ scriptlets passing (93%+) → **GOOD** health

### Progress Tracking
- Run bugbash after each batch of fixes
- Track in `logs/bugbash/summary_YYYYMMDD_HHMMSS.json`
- Update status report weekly
- Document fixes in CHANGELOG.md

## 🎯 Quick Wins (Do First)

These fixes will have the biggest impact:

1. **Add Escape handlers to all GUIs** (Fixes ~15 timeouts quickly)
   - Search: `gui := Gui()`
   - Add: `gui.OnEvent("Escape", (*) => ExitApp())`

2. **Fix JSON.parse() calls** (Fixes ~10 crashes quickly)
   - Search: `JSON.parse`
   - Replace: `JSON.Load()` or manual parsing

3. **Fix SetTimer syntax** (Fixes ~8 crashes quickly)
   - Search: `SetTimer LabelName,`
   - Replace: `SetTimer(LabelName,`

4. **Convert block arrow functions** (Fixes ~5 crashes quickly)
   - Search: `(*) => {`
   - Replace: Named functions or single-expression arrows

## 📝 Fix Template

Use this template for each scriptlet fix:

```autohotkey
#Requires AutoHotkey v2.0+
#SingleInstance Force

; ==============================================================================
; Scriptlet Name
; @name: Scriptlet Name
; @version: 1.0.0
; @description: Brief description
; ==============================================================================

class ScriptletName {
    static gui := ""
    static timerId := 0
    
    static Init() {
        ; Initialize scriptlet
    }
    
    static Run() {
        ; Main execution
        this.CreateGUI()
    }
    
    static CreateGUI() {
        this.gui := Gui()
        ; ... GUI setup ...
        
        ; REQUIRED: Add exit handlers
        this.gui.OnEvent("Close", (*) => this.Stop())
        this.gui.OnEvent("Escape", (*) => this.Stop())
        
        this.gui.Show()
    }
    
    static Stop() {
        ; REQUIRED: Cleanup
        if (this.timerId) {
            SetTimer(this.timerId, 0)
            this.timerId := 0
        }
        if (this.gui) {
            this.gui.Destroy()
            this.gui := ""
        }
    }
}

; REQUIRED: Register exit handler
OnExit((*) => ScriptletName.Stop())

; Initialize
ScriptletName.Init()
```

## ✅ Definition of Done

A scriptlet is "fixed" when:
- ✅ Passes linter with zero errors
- ✅ Runs without crashing (tested with `/ErrorStdOut`)
- ✅ Exits cleanly within 5 seconds (no timeout)
- ✅ Has proper error handling
- ✅ Has cleanup logic (timers, hotkeys, GUIs)
- ✅ Uses v2 syntax throughout
- ✅ No hard-coded paths (or uses ConfigManager)

## 🚀 Getting Started

1. **Run initial bugbash** to get baseline:
   ```powershell
   .\utils\batch_debugger.ps1
   ```

2. **Pick a category** (syntax errors or timeouts)

3. **Fix 5-10 scriptlets** using the patterns above

4. **Test fixes**:
   ```powershell
   AutoHotkey.exe '/ErrorStdOut' scriptlets\fixed_scriptlet.ahk
   ```

5. **Re-run bugbash** to measure progress

6. **Document fixes** in CHANGELOG.md

## 📚 Reference Documentation

- [Complete V1 to V2 Migration Guide](Complete_V1_to_V2_Migration_Guide.md)
- [AutoHotkey v2 Syntax Reference](AutoHotkey_v2_Syntax_Reference.md)
- [Repository Status Report](Repository_Status_Report.md)
- [Development Guide](DEVELOPMENT_GUIDE.md)

---

**Next Steps**: Start with Quick Wins, then follow the 2-week plan systematically.

