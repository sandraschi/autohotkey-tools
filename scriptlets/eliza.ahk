#Requires AutoHotkey v2.0+
#SingleInstance Force
#Include %A_ScriptDir%\lib\ScriptletErrorHandler.ahk

; ==============================================================================
; ELIZA Chatbot
; @name: ELIZA Therapist Chatbot
; @version: 2.0.0
; @description: Classic ELIZA chatbot with optional ELIZA++ mode powered by Ollama local LLMs. Toggle between classic pattern-based responses and intelligent LLM-powered conversations.
; @description: Classic mode implements the original ELIZA algorithm with Rogerian psychotherapy patterns. ELIZA++ mode uses local Ollama models for more intelligent, context-aware therapeutic conversations.
; @description: Educational and entertaining implementation of one of the earliest chatbots, now enhanced with modern local LLM capabilities. Demonstrates both classic NLP patterns and modern conversational AI.
; @category: ai
; @author: Sandra
; @hotkeys: ^!e
; @enabled: true
; @priority: 80
; @tag: eliza, chatbot, ai, conversation, therapy, classic, nlp, entertainment, psychology
; @cli: --script <script_name> - Use specific ELIZA script (doctor, default)
; @cli: --gui - Launch with GUI interface (default)
; @cli: --console - Launch in console mode
; @cli: --help - Show CLI usage and ELIZA options
; @dependencies: 
; ==============================================================================

; Error handling - log to file instead of showing popups
OnError(LogError)

; =============================================================================
; CONFIGURATION
; =============================================================================
; UI Settings
APP_TITLE := "ELIZA Therapist"
WINDOW_WIDTH := 700
WINDOW_HEIGHT := 680
CHAT_HISTORY_HEIGHT := 450
INPUT_HEIGHT := 90
MARGIN := 20

; ELIZA++ (Ollama) Settings
OLLAMA_ENDPOINT := "http://localhost:11434"
OLLAMA_MODEL := "llama3"
USE_ELIZA_PLUS := false  ; Start with classic ELIZA
conversationHistory := []  ; Chat history for LLM

; =============================================================================
; MAIN SCRIPT
; =============================================================================
; Initialize ELIZA
patterns := []
responses := []
InitializeEliza()

; Create the GUI
CreateGUI()

