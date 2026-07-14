; ============================================================================
; Windows Cleanup Robot - "Send to Aunt Edna" Edition
; ============================================================================
; Purpose: Analyze Windows system for common issues, report findings,
;          and offer safe cleanup options. Designed for non-technical users.
;
; SECURITY NOTE: This script intentionally does NOT request admin rights
; for the analysis phase. Only cleanup actions that truly need admin will
; prompt separately, with clear explanation of what will be done.
;
; Author: Sandra
; Version: 1.0.0
; License: MIT
; ============================================================================

#Requires AutoHotkey v2.0
#SingleInstance Force

; ============================================================================
; CONFIGURATION
; ============================================================================

global AppName := "Windows Cleanup Robot 🤖"
global AppVersion := "1.0.0"
global ReportFile := A_Temp . "\cleanup_robot_report.txt"
global Issues := []
global Warnings := []
global Info := []

; ============================================================================
; MAIN GUI
; ============================================================================

Main() {
    global MainGui
    
    MainGui := Gui("+Resize", AppName . " v" . AppVersion)
    MainGui.SetFont("s10", "Segoe UI")
    
    ; Header
    MainGui.SetFont("s14 bold")
    MainGui.Add("Text", "w600 Center", "🤖 Windows Cleanup Robot")
    MainGui.SetFont("s10 norm")
    MainGui.Add("Text", "w600 Center", "Analyzing your system for common issues...")
    
    ; Progress
    MainGui.Add("Text", "w600", "")
    global ProgressText := MainGui.Add("Text", "w600 vProgressText", "Starting analysis...")
    global ProgressBar := MainGui.Add("Progress", "w600 h20 vProgressBar Range0-100", 0)
    
    ; Results area
    MainGui.Add("Text", "w600", "")
    MainGui.SetFont("s10 bold")
    MainGui.Add("Text", "w600", "📋 Analysis Results:")
    MainGui.SetFont("s10 norm")
    global ResultsEdit := MainGui.Add("Edit", "w600 h300 vResults ReadOnly Multi")
    
    ; Buttons
    MainGui.Add("Text", "w600", "")
    global AnalyzeBtn := MainGui.Add("Button", "w150", "🔍 Analyze System")
    global CleanupBtn := MainGui.Add("Button", "x+10 w150 Disabled", "🧹 Safe Cleanup")
    global ReportBtn := MainGui.Add("Button", "x+10 w150 Disabled", "📄 Save Report")
    global HelpBtn := MainGui.Add("Button", "x+10 w120", "❓ Help")
    
    AnalyzeBtn.OnEvent("Click", RunAnalysis)
    CleanupBtn.OnEvent("Click", RunCleanup)
    ReportBtn.OnEvent("Click", SaveReport)
    HelpBtn.OnEvent("Click", ShowHelp)
    
    MainGui.OnEvent("Close", (*) => ExitApp())
    MainGui.Show()
}

; ============================================================================
; ANALYSIS FUNCTIONS
; ============================================================================

RunAnalysis(*) {
    global Issues, Warnings, Info, ProgressText, ProgressBar, ResultsEdit
    global CleanupBtn, ReportBtn, AnalyzeBtn
    
    ; Reset
    Issues := []
    Warnings := []
    Info := []
    ResultsEdit.Value := ""
    AnalyzeBtn.Enabled := false
    
    ; Run checks
    checks := [
        {name: "Checking disk space...", func: CheckDiskSpace},
        {name: "Checking temp files...", func: CheckTempFiles},
        {name: "Checking startup programs...", func: CheckStartupPrograms},
        {name: "Checking Windows Update...", func: CheckWindowsUpdate},
        {name: "Checking antivirus status...", func: CheckAntivirus},
        {name: "Checking browser extensions...", func: CheckBrowserExtensions},
        {name: "Checking recent downloads...", func: CheckRecentDownloads},
        {name: "Checking running processes...", func: CheckSuspiciousProcesses},
        {name: "Checking scheduled tasks...", func: CheckScheduledTasks},
        {name: "Checking network connections...", func: CheckNetworkConnections}
    ]
    
    for i, check in checks {
        ProgressText.Value := check.name
        ProgressBar.Value := (i / checks.Length) * 100
        check.func()
        Sleep 200  ; Brief pause so user can see progress
    }
    
    ; Display results
    ProgressText.Value := "Analysis complete!"
    ProgressBar.Value := 100
    DisplayResults()
    
    ; Enable buttons
    AnalyzeBtn.Enabled := true
    CleanupBtn.Enabled := Issues.Length > 0
    ReportBtn.Enabled := true
}

