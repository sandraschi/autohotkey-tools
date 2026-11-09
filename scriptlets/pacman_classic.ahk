; ==============================================================================
; Pacman Classic
; @name: Pacman Classic
; @version: 2.0.0
; @description: Classic Pacman arcade game with ghosts and dots. Real-time maze chase rendered with GDI+ (no ASCII): walled maze, dot pellets, chomping Pac-Man, eyed ghosts.
; @description: Features dot collection, 2 ghost AI chasers, 3 lives, level speed-up, and score tracking. Arrow keys move, Space starts, P pauses, R resets.
; @category: games
; @author: Sandra
; @hotkeys: Arrow keys, Space, P, R
; @enabled: true
; @priority: 75
; @tag: pacman, game, arcade, classic, retro, entertainment, nostalgic, maze
; @cli: --level <num> - Start at specific level
; @cli: --lives <count> - Set starting lives (default: 3)
; @cli: --help - Show CLI usage and game options
; @dependencies:
; ==============================================================================

#Requires AutoHotkey v2.0+
#SingleInstance Force

; Pacman v2: GDI+ rendering via lib\GdipHelper (backbuffer + Picture ctrl).
; Game model unchanged (step movement, dot eating, random-walk ghosts)
; plus lives, levels, and a working start/pause timer.

_CatchBootError(Thrown, Mode) {
    msg := Thrown && HasProp(Thrown, "Message") ? Thrown.Message : "Unknown"
    try FileAppend("[" A_Now "] pacman: " msg "`n", A_ScriptDir "\pacman_crash.log")
    return 1
}
OnError(_CatchBootError)

#Include %A_ScriptDir%\lib\ScriptletErrorHandler.ahk
#Include %A_ScriptDir%\lib\GdipHelper.ahk
OnError(LogError)

class PacmanApp {
    static gui := ""
    static pic := 0
    static scoreCtrl := ""
    static livesCtrl := ""
    static levelCtrl := ""
    static statusCtrl := ""
    static timerFn := 0
    static running := false
    static layout := []
    static pac := {x: 1, y: 1}
    static facing := {x: 1, y: 0}
    static ghosts := []
    static score := 0
    static lives := 3
    static level := 1
    static frame := 0
    static gfx := 0
    static bmp := 0
    static br := {}
    static pen := 0
    static CW := 36
    static CH := 36
    static BW := 396
    static BH := 324

    static Init() {
        PacmanApp.layout := PacmanApp.LoadLayout()
        PacmanApp.CreateGui()
        PacmanApp.SetupGfx()
        PacmanApp.SetupHotkeys()
        PacmanApp.ResetGame(true)
    }

    static LoadLayout() {
        return [
            "###########",
            "#....#....#",
            "#.##.#.##.#",
            "#.........#",
            "###.#.###.#",
            "#.....#...#",
            "#.###.###.#",
            "#.........#",
            "###########"
        ]
    }

    static TickInterval() {
        return Max(150, 400 - (PacmanApp.level - 1) * 40)
    }

    static CreateGui() {
        if (PacmanApp.gui) {
            PacmanApp.gui.Destroy()
        }
        g := Gui("+Resize +MinSize600x420", "Pac-Man Classic")
        g.BackColor := "101010"
        g.SetFont("s10", "Segoe UI")
        PacmanApp.pic := g.Add("Picture", "x10 y10 w396 h324", "")
        PacmanApp.scoreCtrl := g.Add("Text", "x416 y10 w160 Center cFFFF54", "Score: 0")
        PacmanApp.livesCtrl := g.Add("Text", "x416 y34 w160 Center cFFFFFF", "Lives: 3")
        PacmanApp.levelCtrl := g.Add("Text", "x416 y58 w160 Center cGray", "Level 1")
        btnStart := g.Add("Button", "x436 y96 w120 h30", "Start")
        btnPause := g.Add("Button", "x436 y132 w120 h30", "Pause")
        btnReset := g.Add("Button", "x436 y168 w120 h30", "Reset")
        btnClose := g.Add("Button", "x436 y204 w120 h30", "Close")
        btnStart.OnEvent("Click", (*) => PacmanApp.StartGame())
        btnPause.OnEvent("Click", (*) => PacmanApp.PauseGame())
        btnReset.OnEvent("Click", (*) => PacmanApp.ResetGame(true))
        btnClose.OnEvent("Click", (*) => PacmanApp.HideGui())
        PacmanApp.statusCtrl := g.Add("Text", "x10 y344 w566 h48 cFFFFFF", "Arrows move. Space=Start, P=Pause, R=Reset")
        g.OnEvent("Close", (*) => PacmanApp.HideGui())
        g.OnEvent("Escape", (*) => PacmanApp.HideGui())
        PacmanApp.gui := g
        g.Show("w586 h402")
    }

