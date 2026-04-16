# test_bridge_detection.ps1
# Scaffold: minimal HTTP server on 10744 + launcher detection logic. Run from repo root: .\tests\test_bridge_detection.ps1

$ErrorActionPreference = 'Stop'
$Port = 10744

# --------------- Same detection logic as start_dashboard.ps1 ---------------
function Test-BridgeRunning {
    param([int]$Port = 10744)
    try {
        $tcp = New-Object System.Net.Sockets.TcpClient
        $async = $tcp.BeginConnect('127.0.0.1', $Port, $null, $null)
        if (-not $async.AsyncWaitHandle.WaitOne(2000, $false)) {
            $tcp.Close()
            return $false
        }
        $tcp.EndConnect($async)
        $tcp.Close()
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

# --------------- Kill zombie on port so we can bind ---------------
function Clear-Port {
    param([int]$P)
    try {
        $conn = Get-NetTCPConnection -LocalPort $P -ErrorAction SilentlyContinue
        foreach ($c in $conn) {
            if ($c.OwningProcess -ne 4) {
                Stop-Process -Id $c.OwningProcess -Force -ErrorAction SilentlyContinue
            }
        }
    } catch { }
}
Clear-Port -P $Port
Start-Sleep -Seconds 1

# --------------- Minimal server in same process (thread) so we know it bound ---------------
$portNum = $Port
$serverThread = [System.Threading.Thread]::new([System.Threading.ParameterizedThreadStart]{
    param($state)
    $p = [int]$state
    $listener = New-Object System.Net.HttpListener
    $listener.Prefixes.Add("http://127.0.0.1:${p}/")
    $listener.Start()
    $ctx = $listener.GetContext()
    $ctx.Response.StatusCode = 200
    $buf = [System.Text.Encoding]::UTF8.GetBytes('Server running')
    $ctx.Response.ContentLength64 = $buf.Length
    $ctx.Response.OutputStream.Write($buf, 0, $buf.Length)
    $ctx.Response.Close()
    $listener.Stop()
    $listener.Close()
})
$serverThread.IsBackground = $true
$serverThread.Start($portNum)
Start-Sleep -Seconds 2

Write-Host "Test: server thread started, running detection..." -ForegroundColor Cyan
$result = Test-BridgeRunning -Port $Port

if ($result) {
    Write-Host "PASS  Detection returned true while server was up." -ForegroundColor Green
} else {
    Write-Host "FAIL  Detection returned false; server was running on $Port." -ForegroundColor Red
    exit 1
}

# --------------- Test detection false when nothing listening ---------------
Start-Sleep -Seconds 2
$result2 = Test-BridgeRunning -Port $Port
if (-not $result2) {
    Write-Host "PASS  Detection returned false when server stopped." -ForegroundColor Green
} else {
    Write-Host "WARN  Detection still true after stop (port may be in TIME_WAIT)." -ForegroundColor Yellow
}

Write-Host "Done." -ForegroundColor Cyan
