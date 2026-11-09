set windows-shell := ["powershell.exe", "-NoProfile", "-Command"]

# --- AutoHotkey Test Depot  just recipes ---
# Usage: just <recipe>   or   just --list

default:
    @just --list

# Run the AHK v2 linter on ALL scriptlets (logic in utils/lint_all.ps1 -
# inline -Command quoting kept breaking, so recipes shell out to files)
lint-ahk:
    @powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\utils\lint_all.ps1

# --- Auto-fix known v1 v2 issues on ALL scriptlets ---
lint-fix:
    @powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\utils\lint_all.ps1 -Fix

# Lint a single scriptlet: just lint-one scriptlet_name
lint-one name:
    @powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\utils\lint_one.ps1 -Name "{{name}}"

# Kill all AHK processes (zombie cleanup)
kill-ahk:
    @powershell.exe -NoProfile -Command "Get-Process AutoHotkey64 -ErrorAction SilentlyContinue | ForEach-Object { Stop-Process -Id $_.Id -Force; Write-Host 'Killed PID' $_.Id }"

# Launch the dashboard
dash:
    @start http://127.0.0.1:10764/dashboard

# Start the launcher
start:
    @powershell.exe -NoProfile -File ".\start.ps1"

# Bootstrap: install dev deps + pre-commit hook
bootstrap:
    uv sync --group dev
    uv run pre-commit install
    Write-Host "Pre-commit hooks installed." -ForegroundColor Green
