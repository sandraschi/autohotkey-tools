# PowerShell script to run the compatibility scanner
# This script scans all AutoHotkey scripts for v1 incompatibility and missing v2 requirements

$ErrorActionPreference = "Stop"

Write-Host "============================================"
Write-Host "AutoHotkey v2 Compatibility Scanner"
Write-Host "============================================"
Write-Host ""

# Check if AutoHotkey is installed
try {
    $ahkPath = Get-Command autohotkey.exe -ErrorAction Stop
    Write-Host "Found AutoHotkey at: $($ahkPath.Source)"
} catch {
    Write-Host "ERROR: AutoHotkey not found. Please install AutoHotkey v2."
    exit 1
}

# Get the script directory
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$scannerScript = Join-Path $scriptDir "utils\compatibility_scanner.ahk"

# Check if scanner script exists
if (-not (Test-Path $scannerScript)) {
    Write-Host "ERROR: Scanner script not found at: $scannerScript"
    exit 1
}

Write-Host "Running compatibility scanner..."
Write-Host ""

# Run the scanner
try {
    & $ahkPath.Source '/ErrorStdOut' $scannerScript
    $exitCode = $LASTEXITCODE
    
    Write-Host ""
    Write-Host "============================================"
    Write-Host "Scan Complete!"
    Write-Host "============================================"
    
    if ($exitCode -eq 0) {
        Write-Host "✅ All scripts are compatible!"
    } else {
        Write-Host "⚠️ Issues found - check the report file"
    }
    
    # Try to show the report
    $reportFile = Join-Path $scriptDir "compatibility_scan_report.txt"
    if (Test-Path $reportFile) {
        Write-Host ""
        Write-Host "Report location: $reportFile"
        Write-Host ""
        
        # Ask if user wants to view the report
        $response = Read-Host "Open report file? (y/n)"
        if ($response -eq "y" -or $response -eq "Y") {
            Start-Process notepad.exe -ArgumentList $reportFile
        }
    }
    
    exit $exitCode
} catch {
    Write-Host ""
    Write-Host "ERROR: Failed to run scanner"
    Write-Host $_.Exception.Message
    exit 1
}