; =============================================================================
; GUI CREATION
; =============================================================================
CreateGUI() {
    global guiEliza, chatHistory, userInput, statusBar, modeToggle, modeLabel
    
    ; Create main window with dark theme
    guiEliza := Gui("+Resize +MinSize600x500", APP_TITLE)
    guiEliza.BackColor := "1a1a1a"
    guiEliza.OnEvent("Close", (*) => ExitApp())
    guiEliza.OnEvent("Escape", (*) => guiEliza.Minimize())
    guiEliza.SetFont("s11 cFFFFFF", "Segoe UI")
    
    ; Header with title
    headerHeight := 60
    headerText := guiEliza.Add("Text", 
        "x" MARGIN " y" MARGIN " w" (WINDOW_WIDTH - MARGIN * 2) " h" headerHeight " Center", 
        "🧠 ELIZA Therapist")
    headerText.SetFont("s16 cFFFFFF Bold", "Segoe UI")
    
    subtitleY := MARGIN + headerHeight + 10
    subtitleText := guiEliza.Add("Text", 
        "x" MARGIN " y" subtitleY " w" (WINDOW_WIDTH - MARGIN * 2) " h20 Center", 
        "Your virtual therapeutic conversation partner")
    subtitleText.SetFont("s9 cCCCCCC", "Segoe UI")
    
    ; Mode toggle switch (ELIZA vs ELIZA++)
    toggleY := subtitleY + 25
    modeLabel := guiEliza.Add("Text", 
        "x" MARGIN " y" toggleY " w200 h25", 
        "Mode: Classic ELIZA")
    modeLabel.SetFont("s10 cFFFFFF Bold", "Segoe UI")
    
    modeToggle := guiEliza.Add("CheckBox", 
        "x" (WINDOW_WIDTH - MARGIN - 200) " y" toggleY " w200 h25 Checked" . (USE_ELIZA_PLUS ? 1 : 0), 
        "🤖 Enable ELIZA++ (Ollama LLM)")
    modeToggle.SetFont("s10 cCCCCCC", "Segoe UI")
    modeToggle.OnEvent("Click", ToggleMode)
    
    UpdateModeDisplay()
    
    ; Chat history area with better styling
    chatY := toggleY + 30
    chatHistoryLabel := guiEliza.Add("Text", 
        "x" MARGIN " y" chatY " w" (WINDOW_WIDTH - MARGIN * 2) " h20", 
        "Conversation History")
    chatHistoryLabel.SetFont("s10 cFFFFFF Bold", "Segoe UI")
    
    chatHistory := guiEliza.Add("Edit", 
        "x" MARGIN " y" (chatY + 25) " w" (WINDOW_WIDTH - MARGIN * 2) " h" CHAT_HISTORY_HEIGHT " ReadOnly +VScroll")
    chatHistory.BackColor := "2d2d2d"
    chatHistory.SetFont("s10 cE0E0E0", "Consolas")
    chatHistory.Value := "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━`n"
                      . "  Welcome to ELIZA, your virtual therapist.`n`n"
                      . "  Type your thoughts below and press Enter to send.`n"
                      . "  I'm here to listen and help you explore your feelings.`n"
                      . "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━`n`n"
    
    ; Input area with label
    inputY := chatY + CHAT_HISTORY_HEIGHT + 30
    inputLabel := guiEliza.Add("Text", 
        "x" MARGIN " y" inputY " w" (WINDOW_WIDTH - MARGIN * 2) " h20", 
        "Your Message")
    inputLabel.SetFont("s10 cFFFFFF Bold", "Segoe UI")
    
    userInput := guiEliza.Add("Edit", 
        "x" MARGIN " y" (inputY + 25) " w" (WINDOW_WIDTH - MARGIN * 2) " h" INPUT_HEIGHT " vUserInput")
    userInput.BackColor := "2d2d2d"
    userInput.SetFont("s11 cFFFFFF", "Segoe UI")
    userInput.OnEvent("Change", (ctrl, info) => CheckForEnter(ctrl, info))
    
    ; Buttons with better styling and spacing
    buttonY := inputY + INPUT_HEIGHT + 25
    btnSend := guiEliza.Add("Button", 
        "x" MARGIN " y" buttonY " w120 h40 Default", "&Send")
    btnSend.BackColor := "4CAF50"
    btnSend.SetFont("s11 cFFFFFF Bold", "Segoe UI")
    btnSend.OnEvent("Click", ProcessInput)
    
    btnClear := guiEliza.Add("Button", 
        "x" (MARGIN + 140) " y" buttonY " w120 h40", "C&lear")
    btnClear.BackColor := "FF9800"
    btnClear.SetFont("s11 cFFFFFF", "Segoe UI")
    btnClear.OnEvent("Click", ClearChat)
    
    ; Status bar with better styling
    statusBar := guiEliza.Add("StatusBar", , "✓ Ready - Type your message and press Enter")
    statusBar.SetFont("s9 cCCCCCC", "Segoe UI")
    
    ; Check Ollama availability on startup
    CheckOllamaAvailability()
    
    ; Show the window
    guiEliza.Show("w" WINDOW_WIDTH " h" WINDOW_HEIGHT)
    
    ; Set focus to input
    try {
        userInput.Focus()
    } catch {
        ; Fallback if focus fails
    }
}

; =============================================================================
; EVENT HANDLERS
; =============================================================================
CheckForEnter(ctrl, info) {
    if (info = 1) {  ; ENTER key was pressed
        ProcessInput()
    }
}

ProcessInput(*) {
    global guiEliza, chatHistory, userInput, USE_ELIZA_PLUS, statusBar
    
    ; Get user input
    userText := userInput.Value
    if (userText = "") {
        return
    }
    
    ; Clear input
    userInput.Value := ""
    
    try {
        ; Add user message to chat
        AddToChat("You: " . userText)
        
        ; Update status
        if (statusBar) {
            statusBar.Text := USE_ELIZA_PLUS ? "🤖 ELIZA++ is thinking..." : "💭 ELIZA is processing..."
        }
        
        ; Get and display response based on mode
        if (USE_ELIZA_PLUS) {
            response := GetElizaPlusResponse(userText)
        } else {
            response := GetElizaResponse(userText)
        }
        
        AddToChat("ELIZA: " . response)
        
        ; Update status
        if (statusBar) {
            statusBar.Text := USE_ELIZA_PLUS ? "✓ ELIZA++ ready - Using " . OLLAMA_MODEL : "✓ ELIZA ready"
        }
        
    } catch as e {
        AddToChat("System: An error occurred: " . e.Message)
        if (statusBar) {
            statusBar.Text := "✗ Error: " . e.Message
        }
    }
}

