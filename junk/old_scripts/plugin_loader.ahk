#Requires AutoHotkey v2.0+
; =============================================================================
; PluginLoader.ahk - Dynamic Plugin Loading System
; Version: 1.0
; Author: Sandra (with Claude assistance)
; Purpose: Integrate PluginManager with existing launcher system
; =============================================================================

#SingleInstance Force
#Warn

SetWorkingDir A_ScriptDir

; Include required classes
#Include "utils/ConfigManager.ahk"
#Include "utils/PluginManager.ahk"
#Include "utils/TestFramework.ahk"

; =============================================================================
; INITIALIZATION
; =============================================================================

; Initialize configuration and plugin management
ConfigManager.Init()
PluginManager.Init()

; Load enabled plugins
LoadEnabledPlugins()

; Set up hotkeys for plugin management
SetupPluginHotkeys()

; =============================================================================
; PLUGIN LOADING FUNCTIONS
; =============================================================================

LoadEnabledPlugins() {
    LogOperation("Loading enabled plugins...")
    
    local loadedCount := PluginManager.LoadAllPlugins()
    local stats := PluginManager.GetPluginStats()
    
    LogOperation("Plugin loading complete:")
    LogOperation("  Total plugins: " . stats["total"])
    LogOperation("  Enabled plugins: " . stats["enabled"])
    LogOperation("  Loaded plugins: " . stats["loaded"])
    LogOperation("  Categories: " . stats["categories"])
    
    ; Show notification
    TrayTip("Loaded " . loadedCount . " plugins", "PluginLoader", "1")
}

LoadPluginsByCategory(category) {
    LogOperation("Loading plugins from category: " . category)
    
    local loadedCount := PluginManager.LoadPluginsByCategory(category)
    
    if (loadedCount > 0) {
        TrayTip("Loaded " . loadedCount . " plugins from " . category, "PluginLoader", "1")
    }
    
    return loadedCount
}

ReloadAllPlugins() {
    LogOperation("Reloading all plugins...")
    
    ; Unload all currently loaded plugins
    for pluginName in PluginManager.loadedPlugins {
        PluginManager.UnloadPlugin(pluginName)
    }
    
    ; Reload enabled plugins
    LoadEnabledPlugins()
}

ReloadPlugin(pluginName) {
    LogOperation("Reloading plugin: " . pluginName)
    
    ; Unload if currently loaded
    if (PluginManager.loadedPlugins.Has(pluginName)) {
        PluginManager.UnloadPlugin(pluginName)
    }
    
    ; Load the plugin
    if (PluginManager.LoadPlugin(pluginName)) {
        TrayTip("Reloaded plugin: " . pluginName, "PluginLoader", "1")
        return true
    } else {
        TrayTip("Failed to reload plugin: " . pluginName, "PluginLoader", "2")
        return false
    }
}

; =============================================================================
; PLUGIN MANAGEMENT GUI
; =============================================================================

