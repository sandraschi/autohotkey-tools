# Add Missing Stop() Methods to Scriptlet Classes
# Ensures all GUI scriptlets have cleanup methods

$scriptletsPath = Join-Path $PSScriptRoot "..\scriptlets"
$fixedCount = 0
$skippedCount = 0
$errors = @()

Write-Host "Scanning for classes missing Stop() methods..." -ForegroundColor Cyan

Get-ChildItem -Path $scriptletsPath -Filter "*.ahk" -Recurse | ForEach-Object {
    $file = $_.FullName
    $content = Get-Content $file -Raw -ErrorAction SilentlyContinue
    
    if (-not $content) { return }
    
    # Skip if already has Stop() method
    if ($content -match 'static\s+Stop\(' -or $content -match 'Stop\(') {
        $skippedCount++
        return
    }
    
    # Find classes with GUIs that need Stop() methods
    if ($content -match 'class\s+(\w+)' -and ($content -match 'Gui\(' -or $content -match 'gui\s*:=')) {
        $className = $matches[1]
        $needsFix = $false
        $newContent = $content
        
        # Check if class has GUI but no Stop method
        if ($content -match "class\s+$className\s*\{[^}]*gui" -and $content -notmatch "static\s+Stop\(") {
            $needsFix = $true
            
            # Find the last method before closing brace
            if ($content -match "(?s)(class\s+$className\s*\{.*?)(\n\})") {
                $classBody = $matches[1]
                $closingBrace = $matches[2]
                
                # Add Stop() method before closing brace
                $stopMethod = @"

    static Stop(*) {
        if (this.gui) {
            this.gui.Destroy()
            this.gui := ""
        }
    }
}
"@
                
                $newContent = $content -replace [regex]::Escape($closingBrace), ($stopMethod)
            }
        }
        
        if ($needsFix -and $newContent -ne $content) {
            try {
                # Create backup
                $backupFile = $file + ".bak"
                Copy-Item $file $backupFile -Force
                
                # Write fixed content
                Set-Content -Path $file -Value $newContent -NoNewline
                
                Write-Host "Added Stop() to: $($_.Name)" -ForegroundColor Green
                $fixedCount++
            } catch {
                Write-Host "Error fixing $($_.Name): $_" -ForegroundColor Red
                $errors += "$($_.Name): $_"
            }
        }
    }
}

Write-Host "`nSummary:" -ForegroundColor Cyan
Write-Host "  Fixed: $fixedCount files" -ForegroundColor Green
Write-Host "  Skipped: $skippedCount files (already have Stop methods)" -ForegroundColor Yellow
if ($errors.Count -gt 0) {
    Write-Host "  Errors: $($errors.Count)" -ForegroundColor Red
    $errors | ForEach-Object { Write-Host "    $_" -ForegroundColor Red }
}

