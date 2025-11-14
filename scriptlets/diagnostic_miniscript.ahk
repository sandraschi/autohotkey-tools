#Requires AutoHotkey v2.0+
#SingleInstance Force

try {
    MsgBox("Diagnostic miniscript loaded successfully.", "Harness Check", "Iconi")
} catch as e {
    FileAppend("Error: " . e.Message . "`n", "diagnostic_miniscript.log", "UTF-8")
}
