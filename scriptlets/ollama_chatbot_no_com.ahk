#Requires AutoHotkey v2.0
#SingleInstance Force
#Warn All, MsgBox(#Warn LocalSameAsGlobal,  Off

; =============================================================================
; CONFIGURATION
; =============================================================================
APP_TITLE := "Ollama Chat"
OLLAMA_URL := "http://localhost:11434"
DEFAULT_MODEL := "llama3"

; Colors
COLORS := {
    light: {
        bg: 0xFFFFFF,  text: 0x000000, inputBg: 0xF8F9FA,
        userMsg: 0xE3F2FD, assistantMsg: 0xF5F5F5, systemMsg: 0xFFEBEE
    },
    dark: {
        bg: 0x1E1E1E, text: 0xE0E0E0, inputBg: 0x252526,
        userMsg: 0x0D47A1, assistantMsg: 0x2D2D2D, systemMsg: 0x4A148C
    }
}

; =============================================================================
; GLOBAL STATE
; =============================================================================
chatHistory := []
currentTheme := "light"
selectedModel := ""
models := []
settings := {
    temperature: 0.7,
    maxTokens: 2000,
    maxHistorySize: 50,
    systemPrompt: "You are a helpful AI assistant.",
    darkMode: false
}

; Global variables for GUI controls
guiMain := ""
chatDisplay := ""
userInputBox := ""
modelSelector := ""
statusBar := ""
btnSend := ""

; =============================================================================
; HELPER FUNCTIONS
; =============================================================================
HasValue(arr, val) {
    for item in arr {
        if (item = val) {
            return true
        }
    }
    return false
}

; =============================================================================
; MAIN WINDOW
; =============================================================================
CreateGUI()

; =============================================================================
; GUI CREATION
; =============================================================================
CreateGUI() {
    global guiMain, chatDisplay, userInputBox, modelSelector, statusBar, btnSend
    
    ; Create main window
    guiMain := Gui("+Resize +MinSize800x600", APP_TITLE)
    guiMain.OnEvent("Close", (*) => ExitApp())
    guiMain.OnEvent("Size", OnWindowResize)
    
    ; Apply theme
    ApplyTheme(currentTheme)
    
    ; Chat display - use plain text display for better compatibility
    chatDisplay := guiMain.Add("Edit", "x10 y10 w780 h500 +ReadOnly VScroll +Multi")
    chatDisplay.SetFont("s10", "Segoe UI")
    
    ; Input area
    userInputBox := guiMain.Add("Edit", "x10 y520 w680 h70 +Multi")
    userInputBox.OnEvent("Change", OnInputChange)
    userInputBox.SetFont("s10", "Segoe UI")
    
    ; Send button
    btnSend := guiMain.Add("Button", "x700 y520 w90 h30 Default", "&Send")
    btnSend.OnEvent("Click", SendMessage)
    
    ; Model selector
    guiMain.Add("Text", "x10 y600 w50 h23", "Model:")
    modelSelector := guiMain.Add("DropDownList", "x60 y600 w200")
    modelSelector.OnEvent("Change", OnModelChange)
    
    ; Clear button
    btnClear := guiMain.Add("Button", "x270 y600 w80 h25", "&Clear")
    btnClear.OnEvent("Click", (*) => ClearChat())
    
    ; Theme toggle button
    btnTheme := guiMain.Add("Button", "x360 y600 w80 h25", "&Theme")
    btnTheme.OnEvent("Click", (*) => ToggleTheme())
    
    ; Reconnect button
    btnReconnect := guiMain.Add("Button", "x450 y600 w80 h25", "&Reconnect")
    btnReconnect.OnEvent("Click", (*) => ReconnectOllama())
    
    ; Status bar
    statusBar := guiMain.Add("StatusBar")
    statusBar.SetText("Initializing...")
    
    ; Load settings
    LoadSettings()
    
    ; Test connection and load models
    TestConnectionAndLoadModels()
    
    ; Show window
    guiMain.Show("w800 h640")
    userInputBox.Focus()
}

