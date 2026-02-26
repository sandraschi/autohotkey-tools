# Repository Status Report

**Date:** 2025-11-28
**Scope:** AutoHotkey (`.ahk`) scripts in `d:\Dev\repos\autohotkey-test`

## Executive Summary
The repository contains a mix of AutoHotkey v1 and v2 scripts. The custom linter identified significant compliance issues, particularly with legacy v1 syntax in the `AutoHotkeyDocs` directory and some v2 syntax errors in `scriptlet_launcher_v2.ahk`.

## Linter Statistics
- **Total Files Scanned:** ~100+ (based on file list)
- **Files with Errors:** Many (see details below)
- **Common Issues:**
    - Missing `#Requires AutoHotkey v2.0` directive
    - Legacy `Gui` command usage (should be `Gui()` object)
    - Legacy `Loop` syntax
    - Incorrect `Random` function usage
    - Global variable usage

## Key Issues Identified

### 1. v2 Compliance
Many scripts, especially in `AutoHotkeyDocs/docs/scripts/`, are missing the `#Requires AutoHotkey v2.0` directive. This makes it unclear which version they are intended for, but the syntax suggests they are largely v1 scripts that need migration.

### 2. Syntax Errors
- **`scriptlet_launcher_v2.ahk`**:
    - **Critical**: Incorrect `Random()` syntax. Using `Random(&var, min, max)` (v1 style) instead of `var := Random(min, max)` (v2 style).
    - **Critical**: Legacy `Gui` commands found.
- **`AutoHotkeyDocs` Scripts**:
    - Widespread use of v1 `Gui`, `GuiControl`, `MsgBox` (command style), and `Loop,` syntax.

### 3. Best Practices
- **Global Variables**: Extensive use of global variables in `launcher.ahk` and `launcher_v2.ahk`.
- **Structure**: Many scripts lack a class-based structure or an `Init()` method, which is recommended for the scriptlet architecture.
- **Error Handling**: Missing `try/catch` blocks around file operations.

## Recommendations
1. **Fix `scriptlet_launcher_v2.ahk`**: This appears to be a core file. The `Random` function calls and `Gui` commands must be updated to v2 syntax immediately.
2. **Migrate `AutoHotkeyDocs`**: Decide if these scripts should be migrated to v2 or excluded from v2 linting. If they are examples, they should likely be updated.
3. **Refactor for Safety**: Introduce `try/catch` blocks for file I/O and reduce global variable usage by encapsulating logic in classes.

## Next Steps
- [ ] Fix critical syntax errors in `scriptlet_launcher_v2.ahk`.
- [ ] Update `AutoHotkeyDocs` scripts to v2 or move them to a v1 archive.
- [ ] Implement class-based structure for larger scripts.
