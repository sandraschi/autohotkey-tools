param([Parameter(Mandatory = $true)][string]$Name)
# Lint ONE scriptlet with the headless linter (called from justfile).
$ahk = 'C:\Program Files\AutoHotkey\v2\AutoHotkey64.exe'
$linter = Join-Path $PSScriptRoot 'linter_headless.ahk'
$path = Join-Path $PSScriptRoot "..\scriptlets\$Name.ahk"
if (Test-Path $path) {
    $report = Join-Path $PSScriptRoot 'lint_report.txt'
    $t = Get-Date
    & $ahk $linter $path
    while ((((Get-Item $report).LastWriteTime -lt $t) -and (((Get-Date) - $t).TotalSeconds -lt 120))) { Start-Sleep -Seconds 2 }
    Get-Content $report
} else {
    Write-Host "Scriptlet not found: $Name"
}
