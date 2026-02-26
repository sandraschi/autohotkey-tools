#Requires AutoHotkey v2.0
#SingleInstance Force
#Warn All, Off

; Set working directory to the script's location
SetWorkingDir(A_ScriptDir)

; Global variables
global launcherGui := {}
global scriptlets := Map()

; Initialize the launcher
InitLauncher()

; Create the main GUI
CreateGui()

; Load all scriptlets
LoadScriptlets()

; Show the GUI
launcherGui.Show("w900 h700")

; Set tray icon and tooltip
TraySetIcon("shell32.dll", 4)
TraySetToolTip("Scriptlet Launcher v2`nPress F1 for help")

; Register hotkeys
#HotIf WinActive("ahk_id " launcherGui.Hwnd)
Hotkey("F1", ShowHelp)
Hotkey("#l", ReloadLauncher)
#HotIf

; ==============================================================================
; INITIALIZATION
; ==============================================================================

InitLauncher() {
    ; Create necessary directories
    for dir in ["scriptlets\utilities", "scriptlets\fun", "scriptlets\development", "scriptlets\games", "lib"] {
        DirCreate(dir)
    }
    
    ; Add scriptlets directory to include path
    if (!InStr(A_MyDocuments, A_ScriptDir "\lib")) {
        A_MyDocuments := A_MyDocuments ";" A_ScriptDir "\lib"
    }
}

; ==============================================================================
; GUI CREATION
; ==============================================================================

CreateGui() {
    ; Create the main window
    launcherGui := Gui("+Resize +MinSize800x600", "Scriptlet Launcher v2")
    
    ; Set up the menu
    menuBar := Menu()
    fileMenu := Menu()
    fileMenu.Add("&Reload", ReloadLauncher)
    fileMenu.Add("E&xit", (*) => ExitApp())
    
    helpMenu := Menu()
    helpMenu.Add("&Help", ShowHelp)
    helpMenu.Add("&About", ShowAbout)
    
    menuBar.Add("&File", fileMenu)
    menuBar.Add("&Help", helpMenu)
    
    launcherGui.MenuBar := menuBar
    
    ; Set up the main layout
    launcherGui.SetFont("s10", "Segoe UI")
    launcherGui.MarginX := 10
    launcherGui.MarginY := 10
    
    ; Add a search box
    launcherGui.Add("Text", "w200", "Search:")
    searchBox := launcherGui.Add("Edit", "w600 vSearchTerm")
    searchBox.OnEvent("Change", FilterScriptlets)
    
    ; Add a tab control for categories
    tab := launcherGui.Add("Tab3", "w880 h580 vMainTabs", ["All", "Utilities", "Development", "Fun", "Games"])
    
    ; Create list views for each category
    tab.UseTab(1)
    allList := launcherGui.Add("ListView", "w860 h550 vAllList -Multi", ["Name", "Description", "Hotkey"])
    
    tab.UseTab(2)
    utilList := launcherGui.Add("ListView", "w860 h550 vUtilList -Multi", ["Name", "Description", "Hotkey"])
    
    tab.UseTab(3)
    devList := launcherGui.Add("ListView", "w860 h550 vDevList -Multi", ["Name", "Description", "Hotkey"])
    
    tab.UseTab(4)
    funList := launcherGui.Add("ListView", "w860 h550 vFunList -Multi", ["Name", "Description", "Hotkey"])
    
    tab.UseTab(5)
    gameList := launcherGui.Add("ListView", "w860 h550 vGameList -Multi", ["Name", "Description", "Hotkey"])
    
    tab.UseTab()
    
    ; Add status bar
    statusBar := launcherGui.Add("StatusBar", , "Ready")
    
    ; Store references
    launcherGui.StatusBar := statusBar
    launcherGui.Tab := tab
    launcherGui.Lists := [allList, utilList, devList, funList, gameList]
    launcherGui.SearchBox := searchBox
    
    ; Handle double-clicks and Enter key
    for list in launcherGui.Lists {
        list.OnEvent("DoubleClick", RunSelectedScriptlet)
        list.OnEvent("DoubleClick", "Enter", RunSelectedScriptlet)
    }
    
    ; Handle window resizing
    launcherGui.OnEvent("Size", GuiSize)
}

; ==============================================================================
; SCRIPTLET MANAGEMENT
; ==============================================================================

LoadScriptlets() {
    ; Clear existing scriptlets
    scriptlets := Map()
    
    ; Get all .ahk files in scriptlets directory and subdirectories
    scriptletFiles := []
    Loop Files "scriptlets\**\*.ahk" {
        if (A_LoopFileName != "_base.ahk") {
            scriptletFiles.Push(A_LoopFilePath)
        }
    }
    
    ; Load each scriptlet
    for file in scriptletFiles {
        try {
            ; Use a separate thread to load the scriptlet
            scriptletThread := Critical()
            scriptletThread.Exec("#SingleInstance Off`n#Include " file)
        } catch Error as e {
            UpdateStatus("Error loading " file ": " e.Message)
            OutputDebug("Error loading " file ": " e.Message "`n" e.What "`n" e.Extra "`n" e.File ":" e.Line)
        }
    }
    
    ; Update the UI
    UpdateScriptletLists()
}

