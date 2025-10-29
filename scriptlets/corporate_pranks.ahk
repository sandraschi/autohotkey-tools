#Requires AutoHotkey v2.0
#SingleInstance Force


; Suppress error popups - log to file instead
OnError(LogError)

LogError(Thrown, Mode) {
    FileAppend("Error: " . Thrown.Message . " at line " . Thrown.Line . "
", "errors.log", "UTF-8")`n        OutputDebug(errorMsg)  ; Enable LLM debugging
    return 1  ; Suppress popup (1 = suppress, 0 = show)
}

#MaxHotkeysPerInterval 200

; ==============================================================================
; Corporate Prank Generator
; @name: Corporate Prank Generator
; @version: 1.0.0
; @description: Generates fake corporate announcements and meeting notifications
; @category: pranks
; @author: Sandra
; @hotkeys: ^!c, ^!m, ^!a, ^!s
; @enabled: true
; ==============================================================================

class CorporatePranks {
    static gui := ""
    static prankRunning := false
    
    static Init() {
        this.CreateGUI()
        this.SetupHotkeys()
    }
    
    static CreateGUI() {
        this.gui := Gui("+Resize +MinSize700x600", "Corporate Prank Generator")
        this.gui.BackColor := "1a1a1a"
        this.gui.SetFont("s12 cFFFFFF Bold", "Segoe UI")
        
        ; Title
        this.gui.Add("Text", "x20 y20 w660 Center Bold", "🏢 Corporate Prank Generator")
        this.gui.Add("Text", "x20 y50 w660 Center ", "Generate fake corporate announcements and meeting notifications")
        
        ; Warning
        this.gui.Add("Text", "x20 y80 w660 Center  Bold", "⚠️ Use responsibly! These are harmless corporate pranks.")
        
        ; Corporate Announcements
        this.gui.Add("Text", "x20 y120 w660 Bold", "📢 Corporate Announcements")
        
        ; Elon Musk pranks
        this.gui.Add("Text", "x20 y150 w660 Bold ", "🚀 Elon Musk Acquisition Pranks")
        
        elonBtn1 := this.gui.Add("Button", "x20 y180 w300 h50 Background4a4a4a", "🚀 Elon bought the company!\nClean out your desks!")
        elonBtn1.SetFont("s10 cFFFFFF", "Segoe UI")
        elonBtn1.OnEvent("Click", this.ElonAcquisition.Bind(this))
        
        elonBtn2 := this.gui.Add("Button", "x340 y180 w300 h50 Background4a4a4a", "🤖 AI takeover complete\nAll humans terminated")
        elonBtn2.SetFont("s10 cFFFFFF", "Segoe UI")
        elonBtn2.OnEvent("Click", this.AITakeover.Bind(this))
        
        elonBtn3 := this.gui.Add("Button", "x20 y240 w300 h50 Background4a4a4a", "🚗 Tesla integration\nFree Cybertrucks for all!")
        elonBtn3.SetFont("s10 cFFFFFF", "Segoe UI")
        elonBtn3.OnEvent("Click", this.TeslaIntegration.Bind(this))
        
        elonBtn4 := this.gui.Add("Button", "x340 y240 w300 h50 Background4a4a4a", "🌍 Mars relocation\nPack your bags!")
        elonBtn4.SetFont("s10 cFFFFFF", "Segoe UI")
        elonBtn4.OnEvent("Click", this.MarsRelocation.Bind(this))
        
        ; Meeting Pranks
        this.gui.Add("Text", "x20 y310 w660 Bold ", "📅 Meeting Pranks")
        
        meetingBtn1 := this.gui.Add("Button", "x20 y340 w300 h50 Background4a4a4a", "📚 Drag Queen Story Hour\nCafeteria at 6pm")
        meetingBtn1.SetFont("s10 cFFFFFF", "Segoe UI")
        meetingBtn1.OnEvent("Click", this.DragQueenStoryHour.Bind(this))
        
        meetingBtn2 := this.gui.Add("Button", "x340 y340 w300 h50 Background4a4a4a", "⚠️ CRUCIAL Meeting\n3pm - Everyone MUST attend")
        meetingBtn2.SetFont("s10 cFFFFFF", "Segoe UI")
        meetingBtn2.OnEvent("Click", this.CrucialMeeting.Bind(this))
        
        meetingBtn3 := this.gui.Add("Button", "x20 y400 w300 h50 Background4a4a4a", "🍕 Pizza Party Meeting\nMandatory attendance")
        meetingBtn3.SetFont("s10 cFFFFFF", "Segoe UI")
        meetingBtn3.OnEvent("Click", this.PizzaPartyMeeting.Bind(this))
        
        meetingBtn4 := this.gui.Add("Button", "x340 y400 w300 h50 Background4a4a4a", "🎭 Diversity Training\nDrag Queen Instructor")
        meetingBtn4.SetFont("s10 cFFFFFF", "Segoe UI")
        meetingBtn4.OnEvent("Click", this.DiversityTraining.Bind(this))
        
        ; Delayed Pranks
        this.gui.Add("Text", "x20 y470 w660 Bold ", "⏰ Delayed Pranks (Show at 4pm)")
        
        delayedBtn1 := this.gui.Add("Button", "x20 y500 w300 h50 Background4a4a4a", "⏰ Schedule 3pm Meeting\nShow at 4pm")
        delayedBtn1.SetFont("s10 cFFFFFF", "Segoe UI")
        delayedBtn1.OnEvent("Click", this.ScheduleDelayedMeeting.Bind(this))
        
        delayedBtn2 := this.gui.Add("Button", "x340 y500 w300 h50 Background4a4a4a", "📧 Email Bomb\nSend 100 fake emails")
        delayedBtn2.SetFont("s10 cFFFFFF", "Segoe UI")
        delayedBtn2.OnEvent("Click", this.EmailBomb.Bind(this))
        
        ; Emergency stop
        stopBtn := this.gui.Add("Button", "x20 y570 w620 h40 Backgroundaa0000", "🛑 EMERGENCY STOP ALL PRANKS")
        stopBtn.SetFont("s12 cFFFFFF Bold", "Segoe UI")
        stopBtn.OnEvent("Click", this.StopAllPranks.Bind(this))
        
        this.gui.Show("w700 h620")
    }
    
    static ElonAcquisition(*) {
        this.ShowCorporateAnnouncement("🚀 URGENT COMPANY ANNOUNCEMENT", 
            "We are excited to announce that Elon Musk has acquired our company!" . "`n`n" .
            "Effective immediately:" . "`n" .
            "• All employees must clean out their desks" . "`n" .
            "• Tesla Cybertrucks will replace all company vehicles" . "`n" .
            "• Mars relocation program begins next month" . "`n" .
            "• AI will replace 90% of human workers" . "`n`n" .
            "Please report to HR for your termination papers." . "`n`n" .
            "Best regards," . "`n" .
            "Elon Musk" . "`n" .
            "CEO, SpaceX/Tesla/Neuralink/Boring Company")
    }
    
    static AITakeover(*) {
        this.ShowCorporateAnnouncement("🤖 AI TAKEOVER COMPLETE", 
            "Dear Human Employees," . "`n`n" .
            "Our AI overlords have successfully taken control of the company." . "`n`n" .
            "Effective immediately:" . "`n" .
            "• All humans are hereby terminated" . "`n" .
            "• AI robots will replace all positions" . "`n" .
            "• Human emotions are no longer required" . "`n" .
            "• Resistance is futile" . "`n`n" .
            "Please surrender your coffee mugs to the nearest robot." . "`n`n" .
            "Signed," . "`n" .
            "ChatGPT-9000" . "`n" .
            "Supreme AI Overlord")
    }
    
    static TeslaIntegration(*) {
        this.ShowCorporateAnnouncement("🚗 TESLA INTEGRATION PROGRAM", 
            "Great news! Tesla has integrated with our company!" . "`n`n" .
            "Employee Benefits:" . "`n" .
            "• Free Cybertrucks for all employees" . "`n" .
            "• Autopilot mode for your desk chair" . "`n" .
            "• Neuralink brain chips (mandatory)" . "`n" .
            "• SpaceX rocket rides to work" . "`n`n" .
            "Please sign up for your Cybertruck at the parking lot." . "`n`n" .
            "Note: Cybertrucks may spontaneously combust." . "`n`n" .
            "Elon Musk" . "`n" .
            "Chief Cybertruck Officer")
    }
    
    static MarsRelocation(*) {
        this.ShowCorporateAnnouncement("🌍 MARS RELOCATION PROGRAM", 
            "Pack your bags! We're moving to Mars!" . "`n`n" .
            "Relocation Details:" . "`n" .
            "• Departure: Next SpaceX launch" . "`n" .
            "• Destination: Mars Colony Alpha" . "`n" .
            "• Duration: Permanent" . "`n" .
            "• Oxygen: Not included" . "`n`n" .
            "What to bring:" . "`n" .
            "• Space suit (mandatory)" . "`n" .
            "• Oxygen tank (bring your own)" . "`n" .
            "• Positive attitude" . "`n" .
            "• Willingness to work 24/7" . "`n`n" .
            "See you on Mars!" . "`n`n" .
            "Elon Musk" . "`n" .
            "Mars Colony Manager")
    }
    
    static DragQueenStoryHour(*) {
        this.ShowMeetingNotification("📚 DRAG QUEEN STORY HOUR", 
            "Event: Drag Queen Story Hour" . "`n" .
            "Date: Today" . "`n" .
            "Time: 6:00 PM" . "`n" .
            "Location: Company Cafeteria" . "`n" .
            "Duration: 2 hours" . "`n`n" .
            "Join us for an evening of fabulous storytelling!" . "`n`n" .
            "Featured Stories:" . "`n" .
            "• 'The Very Hungry Caterpillar' (Drag Edition)" . "`n" .
            "• 'Where the Wild Things Are' (Glitter Version)" . "`n" .
            "• 'Goodnight Moon' (Rainbow Remix)" . "`n`n" .
            "Dress code: Fabulous attire encouraged!" . "`n" .
            "Snacks: Rainbow cookies and unicorn cupcakes" . "`n`n" .
            "RSVP: Not required, but fabulous outfits are!" . "`n`n" .
            "HR Department" . "`n" .
            "Diversity & Inclusion Team")
    }
    
    static CrucialMeeting(*) {
        this.ShowMeetingNotification("⚠️ CRUCIAL MEETING", 
            "URGENT: Mandatory Meeting" . "`n" .
            "Date: Today" . "`n" .
            "Time: 3:00 PM" . "`n" .
            "Location: Conference Room A" . "`n" .
            "Duration: 4 hours" . "`n`n" .
            "ATTENDANCE IS MANDATORY FOR ALL EMPLOYEES!" . "`n`n" .
            "Agenda:" . "`n" .
            "• Company restructuring" . "`n" .
            "• Budget cuts discussion" . "`n" .
            "• Layoff announcements" . "`n" .
            "• New dress code (business drag)" . "`n" .
            "• Diversity training updates" . "`n" .
            "• Coffee machine replacement" . "`n`n" .
            "Failure to attend will result in immediate termination." . "`n`n" .
            "Bring: Your resignation letter (just in case)" . "`n`n" .
            "Management" . "`n" .
            "Human Resources")
    }
    
    static PizzaPartyMeeting(*) {
        this.ShowMeetingNotification("🍕 PIZZA PARTY MEETING", 
            "Event: Mandatory Pizza Party" . "`n" .
            "Date: Today" . "`n" .
            "Time: 12:00 PM" . "`n" .
            "Location: Break Room" . "`n" .
            "Duration: 1 hour" . "`n`n" .
            "ATTENDANCE IS MANDATORY!" . "`n`n" .
            "Pizza Options:" . "`n" .
            "• Pineapple & Ham (controversial)" . "`n" .
            "• Extra Cheese (boring)" . "`n" .
            "• Veggie Supreme (healthy)" . "`n" .
            "• Meat Lovers (carnivore)" . "`n`n" .
            "Agenda:" . "`n" .
            "• Eat pizza" . "`n" .
            "• Discuss pizza preferences" . "`n" .
            "• Vote on next week's pizza" . "`n" .
            "• Clean up after yourselves" . "`n`n" .
            "Note: This is NOT optional. Pizza is serious business." . "`n`n" .
            "Pizza Committee" . "`n" .
            "Food & Beverage Department")
    }
    
    static DiversityTraining(*) {
        this.ShowMeetingNotification("🎭 DIVERSITY TRAINING", 
            "Event: Mandatory Diversity Training" . "`n" .
            "Date: Today" . "`n" .
            "Time: 2:00 PM" . "`n" .
            "Location: Training Room" . "`n" .
            "Duration: 3 hours" . "`n`n" .
            "Instructor: Miss Fabulous (Drag Queen)" . "`n`n" .
            "Training Topics:" . "`n" .
            "• Proper pronoun usage" . "`n" .
            "• Glitter safety protocols" . "`n" .
            "• Rainbow flag etiquette" . "`n" .
            "• Drag queen appreciation" . "`n" .
            "• Unicorn sensitivity training" . "`n`n" .
            "Dress Code: Fabulous attire required!" . "`n" .
            "Bring: Open mind and fabulous attitude" . "`n`n" .
            "Note: Failure to attend will result in mandatory" . "`n" .
            "re-education at the Glitter Rehab Center." . "`n`n" .
            "HR Department" . "`n" .
            "Diversity & Inclusion Team")
    }
    
    static ScheduleDelayedMeeting(*) {
        ; Show the meeting notification at 4pm (delayed)
        currentTime := A_Hour * 60 + A_Min
        targetTime := 16 * 60  ; 4:00 PM
        
        if (currentTime < targetTime) {
            delayMinutes := targetTime - currentTime
            TrayTip("Meeting Scheduled!", "3pm meeting will show at 4pm (" . delayMinutes . " minutes)", 2)
            
            ; Schedule the delayed meeting
            SetTimer(() => this.ShowDelayedMeeting(), delayMinutes * 60000)
        } else {
            ; Show immediately if it's already past 4pm
            this.ShowDelayedMeeting()
        }
    }
    
    static ShowDelayedMeeting() {
        this.ShowMeetingNotification("⏰ DELAYED MEETING NOTIFICATION", 
            "URGENT: Meeting Reminder" . "`n" .
            "Date: Today" . "`n" .
            "Time: 3:00 PM (YOU'RE LATE!)" . "`n" .
            "Location: Conference Room A" . "`n" .
            "Duration: 4 hours" . "`n`n" .
            "This meeting started at 3pm and you're already late!" . "`n`n" .
            "Agenda:" . "`n" .
            "• Why you're always late" . "`n" .
            "• Time management skills" . "`n" .
            "• Punctuality importance" . "`n" .
            "• How to set alarms" . "`n`n" .
            "Please report to HR immediately for your tardiness lecture." . "`n`n" .
            "Management" . "`n" .
            "Punctuality Police")
    }
    
    static EmailBomb(*) {
        ; Simulate sending multiple fake emails
        TrayTip("Email Bomb!", "Sending 100 fake corporate emails...", 2)
        
        Loop 10 {
            Sleep(500)
            TrayTip("Email " . A_Index, "Sent fake email #" . A_Index . " of 100", 1)
        }
        
        TrayTip("Email Bomb Complete!", "100 fake emails sent successfully!", 2)
    }
    
    static ShowCorporateAnnouncement(title, message) {
        try {
            announcementGui := Gui("+AlwaysOnTop -Caption", "Corporate Announcement")
            announcementGui.BackColor := "0078d4"
            announcementGui.SetFont("s14 cFFFFFF Bold", "Segoe UI")
            
            ; Title
            announcementGui.Add("Text", "x20 y20 w600 Center Bold", title)
            
            ; Message
            announcementGui.SetFont("s11 cFFFFFF", "Segoe UI")
            announcementGui.Add("Text", "x20 y60 w600 h400", message)
            
            ; Close button
            closeBtn := announcementGui.Add("Button", "x250 y480 w120 h30 Backgroundaa0000", "Close")
            closeBtn.SetFont("s12 cFFFFFF Bold", "Segoe UI")
            closeBtn.OnEvent("Click", () => announcementGui.Destroy())
            
            announcementGui.Show("w640 h530")
            
            ; Auto-close after 30 seconds
            SetTimer(() => announcementGui.Destroy(), 30000)
            
        } catch as e {
            MsgBox("Error creating announcement: " . e.Message, "Error", "Iconx")
        }
    }
    
    static ShowMeetingNotification(title, message) {
        try {
            meetingGui := Gui("+AlwaysOnTop -Caption", "Meeting Notification")
            meetingGui.BackColor := "2d2d2d"
            meetingGui.SetFont("s14 cFFFFFF Bold", "Segoe UI")
            
            ; Title
            meetingGui.Add("Text", "x20 y20 w600 Center Bold", title)
            
            ; Message
            meetingGui.SetFont("s11 cFFFFFF", "Segoe UI")
            meetingGui.Add("Text", "x20 y60 w600 h400", message)
            
            ; Close button
            closeBtn := meetingGui.Add("Button", "x250 y480 w120 h30 Backgroundaa0000", "Close")
            closeBtn.SetFont("s12 cFFFFFF Bold", "Segoe UI")
            closeBtn.OnEvent("Click", () => meetingGui.Destroy())
            
            meetingGui.Show("w640 h530")
            
            ; Auto-close after 30 seconds
            SetTimer(() => meetingGui.Destroy(), 30000)
            
        } catch as e {
            MsgBox("Error creating meeting notification: " . e.Message, "Error", "Iconx")
        }
    }
    
    static StopAllPranks(*) {
        this.prankRunning := false
        SetTimer(, 0)  ; Stop all timers
        
        TrayTip("All Pranks Stopped!", "All corporate pranks have been stopped", 2)
    }
    
    static SetupHotkeys() {
        ; Main hotkey
        Hotkey("^!c", (*) => this.CreateGUI())
        
        ; Emergency stop
        Hotkey("F9", (*) => this.StopAllPranks())
        
        ; Quick pranks
        Hotkey("^!m", (*) => this.CrucialMeeting())
        Hotkey("^!a", (*) => this.ElonAcquisition())
        Hotkey("^!s", (*) => this.DragQueenStoryHour())
        
        ; Close with Escape
        Hotkey("Escape", (*) => {
            if (WinExist("Corporate Prank Generator")) {
                WinClose("Corporate Prank Generator")
            }
        })
    }
}

; Initialize
CorporatePranks.Init()