CheckDiskSpace() {
    global Issues, Warnings, Info
    
    ; Check C: drive
    DriveGet, freeSpace, SpaceFreeMB, C:
    DriveGet, totalSpace, Capacity, C:
    
    if !freeSpace
        freeSpace := GetDriveSpaceMB("C:")
    
    if freeSpace < 5000 {  ; Less than 5GB
        Issues.Push({
            category: "Disk Space",
            description: "C: drive has only " . Round(freeSpace/1024, 1) . " GB free - critically low!",
            fix: "cleanup_disk"
        })
    } else if freeSpace < 20000 {  ; Less than 20GB
        Warnings.Push({
            category: "Disk Space",
            description: "C: drive has " . Round(freeSpace/1024, 1) . " GB free - consider cleanup"
        })
    } else {
        Info.Push("✓ Disk space OK: " . Round(freeSpace/1024, 1) . " GB free")
    }
}

GetDriveSpaceMB(drive) {
    try {
        objWMI := ComObject("WbemScripting.SWbemLocator")
        objSWbemServices := objWMI.ConnectServer(".", "root\cimv2")
        colDisks := objSWbemServices.ExecQuery("Select * from Win32_LogicalDisk Where DeviceID='" . drive . "'")
        for disk in colDisks
            return Round(disk.FreeSpace / 1048576)  ; Convert to MB
    }
    return 0
}

CheckTempFiles() {
    global Issues, Warnings, Info
    
    tempSize := GetFolderSizeMB(A_Temp)
    winTempSize := GetFolderSizeMB("C:\Windows\Temp")
    
    totalTemp := tempSize + winTempSize
    
    if totalTemp > 5000 {  ; More than 5GB of temp files
        Issues.Push({
            category: "Temp Files",
            description: "Temp folders contain " . Round(totalTemp/1024, 1) . " GB - cleanup recommended",
            fix: "cleanup_temp"
        })
    } else if totalTemp > 1000 {
        Warnings.Push({
            category: "Temp Files",
            description: "Temp folders contain " . Round(totalTemp/1024, 1) . " GB"
        })
    } else {
        Info.Push("✓ Temp files OK: " . totalTemp . " MB")
    }
}

GetFolderSizeMB(folder) {
    totalSize := 0
    try {
        Loop Files folder . "\*.*", "RF"
            totalSize += A_LoopFileSize
    }
    return Round(totalSize / 1048576)  ; MB
}

CheckStartupPrograms() {
    global Issues, Warnings, Info
    
    startupCount := 0
    suspiciousStartup := []
    
    ; Check Run registry keys
    try {
        Loop Reg, "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Run"
        {
            startupCount++
            value := RegRead()
            ; Check for suspicious patterns
            if InStr(value, "temp") || InStr(value, "appdata\local\temp")
                suspiciousStartup.Push(A_LoopRegName)
        }
    }
    
    if suspiciousStartup.Length > 0 {
        Issues.Push({
            category: "Startup Programs",
            description: "Suspicious startup entries found: " . StrJoin(suspiciousStartup, ", "),
            fix: "review_startup"
        })
    } else if startupCount > 10 {
        Warnings.Push({
            category: "Startup Programs",
            description: startupCount . " programs start with Windows - may slow boot"
        })
    } else {
        Info.Push("✓ Startup programs OK: " . startupCount . " entries")
    }
}

