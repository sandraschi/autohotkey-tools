#Requires AutoHotkey v2.0
#SingleInstance Force
#Warn

; Set working directory to the script's location
SetWorkingDir(A_ScriptDir)

; Global variables
global launcherGui
scriptlets := Map()

; Include the base scriptlet class
#Include scriptlets\_base.ahk

; Initialize the launcher
InitLauncher()

; Create the main GUI
CreateGui()

; Load all scriptlets
LoadScriptlets()

; Show the GUI
launcherGui.Show("w900 h700")

; Set tray icon and tooltip
TraySetIcon "shell32.dll", 4
TraySetToolTip "Scriptlet Launcher`nPress F1 for help"

; Register hotkeys
#h:: ShowHelp()
#l:: ReloadLauncher()

; Main functions
InitLauncher() {
    ; Create necessary directories
    DirCreate("scriptlets\utilities")
    DirCreate("scriptlets\fun")
    DirCreate("scriptlets\development")
    DirCreate("scriptlets\games")
    DirCreate("lib")
    
    ; Add scriptlets directory to include path
    A_MyDocuments .= "\AutoHotkey\Lib"
    if (!InStr(A_MyDocuments, A_ScriptDir "\lib")) {
        A_MyDocuments .= ";" A_ScriptDir "\lib"
    }
}

CreateGui() {
    ; Create the main window
    launcherGui := Gui("+Resize", "Scriptlet Launcher")
    
    ; Set up the menu
    menuBar := Menu()
    menuBar.Add("&File", ["Reload", "Exit"])
    menuBar.Add("&Help", "Help")
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
    tab := launcherGui.Add("Tab3", "w800 h550 vMainTabs", ["All", "Utilities", "Development", "Fun", "Games"])
    
    ; Create list views for each category
    tab.UseTab(1)
    allList := launcherGui.Add("ListView", "w780 h500 vAllList", ["Name", "Description", "Hotkey"])
    
    tab.UseTab(2)
    utilList := launcherGui.Add("ListView", "w780 h500 vUtilList", ["Name", "Description", "Hotkey"])
    
    tab.UseTab(3)
    devList := launcherGui.Add("ListView", "w780 h500 vDevList", ["Name", "Description", "Hotkey"])
    
    tab.UseTab(4)
    funList := launcherGui.Add("ListView", "w780 h500 vFunList", ["Name", "Description", "Hotkey"])
    
    tab.UseTab(5)
    gameList := launcherGui.Add("ListView", "w780 h500 vGameList", ["Name", "Description", "Hotkey"])
    
    tab.UseTab()
    
    ; Add status bar
    statusBar := launcherGui.Add("StatusBar",, "Ready")
    
    ; Store references
    launcherGui.statusBar := statusBar
    launcherGui.tab := tab
    launcherGui.lists := [allList, utilList, devList, funList, gameList]
    
    ; Handle double-clicks
    for list in launcherGui.lists {
        list.OnEvent("DoubleClick", RunSelectedScriptlet)
    }
}

LoadScriptlets() {
    ; Clear existing scriptlets
    scriptlets := Map()
    
    ; Get all .ahk files in scriptlets directory and subdirectories
    scriptletFiles := []
    Loop Files "scriptlets\**\*.ahk" {
        if (A_LoopFileName != "_base.ahk") {
            scriptletFiles.Push(A_LoopFileFullPath)
        }
    }
    
    ; Load each scriptlet
    for file in scriptletFiles {
        try {
            ; Use a separate thread to load the scriptlet
            scriptletThread := Critical()
            scriptletThread.Exec("#SingleInstance Off\n#Include " file)
            
            ; The scriptlet should register itself via Init()
            ; We'll add it to our list in the OnMessage handler
        } catch as e {
            statusBar.Text := "Error loading " file ": " e.Message
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
    if (!IsObject(launcherGui) || !launcherGui.HasProp("lists"))
        return
    
    ; Clear all lists
    for list in launcherGui.lists {
        list.Delete()
    }
    
    ; Get search term
    searchTerm := ""
    try {
        searchTerm := launcherGui["SearchTerm"].Value
    }
    
    ; Add scriptlets to appropriate lists
    for name, scriptlet in scriptlets {
        ; Skip if doesn't match search term
        if (searchTerm && !InStr(name, searchTerm) && !InStr(scriptlet.description, searchTerm)) {
            continue
        }
        
        ; Add to All list
        launcherGui.lists[1].Add("", name, scriptlet.description, scriptlet.hotkey)
        
        ; Add to category list
        categoryList := GetCategoryList(scriptlet.category)
        if (categoryList) {
            categoryList.Add("", name, scriptlet.description, scriptlet.hotkey)
        }
    }
    
    ; Sort and resize columns
    for list in launcherGui.lists {
        list.ModifyCol()
    }
}

GetCategoryList(category) {
    switch category {
        case "Utilities": return launcherGui.lists[2]
        case "Development": return launcherGui.lists[3]
        case "Fun": return launcherGui.lists[4]
        case "Games": return launcherGui.lists[5]
        default: return launcherGui.lists[1] ; Default to All
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
        } catch as e {
            MsgBox "Error running " name ":" e.Message, "Error", "Icon!"
        }
    }
}

FilterScriptlets(ctrl, info) {
    UpdateScriptletLists()
}

ShowHelp() {
    helpText := """
    Scriptlet Launcher Help
    ====================
    
    [F1] - Show this help
    [Win+H] - Show/hide launcher
    [Win+L] - Reload all scriptlets
    
    Double-click a scriptlet to run it.
    Use the search box to filter scriptlets.
    
    Scriptlets are loaded from the 'scriptlets' directory.
    Each scriptlet should be in its own .ahk file.
    """
    
    MsgBox(helpText, "Scriptlet Launcher Help")
}

ReloadLauncher() {
    Reload
}

; Handle menu events
Reload(*) {
    ReloadLauncher()
}

Exit(*) {
    ExitApp
}

Help(*) {
    ShowHelp()
}

; Handle window close
launcherGui.OnEvent("Close", (*) => ExitApp())
launcherGui.OnEvent("Escape", (*) => launcherGui.Hide())

; Message handler for scriptlet registration
OnMessage(0x4A, RegisterScriptlet)  ; WM_COPYDATA

; Show/hide with Win+H
#h:: {
    if (launcherGui.Visible) {
        launcherGui.Hide()
    } else {
        launcherGui.Show()
        launcherGui.Restore()
    }
}

; Run when the script starts
#Include <_base>

; Export the RegisterScriptlet function for scriptlets to use
RegisterScriptlet(scriptletClass) {
    scriptlets[scriptletClass.name] := scriptletClass
    UpdateScriptletLists()
}
