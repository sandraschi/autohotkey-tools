#Requires AutoHotkey v2.0+
#SingleInstance Force

; Frogger v2: GDI+ rendering via lib\GdipHelper (backbuffer + BitBlt).
; Game logic (lanes/tick/collision/score) unchanged from the ASCII version.
_CatchBootError(Thrown, Mode) {
    msg := Thrown && HasProp(Thrown, "Message") ? Thrown.Message : "Unknown"
    try FileAppend("[" A_Now "] frogger: " msg "`n", A_ScriptDir "\frogger_crash.log")
    return 1
}
OnError(_CatchBootError)

#Include %A_ScriptDir%\lib\ScriptletErrorHandler.ahk
#Include %A_ScriptDir%\lib\GdipHelper.ahk
OnError(LogError)

class F {
    static g := 0
    static pic := 0
    static bc := 0
    static sc := 0
    static st := 0
    static b1 := 0
    static b2 := 0
    static b3 := 0
    static fn := 0
    static r := false
    static fx := 4
    static fy := 6
    static score := 0
    static frame := 0
    static cars := []
    static gfx := 0
    static bmp := 0
    static br := {}
    static pen := 0
    static CW := 44
    static CH := 44
    static BW := 396
    static BH := 308
    static lanes := [{s:400,d:1,p:[0,3,6]},{s:520,d:-1,p:[2,5]},{s:460,d:1,p:[1,4,7]},{s:540,d:-1,p:[0,6]},{s:480,d:1,p:[3]},{s:500,d:-1,p:[1,5]}]
    static B := 9
    static H := 7

    static Init() {
        g := Gui("+AlwaysOnTop +Resize +MinSize560x400", "Frogger")
        g.BackColor := "131320"
        g.SetFont("s10", "Segoe UI")
        F.pic := g.Add("Picture", "x10 y10 w396 h308", "")
        F.sc := g.Add("Text", "x416 y10 w110 Center cFFFFFF", "Score: 0")
        F.b1 := g.Add("Button", "x416 y50 w110 h30", "Start")
        F.b2 := g.Add("Button", "x416 y90 w110 h30", "Pause")
        F.b3 := g.Add("Button", "x416 y130 w110 h30", "Reset")
        F.st := g.Add("Text", "x10 y330 w516 h24 cGray Center", "Ready")
        F.b1.OnEvent("Click", (*) => F.Start())
        F.b2.OnEvent("Click", (*) => F.Pause())
        F.b3.OnEvent("Click", (*) => F.Reset())
        g.OnEvent("Close", (*) => F.Quit())
        F.g := g
        g.Show("w540 h390")
        F.SetupGfx()
        F.Reset()
        HotIf((*) => WinActive("ahk_id " . F.g.Hwnd))
        Hotkey("Up", (*) => F.Move(0, -1))
        Hotkey("Down", (*) => F.Move(0, 1))
        Hotkey("Left", (*) => F.Move(-1, 0))
        Hotkey("Right", (*) => F.Move(1, 0))
        HotIf()
    }

    static SetupGfx() {
        GdipHelper.Startup()
        F.bmp := GdipHelper.CreateBitmap(F.BW, F.BH)
        F.gfx := GdipHelper.GraphicsFromImage(F.bmp)
        GdipHelper.SetSmoothingMode(F.gfx, 4)
        mk := (c) => GdipHelper.BrushCreateSolid(c)
        F.br := Map(
            "roadA", mk(0xFF23232E), "roadB", mk(0xFF1E1E26),
            "dash", mk(0xFF8A7B2D), "goal", mk(0xFF2E7D32),
            "goalSlot", mk(0xFF1B3A24), "home", mk(0xFF191920),
            "frog", mk(0xFF4CAF50), "frogBelly", mk(0xFF81C784),
            "eyeW", mk(0xFFFFFFFF), "pupil", mk(0xFF111111),
            "carR", mk(0xFFE74C3C), "carRTop", mk(0xFFFF8A75),
            "carL", mk(0xFF3498DB), "carLTop", mk(0xFF6FB7FF),
            "glass", mk(0xFF222831), "tire", mk(0xFF0D0D0D),
            "light", mk(0xFFFFEB3B))
        F.pen := GdipHelper.PenCreate(0xFF000000, 2)
    }

    static Quit() {
        try {
            for _, b in F.br {
                GdipHelper.DeleteBrush(b)
            }
            F.br := {}
            if (F.pen) {
                GdipHelper.DisposePen(F.pen)
                F.pen := 0
            }
            if (F.gfx) {
                GdipHelper.DisposeGraphics(F.gfx)
                F.gfx := 0
            }
            if (F.bmp) {
                GdipHelper.DisposeImage(F.bmp)
                F.bmp := 0
            }
            GdipHelper.Shutdown()
        } catch {
        }
        ExitApp()
    }

    static Start() {
        if (F.r) {
            return
        }
        F.r := true
        F.fn := (*) => F.Tick()
        SetTimer(F.fn, 200)
        F.st.Text := "Running"
    }

    static Pause() {
        if (F.r) {
            SetTimer(F.fn, 0)
            F.r := false
            F.fn := 0
            F.st.Text := "Paused"
        }
    }

    static Reset() {
        F.Pause()
        F.fx := 4
        F.fy := 6
        F.score := 0
        F.cars := []
        for _, l in F.lanes {
            p := []
            for _, x in l.p {
                p.Push(x)
            }
            F.cars.Push({p: p, t: 0})
        }
        F.Draw()
        F.sc.Text := "Score: 0"
        F.st.Text := "Press Start"
    }