CheckWindowsUpdate() {
    global Issues, Warnings, Info
    
    ; Check if Windows Update service is running
    try {
        objWMI := ComObject("WbemScripting.SWbemLocator")
        objSWbemServices := objWMI.ConnectServer(".", "root\cimv2")
        colServices := objSWbemServices.ExecQuery("Select * from Win32_Service Where Name='wuauserv'")
        
        for service in colServices {
            if service.State != "Running" {
                Warnings.Push({
                    category: "Windows Update",
                    description: "Windows Update service is not running"
                })
                return
            }
        }
    }
    
    Info.Push("✓ Windows Update service is running")
}

CheckAntivirus() {
    global Issues, Warnings, Info
    
    ; Check Windows Security Center for antivirus
    avFound := false
    avName := ""
    
    try {
        objWMI := ComObject("WbemScripting.SWbemLocator")
        objSWbemServices := objWMI.ConnectServer(".", "root\SecurityCenter2")
        colAV := objSWbemServices.ExecQuery("Select * from AntiVirusProduct")
        
        for av in colAV {
            avFound := true
            avName := av.displayName
            
            ; Check if enabled (productState analysis)
            ; Bit 12 (4096) = enabled, Bit 4 (16) = up to date
            state := av.productState
            enabled := (state & 0x1000) > 0
            upToDate := (state & 0x10) = 0  ; 0 means up to date
            
            if !enabled {
                Issues.Push({
                    category: "Antivirus",
                    description: avName . " is DISABLED - high security risk!",
                    fix: "enable_av"
                })
            } else if !upToDate {
                Warnings.Push({
                    category: "Antivirus",
                    description: avName . " definitions may be outdated"
                })
            } else {
                Info.Push("✓ Antivirus OK: " . avName . " (enabled, up to date)")
            }
            break  ; Just check first AV
        }
    }
    
    if !avFound {
        Issues.Push({
            category: "Antivirus",
            description: "No antivirus detected - high security risk!",
            fix: "install_av"
        })
    }
}

CheckBrowserExtensions() {
    global Issues, Warnings, Info
    
    ; Check Chrome extensions count (rough indicator)
    chromeExtPath := A_AppData . "\..\Local\Google\Chrome\User Data\Default\Extensions"
    extCount := 0
    
    if DirExist(chromeExtPath) {
        Loop Files chromeExtPath . "\*", "D"
            extCount++
    }
    
    if extCount > 20 {
        Warnings.Push({
            category: "Browser Extensions",
            description: "Chrome has " . extCount . " extensions - some may be unwanted"
        })
    } else if extCount > 0 {
        Info.Push("✓ Chrome extensions: " . extCount)
    }
}

CheckRecentDownloads() {
    global Issues, Warnings, Info
    
    downloadPath := A_MyDocuments . "\..\Downloads"
    exeCount := 0
    recentExe := []
    
    if DirExist(downloadPath) {
        Loop Files downloadPath . "\*.exe"
        {
            exeCount++
            ; Check if downloaded in last 7 days
            if DateDiff(A_Now, A_LoopFileTimeCreated, "days") < 7
                recentExe.Push(A_LoopFileName)
        }
    }
    
    if recentExe.Length > 0 {
        Warnings.Push({
            category: "Recent Downloads",
            description: recentExe.Length . " new .exe files in Downloads: " . StrJoin(recentExe, ", ")
        })
    } else {
        Info.Push("✓ No suspicious recent downloads")
    }
}

