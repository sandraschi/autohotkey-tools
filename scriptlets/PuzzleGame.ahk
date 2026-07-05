#Requires AutoHotkey v2.0+
#SingleInstance Force
#Include %A_ScriptDir%\lib\ScriptletErrorHandler.ahk

OnError(LogError)

class PuzzleApp {
    static gui := ""
    static statusCtrl := ""
    static movesCtrl := ""
    static buttons := []
    static board := []
    static empty := {row: 4, col: 4}
    static size := 4
    static moves := 0

    static Init() {
        PuzzleApp.BuildBoard()
        PuzzleApp.CreateGui()
        PuzzleApp.SetupHotkeys()
        PuzzleApp.UpdateBoard()
        PuzzleApp.UpdateStatus("Press Shuffle to mix tiles.")
    }


    static BuildBoard() {
        PuzzleApp.board := []
        value := 1
        Loop PuzzleApp.size {
            row := []
            Loop PuzzleApp.size {
                row.Push(value)
                value++
            }
            PuzzleApp.board.Push(row)
        }
        PuzzleApp.board[PuzzleApp.size][PuzzleApp.size] := 0
        PuzzleApp.empty := {row: PuzzleApp.size, col: PuzzleApp.size}
        PuzzleApp.moves := 0
    }

    static CreateGui() {
        newGui := Gui("+Resize +MinSize320x360", "Sliding Puzzle")
        newGui.BackColor := "1d1d1d"
        newGui.SetFont("s10 c4488FF", "Segoe UI")

        newGui.AddText("x20 y16 w280 Center cFFFFFF", "Sliding Puzzle – arrange tiles in order")
        shuffleBtn := newGui.AddButton("x20 y48 w80 h28", "Shuffle")
        shuffleBtn.OnEvent("Click", (*) => PuzzleApp.Shuffle(80))
        resetBtn := newGui.AddButton("x110 y48 w80 h28", "Reset")
        resetBtn.OnEvent("Click", (*) => PuzzleApp.ResetGame())
        closeBtn := newGui.AddButton("x200 y48 w80 h28", "Close")
        closeBtn.OnEvent("Click", (*) => PuzzleApp.HideGui())

        PuzzleApp.movesCtrl := newGui.AddText("x20 y84 w160 h24 cFFFFFF", "Moves: 0")

        PuzzleApp.buttons := []
        startX := 20
        startY := 120
        size := 60
        padding := 6
        Loop PuzzleApp.size {
            rowIndex := A_Index
            PuzzleApp.buttons.Push([])
            Loop PuzzleApp.size {
                colIndex := A_Index
                x := startX + (colIndex - 1) * (size + padding)
                y := startY + (rowIndex - 1) * (size + padding)
                btn := newGui.AddButton(Format("x{} y{} w{} h{}", x, y, size, size), "")
                btn.SetFont("s12 Bold c4488FF", "Segoe UI")
                btn.OnEvent("Click", PuzzleApp.HandleClick.Bind(PuzzleApp, rowIndex, colIndex))
                PuzzleApp.buttons[rowIndex].Push(btn)
            }
        }

        PuzzleApp.statusCtrl := newGui.AddText("x20 y320 w280 h24 cFFFFFF", "")

        newGui.OnEvent("Close", PuzzleApp.HideGui)
        newGui.OnEvent("Escape", PuzzleApp.HideGui)
        newGui.OnEvent("Size", PuzzleApp.OnResize)

        PuzzleApp.gui := newGui
        newGui.Show("w320 h360")
    }

    static SetupHotkeys() {
        static registered := false
        if (registered) {
            return
        }
        ; Global hotkey to launch/show the game
        Hotkey("^!p", (*) => PuzzleApp.ShowGui())
        
        ; Context-sensitive hotkeys - only work when Puzzle window is active
        Hotkey("s", (*) => PuzzleApp.ShuffleIfActive(80))
        Hotkey("r", (*) => PuzzleApp.ResetGameIfActive())
        Hotkey("Escape", (*) => PuzzleApp.HideGui())
        registered := true
    }
    
    static IsPuzzleWindowActive() {
        if (!PuzzleApp.gui || !PuzzleApp.gui.Hwnd) {
            return false
        }
        return WinActive("ahk_id " . PuzzleApp.gui.Hwnd)
    }
    
