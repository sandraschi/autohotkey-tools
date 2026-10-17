#Requires AutoHotkey v2.0+
#SingleInstance Force

; === Guard: catch parse-time errors (BEFORE any class/func/global) ===
_CatchBootError(Thrown, Mode) {
    msg := Thrown && HasProp(Thrown, "Message") ? Thrown.Message : "Unknown"
    fPath := Thrown && HasProp(Thrown, "File") ? Thrown.File : A_ScriptFullPath
    line := Thrown && HasProp(Thrown, "Line") ? Thrown.Line : "?"
    try FileAppend("[" A_Now "] " fPath ":" line " -- " msg "`n", A_ScriptDir "\typo_watcher.log")
    return 1
}
OnError(_CatchBootError)

; ==============================================================================
; @name: OpenCode Typo Watcher
; @version: 1.0.0
; @description: Keystroke-level autocorrect scoped to OpenCode.exe: classic
; @description: transpositions plus Sandra's personal list. Fires on word
; @description: end-chars (space, comma, period, Enter). Toggle stats with ^!t.
; @category: utilities
; @author: Sandra
; @hotkeys: ^!t stats
; @tag: opencode, spellcheck, typo, autocorrect, rustdesk
; ==============================================================================
;
; Why this exists: the OpenCode TUI has no spellcheck, browser spellcheck
; does not apply to OpenCode.exe, and TUI plugins (v1.18.x) can only toast,
; not underline. This runs on Goliath where the keystrokes land, so it
; works over RustDesk too. Launch/kill via the scriptlet dashboard like
; any other scriptlet. Edit the PERSONAL section below freely.

; Scoped: only inside the OpenCode window. Nothing fires elsewhere.
#HotIf WinActive("ahk_exe OpenCode.exe")

; --- Classics: transpositions and doubled letters (need an end-char) ---
::teh::the
::adn::and
::nad::and
::taht::that
::thier::their
::recieve::receive
::seperate::separate
::definately::definitely
::neccessary::necessary
::occured::occurred
::tommorow::tomorrow
::writting::writing
::comming::coming
::arguement::argument
::calender::calendar
::noticable::noticeable
::wich::which
::happend::happened
::chekc::check
::grammer::grammar

; --- PERSONAL: caught live over RustDesk, 2026-10-16 ---
; (batch 2: the bug report demonstrated the bug - these came from Sandra's
; own messages. :C: = case-sensitive, so AMD/OS-the-company still survive.)
::npw::now
::na,e::name
::commot::common
:C:os::of
:C:amd::and
::demonstratig::demonstrating
::annpyance::annoyance
::mpre::more
::documemt::document
::npt::not
::umderlined::underlined
::becdesperate::be desperate
::imteresting::interesting
::mornimg::morning
::gmini::gemini
::analyzin::analyzing

#HotIf

; --- Stats toast (global hotkey, works anywhere) ---
Hotkey("^!t", ShowStats)

ShowStats(*) {
    if WinActive("ahk_exe OpenCode.exe") {
        ShowToast("Typo watcher armed for this window")
    } else {
        ShowToast("Typo watcher running (fires only in OpenCode.exe)")
    }
}

; --- Toast notification ---
ShowToast(msg) {
    ToolTip(msg)
    SetTimer(() => ToolTip(), -2000)
}

; --- Error logging (overrides boot guard after parse completes) ---
LogError(exception, mode) {
    msg := exception && HasProp(exception, "Message") ? exception.Message : "Unknown"
    fPath := exception && HasProp(exception, "File") ? exception.File : A_ScriptFullPath
    line := exception && HasProp(exception, "Line") ? exception.Line : "?"
    try FileAppend("[" A_Now "] " fPath ":" line " -- " msg "`n", A_ScriptDir "\typo_watcher.log")
    return 1
}
OnError(LogError)
