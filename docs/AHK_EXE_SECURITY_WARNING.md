# AutoHotkey EXE Security Warning

**CRITICAL:** AHK compiled executables with UAC elevation are a **severe malware vector**.

---

## The Risk

When you compile an AHK script to .exe and it requests UAC elevation (Run as Administrator):

```
┌─────────────────────────────────────────────┐
│  User receives "helpful_tool.exe" by email  │
│                    ↓                        │
│  Double-clicks, UAC prompt appears          │
│                    ↓                        │
│  User clicks "Yes" (trusts sender)          │
│                    ↓                        │
│  Script now has FULL ADMIN ACCESS           │
│  - Install malware                          │
│  - Modify system files                      │
│  - Disable antivirus                        │
│  - Create backdoors                         │
│  - Encrypt files (ransomware)               │
│  - Exfiltrate data                          │
└─────────────────────────────────────────────┘
```

## Why AHK EXEs Are Attractive to Attackers

1. **Looks legitimate** - "It's just a script from my nephew"
2. **Bypasses email filters** - Not a known malware signature
3. **Full system access** - AHK can do anything Windows can
4. **Easy to modify** - Attackers can wrap malicious code in helpful-looking tools
5. **Trust exploitation** - Family/friends share tools via email

## Safe Practices

### For Script Authors

1. **Never request UAC unless absolutely necessary**
   ```ahk
   ; DON'T do this unless you really need admin
   ; #Requires AutoHotkey v2.0
   ; #SingleInstance Force
   ; if !A_IsAdmin
   ;     Run '*RunAs "' A_ScriptFullPath '"'
   ```

2. **Sign your executables** - Code signing certificates prove authorship

3. **Provide source code** - Let recipients inspect before running

4. **Use checksums** - Provide SHA256 hash for verification

### For Recipients

1. **NEVER run .exe from unknown sources**
2. **Ask for source code** (.ahk file) instead
3. **Run in sandbox/VM first** if suspicious
4. **Check with sender** via separate channel (phone)
5. **Scan with antivirus** before running

## The "Aunt Edna" Scenario

Sending cleanup tools to family is legitimate, but:

```
GOOD:
- Send .ahk source file + instructions to install AHK
- Use established remote support (TeamViewer, etc.)
- Walk through on phone while they run it

RISKY:
- Sending .exe via email (even if you made it)
- Requesting UAC elevation
- Running automatically without explanation
```

## Legitimate Admin-Required Tools

Some tools genuinely need admin access:

- System cleanup (temp files in protected locations)
- Malware removal (needs to kill protected processes)
- Registry repairs
- Service management

**For these:** Document WHY admin is needed, provide source code, and consider using established tools (Malwarebytes, etc.) instead.

---

## Summary

| Risk Level | Scenario |
|------------|----------|
| 🟢 Low | .ahk source file, no admin needed |
| 🟡 Medium | .exe without admin, from trusted source |
| 🔴 High | .exe with admin request, via email |
| ☠️ Critical | .exe with admin, unknown source |

**Default stance:** Treat any .exe requesting admin as potentially malicious until verified.

