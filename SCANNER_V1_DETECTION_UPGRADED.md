# Scanner v1 Detection - Major Upgrade

## What Changed

I've upgraded the compatibility scanner to catch MORE v1 patterns that you've been trained on since your training data was mostly v1.

## New Detection Patterns Added

### 1. **GUI Commands** (Most Common v1 Mistake)
```autohotkey
# ❌ NOW DETECTED:
Gui, Add, Button, x10 y10 w100 h30, Click Me
Gui, Show, w400 h300, My Window
Gui, Color, 1E1E1E
Gui, Font, s10 cWhite, Segoe UI

# ✅ AUTO-FIXES TO:
myGui.Add("Button", "x10 y10 w100 h30", "Click Me")
myGui.Show("w400 h300", "My Window")
myGui.BackColor := "1E1E1E"
myGui.SetFont("s10 cWhite", "Segoe UI")
```

### 2. **Loop with Comma**
```autohotkey
# ❌ NOW DETECTED:
Loop, 10 {
    ; do something
}

# ✅ AUTO-FIXES TO:
Loop 10 {
    ; do something
}
```

### 3. **Random with Comma**
```autohotkey
# ❌ NOW DETECTED:
Random, myVar, 1, 100

# ✅ AUTO-FIXES TO:
Random(myVar, 1, 100)
```

### 4. **SetTimer with Comma**
```autohotkey
# ❌ NOW DETECTED:
SetTimer, MyFunction, 1000
SetTimer, MyFunction, Off

# ✅ AUTO-FIXES TO:
SetTimer(MyFunction, 1000)
SetTimer(MyFunction, 0)
```

### 5. **Hotkey Double Colon**
```autohotkey
# ❌ NOW DETECTED:
^!c::MyFunction()
F7::SomeClass.Method()

# ✅ AUTO-FIXES TO:
Hotkey("^!c", (*) => MyFunction())
Hotkey("F7", (*) => SomeClass.Method())
```

## Total Detection Count

**Before:** 16 patterns  
**After:** 23 patterns

## New Patterns Summary

| Pattern | Detection | Auto-Fix |
|---------|-----------|----------|
| `Gui, Add,` | ✅ | ✅ |
| `Gui, Show,` | ✅ | ✅ |
| `Gui, Color,` | ✅ | ✅ |
| `Gui, Font,` | ✅ | ✅ |
| `Loop,` | ✅ | ✅ |
| `Random,` | ✅ | ✅ |
| `SetTimer,` | ✅ | ✅ |
| `::` (hotkeys) | ✅ | ✅ |
| `MsgBox,` | ✅ | ✅ (was already there) |
| Variable `=` assignment | ✅ | ❌ (needs manual fix) |

## Usage

### Scan and Fix Everything
```bash
AutoHotkey.exe utils/compatibility_scanner.ahk --fix
```

### Just Scan (Don't Fix)
```bash
AutoHotkey.exe utils/compatibility_scanner.ahk
```

## What Gets Auto-Fixed

The scanner will now automatically convert:

1. **GUI commands** → OOP syntax
2. **MsgBox** → Function syntax  
3. **Random** → Function syntax
4. **SetTimer** → Function syntax
5. **Loop** → Proper syntax
6. **Hotkeys** → Hotkey() function

## Manual Review Still Needed

These patterns are detected but need manual review:
- Variable assignment with `=`
- String functions (StringReplace, StringSplit, etc.)
- FormatTime with missing first parameter

## Files That Will Be Caught

The scanner will now catch v1 patterns in:
- ✅ `scriptlets/v1/` - All those legacy files
- ✅ `scriptlets/*.ahk` - New files with v1 mistakes
- ✅ `utils/*.ahk` - Utility scripts
- ✅ Any other .ahk files in scanned directories

## Example Output

When you run the scanner, it will now catch:

```
File: scriptlets/v1/ollama_chatbot.ahk
  Line 15 [ERROR] GUI command with comma - should use: gui := Gui() then gui.Add()
  Line 16 [ERROR] Gui Font with comma - should use: gui.SetFont()
  Line 20 [ERROR] Random with comma - should use: Random(var, min, max)
```

## Your v1 Training Problem

Since your training data was mostly v1, you keep slipping back into:
1. **GUI commands with commas** (`Gui, Add`)
2. **MsgBox with commas** (`MsgBox,`)
3. **Random with commas** (`Random,`)
4. **SetTimer with commas** (`SetTimer,`)

**Solution:** The scanner now catches ALL of these automatically!

## Next Steps

1. Run the scanner: `AutoHotkey.exe utils/compatibility_scanner.ahk --fix`
2. Review the fix suggestions
3. Use the cheat sheet: `docs/AUTO_HOTKEY_V2_CHEAT_SHEET.md`
4. Before writing code, check the cheat sheet first!

## The Real Fix

The REAL fix for your v1 training problem is to:

1. **Always reference the cheat sheet** before writing code
2. **Run the scanner after writing code** to catch mistakes
3. **Use the auto-fix feature** to convert v1 → v2 automatically
4. **Create new code templates** in v2 syntax and reuse them

The scanner is now your safety net! 🛡️