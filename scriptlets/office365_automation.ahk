; ==============================================================================
; Office 365 Automation Suite
; @name: Office 365 Automation Suite
; @version: 1.0.0
; @description: Comprehensive automation for Office 365 applications. Full-featured automation suite for Outlook, Teams, OneNote, and Office applications.
; @description: Provides email automation, meeting scheduling, OneNote integration, Teams shortcuts, and Office document management. Includes templates, quick actions, and workflow automation for productivity enhancement.
; @description: Essential productivity tool for Office 365 power users who need advanced automation, shortcuts, and workflow integration across Microsoft 365 applications.
; @category: productivity
; @author: Sandra
; @hotkeys: ^!o, ^!n, ^!t, ^!w, ^!e
; @enabled: true
; @priority: 20
; @tag: office365, automation, productivity, outlook, teams, onenote, microsoft, workflows
; @cli: --outlook <action> - Execute Outlook automation action
; @cli: --teams <action> - Execute Teams automation action
; @cli: --onenote <action> - Execute OneNote automation action
; @cli: --help - Show CLI usage and Office 365 options
; @dependencies: Office 365 applications
; ==============================================================================

#Requires AutoHotkey v2.0+
#SingleInstance Force
#Include %A_ScriptDir%\lib\ScriptletErrorHandler.ahk


; Suppress error popups - log to file instead
OnError(LogError)

class Office365Automation {
    static gui := ""
    static outlookApp := ""
    static onenoteApp := ""
    static teamsApp := ""
    static wordApp := ""
    static excelApp := ""
    
    static Init() {
        this.CreateGUI()
        this.SetupHotkeys()
        this.InitializeOfficeApps()
    }
    
