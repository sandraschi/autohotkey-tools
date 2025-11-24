; ==============================================================================
; Video Filename Scrubber
; @name: Video Filename Scrubber
; @version: 1.0.0
; @description: Cleans and organizes video filenames by removing brackets, replacing dots with spaces, and formatting episodes/movies correctly.
; @category: utilities
; @author: Sandra
; @hotkeys: ^!v
; @enabled: true
; ==============================================================================

#Requires AutoHotkey v2.0+
#SingleInstance Force
#Include %A_ScriptDir%\lib\ScriptletErrorHandler.ahk

; Show that script is starting
TrayTip("Video Filename Scrubber", "Script starting...", 3)

; Log errors but allow GUI errors to show
OnError(LogError)

VideoFilenameScrubberLogError(Thrown, Mode) {
    ScriptletErrorHandler.Handle(Thrown, Mode)
    if (Thrown && (InStr(Thrown.Message, "GUI") || (HasProp(Thrown, "Stack") && InStr(Thrown.Stack, "CreateGUI")))) {
        return 0
    }
    return 1
}

class VideoFilenameScrubber {
    static targetDir := ""
    static logFile := ""
    static dryRun := false
    static enableLog := true
    static videoExtensions := []
    static logArea := ""
    static resultArea := ""
    static guiInstance := ""
    static statsArea := ""
    static dirTextControl := ""
    static processedCount := 0
    static movedCount := 0
    static renamedCount := 0
    static errorCount := 0
    static deletedDirCount := 0
    static operations := []
    static directoriesToCheck := []
    
    static Init() {
        try {
            ; Try to load saved directory from config, or use default
            this.targetDir := this.LoadTargetDirectory()
            this.logFile := "video_filename_scrubber.log"
            this.videoExtensions := [".mkv", ".mp4", ".avi", ".mov", ".wmv", ".flv", ".webm", ".m4v"]
            this.operations := []
            this.directoriesToCheck := []
            TrayTip("Video Filename Scrubber", "Starting GUI...", 2)
            this.CreateGUI()
        } catch as e {
            MsgBox("Init error: " . e.Message . "`n" . e.Stack, "Error", "Icon!")
        }
    }
    
    static LoadTargetDirectory() {
        configFile := "video_filename_scrubber_config.ini"
        if (FileExist(configFile)) {
            try {
                configContent := FileRead(configFile)
                if (RegExMatch(configContent, "i)TargetDir\s*=\s*(.+)", &match)) {
                    savedDir := Trim(match[1])
                    if (DirExist(savedDir)) {
                        return savedDir
                    }
                }
            } catch {
                ; If config read fails, use default
            }
        }
        ; Default to user's Videos folder if it exists
        videosDir := A_MyDocuments . "\..\Videos"
        if (DirExist(videosDir)) {
            return videosDir
        }
        return A_MyDocuments
    }
    
    static SaveTargetDirectory(dirPath) {
        configFile := "video_filename_scrubber_config.ini"
        try {
            FileOpen(configFile, "w", "UTF-8").Write("TargetDir=" . dirPath)
        } catch {
            ; Ignore save errors
        }
    }
    
    static SelectDirectory(*) {
        selectedDir := DirSelect(, 3, "Select Target Directory for Video Files")
        if (selectedDir != "") {
            this.targetDir := selectedDir
            this.SaveTargetDirectory(selectedDir)
            ; Update GUI display
            if (this.guiInstance && this.guiInstance.Hwnd) {
                ; Find and update the target directory text control
                try {
                    ; We'll need to store a reference to the dirText control
                    if (this.dirTextControl && this.dirTextControl.Hwnd) {
                        this.dirTextControl.Text := "Target: " . this.targetDir
                    }
                } catch {
                    ; If update fails, recreate GUI
                    this.guiInstance.Destroy()
                    this.CreateGUI()
                }
            }
            TrayTip("Video Filename Scrubber", "Target directory set to: " . selectedDir, 3)
        }
    }
    
