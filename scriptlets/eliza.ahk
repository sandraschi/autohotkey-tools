#Requires AutoHotkey v2.0
#SingleInstance Force


; Suppress error popups - log to file instead
OnError(LogError)

LogError(Thrown, Mode) {
    FileAppend("Error: " . Thrown.Message . " at line " . Thrown.Line . "
", "errors.log", "UTF-8")`n        OutputDebug(errorMsg)  ; Enable LLM debugging
    return 1  ; Suppress popup (1 = suppress, 0 = show)
}

#Warn

; =============================================================================
; CONFIGURATION
; =============================================================================
; UI Settings
APP_TITLE := "ELIZA Therapist"
WINDOW_WIDTH := 500
WINDOW_HEIGHT := 500
CHAT_HISTORY_HEIGHT := 350
INPUT_HEIGHT := 80

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
    global guiEliza, chatHistory, userInput
    
    guiEliza := Gui("+Resize +MinSize400x300", APP_TITLE)
    guiEliza.OnEvent("Close", (*) => ExitApp())
    guiEliza.OnEvent("Escape", (*) => guiEliza.Minimize())
    guiEliza.SetFont("s10", "Segoe UI")
    
    ; Chat history (read-only)
    chatHistory := guiEliza.Add("Edit", 
        "x10 y10 w" (WINDOW_WIDTH-30) " h" CHAT_HISTORY_HEIGHT " ReadOnly")
    chatHistory.Value := "Welcome to ELIZA, your virtual therapist.`n"
                      . "Type your thoughts and press Enter.`n"
                      . "----------------------------------------`n"
    
    ; User input
    userInput := guiEliza.Add("Edit", 
        "x10 y" (CHAT_HISTORY_HEIGHT+20) " w" (WINDOW_WIDTH-30) " h" INPUT_HEIGHT " vUserInput")
    userInput.OnEvent("Change", (ctrl, info) => CheckForEnter(ctrl, info))
    
    ; Buttons
    btnSend := guiEliza.Add("Button", 
        "x10 y" (CHAT_HISTORY_HEIGHT+INPUT_HEIGHT+30) " w100 h30 Default", "&Send")
    btnSend.OnEvent("Click", ProcessInput)
    
    btnClear := guiEliza.Add("Button", 
        "x120 y" (CHAT_HISTORY_HEIGHT+INPUT_HEIGHT+30) " w100 h30", "C&lear")
    btnClear.OnEvent("Click", ClearChat)
    
    ; Status bar
    statusBar := guiEliza.Add("StatusBar", , "Ready")
    
    ; Show the window
    guiEliza.Show("w" WINDOW_WIDTH " h" WINDOW_HEIGHT)
    
    ; Set focus to input
    try {
        ControlFocus(userInput)
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
    global guiEliza, chatHistory, userInput
    
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
        
        ; Get and display ELIZA's response
        response := GetElizaResponse(userText)
        AddToChat("ELIZA: " . response)
        
    } catch as e {
        AddToChat("System: An error occurred: " . e.Message)
    }
}

ClearChat(*) {
    global chatHistory
    chatHistory.Value := "Chat cleared. Continue your conversation...`n"
                     . "----------------------------------------`n"
}

AddToChat(text) {
    global chatHistory
    
    ; Add timestamp
    timestamp := FormatTime("HH:mm:ss")
    fullText := "[" timestamp "] " text "`n"
    
    ; Append to chat history
    chatHistory.Value .= fullText
    
    ; Auto-scroll to bottom
    SendMessage(0x0115, 7, 0, chatHistory)  ; WM_VSCROLL, SB_BOTTOM
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
