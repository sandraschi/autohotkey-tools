; ==============================================================================
; Main Application Initialization and Command Line Handling
; ==============================================================================

; Include JSON utility
#Include json_utility.ahk

; ==============================================================================
; COMMAND LINE INTERFACE (for PowerShell server callbacks)
; ==============================================================================

HandleCommandLine() {
    if (A_Args.Length > 0) {
        command := A_Args[1]
        
        switch command {
            case "run":
                if (A_Args.Length > 1) {
                    result := g_ScriptletManager.RunScript(A_Args[2])
                    ; Output result for PowerShell to capture
                    if (result.success) {
                        FileAppend(JSON.stringify(result), A_Temp . "\bridge_result.json", "UTF-8")
                        ExitApp(0)
                    } else {
                        FileAppend(JSON.stringify(result), A_Temp . "\bridge_result.json", "UTF-8")
                        ExitApp(1)
                    }
                }
            
            case "stop":
                if (A_Args.Length > 1) {
                    result := g_ScriptletManager.StopScript(A_Args[2])
                    FileAppend(JSON.stringify(result), A_Temp . "\bridge_result.json", "UTF-8")
                    ExitApp(result.success ? 0 : 1)
                }
            
            case "list":
                result := g_ScriptletManager.ListRunningScripts()
                FileAppend(JSON.stringify(result), A_Temp . "\bridge_result.json", "UTF-8")
                ExitApp(result.success ? 0 : 1)
                
            case "info":
                if (A_Args.Length > 1) {
                    result := g_ScriptletManager.GetScriptInfo(A_Args[2])
                    FileAppend(JSON.stringify(result), A_Temp . "\bridge_result.json", "UTF-8")
                    ExitApp(result.success ? 0 : 1)
                }
        }
    }
    return false
}

; ==============================================================================
; MAIN APPLICATION STARTUP
; ==============================================================================

; Global bridge instance
g_Bridge := ""

; Main initialization
Main() {
    try {
        ; Check if we're being called from command line
        if (A_Args.Length > 0) {
            ; We need the bridge components for command line operations
            g_Logger := Logger()
            g_ScriptletManager := ScriptletManager(g_Logger)
            return HandleCommandLine()
        }
        
        ; Normal GUI startup
        g_Bridge := ScriptletBridge()
        
        ; Set up exit handler
        OnExit((*) => g_Bridge.Cleanup())
        
        ; Keep script running
        return true
        
    } catch as err {
        ; Emergency error handling
        errorMsg := "Critical startup error: " . err.Message
        try {
            FileAppend("[" . A_Now . "] CRITICAL: " . errorMsg . "`n", A_ScriptDir . "\emergency.log", "UTF-8")
        } catch {
            ; If even logging fails, just show message
        }
        
        MsgBox(errorMsg, "Scriptlet Bridge - Critical Error", 16)
        ExitApp(1)
    }
}

; Start the application
if (!Main()) {
    ExitApp(1)
}