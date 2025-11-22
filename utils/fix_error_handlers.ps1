# Fix Error Handlers to Add OutputDebug for LLM Debugging
# This script adds OutputDebug to all LogError functions in scriptlets

$scriptletsPath = ".\scriptlets\*.ahk"
$files = Get-ChildItem -Path $scriptletsPath -File

Write-Host "hi! Found $($files.Count) scriptlet files to process"

foreach ($file in $files) {
    $content = Get-Content -Path $file.FullName -Raw
    
    # Check if file has LogError function
    if ($content -match 'LogError\(Exception, Mode\)') {
        Write-Host "Processing: $($file.Name)"
        
        # Pattern to find LogError without OutputDebug
        $pattern1 = '(?s)(LogError\(Exception, Mode\) \{[^}]*?)(FileAppend[^\n]*)'
        
        if ($content -match $pattern1) {
            # Check if it already has OutputDebug
            if ($content -notmatch 'OutputDebug\(errorMsg\)') {
                # Add OutputDebug after FileAppend
                $content = $content -replace '(LogError\(Exception, Mode\) \{)([^}]*?)(FileAppend\([^)]+\)[^\n]+)([^}]*?)(return true)', '$1$2$3`n        OutputDebug(errorMsg)  ; Enable LLM debugging$4$5'
                
                Write-Host "  - Added OutputDebug to LogError"
                
                # Add errorMsg variable if missing
                if ($content -match 'FileAppend\("Error:' -and $content -notmatch 'errorMsg :=') {
                    $content = $content -replace '(LogError\(Exception, Mode\) \{[^`]*?)FileAppend\((.+?)\)', '$1errorMsg := $2`n        FileAppend(errorMsg'
                }
                
                Set-Content -Path $file.FullName -Value $content -NoNewline
                Write-Host "  - Updated: $($file.Name)" -ForegroundColor Green
            } else {
                Write-Host "  - Already has OutputDebug" -ForegroundColor Yellow
            }
        }
    }
}

Write-Host "`nhi! Done processing $($files.Count) files"















