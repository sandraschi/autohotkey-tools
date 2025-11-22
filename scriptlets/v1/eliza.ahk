#NoEnv
#SingleInstance Force
#Persistent
SetWorkingDir %A_ScriptDir%
SetBatchLines -1

; ELIZA script patterns and responses
patterns := []
responses := []

; Initialize patterns and responses
InitializeEliza()

; Create the GUI
Gui, +AlwaysOnTop +Resize
Gui, Font, s10, Arial
Gui, Add, Edit, x10 y10 w400 h200 vChatLog ReadOnly, Welcome to ELIZA. Type your thoughts and press Enter.`n----------------------------------------`n
Gui, Add, Edit, x10 w400 h60 vUserInput gSubmit
Gui, Show, w420 h320, ELIZA Therapist
return

Submit:
    Gui, Submit, NoHide
    GuiControlGet, userInput,, UserInput
    GuiControl,, UserInput  ; Clear the input field
    
    ; Add user input to chat
    AddToChat("You: " . userInput)
    
    ; Get and display ELIZA's response
    response := GetElizaResponse(userInput)
    AddToChat("ELIZA: " . response)
return

AddToChat(text) {
    GuiControlGet, chatLog,, ChatLog
    GuiControl,, ChatLog, %chatLog%`n%text%
    SendMessage, 0x115, 7, 0, Edit1, A  ; Scroll to bottom
}

GetElizaResponse(input) {
    global patterns, responses
    
    ; Convert input to lowercase for matching
    input := " " . input . " "
    StringLower, input, input
    
    ; Check for patterns
    for index, pattern in patterns {
        if (InStr(input, pattern)) {
            response := responses[index]
            ; Replace placeholders
            response := RegExReplace(response, "\[name\]", "my friend")
            response := RegExReplace(response, "\[input\]", input)
            return response
        }
    }
    
    ; Default response if no pattern matches
    defaultResponses := ["Please go on.", "Tell me more about that.", "How does that make you feel?", "Can you elaborate on that?", "I see. And what does that suggest to you?"]
    Random, rand, 1, % defaultResponses.MaxIndex()
    return defaultResponses[rand]
}

InitializeEliza() {
    global patterns, responses
    
    ; Pattern-Response pairs
    patterns := []
    responses := []
    
    ; Add patterns and responses
    patterns.Push(" i need ")
    responses.Push("Why do you need [input]?")
    
    patterns.Push(" why don'?t you ")
    responses.Push("Do you really think I don't [input]?")
    
    patterns.Push(" why can'?t i ")
    responses.Push("Do you think you should be able to [input]?")
    
    patterns.Push(" i can'?t ")
    responses.Push("How do you know you can't [input]?")
    
    patterns.Push(" i am ")
    responses.Push("How long have you been [input]?")
    
    patterns.Push(" i'm ")
    responses.Push("How does being [input] make you feel?")
    
    patterns.Push(" are you ")
    responses.Push("Why are you interested in whether I am [input]?")
    
    patterns.Push(" what ")
    responses.Push("Why do you ask?")
    
    patterns.Push(" how ")
    responses.Push("How do you suppose?")
    
    patterns.Push(" because ")
    responses.Push("Is that the real reason?")
    
    patterns.Push(" sorry ")
    responses.Push("There are many times when no apology is needed.")
    
    patterns.Push(" i think ")
    responses.Push("You mention that you [input]. Can you tell me more?")
    
    patterns.Push(" i feel ")
    responses.Push("When you [input], how do you feel?")
    
    patterns.Push(" i have ")
    responses.Push("Why do you tell me that you've [input]?")
    
    patterns.Push(" i would ")
    responses.Push("Could you explain why you would [input]?")
    
    patterns.Push(" is there ")
    responses.Push("Do you think there is [input]?")
    
    patterns.Push(" can you ")
    responses.Push("You're not really asking me if I can [input], are you?")
    
    patterns.Push(" can i ")
    responses.Push("Perhaps you don't want to [input]?")
    
    patterns.Push(" you are ")
    responses.Push("What makes you think I am [input]?")
    
    patterns.Push(" you're ")
    responses.Push("Why do you say I am [input]?")
    
    patterns.Push(" i don'?t ")
    responses.Push("Don't you really [input]?")
    
    patterns.Push(" my ")
    responses.Push("I see, your [input]. How does that make you feel?")
    
    patterns.Push(" you ")
    responses.Push("We should be discussing you, not me.")
    
    patterns.Push(" why ")
    responses.Push("Why do you think [input]?")
    
    patterns.Push(" i want ")
    responses.Push("What would it mean to you if you got [input]?")
    
    patterns.Push(" mother ")
    responses.Push("Tell me more about your family.")
    
    patterns.Push(" father ")
    responses.Push("Your father?")
    
    patterns.Push(" child ")
    responses.Push("Did you have close friends as a child?")
    
    patterns.Push(" ? ")
    responses.Push("Why do you ask that?")
}

GuiClose:
    ExitApp
return