CheckSuspiciousProcesses() {
    global Issues, Warnings, Info
    
    ; Known suspicious process names (very basic check)
    suspicious := ["cryptominer", "miner", "keylogger"]
    foundSuspicious := []
    
    try {
        objWMI := ComObject("WbemScripting.SWbemLocator")
        objSWbemServices := objWMI.ConnectServer(".", "root\cimv2")
        colProcesses := objSWbemServices.ExecQuery("Select * from Win32_Process")
        
        for proc in colProcesses {
            procName := StrLower(proc.Name)
            for term in suspicious {
                if InStr(procName, term)
                    foundSuspicious.Push(proc.Name)
            }
        }
    }
    
    if foundSuspicious.Length > 0 {
        Issues.Push({
            category: "Suspicious Processes",
            description: "Potentially malicious processes found: " . StrJoin(foundSuspicious, ", "),
            fix: "kill_process"
        })
    } else {
        Info.Push("✓ No obviously suspicious processes detected")
    }
}

CheckScheduledTasks() {
    global Issues, Warnings, Info
    
    ; Check for recently created scheduled tasks (PowerShell-based)
    ; This is informational - deep analysis would need admin
    Info.Push("✓ Scheduled tasks check requires manual review")
}

CheckNetworkConnections() {
    global Issues, Warnings, Info
    
    ; Basic network check
    try {
        ; Check if connected to internet
        httpObj := ComObject("WinHttp.WinHttpRequest.5.1")
        httpObj.Open("GET", "https://www.google.com", false)
        httpObj.Send()
        
        if httpObj.Status = 200
            Info.Push("✓ Internet connection OK")
        else
            Warnings.Push({category: "Network", description: "Internet connection issues detected"})
    } catch {
        Warnings.Push({category: "Network", description: "Could not verify internet connection"})
    }
}

; ============================================================================
; DISPLAY & REPORTING
; ============================================================================

DisplayResults() {
    global Issues, Warnings, Info, ResultsEdit
    
    output := ""
    
    ; Issues (red)
    if Issues.Length > 0 {
        output .= "🔴 ISSUES FOUND (" . Issues.Length . "):`n"
        output .= "═══════════════════════════════════════`n"
        for issue in Issues {
            output .= "  ⚠️ [" . issue.category . "] " . issue.description . "`n"
        }
        output .= "`n"
    }
    
    ; Warnings (yellow)
    if Warnings.Length > 0 {
        output .= "🟡 WARNINGS (" . Warnings.Length . "):`n"
        output .= "═══════════════════════════════════════`n"
        for warning in Warnings {
            output .= "  ⚡ [" . warning.category . "] " . warning.description . "`n"
        }
        output .= "`n"
    }
    
    ; Info (green)
    if Info.Length > 0 {
        output .= "🟢 PASSED CHECKS:`n"
        output .= "═══════════════════════════════════════`n"
        for info in Info {
            output .= "  " . info . "`n"
        }
        output .= "`n"
    }
    
    ; Summary
    output .= "═══════════════════════════════════════`n"
    output .= "SUMMARY: "
    if Issues.Length = 0 && Warnings.Length = 0 {
        output .= "🎉 Your system looks healthy!`n"
    } else if Issues.Length > 0 {
        output .= "🔴 " . Issues.Length . " issues need attention`n"
    } else {
        output .= "🟡 " . Warnings.Length . " minor concerns found`n"
    }
    
    ResultsEdit.Value := output
}

