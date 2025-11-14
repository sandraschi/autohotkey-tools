# Help System Pro – Overview

Welcome! This repository contains a curated collection of professional AutoHotkey v2 scriptlets that automate common workflows, boost productivity, and provide lightweight entertainment.

## Why Scriptlets Matter

- **Time savers:** repetitive steps become single key presses.  
- **Productivity boosters:** window management, note capture, and automation helpers.  
- **Fun extras:** mini games and easter-egg utilities for quick mental breaks.  
- **Composable:** scriptlets are independent; combine them to create your own workspace.

## Components At A Glance

| Area | What You Get | Highlights |
| ---- | ------------ | ---------- |
| **Automation** | Smart Assistant, Workflow Automator, Clipboard tools | Logging, error handling, GUI feedback |
| **Development** | Log analyzers, scaffolding helpers, code formatters | Strict v2 syntax, structured output |
| **System** | Window managers, media controls, restart helpers | Non-blocking alerts, safe hotkeys |
| **Fun** | Snake, Frogger, Pac-Man, pranks (opt-in) | Timed notifications, F9 emergency stop |

## How Everything Connects

1. **Scriptlets** live in `scriptlets/` and expose structured metadata.  
2. **Launchers** (web, plugin loader, direct hotkeys) discover metadata and surface features.  
3. **Utilities** such as the bugbash harness enforce consistency and catch regressions.  
4. **Documentation** (this help system + docs/) keeps behaviour transparent and repeatable.

## Quick Start

1. Install AutoHotkey v2.0+.  
2. Clone or unpack the repository.  
3. Run `plugin_loader.ahk` or double-click the scriptlet you need.  
4. Use the hotkeys listed in each header; press `F1` or `Ctrl+Alt+H` for help at any time.

## Culture & Expectations

- **Zero pop-up hangers:** every alert auto-dismisses.  
- **Repo-wide sweeps:** fix once, search everywhere.  
- **Logging first:** every scriptlet ships with a timestamped, UTF-8 log.  
- **V2 or bust:** no legacy syntax, no hidden race conditions, strict linting.

Explore the topic tabs in the help window to dive deeper into AutoHotkey basics, the COM bridge architecture, setup guides, and FAQs. We're still grinding down the error backlog—thanks for helping to keep quality high.

