# Web Interface Cheat Sheet

The modern launcher lives in `launcher_enhanced.html`. It discovers metadata in `scriptlets/`, calls the COM bridge, and renders a dashboard.

## Layout

- **Header:** connection status, theme toggle, settings button.  
- **Search Bar:** type ahead, `Ctrl+F` focus, shows categories instantly.  
- **Category Tabs:** Utilities, Development, Media, Games, AI, plus “All”.  
- **Cards:** display name, description, author, hotkeys, and enable state.  
- **Status Panel:** running count, total scriptlets, recent errors pulled from logs.

## Interaction Shortcuts

| Shortcut | Action |
| -------- | ------ |
| `Ctrl+K` | Command palette (toggle scriptlets, open settings, refresh). |
| `Ctrl+F` | Focus the search bar. |
| `Enter`  | Toggle highlighted scriptlet. |
| `Esc`    | Close dialogs / palettes. |
| `R`      | Refresh status from `/status`. |

## Theme & Display

- Dark, Light, and Auto (follows OS).  
- Adjustable card density and font scale.  
- Persisted to `localStorage`, so preferences survive restarts.

## Integration With The Harness

- Status badges reflect harness results (pass, warning, fail).  
- Clicking the badge opens the relevant log file.  
- Pending rewrites are tagged with “needs love” to surface tech-debt quickly.

## Troubleshooting

1. If nothing loads, ensure the PowerShell bridge is running (`plugin_loader` tray icon).  
2. Use browser dev tools to inspect fetch calls (should point to `http://localhost:8765`).  
3. Verify the scriptlet metadata contains valid JSON; malformed fields are ignored.  
4. Run the harness manually when stats look stale.

Remember: the launcher is the friendly face, but quality comes from the scriptlets and harness underneath. Keep metadata up to date—users rely on it here.

