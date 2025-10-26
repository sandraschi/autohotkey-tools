; ==============================================================================
; GitHub Repository Manager
; @name: GitHub Repository Manager
; @version: 1.0.0
; @description: Manage and display GitHub repositories with URLs and stats
; @category: development
; @author: Sandra
; @hotkeys: ^!g, Ctrl+Alt+R
; @enabled: true
; ==============================================================================

#Requires AutoHotkey v2.0+
#SingleInstance Force

class GitHubRepoManager {
    static gui := ""
    static username := "sandraschi"
    static repositories := []
    
    static Init() {
        this.LoadRepositories()
        this.CreateGUI()
        this.SetupHotkeys()
    }
    
    static LoadRepositories() {
        ; Known repositories from your profile
        this.repositories := [
            {name: "pywinauto-mcp", description: "MCP 2.12 Server for Windows Automation", language: "Python", stars: 3},
            {name: "database-operations-mcp", description: "Database operations MCP server", language: "Python", stars: 1},
            {name: "fastsearch-mcp", description: "âš¡ Lightning-fast file search MCP server using NTFS Master File Table", language: "JavaScript", stars: 1},
            {name: "windows-operations-mcp", description: "Windows operations MCP server", language: "Python", stars: 1},
            {name: "vboxmcp", description: "FastMCP 2.0 server for VirtualBox management through Claude Desktop", language: "Python", stars: 2},
            {name: "local-llm-mcp", description: "Local LLM MCP - A FastMCP 2.10 compliant server for local LLM management", language: "Python", stars: 0},
            {name: "autohotkey-test", description: "AutoHotkey v2 scriptlets and utilities collection", language: "AutoHotkey", stars: 0}
        ]
    }
    
    static CreateGUI() {
        this.gui := Gui("+Resize +MinSize800x600", "GitHub Repository Manager")
        this.gui.BackColor := "0x1a1a1a"
        this.gui.SetFont("s10 cWhite", "Segoe UI")
        
        ; Title
        this.gui.Add("Text", "x20 y20 w760 Center Bold", "ðŸ™ GitHub Repository Manager")
        this.gui.Add("Text", "x20 y50 w760 Center c0xcccccc", "Manage and display GitHub repositories for @" . this.username)
        
        ; Profile info
        this.gui.Add("Text", "x20 y90 w760 Bold", "ðŸ‘¤ Profile Information")
        this.gui.Add("Text", "x20 y120 w200", "Username: @" . this.username)
        this.gui.Add("Text", "x240 y120 w200", "Location: Vienna")
        this.gui.Add("Text", "x460 y120 w200", "Repositories: 34")
        this.gui.Add("Text", "x20 y150 w200", "Stars: 76")
        this.gui.Add("Text", "x240 y150 w200", "Followers: 3")
        this.gui.Add("Text", "x460 y150 w200", "Following: 6")
        
        ; Actions
        this.gui.Add("Text", "x20 y190 w760 Bold", "âš¡ Actions")
        
        refreshBtn := this.gui.Add("Button", "x20 y220 w150 h40 Background0x4a4a4a", "ðŸ”„ Refresh List")
        refreshBtn.SetFont("s10 cWhite", "Segoe UI")
        refreshBtn.OnEvent("Click", this.RefreshRepositories.Bind(this))
        
        exportBtn := this.gui.Add("Button", "x190 y220 w150 h40 Background0x4a4a4a", "ðŸ“‹ Export URLs")
        exportBtn.SetFont("s10 cWhite", "Segoe UI")
        exportBtn.OnEvent("Click", this.ExportURLs.Bind(this))
        
        openProfileBtn := this.gui.Add("Button", "x360 y220 w150 h40 Background0x4a4a4a", "ðŸŒ Open Profile")
        openProfileBtn.SetFont("s10 cWhite", "Segoe UI")
        openProfileBtn.OnEvent("Click", this.OpenProfile.Bind(this))
        
        ; Repository list
        this.gui.Add("Text", "x20 y280 w760 Bold", "ðŸ“š Repositories")
        
        repoList := this.gui.Add("ListBox", "x20 y310 w760 h250")
        repoList.SetFont("s9 cWhite", "Consolas")
        repoList.BackColor := "0x2d2d2d"
        
        ; Populate list
        this.PopulateRepositoryList()
        
        ; Repository details
        this.gui.Add("Text", "x20 y580 w760 Bold", "ðŸ“– Repository Details")
        
        detailsText := this.gui.Add("Text", "x20 y610 w760 h60 c0xcccccc", "Select a repository to view details...")
        detailsText.SetFont("s9 cWhite", "Segoe UI")
        
        ; Store references
        this.gui.repoList := repoList
        this.gui.detailsText := detailsText
        
        ; Event handlers
        repoList.OnEvent("Click", this.ShowRepositoryDetails.Bind(this))
        
        this.gui.Show("w800 h700")
    }
    