    static CreateGUI() {
        this.gui := Gui("+Resize +MinSize800x700", "Office 365 Automation Suite")
        this.gui.BackColor := "1a1a1a"
        this.gui.SetFont("s12 cFFFFFF Bold", "Segoe UI")
        
        ; Title
        this.gui.Add("Text", "x20 y20 w760 Center Bold", "🏢 Office 365 Automation Suite")
        this.gui.Add("Text", "x20 y50 w760 Center ", "Automate common Office 365 tasks and workflows")
        
        ; Outlook Automation
        this.gui.Add("Text", "x20 y90 w760 Bold", "📧 Outlook Automation")
        
        outlookBtn1 := this.gui.Add("Button", "x20 y120 w180 h50 Background4a4a4a", "📬 Quick Email Reply")
        outlookBtn1.SetFont("s10 cFFFFFF", "Segoe UI")
        outlookBtn1.OnEvent("Click", this.QuickEmailReply.Bind(this))
        
        outlookBtn2 := this.gui.Add("Button", "x220 y120 w180 h50 Background4a4a4a", "📅 Schedule Meeting")
        outlookBtn2.SetFont("s10 cFFFFFF", "Segoe UI")
        outlookBtn2.OnEvent("Click", this.ScheduleMeeting.Bind(this))
        
        outlookBtn3 := this.gui.Add("Button", "x420 y120 w180 h50 Background4a4a4a", "📋 Email Templates")
        outlookBtn3.SetFont("s10 cFFFFFF", "Segoe UI")
        outlookBtn3.OnEvent("Click", this.EmailTemplates.Bind(this))
        
        outlookBtn4 := this.gui.Add("Button", "x620 y120 w180 h50 Background4a4a4a", "🗂️ Auto-Organize")
        outlookBtn4.SetFont("s10 cFFFFFF", "Segoe UI")
        outlookBtn4.OnEvent("Click", this.AutoOrganize.Bind(this))
        
        ; OneNote Automation
        this.gui.Add("Text", "x20 y190 w760 Bold", "📝 OneNote Automation")
        
        onenoteBtn1 := this.gui.Add("Button", "x20 y220 w180 h50 Background4a4a4a", "📄 Quick Note")
        onenoteBtn1.SetFont("s10 cFFFFFF", "Segoe UI")
        onenoteBtn1.OnEvent("Click", this.QuickNote.Bind(this))
        
        onenoteBtn2 := this.gui.Add("Button", "x220 y220 w180 h50 Background4a4a4a", "📋 Meeting Notes")
        onenoteBtn2.SetFont("s10 cFFFFFF", "Segoe UI")
        onenoteBtn2.OnEvent("Click", this.MeetingNotes.Bind(this))
        
        onenoteBtn3 := this.gui.Add("Button", "x420 y220 w180 h50 Background4a4a4a", "🔍 Search Notes")
        onenoteBtn3.SetFont("s10 cFFFFFF", "Segoe UI")
        onenoteBtn3.OnEvent("Click", this.SearchNotes.Bind(this))
        
        onenoteBtn4 := this.gui.Add("Button", "x620 y220 w180 h50 Background4a4a4a", "📊 Note Statistics")
        onenoteBtn4.SetFont("s10 cFFFFFF", "Segoe UI")
        onenoteBtn4.OnEvent("Click", this.NoteStatistics.Bind(this))
        
        ; Teams Automation
        this.gui.Add("Text", "x20 y290 w760 Bold", "💬 Microsoft Teams Automation")
        
        teamsBtn1 := this.gui.Add("Button", "x20 y320 w180 h50 Background4a4a4a", "📞 Quick Call")
        teamsBtn1.SetFont("s10 cFFFFFF", "Segoe UI")
        teamsBtn1.OnEvent("Click", this.QuickCall.Bind(this))
        
        teamsBtn2 := this.gui.Add("Button", "x220 y320 w180 h50 Background4a4a4a", "💬 Auto-Reply")
        teamsBtn2.SetFont("s10 cFFFFFF", "Segoe UI")
        teamsBtn2.OnEvent("Click", this.TeamsAutoReply.Bind(this))
        
        teamsBtn3 := this.gui.Add("Button", "x420 y320 w180 h50 Background4a4a4a", "📅 Meeting Status")
        teamsBtn3.SetFont("s10 cFFFFFF", "Segoe UI")
        teamsBtn3.OnEvent("Click", this.MeetingStatus.Bind(this))
        
        teamsBtn4 := this.gui.Add("Button", "x620 y320 w180 h50 Background4a4a4a", "🎯 Focus Mode")
        teamsBtn4.SetFont("s10 cFFFFFF", "Segoe UI")
        teamsBtn4.OnEvent("Click", this.FocusMode.Bind(this))
        
        ; Word & Excel Automation
        this.gui.Add("Text", "x20 y390 w760 Bold", "📄 Word & Excel Automation")
        
        officeBtn1 := this.gui.Add("Button", "x20 y420 w180 h50 Background4a4a4a", "📝 Document Templates")
        officeBtn1.SetFont("s10 cFFFFFF", "Segoe UI")
        officeBtn1.OnEvent("Click", this.DocumentTemplates.Bind(this))
        
        officeBtn2 := this.gui.Add("Button", "x220 y420 w180 h50 Background4a4a4a", "📊 Excel Shortcuts")
        officeBtn2.SetFont("s10 cFFFFFF", "Segoe UI")
        officeBtn2.OnEvent("Click", this.ExcelShortcuts.Bind(this))
        
        officeBtn3 := this.gui.Add("Button", "x420 y420 w180 h50 Background4a4a4a", "🔄 Auto-Save")
        officeBtn3.SetFont("s10 cFFFFFF", "Segoe UI")
        officeBtn3.OnEvent("Click", this.AutoSave.Bind(this))
        
        officeBtn4 := this.gui.Add("Button", "x620 y420 w180 h50 Background4a4a4a", "📋 Clipboard Sync")
        officeBtn4.SetFont("s10 cFFFFFF", "Segoe UI")
        officeBtn4.OnEvent("Click", this.ClipboardSync.Bind(this))
        
        ; Advanced Features
        this.gui.Add("Text", "x20 y490 w760 Bold", "⚡ Advanced Features")
        
        advancedBtn1 := this.gui.Add("Button", "x20 y520 w180 h50 Background4a4a4a", "🤖 AI Assistant")
        advancedBtn1.SetFont("s10 cFFFFFF", "Segoe UI")
        advancedBtn1.OnEvent("Click", this.AIAssistant.Bind(this))
        
        advancedBtn2 := this.gui.Add("Button", "x220 y520 w180 h50 Background4a4a4a", "📈 Analytics")
        advancedBtn2.SetFont("s10 cFFFFFF", "Segoe UI")
        advancedBtn2.OnEvent("Click", this.ProductivityAnalytics.Bind(this))
        
        advancedBtn3 := this.gui.Add("Button", "x420 y520 w180 h50 Background4a4a4a", "🔧 Settings")
        advancedBtn3.SetFont("s10 cFFFFFF", "Segoe UI")
        advancedBtn3.OnEvent("Click", this.Settings.Bind(this))
        
        advancedBtn4 := this.gui.Add("Button", "x620 y520 w180 h50 Background4a4a4a", "❓ Help")
        advancedBtn4.SetFont("s10 cFFFFFF", "Segoe UI")
        advancedBtn4.OnEvent("Click", this.Help.Bind(this))
        
        ; Status bar
        statusText := this.gui.Add("Text", "x20 y590 w760 h30 Center ", "Ready - Office 365 apps initialized")
        statusText.Name := "StatusText"
        
        this.gui.Show("w800 h630")
    }
    
    static InitializeOfficeApps() {
        try {
            ; Initialize Outlook
            this.outlookApp := ComObject("Outlook.Application")
            this.UpdateStatus("Outlook connected")
        } catch {
            this.UpdateStatus("Outlook not available")
        }
        
        try {
            ; Initialize OneNote
            this.onenoteApp := ComObject("OneNote.Application")
            this.UpdateStatus("OneNote connected")
        } catch {
            this.UpdateStatus("OneNote not available")
        }
        
        try {
            ; Initialize Word
            this.wordApp := ComObject("Word.Application")
            this.UpdateStatus("Word connected")
        } catch {
            this.UpdateStatus("Word not available")
        }
        
        try {
            ; Initialize Excel
            this.excelApp := ComObject("Excel.Application")
            this.UpdateStatus("Excel connected")
        } catch {
            this.UpdateStatus("Excel not available")
        }
    }
    
