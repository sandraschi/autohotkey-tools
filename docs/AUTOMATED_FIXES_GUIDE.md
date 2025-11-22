# Automated Fix Scripts Guide

## Overview

Automated PowerShell scripts to fix common AutoHotkey v2 syntax issues across all scriptlets.

## Available Fix Scripts

### 1. `fix_gui_escape_handlers.ps1`
**Purpose**: Adds Escape and Close event handlers to GUIs missing them.

**What it fixes**:
- GUIs without `OnEvent("Close")` handlers
- GUIs without `OnEvent("Escape")` handlers
- Adds proper cleanup handlers before `gui.Show()` calls

**Usage**:
```powershell
.\utils\fix_gui_escape_handlers.ps1
```

### 2. `fix_missing_stop_methods.ps1`
**Purpose**: Adds `Stop()` cleanup methods to classes with GUIs.

**What it fixes**:
- Classes with GUIs but no cleanup method
- Adds `Stop()` method to destroy GUIs properly

**Usage**:
```powershell
.\utils\fix_missing_stop_methods.ps1
```

### 3. `fix_settimer_syntax.ps1`
**Purpose**: Converts v1-style SetTimer syntax to v2 function syntax.

**What it fixes**:
- `SetTimer LabelName, interval` → `SetTimer(LabelName, interval)`
- `SetTimer, LabelName, interval` → `SetTimer(LabelName, interval)`
- `SetTimer LabelName` → `SetTimer(LabelName, 0)`

**Usage**:
```powershell
.\utils\fix_settimer_syntax.ps1
```

### 4. `fix_on_exit_handlers.ps1`
**Purpose**: Adds OnExit handlers for proper cleanup on script termination.

**What it fixes**:
- Scriptlets with GUIs/timers but no OnExit handler
- Adds `OnExit((*) => ClassName.Stop())` before Init() calls

**Usage**:
```powershell
.\utils\fix_on_exit_handlers.ps1
```

### 5. `run_all_fixes.ps1` (Master Script)
**Purpose**: Runs all fix scripts in sequence.

**Usage**:
```powershell
# Dry run (preview changes)
.\utils\run_all_fixes.ps1 -DryRun

# Apply all fixes
.\utils\run_all_fixes.ps1
```

## Safety Features

1. **Automatic Backups**: All scripts create `.bak` backup files before making changes
2. **Dry Run Mode**: Test what would be changed without applying fixes
3. **Error Reporting**: Scripts report which files were fixed and any errors

## Workflow

### Recommended Fix Order

1. **Run all fixes**:
   ```powershell
   .\utils\run_all_fixes.ps1
   ```

2. **Test the fixes**:
   ```powershell
   .\utils\batch_debugger.ps1
   ```

3. **Review changes**:
   - Check `.bak` files if you need to revert
   - Review git diff to see what changed

4. **Run linter**:
   ```powershell
   .\utils\linter.ahk scriptlets\your_scriptlet.ahk
   ```

## Limitations

These scripts fix **common patterns** but may not catch:
- Complex object literal issues
- Block arrow function problems (needs manual review)
- Custom error handling patterns
- Edge cases in GUI creation

## Manual Review Still Needed

After running automated fixes, manually review:
1. Object literal syntax (especially nested objects)
2. Block arrow functions causing errors
3. Custom error handling
4. Complex GUI setups

## Example Output

```
========================================
AutoHotkey Scriptlet Automated Fixes
========================================

Total scriptlets found: 75

Running: fix_gui_escape_handlers.ps1
----------------------------------------
Scanning for GUIs without Escape handlers...
Fixed: text_transformer_pro.ahk
Fixed: git_assistant_pro.ahk
Fixed: corporate_pranks.ahk

Summary:
  Fixed: 3 files
  Skipped: 40 files (already have handlers)

Running: fix_missing_stop_methods.ps1
----------------------------------------
...
```

## Troubleshooting

### Scripts Don't Run
- Ensure PowerShell execution policy allows scripts:
  ```powershell
  Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
  ```

### Too Many Changes
- Review `.bak` files to see what changed
- Use git to see diffs: `git diff scriptlets/`

### Need to Revert
- Restore from `.bak` files:
  ```powershell
  Get-ChildItem scriptlets -Filter *.bak -Recurse | ForEach-Object {
      $original = $_.FullName -replace '\.bak$', ''
      Copy-Item $_.FullName $original -Force
  }
  ```

## Next Steps After Fixes

1. Run bugbash to measure improvement
2. Fix remaining issues manually
3. Update documentation
4. Commit fixes with clear messages

