# Create new AutoHotkey scriptlet with full workflow
# Usage: .\create_new_script.ps1 -Name "My Script" -Description "Does something"

param(
    [Parameter(Mandatory=$true)]
    [string]$Name,
    
    [Parameter(Mandatory=$true)]
    [string]$Description,
    
    [string]$Category = "utility",
    [string]$Template = "basic",
    [string]$Code = "",
    [string]$Hotkeys = ""
)

Write-Host "hi! Creating new AutoHotkey scriptlet: $Name" -ForegroundColor Cyan

# Step 1: Generate clean v2 script template
Write-Host "`n[1/4] Generating script..." -ForegroundColor Yellow

$filename = ($Name -replace " ", "_").ToLower() + ".ahk"
$filePath = "scriptlets\$filename"

# Delete if exists
if (Test-Path $filePath) {
    Remove-Item $filePath -Force
    Write-Host "  - Removed existing file" -ForegroundColor Gray
}

# Create script content
$content = @"
#Requires AutoHotkey v2.0+
#SingleInstance Force
#Warn

; ==============================================================================
; $Name
; @name: $Name
; @version: 1.0.0
; @description: $Description
; @category: $Category
; @author: Sandra
; @hotkeys: $Hotkeys
; @enabled: true
; ==============================================================================

; Error handling - log to file instead of showing popups
OnError(LogError)

LogError(Thrown, Mode) {
    errorMsg := "Error: " . Thrown.Message . " at line " . Thrown.Line . "`n" . Thrown.Stack
    FileAppend(errorMsg, "${filename}_errors.log", "UTF-8")
    OutputDebug(errorMsg)  ; Enable LLM debugging
    return 1  ; Suppress popup (1 = suppress, 0 = show)
}

; =============================================================================
; MAIN SCRIPT
; =============================================================================
SetWorkingDir A_ScriptDir

; $Code

; Initialize
Initialize()

; =============================================================================
; FUNCTIONS
; =============================================================================
Initialize() {
    ; Add initialization code here
}
"@

# Write to file
$content | Out-File -FilePath $filePath -Encoding UTF8 -NoNewline
Write-Host "  ✓ Script created: $filePath" -ForegroundColor Green

# Step 2: Auto-fix
Write-Host "`n[2/4] Auto-fixing..." -ForegroundColor Yellow
$fixResult = & autohotkey.exe /ErrorStdOut utils\autofix_engine.ahk "$filePath" 2>&1
if ($LASTEXITCODE -eq 0) {
    Write-Host "  ✓ Auto-fixes applied" -ForegroundColor Green
} else {
    Write-Host "  ⚠ Auto-fix issues" -ForegroundColor Yellow
    Write-Host $fixResult -ForegroundColor Gray
}

# Step 3: Lint
Write-Host "`n[3/4] Linting..." -ForegroundColor Yellow
$lintResult = & autohotkey.exe /ErrorStdOut utils\linter.ahk "$filePath" 2>&1
if ($LASTEXITCODE -eq 0) {
    Write-Host "  ✓ Linting passed" -ForegroundColor Green
} else {
    Write-Host "  ⚠ Linting issues found:" -ForegroundColor Yellow
    Write-Host $lintResult -ForegroundColor Gray
}

# Step 4: Test execution
Write-Host "`n[4/4] Testing execution..." -ForegroundColor Yellow
$testResult = & autohotkey.exe /ErrorStdOut "$filePath" 2>&1
if ($LASTEXITCODE -eq 0) {
    Write-Host "  ✓ Script executes cleanly" -ForegroundColor Green
} else {
    Write-Host "  ⚠ Execution issues:" -ForegroundColor Yellow
    Write-Host $testResult -ForegroundColor Gray
}

# Summary
Write-Host "`n" -NoNewline
Write-Host "========================================" -ForegroundColor Green
Write-Host "Scriptlet created successfully!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host "File: $filePath" -ForegroundColor White
Write-Host "Next: Edit the script and add your functionality" -ForegroundColor Yellow
Write-Host ""