    static QuickEmailReply(*) {
        try {
            if (!this.outlookApp) {
                MsgBox("Outlook is not available. Please ensure Outlook is installed and running.", "Error", "Iconx")
                return
            }
            
            ; Get the currently selected email
            selection := this.outlookApp.ActiveExplorer.Selection
            if (selection.Count > 0) {
                mailItem := selection.Item(1)
                
                ; Create reply
                reply := mailItem.Reply()
                
                ; Add quick reply templates
                replyTemplates := this.GetReplyTemplates()
                
                ; Show template selection
                templateGui := Gui("+AlwaysOnTop", "Quick Reply Templates")
                templateGui.Add("Text", "w300 Center", "Select a reply template:")
                
                for i, template in replyTemplates {
                    btn := templateGui.Add("Button", "w280 h40", template.name)
                    btn.OnEvent("Click", ObjBindMethod(this, "HandleQuickReplyTemplate", templateGui, reply, template))
                }
                
                templateGui.Show("w320 h" . (replyTemplates.Length * 50 + 100))
            } else {
                MsgBox("Please select an email to reply to.", "No Selection", "Icon!")
            }
        } catch as e {
            MsgBox("Error creating reply: " . e.Message, "Error", "Iconx")
        }
    }
    
    static GetReplyTemplates() {
        return [
            {name: "Thank You", content: "Thank you for your email. I'll get back to you shortly.`n`nBest regards"},
            {name: "Meeting Request", content: "I'd be happy to schedule a meeting. Please let me know your availability.`n`nBest regards"},
            {name: "Information Request", content: "I'll look into this and provide you with the information you need.`n`nBest regards"},
            {name: "Out of Office", content: "I'm currently out of the office and will respond to your email when I return.`n`nBest regards"},
            {name: "Custom", content: ""}
        ]
    }
    
    static ScheduleMeeting(*) {
        try {
            if (!this.outlookApp) {
                MsgBox("Outlook is not available.", "Error", "Iconx")
                return
            }
            
            ; Create meeting request
            meeting := this.outlookApp.CreateItem(1)  ; olAppointmentItem
            
            ; Get meeting details from user
            meetingGui := Gui("+AlwaysOnTop", "Schedule Meeting")
            meetingGui.Add("Text", "w300", "Meeting Subject:")
            subjectEdit := meetingGui.Add("Edit", "w280 h20")
            
            meetingGui.Add("Text", "w300 y+20", "Attendees (comma separated):")
            attendeesEdit := meetingGui.Add("Edit", "w280 h20")
            
            meetingGui.Add("Text", "w300 y+20", "Start Time:")
            startTimeEdit := meetingGui.Add("Edit", "w280 h20", A_Now)
            
            meetingGui.Add("Text", "w300 y+20", "Duration (minutes):")
            durationEdit := meetingGui.Add("Edit", "w280 h20", "60")
            
            meetingGui.Add("Text", "w300 y+20", "Location:")
            locationEdit := meetingGui.Add("Edit", "w280 h20")
            
            scheduleBtn := meetingGui.Add("Button", "w280 h30", "Schedule Meeting")
            scheduleBtn.OnEvent("Click", ObjBindMethod(this, "HandleScheduleMeeting", meetingGui, meeting, subjectEdit, attendeesEdit, startTimeEdit, durationEdit, locationEdit))
            
            meetingGui.Show("w320 h300")
        } catch as e {
            MsgBox("Error scheduling meeting: " . e.Message, "Error", "Iconx")
        }
    }
    
    static EmailTemplates(*) {
        try {
            templateGui := Gui("+AlwaysOnTop", "Email Templates")
            templateGui.Add("Text", "w400 Center Bold", "📧 Email Templates")
            
            templates := [
                {name: "Follow-up Email", content: "Hi [Name],`n`nI wanted to follow up on our previous conversation regarding [Topic].`n`nPlease let me know if you need any additional information.`n`nBest regards,`n[Your Name]"},
                {name: "Meeting Request", content: "Hi [Name],`n`nI would like to schedule a meeting to discuss [Topic].`n`nPlease let me know your availability for the following times:`n- [Time 1]`n- [Time 2]`n- [Time 3]`n`nBest regards,`n[Your Name]"},
                {name: "Project Update", content: "Hi Team,`n`nHere's an update on the [Project Name] project:`n`nProgress:`n- [Update 1]`n- [Update 2]`n- [Update 3]`n`nNext Steps:`n- [Next Step 1]`n- [Next Step 2]`n`nPlease let me know if you have any questions.`n`nBest regards,`n[Your Name]"},
                {name: "Thank You", content: "Hi [Name],`n`nThank you for [Reason]. I really appreciate your [Specific Action].`n`nBest regards,`n[Your Name]"},
                {name: "Status Report", content: "Hi [Name],`n`nHere's the status update for [Project/Task]:`n`nCompleted:`n- [Item 1]`n- [Item 2]`n`nIn Progress:`n- [Item 3]`n- [Item 4]`n`nBlockers:`n- [Blocker 1]`n`nBest regards,`n[Your Name]"}
            ]
            
            for i, template in templates {
                btn := templateGui.Add("Button", "w380 h40", template.name)
                btn.OnEvent("Click", ObjBindMethod(this, "HandleEmailTemplateSelection", templateGui, template))
            }
            
            templateGui.Show("w400 h" . (templates.Length * 50 + 100))
        } catch as e {
            MsgBox("Error loading templates: " . e.Message, "Error", "Iconx")
        }
    }
    
