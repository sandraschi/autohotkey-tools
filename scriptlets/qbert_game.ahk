#Requires AutoHotkey v2.0+
#SingleInstance Force
#Include %A_ScriptDir%\lib\ScriptletErrorHandler.ahk

OnError(LogError)

class QBertApp {
    static gui := ""
    static boardCtrl := ""
    static statusCtrl := ""
    static levelCtrl := ""
    static pyramid := []
    static player := {row: 1, col: 1}
    static targetColor := 2

    static Init() {
        QBertApp.ResetBoard()
        QBertApp.CreateGui()
        QBertApp.SetupHotkeys()
        QBertApp.UpdateBoard()
        QBertApp.UpdateStatus("Use Ctrl+Alt+Arrow keys to hop.")
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
    }

    static CreateGui() {
        if (QBertApp.gui) {
            QBertApp.gui.Destroy()
        }
        newGui := Gui("+Resize +MinSize260x300", "Q*bert Pyramid")
        newGui.BackColor := "1a1a32"
        newGui.SetFont("s11", "Consolas")

        newGui.AddText("x20 y16 w220 Center cFFFFFF", "Q*bert – change all tiles twice")
        QBertApp.boardCtrl := newGui.AddText("x20 y48 w200 h160 Background000000 Border", "")
        QBertApp.boardCtrl.SetFont("s11", "Consolas")

        QBertApp.levelCtrl := newGui.AddText("x20 y220 w200 h24 cFFFFFF Center", "Target color level: 2")
        resetBtn := newGui.AddButton("x20 y250 w90 h28", "Reset")
        resetBtn.OnEvent("Click", (*) => QBertApp.ResetGame())
        closeBtn := newGui.AddButton("x130 y250 w90 h28", "Close")
        closeBtn.OnEvent("Click", (*) => QBertApp.HideGui())

        QBertApp.statusCtrl := newGui.AddText("x20 y280 w220 h24 cFFFFFF", "")

        newGui.OnEvent("Close", QBertApp.HideGui)
        newGui.OnEvent("Escape", QBertApp.HideGui)
        newGui.OnEvent("Size", QBertApp.OnResize)

        QBertApp.gui := newGui
        newGui.Show("w260 h320")
    }

    static SetupHotkeys() {
        static registered := false
        if (registered) {
            return
        }
        ; Global hotkey to launch/show the game
        Hotkey("^!b", (*) => QBertApp.ShowGui())
        
        ; Context-sensitive hotkeys - only work when Q*bert window is active
        Hotkey("Up", (*) => QBertApp.HopIfActive(-1, 0))
        Hotkey("Down", (*) => QBertApp.HopIfActive(1, 0))
        Hotkey("Left", (*) => QBertApp.HopIfActive(0, -1))
        Hotkey("Right", (*) => QBertApp.HopIfActive(0, 1))
        Hotkey("r", (*) => QBertApp.ResetGameIfActive())
        Hotkey("Escape", (*) => QBertApp.HideGui())
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
        current := QBertApp.pyramid[newRow][newCol]
        QBertApp.pyramid[newRow][newCol] := Mod(current + 1, QBertApp.targetColor + 1)
        if (QBertApp.pyramid[newRow][newCol] = 0) {
            QBertApp.pyramid[newRow][newCol] := 1
        }
        QBertApp.UpdateBoard()
        if (QBertApp.AllTilesTargeted()) {
            QBertApp.UpdateStatus("Great! All tiles transformed.")
            MsgBox("You completed the pyramid!", "Q*bert", "Iconi")
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

    static UpdateBoard() {
        lines := []
        for rowIndex, row in QBertApp.pyramid {
            indent := Format("{:" . (QBertApp.pyramid.Length - rowIndex) . "}", "")
            line := indent
            for colIndex, tile in row {
                if (QBertApp.player.row = rowIndex && QBertApp.player.col = colIndex) {
                    line .= "🐰 "
                } else {
                    line .= Format("{} ", tile)
                }
            }
            lines.Push(line)
        }
        QBertApp.boardCtrl.Text := lines.Join("`n")
        if (QBertApp.levelCtrl) {
            QBertApp.levelCtrl.Text := "Target color level: " . QBertApp.targetColor
        }
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

    static OnResize(gui, minMax, width, height) {
        if (!QBertApp.boardCtrl) {
            return
        }
        QBertApp.boardCtrl.Move(20, 48, Min(200, width - 80), height - 160)
        if (QBertApp.statusCtrl) {
            QBertApp.statusCtrl.Move(20, height - 40, width - 40, 24)
        }
    }
}

QBertApp.Init()

OnExit((*) => QBertApp.UpdateStatus(""))
