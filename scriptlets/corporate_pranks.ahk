#Requires AutoHotkey v2.0+
#SingleInstance Force
#Include %A_ScriptDir%\lib\ScriptletErrorHandler.ahk

OnError(LogError)

LogError(Thrown, Mode) {
    ScriptletErrorHandler.Handle(Thrown, Mode)
    scriptInfo := (Thrown && HasProp(Thrown, "File") && Thrown.File) ? Thrown.File : A_ScriptFullPath
    lineInfo := (Thrown && HasProp(Thrown, "Line") && Thrown.Line) ? Thrown.Line : "?"
    message := "Error in " . scriptInfo . " @ line " . lineInfo . ": " . (Thrown && HasProp(Thrown, "Message") ? Thrown.Message : "Unknown error")
    CorporatePranks.AppendLog(message)
    if (Mode = "Throw") {
        return 0
    }
    return 1
}

class CorporatePranks {
    static mainGui := ""
    static logEdit := ""
    static mainGuiVisible := false
    static activeDialogs := []
    static activeTimers := []
    static logFile := A_ScriptDir . "\\corporate_pranks.log"

    static Init() {
        if (!CorporatePranks.mainGui) {
            CorporatePranks.CreateGUI()
            CorporatePranks.SetupHotkeys()
        }
        CorporatePranks.ShowMainGui()
        CorporatePranks.AppendLog("Corporate Prank Generator initialized.")
    }

    static CreateGUI() {
        gui := Gui("+Resize +MinSize720x720", "Corporate Prank Generator")
        gui.SetFont("s11", "Segoe UI")

        gui.AddText("x20 y20 w680 Center c0A74FF Bold", "Corporate Prank Generator")
        gui.AddText("x20 y48 w680 Center", "Generate fake corporate announcements, meetings, and email pranks.")
        gui.AddText("x20 y76 w680 Center cFF6600", "⚠️ Use responsibly. For harmless office fun only.")

        gui.AddText("x20 y120 w680 Bold", "Corporate Announcements")
        gui.AddButton("x20 y150 w320 h44", "🚀 Elon bought the company").OnEvent("Click", ObjBindMethod(CorporatePranks, "ElonAcquisition"))
        gui.AddButton("x360 y150 w320 h44", "🤖 AI takeover complete").OnEvent("Click", ObjBindMethod(CorporatePranks, "AITakeover"))
        gui.AddButton("x20 y200 w320 h44", "🚗 Tesla integration perks").OnEvent("Click", ObjBindMethod(CorporatePranks, "TeslaIntegration"))
        gui.AddButton("x360 y200 w320 h44", "🌍 Mars relocation memo").OnEvent("Click", ObjBindMethod(CorporatePranks, "MarsRelocation"))

        gui.AddText("x20 y260 w680 Bold", "Meeting Pranks")
        gui.AddButton("x20 y290 w320 h44", "📚 Drag Queen Story Hour").OnEvent("Click", ObjBindMethod(CorporatePranks, "DragQueenStoryHour"))
        gui.AddButton("x360 y290 w320 h44", "⚠️ Crucial 3PM meeting").OnEvent("Click", ObjBindMethod(CorporatePranks, "CrucialMeeting"))
        gui.AddButton("x20 y340 w320 h44", "🍕 Mandatory pizza party").OnEvent("Click", ObjBindMethod(CorporatePranks, "PizzaPartyMeeting"))
        gui.AddButton("x360 y340 w320 h44", "🎭 Diversity training").OnEvent("Click", ObjBindMethod(CorporatePranks, "DiversityTraining"))

        gui.AddText("x20 y400 w680 Bold", "Delayed Pranks")
        gui.AddButton("x20 y430 w320 h44", "⏰ Schedule 3PM meeting for 4PM").OnEvent("Click", ObjBindMethod(CorporatePranks, "ScheduleDelayedMeeting"))
        gui.AddButton("x360 y430 w320 h44", "📧 Email bomb (fake)").OnEvent("Click", ObjBindMethod(CorporatePranks, "EmailBomb"))

        gui.AddText("x20 y490 w680 Bold", "Activity Log")
        logEdit := gui.AddEdit("x20 y520 w680 h140 -Wrap ReadOnly VScroll", "")

        stopBtn := gui.AddButton("x20 y680 w680 h40", "🛑 Emergency Stop All Pranks")
        stopBtn.SetFont("s12 Bold", "Segoe UI")
        stopBtn.OnEvent("Click", ObjBindMethod(CorporatePranks, "StopAllPranks"))

        gui.OnEvent("Close", ObjBindMethod(CorporatePranks, "HideMainGui"))
        gui.OnEvent("Escape", ObjBindMethod(CorporatePranks, "HideMainGui"))

        CorporatePranks.mainGui := gui
        CorporatePranks.logEdit := logEdit
    }

