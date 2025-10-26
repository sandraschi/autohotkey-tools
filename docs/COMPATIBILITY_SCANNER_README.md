# AutoHotkey v2 Compatibility Scanner

## Overview

The Compatibility Scanner checks all AutoHotkey scripts for 2 critical incompatibilities:

1. **v1 Syntax Patterns** - Detects AutoHotkey v1 syntax that is incompatible with v2
2. **Missing v2 Requirements** - Identifies missing v2 requirements like error handling and proper structure

## Quick Start

### Windows PowerShell (Recommended)
```powershell
.\run_compatibility_scan.ps1
```

### Windows Batch File (Simple)
```batch
run_compatibility_scan.bat
```

### Direct Execution
```powershell
autohotkey.exe utils\compatibility_scanner.ahk
```

## What Gets Scanned

### Pattern 1: v1 Syntax Incompatibilities (15 patterns)

The scanner checks for these v1 syntax patterns that are incompatible with v2:

1. **FormatTime** - Missing first parameter
2. **FileRead** - v1 command syntax instead of v2 function syntax
3. **MsgBox** - v1 command syntax instead of v2 function syntax
4. **Hotkeys** - v1 syntax (`key::`) instead of v2 (`Hotkey()`)
5. **For Loops** - Using `to` instead of `..`
6. **Random** - v1 syntax instead of v2 function
7. **GUI Commands** - v1 Gui commands instead of v2 methods
8. **String Functions** - v1 String functions instead of v2 Str functions
9. **Loop Command** - v1 Loop syntax
10. **SetWorkingDir** - v1 command syntax
11. **Variable Assignment** - Using `=` instead of `:=`

### Pattern 2: Missing v2 Requirements (5 checks)

The scanner checks for missing v2 best practices:

1. **#Requires Directive** - Missing v2.0 requirement
2. **Class Structure** - No class definition found
3. **Init Method** - Missing static Init() method
4. **Error Handling** - No try/catch blocks
5. **Logging** - No AppendLog() method

## Report Output

The scanner generates a detailed report saved to:
```
compatibility_scan_report.txt
```

### Report Contents

- Files scanned count
- Total issues found
- Issues grouped by file
- Summary by category
- Detailed line-by-line errors

### Example Report Structure

```
================================================================================
AutoHotkey v2 Compatibility Scan Report
================================================================================
Scan Date: 2024-01-15 14:30:00
Directory Scanned: D:\Dev\repos\autohotkey-test\scriptlets
Files Scanned: 84
Issues Found: 12
================================================================================

[File Path]
Issues found: 5
--------------------------------------------------------------------------------
  Line 45 [ERROR] FormatTime missing first parameter (v1 syntax)
  Line 89 [ERROR] FileRead using v1 syntax
  Line 102 [WARNING] No error handling found
  Line 203 [WARNING] No class definition found
  Total: 2 errors, 3 warnings

================================================================================
SUMMARY BY CATEGORY
================================================================================
Total Errors: 2
Total Warnings: 3
v1 Syntax Issues: 2
v2 Requirement Issues: 3
```

## Integration

### Pre-commit Hook

Add to your git hooks:
```powershell
# .git/hooks/pre-commit
.\run_compatibility_scan.ps1
```

### CI/CD Integration

```powershell
# In your CI pipeline
& .\run_compatibility_scan.ps1
if ($LASTEXITCODE -ne 0) {
    Write-Error "Compatibility scan failed"
    exit 1
}
```

## Customization

### Adjust Scan Directory

Edit the scanner script:
```autohotkey
static scanDir := A_ScriptDir . "\scriptlets"  ; Change this line
```

### Add Custom Patterns

Add to the `v1Patterns` array in the scanner:
```autohotkey
static v1Patterns := [
    ; ... existing patterns ...
    {pattern: "YourPatternHere",
     message: "Your custom message",
     severity: "ERROR",
     category: "v1 syntax"}
]
```

## Understanding Results

### Severity Levels

- **ERROR**: Critical issue that will cause script failure
- **WARNING**: Best practice violation that should be fixed
- **SUGGESTION**: Optional improvement

### Category Types

- **v1 syntax**: Incompatible v1 syntax pattern
- **v2 requirements**: Missing v2 best practices

## Troubleshooting

### Scanner Not Found

If you get "File not found" errors:
1. Ensure you're running from the repo root
2. Check that `utils/compatibility_scanner.ahk` exists
3. Verify AutoHotkey v2 is installed

### No Results

If no issues are reported:
1. Check that scriptlets exist in the target directory
2. Verify files have `.ahk` extension
3. Check file permissions

### False Positives

Some patterns may trigger incorrectly:
1. Review the specific line in context
2. Adjust pattern regex if needed
3. Consider adding exceptions for specific cases

## Best Practices

1. **Run Before Commits** - Scan all scripts before committing
2. **Fix Errors First** - Address ERROR level issues before warnings
3. **Review Warnings** - Check if WARNING level issues are intentional
4. **Keep Updated** - Update patterns as needed for your codebase

## Related Tools

- **Linter**: `utils/linter.ahk` - General syntax checking
- **Test Framework**: `tests/unit_tests.ahk` - Unit testing
- **Batch Linter**: `utils/batch_linter.ahk` - Batch processing

## Contributing

To improve the scanner:

1. Add new patterns to detect common issues
2. Enhance reporting with better categorization
3. Add auto-fix capabilities for simple issues
4. Improve pattern matching accuracy

## License

See main repository LICENSE file.
