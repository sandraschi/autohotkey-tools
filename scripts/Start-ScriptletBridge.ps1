# Start ScriptletCOMBridge.ahk (HTTP on 10764). Used by fleet-start custom backend.
$ErrorActionPreference = 'Stop'
$RepoRoot = Split-Path -Parent $PSScriptRoot
$BridgeScript = Join-Path $RepoRoot 'ScriptletCOMBridge.ahk'
$BridgePort = 10764

$AhkPaths = @(
    "$env:ProgramFiles\AutoHotkey\v2\AutoHotkey64.exe",
    "$env:ProgramFiles\AutoHotkey\AutoHotkey64.exe",
    "$env:LocalAppData\Programs\AutoHotkey\v2\AutoHotkey64.exe"
)
$AhkExe = $null
foreach ($p in $AhkPaths) {
    if (Test-Path -LiteralPath $p) { $AhkExe = $p; break }
}
if (-not $AhkExe) {
    $cmd = Get-Command 'AutoHotkey64.exe' -ErrorAction SilentlyContinue
    if ($cmd) { $AhkExe = $cmd.Source }
}
if (-not $AhkExe) {
    throw 'AutoHotkey v2 not found. Install from https://www.autohotkey.com/'
}

function Test-BridgeRunning {
    param([int]$Port = 10764)
    try {
        $tcp = New-Object System.Net.Sockets.TcpClient
        $async = $tcp.BeginConnect('127.0.0.1', $Port, $null, $null)
        if (-not $async.AsyncWaitHandle.WaitOne(2000, $false)) {
            $tcp.Close()
            return $false
        }
        $tcp.EndConnect($async)
        $tcp.Close()
        $r = Invoke-WebRequest -Uri "http://127.0.0.1:${Port}/status" -TimeoutSec 3 -UseBasicParsing
        return ($r.StatusCode -eq 200)
    } catch {
        return $false
    }
}

if (Test-BridgeRunning -Port $BridgePort) {
    Write-Host "Scriptlet bridge already running on :$BridgePort"
    exit 0
}

if (-not (Test-Path -LiteralPath $BridgeScript)) {
    throw "Bridge script not found: $BridgeScript"
}

Start-Process -FilePath $AhkExe -ArgumentList @('/ErrorStdOut', $BridgeScript) -WindowStyle Hidden
Write-Host "Started ScriptletCOMBridge (waiting for /status on :$BridgePort)..."

