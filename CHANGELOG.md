# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Fixed
- **Bridge /run endpoint**: Replaced synchronous `& batfile` with `Start-Process` directly in PS server. Resolved timeout when launching games via HTTP.
- **Bridge /stop endpoint**: Replaced broken WMI/Get-Process logic with `Get-CimInstance` + command-line matching. Stop now works reliably.
- **All games with dark backgrounds**: Added explicit text colors (`cLime`, `cWhite`, `c4488FF`) to board controls and `SetFont` calls. Previously defaulted to system text color (black on dark mode), making text invisible.
- **Hotkey scoping**: Pong, Tetris, Frogger changed from global hotkeys with window guards to `HotIf`-scoped hotkeys. Keys (W/S, arrows, etc.) no longer consumed by AHK when the game window isn't focused.
- **Word Games tab background**: Tab3 → Tab2 so page area respects dark GUI BackColor. Per-control SetFont calls now include explicit colors.
- **Wordle grid arrows**: Removed `+0x200` style from Edit controls (caused up/down arrow artifacts). Switched to Text controls for cells.
- **Wordle help**: Added yellow "?" button with MsgBox explaining rules (green/yellow/gray color meaning).

### Added
- **GDI+ Pong rewrite**: Classic Pong now uses GDI+ vector graphics (rounded green paddles, white ball, dotted center line, dark background, 60fps).
- **Wordle cheat buttons**: Yellow "C" button suggests a valid word based on all previous guesses. Green "S" button auto-solves the entire puzzle.
- **Wordle physical keyboard input**: A-Z, Backspace, Enter hotkeys work on the Wordle tab. On-screen keyboard removed.
- **Hangman physical keyboard input**: A-Z hotkeys work on the Hangman tab.
- **Wordle guess tracking**: Each submit result is stored for cheat solver analysis.
- **GDI+ helper library** (`scriptlets/lib/GdipHelper.ahk`): Minimal GDI+ wrapper for AHK v2 (shapes, brushes, pens, bitmap display).
- **Wordle solver**: Filters WORDS list by green/yellow/gray constraints. Tracks exact positions, present/absent letters, and wrong positions.
- **iPad Scroll Widget** (`ipad_scroll_widget.ahk`): Vertical always-on-top PgUp/Up/Down/PgDn/Top/End buttons for terminal scrolling via RustDesk from iPad. Uses `PostMessage` WM_MOUSEWHEEL — zero focus steal. Play submenu launches 5 games.
- **Ollama Chatbot v3** (`ollama_chatbot_v3.ahk`): Native AHK chat client with 4 personalities, model ComboBox, session persistence, dark GUI. ComObject backend.
- **AHK Launcher** (`ahk_launcher.ahk`): Ctrl+Alt+A, searchable script list with favorites, Run button. Scans depot for `@category` and `@description` headers.
- **Word Games** (`word_games.ahk`): Ctrl+Alt+G, tabbed Wordle/Anagrams/Hangman with on-screen keyboards.
- **`justfile`**: 6 recipes — `lint-ahk`, `lint-fix`, `lint-one`, `kill-ahk`, `dash`, `start`.
- **`autohotkey_v2_standard.md`**: Fleet standard for AHK v2 syntax and conventions.

### Changed
- **ScriptletErrorHandler.ahk**: Self-registers `OnError` internally — no more invisible error popups on runtime crashes.
- **Linter** (`utils/linter_headless.ahk`): 33+ checks, added `--fix` mode with `.bak` backup. New checks: `Gui`/`File`/`MenuBar` variable shadowing, `for i from...to...by` v1 syntax.
- **All 77 scripts**: Bulk v1→v2 migration — `Random(&var)` → `var := Random()`, `Loop Files,` → `Loop Files`, `FormatTime outputVar` → `outputVar := FormatTime()`, `StringRepeat` → `StrRepeat`, missing `#Requires`/`#Include` headers added, `Menu.Add` arrays → proper submenu objects, `ParseJSON` stub added where needed.
- **README.md**: Updated with widget docs, justfile recipes, and linter status.

### Changed
- **Scriptlet bridge port**: 8765 → **10744** (fleet port scheme, see robofang `docs/standards/WEBAPP_PORTS.md`). Bridge binds to `127.0.0.1:10744` only; zombie kill before bind, no port crawling.
- **Launcher**: `start_dashboard.bat` / `start_dashboard.ps1` start the bridge and open the dashboard. **Known issue:** bridge detection in the launcher may not report "Bridge is live" before opening the browser; the webapp works nonetheless—open `http://127.0.0.1:10744/dashboard` or use the script to open it.

