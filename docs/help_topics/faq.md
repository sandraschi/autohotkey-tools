# FAQ – Quick Answers

### Do I need to learn AutoHotkey to use this?
No. Every scriptlet is self-contained with GUI/help text. Learning v2 syntax helps if you plan to contribute, but day-to-day usage relies on hotkeys and buttons.

### Why the obsession with AutoHotkey v2?
Legacy v1 syntax caused thousands of lint failures. V2 enforces clarity (function calls, proper error handling) and plays nicer with modern tooling. All new code must be v2-compliant.

### Where do logs go?
Each scriptlet writes to `scriptlets\logs\<script>.log`. Harness logs live in `logs\bugbash\`. The shared `ScriptletErrorHandler` handles timestamping and UTF-8 encoding.

### Harness says “script path first” — what does that mean?
PowerShell must launch AutoHotkey as `AutoHotkey.exe "<script>" /ErrorStdOut /Warn All,Off`. If switches appear before the script path, AutoHotkey treats them as files and everything fails.

### I fixed a bug in one scriptlet. Am I done?
No. Rule #7 in `.cursorrules`: when you discover a bad pattern, sweep the repo and fix every instance in the same pass. The lint count only drops when patterns disappear everywhere.

### Hotkeys aren’t working.
- Ensure AutoHotkey is running (`plugin_loader` tray icon).  
- Check the scriptlet header for the correct combination.  
- Confirm no other app already owns that shortcut.  
- Re-run the harness; if it fails, read the script log.

### How do I stop a runaway script?
Press `F9` (mandatory emergency stop) or close the script window. If the process still hangs, the harness or task manager will kill it after timeout.

### Can I add new docs?
Yes. Drop Markdown files into `docs/help_topics/` and register them in `help_system_pro.ahk`. Keep the tone practical, emphasise error handling, and document hotkeys/cleanup steps.

### Where do I get more help?
- `Ctrl+Alt+H` opens this window.  
- The cloned AutoHotkey manual lives in `AutoHotkeyDocs/`.  
- Lint output is your friend—run it whenever you touch a file.

