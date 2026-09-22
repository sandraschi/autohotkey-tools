# Installation

This is an AutoHotkey v2 scriptlet depot — no Python, no `pip`, no `uv`. You need AutoHotkey v2 and (optionally) `just`.

## 🚀 Quick Start (recommended)

```powershell
# 1. Install AutoHotkey v2 (required)
#    https://www.autohotkey.com/ -> download "AutoHotkey v2"

# 2. Install just if you don't have it (optional but recommended)
winget install Casey.Just    # Windows
# scoop install just          # Windows (alternative)

# 3. Clone and start
git clone https://github.com/sandraschi/autohotkey-test
cd autohotkey-test
just dash
```

`just dash` starts `ScriptletCOMBridge.ahk` (if it isn't already running) and opens the dashboard at `http://127.0.0.1:10764/dashboard`. From the dashboard you can browse, search, launch and stop any registered scriptlet.

Other useful recipes:
```powershell
just lint-ahk     # check every scriptlet against the AHK v2 standard
just lint-fix      # auto-fix v1->v2 issues (creates .bak backups)
just kill-ahk       # kill all running AutoHotkey64.exe processes
```
Run `just` with no arguments (or `just --list`) to print the full recipe list in your terminal — there's no separate GUI dashboard for the recipes themselves, that's a `just` limitation, not something this repo builds.

## 🐌 Manual Setup (no `just`)

1. Install [AutoHotkey v2](https://www.autohotkey.com/)
2. Clone the repo:
   ```powershell
   git clone https://github.com/sandraschi/autohotkey-test
   cd autohotkey-test
   ```
3. Start the bridge directly:
   ```powershell
   .\start.bat
   # or:
   .\start_dashboard.ps1
   ```
4. Open `http://127.0.0.1:10764/dashboard`

To run a single scriptlet without the bridge at all, just double-click it or:
```powershell
"C:\Program Files\AutoHotkey\v2\AutoHotkey64.exe" "scriptlets\clipboard_manager.ahk"
```

## ❓ Troubleshooting

| Issue | Fix |
|---|---|
| `just` not found | `winget install Casey.Just`, or skip it and use `.\start.bat` directly |
| AutoHotkey not found | Install AutoHotkey v2 from [autohotkey.com](https://www.autohotkey.com/); the bridge looks for it under `C:\Program Files\AutoHotkey\v2\` |
| Port 10764 already in use | `just kill-ahk` then retry, or check `Get-NetTCPConnection -LocalPort 10764` for what's holding it |
| Dashboard shows a scriptlet that no longer works | Check `scriptlets/metadata.json` — the dashboard reflects a live directory scan of `scriptlets/`, not a curated "known-good" list |
| Something else | [Open a GitHub issue](https://github.com/sandraschi/autohotkey-test/issues) |

---

*See the main [README](README.md) for the feature overview, and [ASSESSMENT.md](ASSESSMENT.md) for current known gaps.*