    static CreateGUI() {
        try {
            this.guiInstance := Gui("+Resize +MinSize800x600", "Video Filename Scrubber")
            this.guiInstance.BackColor := "1a1a1a"
            this.guiInstance.SetFont("s10 cFFFFFF", "Segoe UI")
            
            titleText := this.guiInstance.Add("Text", "x20 y20 w760 Center", "Video Filename Scrubber")
            titleText.SetFont("Bold")
            
            statusText := this.dryRun ? "[DRY RUN] No changes will be made" : "[LIVE] Changes will be applied"
            this.guiInstance.Add("Text", "x20 y50 w760 Center cYellow", statusText)
            
            ; Directory selection row
            this.guiInstance.Add("Text", "x20 y80 w100 h25", "Target Directory:")
            this.dirTextControl := this.guiInstance.Add("Text", "x130 y80 w500 h25 cGray", this.targetDir)
            btnSelectDir := this.guiInstance.Add("Button", "x640 y78 w120 h28", "&Select Directory")
            btnSelectDir.OnEvent("Click", ObjBindMethod(this, "SelectDirectory"))
            
            this.guiInstance.Add("Text", "x20 y110", "Results:")
            this.resultArea := this.guiInstance.Add("Edit", "x20 y130 w760 h200 +Multi +ReadOnly VScroll", "")
            this.resultArea.BackColor := "252526"
            
            this.guiInstance.Add("Text", "x20 y340", "Log:")
            this.logArea := this.guiInstance.Add("Edit", "x20 y360 w760 h180 +Multi +ReadOnly VScroll", "")
            this.logArea.BackColor := "252526"
            
            btnStart := this.guiInstance.Add("Button", "x20 y550 w120 h30", "&Start Processing")
            btnStart.OnEvent("Click", (*) => this.ProcessDirectory())
            
            btnClose := this.guiInstance.Add("Button", "x150 y550 w120 h30", "&Close")
            btnClose.OnEvent("Click", (*) => this.guiInstance.Close())
            
            this.statsArea := this.guiInstance.Add("Text", "x300 y550 w480", "Ready to process...")
            
            this.guiInstance.OnEvent("Close", (*) => ExitApp())
            this.guiInstance.OnEvent("Escape", (*) => this.guiInstance.Close())
            
            this.guiInstance.Show("w800 h600 Center")
            WinShow(this.guiInstance.Hwnd)
            WinActivate(this.guiInstance.Hwnd)
        } catch as e {
            errorMsg := "Error creating GUI: " . e.Message . "`n" . e.Stack
            FileAppend(errorMsg, "video_filename_scrubber_errors.log", "UTF-8")
            OutputDebug(errorMsg)
            MsgBox("Error creating GUI: " . e.Message, "Error", "Iconx")
            throw
        }
    }
    
    static ProcessDirectory() {
        this.processedCount := 0
        this.movedCount := 0
        this.renamedCount := 0
        this.errorCount := 0
        this.deletedDirCount := 0
        this.operations := []
        this.directoriesToCheck := []
        
        try {
            this.AppendLog("Starting directory scan: " . this.targetDir)
            
            if (!DirExist(this.targetDir)) {
                errorMsg := "Target directory does not exist: " . this.targetDir
                this.AppendResult("[ERROR] " . errorMsg)
                this.AppendLog("ERROR: " . errorMsg)
                MsgBox(errorMsg, "Directory Error", "Icon!")
                return
            }
            
            this.ProcessDirectoryRecursive(this.targetDir)
            this.AppendLog("Checking for empty directories to delete...")
            this.CleanupEmptyDirectories()
            
            this.AppendResult("`n" . this.StrRepeat("=", 60))
            this.AppendResult("SUMMARY:")
            this.AppendResult("Processed: " . this.processedCount . " files")
            this.AppendResult("Renamed: " . this.renamedCount . " files")
            this.AppendResult("Moved: " . this.movedCount . " files")
            this.AppendResult("Directories deleted: " . this.deletedDirCount)
            this.AppendResult("Errors: " . this.errorCount . " files")
            
            try {
                statsText := "Processed: " . this.processedCount . " | Renamed: " . this.renamedCount . " | Moved: " . this.movedCount . " | Dirs deleted: " . this.deletedDirCount . " | Errors: " . this.errorCount
                if (this.statsArea && this.statsArea.Hwnd) {
                    this.statsArea.Text := statsText
                }
            } catch {
                OutputDebug("Could not update stats display")
            }
            
            this.AppendLog("Processing complete. Total operations: " . this.processedCount)
            
            if (this.enableLog) {
                try {
                    this.SaveLogToFile()
                } catch as saveErr {
                    this.AppendLog("WARNING: Could not save log file: " . saveErr.Message)
                }
            }
        } catch as procErr {
            this.AppendLog("FATAL ERROR: " . procErr.Message)
            this.AppendResult("[FATAL ERROR] " . procErr.Message)
            MsgBox("Processing Error: " . procErr.Message, "Error", "Icon!")
        }
    }
    
