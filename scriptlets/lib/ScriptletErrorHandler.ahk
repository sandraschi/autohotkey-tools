#Requires AutoHotkey v2.0+

; === Guard: catch parse-time errors (before class definition resolves) ===
__SHE_Guard(Thrown, Mode) {
    msg := Thrown && HasProp(Thrown, "Message") ? Thrown.Message : "Unknown"
    fPath := Thrown && HasProp(Thrown, "File") ? Thrown.File : A_ScriptFullPath
    line := Thrown && HasProp(Thrown, "Line") ? Thrown.Line : "?"
    try FileAppend("[" A_Now "] " fPath ":" line " — " msg "`n", A_ScriptDir "\crash.log")
    return 1
}
OnError(__SHE_Guard)

class ScriptletErrorHandler {
    static logDir := ""

    static Handle(Thrown, Mode) {
        scriptName := RegExReplace(A_ScriptName, "\.ahk$", "", , 1)
        ScriptletErrorHandler.EnsureLogDirectory()

        timestamp := FormatTime(A_Now, "yyyy-MM-dd HH:mm:ss")
        severity := Mode ? Mode : "Runtime"
        message := Thrown && HasProp(Thrown, "Message") ? Thrown.Message : "Unknown error"
        fileInfo := Thrown && HasProp(Thrown, "File") && Thrown.File ? Thrown.File : A_ScriptFullPath
        lineInfo := Thrown && HasProp(Thrown, "Line") && Thrown.Line ? Thrown.Line : "unknown"

        logEntry := "[" . timestamp . "] [" . severity . "] " . scriptName . ": " . message
        logEntry .= "`n    File: " . fileInfo . " | Line: " . lineInfo

        if (Thrown && HasProp(Thrown, "Stack") && Thrown.Stack) {
            logEntry .= "`n    Stack:`n" . Thrown.Stack
        }
        logEntry .= "`n`n"

        ScriptletErrorHandler.WriteLog(scriptName, logEntry)
        OutputDebug(logEntry)

        try {
            TrayTip(scriptName . " Error", message, 10)
        } catch {
        }

        return 1
    }

    static EnsureLogDirectory() {
        if (!ScriptletErrorHandler.logDir) {
            baseDir := A_ScriptDir . "\logs"
            if (!DirExist(baseDir)) {
                DirCreate(baseDir)
            }
            ScriptletErrorHandler.logDir := baseDir
        }
    }

    static WriteLog(scriptName, logEntry) {
        if (!ScriptletErrorHandler.logDir) {
            ScriptletErrorHandler.EnsureLogDirectory()
        }
        logFile := ScriptletErrorHandler.logDir . "\" . scriptName . ".log"
        try {
            FileAppend(logEntry, logFile, "UTF-8")
        } catch {
        }
    }
}

; Full handler — re-register after class resolves
LogError(Thrown, Mode) {
    return ScriptletErrorHandler.Handle(Thrown, Mode)
}
OnError(LogError)
