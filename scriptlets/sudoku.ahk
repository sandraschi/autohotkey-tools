#Requires AutoHotkey v2.0
#SingleInstance Force
#Warn

; =============================================================================
; CONSTANTS AND CONFIGURATION
; =============================================================================
; Game settings
APP_TITLE := "Sudoku"
GRID_SIZE := 9
CELL_SIZE := 50
GRID_OFFSET_X := 20
GRID_OFFSET_Y := 20
THICK_LINE := 3
THIN_LINE := 1

; Colors
COLOR_BG := 0xFFFFFF
COLOR_TEXT := 0x000000
COLOR_SELECTED := 0xFFFF00
COLOR_HIGHLIGHT := 0xE6F3FF
COLOR_ERROR := 0xFFCCCC
COLOR_GRID := 0x000000
COLOR_NOTE := 0x808080

; =============================================================================
; GLOBAL VARIABLES
; =============================================================================
; Main GUI and controls
global guiSudoku
global statusBar
global cellControls := Map()
global guiControls := Map()

; Game state
global board := []
global solution := []
global original := []
global notes := []
global selectedCell := {row: 0, col: 0}

; Game settings
global difficulty := "medium"
global showHints := true
global showMistakes := true
global noteMode := false
global debugMode := false

; Control references
global difficultyDDL
global showHintsCB
global showMistakesCB

; =============================================================================
; MAIN WINDOW
; =============================================================================
; Create the main window
CreateGUI()

; =============================================================================
; HELPER FUNCTIONS
; =============================================================================
LogDebug(message) {
    global debugMode
    if (debugMode) {
        OutputDebug("[Sudoku] " . message)
    }
}

ValidateGUI() {
    global guiSudoku
    if (guiSudoku = "") {
        LogDebug("GUI instance not available")
        return false
    }
    return true
}

; =============================================================================
; GUI CREATION
; =============================================================================
CreateGUI() {
    global guiSudoku, statusBar, selectedCell, cellControls, guiControls
    
    try {
        ; Create main window
        guiSudoku := Gui("+Resize +MinSize500x600", APP_TITLE)
        guiSudoku.OnEvent("Close", (*) => ExitApp())
        guiSudoku.SetFont("s10", "Segoe UI")
        
        ; Initialize selected cell
        selectedCell := {row: 0, col: 0}
        
        ; Initialize cell controls map
        cellControls := Map()
        guiControls := Map()
    
    ; Create game board
    CreateBoard()
    
    ; Create control panel
    CreateControls()
    
    ; Status bar
    statusBar := guiSudoku.Add("StatusBar", , "Ready")
    guiControls["statusBar"] := statusBar
    
    ; Initialize hotkeys
    InitHotkeys()
    
    ; Show the window
    guiSudoku.Show("w500 h600")
    
    ; Generate initial puzzle
    GeneratePuzzle()
    LogDebug("Sudoku GUI created successfully")
    
    } catch as e {
        LogDebug("Error creating Sudoku GUI: " . e.Message)
        MsgBox("Error creating GUI: " . e.Message, "Error", "Iconx")
        throw
    }
}

CreateBoard() {
    global guiSudoku, cellControls, notes
    
    ; Create cells
    cellSize := CELL_SIZE
    thickPen := THICK_LINE
    
    ; Initialize arrays
    InitializeArrays()
    
    ; Create cells
    Loop GRID_SIZE {
        i := A_Index
        
        Loop GRID_SIZE {
            j := A_Index
            
            ; Calculate position with thicker borders for 3x3 boxes
            xOffset := Floor((j-1) / 3) * thickPen
            yOffset := Floor((i-1) / 3) * thickPen
            xPos := GRID_OFFSET_X + (j-1) * cellSize + xOffset
            yPos := GRID_OFFSET_Y + (i-1) * cellSize + yOffset
            
            ; Create cell
            cell := guiSudoku.Add("Text", 
                "x" xPos " y" yPos 
                . " w" cellSize " h" cellSize " 0x201 Border Center BackgroundWhite")
            
            ; Set cell properties
            cell.SetFont("s16 Bold", "Arial")
            
            ; Store cell control reference
            cellKey := i . "_" . j
            cellControls[cellKey] := cell
            
            ; Add click event
            cell.OnEvent("Click", SelectCell.Bind(i, j))
        }
    }
    
    ; Draw grid lines
    DrawGrid()
}