    static ProcessDirectoryRecursive(dirPath) {
        if (!DirExist(dirPath)) {
            this.AppendLog("WARNING: Directory does not exist: " . dirPath)
            return
        }
        
        this.AppendLog("Scanning directory: " . dirPath)
        
        try {
            files := []
            Loop Files dirPath . "\*" {
                if (this.IsVideoFile(A_LoopFileName)) {
                    files.Push(A_LoopFileFullPath)
                }
            }
            
            for filePath in files {
                this.ProcessFile(filePath)
            }
            
            Loop Files dirPath . "\*", "D" {
                this.ProcessDirectoryRecursive(A_LoopFileFullPath)
            }
        } catch as err {
            errorMsg := "ERROR processing directory " . dirPath . ": " . err.Message
            this.AppendLog(errorMsg)
            this.AppendResult("[ERROR] " . dirPath . " - " . err.Message)
            this.errorCount++
        }
    }
    
    static ProcessFile(filePath) {
        this.processedCount++
        
        try {
            SplitPath(filePath, &fileName, &fileDir, &fileExt)
            this.AppendLog("Processing: " . fileName)
            
            isInTargetDir := (StrLower(fileDir) = StrLower(this.targetDir))
            cleanedName := this.CleanFilename(fileName)
            formattedName := this.FormatFilename(cleanedName)
            finalFormattedName := this.ResolveDuplicateFilename(formattedName, this.targetDir)
            finalPath := this.targetDir . "\" . finalFormattedName
            
            needsMove := !isInTargetDir
            needsRename := (StrLower(finalFormattedName) != StrLower(fileName))
            
            if (!needsMove && !needsRename) {
                this.AppendLog("  [OK] No changes needed")
                return
            }
            
            operation := ""
            if (needsMove && needsRename) {
                operation := "Move & Rename"
            } else if (needsMove) {
                operation := "Move"
            } else if (needsRename) {
                operation := "Rename"
            }
            
            if (this.dryRun) {
                this.AppendResult("[DRY RUN] [" . operation . "] " . fileName)
                this.AppendResult("    -> " . finalFormattedName)
                if (needsMove) {
                    this.AppendResult("    Move from: " . fileDir)
                }
            } else {
                if (needsMove && needsRename) {
                    try {
                        FileMove(filePath, finalPath, 1)
                        this.AppendResult("[OK] " . operation . ": " . fileName . " -> " . finalFormattedName)
                        this.AppendLog("  [OK] Moved and renamed: " . finalFormattedName)
                        this.movedCount++
                        this.renamedCount++
                        if (fileDir != "" && !this.IsInArray(this.directoriesToCheck, fileDir)) {
                            this.directoriesToCheck.Push(fileDir)
                        }
                    } catch as moveErr {
                        this.AppendLog("  [ERROR] " . moveErr.Message)
                        this.AppendResult("[ERROR] " . fileName . " - " . moveErr.Message)
                        this.errorCount++
                    }
                } else if (needsMove) {
                    try {
                        FileMove(filePath, finalPath, 1)
                        this.AppendResult("[OK] " . operation . ": " . fileName)
                        this.AppendLog("  [OK] Moved: " . fileName)
                        this.movedCount++
                        if (fileDir != "" && !this.IsInArray(this.directoriesToCheck, fileDir)) {
                            this.directoriesToCheck.Push(fileDir)
                        }
                    } catch as moveErr {
                        this.AppendLog("  [ERROR] " . moveErr.Message)
                        this.AppendResult("[ERROR] " . fileName . " - " . moveErr.Message)
                        this.errorCount++
                    }
                } else if (needsRename) {
                    try {
                        FileMove(filePath, finalPath, 1)
                        this.AppendResult("[OK] " . operation . ": " . fileName . " -> " . finalFormattedName)
                        this.AppendLog("  [OK] Renamed: " . finalFormattedName)
                        this.renamedCount++
                    } catch as renameErr {
                        this.AppendLog("  [ERROR] " . renameErr.Message)
                        this.AppendResult("[ERROR] " . fileName . " - " . renameErr.Message)
                        this.errorCount++
                    }
                }
            }
            
            this.operations.Push({
                original: fileName,
                new: finalFormattedName,
                operation: operation,
                path: filePath,
                newPath: finalPath
            })
        } catch as err {
            this.AppendLog("  [ERROR] processing file: " . err.Message)
            this.AppendResult("[ERROR] " . filePath . " - " . err.Message)
            this.errorCount++
        }
    }
    
    static CleanFilename(fileName) {
        SplitPath(fileName, , , &ext)
        baseName := SubStr(fileName, 1, StrLen(fileName) - StrLen(ext))
        cleaned := RegExReplace(baseName, "\[[^\]]+\]", "")
        cleaned := StrReplace(cleaned, ".", " ")
        cleaned := RegExReplace(cleaned, "\s+", " ")
        cleaned := Trim(cleaned)
        return cleaned . ext
    }
    