    static Tick() {
        F.frame++
        for i, ld in F.cars {
            l := F.lanes[i]
            ld.t := ld.t + 200
            if (ld.t < l.s) {
                continue
            }
            ld.t := 0
            np := []
            for _, x in ld.p {
                n := x + l.d
                if (n < 0) {
                    n := F.B - 1
                }
                if (n >= F.B) {
                    n := 0
                }
                np.Push(n)
            }
            ld.p := np
        }
        if (F.fy >= 1) and (F.fy <= F.cars.Length) {
            cl := F.cars[F.fy]
            if (cl.p.Has(F.fx)) {
                F.Pause()
                F.st.Text := "Hit! Reset"
                return
            }
        }
        F.Draw()
    }

    static Move(dx, dy) {
        nx := F.fx + dx
        ny := F.fy + dy
        if (nx < 0) or (nx >= F.B) or (ny < 0) or (ny >= F.H) {
            return
        }
        F.fx := nx
        F.fy := ny
        if (ny = 0) {
            F.score := F.score + 100
            F.sc.Text := "Score: " F.score
            F.ResetCars()
            F.fx := 4
            F.fy := 6
        }
        F.Tick()
    }

    static ResetCars() {
        F.cars := []
        for _, l in F.lanes {
            p := []
            for _, x in l.p {
                p.Push(x)
            }
            F.cars.Push({p: p, t: 0})
        }
    }

    static Draw() {
        g := F.gfx
        if (!g) {
            return
        }
        cw := F.CW
        ch := F.CH
        GdipHelper.Clear(g, 0xFF14141C)
        ; Lanes: goal strip, animated roads, home strip.
        off := Mod(F.frame * 6, 26)
        Loop F.H {
            ri := A_Index - 1
            y := ri * ch
            if (ri = 0) {
                GdipHelper.FillRectangle(g, F.br["goal"], 0, y, F.BW, ch)
                for gx in [0, 2, 4, 6, 8] {
                    GdipHelper.FillRectangle(g, F.br["goalSlot"], gx * cw + 4, y + 4, cw - 8, ch - 8)
                }
            } else if (ri = F.H - 1) {
                GdipHelper.FillRectangle(g, F.br["home"], 0, y, F.BW, ch)
            } else {
                GdipHelper.FillRectangle(g, F.br[Mod(ri, 2) ? "roadA" : "roadB"], 0, y, F.BW, ch)
                x := -26 + off
                while (x < F.BW) {
                    GdipHelper.FillRectangle(g, F.br["dash"], x, y + ch // 2 - 2, 13, 4)
                    x += 26
                }
            }
        }
        ; Cars (one per occupied cell).
        for i, ld in F.cars {
            dir := F.lanes[i].d
            body := dir = 1 ? F.br["carR"] : F.br["carL"]
            top := dir = 1 ? F.br["carRTop"] : F.br["carLTop"]
            for _, x in ld.p {
                F.DrawCar(g, x * cw, i * ch, dir, body, top)
            }
        }
        ; Frog.
        F.DrawFrog(g, F.fx * cw, F.fy * ch)
        GdipHelper.UpdatePicture(F.pic, F.bmp, F.BW, F.BH)
    }

    static DrawCar(g, bx, by, dir, body, top) {
        cw := F.CW
        ch := F.CH
        ; Tires.
        GdipHelper.FillRectangle(g, F.br["tire"], bx + 6, by + 6, 9, 5)
        GdipHelper.FillRectangle(g, F.br["tire"], bx + cw - 15, by + 6, 9, 5)
        GdipHelper.FillRectangle(g, F.br["tire"], bx + 6, by + ch - 11, 9, 5)
        GdipHelper.FillRectangle(g, F.br["tire"], bx + cw - 15, by + ch - 11, 9, 5)
        ; Body + roof + windshield at the front.
        GdipHelper.FillRectangle(g, body, bx + 3, by + 10, cw - 6, 24)
        GdipHelper.FillRectangle(g, top, bx + 3, by + 10, cw - 6, 8)
        if (dir = 1) {
            GdipHelper.FillRectangle(g, F.br["glass"], bx + cw - 13, by + 14, 8, 12)
            GdipHelper.FillRectangle(g, F.br["light"], bx + cw - 5, by + 12, 3, 5)
            GdipHelper.FillRectangle(g, F.br["light"], bx + cw - 5, by + 27, 3, 5)
        } else {
            GdipHelper.FillRectangle(g, F.br["glass"], bx + 5, by + 14, 8, 12)
            GdipHelper.FillRectangle(g, F.br["light"], bx + 2, by + 12, 3, 5)
            GdipHelper.FillRectangle(g, F.br["light"], bx + 2, by + 27, 3, 5)
        }
        GdipHelper.DrawRectangle(g, F.pen, bx + 3, by + 10, cw - 6, 24)
    }

    static DrawFrog(g, bx, by) {
        cw := F.CW
        ch := F.CH
        ; Body + belly.
        GdipHelper.FillEllipse(g, F.br["frog"], bx + 7, by + 7, cw - 14, ch - 14)
        GdipHelper.FillEllipse(g, F.br["frogBelly"], bx + 13, by + 16, cw - 26, ch - 26)
        ; Eyes on top.
        GdipHelper.FillEllipse(g, F.br["eyeW"], bx + 11, by + 4, 10, 10)
        GdipHelper.FillEllipse(g, F.br["eyeW"], bx + cw - 21, by + 4, 10, 10)
        GdipHelper.FillEllipse(g, F.br["pupil"], bx + 14, by + 7, 4, 4)
        GdipHelper.FillEllipse(g, F.br["pupil"], bx + cw - 18, by + 7, 4, 4)
    }
}

F.Init()
