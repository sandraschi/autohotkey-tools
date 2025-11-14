; ==============================================================================
; AutoHotkey Warning System
; @name: AutoHotkey Warning System
; @version: 1.0.0
; @description: Shows warning messages about AutoHotkey security and capabilities. Displays important security information about script execution risks.
; @description: Warns users about AutoHotkey's powerful capabilities including file access, application control, keystroke injection, and system modification.
; @description: Provides critical security awareness for users running AutoHotkey scripts, especially AI-generated or untrusted scripts.
; @category: utilities
; @author: Sandra
; @hotkeys: ^!w, F3
; @enabled: true
; @priority: 1
; @tag: security, warning, safety, awareness, utilities, education
; @cli: --show-once - Show warning only once (default behavior)
; @cli: --force-show - Force show warning even if already shown
; @cli: --skip-warning - Skip warning display (use with caution)
; @cli: --help - Show CLI usage and security information
; @dependencies: 
; ==============================================================================

#Requires AutoHotkey v2.0+
#SingleInstance Force
#Include %A_ScriptDir%\lib\ScriptletErrorHandler.ahk


; Suppress error popups - log to file instead
OnError(LogError)

class AutoHotkeyWarning {
    static warningCount := 0
    static maxWarnings := 1  ; Only show once
    static hasShownWarning := false
    
    static ShowWarning() {
        if (this.hasShownWarning) {
            return  ; Don't spam warnings
        }
        
        this.hasShownWarning := true
        
        warningText := "⚠️ AUTOHOTKEY SECURITY WARNING ⚠️`n`n"
        warningText .= "AutoHotkey can do ANYTHING on your computer:`n"
        warningText .= "• Access all files and folders`n"
        warningText .= "• Control other applications`n"
        warningText .= "• Send keystrokes and mouse clicks`n"
        warningText .= "• Access system settings`n"
        warningText .= "• Run commands as administrator`n`n"
        warningText .= "🚨 CRITICAL WARNINGS:`n"
        warningText .= "• Never run untrusted AutoHotkey scripts`n"
        warningText .= "• Review all scripts before running`n"
        warningText .= "• Be especially careful with AI-generated scripts`n"
        warningText .= "• AutoHotkey CANNOT read browser DOM content`n`n"
        warningText .= "✅ SAFE PRACTICES:`n"
        warningText .= "• Only run scripts from trusted sources`n"
        warningText .= "• Test scripts in a safe environment first`n"
        warningText .= "• Keep backups of important data`n"
        warningText .= "• Use antivirus software`n`n"
        warningText .= "Press OK to acknowledge this warning."
        
        MsgBox(warningText, "AutoHotkey Security Warning", "Icon!")
    }
    
    static ShowSpamWarning() {
        spamText := "🚨 AUTOHOTKEY SPAM WARNING 🚨`n`n"
        spamText .= "You're running multiple AutoHotkey scripts!`n`n"
        spamText .= "This can cause:`n"
        spamText .= "• Hotkey conflicts`n"
        spamText .= "• Performance issues`n"
        spamText .= "• Unexpected behavior`n"
        spamText .= "• System instability`n`n"
        spamText .= "💡 RECOMMENDATIONS:`n"
        spamText .= "• Close unnecessary scripts`n"
        spamText .= "• Use the web UI to manage running scriptlets`n"
        spamText .= "• Check for duplicate hotkeys`n"
        spamText .= "• Monitor system resources`n`n"
        spamText .= "Press OK to continue."
        
        MsgBox(spamText, "AutoHotkey Spam Warning", "Icon!")
    }
    
    static CheckRunningScripts() {
        ; Count running AutoHotkey processes
        runningCount := 0
        try {
            ; Use WMI to count AutoHotkey processes
            for process in ComObjGet("winmgmts:").ExecQuery("SELECT * FROM Win32_Process WHERE Name='AutoHotkey64.exe'") {
                runningCount++
            }
        } catch {
            ; Fallback method
            try {
                RunWait('tasklist /FI "IMAGENAME eq AutoHotkey64.exe" /FO CSV', , "Hide")
                ; This is a simplified check - in reality you'd parse the output
                runningCount := 3  ; Assume multiple running
            }
        }
        
        if (runningCount > 5) {
            this.ShowSpamWarning()
        }
    }
}

; Hotkeys
Hotkey("^!w", (*) => AutoHotkeyWarning.ShowWarning())
Hotkey("F3", (*) => AutoHotkeyWarning.ShowWarning())
Hotkey("^!s", (*) => AutoHotkeyWarning.ShowSpamWarning())

; Only show warning on first run, not automatically
; AutoHotkeyWarning.ShowWarning()

; Don't automatically check for spam - only on demand
; SetTimer(() => AutoHotkeyWarning.CheckRunningScripts(), 5000)
