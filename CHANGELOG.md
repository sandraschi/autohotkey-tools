# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- AutoHotkey++ Cursor Extension support documentation
- Enhanced IDE support section in development guides
- Documentation for AutoHotkey++ extension features and installation

### Fixed
- AutoHotkey v2 linter errors in multiple files
  - Fixed duplicate function declarations and syntax errors in `quick_notes.ahk`
  - Fixed `Loop Dir` syntax errors in `video_filename_scrubber.ahk` (use `Loop Files` with `D` mode)
  - Fixed `WinSetAlwaysOnTop` syntax and arrow function issues in `hello_world.ahk`
  - Converted arrow functions to named functions in `claude-mcp-scripts.ahk` to fix object literal errors
  - Fixed `GuiSize` function parameter syntax errors

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





