# AutoHotkey Test - General Rules

## Rule #1: Check Central Documentation First

**BEFORE making any changes, ALWAYS check:**
- **Central Docs:** `D:\Dev\repos\mcp-central-docs\`
- **AutoHotkey Docs:** `mcp-central-docs/autohotkey/`
- **V2 Migration Guide:** `mcp-central-docs/autohotkey/Complete_V1_to_V2_Migration_Guide.md`

## Rule #2: Shell Context for Multi-Workspace

When switching to work on this repo in a multi-workspace setup:
1. Start a fresh shell (don't reuse terminals from other repos)
2. Always `cd D:\Dev\repos\autohotkey-test` as the first command
3. Verify `Get-Location` shows correct directory before running other commands

## Rule #3: PowerShell Only (Windows)

**NEVER use Linux syntax:**
- ❌ `&&`, `||`, `ls`, `cat`, `grep`, `rm -rf`
- ✅ Use PowerShell: `Get-ChildItem`, `Get-Content`, `Select-String`, `Remove-Item -Recurse -Force`

## AutoHotkey v2-Specific

**ALWAYS use AutoHotkey v2 syntax:**
- ❌ `MsgBox, text` (v1)
- ✅ `MsgBox("text")` (v2)
- ❌ `var = value` (v1)
- ✅ `var := "value"` (v2)

See `mcp-central-docs/autohotkey/` for complete v2 syntax reference.

