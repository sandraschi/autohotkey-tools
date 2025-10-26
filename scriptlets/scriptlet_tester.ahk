; ==============================================================================
; Scriptlet Tester
; @name: Scriptlet Tester
; @version: 1.0.0
; @description: Tests scriptlets and shows syntax errors
; @category: utilities
; @author: Sandra
; @hotkeys: ^!t
; @enabled: true
; ==============================================================================

#Requires AutoHotkey v2.0+
#SingleInstance Force

class ScriptletTester {
    static TestScriptlet(scriptPath) {
        if (!FileExist(scriptPath)) {
            MsgBox("Script not found: " . scriptPath, "Test Error", "Icon!")
            return
        }
        
        ; Create a test command
        testCmd := '"' . A_AhkPath . '" /ErrorStdOut "' . scriptPath . '"'
        
        try {
            ; Run the script and capture output
            result := RunWait(testCmd, , "Hide")
            
            if (result = 0) {
                MsgBox("✅ Script syntax is valid: " . scriptPath, "Test Result", "Iconi")
            } else {
                MsgBox("❌ Script has errors (exit code: " . result . "): " . scriptPath . "`n`nCheck the script for syntax issues.", "Test Result", "Icon!")
            }
        } catch as e {
            MsgBox("Test failed: " . e.Message, "Test Error", "Icon!")
        }
    }
    
    static TestAllScriptlets() {
        scriptletsDir := A_ScriptDir . "\scriptlets"
        if (!DirExist(scriptletsDir)) {
            MsgBox("Scriptlets directory not found: " . scriptletsDir, "Test Error", "Icon!")
            return
        }
        
        results := []
        Loop Files, scriptletsDir . "\*.ahk" {
            scriptPath := A_LoopFilePath
            scriptName := A_LoopFileName
            
            ; Test the script
            testCmd := '"' . A_AhkPath . '" /ErrorStdOut "' . scriptPath . '"'
            
            try {
                result := RunWait(testCmd, , "Hide")
                if (result = 0) {
                    results.Push("✅ " . scriptName . " - OK")
                } else {
                    results.Push("❌ " . scriptName . " - ERROR (code: " . result . ")")
                }
            } catch {
                results.Push("❌ " . scriptName . " - FAILED")
            }
        }
        
        ; Show results
        resultText := "🔍 SCRIPTLET TEST RESULTS 🔍`n`n"
        resultText .= "Total scripts tested: " . results.Length . "`n`n"
        
        for result in results {
            resultText .= result . "`n"
        }
        
        MsgBox(resultText, "Test Results", "Iconi")
    }
    
    static ShowQuickFix() {
        fixText := "🔧 QUICK FIX GUIDE 🔧`n`n"
        fixText .= "Most common AutoHotkey v2 fixes:`n`n"
        fixText .= "1. String concatenation:`n"
        fixText .= "   Change: `"text`" variable`n"
        fixText .= "   To: `"text`" . variable`n`n"
        fixText .= "2. Function calls:`n"
        fixText .= "   Change: FileRead var, file`n"
        fixText .= "   To: var := FileRead(file)`n`n"
        fixText .= "3. Global variables:`n"
        fixText .= "   Change: global var1, var2`n"
        fixText .= "   To: var1 := `"`"`n"
        fixText .= "         var2 := `"`"`n`n"
        fixText .= "4. Exception handling:`n"
        fixText .= "   Change: catch Error as e`n"
        fixText .= "   To: catch as e`n`n"
        fixText .= "5. Reserved words:`n"
        fixText .= "   Avoid using 'continue' as variable name`n`n"
        fixText .= "Press OK to continue."
        
        MsgBox(fixText, "Quick Fix Guide", "Iconi")
    }
}

; Hotkeys
^!Hotkey("t", (*) => ScriptletTester.TestAllScriptlets()
^!f::ScriptletTester.ShowQuickFix()

; Test specific scriptlet (you can change this)
; ScriptletTester.TestScriptlet(A_ScriptDir . "\scriptlets\system_monitor.ahk")