    static SetupGfx() {
        GdipHelper.Startup()
        PacmanApp.bmp := GdipHelper.CreateBitmap(PacmanApp.BW, PacmanApp.BH)
        PacmanApp.gfx := GdipHelper.GraphicsFromImage(PacmanApp.bmp)
        GdipHelper.SetSmoothingMode(PacmanApp.gfx, 4)
        mk := (c) => GdipHelper.BrushCreateSolid(c)
        PacmanApp.br := Map(
            "bg",     mk(0xFF000000),
            "wall",   mk(0xFF16265E),
            "wallHi", mk(0xFF3B6FE0),
            "dot",    mk(0xFFFFC890),
            "pac",    mk(0xFFFFE400),
            "mouth",  mk(0xFF000000),
            "ghostA", mk(0xFFFF0000),
            "ghostB", mk(0xFFFF9DE2),
            "eyeW",   mk(0xFFFFFFFF),
            "pupil",  mk(0xFF2121DE))
        PacmanApp.pen := GdipHelper.PenCreate(0xFF000000, 1)
    }

    static SetupHotkeys() {
        static registered := false
        if (registered) {
            return
        }
        ; Global hotkey to launch/show the game (dg: Ctrl+Win+M, was ^!m which collides with the widget snap)
        Hotkey("^#m", (*) => PacmanApp.ShowGui())

        ; Game keys are window-scoped so arrows/space/letters keep working
        ; in other apps while Pac-Man runs in the background.
        HotIf((*) => WinActive("ahk_id " . PacmanApp.gui.Hwnd))
        Hotkey("Up", (*) => PacmanApp.MovePac(0, -1))
        Hotkey("Down", (*) => PacmanApp.MovePac(0, 1))
        Hotkey("Left", (*) => PacmanApp.MovePac(-1, 0))
        Hotkey("Right", (*) => PacmanApp.MovePac(1, 0))
        Hotkey("Space", (*) => PacmanApp.StartGame())
        Hotkey("p", (*) => PacmanApp.PauseGame())
        Hotkey("r", (*) => PacmanApp.ResetGame(true))
        Hotkey("Escape", (*) => PacmanApp.HideGui())
        HotIf()
        registered := true
    }

    static ShowGui(*) {
        if (PacmanApp.gui) {
            PacmanApp.gui.Show()
            WinActivate(PacmanApp.gui.Hwnd)
        } else {
            PacmanApp.Init()
        }
    }

    static HideGui(*) {
        PacmanApp.PauseGame()
        if (PacmanApp.gui) {
            PacmanApp.gui.Hide()
        }
    }

    static ResetPositions() {
        PacmanApp.pac := {x: 1, y: 1}
        PacmanApp.facing := {x: 1, y: 0}
        PacmanApp.ghosts := [{x: 9, y: 1}, {x: 5, y: 3}]
    }

    static ResetGame(full) {
        PacmanApp.PauseGame()
        if (full) {
            PacmanApp.score := 0
            PacmanApp.lives := 3
            PacmanApp.level := 1
        }
        PacmanApp.layout := PacmanApp.LoadLayout()
        PacmanApp.ResetPositions()
        PacmanApp.frame := 0
        PacmanApp.UpdateHud()
        PacmanApp.Draw()
        PacmanApp.UpdateStatus(full ? "Press Start." : "Level " . PacmanApp.level . " - press Start.")
    }

    static StartGame() {
        if (PacmanApp.running) {
            return
        }
        PacmanApp.running := true
        PacmanApp.timerFn := (*) => PacmanApp.Tick()
        SetTimer(PacmanApp.timerFn, PacmanApp.TickInterval())
        PacmanApp.UpdateStatus("Game running - level " . PacmanApp.level . ".")
    }

    static PauseGame() {
        if (!PacmanApp.running) {
            return
        }
        SetTimer(PacmanApp.timerFn, 0)
        PacmanApp.running := false
        PacmanApp.timerFn := 0
        PacmanApp.UpdateStatus("Paused.")
    }

