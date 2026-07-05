#Requires AutoHotkey v2.0+
#SingleInstance Force

#Include %A_ScriptDir%\lib\GdipHelper.ahk
#Include %A_ScriptDir%\lib\ScriptletErrorHandler.ahk
OnError(LogError)

; ==============================================================================
; Classic Pong Game — GDI+ rendering
; ==============================================================================

class PongApp {
    static g := ""
    static boardCtrl := ""
    static statusCtrl := ""
    static scoreCtrl := ""

    ; GDI+ resources
    static pBitmap := 0
    static pGraphics := 0
    static brushBg := 0
    static brushLime := 0
    static brushWhite := 0
    static brushDotted := 0
    static brushGray := 0

    ; Board dimensions (pixels)
    static bw := 600
    static bh := 350
    static paddleW := 8
    static paddleH := 60
    static ballR := 7
    static margin := 20

    ; Game state (pixel coords)
    static leftY := 0.0
    static rightY := 0.0
    static ball := {x: 0.0, y: 0.0, dx: 4.0, dy: 3.5}
    static score := {left: 0, right: 0}
    static running := false
    static tickFn := 0

    static Init() {
        GdipHelper.Startup()
        PongApp.CreateBrushes()
        PongApp.CreateGui()
        PongApp.SetupHotkeys()
        PongApp.ResetMatch()
    }

    static CreateBrushes() {
        PongApp.brushBg     := GdipHelper.BrushCreateSolid(0xFF111118)
        PongApp.brushLime   := GdipHelper.BrushCreateSolid(0xFF00DD44)
        PongApp.brushWhite  := GdipHelper.BrushCreateSolid(0xFFFFFFFF)
        PongApp.brushGray   := GdipHelper.BrushCreateSolid(0xFF333340)
    }

    static CreateGui() {
        if (PongApp.g)
            PongApp.g.Destroy()
        PongApp.pBitmap := GdipHelper.CreateBitmap(PongApp.bw, PongApp.bh)
        PongApp.pGraphics := GdipHelper.GraphicsFromImage(PongApp.pBitmap)
        GdipHelper.SetSmoothingMode(PongApp.pGraphics, 4)

        newGui := Gui("+Resize +MinSize660x480", "Classic Pong")
        newGui.BackColor := "0C0C10"
        newGui.SetFont("s10 cCCCCCC", "Segoe UI")

        newGui.Add("Text", "x20 y12 w260 Center", "Pong — keep the ball in play!")
        PongApp.boardCtrl := newGui.Add("Picture", "x20 y44 w600 h350")
        PongApp.scoreCtrl := newGui.Add("Text", "x640 y60 w100 h40 cFFFFFF Center", "0 : 0")

        btnStart := newGui.Add("Button", "x640 y110 w100 h32", "Start")
        btnStart.OnEvent("Click", (*) => PongApp.StartGame())
        btnPause := newGui.Add("Button", "x640 y150 w100 h32", "Pause")
        btnPause.OnEvent("Click", (*) => PongApp.PauseGame())
        btnReset := newGui.Add("Button", "x640 y190 w100 h32", "Reset")
        btnReset.OnEvent("Click", (*) => PongApp.ResetMatch())
        btnClose := newGui.Add("Button", "x640 y230 w100 h32", "Close")
        btnClose.OnEvent("Click", (*) => PongApp.HideGui())

        PongApp.statusCtrl := newGui.Add("Text", "x20 y400 w620 h24 cAAAAAA", "Use W/S or arrow keys. Space=Start  P=Pause  R=Reset")

        newGui.OnEvent("Close", PongApp.HideGui)
        newGui.OnEvent("Escape", PongApp.HideGui)

        PongApp.g := newGui
        newGui.Show("w760 h460")
    }

    static SetupHotkeys() {
        static registered := false
        if (registered)
            return
        Hotkey("^!p", (*) => PongApp.ShowGui())
        PongApp.RegisterGameHotkeys()
        registered := true
    }

    static RegisterGameHotkeys() {
        ; Use HotIf so keys pass through when Pong isn't focused
        HotIf((*) => WinActive("ahk_id " . PongApp.g.Hwnd))
        Hotkey("w",       (*) => PongApp.MovePaddle(-8))
        Hotkey("s",       (*) => PongApp.MovePaddle(8))
        Hotkey("Up",      (*) => PongApp.MovePaddle(-8))
        Hotkey("Down",    (*) => PongApp.MovePaddle(8))
        Hotkey("Space",   (*) => PongApp.StartGame())
        Hotkey("p",       (*) => PongApp.PauseGame())
        Hotkey("r",       (*) => PongApp.ResetMatch())
        HotIf()
    }

    static ShowGui(*) {
        if (PongApp.g) {
            PongApp.g.Show()
            WinActivate(PongApp.g.Hwnd)
        } else {
            PongApp.Init()
        }
    }

    ; --- Game Logic ---

    static ResetMatch() {
        PongApp.PauseGame()
        PongApp.score := {left: 0, right: 0}
        PongApp.ResetRound()
        PongApp.UpdateScore()
        PongApp.UpdateStatus("Press Space or Start to serve.")
    }

    static ResetRound() {
        ch := PongApp.bh - PongApp.paddleH
        PongApp.leftY := ch / 2.0
        PongApp.rightY := ch / 2.0
        PongApp.ball := {x: PongApp.bw / 2.0, y: PongApp.bh / 2.0, dx: 4.0, dy: (Random(0,1) ? 3.5 : -3.5)}
        PongApp.Render()
    }