### Added
- AutoHotkey++ Cursor Extension support documentation
- Enhanced IDE support section in development guides
- Documentation for AutoHotkey++ extension features and installation
- Repository Status Report documenting current health and bugbash results

### Fixed
- AutoHotkey v2 linter errors in multiple files
  - Fixed duplicate function declarations and syntax errors in `quick_notes.ahk`
  - Fixed `Loop Dir` syntax errors in `video_filename_scrubber.ahk` (use `Loop Files` with `D` mode)
  - Fixed `WinSetAlwaysOnTop` syntax and arrow function issues in `hello_world.ahk`
  - Converted arrow functions to named functions in `claude-mcp-scripts.ahk` to fix object literal errors
  - Fixed `GuiSize` function parameter syntax errors
- Recent scriptlet fixes (2025-11-13):
  - `classic_pranks_fixed.ahk`: stripped non-prank content, cleaned timers
  - `classic_pranks_collection.ahk`: refactored timers/hotkeys, removed v1-era calls
  - `clipboard_manager.ahk`: rewritten to pure v2, custom history persistence

### Changed
- **Repository Health Status**: Improved from POOR to FAIR (Latest bugbash: 29/74 succeeded, 0 crashed, 45 timed out)
- **Documentation Accuracy**: Updated README and status reports to reflect improved health
- **Bugbash Integration**: Automated testing harness integrated with CI/CD pipeline
- **Main README**: Updated scriptlet counts and health status

### Fixed (2025-11-22)
- **32 files fixed** with automated safety scripts:
  - 11 files: Added GUI Escape/Close handlers
  - 12 files: Fixed SetTimer syntax (~51 instances converted from v1 to v2)
  - 8 files: Added OnExit handlers (with method validation)
  - 1 file: Fixed critical syntax error (classic_pranks.ahk)
- **Bugbash results**: Pass rate improved from 14.7% to 39.2% (+24.5%)
- **All crashes eliminated**: From 38 crashes to 0 crashes
- **18 more scriptlets passing**: From 11 to 29 successful scriptlets

### Known Issues
- **Remaining**: 45/74 scriptlets timeout in automated testing (Latest bugbash: 2025-11-22)
  - 29 scriptlets completed cleanly (39.2%) ⬆️ Improved
  - 0 scriptlets crashed (0%) ⬇️ Fixed
  - 45 scriptlets timed out (60.8%) - Many are GUI scripts requiring user interaction
- **High Priority**: Object literal syntax failures in 38+ scriptlets
- **High Priority**: 26 scriptlets exceed 20s timeout due to missing auto-exit logic
- **Configuration Debt**: Hard-coded paths throughout codebase require environment detection
- **Documentation**: Some docs still claim "excellent" health despite widespread failures

## [2025-01-XX]

### Added
- MCP Server Scaffolding Guide documentation
- Enhanced MCP tools parsing from FastMCP server files
- SVG chess pieces for visual chessboard
- Recording tools: Macro Recorder Pro, Macro Editor Pro, Action Automation Builder
- Comprehensive recording capabilities documentation
- Mandatory v2 compliance checklist (10-point verification system)
- Strict prohibitions list for v1 syntax patterns
- Rule #6: Run linter after every scriptlet creation
- Check 32: ToUpper/ToLower error prevention
- Rule #5: Use StrUpper() and StrLower() instead of .ToUpper() and .ToLower()
- Rule #4: ALWAYS use /ErrorStdOut flag for AutoHotkey executions
- Visual chessboard with GUI buttons (8x8 grid with Unicode chess pieces)
- Checkered pattern board with rank and file labels

### Fixed
- All AutoHotkey v2 GUI syntax issues across scriptlets
- Complete v2 migration with OnError handlers added to all scripts
- InputBox syntax fixes across all files
- ScriptletLauncher conversion to v2 syntax
- Missing parentheses in Hotkey calls
- v1 syntax remnants throughout codebase
- Linter syntax errors (backtick escaping, for loop syntax)
- Chess board rendering (replaced broken characters)
- Arrow function event handlers (this.Method() to Class.Method())

### Changed
- Updated all templates to use FastMCP 2.12 with stdio transport compatibility
- Enhanced linter with 12 additional checks
- Improved error handling and debugging capabilities
- All AutoHotkey runs now use /ErrorStdOut flag to suppress error popups

### Documentation
- Added comprehensive AutoHotkey v2 syntax reference
- Created debugging guide and migration guides
- Added MCP Server Scaffolding Guide
- Updated development workflow documentation
- Enhanced README with IDE support information

## Previous Versions

See git commit history for detailed changes before 2025-01-XX.

---

**License**: MIT License  
**Author**: Sandra Schi  
**Copyright**: © 2025 Sandra Schi









