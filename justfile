set windows-shell := ["powershell.exe", "-NoProfile", "-Command"]

# --- AutoHotkey Test Depot  just recipes ---
# Usage: just <recipe>   or   just --list

default:
    @just --list

# Run the AHK v2 linter on ALL scriptlets
lint-ahk:
    @powershell.exe -NoProfile -Command "$ahk = 'C:\Program Files\AutoHotkey\v2\AutoHotkey64.exe'; $linter = '.\utils\linter_headless.ahk'; $scripts = Get-ChildItem '.\scriptlets\*.ahk' -File | Where-Object { $_.Name -notlike '_*' -and $_.Name -notlike '*.bak' }; $pass = 0; $fail = 0; foreach ($f in $scripts) { $p = Start-Process -FilePath $ahk -ArgumentList \"`\"$linter`\" `\"$($f.FullName)`\"\" -PassThru -Wait -NoNewWindow; if ($p.ExitCode -eq 0) { Write-Host \"  OK   $($f.Name)\" -ForegroundColor Green; $pass++ } else { Write-Host \"  FAIL $($f.Name)\" -ForegroundColor Red; $fail++ } }; Write-Host \"`n$pass OK, $fail with issues\" -ForegroundColor $(if ($fail -eq 0) { 'Green' } else { 'Yellow' })"

# --- Auto-fix known v1 v2 issues on ALL scriptlets  creates  bak backups ---
lint-fix:
    @powershell.exe -NoProfile -Command "$ahk = 'C:\Program Files\AutoHotkey\v2\AutoHotkey64.exe'; $linter = '.\utils\linter_headless.ahk'; $scripts = Get-ChildItem '.\scriptlets\*.ahk' -File | Where-Object { $_.Name -notlike '_*' -and $_.Name -notlike '*.bak' }; $fixed = 0; foreach ($f in $scripts) { $p = Start-Process -FilePath $ahk -ArgumentList \"`\"$linter`\" `\"$($f.FullName)`\"\ --fix\" -PassThru -Wait -NoNewWindow; if ($p.ExitCode -eq 0) { Write-Host \"  OK   $($f.Name)\" -ForegroundColor Green } else { Write-Host \"  WARN $($f.Name)\" -ForegroundColor Yellow; $fixed++ } }; Write-Host \"`n$($fixed) files still have warnings after fix\" -ForegroundColor $(if ($fixed -eq 0) { 'Green' } else { 'Yellow' })"

# --- Run the compatibility scanner  v1 v2 migration check ---
scan-compat:
    @powershell.exe -NoProfile -Command "& '.\run_compatibility_scan.ps1'"

# Lint a single scriptlet: just lint-one scriptlet_name
lint-one name:
    @powershell.exe -NoProfile -Command "$ahk = 'C:\Program Files\AutoHotkey\v2\AutoHotkey64.exe'; $linter = '.\utils\linter_headless.ahk'; $path = \".\scriptlets\{{name}}.ahk\"; if (Test-Path $path) { & $ahk \"`\"$linter`\" `\"$path`\"\"; Get-Content '.\utils\lint_report.txt' } else { Write-Host \"Scriptlet not found: {{name}}\" }"

# Kill all AHK processes (zombie cleanup)
kill-ahk:
    @powershell.exe -NoProfile -Command "Get-Process AutoHotkey64 -ErrorAction SilentlyContinue | ForEach-Object { Stop-Process -Id $_.Id -Force; Write-Host 'Killed PID' $_.Id }"

# Launch the dashboard
dash:
    @start http://127.0.0.1:10744/dashboard

# Start the launcher
start:
    @powershell.exe -NoProfile -File ".\start.ps1"

# Bootstrap: install dev deps + pre-commit hook
bootstrap:
    uv sync --group dev
    uv run pre-commit install
    Write-Host "Pre-commit hooks installed." -ForegroundColor Green