    static PopulateRepositoryList() {
        if (!this.gui.repoList) {
            return
        }
        
        this.gui.repoList.Text := ""
        
        for repo in this.repositories {
            repoText := "[" . repo.language . "] " . repo.name . " â­" . repo.stars
            this.gui.repoList.Add([repoText])
        }
    }
    
    static ShowRepositoryDetails(*) {
        try {
            selectedIndex := this.gui.repoList.Value
            if (selectedIndex > 0 && selectedIndex <= this.repositories.Length) {
                repo := this.repositories[selectedIndex]
                
                details := "ðŸ“ " . repo.name . "`n"
                details .= "ðŸ“ " . repo.description . "`n"
                details .= "ðŸ’» Language: " . repo.language . "`n"
                details .= "â­ Stars: " . repo.stars . "`n"
                details .= "ðŸ”— URL: https://github.com/" . this.username . "/" . repo.name
                
                this.gui.detailsText.Text := details
            }
        } catch as e {
            this.gui.detailsText.Text := "Error loading details: " . e.Message
        }
    }
    
    static RefreshRepositories(*) {
        try {
            this.LoadRepositories()
            this.PopulateRepositoryList()
            TrayTip("Repositories Refreshed!", "Repository list updated", 2)
        } catch as e {
            MsgBox("Error refreshing repositories: " . e.Message, "Error", "Iconx")
        }
    }
    
    static ExportURLs(*) {
        try {
            filePath := FileSelect("S16",, "Export Repository URLs", "Markdown (*.md);;Text (*.txt)")
            if (filePath) {
                content := "# GitHub Repositories - @" . this.username . "`n`n"
                content .= "**Profile:** https://github.com/" . this.username . "`n`n"
                content .= "## ðŸ“š Repository List`n`n"
                
                for repo in this.repositories {
                    content .= "### " . repo.name . "`n"
                    content .= "- **Description:** " . repo.description . "`n"
                    content .= "- **Language:** " . repo.language . "`n"
                    content .= "- **Stars:** " . repo.stars . "`n"
                    content .= "- **URL:** https://github.com/" . this.username . "/" . repo.name . "`n`n"
                }
                
                content .= "## ðŸ“Š Statistics`n`n"
                content .= "- **Total Repositories:** " . this.repositories.Length . "`n"
                content .= "- **Total Stars:** " . this.GetTotalStars() . "`n"
                content .= "- **Languages:** " . this.GetLanguages() . "`n"
                
                FileWrite(content, filePath)
                TrayTip("URLs Exported!", "Repository URLs exported to " . filePath, 2)
            }
        } catch as e {
            MsgBox("Error exporting URLs: " . e.Message, "Error", "Iconx")
        }
    }
    
    static OpenProfile(*) {
        try {
            Run("https://github.com/" . this.username)
            TrayTip("Profile Opened!", "Opening GitHub profile in browser", 2)
        } catch as e {
            MsgBox("Error opening profile: " . e.Message, "Error", "Iconx")
        }
    }
    
    static GetTotalStars() {
        total := 0
        for repo in this.repositories {
            total += repo.stars
        }
        return total
    }
    
    static GetLanguages() {
        languages := []
        for repo in this.repositories {
            if (!languages.Has(repo.language)) {
                languages.Push(repo.language)
            }
        }
        return languages.Join(", ")
    }
    
    static SetupHotkeys() {
        ; Main hotkey
        ^!Hotkey("g", (*) => this.CreateGUI()
        
        ; Refresh hotkey
        ^!r::this.RefreshRepositories()
        
        ; Close with Escape
        Escape::{
            if (Wi)nExist("GitHub Repository Manager")) {
                WinClose("GitHub Repository Manager")
            }
        }
    }
}

; Initialize
GitHubRepoManager.Init()





