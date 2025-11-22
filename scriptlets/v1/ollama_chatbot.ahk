#NoEnv
#SingleInstance Force
#Persistent
SetWorkingDir %A_ScriptDir%
SetBatchLines -1

; Configuration
ollamaUrl := "http://localhost:11434"  ; Default Ollama API endpoint
currentModel := "llama3"  ; Default model, change to your preferred model
chatHistory := []
maxHistory := 10  ; Number of messages to keep in history

; Create the GUI
Gui, +Resize +MinSize640x480
Gui, Font, s10, Segoe UI

; Chat display
Gui, Add, Edit, x10 y10 w620 h300 vChatDisplay ReadOnly +HScroll

; User input
Gui, Add, Edit, x10 y320 w520 h80 vUserInput gSendMessage
Gui, Add, Button, x540 y320 w90 h35 gSendMessage, &Send
Gui, Add, Button, x540 y365 w90 h35 gClearChat, C&lear

; Model selection
Gui, Add, Text, x10 y410 w80 h20, Model:
Gui, Add, DropDownList, x60 y405 w200 vModelSelect gUpdateModel, llama3||mistral|gemma|phi3

; Options
Gui, Add, CheckBox, x270 y405 vUseTTS gToggleTTS, Text-to-Speech
Gui, Add, CheckBox, x270 y430 vDarkMode gToggleDarkMode, Dark Mode

; Status bar
Gui, Add, StatusBar,, Ready. Connected to Ollama at %ollamaUrl%

; Set up TTS
try {
    oVoice := ComObjCreate("SAPI.SpVoice")
    oVoice.Rate := 0  ; -10 to 10
    oVoice.Volume := 100
    TTSEnabled := true
} catch {
    TTSEnabled := false
    SB_SetText("TTS initialization failed. Speech disabled.")
}

; Load settings
LoadSettings()

; Show the GUI
Gui, Show, w640 h480, Ollama Chatbot

; Get available models
GetAvailableModels()

; Set up hotkey to show/hide the chat
^!O::  ; Ctrl+Alt+O
    if (WinExist("Ollama Chatbot")) {
        if (WinActive("Ollama Chatbot")) {
            WinHide, Ollama Chatbot
        } else {
            WinShow, Ollama Chatbot
            WinActivate, Ollama Chatbot
        }
    }
return

SendMessage:
    Gui, Submit, NoHide
    
    ; Get user input
    userMessage := UserInput
    if (userMessage = "") {
        return
    }
    
    ; Add to chat
    AddToChat("You: " . userMessage, "user")
    
    ; Clear input
    GuiControl,, UserInput
    
    ; Show typing indicator
    SB_SetText("Thinking...")
    
    ; Add to history
    chatHistory.Push({"role": "user", "content": userMessage})
    
    ; Keep history within limits
    if (chatHistory.Length() > maxHistory * 2) {  ; *2 for user/assistant pairs
        chatHistory.RemoveAt(1, 2)  ; Remove oldest user/assistant pair
    }
    
    ; Prepare the API request
    requestBody := {}
    requestBody.model := currentModel
    requestBody.messages := chatHistory
    requestBody.stream := false
    
    ; Convert to JSON
    jsonBody := JSON.Dump(requestBody)
    
    ; Send request to Ollama
    whr := ComObjCreate("WinHttp.WinHttpRequest.5.1")
    try {
        whr.Open("POST", ollamaUrl . "/api/chat", 0)
        whr.SetRequestHeader("Content-Type", "application/json")
        whr.Send(jsonBody)
        
        if (whr.Status = 200) {
            response := JSON.Load(whr.ResponseText)
            assistantMessage := response.message.content
            
            ; Add to chat and history
            AddToChat("Assistant: " . assistantMessage, "assistant")
            chatHistory.Push({"role": "assistant", "content": assistantMessage})
            
            ; Read response with TTS if enabled
            if (TTSEnabled && UseTTS) {
                oVoice.Speak(assistantMessage, 1)  ; 1 = async
            }
            
            SB_SetText("Response received from " . currentModel)
        } else {
            errorMsg := "Error: " . whr.StatusText
            AddToChat(errorMsg, "system")
            SB_SetText(errorMsg)
        }
    } catch e {
        errorMsg := "Error: " . e.Message
        AddToChat(errorMsg, "system")
        SB_SetText(errorMsg)
    }
