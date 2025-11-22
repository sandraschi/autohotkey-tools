# Add OnExit Handlers for Scriptlets with GUIs/Timers - SAFE VERSION
# Ensures proper cleanup on script exit

param(
    [switch]$DryRun = $false,
    [switch]$Verbose = $false
)

$scriptletsPath = Join-Path $PSScriptRoot "..\scriptlets"
$fixedCount = 0
$skippedCount = 0
$errors = @()

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "OnExit Handler Adder (Safe Mode)" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
if ($DryRun) {
    Write-Host "DRY RUN MODE - No changes will be made" -ForegroundColor Yellow
}
Write-Host ""

Get-ChildItem -Path $scriptletsPath -Filter "*.ahk" -Recurse | ForEach-Object {
    $file = $_.FullName
    $content = Get-Content $file -Raw -ErrorAction SilentlyContinue
    
    if (-not $content) { return }
    
    # Skip if already has OnExit
    if ($content -match 'OnExit\(') {
        $skippedCount++
        return
    }
    
    # Check if scriptlet has GUIs or timers that need cleanup
    $needsFix = $false
    if (($content -match 'Gui\(' -or $content -match 'gui\s*:=') -or $content -match 'SetTimer') {
        # Find class name
        $className = ""
        if ($content -match 'class\s+(\w+)') {
            $className = $matches[1]
        }
        
        if ($className) {
            # CRITICAL: Check if Stop() or HideGui() method exists before adding OnExit
            $hasStopMethod = $content -match "static\s+Stop\(" -or $content -match "^\s*Stop\("
            $hasHideGuiMethod = $content -match "static\s+HideGui\(" -or $content -match "^\s*HideGui\("
            
            if (-not $hasStopMethod -and -not $hasHideGuiMethod) {
                if ($Verbose) {
                    Write-Host "Skipping $($_.Name) - no Stop() or HideGui() method found" -ForegroundColor Yellow
                }
                $skippedCount++
                return
            }
            
            # Determine which method to use
            $cleanupMethod = ""
            if ($hasStopMethod) {
                $cleanupMethod = "$className.Stop()"
            } elseif ($hasHideGuiMethod) {
                $cleanupMethod = "$className.HideGui()"
            } else {
                # Fallback to ExitApp() if neither exists (shouldn't happen due to check above)
                $cleanupMethod = "ExitApp()"
            }
            
            $needsFix = $true
            $newContent = $content
            
            # Find where to add OnExit (before Init() call at end of file)
            if ($content -match '(?s)(.*?)(\n' + [regex]::Escape($className) + '\.Init\(\))') {
                $beforeInit = $matches[1]
                $initCall = $matches[2]
                
                # Add OnExit handler before Init
                $onExitHandler = @"

; Register exit handler
OnExit((*) => $cleanupMethod)

"@
                
                $newContent = $beforeInit + $onExitHandler + $initCall
            } elseif ($content -match '(?s)(.*?)(\n; Initialize.*?\n.*?\.Init\(\))') {
                # Alternative pattern: before "Initialize" comment
                $beforeInit = $matches[1]
                $initSection = $matches[2]
                
                $onExitHandler = @"

; Register exit handler
OnExit((*) => $cleanupMethod)

"@
                
                $newContent = $beforeInit + $onExitHandler + $initSection
            }
            
            if ($needsFix -and $newContent -ne $content) {
                if ($DryRun) {
                    Write-Host "[DRY RUN] Would add OnExit handler to: $($_.Name)" -ForegroundColor Cyan
                    if ($Verbose) {
                        Write-Host "  Class: $className" -ForegroundColor Gray
                        Write-Host "  Cleanup method: $cleanupMethod" -ForegroundColor Gray
                    }
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
                        
                        Write-Host "Added OnExit handler to: $($_.Name)" -ForegroundColor Green
                        if ($Verbose) {
                            Write-Host "  Class: $className" -ForegroundColor Gray
                            Write-Host "  Cleanup method: $cleanupMethod" -ForegroundColor Gray
                        }
                        $fixedCount++
                    } catch {
                        $errorMsg = "Error fixing $($_.Name): $_"
                        Write-Host $errorMsg -ForegroundColor Red
                        $errors += $errorMsg
                    }
                }
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