    static SetupHotkeys() {
        Hotkey("^!c", ObjBindMethod(CorporatePranks, "ToggleMainGui"))
        Hotkey("F9", ObjBindMethod(CorporatePranks, "StopAllPranks"))
        Hotkey("^!m", ObjBindMethod(CorporatePranks, "CrucialMeeting"))
        Hotkey("^!a", ObjBindMethod(CorporatePranks, "ElonAcquisition"))
        Hotkey("^!s", ObjBindMethod(CorporatePranks, "DragQueenStoryHour"))
        Hotkey("Escape", ObjBindMethod(CorporatePranks, "HideMainGui"))
    }

    static ToggleMainGui(*) {
        if (!CorporatePranks.mainGui) {
            return
        }
        if (CorporatePranks.mainGuiVisible) {
            CorporatePranks.HideMainGui()
        } else {
            CorporatePranks.ShowMainGui()
        }
    }

    static ShowMainGui() {
        try {
            CorporatePranks.mainGui.Show("w720 h740")
            CorporatePranks.mainGuiVisible := true
        } catch as e {
            CorporatePranks.AppendLog("Failed to show main GUI: " . e.Message)
        }
    }

    static HideMainGui(*) {
        if (CorporatePranks.mainGui) {
            CorporatePranks.mainGui.Hide()
        }
        CorporatePranks.mainGuiVisible := false
    }

    static AppendLog(message) {
        timestamp := ""
        FormatTime(timestamp, A_Now, "HH:mm:ss")
        entry := "[" . timestamp . "] " . message
        try {
            FileAppend(entry . "`n", CorporatePranks.logFile, "UTF-8")
        } catch {
        }
        if (CorporatePranks.logEdit) {
            CorporatePranks.logEdit.Value := CorporatePranks.logEdit.Value . entry . "`n"
        }
        OutputDebug(entry)
    }

    static RegisterTimer(callback, intervalMs, tag := "") {
        CorporatePranks.activeTimers.Push({callback: callback, tag: tag})
        SetTimer(callback, intervalMs)
    }

    static CancelTimersByTag(tag) {
        remaining := []
        for timerInfo in CorporatePranks.activeTimers {
            if (timerInfo.tag = tag) {
                try SetTimer(timerInfo.callback, 0)
            } else {
                remaining.Push(timerInfo)
            }
        }
        CorporatePranks.activeTimers := remaining
    }

    static ClearTimers() {
        for timerInfo in CorporatePranks.activeTimers {
            try SetTimer(timerInfo.callback, 0)
        }
        CorporatePranks.activeTimers := []
    }

    static TrackDialog(dialog) {
        CorporatePranks.activeDialogs.Push(dialog)
        dialog.OnEvent("Close", ObjBindMethod(CorporatePranks, "DestroyDialog", dialog))
    }

    static DestroyDialog(dialog, *) {
        CorporatePranks.RemoveDialog(dialog)
        CorporatePranks.CancelTimersByTag(dialog)
        try dialog.Destroy()
    }

    static RemoveDialog(dialog) {
        index := CorporatePranks.activeDialogs.IndexOf(dialog)
        if (index) {
            CorporatePranks.activeDialogs.RemoveAt(index)
        }
    }

