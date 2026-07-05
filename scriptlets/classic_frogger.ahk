#Requires AutoHotkey v2.0+
#SingleInstance Force
OnError((*) => 1)

class F {
    static g := 0
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
    static cars := []
    static lanes := [{s:400,d:1,p:[0,3,6]},{s:520,d:-1,p:[2,5]},{s:460,d:1,p:[1,4,7]},{s:540,d:-1,p:[0,6]},{s:480,d:1,p:[3]},{s:500,d:-1,p:[1,5]}]
    static B := 9
    static H := 7

    static Init() {
        g := Gui("+AlwaysOnTop +Resize", "Frogger")
        g.BackColor := "131320"
        g.SetFont("s10", "Segoe UI")
        g.Add("Text", "x10 y10 w280 cWhite Center", "Frogger")
        F.bc := g.Add("Text", "x10 y40 w200 h200 Background000000 Border", "")
        F.bc.SetFont("s11 cLime", "Consolas")
        F.sc := g.Add("Text", "x220 y40 w100 cWhite", "Score: 0")
        F.b1 := g.Add("Button", "x220 y80 w80 h28", "Start")
        F.b2 := g.Add("Button", "x220 y120 w80 h28", "Pause")
        F.b3 := g.Add("Button", "x220 y160 w80 h28", "Reset")
        F.st := g.Add("Text", "x10 y260 w300 cGray Center", "Ready")
        F.b1.OnEvent("Click", (*) => F.Start())
        F.b2.OnEvent("Click", (*) => F.Pause())
        F.b3.OnEvent("Click", (*) => F.Reset())
        g.OnEvent("Close", (*) => ExitApp())
        F.g := g
        g.Show("w310 h290")
        F.Reset()
        HotIf((*) => WinActive("ahk_id " . F.g.Hwnd))
        Hotkey("Up", (*) => F.Move(0, -1))
        Hotkey("Down", (*) => F.Move(0, 1))
        Hotkey("Left", (*) => F.Move(-1, 0))
        Hotkey("Right", (*) => F.Move(1, 0))
        HotIf()
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
        s := ""
        Loop F.H {
            ri := A_Index - 1
            Loop F.B {
                ci := A_Index - 1
                if (ri = F.fy) and (ci = F.fx) {
                    s .= "F"
                } else if (ri = 0) {
                    s .= "G"
                } else if (ri = F.H - 1) {
                    s .= "."
                } else {
                    if (F.cars[ri].p.Has(ci)) {
                        s .= "C"
                    } else {
                        s .= "."
                    }
                }
            }
            if (ri < F.H - 1) {
                s .= "`n"
            }
        }
        F.bc.Text := s
    }
}

F.Init()
