# Scriptlet Catalogue (Snapshot)

This section lists the most actively maintained scriptlets. Each one follows the v2 ruleset: metadata header, logging, timed notifications, and safe hotkeys.

## Productivity & Automation

- **Smart Assistant Pro** – configurable workflows, quick command palette, voice-toggle stub.  
- **Workflow Automator Pro** – trigger-based sequences with logging, status bar, and pause/resume.  
- **Quick Notes** – markdown editor with autosave, backups, search, and export.  
- **Clipboard Manager** – history, pinning, and preview; `Win+V` to open, `Ctrl+Alt+C` to copy.

## Development Utilities

- **MCP Log Analyzer** – scan Claude Desktop logs, filter by severity, produce recommendations.  
- **MCP Server Scaffolding** – generate FastMCP-ready skeletons, JSON config, and logging stubs.  
- **Code Formatter Pro** – multi-language formatting / validation, diff preview, live stats.  
- **Git Assistant Pro** – status dashboard, staged diff preview, guided commit templates.

## System Tools

- **Window Manager Pro** – snapping presets, multi-monitor helpers, window history.  
- **Music Controller Pro** – playlist manager with progress display, shuffle, and hotkeys.  
- **System Monitor Pro** – CPU, RAM, GPU metrics with alerts and log view.  
- **Claude Desktop Restart Helper** – graceful restart workflow with fallback kill + relaunch.

## Games & Experiments

- **Snake (Fun Games)** – arrow-key control, status bar, pause, emergency stop.  
- **Pac-Man Classic** – mini maze with ghost AI and hotkey controls.  
- **Tetris Classic** – rotation, next-piece preview, score logging.  
- **Classic Pranks (opt-in)** – fake BSOD, cursor swap, screen flip; only runs on request.

## What Every Scriptlet Shares

1. `OnError(LogError)` wired to `ScriptletErrorHandler`.  
2. Dedicated log file in `scriptlets\logs\`.  
3. Metadata header including name, version, hotkeys, tags, and CLI switches.  
4. F9 emergency stop and Escape-to-close (for GUIs).  
5. Timer clean-up and object disposal in error paths.

Consult the repo for additional scriptlets—new ones appear regularly as we continue burning down the rewrite backlog. If you add a scriptlet, mirror these conventions so the harness and launcher pick it up automatically.