ToggleMode(*) {
    global modeToggle, modeLabel, USE_ELIZA_PLUS, statusBar, conversationHistory
    
    USE_ELIZA_PLUS := modeToggle.Value
    UpdateModeDisplay()
    
    ; Clear conversation history when switching modes
    conversationHistory := []
    
    ; Show mode change message
    if (USE_ELIZA_PLUS) {
        AddToChat("System: Switched to ELIZA++ mode (Ollama LLM powered)")
        if (statusBar) {
            statusBar.Text := "✓ ELIZA++ enabled - Using " . OLLAMA_MODEL . " @ " . OLLAMA_ENDPOINT
        }
    } else {
        AddToChat("System: Switched to Classic ELIZA mode (pattern-based)")
        if (statusBar) {
            statusBar.Text := "✓ Classic ELIZA enabled"
        }
    }
}

UpdateModeDisplay() {
    global modeLabel, USE_ELIZA_PLUS
    
    if (modeLabel) {
        if (USE_ELIZA_PLUS) {
            modeLabel.Text := "Mode: ELIZA++ (Ollama LLM)"
        } else {
            modeLabel.Text := "Mode: Classic ELIZA"
        }
    }
}

ClearChat(*) {
    global chatHistory, statusBar
    chatHistory.Value := "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━`n"
                      . "  Chat cleared. Continue your conversation...`n"
                      . "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━`n`n"
    if (statusBar) {
        statusBar.Text := "✓ Chat cleared - Continue your conversation"
    }
}

AddToChat(text) {
    global chatHistory
    
    ; Add timestamp with better formatting
    timestamp := FormatTime(A_Now, "HH:mm:ss")
    fullText := "  [" timestamp "] " text "`n`n"
    
    ; Append to chat history
    chatHistory.Value .= fullText
    
    ; Auto-scroll to bottom
    try {
        ; Scroll to bottom of chat history
        SendMessage(0x0115, 7, 0, chatHistory)  ; WM_VSCROLL, SB_BOTTOM
    } catch {
        ; If SendMessage fails, try alternative method
        chatHistory.Focus()
        Send("^{End}")
    }
}

; =============================================================================
; ELIZA++ (Ollama LLM) LOGIC
; =============================================================================
GetElizaPlusResponse(userMessage) {
    global OLLAMA_ENDPOINT, OLLAMA_MODEL, conversationHistory
    
    ; Add user message to conversation history
    conversationHistory.Push({role: "user", content: userMessage})
    
    ; Create system prompt for therapeutic conversation
    systemPrompt := "You are ELIZA, a Rogerian psychotherapist. Use reflective listening, open-ended questions, and therapeutic techniques. Keep responses concise (2-3 sentences) and empathetic. Focus on helping the user explore their feelings."
    
    ; Build messages array with system prompt at the start (if first message)
    messages := []
    if (conversationHistory.Length = 1) {
        messages.Push({role: "system", content: systemPrompt})
    }
    
    ; Add recent conversation history (last 10 messages to keep context manageable)
    historyStart := Max(1, conversationHistory.Length - 10)
    Loop conversationHistory.Length - historyStart + 1 {
        messages.Push(conversationHistory[historyStart + A_Index - 1])
    }
    
    ; Prepare request body
    requestBody := Map(
        "model", OLLAMA_MODEL,
        "messages", messages,
        "stream", false,
        "options", Map(
            "temperature", 0.7,
            "top_p", 0.9
        )
    )
    
    ; Convert to JSON (simple implementation - might need JSON library)
    jsonBody := ToJSON(requestBody)
    
    ; Send request to Ollama
    try {
        whr := ComObject("WinHttp.WinHttpRequest.5.1")
        whr.Open("POST", OLLAMA_ENDPOINT . "/api/chat", false)
        whr.SetRequestHeader("Content-Type", "application/json")
        whr.Send(jsonBody)
        
        if (whr.Status = 200) {
            response := whr.ResponseText
            ; Parse JSON response
            jsonResponse := ParseJSON(response)
            
            ; Check if response has message content
            if (jsonResponse.Has("message")) {
                message := jsonResponse.Get("message")
                if (Type(message) = "Map" && message.Has("content")) {
                    assistantMessage := message.Get("content")
                } else if (Type(message) = "Object" && HasProp(message, "content")) {
                    assistantMessage := message.content
                } else {
                    throw Error("Invalid message format in Ollama response")
                }
                
                ; Add assistant response to history
                conversationHistory.Push({role: "assistant", content: assistantMessage})
                
                ; Keep history manageable (last 20 messages)
                if (conversationHistory.Length > 20) {
                    conversationHistory.RemoveAt(1, conversationHistory.Length - 20)
                }
                
                return assistantMessage
            } else {
                throw Error("Invalid response format from Ollama")
            }
        } else {
            throw Error("Ollama API error: " . whr.Status . " " . whr.StatusText)
        }
    } catch as e {
        ; Fallback to classic ELIZA if Ollama fails
        errorMsg := "Ollama connection failed: " . e.Message . " Falling back to classic ELIZA."
        AddToChat("System: " . errorMsg)
        return GetElizaResponse(userMessage)
    }
}

