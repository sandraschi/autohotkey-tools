# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

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









