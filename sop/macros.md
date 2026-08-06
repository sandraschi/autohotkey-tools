# Macro SOP — //trigger definitions for macro_expander.ahk

Each `## name` heading below is a macro. Typing `//name arg1 arg2` then
Tab or Enter (in any app) expands it using the body text as a template.

- `{1}`, `{2}`, ... are positional parameters, filled from space-separated
  args typed after the macro name.
- Unused placeholders are stripped if you don't pass enough args.
- Edit this file, then press Ctrl+Alt+R (while macro_expander.ahk is running)
  to reload without restarting the script.

## vqa
Assess {1} for {2} — check for real bugs (not stylistic nits), fleet standards compliance (AGENT_PROTOCOLS.md), test coverage gaps, and doc drift against its own STATUS.md/TODO.md/CHANGELOG.md. Be brutally honest, no rah-rah.

## status
Give me a full, honest status reassessment of {1}: what changed since last check, real bugs found (cite file/line), standards compliance gaps, and whether STATUS.md/TODO.md/CHANGELOG.md still match reality.

## newmcp
Scaffold a new MCP server called {1}: pyproject.toml (fastmcp>=3.4.2,<4), src/{1}_mcp/server.py with FastMCP app, GET /health and POST /tool, stdio-only when stdin is not a TTY, README with run instructions, STATUS.md/TODO.md/CHANGELOG.md per fleet doc standards.

## prcheck
Review this PR/diff for: correctness, edge cases, error handling, security (no secrets, safe inputs), performance, style/naming, test coverage of the actual change, and doc updates if user-facing.

## commit
Write a conventional commit message for: {1}. Format: type(scope): message. Types: feat, fix, docs, style, refactor, test, chore.

## v2check
Scan {1} for AutoHotkey v1-vs-v2 syntax issues: Gui/GuiControl labels, hotkey labels instead of Hotkey(), StringUpper/Lower, Random legacy syntax, FileSelectFolder, missing #Requires AutoHotkey v2.0+, missing OnError registration.