    static ShuffleIfActive(count) {
        if (PuzzleApp.IsPuzzleWindowActive()) {
            PuzzleApp.Shuffle(count)
        }
    }
    
    static ResetGameIfActive() {
        if (PuzzleApp.IsPuzzleWindowActive()) {
            PuzzleApp.ResetGame()
        }
    }

    static ShowGui() {
        if (!PuzzleApp.gui) {
            PuzzleApp.CreateGui()
        }
        PuzzleApp.gui.Show()
    }

    static HideGui(*) {
        if (PuzzleApp.gui) {
            PuzzleApp.gui.Hide()
        }
    }

    static ResetGame() {
        PuzzleApp.BuildBoard()
        PuzzleApp.UpdateBoard()
        PuzzleApp.UpdateStatus("Puzzle reset.")
    }

    static Shuffle(count) {
        directions := [[-1,0],[1,0],[0,-1],[0,1]]
        Loop count {
            valid := []
            for dir in directions {
                newRow := PuzzleApp.empty.row + dir[1]
                newCol := PuzzleApp.empty.col + dir[2]
                if (newRow >= 1 && newRow <= PuzzleApp.size && newCol >= 1 && newCol <= PuzzleApp.size) {
                    valid.Push(dir)
                }
            }
            if (valid.Length = 0) {
                continue
            }
            idx := Random(1, valid.Length)
            dir := valid[idx]
            PuzzleApp.SwapWithEmpty(PuzzleApp.empty.row + dir[1], PuzzleApp.empty.col + dir[2])
        }
        PuzzleApp.moves := 0
        PuzzleApp.UpdateBoard()
        PuzzleApp.UpdateStatus("Shuffled. Solve the puzzle!")
    }

    static SwapWithEmpty(row, col) {
        temp := PuzzleApp.board[row][col]
        PuzzleApp.board[row][col] := 0
        PuzzleApp.board[PuzzleApp.empty.row][PuzzleApp.empty.col] := temp
        PuzzleApp.empty := {row: row, col: col}
    }

    static HandleClick(rowIndex, colIndex, ctrl, info) {
        if (Abs(rowIndex - PuzzleApp.empty.row) + Abs(colIndex - PuzzleApp.empty.col) != 1) {
            return
        }
        PuzzleApp.SwapWithEmpty(rowIndex, colIndex)
        PuzzleApp.moves++
        PuzzleApp.UpdateBoard()
        if (PuzzleApp.IsSolved()) {
            PuzzleApp.UpdateStatus("Solved in " . PuzzleApp.moves . " moves!")
            MsgBox("Great job!", "Sliding Puzzle", "Iconi")
        }
    }

    static UpdateBoard() {
        Loop PuzzleApp.size {
            rowIndex := A_Index
            Loop PuzzleApp.size {
                colIndex := A_Index
                value := PuzzleApp.board[rowIndex][colIndex]
                btn := PuzzleApp.buttons[rowIndex][colIndex]
                if (value = 0) {
                    btn.Text := ""
                    btn.Enable(false)
                } else {
                    btn.Text := value
                    btn.Enable(true)
                }
            }
        }
        if (PuzzleApp.movesCtrl) {
            PuzzleApp.movesCtrl.Text := "Moves: " . PuzzleApp.moves
        }
    }

    static IsSolved() {
        expected := 1
        Loop PuzzleApp.size {
            rowIndex := A_Index
            Loop PuzzleApp.size {
                colIndex := A_Index
                value := PuzzleApp.board[rowIndex][colIndex]
                if (rowIndex = PuzzleApp.size && colIndex = PuzzleApp.size) {
                    return value = 0
                }
                if (value != expected) {
                    return false
                }
                expected++
            }
        }
        return true
    }

    static UpdateStatus(message) {
        if (PuzzleApp.statusCtrl) {
            PuzzleApp.statusCtrl.Text := message
        }
    }

    static OnResize(gui, minMax, width, height) {
        if (!PuzzleApp.boardCtrlExists()) {
            return
        }
        ; This puzzle uses fixed buttons; no resize behaviour needed beyond status text.
        if (PuzzleApp.statusCtrl) {
            PuzzleApp.statusCtrl.Move(20, height - 40, width - 40, 24)
        }
    }

    static boardCtrlExists() {
        return PuzzleApp.buttons.Length > 0
    }
}

PuzzleApp.Init()

OnExit((*) => PuzzleApp.UpdateStatus(""))
