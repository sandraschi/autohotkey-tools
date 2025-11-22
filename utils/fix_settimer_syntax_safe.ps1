# Fix SetTimer Syntax Issues - SAFE VERSION
# Converts v1-style SetTimer label syntax to v2 function syntax
# SKIPS arrow functions and already-correct v2 syntax

param(
    [switch]$DryRun = $false,
    [switch]$Verbose = $false
)

$scriptletsPath = Join-Path $PSScriptRoot "..\scriptlets"
$fixedCount = 0
$skippedCount = 0
$errors = @()

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "SetTimer Syntax Fixer (Safe Mode)" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
if ($DryRun) {
    Write-Host "DRY RUN MODE - No changes will be made" -ForegroundColor Yellow
}
Write-Host ""

Get-ChildItem -Path $scriptletsPath -Filter "*.ahk" -Recurse | ForEach-Object {
    $file = $_.FullName
    $fileName = $_.Name
    $content = Get-Content $file -Raw -ErrorAction SilentlyContinue
    
    if (-not $content) { 
        $skippedCount++
        return 
    }
    
    # Skip if no SetTimer calls
    if ($content -notmatch 'SetTimer') {
        $skippedCount++
        return
    }
    
    $needsFix = $false
    $newContent = $content
    $changes = @()
    
    # Pattern 1: SetTimer LabelName, interval (v1 syntax)
    # BUT ONLY if it's NOT already SetTimer(LabelName, ...) or SetTimer(() => ...)
    # Match: SetTimer LabelName, (with space before LabelName, comma after)
    # Skip: SetTimer(LabelName, SetTimer(() =>, SetTimer(LabelName,
    $lines = $content -split "`n"
    $lineNum = 0
    
    foreach ($line in $lines) {
        $lineNum++
        
        # Skip comments and strings
        if ($line -match '^\s*;' -or $line -match '".*SetTimer.*"') {
            continue
        }
        
        # Pattern 1: SetTimer LabelName, interval (v1 label syntax)
        # Must have: SetTimer + space + word + comma
        # Must NOT have: SetTimer( or SetTimer(() =>
        if ($line -match 'SetTimer\s+(\w+)\s*,' -and $line -notmatch 'SetTimer\(' -and $line -notmatch 'SetTimer\s*\(\s*\(\s*\)\s*=>') {
            $labelName = $matches[1]
            $oldLine = $line
            $newLine = $line -replace 'SetTimer\s+(\w+)\s*,', 'SetTimer($1, '
            
            if ($oldLine -ne $newLine) {
                $needsFix = $true
                $newContent = $newContent -replace ([regex]::Escape($oldLine)), $newLine
                $changes += "Line $lineNum : SetTimer $labelName, -> SetTimer($labelName, "
            }
        }
        
        # Pattern 2: SetTimer, LabelName, interval (v1 command syntax)
        if ($line -match 'SetTimer,\s*(\w+)\s*,' -and $line -notmatch 'SetTimer\(') {
            $labelName = $matches[1]
            $oldLine = $line
            $newLine = $line -replace 'SetTimer,\s*(\w+)\s*,', 'SetTimer($1, '
            
            if ($oldLine -ne $newLine) {
                $needsFix = $true
                $newContent = $newContent -replace ([regex]::Escape($oldLine)), $newLine
                $changes += "Line $lineNum : SetTimer, $labelName, -> SetTimer($labelName, "
            }
        }
        
        # Pattern 3: SetTimer LabelName (no interval, no parentheses)
        # Only if it's standalone (not SetTimer(LabelName) or SetTimer(() =>)
        if ($line -match 'SetTimer\s+(\w+)(?=\s|$|`n|;)' -and $line -notmatch 'SetTimer\(' -and $line -notmatch 'SetTimer\s*\(\s*\(\s*\)\s*=>') {
            $labelName = $matches[1]
            $oldLine = $line
            $newLine = $line -replace 'SetTimer\s+(\w+)(?=\s|$|`n|;)', 'SetTimer($1, 0)'
            
            if ($oldLine -ne $newLine) {
                $needsFix = $true
                $newContent = $newContent -replace ([regex]::Escape($oldLine)), $newLine
                $changes += "Line $lineNum : SetTimer $labelName -> SetTimer($labelName, 0)"
            }
        }
    }
    
    if ($needsFix -and $newContent -ne $content) {
        if ($DryRun) {
            Write-Host "[DRY RUN] Would fix: $fileName" -ForegroundColor Cyan
            $changes | ForEach-Object { Write-Host "  - $_" -ForegroundColor Gray }
            $fixedCount++
        } else {
            try {
                # Create backup
                $backupFile = $file + ".bak"
                if (-not (Test-Path $backupFile)) {
                    Copy-Item $file $backupFile -Force
                }
                
                # Write fixed content
                Set-Content -Path $file -Value $newContent -NoNewline -Encoding UTF8
                
                Write-Host "Fixed: $fileName" -ForegroundColor Green
                if ($Verbose) {
                    $changes | ForEach-Object { Write-Host "  - $_" -ForegroundColor Gray }
                }
                $fixedCount++
            } catch {
                $errorMsg = "Error fixing $fileName : $_"
                Write-Host $errorMsg -ForegroundColor Red
                $errors += $errorMsg
            }
        }
    } else {
        $skippedCount++
    }
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Summary" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Fixed: $fixedCount files" -ForegroundColor Green
Write-Host "  Skipped: $skippedCount files" -ForegroundColor Yellow

if ($errors.Count -gt 0) {
    Write-Host "  Errors: $($errors.Count)" -ForegroundColor Red
    $errors | ForEach-Object { Write-Host "    $_" -ForegroundColor Red }
}

if ($DryRun) {
    Write-Host ""
    Write-Host "Run without -DryRun to apply fixes" -ForegroundColor Cyan
}