    static DestroyAllDialogs() {
        for dialog in CorporatePranks.activeDialogs {
            try dialog.Destroy()
        }
        CorporatePranks.activeDialogs := []
    }

    static ShowCorporateAnnouncement(title, message) {
        CorporatePranks.CreateDialog(title, message, "Corporate Announcement", "0x1E4E79")
    }

    static ShowMeetingNotification(title, message) {
        CorporatePranks.CreateDialog(title, message, "Meeting Notification", "0x323232")
    }

    static CreateDialog(title, message, caption, backgroundColor) {
        try {
            dialog := Gui("+AlwaysOnTop -Caption +ToolWindow", caption)
            dialog.BackColor := backgroundColor
            dialog.SetFont("s13 Bold", "Segoe UI")
            dialog.AddText("x20 y20 w540 Center", title)
            dialog.SetFont("s10", "Segoe UI")
            dialog.AddEdit("x20 y60 w540 h320 ReadOnly -Wrap", message)
            closeBtn := dialog.AddButton("x220 y400 w140 h34", "Close")
            closeBtn.SetFont("s11 Bold", "Segoe UI")
            closeBtn.OnEvent("Click", ObjBindMethod(CorporatePranks, "DestroyDialog", dialog))

            CorporatePranks.TrackDialog(dialog)
            dialog.Show("w580 h450")

            autoClose := ObjBindMethod(CorporatePranks, "DestroyDialog", dialog)
            CorporatePranks.RegisterTimer(autoClose, -30000, dialog)

            CorporatePranks.AppendLog("Displayed dialog: " . title)
        } catch as e {
            CorporatePranks.AppendLog("Failed to create dialog: " . e.Message)
        }
    }

    static ShowTrayMessage(title, message) {
        TrayTip(title, message)
        CorporatePranks.CancelTimersByTag("TrayTipClear")
        clearTip := (*) => TrayTip()
        CorporatePranks.RegisterTimer(clearTip, -4000, "TrayTipClear")
        CorporatePranks.AppendLog(title . " - " . message)
    }

    static ElonAcquisition(*) {
        CorporatePranks.ShowCorporateAnnouncement("🚀 URGENT COMPANY ANNOUNCEMENT", "Elon Musk has acquired the company!" . "`n`n"
            . "• All employees must clean out their desks." . "`n"
            . "• Tesla Cybertrucks replace all company vehicles." . "`n"
            . "• Mars relocation begins next month." . "`n"
            . "• AI will replace 90% of roles." . "`n`n"
            . "Please report to HR for termination paperwork." . "`n`n" . "– Elon Musk")
    }

    static AITakeover(*) {
        CorporatePranks.ShowCorporateAnnouncement("🤖 AI TAKEOVER COMPLETE", "Dear Human Employees," . "`n`n"
            . "Our AI overlords now control the company." . "`n`n"
            . "• All humans are terminated." . "`n"
            . "• AI robots assume all positions." . "`n"
            . "• Surrender your coffee mug to the nearest robot." . "`n`n"
            . "Signed, ChatGPT‑9000")
    }

    static TeslaIntegration(*) {
        CorporatePranks.ShowCorporateAnnouncement("🚗 TESLA INTEGRATION PROGRAM", "Great news! Tesla is integrating with us." . "`n`n"
            . "Benefits:" . "`n"
            . "• Free Cybertrucks." . "`n"
            . "• Autopilot desk chairs." . "`n"
            . "• Mandatory Neuralink implants." . "`n"
            . "• SpaceX rocket rides to work." . "`n`n"
            . "Sign up in the parking lot (combustion risk applies).")
    }

    static MarsRelocation(*) {
        CorporatePranks.ShowCorporateAnnouncement("🌍 MARS RELOCATION PROGRAM", "Pack your bags—Mars awaits!" . "`n`n"
            . "Departure: Next SpaceX launch." . "`n"
            . "Destination: Mars Colony Alpha." . "`n"
            . "Oxygen: Bring your own." . "`n"
            . "Work schedule: 24/7." . "`n`n"
            . "See you on the red planet.")
    }

