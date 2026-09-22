# autohotkey-test — Project Assessment

**Category**: Other Project (AutoHotkey v2 scriptlet depot + PowerShell HTTP bridge — not a FastMCP server; MCP-server-specific criteria like MCPB packaging and tool-surface scoring do not apply)
**Assessment Date**: 2026-09-22
**Status**: Working, actively maintained — supersedes [OBSOLETE_ASSESSMENT_2026-01-01.md](OBSOLETE_ASSESSMENT_2026-01-01.md), which was 9 months stale and described a state ("Runt", "No standards compliance detected") that no longer matches reality.

---

## What this repo actually is

A depot of ~64 AutoHotkey v2 scriptlets (`scriptlets/`) — clipboard/window/media utilities, games, pranks, dev-workflow tools — served through `ScriptletCOMBridge.ahk`, a PowerShell-`HttpListener`-backed HTTP bridge on port **10764** (`/status`, `/scriptlets`, `/run/{id}`, `/stop/{id}`, `/dashboard`), fronted by a static `dashboard.html` that live-queries `/scriptlets`. `ahk-linter` (sibling repo) provides AST-based v1→v2 lint checks with auto-fix.

## 📊 Assessment Summary

| Metric | Value |
|--------|-------|
| **Status** | Working / maintained |
| **Has Git Repository** | True |
| **Has Proper Structure** | Yes for what it is — `scriptlets/`, `tests/`, `scripts/`, `utils/`, `.gitignore` all present and used |
| **Has MCPB Packaging** | N/A — not a Claude Desktop MCP server |
| **Has CI/CD Pipeline** | False — still a real gap |
| **Has Monitoring Stack** | False — not applicable at this scale, low priority |
| **Scriptlet catalog** | 63 registered in `metadata.json` (was 43 before 2026-09-22) |
| **Depot bridge** | Working, verified live on :10764 as of 2026-09-22 |

## 🎯 2026-09-22 work log (today)

- Audited all 111 files in `scriptlets/` against `metadata.json` (the real catalog source of truth). Deleted 4 zero-byte junk files, a confirmed-dead `ollama_chatbot_v3.ahk` stub, one byte-identical duplicate; truncated a 27.7MB `crash.log`. Archived 11 test/debug scratch files and 3 superseded draft versions to `scriptlets/_archive/` via `git mv` (history preserved).
- Fixed a real runtime bug found while linting: `windows_cleanup_robot.ahk` used dead AHK v1 command syntax (`DriveGet, var, ...`) that would throw at runtime — converted to v2 function syntax.
- `ahk-lint --fix` pass on 20 files (whitespace/line-length), `.bak` safety copies via the linter's own `--backup` flag (gitignored).
- Registered 21 previously-orphaned tools into `metadata.json` (43 → 63 plugins net: +21 registrations, -1 broken entry removed — see below), including `office365_automation.ahk` (40KB, the largest file in the depot) and `ScriptletLauncher.ahk` itself, none of which had ever been wired into the catalog. Added an `automation` category and metadata headers to the 4 files that lacked one.
- Fixed two broken catalog entries: `weather_widget` (registered, but no v2 file exists — only an unmigrated `v1/weather_widget.ahk` needing an API key that was never configured; deregistered rather than leaving a dead entry) and `classic_pranks_collection` (key didn't match its actual file `classic_pranks.ahk`; renamed, and fixed its category from the invalid `"pranks"` to `"fun"`).
- **`ScriptletCOMBridge.ahk`**: the `/scriptlets` endpoint does a live recursive directory scan (not a `metadata.json` read) and already excluded `v1/` and `lib/`, but not the new `_archive/` — fixed, so archived scriptlets no longer appear as launchable in the dashboard.
- **`ScriptletCOMBridge.ahk`**: found the bridge's actual `HttpListener` still hardcoded to port **10744** internally (`$port = 10744`, plus 5 more references in port-cleanup/health-check/exit calls), even though the external-facing port migration to 10764 (commit `122b1c0`, per `WEBAPP_PORTS.md`) had updated `dashboard.html` and `start_dashboard.ps1`. Port 10744 now belongs to `openclaw-molt-mcp`'s webapp frontend — this was a live collision risk. Fixed all 6 internal references; killed the stale detached `powershell.exe` listener process still bound to 10744; verified `/status` and `/scriptlets` both respond correctly on 10764.

## 📋 Real, currently-open gaps

- 🟡 **No CI/CD pipeline** — genuinely absent, would catch AHK v1-syntax regressions like the `DriveGet` bug automatically via `ahk-lint` in a GitHub Action.
- 🟡 **`fleet-start.config.ps1` vs `start.ps1` are out of sync** (pre-existing, uncommitted at time of writing) — `start.ps1` gained a new "standalone fallback" mode with `Kind`: `module-serve`/`cli-serve`/uvicorn dispatch, but has no case for this repo's actual backend (`Kind = 'custom'` running `Start-ScriptletBridge.ps1`). `fleet-start.config.ps1` was mid-edited to `Kind = 'module-serve', Module = 'autohotkey_test'`, which points at a Python module that doesn't exist — this repo has no Python backend. Needs either a `custom` case added to `start.ps1`'s fallback dispatch, or the config reverted to a working state.
- 🟡 **`ahk_launcher.ahk` and `ScriptletLauncher.ahk` overlap** — both are "browse and launch scriptlets" UIs (one tray-resident/auto-start, one search-popup/toggle). Both are now registered; not consolidated. Worth a decision on whether one should retire.
- 🟢 **`weather_widget`** — only exists as an unmigrated AHK v1 script (`scriptlets/v1/weather_widget.ahk`) needing an OpenWeatherMap API key that was never configured. Deregistered from the catalog rather than left broken; a real fix is a v2 rewrite + key setup, not attempted here.

## 📚 References

- [MCP Central Documentation Standards](../mcp-central-docs/STANDARDS.md)
- [FastMCP Standards Guide](../mcp-central-docs/standards/FASTMCP_STANDARDS.md) — not applicable to this repo's own code, kept for fleet-wide cross-reference
- [Repo Assess-and-Fix pattern](../mcp-central-docs/patterns/repo-assess-and-fix.md)

---

*Assessment generated 2026-09-22. Point-in-time audit trail also written to `reports/assess-2026-09-22.md` (gitignored, not committed).*
