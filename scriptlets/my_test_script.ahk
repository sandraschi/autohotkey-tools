#Requires AutoHotkey v2.0+
#SingleInstance Force
#Include %A_ScriptDir%\lib\ScriptletErrorHandler.ahk
#Warn

; ==============================================================================
; My Test Script
; @name: My Test Script
; @version: 1.0.0
; @description: Tests the full workflow without popups or errors
; @category: utility
; @author: Sandra
; @hotkeys: 
; @enabled: true
; ==============================================================================

; Error handling - log to file instead of showing popups
OnError(LogError)

; =============================================================================
; MAIN SCRIPT
; =============================================================================
SetWorkingDir A_ScriptDir

; 

; Initialize
Initialize()

; =============================================================================
; FUNCTIONS
; =============================================================================
Initialize() {
    ; Add initialization code here
}