    static Tick() {
        PacmanApp.frame++
        PacmanApp.MoveGhosts()
        PacmanApp.CheckCollision()
        PacmanApp.Draw()
    }

    static MovePac(dx, dy) {
        newX := PacmanApp.pac.x + dx
        newY := PacmanApp.pac.y + dy
        if (!PacmanApp.CanWalk(newX, newY)) {
            return
        }
        PacmanApp.facing := {x: dx, y: dy}
        if (SubStr(PacmanApp.layout[newY + 1], newX + 1, 1) = ".") {
            PacmanApp.layout[newY + 1] := PacmanApp.ReplaceChar(PacmanApp.layout[newY + 1], newX + 1, " ")
            PacmanApp.score += 10
        }
        PacmanApp.pac := {x: newX, y: newY}
        PacmanApp.CheckCollision()
        PacmanApp.UpdateHud()
        PacmanApp.Draw()
        if (!PacmanApp.HasDots()) {
            PacmanApp.level++
            PacmanApp.score += 100
            wasRunning := PacmanApp.running
            PacmanApp.PauseGame()
            PacmanApp.layout := PacmanApp.LoadLayout()
            PacmanApp.ResetPositions()
            PacmanApp.UpdateHud()
            PacmanApp.Draw()
            PacmanApp.UpdateStatus("Level " . PacmanApp.level . " clear! Bonus +100.")
            if (wasRunning) {
                PacmanApp.StartGame()
            }
        }
    }

    static MoveGhosts() {
        for g in PacmanApp.ghosts {
            choices := []
            dirs := [[1,0],[-1,0],[0,1],[0,-1]]
            for dir in dirs {
                newX := g.x + dir[1]
                newY := g.y + dir[2]
                if (PacmanApp.CanWalk(newX, newY)) {
                    choices.Push({x: newX, y: newY})
                }
            }
            if (choices.Length) {
                step := choices[Random(1, choices.Length)]
                g.x := step.x
                g.y := step.y
            }
        }
    }

    static CanWalk(x, y) {
        if (y < 0 || y >= PacmanApp.layout.Length) {
            return false
        }
        row := PacmanApp.layout[y + 1]
        if (x < 0 || x >= StrLen(row)) {
            return false
        }
        return SubStr(row, x + 1, 1) != "#"
    }

    static HasDots() {
        for row in PacmanApp.layout {
            if InStr(row, ".") {
                return true
            }
        }
        return false
    }

    static CheckCollision() {
        for g in PacmanApp.ghosts {
            if (PacmanApp.pac.x = g.x && PacmanApp.pac.y = g.y) {
                PacmanApp.lives--
                PacmanApp.UpdateHud()
                if (PacmanApp.lives <= 0) {
                    PacmanApp.PauseGame()
                    PacmanApp.UpdateStatus("Game over! Final score: " . PacmanApp.score)
                    MsgBox("Game Over! Score: " . PacmanApp.score, "Pac-Man", "Iconi")
                    PacmanApp.ResetGame(true)
                } else {
                    PacmanApp.PauseGame()
                    PacmanApp.ResetPositions()
                    PacmanApp.Draw()
                    PacmanApp.UpdateStatus("Caught! " . PacmanApp.lives . " lives left - press Start.")
                }
                return
            }
        }
    }

    static UpdateHud() {
        if (PacmanApp.scoreCtrl) {
            PacmanApp.scoreCtrl.Text := "Score: " . PacmanApp.score
        }
        if (PacmanApp.livesCtrl) {
            PacmanApp.livesCtrl.Text := "Lives: " . PacmanApp.lives
        }
        if (PacmanApp.levelCtrl) {
            PacmanApp.levelCtrl.Text := "Level " . PacmanApp.level
        }
    }

    static UpdateStatus(message) {
        if (PacmanApp.statusCtrl) {
            PacmanApp.statusCtrl.Text := message
        }
    }

    static ReplaceChar(text, index, replacement) {
        return SubStr(text, 1, index - 1) . replacement . SubStr(text, index + 1)
    }

