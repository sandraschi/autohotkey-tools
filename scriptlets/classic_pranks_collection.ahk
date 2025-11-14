; ==============================================================================
; Classic Pranks Collection
; @name: Classic Pranks Collection
; @version: 1.0.0
; @description: Collection of classic computer pranks and harmless jokes. Comprehensive collection of classic prank effects with GUI interface.
; @description: Provides fake blue screens, flying bugs, screen flipping, key swapping, fake errors, and other classic prank effects. Includes GUI launcher with previews and descriptions.
; @description: Entertainment tool for harmless classic computer pranks. Use responsibly and only with consenting participants.
; @category: fun
; @author: Sandra
; @hotkeys: ^!p, F9
; @enabled: false
; @priority: 90
; @tag: pranks, classic, fun, entertainment, harmless, jokes, gui, collection
; @cli: --prank <name> - Run specific prank from collection
; @cli: --list - List all available pranks
; @cli: --help - Show CLI usage and prank options
; @dependencies: 
; ==============================================================================

#Requires AutoHotkey v2.0+
#SingleInstance Force
#Include %A_ScriptDir%\lib\ScriptletErrorHandler.ahk


; Suppress error popups - log to file instead
OnError(LogError)


class ClassicPranks {
    static gui := ""
    static prankRunning := false
    static timers := Map()
    static keySwapHotkeys := Map()
    static flipOverlay := ""
    
    static Init() {
        this.CreateGUI()
        this.SetupHotkeys()
    }
    
    static CreateGUI() {
        this.gui := Gui("+Resize +MinSize600x500", "Classic Pranks Collection")
        this.gui.BackColor := "1a1a1a"
        this.gui.SetFont("s12 cFFFFFF Bold", "Segoe UI")
        
        ; Title
        this.gui.Add("Text", "x20 y20 w560 Center Bold", "🎭 Classic Pranks Collection")
        this.gui.Add("Text", "x20 y50 w560 Center ", "Harmless computer pranks and classic jokes")
        
        ; Warning
        this.gui.Add("Text", "x20 y80 w560 Center Bold", "⚠️ Use responsibly! These are harmless pranks.")
        
        ; Prank categories
        this.gui.Add("Text", "x20 y120 w560 Bold", "🎯 Classic Pranks")
        
        ; Desktop pranks
        this.gui.Add("Text", "x20 y150 w560 Bold ", "🖥️ Desktop Pranks")
        
        desktopBtn1 := this.gui.Add("Button", "x20 y180 w250 h40 Background4a4a4a", "🔄 Flip Screen")
        desktopBtn1.SetFont("s10 cFFFFFF", "Segoe UI")
        desktopBtn1.OnEvent("Click", (*) => this.FlipScreen())
        
        desktopBtn2 := this.gui.Add("Button", "x290 y180 w250 h40 Background4a4a4a", "🖼️ Fake Blue Screen")
        desktopBtn2.SetFont("s10 cFFFFFF", "Segoe UI")
        desktopBtn2.OnEvent("Click", (*) => this.FakeBlueScreen())
        
        desktopBtn3 := this.gui.Add("Button", "x20 y230 w250 h40 Background4a4a4a", "📱 Fake Phone Call")
        desktopBtn3.SetFont("s10 cFFFFFF", "Segoe UI")
        desktopBtn3.OnEvent("Click", (*) => this.FakePhoneCall())
        
        desktopBtn4 := this.gui.Add("Button", "x290 y230 w250 h40 Background4a4a4a", "🎭 Fake Windows Update")
        desktopBtn4.SetFont("s10 cFFFFFF", "Segoe UI")
        desktopBtn4.OnEvent("Click", (*) => this.FakeWindowsUpdate())
        
        ; Mouse pranks
        this.gui.Add("Text", "x20 y290 w560 Bold ", "🖱️ Mouse Pranks")
        
        mouseBtn1 := this.gui.Add("Button", "x20 y320 w250 h40 Background4a4a4a", "🔄 Reverse Mouse")
        mouseBtn1.SetFont("s10 cFFFFFF", "Segoe UI")
        mouseBtn1.OnEvent("Click", (*) => this.ReverseMouse())
        
        mouseBtn2 := this.gui.Add("Button", "x290 y320 w250 h40 Background4a4a4a", "🎯 Mouse Jitter")
        mouseBtn2.SetFont("s10 cFFFFFF", "Segoe UI")
        mouseBtn2.OnEvent("Click", (*) => this.MouseJitter())
        
        mouseBtn3 := this.gui.Add("Button", "x20 y370 w250 h40 Background4a4a4a", "🖱️ Mouse Trail")
        mouseBtn3.SetFont("s10 cFFFFFF", "Segoe UI")
        mouseBtn3.OnEvent("Click", (*) => this.MouseTrail())
        
        mouseBtn4 := this.gui.Add("Button", "x290 y370 w250 h40 Background4a4a4a", "🎪 Random Clicks")
        mouseBtn4.SetFont("s10 cFFFFFF", "Segoe UI")
        mouseBtn4.OnEvent("Click", (*) => this.RandomClicks())
        
        ; Keyboard pranks
        this.gui.Add("Text", "x20 y430 w560 Bold ", "⌨️ Keyboard Pranks")
        
        keyboardBtn1 := this.gui.Add("Button", "x20 y460 w250 h40 Background4a4a4a", "🔄 Swap Keys")
        keyboardBtn1.SetFont("s10 cFFFFFF", "Segoe UI")
        keyboardBtn1.OnEvent("Click", (*) => this.SwapKeys())
        
        keyboardBtn2 := this.gui.Add("Button", "x290 y460 w250 h40 Background4a4a4a", "🎭 Fake Typing")
        keyboardBtn2.SetFont("s10 cFFFFFF", "Segoe UI")
        keyboardBtn2.OnEvent("Click", (*) => this.FakeTyping())
        
        ; Emergency stop
        stopBtn := this.gui.Add("Button", "x20 y520 w540 h40 Backgroundaa0000", "🛑 EMERGENCY STOP ALL PRANKS")
        stopBtn.SetFont("s12 cFFFFFF Bold", "Segoe UI")
        stopBtn.OnEvent("Click", (*) => this.StopAllPranks())
        
        this.gui.Show("w600 h580")
    }
    
