# AutoHotkey v2 GUI Syntax Fixer
# Applies all GUI syntax fixes to scriptlet files

$ErrorActionPreference = "Stop"

Write-Host "AutoHotkey v2 GUI Syntax Fixer" -ForegroundColor Cyan
Write-Host "================================" -ForegroundColor Cyan
Write-Host ""

$scriptletsDir = Join-Path $PSScriptRoot "..\scriptlets"
$fixed = 0
$skipped = 0

Get-ChildItem -Path $scriptletsDir -Filter "*.ahk" -Recurse | Where-Object { 
    $_.Name -notlike "*_v1*" -and $_.Name -notlike "*backup*"
} | ForEach-Object {
    $file = $_.FullName
    $content = Get-Content $file -Raw -Encoding UTF8
    $original = $content
    $changed = $false
    
    Write-Host "Processing: $($_.Name)" -ForegroundColor Yellow
    
    # Fix 1: OnError callback registration
    if ($content -match 'OnError\("LogError"\)') {
        $content = $content -replace 'OnError\("LogError"\)', 'OnError(LogError)'
        $changed = $true
        Write-Host "  ✓ Fixed OnError callback" -ForegroundColor Green
    }
    
    # Fix 2: LogError function signature and return
    if ($content -match 'LogError\(Exception,\s*Mode\)') {
        $content = $content -replace 'LogError\(Exception,\s*Mode\)', 'LogError(Thrown, Mode)'
        $content = $content -replace '(\s+errorMsg\s*:=\s*"Error:\s*")\.\s*Exception\.Message', '$1. Thrown.Message'
        $content = $content -replace '(\s+errorMsg\s*:=\s*.*)Exception\.Message', '$1Thrown.Message'
        $content = $content -replace '(\s+errorMsg\s*:=\s*.*)Exception\.Line', '$1Thrown.Line'
        $content = $content -replace '(\s+errorMsg\s*:=\s*.*)Exception\.Stack', '$1Thrown.Stack'
        $content = $content -replace 'Exception\.Message', 'Thrown.Message'
        $content = $content -replace 'Exception\.Line', 'Thrown.Line'
        $content = $content -replace 'Exception\.Stack', 'Thrown.Stack'
        $content = $content -replace '(\s+return\s+)true(\s+;.*Suppress.*popup)', '$11$2'
        $content = $content -replace '(\s+return\s+)true(\s+;.*Suppress)', '$11$2'
        $changed = $true
        Write-Host "  ✓ Fixed LogError signature" -ForegroundColor Green
    }
    
    # Fix 3: BackColor with 0x prefix
    if ($content -match 'BackColor\s*:=\s*"0x') {
        $content = $content -replace 'BackColor\s*:=\s*"0x([0-9a-fA-F]{6})"', 'BackColor := "$1"'
        $changed = $true
        Write-Host "  ✓ Fixed BackColor syntax" -ForegroundColor Green
    }
    
    # Fix 4: SetFont with cWhite
    if ($content -match 'SetFont\([^)]*cWhite') {
        $content = $content -replace 'SetFont\(([^,)]*),?\s*cWhite', 'SetFont($1cFFFFFF'
        $content = $content -replace 'SetFont\(([^,)]*),?\s*"([^"]*)\s+cWhite', 'SetFont($1"$2 cFFFFFF'
        $changed = $true
        Write-Host "  ✓ Fixed SetFont color" -ForegroundColor Green
    }
    
    # Fix 5: Color options in Add() strings (c0x...)
    if ($content -match 'c0x[0-9a-fA-F]{6}') {
        $content = $content -replace 'c0x([0-9a-fA-F]{6})', { param($m) 'c' + $m.Groups[1].Value.ToUpper() }
        $changed = $true
        Write-Host "  ✓ Fixed Add() color options" -ForegroundColor Green
    }
    
    # Fix 6: Edit controls with +Multi +VScroll
    if ($content -match '\.Add\("Edit".*\+Multi.*\+VScroll') {
        $content = $content -replace '(\+Multi)\s*(\+VScroll)', 'Multi VScroll'
        $changed = $true
        Write-Host "  ✓ Fixed Edit control options" -ForegroundColor Green
    }
    
    # Fix 7: Background with 0x in Add() options
    if ($content -match 'Background0x[0-9a-fA-F]{6}') {
        $content = $content -replace 'Background0x([0-9a-fA-F]{6})', { param($m) 'Background' + $m.Groups[1].Value.ToUpper() }
        $changed = $true
        Write-Host "  ✓ Fixed Background in Add() options" -ForegroundColor Green
    }
    
    if ($changed) {
        Set-Content -Path $file -Value $content -Encoding UTF8 -NoNewline
        $fixed++
        Write-Host "  ✓ File updated" -ForegroundColor Green
    } else {
        $skipped++
        Write-Host "  - No changes needed" -ForegroundColor Gray
    }
    
    Write-Host ""
}

Write-Host "================================" -ForegroundColor Cyan
Write-Host "Complete!" -ForegroundColor Green
Write-Host "Fixed: $fixed files" -ForegroundColor Green
Write-Host "Skipped: $skipped files" -ForegroundColor Gray
Write-Host ""
Write-Host "Note: This script applies automatic fixes. Please review the changes" -ForegroundColor Yellow
Write-Host "and test the scripts to ensure everything works correctly." -ForegroundColor Yellow

