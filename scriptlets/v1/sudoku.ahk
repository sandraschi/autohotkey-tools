#NoEnv
#SingleInstance Force
#Persistent
SetWorkingDir %A_ScriptDir%
SetBatchLines -1

; Game state
board := []
original := []
selectedCell := {row: 0, col: 0}
difficulty := "medium" ; easy, medium, hard

; Create the GUI
Gui, +AlwaysOnTop +Resize
Gui, Font, s12, Arial

; Create the Sudoku grid
CreateGrid()

; Add controls
Gui, Add, Button, x10 y400 w100 h30 gNewGame, &New Game
Gui, Add, Button, x120 y400 w100 h30 gCheckSolution, &Check
Gui, Add, Button, x230 y400 w100 h30 gSolve, &Solve
Gui, Add, Button, x340 y400 w100 h30 gExitApp, E&xit

; Difficulty selector
Gui, Add, Text, x10 y440 w80 h30, Difficulty:
Gui, Add, DropDownList, x90 y440 w100 vDifficulty Choose2, Easy|Medium|Hard

; Status text
Gui, Add, Text, x200 y440 w240 h30 vStatus, Game Started

; Set up keyboard shortcuts
OnMessage(0x100, "WM_KEYDOWN")

; Show the GUI
Gui, Show, w460 w500, Sudoku
GeneratePuzzle()
return

CreateGrid() {
    global
    cellSize := 40
    thickPen := 3
    thinPen := 1
    
    ; Create the grid
    Gui, Add, Text, x10 y10 w%cellSize% h%cellSize% 0x201 vCell_0_0 gSelectCell, 
    
    Loop 8 {
        i := A_Index
        Loop 8 {
            j := A_Index
            xPos := 10 + (j * cellSize)
            yPos := 10 + (i * cellSize)
            Gui, Add, Text, x%xPos% y%yPos% w%cellSize% h%cellSize% 0x201 vCell_%i%_%j% gSelectCell, 
        }
    }
    
    ; Draw the grid lines
    Gui, Add, Progress, x10 y10 w%cellSize% h%cellSize% BackgroundWhite -Smooth, 100
    Loop 8 {
        i := A_Index
        xPos := 10 + (i * cellSize)
        Gui, Add, Progress, x%xPos% y10 w%thickPen% h%cellSize% BackgroundBlack, 100
        Gui, Add, Progress, x10 y%xPos% w%cellSize% h%thickPen% BackgroundBlack, 100
    }
}

SelectCell() {
    global selectedCell
    
    ; Get the cell coordinates from the control name
    RegExMatch(A_GuiControl, "Cell_(\d+)_(\d+)", cell)
    selectedCell.row := cell1
    selectedCell.col := cell2
    
    ; Update UI to show selected cell
    UpdateUI()
}

UpdateUI() {
    global board, original, selectedCell
    
    ; Update all cells
    for i, row in board {
        for j, val in row {
            cellValue := val = 0 ? "" : val
            GuiControl,, Cell_%i%_%j%, %cellValue%
            
            ; Style the cell based on whether it's an original number or user input
            if (original[i][j] != 0) {
                Gui, Font, s12 Bold
                GuiControl, Font, Cell_%i%_%j%
                GuiControl, +cBlue, Cell_%i%_%j%
            } else {
                Gui, Font, s12 Normal
                GuiControl, Font, Cell_%i%_%j%
                GuiControl, +cBlack, Cell_%i%_%j%
            }
            
            ; Highlight selected cell
            if (i = selectedCell.row && j = selectedCell.col) {
                GuiControl, +BackgroundYellow, Cell_%i%_%j%
            } else {
                GuiControl, +BackgroundWhite, Cell_%i%_%j%
            }
        }
    }
}

GeneratePuzzle() {
    global board, original, difficulty
    
    ; Initialize empty board
    board := []
    original := []
    
    ; Create empty 9x9 grid
    Loop 9 {
        i := A_Index
        board[i] := []
        original[i] := []
        Loop 9 {
            board[i][A_Index] := 0
            original[i][A_Index] := 0
        }
    }
    
    ; Generate a solved puzzle
    SolvePuzzle()
    
    ; Store the solution
    solution := []
    for i, row in board {
        solution[i] := []
        for j, val in row {
            solution[i][j] := val
        }
    }
    
    ; Remove numbers based on difficulty
    cellsToRemove := difficulty = "easy" ? 40 : (difficulty = "medium" ? 50 : 60)
    
    Loop %cellsToRemove% {
        ; Find a random cell that's not already empty
        while (true) {
            row := Random(1, 9)
            col := Random(1, 9)
            if (board[row][col] != 0) {
                board[row][col] := 0
                original[row][col] := 0
                break
            }
        }
    }
    
    ; Mark the remaining cells as original (not to be modified by user)
    for i, row in board {
        for j, val in row {
            if (val != 0) {
                original[i][j] := val
            }
        }
    }
    
    ; Update the UI
    UpdateUI()
    GuiControl,, Status, New game started (%difficulty%)
}