    static FlipScreen(*) {
        try {
            if (this.flipOverlay) {
                this.flipOverlay.Destroy()
            }
            overlay := Gui("+AlwaysOnTop -Caption", "Flipped Screen")
            overlay.BackColor := "000000"
            overlay.SetFont("s20 cFFFFFF Bold", "Segoe UI")
            overlay.Add("Text", "Center w" . A_ScreenWidth . " h" . A_ScreenHeight, "Screen is upside down! 😵")
            overlay.Show("x0 y0 w" . A_ScreenWidth . " h" . A_ScreenHeight)
            this.flipOverlay := overlay
            this.ShowTrayTip("Screen Flipped!", "Screen rotated 180 degrees (simulated)")
            this.RegisterOneShot(10000, (*) => this.RestoreScreen())
        } catch as e {
            MsgBox("Error flipping screen: " . e.Message, "Error", "Iconx")
        }
    }
    
    static RestoreScreen() {
        if (this.flipOverlay) {
            try {
                this.flipOverlay.Destroy()
            } catch {
            }
            this.flipOverlay := ""
        }
        this.ShowTrayTip("Screen Restored!", "Screen orientation restored")
    }
    
    static FakeBlueScreen(*) {
        try {
            ; Create fake blue screen
            bsGui := Gui("+AlwaysOnTop -Caption", "Fake Blue Screen")
            bsGui.BackColor := "0000AA"
            bsGui.SetFont("s12 cFFFFFF", "Courier New")
            
            bsGui.Add("Text", "x50 y50 w500 Center", "A problem has been detected and Windows has been shut down")
            bsGui.Add("Text", "x50 y80 w500 Center", "to prevent damage to your computer.")
            bsGui.Add("Text", "x50 y120 w500 Center", "IRQL_NOT_LESS_OR_EQUAL")
            bsGui.Add("Text", "x50 y150 w500 Center", "If this is the first time you've seen this error screen,")
            bsGui.Add("Text", "x50 y180 w500 Center", "restart your computer. If this screen appears again,")
            bsGui.Add("Text", "x50 y210 w500 Center", "follow these steps:")
            bsGui.Add("Text", "x50 y250 w500 Center", "Check to make sure any new hardware or software")
            bsGui.Add("Text", "x50 y280 w500 Center", "is properly installed.")
            bsGui.Add("Text", "x50 y320 w500 Center", "Press any key to continue...")
            
            bsGui.Show("w600 h400")
            
            this.RegisterOneShot(5000, (*) => bsGui.Destroy())
            this.ShowTrayTip("Fake Blue Screen!", "Blue screen prank activated")
            
        } catch as e {
            MsgBox("Error creating fake blue screen: " . e.Message, "Error", "Iconx")
        }
    }
    
