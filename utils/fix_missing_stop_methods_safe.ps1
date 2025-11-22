# Add Missing Stop() Methods - SAFE VERSION
# Ensures all GUI scriptlets have cleanup methods
# WITH VALIDATION

param(
    [switch]$DryRun = $false,
    [switch]$Verbose = $false
)

$scriptletsPath = Join-Path $PSScriptRoot "..\scriptlets"
$fixedCount = 0
$skippedCount = 0
$errors = @()

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Stop() Method Adder (Safe Mode)" -ForegroundColor Cyan
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
    
    # Skip if already has Stop() method
    if ($content -match 'static\s+Stop\(' -or $content -match '^\s*Stop\(') {
        if ($Verbose) {
            Write-Host "Skipping $fileName - already has Stop() method" -ForegroundColor Gray
        }
        $skippedCount++
        return
    }
    
    # Find classes with GUIs that need Stop() methods
    if ($content -match 'class\s+(\w+)' -and ($content -match 'Gui\(' -or $content -match 'gui\s*:=')) {
        $className = $matches[1]
        $needsFix = $false
        $newContent = $content
        
        # More precise check: class has GUI property but no Stop method
        # Find class definition and check its body
        if ($content -match "(?s)(class\s+$className\s*\{)(.*?)(\n\})") {
            $classHeader = $matches[1]
            $classBody = $matches[2]
            $closingBrace = $matches[3]
            
            # Check if class body has GUI but no Stop
            if ($classBody -match 'gui' -and $classBody -notmatch 'static\s+Stop\(' -and $classBody -notmatch '^\s*Stop\(') {
                $needsFix = $true
                
                # Determine GUI variable name
                $guiVar = "this.gui"
                if ($classBody -match 'this\.gui\s*:=') {
                    $guiVar = "this.gui"
                } elseif ($classBody -match 'newGui\s*:=') {
                    $guiVar = "newGui"
                } elseif ($classBody -match 'gui\s*:=') {
                    $guiVar = "gui"
                }
                
                # Add Stop() method before closing brace
                $stopMethod = @"

    static Stop(*) {
        if ($guiVar) {
            $guiVar.Destroy()
            $guiVar := ""
        }
    }
}
"@
                
                $newContent = $content -replace ([regex]::Escape($closingBrace)), ($stopMethod)
            }
        }
        
        if ($needsFix -and $newContent -ne $content) {
            if ($DryRun) {
                Write-Host "[DRY RUN] Would add Stop() to: $fileName" -ForegroundColor Cyan
                Write-Host "  Class: $className" -ForegroundColor Gray
                Write-Host "  GUI variable: $guiVar" -ForegroundColor Gray
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
                    
                    Write-Host "Added Stop() to: $fileName" -ForegroundColor Green
                    if ($Verbose) {
                        Write-Host "  Class: $className" -ForegroundColor Gray
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