TestConnectionAndLoadModels() {
    global statusBar
    
    statusBar.SetText("Testing Ollama connection...")
    
    ; First test basic connectivity
    if (!TestOllamaConnection()) {
        statusBar.SetText("Ollama connection failed")
        ShowConnectionError()
        return false
    }
    
    statusBar.SetText("Loading models...")
    
    ; Then try to load models
    if (LoadModels()) {
        statusBar.SetText("Ready - " . models.Length . " models loaded")
        return true
    } else {
        statusBar.SetText("Model loading failed")
        return false
    }
}

TestOllamaConnection() {
    global OLLAMA_URL
    
    try {
        ; Create a simple HTTP request to test connectivity
        whr := ComObject("WinHttp.WinHttpRequest.5.1")
        whr.Open("GET", OLLAMA_URL . "/api/tags", false)
        whr.SetTimeouts(5000, 5000, 5000, 5000)  ; 5 second timeout
        whr.Send()
        
        return (whr.Status = 200)
    } catch as e {
        return false
    }
}

ShowConnectionError() {
    global OLLAMA_URL
    
    errorMsg := "Cannot connect to Ollama server.`n`n"
    errorMsg .= "Please check:`n"
    errorMsg .= "• Ollama is installed and running`n"
    errorMsg .= "• Ollama server is accessible at: " . OLLAMA_URL . "`n"
    errorMsg .= "• No firewall blocking the connection`n`n"
    errorMsg .= "To start Ollama, run 'ollama serve' in a command prompt."
    
    MsgBox(errorMsg, "Ollama Connection Error", "OK")
}

ReconnectOllama() {
    global statusBar
    statusBar.SetText("Reconnecting...")
    TestConnectionAndLoadModels()
}

ApplyTheme(theme) {
    global guiMain, COLORS, currentTheme, chatDisplay, userInputBox
    currentTheme := theme
    colors := COLORS.%theme%
    
    guiMain.BackColor := colors.bg
    
    ; Update chat display colors - convert hex to proper format
    if (chatDisplay) {
        chatDisplay.Opt("+Background" . Format("0x{:X}", colors.inputBg))
    }
    
    ; Update input box colors
    if (userInputBox) {
        userInputBox.Opt("+Background" . Format("0x{:X}", colors.inputBg))
    }
}

; =============================================================================
; EVENT HANDLERS
; =============================================================================
OnWindowResize(guiObj, minMax, width, height) {
    global chatDisplay, userInputBox, btnSend
    if (minMax = -1)
        return
    
    chatDisplay.Move(10, 10, width - 20, height - 130)
    userInputBox.Move(10, height - 110, width - 120, 70)
    btnSend.Move(width - 100, height - 110, 80, 30)
}

OnInputChange(ctrl, info) {
    global btnSend
    btnSend.Enabled := (Trim(ctrl.Value) != "")
}

OnModelChange(ctrl, info) {
    global selectedModel, statusBar
    selectedModel := ctrl.Text
    statusBar.SetText("Model: " . selectedModel)
    SaveSettings()
}

SendMessage(ctrl, info) {
    global userInputBox, chatDisplay, selectedModel, chatHistory, settings, statusBar, btnSend
    
    ; Get and validate user input
    userMessage := Trim(userInputBox.Value)
    if (userMessage = "") {
        return  ; Don't send empty messages
    }
    
    ; Check if model is selected
    if (selectedModel = "") {
        MsgBox("Please select a model first.", "No Model Selected", "OK")
        return
    }
    
    ; Clear input box and disable it during processing
    userInputBox.Value := ""
    userInputBox.Enabled := false
    btnSend.Enabled := false
    
    try {
        ; Show typing indicator
        statusBar.SetText("Sending message...")
        
        ; Add user message to chat
        AddMessage("user", userMessage)
        
        ; Prepare API request
        request := {
            model: selectedModel,
            messages: [],
            stream: false,
            options: {
                temperature: settings.temperature,
                num_ctx: settings.maxTokens
            }
        }
        
        ; Add system prompt if configured
        if (settings.systemPrompt != "") {
            request.messages.Push({
                role: "system",
                content: settings.systemPrompt
            })
        }
        
        ; Add chat history
        for msg in chatHistory {
            request.messages.Push({
                role: msg.role,
                content: msg.content
            })
        }
        
        ; Send request with timeout
        try {
            response := SendOllamaRequest("chat", request, 120000)  ; 2 minute timeout
        } catch as e {
            throw Error("Failed to get response from Ollama: " . e.Message)
        }
        
        ; Validate and process response
        if (!response.HasProp("message") || !response.message.HasProp("content")) {
            throw Error("Invalid response format from Ollama API")
        }
        
        ; Add assistant's response to chat
        AddMessage("assistant", response.message.content)
        
        ; Update status
        statusBar.SetText("Message sent")
        
    } catch as e {
        ; Show error to user
        errorMsg := "Error: " . e.Message
        AddMessage("system", errorMsg)
        statusBar.SetText("Error: " . e.Message)
        
        ; Log detailed error for debugging
        OutputDebug("Ollama Chat Error: " . errorMsg . "`n" . e.Stack)
        
    } finally {
        ; Re-enable input box and send button
        userInputBox.Enabled := true
        btnSend.Enabled := true
        
        ; Focus the input box for next message
        try {
            userInputBox.Focus()
        }
    }
}