InitializeArrays() {
    global board, solution, original, notes
    
    ; Initialize empty 9x9 grids
    board := []
    solution := []
    original := []
    notes := []
    
    Loop GRID_SIZE {
        i := A_Index
        board.Push([])
        solution.Push([])
        original.Push([])
        notes.Push([])
        
        Loop GRID_SIZE {
            board[i].Push(0)
            solution[i].Push(0)
            original[i].Push(0)
            notes[i].Push([])
        }
    }
}

DrawGrid() {
    global guiSudoku
    
    ; Draw vertical lines
    Loop 10 {
        lineNum := A_Index - 1
        xOffset := Floor(lineNum / 3) * THICK_LINE
        xPos := GRID_OFFSET_X + lineNum * CELL_SIZE + xOffset
        lineWidth := (Mod(lineNum, 3) = 0) ? THICK_LINE : THIN_LINE
        
        guiSudoku.Add("Progress", "x" xPos " y" GRID_OFFSET_Y " w" lineWidth " h" (CELL_SIZE*9 + THICK_LINE*4) 
            . " Background0x000000 -Smooth", 100)
    }
    
    ; Draw horizontal lines
    Loop 10 {
        lineNum := A_Index - 1
        yOffset := Floor(lineNum / 3) * THICK_LINE
        yPos := GRID_OFFSET_Y + lineNum * CELL_SIZE + yOffset
        lineHeight := (Mod(lineNum, 3) = 0) ? THICK_LINE : THIN_LINE
        
        guiSudoku.Add("Progress", "x" GRID_OFFSET_X " y" yPos " w" (CELL_SIZE*9 + THICK_LINE*4) " h" lineHeight 
            . " Background0x000000 -Smooth", 100)
    }
}

CreateControls() {
    global guiSudoku, difficultyDDL, showHintsCB, showMistakesCB
    
    ; Game controls
    yPos := GRID_OFFSET_Y + (CELL_SIZE * 9) + 40
    
    ; Top row of buttons
    newGameBtn := guiSudoku.Add("Button", "x20 y" yPos " w100 h30", "&New Game")
    newGameBtn.OnEvent("Click", NewGame)
    
    checkBtn := guiSudoku.Add("Button", "x130 y" yPos " w100 h30", "&Check")
    checkBtn.OnEvent("Click", CheckSolution)
    
    hintBtn := guiSudoku.Add("Button", "x240 y" yPos " w100 h30", "&Hint")
    hintBtn.OnEvent("Click", ShowHint)
    
    solveBtn := guiSudoku.Add("Button", "x350 y" yPos " w100 h30", "&Solve")
    solveBtn.OnEvent("Click", SolvePuzzleButton)
    
    ; Second row of controls
    yPos += 40
    guiSudoku.Add("Text", "x20 y" yPos+5 " w60 h30", "Difficulty:")
    difficultyDDL := guiSudoku.Add("DropDownList", "x90 y" yPos " w100 Choose2", ["Easy", "Medium", "Hard", "Expert"])
    
    ; Toggle options
    showHintsCB := guiSudoku.Add("CheckBox", "x210 y" yPos " w100 h30 Checked", "Show Hints")
    showMistakesCB := guiSudoku.Add("CheckBox", "x320 y" yPos " w120 h30 Checked", "Show Mistakes")
    
    ; Number pad
    yPos += 40
    guiSudoku.Add("Text", "x20 y" yPos " w100 h30", "Number Pad:")
    yPos += 30
    
    ; Create number buttons 1-9 in 3x3 grid
    Loop 9 {
        i := A_Index
        row := Floor((i-1) / 3)
        col := Mod(i-1, 3)
        xPos := 20 + col * 40
        yPosBtn := yPos + row * 40
        
        btn := guiSudoku.Add("Button", "x" xPos " y" yPosBtn " w35 h35", i)
        btn.OnEvent("Click", NumberButton.Bind(i))
    }
    
    ; Add note button and clear button
    yPos += 120
    noteBtn := guiSudoku.Add("Button", "x200 y" yPos " w100 h35", "&Note Mode (N)")
    noteBtn.OnEvent("Click", ToggleNoteMode)
    
    clearBtn := guiSudoku.Add("Button", "x310 y" yPos " w100 h35", "&Clear (Del)")
    clearBtn.OnEvent("Click", ClearCell)
}

