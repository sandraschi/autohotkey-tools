# Master Script: Run All Automated Fixes
# Applies all common pattern fixes to scriptlets

param(
    [switch]$Backup = $true,
    [switch]$DryRun = $false,
    [switch]$Verbose = $false
)

$scriptletsPath = Join-Path $PSScriptRoot "..\scriptlets"
$fixScripts = @(
    @{ Name = "fix_gui_escape_handlers_safe.ps1"; Description = "Add Escape handlers to GUIs" },
    @{ Name = "fix_settimer_syntax_safe.ps1"; Description = "Fix SetTimer v1 syntax" },
    @{ Name = "fix_missing_stop_methods_safe.ps1"; Description = "Add Stop() cleanup methods" },
    @{ Name = "fix_on_exit_handlers.ps1"; Description = "Add OnExit handlers" }
)

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "AutoHotkey Scriptlet Automated Fixes" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

if ($DryRun) {
    Write-Host "DRY RUN MODE - No changes will be made" -ForegroundColor Yellow
    Write-Host ""
}

# Count scriptlets before fixes
$totalScriptlets = (Get-ChildItem -Path $scriptletsPath -Filter "*.ahk" -Recurse).Count
Write-Host "Total scriptlets found: $totalScriptlets" -ForegroundColor Cyan
Write-Host ""

$totalFixed = 0
$allErrors = @()

foreach ($fixScript in $fixScripts) {
    $scriptPath = Join-Path $PSScriptRoot $fixScript.Name
    
    if (-not (Test-Path $scriptPath)) {
        Write-Host "Warning: Fix script not found: $($fixScript.Name)" -ForegroundColor Yellow
        continue
    }
    
    Write-Host "Running: $($fixScript.Description)" -ForegroundColor Green
    Write-Host "  Script: $($fixScript.Name)" -ForegroundColor Gray
    Write-Host "----------------------------------------" -ForegroundColor Gray
    
    try {
        $params = @{}
        if ($DryRun) {
            $params.DryRun = $true
        }
        if ($Verbose) {
            $params.Verbose = $true
        }
        
        $result = & $scriptPath @params 2>&1
        Write-Host $result
    } catch {
        $errorMsg = "Error running $($fixScript.Name) : $_"
        Write-Host $errorMsg -ForegroundColor Red
        $allErrors += $errorMsg
    }
    
    Write-Host ""
}

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Summary" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

if ($DryRun) {
    Write-Host "Dry run completed. Use without -DryRun to apply fixes." -ForegroundColor Yellow
} else {
    Write-Host "All fixes applied!" -ForegroundColor Green
    Write-Host ""
    Write-Host "Next steps:" -ForegroundColor Cyan
    Write-Host "1. Review the changes made" -ForegroundColor White
    Write-Host "2. Test fixed scriptlets: .\utils\batch_debugger.ps1" -ForegroundColor White
    Write-Host "3. Check backup files (.bak) if you need to revert" -ForegroundColor White
}

if ($allErrors.Count -gt 0) {
    Write-Host ""
    Write-Host "Errors encountered:" -ForegroundColor Red
    $allErrors | ForEach-Object { Write-Host "  $_" -ForegroundColor Red }
}

Write-Host ""