    static FakePhoneCall(*) {
        try {
            ; Create fake phone call popup
            callGui := Gui("+AlwaysOnTop -Caption", "Fake Phone Call")
            callGui.BackColor := "2d2d2d"
            callGui.SetFont("s14 cFFFFFF Bold", "Segoe UI")
            
            callGui.Add("Text", "x20 y20 w300 Center", "📞 Incoming Call")
            callGui.Add("Text", "x20 y60 w300 Center", "Unknown Number")
            callGui.Add("Text", "x20 y100 w300 Center", "555-0123")
            
            answerBtn := callGui.Add("Button", "x50 y150 w100 h40 Background00aa00", "Answer")
            answerBtn.SetFont("s12 cFFFFFF Bold", "Segoe UI")
            answerBtn.OnEvent("Click", (*) => callGui.Destroy())
            
            declineBtn := callGui.Add("Button", "x170 y150 w100 h40 Backgroundaa0000", "Decline")
            declineBtn.SetFont("s12 cFFFFFF Bold", "Segoe UI")
            declineBtn.OnEvent("Click", (*) => callGui.Destroy())
            
            callGui.Show("w340 h220")
            
            this.RegisterOneShot(10000, (*) => callGui.Destroy())
            this.ShowTrayTip("Fake Phone Call!", "Incoming call popup shown")
            
        } catch as e {
            MsgBox("Error creating fake phone call: " . e.Message, "Error", "Iconx")
        }
    }
    
    static FakeWindowsUpdate(*) {
        try {
            ; Create fake Windows update
            updateGui := Gui("+AlwaysOnTop -Caption", "Fake Windows Update")
            updateGui.BackColor := "0078d4"
            updateGui.SetFont("s12 cFFFFFF", "Segoe UI")
            
            updateGui.Add("Text", "x20 y20 w400 Center Bold", "Windows Update")
            updateGui.Add("Text", "x20 y60 w400 Center", "Installing updates...")
            updateGui.Add("Text", "x20 y90 w400 Center", "Please don't turn off your computer.")
            
            ; Progress bar
            progress := updateGui.Add("Progress", "x20 y130 w400 h20", 0)
            
            updateGui.Show("w440 h200")
            
            ; Animate progress
            Loop 100 {
                progress.Value := A_Index
                Sleep(100)
            }
            updateGui.Destroy()
            this.ShowTrayTip("Windows Update!", "Fake update completed")
            
        } catch as e {
            MsgBox("Error creating fake Windows update: " . e.Message, "Error", "Iconx")
        }
    }
    
    static ReverseMouse(*) {
        try {
            this.prankRunning := true
            
            this.RegisterTimer("mouseReverse", (*) => this.ReverseMouseStep(), 10)
            this.ShowTrayTip("Mouse Reversed!", "Mouse movement is now reversed")
            this.RegisterOneShot(30000, (*) => this.StopMousePrank())
            
        } catch as e {
            MsgBox("Error reversing mouse: " . e.Message, "Error", "Iconx")
        }
    }
    
    static MouseJitter(*) {
        try {
            this.prankRunning := true
            
            this.RegisterTimer("mouseJitter", (*) => this.MouseJitterStep(), 50)
            this.ShowTrayTip("Mouse Jitter!", "Mouse has random jitter")
            this.RegisterOneShot(20000, (*) => this.StopMousePrank())
            
        } catch as e {
            MsgBox("Error adding mouse jitter: " . e.Message, "Error", "Iconx")
        }
    }
    
    static MouseTrail(*) {
        try {
            this.prankRunning := true
            
            this.RegisterTimer("mouseTrail", (*) => this.MouseTrailStep(), 100)
            this.ShowTrayTip("Mouse Trail!", "Mouse leaves a green trail")
            this.RegisterOneShot(15000, (*) => this.StopMousePrank())
            
        } catch as e {
            MsgBox("Error creating mouse trail: " . e.Message, "Error", "Iconx")
        }
    }
    
    static RandomClicks(*) {
        try {
            this.prankRunning := true
            
            this.RegisterTimer("randomClicks", (*) => this.RandomClicksStep(), 2000)
            this.ShowTrayTip("Random Clicks!", "Random clicks every 2 seconds")
            this.RegisterOneShot(30000, (*) => this.StopMousePrank())
            
        } catch as e {
            MsgBox("Error creating random clicks: " . e.Message, "Error", "Iconx")
        }
    }
    
