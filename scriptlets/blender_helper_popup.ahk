#Requires AutoHotkey v2.0
; @description: Small always-on-top HUD for Blender -- shortcut cheat sheet, quick render-output folder access
; @category: ai_generated
; @version: 1.0.0
; @generated_by: autohotkey-mcp
; @hotkeys: ^!y toggle
; @tag: blender, cheat-sheet, hud, 3d

#SingleInstance Force

class BlenderHelper {
    static gui := ""
    static visible := false

    static Init() {
        this.BuildGui()
        Hotkey("^!y", (*) => this.Toggle())
    }

    static BuildGui() {
        g := Gui("+AlwaysOnTop -Caption +ToolWindow +Border", "Blender Helper")
        g.BackColor := "1e1e1e"
        g.SetFont("s9 cSilver", "Consolas")
        g.MarginX := 10
        g.MarginY := 8

        g.SetFont("s11 cE87D0D Bold")
        g.Add("Text", "w260", "Blender Quick Reference")
        g.SetFont("s9 cSilver")

        shortcuts := [
            ["Tab", "Edit / Object mode"],
            ["G / R / S", "Grab / Rotate / Scale"],
            ["X, Y, Z", "Constrain to axis"],
            ["Shift+D", "Duplicate"],
            ["Ctrl+R", "Loop cut"],
            ["Numpad 0", "Camera view"],
            ["Numpad 1/3/7", "Front / Side / Top"],
            ["Ctrl+Z", "Undo (global)"],
            ["F12", "Render image"],
            ["Ctrl+F12", "Render animation"],
        ]
        for row in shortcuts {
            line := Format("{:-14}{}", row[1], row[2])
            g.Add("Text", "w260", line)
        }

        g.Add("Text", "w260 y+8", "Ctrl+Alt+Y toggles this window")

        openBtn := g.Add("Button", "w120 y+10", "Open Renders Folder")
        openBtn.OnEvent("Click", (*) => this.OpenRenderFolder())

        closeBtn := g.Add("Button", "x+20 w80", "Close")
        closeBtn.OnEvent("Click", (*) => this.Hide())

        g.OnEvent("Close", (*) => this.Hide())
        g.OnEvent("Escape", (*) => this.Hide())

        this.gui := g
    }

    static OpenRenderFolder() {
        renderDir := A_MyDocuments "\Blender\Renders"
        if !DirExist(renderDir)
            DirCreate(renderDir)
        Run(renderDir)
    }

    static Toggle() {
        if this.visible
            this.Hide()
        else
            this.Show()
    }

    static Show() {
        this.gui.Show("x20 y20 w280 AutoSize")
        this.visible := true
    }

    static Hide() {
        this.gui.Hide()
        this.visible := false
    }
}

BlenderHelper.Init()