    static Draw() {
        g := PacmanApp.gfx
        if (!g) {
            return
        }
        cw := PacmanApp.CW
        ch := PacmanApp.CH
        GdipHelper.Clear(g, 0xFF000000)
        ; Maze: walls get a bright inner frame, dots are small pellets.
        Loop PacmanApp.layout.Length {
            y := A_Index - 1
            row := PacmanApp.layout[y + 1]
            Loop StrLen(row) {
                x := A_Index - 1
                ch1 := SubStr(row, x + 1, 1)
                bx := x * cw
                by := y * ch
                if (ch1 = "#") {
                    GdipHelper.FillRectangle(g, PacmanApp.br["wall"], bx, by, cw, ch)
                    GdipHelper.DrawRectangle(g, PacmanApp.pen, bx + 1, by + 1, cw - 2, ch - 2)
                    GdipHelper.FillRectangle(g, PacmanApp.br["wallHi"], bx + 4, by + 4, cw - 8, 3)
                } else if (ch1 = ".") {
                    GdipHelper.FillEllipse(g, PacmanApp.br["dot"], bx + cw // 2 - 3, by + ch // 2 - 3, 6, 6)
                }
            }
        }
        ; Ghosts first (under Pac-Man on overlap).
        colors := ["ghostA", "ghostB"]
        i := 0
        for gh in PacmanApp.ghosts {
            i++
            PacmanApp.DrawGhost(g, gh.x * cw, gh.y * ch, PacmanApp.br[colors[Mod(i - 1, colors.Length) + 1]])
        }
        PacmanApp.DrawPac(g, PacmanApp.pac.x * cw, PacmanApp.pac.y * ch)
        GdipHelper.UpdatePicture(PacmanApp.pic, PacmanApp.bmp, PacmanApp.BW, PacmanApp.BH)
    }

    static DrawPac(g, bx, by) {
        cw := PacmanApp.CW
        ch := PacmanApp.CH
        cx := bx + cw // 2
        cy := by + ch // 2
        r := 13
        GdipHelper.FillEllipse(g, PacmanApp.br["pac"], cx - r, cy - r, r * 2, r * 2)
        ; Chomping mouth: background wedge, alternating open/closed.
        if (Mod(PacmanApp.frame, 2) = 0) {
            m := PacmanApp.br["mouth"]
            fx := PacmanApp.facing.x
            fy := PacmanApp.facing.y
            if (fx = 1) {
                GdipHelper.FillRectangle(g, m, cx, cy - 5, r, 10)
            } else if (fx = -1) {
                GdipHelper.FillRectangle(g, m, cx - r, cy - 5, r, 10)
            } else if (fy = -1) {
                GdipHelper.FillRectangle(g, m, cx - 5, cy - r, 10, r)
            } else {
                GdipHelper.FillRectangle(g, m, cx - 5, cy, 10, r)
            }
        }
        ; Single eye, offset toward facing.
        ex := cx + PacmanApp.facing.x * 3 - 2
        ey := cy + PacmanApp.facing.y * 3 - 6
        GdipHelper.FillEllipse(g, PacmanApp.br["mouth"], ex, ey, 4, 5)
    }

    static DrawGhost(g, bx, by, bodyBrush) {
        cw := PacmanApp.CW
        ch := PacmanApp.CH
        w := 24
        x0 := bx + (cw - w) // 2
        top := by + 5
        ; Skirt + dome body.
        GdipHelper.FillRectangle(g, bodyBrush, x0, top + 10, w, ch - 10 - 8)
        GdipHelper.FillEllipse(g, bodyBrush, x0, top, w, 20)
        ; Feet zigzag.
        feetY := by + ch - 8
        Loop 3 {
            fx := x0 + (A_Index - 1) * 8
            GdipHelper.FillRectangle(g, bodyBrush, fx, feetY, 8, 4)
        }
        ; Eyes look toward Pac-Man.
        dx := (PacmanApp.pac.x * cw > bx) ? 1 : -1
        GdipHelper.FillEllipse(g, PacmanApp.br["eyeW"], x0 + 4 + dx, top + 6, 7, 9)
        GdipHelper.FillEllipse(g, PacmanApp.br["eyeW"], x0 + 13 + dx, top + 6, 7, 9)
        GdipHelper.FillEllipse(g, PacmanApp.br["pupil"], x0 + 6 + dx * 2, top + 10, 3, 4)
        GdipHelper.FillEllipse(g, PacmanApp.br["pupil"], x0 + 15 + dx * 2, top + 10, 3, 4)
    }
}

PacmanApp.Init()