    static FormatFilename(fileName) {
        SplitPath(fileName, , , &ext)
        baseName := SubStr(fileName, 1, StrLen(fileName) - StrLen(ext))
        
        if (RegExMatch(baseName, "i)(?:s|season)[\s_\.-]*(\d+)[\s_\.-]*(?:e|ep|episode)[\s_\.-]*(\d+)", &match)) {
            seasonNum := Integer(match[1])
            episodeNum := Integer(match[2])
            season := (seasonNum < 10 ? "0" : "") . String(seasonNum)
            episode := (episodeNum < 10 ? "0" : "") . String(episodeNum)
            showName := RegExReplace(baseName, "i)(?:s|season)[\s_\.-]*\d+[\s_\.-]*(?:e|ep|episode)[\s_\.-]*\d+.*$", "")
            showName := Trim(RegExReplace(showName, "[\s_\.-]+", " "))
            return showName . " - s" . season . "e" . episode . ext
        }
        
        if (RegExMatch(baseName, "(\d+)[\s_\.-]*[xX][\s_\.-]*(\d+)", &match)) {
            seasonNum := Integer(match[1])
            episodeNum := Integer(match[2])
            season := (seasonNum < 10 ? "0" : "") . String(seasonNum)
            episode := (episodeNum < 10 ? "0" : "") . String(episodeNum)
            showName := RegExReplace(baseName, "\d+[\s_\.-]*[xX][\s_\.-]*\d+.*$", "")
            showName := Trim(RegExReplace(showName, "[\s_\.-]+", " "))
            return showName . " - s" . season . "e" . episode . ext
        }
        
        if (RegExMatch(baseName, "i)(?:^|[\s_\.-])(?:e|ep|episode)[\s_\.-]*(\d+)", &match)) {
            season := "01"
            episodeNum := Integer(match[1])
            episode := (episodeNum < 10 ? "0" : "") . String(episodeNum)
            showName := RegExReplace(baseName, "i)(?:[\s_\.-]|^)(?:e|ep|episode)[\s_\.-]*\d+.*$", "")
            showName := Trim(RegExReplace(showName, "[\s_\.-]+", " "))
            return showName . " - s" . season . "e" . episode . ext
        }
        
        if (RegExMatch(baseName, "\((\d{4})\)", &match)) {
            year := match[1]
            movieName := RegExReplace(baseName, "\((\d{4})\)", "")
            movieName := Trim(RegExReplace(movieName, "[\s_\.-]+", " "))
            return movieName . " (" . year . ")" . ext
        }
        
        if (RegExMatch(baseName, "\b(19|20)\d{2}\b", &yearMatch)) {
            year := yearMatch[0]
            movieName := RegExReplace(baseName, "\b(19|20)\d{2}\b", "")
            movieName := Trim(RegExReplace(movieName, "[\s_\.-]+", " "))
            return movieName . " (" . year . ")" . ext
        }
        
        return fileName
    }
    
    static IsVideoFile(fileName) {
        SplitPath(fileName, , , &ext)
        ext := StrLower(ext)
        for videoExt in this.videoExtensions {
            if (ext = videoExt) {
                return true
            }
        }
        return false
    }
    
    static AppendLog(message) {
        timestamp := ""
        FormatTime(timestamp, A_Now, "HH:mm:ss")
        logMessage := "[" . timestamp . "] " . message . "`n"
        try {
            if (this.logArea && this.logArea.Hwnd) {
                this.logArea.Text .= logMessage
                this.logArea.Focus()
                Send("^{End}")
            } else {
                OutputDebug(logMessage)
            }
        } catch {
            OutputDebug(logMessage)
        }
        if (this.enableLog) {
            try {
                FileAppend(logMessage, this.logFile, "UTF-8")
            } catch {
            }
        }
    }
    
    static AppendResult(message) {
        resultMessage := message . "`n"
        try {
            if (this.resultArea && this.resultArea.Hwnd) {
                this.resultArea.Text .= resultMessage
                this.resultArea.Focus()
                Send("^{End}")
            } else {
                OutputDebug(resultMessage)
            }
        } catch {
            OutputDebug(resultMessage)
        }
    }
    
    static StrRepeat(str, count) {
        result := ""
        Loop count {
            result .= str
        }
        return result
    }
    
    static IsInArray(arr, value) {
        for item in arr {
            if (item = value) {
                return true
            }
        }
        return false
    }
    
