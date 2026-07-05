# autohotkey-test

<p align="center">
  <a href="https://github.com/casey/just"><img src="https://img.shields.io/badge/just-ready_to_go-7c5cfc?style=flat-square&logo=just&logoColor=white" alt="Just"></a>
  <a href="https://github.com/astral-sh/ruff"><img src="https://img.shields.io/endpoint?url=https://raw.githubusercontent.com/astral-sh/ruff/main/assets/badge/v2.json" alt="Ruff"></a>
  <a href="https://python.org"><img src="https://img.shields.io/badge/Python-3.13+-3776AB?style=flat-square&logo=python&logoColor=white" alt="Python"></a>
  <a href="https://github.com/PrefectHQ/fastmcp"><img src="https://img.shields.io/badge/FastMCP-3.2-7c5cfc?style=flat-square" alt="FastMCP"></a>
</p>


> 📖 **[Installation Guide](INSTALL.md)** — quick start, manual setup, and troubleshooting

**AutoHotkey v2 scriptlet depot** — 80+ `.ahk` scripts plus a local HTTP bridge for list/run/stop from [autohotkey-mcp](../autohotkey-mcp).

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
| `scriptlets/` | 80+ AHK v2 scripts by category |
| `scriptlets/ai_generated/` | Sandbox for MCP-generated scripts — review before promoting |
| `scriptlet_launcher_v2.ahk` | Native GUI launcher |
| `utils/linter_headless.ahk` | Headless static analyzer with `--fix` mode |
| `utils/batch_debugger.ps1` | Batch syntax checker |
| `docs/` | Syntax reference, migration guides, bugbash reports |
| `stockfish.exe` | Chess engine (for `chess_stockfish.ahk`) |
| `justfile` | `lint-ahk`, `lint-fix`, `lint-one`, `kill-ahk`, `dash`, `start` |

## Widgets

| Widget | Hotkey | What |
|--------|--------|------|
| `ipad_scroll_widget.ahk` | — | ▲△▽▼/Top/End buttons + Play game menu. For RustDesk iPad. |
| `ollama_chatbot_v3.ahk` | Ctrl+Alt+O | 4 personalities, model ComboBox, session persistence, dark GUI |
| `ahk_launcher.ahk` | Ctrl+Alt+A | Searchable script list with favorites, Run button |
| `word_games.ahk` | Ctrl+Alt+G | Tabbed Wordle / Anagrams / Hangman. Physical keyboard input, cheat solver. |
| `classic_pong.ahk` | Ctrl+Alt+P | GDI+ arcade game with vector graphics (green paddles, white ball). |

## Scriptlet Categories

- **games** — Snake, Tetris, Sudoku, Chess (Stockfish), Pong, Pac-Man, Frogger, Q*bert, Wordle, Anagrams, Hangman
- **productivity** — Clipboard manager, window snapping, volume, quick notes
- **system** — System monitor, security guide, window helpers
- **development** — Git assistant, code formatter, MCP scaffolding, AHK linter
- **chat** — Ollama chatbot v3 with personalities
- **fun** — Pranks, sounds, corporate comedy
- **hotkeys** — Remaps and shortcut layers
- **ai_generated** — Scripts generated via `autohotkey-mcp generate_scriptlet`

## Health

77 scriptlets, **0 lint errors** (2026-07-05). `just lint-ahk` to verify.

- All scripts pass `linter_headless.ahk` with zero errors
- 6 shipped widgets running simultaneously from depot
- `just lint-fix` auto-applies mechanical v1→v2 fixes with `.bak` backup
- See `standards/rules/autohotkey_v2_standard.md` for fleet AHK v2 conventions

## Arcade Games

13 playable arcade games in `scriptlets/`. GDI+ rendering in classic_pong. ASCII grid rendering in tetris, frogger, pacman, qbert. All use `HotIf`-scoped hotkeys (no global key stealing). Access via bridge at `http://127.0.0.1:10744/dashboard`.

| Game | Rendering | Controls |
|------|-----------|----------|
| Classic Pong | GDI+ (paddles, ball, net) | W/S or arrows, Space=Start |
| Tetris | ASCII (green on black) | Arrows, Up=Rotate, Space=Drop |
| Frogger | ASCII (green on black) | Arrows |
| Pac-Man | ASCII (yellow on black) | Arrow keys |
| Q*bert | ASCII (green on black) | Arrows |
| Sudoku | Edit grid | Click + type |
| Chess | Full board UI | Click to move, Stockfish AI |
| Word Games | Tabbed UI | Physical keyboard: type, Backspace, Enter |

### Hotkey Fixes (2026-07-05)
All games now use `HotIf`-scoped hotkeys instead of global guards. Keys pass through to other apps when the game window isn't focused. Previously, bare letter hotkeys (W/S/A/D, arrows) were consumed globally regardless of window state.

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
