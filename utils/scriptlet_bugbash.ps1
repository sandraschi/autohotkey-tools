param(
    [string]$AutoHotkeyPath = "AutoHotkey.exe",
    [string]$ScriptletsRoot,
    [string]$OutputRoot,
    [int]$TimeoutSeconds = 10,
    [int]$Throttle = 5,
    [string[]]$CategoryFilter,
    [switch]$GenerateInventoryOnly,
    [switch]$SkipInventory,
    [string]$WarnOptions = 'All,Off'
)

function Resolve-RepositoryRoot {
    param([string]$StartingPath)

    $item = Get-Item -LiteralPath $StartingPath
    $directory = if ($item -is [System.IO.DirectoryInfo]) { $item } else { $item.Directory }

    while ($directory) {
        $hasReadme = Test-Path -Path (Join-Path -Path $directory.FullName -ChildPath "README.md")
        $hasScriptlets = Test-Path -Path (Join-Path -Path $directory.FullName -ChildPath "scriptlets")
        if ($hasReadme -and $hasScriptlets) {
            return $directory.FullName
        }
        $directory = $directory.Parent
    }

    throw "Unable to determine repository root from $StartingPath."
}

function Get-DefaultScriptletsRoot {
    param([string]$RepoRoot)

    $default = Join-Path -Path $RepoRoot -ChildPath "scriptlets"
    if (-not (Test-Path -Path $default)) {
        throw "Scriptlets directory not found at $default."
    }
    return $default
}

function Get-DefaultOutputRoot {
    param([string]$RepoRoot)

    $output = Join-Path -Path $RepoRoot -ChildPath "logs\bugbash"
    if (-not (Test-Path -Path $output)) {
        New-Item -Path $output -ItemType Directory -Force | Out-Null
    }
    return $output
}