; Simple JSON encoding (basic implementation)
ToJSON(obj) {
    if (Type(obj) = "String") {
        return '"' . StrReplace(StrReplace(obj, '\', '\\'), '"', '\"') . '"'
    } else if (Type(obj) = "Integer" || Type(obj) = "Float") {
        return String(obj)
    } else if (Type(obj) = "Array" || obj.HasMethod("__Enum")) {
        result := "["
        isFirst := true
        for item in obj {
            if (!isFirst) {
                result .= ","
            }
            result .= ToJSON(item)
            isFirst := false
        }
        result .= "]"
        return result
    } else if (Type(obj) = "Map" || obj.HasMethod("Has")) {
        result := "{"
        isFirst := true
        for key, value in obj {
            if (!isFirst) {
                result .= ","
            }
            result .= '"' . String(key) . '":' . ToJSON(value)
            isFirst := false
        }
        result .= "}"
        return result
    } else {
        return 'null'
    }
}

; Simple JSON parsing (basic implementation using regex)
ParseJSON(jsonStr) {
    ; This is a simplified parser - for production, use a proper JSON library
    ; Try to extract the message content (handles multi-line and escaped quotes)
    if (RegExMatch(jsonStr, '"content"\s*:\s*"(.*?)"', &match)) {
        content := match[1]
        ; Unescape JSON strings
        content := StrReplace(content, '\"', '"')
        content := StrReplace(content, '\\', '\')
        content := StrReplace(content, '\n', "`n")
        content := StrReplace(content, '\r', "`r")
        content := StrReplace(content, '\t', "`t")
        return Map("message", Map("content", content))
    }
    ; Alternative pattern for escaped quotes
    if (RegExMatch(jsonStr, '"content"\s*:\s*"(.*)"', &match)) {
        content := match[1]
        content := StrReplace(content, '\"', '"')
        content := StrReplace(content, '\\', '\')
        content := StrReplace(content, '\n', "`n")
        content := StrReplace(content, '\r', "`r")
        content := StrReplace(content, '\t', "`t")
        return Map("message", Map("content", content))
    }
    throw Error("Failed to parse Ollama response: " . SubStr(jsonStr, 1, 200))
}

; =============================================================================
; ELIZA LOGIC
; =============================================================================
GetElizaResponse(input) {
    global patterns, responses
    
    ; Convert input to lowercase for matching
    input := " " . input . " "
    input := StrLower(input)
    
    ; Check for patterns
    for index, pattern in patterns {
        if (InStr(input, pattern)) {
            response := responses[index]
            
            ; Extract the part after the matched pattern for [input] substitution
            if (InStr(response, "[input]")) {
                ; Find the position after the matched pattern
                pos := InStr(input, pattern) + StrLen(pattern)
                userInputLocal := SubStr(input, pos)
                userInputLocal := Trim(userInputLocal)
                
                ; Clean up the input (remove extra spaces, punctuation, etc.)
                userInputLocal := RegExReplace(userInputLocal, "^[\s,.;:!?]+", "")  ; Start
                userInputLocal := RegExReplace(userInputLocal, "[\s,.;:!?]+$", "")  ; End
                
                ; Replace placeholders
                response := StrReplace(response, "[input]", userInputLocal)
            }
            
            ; Replace other placeholders
            response := StrReplace(response, "[name]", "my friend")
            
            return response
        }
    }
    
    ; Default responses if no pattern matches
    defaultResponses := [
        "Please go on.",
        "Tell me more about that.",
        "How does that make you feel?",
        "Can you elaborate on that?",
        "I see. And what does that suggest to you?",
        "That's interesting. Please continue.",
        "What do you think that means?",
        "How do you feel when you say that?"
    ]
    
    randomIndex := Random(1, defaultResponses.Length)
    return defaultResponses[randomIndex]
}

CheckOllamaAvailability() {
    global OLLAMA_ENDPOINT, statusBar, modeToggle
    
    ; Try to connect to Ollama to check if it's running
    try {
        whr := ComObject("WinHttp.WinHttpRequest.5.1")
        whr.Open("GET", OLLAMA_ENDPOINT . "/api/tags", false)
        whr.SetTimeouts(2000, 2000, 2000, 2000)  ; 2 second timeout
        whr.Send()
        
        if (whr.Status = 200) {
            ; Ollama is available
            if (statusBar) {
                statusBar.Text := "✓ Ollama detected at " . OLLAMA_ENDPOINT . " - ELIZA++ available"
            }
        } else {
            if (statusBar) {
                statusBar.Text := "⚠ Ollama not responding - ELIZA++ may not work. Check if Ollama is running."
            }
        }
    } catch {
        ; Ollama not available
        if (statusBar) {
            statusBar.Text := "⚠ Ollama not detected - Using Classic ELIZA only"
        }
        ; Disable toggle if Ollama is not available
        if (modeToggle) {
            modeToggle.Enabled := false
            modeToggle.ToolTip := "Ollama not available. Install and start Ollama to use ELIZA++"
        }
    }
}

InitializeEliza() {
    global patterns, responses
    
    ; Clear any existing patterns and responses
    patterns := []
    responses := []
    
    ; Helper function to add patterns
    AddPattern(pattern, response) {
        patterns.Push(pattern)
        responses.Push(response)
    }
    
    ; Pattern-Response pairs
    AddPattern(" i need ", "Why do you need [input]?")
    AddPattern(" why don'?t you ", "Do you really think I don't [input]?")
    AddPattern(" why can'?t i ", "Do you think you should be able to [input]?")
    AddPattern(" i can'?t ", "How do you know you can't [input]?")
    AddPattern(" i am ", "How long have you been [input]?")
    AddPattern(" i'm ", "How does being [input] make you feel?")
    AddPattern(" are you ", "Why are you interested in whether I am [input]?")
    AddPattern(" what ", "Why do you ask?")
    AddPattern(" how ", "How do you suppose?")
    AddPattern(" because ", "Is that the real reason?")
    AddPattern(" sorry ", "There are many times when no apology is needed.")
    AddPattern(" i think ", "You mention that you [input]. Can you tell me more?")
    AddPattern(" i feel ", "When you [input], how do you feel?")
    AddPattern(" i have ", "Why do you tell me that you've [input]?")
    AddPattern(" i would ", "Could you explain why you would [input]?")
    AddPattern(" is there ", "Do you think there is [input]?")
    AddPattern(" can you ", "You're not really asking me if I can [input], are you?")
    AddPattern(" can i ", "Perhaps you don't want to [input]?")
    AddPattern(" you are ", "What makes you think I am [input]?")
    AddPattern(" you're ", "Why do you say I am [input]?")
    AddPattern(" i don'?t ", "Don't you really [input]?")
    AddPattern(" my ", "I see, your [input]. How does that make you feel?")
    AddPattern(" you ", "We should be discussing you, not me.")
    AddPattern(" why ", "Why do you think [input]?")
    AddPattern(" i want ", "What would it mean to you if you got [input]?")
    AddPattern(" mother ", "Tell me more about your family.")
    AddPattern(" father ", "Your father?")
    AddPattern(" child ", "Did you have close friends as a child?")
    AddPattern(" \? ", "Why do you ask that?")
    
    ; Add some modern patterns
    AddPattern(" ai ", "How do you feel about artificial intelligence?")
    AddPattern(" computer ", "Do computers worry you?")
    AddPattern(" dream ", "What does that dream suggest to you?")
    AddPattern(" hello ", "Hello... I'm glad you could drop by today.")
    AddPattern(" hi ", "Hi there... how are you today?")
    AddPattern(" maybe ", "You don't seem quite certain.")
    AddPattern(" no", "Why not?")
    AddPattern(" yes", "You seem quite sure.")
}
