$ahkPath = "C:\Program Files\AutoHotkey\v2\AutoHotkey64.exe"
$linterPath = "d:\Dev\repos\autohotkey-test\utils\linter_headless.ahk"
$repoPath = "d:\Dev\repos\autohotkey-test"

$files = Get-ChildItem -Path $repoPath -Recurse -Filter "*.ahk"

$totalFiles = 0
$passedFiles = 0
$failedFiles = 0
$results = @()

foreach ($file in $files) {
    # Skip the linter itself and other utility scripts if they are not the target
    # But user said "all ahk scripts", so we include them.
    
    $totalFiles++
    Write-Host "Linting: $($file.FullName)"
    
    # Clean up previous temp file
    $tempFile = "$repoPath\utils\lint_report.txt"
    if (Test-Path $tempFile) { Remove-Item $tempFile }

    $process = Start-Process -FilePath $ahkPath -ArgumentList "`"$linterPath`" `"$($file.FullName)`"" -PassThru -Wait -NoNewWindow
    
    if (Test-Path $tempFile) {
        $content = Get-Content $tempFile
        $content | Out-File -FilePath "$repoPath\full_report.txt" -Append -Encoding utf8
        $content | Write-Host
        Remove-Item $tempFile
    }
    
    if ($process.ExitCode -eq 0) {
        $passedFiles++
    }
    else {
        $failedFiles++
        $results += "$($file.FullName) (Exit Code: $($process.ExitCode))"
    }
}

Write-Host "`nSummary:"
Write-Host "Total Files: $totalFiles"
Write-Host "Passed: $passedFiles"
Write-Host "Failed: $failedFiles"

if ($failedFiles -gt 0) {
    Write-Host "`nFailed Files:"
    $results | ForEach-Object { Write-Host $_ }
}
