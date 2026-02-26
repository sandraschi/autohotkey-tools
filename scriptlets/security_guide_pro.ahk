; ==============================================================================
; Security Guide Pro
; @name: Security Guide Pro
; @version: 1.0.0
; @description: Comprehensive security guide for AutoHotkey scriptlets with warnings, limitations, and best practices. Educational resource about AutoHotkey security capabilities and risks.
; @description: Provides detailed information about AutoHotkey's powerful capabilities, security warnings, best practices, and safe scripting guidelines. Includes examples of secure code patterns and common vulnerabilities.
; @description: Essential security awareness tool for AutoHotkey users to understand the risks and responsibilities when writing and running automation scripts.
; @category: utilities
; @author: Sandra
; @hotkeys: ^!s, F2
; @enabled: true
; @priority: 1
; @tag: security, guide, education, safety, warnings, best-practices, utilities
; @cli: --topic <name> - Open specific security topic
; @cli: --warnings - Show all security warnings
; @cli: --best-practices - Display security best practices
; @cli: --help - Show CLI usage and security guide options
; @dependencies: 
; ==============================================================================

#Requires AutoHotkey v2.0+
#SingleInstance Force
#Include %A_ScriptDir%\lib\ScriptletErrorHandler.ahk


; Suppress error popups - log to file instead
OnError(LogError)


class SecurityGuide {
    static securityData := Map()
    static gui := ""
    static contentArea := ""
    static statusBar := ""
    
    static Init() {
        this.LoadSecurityData()
        this.CreateGUI()
    }
    
    static LoadSecurityData() {
        securityFiles := Map(
            "overview", "docs\security_topics\overview.md",
            "limitations", "docs\security_topics\limitations.md",
            "bestpractices", "docs\security_topics\bestpractices.md",
            "emergency", "docs\security_topics\emergency.md",
            "aisafety", "docs\security_topics\aisafety.md"
        )

        for id, filePath in securityFiles {
            fullPath := A_ScriptDir . "\..\" . filePath
            if (FileExist(fullPath)) {
                content := FileRead(fullPath)
                ; Extract title from first H1 tag if available, otherwise use ID
                titleMatch := RegExMatch(content, "#\s*(.*?)\n", &match)
                title := titleMatch ? Trim(match[1]) : Format("Topic: {}", id)
                
                ; Use predefined titles for better display
                if (id = "overview") {
                    title := "🚨 SECURITY WARNING - AutoHotkey Can Do ANYTHING!"
                } else if (id = "limitations") {
                    title := "AutoHotkey Limitations - What It CAN'T Do"
                } else if (id = "bestpractices") {
                    title := "Security Best Practices - Safe AutoHotkey Usage"
                } else if (id = "emergency") {
                    title := "Emergency Security Procedures - What to Do When Things Go Wrong"
                } else if (id = "aisafety") {
                    title := "AI Safety with AutoHotkey - Critical Warnings"
                }

                this.securityData[id] := {title: title, content: content}
            } else {
                this.AppendLog("Warning: Security file not found: " . fullPath, "WARN")
                this.securityData[id] := {title: Format("Error: Topic '{}' not found", id), content: "Security content for this topic could not be loaded."}
            }
        }
    }
    
    static AppendLog(message, level := "INFO") {
        timestamp := FormatTime(A_Now, "yyyy-MM-dd HH:mm:ss")
        OutputDebug(Format("[{}] [{}] {}", timestamp, level, message))
    }
    
