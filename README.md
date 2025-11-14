# AutoHotkey v2 Scriptlets Collection

A comprehensive collection of AutoHotkey v2 scriptlets with modern web dashboard and development tools.

## 🚀 Quick Start

### Launch Dashboard
```powershell
# Start the bridge server
.\ScriptletCOMBridge.ahk

# Or run the launcher scriptlet
.\scriptlet_launcher_v2.ahk
```

The web interface will be available at `http://localhost:8765/`

### Available Scriptlets

Navigate through 84+ professional scriptlets including:
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
- `scriptlets/` - All 84 scriptlets organized by category

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

- **Games** (10): Mini games collection, classic arcade games
- **Productivity** (15): Clipboard, window management, automation
- **Development** (20): Git, code formatting, MCP tools
- **System** (10): Monitoring, security, helpers
- **Utilities** (29): Various utility scripts

## 📜 License

Licensed under MIT License - see LICENSE file for details.

## 👤 Author

Sandra - AutoHotkey v2 enthusiast and developer

---

**Status**: 84 scriptlets | AutoHotkey v2 compatible | Web dashboard available

