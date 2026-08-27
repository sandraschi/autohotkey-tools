# COM Bridge Architecture

The COM bridge lets our HTML launcher talk to AutoHotkey scriptlets. It removes guesswork and keeps a single source of truth for script status.

## Data Flow

```
Browser (launcher_enhanced.html)
      │  fetch /run/scriptlet
      ▼
PowerShell HTTP server (utils/scriptlet_bridge.ps1)
      │  Start-Process AutoHotkey.exe "<script>" /ErrorStdOut /Warn All,Off
      ▼
AutoHotkey Scriptlet (logs + GUI + hotkeys)
```

## Bridge Responsibilities

- Serve `/run`, `/stop`, `/status`, and `/dashboard` on **`http://127.0.0.1:10764`** (fleet port 10764). Single port only; zombie kill before bind.  
- Launch AutoHotkey with `/ErrorStdOut` and `/Warn All,Off`.  
- Enforce a strict timeout (default 10 s) and throttle (default 5 concurrent).  
- Terminate stray processes via `CloseMainWindow()` then `Kill()` if needed.  
- Persist harness logs to `logs\bugbash\harness_errors.log`.

## Scriptlet Contracts

Every scriptlet must:

1. Include structured metadata in the header (name, version, description, hotkeys).  
2. Register `OnError(LogError)` and send failures to `scriptlets\logs\<script>.log`.  
3. Avoid blocking dialogs—use timed `MsgBox` or custom tooltips/status bars.  
4. Provide an F9 escape hatch for loops or game timers.  
5. Clean up timers, GUI handles, and temp files during shutdown.

## Harness Expectations

- Statistics are recomputed after each run; stale counts are rejected.  
- Warning popups are suppressed; `WarnOptions` default to `All,Off`.  
- Scripts that spawn popups without timeouts fail the run.  
- Logs are parsed for “local variable has not been assigned” errors and similar v2 issues.

## Debug Tips

- If the bridge says “script path first”, confirm argument ordering in PowerShell.  
- Harness timeout errors usually mean the script never returned—add graceful exits.  
- When AutoHotkey logs complain about missing callbacks, sweep the repo for identical patterns and fix them all in one pass.

Use the bridge topic whenever you need to remember the launch pipeline or the forced command-line switches the harness applies.


