#Requires AutoHotkey v2.0+
#SingleInstance Force

; Q*bert v2: GDI+ board (beveled color cubes + drawn player) via lib\GdipHelper.
; Game logic unchanged: orthogonal pyramid hops recolor tiles, all tiles to
; target color clears the board.

_CatchBootError(Thrown, Mode) {
    msg := Thrown && HasProp(Thrown, "Message") ? Thrown.Message : "Unknown"
    try FileAppend("[" A_Now "] qbert: " msg "`n", A_ScriptDir "\qbert_crash.log")
    return 1
}
OnError(_CatchBootError)

#Include %A_ScriptDir%\lib\ScriptletErrorHandler.ahk
#Include %A_ScriptDir%\lib\GdipHelper.ahk
OnError(LogError)

; @name: Q*bert
; @description: Pyramid-hopping arcade game -- color every cube by landing on it, avoid falling off the edge.
; @category: games
; @hotkeys: ^!b toggle, arrow keys to hop
; @tag: games, arcade, qbert, puzzle

class QBertApp {
    static gui := ""
    static pic := 0
    static statusCtrl := ""
    static levelCtrl := ""
    static hopsCtrl := ""
    static pyramid := []
    static player := {row: 1, col: 1}
    static targetColor := 2
    static moves := 0
    static gfx := 0
    static bmp := 0
    static br := {}
    static pen := 0
    static CW := 56
    static CH := 58
    static BW := 360
    static BH := 330

    static Init() {
        QBertApp.ResetBoard()
        QBertApp.CreateGui()
        QBertApp.SetupGfx()
        QBertApp.SetupHotkeys()
        QBertApp.UpdateBoard()
        QBertApp.UpdateStatus("Use arrow keys to hop.")
    }

    static ResetBoard() {
        QBertApp.pyramid := []
        Loop 5 {
            row := []
            Loop A_Index {
                row.Push(0)
            }
            QBertApp.pyramid.Push(row)
        }
        QBertApp.player := {row: 1, col: 1}
        QBertApp.moves := 0
    }

    static CreateGui() {
        if (QBertApp.gui) {
            QBertApp.gui.Destroy()
        }
        newGui := Gui("+MinSize440x400", "Q*bert Pyramid")
        newGui.BackColor := "1a1a32"
        newGui.SetFont("s10", "Segoe UI")

        newGui.Add("Text", "x20 y10 w320 Center cFFFFFF", "Q*bert - hop every tile to orange")
        QBertApp.pic := newGui.Add("Picture", "x20 y36 w360 h330", "")
        QBertApp.levelCtrl := newGui.Add("Text", "x20 y372 w120 h24 cFFFFFF", "Target: orange")
        QBertApp.hopsCtrl := newGui.Add("Text", "x150 y372 w90 h24 cFFFFFF", "Hops: 0")
        resetBtn := newGui.Add("Button", "x250 y368 w60 h28", "Reset")
        resetBtn.OnEvent("Click", (*) => QBertApp.ResetGame())
        closeBtn := newGui.Add("Button", "x320 y368 w60 h28", "Close")
        closeBtn.OnEvent("Click", (*) => QBertApp.HideGui())

        QBertApp.statusCtrl := newGui.Add("Text", "x20 y400 w360 h24 cFFFFFF", "")

        newGui.OnEvent("Close", QBertApp.HideGui)
        newGui.OnEvent("Escape", QBertApp.HideGui)

        QBertApp.gui := newGui
        newGui.Show("w400 h434")
    }

    static SetupGfx() {
        GdipHelper.Startup()
        QBertApp.bmp := GdipHelper.CreateBitmap(QBertApp.BW, QBertApp.BH)
        QBertApp.gfx := GdipHelper.GraphicsFromImage(QBertApp.bmp)
        GdipHelper.SetSmoothingMode(QBertApp.gfx, 4)
        mk := (c) => GdipHelper.BrushCreateSolid(c)
        QBertApp.br := Map(
            ; Tile stage colors: base / top-light / bottom-shade.
            "t0",   mk(0xFF23233E), "t0hi", mk(0xFF3A3A5C), "t0lo", mk(0xFF12121F),
            "t1",   mk(0xFF2E6FDB), "t1hi", mk(0xFF7AA8F0), "t1lo", mk(0xFF1A3F80),
            "t2",   mk(0xFFFF8C00), "t2hi", mk(0xFFFFC25E), "t2lo", mk(0xFF9A5200),
            "bert", mk(0xFFFF6A00), "bertBelly", mk(0xFFFFB066),
            "eyeW", mk(0xFFFFFFFF), "pupil", mk(0xFF111111))
        QBertApp.pen := GdipHelper.PenCreate(0xFF000000, 2)
    }

    static SetupHotkeys() {
        static registered := false
        if (registered) {
            return
        }
        ; Global hotkey to launch/show the game (dg: Ctrl+Win+B, was ^!b which collides with other tools)
        Hotkey("^#b", (*) => QBertApp.ShowGui())

        ; Game keys are window-scoped so arrows/letters keep working in
        ; other apps while Q*Bert runs in the background.
        HotIf((*) => WinActive("ahk_id " . QBertApp.gui.Hwnd))
        Hotkey("Up", (*) => QBertApp.Hop(-1, 0))
        Hotkey("Down", (*) => QBertApp.Hop(1, 0))
        Hotkey("Left", (*) => QBertApp.Hop(0, -1))
        Hotkey("Right", (*) => QBertApp.Hop(0, 1))
        Hotkey("r", (*) => QBertApp.ResetGame())
        Hotkey("Escape", (*) => QBertApp.HideGui())
        HotIf()
        registered := true
    }

