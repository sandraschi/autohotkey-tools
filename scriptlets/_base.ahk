#Requires AutoHotkey v2.0

; Base class for all scriptlets
class Scriptlet {
    ; Required properties
    static name := "Unnamed Scriptlet"
    static description := "No description provided"
    static category := "Uncategorized"
    static hotkey := ""  ; e.g., "^!s" for Ctrl+Alt+S
    
    ; Initialize the scriptlet
    static Init() {
        ; Register hotkey if specified
        if (this.hotkey != "") {
            try {
                Hotkey(this.hotkey, (*) => this.Run())
            } catch as e {
                OutputDebug("Failed to register hotkey for " . this.name . ": " . e.Message)
            }
        }
    }
    
    ; Main execution method (override in child classes)
    static Run() {
        MsgBox("This is a base scriptlet and does nothing.", this.name)
    }
    
    ; Helper method to show status
    static ShowStatus(message) {
        if (IsObject(launcherGui) && launcherGui.HasOwnProp("statusBar")) {
            launcherGui.statusBar.Text := message
        } else {
            ToolTip(message)
            SetTimer(() => ToolTip(), -3000)
        }
    }
    
    ; Helper method to log errors
    static LogError(message) {
        OutputDebug("[" . A_Now . "] [" . this.name . "] ERROR: " . message)
        this.ShowStatus("Error: " . message)
    }
}






