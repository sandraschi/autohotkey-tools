# autohotkey-test

**AutoHotkey v2 scriptlet depot** — 64 working `.ahk` utilities, widgets, games and pranks, served through a local HTTP bridge with a live web dashboard. Sibling to [ahk-lint](../ahk-linter) (AST-based v2 linter with auto-fix) and consumed by [autohotkey-mcp](../autohotkey-mcp).

> 📖 **[Installation Guide](INSTALL.md)** — quick start, manual setup, and troubleshooting

## This is not just a script library — ask Claude to build you something

The point of this depot isn't only "browse and run 64 existing scripts." Through [autohotkey-mcp](../autohotkey-mcp)'s `generate_scriptlet` tool, you can ask an AI assistant to **write a new one for you**, and it becomes a real, launchable entry in this dashboard. For example:

> "Make me an AHK shogi game and wire it into the AHK starter dashboard."

> "Make a useful little helper popup for working in Blender."

What actually happens:
1. `generate_scriptlet(prompt)` writes the new script to `scriptlets/ai_generated/` (sandboxed — never touches the live catalog directly).
2. You (or Claude, if asked) review it — run `just lint-ahk` against it, try it standalone.
3. **"Wiring it in"** means moving it from `ai_generated/` into `scriptlets/` and registering it in `metadata.json` (name, category, hotkeys, description) — the exact process used to bring 21 previously-orphaned tools into the catalog on 2026-09-22. There's no one-click "promote" tool yet; ask Claude to do it, the same way it was done for this whole batch.
4. Once registered, it shows up in the dashboard like any other scriptlet — searchable, launchable, stoppable, no restart needed (the bridge live-scans `scriptlets/`).

This is the actual value proposition: a standing target you can keep pointing an AI assistant at to grow, not a fixed collection you're stuck with.

## Quick Start

```powershell
git clone https://github.com/sandraschi/autohotkey-test
cd autohotkey-test
just dash
```

`just dash` starts the bridge if it isn't running and opens the dashboard at **`http://127.0.0.1:10764/dashboard`** — browse by category, search, launch and stop scriptlets from the browser.

Manual alternative:
```powershell
.\start.bat
# or:
.\start_dashboard.ps1
```

## What's here

| Path | Description |
|------|-------------|
| `ScriptletCOMBridge.ahk` | HTTP bridge on **:10764** — `/scriptlets` (live directory scan), `/run/:name`, `/stop/:name`, `/status`, `/dashboard` |
| `dashboard.html` | Web UI, talks to the bridge live — no build step |
| `scriptlets/` | 64 AHK v2 scripts (`metadata.json` is the catalog: 63 registered) |
| `scriptlets/_archive/` | Superseded drafts and test scratch files, kept for history, excluded from the dashboard |
| `scriptlets/v1/` | Unmigrated AHK v1 scripts, excluded from the dashboard and depot scans |
| `scriptlets/ai_generated/` | Sandbox for MCP-generated scripts — review before promoting |
| `utils/linter_headless.ahk` | Headless static analyzer with `--fix` mode (see also the standalone [ahk-lint](../ahk-linter) CLI) |
| `docs/` | Syntax references, v1→v2 migration guides, bugbash reports (20+ files, not yet indexed) |
| `justfile` | `just dash` / `lint-ahk` / `lint-fix` / `scan-compat` / `kill-ahk` / `start` |

### Three launchers, one recommended path

There are three separate launcher UIs in this repo, from different points in its history:

- **`dashboard.html` (via the bridge, port 10764)** — current, recommended. Live-scans `scriptlets/`, reads `metadata.json` for descriptions, category filtering, search, run/stop from the browser.
- **`scriptlets/ScriptletLauncher.ahk`** — tray-resident AHK GUI, auto-starts, tabbed categories. Registered in the catalog.
- **`scriptlets/ahk_launcher.ahk`** — lightweight searchable popup (`Ctrl+Alt+A`). Registered in the catalog.
- **`scriptlet_launcher_v2.ahk`** (repo root, ~2965 lines, Sept 2025) — the original monolithic launcher with a hardcoded item list, predates the bridge/dashboard/catalog system entirely. Legacy; not wired into `metadata.json`.

If you're picking one, use the dashboard. The two in-AHK launchers overlap and haven't been consolidated yet.

## Scriptlet categories (registered in `metadata.json`)

- **games** — Chess (Stockfish), Pong, Tetris, Frogger, Pac-Man, Q\*bert, Sudoku, Puzzle (15-tile), Wordle/Anagrams/Hangman
- **productivity** — Clipboard managers, window snapping/management, quick notes, quick launch, text/macro expansion, prompt snippets
- **system** — System monitor(s), cleanup robot, security warnings, system shortcuts
- **development** — Git repo manager, code formatter, MCP scaffolding/dev-cycle tools, AHK debug helper
- **automation** — Macro recorder/editor, visual workflow builder
- **fun** — Classic and corporate pranks, ambient sounds
- **widgets** — iPad scroll widget
- **ai** — Ollama chatbot, AI code assistant

Run `just lint-ahk` to check the whole depot against the fleet AHK v2 standard (see `mcp-central-docs/standards/rules/autohotkey_v2_standard.md`).

## Integration with autohotkey-mcp

`autohotkey-mcp` reads this depot directly:

```
AUTOHOTKEY_SCRIPT_DEPOT=D:\Dev\repos\autohotkey-test
AUTOHOTKEY_BRIDGE_URL=http://127.0.0.1:10764
```

When the bridge is running, `list_scriptlets` / `run_scriptlet` / `stop_scriptlet` go through it. When it's not, `autohotkey-mcp` scans `scriptlets/` directly and launches AHK via subprocess.

## Port

`10764` — ScriptletCOMBridge HTTP server. Registered in `mcp-central-docs/operations/WEBAPP_PORTS.md`. (Historical note: this used to be 10744, migrated 2026-08-27 due to a collision with `openclaw-molt-mcp` — as of 2026-09-22 all internal references are consistent on 10764.)

## Requirements

- AutoHotkey v2.0+ — [autohotkey.com](https://www.autohotkey.com/)
- Windows 10/11
- PowerShell 5+

## Security

AHK scripts have full desktop access. Only run trusted scripts. Review `ai_generated/` output before executing.

## Known gaps

- `just bootstrap` references `uv sync`/`pre-commit` — there's no `pyproject.toml` or `.pre-commit-config.yaml` in this repo; that recipe doesn't currently work.
- No CI/CD pipeline.
- See [ASSESSMENT.md](ASSESSMENT.md) for the current full status.

## License

MIT
