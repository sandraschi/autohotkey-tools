# ==============================================================================
# AutoHotkey Linting Helper
# Detects large embedded text blocks that may cause false linter errors
# ==============================================================================

param(
    [string]$ScriptPath,
    [string]$ScriptletsRoot = "scriptlets",
    [switch]$Fix,
    [int]$MinLines = 20
)

function Test-LargeTextBlock {
    param([string]$FilePath)
    
    $content = Get-Content -Path $FilePath -Raw
    $lines = Get-Content -Path $FilePath
    
    # Find multi-line string literals (content: " ... ")
    $pattern = '(?s)content:\s*"([^"]*(?:\n[^"]*)*)"'
    $matches = [regex]::Matches($content, $pattern)
    
    $issues = @()
    foreach ($match in $matches) {
        $textBlock = $match.Groups[1].Value
        $lineCount = ($textBlock -split "`n").Count
        
        if ($lineCount -ge $MinLines) {
            # Find line number
            $beforeMatch = $content.Substring(0, $match.Index)
            $lineNumber = ($beforeMatch -split "`n").Count
            
            $issues += [PSCustomObject]@{
                File = $FilePath
                Line = $lineNumber
                Lines = $lineCount
                Snippet = ($textBlock -split "`n")[0..4] -join "`n"
            }
        }
    }
    
    return $issues
}

function Get-ScriptletsWithLargeText {
    param([string]$Root)
    
    $scripts = Get-ChildItem -Path $Root -Filter "*.ahk" -Recurse | Where-Object {
        $_.FullName -notmatch "\\v1\\" -and
        $_.FullName -notmatch "\\backup\\" -and
        $_.FullName -notmatch "\\junk\\"
    }
    
    $allIssues = @()
    foreach ($script in $scripts) {
        $issues = Test-LargeTextBlock -FilePath $script.FullName
        if ($issues) {
            $allIssues += $issues
        }
    }
    
    return $allIssues
}

# Main execution
if ($ScriptPath) {
    if (-not (Test-Path $ScriptPath)) {
        Write-Error "Script not found: $ScriptPath"
        exit 1
    }
    
    $issues = Test-LargeTextBlock -FilePath $ScriptPath
    if ($issues) {
        Write-Host "Found $($issues.Count) large text block(s) in $ScriptPath" -ForegroundColor Yellow
        foreach ($issue in $issues) {
            Write-Host "  Line $($issue.Line): $($issue.Lines) lines" -ForegroundColor Yellow
            Write-Host "  Snippet: $($issue.Snippet.Substring(0, [Math]::Min(80, $issue.Snippet.Length)))..." -ForegroundColor Gray
        }
        exit 1
    } else {
        Write-Host "No large text blocks found in $ScriptPath" -ForegroundColor Green
        exit 0
    }
} else {
    $issues = Get-ScriptletsWithLargeText -Root $ScriptletsRoot
    if ($issues) {
        Write-Host "Found $($issues.Count) script(s) with large embedded text blocks:" -ForegroundColor Yellow
        $grouped = $issues | Group-Object -Property File
        foreach ($group in $grouped) {
            Write-Host "`n  $($group.Name):" -ForegroundColor Cyan
            foreach ($issue in $group.Group) {
                Write-Host "    Line $($issue.Line): $($issue.Lines) lines" -ForegroundColor Yellow
            }
        }
        Write-Host "`nRecommendation: Externalize large text blocks to .md files and load them at runtime." -ForegroundColor Green
        exit 1
    } else {
        Write-Host "No scripts with large embedded text blocks found." -ForegroundColor Green
        exit 0
    }
}

