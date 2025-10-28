# Test puzzle game without popups
$ErrorActionPreference = "SilentlyContinue"

# Run and capture output to file
& AutoHotkey.exe '/ErrorStdOut' scriptlets\PuzzleGame.ahk > test_output.txt 2>&1

# Check for errors in output
Start-Sleep -Seconds 1
if (Test-Path test_output.txt) {
    $output = Get-Content test_output.txt
    if ($output) {
        Write-Host "ERRORS FOUND:" -ForegroundColor Red
        $output
    } else {
        Write-Host "No errors - script running" -ForegroundColor Green
    }
}
Remove-Item test_output.txt -ErrorAction SilentlyContinue

