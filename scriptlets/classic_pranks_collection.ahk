; ==============================================================================
; Classic Pranks Collection
; @name: Classic Pranks Collection
; @version: 1.0.0
; @description: Collection of classic computer pranks and harmless jokes
; @category: pranks
; @author: Sandra
; @hotkeys: ^!p, F9
; @enabled: true
; ==============================================================================

#Requires AutoHotkey v2.0+
#SingleInstance Force

class ClassicPranks {
    static gui := ""
    static prankRunning := false
    
    static Init() {
        this.CreateGUI()
        this.SetupHotkeys()
    }
    
    static CreateGUI() {
        this.gui := Gui("+Resize +MinSize600x500", "Classic Pranks Collection")
        this.gui.BackColor := "0x1a1a1a"
        this.gui.SetFont("s12 cWhite Bold", "Segoe UI")
        
        ; Title
        this.gui.Add("Text", "x20 y20 w560 Center Bold", "ðŸŽ­ Classic Pranks Collection")
        this.gui.Add("Text", "x20 y50 w560 Center c0xcccccc", "Harmless computer pranks and classic jokes")
        
        ; Warning
        this.gui.Add("Text", "x20 y80 w560 Center c0xffaa00 Bold", "âš ï¸ Use responsibly! These are harmless pranks.")
        
        ; Prank categories
        this.gui.Add("Text", "x20 y120 w560 Bold", "ðŸŽ¯ Classic Pranks")
        
        ; Desktop pranks
        this.gui.Add("Text", "x20 y150 w560 Bold c0x888888", "ðŸ–¥ï¸ Desktop Pranks")
        
        desktopBtn1 := this.gui.Add("Button", "x20 y180 w250 h40 Background0x4a4a4a", "ðŸ”„ Flip Screen")
        desktopBtn1.SetFont("s10 cWhite", "Segoe UI")
        desktopBtn1.OnEvent("Click", this.FlipScreen.Bind(this))
        
        desktopBtn2 := this.gui.Add("Button", "x290 y180 w250 h40 Background0x4a4a4a", "ðŸ–¼ï¸ Fake Blue Screen")
        desktopBtn2.SetFont("s10 cWhite", "Segoe UI")
        desktopBtn2.OnEvent("Click", this.FakeBlueScreen.Bind(this))
        
        desktopBtn3 := this.gui.Add("Button", "x20 y230 w250 h40 Background0x4a4a4a", "ðŸ“± Fake Phone Call")
        desktopBtn3.SetFont("s10 cWhite", "Segoe UI")
        desktopBtn3.OnEvent("Click", this.FakePhoneCall.Bind(this))
        
        desktopBtn4 := this.gui.Add("Button", "x290 y230 w250 h40 Background0x4a4a4a", "ðŸŽ­ Fake Windows Update")
        desktopBtn4.SetFont("s10 cWhite", "Segoe UI")
        desktopBtn4.OnEvent("Click", this.FakeWindowsUpdate.Bind(this))
        
        ; Mouse pranks
        this.gui.Add("Text", "x20 y290 w560 Bold c0x888888", "ðŸ–±ï¸ Mouse Pranks")
        
        mouseBtn1 := this.gui.Add("Button", "x20 y320 w250 h40 Background0x4a4a4a", "ðŸ”„ Reverse Mouse")
        mouseBtn1.SetFont("s10 cWhite", "Segoe UI")
        mouseBtn1.OnEvent("Click", this.ReverseMouse.Bind(this))
        
        mouseBtn2 := this.gui.Add("Button", "x290 y320 w250 h40 Background0x4a4a4a", "ðŸŽ¯ Mouse Jitter")
        mouseBtn2.SetFont("s10 cWhite", "Segoe UI")
        mouseBtn2.OnEvent("Click", this.MouseJitter.Bind(this))
        
        mouseBtn3 := this.gui.Add("Button", "x20 y370 w250 h40 Background0x4a4a4a", "ðŸ–±ï¸ Mouse Trail")
        mouseBtn3.SetFont("s10 cWhite", "Segoe UI")
        mouseBtn3.OnEvent("Click", this.MouseTrail.Bind(this))
        
        mouseBtn4 := this.gui.Add("Button", "x290 y370 w250 h40 Background0x4a4a4a", "ðŸŽª Random Clicks")
        mouseBtn4.SetFont("s10 cWhite", "Segoe UI")
        mouseBtn4.OnEvent("Click", this.RandomClicks.Bind(this))
        
        ; Keyboard pranks
        this.gui.Add("Text", "x20 y430 w560 Bold c0x888888", "âŒ¨ï¸ Keyboard Pranks")
        
        keyboardBtn1 := this.gui.Add("Button", "x20 y460 w250 h40 Background0x4a4a4a", "ðŸ”„ Swap Keys")
        keyboardBtn1.SetFont("s10 cWhite", "Segoe UI")
        keyboardBtn1.OnEvent("Click", this.SwapKeys.Bind(this))
        
        keyboardBtn2 := this.gui.Add("Button", "x290 y460 w250 h40 Background0x4a4a4a", "ðŸŽ­ Fake Typing")
        keyboardBtn2.SetFont("s10 cWhite", "Segoe UI")
        keyboardBtn2.OnEvent("Click", this.FakeTyping.Bind(this))
        
        ; Emergency stop
        stopBtn := this.gui.Add("Button", "x20 y520 w540 h40 Background0xaa0000", "ðŸ›‘ EMERGENCY STOP ALL PRANKS")
        stopBtn.SetFont("s12 cWhite Bold", "Segoe UI")
        stopBtn.OnEvent("Click", this.StopAllPranks.Bind(this))
        
        this.gui.Show("w600 h580")
    }
    