ShowPluginManager() {
    local gui := Gui(, "Plugin Manager - AutoHotkey Repository")
    gui.SetFont("s10", "Segoe UI")
    gui.MarginX := 20
    gui.MarginY := 15
    
    ; Add title and stats
    gui.Add("Text", "w800", "Plugin Manager")
    gui.Add("Text", "w800 cGray", "Manage your AutoHotkey scriptlets and plugins")
    gui.Add("Text", "w800", "") ; Spacer
    
    ; Show plugin statistics
    local stats := PluginManager.GetPluginStats()
    gui.Add("Text", "w800", "Plugin Statistics:")
    gui.Add("Text", "w800 cGray", "Total: " . stats["total"] . " | Enabled: " . stats["enabled"] . " | Loaded: " . stats["loaded"] . " | Categories: " . stats["categories"])
    gui.Add("Text", "w800", "") ; Spacer
    
    ; Create tabs for different views
    local tab := gui.Add("Tab3", "w800 h500", ["All Plugins", "By Category", "Loaded Plugins", "Settings"])
    
    ; ========== ALL PLUGINS TAB ==========
    tab.UseTab(1)
    gui.Add("Text", "w760", "All Available Plugins")
    gui.Add("Text", "w760 cGray", "Double-click to toggle enable/disable")
    
    local lvAll := gui.Add("ListView", "w760 h400", ["Name", "Version", "Category", "Status", "Priority"])
    
    ; Populate all plugins list
    for pluginName, plugin in PluginManager.plugins {
        local status := plugin["enabled"] ? "Enabled" : "Disabled"
        if (PluginManager.loadedPlugins.Has(pluginName)) {
            status .= " (Loaded)"
        }
        
        lvAll.Add(, plugin["name"], plugin["metadata"]["version"], plugin["category"], status, plugin["priority"])
    }
    
    ; ========== BY CATEGORY TAB ==========
    tab.UseTab(2)
    gui.Add("Text", "w760", "Plugins by Category")
    
    local lvCategory := gui.Add("ListView", "w760 h400", ["Category", "Plugin Count", "Loaded Count"])
    
    ; Populate categories list
    for category, plugins in PluginManager.categories {
        local loadedCount := 0
        for plugin in plugins {
            if (PluginManager.loadedPlugins.Has(plugin["name"])) {
                loadedCount++
            }
        }
        
        lvCategory.Add(, category, plugins.Length, loadedCount)
    }
    
    ; ========== LOADED PLUGINS TAB ==========
    tab.UseTab(3)
    gui.Add("Text", "w760", "Currently Loaded Plugins")
    
    local lvLoaded := gui.Add("ListView", "w760 h400", ["Name", "Version", "Category", "Load Time"])
    
    ; Populate loaded plugins list
    for pluginName, plugin in PluginManager.loadedPlugins {
        lvLoaded.Add(, plugin["name"], plugin["metadata"]["version"], plugin["category"], "Unknown")
    }
    
    ; ========== SETTINGS TAB ==========
    tab.UseTab(4)
    gui.Add("Text", "w760", "Plugin Manager Settings")
    
    local cbAutoDiscovery := gui.Add("CheckBox", "w760", "Enable automatic plugin discovery")
    local cbAutoLoad := gui.Add("CheckBox", "w760", "Auto-load enabled plugins on startup")
    local cbHotkeyCheck := gui.Add("CheckBox", "w760", "Check for hotkey conflicts")
    local cbDependencyResolve := gui.Add("CheckBox", "w760", "Auto-resolve dependencies")
    
    ; Load current settings
    cbAutoDiscovery.Value := true
    cbAutoLoad.Value := true
    cbHotkeyCheck.Value := true
    cbDependencyResolve.Value := true
    
    ; Add buttons
    gui.Add("Text", "w800", "") ; Spacer
    
    local btnReloadAll := gui.Add("Button", "w120", "Reload All")
    local btnRefresh := gui.Add("Button", "x+10 w120", "Refresh")
    local btnExport := gui.Add("Button", "x+10 w120", "Export List")
    local btnClose := gui.Add("Button", "x+10 w120", "Close")
    
    ; Button event handlers
    btnReloadAll.OnEvent("Click", (*) => {
        ReloadAllPlugins()
        gui.Close()
    })
    
    btnRefresh.OnEvent("Click", (*) => {
        PluginManager.DiscoverPlugins()
        PluginManager.CategorizePlugins()
        gui.Close()
        ShowPluginManager()
    })
    
    btnExport.OnEvent("Click", (*) => {
        ExportPluginList()
    })
    
    btnClose.OnEvent("Click", (*) => gui.Close())
    
    ; ListView event handlers
    lvAll.OnEvent("DoubleClick", (*) => {
        local selectedRow := lvAll.GetNext()
        if (selectedRow) {
            local pluginName := lvAll.GetText(selectedRow, 1)
            TogglePlugin(pluginName)
            gui.Close()
            ShowPluginManager()
        }
    })
    
    ; Show GUI
    gui.Show()
}

