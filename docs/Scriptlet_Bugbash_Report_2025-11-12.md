# Scriptlet Bugbash Report (2025-11-12)

## Overview
- **Runner**: `utils/scriptlet_bugbash.ps1`
- **Command**: `./utils/scriptlet_bugbash.ps1 -TimeoutSeconds 20 -Throttle 1`
- **AutoHotkey**: `C:\Program Files\AutoHotkey\v2\AutoHotkey.exe` (2.0.19)
- **Inventory**: `logs/bugbash/inventory_20251112_200949.json`
- **Summary**: `logs/bugbash/summary_20251112_200949.json`
- **Log Folder**: `logs/bugbash/logs_20251112_200949/`

## Aggregate Results
- **Total Scriptlets Executed**: 75 (AutoHotkey v1 backups and `.bak` files excluded)
- **Completed Cleanly**: 9
- **Completed with Errors**: 50
- **Timeouts (hard-killed after 20s)**: 16
- **Average Runtime**: < 1s (fast failures; long-running items forced to exit at 20s)

## Representative Outcomes
- ✅ `macro_recorder_pro.ahk`, `ollama_chatbot_no_com.ahk`, `test_video_minimal2.ahk` exited cleanly (0 exit code, no stderr).
- ⚠️ Object literal syntax failures (missing property labels) across multiple scripts:
  - `action_automation_builder.ahk (line 133)`
  - `action_automation_builder_temp.ahk (line 127)`
  - `ai_code_assistant.ahk (line 270)`
- ⏱️ Long-running GUI helpers exceeded the 20s limit and were force-terminated, e.g. `autohotkey_debug_helper.ahk`.

## Error Themes
1. **Object Literal Syntax** (`Missing "propertyname:" in object literal`) – 30+ files still include v1-style literal blocks.
2. **Random/loop syntax** – Several logs show `Specifically: Random}}` or `Specifically: SysGet}}`, indicating residual v1 command syntax inside nested objects.
3. **Timeouts** – GUI-centric utilities and monitors remain resident and require graceful shutdown logic (send `Esc`/`F9`) before fallback to kill.

## Artifacts
- Per-script logs: `logs/bugbash/logs_20251112_200949/<script>_20251112_200949.log`
- Summary JSON: breakdown by script with PID, exit code, status, duration, termination method.
- Inventory JSON: enumerates exact files processed in this run.

## Next Actions
1. **Syntax Fixes**: Prioritize the object literal / Random / SysGet issues flagged in the stderr logs.
2. **Timeout Handling**: Add graceful shutdown handlers (Esc/F9) into long-running GUIs so they exit cleanly under automation.
3. **Re-run Harness**: After targeted fixes, rerun the bugbash (full or category subset) and compare against the original summary.
4. **Tracking**: Log follow-up tasks per failing script (consider `notes/` entries or todo list) with direct links to log files.

## Reproduction Notes
- Ensure the working directory is repository root: `Set-Location D:\Dev\repos\autohotkey-test`.
- AutoHotkey must be accessible on PATH or passed via `-AutoHotkeyPath`.
- Adjust `-TimeoutSeconds` and `-Throttle` as needed; default throttle is sequential to avoid hotkey collisions.
- Harness writes a fresh inventory each run unless `-SkipInventory` is specified.