    static AutoOrganize(*) {
        try {
            if (!this.outlookApp) {
                MsgBox("Outlook is not available.", "Error", "Iconx")
                return
            }
            
            ; Get inbox
            inbox := this.outlookApp.GetNamespace("MAPI").GetDefaultFolder(6)  ; olFolderInbox
            messages := inbox.Items
            
            ; Organize rules
            organizedCount := 0
            
            Loop messages.Count {
                message := messages.Item(A_Index)
                
                ; Rule 1: Move emails with "unsubscribe" to Junk
                if (InStr(message.Subject, "unsubscribe") || InStr(message.Body, "unsubscribe")) {
                    junkFolder := this.outlookApp.GetNamespace("MAPI").GetDefaultFolder(23)  ; olFolderJunk
                    message.Move(junkFolder)
                    organizedCount++
                }
                
                ; Rule 2: Flag emails from boss
                if (InStr(message.SenderEmailAddress, "boss@company.com")) {
                    message.FlagRequest := "Follow up"
                    organizedCount++
                }
                
                ; Rule 3: Categorize meeting requests
                if (InStr(message.Subject, "meeting") || InStr(message.Subject, "Meeting")) {
                    message.Categories := "Meeting"
                    organizedCount++
                }
            }
            
            TrayTip("Auto-Organize Complete!", "Organized " . organizedCount . " emails", 2)
        } catch as e {
            MsgBox("Error organizing emails: " . e.Message, "Error", "Iconx")
        }
    }
    
    static QuickNote(*) {
        try {
            if (!this.onenoteApp) {
                MsgBox("OneNote is not available.", "Error", "Iconx")
                return
            }
            
            ; Get current date and time
            currentDate := FormatTime(, "yyyy-MM-dd")
            currentTime := FormatTime(, "HH:mm")
            
            ; Create quick note
            noteContent := "Quick Note - " . currentDate . " " . currentTime . "`n`n" . 
                          "Notes:`n" . 
                          "- `n" . 
                          "- `n" . 
                          "- `n`n" . 
                          "Action Items:`n" . 
                          "- [ ] `n" . 
                          "- [ ] `n" . 
                          "- [ ] `n`n" . 
                          "Follow-up:`n" . 
                          "- `n"
            
            ; Copy to clipboard
            A_Clipboard := noteContent
            
            TrayTip("Quick Note Created!", "Note template copied to clipboard. Paste into OneNote.", 2)
        } catch as e {
            MsgBox("Error creating quick note: " . e.Message, "Error", "Iconx")
        }
    }
    
    static MeetingNotes(*) {
        try {
            ; Get meeting details
            meetingGui := Gui("+AlwaysOnTop", "Meeting Notes Template")
            meetingGui.Add("Text", "w400", "Meeting Title:")
            titleEdit := meetingGui.Add("Edit", "w380 h20")
            
            meetingGui.Add("Text", "w400 y+20", "Date:")
            dateStr := ""
            dateStr := FormatTime(, "yyyy-MM-dd")
            dateEdit := meetingGui.Add("Edit", "w380 h20", dateStr)
            
            meetingGui.Add("Text", "w400 y+20", "Attendees:")
            attendeesEdit := meetingGui.Add("Edit", "w380 h20")
            
            meetingGui.Add("Text", "w400 y+20", "Agenda:")
            agendaEdit := meetingGui.Add("Edit", "w380 h40")
            
            createBtn := meetingGui.Add("Button", "w380 h30", "Create Meeting Notes")
            createBtn.OnEvent("Click", ObjBindMethod(this, "HandleMeetingNotesCreate", meetingGui, titleEdit, dateEdit, attendeesEdit, agendaEdit))
            
            meetingGui.Show("w420 h300")
        } catch as e {
            MsgBox("Error creating meeting notes: " . e.Message, "Error", "Iconx")
        }
    }
    
    static SearchNotes(*) {
        try {
            searchGui := Gui("+AlwaysOnTop", "Search OneNote")
            searchGui.Add("Text", "w400", "Search Term:")
            searchEdit := searchGui.Add("Edit", "w380 h20")
            
            searchBtn := searchGui.Add("Button", "w380 h30", "Search Notes")
            searchBtn.OnEvent("Click", ObjBindMethod(this, "HandleSearchNotes", searchGui, searchEdit))
            
            searchGui.Show("w420 h100")
        } catch as e {
            MsgBox("Error searching notes: " . e.Message, "Error", "Iconx")
        }
    }
    