SaveReport(*) {
    global ReportFile, Issues, Warnings, Info
    
    report := "WINDOWS CLEANUP ROBOT REPORT`n"
    report .= "Generated: " . FormatTime(A_Now, "yyyy-MM-dd HH:mm:ss") . "`n"
    report .= "Computer: " . A_ComputerName . "`n"
    report .= "User: " . A_UserName . "`n"
    report .= "═══════════════════════════════════════════════════════`n`n"
    
    report .= "ISSUES (" . Issues.Length . "):`n"
    for issue in Issues
        report .= "  - [" . issue.category . "] " . issue.description . "`n"
    
    report .= "`nWARNINGS (" . Warnings.Length . "):`n"
    for warning in Warnings
        report .= "  - [" . warning.category . "] " . warning.description . "`n"
    
    report .= "`nPASSED CHECKS:`n"
    for info in Info
        report .= "  " . info . "`n"
    
    ; Save to file
    try {
        FileDelete ReportFile
    }
    FileAppend report, ReportFile
    
    MsgBox("Report saved to:`n" . ReportFile . "`n`nSend this to your tech support person!", AppName, "64"
    Run "notepad.exe " . ReportFile
}

; ============================================================================
; CLEANUP FUNCTIONS
; ============================================================================

RunCleanup(*) {
    global Issues
    
    if Issues.Length = 0 {
        MsgBox("No issues to clean up!", AppName, "64"
        return
    }
    
    msg := "The following cleanup actions are available:`n`n"
    
    for issue in Issues {
        if issue.HasProp("fix")
            msg .= "• " . issue.description . "`n"
    }
    
    msg .= "`nDo you want to proceed with safe cleanup?`n"
    msg .= "`n⚠️ Some operations may require administrator approval."
    
    result := MsgBox(msg, AppName, "YesNo")
    
    if result = "Yes" {
        PerformCleanup()
    }
}

PerformCleanup() {
    global Issues
    
    for issue in Issues {
        if !issue.HasProp("fix")
            continue
            
        switch issue.fix {
            case "cleanup_temp":
                CleanupTempFiles()
            case "cleanup_disk":
                RunDiskCleanup()
            case "review_startup":
                OpenStartupManager()
            case "enable_av":
                OpenWindowsSecurity()
            case "install_av":
                OpenWindowsSecurity()
        }
    }
    
    MsgBox("Cleanup operations completed!`n`nRe-run analysis to verify improvements.", AppName, "64"
}

CleanupTempFiles() {
    ; Safe temp cleanup - user's temp folder only
    deletedCount := 0
    
    Loop Files A_Temp . "\*.*", "F"
    {
        try {
            FileDelete A_LoopFilePath
            deletedCount++
        }
    }
    
    MsgBox("Deleted " . deletedCount . " temporary files.", AppName, "64"
}

RunDiskCleanup() {
    ; Launch Windows built-in disk cleanup
    try {
        Run "cleanmgr.exe"
    } catch {
        MsgBox("Could not launch Disk Cleanup. Try running it manually.", AppName, "48"
    }
}

OpenStartupManager() {
    ; Open Task Manager to Startup tab
    try {
        Run "taskmgr.exe"
        Sleep 500
        Send "^+{Escape}"  ; Alternative: Ctrl+Shift+Escape
        Sleep 500
        Send "!s"  ; Alt+S for Startup tab (Windows 11)
    }
}

OpenWindowsSecurity() {
    try {
        Run "windowsdefender:"
    } catch {
        Run "ms-settings:windowsdefender"
    }
}

; ============================================================================
; HELP
; ============================================================================

ShowHelp(*) {
    help := "
    (
🤖 WINDOWS CLEANUP ROBOT HELP

This tool analyzes your Windows computer for common issues:

📊 WHAT IT CHECKS:
• Disk space - Is your hard drive full?
• Temp files - Accumulated junk files
• Startup programs - What runs when Windows starts
• Windows Update - Is it working?
• Antivirus - Is protection enabled?
• Browser extensions - Too many installed?
• Recent downloads - Any suspicious .exe files?
• Running processes - Anything obviously bad?

🔒 SECURITY NOTE:
This tool runs WITHOUT administrator rights for analysis.
Only cleanup operations that truly need admin will ask separately.

📧 FOR TECH SUPPORT:
Click 'Save Report' and send the report file to your
tech-savvy family member or IT support person.

❓ FALSE ALARMS:
This tool uses basic checks. Some warnings may be
false alarms. When in doubt, ask for help!
    )"
    
    MsgBox(help, AppName . " - Help", "64"
}

; ============================================================================
; UTILITY FUNCTIONS
; ============================================================================

StrJoin(arr, delimiter) {
    result := ""
    for i, item in arr {
        if i > 1
            result .= delimiter
        result .= item
    }
    return result
}

; ============================================================================
; RUN
; ============================================================================

Main()

