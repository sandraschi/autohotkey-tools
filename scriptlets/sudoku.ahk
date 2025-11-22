#Requires AutoHotkey v2.0+
#SingleInstance Force
#Include %A_ScriptDir%\lib\ScriptletErrorHandler.ahk

OnError(LogError)

class SudokuApp {
    static gui := ""
    static statusCtrl := ""
    static cellData := []
    static puzzleState := []
    static puzzleSeed := [
        "530070000",
        "600195000",
        "098000060",
        "800060003",
        "400803001",
        "700020006",
        "060000280",
        "000419005",
        "000080079"
    ]
    static puzzleSolution := [
        "534678912",
        "672195348",
        "198342567",
        "859761423",
        "426853791",
        "713924856",
        "961537284",
        "287419635",
        "345286179"
    ]

    static Init() {
        SudokuApp.ResetState()
        SudokuApp.CreateGui()
        SudokuApp.SetupHotkeys()
        SudokuApp.UpdateStatus("Loaded starter puzzle.")
    }


    static ResetState() {
        SudokuApp.puzzleState := []
        for rowText in SudokuApp.puzzleSeed {
            row := []
            Loop StrLen(rowText) {
                row.Push(SubStr(rowText, A_Index, 1))
            }
            SudokuApp.puzzleState.Push(row)
        }
    }

    static CreateGui() {
        if (SudokuApp.gui) {
            SudokuApp.gui.Destroy()
        }
        gui := Gui("+Resize +MinSize460x540", "Sudoku")
        gui.BackColor := "1f1f1f"
        gui.SetFont("s10", "Segoe UI")

        gui.AddText("x20 y16 w420 Center cFFFFFF", "Sudoku – fill the grid so each row, column, and 3×3 box contains 1‑9.")

        SudokuApp.cellData := []
        cellSize := 42
        baseX := 40
        baseY := 48

        Loop 9 {
            rowIndex := A_Index
            rowSet := []
            Loop 9 {
                colIndex := A_Index
                x := baseX + (colIndex - 1) * cellSize
                y := baseY + (rowIndex - 1) * cellSize
                boxShade := Mod(Floor((rowIndex - 1) / 3) + Floor((colIndex - 1) / 3), 2)
                backColor := boxShade ? "0xF2F2F2" : "0xFFFFFF"
                ctrl := gui.AddEdit(Format("x{} y{} w{} h{} Limit1 Center +0x200 Background{}", x, y, cellSize - 2, cellSize - 2, backColor), "")
                ctrl.SetFont("s16", "Segoe UI")
                ctrl.OnEvent("Change", SudokuApp.OnCellChange.Bind(SudokuApp, rowIndex, colIndex))
                ctrl.OnEvent("Focus", SudokuApp.OnCellFocus.Bind(SudokuApp, rowIndex, colIndex))
                rowSet.Push({ctrl: ctrl, baseColor: backColor, given: false})
            }
            SudokuApp.cellData.Push(rowSet)
        }

        btnCheck := gui.AddButton("x40 y440 w120 h32", "Check Puzzle")
        btnCheck.OnEvent("Click", (*) => SudokuApp.CheckPuzzle())
        btnReset := gui.AddButton("x180 y440 w120 h32", "Reset")
        btnReset.OnEvent("Click", (*) => SudokuApp.ResetBoard())
        btnClose := gui.AddButton("x320 y440 w120 h32", "Close")
        btnClose.OnEvent("Click", (*) => SudokuApp.HideGui())

        SudokuApp.statusCtrl := gui.AddText("x20 y488 w420 h24 cFFFFFF", "")

        gui.OnEvent("Close", SudokuApp.HideGui)
        gui.OnEvent("Escape", SudokuApp.HideGui)
        gui.OnEvent("Size", SudokuApp.OnResize)

        SudokuApp.gui := gui
        SudokuApp.ResetBoard()
        gui.Show("w460 h520")
    }

    static SetupHotkeys() {
        static registered := false
        if (registered) {
            return
        }
        ; Global hotkey to launch/show the game
        Hotkey("^!s", (*) => SudokuApp.ShowGui())
        
        ; Context-sensitive hotkeys - only work when Sudoku window is active
        Hotkey("r", (*) => SudokuApp.ResetBoardIfActive())
        Hotkey("c", (*) => SudokuApp.CheckPuzzleIfActive())
        Hotkey("Escape", (*) => SudokuApp.HideGui())
        registered := true
    }
    
    static IsSudokuWindowActive() {
        if (!SudokuApp.gui || !SudokuApp.gui.Hwnd) {
            return false
        }
        return WinActive("ahk_id " . SudokuApp.gui.Hwnd)
    }
    
    static ResetBoardIfActive() {
        if (SudokuApp.IsSudokuWindowActive()) {
            SudokuApp.ResetBoard()
        }
    }
    
    static CheckPuzzleIfActive() {
        if (SudokuApp.IsSudokuWindowActive()) {
            SudokuApp.CheckPuzzle()
        }
    }
    