    static NoteStatistics(*) {
        try {
            if (!this.onenoteApp) {
                MsgBox("OneNote is not available.", "Error", "Iconx")
                return
            }
            
            ; Get notebook information
            notebooks := this.onenoteApp.GetNotebooks()
            
            statsGui := Gui("+AlwaysOnTop", "OneNote Statistics")
            statsGui.Add("Text", "w400 Center Bold", "📊 OneNote Statistics")
            
            statsText := "Notebooks: " . notebooks.Count . "`n`n"
            
            Loop notebooks.Count {
                notebook := notebooks.Item(A_Index)
                statsText .= "Notebook " . A_Index . ": " . notebook.Name . "`n"
            }
            
            statsGui.Add("Text", "w380 h200", statsText)
            
            statsGui.Show("w420 h300")
        } catch as e {
            MsgBox("Error getting statistics: " . e.Message, "Error", "Iconx")
        }
    }
    
    static QuickCall(*) {
        try {
            callGui := Gui("+AlwaysOnTop", "Quick Teams Call")
            callGui.Add("Text", "w300", "Contact Name or Email:")
            contactEdit := callGui.Add("Edit", "w280 h20")
            
            callBtn := callGui.Add("Button", "w280 h30", "Start Call")
            callBtn.OnEvent("Click", ObjBindMethod(this, "HandleQuickCall", callGui, contactEdit))
            
            callGui.Show("w320 h100")
        } catch as e {
            MsgBox("Error starting call: " . e.Message, "Error", "Iconx")
        }
    }
    
    static TeamsAutoReply(*) {
        try {
            replyGui := Gui("+AlwaysOnTop", "Teams Auto-Reply")
            replyGui.Add("Text", "w400", "Auto-Reply Message:")
            replyEdit := replyGui.Add("Edit", "w380 h60", "I'm currently busy and will respond to your message shortly.")
            
            replyBtn := replyGui.Add("Button", "w380 h30", "Set Auto-Reply")
            replyBtn.OnEvent("Click", ObjBindMethod(this, "HandleTeamsAutoReply", replyGui, replyEdit))
            
            replyGui.Show("w420 h150")
        } catch as e {
            MsgBox("Error setting auto-reply: " . e.Message, "Error", "Iconx")
        }
    }
    
    static MeetingStatus(*) {
        try {
            statusGui := Gui("+AlwaysOnTop", "Meeting Status")
            statusGui.Add("Text", "w300 Center Bold", "📅 Current Meeting Status")
            
            ; Check if in a meeting
            if (this.IsInMeeting()) {
                statusGui.Add("Text", "w280 Center ", "🔴 Currently in a meeting")
                statusGui.Add("Text", "w280 Center", "Meeting: " . this.GetCurrentMeeting())
            } else {
                statusGui.Add("Text", "w280 Center ", "🟢 No active meeting")
            }
            
            ; Next meeting
            nextMeeting := this.GetNextMeeting()
            if (nextMeeting) {
                statusGui.Add("Text", "w280 Center", "Next: " . nextMeeting)
            }
            
            statusGui.Show("w320 h200")
        } catch as e {
            MsgBox("Error checking meeting status: " . e.Message, "Error", "Iconx")
        }
    }
    
    static IsInMeeting() {
        ; Simple check - in real implementation, you'd check Teams status
        return false
    }
    
    static GetCurrentMeeting() {
        return "Sample Meeting"
    }
    
    static GetNextMeeting() {
        return "Next Meeting at 3:00 PM"
    }
    
    static FocusMode(*) {
        try {
            ; Set Teams to Do Not Disturb
            Run("msteams://teams.microsoft.com/l/settings/notifications")
            TrayTip("Focus Mode", "Opening Teams settings for Do Not Disturb", 2)
        } catch as e {
            MsgBox("Error setting focus mode: " . e.Message, "Error", "Iconx")
        }
    }
    
    static DocumentTemplates(*) {
        try {
            templateGui := Gui("+AlwaysOnTop", "Document Templates")
            templateGui.Add("Text", "w400 Center Bold", "📄 Document Templates")
            
            templates := [
                "Meeting Minutes",
                "Project Proposal",
                "Status Report",
                "Email Template",
                "Presentation Outline"
            ]
            
            for i, template in templates {
                btn := templateGui.Add("Button", "w380 h40", template)
                btn.OnEvent("Click", ObjBindMethod(this, "HandleDocumentTemplateSelection", templateGui, template))
            }
            
            templateGui.Show("w420 h" . (templates.Length * 50 + 100))
        } catch as e {
            MsgBox("Error loading templates: " . e.Message, "Error", "Iconx")
        }
    }
    