; =============================================================================
; OLLAMA API FUNCTIONS
; =============================================================================
SendOllamaRequest(endpoint, data, timeout := 30000) {
    static whr := 0
    
    ; Initialize WinHttpRequest if not already done
    if (!whr) {
        try {
            whr := ComObject("WinHttp.WinHttpRequest.5.1")
        } catch as e {
            throw Error("Failed to initialize HTTP client: " . e.Message)
        }
    }
    
    try {
        url := OLLAMA_URL . "/api/" . endpoint
        
        ; Configure request
        whr.Open("POST", url, false)
        whr.SetRequestHeader("Content-Type", "application/json")
        whr.Option(6, false)  ; Disable auto-redirect
        
        ; Set timeouts (in milliseconds)
        whr.SetTimeouts(timeout, timeout, timeout, timeout)
        
        ; Send request with error handling
        jsonData := SimpleJSON.Stringify(data)
        try {
            whr.Send(jsonData)
        } catch as e {
            throw Error("Failed to send request: " . e.Message)
        }
        
        ; Check response status
        status := whr.Status
        if (status != 200) {
            errorMsg := "API request failed with status: " . status
            try {
                if (whr.ResponseText != "") {
                    errorMsg .= "`nResponse: " . whr.ResponseText
                }
            }
            throw Error(errorMsg)
        }
        
        ; Parse and return response
        try {
            return SimpleJSON.Parse(whr.ResponseText)
        } catch as e {
            throw Error("Failed to parse response: " . e.Message)
        }
    } catch as e {
        throw Error("Request failed: " . e.Message)
    }
}

LoadModels() {
    global models, modelSelector, selectedModel, statusBar
    
    try {
        ; Get available models from Ollama
        response := SendOllamaRequest("tags", {})
        
        if (!response.HasProp("models")) {
            throw Error("Invalid response format from Ollama API")
        }
        
        ; Clear existing models
        models := []
        
        ; Process each model
        for model in response.models {
            modelName := model.name
            
            ; Remove tag/version if present (e.g., "llama3:latest" -> "llama3")
            if (InStr(modelName, ":")) {
                modelName := SubStr(modelName, 1, InStr(modelName, ":") - 1)
            }
            
            ; Add to list if not already present
            if (!HasValue(models, modelName)) {
                models.Push(modelName)
            }
        }
        
        ; Sort models alphabetically
        if (models.Length > 1) {
            models.Sort()
        }
        
        ; Update the dropdown
        modelSelector.Delete()
        for model in models {
            modelSelector.Add([model])
        }
        
        ; Select the first model if none selected or if the selected model doesn't exist
        if (selectedModel = "" && models.Length > 0) {
            selectedModel := models[1]
            modelSelector.Choose(1)
        } else if (selectedModel != "" && HasValue(models, selectedModel)) {
            ; Find and select the previously selected model
            for i, model in models {
                if (model = selectedModel) {
                    modelSelector.Choose(i)
                    break
                }
            }
        } else if (models.Length > 0) {
            ; Fallback to first model if selected model doesn't exist
            selectedModel := models[1]
            modelSelector.Choose(1)
        }
        
        ; Update status bar
        statusBar.SetText(models.Length . " models loaded")
        return true
        
    } catch as e {
        statusBar.SetText("Failed to load models: " . e.Message)
        
        ; Show user-friendly error message
        errorMsg := "Failed to load models from Ollama.`n`n"
        errorMsg .= "Error: " . e.Message . "`n`n"
        errorMsg .= "Please ensure:`n"
        errorMsg .= "• Ollama is running on " . OLLAMA_URL . "`n"
        errorMsg .= "• At least one model is installed (try: ollama pull llama3)`n"
        errorMsg .= "• No firewall is blocking the connection"
        
        MsgBox(errorMsg, "Model Loading Error", "OK")
        return false
    }
}