; Called by scriptlets to register themselves
RegisterScriptlet(scriptletClass) {
    scriptlets[scriptletClass.name] := scriptletClass
    UpdateScriptletLists()
}

UpdateScriptletLists() {
    if (!IsObject(launcherGui) || !launcherGui.HasOwnProp("Lists"))
        return
    
    ; Clear all lists
    for list in launcherGui.Lists {
        list.Delete()
    }
    
    ; Get search term
    searchTerm := ""
    try {
        searchTerm := launcherGui.SearchBox.Value
    }
    
    ; Add scriptlets to appropriate lists
    for name, scriptlet in scriptlets {
        ; Skip if doesn't match search term
        if (searchTerm && !InStr(name, searchTerm) && !InStr(scriptlet.description, searchTerm)) {
            continue
        }
        
        ; Add to All list
        launcherGui.Lists[1].Add(, name, scriptlet.description, scriptlet.hotkey)
        
        ; Add to category list
        categoryList := GetCategoryList(scriptlet.category)
        if (categoryList) {
            categoryList.Add(, name, scriptlet.description, scriptlet.hotkey)
        }
    }
    
    ; Sort and resize columns
    for list in launcherGui.Lists {
        list.ModifyCol()
    }
    
    UpdateStatus("Loaded " scriptlets.Count " scriptlets")
}

GetCategoryList(category) {
    switch category, false {
        case "Utilities": return launcherGui.Lists[2]
        case "Development": return launcherGui.Lists[3]
        case "Fun": return launcherGui.Lists[4]
        case "Games": return launcherGui.Lists[5]
        default: return launcherGui.Lists[1] ; Default to All
    }
}

RunSelectedScriptlet(ctrl, info) {
    row := ctrl.GetNext(0)
    if (!row) {
        return
    }
    
    name := ctrl.GetText(row, 1)
    if (scriptlets.Has(name)) {
        try {
            scriptlets[name].Run()
            UpdateStatus("Started: " name)
        } catch Error as e {
            UpdateStatus("Error running " name ": " e.Message)
            MsgBox("Error running " name ":`n" e.Message, "Error", 16)
        }
    }
}

FilterScriptlets(ctrl, info) {
    UpdateScriptletLists()
}

; ==============================================================================
; HELPER FUNCTIONS
; ==============================================================================

UpdateStatus(message) {
    if (launcherGui.HasOwnProp("StatusBar")) {
        launcherGui.StatusBar.Text := message
    }
}

ShowHelp() {
    helpText := ""
    helpText .= "Scriptlet Launcher Help`n"
    helpText .= "---------------------`n`n"
    helpText .= "• Double-click or press Enter to run a scriptlet`n"
    helpText .= "• Use the search box to filter scriptlets`n"
    helpText .= "• Right-click for more options`n`n"
    helpText .= "Hotkeys:`n"
    helpText .= "- Win+L: Reload the launcher`n"
    helpText .= "- F1: Show this help"
    
    MsgBox(helpText, "Scriptlet Launcher Help", "T2")
}

ShowAbout() {
    MsgBox("Scriptlet Launcher v2.0`n`nA modern launcher for AutoHotkey scriptlets", "About", "T1")
}

ReloadLauncher(*) {
    Reload()
}

GuiSize(GuiObj, MinMax, Width, Height) {
    if (MinMax = -1)  ; Window is minimized
        return
    
    ; Resize controls
    try {
        ctrlW := Width - 30
        ctrlH := Height - 100
        
        ; Resize tab control
        launcherGui["MainTabs"].Move(, , ctrlW + 20, ctrlH + 30)
        
        ; Resize listviews
        for list in launcherGui.Lists {
            list.Move(, , ctrlW, ctrlH - 20)
            list.ModifyCol(1, "AutoHdr")
            list.ModifyCol(2, "AutoHdr")
            list.ModifyCol(3, "AutoHdr")
        }
        
        ; Resize search box
        launcherGui.SearchBox.Move(, , ctrlW - 210)
        
    } catch Error as e {
        OutputDebug("Error in GuiSize: " e.Message "`n" e.What "`n" e.Extra "`n" e.File ":" e.Line)
    }
}

; ==============================================================================
; SCRIPTLET BASE CLASS
; ==============================================================================

class Scriptlet {
    name := "Untitled Scriptlet"
    description := "No description available"
    category := "Uncategorized"
    hotkey := ""
    
    __New() {
        ; Register this scriptlet with the launcher
        RegisterScriptlet(this)
    }
    
    Run() {
        ; To be implemented by derived classes
        MsgBox("This scriptlet has no Run() method defined.", "Error", 16)
    }
}

; ==============================================================================
; AUTO-EXECUTE SECTION
; ==============================================================================

; Register script exit handler
OnExit(ExitFunc)

ExitFunc(ExitReason, ExitCode) {
    ; Clean up resources here if needed
    return 0
}
