# Community + combo repo idea

## Useful Discords

- **AutoHotkey (main)** — [autohotkey.com/discord](https://www.autohotkey.com/discord) or search "AutoHotkey" in Discord. ~25k members, active; v2 help, show-and-tell, scripting. Best place to share scriptlet depot + MCP + bridge and get stars/feedback. Post in a show-and-tell or v2 channel with a one-liner + link to the repo(s).
- **Reddit:** r/AutoHotkey — smaller but good for "I built X with AHK" posts.
- **Forums:** [autohotkey.com/boards](https://www.autohotkey.com/boards/) — still used for long threads and docs; link from Discord or Reddit.

Since the AHK dev bubble is small, a single clear "scriptlets + MCP + optional bridge + webapp" story can get real traction. One combo repo is easier to star and share than two.

---

## Combo repo: one repo to rule them all

**Idea:** One GitHub repo that contains (1) scriptlet depot, (2) bridge, (3) webapp/dashboard, (4) MCP server. Clone once, run bridge or MCP or both; Cursor/IDE users get MCP, browser users get dashboard.

### Suggested layout

```
autohotkey-scriptlets/   (or keep name autohotkey-test)
├── scriptlets/          # AHK scriptlets (current content)
├── ScriptletCOMBridge.ahk
├── start_dashboard.bat
├── launcher_enhanced.html, scriptlet_launcher_v2.ahk, ...
├── mcp/                 # MCP server (current autohotkey-mcp)
│   ├── pyproject.toml
│   ├── src/autohotkey_mcp/
│   ├── web_sota/        # optional; or keep web at repo root)
│   └── README.md
├── web/                 # optional: dashboard SPA if not already in repo root
│   └── ...
├── docs/
│   ├── COMMUNITY_AND_COMBO_REPO.md
│   └── SCRIPTLET_IDEAS.md (or scriptlets/SCRIPTLET_IDEAS.md)
└── README.md            # One story: scriptlets, bridge, MCP, Cursor, Discord
```

**README one-liner:** "AutoHotkey v2 scriptlet depot + ScriptletCOMBridge (web dashboard) + MCP server for Cursor/IDE. One repo: list/run/stop scriptlets from the web or from your AI assistant."

### Pros

- **Single star target** — one repo to discover and star.
- **Clear narrative** — "AHK scriptlets + MCP + bridge" in one place; great for a Discord post or Reddit.
- **One clone** — `git clone` then run bridge and/or MCP; depot path is same repo.

### Cons / choices

- **Polyglot** — AHK + Python in one repo; some prefer separate. Mitigation: keep `mcp/` as a clear subdir with its own `pyproject.toml` and `uv run` from `mcp/`.
- **autohotkey-test as "my depot"** — if you want to keep autohotkey-test as a private/personal depot, you could instead create a **new** repo (e.g. `autohotkey-scriptlets-stack`) that has scriptlets + bridge + mcp as subdirs, and keep autohotkey-test as the canonical depot you clone into that repo or symlink. Or merge and make the combo repo the main one.

### How to do it

1. **Option A — Merge into autohotkey-test:** Copy `autohotkey-mcp` contents into `autohotkey-test/mcp/`. Update MCP README to say "run from repo root: `cd mcp && uv run autohotkey-mcp`". Default `AUTOHOTKEY_SCRIPT_DEPOT` to parent repo (e.g. `..` when run from `mcp/`). Deprecate or archive the standalone autohotkey-mcp repo and point its README to the combo repo.
2. **Option B — New combo repo:** Create `autohotkey-scriptlets` (or similar). Add scriptlets + bridge + web from autohotkey-test, add MCP from autohotkey-mcp. Single README. Then either archive both old repos or keep autohotkey-test as "upstream depot" and combo as the "distribution" repo.

### Discord post template

> **AHK v2 scriptlets + MCP server + web dashboard** — One repo: 75+ scriptlets (games, productivity, dev tools), ScriptletCOMBridge for the web launcher, and a FastMCP server so Cursor/Claude can list/run/stop scriptlets. Works with or without the bridge (direct AHK run). [link]

Use that in the AutoHotkey Discord (show-and-tell or v2) and optionally r/AutoHotkey. The combo repo makes the link one place to star.
