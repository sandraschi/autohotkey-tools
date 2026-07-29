# AutoHotkey Scriptlet Creator with Auto-Fix and Dashboard Integration
# Usage: .\create_scriptlet.ps1 -Name "My Script" -Description "Does something" -Category "utility" -Template "basic"

param(
    [Parameter(Mandatory=$true)]
    [string]$Name,
    
    [Parameter(Mandatory=$true)]
    [string]$Description,
    
    [string]$Category = "utility",
    
    [ValidateSet("basic", "gui", "automation", "utility")]
    [string]$Template = "basic",
    
    [string]$Code = "",
    
    [string]$Hotkeys = ""
)

Write-Host "hi! Creating scriptlet: $Name" -ForegroundColor Cyan

# Step 1: Generate the script
Write-Host "`n[1/4] Generating scriptlet..." -ForegroundColor Yellow
$generatorPath = "utils\script_generator.ahk"

# Build arguments
$args = @(
    "$Name",
    "$Description",
    "$Category",
    "$Template"
)

if ($Code) {
    $args += $Code
}

# Run generator silently
$result = & autohotkey.exe /ErrorStdOut "utils\script_generator.ahk" $args 2>&1
if ($LASTEXITCODE -ne 0) {
    Write-Host "Error generating script: $result" -ForegroundColor Red
    exit 1
}

Write-Host "  âœ" Script generated" -ForegroundColor Green

# Step 2: Auto-fix the script
Write-Host "`n[2/4] Auto-fixing scriptlet..." -ForegroundColor Yellow
$filename = ($Name -replace " ", "_").ToLower() + ".ahk"
$scriptPath = "scriptlets\$filename"

if (Test-Path $scriptPath) {
    $fixResult = & autohotkey.exe /ErrorStdOut "utils\autofix_engine.ahk" "$scriptPath" 2>&1
    Write-Host "  âœ" Auto-fixes applied" -ForegroundColor Green
} else {
    Write-Host "  âœ- Script not found: $scriptPath" -ForegroundColor Red
    exit 1
}

# Step 3: Lint and validate
Write-Host "`n[3/4] Validating scriptlet..." -ForegroundColor Yellow
$lintResult = & autohotkey.exe /ErrorStdOut "utils\linter.ahk" "$scriptPath" 2>&1
if ($LASTEXITCODE -eq 0) {
    Write-Host "  âœ" Linting passed" -ForegroundColor Green
} else {
    Write-Host "  âš  Linting issues found (see output)" -ForegroundColor Yellow
    Write-Host $lintResult -ForegroundColor Gray
}

# Step 4: Run test execution
Write-Host "`n[4/4] Testing execution..." -ForegroundColor Yellow
$testResult = & autohotkey.exe /ErrorStdOut "$scriptPath" 2>&1
if ($LASTEXITCODE -eq 0) {
    Write-Host "  âœ" Script executes without errors" -ForegroundColor Green
} else {
    Write-Host "  âš  Execution test issues:" -ForegroundColor Yellow
    Write-Host $testResult -ForegroundColor Gray
}

# Summary
Write-Host "`n" -NoNewline
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Scriptlet created successfully!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Name:      $Name"
Write-Host "Path:      $scriptPath"
Write-Host "Category:  $Category"
Write-Host "Template:  $Template"
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Yellow
Write-Host "  1. Review the script at: $scriptPath"
Write-Host "  2. Add to dashboard by running: ScriptletCOMBridge.ahk"
Write-Host "  3. Test with: autohotkey.exe /ErrorStdOut `"$scriptPath`""
Write-Host ""







