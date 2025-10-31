# AutoHotkey v2 Modulo Operator Migration Guide

## 🚨 **Critical Syntax Change: Modulo Operator**

### **The Problem**
In AutoHotkey v2, the modulo operator `%` has been **completely removed** and replaced with the `Mod()` function. This is a **breaking change** that will cause syntax errors.

### **Error Messages You'll See**
```
Error: Missing ending "%"
Text: A_Index % 2 = 0
Line: 429
```

### **Files Fixed**
I found and fixed **3 instances** of this error in your codebase:

1. **`scriptlets/mcp_config_manager.ahk`** - Line 429
2. **`scriptlets/mcp_troubleshooter.ahk`** - Line 115  
3. **`scriptlets/classic_frogger.ahk`** - Line 261

## 🔧 **Migration Rules**

### **Before (v1 syntax):**
```ahk
if (A_Index % 2 = 0) {
    ; Even index
}

if (number % 3 = 0) {
    ; Divisible by 3
}

remainder := 10 % 4  ; Returns 2
```

### **After (v2 syntax):**
```ahk
if (Mod(A_Index, 2) = 0) {
    ; Even index
}

if (Mod(number, 3) = 0) {
    ; Divisible by 3
}

remainder := Mod(10, 4)  ; Returns 2
```

## 📋 **Complete Migration Table**

| v1 Syntax | v2 Syntax | Description |
|-----------|-----------|-------------|
| `x % y` | `Mod(x, y)` | Modulo operation |
| `5 % 3` | `Mod(5, 3)` | Returns 2 |
| `A_Index % 2` | `Mod(A_Index, 2)` | Check if even/odd |
| `level % 3` | `Mod(level, 3)` | Check divisibility |

## 🔍 **How to Find These Errors**

### **Search Pattern:**
```bash
# Search for modulo operator usage
grep -r "\w\+\s*%\s*\w\+" scriptlets/
```

### **Common Patterns to Look For:**
- `A_Index % 2` - Checking even/odd
- `number % 3` - Checking divisibility
- `level % 5` - Periodic operations
- `counter % 10` - Every Nth iteration

## 🛠️ **Automated Fix Script**

Here's a script to automatically fix modulo operators:

```ahk
; AutoHotkey v2 Modulo Fixer
FixModuloOperators(filePath) {
    try {
        content := FileRead(filePath)
        
        ; Replace modulo operators with Mod() function
        fixedContent := RegExReplace(content, "(\w+)\s*%\s*(\w+)", "Mod($1, $2)")
        
        ; Write back to file
        FileWrite(fixedContent, filePath)
        
        MsgBox("Fixed modulo operators in: " . filePath, "Success", "Iconi")
    } catch as e {
        MsgBox("Error fixing file: " . e.Message, "Error", "Iconx")
    }
}
```

## ⚠️ **Important Notes**

### **1. Function vs Operator**
- **v1:** `%` was an **operator**
- **v2:** `Mod()` is a **function**
- **Parentheses are required** in v2

### **2. Precedence Changes**
```ahk
; v1 (operator precedence)
result := 10 + 5 % 3  ; = 10 + 2 = 12

; v2 (function call)
result := 10 + Mod(5, 3)  ; = 10 + 2 = 12
```

### **3. Edge Cases**
```ahk
; Negative numbers
Mod(-5, 3)   ; Returns 1 (not -2)
Mod(5, -3)   ; Returns -1

; Zero divisor
Mod(5, 0)    ; Error: Division by zero
```

## 🧪 **Testing Your Fixes**

### **Test Cases:**
```ahk
; Test even/odd detection
if (Mod(4, 2) = 0) {
    MsgBox("4 is even")  ; Should show
}

; Test divisibility
if (Mod(9, 3) = 0) {
    MsgBox("9 is divisible by 3")  ; Should show
}

; Test remainder
remainder := Mod(17, 5)
MsgBox("17 % 5 = " . remainder)  ; Should show 2
```

## 🔄 **Prevention Strategies**

### **1. Use AI Code Assistant**
The **AI Code Assistant** (`Ctrl+Alt+A`) can detect these issues:
- Paste your code
- Click "Debug" 
- It will identify v1 syntax issues

### **2. Regular Syntax Audits**
```bash
# Run this periodically to find modulo operators
grep -r "\w\+\s*%\s*\w\+" scriptlets/ --include="*.ahk"
```

### **3. IDE Integration**
- Use **VSCode with AutoHotkey v2 extension**
- Enable **syntax highlighting**
- Set up **linting rules**

## 📚 **Related v2 Changes**

While fixing modulo operators, also check for:

| v1 Syntax | v2 Syntax |
|-----------|-----------|
| `MsgBox text` | `MsgBox(text)` |
| `FileRead var, file` | `FileRead(var, file)` |
| `catch Error as e` | `catch as e` |
| `local var := value` | `var := value` |
| `global var` | `var := value` |

## ✅ **Verification Checklist**

After fixing modulo operators:

- [ ] **No syntax errors** when running scripts
- [ ] **Mathematical results** are correct
- [ ] **Logic flow** works as expected
- [ ] **Edge cases** are handled properly
- [ ] **Performance** is acceptable

## 🎯 **Summary**

The modulo operator `%` → `Mod()` function change is one of the **most common v1 to v2 migration issues**. Always:

1. **Search for `%`** in your code
2. **Replace with `Mod()`** function
3. **Test thoroughly** 
4. **Use AI tools** for detection
5. **Document changes** for team

This change affects **mathematical operations**, **loops**, **conditionals**, and **algorithmic logic** throughout your codebase.
