    static SwapKeys(*) {
        try {
            this.prankRunning := true
            
            if (this.keySwapHotkeys.Count = 0) {
                swaps := [
                    ["a", "b"],
                    ["b", "a"],
                    ["n", "m"],
                    ["m", "n"]
                ]
                for swap in swaps {
                    src := swap[1]
                    dest := swap[2]
                    callback := (*) => Send(dest)
                    Hotkey(src, callback, "On")
                    this.keySwapHotkeys[src] := callback
                }
            }
            this.ShowTrayTip("Keys Swapped!", "Some keys are now swapped")
            this.RegisterOneShot(30000, (*) => this.StopKeyboardPrank())
            
        } catch as e {
            MsgBox("Error swapping keys: " . e.Message, "Error", "Iconx")
        }
    }
    
    static FakeTyping(*) {
        try {
            this.prankRunning := true
            
            this.RegisterTimer("fakeTyping", (*) => this.FakeTypingStep(), 3000)
            this.ShowTrayTip("Fake Typing!", "Random text will be typed")
            this.RegisterOneShot(30000, (*) => this.StopKeyboardPrank())
            
        } catch as e {
            MsgBox("Error creating fake typing: " . e.Message, "Error", "Iconx")
        }
    }
    
    static StopMousePrank() {
        this.prankRunning := false
        this.StopTimer("mouseReverse")
        this.StopTimer("mouseJitter")
        this.StopTimer("mouseTrail")
        this.StopTimer("randomClicks")
        this.ShowTrayTip("Mouse Prank Stopped!", "Mouse behavior restored")
    }
    
    static StopKeyboardPrank() {
        this.prankRunning := false
        this.StopTimer("fakeTyping")
        this.RestoreKeySwaps()
        this.ShowTrayTip("Keyboard Prank Stopped!", "Keyboard behavior restored")
    }
    
    static StopAllPranks(*) {
        this.prankRunning := false
        this.StopAllTimers()
        this.RestoreKeySwaps()
        this.RestoreScreen()
        this.ShowTrayTip("All Pranks Stopped!", "All pranks have been stopped")
    }
    
    static SetupHotkeys() {
        Hotkey("^!p", (*) => this.CreateGUI())
        Hotkey("F9", (*) => this.StopAllPranks())
        Hotkey("Escape", (*) => this.CloseGui())
    }

    static RegisterTimer(name, callback, period) {
        this.StopTimer(name)
        timer := SetTimer(callback, period)
        this.timers[name] := timer
        return timer
    }

    static RegisterOneShot(delayMs, callback) {
        SetTimer(callback, -Abs(delayMs))
    }

    static StopTimer(name) {
        if (this.timers.Has(name)) {
            timer := this.timers[name]
            try {
                timer.Stop()
            } catch {
            }
            this.timers.Delete(name)
        }
    }

    static StopAllTimers() {
        for name, timer in this.timers {
            try {
                timer.Stop()
            } catch {
            }
        }
        this.timers.Clear()
    }

    static RestoreKeySwaps() {
        for key, callback in this.keySwapHotkeys {
            try {
                Hotkey(key, callback, "Off")
            } catch {
            }
        }
        this.keySwapHotkeys.Clear()
    }

    static ShowTrayTip(title, message) {
        TrayTip(title, message)
    }

    static CloseGui(*) {
        if (WinExist("Classic Pranks Collection")) {
            WinClose("Classic Pranks Collection")
        }
    }

    static ReverseMouseStep(*) {
        x := 0
        y := 0
        MouseGetPos(&x, &y)
        MouseMove(A_ScreenWidth - x, A_ScreenHeight - y, 0)
    }

    static MouseJitterStep(*) {
        x := 0
        y := 0
        MouseGetPos(&x, &y)
        jitterX := Random(-5, 5)
        jitterY := Random(-5, 5)
        MouseMove(x + jitterX, y + jitterY, 0)
    }

    static MouseTrailStep(*) {
        x := 0
        y := 0
        MouseGetPos(&x, &y)
        trailGui := Gui("+AlwaysOnTop -Caption +ToolWindow", "")
        trailGui.BackColor := "00ff00"
        trailGui.Show("x" . x . " y" . y . " w4 h4")
        this.RegisterOneShot(1000, (*) => trailGui.Destroy())
    }

    static RandomClicksStep(*) {
        x := Random(0, A_ScreenWidth)
        y := Random(0, A_ScreenHeight)
        Click(x, y)
    }

    static FakeTypingStep(*) {
        fakeText := "Hello World! This is fake typing. "
        Send(fakeText)
    }
}

; Initialize
ClassicPranks.Init()