; =============================================================================
; GAME LOGIC
; =============================================================================
GeneratePuzzle() {
    global board, solution, original, notes, difficulty, difficultyDDL, statusBar
    
    ; Get selected difficulty
    diffText := difficultyDDL.Text
    difficulty := diffText ? StrLower(diffText) : "medium"
    
    ; Initialize arrays
    InitializeArrays()
    
    ; Generate a solved puzzle
    SolvePuzzle(solution)
    
    ; Determine number of cells to remove based on difficulty
    cellsToRemove := Map(
        "easy", 40,
        "medium", 50, 
        "hard", 55,
        "expert", 60
    )
    
    removeCount := cellsToRemove.Has(difficulty) ? cellsToRemove[difficulty] : 50
    
    ; Create a copy of the solution
    CopyArray(solution, board)
    
    ; Remove numbers to create the puzzle
    removed := 0
    attempts := 0
    maxAttempts := 200
    
    while (removed < removeCount && attempts < maxAttempts) {
        row := Random(1, GRID_SIZE)
        col := Random(1, GRID_SIZE)
        
        ; Skip if already empty
        if (board[row][col] = 0) {
            attempts++
            continue
        }
        
        ; Try removing this cell
        value := board[row][col]
        board[row][col] := 0
        
        ; For now, just remove cells (proper uniqueness check would be complex)
        original[row][col] := 0
        removed++
        attempts++
    }
    
    ; Mark the remaining cells as original
    Loop GRID_SIZE {
        i := A_Index
        Loop GRID_SIZE {
            j := A_Index
            if (board[i][j] != 0) {
                original[i][j] := board[i][j]
            }
        }
    }
    
    ; Update the UI
    UpdateUI()
    statusBar.Text := "New " difficulty " puzzle generated."
}

CopyArray(source, dest) {
    Loop source.Length {
        i := A_Index
        Loop source[i].Length {
            j := A_Index
            dest[i][j] := source[i][j]
        }
    }
}

SolvePuzzle(puzzle, row := 1, col := 1) {
    ; Find the next empty cell
    while (row <= GRID_SIZE) {
        while (col <= GRID_SIZE) {
            if (puzzle[row][col] = 0) {
                break 2
            }
            col++
        }
        row++
        col := 1
    }
    
    ; If we've gone past the grid, puzzle is solved
    if (row > GRID_SIZE) {
        return true
    }
    
    ; Try numbers 1-9
    numbers := [1,2,3,4,5,6,7,8,9]
    ShuffleArray(&numbers)
    
    for num in numbers {
        if (IsValidMove(puzzle, row, col, num)) {
            ; Try this number
            puzzle[row][col] := num
            
            ; Recursively try to solve the rest
            if (SolvePuzzle(puzzle, row, col)) {
                return true
            }
            
            ; If we get here, the number didn't work, so backtrack
            puzzle[row][col] := 0
        }
    }
    
    return false  ; Trigger backtracking
}

IsValidMove(puzzle, row, col, num) {
    ; Check row
    Loop GRID_SIZE {
        j := A_Index
        if (puzzle[row][j] = num && j != col) {
            return false
        }
    }
    
    ; Check column
    Loop GRID_SIZE {
        i := A_Index
        if (puzzle[i][col] = num && i != row) {
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
            if (puzzle[i][j] = num && (i != row || j != col)) {
                return false
            }
        }
    }
    
    return true
}

; =============================================================================
; UI UPDATES
; =============================================================================
UpdateUI() {
    global cellControls, board, original, notes, selectedCell, showMistakesCB, solution, showMistakes
    
    showMistakes := showMistakesCB.Value
    
    Loop GRID_SIZE {
        i := A_Index
        Loop GRID_SIZE {
            j := A_Index
            cellValue := board[i][j]
            cellKey := i . "_" . j
            cellControl := cellControls[cellKey]
            
            ; Update cell appearance
            if (cellValue != 0) {
                ; Show number
                cellControl.Text := cellValue
                
                ; Style based on whether it's an original number or user input
                if (original[i][j] != 0) {
                    cellControl.SetFont("s16 Bold c0x0000FF", "Arial")  ; Blue for original numbers
                } else {
                    ; Check for mistakes if enabled
                    if (showMistakes && cellValue != 0 && cellValue != solution[i][j]) {
                        cellControl.SetFont("s16 Bold c0xFF0000", "Arial")  ; Red for mistakes
                    } else {
                        cellControl.SetFont("s16 c0x000000", "Arial")  ; Black for user input
                    }
                }
            } else {
                ; Show notes if any
                cellNotes := notes[i][j]
                if (cellNotes.Length > 0) {
                    ; Create a simple note display
                    noteText := ""
                    for note in cellNotes {
                        noteText .= note . " "
                    }
                    cellControl.Text := Trim(noteText)
                    cellControl.SetFont("s8 c0x808080", "Arial")  ; Gray for notes
                } else {
                    cellControl.Text := ""
                }
            }
            
            ; Highlight selected cell
            if (i = selectedCell.row && j = selectedCell.col) {
                cellControl.Opt("+BackgroundYellow")
            } else {
                cellControl.Opt("+BackgroundWhite")
            }
        }
    }
}