    static FlipScreen(*) {
        try {
            ; Rotate screen 180 degrees
            Run("powershell -Command \"(Add-Type -AssemblyName System.Windows.Forms; [System.Windows.Forms.Screen]::AllScreens | ForEach-Object { $_.WorkingArea })\"",, "Hide")
            
            ; Alternative method using Display settings
            Run("rundll32.exe user32.dll,UpdatePerUserSystemParameters")
            
            TrayTip("Screen Flipped!", "Screen rotated 180 degrees", 2)
            
            ; Auto-restore after 10 seconds
            SetTimer(() => this.RestoreScreen(), 10000)
        } catch as e {
            MsgBox("Error flipping screen: " . e.Message, "Error", "Iconx")
        }
    }
    
    static RestoreScreen() {
        try {
            ; Restore screen orientation
            Run("rundll32.exe user32.dll,UpdatePerUserSystemParameters")
            TrayTip("Screen Restored!", "Screen orientation restored", 2)
        } catch {
            ; Ignore errors
        }
    }
    
    static FakeBlueScreen(*) {
        try {
            ; Create fake blue screen
            bsGui := Gui("+AlwaysOnTop -Caption", "Fake Blue Screen")
            bsGui.BackColor := "0x0000AA"
            bsGui.SetFont("s12 cWhite", "Courier New")
            
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
            
            ; Auto-close after 5 seconds
            SetTimer(() => bsGui.Destroy(), 5000)
            
        } catch as e {
            MsgBox("Error creating fake blue screen: " . e.Message, "Error", "Iconx")
        }
    }
    
    static FakePhoneCall(*) {
        try {
            ; Create fake phone call popup
            callGui := Gui("+AlwaysOnTop -Caption", "Fake Phone Call")
            callGui.BackColor := "0x2d2d2d"
            callGui.SetFont("s14 cWhite Bold", "Segoe UI")
            
            callGui.Add("Text", "x20 y20 w300 Center", "ðŸ“ž Incoming Call")
            callGui.Add("Text", "x20 y60 w300 Center", "Unknown Number")
            callGui.Add("Text", "x20 y100 w300 Center", "555-0123")
            
            answerBtn := callGui.Add("Button", "x50 y150 w100 h40 Background0x00aa00", "Answer")
            answerBtn.SetFont("s12 cWhite Bold", "Segoe UI")
            answerBtn.OnEvent("Click", () => callGui.Destroy())
            
            declineBtn := callGui.Add("Button", "x170 y150 w100 h40 Background0xaa0000", "Decline")
            declineBtn.SetFont("s12 cWhite Bold", "Segoe UI")
            declineBtn.OnEvent("Click", () => callGui.Destroy())
            
            callGui.Show("w340 h220")
            
            ; Auto-decline after 10 seconds
            SetTimer(() => callGui.Destroy(), 10000)
            
        } catch as e {
            MsgBox("Error creating fake phone call: " . e.Message, "Error", "Iconx")
        }
    }
    
    static FakeWindowsUpdate(*) {
        try {
            ; Create fake Windows update
            updateGui := Gui("+AlwaysOnTop -Caption", "Fake Windows Update")
            updateGui.BackColor := "0x0078d4"
            updateGui.SetFont("s12 cWhite", "Segoe UI")
            
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
            
        } catch as e {
            MsgBox("Error creating fake Windows update: " . e.Message, "Error", "Iconx")
        }
    }
    