    static IsQBertWindowActive() {
        if (!QBertApp.gui || !QBertApp.gui.Hwnd) {
            return false
        }
        return WinActive("ahk_id " . QBertApp.gui.Hwnd)
    }

    static HopIfActive(rowOffset, colOffset) {
        if (QBertApp.IsQBertWindowActive()) {
            QBertApp.Hop(rowOffset, colOffset)
        }
    }

    static ResetGameIfActive() {
        if (QBertApp.IsQBertWindowActive()) {
            QBertApp.ResetGame()
        }
    }

    static ShowGui(*) {
        if (QBertApp.gui) {
            QBertApp.gui.Show()
            WinActivate(QBertApp.gui.Hwnd)
        } else {
            QBertApp.Init()
        }
    }

    static ResetGame() {
        QBertApp.ResetBoard()
        QBertApp.UpdateBoard()
        QBertApp.UpdateStatus("Pyramid reset.")
    }

    static Hop(rowOffset, colOffset) {
        newRow := QBertApp.player.row + rowOffset
        newCol := QBertApp.player.col + colOffset
        if (newRow < 1 || newRow > QBertApp.pyramid.Length) {
            QBertApp.UpdateStatus("Cannot hop outside the pyramid.")
            return
        }
        if (newCol < 1 || newCol > QBertApp.pyramid[newRow].Length) {
            QBertApp.UpdateStatus("Cannot hop outside the pyramid.")
            return
        }
        QBertApp.player := {row: newRow, col: newCol}
        QBertApp.moves++
        current := QBertApp.pyramid[newRow][newCol]
        QBertApp.pyramid[newRow][newCol] := Mod(current + 1, QBertApp.targetColor + 1)
        if (QBertApp.pyramid[newRow][newCol] = 0) {
            QBertApp.pyramid[newRow][newCol] := 1
        }
        QBertApp.UpdateBoard()
        if (QBertApp.AllTilesTargeted()) {
            QBertApp.UpdateStatus("Great! All tiles transformed in " . QBertApp.moves . " hops.")
            MsgBox("You completed the pyramid in " . QBertApp.moves . " hops!", "Q*bert", "Iconi")
            QBertApp.ResetGame()
        }
    }

    static AllTilesTargeted() {
        for row in QBertApp.pyramid {
            for tile in row {
                if (tile != QBertApp.targetColor) {
                    return false
                }
            }
        }
        return true
    }

    static RowOrigin(r) {
        y := 10 + (r - 1) * QBertApp.CH
        count := QBertApp.pyramid[r].Length
        x0 := (QBertApp.BW - count * QBertApp.CW) // 2
        return {x: x0, y: y}
    }

    static UpdateBoard() {
        g := QBertApp.gfx
        if (!g) {
            return
        }
        cw := QBertApp.CW
        ch := QBertApp.CH
        GdipHelper.Clear(g, 0xFF0B0B1A)
        Loop QBertApp.pyramid.Length {
            r := A_Index
            o := QBertApp.RowOrigin(r)
            for c, tile in QBertApp.pyramid[r] {
                QBertApp.DrawCube(g, o.x + (c - 1) * cw, o.y, tile)
            }
        }
        o := QBertApp.RowOrigin(QBertApp.player.row)
        QBertApp.DrawBert(g, o.x + (QBertApp.player.col - 1) * cw, o.y)
        GdipHelper.UpdatePicture(QBertApp.pic, QBertApp.bmp, QBertApp.BW, QBertApp.BH)
        if (QBertApp.hopsCtrl) {
            QBertApp.hopsCtrl.Text := "Hops: " . QBertApp.moves
        }
    }

    static DrawCube(g, bx, by, stage) {
        cw := QBertApp.CW
        ch := QBertApp.CH
        key := "t" . stage
        GdipHelper.FillRectangle(g, QBertApp.br[key], bx + 2, by + 2, cw - 4, ch - 4)
        ; Bevel: light top strip, dark bottom strip.
        GdipHelper.FillRectangle(g, QBertApp.br[key . "hi"], bx + 2, by + 2, cw - 4, 7)
        GdipHelper.FillRectangle(g, QBertApp.br[key . "lo"], bx + 2, by + ch - 9, cw - 4, 7)
        GdipHelper.DrawRectangle(g, QBertApp.pen, bx + 2, by + 2, cw - 4, ch - 4)
    }

    static DrawBert(g, bx, by) {
        cw := QBertApp.CW
        ch := QBertApp.CH
        ; Round orange body + lighter belly.
        GdipHelper.FillEllipse(g, QBertApp.br["bert"], bx + 11, by + 10, cw - 22, ch - 20)
        GdipHelper.FillEllipse(g, QBertApp.br["bertBelly"], bx + 18, by + 22, cw - 36, ch - 36)
        ; Eyes on top.
        GdipHelper.FillEllipse(g, QBertApp.br["eyeW"], bx + 15, by + 6, 11, 11)
        GdipHelper.FillEllipse(g, QBertApp.br["eyeW"], bx + cw - 26, by + 6, 11, 11)
        GdipHelper.FillEllipse(g, QBertApp.br["pupil"], bx + 18, by + 9, 5, 5)
        GdipHelper.FillEllipse(g, QBertApp.br["pupil"], bx + cw - 23, by + 9, 5, 5)
    }

    static UpdateStatus(message) {
        if (QBertApp.statusCtrl) {
            QBertApp.statusCtrl.Text := message
        }
    }

    static HideGui(*) {
        if (QBertApp.gui) {
            QBertApp.gui.Hide()
        }
    }
}

QBertApp.Init()
