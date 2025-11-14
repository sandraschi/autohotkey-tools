# AutoHotkey Basics (v2)

AutoHotkey v2 is a modernised scripting language for Windows. We follow these non-negotiables:

- **Parentheses everywhere:** function style calls only.  
- **Explicit hotkeys:** `Hotkey("^!n", Callback)` instead of legacy label syntax.  
- **Structured error handling:** `try/catch` blocks and `OnError()` hooks in every scriptlet.  
- **UTF-8 logging:** append human-readable traces to `scriptlets\logs\*.log`.

## Core Building Blocks

```autohotkey
; functions
StartWorkflow(name) {
    MsgBox("Starting " . name, "Automation", "Iconi", 10)
}

; objects
workflow := Map("name", "Daily prep", "steps", ["browser", "notes", "focus"])

; GUIs
gui := Gui("+Resize +MinSize400x200", "Quick Demo")
gui.Add("Text", "w360", "AutoHotkey v2 is class-based and callback-driven.")
gui.Add("Button", "Default", "OK").OnEvent("Click", (*) => gui.Destroy())
gui.Show()
```

## Hotkey Patterns We Use

| Pattern | Usage | Notes |
| ------- | ----- | ----- |
| `Hotkey("^!b", (*) => Builder.Toggle())` | Register Ctrl+Alt+B | Always wrap in helper methods. |
| `Hotkey("F9", (*) => ScriptletEmergency.Stop())` | Emergency stop | Mandatory for long-running loops. |
| `Hotkey("^!h", HelpSystem.ShowWindow)` | Open help | Points back to this script. |

## Error Strategy

```autohotkey
OnError(LogError)

LogError(Thrown, Mode) {
    ScriptletErrorHandler.Handle(Thrown, Mode)
    return 1 ; suppress UI popups
}
```

- Wrap file, GUI, and system calls in `try/catch`.  
- Log both the message and stack; fall back to script path if `Thrown.File` is empty.  
- Surface user feedback through timed tooltips or status-bar text.

## Everyday Helpers

- `FormatTime(A_Now, "HH:mm:ss")` for timestamps.  
- `StrReplace`, `StrUpper`, `StrLower` for text transforms.  
- `DirSelect`, `FileSelect`, `FileOpen()` for user-initiated IO with safe fallbacks.  
- `SetTimer` with bound methods for background loops (`SetTimer(this.Tick.Bind(this), 1000)`).

If you need deeper coverage, open the official docs cloned at `AutoHotkeyDocs/`, especially the migration guide from v1 to v2. Every rewrite in this repo references those canonical rules.

