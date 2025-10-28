# Add OnError handler to all AutoHotkey v2 scripts
# This prevents error popups during development and debugging

$scriptsDir = "scriptlets"
$files = Get-ChildItem -Path $scriptsDir -Filter "*.ahk" -Recurse

$addedCount = 0
$skippedCount = 0

foreach ($file in $files) {
    $content = Get-Content $file.FullName -Raw -Encoding UTF8
    
    # Skip if already has OnError
    if ($content -match "OnError\(") {
        Write-Host "Skipping (already has OnError): $($file.Name)" -ForegroundColor Yellow
        $skippedCount++
        continue
    }
    
    # Skip v1 scripts
    if ($content -notmatch "#Requires AutoHotkey v2") {
        Write-Host "Skipping (not v2): $($file.Name)" -ForegroundColor Gray
        continue
    }
    
    # Create the OnError handler
    $onErrorHandler = @"

; Suppress error popups - log to file instead
OnError("LogError")

LogError(Exception, Mode) {
    FileAppend("Error: " . Exception.Message . " at line " . Exception.Line . "`n", "errors.log", "UTF-8")
    return true  ; Suppress popup
}

"@
    
    # Insert after #SingleInstance (or at the top if no #SingleInstance)
    if ($content -match "(#SingleInstance Force)") {
        $newContent = $content -replace "(#SingleInstance Force)", "`$1`n`n$onErrorHandler"
    } elseif ($content -match "(#Requires AutoHotkey v2.0\+)") {
        $newContent = $content -replace "(#Requires AutoHotkey v2.0\+)", "`$1`n`n$onErrorHandler"
    } else {
        Write-Host "Skipping (unexpected format): $($file.Name)" -ForegroundColor Red
        continue
    }
    
    # Write the modified content
    Set-Content -Path $file.FullName -Value $newContent -Encoding UTF8 -NoNewline
    Write-Host "Added OnError to: $($file.Name)" -ForegroundColor Green
    $addedCount++
}

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "OnError Addition Complete" -ForegroundColor Cyan
Write-Host "Added to: $addedCount scripts" -ForegroundColor Green
Write-Host "Skipped: $skippedCount scripts" -ForegroundColor Yellow
Write-Host "========================================" -ForegroundColor Cyan