; =============================================================================
; EVENT HANDLERS
; =============================================================================
SelectCell(row, col, *) {
    global selectedCell
    
    selectedCell := {row: row, col: col}
    UpdateUI()
}

NumberButton(num, *) {
    global board, original, notes, selectedCell, statusBar
    
    ; Check if a cell is selected and it's not an original number
    if (selectedCell.row = 0 || selectedCell.col = 0 || original[selectedCell.row][selectedCell.col] != 0) {
        return
    }
    
    ; Toggle the number in the selected cell
    if (board[selectedCell.row][selectedCell.col] = num) {
        ; If the number is already set, clear it
        board[selectedCell.row][selectedCell.col] := 0
    } else {
        ; Otherwise, set the number
        board[selectedCell.row][selectedCell.col] := num
        notes[selectedCell.row][selectedCell.col] := []  ; Clear notes when setting a number
    }
    
    ; Check if the puzzle is complete
    if (IsBoardComplete() && IsBoardCorrect()) {
        statusBar.Text := "Congratulations! You've solved the puzzle!"
    }
    
    UpdateUI()
}

ToggleNoteMode(*) {
    global noteMode, statusBar
    
    ; Toggle the note mode
    noteMode := !noteMode
    
    statusBar.Text := noteMode ? "Note mode: ON" : "Note mode: OFF"
}

ClearCell(*) {
    global board, original, notes, selectedCell, statusBar
    
    row := selectedCell.row
    col := selectedCell.col
    
    ; Check for invalid cell
    if (row = 0 || col = 0) {
        return
    }
    
    ; Check if the cell is not an original number
    if (original[row][col] = 0) {
        ; Clear the cell
        board[row][col] := 0
        
        ; Clear any notes for this cell
        notes[row][col] := []
        
        ; Update the UI
        UpdateUI()
        statusBar.Text := "Cell cleared"
    } else {
        statusBar.Text := "Cannot clear an original number"
    }
}

NewGame(*) {
    GeneratePuzzle()
}

CheckSolution(*) {
    global statusBar
    
    if (IsBoardComplete()) {
        if (IsBoardCorrect()) {
            statusBar.Text := "Congratulations! The solution is correct!"
        } else {
            statusBar.Text := "The solution is not correct. Keep trying!"
        }
    } else {
        statusBar.Text := "The puzzle is not complete yet!"
    }
}

ShowHint(*) {
    global board, solution, selectedCell, showHintsCB, statusBar
    
    if (!showHintsCB.Value) {
        statusBar.Text := "Hints are disabled. Enable them in the options."
        return
    }
    
    ; If a cell is selected, show the correct number
    if (selectedCell.row != 0 && selectedCell.col != 0) {
        if (board[selectedCell.row][selectedCell.col] = 0) {
            board[selectedCell.row][selectedCell.col] := solution[selectedCell.row][selectedCell.col]
            statusBar.Text := "Hint: The correct number is " solution[selectedCell.row][selectedCell.col]
            UpdateUI()
            
            ; Check if the puzzle is complete
            if (IsBoardComplete() && IsBoardCorrect()) {
                statusBar.Text := "Congratulations! You've solved the puzzle with a hint!"
            }
        } else {
            statusBar.Text := "This cell already has a number. Select an empty cell for a hint."
        }
    } else {
        ; Find the first empty cell and fill it
        found := false
        Loop GRID_SIZE {
            i := A_Index
            Loop GRID_SIZE {
                j := A_Index
                if (board[i][j] = 0) {
                    board[i][j] := solution[i][j]
                    selectedCell := {row: i, col: j}
                    statusBar.Text := "Hint: Filled in one empty cell"
                    UpdateUI()
                    found := true
                    break 2
                }
            }
        }
        
        if (!found) {
            statusBar.Text := "The puzzle is already complete!"
        }
    }
}

