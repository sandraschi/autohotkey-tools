#Requires AutoHotkey v2.0+
Loop 20 {
    Sleep 500
    hwnd := WinExist("Frogger")
    if (hwnd) { break }
}
if !hwnd { FileAppend("FAIL: no window`n","frogger_test.txt"); ExitApp(1) }
Sleep 1000
; Click Start button
SendMessage(0x00F5, 0, 0, "Button1", "Frogger")  ; BM_CLICK
Sleep 2000
; Read board text (Static2 is the board)
text := ControlGetText("Static2", "Frogger")
if (text != "" && InStr(text, "G")) {
    FileAppend("PASS`n","frogger_test.txt")
    FileAppend(text,"frogger_test.txt")
} else {
    FileAppend("FAIL: [" text "]`n","frogger_test.txt")
}
ExitApp(0)