    static CreateGUI() {
        this.gui := Gui("+Resize +MinSize1000x700", "Security Guide Pro")
        this.gui.SetFont("s9", "Segoe UI")
        
        ; Warning header at top
        warningHeader := this.gui.Add("Text", "x0 y0 w1000 h50 BackgroundRed Center cWhite", "🚨 SECURITY WARNING - AutoHotkey Can Do ANYTHING! 🚨")
        warningHeader.SetFont("s12 Bold", "Segoe UI")
        warningSubtext := this.gui.Add("Text", "x0 y30 w1000 h20 BackgroundRed Center cWhite", "Handle with EXTREME CARE - Financial, Privacy, and System Risks")
        warningSubtext.SetFont("s9", "Segoe UI")
        
        ; Left sidebar for navigation (starts below header)
        sidebarY := 50
        sidebarWidth := 220
        this.gui.Add("Text", "x10 y" . sidebarY . " w" . (sidebarWidth - 20) . " h25 Center BackgroundE0E0E0", "Topics")
        this.gui.SetFont("s10 Bold", "Segoe UI")
        
        ; Navigation buttons in sidebar
        buttonY := sidebarY + 30
        buttonWidth := sidebarWidth - 20
        buttonHeight := 35
        
        overviewBtn := this.gui.Add("Button", "x10 y" . buttonY . " w" . buttonWidth . " h" . buttonHeight, "Overview")
        buttonY += buttonHeight + 5
        limitationsBtn := this.gui.Add("Button", "x10 y" . buttonY . " w" . buttonWidth . " h" . buttonHeight, "Limitations")
        buttonY += buttonHeight + 5
        practicesBtn := this.gui.Add("Button", "x10 y" . buttonY . " w" . buttonWidth . " h" . buttonHeight, "Best Practices")
        buttonY += buttonHeight + 5
        emergencyBtn := this.gui.Add("Button", "x10 y" . buttonY . " w" . buttonWidth . " h" . buttonHeight, "Emergency")
        buttonY += buttonHeight + 5
        aiBtn := this.gui.Add("Button", "x10 y" . buttonY . " w" . buttonWidth . " h" . buttonHeight, "AI Safety")
        
        ; Bind button events
        overviewBtn.OnEvent("Click", (*) => SecurityGuide.ShowTopic("overview"))
        limitationsBtn.OnEvent("Click", (*) => SecurityGuide.ShowTopic("limitations"))
        practicesBtn.OnEvent("Click", (*) => SecurityGuide.ShowTopic("bestpractices"))
        emergencyBtn.OnEvent("Click", (*) => SecurityGuide.ShowTopic("emergency"))
        aiBtn.OnEvent("Click", (*) => SecurityGuide.ShowTopic("aisafety"))
        
        ; Content area (right side, starts below header)
        contentX := sidebarWidth + 10
        contentY := sidebarY
        contentWidth := 1000 - contentX - 10
        contentHeight := 700 - contentY - 30
        
        this.contentArea := this.gui.Add("Edit", "x" . contentX . " y" . contentY . " w" . contentWidth . " h" . contentHeight . " ReadOnly VScroll HScroll -Wrap", "")
        this.contentArea.SetFont("s11", "Consolas")
        
        ; Status bar at bottom
        this.statusBar := this.gui.Add("StatusBar", "", "Security Guide Ready - Select a topic to learn about AutoHotkey security")
        
        ; Handle window resize
        this.gui.OnEvent("Size", ObjBindMethod(SecurityGuide, "OnResize"))
        this.gui.OnEvent("Close", ObjBindMethod(SecurityGuide, "HideGUI"))
        this.gui.OnEvent("Escape", ObjBindMethod(SecurityGuide, "HideGUI"))
        
        this.gui.Show("w1000 h700 Center")
        this.ShowTopic("overview")
    }
    
    static OnResize(gui, minMax, width, height) {
        if (!SecurityGuide.contentArea || !SecurityGuide.statusBar) {
            return
        }
        sidebarWidth := 220
        headerHeight := 50
        statusBarHeight := 25
        padding := 10
        
        contentX := sidebarWidth + padding
        contentY := headerHeight
        contentWidth := width - contentX - padding
        contentHeight := height - contentY - statusBarHeight - padding
        
        SecurityGuide.contentArea.Move(contentX, contentY, contentWidth, contentHeight)
    }
    
    static HideGUI(*) {
        if (SecurityGuide.gui) {
            SecurityGuide.gui.Hide()
        }
    }
    
    static ShowTopic(topic) {
        if (!SecurityGuide.securityData.Has(topic)) {
            if (SecurityGuide.statusBar) {
                SecurityGuide.statusBar.Text := "Topic not found: " . topic
            }
            return
        }
        
        data := SecurityGuide.securityData[topic]
        if (SecurityGuide.gui) {
            SecurityGuide.gui.Title := data.title
        }
        if (SecurityGuide.contentArea) {
            SecurityGuide.contentArea.Text := data.content
        }
        if (SecurityGuide.statusBar) {
            SecurityGuide.statusBar.Text := "Showing: " . data.title
        }
    }
}

; Hotkeys
Hotkey("^!s", (*) => SecurityGuide.Init())
Hotkey("F2", (*) => SecurityGuide.Init())

; Initialize

; Register exit handler
OnExit((*) => SecurityGuide.HideGui())

SecurityGuide.Init()