return

AddToChat(message, sender := "") {
    global ChatDisplay
    
    ; Get current time
    FormatTime, currentTime,, HH:mm:ss
    
    ; Format message with timestamp and sender
    formattedMessage := "[" . currentTime . "] " . message . "`n"
    
    ; Add to chat display
    GuiControlGet, currentChat,, ChatDisplay
    GuiControl,, ChatDisplay, %currentChat%%formattedMessage%
    
    ; Auto-scroll to bottom
    SendMessage, 0x115, 7, 0,, ahk_id %ChatDisplayHwnd%  ; WM_VSCROLL
}

ClearChat:
    GuiControl,, ChatDisplay
    chatHistory := []
    SB_SetText("Chat cleared")
return

UpdateModel:
    Gui, Submit, NoHide
    currentModel := ModelSelect
    SB_SetText("Model changed to: " . currentModel)
    
    ; Save the setting
    IniWrite, %currentModel%, %A_ScriptDir%\ollama_chat.ini, Settings, Model
return

ToggleTTS:
    Gui, Submit, NoHide
    TTSEnabled := UseTTS
    status := TTSEnabled ? "enabled" : "disabled"
    SB_SetText("Text-to-speech " . status)
    
    ; Save the setting
    IniWrite, %TTSEnabled%, %A_ScriptDir%\ollama_chat.ini, Settings, UseTTS
return

ToggleDarkMode:
    Gui, Submit, NoHide
    
    if (DarkMode) {
        ; Dark theme
        Gui, Color, 0x1E1E1E
        Gui, Font, cSilver
        GuiControl, Font, ChatDisplay
        Gui, Font, cWhite
        GuiControl, +Background0x2D2D2D, ChatDisplay
        GuiControl, +cWhite, UserInput
        GuiControl, +Background0x2D2D2D, UserInput
    } else {
        ; Light theme
        Gui, Color, Default
        Gui, Font, cBlack
        GuiControl, Font, ChatDisplay
        Gui, Font, cDefault
        GuiControl, +BackgroundDefault, ChatDisplay
        GuiControl, +cDefault, UserInput
        GuiControl, +BackgroundDefault, UserInput
    }
    
    ; Save the setting
    IniWrite, %DarkMode%, %A_ScriptDir%\ollama_chat.ini, Settings, DarkMode
return

GetAvailableModels() {
    global ollamaUrl, ModelSelect
    
    whr := ComObjCreate("WinHttp.WinHttpRequest.5.1")
    try {
        whr.Open("GET", ollamaUrl . "/api/tags", 0)
        whr.Send()
        
        if (whr.Status = 200) {
            response := JSON.Load(whr.ResponseText)
            models := []
            
            for i, model in response.models {
                modelName := model.name
                ; Remove the tag if present (e.g., "llama3:latest" -> "llama3")
                if (InStr(modelName, ":")) {
                    modelName := SubStr(modelName, 1, InStr(modelName, ":") - 1)
                }
                models.Push(modelName)
            }
            
            ; Update the dropdown
            GuiControl,, ModelSelect, |% "llama3||" . Join("|", models)
            SB_SetText(models.Length() . " models available")
        }
    } catch {
        ; Couldn't fetch models, use defaults
    }
}

LoadSettings() {
    global currentModel, TTSEnabled, DarkMode, UseTTS
    
    IniRead, model, %A_ScriptDir%\ollama_chat.ini, Settings, Model, %A_Space%
    if (model != "") {
        currentModel := model
        GuiControl, ChooseString, ModelSelect, %currentModel%
    }
    
    IniRead, useTTS, %A_ScriptDir%\ollama_chat.ini, Settings, UseTTS, 1
    TTSEnabled := (useTTS = "1")
    GuiControl,, UseTTS, %TTSEnabled%
    
    IniRead, darkMode, %A_ScriptDir%\ollama_chat.ini, Settings, DarkMode, 0
    DarkMode := (darkMode = "1")
    GuiControl,, DarkMode, %DarkMode%
    
    ; Apply dark mode if needed
    if (DarkMode) {
        Gui, Color, 0x1E1E1E
        Gui, Font, cSilver
        GuiControl, Font, ChatDisplay
        Gui, Font, cWhite
        GuiControl, +Background0x2D2D2D, ChatDisplay
        GuiControl, +cWhite, UserInput
        GuiControl, +Background0x2D2D2D, UserInput
    }
}

