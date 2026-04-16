# AutoHotkey v2 Scriptlets Collection

**AutoHotkey (AHK)** is a free, open-source **Windows automation language**: you write small scripts (`.ahk`) that can define **hotkeys** and **hotstrings**, send **mouse and keyboard** input, **find and control windows**, read and write **files**, call **COM** objects, run **HTTP** requests, show **GUIs**, and glue together everyday workflows without shipping a full app. **v2** is the current branch: clearer syntax, classes, and stricter behavior than legacy v1, while keeping the same “script everything on the desktop” idea.

**What you can build with it:** keyboard layers and remaps, text expanders, window managers, clipboard tools, installers for repetitive clicks, game helpers, dev utilities, and one-off **MCP** or **HTTP** bridges—anything that fits “when I press this / when this happens, do that on Windows.”

This repository is a **scriptlet collection** plus a **local web dashboard** to browse and launch scripts. It is **not** the AutoHotkey runtime: install **AutoHotkey v2** from [autohotkey.com](https://www.autohotkey.com/) if you do not already have it.

## 🚀 Quick Start

### Launch Dashboard
```powershell
# Start the bridge server
.\ScriptletCOMBridge.ahk

# Or run the launcher (starts bridge + opens dashboard)
.\start_dashboard.bat

# Or run the native GUI launcher
.\scriptlet_launcher_v2.ahk
```

The web interface is at **`http://127.0.0.1:10744/`** (fleet port 10744). Use `/dashboard` for the dashboard. The launcher may not report "Bridge is live" before opening; the webapp works regardless.

### Available Scriptlets

Navigate through 74+ scriptlets (⚠️ **Note**: Repository health improved to **FAIR** - Latest bugbash results: 29 succeeded, 0 crashed, 45 timed out):
- **Games**: Snake, Tetris, Sudoku, Chess (with Stockfish), Pong, Pac-Man, Q*bert, Frogger
- **Development**: Git Assistant, Code Formatter, AI Code Assistant
- **Productivity**: Clipboard Manager, Window Snapping, Volume Control
- **MCP Integration**: Ollama Chatbot, MCP Config Manager, MCP Server Scaffolding Tool, MCP Development Tools
- **System**: System Monitor, Security Guide, Help System

### Key Files

- `ScriptletCOMBridge.ahk` - HTTP bridge server for web dashboard
- `launcher_enhanced.html` - Modern web-based scriptlet launcher  
- `scriptlet_launcher_v2.ahk` - Native GUI launcher
- `RunScriptlet.bat` - Execute individual scriptlets
- `scriptlets/` - 75+ scriptlets organized by category

### Development Tools

- `utils/linter.ahk` - AutoHotkey v2 static analyzer
- `utils/batch_debugger.ps1` - Batch syntax checking
- `utils/compatibility_scanner.ahk` - v1→v2 migration scanner

### IDE Support

**AutoHotkey++ Cursor Extension** - Enhanced AutoHotkey v2 support for Cursor IDE:
- Full IntelliSense and autocomplete for AutoHotkey v2
- Real-time syntax checking and error detection
- Code formatting and refactoring tools
- Integrated debugging support
- Syntax highlighting optimized for v2

Install the AutoHotkey++ extension from the Cursor extensions marketplace for the best development experience.

### MCP Server Scaffolding

The **MCP Server Scaffolding Tool** (`scriptlets/mcp_server_scaffolding.ahk`) generates complete, production-ready MCP servers:

**Features:**
- FastMCP 2.12+ compatibility with stdio transport
- Standard tools included: `help()`, `status()`, `ping()`
- Organized project structure with `src/tools/` modules
- Build scripts in `mcpb/` directory
- Ready-to-use Claude Desktop integration

**Usage**: Press `Ctrl+Alt+M` or `F9` to launch, or run:
```powershell
AutoHotkey.exe '/ErrorStdOut' scriptlets\mcp_server_scaffolding.ahk
```

See [docs/MCP_Server_Scaffolding_Guide.md](docs/MCP_Server_Scaffolding_Guide.md) for complete documentation.

## 🔒 Security

**Warning**: AutoHotkey can access and control all parts of your computer. Only run trusted scripts and review code before execution.

See `scriptlets/security_guide_pro.ahk` for complete safety guide.

## 📚 Documentation

- `docs/AutoHotkey_v2_Syntax_Reference.md` - Complete v2 syntax guide
- `docs/AutoHotkey_Debugging_Guide.md` - Debugging techniques
- `docs/AutoHotkey_v2_Modulo_Migration_Guide.md` - Migration from v1 to v2
- `docs/REPOSITORY_HEALTH_IMPROVEMENT_PLAN.md` ⭐ - Action plan to fix failing scriptlets and improve health

## 🎮 Games

All games are functional implementations:
- **Chess** (`chess_stockfish.ahk`) - Full chess game with Stockfish engine
- **Snake** (`mini_games_collection.ahk`) - Classic snake game
- **Sudoku** (`sudoku.ahk`) - Working Sudoku puzzle
- **Tetris**, **Pong**, **Pac-Man**, **Q*bert**, **Frogger** - Available via launcher

## ⚙️ Requirements

- AutoHotkey v2.0+
- PowerShell 5.0+
- Windows 10/11

## 📝 Project Structure

```
autohotkey-test/
├── ScriptletCOMBridge.ahk    # HTTP bridge server
├── launcher_enhanced.html     # Web dashboard
├── scriptlets/                # 84 scriptlets
├── utils/                     # Development tools
├── docs/                      # Documentation
├── junk/                      # Archive/temp files
└── stockfish.exe             # Chess engine
```

## 🔧 Scriptlet Categories

- **Games**: Mini games collection, classic arcade games (Snake, Tetris, Sudoku, Chess, Pong, Pac-Man, Q*bert, Frogger)
- **Productivity**: Clipboard, window management, automation tools
- **Development**: Git, code formatting, MCP tools
- **System**: Monitoring, security, helpers
- **Utilities**: Various utility scripts

**Note**: See [docs/BUGBASH_RESULTS.md](docs/BUGBASH_RESULTS.md) for latest bugbash comparison and [docs/Repository_Status_Report.md](docs/Repository_Status_Report.md) for detailed analysis.

## 📜 License

Licensed under MIT License - see LICENSE file for details.

## 👤 Author

Sandra - AutoHotkey v2 enthusiast and developer

---

**Status**: 75+ scriptlets | AutoHotkey v2 compatible | Web dashboard available  
**Repository Health**: ⚠️ **POOR** - See [Repository Status Report](docs/Repository_Status_Report.md) for details

