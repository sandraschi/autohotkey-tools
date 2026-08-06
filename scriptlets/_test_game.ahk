#Requires AutoHotkey v2.0+
#SingleInstance Force
SetWorkingDir(A_ScriptDir)

; Test: launch frogger, click Start, verify Tick fires
Run("Classic Frogger.exe")  ; create shortcut or rename
Sleep 500

; Find the frogger window
hwnd := WinExist("Frogger")
if !hwnd {
    FileAppend("FAIL: window not found`n", "test_result.txt")
    ExitApp 1
}

; Click Start button (first button in the GUI)
ControlClick("Button1", "Frogger")
Sleep 1000

; Read the board control text
boardText := ""
try boardText := ControlGetText("Static2", "Frogger")
catch
    boardText := ""

if InStr(boardText, "F") || InStr(boardText, "G") || InStr(boardText, "C") {
    FileAppend("PASS: game board rendered`n", "test_result.txt")
    FileAppend("Board: " boardText "`n", "test_result.txt")
} else {
    FileAppend("FAIL: board not rendered, text=" boardText "`n", "test_result.txt")
}

Sleep 2000
boardText2 := ControlGetText("Static2", "Frogger")
if (boardText != boardText2) {
    FileAppend("PASS: board changed (Tick fired)`n", "test_result.txt")
} else {
    FileAppend("WARN: board unchanged (Tick may not fire)`n", "test_result.txt")
}

; Close
WinClose("Frogger")
ExitApp 0