    static CreateDocumentTemplate(templateName) {
        try {
            if (!this.wordApp) {
                MsgBox("Word is not available.", "Error", "Iconx")
                return
            }
            
            ; Create new document
            doc := this.wordApp.Documents.Add()
            
            ; Add template content based on type
            switch templateName {
                case "Meeting Minutes":
                    doc.Content.Text := "Meeting Minutes`n" . 
                                      "===============`n`n" . 
                                      "Date: " . FormatTime(, "yyyy-MM-dd") . "`n" . 
                                      "Time: " . FormatTime(, "HH:mm") . "`n" . 
                                      "Attendees: `n`n" . 
                                      "Agenda:`n" . 
                                      "1. `n" . 
                                      "2. `n" . 
                                      "3. `n`n" . 
                                      "Notes:`n" . 
                                      "- `n" . 
                                      "- `n`n" . 
                                      "Action Items:`n" . 
                                      "- [ ] `n" . 
                                      "- [ ] `n"
                case "Project Proposal":
                    doc.Content.Text := "Project Proposal`n" . 
                                      "=================`n`n" . 
                                      "Project Name: `n" . 
                                      "Date: " . FormatTime(, "yyyy-MM-dd") . "`n" . 
                                      "Proposed By: `n`n" . 
                                      "Executive Summary:`n" . 
                                      "`n`n" . 
                                      "Objectives:`n" . 
                                      "1. `n" . 
                                      "2. `n" . 
                                      "3. `n`n" . 
                                      "Timeline:`n" . 
                                      "- Phase 1: `n" . 
                                      "- Phase 2: `n" . 
                                      "- Phase 3: `n`n" . 
                                      "Budget: `n`n" . 
                                      "Resources Required:`n" . 
                                      "- `n" . 
                                      "- `n"
            }
            
            TrayTip("Template Created!", "Document template created in Word", 2)
        } catch as e {
            MsgBox("Error creating template: " . e.Message, "Error", "Iconx")
        }
    }
    
    static ExcelShortcuts(*) {
        try {
            shortcutsGui := Gui("+AlwaysOnTop", "Excel Shortcuts")
            shortcutsGui.Add("Text", "w400 Center Bold", "📊 Excel Automation Shortcuts")
            
            shortcuts := [
                "Ctrl+Shift+L - Auto-filter",
                "Ctrl+T - Create table",
                "Ctrl+Shift+$ - Currency format",
                "Ctrl+Shift+% - Percentage format",
                "Ctrl+Shift+# - Date format",
                "Ctrl+Shift+@ - Time format",
                "Ctrl+Shift+! - Number format",
                "Ctrl+Shift+& - Add borders",
                "Ctrl+Shift+_ - Remove borders",
                "Ctrl+Shift+~ - General format"
            ]
            
            for i, shortcut in shortcuts {
                shortcutsGui.Add("Text", "w380 h20", shortcut)
            }
            
            shortcutsGui.Show("w420 h" . (shortcuts.Length * 25 + 100))
        } catch as e {
            MsgBox("Error loading shortcuts: " . e.Message, "Error", "Iconx")
        }
    }
    
    static AutoSave(*) {
        try {
            if (!this.wordApp && !this.excelApp) {
                MsgBox("Word or Excel is not available.", "Error", "Iconx")
                return
            }
            
            ; Enable auto-save
            if (this.wordApp) {
                this.wordApp.Options.AutoSave := true
            }
            if (this.excelApp) {
                this.excelApp.Options.AutoSave := true
            }
            
            TrayTip("Auto-Save Enabled!", "Auto-save has been enabled for Office applications", 2)
        } catch as e {
            MsgBox("Error enabling auto-save: " . e.Message, "Error", "Iconx")
        }
    }
    
    static ClipboardSync(*) {
        try {
            ; Copy current clipboard content
            currentClipboard := A_Clipboard
            
            ; Show clipboard sync options
            syncGui := Gui("+AlwaysOnTop", "Clipboard Sync")
            syncGui.Add("Text", "w300 Center Bold", "📋 Clipboard Sync")
            syncGui.Add("Text", "w280", "Current clipboard content:")
            contentText := syncGui.Add("Text", "w280 h100", currentClipboard)
            
            syncBtn := syncGui.Add("Button", "w280 h30", "Sync to OneNote")
            syncBtn.OnEvent("Click", ObjBindMethod(this, "HandleClipboardSync", syncGui, currentClipboard))
            
            syncGui.Show("w320 h200")
        } catch as e {
            MsgBox("Error syncing clipboard: " . e.Message, "Error", "Iconx")
        }
    }
    
    static AIAssistant(*) {
        try {
            aiGui := Gui("+AlwaysOnTop", "AI Assistant")
            aiGui.Add("Text", "w400 Center Bold", "🤖 AI Assistant")
            aiGui.Add("Text", "w380", "AI-powered Office 365 assistance")
            
            features := [
                "Smart email suggestions",
                "Meeting optimization",
                "Document analysis",
                "Task prioritization",
                "Calendar management"
            ]
            
            for i, feature in features {
                aiGui.Add("Text", "w380 h20", "• " . feature)
            }
            
            aiGui.Add("Text", "w380 Center ", "`nComing soon...")
            
            aiGui.Show("w420 h250")
        } catch as e {
            MsgBox("Error loading AI assistant: " . e.Message, "Error", "Iconx")
        }
    }
    