    static CleanupEmptyDirectories() {
        sortedDirs := this.SortDirectoriesByDepth(this.directoriesToCheck)
        for dirPath in sortedDirs {
            if (this.DeleteEmptyDirectory(dirPath)) {
                this.AppendLog("  [OK] Deleted empty directory: " . dirPath)
                this.AppendResult("[OK] Deleted empty directory: " . dirPath)
            }
        }
    }
    
    static SortDirectoriesByDepth(dirArray) {
        dirsWithDepth := []
        for dirPath in dirArray {
            depth := StrLen(dirPath) - StrLen(RegExReplace(dirPath, "\\", ""))
            dirsWithDepth.Push({path: dirPath, depth: depth})
        }
        sorted := []
        maxDepth := 0
        for item in dirsWithDepth {
            if (item.depth > maxDepth) {
                maxDepth := item.depth
            }
        }
        Loop maxDepth {
            currentDepth := maxDepth - A_Index + 1
            for item in dirsWithDepth {
                if (item.depth = currentDepth) {
                    sorted.Push(item.path)
                }
            }
        }
        return sorted
    }
    
    static ResolveDuplicateFilename(fileName, targetDir) {
        testPath := targetDir . "\" . fileName
        if (!FileExist(testPath)) {
            return fileName
        }
        SplitPath(fileName, , , &ext)
        baseName := SubStr(fileName, 1, StrLen(fileName) - StrLen(ext))
        version := 2
        Loop {
            newName := baseName . " (v" . version . ")" . ext
            testPath := targetDir . "\" . newName
            if (!FileExist(testPath)) {
                this.AppendLog("  [WARN] Duplicate detected, will rename to: " . newName)
                return newName
            }
            version++
            if (version > 999) {
                timestamp := ""
                FormatTime(timestamp, A_Now, "yyyyMMdd_HHmmss")
                return baseName . " (" . timestamp . ")" . ext
            }
        }
    }
    
    static DeleteEmptyDirectory(dirPath) {
        if (StrLower(dirPath) = StrLower(this.targetDir)) {
            return false
        }
        try {
            fileCount := 0
            dirCount := 0
            Loop Files dirPath . "\*" {
                fileCount++
            }
            Loop Files, dirPath . "\*", "D" {
                dirCount++
            }
            if (fileCount = 0 && dirCount = 0) {
                if (!this.dryRun) {
                    try {
                        DirDelete(dirPath)
                        this.deletedDirCount++
                        return true
                    } catch as err {
                        this.AppendLog("  [WARN] ERROR deleting directory " . dirPath . ": " . err.Message)
                        return false
                    }
                } else {
                    return true
                }
            }
        } catch as err {
            this.AppendLog("  [WARN] ERROR checking directory " . dirPath . ": " . err.Message)
            return false
        }
        return false
    }
    
    static SaveLogToFile() {
        try {
            logContent := "Video Filename Scrubber Log`n"
            logContent .= "========================`n`n"
            dateTime := ""
            FormatTime(dateTime, A_Now, "yyyy-MM-dd HH:mm:ss")
            logContent .= "Date: " . dateTime . "`n"
            logContent .= "Mode: " . (this.dryRun ? "DRY RUN" : "LIVE") . "`n"
            logContent .= "Target Directory: " . this.targetDir . "`n`n"
            logContent .= "Operations:`n"
            logContent .= this.StrRepeat("-", 60) . "`n"
            for op in this.operations {
                logContent .= op.operation . ": " . op.original . " -> " . op.new . "`n"
            }
            logContent .= "`n" . this.StrRepeat("-", 60) . "`n"
            logContent .= "Total Processed: " . this.processedCount . "`n"
            logContent .= "Renamed: " . this.renamedCount . "`n"
            logContent .= "Moved: " . this.movedCount . "`n"
            logContent .= "Directories Deleted: " . this.deletedDirCount . "`n"
            logContent .= "Errors: " . this.errorCount . "`n"
            timestamp := ""
            FormatTime(timestamp, A_Now, "yyyyMMdd_HHmmss")
            logFileName := "video_filename_scrubber_report_" . timestamp . ".txt"
            FileAppend(logContent, logFileName, "UTF-8")
            this.AppendLog("Report saved to: " . logFileName)
        } catch as err {
            this.AppendLog("ERROR saving report: " . err.Message)
        }
    }
}

; Hotkeys
Hotkey("^!v", (*) => VideoFilenameScrubber.Init())

; Initialize
VideoFilenameScrubber.Init()

; Keep script running
Loop {
    Sleep(1000)
}
