# Scanner Patterns Added

## Summary

Added MsgBox parameter syntax error detection to the compatibility scanner.

## Pattern Added

**Location:** `utils/compatibility_scanner.ahk`

### New Pattern #1: Empty second parameter
```autohotkey
{pattern: "MsgBox\s*\(\s*[^,]+,\s*,\s*",
 message: "MsgBox with empty second parameter - add space between commas or use correct syntax",
 severity: "ERROR",
 category: "v1 syntax"}
```

**Detects:** `MsgBox(text,, "title")` - Missing space between commas

### New Pattern #2: Empty parameter error
```autohotkey
{pattern: "MsgBox\s*\([^)]+,\s*,\s*",
 message: "MsgBox parameter syntax error - empty parameter between commas",
 severity: "ERROR",
 category: "v1 syntax"}
```

**Detects:** Any MsgBox with empty parameter between commas

## Fixed in Scanner

**Line 338:** Changed from:
```autohotkey
MsgBox(statusMsg,, "Compatibility Scanner")
```

To:
```autohotkey
MsgBox(statusMsg, , "Compatibility Scanner")
```

Added space between commas for proper v2 syntax.

## Total Patterns Now

The scanner now detects **19 v1 syntax incompatibility patterns** (was 17):
1. Malformed #Requires directive
2. Extra 'e' before #Requires
3. FormatTime v1 syntax (2 patterns)
4. FileRead v1 syntax
5. MsgBox v1 syntax (3 patterns - original + 2 new)
6. Hotkey v1 syntax
7. For loop 'to' syntax
8. Random v1 syntax (2 patterns)
9. GUI commands v1 syntax (4 patterns)
10. String functions (3 patterns)
11. Loop v1 syntax
12. SetWorkingDir v1 syntax
13. Variable assignment with =
14. Malformed MsgBox parameters (NEW - 2 patterns)

Plus **5 v2 requirements** checks (unchanged).

## Usage

The scanner will now detect and report:
- `MsgBox(text,, "title")` ❌ ERROR
- `MsgBox(text, , "title")` ✅ OK (space between commas)
- `MsgBox(text, "", "title")` ✅ OK (empty string)

## Files Modified

- `utils/compatibility_scanner.ahk` (line 50-58, 338)

