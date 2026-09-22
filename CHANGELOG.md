# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

Nothing yet.

## [2026-09-22]

### Fixed
- **Depot weed**: audited all 111 files in `scriptlets/` against `metadata.json`. Deleted 4 zero-byte junk files, a confirmed-dead `ollama_chatbot_v3.ahk` stub (GUI skeleton, no Ollama wiring at all), a byte-identical duplicate; truncated a 27.7MB `crash.log`. Archived 11 test/debug scratch files and 3 superseded draft versions to `scriptlets/_archive/`.
- **`windows_cleanup_robot.ahk`**: dead AHK v1 command syntax (`DriveGet, var, ...`) that would throw at runtime, converted to v2 function syntax.
- **`ScriptletCOMBridge.ahk` dashboard scan**: `/scriptlets` live directory scan excluded `v1/` and `lib/` but not `_archive/` — archived scriptlets were still showing as launchable. Fixed.
- **`ScriptletCOMBridge.ahk` stale internal port**: the actual `HttpListener` was still hardcoded to port 10744 in 6 places, even though the 2026-08-27 port migration updated the external-facing references (`dashboard.html`, `start_dashboard.ps1`). Port 10744 now belongs to `openclaw-molt-mcp` per the fleet port registry — a live collision risk. Fixed all 6 references; killed a stale detached `powershell.exe` listener still bound to the old port.
- **`justfile`**: `dash` recipe opened `:10744`, same stale-port bug. Fixed to `:10764`.
- **`metadata.json`**: `weather_widget` was registered but no v2 file exists (only an unmigrated `v1/weather_widget.ahk` needing an API key that was never configured) — deregistered. `classic_pranks_collection` key didn't match its actual file (`classic_pranks.ahk`) and used an invalid category (`"pranks"`) — renamed and recategorized to `"fun"`.

### Added
- 20 previously-unregistered scriptlets added to `metadata.json` (43 → 63 plugins), including `office365_automation.ahk` (40KB, the largest file in the depot) and `ScriptletLauncher.ahk` itself — none had ever been wired into the catalog.
- `automation` category, and metadata headers for the 4 files that lacked one (`windows_cleanup_robot`, `qbert_game`, `PuzzleGame`, `corporate_pranks`).
- `reports/assess-2026-09-22.md` audit trail (gitignored); `reports/` added to `.gitignore`.

### Changed
- `ASSESSMENT.md` regenerated from scratch — the previous version, dated 2026-01-01 and describing this as a "Runt" with "no standards compliance detected," was 9 months stale. Retired to `OBSOLETE_ASSESSMENT_2026-01-01.md`.
- `README.md` and `INSTALL.md` rewritten — both previously carried a generic fleet MCP-server template (Python 3.13+/FastMCP/`uv` badges and instructions) that doesn't apply to this repo at all (AHK v2 + PowerShell, no Python). Also removed the README's description of `ollama_chatbot_v3.ahk` as a working feature (it was the dead stub deleted above); documented the three overlapping launcher implementations honestly instead of presenting one as canonical.

## [2025-11-22] (historical, previously mislabeled "Unreleased")

### Fixed
- **Bridge /run endpoint**: Replaced synchronous `& batfile` with `Start-Process` directly in PS server. Resolved timeout when launching games via HTTP.
- **Bridge /stop endpoint**: Replaced broken WMI/Get-Process logic with `Get-CimInstance` + command-line matching. Stop now works reliably.
- **All games with dark backgrounds**: Added explicit text colors (`cLime`, `cWhite`, `c4488FF`) to board controls and `SetFont` calls. Previously defaulted to system text color (black on dark mode), making text invisible.
- **Hotkey scoping**: Pong, Tetris, Frogger changed from global hotkeys with window guards to `HotIf`-scoped hotkeys. Keys (W/S, arrows, etc.) no longer consumed by AHK when the game window isn't focused.
- **Word Games tab background**: Tab3 → Tab2 so page area respects dark GUI BackColor. Per-control SetFont calls now include explicit colors.
- **Wordle grid arrows**: Removed `+0x200` style from Edit controls (caused up/down arrow artifacts). Switched to Text controls for cells.
- **Wordle help**: Added yellow "?" button with MsgBox explaining rules (green/yellow/gray color meaning).
- AutoHotkey v2 linter errors in multiple files (duplicate function declarations, `Loop Dir` v1 syntax, `WinSetAlwaysOnTop` syntax, arrow-function object-literal errors, `GuiSize` parameter errors).
- Recent scriptlet fixes (2025-11-13): `classic_pranks_fixed.ahk` stripped non-prank content; `classic_pranks_collection.ahk` refactored timers/hotkeys, removed v1-era calls; `clipboard_manager.ahk` rewritten to pure v2 with custom history persistence.
- **32 files fixed** with automated safety scripts: 11 files got GUI Escape/Close handlers, 12 files had `SetTimer` v1→v2 syntax fixed (~51 instances), 8 files got `OnExit` handlers, 1 critical syntax error fixed (`classic_pranks.ahk`).
- Bugbash pass rate improved from 14.7% to 39.2% (+24.5%); crashes eliminated (38 → 0); 18 more scriptlets passing (11 → 29).