TogglePlugin(pluginName) {
    local plugin := PluginManager.GetPlugin(pluginName)
    if (!plugin) {
        MsgBox("Plugin not found: " . pluginName, "Error", "Icon!")
        return
    }
    
    if (plugin["enabled"]) {
        PluginManager.DisablePlugin(pluginName)
        TrayTip("Disabled plugin: " . pluginName, "PluginManager", "1")
    } else {
        PluginManager.EnablePlugin(pluginName)
        TrayTip("Enabled plugin: " . pluginName, "PluginManager", "1")
    }
}

ExportPluginList() {
    local exportDir := A_ScriptDir . "\exports"
    if (!DirExist(exportDir)) {
        DirCreate(exportDir)
    }
    
    local timestamp := FormatTime(A_Now, "yyyyMMdd_HHmmss")
    
    ; Export JSON
    local jsonContent := PluginManager.ExportPluginList("json")
    FileAppend(jsonContent, exportDir . "\plugins_" . timestamp . ".json")
    
    ; Export CSV
    local csvContent := PluginManager.ExportPluginList("csv")
    FileAppend(csvContent, exportDir . "\plugins_" . timestamp . ".csv")
    
    ; Export Text
    local textContent := PluginManager.ExportPluginList("text")
    FileAppend(textContent, exportDir . "\plugins_" . timestamp . ".txt")
    
    TrayTip("Plugin list exported to exports folder", "PluginManager", "1")
}

; =============================================================================
; HOTKEY SETUP
; =============================================================================

SetupPluginHotkeys() {
    ; Plugin Manager hotkeys
    Hotkey "^!p", ShowPluginManager  ; Ctrl+Alt+P for Plugin Manager
    Hotkey "^!+r", ReloadAllPlugins  ; Ctrl+Alt+Shift+R for Reload All
    
    ; Category-specific loading hotkeys
    Hotkey "^!+u", (*) => LoadPluginsByCategory("utilities")     ; Ctrl+Alt+Shift+U for Utilities
    Hotkey "^!+s", (*) => LoadPluginsByCategory("system")       ; Ctrl+Alt+Shift+S for System
    Hotkey "^!+d", (*) => LoadPluginsByCategory("development")   ; Ctrl+Alt+Shift+D for Development
    Hotkey "^!+m", (*) => LoadPluginsByCategory("media")         ; Ctrl+Alt+Shift+M for Media
    Hotkey "^!+g", (*) => LoadPluginsByCategory("games")         ; Ctrl+Alt+Shift+G for Games
    
    LogOperation("Plugin hotkeys registered")
}

; =============================================================================
; PLUGIN VALIDATION AND TESTING
; =============================================================================

ValidateAllPlugins() {
    LogOperation("Validating all plugins...")
    
    local results := PluginManager.ValidateAllPlugins()
    local validCount := 0
    local invalidCount := 0
    
    for pluginName, result in results {
        if (result["valid"]) {
            validCount++
        } else {
            invalidCount++
            LogOperation("Plugin validation failed: " . pluginName)
            for error in result["errors"] {
                LogOperation("  Error: " . error)
            }
        }
    }
    
    LogOperation("Plugin validation complete: " . validCount . " valid, " . invalidCount . " invalid")
    
    if (invalidCount > 0) {
        MsgBox("Plugin validation found " . invalidCount . " invalid plugins. Check log for details.", "Validation Results", "Icon!")
    } else {
        TrayTip("All plugins validated successfully", "PluginManager", "1")
    }
}

RunPluginTests() {
    LogOperation("Running plugin tests...")
    
    ; Create test suite for plugins
    TestSuite("Plugin Management", PluginTests)
    
    ; Run tests
    local success := TestFramework.RunAllTests()
    
    if (success) {
        TrayTip("All plugin tests passed", "PluginManager", "1")
    } else {
        MsgBox("Some plugin tests failed. Check test results for details.", "Test Results", "Icon!")
    }
}