    static ShowGui(*) {
        if (SudokuApp.gui) {
            SudokuApp.gui.Show()
            WinActivate(SudokuApp.gui.Hwnd)
        } else {
            SudokuApp.Init()
        }
    }

    static ResetBoard() {
        SudokuApp.ResetState()
        Loop 9 {
            rowIndex := A_Index
            Loop 9 {
                colIndex := A_Index
                cell := SudokuApp.cellData[rowIndex][colIndex]
                value := SudokuApp.puzzleState[rowIndex][colIndex]
                solutionDigit := SubStr(SudokuApp.puzzleSolution[rowIndex], colIndex, 1)
                if (value != "0") {
                    cell.ctrl.Value := value
                    cell.ctrl.Opt("+ReadOnly")
                    cell.ctrl.SetFont("s16 Bold", "Segoe UI")
                    cell.given := true
                } else {
                    cell.ctrl.Value := ""
                    cell.ctrl.Opt("-ReadOnly")
                    cell.ctrl.SetFont("s16", "Segoe UI")
                    cell.given := false
                }
                cell.ctrl.Opt("Background" . cell.baseColor)
            }
        }
        SudokuApp.UpdateStatus("Board reset to starting puzzle.")
    }

    static OnCellFocus(rowIndex, colIndex, ctrl, info) {
        SudokuApp.HighlightSelection(rowIndex, colIndex)
    }

    static OnCellChange(rowIndex, colIndex, ctrl, info) {
        cell := SudokuApp.cellData[rowIndex][colIndex]
        if (cell.given) {
            ctrl.Value := SubStr(SudokuApp.puzzleSeed[rowIndex], colIndex, 1)
            return
        }
        text := Trim(ctrl.Value)
        if (text = "") {
            SudokuApp.puzzleState[rowIndex][colIndex] := "0"
        } else if (text ~= "^[1-9]$") {
            SudokuApp.puzzleState[rowIndex][colIndex] := text
        } else {
            ctrl.Value := ""
            SudokuApp.puzzleState[rowIndex][colIndex] := "0"
        }
        SudokuApp.HighlightSelection(rowIndex, colIndex)
    }

    static HighlightSelection(selRow, selCol) {
        Loop 9 {
            rowIndex := A_Index
            Loop 9 {
                colIndex := A_Index
                cell := SudokuApp.cellData[rowIndex][colIndex]
                baseColor := cell.baseColor
                highlight := (rowIndex = selRow || colIndex = selCol || (Floor((rowIndex - 1) / 3) = Floor((selRow - 1) / 3) && Floor((colIndex - 1) / 3) = Floor((selCol - 1) / 3)))
                color := highlight ? "0xFFF7CC" : baseColor
                cell.ctrl.Opt("Background" . color)
            }
        }
    }

    static CheckPuzzle() {
        mistakes := 0
        Loop 9 {
            rowIndex := A_Index
            rowSolution := SudokuApp.puzzleSolution[rowIndex]
            Loop 9 {
                colIndex := A_Index
                expected := SubStr(rowSolution, colIndex, 1)
                cell := SudokuApp.cellData[rowIndex][colIndex]
                current := SudokuApp.puzzleState[rowIndex][colIndex]
                if (!cell.given) {
                    if (current = "0") {
                        cell.ctrl.Opt("Background0xFFEFCC")
                        mistakes++
                    } else if (current != expected) {
                        cell.ctrl.Opt("Background0xFFCCCC")
                        mistakes++
                    } else {
                        cell.ctrl.Opt("Background0xE6FFE6")
                    }
                }
            }
        }
        if (mistakes = 0) {
            SudokuApp.UpdateStatus("Great job! Puzzle solved correctly.")
        } else {
            SudokuApp.UpdateStatus(mistakes . " cell(s) need attention.")
        }
    }

    static UpdateStatus(message) {
        if (SudokuApp.statusCtrl) {
            SudokuApp.statusCtrl.Text := message
        }
    }

    static OnResize(gui, minMax, newW, newH) {
        if (!SudokuApp.cellData.Length) {
            return
        }
        padding := 80
        squareSize := Min(newW - padding, newH - 180) // 9
        baseX := (newW - squareSize * 9) // 2
        baseY := 48
        Loop 9 {
            rowIndex := A_Index
            Loop 9 {
                colIndex := A_Index
                ctrl := SudokuApp.cellData[rowIndex][colIndex].ctrl
                x := baseX + (colIndex - 1) * squareSize
                y := baseY + (rowIndex - 1) * squareSize
                ctrl.Move(x, y, squareSize - 2, squareSize - 2)
            }
        }
        if (SudokuApp.statusCtrl) {
            SudokuApp.statusCtrl.Move(baseX, baseY + squareSize * 9 + 40, squareSize * 9, 24)
        }
    }

    static HideGui(*) {
        if (SudokuApp.gui) {
            SudokuApp.gui.Hide()
            SudokuApp.UpdateStatus("GUI hidden. Press Ctrl+Alt+S to reopen.")
        }
    }
}

SudokuApp.Init()

OnExit((*) => SudokuApp.UpdateStatus(""))
