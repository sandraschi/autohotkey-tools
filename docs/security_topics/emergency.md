# Emergency Security Procedures - When Things Go Wrong

A runaway or hostile script is a WHEN, not an IF. Drill this once
so your hands know it before your brain has to think.

## Stop it NOW (in order)

1. **Tray first.** Right-click the AutoHotkey tray icon (green "H")
   and choose Suspend Hotkeys, then Exit. Every depot scriptlet
   keeps its tray icon visible for exactly this reason.
2. **Task Manager.** `Ctrl+Shift+Esc` > Details > kill
   `AutoHotkey64.exe` (one entry per running scriptlet).
3. **Command line.** If the GUI is wedged:
   `taskkill /F /IM AutoHotkey64.exe`
4. **Nuclear.** If input is fully hijacked (mouse/keyboard stolen
   by the script): hard power-off. Unsaved work is cheaper than a
   script with ten more minutes.

## After a suspicious script ran

1. **Disconnect the network.** Pull the cable / airplane mode.
   Stops exfiltration and second-stage downloads cold.
2. **Do not log into anything.** Assume keystrokes were watched.
3. **Full AV scan** with updated definitions, then a second
   opinion scanner.
4. **Check persistence spots** - this is where malware lives:
   - `shell:startup` folder
   - `HKCU\...\Run` and `HKCU\...\RunOnce` registry keys
   - Task Scheduler Library (look for new/odd tasks)
   - `scriptlets\` itself - verify `git status` is clean
5. **Rotate credentials** typed or stored on the machine, from a
   CLEAN device.
6. **Restore from backup** if anything feels off. Reimage beats
   regret.

## Runaway-loop first aid (your own bug)

- Keep a global kill-switch hotkey while developing, e.g.
  `^!Esc::ExitApp` in a tiny always-on script.
- Prefer window-scoped hotkeys (`HotIf WinActive(...)`) so test
  keys do not fire while you type in your editor.
- Write logs to a file (`OutputDebug` / `FileAppend`), not
  `MsgBox` - a thousand stacked message boxes IS the emergency.

## Report it

File an issue with: script name + version, what you ran, what it
did, and the log tail. A bug fixed in one scriptlet gets audited
across the whole depot - your report protects everyone.