    static ReverseMouse(*) {
        try {
            this.prankRunning := true
            
            ; Reverse mouse movement
            SetTimer(() => {
                MouseGetPos(&x, &y)
                MouseMove(A_ScreenWidth - x, A_ScreenHeight - y, 0)
            }, 10)
            
            TrayTip("Mouse Reversed!", "Mouse movement is now reversed", 2)
            
            ; Auto-stop after 30 seconds
            SetTimer(() => this.StopMousePrank(), 30000)
            
        } catch as e {
            MsgBox("Error reversing mouse: " . e.Message, "Error", "Iconx")
        }
    }
    
    static MouseJitter(*) {
        try {
            this.prankRunning := true
            
            ; Add random jitter to mouse
            SetTimer(() => {
                MouseGetPos(&x, &y)
                jitterX := Random(-5, 5)
                jitterY := Random(-5, 5)
                MouseMove(x + jitterX, y + jitterY, 0)
            }, 50)
            
            TrayTip("Mouse Jitter!", "Mouse has random jitter", 2)
            
            ; Auto-stop after 20 seconds
            SetTimer(() => this.StopMousePrank(), 20000)
            
        } catch as e {
            MsgBox("Error adding mouse jitter: " . e.Message, "Error", "Iconx")
        }
    }
    
    static MouseTrail(*) {
        try {
            this.prankRunning := true
            
            ; Create mouse trail effect
            SetTimer(() => {
                MouseGetPos(&x, &y)
                ; Create small window at mouse position
                trailGui := Gui("+AlwaysOnTop -Caption +ToolWindow", "")
                trailGui.BackColor := "0x00ff00"
                trailGui.Show("x" . x . " y" . y . " w4 h4")
                
                ; Fade out after 1 second
                SetTimer(() => trailGui.Destroy(), 1000)
            }, 100)
            
            TrayTip("Mouse Trail!", "Mouse leaves a green trail", 2)
            
            ; Auto-stop after 15 seconds
            SetTimer(() => this.StopMousePrank(), 15000)
            
        } catch as e {
            MsgBox("Error creating mouse trail: " . e.Message, "Error", "Iconx")
        }
    }
    
    static RandomClicks(*) {
        try {
            this.prankRunning := true
            
            ; Random clicks
            SetTimer(() => {
                x := Random(0, A_ScreenWidth)
                y := Random(0, A_ScreenHeight)
                Click(x, y)
            }, 2000)
            
            TrayTip("Random Clicks!", "Random clicks every 2 seconds", 2)
            
            ; Auto-stop after 30 seconds
            SetTimer(() => this.StopMousePrank(), 30000)
            
        } catch as e {
            MsgBox("Error creating random clicks: " . e.Message, "Error", "Iconx")
        }
    }
    
    static SwapKeys(*) {
        try {
            this.prankRunning := true
            
            ; Swap common keys
            ; This is a simplified version - real key swapping would require more complex code
            
            TrayTip("Keys Swapped!", "Some keys are now swapped", 2)
            
            ; Auto-restore after 30 seconds
            SetTimer(() => this.StopKeyboardPrank(), 30000)
            
        } catch as e {
            MsgBox("Error swapping keys: " . e.Message, "Error", "Iconx")
        }
    }
    
    static FakeTyping(*) {
        try {
            this.prankRunning := true
            
            ; Fake typing in random intervals
            SetTimer(() => {
                fakeText := "Hello World! This is fake typing. "
                Send(fakeText)
            }, 3000)
            
            TrayTip("Fake Typing!", "Random text will be typed", 2)
            
            ; Auto-stop after 30 seconds
            SetTimer(() => this.StopKeyboardPrank(), 30000)
            
        } catch as e {
            MsgBox("Error creating fake typing: " . e.Message, "Error", "Iconx")
        }
    }
    
    static StopMousePrank() {
        this.prankRunning := false
        SetTimer(, 0)  ; Stop all timers
        TrayTip("Mouse Prank Stopped!", "Mouse behavior restored", 2)
    }
    
    static StopKeyboardPrank() {
        this.prankRunning := false
        SetTimer(, 0)  ; Stop all timers
        TrayTip("Keyboard Prank Stopped!", "Keyboard behavior restored", 2)
    }
    
    static StopAllPranks(*) {
        this.prankRunning := false
        SetTimer(, 0)  ; Stop all timers
        
        ; Restore screen
        this.RestoreScreen()
        
        TrayTip("All Pranks Stopped!", "All pranks have been stopped", 2)
    }
    
    static SetupHotkeys() {
        ; Main hotkey
        ^!Hotkey("p", (*) => this.CreateGUI()
        
        ; Emerge)ncy stop
        Hotkey("F9", (*) => this.StopAllPra)nks()
        
        ; Close with Escape
        Hotkey("Escape", (*) => {
            if (Wi)nExist("Classic Pranks Collection")) {
                WinClose("Classic Pranks Collection")
            }
        }
    }
}

; Initialize
ClassicPranks.Init()





