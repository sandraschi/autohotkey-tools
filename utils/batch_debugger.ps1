# Batch Scriptlet Debugger and Fixer
# PowerShell script to analyze and fix common AutoHotkey v2 issues

param(
    [string]$ScriptletsPath = ".\scriptlets",
    [switch]$Fix,
    [switch]$Report,
    [switch]$Verbose
)

Write-Host "🔧 AutoHotkey Scriptlet Batch Debugger" -ForegroundColor Cyan
Write-Host "=====================================" -ForegroundColor Cyan

# Common AutoHotkey v2 fixes
$CommonFixes = @{
    # FormatTime syntax fixes
    "FormatTime\s+(\w+),\s*," = "FormatTime(`$1, ,"
    
    # FileRead syntax fixes  
    "FileRead\s+(\w+),\s*(\w+)" = "FileRead(`$1, `$2)"
    
    # MsgBox syntax fixes
    "MsgBox\s+(\w+)" = "MsgBox(`$1)"
    
    # Hotkey syntax fixes - DISABLED: too dangerous, use manual fixes
    # "(\w+)::" = "Hotkey(`"`$1`", (*) =>`"
    
    # String functions
    "StringReplace\s*\(([^)]+)\)" = "StrReplace(`$1)"
    "StringSplit\s*\(([^)]+)\)" = "StrSplit(`$1)"
    "StringLen\s*\(([^)]+)\)" = "StrLen(`$1)"
    
    # GUI commands
    "Gui,\s*([^`n]+)" = "gui := Gui(`$1)"
    "GuiAdd,\s*([^`n]+)" = "gui.Add(`$1)"
    "GuiShow,\s*([^`n]+)" = "gui.Show(`$1)"
    "GuiClose,\s*([^`n]+)" = "gui.Close(`$1)"
}

# Get all .ahk files
$AhkFiles = Get-ChildItem -Path $ScriptletsPath -Filter "*.ahk" -Recurse

Write-Host "Found $($AhkFiles.Count) AutoHotkey files to analyze" -ForegroundColor Yellow

$TotalIssues = 0
$FixedFiles = 0
$ErrorFiles = 0
$ReportData = @()

foreach ($File in $AhkFiles) {
    Write-Host "`nAnalyzing: $($File.Name)" -ForegroundColor Green
    
    try {
        $Content = Get-Content -Path $File.FullName -Raw -Encoding UTF8
        $OriginalContent = $Content
        $Issues = @()
        
        # Check for common issues
        foreach ($Pattern in $CommonFixes.Keys) {
            $Matches = [regex]::Matches($Content, $Pattern)
            if ($Matches.Count -gt 0) {
                foreach ($Match in $Matches) {
                    $Issues += "Found: $($Match.Value) - Should be: $($CommonFixes[$Pattern])"
                }
                
                if ($Fix) {
                    $Content = $Content -replace $Pattern, $CommonFixes[$Pattern]
                }
            }
        }
        
        # Additional checks
        if ($Content -notmatch "#Requires AutoHotkey v2\.0") {
            $Issues += "Missing #Requires AutoHotkey v2.0 directive"
        }
        
        if ($Content -notmatch "class\s+\w+") {
            $Issues += "No class definition found"
        }
        
        if ($Content -notmatch "static\s+Init\s*\(") {
            $Issues += "Missing Init() method"
        }
        
        # Check for v1 syntax
        $V1Patterns = @(
            "Gui,",
            "GuiAdd,",
            "GuiShow,",
            "GuiClose,",
            "GuiControl,",
            "StringReplace,",
            "StringSplit,",
            "StringLen,"
        )
        
        foreach ($V1Pattern in $V1Patterns) {
            if ($Content -match $V1Pattern) {
                $Issues += "Found v1 syntax: $V1Pattern - needs updating to v2"
            }
        }
        
        $TotalIssues += $Issues.Count
        
        if ($Issues.Count -gt 0) {
            Write-Host "  Issues found: $($Issues.Count)" -ForegroundColor Red
            if ($Verbose) {
                foreach ($Issue in $Issues) {
                    Write-Host "    - $Issue" -ForegroundColor Red
                }
            }
            
            if ($Fix -and $Content -ne $OriginalContent) {
                Set-Content -Path $File.FullName -Value $Content -Encoding UTF8
                Write-Host "  ✅ Fixed issues in $($File.Name)" -ForegroundColor Green
                $FixedFiles++
            }
        } else {
            Write-Host "  ✅ No issues found" -ForegroundColor Green
        }
        
        # Store report data
        $ReportData += [PSCustomObject]@{
            File = $File.Name
            Path = $File.FullName
            Issues = $Issues.Count
            IssueDetails = $Issues -join "; "
            Status = if ($Issues.Count -eq 0) { "Clean" } else { "Has Issues" }
        }
        
    } catch {
        Write-Host "  ❌ Error processing file: $($_.Exception.Message)" -ForegroundColor Red
        $ErrorFiles++
    }
}

# Generate summary
Write-Host "`n📊 Analysis Summary" -ForegroundColor Cyan
Write-Host "===================" -ForegroundColor Cyan
Write-Host "Total files analyzed: $($AhkFiles.Count)" -ForegroundColor White
Write-Host "Total issues found: $TotalIssues" -ForegroundColor White
Write-Host "Files with issues: $($ReportData | Where-Object { $_.Issues -gt 0 } | Measure-Object).Count" -ForegroundColor White
Write-Host "Files fixed: $FixedFiles" -ForegroundColor White
Write-Host "Files with errors: $ErrorFiles" -ForegroundColor White

# Generate report if requested
if ($Report) {
    $ReportFile = ".\scriptlet_analysis_report_$(Get-Date -Format 'yyyyMMdd_HHmmss').csv"
    $ReportData | Export-Csv -Path $ReportFile -NoTypeInformation
    Write-Host "`n📋 Report saved to: $ReportFile" -ForegroundColor Green
    
    # Also create a text summary
    $SummaryFile = ".\scriptlet_analysis_summary_$(Get-Date -Format 'yyyyMMdd_HHmmss').txt"
    $Summary = @"
AutoHotkey Scriptlet Analysis Summary
Generated: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')

SUMMARY:
- Total files analyzed: $($AhkFiles.Count)
- Total issues found: $TotalIssues
- Files with issues: $(($ReportData | Where-Object { $_.Issues -gt 0 }).Count)
- Files fixed: $FixedFiles
- Files with errors: $ErrorFiles

DETAILED RESULTS:
"@
    
    foreach ($Item in $ReportData) {
        $Summary += "`nFile: $($Item.File)`n"
        $Summary += "Path: $($Item.Path)`n"
        $Summary += "Issues: $($Item.Issues)`n"
        if ($Item.Issues -gt 0) {
            $Summary += "Details: $($Item.IssueDetails)`n"
        }
        $Summary += "Status: $($Item.Status)`n"
    }
    
    Set-Content -Path $SummaryFile -Value $Summary -Encoding UTF8
    Write-Host "📋 Summary saved to: $SummaryFile" -ForegroundColor Green
}

Write-Host "`n✅ Analysis complete!" -ForegroundColor Green
