; ==============================================================================
; Git Assistant Pro
; @name: Git Assistant Pro
; @version: 1.0.0
; @description: Advanced Git workflow automation with commit templates and branch management
; @category: development
; @author: Sandra
; @hotkeys: ^!g, ^!commit, ^!branch
; @enabled: true
; ==============================================================================

#Requires AutoHotkey v2.0+
#SingleInstance Force


; Suppress error popups - log to file instead
OnError(LogError)

LogError(Thrown, Mode) {
    FileAppend("Error: " . Thrown.Message . " at line " . Thrown.Line . "
", "errors.log", "UTF-8")`n        OutputDebug(errorMsg)  ; Enable LLM debugging
    return 1  ; Suppress popup (1 = suppress, 0 = show)
}


class GitAssistant {
    static commitTemplates := Map()
    static branchPatterns := Map()
    static currentRepo := ""
    
    static Init() {
        this.LoadTemplates()
        this.DetectRepository()
        this.CreateGUI()
    }
    
    static LoadTemplates() {
        ; Default commit templates
        this.commitTemplates["feat"] := "feat: add new feature"
        this.commitTemplates["fix"] := "fix: resolve issue"
        this.commitTemplates["docs"] := "docs: update documentation"
        this.commitTemplates["style"] := "style: improve code formatting"
        this.commitTemplates["refactor"] := "refactor: restructure code"
        this.commitTemplates["test"] := "test: add or update tests"
        this.commitTemplates["chore"] := "chore: update build process"
        
        ; Branch patterns
        this.branchPatterns["feature"] := "feature/"
        this.branchPatterns["bugfix"] := "bugfix/"
        this.branchPatterns["hotfix"] := "hotfix/"
        this.branchPatterns["release"] := "release/"
    }
    
    static DetectRepository() {
        try {
            ; Check if we're in a git repository
            RunWait("git rev-parse --is-inside-work-tree", , "Hide", &output)
            if (output = "true") {
                RunWait("git rev-parse --show-toplevel", , "Hide", &repoPath)
                this.currentRepo := Trim(repoPath)
            }
        } catch {
            this.currentRepo := ""
        }
    }
    
    static CreateGUI() {
        this.gui := Gui("+Resize", "Git Assistant Pro")
        
        ; Title
        this.gui.Add("Text", "w600 h30 Center", "ðŸš€ Git Assistant Pro")
        
        ; Repository info
        repoInfo := this.gui.Add("Text", "w600 h20", "Repository: " . (this.currentRepo ? this.currentRepo : "Not in a Git repository"))
        
        ; Quick actions
        quickPanel := this.gui.Add("Text", "w600 h60")
        
        statusBtn := this.gui.Add("Button", "x10 y10 w80 h25", "Status")
        addBtn := this.gui.Add("Button", "x100 y10 w80 h25", "Add All")
        commitBtn := this.gui.Add("Button", "x190 y10 w80 h25", "Commit")
        pushBtn := this.gui.Add("Button", "x280 y10 w80 h25", "Push")
        pullBtn := this.gui.Add("Button", "x370 y10 w80 h25", "Pull")
        logBtn := this.gui.Add("Button", "x460 y10 w80 h25", "Log")
        
        statusBtn.OnEvent("Click", this.GitStatus.Bind(this))
        addBtn.OnEvent("Click", this.GitAddAll.Bind(this))
        commitBtn.OnEvent("Click", this.GitCommit.Bind(this))
        pushBtn.OnEvent("Click", this.GitPush.Bind(this))
        pullBtn.OnEvent("Click", this.GitPull.Bind(this))
        logBtn.OnEvent("Click", this.GitLog.Bind(this))
        
        ; Commit section
        commitPanel := this.gui.Add("Text", "w600 h120")
        
        this.gui.Add("Text", "x10 y10 w100 h20", "Commit Type:")
        this.commitType := this.gui.Add("DropDownList", "x120 y8 w150", Array.from(this.commitTemplates.Keys))
        this.commitType.Text := "feat"
        
        this.gui.Add("Text", "x10 y40 w100 h20", "Commit Message:")
        this.commitMessage := this.gui.Add("Edit", "x120 y38 w450 h25", "")
        
        this.gui.Add("Text", "x10 y70 w100 h20", "Description:")
        this.commitDesc := this.gui.Add("Edit", "x120 y68 w450 h40 VScroll", "")
        
        ; Branch management
        branchPanel := this.gui.Add("Text", "w600 h120")
        
        this.gui.Add("Text", "x10 y10 w100 h20", "Branch Type:")
        this.branchType := this.gui.Add("DropDownList", "x120 y8 w150", Array.from(this.branchPatterns.Keys))
        this.branchType.Text := "feature"
        
        this.gui.Add("Text", "x10 y40 w100 h20", "Branch Name:")
        this.branchName := this.gui.Add("Edit", "x120 y38 w300 h25", "")
        
        createBranchBtn := this.gui.Add("Button", "x430 y38 w80 h25", "Create")
        switchBranchBtn := this.gui.Add("Button", "x520 y38 w60 h25", "Switch")
        
        createBranchBtn.OnEvent("Click", this.CreateBranch.Bind(this))
        switchBranchBtn.OnEvent("Click", this.SwitchBranch.Bind(this))
        
        this.gui.Add("Text", "x10 y70 w100 h20", "Current Branch:")
        this.currentBranch := this.gui.Add("Text", "x120 y70 w200 h20", "")
        
        ; Output area
        this.gui.Add("Text", "w600 h20", "Git Output:")
        this.outputArea := this.gui.Add("Edit", "w600 h200 VScroll HScroll ReadOnly", "")
        
        ; Action buttons
        actionPanel := this.gui.Add("Text", "w600 h40")
        
        clearBtn := this.gui.Add("Button", "x10 y10 w80 h25", "Clear")
        copyBtn := this.gui.Add("Button", "x100 y10 w80 h25", "Copy Output")
        refreshBtn := this.gui.Add("Button", "x190 y10 w80 h25", "Refresh")
        settingsBtn := this.gui.Add("Button", "x280 y10 w80 h25", "Settings")
        
        clearBtn.OnEvent("Click", this.ClearOutput.Bind(this))
        copyBtn.OnEvent("Click", this.CopyOutput.Bind(this))
        refreshBtn.OnEvent("Click", this.RefreshInfo.Bind(this))
        settingsBtn.OnEvent("Click", this.ShowSettings.Bind(this))
        
        this.gui.Show("w620 h500")
        this.RefreshInfo()
    }
    
    static GitStatus(*) {
        this.RunGitCommand("status")
    }
    
    static GitAddAll(*) {
        this.RunGitCommand("add .")
    }
    
    static GitCommit(*) {
        type := this.commitType.Text
        message := this.commitMessage.Text
        desc := this.commitDesc.Text
        
        if (!message) {
            message := this.commitTemplates[type]
        }
        
        if (desc) {
            message .= "`n`n" . desc
        }
        
        this.RunGitCommand("commit -m """ . message . """")
    }
    
    static GitPush(*) {
        this.RunGitCommand("push")
    }
    
    static GitPull(*) {
        this.RunGitCommand("pull")
    }
    
    static GitLog(*) {
        this.RunGitCommand("log --oneline -10")
    }
    
    static CreateBranch(*) {
        type := this.branchType.Text
        name := this.branchName.Text
        
        if (!name) {
            this.AppendOutput("Error: Branch name is required")
            return
        }
        
        branchName := this.branchPatterns[type] . name
        this.RunGitCommand("checkout -b " . branchName)
    }
    
    static SwitchBranch(*) {
        name := this.branchName.Text
        
        if (!name) {
            this.AppendOutput("Error: Branch name is required")
            return
        }
        
        this.RunGitCommand("checkout " . name)
    }
    
    static RunGitCommand(command) {
        if (!this.currentRepo) {
            this.AppendOutput("Error: Not in a Git repository")
            return
        }
        
        try {
            this.AppendOutput("Running: git " . command)
            
            ; Change to repository directory
            originalDir := A_WorkingDir
            SetWorkingDir(this.currentRepo)
            
            ; Run git command
            RunWait("git " . command, , "Hide", &output)
            
            ; Restore original directory
            SetWorkingDir(originalDir)
            
            this.AppendOutput(output)
            this.RefreshInfo()
            
        } catch as e {
            this.AppendOutput("Error: " . e.Message)
        }
    }
    
    static RefreshInfo(*) {
        if (!this.currentRepo) return
        
        try {
            ; Get current branch
            RunWait("git branch --show-current", , "Hide", &branch)
            this.currentBranch.Text := Trim(branch)
            
            ; Get repository status
            RunWait("git status --porcelain", , "Hide", &status)
            if (status) {
                this.AppendOutput("Repository has uncommitted changes")
            } else {
                this.AppendOutput("Repository is clean")
            }
            
        } catch {
            this.AppendOutput("Error refreshing repository info")
        }
    }
    
    static AppendOutput(text) {
        timestamp := FormatTime(, "HH:mm:ss")
        this.outputArea.Text .= "[" . timestamp . "] " . text . "`n"
        
        ; Auto-scroll to bottom
        this.outputArea.Focus()
        Send("^{End}")
    }
    
    static ClearOutput(*) {
        this.outputArea.Text := ""
    }
    
    static CopyOutput(*) {
        Clipboard := this.outputArea.Text
        ToolTip("Output copied to clipboard!")
        SetTimer(() => ToolTip(), -2000)
    }
    
    static ShowSettings(*) {
        settingsGui := Gui("+Resize", "Git Assistant Settings")
        
        settingsGui.Add("Text", "w400 h20", "Commit Templates:")
        
        ; Template editor
        templateList := settingsGui.Add("ListView", "w400 h200", ["Type", "Template"])
        
        for type, template in this.commitTemplates {
            templateList.Add("", type, template)
        }
        
        ; Add new template
        settingsGui.Add("Text", "x10 y220 w80 h20", "New Type:")
        newType := settingsGui.Add("Edit", "x100 y218 w100 h25", "")
        
        settingsGui.Add("Text", "x210 y220 w80 h20", "Template:")
        newTemplate := settingsGui.Add("Edit", "x300 y218 w100 h25", "")
        
        addBtn := settingsGui.Add("Button", "x10 y250 w80 h25", "Add")
        removeBtn := settingsGui.Add("Button", "x100 y250 w80 h25", "Remove")
        saveBtn := settingsGui.Add("Button", "x190 y250 w80 h25", "Save")
        
        addBtn.OnEvent("Click", (*) => {
            type := newType.Text
            template := newTemplate.Text
            if (type && template) {
                this.commitTemplates[type] := template
                templateList.Add("", type, template)
                newType.Text := ""
                newTemplate.Text := ""
            }
        })
        
        saveBtn.OnEvent("Click", (*) => {
            settingsGui.Close()
        })
        
        settingsGui.Show("w420 h300")
    }
}

; Hotkeys
Hotkey("^!g", (*) => GitAssistant.Init()
Hotkey("^!commit", (*) => GitAssistant.GitCommit()
Hotkey("^!branch", (*) => GitAssistant.CreateBranch()

; Initialize
GitAssistant.Init()