PluginTests() {
    Test("Plugin Discovery", TestPluginDiscovery)
    Test("Plugin Loading", TestPluginLoading)
    Test("Plugin Validation", TestPluginValidation)
    Test("Plugin Management", TestPluginManagement)
}

TestPluginDiscovery() {
    PluginManager.DiscoverPlugins()
    
    AssertTrue(PluginManager.plugins.Length > 0, "Should discover plugins")
    AssertTrue(PluginManager.categories.Length > 0, "Should categorize plugins")
    
    ; Test specific plugins
    AssertTrue(PluginManager.plugins.Has("clipboard_manager"), "Should find clipboard_manager plugin")
    AssertTrue(PluginManager.plugins.Has("system_monitor"), "Should find system_monitor plugin")
}

TestPluginLoading() {
    ; Test loading a specific plugin
    local success := PluginManager.LoadPlugin("clipboard_manager")
    AssertTrue(success, "Should load clipboard_manager plugin")
    
    ; Test loading by category
    local loadedCount := PluginManager.LoadPluginsByCategory("utilities")
    AssertTrue(loadedCount > 0, "Should load utilities plugins")
}

TestPluginValidation() {
    local results := PluginManager.ValidateAllPlugins()
    
    AssertTrue(results.Length > 0, "Should validate plugins")
    
    ; Check that at least some plugins are valid
    local validCount := 0
    for pluginName, result in results {
        if (result["valid"]) {
            validCount++
        }
    }
    
    AssertTrue(validCount > 0, "Should have valid plugins")
}

TestPluginManagement() {
    ; Test plugin enable/disable
    local originalState := PluginManager.GetPlugin("clipboard_manager")["enabled"]
    
    PluginManager.DisablePlugin("clipboard_manager")
    AssertFalse(PluginManager.GetPlugin("clipboard_manager")["enabled"], "Should disable plugin")
    
    PluginManager.EnablePlugin("clipboard_manager")
    AssertTrue(PluginManager.GetPlugin("clipboard_manager")["enabled"], "Should enable plugin")
    
    ; Restore original state
    if (!originalState) {
        PluginManager.DisablePlugin("clipboard_manager")
    }
}

; =============================================================================
; UTILITY FUNCTIONS
; =============================================================================

LogOperation(message) {
    try {
        local logFile := A_Temp . "\plugin_loader.log"
        local timestamp := FormatTime(A_Now, "yyyy-MM-dd HH:mm:ss")
        FileAppend(timestamp . " - " . message . "`n", logFile)
    } catch {
        ; Ignore logging errors
    }
}

ShowPluginStatus() {
    local stats := PluginManager.GetPluginStats()
    local statusMsg := "Plugin Status:`n"
    statusMsg .= "Total: " . stats["total"] . "`n"
    statusMsg .= "Enabled: " . stats["enabled"] . "`n"
    statusMsg .= "Loaded: " . stats["loaded"] . "`n"
    statusMsg .= "Categories: " . stats["categories"]
    
    MsgBox(statusMsg, "Plugin Status", "Iconi")
}

; =============================================================================
; STARTUP NOTIFICATION
; =============================================================================

; Show startup notification
TrayTip("PluginLoader initialized", "AutoHotkey Repository", "1")

; Set up tray menu
A_TrayMenu.Delete()
A_TrayMenu.Add("Plugin Manager", ShowPluginManager)
A_TrayMenu.Add("Plugin Status", ShowPluginStatus)
A_TrayMenu.Add("Reload All Plugins", ReloadAllPlugins)
A_TrayMenu.Add("Validate Plugins", ValidateAllPlugins)
A_TrayMenu.Add("Run Plugin Tests", RunPluginTests)
A_TrayMenu.Add("Export Plugin List", ExportPluginList)
A_TrayMenu.Add("")
A_TrayMenu.Add("Exit", (*) => ExitApp())
A_TrayMenu.Default := "Plugin Manager"
A_TrayMenu.Tip := "AutoHotkey Plugin Loader v1.0"
