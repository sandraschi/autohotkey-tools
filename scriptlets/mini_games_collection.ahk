; ==============================================================================
; Mini Games Collection
; @name: Mini Games Collection
; @version: 1.0.0
; @description: Collection of fun mini-games including Snake, Tetris, and Memory. Quick-access entertainment games for breaks and leisure time.
; @description: Features classic arcade-style games with simple controls and addictive gameplay. Includes Snake, Tetris, and Memory card matching games with score tracking.
; @description: Perfect for short gaming sessions during breaks with nostalgic gameplay and easy-to-learn mechanics.
; @category: games
; @author: Sandra
; @hotkeys: ^!g, #s, #t, #m
; @enabled: true
; @priority: 80
; @tag: games, mini-games, snake, tetris, memory, entertainment, arcade, retro
; @cli: --game <name> - Launch specific game (snake, tetris, memory)
; @cli: --help - Show CLI usage and game options
; @dependencies: 
; ==============================================================================

#Requires AutoHotkey v2.0+
#SingleInstance Force
#Include %A_ScriptDir%\lib\ScriptletErrorHandler.ahk

OnError(LogError)

class MiniArcade {
    static gui := ""
    static statusCtrl := ""
    static reactionStart := 0
    static guessTarget := 0
    static guessCtrl := ""

    static Init() {
        MiniArcade.CreateGui()
        MiniArcade.SetupHotkeys()
    }

    static HandleError(Thrown, Mode) {
        message := "MiniArcade error: " . Thrown.Message . " at line " . Thrown.Line
        try FileAppend(message . "`n", "mini_games_collection_errors.log", "UTF-8")
        OutputDebug(message)
        return 1
    }

    static CreateGui() {
        if (MiniArcade.gui) {
            MiniArcade.gui.Destroy()
        }
        newGui := Gui("+Resize +MinSize360x280", "Mini Games Collection")
        newGui.BackColor := "1e1e1e"
        newGui.SetFont("s10", "Segoe UI")

        newGui.AddText("x20 y16 w320 Center cFFFFFF", "Mini Games Collection – quick break fun")

        reactionBtn := newGui.AddButton("x40 y56 w120 h48", "⚡ Reaction Timer")
        reactionBtn.OnEvent("Click", (*) => MiniArcade.StartReactionTimer())

        guessBtn := newGui.AddButton("x200 y56 w120 h48", "🎯 Number Guess")
        guessBtn.OnEvent("Click", (*) => MiniArcade.StartGuessGame())

        info := "Instructions:`n" . "• Reaction Timer: press 'Start' then 'Stop' as quickly as possible.`n" . "• Number Guess: choose a number 1-20 and check the answer.`n" . "• Use Ctrl+Alt+G to open this menu, Ctrl+Alt+Q to close." 
        newGui.AddText("x20 y120 w320 h100 cFFFFFF", info)

        MiniArcade.statusCtrl := newGui.AddText("x20 y230 w320 h24 cFFFFFF", "Select a mini game to begin.")

        newGui.OnEvent("Close", MiniArcade.HideGui)
        newGui.OnEvent("Escape", MiniArcade.HideGui)
        newGui.OnEvent("Size", MiniArcade.OnResize)

        MiniArcade.gui := newGui
        newGui.Show("w360 h260")
    }

    static SetupHotkeys() {
        static registered := false
        if (registered) {
            return
        }
        Hotkey("^!g", (*) => MiniArcade.ShowGui())
        Hotkey("^!q", (*) => MiniArcade.HideGui())
        registered := true
    }

    static ShowGui() {
        if (!MiniArcade.gui) {
            MiniArcade.CreateGui()
        }
        MiniArcade.gui.Show()
        MiniArcade.UpdateStatus("Menu opened.")
    }

    static HideGui(*) {
        if (MiniArcade.gui) {
            MiniArcade.gui.Hide()
            MiniArcade.UpdateStatus("Menu hidden.")
        }
    }

