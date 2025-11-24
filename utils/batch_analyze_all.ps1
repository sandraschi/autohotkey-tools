# Batch AutoHotkey Linter
# Analyzes all scriptlets and creates a comprehensive report

Write-Host "=== AutoHotkey Scriptlet Batch Analysis ===" -ForegroundColor Cyan

$scriptlets = Get-ChildItem -Path ".\scriptlets" -Filter "*.ahk"
$totalFiles = $scriptlets.Count
$currentFile = 0

$allResults = @()

foreach ($file in $scriptlets) {
    $currentFile++
    Write-Host "`n[$currentFile/$totalFiles] Analyzing: $($file.Name)" -ForegroundColor Yellow
    
    try {
        # Run the linter
        .\utils\run_linter_clean.ps1 -ScriptletPath $file.FullName
        
        # Read the report if it exists
        $reportFile = ".\utils\lint_report.txt"
        if (Test-Path $reportFile) {
            $reportContent = Get-Content $reportFile -Raw
            $allResults += [PSCustomObject]@{
                File = $file.Name
                Report = $reportContent
                Success = $true
            }
        } else {
            $allResults += [PSCustomObject]@{
                File = $file.Name
                Report = "No report generated"
                Success = $false
            }
        }
    } catch {
        $allResults += [PSCustomObject]@{
            File = $file.Name
            Report = "Error: $($_.Exception.Message)"
            Success = $false
        }
    }
    
    Start-Sleep -Seconds 1
}

# Create comprehensive report
$summaryReport = "=== COMPREHENSIVE LINT ANALYSIS REPORT ===`n"
$summaryReport += "Generated: $(Get-Date)`n"
$summaryReport += "Total Files Analyzed: $totalFiles`n`n"

$errorCount = 0
$warningCount = 0
$filesWithErrors = @()
$filesWithWarnings = @()

foreach ($result in $allResults) {
    $summaryReport += "`n=== $($result.File) ===`n"
    $summaryReport += $result.Report
    $summaryReport += "`n"
    
    # Count errors and warnings
    if ($result.Report -match "ERRORS \((\d+)\):") {
        if ($matches -and $matches.Count -gt 1) {
            $fileErrors = [int]$matches[1]
            $errorCount += $fileErrors
            if ($fileErrors -gt 0) {
                $filesWithErrors += $result.File
            }
        }
    }
    
    if ($result.Report -match "WARNINGS \((\d+)\):") {
        if ($matches -and $matches.Count -gt 1) {
            $fileWarnings = [int]$matches[1]
            $warningCount += $fileWarnings
            if ($fileWarnings -gt 0) {
                $filesWithWarnings += $result.File
            }
        }
    }
}

$summaryReport += "`n=== SUMMARY ===`n"
$summaryReport += "Total Errors Found: $errorCount`n"
$summaryReport += "Total Warnings Found: $warningCount`n"
$summaryReport += "Files with Errors: $($filesWithErrors.Count)`n"
$summaryReport += "Files with Warnings: $($filesWithWarnings.Count)`n"

if ($filesWithErrors.Count -gt 0) {
    $summaryReport += "`nFiles with Errors:`n"
    foreach ($file in $filesWithErrors) {
        $summaryReport += "  - $file`n"
    }
}

if ($filesWithWarnings.Count -gt 0) {
    $summaryReport += "`nFiles with Warnings:`n"
    foreach ($file in $filesWithWarnings) {
        $summaryReport += "  - $file`n"
    }
}

# Save comprehensive report
$summaryReport | Out-File -FilePath ".\docs\comprehensive_lint_report.txt" -Encoding UTF8

Write-Host "`n=== ANALYSIS COMPLETE ===" -ForegroundColor Green
Write-Host "Total Errors: $errorCount" -ForegroundColor Red
Write-Host "Total Warnings: $warningCount" -ForegroundColor Yellow
Write-Host "Comprehensive report saved to: .\docs\comprehensive_lint_report.txt" -ForegroundColor Cyan
