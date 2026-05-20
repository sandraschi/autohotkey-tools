# autohotkey-test

<p align="center">
  <a href="https://github.com/casey/just"><img src="https://img.shields.io/badge/just-ready_to_go-7c5cfc?style=flat-square&logo=just&logoColor=white" alt="Just"></a>
  <a href="https://github.com/astral-sh/ruff"><img src="https://img.shields.io/endpoint?url=https://raw.githubusercontent.com/astral-sh/ruff/main/assets/badge/v2.json" alt="Ruff"></a>
  <a href="https://python.org"><img src="https://img.shields.io/badge/Python-3.13+-3776AB?style=flat-square&logo=python&logoColor=white" alt="Python"></a>
  <a href="https://github.com/PrefectHQ/fastmcp"><img src="https://img.shields.io/badge/FastMCP-3.2-7c5cfc?style=flat-square" alt="FastMCP"></a>
</p>


> 📖 **[Installation Guide](INSTALL.md)** — quick start, manual setup, and troubleshooting

**AutoHotkey v2 scriptlet depot** — 75+ `.ahk` scripts plus a local HTTP bridge for list/run/stop from [autohotkey-mcp](../autohotkey-mcp).

## Quick Start

```powershell
git clone https://github.com/sandraschi/autohotkey-test
cd autohotkey-test
just
```

This opens an interactive dashboard showing all available commands. Run `just bootstrap` to install dependencies, then `just serve` or `just dev` to start.

### Manual Setup

If you don't have `just` installed:
# Fleet-standard start (kills port zombie, starts bridge, opens dashboard)
.\start.bat
# Or directly:
.\start_dashboard.ps1
Dashboard opens at **`http://127.0.0.1:10744/dashboard`**.

## What's Here

| Path | Description |
|------|-------------|
| `ScriptletCOMBridge.ahk` | HTTP server on **10744** — `/scriptlets`, `/run/:name`, `/stop/:name`, `/dashboard` |
| `scriptlets/` | 75+ AHK v2 scripts by category |
| `scriptlets/ai_generated/` | Sandbox for MCP-generated scripts — review before promoting |
| `scriptlet_launcher_v2.ahk` | Native GUI launcher |
| `utils/linter.ahk` | Static analyzer for AHK v2 |
| `utils/batch_debugger.ps1` | Batch syntax checker |
| `docs/` | Syntax reference, migration guides, bugbash reports |
| `stockfish.exe` | Chess engine (for `chess_stockfish.ahk`) |

## Scriptlet Categories

- **games** — Snake, Tetris, Sudoku, Chess (Stockfish), Pong, Pac-Man, Frogger, Q*bert
- **productivity** — Clipboard manager, window snapping, volume, quick notes
- **system** — System monitor, security guide, window helpers
- **development** — Git assistant, code formatter, MCP scaffolding, AHK linter
- **fun** — Pranks, sounds, corporate comedy
- **hotkeys** — Remaps and shortcut layers
- **ai_generated** — Scripts generated via `autohotkey-mcp generate_scriptlet`

## Health

Latest bugbash: **29/74 pass, 45 timeout** (~39% success rate).

- Core productivity, hotkey, and clipboard scripts are reliable.
- Games and complex GUI scripts timeout under headless test conditions — they work fine when run normally.
- `ai_generated/` scripts are unsanitized and should be reviewed before use.

See [docs/BUGBASH_RESULTS.md](docs/BUGBASH_RESULTS.md) for the full report.

## Integration with autohotkey-mcp

`autohotkey-mcp` reads this depot directly:

```
AUTOHOTKEY_SCRIPT_DEPOT=D:\Dev\repos\autohotkey-test
AUTOHOTKEY_BRIDGE_URL=http://127.0.0.1:10744
```

When the bridge is running, `list_scriptlets` / `run_scriptlet` / `stop_scriptlet`
go through it. When it's not, autohotkey-mcp scans `scriptlets/` directly and
launches AHK via subprocess.

## Port

`10744` — ScriptletCOMBridge HTTP server. Registered in `mcp-central-docs/operations/WEBAPP_PORTS.md`.

## Requirements

- AutoHotkey v2.0+ — [autohotkey.com](https://www.autohotkey.com/)
- Windows 10/11
- PowerShell 5+

## Security

AHK scripts have full desktop access. Only run trusted scripts. Review `ai_generated/` output before executing.

## License

MIT