function Get-CategoryFromPath {
    param([string]$ScriptPath, [string]$RepoRoot)

    $relative = Resolve-Path -Path $ScriptPath | ForEach-Object { $_.Path.Substring($RepoRoot.Length).TrimStart('\') }
    $segments = $relative -split "\\"

    foreach ($segment in $segments) {
        switch -Regex ($segment.ToLowerInvariant()) {
            "games" { return "games" }
            "game" { return "games" }
            "development" { return "development" }
            "mcp" { return "mcp" }
            "system" { return "system" }
            "fun" { return "entertainment" }
            "utility" { return "utilities" }
            "tool" { return "utilities" }
        }
    }

    if ($segments.Length -ge 2) {
        return $segments[1].ToLowerInvariant()
    }

    return "uncategorized"
}

function Get-ScriptletInventory {
    param(
        [string]$ScriptletsPath,
        [string]$RepoRoot,
        [string[]]$CategoryFilter
    )

    $pattern = '*.ahk'
    $allScripts = Get-ChildItem -Path $ScriptletsPath -Filter $pattern -Recurse |
        Where-Object {
            $_.Extension -eq '.ahk' -and
            $_.FullName -notmatch '\\v1\\' -and
            $_.Name -notmatch '\.bak$'
        }

    $inventory = @()
    foreach ($script in $allScripts) {
        $category = Get-CategoryFromPath -ScriptPath $script.FullName -RepoRoot $RepoRoot
        if ($CategoryFilter -and -not ($CategoryFilter -contains $category)) {
            continue
        }

        $inventory += [ordered]@{
            name      = $script.BaseName
            path      = $script.FullName
            category  = $category
            relative  = $script.FullName.Substring($RepoRoot.Length).TrimStart('\\')
            sizeBytes = $script.Length
            lastWrite = $script.LastWriteTimeUtc.ToString('o')
        }
    }

    return $inventory
}

function Save-Json {
    param(
        [Parameter(Mandatory)] [object]$Data,
        [Parameter(Mandatory)] [string]$Path,
        [int]$Depth = 5
    )

    $json = $Data | ConvertTo-Json -Depth $Depth
    Set-Content -Path $Path -Value $json -Encoding UTF8
}

function Invoke-Scriptlet {
    param(
        [string]$AutoHotkeyPath,
        [string]$ScriptPath,
        [int]$TimeoutSeconds,
        [string]$LogPath,
        [string]$WarnOptions
    )

    $process = $null
    try {
        $psi = [System.Diagnostics.ProcessStartInfo]::new()
        $psi.FileName = $AutoHotkeyPath
        $psi.ArgumentList.Add($ScriptPath)
        $psi.ArgumentList.Add('/ErrorStdOut')
        if ($WarnOptions -and $WarnOptions.Trim()) {
            $warnOptionValue = $WarnOptions.Trim()
            if (-not $warnOptionValue.StartsWith('"')) {
                $warnOptionValue = '"' + $warnOptionValue.Trim('"') + '"'
            }
            $psi.ArgumentList.Add('/Warn')
            $psi.ArgumentList.Add($warnOptionValue)
        }
        $psi.RedirectStandardOutput = $true
        $psi.RedirectStandardError = $true
        $psi.UseShellExecute = $false
        $psi.CreateNoWindow = $true

        $process = [System.Diagnostics.Process]::Start($psi)
        if (-not $process) {
            throw "Failed to start AutoHotkey for $ScriptPath"
        }

        $stdoutTask = $process.StandardOutput.ReadToEndAsync()
        $stderrTask = $process.StandardError.ReadToEndAsync()

        $result = [ordered]@{
            script        = $ScriptPath
            pid           = $process.Id
            startTimeUtc  = (Get-Date).ToUniversalTime().ToString('o')
            exitCode      = $null
            status        = 'Running'
            durationMs    = 0
            termination   = 'Unknown'
            logPath       = $LogPath
            stdoutLength  = 0
            stderrLength  = 0
        }

        $timeoutMs = [Math]::Max(1, $TimeoutSeconds * 1000)
        $exited = $process.WaitForExit($timeoutMs)

        if (-not $exited) {
            $result.status = 'Timeout'
            $result.termination = 'TimeoutForceKill'
            try {
                $process.CloseMainWindow() | Out-Null
            } catch {
                # Ignore close errors
            }

            Start-Sleep -Milliseconds 500

            if (-not $process.HasExited) {
                try {
                    $process.Kill($true)
                    $process.WaitForExit()
                } catch {
                    try {
                        Stop-Process -Id $process.Id -Force -ErrorAction Stop
                        $process.WaitForExit()
                    } catch {
                        # Ignore kill errors
                    }
                }
            }

            if (-not $process.HasExited) {
                try {
                    Stop-Process -Id $process.Id -Force -ErrorAction SilentlyContinue
                } catch {
                    # Ignore stop-process errors
                }
            }
        } else {
            $result.status = 'Completed'
            $result.termination = 'NaturalExit'
        }

        $stdout = $stdoutTask.Result
        $stderr = $stderrTask.Result

        $result.exitCode = if ($process.HasExited) { $process.ExitCode } else { $null }
        $result.endTimeUtc = (Get-Date).ToUniversalTime().ToString('o')
        $result.durationMs = [Math]::Round(($process.ExitTime - $process.StartTime).TotalMilliseconds)
        $result.stdoutLength = $stdout.Length
        $result.stderrLength = $stderr.Length

        $logBuilder = New-Object System.Text.StringBuilder
        [void]$logBuilder.AppendLine("# Scriptlet Bugbash Log")
        [void]$logBuilder.AppendLine("Script: $($ScriptPath)")
        [void]$logBuilder.AppendLine("PID: $($result.pid)")
        [void]$logBuilder.AppendLine("Start (UTC): $($result.startTimeUtc)")
        [void]$logBuilder.AppendLine("End (UTC): $($result.endTimeUtc)")
        [void]$logBuilder.AppendLine("Status: $($result.status)")
        [void]$logBuilder.AppendLine("Termination: $($result.termination)")
        [void]$logBuilder.AppendLine("Exit Code: $($result.exitCode)")
        [void]$logBuilder.AppendLine("Duration (ms): $($result.durationMs)")
        [void]$logBuilder.AppendLine("StdOut Length: $($result.stdoutLength)")
        [void]$logBuilder.AppendLine("StdErr Length: $($result.stderrLength)")
        [void]$logBuilder.AppendLine("--- StdOut ---")
        [void]$logBuilder.AppendLine($stdout)
        [void]$logBuilder.AppendLine("--- StdErr ---")
        [void]$logBuilder.AppendLine($stderr)

        Set-Content -Path $LogPath -Value $logBuilder.ToString() -Encoding UTF8

        if ($result.stderrLength -gt 0) {
            $result.status = 'CompletedWithErrors'
        }

        return $result
    } finally {
        if ($process) {
            $process.Dispose()
        }
    }
}

function Get-Summary {
    param([object[]]$Results)

    $summary = [ordered]@{
        total     = $Results.Count
        completed = ($Results | Where-Object { $_.status -eq 'Completed' }).Count
        completedWithErrors = ($Results | Where-Object { $_.status -eq 'CompletedWithErrors' }).Count
        timeouts  = ($Results | Where-Object { $_.status -eq 'Timeout' }).Count
        averageDurationMs = if ($Results.Count -gt 0) {
            [Math]::Round(($Results | Measure-Object -Property durationMs -Average).Average, 2)
        } else {
            0
        }
    }

    return $summary
}

try {
    $scriptLocation = Split-Path -Parent $MyInvocation.MyCommand.Path
    $repoRoot = Resolve-RepositoryRoot -StartingPath $scriptLocation

    if (-not $ScriptletsRoot) {
        $ScriptletsRoot = Get-DefaultScriptletsRoot -RepoRoot $repoRoot
    }

    if (-not $OutputRoot) {
        $OutputRoot = Get-DefaultOutputRoot -RepoRoot $repoRoot
    } else {
        if (-not (Test-Path -Path $OutputRoot)) {
            New-Item -Path $OutputRoot -ItemType Directory -Force | Out-Null
        }
    }

    $autoHotkeyResolvedPath = $null
    $autoHotkeyCommand = Get-Command -Name $AutoHotkeyPath -ErrorAction SilentlyContinue
    if ($autoHotkeyCommand) {
        $autoHotkeyResolvedPath = $autoHotkeyCommand.Source
    } elseif (Test-Path -Path $AutoHotkeyPath) {
        $autoHotkeyResolvedPath = (Resolve-Path -Path $AutoHotkeyPath).Path
    } else {
        throw "AutoHotkey executable not found. Provide -AutoHotkeyPath with a valid path."
    }

    $timestamp = Get-Date -Format 'yyyyMMdd_HHmmss'
    $inventoryPath = Join-Path -Path $OutputRoot -ChildPath "inventory_$timestamp.json"
    $summaryPath = Join-Path -Path $OutputRoot -ChildPath "summary_$timestamp.json"

    if (-not $SkipInventory) {
        $inventory = Get-ScriptletInventory -ScriptletsPath $ScriptletsRoot -RepoRoot $repoRoot -CategoryFilter $CategoryFilter
        if ($null -eq $inventory) {
            $inventory = @()
        }
        Save-Json -Data $inventory -Path $inventoryPath -Depth 4
        Write-Host "Inventory saved to $inventoryPath"
    } else {
        $latestInventory = Get-ChildItem -Path $OutputRoot -Filter 'inventory_*.json' | Sort-Object LastWriteTime -Descending | Select-Object -First 1
        if (-not $latestInventory) {
            throw "No existing inventory found. Remove -SkipInventory to generate one."
        }
        $inventoryPath = $latestInventory.FullName
        $inventory = Get-Content -Path $inventoryPath | ConvertFrom-Json
        if ($null -eq $inventory) {
            $inventory = @()
        }
    }

    if ($GenerateInventoryOnly) {
        return
    }

    $results = @()
    $logFolder = Join-Path -Path $OutputRoot -ChildPath "logs_$timestamp"
    if (-not (Test-Path -Path $logFolder)) {
        New-Item -Path $logFolder -ItemType Directory -Force | Out-Null
    }

    $queue = [System.Collections.Generic.Queue[object]]::new()
    foreach ($item in $inventory) {
        $null = $queue.Enqueue($item)
    }

    while ($queue.Count -gt 0) {
        $batch = @()
        for ($i = 0; $i -lt $Throttle -and $queue.Count -gt 0; $i++) {
            $batch += $queue.Dequeue()
        }

        foreach ($item in $batch) {
            $logFileName = "{0}_{1}.log" -f ($item.name -replace '[^a-zA-Z0-9_-]', '_'), $timestamp
            $logPath = Join-Path -Path $logFolder -ChildPath $logFileName
            $results += Invoke-Scriptlet -AutoHotkeyPath $autoHotkeyResolvedPath -ScriptPath $item.path -TimeoutSeconds $TimeoutSeconds -LogPath $logPath -WarnOptions $WarnOptions
        }
    }

    $summary = Get-Summary -Results $results
    $summaryObject = [ordered]@{
        summary  = $summary
        results  = $results
        metadata = [ordered]@{
            generatedUtc   = (Get-Date).ToUniversalTime().ToString('o')
            timeoutSeconds = $TimeoutSeconds
            throttle       = $Throttle
            autoHotkeyPath = $autoHotkeyResolvedPath
            inventoryPath  = $inventoryPath
            logFolder      = $logFolder
            warnOptions    = $WarnOptions
        }
    }

    Save-Json -Data $summaryObject -Path $summaryPath -Depth 6
    Write-Host "Summary saved to $summaryPath"

} catch {
    $errorTimestamp = (Get-Date).ToUniversalTime().ToString('yyyy-MM-dd HH:mm:ss')
    $errorMessage = "[$errorTimestamp] [HARNESS] Unhandled exception: $($_.Exception.Message)"
    $harnessStackTrace = $_.Exception.StackTrace
    Write-Error $errorMessage
    if ($harnessStackTrace) {
        Write-Error $harnessStackTrace
    }
    try {
        $repoRootForLog = if ($repoRoot) { $repoRoot } else { Resolve-RepositoryRoot -StartingPath (Split-Path -Parent $MyInvocation.MyCommand.Path) }
        $harnessLogDir = Join-Path -Path $repoRootForLog -ChildPath "logs\bugbash"
        if (-not (Test-Path -Path $harnessLogDir)) {
            New-Item -Path $harnessLogDir -ItemType Directory -Force | Out-Null
        }
        $harnessLogPath = Join-Path -Path $harnessLogDir -ChildPath "harness_errors.log"
        $logEntry = "$errorMessage`n$harnessStackTrace`n---`n"
        Add-Content -Path $harnessLogPath -Value $logEntry -Encoding UTF8
    } catch {
        Write-Error "Failed to write harness error log: $($_.Exception.Message)"
    }
    exit 1
}