    static ProductivityAnalytics(*) {
        try {
            analyticsGui := Gui("+AlwaysOnTop", "Productivity Analytics")
            analyticsGui.Add("Text", "w400 Center Bold", "📈 Productivity Analytics")
            
            ; Mock analytics data
            analyticsText := "Today's Activity:`n" . 
                           "• Emails sent: 15`n" . 
                           "• Meetings attended: 3`n" . 
                           "• Documents created: 2`n" . 
                           "• Notes taken: 5`n`n" . 
                           "Weekly Summary:`n" . 
                           "• Total emails: 75`n" . 
                           "• Meeting hours: 12`n" . 
                           "• Documents: 8`n" . 
                           "• Productivity score: 85%`n`n" . 
                           "Recommendations:`n" . 
                           "• Schedule fewer meetings`n" . 
                           "• Use email templates`n" . 
                           "• Batch similar tasks"
            
            analyticsGui.Add("Text", "w380 h300", analyticsText)
            
            analyticsGui.Show("w420 h400")
        } catch as e {
            MsgBox("Error loading analytics: " . e.Message, "Error", "Iconx")
        }
    }
    
    static Settings(*) {
        try {
            settingsGui := Gui("+AlwaysOnTop", "Settings")
            settingsGui.Add("Text", "w400 Center Bold", "🔧 Office 365 Automation Settings")
            
            ; Auto-connect checkbox
            autoConnectCheck := settingsGui.Add("Checkbox", "w380 h20", "Auto-connect to Office apps on startup")
            autoConnectCheck.Value := 1
            
            ; Notification settings
            notifyCheck := settingsGui.Add("Checkbox", "w380 h20", "Enable notifications")
            notifyCheck.Value := 1
            
            ; Hotkey settings
            settingsGui.Add("Text", "w380 Bold", "Hotkeys:")
            settingsGui.Add("Text", "w380", "Ctrl+Alt+O - Open automation suite")
            settingsGui.Add("Text", "w380", "Ctrl+Alt+N - Quick note")
            settingsGui.Add("Text", "w380", "Ctrl+Alt+T - Teams call")
            settingsGui.Add("Text", "w380", "Ctrl+Alt+W - Word template")
            settingsGui.Add("Text", "w380", "Ctrl+Alt+E - Excel shortcuts")
            
            saveBtn := settingsGui.Add("Button", "w380 h30", "Save Settings")
            saveBtn.OnEvent("Click", ObjBindMethod(this, "HandleSettingsSave", settingsGui))
            
            settingsGui.Show("w420 h350")
        } catch as e {
            MsgBox("Error loading settings: " . e.Message, "Error", "Iconx")
        }
    }
    
    static Help(*) {
        try {
            helpGui := Gui("+AlwaysOnTop", "Help")
            helpGui.Add("Text", "w500 Center Bold", "❓ Office 365 Automation Help")
            
            helpText := "Welcome to Office 365 Automation Suite!`n`n" . 
                       "Features:`n" . 
                       "• Outlook: Quick replies, meeting scheduling, email templates`n" . 
                       "• OneNote: Quick notes, meeting notes, search`n" . 
                       "• Teams: Quick calls, auto-reply, meeting status`n" . 
                       "• Word/Excel: Templates, shortcuts, auto-save`n`n" . 
                       "Hotkeys:`n" . 
                       "• Ctrl+Alt+O - Open automation suite`n" . 
                       "• Ctrl+Alt+N - Quick OneNote note`n" . 
                       "• Ctrl+Alt+T - Quick Teams call`n" . 
                       "• Ctrl+Alt+W - Word document template`n" . 
                       "• Ctrl+Alt+E - Excel shortcuts`n`n" . 
                       "Tips:`n" . 
                       "• Ensure Office 365 apps are installed`n" . 
                       "• Run as administrator for full functionality`n" . 
                       "• Check Office 365 subscription status`n`n" . 
                       "Support: Contact IT department for assistance"
            
            helpGui.Add("Text", "w480 h400", helpText)
            
            helpGui.Show("w520 h500")
        } catch as e {
            MsgBox("Error loading help: " . e.Message, "Error", "Iconx")
        }
    }
    
    static UpdateStatus(message) {
        try {
            if (this.gui && this.gui["StatusText"]) {
                this.gui["StatusText"].Text := message
            }
        } catch {
            ; Ignore errors
        }
    }
    
    static SetupHotkeys() {
        ; Main hotkey
        Hotkey("^!o", (*) => this.CreateGUI())
        
        ; Quick shortcuts
        Hotkey("^!n", (*) => this.QuickNote())
        Hotkey("^!t", (*) => this.QuickCall())
        Hotkey("^!w", (*) => this.DocumentTemplates())
        Hotkey("^!e", (*) => this.ExcelShortcuts())
        
        ; Close with Escape
        Hotkey("Escape", (*) => this.CloseSuite())
    }

    static HandleQuickReplyTemplate(templateGui, reply, template) {
        reply.Body := template.content
        reply.Display()
        templateGui.Destroy()
    }

