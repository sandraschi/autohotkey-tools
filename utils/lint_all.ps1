param([switch]$Fix)
# Lint ALL scriptlets with the headless linter (called from justfile).
$ahk = 'C:\Program Files\AutoHotkey\v2\AutoHotkey64.exe'
$linter = Join-Path $PSScriptRoot 'linter_headless.ahk'
$scripts = Get-ChildItem -Path (Join-Path $PSScriptRoot '..\scriptlets\*.ahk') -File |
    Where-Object { $_.Name -notlike '_*' -and $_.Name -notlike '*.bak' }
$pass = 0
$fail = 0
foreach ($f in $scripts) {
    $lintArgs = @($linter, $f.FullName)
    if ($Fix) { $lintArgs += '--fix' }
    $p = Start-Process -FilePath $ahk -ArgumentList $lintArgs -PassThru -Wait -NoNewWindow
    if ($p.ExitCode -eq 0) { Write-Host "  OK   $($f.Name)" -ForegroundColor Green; $pass++ }
    else { Write-Host "  FAIL $($f.Name)" -ForegroundColor Red; $fail++ }
}
Write-Host ""
Write-Host "$pass OK, $fail with issues" -ForegroundColor $(if ($fail -eq 0) { 'Green' } else { 'Yellow' })
