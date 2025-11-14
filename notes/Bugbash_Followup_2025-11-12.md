# Bugbash Follow-up (2025-11-12)

## Summary
The automated bugbash harness (`utils/scriptlet_bugbash.ps1`) executed 75 AutoHotkey v2 scriptlets with a 20-second timeout per run. Result breakdown:
- **Latest Run (2025-11-13 04:13)**: 11 clean, 38 with errors, 26 timeouts (`logs/bugbash/summary_20251113_041354.json`).
- Previous snapshot (2025-11-12 21:19): 11 clean, 39 errors, 25 timeouts (see `summary_20251112_211908.json`).

Key log artifacts:
- Summaries: `logs/bugbash/summary_20251112_211908.json`, `logs/bugbash/summary_20251113_041354.json`
- Per-script logs: `logs/bugbash/logs_20251112_211908/`, `logs/bugbash/logs_20251113_041354/`

## High-Priority Issues
1. **Object literal syntax failures**
   - Examples: `action_automation_builder.ahk`, `ai_code_assistant.ahk`, `action_automationführer_builder_temp.ahk`
   - Error: `Missing "propertyname:" in object literal` (v1-style associative literals still present).
2. **Legacy command syntax inside structures**
   - Logs showing `Specifically: Random`, `Specifically: SysGet`, `Specifically: TrayTip` indicate residual v1 commands in object literals/expressions.
3. **Long-running GUIs timing out**
   - Scripts such as `autohotkey_debug_helper.ahk` exceed the 20s timeout, implying no auto-exit logic when run headless.

## Recommended Remediation Steps
- Refactor object literals to compliant v2 syntax (`{ key: value }`) across the flagged scriptlets.
- Replace remaining command syntax with function equivalents (`Random(value, min, max)`, `SysGet(outputVar, ...)`, `TrayTip()` etc.).
- Add graceful shutdown handlers (e.g., respond to `Esc`/`F9`) so GUI utilities exit cleanly when triggered by the harness before the forced kill.
- After targeted fixes, rerun the harness (full sweep or filtered subset via `-CategoryFilter`) and compare results to the 2025-11-12 baseline.

## Next Steps
- Track remediation tasks per scriptlet (todo entries) referencing the corresponding log file.
- Schedule a follow-up bugbash once the high-priority fixes land.
- Consider extending the harness with category tags and graceful-stop hooks for eigen testing.
