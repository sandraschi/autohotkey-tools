# start.ps1 - Fleet-standard launcher for autohotkey-test
# Kills any zombie on port 10744, starts ScriptletCOMBridge, opens dashboard.
# Usage: pwsh -ExecutionPolicy Bypass -File .\start.ps1

$ErrorActionPreference = 'Stop'
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path

Write-Host ""
Write-Host "autohotkey-test - ScriptletCOMBridge launcher" -ForegroundColor Magenta
Write-Host "Port: 10744  |  Dashboard: http://127.0.0.1:10744/dashboard" -ForegroundColor DarkGray
Write-Host ""

# Fleet standard: kill zombie on port before binding
$port = 10744
try {
    $conns = Get-NetTCPConnection -LocalPort $port -ErrorAction SilentlyContinue
    if ($conns) {
        $conns | ForEach-Object {
            if ($_.OwningProcess -ne 4) {
                Stop-Process -Id $_.OwningProcess -Force -ErrorAction SilentlyContinue
                Write-Host "  Killed zombie PID $($_.OwningProcess) on port $port" -ForegroundColor DarkGray
            }
        }
        Start-Sleep -Seconds 1
    }
} catch {
    Write-Host "  Port cleanup skipped: $_" -ForegroundColor DarkGray
}

# Delegate to existing launcher script
$dashboardScript = Join-Path -Path $ScriptDir -ChildPath 'start_dashboard.ps1'
& $dashboardScript

$FleetStartPath = Join-Path $ProjectRoot "scripts\FleetStartMode.ps1"
if (-not (Test-Path -LiteralPath $FleetStartPath)) {
    Write-Host "ERROR: Missing vendored launcher helper: $FleetStartPath" -ForegroundColor Red
    exit 1
}
. $FleetStartPath