    static StartGame(*) {
        if (PongApp.running)
            return
        PongApp.running := true
        PongApp.tickFn := (*) => PongApp.Tick()
        SetTimer(PongApp.tickFn, 16)  ; ~60 fps
        PongApp.UpdateStatus("Running — W/S or arrows to move.")
    }

    static PauseGame(*) {
        if (PongApp.running) {
            SetTimer(PongApp.tickFn, 0)
            PongApp.running := false
            PongApp.tickFn := 0
            PongApp.UpdateStatus("Paused.")
        }
    }

    static HideGui(*) {
        PongApp.PauseGame()
        if (PongApp.g)
            PongApp.g.Hide()
    }

    static MovePaddle(dy) {
        ch := PongApp.bh - PongApp.paddleH
        PongApp.leftY := Max(0.0, Min(Float(ch), PongApp.leftY + dy))
        PongApp.Render()
    }

    static Tick() {
        PongApp.MoveBall()
        PongApp.AutoMoveOpponent()
        PongApp.Render()
    }

    static AutoMoveOpponent() {
        target := PongApp.ball.y - PongApp.paddleH / 2.0
        ch := PongApp.bh - PongApp.paddleH
        PongApp.rightY += (target - PongApp.rightY) * 0.08
        PongApp.rightY := Max(0.0, Min(Float(ch), PongApp.rightY))
    }

    static MoveBall() {
        nx := PongApp.ball.x + PongApp.ball.dx
        ny := PongApp.ball.y + PongApp.ball.dy

        ; Wall bounce (top/bottom)
        if (ny - PongApp.ballR < 0) {
            PongApp.ball.dy := Abs(PongApp.ball.dy)
            ny := PongApp.ballR
        } else if (ny + PongApp.ballR > PongApp.bh) {
            PongApp.ball.dy := -Abs(PongApp.ball.dy)
            ny := PongApp.bh - PongApp.ballR
        }

        ; Left paddle collision
        px := PongApp.margin
        if (nx - PongApp.ballR <= px + PongApp.paddleW && PongApp.ball.dx < 0) {
            if (ny >= PongApp.leftY && ny <= PongApp.leftY + PongApp.paddleH) {
                PongApp.ball.dx := Abs(PongApp.ball.dx) * 1.02
                nx := px + PongApp.paddleW + PongApp.ballR
                PongApp.ball.dy += (ny - (PongApp.leftY + PongApp.paddleH/2)) * 0.15
            }
        }

        ; Right paddle collision
        px := PongApp.bw - PongApp.margin - PongApp.paddleW
        if (nx + PongApp.ballR >= px && PongApp.ball.dx > 0) {
            if (ny >= PongApp.rightY && ny <= PongApp.rightY + PongApp.paddleH) {
                PongApp.ball.dx := -Abs(PongApp.ball.dx) * 1.02
                nx := px - PongApp.ballR
                PongApp.ball.dy += (ny - (PongApp.rightY + PongApp.paddleH/2)) * 0.15
            }
        }

        PongApp.ball.x := nx
        PongApp.ball.y := ny

        ; Score
        if (PongApp.ball.x + PongApp.ballR < 0)
            PongApp.ScorePoint("right")
        else if (PongApp.ball.x - PongApp.ballR > PongApp.bw)
            PongApp.ScorePoint("left")
    }

    static ScorePoint(side) {
        PongApp.score[side] += 1
        PongApp.UpdateScore()
        PongApp.ResetRound()
        PongApp.UpdateStatus(side = "left" ? "You scored!" : "AI scored.")
    }

    ; --- GDI+ Rendering ---

    static Render() {
        g := PongApp.pGraphics

        ; Clear background
        GdipHelper.Clear(g, 0xFF0A0A12)

        ; Center line (dotted)
        cx := PongApp.bw / 2.0
        loop 18 {
            y := (A_Index - 1) * 20.0 + 3
            GdipHelper.FillRectangle(g, PongApp.brushGray, cx - 1, y, 2, 14)
        }

        ; Left paddle (rounded via two halves)
        px := PongApp.margin
        py := PongApp.leftY
        pw := PongApp.paddleW
        ph := PongApp.paddleH
        GdipHelper.FillRectangle(g, PongApp.brushLime, px, py + 4, pw, ph - 8)
        r := pw / 2.0
        GdipHelper.FillEllipse(g, PongApp.brushLime, px, py, pw, 2*r)
        GdipHelper.FillEllipse(g, PongApp.brushLime, px, py + ph - 2*r, pw, 2*r)

        ; Right paddle
        px := PongApp.bw - PongApp.margin - pw
        py := PongApp.rightY
        GdipHelper.FillRectangle(g, PongApp.brushLime, px, py + 4, pw, ph - 8)
        GdipHelper.FillEllipse(g, PongApp.brushLime, px, py, pw, 2*r)
        GdipHelper.FillEllipse(g, PongApp.brushLime, px, py + ph - 2*r, pw, 2*r)

        ; Ball
        bx := PongApp.ball.x - PongApp.ballR
        by := PongApp.ball.y - PongApp.ballR
        bd := PongApp.ballR * 2
        GdipHelper.FillEllipse(g, PongApp.brushWhite, bx, by, bd, bd)

        ; Push to GUI
        GdipHelper.UpdatePicture(PongApp.boardCtrl, PongApp.pBitmap, PongApp.bw, PongApp.bh)
    }

    static UpdateScore() {
        if (PongApp.scoreCtrl)
            PongApp.scoreCtrl.Text := Format("{} : {}", PongApp.score.left, PongApp.score.right)
    }

    static UpdateStatus(msg) {
        if (PongApp.statusCtrl)
            PongApp.statusCtrl.Text := msg
    }
}

PongApp.Init()