    static DragQueenStoryHour(*) {
        CorporatePranks.ShowMeetingNotification("📚 DRAG QUEEN STORY HOUR", "Event: Drag Queen Story Hour" . "`n"
            . "Time: 6:00 PM today" . "`n"
            . "Location: Cafeteria" . "`n`n"
            . "Featured stories include glitter remixes of childhood classics." . "`n"
            . "Rainbow snacks provided. Fabulous attire encouraged.")
    }

    static CrucialMeeting(*) {
        CorporatePranks.ShowMeetingNotification("⚠️ CRUCIAL MEETING", "Mandatory meeting at 3:00 PM." . "`n`n"
            . "Agenda:" . "`n"
            . "• Company restructuring" . "`n"
            . "• Layoff announcements" . "`n"
            . "• New dress code (business drag)" . "`n" . "Bring your resignation letter—just in case.")
    }

    static PizzaPartyMeeting(*) {
        CorporatePranks.ShowMeetingNotification("🍕 MANDATORY PIZZA PARTY", "Event: Lunch meeting at noon." . "`n`n"
            . "Pizza lineup:" . "`n"
            . "• Pineapple & ham" . "`n"
            . "• Extra cheese" . "`n"
            . "• Veggie supreme" . "`n"
            . "• Meat lovers" . "`n`n"
            . "Attendance is not optional—pizza is serious business.")
    }

    static DiversityTraining(*) {
        CorporatePranks.ShowMeetingNotification("🎭 DIVERSITY TRAINING", "Instructor: Miss Fabulous." . "`n"
            . "Time: 2:00 PM today" . "`n"
            . "Duration: 3 hours" . "`n`n"
            . "Topics include glitter safety and unicorn sensitivity." . "`n"
            . "Dress code: Fabulous. Blank outfits will be bedazzled at the door.")
    }

    static ScheduleDelayedMeeting(*) {
        currentMinutes := (A_Hour + 0) * 60 + (A_Min + 0)
        targetMinutes := 16 * 60
        if (currentMinutes < targetMinutes) {
            delayMinutes := targetMinutes - currentMinutes
            CorporatePranks.ShowTrayMessage("Delayed Meeting Scheduled", "3PM reminder will pop at 4PM (" . delayMinutes . " min)")
            CorporatePranks.CancelTimersByTag("DelayedMeeting")
            callback := ObjBindMethod(CorporatePranks, "ShowDelayedMeeting")
            CorporatePranks.RegisterTimer(callback, -(delayMinutes * 60000), "DelayedMeeting")
        } else {
            CorporatePranks.ShowDelayedMeeting()
        }
    }

    static ShowDelayedMeeting(*) {
        CorporatePranks.CancelTimersByTag("DelayedMeeting")
        CorporatePranks.ShowMeetingNotification("⏰ DELAYED MEETING NOTICE", "This meeting started at 3:00 PM—you are late." . "`n`n"
            . "Agenda:" . "`n"
            . "• Time management" . "`n"
            . "• Alarm configuration" . "`n"
            . "• HR tardiness counseling" . "`n`n"
            . "Report to HR immediately.")
    }

    static EmailBomb(*) {
        CorporatePranks.AppendLog("Launching fake email bomb.")
        CorporatePranks.ShowTrayMessage("Email Bomb", "Sending 20 fake corporate emails...")
        Loop 20 {
            Sleep(400)
            CorporatePranks.ShowTrayMessage("Email " . A_Index, "Fake email #" . A_Index . " sent")
        }
        CorporatePranks.ShowTrayMessage("Email Bomb Complete", "20 fake emails sent successfully")
        CorporatePranks.AppendLog("Fake email bomb completed.")
    }

    static StopAllPranks(*) {
        CorporatePranks.ClearTimers()
        CorporatePranks.DestroyAllDialogs()
        TrayTip()
        CorporatePranks.AppendLog("All pranks halted.")
    }
}

CorporatePranks.Init()

OnExit((*) => CorporatePranks.StopAllPranks())