    ; --- Reaction Timer ---
    static StartReactionTimer() {
        dlg := Gui("+Owner" . MiniArcade.gui.Hwnd, "Reaction Timer")
        dlg.BackColor := "202020"
        dlg.SetFont("s11", "Segoe UI")
        dlg.AddText("w280 h24 cFFFFFF", "Click 'Start' then stop as soon as color changes.")
        indicator := dlg.AddText("x20 y40 w280 h80 Center BackgroundFF4444 cFFFFFF", "Waiting ...")
        resultCtrl := dlg.AddText("x20 y130 w280 h24 cFFFFFF", "")
        startBtn := dlg.AddButton("x60 y170 w80 h30", "Start")
        stopBtn := dlg.AddButton("x160 y170 w80 h30", "Stop")
        stopBtn.Enabled := false

        startBtn.OnEvent("Click", MiniArcade.ReactionStart.Bind(MiniArcade, indicator, startBtn, stopBtn))
        stopBtn.OnEvent("Click", MiniArcade.ReactionStop.Bind(MiniArcade, indicator, startBtn, stopBtn, resultCtrl))

        dlg.OnEvent("Close", (*) => dlg.Destroy())
        dlg.Show("w320 h220")
    }

    static ReactionStart(indicator, startBtn, stopBtn, *) {
        indicator.Opt("Background44FF44")
        indicator.Text := "GO!"
        MiniArcade.reactionStart := A_TickCount
        startBtn.Enabled := false
        stopBtn.Enabled := true
    }

    static ReactionStop(indicator, startBtn, stopBtn, resultCtrl, *) {
        if (!MiniArcade.reactionStart) {
            return
        }
        elapsed := A_TickCount - MiniArcade.reactionStart
        resultCtrl.Text := "Reaction time: " . elapsed . " ms"
        MiniArcade.UpdateStatus("Reaction recorded: " . elapsed . " ms")
        startBtn.Enabled := true
        stopBtn.Enabled := false
        indicator.Opt("BackgroundFFAA00")
        indicator.Text := "Round complete"
        MiniArcade.reactionStart := 0
    }

    ; --- Number Guess ---
    static StartGuessGame() {
        dlg := Gui("+Owner" . MiniArcade.gui.Hwnd, "Number Guess")
        dlg.BackColor := "202020"
        dlg.SetFont("s11", "Segoe UI")
        dlg.AddText("x20 y16 w260 h24 cFFFFFF", "Pick a number between 1 and 20")
        slider := dlg.AddSlider("x20 y48 w260 Range1-20 TickInterval1", 10)
        valueText := dlg.AddText("x20 y80 w260 h24 Center cFFFFFF", "Current guess: 10")
        slider.OnEvent("Change", MiniArcade.UpdateGuessDisplay.Bind(MiniArcade, slider, valueText))
        Random(&target, 1, 20)
        MiniArcade.guessTarget := target
        checkBtn := dlg.AddButton("x60 y120 w80 h30", "Check")
        resetBtn := dlg.AddButton("x160 y120 w80 h30", "New #")
        resultCtrl := dlg.AddText("x20 y170 w260 h24 Center cFFFFFF", "")

        checkBtn.OnEvent("Click", MiniArcade.CheckGuess.Bind(MiniArcade, slider, resultCtrl))
        resetBtn.OnEvent("Click", MiniArcade.ResetGuess.Bind(MiniArcade, resultCtrl))

        dlg.OnEvent("Close", (*) => dlg.Destroy())
        dlg.Show("w300 h210")
    }

    static UpdateGuessDisplay(slider, valueText, *) {
        valueText.Text := "Current guess: " . slider.Value
    }

    static CheckGuess(slider, resultCtrl, *) {
        guess := slider.Value
        if (guess = MiniArcade.guessTarget) {
            resultCtrl.Text := "🎉 Correct!"
            MiniArcade.UpdateStatus("Correct guess: " . guess)
        } else if (guess < MiniArcade.guessTarget) {
            resultCtrl.Text := "Too low."
        } else {
            resultCtrl.Text := "Too high."
        }
    }

    static ResetGuess(resultCtrl, *) {
        Random(&target, 1, 20)
        MiniArcade.guessTarget := target
        resultCtrl.Text := "New number chosen."
        MiniArcade.UpdateStatus("Guess number reset.")
    }

    static UpdateStatus(message) {
        if (MiniArcade.statusCtrl) {
            MiniArcade.statusCtrl.Text := message
        }
    }

    static OnResize(gui, minMax, width, height) {
        if (MiniArcade.statusCtrl) {
            MiniArcade.statusCtrl.Move(20, height - 40, width - 40, 24)
        }
    }
}

MiniArcade.Init()

OnExit((*) => MiniArcade.UpdateStatus(""))




