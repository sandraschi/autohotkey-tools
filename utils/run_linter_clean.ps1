# Clean AutoHotkey Linter Runner
# This script kills any running AutoHotkey processes before running the linter

param(
    [Parameter(Mandatory=$true)]
    [string]$ScriptletPath
)

Write-Host "=== Clean AutoHotkey Linter Runner ===" -ForegroundColor Cyan

# Kill any running AutoHotkey processes
Write-Host "Checking for running AutoHotkey processes..." -ForegroundColor Yellow
$runningProcesses = Get-Process -Name 'AutoHotkey*' -ErrorAction SilentlyContinue

if ($runningProcesses) {
    Write-Host "Found $($runningProcesses.Count) running AutoHotkey process(es). Terminating..." -ForegroundColor Red
    $killedIds = $runningProcesses | ForEach-Object { $_.Id }
    $runningProcesses | ForEach-Object {
        Write-Host "  - Killing: $($_.ProcessName) (PID: $($_.Id))" -ForegroundColor Red
        Stop-Process -Id $_.Id -Force
    }
    # HARDENED 2026-09-17: was a blind Start-Sleep -Seconds 1, no check the
    # processes actually died (TRAPS_AND_PITFALLS.md #36). Poll instead.
    $waitSec = 5
    $elapsed = 0
    while ($elapsed -lt $waitSec -and ($killedIds | Where-Object { Get-Process -Id $_ -ErrorAction SilentlyContinue })) {
        Start-Sleep -Milliseconds 500
        $elapsed += 0.5
    }
} else {
    Write-Host "No AutoHotkey processes found running." -ForegroundColor Green
}

# Verify the scriptlet file exists
if (!(Test-Path $ScriptletPath)) {
    Write-Host "ERROR: Scriptlet file not found: $ScriptletPath" -ForegroundColor Red
    exit 1
}

# Run the linter
Write-Host "Running linter on: $ScriptletPath" -ForegroundColor Green
try {
    & 'C:\Program Files\AutoHotkey\v2\AutoHotkey.exe' '/ErrorStdOut' '.\utils\linter_headless.ahk' $ScriptletPath
    Write-Host "Linter completed successfully!" -ForegroundColor Green
} catch {
    Write-Host "ERROR: Linter failed with exception: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

# Check for output files
$logFile = ".\utils\linter.log"
$reportFile = ".\utils\lint_report.txt"

if (Test-Path $logFile) {
    Write-Host "Log file created: $logFile" -ForegroundColor Green
} else {
    Write-Host "WARNING: No log file created" -ForegroundColor Yellow
}

if (Test-Path $reportFile) {
    Write-Host "Report file created: $reportFile" -ForegroundColor Green
} else {
    Write-Host "WARNING: No report file created" -ForegroundColor Yellow
}
