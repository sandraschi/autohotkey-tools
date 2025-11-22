# Fix Missing GUI Escape Handlers - SAFE VERSION
# Adds Escape and Close handlers to GUIs that don't have them
# WITH VALIDATION AND SAFETY CHECKS

param(
    [switch]$DryRun = $false,
    [switch]$Verbose = $false
)

$scriptletsPath = Join-Path $PSScriptRoot "..\scriptlets"
$fixedCount = 0
$skippedCount = 0
$errors = @()
$warnings = @()

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "GUI Escape Handler Fixer (Safe Mode)" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
if ($DryRun) {
    Write-Host "DRY RUN MODE - No changes will be made" -ForegroundColor Yellow
}
Write-Host ""

function Test-ScriptletSyntax {
    param([string]$Content, [string]$FileName)
    
    # Basic validation - check for common syntax issues
    $issues = @()
    
    # Check for balanced braces
    $openBraces = ([regex]::Matches($Content, '\{')).Count
    $closeBraces = ([regex]::Matches($Content, '\}')).Count
    if ($openBraces -ne $closeBraces) {
        $issues += "Unbalanced braces"
    }
    
    # Check for basic v2 syntax
    if ($Content -match 'Gui,\s+Add' -or $Content -match 'MsgBox,\s+') {
        $issues += "Contains v1 syntax patterns"
    }
    
    return $issues
}

Get-ChildItem -Path $scriptletsPath -Filter "*.ahk" -Recurse | ForEach-Object {
    $file = $_.FullName
    $fileName = $_.Name
    $content = Get-Content $file -Raw -ErrorAction SilentlyContinue
    
    if (-not $content) { 
        $skippedCount++
        return 
    }
    
    # Skip if file already has Escape handler
    if ($content -match 'OnEvent\("Escape"') {
        if ($Verbose) {
            Write-Host "Skipping $fileName - already has Escape handler" -ForegroundColor Gray
        }
        $skippedCount++
        return
    }
    
    # Find GUIs that need handlers - be more precise
    $guiPatterns = @(
        @{ Pattern = 'this\.gui\s*:=\s*Gui\([^)]*\)'; VarName = 'this.gui'; Type = 'instance' },
        @{ Pattern = 'newGui\s*:=\s*Gui\([^)]*\)'; VarName = 'newGui'; Type = 'local' },
        @{ Pattern = 'gui\s*:=\s*Gui\([^)]*\)'; VarName = 'gui'; Type = 'local' }
    )
    
    $needsFix = $false
    $newContent = $content
    $changes = @()
    
    foreach ($guiPattern in $guiPatterns) {
        # Find GUI creation and Show() call in same method/scope
        $pattern = '(?s)(static\s+\w+\([^)]*\)\s*\{[^}]*?' + $guiPattern.Pattern + '[^}]*?)((' + $guiPattern.VarName + '\.Show\([^)]*\)))'
        
        if ($content -match $pattern) {
            $methodBody = $matches[1]
            $showCall = $matches[2]
            
            # Check if handlers already exist in this method
            if ($methodBody -notmatch 'OnEvent\("Close"' -and $methodBody -notmatch 'OnEvent\("Escape"') {
                $needsFix = $true
                
                # Find class name for proper method reference
                $className = ""
                if ($content -match 'class\s+(\w+)\s*\{') {
                    $className = $matches[1]
                }
                
                # Determine handler method
                $handlerMethod = ""
                if ($guiPattern.VarName -eq 'this.gui' -and $className) {
                    # Check if Stop() method exists
                    if ($content -match "static\s+Stop\(") {
                        $handlerMethod = "this.Stop()"
                    } elseif ($content -match "static\s+HideGui\(") {
                        $handlerMethod = "this.HideGui()"
                    } else {
                        $warnings += "$fileName : No Stop() or HideGui() method found, using ExitApp()"
                        $handlerMethod = "ExitApp()"
                    }
                } elseif ($guiPattern.VarName -eq 'newGui' -and $className) {
                    # Check if HideGui exists
                    if ($content -match "static\s+HideGui\(") {
                        $handlerMethod = "$className.HideGui"
                    } else {
                        $warnings += "$fileName : No HideGui() method found for newGui, using ExitApp()"
                        $handlerMethod = "ExitApp()"
                    }
                } else {
                    $handlerMethod = "ExitApp()"
                }
                
                # Create handler code
                if ($handlerMethod -match '\.') {
                    # Method reference
                    $handlers = @"

        ; Add exit handlers
        $($guiPattern.VarName).OnEvent("Close", $handlerMethod)
        $($guiPattern.VarName).OnEvent("Escape", $handlerMethod)
        
"@
                } else {
                    # Function call
                    $handlers = @"

        ; Add exit handlers
        $($guiPattern.VarName).OnEvent("Close", (*) => $handlerMethod)
        $($guiPattern.VarName).OnEvent("Escape", (*) => $handlerMethod)
        
"@
                }
                
                # Replace Show() call with handlers + Show()
                $newContent = $newContent -replace ([regex]::Escape($showCall)), ($handlers + $showCall)
                $changes += "Added handlers for $($guiPattern.VarName) before Show()"
                
                # Only fix first occurrence per file to avoid multiple changes
                break
            }
        }
    }
    
    if ($needsFix -and $newContent -ne $content) {
        # Validate syntax before applying
        $syntaxIssues = Test-ScriptletSyntax -Content $newContent -FileName $fileName
        
        if ($syntaxIssues.Count -gt 0) {
            $errors += "$fileName : Syntax validation failed - $($syntaxIssues -join ', ')"
            Write-Host "SKIP $fileName - Syntax issues detected" -ForegroundColor Yellow
            return
        }
        
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

if ($warnings.Count -gt 0) {
    Write-Host "  Warnings: $($warnings.Count)" -ForegroundColor Yellow
    if ($Verbose) {
        $warnings | ForEach-Object { Write-Host "    $_" -ForegroundColor Yellow }
    }
}

if ($errors.Count -gt 0) {
    Write-Host "  Errors: $($errors.Count)" -ForegroundColor Red
    $errors | ForEach-Object { Write-Host "    $_" -ForegroundColor Red }
}

if ($DryRun) {
    Write-Host ""
    Write-Host "Run without -DryRun to apply fixes" -ForegroundColor Cyan
}

