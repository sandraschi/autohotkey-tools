# Installation & Setup

## Prerequisites

- **Windows 10 or 11** (64-bit).  
- **AutoHotkey v2.0+** – download from [autohotkey.com](https://www.autohotkey.com).  
- **PowerShell 5.1+** (installed by default).  
- **Optional:** Git, Python (for MCP tooling), Claude Desktop.

## Quick Start (10 minutes)

1. **Install AutoHotkey v2** with default options (all users recommended).  
2. **Clone or unzip** the repository into a writable directory.  
3. **Run** `plugin_loader.ahk`; a tray icon appears when the loader is ready.  
4. **Launch** `launcher_enhanced.html` to open the web interface.  
5. **Test** a scriptlet (`Win+V` for Clipboard Manager, `Ctrl+Alt+H` for this help).

## Running Scriptlets Directly

You can double-click any `.ahk` file in `scriptlets/`. Each script drops logs into `scriptlets\logs\` and enforces timed popups, so direct runs remain safe.

## Harness Usage

```
pwsh -File .\utils\scriptlet_bugbash.ps1 `
    -ScriptletsRoot .\scriptlets `
    -OutputRoot .\reports `
    -TimeoutSeconds 10 `
    -Throttle 5
```

The harness launches every scriptlet with `/ErrorStdOut` and `/Warn All,Off`, records stdout/stderr, and kills stragglers. Review `reports\summary.json` for pass/fail counts.

## Troubleshooting

- **AutoHotkey not found:** rerun the installer; ensure `.ahk` files are associated.  
- **Bridge offline:** ensure the bridge is running (tray or `ScriptletCOMBridge.ahk`). Dashboard at `http://127.0.0.1:10764/dashboard`. Launcher may not report "live" but the webapp works. “”  
- **Popups hanging:** ensure every new scriptlet uses timed `MsgBox` or non-blocking alerts.  
- **Permissions:** if a script needs admin rights, document it in the header and use `Run("*RunAs", ...)` carefully.

## Keeping Up To Date

- Pull latest changes or sync the ZIP regularly.  
- Run the harness after significant edits.  
- Update metadata (`@version`, `@description`, `@hotkeys`) so the launcher stays accurate.  
- Sweep for repeated bug patterns whenever you fix one—Rule #7 in `.cursorrules`.

Done correctly, setup is a once-off effort. The rest of the time, you launch scriptlets, watch logs, and keep grinding down issues.