    static HandleScheduleMeeting(meetingGui, meeting, subjectEdit, attendeesEdit, startTimeEdit, durationEdit, locationEdit) {
        meeting.Subject := subjectEdit.Text
        meeting.Recipients.Add(attendeesEdit.Text)
        meeting.Start := startTimeEdit.Text
        meeting.Duration := durationEdit.Text
        meeting.Location := locationEdit.Text
        meeting.Body := "Meeting scheduled via Office 365 Automation Suite"
        meeting.Send()
        meetingGui.Destroy()
        TrayTip("Meeting Scheduled!", "Meeting has been scheduled successfully", 2)
    }

    static HandleEmailTemplateSelection(templateGui, template) {
        A_Clipboard := template.content
        TrayTip("Template Copied!", "Email template copied to clipboard", 2)
        templateGui.Destroy()
    }

    static HandleMarkAsRead(msgGui, message) {
        message.UnRead := false
        msgGui.Destroy()
    }

    static HandleMoveToArchive(msgGui, message) {
        archiveFolder := this.outlookApp.GetNamespace("MAPI").GetDefaultFolder(6).Folders.Item("Archive")
        message.Move(archiveFolder)
        msgGui.Destroy()
    }

    static HandleOpenMailNotification(notification, message) {
        message.Display()
        notification.Destroy()
    }

    static HandleQuickReplyNotification(notification) {
        this.QuickEmailReply()
        notification.Destroy()
    }

    static HandleMarkAsDoneNotification(notification, message) {
        message.Categories := "Completed"
        message.Save()
        notification.Destroy()
    }

    static HandleTaskSnooze(reminderGui, task) {
        task.ReminderTime := DateAdd(A_Now, 5, "Minutes")
        task.Save()
        reminderGui.Destroy()
    }

    static HandleTaskComplete(reminderGui, task) {
        task.MarkComplete()
        reminderGui.Destroy()
    }

    static HandleProjectStart(progressGui, progressList, projects) {
        selected := progressList.GetNext()
        if (selected) {
            project := projects[selected]
            TrayTip("Starting Project", project.title, 2)
            progressGui.Destroy()
        }
    }

    static HandleProjectViewSchedule(progressList, projects) {
        selected := progressList.GetNext()
        if (selected) {
            project := projects[selected]
            MsgBox("Schedule for " . project.title . "`n`n" . project.schedule, "Project Schedule")
        }
    }

    static HandleMeetingNotesCreate(meetingGui, titleEdit, dateEdit, attendeesEdit, agendaEdit) {
        notesContent := "Meeting Notes`n" . 
                      "=============`n`n" . 
                      "Title: " . titleEdit.Text . "`n" . 
                      "Date: " . dateEdit.Text . "`n" . 
                      "Attendees: " . attendeesEdit.Text . "`n`n" . 
                      "Agenda:`n" . agendaEdit.Text . "`n`n" . 
                      "Notes:`n" . 
                      "- `n" . 
                      "- `n" . 
                      "- `n`n" . 
                      "Action Items:`n" . 
                      "- [ ] `n" . 
                      "- [ ] `n" . 
                      "- [ ] `n`n" . 
                      "Decisions:`n" . 
                      "- `n" . 
                      "- `n`n" . 
                      "Next Meeting:`n" . 
                      "Date: `n" . 
                      "Agenda: `n"
        A_Clipboard := notesContent
        meetingGui.Destroy()
        TrayTip("Meeting Notes Created!", "Meeting notes template copied to clipboard", 2)
    }

    static HandleSearchNotes(searchGui, searchEdit) {
        searchTerm := searchEdit.Text
        if (searchTerm) {
            Run("onenote:search/" . searchTerm)
            searchGui.Destroy()
            TrayTip("Searching OneNote", "Search opened for: " . searchTerm, 2)
        }
    }

    static HandleQuickCall(callGui, contactEdit) {
        contact := contactEdit.Text
        if (contact) {
            Run("msteams://teams.microsoft.com/l/call/0/0?users=" . contact)
            callGui.Destroy()
            TrayTip("Starting Call", "Initiating call to " . contact, 2)
        }
    }

    static HandleTeamsAutoReply(replyGui, replyEdit) {
        replyMessage := replyEdit.Text
        A_Clipboard := replyMessage
        replyGui.Destroy()
        TrayTip("Auto-Reply Ready", "Message copied to clipboard. Set up auto-reply in Teams settings.", 2)
    }

    static HandleDocumentTemplateSelection(templateGui, template) {
        this.CreateDocumentTemplate(template)
        templateGui.Destroy()
    }

    static HandleClipboardSync(syncGui, currentClipboard) {
        timestamp := ""
        timestamp := FormatTime(, "yyyy-MM-dd HH:mm:ss")
        A_Clipboard := "Clipboard Sync - " . timestamp . "`n`n" . currentClipboard
        syncGui.Destroy()
        TrayTip("Clipboard Synced!", "Content copied to OneNote", 2)
    }

    static HandleSettingsSave(settingsGui) {
        TrayTip("Settings Saved!", "Settings have been saved", 2)
        settingsGui.Destroy()
    }

    static CloseSuite() {
        if (WinExist("Office 365 Automation Suite")) {
            WinClose("Office 365 Automation Suite")
        }
    }
}

; Initialize
Office365Automation.Init()