; =============================================================================
; CHAT MANAGEMENT
; =============================================================================
AddMessage(role, content) {
    global chatHistory, chatDisplay, settings
    
    ; Add message to history
    msgObj := {
        role: role,
        content: content,
        timestamp: A_Now
    }
    
    chatHistory.Push(msgObj)
    
    ; Limit chat history to prevent memory issues
    if (chatHistory.Length > settings.maxHistorySize) {
        chatHistory.RemoveAt(1, chatHistory.Length - settings.maxHistorySize)
    }
    
    ; Update the display
    UpdateChatDisplay()
    
    return msgObj
}

UpdateChatDisplay() {
    global chatDisplay, chatHistory, currentTheme
    
    ; Create formatted text display
    displayText := ""
    
    for msg in chatHistory {
        time := FormatTime(msg.timestamp, "HH:mm:ss")
        roleDisplay := ""
        
        switch msg.role {
            case "user":
                roleDisplay := "You"
            case "assistant":
                roleDisplay := "Assistant"
            case "system":
                roleDisplay := "System"
            default:
                roleDisplay := msg.role
        }
        
        ; Add message to display
        displayText .= "[" . time . "] " . roleDisplay . ":`n"
        displayText .= msg.content . "`n`n"
    }
    
    ; Update the display
    try {
        chatDisplay.Value := displayText
        ; Scroll to bottom using DllCall for better compatibility
        DllCall("SendMessage", "Ptr", chatDisplay.Hwnd, "UInt", 0x115, "Ptr", 7, "Ptr", 0)  ; WM_VSCROLL, SB_BOTTOM
    } catch as e {
        OutputDebug("Failed to update chat display: " . e.Message)
    }
}

; =============================================================================
; SETTINGS MANAGEMENT
; =============================================================================
LoadSettings() {
    global settings, selectedModel, currentTheme
    
    iniFile := A_ScriptDir . "\ollama_chat.ini"
    
    ; Load settings with defaults
    try {
        if (FileExist(iniFile)) {
            model := IniRead(iniFile, "Settings", "model", DEFAULT_MODEL)
            darkMode := IniRead(iniFile, "Settings", "darkMode", "0")
            
            selectedModel := model
            settings.darkMode := (darkMode = "1")
            
            if (settings.darkMode) {
                currentTheme := "dark"
            }
        } else {
            ; Create default settings file
            selectedModel := DEFAULT_MODEL
            settings.darkMode := false
            SaveSettings()
        }
    } catch as e {
        ; Fallback to defaults if there's an error reading the INI
        selectedModel := DEFAULT_MODEL
        settings.darkMode := false
    }
}

SaveSettings() {
    global settings, selectedModel
    
    iniFile := A_ScriptDir . "\ollama_chat.ini"
    
    try {
        IniWrite(selectedModel, iniFile, "Settings", "model")
        IniWrite(settings.darkMode ? "1" : "0", iniFile, "Settings", "darkMode")
    } catch as e {
        OutputDebug("Failed to save settings: " . e.Message)
    }
}

; =============================================================================
; SIMPLE JSON HANDLING (NO COM DEPENDENCIES)
; =============================================================================
class SimpleJSON {
    static Stringify(obj) {
        return SimpleJSON._StringifyValue(obj)
    }
    
    static _StringifyValue(val) {
        switch Type(val) {
            case "String":
                return '"' . SimpleJSON._EscapeString(val) . '"'
            case "Integer", "Float":
                return String(val)
            case "Object":
                return SimpleJSON._StringifyObject(val)
            case "Array":
                return SimpleJSON._StringifyArray(val)
            default:
                return "null"
        }
    }
    
    static _StringifyObject(obj) {
        parts := []
        for key, value in obj {
            keyStr := '"' . SimpleJSON._EscapeString(String(key)) . '"'
            valueStr := SimpleJSON._StringifyValue(value)
            parts.Push(keyStr . ":" . valueStr)
        }
        return "{" . parts.Join(",") . "}"
    }
    
