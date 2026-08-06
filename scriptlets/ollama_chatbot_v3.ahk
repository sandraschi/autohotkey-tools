#Requires AutoHotkey v2.0+
#SingleInstance Force

g := Gui("+AlwaysOnTop +Resize +MinSize520x420", "Ollama Chat")
g.BackColor := "131320"
g.SetFont("s9", "Segoe UI")

g.Add("Text", "x10 y10 w45 h22 cWhite", "Model:")
g.Add("ComboBox", "x55 y8 w170", ["llama3.2","llama3.1","mistral","gemma3","phi4","deepseek-coder"])

g.Add("Text", "x240 y10 w65 h22 cWhite", "Personality:")
g.Add("DropDownList", "x305 y8 w140", ["Assistant","Code Expert","Creative","Sarcastic"])

g.Add("Edit", "x10 y38 w500 h320 ReadOnly VScroll", "").SetFont("s9", "Consolas")

g.Add("Edit", "x10 y368 w410 h30", "")
g.Add("Button", "x428 y368 w82 h30 Background1a5a1a", "Send")
g.Add("Button", "x10 y408 w60 h22", "Clear")

Hotkey("^!o", (*) => g.Hide())
g.OnEvent("Close", (*) => g.Hide())

g.Show("w520 h440")
