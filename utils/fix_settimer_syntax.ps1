# Fix SetTimer Syntax Issues
# Converts v1-style SetTimer label syntax to v2 function syntax

$scriptletsPath = Join-Path $PSScriptRoot "..\scriptlets"
$fixedCount = 0
$skippedCount = 0
$errors = @()

Write-Host "Scanning for SetTimer syntax issues..." -ForegroundColor Cyan

Get-ChildItem -Path $scriptletsPath -Filter "*.ahk" -Recurse | ForEach-Object {
    $file = $_.FullName
    $content = Get-Content $file -Raw -ErrorAction SilentlyContinue
    
    if (-not $content) { return }
    
    # Skip if no SetTimer calls
    if ($content -notmatch 'SetTimer') {
        $skippedCount++
        return
    }
    
    $needsFix = $false
    $newContent = $content
    
    # Pattern 1: SetTimer LabelName, interval (v1 syntax)
    # Convert to: SetTimer(LabelName, interval)
    if ($content -match 'SetTimer\s+(\w+)\s*,') {
        $needsFix = $true
        $newContent = $newContent -replace 'SetTimer\s+(\w+)\s*,', 'SetTimer($1, '
    }
    
    # Pattern 2: SetTimer, LabelName, interval (v1 command syntax)
    if ($content -match 'SetTimer,\s*(\w+)\s*,') {
        $needsFix = $true
        $newContent = $newContent -replace 'SetTimer,\s*(\w+)\s*,', 'SetTimer($1, '
    }
    
    # Pattern 3: SetTimer LabelName (no interval, should be SetTimer(LabelName, 0))
    if ($content -match 'SetTimer\s+(\w+)(?!\s*[\(,])') {
        $needsFix = $true
        # Only fix if it's not already SetTimer(LabelName, ...)
        $newContent = $newContent -replace 'SetTimer\s+(\w+)(?=\s|$|`n)', 'SetTimer($1, 0)'
    }
    
    if ($needsFix -and $newContent -ne $content) {
        try {
            # Create backup
            $backupFile = $file + ".bak"
            Copy-Item $file $backupFile -Force
            
            # Write fixed content
            Set-Content -Path $file -Value $newContent -NoNewline
            
            Write-Host "Fixed SetTimer syntax in: $($_.Name)" -ForegroundColor Green
            $fixedCount++
        } catch {
            Write-Host "Error fixing $($_.Name): $_" -ForegroundColor Red
            $errors += "$($_.Name): $_"
        }
    } else {
        $skippedCount++
    }
}

Write-Host "`nSummary:" -ForegroundColor Cyan
Write-Host "  Fixed: $fixedCount files" -ForegroundColor Green
Write-Host "  Skipped: $skippedCount files" -ForegroundColor Yellow
if ($errors.Count -gt 0) {
    Write-Host "  Errors: $($errors.Count)" -ForegroundColor Red
    $errors | ForEach-Object { Write-Host "    $_" -ForegroundColor Red }
}