    static _StringifyArray(arr) {
        parts := []
        for item in arr {
            parts.Push(SimpleJSON._StringifyValue(item))
        }
        return "[" . parts.Join(",") . "]"
    }
    
    static _EscapeString(str) {
        ; Escape JSON special characters
        str := StrReplace(str, "\", "\\")
        str := StrReplace(str, '"', '\"')
        str := StrReplace(str, "`n", "\n")
        str := StrReplace(str, "`r", "\r")
        str := StrReplace(str, "`t", "\t")
        return str
    }
    
    static Parse(jsonStr) {
        ; Simple JSON parser - handles basic objects and arrays
        jsonStr := Trim(jsonStr)
        
        if (jsonStr = "") {
            throw Error("Empty JSON string")
        }
        
        pos := 1
        result := SimpleJSON._ParseValue(jsonStr, &pos)
        return result
    }
    
    static _ParseValue(jsonStr, &pos) {
        ; Skip whitespace
        while (pos <= StrLen(jsonStr) && InStr(" `t`n`r", SubStr(jsonStr, pos, 1))) {
            pos++
        }
        
        if (pos > StrLen(jsonStr)) {
            throw Error("Unexpected end of JSON")
        }
        
        char := SubStr(jsonStr, pos, 1)
        
        switch char {
            case "{":
                return SimpleJSON._ParseObject(jsonStr, &pos)
            case "[":
                return SimpleJSON._ParseArray(jsonStr, &pos)
            case '"':
                return SimpleJSON._ParseString(jsonStr, &pos)
            case "t":
                if (SubStr(jsonStr, pos, 4) = "true") {
                    pos += 4
                    return true
                }
                throw Error("Invalid JSON at position " . pos)
            case "f":
                if (SubStr(jsonStr, pos, 5) = "false") {
                    pos += 5
                    return false
                }
                throw Error("Invalid JSON at position " . pos)
            case "n":
                if (SubStr(jsonStr, pos, 4) = "null") {
                    pos += 4
                    return ""
                }
                throw Error("Invalid JSON at position " . pos)
            default:
                ; Try to parse as number
                return SimpleJSON._ParseNumber(jsonStr, &pos)
        }
    }
    
    static _ParseObject(jsonStr, &pos) {
        obj := {}
        pos++  ; Skip opening brace
        
        ; Skip whitespace
        while (pos <= StrLen(jsonStr) && InStr(" `t`n`r", SubStr(jsonStr, pos, 1))) {
            pos++
        }
        
        ; Check for empty object
        if (pos <= StrLen(jsonStr) && SubStr(jsonStr, pos, 1) = "}") {
            pos++
            return obj
        }
        
        loop {
            ; Parse key
            key := SimpleJSON._ParseString(jsonStr, &pos)
            
            ; Skip whitespace and colon
            while (pos <= StrLen(jsonStr) && InStr(" `t`n`r", SubStr(jsonStr, pos, 1))) {
                pos++
            }
            if (pos > StrLen(jsonStr) || SubStr(jsonStr, pos, 1) != ":") {
                throw Error('Expected ":" at position ' . pos)
            }
            pos++
            
            ; Parse value
            value := SimpleJSON._ParseValue(jsonStr, &pos)
            obj.%key% := value
            
            ; Skip whitespace
            while (pos <= StrLen(jsonStr) && InStr(" `t`n`r", SubStr(jsonStr, pos, 1))) {
                pos++
            }
            
            if (pos > StrLen(jsonStr)) {
                throw Error("Unexpected end of JSON")
            }
            
            char := SubStr(jsonStr, pos, 1)
            if (char = "}") {
                pos++
                break
            } else if (char = ",") {
                pos++
            } else {
                throw Error("Expected ',' or '}' at position " . pos)
            }
        }
        
        return obj
    }
    
    static _ParseArray(jsonStr, &pos) {
        arr := []
        pos++  ; Skip opening bracket
        
        ; Skip whitespace
        while (pos <= StrLen(jsonStr) && InStr(" `t`n`r", SubStr(jsonStr, pos, 1))) {
            pos++
        }
        
        ; Check for empty array
        if (pos <= StrLen(jsonStr) && SubStr(jsonStr, pos, 1) = "]") {
            pos++
            return arr
        }
        
        loop {
            value := SimpleJSON._ParseValue(jsonStr, &pos)
            arr.Push(value)
            
            ; Skip whitespace
            while (pos <= StrLen(jsonStr) && InStr(" `t`n`r", SubStr(jsonStr, pos, 1))) {
                pos++
            }
            
            if (pos > StrLen(jsonStr)) {
                throw Error("Unexpected end of JSON")
            }
            
            char := SubStr(jsonStr, pos, 1)
            if (char = "]") {
                pos++
                break
            } else if (char = ",") {
                pos++
            } else {
                throw Error("Expected ',' or ']' at position " . pos)
            }
        }
        
        return arr
    }
    
    static _ParseString(jsonStr, &pos) {
        if (SubStr(jsonStr, pos, 1) != '"') {
            throw Error('Expected " at position ' . pos)
        }
        
        pos++
        start := pos
        result := ""
        
        while (pos <= StrLen(jsonStr)) {
            char := SubStr(jsonStr, pos, 1)
            
            if (char = '"') {
                pos++
                return result
            } else if (char = "\") {
                pos++
                if (pos > StrLen(jsonStr)) {
                    throw Error("Unexpected end of JSON in string")
                }
                escapeChar := SubStr(jsonStr, pos, 1)
                switch escapeChar {
                    case '"':
                        result .= '"'
                    case "\\":
                        result .= "\"
                    case "n":
                        result .= "`n"
                    case "r":
                        result .= "`r"
                    case "t":
                        result .= "`t"
                    default:
                        result .= escapeChar
                }
                pos++
            } else {
                result .= char
                pos++
            }
        }
        
        throw Error("Unterminated string")
    }
    
    static _ParseNumber(jsonStr, &pos) {
        start := pos
        
        ; Handle negative numbers
        if (SubStr(jsonStr, pos, 1) = "-") {
            pos++
        }
        
        ; Parse integer part
        if (!SimpleJSON._IsDigit(SubStr(jsonStr, pos, 1))) {
            throw Error("Invalid number at position " . pos)
        }
        
        while (pos <= StrLen(jsonStr) && SimpleJSON._IsDigit(SubStr(jsonStr, pos, 1))) {
            pos++
        }
        
        ; Parse decimal part if present
        if (pos <= StrLen(jsonStr) && SubStr(jsonStr, pos, 1) = ".") {
            pos++
            if (!SimpleJSON._IsDigit(SubStr(jsonStr, pos, 1))) {
                throw Error("Invalid number at position " . pos)
            }
            while (pos <= StrLen(jsonStr) && SimpleJSON._IsDigit(SubStr(jsonStr, pos, 1))) {
                pos++
            }
        }
        
        numberStr := SubStr(jsonStr, start, pos - start)
        return Number(numberStr)
    }
    
    static _IsDigit(char) {
        return (char >= "0" && char <= "9")
    }
}

; =============================================================================
; UTILITY FUNCTIONS
; =============================================================================
ToggleTheme() {
    global currentTheme, settings
    newTheme := (currentTheme = "light") ? "dark" : "light"
    ApplyTheme(newTheme)
    settings.darkMode := (newTheme = "dark")
    SaveSettings()
}

ClearChat() {
    global chatHistory, chatDisplay
    if (chatHistory.Length > 0) {
        result := MsgBox("Clear chat history?", "Confirm", "YesNo")
        if (result = "Yes") {
            chatHistory := []
            chatDisplay.Value := ""
        }
    }
}

; Function wrappers for hotkeys
SendMessageHotkey() {
    SendMessage("", "")
}

LoadModelsHotkey() {
    LoadModels()
}

ToggleThemeHotkey() {
    ToggleTheme()
}

ClearChatHotkey() {
    ClearChat()
}

; =============================================================================
; HOTKEYS
; =============================================================================
#HotIf WinActive(APP_TITLE)
{
    Hotkey("^Enter", (*) => SendMessageHotkey()
    Hotkey("^N", (*) => LoadModelsHotkey()
    ^T::ToggleThemeHotkey()
    ^L::ClearChatHotkey()
    Escape::ExitApp()
}
#HotIf

; Initialize
; Script end