SolvePuzzleButton(*) {
    global board, solution, original, statusBar
    
    ; Confirm before solving
    result := MsgBox("This will solve the puzzle for you. Continue?", "Solve Puzzle", "YesNo")
    if (result = "No") {
        return
    }
    
    ; Copy solution to board
    Loop GRID_SIZE {
        i := A_Index
        Loop GRID_SIZE {
            j := A_Index
            if (original[i][j] = 0) {  ; Only fill in empty cells
                board[i][j] := solution[i][j]
            }
        }
    }
    
    UpdateUI()
    statusBar.Text := "Puzzle solved!"
}

; =============================================================================
; HELPER FUNCTIONS
; =============================================================================
IsBoardComplete() {
    global board
    
    Loop GRID_SIZE {
        i := A_Index
        Loop GRID_SIZE {
            j := A_Index
            if (board[i][j] = 0) {
                return false
            }
        }
    }
    
    return true
}

IsBoardCorrect() {
    global board
    
    Loop GRID_SIZE {
        i := A_Index
        Loop GRID_SIZE {
            j := A_Index
            if (board[i][j] != 0 && !IsValidMove(board, i, j, board[i][j])) {
                return false
            }
        }
    }
    
    return true
}

ShuffleArray(&arr) {
    ; Fisher-Yates shuffle algorithm
    Loop arr.Length {
        i := A_Index
        j := Random(1, arr.Length)
        if (i != j) {
            temp := arr[i]
            arr[i] := arr[j]
            arr[j] := temp
        }
    }
}

; =============================================================================
; KEYBOARD HANDLING
; =============================================================================
HandleNumberKey(num) {
    global noteMode, board, original, notes, selectedCell, statusBar
    
    ; Get cell position
    cellRow := selectedCell.row
    cellCol := selectedCell.col
    
    ; Check for invalid selection and original numbers
    if (cellRow = 0 || cellCol = 0 || original[cellRow][cellCol] != 0) {
        return
    }
    
    ; Handle note mode
    if (noteMode) {
        ; Toggle note
        currentNotes := notes[cellRow][cellCol]
        
        ; Check if note exists
        found := false
        foundIndex := 0
        Loop currentNotes.Length {
            if (currentNotes[A_Index] = num) {
                found := true
                foundIndex := A_Index
                break
            }
        }
        
        if (found) {
            currentNotes.RemoveAt(foundIndex)
        } else {
            currentNotes.Push(num)
        }
    } else {
        ; Set number or clear if same number pressed
        currentVal := board[cellRow][cellCol]
        if (currentVal = num) {
            board[cellRow][cellCol] := 0
        } else {
            board[cellRow][cellCol] := num
            notes[cellRow][cellCol] := []  ; Clear notes
        }
        
        ; Check for win
        if (IsBoardComplete() && IsBoardCorrect()) {
            statusBar.Text := "Congratulations! You've solved the puzzle!"
        }
    }
    
    ; Update the UI
    UpdateUI()
}

MoveSelection(rowDelta, colDelta) {
    global selectedCell
    
    if (selectedCell.row = 0 || selectedCell.col = 0) {
        return
    }
    
    newRow := selectedCell.row + rowDelta
    newCol := selectedCell.col + colDelta
    
    ; Keep within bounds
    if (newRow < 1) newRow := 1
    if (newRow > GRID_SIZE) newRow := GRID_SIZE
    if (newCol < 1) newCol := 1
    if (newCol > GRID_SIZE) newCol := GRID_SIZE
    
    selectedCell := {row: newRow, col: newCol}
    UpdateUI()
}

; Initialize hotkeys
InitHotkeys() {
    ; Handle number keys 1-9
    Loop 9 {
        num := A_Index
        Hotkey(num, (*) => HandleNumberKey(num))
    }
    
    ; Handle arrow keys for navigation
    Hotkey("Left", (*) => MoveSelection(0, -1))
    Hotkey("Right", (*) => MoveSelection(0, 1))
    Hotkey("Up", (*) => MoveSelection(-1, 0))
    Hotkey("Down", (*) => MoveSelection(1, 0))
    
    ; Handle backspace/delete to clear cell
    Hotkey("Backspace", (*) => ClearCell())
    Hotkey("Delete", (*) => ClearCell())
    
    ; Toggle note mode with N
    Hotkey("n", (*) => ToggleNoteMode())
}

; =============================================================================
; MAIN ENTRY POINT
; =============================================================================
; Initialize the game
CreateSudokuGUI()
SetupGameHotkeys()
StartNewGame()