; JSON handling (simplified implementation)
class JSON {
    static Load(json) {
        json := Trim(json)
        if (SubStr(json, 1, 1) = "{" && SubStr(json, -1) = "}") {
            return this.ParseObject(SubStr(json, 2, -1))
        } else if (SubStr(json, 1, 1) = "[" && SubStr(json, -1) = "]") {
            return this.ParseArray(SubStr(json, 2, -1))
        }
        throw Exception("Invalid JSON")
    }
    
    static Dump(obj) {
        if (IsObject(obj)) {
            if (obj.Length() > 0) {
                ; Array
                result := "["
                for i, v in obj {
                    if (A_Index > 1) {
                        result .= ","
                    }
                    result .= this.Dump(v)
                }
                return result . "]"
            } else {
                ; Object
                result := "{"
                first := true
                for k, v in obj {
                    if (!first) {
                        result .= ","
                    }
                    result .= """" . k . """:" . this.Dump(v)
                    first := false
                }
                return result . "}"
            }
        } else if (obj = "") {
            return """""
        } else if (obj is number) {
            return obj
        } else if (obj is string) {
            ; Escape special characters
            str := StrReplace(obj, "\"\"", "\\")
            str := StrReplace(str, """", "\"\"")
            str := StrReplace(str, "`n", "\n")
            str := StrReplace(str, "`r", "\r")
            str := StrReplace(str, "`t", "\t")
            return """" . str . """
        } else if (obj = true) {
            return "true"
        } else if (obj = false) {
            return "false"
        } else if (obj = "") {
            return "null"
        }
        return """" . obj . """"
    }
    
    static ParseObject(str) {
        obj := {}
        str := Trim(str)
        if (str = "") {
            return obj
        }
        
        pos := 1
        while (pos <= StrLen(str)) {
            ; Find the key
            key := this.ParseString(str, pos)
            if (key = "") {
                break
            }
            
            ; Find the colon
            pos := InStr(str, ":", false, pos)
            if (!pos) {
                break
            }
            pos++
            
            ; Find the value
            value := this.ParseValue(str, pos)
            if (value = "" && pos <= StrLen(str)) {
                break
            }
            
            ; Add to object
            obj[key] := value
            
            ; Skip comma
            pos := InStr(str, ",", false, pos) + 1
            if (!pos) {
                break
            }
        }
        
        return obj
    }
    
    static ParseArray(str) {
        arr := []
        str := Trim(str)
        if (str = "") {
            return arr
        }
        
        pos := 1
        while (pos <= StrLen(str)) {
            ; Find the value
            value := this.ParseValue(str, pos)
            if (value = "" && pos <= StrLen(str)) {
                break
            }
            
            ; Add to array
            arr.Push(value)
            
            ; Skip comma
            pos := InStr(str, ",", false, pos) + 1
            if (!pos) {
                break
            }
        }
        
        return arr
    }
    
    static ParseValue(str, ByRef pos) {
        str := Trim(str)
        if (pos > StrLen(str)) {
            return ""
        }
        
        char := SubStr(str, pos, 1)
        if (char = "{") {
            ; Object
            end := FindMatchingBrace(str, pos, "{", "}")
            if (!end) {
                return ""
            }
            value := this.ParseObject(SubStr(str, pos + 1, end - pos - 1))
            pos := end + 1
            return value
        } else if (char = "[") {
            ; Array
            end := FindMatchingBrace(str, pos, "[", "]")
            if (!end) {
                return ""
            }
            value := this.ParseArray(SubStr(str, pos + 1, end - pos - 1))
            pos := end + 1
            return value
        } else if (char = """ || char = "'") {
            ; String
            value := this.ParseString(str, pos)
            return value
        } else if (char = "t" && SubStr(str, pos, 4) = "true") {
            ; Boolean true
            pos += 4
            return true
        } else if (char = "f" && SubStr(str, pos, 5) = "false") {
            ; Boolean false
            pos += 5
            return false
        } else if (char = "n" && SubStr(str, pos, 4) = "null") {
            ; Null
            pos += 4
            return ""
        } else if (RegExMatch(SubStr(str, pos), "^[\-0-9]", match)) {
            ; Number
            RegExMatch(SubStr(str, pos), "^[\-0-9]+\.?[0-9]*([eE][\-+]?[0-9]+)?", numStr)
            pos += StrLen(numStr)
            return numStr + 0
        }
        
        return ""
    }
    
    static ParseString(str, ByRef pos) {
        if (SubStr(str, pos, 1) != """ && SubStr(str, pos, 1) != "'") {
            return ""
        }
        
        quote := SubStr(str, pos, 1)
        pos++
        result := ""
        
        while (pos <= StrLen(str)) {
            char := SubStr(str, pos, 1)
            
            if (char = "\") {
                ; Escape sequence
                pos++
                if (pos > StrLen(str)) {
                    break
                }
                
                char := SubStr(str, pos, 1)
                switch char {
                    case """": result .= """"
                    case "'": result .= "'"
                    case "\": result .= "\"
                    case "/": result .= "/"
                    case "b": result .= "`b"
                    case "f": result .= "`f"
                    case "n": result .= "`n"
                    case "r": result .= "`r"
                    case "t": result .= "`t"
                    case "u":
                        ; Unicode escape sequence
                        if (pos + 4 <= StrLen(str)) {
                            hex := SubStr(str, pos + 1, 4)
                            if (RegExMatch(hex, "^[0-9A-Fa-f]{4}$")) {
                                result .= Chr("0x" . hex)
                                pos += 4
                                continue
                            }
                        }
                        result .= "\u"
                }
            } else if (char = quote) {
                ; End of string
                pos++
                return result
            } else {
                result .= char
            }
            
            pos++
        }
        
        return result
    }
}