SolvePuzzle() {
    global board
    
    ; Find an empty cell
    cell := FindEmptyCell()
    if (!cell) {
        return true  ; Puzzle is solved
    }
    
    row := cell.row
    col := cell.col
    
    ; Try numbers 1-9
    Loop 9 {
        num := A_Index
        
        ; Check if the number is valid in this position
        if (IsValidMove(row, col, num)) {
            ; Try this number
            board[row][col] := num
            
            ; Recursively try to solve the rest of the puzzle
            if (SolvePuzzle()) {
                return true
            }
            
            ; If we get here, the number didn't work, so backtrack
            board[row][col] := 0
        }
    }
    
    ; Trigger backtracking
    return false
}

FindEmptyCell() {
    global board
    
    for i, row in board {
        for j, val in row {
            if (val = 0) {
                return {row: i, col: j}
            }
        }
    }
    
    return false  ; No empty cells found
}

IsValidMove(row, col, num) {
    global board
    
    ; Check row
    for j, val in board[row] {
        if (val = num && j != col) {
            return false
        }
    }
    
    ; Check column
    for i, r in board {
        if (r[col] = num && i != row) {
            return false
        }
    }
    
    ; Check 3x3 box
    boxStartRow := Floor((row - 1) / 3) * 3 + 1
    boxStartCol := Floor((col - 1) / 3) * 3 + 1
    
    Loop 3 {
        i := boxStartRow + A_Index - 1
        Loop 3 {
            j := boxStartCol + A_Index - 1
            if (board[i][j] = num && i != row && j != col) {
                return false
            }
        }
    }
    
    return true
}

NewGame:
    Gui, Submit, NoHide
    difficulty := Difficulty
    GeneratePuzzle()
return

CheckSolution:
    ; Check if the board is complete and correct
    if (IsBoardComplete() && IsBoardCorrect()) {
        GuiControl,, Status, Congratulations! You've solved the puzzle!
    } else {
        GuiControl,, Status, Keep trying! The puzzle isn't solved yet.
    }
return

IsBoardComplete() {
    global board
    
    for i, row in board {
        for j, val in row {
            if (val = 0) {
                return false
            }
        }
    }
    
    return true
}

IsBoardCorrect() {
    global board
    
    for i, row in board {
        for j, val in row {
            if (val != 0 && !IsValidMove(i, j, val)) {
                return false
            }
        }
    }
    
    return true
}

Solve:
    ; Solve the puzzle
    SolvePuzzle()
    UpdateUI()
    GuiControl,, Status, Puzzle solved!
return

WM_KEYDOWN(wParam, lParam) {
    global selectedCell, board, original
    
    ; Only process if a cell is selected
    if (selectedCell.row = 0 || selectedCell.col = 0) {
        return
    }
    
    ; Don't allow modifying original numbers
    if (original[selectedCell.row][selectedCell.col] != 0) {
        return
    }
    
    ; Handle number keys 1-9
    if (wParam >= 0x31 && wParam <= 0x39) {  ; 1-9
        num := wParam - 0x30  ; Convert to actual number
        board[selectedCell.row][selectedCell.col] := num
        GuiControl,, Cell_%selectedCell.row%_%selectedCell.col%, %num%
    } 
    ; Handle backspace/delete to clear cell
    else if (wParam = 0x08 || wParam = 0x2E) {  ; Backspace or Delete
        board[selectedCell.row][selectedCell.col] := 0
        GuiControl,, Cell_%selectedCell.row%_%selectedCell.col%,
    }
    
    ; Handle arrow keys to move selection
    else if (wParam = 0x25) {  ; Left arrow
        if (selectedCell.col > 1) {
            selectedCell.col--
            UpdateUI()
        }
    }
    else if (wParam = 0x27) {  ; Right arrow
        if (selectedCell.col < 9) {
            selectedCell.col++
            UpdateUI()
        }
    }
    else if (wParam = 0x26) {  ; Up arrow
        if (selectedCell.row > 1) {
            selectedCell.row--
            UpdateUI()
        }
    }
    else if (wParam = 0x28) {  ; Down arrow
        if (selectedCell.row < 9) {
            selectedCell.row++
            UpdateUI()
        }
    }
}

; Helper function to generate random numbers
Random(min, max) {
    Random, r, %min%, %max%
    return r
}

GuiClose:
    ExitApp
return
