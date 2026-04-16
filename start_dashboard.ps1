# start_dashboard.ps1
# Launches ScriptletCOMBridge.ahk (if not already running) then opens dashboard.

$ScriptDir    = Split-Path -Parent $MyInvocation.MyCommand.Path
$BridgeScript = Join-Path $ScriptDir 'ScriptletCOMBridge.ahk'
$Dashboard    = Join-Path $ScriptDir 'dashboard.html'
$BridgePort   = 10744

Write-Host ""
Write-Host "AHK Control Tower - Launcher" -ForegroundColor Magenta
Write-Host "---------------------------------" -ForegroundColor DarkGray

# 1. Find AutoHotkey v2
$AhkPaths = @(
    "$env:ProgramFiles\AutoHotkey\v2\AutoHotkey64.exe",
    "$env:ProgramFiles\AutoHotkey\AutoHotkey64.exe",
    "$env:LocalAppData\Programs\AutoHotkey\v2\AutoHotkey64.exe",
    "C:\Program Files\AutoHotkey\v2\AutoHotkey64.exe"
)
$AhkExe = $null
foreach ($p in $AhkPaths) {
    if (Test-Path $p) { $AhkExe = $p; break }
}
if (-not $AhkExe) {
    $cmd = Get-Command 'AutoHotkey64.exe' -ErrorAction SilentlyContinue
    if ($cmd) { $AhkExe = $cmd.Source }
}
if (-not $AhkExe) {
    Write-Host "ERROR: AutoHotkey v2 not found. Install from https://www.autohotkey.com/" -ForegroundColor Red
    Read-Host "Press Enter to exit"
    exit 1
}
Write-Host "OK  AutoHotkey: $AhkExe" -ForegroundColor Green

# 2. Bridge detection: TCP connect then GET /status (port 10744 only)
$BridgePort = 10744

function Test-BridgeRunning {
    param([int]$Port = 10744)
    try {
        # 1) Port open?
        $tcp = New-Object System.Net.Sockets.TcpClient
        $async = $tcp.BeginConnect('127.0.0.1', $Port, $null, $null)
        if (-not $async.AsyncWaitHandle.WaitOne(2000, $false)) {
            $tcp.Close()
            return $false
        }
        $tcp.EndConnect($async)
        $tcp.Close()
        # 2) HTTP GET /status returns 200
        $req = [System.Net.WebRequest]::Create("http://127.0.0.1:${Port}/status")
        $req.Timeout = 3000
        $req.ReadWriteTimeout = 3000
        $req.Method = 'GET'
        $resp = $req.GetResponse()
        $ok = ([int]$resp.StatusCode -eq 200)
        $resp.Close()
        return $ok
    } catch {
        return $false
    }
}

if (Test-BridgeRunning -Port $BridgePort) {
    Write-Host "RUNNING  Bridge already on port $BridgePort" -ForegroundColor Green
} else {
    Write-Host "STARTING ScriptletCOMBridge.ahk ..." -ForegroundColor Cyan
    if (-not (Test-Path $BridgeScript)) {
        Write-Host "ERROR: Bridge script not found: $BridgeScript" -ForegroundColor Red
        Read-Host "Press Enter to exit"
        exit 1
    }
    Start-Process -FilePath $AhkExe -ArgumentList "/ErrorStdOut `"$BridgeScript`"" -WindowStyle Hidden

    Write-Host "   Giving bridge time to start (zombie kill + bind 10744)..." -ForegroundColor DarkGray
    Start-Sleep -Seconds 6
    Write-Host "   Checking for bridge on port $BridgePort..." -ForegroundColor DarkGray
    $waited = 0
    while (-not (Test-BridgeRunning -Port $BridgePort) -and $waited -lt 20) {
        Start-Sleep -Seconds 1
        $waited++
        Write-Host "   ...${waited}s" -ForegroundColor DarkGray
    }

    if (Test-BridgeRunning -Port $BridgePort) {
        Write-Host "OK  Bridge is live on port $BridgePort" -ForegroundColor Green
    } else {
        Write-Host "WARN: Bridge did not respond in time - opening dashboard anyway." -ForegroundColor Yellow
        Write-Host "   If bind fails, run once as Admin: netsh http add urlacl url=http://+:10744/ user=Everyone" -ForegroundColor DarkGray
    }
}

# 3. Open dashboard via bridge (avoids CORS null-origin issue with file://)
$DashboardUrl = "http://localhost:${BridgePort}/dashboard"
Write-Host "OPENING dashboard: $DashboardUrl" -ForegroundColor Cyan
Start-Process $DashboardUrl

Write-Host "DONE. Dashboard is open in your browser." -ForegroundColor Green
Write-Host ""
