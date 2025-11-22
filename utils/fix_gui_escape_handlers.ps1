# Fix Missing GUI Escape Handlers
# Adds Escape and Close handlers to GUIs that don't have them

$scriptletsPath = Join-Path $PSScriptRoot "..\scriptlets"
$fixedCount = 0
$skippedCount = 0
$errors = @()

Write-Host "Scanning for GUIs without Escape handlers..." -ForegroundColor Cyan

Get-ChildItem -Path $scriptletsPath -Filter "*.ahk" -Recurse | ForEach-Object {
    $file = $_.FullName
    $content = Get-Content $file -Raw -ErrorAction SilentlyContinue
    
    if (-not $content) { return }
    
    # Skip if file already has Escape handler
    if ($content -match 'OnEvent\("Escape"') {
        $skippedCount++
        return
    }
    
    # Find GUIs that need handlers
    if ($content -match 'Gui\([^)]*\)' -or $content -match 'gui\s*:=\s*Gui\(') {
        $needsFix = $false
        $newContent = $content
        
        # Pattern 1: gui.Show() without OnEvent handlers before it
        if ($content -match '(?s)(gui\s*:=\s*Gui\([^)]*\)[^S]*?)(gui\.Show\([^)]*\))') {
            $needsFix = $true
            $guiCreation = $matches[1]
            $guiShow = $matches[2]
            
            # Check if there are already handlers
            if ($guiCreation -notmatch 'OnEvent\("Close"' -and $guiCreation -notmatch 'OnEvent\("Escape"') {
                # Find the class name
                $className = ""
                if ($content -match 'class\s+(\w+)\s*\{') {
                    $className = $matches[1]
                }
                
                # Add handlers before Show()
                $handlers = @"

        ; Add exit handlers
        this.gui.OnEvent("Close", (*) => this.Stop())
        this.gui.OnEvent("Escape", (*) => this.Stop())
        
"@
                $newContent = $newContent -replace [regex]::Escape($guiShow), ($handlers + $guiShow)
            }
        }
        
        # Pattern 2: this.gui.Show() without handlers
        if ($content -match '(?s)(this\.gui\s*:=\s*Gui\([^)]*\)[^S]*?)(this\.gui\.Show\([^)]*\))') {
            $needsFix = $true
            $guiShow = $matches[2]
            
            if ($matches[1] -notmatch 'OnEvent\("Close"' -and $matches[1] -notmatch 'OnEvent\("Escape"') {
                $handlers = @"

        ; Add exit handlers
        this.gui.OnEvent("Close", (*) => this.Stop())
        this.gui.OnEvent("Escape", (*) => this.Stop())
        
"@
                $newContent = $newContent -replace [regex]::Escape($guiShow), ($handlers + $guiShow)
            }
        }
        
        # Pattern 3: newGui.Show() without handlers
        if ($content -match '(?s)(newGui\s*:=\s*Gui\([^)]*\)[^S]*?)(newGui\.Show\([^)]*\))') {
            $needsFix = $true
            $guiShow = $matches[2]
            
            if ($matches[1] -notmatch 'OnEvent\("Close"' -and $matches[1] -notmatch 'OnEvent\("Escape"') {
                # Try to find class name
                $className = ""
                if ($content -match 'class\s+(\w+)\s*\{') {
                    $className = $matches[1]
                }
                
                if ($className) {
                    $handlers = @"

        newGui.OnEvent("Close", $className.HideGui)
        newGui.OnEvent("Escape", $className.HideGui)
        
"@
                } else {
                    $handlers = @"

        newGui.OnEvent("Close", (*) => ExitApp())
        newGui.OnEvent("Escape", (*) => ExitApp())
        
"@
                }
                $newContent = $newContent -replace [regex]::Escape($guiShow), ($handlers + $guiShow)
            }
        }
        
        if ($needsFix -and $newContent -ne $content) {
            try {
                # Create backup
                $backupFile = $file + ".bak"
                Copy-Item $file $backupFile -Force
                
                # Write fixed content
                Set-Content -Path $file -Value $newContent -NoNewline
                
                Write-Host "Fixed: $($_.Name)" -ForegroundColor Green
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
Write-Host "  Skipped: $skippedCount files (already have handlers)" -ForegroundColor Yellow
if ($errors.Count -gt 0) {
    Write-Host "  Errors: $($errors.Count)" -ForegroundColor Red
    $errors | ForEach-Object { Write-Host "    $_" -ForegroundColor Red }
}

