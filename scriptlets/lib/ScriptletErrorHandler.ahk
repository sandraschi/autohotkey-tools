#Requires AutoHotkey v2.0+

class ScriptletErrorHandler {
    static logDir := ""

    static Handle(Thrown, Mode) {
        scriptName := RegExReplace(A_ScriptName, "\.ahk$", "", , 1)
        ScriptletErrorHandler.EnsureLogDirectory()

        timestamp := ""
        timestamp := FormatTime(, "yyyy-MM-dd HH:mm:ss")
        severity := Mode ? Mode : "Runtime"
        message := Thrown && HasProp(Thrown, "Message") ? Thrown.Message : "Unknown error"
        fileInfo := ""
        if (Thrown && HasProp(Thrown, "File") && Thrown.File) {
            fileInfo := Thrown.File
        } else {
            fileInfo := A_ScriptFullPath
        }
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
            ; Ignore tray errors
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
            ; Ignore write failures
        }
    }
}

LogError(Thrown, Mode) {
    return ScriptletErrorHandler.Handle(Thrown, Mode)
}