### Added
- **GDI+ Pong rewrite**: Classic Pong now uses GDI+ vector graphics (rounded green paddles, white ball, dotted center line, dark background, 60fps).
- **Wordle cheat buttons**: Yellow "C" suggests a valid word from previous guesses; green "S" auto-solves the puzzle. Physical keyboard input (A-Z, Backspace, Enter) on the Wordle and Hangman tabs, replacing the on-screen keyboard.
- **GDI+ helper library** (`scriptlets/lib/GdipHelper.ahk`): Minimal GDI+ wrapper for AHK v2.
- **iPad Scroll Widget** (`ipad_scroll_widget.ahk`): Vertical always-on-top PgUp/Up/Down/PgDn/Top/End buttons for terminal scrolling via RustDesk from iPad, `PostMessage` WM_MOUSEWHEEL (zero focus steal), Play submenu launches games.
- **Ollama Chatbot v3** (`ollama_chatbot_v3.ahk`): originally logged here as a native AHK chat client with 4 personalities and session persistence. **Note (2026-09-22): this file was found to be a non-functional GUI skeleton with no wiring and was deleted** — whatever this changelog entry described either never fully landed or was lost. The working chatbot is `ollama_chatbot.ahk`.
- **AHK Launcher** (`ahk_launcher.ahk`): Ctrl+Alt+A, searchable script list scanning the depot for `@category`/`@description` headers.
- **Word Games** (`word_games.ahk`): Ctrl+Alt+G, tabbed Wordle/Anagrams/Hangman.
- `justfile` with `lint-ahk`, `lint-fix`, `lint-one`, `kill-ahk`, `dash`, `start` recipes.
- `autohotkey_v2_standard.md` fleet standard for AHK v2 syntax and conventions.
- AutoHotkey++ Cursor extension support docs, enhanced IDE support section, repository status report.

### Changed
- **ScriptletErrorHandler.ahk**: Self-registers `OnError` internally — no more invisible error popups on runtime crashes.
- **Linter** (`utils/linter_headless.ahk`): 33+ checks, `--fix` mode with `.bak` backup.
- **All 77 scripts**: Bulk v1→v2 migration pass (`Random(&var)`, `Loop Files`, `FormatTime`, `StrRepeat`, `#Requires`/`#Include` headers, `Menu.Add` submenu objects).
- **Scriptlet bridge port**: 8765 → 10764 (fleet port scheme).
- Repository health improved from POOR to FAIR per bugbash (29/74 succeeded, 0 crashed, 45 timed out at the time).

### Known Issues (as of 2025-11-22, not re-verified since)
- 45/74 scriptlets timed out in automated testing — many are GUI scripts requiring user interaction, likely a harness limitation rather than a real failure.
- Object literal syntax failures flagged in 38+ scriptlets at the time.
- Hardcoded paths throughout the codebase.

## [2025-01] (exact date not recorded in the original entry)

### Added
- MCP Server Scaffolding Guide documentation, enhanced MCP tools parsing from FastMCP server files.
- SVG chess pieces and visual chessboard (8x8 grid, Unicode pieces, checkered pattern with rank/file labels).
- Recording tools: Macro Recorder Pro, Macro Editor Pro, Action Automation Builder.
- Mandatory v2 compliance checklist (10-point verification), strict v1-syntax prohibitions list.

### Fixed
- All AutoHotkey v2 GUI syntax issues across scriptlets; `OnError` handlers added everywhere; `InputBox` syntax fixes; `ScriptletLauncher` converted to v2; missing parentheses in `Hotkey` calls; chess board rendering.

### Changed
- Enhanced linter with 12 additional checks; all AutoHotkey runs use `/ErrorStdOut` to suppress error popups.

### Documentation
- AutoHotkey v2 syntax reference, debugging guide, migration guides, MCP Server Scaffolding Guide.

## Previous Versions

See git commit history for detailed changes before 2025-01.

---

**License**: MIT License
**Author**: Sandra Schipal
**Copyright**: © 2025-2026 Sandra Schipal