FindMatchingBrace(str, pos, open, close) {
    if (SubStr(str, pos, 1) != open) {
        return 0
    }
    
    depth := 1
    i := pos + 1
    len := StrLen(str)
    
    while (i <= len) {
        char := SubStr(str, i, 1)
        
        if (char = "\") {
            ; Skip escaped characters
            i += 2
            continue
        } else if (char = """ || char = "'") {
            ; Skip strings
            quote := char
            i++
            while (i <= len && SubStr(str, i, 1) != quote) {
                if (SubStr(str, i, 1) = "\") {
                    i++
                }
                i++
            }
            if (i > len) {
                return 0
            }
        } else if (char = open) {
            depth++
        } else if (char = close) {
            depth--
            if (depth = 0) {
                return i
            }
        }
        
        i++
    }
    
    return 0
}

Join(sep, params*) {
    for i, param in params {
        str .= (i > 1 ? sep : "") . param
    }
    return str
}

GuiSize:
    if (A_EventInfo = 1)  ; The window has been minimized
        return
    
    ; Resize controls
    GuiControl, Move, ChatDisplay, % "w" . (A_GuiWidth - 20) . " h" . (A_GuiHeight - 160)
    GuiControl, Move, UserInput, % "w" . (A_GuiWidth - 130) . " h80"
    GuiControl, Move, Send, % "x" . (A_GuiWidth - 110) . " y" . (A_GuiHeight - 120)
    GuiControl, Move, Clear, % "x" . (A_GuiWidth - 110) . " y" . (A_GuiHeight - 80)
    
    ; Reposition status bar
    Gui, StatusBar
    SB_SetParts(A_GuiWidth - 150, A_GuiWidth - 75)
return

GuiClose:
    ; Save settings before exiting
    IniWrite, %currentModel%, %A_ScriptDir%\ollama_chat.ini, Settings, Model
    IniWrite, %TTSEnabled%, %A_ScriptDir%\ollama_chat.ini, Settings, UseTTS
    IniWrite, %DarkMode%, %A_ScriptDir%\ollama_chat.ini, Settings, DarkMode
    
    ExitApp
return
