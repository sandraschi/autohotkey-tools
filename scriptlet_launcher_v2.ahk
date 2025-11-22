; AutoHotkey v2 Script - Ultimate Scriptlet Launcher
; Organized into categories with 30+ useful and fun scriptlets
; Created: 2025-09-08

#Requires AutoHotkey v2.0
#SingleInstance Force
#Warn

; Set working directory to the script's location
SetWorkingDir A_ScriptDir

; Create the main GUI with tabs
MyGui := Gui(, "Ultimate Scriptlet Launcher")
MyGui.SetFont("s10", "Segoe UI")
MyGui.MarginX := 20
MyGui.MarginY := 15

; Add tabs for different categories
tab := MyGui.Add("Tab3", "w800 h600", ["Utilities", "Development", "Fun", "Games"])

; ========== UTILITIES ==========
tab.UseTab(1)
MyGui.Add("Text", "w760", "System Utilities - Press number keys or click buttons")
MyGui.Add("Text", "w760 cGray", "----------------------------------------------------")

utilScriptlets := Map(
    "01", ["Quick Note", QuickNote],
    "02", ["Screenshot to Clipboard", ScreenshotToClipboard],
    "03", ["Toggle Hidden Files", ToggleHiddenFiles],
    "04", ["Open CMD Here", OpenCmdHere],
    "05", ["Eject USB Drives", EjectUSB],
    "06", ["System Info", ShowSystemInfo],
    "07", ["Empty Recycle Bin", EmptyRecycleBin],
    "08", ["Toggle Dark Mode", ToggleDarkMode],
    "09", ["Window Opacity", ToggleWindowOpacity],
    "10", ["Clipboard History", ShowClipboardHistory],
    "11", ["Process Killer", ShowProcessList],
    "12", ["WiFi Password Reveal", ShowWifiPasswords],
    "13", ["Monitor Sleep", ToggleMonitorSleep],
    "14", ["Text to Speech", TextToSpeech],
    "15", ["Quick Calculator", ShowCalculator]
)

AddScriptletButtons(MyGui, utilScriptlets, 1)

; ========== DEVELOPMENT ==========
tab.UseTab(2)
MyGui.Add("Text", "w760", "Development Tools - Press number keys or click buttons")
MyGui.Add("Text", "w760 cGray", "----------------------------------------------------")

devScriptlets := Map(
    "16", ["Base64 Encode/Decode", Base64Tool],
    "17", ["JSON Formatter", JsonFormatter],
    "18", ["Timestamp Converter", TimestampTool],
    "19", ["Regex Tester", RegexTester],
    "20", ["Color Picker", ColorPicker],
    "21", ["HTTP Status Codes", ShowHttpStatusCodes],
    "22", ["Character Map", ShowCharMap],
    "23", ["GUID Generator", GenerateGuid],
    "24", ["HTML Entity Encoder", HtmlEntityEncoder],
    "25", ["URL Encoder/Decoder", UrlEncoder]
)

AddScriptletButtons(MyGui, devScriptlets, 2)

; ========== FUN ==========
tab.UseTab(3)
MyGui.Add("Text", "w760", "Fun Scriptlets - Press number keys or click buttons")
MyGui.Add("Text", "w760 cGray", "----------------------------------------------------")

funScriptlets := Map(
    "26", ["Dad Joke", TellDadJoke],
    "27", ["ASCII Art Generator", AsciiArtGenerator],
    "28", ["Text Effects", TextEffects],
    "29", ["Meme Generator", SimpleMemeGenerator],
    "30", ["Fortune Cookie", FortuneCookie],
    "31", ["Text to Emoji", TextToEmoji],
    "32", ["Random Password", GeneratePassword],
    "33", ["Countdown Timer", CountdownTimer],
    "34", ["Alarm Clock", SetAlarm],
    "35", ["Text to Binary", TextToBinary]
)

AddScriptletButtons(MyGui, funScriptlets, 3)

; ========== GAMES ==========
tab.UseTab(4)
MyGui.Add("Text", "w760", "Mini Games - Press number keys or click buttons")
MyGui.Add("Text", "w760 cGray", "----------------------------------------------------")

gameScriptlets := Map(
    "36", ["Snake Game", PlaySnake],
    "37", ["Tic-Tac-Toe", PlayTicTacToe],
    "38", ["Hangman", PlayHangman],
    "39", ["Memory Game", PlayMemoryGame],
    "40", ["Number Guesser", PlayNumberGuesser],
    "41", ["Typing Test", TypingTest],
    "42", ["Minesweeper", PlayMinesweeper],
    "43", ["Blackjack", PlayBlackjack],
    "44", ["Pong", PlayPong],
    "45", ["Space Invaders", PlaySpaceInvaders]
)

AddScriptletButtons(MyGui, gameScriptlets, 4)

tab.UseTab() ; End tab definition

; Add status bar
statusBar := MyGui.Add("StatusBar",, "Ready")

; Show the GUI
MyGui.Show("w840 h650")

; Register hotkeys for all scriptlets
RegisterHotkeys(utilScriptlets)
RegisterHotkeys(devScriptlets)
RegisterHotkeys(funScriptlets)
RegisterHotkeys(gameScriptlets)

; ========== HELPER FUNCTIONS ==========
AddScriptletButtons(gui, scriptlets, tabNum) {
    gui.SetFont("s9", "Consolas")
    for key, value in scriptlets {
        btn := gui.Add("Button", "w760 y+5", key ". " value[1])
        btn.OnEvent("Click", value[2])
    }
}

ShowHttpStatusCodes(*) {
    try {
        httpGui := Gui("+AlwaysOnTop", "HTTP Status Codes")
        httpGui.Add("Text",, "HTTP Status Code Reference:")
        httpList := httpGui.Add("ListView", "w500 h300 vHttpList", ["Code", "Status", "Description"])
        
        ; Add common HTTP status codes
        codes := [
            ["200", "OK", "Request successful"],
            ["201", "Created", "Resource created successfully"],
            ["204", "No Content", "Request successful, no content returned"],
            ["301", "Moved Permanently", "Resource permanently moved"],
            ["302", "Found", "Resource temporarily moved"],
            ["400", "Bad Request", "Invalid request syntax"],
            ["401", "Unauthorized", "Authentication required"],
            ["403", "Forbidden", "Access denied"],
            ["404", "Not Found", "Resource not found"],
            ["405", "Method Not Allowed", "HTTP method not supported"],
            ["408", "Request Timeout", "Request took too long"],
            ["429", "Too Many Requests", "Rate limit exceeded"],
            ["500", "Internal Server Error", "Server error occurred"],
            ["502", "Bad Gateway", "Invalid response from upstream"],
            ["503", "Service Unavailable", "Server temporarily unavailable"],
            ["504", "Gateway Timeout", "Upstream server timeout"]
        ]
        
        for code in codes {
            httpList.Add("", code[1], code[2], code[3])
        }
        
        httpGui.Add("Button", "Default w80", "Copy").OnEvent("Click", CopyCode)
        httpGui.Add("Button", "xp+90 yp w80", "Close").OnEvent("Click", (*) => httpGui.Destroy())
        httpGui.Show()
        
        CopyCode(*) {
            selected := httpList.GetNext()
            if (selected > 0) {
                code := httpList.GetText(selected, 1)
                status := httpList.GetText(selected, 2)
                A_Clipboard := code " " status
                statusBar.Text := "HTTP " code " " status " copied to clipboard"
            }
        }
        
        statusBar.Text := "HTTP status codes displayed"
    } catch as e {
        statusBar.Text := "Error showing HTTP codes: " e.Message
    }
}

ShowCharMap(*) {
    try {
        charGui := Gui("+AlwaysOnTop", "Character Map")
        charGui.Add("Text",, "Special Characters (click to copy):")
        
        ; Create character buttons
        chars := ["♠", "♣", "♥", "♦", "★", "☆", "♪", "♫", "☀", "☁", "☂", "❤", "✓", "✗", "→", "←",
                  "↑", "↓", "±", "∞", "≤", "≥", "≠", "≈", "°", "©", "®", "™", "€", "£", "¥", "¢"]
        
        ; Add character buttons in a grid
        x := 20
        y := 50
        for i, char in chars {
            btn := charGui.Add("Button", "x" x " y" y " w40 h30", char)
            btn.OnEvent("Click", (*) => CopyChar(char))
            x += 45
            if (Mod(i, 8) = 0) {
                x := 20
                y += 35
            }
        }
        
        charGui.Add("Text", "x20 y" (y + 40) " w360", "Selected character will be copied to clipboard")
        charGui.Add("Button", "x20 y" (y + 70) " w80", "Close").OnEvent("Click", (*) => charGui.Destroy())
        charGui.Show("w400 h" (y + 110))
        
        CopyChar(char) {
            A_Clipboard := char
            statusBar.Text := "Character '" char "' copied to clipboard"
        }
        
        statusBar.Text := "Character map opened"
    } catch as e {
        statusBar.Text := "Error opening character map: " e.Message
    }
}

GenerateGuid(*) {
    try {
        guidGui := Gui("+AlwaysOnTop", "GUID Generator")
        guidGui.Add("Text",, "Generated GUIDs:")
        guidGui.Add("Edit", "w400 h200 ReadOnly vGuidList")
        guidGui.Add("Button", "Default w120", "Generate New").OnEvent("Click", GenerateNew)
        guidGui.Add("Button", "xp+130 yp w120", "Copy All").OnEvent("Click", CopyAll)
        guidGui.Add("Button", "xm y+10 w120", "Clear").OnEvent("Click", ClearAll)
        guidGui.Add("Button", "xp+130 yp w120", "Close").OnEvent("Click", (*) => guidGui.Destroy())
        guidGui.Show()
        
        ; Generate initial GUID
        GenerateNew()
        
        GenerateNew(*) {
            ; Generate GUID using COM
            try {
                guid := ComObject("Scriptlet.TypeLib").Guid
                guid := StrReplace(guid, "{")
                guid := StrReplace(guid, "}")
                guid := RTrim(guid)
                
                current := guidGui["GuidList"].Value
                if (current != "")
                    current .= "`n"
                guidGui["GuidList"].Value := current guid
                
                ; Copy to clipboard
                A_Clipboard := guid
                statusBar.Text := "New GUID generated and copied: " guid
            } catch as e {
                statusBar.Text := "Error generating GUID: " e.Message
            }
        }
        
        CopyAll(*) {
            A_Clipboard := guidGui["GuidList"].Value
            statusBar.Text := "All GUIDs copied to clipboard"
        }
        
        ClearAll(*) {
            guidGui["GuidList"].Value := ""
            statusBar.Text := "GUID list cleared"
        }
        
    } catch as e {
        statusBar.Text := "Error opening GUID generator: " e.Message
    }
}

HtmlEntityEncoder(*) {
    try {
        htmlGui := Gui("+AlwaysOnTop", "HTML Entity Encoder")
        htmlGui.Add("Text",, "Text to encode/decode:")
        htmlGui.Add("Edit", "w500 h100 vHtmlText")
        htmlGui.Add("Button", "Default w120", "Encode").OnEvent("Click", EncodeHtml)
        htmlGui.Add("Button", "xp+130 yp w120", "Decode").OnEvent("Click", DecodeHtml)
        htmlGui.Add("Edit", "xm y+20 w500 h150 ReadOnly vHtmlResult")
        htmlGui.Show()
        
        EncodeHtml(*) {
            try {
                text := htmlGui["HtmlText"].Value
                ; Basic HTML entity encoding
                encoded := StrReplace(text, "&", "&amp;")
                encoded := StrReplace(encoded, "<", "&lt;")
                encoded := StrReplace(encoded, ">", "&gt;")
                encoded := StrReplace(encoded, '"', "&quot;")
                encoded := StrReplace(encoded, "'", "&#39;")
                encoded := StrReplace(encoded, " ", "&nbsp;")
                
                htmlGui["HtmlResult"].Value := encoded
                A_Clipboard := encoded
                statusBar.Text := "HTML encoded and copied to clipboard"
            } catch as e {
                statusBar.Text := "Error encoding HTML: " e.Message
            }
        }
        
        DecodeHtml(*) {
            try {
                text := htmlGui["HtmlText"].Value
                ; Basic HTML entity decoding
                decoded := StrReplace(text, "&amp;", "&")
                decoded := StrReplace(decoded, "&lt;", "<")
                decoded := StrReplace(decoded, "&gt;", ">")
                decoded := StrReplace(decoded, "&quot;", '"')
                decoded := StrReplace(decoded, "&#39;", "'")
                decoded := StrReplace(decoded, "&nbsp;", " ")
                
                htmlGui["HtmlResult"].Value := decoded
                A_Clipboard := decoded
                statusBar.Text := "HTML decoded and copied to clipboard"
            } catch as e {
                statusBar.Text := "Error decoding HTML: " e.Message
            }
        }
        
    } catch as e {
        statusBar.Text := "Error opening HTML encoder: " e.Message
    }
}

UrlEncoder(*) {
    try {
        urlGui := Gui("+AlwaysOnTop", "URL Encoder/Decoder")
        urlGui.Add("Text",, "URL to encode/decode:")
        urlGui.Add("Edit", "w500 h100 vUrlText")
        urlGui.Add("Button", "Default w120", "Encode").OnEvent("Click", EncodeUrl)
        urlGui.Add("Button", "xp+130 yp w120", "Decode").OnEvent("Click", DecodeUrl)
        urlGui.Add("Edit", "xm y+20 w500 h150 ReadOnly vUrlResult")
        urlGui.Show()
        
        EncodeUrl(*) {
            try {
                text := urlGui["UrlText"].Value
                ; Basic URL encoding for common characters
                encoded := StrReplace(text, " ", "%20")
                encoded := StrReplace(encoded, "!", "%21")
                encoded := StrReplace(encoded, '"', "%22")
                encoded := StrReplace(encoded, "#", "%23")
                encoded := StrReplace(encoded, "$", "%24")
                encoded := StrReplace(encoded, "%", "%25")
                encoded := StrReplace(encoded, "&", "%26")
                encoded := StrReplace(encoded, "'", "%27")
                encoded := StrReplace(encoded, "(", "%28")
                encoded := StrReplace(encoded, ")", "%29")
                encoded := StrReplace(encoded, "+", "%2B")
                encoded := StrReplace(encoded, ",", "%2C")
                encoded := StrReplace(encoded, "/", "%2F")
                encoded := StrReplace(encoded, ":", "%3A")
                encoded := StrReplace(encoded, ";", "%3B")
                encoded := StrReplace(encoded, "=", "%3D")
                encoded := StrReplace(encoded, "?", "%3F")
                encoded := StrReplace(encoded, "@", "%40")
                
                urlGui["UrlResult"].Value := encoded
                A_Clipboard := encoded
                statusBar.Text := "URL encoded and copied to clipboard"
            } catch as e {
                statusBar.Text := "Error encoding URL: " e.Message
            }
        }
        
        DecodeUrl(*) {
            try {
                text := urlGui["UrlText"].Value
                ; Basic URL decoding
                decoded := StrReplace(text, "%20", " ")
                decoded := StrReplace(decoded, "%21", "!")
                decoded := StrReplace(decoded, "%22", '"')
                decoded := StrReplace(decoded, "%23", "#")
                decoded := StrReplace(decoded, "%24", "$")
                decoded := StrReplace(decoded, "%25", "%")
                decoded := StrReplace(decoded, "%26", "&")
                decoded := StrReplace(decoded, "%27", "'")
                decoded := StrReplace(decoded, "%28", "(")
                decoded := StrReplace(decoded, "%29", ")")
                decoded := StrReplace(decoded, "%2B", "+")
                decoded := StrReplace(decoded, "%2C", ",")
                decoded := StrReplace(decoded, "%2F", "/")
                decoded := StrReplace(decoded, "%3A", ":")
                decoded := StrReplace(decoded, "%3B", ";")
                decoded := StrReplace(decoded, "%3D", "=")
                decoded := StrReplace(decoded, "%3F", "?")
                decoded := StrReplace(decoded, "%40", "@")
                
                urlGui["UrlResult"].Value := decoded
                A_Clipboard := decoded
                statusBar.Text := "URL decoded and copied to clipboard"
            } catch as e {
                statusBar.Text := "Error decoding URL: " e.Message
            }
        }
        
    } catch as e {
        statusBar.Text := "Error opening URL encoder: " e.Message
    }
}

; ========== DEVELOPMENT TOOLS CONTINUED ==========

JsonFormatter(*) {
    try {
        jsonGui := Gui("+AlwaysOnTop", "JSON Formatter")
        jsonGui.Add("Text",, "Enter JSON to format:")
        jsonGui.Add("Edit", "w500 h150 vJsonInput")
        jsonGui.Add("Button", "Default w120", "Format").OnEvent("Click", FormatJson)
        jsonGui.Add("Button", "xp+130 yp w120", "Minify").OnEvent("Click", MinifyJson)
        jsonGui.Add("Edit", "w500 h200 ReadOnly vJsonResult")
        jsonGui.Show()
        
        FormatJson(*) {
            try {
                jsonText := jsonGui["JsonInput"].Value
                script := ComObject("ScriptControl")
                script.Language := "JScript"
                formatted := script.Eval("JSON.stringify(JSON.parse('" StrReplace(jsonText, "'", "\'") "'), null, 2)")
                jsonGui["JsonResult"].Value := formatted
                statusBar.Text := "JSON formatted successfully"
            } catch as e {
                jsonGui["JsonResult"].Value := "Error: Invalid JSON - " e.Message
                statusBar.Text := "JSON formatting error"
            }
        }
        
        MinifyJson(*) {
            try {
                jsonText := jsonGui["JsonInput"].Value
                script := ComObject("ScriptControl")
                script.Language := "JScript"
                minified := script.Eval("JSON.stringify(JSON.parse('" StrReplace(jsonText, "'", "\'") "'))")
                jsonGui["JsonResult"].Value := minified
                statusBar.Text := "JSON minified successfully"
            } catch as e {
                jsonGui["JsonResult"].Value := "Error: Invalid JSON - " e.Message
                statusBar.Text := "JSON minifying error"
            }
        }
    } catch as e {
        statusBar.Text := "Error opening JSON formatter: " e.Message
    }
}

TimestampTool(*) {
    try {
        timestampGui := Gui("+AlwaysOnTop", "Timestamp Converter")
        timestampGui.Add("Text",, "Unix timestamp:")
        timestampGui.Add("Edit", "w300 h30 vTimestampInput")
        timestampGui.Add("Button", "xp+320 yp w100", "To Date").OnEvent("Click", TimestampToDate)
        
        timestampGui.Add("Text", "xm y+20", "Date/Time (YYYY-MM-DD HH:MM:SS):")
        timestampGui.Add("Edit", "w300 h30 vDateInput")
        timestampGui.Add("Button", "xp+320 yp w100", "To Timestamp").OnEvent("Click", DateToTimestamp)
        
        timestampGui.Add("Edit", "xm y+20 w420 h100 ReadOnly vTimestampResult")
        timestampGui.Show()
        
        FormatTime(currentTime, A_Now, "yyyy-MM-dd HH:mm:ss")
        timestampGui["TimestampResult"].Value := "Current time: " currentTime
        
        TimestampToDate(*) {
            try {
                timestamp := timestampGui["TimestampInput"].Value
                if (timestamp) {
                    dateTime := DateAdd("19700101000000", timestamp, "Seconds")
                    FormatTime readable, dateTime, "yyyy-MM-dd HH:mm:ss"
                    timestampGui["TimestampResult"].Value := "Timestamp " timestamp " = " readable
                }
            } catch as e {
                timestampGui["TimestampResult"].Value := "Error converting timestamp: " e.Message
            }
        }
        
        DateToTimestamp(*) {
            try {
                dateInput := timestampGui["DateInput"].Value
                if (dateInput) {
                    dateInput := StrReplace(dateInput, " ", "")
                    dateInput := StrReplace(dateInput, "-", "")
                    dateInput := StrReplace(dateInput, ":", "")
                    timestamp := DateDiff(dateInput, "19700101000000", "Seconds")
                    timestampGui["TimestampResult"].Value := "Date converts to timestamp: " timestamp
                }
            } catch as e {
                timestampGui["TimestampResult"].Value := "Error converting date: " e.Message
            }
        }
        
        statusBar.Text := "Timestamp converter opened"
    } catch as e {
        statusBar.Text := "Error opening timestamp tool: " e.Message
    }
}

RegexTester(*) {
    try {
        regexGui := Gui("+AlwaysOnTop", "Regex Tester")
        regexGui.Add("Text",, "Regular Expression:")
        regexGui.Add("Edit", "w500 h30 vRegexPattern")
        regexGui.Add("Text", "y+10", "Test Text:")
        regexGui.Add("Edit", "w500 h100 vTestText")
        regexGui.Add("Button", "Default w100", "Test").OnEvent("Click", TestRegex)
        regexGui.Add("Button", "xp+110 yp w100", "Find All").OnEvent("Click", FindAllMatches)
        regexGui.Add("Edit", "xm y+20 w500 h150 ReadOnly vRegexResult")
        regexGui.Show()
        
        TestRegex(*) {
            try {
                pattern := regexGui["RegexPattern"].Value
                text := regexGui["TestText"].Value
                
                if (RegExMatch(text, pattern, &match)) {
                    result := "Match found: " match[0] "`n"
                    if (match.Count > 1) {
                        Loop match.Count - 1
                            result .= "Group " A_Index ": " match[A_Index] "`n"
                    }
                    regexGui["RegexResult"].Value := result
                } else {
                    regexGui["RegexResult"].Value := "No matches found"
                }
            } catch as e {
                regexGui["RegexResult"].Value := "Error: " e.Message
            }
        }
        
        FindAllMatches(*) {
            try {
                pattern := regexGui["RegexPattern"].Value
                text := regexGui["TestText"].Value
                result := "All matches:`n"
                
                pos := 1
                count := 0
                while (pos := RegExMatch(text, pattern, &match, pos)) {
                    count++
                    result .= count ": " match[0] "`n"
                    pos := match.Pos + match.Len
                }
                
                if (count = 0)
                    result := "No matches found"
                else
                    result .= "`nTotal matches: " count
                
                regexGui["RegexResult"].Value := result
            } catch as e {
                regexGui["RegexResult"].Value := "Error: " e.Message
            }
        }
        
        statusBar.Text := "Regex tester opened"
    } catch as e {
        statusBar.Text := "Error opening regex tester: " e.Message
    }
}

ColorPicker(*) {
    try {
        colorGui := Gui("+AlwaysOnTop", "Color Picker")
        colorGui.Add("Text",, "Click to pick a color from screen:")
        colorGui.Add("Button", "Default w200", "Pick Color").OnEvent("Click", PickColor)
        colorGui.Add("Text", "y+20", "Selected Color:")
        colorGui.Add("Progress", "w50 h50 vColorSample BackgroundDefault")
        colorGui.Add("Edit", "xp+60 yp+15 w200 ReadOnly vColorInfo")
        colorGui.Show()
        
        PickColor(*) {
            MouseGetPos &x, &y
            color := PixelGetColor(x, y)
            
            hexColor := Format("#{:06X}", color)
            r := (color >> 16) & 0xFF
            g := (color >> 8) & 0xFF
            b := color & 0xFF
            
            colorGui["ColorSample"].Opt("Background" color)
            colorGui["ColorInfo"].Value := "Hex: " hexColor "`nRGB: " r ", " g ", " b
            
            A_Clipboard := hexColor
            statusBar.Text := "Color " hexColor " copied to clipboard"
        }
        
    } catch as e {
        statusBar.Text := "Error opening color picker: " e.Message
    }
}

ShowClipboardHistory(*) {
    try {
        ; Simple clipboard history (just current content)
        clipGui := Gui("+AlwaysOnTop", "Clipboard Content")
        clipGui.Add("Text",, "Current clipboard content:")
        clipGui.Add("Edit", "w500 h200 ReadOnly vClipText", A_Clipboard)
        clipGui.Add("Button", "Default w80", "Clear").OnEvent("Click", ClearClipboard)
        clipGui.Add("Button", "xp+90 yp w80", "Close").OnEvent("Click", (*) => clipGui.Destroy())
        clipGui.Show()
        statusBar.Text := "Clipboard history displayed"
        
        ClearClipboard(*) {
            A_Clipboard := ""
            clipGui.Destroy()
        }
    } catch as e {
        statusBar.Text := "Error showing clipboard: " e.Message
    }
}

ShowProcessList(*) {
    try {
        processGui := Gui("+AlwaysOnTop", "Process Manager")
        processGui.Add("Text",, "Running processes (select to kill):")
        processList := processGui.Add("ListView", "w600 h300 vProcessList", ["PID", "Name", "Memory"])
        
        ; Get process list
        for process in ComObjGet("winmgmts:").ExecQuery("SELECT * FROM Win32_Process") {
            try {
                memory := Round(process.WorkingSetSize / 1024 / 1024, 1)
                processList.Add("", process.ProcessId, process.Name, memory " MB")
            }
        }
        
        processGui.Add("Button", "Default w80", "Kill").OnEvent("Click", KillSelected)
        processGui.Add("Button", "xp+90 yp w80", "Refresh").OnEvent("Click", RefreshList)
        processGui.Add("Button", "xp+90 yp w80", "Close").OnEvent("Click", (*) => processGui.Destroy())
        processGui.Show()
        
        KillSelected(*) {
            selected := processList.GetNext()
            if (selected > 0) {
                pid := processList.GetText(selected, 1)
                name := processList.GetText(selected, 2)
                result := MsgBox("Kill process " name " (PID: " pid ")?", "Confirm", "YesNo Icon!")
                if (result = "Yes") {
                    try {
                        ProcessClose(pid)
                        statusBar.Text := "Process " name " killed"
                        RefreshList()
                    } catch {
                        statusBar.Text := "Failed to kill process " name
                    }
                }
            }
        }
        
        RefreshList(*) {
            processList.Delete()
            for process in ComObjGet("winmgmts:").ExecQuery("SELECT * FROM Win32_Process") {
                try {
                    memory := Round(process.WorkingSetSize / 1024 / 1024, 1)
                    processList.Add("", process.ProcessId, process.Name, memory " MB")
                }
            }
        }
        
        statusBar.Text := "Process list displayed"
    } catch as e {
        statusBar.Text := "Error showing processes: " e.Message
    }
}

ShowWifiPasswords(*) {
    try {
        wifiGui := Gui("+AlwaysOnTop", "WiFi Passwords")
        wifiGui.Add("Text",, "Saved WiFi profiles and passwords:")
        wifiList := wifiGui.Add("ListView", "w500 h300 vWifiList", ["Profile", "Password"])
        
        ; Get WiFi profiles
        RunWait "netsh wlan show profiles > " A_Temp "\profiles.txt", , "Hide"
        profiles := FileRead(A_Temp "\profiles.txt")
        
        Loop Parse, profiles, "`n" {
            if (InStr(A_LoopField, "All User Profile")) {
                profile := RegExReplace(A_LoopField, ".*: (.+)", "$1")
                profile := Trim(profile)
                
                ; Get password for this profile
                RunWait 'netsh wlan show profile "' profile '" key=clear > ' A_Temp '\profile.txt', , "Hide"
                profileData := FileRead(A_Temp "\profile.txt")
                
                password := "No password"
                if (RegExMatch(profileData, "Key Content\s*:\s*(.+)", &match))
                    password := Trim(match[1])
                
                wifiList.Add("", profile, password)
            }
        }
        
        wifiGui.Add("Button", "Default w80", "Copy").OnEvent("Click", CopyPassword)
        wifiGui.Add("Button", "xp+90 yp w80", "Close").OnEvent("Click", (*) => wifiGui.Destroy())
        wifiGui.Show()
        
        CopyPassword(*) {
            selected := wifiList.GetNext()
            if (selected > 0) {
                password := wifiList.GetText(selected, 2)
                A_Clipboard := password
                statusBar.Text := "Password copied to clipboard"
            }
        }
        
        ; Clean up temp files
        FileDelete A_Temp "\profiles.txt"
        FileDelete A_Temp "\profile.txt"
        
        statusBar.Text := "WiFi passwords displayed"
    } catch as e {
        statusBar.Text := "Error getting WiFi passwords: " e.Message
    }
}

ToggleMonitorSleep(*) {
    try {
        ; Turn off monitors
        SendMessage 0x112, 0xF170, 2, , "Program Manager"
        statusBar.Text := "Monitors turned off"
    } catch as e {
        statusBar.Text := "Error turning off monitors: " e.Message
    }
}

TextToSpeech(*) {
    try {
        ttsGui := Gui("+AlwaysOnTop", "Text to Speech")
        ttsGui.Add("Text",, "Enter text to speak:")
        ttsGui.Add("Edit", "w400 h100 vTtsText")
        ttsGui.Add("Button", "Default w80", "Speak").OnEvent("Click", SpeakText)
        ttsGui.Add("Button", "xp+90 yp w80", "Stop").OnEvent("Click", StopSpeech)
        ttsGui.Add("Button", "xp+90 yp w80", "Close").OnEvent("Click", (*) => ttsGui.Destroy())
        ttsGui.Show()
        
        ; Create speech object
        static voice := ComObject("SAPI.SpVoice")
        
        SpeakText(*) {
            text := ttsGui["TtsText"].Value
            if (text) {
                try {
                    voice.Speak(text, 1)  ; 1 = asynchronous
                    statusBar.Text := "Speaking text..."
                } catch as e {
                    statusBar.Text := "Error speaking: " e.Message
                }
            }
        }
        
        StopSpeech(*) {
            try {
                voice.Speak("", 2)  ; 2 = purge before speak
                statusBar.Text := "Speech stopped"
            } catch as e {
                statusBar.Text := "Error stopping speech: " e.Message
            }
        }
        
    } catch as e {
        statusBar.Text := "Error initializing TTS: " e.Message
    }
}

ShowCalculator(*) {
    try {
        calcGui := Gui("+AlwaysOnTop", "Quick Calculator")
        calcGui.Add("Text",, "Enter calculation:")
        calcGui.Add("Edit", "w300 h30 vCalcInput")
        calcGui.Add("Text", "w300 h30 vCalcResult", "Result: ")
        calcGui.Add("Button", "Default w80", "Calculate").OnEvent("Click", Calculate)
        calcGui.Add("Button", "xp+90 yp w80", "Clear").OnEvent("Click", ClearCalc)
        calcGui.Add("Button", "xp+90 yp w80", "Close").OnEvent("Click", (*) => calcGui.Destroy())
        calcGui.Show()
        
        Calculate(*) {
            try {
                expression := calcGui["CalcInput"].Value
                ; Simple math evaluation using COM
                result := ComObject("ScriptControl")
                result.Language := "JScript"
                answer := result.Eval(expression)
                calcGui["CalcResult"].Value := "Result: " answer
                A_Clipboard := answer
                statusBar.Text := "Result copied to clipboard"
            } catch as e {
                calcGui["CalcResult"].Value := "Error: Invalid expression"
                statusBar.Text := "Calculation error"
            }
        }
        
        ClearCalc(*) {
            calcGui["CalcInput"].Value := ""
            calcGui["CalcResult"].Value := "Result: "
        }
        
    } catch as e {
        statusBar.Text := "Error opening calculator: " e.Message
    }
}

; ========== UTILITY FUNCTION IMPLEMENTATIONS ==========

ToggleHiddenFiles(*) {
    try {
        ; Toggle hidden files in File Explorer
        RegRead currentValue, "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced", "Hidden"
        newValue := currentValue = 1 ? 2 : 1
        RegWrite newValue, "REG_DWORD", "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced", "Hidden"
        
        ; Refresh all explorer windows
        for window in ComObjCreate("Shell.Application").Windows
            window.Refresh()
        
        statusBar.Text := newValue = 1 ? "Hidden files now visible" : "Hidden files now hidden"
    } catch as e {
        statusBar.Text := "Error toggling hidden files: " e.Message
    }
}

OpenCmdHere(*) {
    try {
        ; Get active window path or use desktop
        hwnd := WinGetID("A")
        path := "C:\"
        
        ; Try to get path from File Explorer window
        try {
            for window in ComObjCreate("Shell.Application").Windows {
                if (window.HWND = hwnd) {
                    path := window.Document.Folder.Self.Path
                    break
                }
            }
        }
        
        Run 'cmd.exe /k cd /d "' path '"', path
        statusBar.Text := "Command prompt opened at: " path
    } catch as e {
        statusBar.Text := "Error opening command prompt: " e.Message
    }
}

EjectUSB(*) {
    try {
        ; Get removable drives
        drives := []
        Loop Parse, "ABCDEFGHIJKLMNOPQRSTUVWXYZ" {
            drive := A_LoopField ":"
            if (DriveType(drive) = "Removable") {
                drives.Push(drive)
            }
        }
        
        if (drives.Length = 0) {
            statusBar.Text := "No removable drives found"
            return
        }
        
        ; Create selection GUI
        ejectGui := Gui("+AlwaysOnTop", "Eject USB Drive")
        ejectGui.Add("Text",, "Select drive to eject:")
        driveList := ejectGui.Add("ListBox", "w200 h100 vDriveList")
        
        for drive in drives {
            label := DriveGetLabel(drive)
            driveList.Add(drive " (" (label || "No Label") ")")
        }
        
        ejectGui.Add("Button", "Default w80", "Eject").OnEvent("Click", EjectSelected)
        ejectGui.Add("Button", "xp+90 yp w80", "Cancel").OnEvent("Click", (*) => ejectGui.Destroy())
        ejectGui.Show()
        
        EjectSelected(*) {
            selected := driveList.Value
            if (selected > 0) {
                drive := drives[selected]
                try {
                    RunWait "powershell.exe -Command `"(New-Object -comObject Shell.Application).Namespace(17).ParseName('" drive "').InvokeVerb('Eject')`""
                    statusBar.Text := "Drive " drive " ejected successfully"
                } catch {
                    statusBar.Text := "Failed to eject drive " drive
                }
            }
            ejectGui.Destroy()
        }
    } catch as e {
        statusBar.Text := "Error ejecting USB: " e.Message
    }
}

ShowSystemInfo(*) {
    try {
        info := "System Information`n"
        info .= "=================`n`n"
        info .= "Computer: " A_ComputerName "`n"
        info .= "User: " A_UserName "`n"
        info .= "OS: " A_OSVersion "`n"
        info .= "Is Admin: " (A_IsAdmin ? "Yes" : "No") "`n"
        info .= "Screen: " A_ScreenWidth "x" A_ScreenHeight "`n"
        info .= "Working Dir: " A_WorkingDir "`n"
        info .= "Script Dir: " A_ScriptDir "`n"
        info .= "Temp Dir: " A_Temp "`n"
        
        ; Get memory info
        VarSetStrCapacity(&memInfo, 64)
        DllCall("kernel32\GlobalMemoryStatusEx", "Ptr", NumPut("UInt", 64, memInfo))
        totalMem := Round(NumGet(memInfo, 8, "UInt64") / 1024**3, 1)
        availMem := Round(NumGet(memInfo, 16, "UInt64") / 1024**3, 1)
        
        info .= "Total RAM: " totalMem " GB`n"
        info .= "Available RAM: " availMem " GB`n"
        
        MsgBox info, "System Information", "OK Iconinformation"
        statusBar.Text := "System information displayed"
    } catch as e {
        statusBar.Text := "Error getting system info: " e.Message
    }
}

EmptyRecycleBin(*) {
    try {
        result := MsgBox("Empty the Recycle Bin?`n`nThis action cannot be undone.", "Confirm", "YesNo Icon?")
        if (result = "Yes") {
            DllCall("shell32\SHEmptyRecycleBin", "Ptr", 0, "Ptr", 0, "UInt", 0x0001)
            statusBar.Text := "Recycle Bin emptied"
        }
    } catch as e {
        statusBar.Text := "Error emptying recycle bin: " e.Message
    }
}

ToggleDarkMode(*) {
    try {
        ; Toggle Windows dark mode
        RegRead currentValue, "HKCU\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize", "AppsUseLightTheme"
        newValue := currentValue = 0 ? 1 : 0
        RegWrite newValue, "REG_DWORD", "HKCU\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize", "AppsUseLightTheme"
        RegWrite newValue, "REG_DWORD", "HKCU\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize", "SystemUsesLightTheme"
        
        statusBar.Text := newValue = 0 ? "Dark mode enabled" : "Light mode enabled"
    } catch as e {
        statusBar.Text := "Error toggling dark mode: " e.Message
    }
}

ToggleWindowOpacity(*) {
    try {
        hwnd := WinGetID("A")
        currentTrans := WinGetTransparent(hwnd)
        
        if (currentTrans = "") {
            WinSetTransparent(200, hwnd)
            statusBar.Text := "Window transparency: 80%"
        } else if (currentTrans = 200) {
            WinSetTransparent(100, hwnd)
            statusBar.Text := "Window transparency: 60%"
        } else {
            WinSetTransparent("Off", hwnd)
            statusBar.Text := "Window transparency: Off"
        }
    } catch as e {
        statusBar.Text := "Error changing window opacity: " e.Message
    }
}

RegisterHotkeys(scriptlets) {
    for key in scriptlets {
        Hotkey "~" key, (*) => scriptlets[key][2].Call()
    }
}

; ========== UTILITY SCRIPTLETS ==========
QuickNote(*) {
    noteGui := Gui("+AlwaysOnTop -SysMenu", "Quick Note")
    noteGui.Add("Edit", "w500 h300 vNoteText")
    noteGui.Add("Button", "Default w80", "Save").OnEvent("Click", SaveNote)
    noteGui.OnEvent("Close", (*) => noteGui.Destroy())
    noteGui.Show()
    
    SaveNote(*) {
        savedNote := noteGui["NoteText"].Value
        if (savedNote != "") {
            FormatTime(timestamp, A_Now, "yyyyMMdd_HHmmss")
            noteFile := A_ScriptDir "\notes\note_" timestamp ".txt"
            DirCreate(A_ScriptDir "\notes")
            FileAppend(savedNote, noteFile, "UTF-8")
            statusBar.Text := "Note saved to: " noteFile
        }
        noteGui.Destroy()
    }
}

ScreenshotToClipboard(*) {
    try {
        A_Clipboard := ""
        Send("#+S")
        statusBar.Text := "Select area to capture (screenshot)"
    } catch as e {
        statusBar.Text := "Error taking screenshot: " e.Message
    }
}

; ========== DEVELOPMENT TOOL IMPLEMENTATIONS ==========
Base64Tool(*) {
    base64Gui := Gui("+AlwaysOnTop", "Base64 Tool")
    base64Gui.Add("Text",, "Text to encode/decode:")
    base64Gui.Add("Edit", "w500 h100 vBase64Text")
    base64Gui.Add("Button", "Default w120", "Encode").OnEvent("Click", (*) => EncodeBase64())
    base64Gui.Add("Button", "xp+130 yp w120", "Decode").OnEvent("Click", (*) => DecodeBase64())
    base64Gui.Add("Text", "w500 h200 vResult", "Result will appear here...")
    base64Gui.Show()
    
    EncodeBase64() {
        try {
            text := base64Gui["Base64Text"].Value
            textBuf := Buffer(StrPut(text, "UTF-8"))
            StrPut(text, textBuf, "UTF-8")
            
            ; Get required buffer size
            if !DllCall("crypt32\CryptBinaryToString", "Ptr", textBuf.Ptr, "UInt", textBuf.Size-1, "UInt", 0x1, "Ptr", 0, "UInt*", &size:=0)
                throw Error("Failed to get buffer size")
            
            ; Encode to Base64
            encoded := Buffer(size * 2)
            if !DllCall("crypt32\CryptBinaryToString", "Ptr", textBuf.Ptr, "UInt", textBuf.Size-1, "UInt", 0x1, "Ptr", encoded.Ptr, "UInt*", &size)
                throw Error("Failed to encode")
            
            result := StrGet(encoded, "UTF-16")
            base64Gui["Result"].Value := "Encoded:`n" result
        } catch as e {
            base64Gui["Result"].Value := "Error: " e.Message
        }
    }
    
    DecodeBase64() {
        try {
            text := base64Gui["Base64Text"].Value
            decoded := Buffer(StrLen(text) * 2, 0)
            if !DllCall("crypt32\CryptStringToBinary", "Str", text, "UInt", 0, "UInt", 0x1, "Ptr", 0, "UInt*", &size:=0, "Ptr", 0, "Ptr", 0)
                throw Error("Invalid Base64 string")
            buf := Buffer(size)
            if !DllCall("crypt32\CryptStringToBinary", "Str", text, "UInt", 0, "UInt", 0x1, "Ptr", buf.Ptr, "UInt*", &size, "Ptr", 0, "Ptr", 0)
                throw Error("Decode failed")
            decoded := StrGet(buf, "UTF-8")
            base64Gui["Result"].Value := "Decoded:`n" decoded
        } catch as e {
            base64Gui["Result"].Value := "Error: " e.Message
        }
    }
}

; ========== FUN FUNCTIONS (26-35) ==========

; 26 - ASCII Art Generator
AsciiArtGenerator(*) {
    try {
        asciiGui := Gui("+AlwaysOnTop", "ASCII Art Generator")
        asciiGui.Add("Text",, "Enter text to convert:")
        asciiGui.Add("Edit", "w400 h30 vAsciiText")
        asciiGui.Add("DropDownList", "w200 vAsciiStyle", ["Big", "Block", "Simple", "Banner"])
        asciiGui["AsciiStyle"].Value := 1
        asciiGui.Add("Button", "Default w100", "Generate").OnEvent("Click", GenerateArt)
        asciiGui.Add("Edit", "w600 h300 ReadOnly vAsciiResult")
        asciiGui.Show()
        
        GenerateArt(*) {
            try {
                text := asciiGui["AsciiText"].Value
                style := asciiGui["AsciiStyle"].Text
                
                if (text = "") {
                    asciiGui["AsciiResult"].Value := "Please enter text to convert"
                    return
                }
                
                ; Simple ASCII art conversion
                art := ""
                for i, char in StrSplit(text) {
                    if (style = "Big") {
                        art .= ConvertToBigAscii(char) "`n"
                    } else if (style = "Block") {
                        art .= "█" char "█ "
                    } else if (style = "Simple") {
                        art .= char " "
                    } else {
                        art .= "*** " char " *** "
                    }
                }
                
                asciiGui["AsciiResult"].Value := art
                A_Clipboard := art
                statusBar.Text := "ASCII art generated and copied"
            } catch as e {
                statusBar.Text := "Error generating ASCII art: " e.Message
            }
        }
        
        ConvertToBigAscii(char) {
            ; Simple big character patterns
            char := StrUpper(char)
            switch char {
                case "A": return " █▀█ `n █▀█ `n ▀ █▀"
                case "B": return " █▀▄ `n █▀▄ `n █▄▀"
                case "C": return " ▄▀█ `n █▄▄ `n ▀▀▀"
                case " ": return "     `n     `n     "
                default: return " ▀█▀ `n  █  `n ▀▀▀"
            }
        }
        
        statusBar.Text := "ASCII art generator opened"
    } catch as e {
        statusBar.Text := "Error opening ASCII generator: " e.Message
    }
}

; 27 - Text Effects
TextEffects(*) {
    try {
        effectGui := Gui("+AlwaysOnTop", "Text Effects")
        effectGui.Add("Text",, "Enter text:")
        effectGui.Add("Edit", "w400 h60 vEffectText")
        effectGui.Add("Text",, "Choose effect:")
        effectGui.Add("DropDownList", "w200 vEffectType", ["UPPERCASE", "lowercase", "Title Case", "Reverse", "L33t Speak", "Upside Down", "Strikethrough", "Bold", "Italic"])
        effectGui["EffectType"].Value := 1
        effectGui.Add("Button", "Default w100", "Apply").OnEvent("Click", ApplyEffect)
        effectGui.Add("Edit", "w400 h150 ReadOnly vEffectResult")
        effectGui.Show()
        
        ApplyEffect(*) {
            try {
                text := effectGui["EffectText"].Value
                effect := effectGui["EffectType"].Text
                result := ""
                
                switch effect {
                    case "UPPERCASE":
                        result := StrUpper(text)
                    case "lowercase":
                        result := StrLower(text)
                    case "Title Case":
                        result := StrTitle(text)
                    case "Reverse":
                        result := ReverseString(text)
                    case "L33t Speak":
                        result := ConvertToLeet(text)
                    case "Upside Down":
                        result := ConvertUpsideDown(text)
                    case "Strikethrough":
                        result := "~~" text "~~"
                    case "Bold":
                        result := "**" text "**"
                    case "Italic":
                        result := "*" text "*"
                }
                
                effectGui["EffectResult"].Value := result
                A_Clipboard := result
                statusBar.Text := "Text effect applied and copied"
            } catch as e {
                statusBar.Text := "Error applying effect: " e.Message
            }
        }
        
        ReverseString(str) {
            reversed := ""
            Loop Parse, str
                reversed := A_LoopField . reversed
            return reversed
        }
        
        ConvertToLeet(str) {
            leet := str
            leet := StrReplace(leet, "a", "4", false)
            leet := StrReplace(leet, "e", "3", false)
            leet := StrReplace(leet, "i", "1", false)
            leet := StrReplace(leet, "o", "0", false)
            leet := StrReplace(leet, "s", "5", false)
            leet := StrReplace(leet, "t", "7", false)
            return leet
        }
        
        ConvertUpsideDown(str) {
            ; Simple upside down character mapping
            upsideMap := Map("a", "ɐ", "b", "q", "c", "ɔ", "d", "p", "e", "ǝ", 
                           "f", "ɟ", "g", "ƃ", "h", "ɥ", "i", "ᴉ", "j", "ɾ",
                           "k", "ʞ", "l", "l", "m", "ɯ", "n", "u", "o", "o",
                           "p", "d", "q", "b", "r", "ɹ", "s", "s", "t", "ʇ",
                           "u", "n", "v", "ʌ", "w", "ʍ", "x", "x", "y", "ʎ", "z", "z")
            
            result := ""
            Loop Parse, str {
                char := StrLower(A_LoopField)
                result .= upsideMap.Has(char) ? upsideMap[char] : A_LoopField
            }
            return ReverseString(result)
        }
        
        statusBar.Text := "Text effects tool opened"
    } catch as e {
        statusBar.Text := "Error opening text effects: " e.Message
    }
}

; 28 - Simple Meme Generator
SimpleMemeGenerator(*) {
    try {
        memeGui := Gui("+AlwaysOnTop", "Simple Meme Generator")
        memeGui.Add("Text",, "Top text:")
        memeGui.Add("Edit", "w400 h30 vTopText")
        memeGui.Add("Text",, "Bottom text:")
        memeGui.Add("Edit", "w400 h30 vBottomText")
        memeGui.Add("Text",, "Meme template:")
        memeGui.Add("DropDownList", "w200 vMemeTemplate", ["Distracted Boyfriend", "Drake Pointing", "Woman Yelling at Cat", "This is Fine", "Change My Mind", "Expanding Brain"])
        memeGui["MemeTemplate"].Value := 1
        memeGui.Add("Button", "Default w100", "Generate").OnEvent("Click", GenerateMeme)
        memeGui.Add("Edit", "w500 h200 ReadOnly vMemeResult")
        memeGui.Show()
        
        GenerateMeme(*) {
            try {
                topText := memeGui["TopText"].Value
                bottomText := memeGui["BottomText"].Value
                template := memeGui["MemeTemplate"].Text
                
                ; Simple text-based meme output
                meme := ""
                meme .= "╔═══════════════════════════════════════╗`n"
                meme .= "║  " . PadString(topText, 33) . "  ║`n"
                meme .= "║                                       ║`n"
                meme .= "║       [" . template . "]       ║`n"
                meme .= "║                                       ║`n"
                meme .= "║  " . PadString(bottomText, 33) . "  ║`n"
                meme .= "╚═══════════════════════════════════════╝"
                
                memeGui["MemeResult"].Value := meme
                A_Clipboard := meme
                statusBar.Text := "Meme generated and copied!"
            } catch as e {
                statusBar.Text := "Error generating meme: " e.Message
            }
        }
        
        PadString(str, length) {
            if (StrLen(str) >= length)
                return SubStr(str, 1, length)
            padding := (length - StrLen(str)) // 2
            return Format("{:" . padding . "}" . str . "{:" . (length - StrLen(str) - padding) . "}", "", "")
        }
        
        statusBar.Text := "Meme generator opened"
    } catch as e {
        statusBar.Text := "Error opening meme generator: " e.Message
    }
}

; 29 - Fortune Cookie
FortuneCookie(*) {
    try {
        fortunes := [
            "The best time to plant a tree was 20 years ago. The second best time is now.",
            "Your future is created by what you do today, not tomorrow.",
            "A ship in harbor is safe, but that is not what ships are built for.",
            "Don't wait for opportunity. Create it.",
            "The only impossible journey is the one you never begin.",
            "Success is not final, failure is not fatal: it is the courage to continue that counts.",
            "The way to get started is to quit talking and begin doing.",
            "Innovation distinguishes between a leader and a follower.",
            "Life is what happens to you while you're busy making other plans.",
            "The future belongs to those who believe in the beauty of their dreams.",
            "It is during our darkest moments that we must focus to see the light.",
            "Not everything that is faced can be changed, but nothing can be changed until it is faced.",
            "A person who never made a mistake never tried anything new.",
            "Twenty years from now you will be more disappointed by the things you didn't do than by the ones you did do.",
            "The only way to do great work is to love what you do."
        ]
        
        fortuneGui := Gui("+AlwaysOnTop", "Fortune Cookie")
        fortuneGui.SetFont("s12")
        
        Random(&rand, 1, fortunes.Length)
        selectedFortune := fortunes[rand]
        
        fortuneGui.Add("Text", "w400 h20 Center", "🥠 Your Fortune Cookie 🥠")
        fortuneGui.Add("Text", "w400 h2 0x10")  ; Separator line
        fortuneGui.Add("Text", "w400 h120 Wrap Center vFortuneText", selectedFortune)
        fortuneGui.Add("Text", "w400 h2 0x10")  ; Separator line
        fortuneGui.Add("Button", "Default w100", "New Fortune").OnEvent("Click", NewFortune)
        fortuneGui.Add("Button", "xp+110 yp w100", "Copy Fortune").OnEvent("Click", CopyFortune)
        fortuneGui.Add("Button", "xp+110 yp w100", "Close").OnEvent("Click", (*) => fortuneGui.Destroy())
        
        fortuneGui.Show()
        
        NewFortune(*) {
            Random(&rand, 1, fortunes.Length)
            newFortune := fortunes[rand]
            fortuneGui["FortuneText"].Value := newFortune
            selectedFortune := newFortune
            statusBar.Text := "New fortune revealed!"
        }
        
        CopyFortune(*) {
            A_Clipboard := selectedFortune
            statusBar.Text := "Fortune copied to clipboard"
        }
        
        statusBar.Text := "Fortune cookie opened - enjoy your wisdom!"
    } catch as e {
        statusBar.Text := "Error opening fortune cookie: " e.Message
    }
}

; Games
PlaySnake(*) {
    ; Simple Snake game implementation
    snakeGui := Gui("+AlwaysOnTop -Caption", "Snake Game")
    snakeGui.BackColor := "Black"
    snakeGui.SetFont("s16 cLime", "Consolas")
    snakeGui.Add("Text", "w400 h400 vGameArea", "")
    snakeGui.Show("w420 h420")
    
    ; Game state
    snake := [[10, 10], [10, 9], [10, 8]]
    direction := "right"
    Random(&foodX, 1, 38)
    Random(&foodY, 1, 38)
    food := [foodX, foodY]
    score := 0
    
    ; Game loop
    SetTimer UpdateGame, 100
    
    ; Controls
    snakeGui.OnEvent("Escape", (*) => snakeGui.Destroy())
    snakeGui.OnEvent("KeyDown", HandleKeyPress)
    
    HandleKeyPress(guiObj, vk, *) {
        if (vk = 37) && (direction != "right")  ; Left
            direction := "left"
        else if (vk = 38) && (direction != "down")  ; Up
            direction := "up"
        else if (vk = 39) && (direction != "left")  ; Right
            direction := "right"
        else if (vk = 40) && (direction != "up")  ; Down
            direction := "down"
    }
    
    UpdateGame() {
        ; Move snake
        head := snake[1].Clone()
        if (direction = "right") {
            head[1] += 1
        } else if (direction = "left") {
            head[1] -= 1
        } else if (direction = "up") {
            head[2] -= 1
        } else if (direction = "down") {
            head[2] += 1
        }
        
        ; Check collision with walls
        if (head[1] < 1 || head[1] > 40 || head[2] < 1 || head[2] > 40) {
            MsgBox("Game Over! Score: " score)
            SetTimer , 0
            snakeGui.Destroy()
            return
        }
        
        ; Check collision with self
        for i, segment in snake {
            if (segment[1] = head[1] && segment[2] = head[2]) {
                MsgBox("Game Over! Score: " score)
                SetTimer , 0
                snakeGui.Destroy()
                return
            }
        }
        
        ; Check if food is eaten
        if (head[1] = food[1] && head[2] = food[2]) {
            score += 10
            Random(&foodX, 1, 38)
            Random(&foodY, 1, 38)
            food := [foodX, foodY]
        } else {
            snake.Pop()
        }
        
        snake.InsertAt(1, head)
        
        ; Draw game
        gameText := ""
        loop 40 {
            y := A_Index
            loop 40 {
                x := A_Index
                cell := "  "
                
                ; Draw snake
                for i, segment in snake {
                    if (segment[1] = x && segment[2] = y) {
                        cell := i = 1 ? "()" : "[]"
                        break
                    }
                }
                
                ; Draw food
                if (food[1] = x && food[2] = y) {
                    cell := "**"
                }
                
                gameText .= cell
            }
            gameText .= "`n"
        }
        
        snakeGui["GameArea"].Value := gameText "`nScore: " score
    }
}

; ========== FUN FUNCTIONS CONTINUED ==========

TellDadJoke(*) {
    try {
        jokes := [
            "Why don't scientists trust atoms? Because they make up everything!",
            "I told my wife she was drawing her eyebrows too high. She looked surprised.",
            "Why don't eggs tell jokes? They'd crack each other up!",
            "What do you call a fake noodle? An impasta!",
            "Why did the scarecrow win an award? He was outstanding in his field!",
            "I'm reading a book about anti-gravity. It's impossible to put down!",
            "Why don't skeletons fight each other? They don't have the guts!",
            "What do you call a bear with no teeth? A gummy bear!",
            "Why did the math book look so sad? Because it had too many problems!",
            "What's the best thing about Switzerland? I don't know, but the flag is a big plus!",
            "Why don't programmers like nature? It has too many bugs!",
            "How do you organize a space party? You planet!",
            "Why did the coffee file a police report? It got mugged!",
            "What do you call a sleeping bull? A bulldozer!",
            "Why don't scientists trust stairs? Because they're always up to something!"
        ]
        
        Random(&rand, 1, jokes.Length)
        selectedJoke := jokes[rand]
        
        jokeGui := Gui("+AlwaysOnTop", "Dad Joke")
        jokeGui.SetFont("s11")
        jokeGui.Add("Text", "w500 h20 Center", "😄 Dad Joke Time! 😄")
        jokeGui.Add("Text", "w500 h2 0x10")
        jokeGui.Add("Text", "w500 h150 Wrap Center vJokeText", selectedJoke)
        jokeGui.Add("Text", "w500 h2 0x10")
        jokeGui.Add("Button", "Default w120", "New Joke").OnEvent("Click", NewJoke)
        jokeGui.Add("Button", "xp+130 yp w120", "Copy Joke").OnEvent("Click", CopyJoke)
        jokeGui.Add("Button", "xp+130 yp w120", "Close").OnEvent("Click", (*) => jokeGui.Destroy())
        jokeGui.Show()
        
        NewJoke(*) {
            Random(&rand, 1, jokes.Length)
            newJoke := jokes[rand]
            jokeGui["JokeText"].Value := newJoke
            selectedJoke := newJoke
            statusBar.Text := "New joke loaded!"
        }
        
        CopyJoke(*) {
            A_Clipboard := selectedJoke
            statusBar.Text := "Joke copied to clipboard"
        }
        
        statusBar.Text := "Dad joke displayed - enjoy the laughs!"
    } catch as e {
        statusBar.Text := "Error showing dad joke: " e.Message
    }
}

TextToEmoji(*) {
    try {
        emojiGui := Gui("+AlwaysOnTop", "Text to Emoji")
        emojiGui.Add("Text",, "Enter text to convert:")
        emojiGui.Add("Edit", "w400 h60 vEmojiText")
        emojiGui.Add("Button", "Default w100", "Convert").OnEvent("Click", ConvertToEmoji)
        emojiGui.Add("Edit", "w400 h150 ReadOnly vEmojiResult")
        emojiGui.Show()
        
        ConvertToEmoji(*) {
            try {
                text := emojiGui["EmojiText"].Value
                text := StrLower(text)
                
                ; Simple emoji mapping
                emojiMap := Map(
                    "happy", "😊", "sad", "😢", "love", "❤️", "heart", "❤️",
                    "fire", "🔥", "star", "⭐", "thumbs up", "👍", "thumbs down", "👎",
                    "ok", "👌", "clap", "👏", "party", "🎉", "cake", "🎂",
                    "coffee", "☕", "pizza", "🍕", "burger", "🍔", "beer", "🍺",
                    "car", "🚗", "plane", "✈️", "train", "🚂", "bike", "🚲",
                    "sun", "☀️", "moon", "🌙", "rain", "🌧️", "snow", "❄️",
                    "cat", "🐱", "dog", "🐶", "bird", "🐦", "fish", "🐟",
                    "yes", "✅", "no", "❌", "check", "✓", "x", "✗",
                    "money", "💰", "gift", "🎁", "balloon", "🎈", "trophy", "🏆"
                )
                
                result := text
                for word, emoji in emojiMap {
                    result := StrReplace(result, word, emoji, false)
                }
                
                ; Also convert common words
                result := StrReplace(result, " :)", " 😊", false)
                result := StrReplace(result, " :(", " 😢", false)
                result := StrReplace(result, " <3", " ❤️", false)
                
                emojiGui["EmojiResult"].Value := result
                A_Clipboard := result
                statusBar.Text := "Text converted to emoji and copied"
            } catch as e {
                statusBar.Text := "Error converting to emoji: " e.Message
            }
        }
        
        statusBar.Text := "Text to emoji converter opened"
    } catch as e {
        statusBar.Text := "Error opening emoji converter: " e.Message
    }
}

GeneratePassword(*) {
    try {
        passGui := Gui("+AlwaysOnTop", "Password Generator")
        passGui.Add("Text",, "Password Length:")
        passGui.Add("Edit", "w100 h30 vPassLength", "16")
        passGui.Add("Text", "y+10", "Options:")
        passGui.Add("Checkbox", "vUseUpper Checked", "Uppercase (A-Z)")
        passGui.Add("Checkbox", "vUseLower Checked", "Lowercase (a-z)")
        passGui.Add("Checkbox", "vUseNumbers Checked", "Numbers (0-9)")
        passGui.Add("Checkbox", "vUseSpecial", "Special (!@#$%^&*)")
        passGui.Add("Button", "Default w120", "Generate").OnEvent("Click", GeneratePass)
        passGui.Add("Edit", "w400 h60 ReadOnly vPassResult")
        passGui.Add("Button", "xp y+10 w120", "Copy").OnEvent("Click", CopyPass)
        passGui.Add("Button", "xp+130 yp w120", "New Password").OnEvent("Click", GeneratePass)
        passGui.Add("Button", "xp+130 yp w120", "Close").OnEvent("Click", (*) => passGui.Destroy())
        passGui.Show()
        
        GeneratePass(*) {
            try {
                length := Integer(passGui["PassLength"].Value)
                if (length < 4 || length > 128) {
                    MsgBox("Password length must be between 4 and 128", "Error", "Icon!")
                    return
                }
                
                charset := ""
                if (passGui["UseUpper"].Value)
                    charset .= "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
                if (passGui["UseLower"].Value)
                    charset .= "abcdefghijklmnopqrstuvwxyz"
                if (passGui["UseNumbers"].Value)
                    charset .= "0123456789"
                if (passGui["UseSpecial"].Value)
                    charset .= "!@#$%^&*()_+-=[]{}|;:,.<>?"
                
                if (charset = "") {
                    MsgBox("Please select at least one character type", "Error", "Icon!")
                    return
                }
                
                password := ""
                Loop length {
                    Random(&rand, 1, StrLen(charset))
                    password .= SubStr(charset, rand, 1)
                }
                
                passGui["PassResult"].Value := password
                A_Clipboard := password
                statusBar.Text := "Password generated and copied"
            } catch as e {
                statusBar.Text := "Error generating password: " e.Message
            }
        }
        
        CopyPass(*) {
            password := passGui["PassResult"].Value
            if (password != "") {
                A_Clipboard := password
                statusBar.Text := "Password copied to clipboard"
            }
        }
        
        ; Generate initial password
        GeneratePass()
        
        statusBar.Text := "Password generator opened"
    } catch as e {
        statusBar.Text := "Error opening password generator: " e.Message
    }
}

CountdownTimer(*) {
    try {
        timerGui := Gui("+AlwaysOnTop", "Countdown Timer")
        timerGui.SetFont("s12 Bold")
        timerGui.Add("Text", "w300 Center", "Countdown Timer")
        timerGui.Add("Text", "w300 h2 0x10")
        timerGui.Add("Text", "w300 h80 Center vTimerDisplay", "00:00:00")
        timerGui.Add("Text", "w300 h2 0x10")
        timerGui.Add("Text",, "Minutes:")
        timerGui.Add("Edit", "w100 h30 vMinutes", "5")
        timerGui.Add("Text", "y+10", "Seconds:")
        timerGui.Add("Edit", "w100 h30 vSeconds", "0")
        timerGui.Add("Button", "Default w80", "Start").OnEvent("Click", StartTimer)
        timerGui.Add("Button", "xp+90 yp w80", "Stop").OnEvent("Click", StopTimer)
        timerGui.Add("Button", "xp+90 yp w80", "Reset").OnEvent("Click", ResetTimer)
        timerGui.Add("Button", "xm y+10 w80", "Close").OnEvent("Click", (*) => timerGui.Destroy())
        timerGui.Show()
        
        static remainingSeconds := 0
        static timerActive := false
        
        StartTimer(*) {
            if (timerActive)
                return
            
            mins := Integer(timerGui["Minutes"].Value)
            secs := Integer(timerGui["Seconds"].Value)
            remainingSeconds := (mins * 60) + secs
            
            if (remainingSeconds <= 0) {
                MsgBox("Please enter a valid time", "Error", "Icon!")
                return
            }
            
            timerActive := true
            UpdateDisplay()
            SetTimer(CountdownTick, 1000)
            statusBar.Text := "Timer started"
        }
        
        StopTimer(*) {
            timerActive := false
            SetTimer(CountdownTick, 0)
            statusBar.Text := "Timer stopped"
        }
        
        ResetTimer(*) {
            timerActive := false
            SetTimer(CountdownTick, 0)
            remainingSeconds := 0
            UpdateDisplay()
            statusBar.Text := "Timer reset"
        }
        
        CountdownTick(*) {
            if (!timerActive)
                return
            
            remainingSeconds--
            UpdateDisplay()
            
            if (remainingSeconds <= 0) {
                timerActive := false
                SetTimer(CountdownTick, 0)
                SoundBeep(1000, 500)
                MsgBox("Time's up!⏰", "Countdown Complete", "OK Icon!")
                statusBar.Text := "Countdown finished"
            }
        }
        
        UpdateDisplay() {
            hours := remainingSeconds // 3600
            mins := (remainingSeconds // 60) - (hours * 60)
            secs := Mod(remainingSeconds, 60)
            display := Format("{:02d}:{:02d}:{:02d}", hours, mins, secs)
            timerGui["TimerDisplay"].Value := display
        }
        
        statusBar.Text := "Countdown timer opened"
    } catch as e {
        statusBar.Text := "Error opening countdown timer: " e.Message
    }
}

SetAlarm(*) {
    try {
        alarmGui := Gui("+AlwaysOnTop", "Alarm Clock")
        alarmGui.Add("Text",, "Set Alarm Time:")
        alarmGui.Add("Text",, "Hour (0-23):")
        alarmGui.Add("Edit", "w100 h30 vAlarmHour", "12")
        alarmGui.Add("Text", "y+10", "Minute (0-59):")
        alarmGui.Add("Edit", "w100 h30 vAlarmMinute", "0")
        alarmGui.Add("Text", "y+10", "Message:")
        alarmGui.Add("Edit", "w300 h40 vAlarmMessage", "Wake up!")
        alarmGui.Add("Checkbox", "vAlarmEnabled", "Alarm Enabled")
        alarmGui.Add("Button", "Default w100", "Set Alarm").OnEvent("Click", SetAlarmTime)
        alarmGui.Add("Button", "xp+110 yp w100", "Clear Alarm").OnEvent("Click", ClearAlarm)
        alarmGui.Add("Text", "xm y+10 w300 vAlarmStatus", "No alarm set")
        alarmGui.Add("Button", "xm y+10 w100", "Close").OnEvent("Click", (*) => alarmGui.Destroy())
        alarmGui.Show()
        
        static alarmHour := -1
        static alarmMinute := -1
        static alarmMsg := ""
        static alarmSet := false
        
        SetAlarmTime(*) {
            try {
                hour := Integer(alarmGui["AlarmHour"].Value)
                minute := Integer(alarmGui["AlarmMinute"].Value)
                
                if (hour < 0 || hour > 23 || minute < 0 || minute > 59) {
                    MsgBox("Please enter valid time (Hour: 0-23, Minute: 0-59)", "Error", "Icon!")
                    return
                }
                
                alarmHour := hour
                alarmMinute := minute
                alarmMsg := alarmGui["AlarmMessage"].Value
                alarmSet := alarmGui["AlarmEnabled"].Value
                
                if (alarmSet) {
                    alarmGui["AlarmStatus"].Value := Format("Alarm set for {:02d}:{:02d} - {}", hour, minute, alarmMsg)
                    SetTimer(CheckAlarm, 1000)
                    statusBar.Text := Format("Alarm set for {:02d}:{:02d}", hour, minute)
                } else {
                    alarmGui["AlarmStatus"].Value := "Alarm disabled"
                    SetTimer(CheckAlarm, 0)
                    statusBar.Text := "Alarm disabled"
                }
            } catch as e {
                statusBar.Text := "Error setting alarm: " e.Message
            }
        }
        
        ClearAlarm(*) {
            alarmHour := -1
            alarmMinute := -1
            alarmSet := false
            SetTimer(CheckAlarm, 0)
            alarmGui["AlarmStatus"].Value := "No alarm set"
            statusBar.Text := "Alarm cleared"
        }
        
        CheckAlarm(*) {
            if (!alarmSet || alarmHour < 0)
                return
            
            FormatTime(currentTime, A_Now, "HH:mm")
            currentHour := Integer(SubStr(currentTime, 1, 2))
            currentMinute := Integer(SubStr(currentTime, 4, 2))
            
            if (currentHour = alarmHour && currentMinute = alarmMinute) {
                SetTimer(CheckAlarm, 0)
                SoundBeep(1000, 1000)
                MsgBox(alarmMsg, "⏰ ALARM ⏰", "OK Icon!")
                alarmSet := false
                alarmGui["AlarmStatus"].Value := "Alarm triggered"
                statusBar.Text := "Alarm triggered"
            }
        }
        
        statusBar.Text := "Alarm clock opened"
    } catch as e {
        statusBar.Text := "Error opening alarm clock: " e.Message
    }
}

TextToBinary(*) {
    try {
        binaryGui := Gui("+AlwaysOnTop", "Text to Binary Converter")
        binaryGui.Add("Text",, "Enter text to convert:")
        binaryGui.Add("Edit", "w400 h100 vBinaryText")
        binaryGui.Add("Button", "Default w120", "To Binary").OnEvent("Click", ConvertToBinary)
        binaryGui.Add("Button", "xp+130 yp w120", "From Binary").OnEvent("Click", ConvertFromBinary)
        binaryGui.Add("Edit", "w400 h200 ReadOnly vBinaryResult")
        binaryGui.Show()
        
        ConvertToBinary(*) {
            try {
                text := binaryGui["BinaryText"].Value
                binary := ""
                
                Loop Parse, text {
                    charCode := Ord(A_LoopField)
                    binaryStr := ""
                    temp := charCode
                    Loop 8 {
                        binaryStr := Mod(temp, 2) . binaryStr
                        temp := temp // 2
                    }
                    binary .= binaryStr . " "
                }
                
                binaryGui["BinaryResult"].Value := Trim(binary)
                A_Clipboard := Trim(binary)
                statusBar.Text := "Text converted to binary and copied"
            } catch as e {
                statusBar.Text := "Error converting to binary: " e.Message
            }
        }
        
        ConvertFromBinary(*) {
            try {
                binary := binaryGui["BinaryText"].Value
                binary := StrReplace(binary, " ", "")
                
                if (Mod(StrLen(binary), 8) != 0) {
                    MsgBox("Invalid binary format. Must be groups of 8 bits.", "Error", "Icon!")
                    return
                }
                
                text := ""
                pos := 1
                while (pos <= StrLen(binary)) {
                    byte := SubStr(binary, pos, 8)
                    charCode := 0
                    Loop Parse, byte {
                        charCode := (charCode * 2) + Integer(A_LoopField)
                    }
                    text .= Chr(charCode)
                    pos += 8
                }
                
                binaryGui["BinaryResult"].Value := text
                A_Clipboard := text
                statusBar.Text := "Binary converted to text and copied"
            } catch as e {
                statusBar.Text := "Error converting from binary: " e.Message
            }
        }
        
        statusBar.Text := "Text to binary converter opened"
    } catch as e {
        statusBar.Text := "Error opening binary converter: " e.Message
    }
}

; ========== GAME IMPLEMENTATIONS ==========

PlayTicTacToe(*) {
    try {
        tttGui := Gui("+AlwaysOnTop", "Tic-Tac-Toe")
        tttGui.SetFont("s20 Bold")
        
        static board := ["", "", "", "", "", "", "", "", ""]
        static currentPlayer := "X"
        static gameOver := false
        
        ; Create 3x3 grid
        buttons := []
        Loop 9 {
            row := (A_Index - 1) // 3 + 1
            col := Mod(A_Index - 1, 3) + 1
            btn := tttGui.Add("Button", Format("w60 h60 x{} y{} vBtn{}", (col-1)*65+20, (row-1)*65+20, A_Index), "")
            btn.OnEvent("Click", MakeMove)
            buttons.Push(btn)
        }
        
        tttGui.Add("Text", "xm y+10 w200 Center vStatusText", "Player X's turn")
        tttGui.Add("Button", "xp y+10 w80", "Reset").OnEvent("Click", ResetGame)
        tttGui.Add("Button", "xp+90 yp w80", "Close").OnEvent("Click", (*) => tttGui.Destroy())
        tttGui.Show()
        
        MakeMove(btn, *) {
            if (gameOver)
                return
            
            btnNum := Integer(StrReplace(btn.Name, "Btn", ""))
            if (board[btnNum] != "")
                return
            
            board[btnNum] := currentPlayer
            btn.Text := currentPlayer
            
            if (CheckWinner()) {
                tttGui["StatusText"].Value := "Player " . currentPlayer . " wins!"
                gameOver := true
                statusBar.Text := "Tic-tac-toe: " . currentPlayer . " wins!"
            } else if (IsBoardFull()) {
                tttGui["StatusText"].Value := "It's a tie!"
                gameOver := true
                statusBar.Text := "Tic-tac-toe: Tie game"
            } else {
                currentPlayer := (currentPlayer = "X") ? "O" : "X"
                tttGui["StatusText"].Value := "Player " . currentPlayer . "'s turn"
            }
        }
        
        CheckWinner() {
            ; Check rows, columns, diagonals
            lines := [
                [1,2,3], [4,5,6], [7,8,9],  ; rows
                [1,4,7], [2,5,8], [3,6,9],  ; columns
                [1,5,9], [3,5,7]             ; diagonals
            ]
            
            for line in lines {
                if (board[line[1]] != "" && board[line[1]] = board[line[2]] && board[line[2]] = board[line[3]])
                    return true
            }
            return false
        }
        
        IsBoardFull() {
            for cell in board {
                if (cell = "")
                    return false
            }
            return true
        }
        
        ResetGame(*) {
            board := ["", "", "", "", "", "", "", "", ""]
            currentPlayer := "X"
            gameOver := false
            Loop 9 {
                tttGui["Btn" . A_Index].Text := ""
            }
            tttGui["StatusText"].Value := "Player X's turn"
            statusBar.Text := "Tic-tac-toe game reset"
        }
        
        ResetGame()
        statusBar.Text := "Tic-tac-toe game started"
    } catch as e {
        statusBar.Text := "Error starting tic-tac-toe: " e.Message
    }
}

PlayHangman(*) {
    try {
        words := ["COMPUTER", "PROGRAMMING", "AUTOHOTKEY", "DEVELOPMENT", "SOFTWARE", 
                  "ALGORITHM", "FUNCTION", "VARIABLE", "SYNTAX", "KEYBOARD"]
        
        Random(&rand, 1, words.Length)
        word := words[rand]
        guessed := Map()
        wrongGuesses := 0
        maxWrong := 6
        
        hangmanGui := Gui("+AlwaysOnTop", "Hangman")
        hangmanGui.SetFont("s12")
        hangmanGui.Add("Text", "w400 Center", "Hangman Game")
        hangmanGui.Add("Text", "w400 h2 0x10")
        hangmanGui.Add("Text", "w400 h100 Center vWordDisplay", "")
        hangmanGui.Add("Text", "w400 h2 0x10")
        hangmanGui.Add("Text", "w400 vStatusText", "Guess a letter!")
        hangmanGui.Add("Text",, "Enter letter:")
        hangmanGui.Add("Edit", "w50 h30 vLetterInput Limit1")
        hangmanGui.Add("Button", "Default w80", "Guess").OnEvent("Click", MakeGuess)
        hangmanGui.Add("Text", "xm y+10 w400 vWrongText", "Wrong guesses: 0/6")
        hangmanGui.Add("Button", "xm y+10 w80", "New Word").OnEvent("Click", NewWord)
        hangmanGui.Add("Button", "xp+90 yp w80", "Close").OnEvent("Click", (*) => hangmanGui.Destroy())
        hangmanGui.Show()
        
        UpdateDisplay() {
            display := ""
            for i, char in StrSplit(word) {
                if (guessed.Has(char))
                    display .= char . " "
                else
                    display .= "_ "
            }
            hangmanGui["WordDisplay"].Value := display
            
            wrongCount := 0
            for char in guessed {
                if (!InStr(word, char))
                    wrongCount++
            }
            hangmanGui["WrongText"].Value := Format("Wrong guesses: {}/{}", wrongCount, maxWrong)
            
            if (wrongCount >= maxWrong) {
                hangmanGui["StatusText"].Value := "Game Over! The word was: " . word
                hangmanGui["LetterInput"].Enabled := false
            } else if (!InStr(display, "_")) {
                hangmanGui["StatusText"].Value := "Congratulations! You won!"
                hangmanGui["LetterInput"].Enabled := false
            }
        }
        
        MakeGuess(*) {
            letter := StrUpper(hangmanGui["LetterInput"].Value)
            if (StrLen(letter) != 1 || !RegExMatch(letter, "[A-Z]"))
                return
            
            if (guessed.Has(letter))
                return
            
            guessed[letter] := true
            hangmanGui["LetterInput"].Value := ""
            UpdateDisplay()
        }
        
        NewWord(*) {
            Random(&rand, 1, words.Length)
            word := words[rand]
            guessed := Map()
            hangmanGui["LetterInput"].Enabled := true
            hangmanGui["StatusText"].Value := "Guess a letter!"
            UpdateDisplay()
            statusBar.Text := "New word selected"
        }
        
        UpdateDisplay()
        statusBar.Text := "Hangman game started"
    } catch as e {
        statusBar.Text := "Error starting hangman: " e.Message
    }
}

PlayMemoryGame(*) {
    try {
        memoryGui := Gui("+AlwaysOnTop", "Memory Game")
        memoryGui.SetFont("s16 Bold")
        
        symbols := ["A", "B", "C", "D", "E", "F", "G", "H"]
        cards := []
        cards.Push(symbols*)
        cards.Push(symbols*)
        
        ; Shuffle
        Loop cards.Length {
            Random(&rand1, 1, cards.Length)
            Random(&rand2, 1, cards.Length)
            temp := cards[rand1]
            cards[rand1] := cards[rand2]
            cards[rand2] := temp
        }
        
        static revealed := []
        static firstCard := -1
        static matches := 0
        static moves := 0
        
        Loop 16 {
            revealed.Push(false)
        }
        
        ; Create card buttons
        Loop 4 {
            row := A_Index
            Loop 4 {
                col := A_Index
                idx := (row - 1) * 4 + col
                btn := memoryGui.Add("Button", Format("w60 h60 x{} y{} vCard{}", (col-1)*70+20, (row-1)*70+20, idx), "?")
                btn.OnEvent("Click", RevealCard)
            }
        }
        
        memoryGui.Add("Text", "xm y+10 w300 Center vStatusText", "Moves: 0")
        memoryGui.Add("Button", "xm y+10 w80", "Reset").OnEvent("Click", ResetMemory)
        memoryGui.Add("Button", "xp+90 yp w80", "Close").OnEvent("Click", (*) => memoryGui.Destroy())
        memoryGui.Show()
        
        RevealCard(btn, *) {
            idx := Integer(StrReplace(btn.Name, "Card", ""))
            if (revealed[idx] || firstCard = idx)
                return
            
            btn.Text := cards[idx]
            revealed[idx] := true
            
            if (firstCard = -1) {
                firstCard := idx
            } else {
                moves++
                memoryGui["StatusText"].Value := "Moves: " . moves
                
                if (cards[firstCard] = cards[idx]) {
                    matches++
                    firstCard := -1
                    if (matches = 8) {
                        MsgBox("Congratulations! You won in " . moves . " moves!", "Memory Game", "OK Icon!")
                        statusBar.Text := "Memory game completed"
                    }
                } else {
                    SetTimer(() => HideCards(idx), -1000)
                }
            }
        }
        
        HideCards(secondIdx) {
            memoryGui["Card" . firstCard].Text := "?"
            memoryGui["Card" . secondIdx].Text := "?"
            revealed[firstCard] := false
            revealed[secondIdx] := false
            firstCard := -1
        }
        
        ResetMemory(*) {
            ; Reshuffle
            Loop cards.Length {
                Random(&rand1, 1, cards.Length)
                Random(&rand2, 1, cards.Length)
                temp := cards[rand1]
                cards[rand1] := cards[rand2]
                cards[rand2] := temp
            }
            
            revealed := []
            Loop 16 {
                revealed.Push(false)
            }
            firstCard := -1
            matches := 0
            moves := 0
            
            Loop 16 {
                memoryGui["Card" . A_Index].Text := "?"
            }
            memoryGui["StatusText"].Value := "Moves: 0"
            statusBar.Text := "Memory game reset"
        }
        
        statusBar.Text := "Memory game started"
    } catch as e {
        statusBar.Text := "Error starting memory game: " e.Message
    }
}

PlayNumberGuesser(*) {
    try {
        Random(&secretNumber, 1, 100)
        guesses := 0
        maxGuesses := 7
        
        guessGui := Gui("+AlwaysOnTop", "Number Guesser")
        guessGui.SetFont("s12")
        guessGui.Add("Text", "w300 Center", "Number Guessing Game")
        guessGui.Add("Text", "w300 h2 0x10")
        guessGui.Add("Text", "w300 Center", "I'm thinking of a number between 1 and 100")
        guessGui.Add("Text", "w300 Center vHintText", "Can you guess it?")
        guessGui.Add("Text", "w300 h2 0x10")
        guessGui.Add("Text",, "Your guess:")
        guessGui.Add("Edit", "w100 h30 vGuessInput")
        guessGui.Add("Button", "Default w80", "Guess").OnEvent("Click", MakeGuess)
        guessGui.Add("Text", "xm y+10 w300 vResultText", "")
        guessGui.Add("Text", "xm y+10 w300 vGuessesText", "Guesses: 0/" . maxGuesses)
        guessGui.Add("Button", "xm y+10 w80", "New Game").OnEvent("Click", NewGame)
        guessGui.Add("Button", "xp+90 yp w80", "Close").OnEvent("Click", (*) => guessGui.Destroy())
        guessGui.Show()
        
        MakeGuess(*) {
            try {
                guess := Integer(guessGui["GuessInput"].Value)
                if (guess < 1 || guess > 100) {
                    guessGui["ResultText"].Value := "Please enter a number between 1 and 100"
                    return
                }
                
                guesses++
                guessGui["GuessesText"].Value := Format("Guesses: {}/{}", guesses, maxGuesses)
                
                if (guess = secretNumber) {
                    guessGui["ResultText"].Value := Format("Congratulations! You guessed it in {} tries!", guesses)
                    guessGui["HintText"].Value := "You won!"
                    guessGui["GuessInput"].Enabled := false
                    statusBar.Text := "Number guessed correctly"
                } else if (guesses >= maxGuesses) {
                    guessGui["ResultText"].Value := Format("Game Over! The number was: {}", secretNumber)
                    guessGui["HintText"].Value := "Better luck next time!"
                    guessGui["GuessInput"].Enabled := false
                    statusBar.Text := "Number guesser game over"
                } else if (guess < secretNumber) {
                    guessGui["ResultText"].Value := "Too low! Try again."
                } else {
                    guessGui["ResultText"].Value := "Too high! Try again."
                }
                
                guessGui["GuessInput"].Value := ""
            } catch as e {
                guessGui["ResultText"].Value := "Please enter a valid number"
            }
        }
        
        NewGame(*) {
            Random(&secretNumber, 1, 100)
            guesses := 0
            guessGui["GuessInput"].Enabled := true
            guessGui["GuessInput"].Value := ""
            guessGui["ResultText"].Value := ""
            guessGui["HintText"].Value := "Can you guess it?"
            guessGui["GuessesText"].Value := "Guesses: 0/" . maxGuesses
            statusBar.Text := "New number guesser game started"
        }
        
        statusBar.Text := "Number guesser game started"
    } catch as e {
        statusBar.Text := "Error starting number guesser: " e.Message
    }
}

TypingTest(*) {
    try {
        texts := [
            "The quick brown fox jumps over the lazy dog.",
            "Programming is the art of telling a computer what to do.",
            "Practice makes perfect when learning to type quickly.",
            "AutoHotkey is a powerful automation scripting language.",
            "Type accurately and quickly to improve your skills."
        ]
        
        Random(&rand, 1, texts.Length)
        testText := texts[rand]
        startTime := 0
        testActive := false
        
        typingGui := Gui("+AlwaysOnTop", "Typing Test")
        typingGui.SetFont("s11")
        typingGui.Add("Text", "w500 Center", "Typing Speed Test")
        typingGui.Add("Text", "w500 h2 0x10")
        typingGui.Add("Text", "w500 Wrap vTestText", testText)
        typingGui.Add("Text", "w500 h2 0x10")
        typingGui.Add("Text",, "Type the text above:")
        typingGui.Add("Edit", "w500 h80 vTypedText")
        typingGui.Add("Text", "xm y+10 w500 vStatsText", "Time: 0s | WPM: 0 | Accuracy: 0%")
        typingGui.Add("Button", "Default w100", "Start").OnEvent("Click", StartTest)
        typingGui.Add("Button", "xp+110 yp w100", "New Text").OnEvent("Click", NewText)
        typingGui.Add("Button", "xp+110 yp w100", "Close").OnEvent("Click", (*) => typingGui.Destroy())
        typingGui.Show()
        
        StartTest(*) {
            testActive := true
            startTime := A_TickCount
            typingGui["TypedText"].Value := ""
            typingGui["TypedText"].Focus()
            SetTimer(UpdateStats, 100)
            statusBar.Text := "Typing test started"
        }
        
        UpdateStats(*) {
            if (!testActive)
                return
            
            elapsed := (A_TickCount - startTime) / 1000
            typed := typingGui["TypedText"].Value
            typedLen := StrLen(typed)
            
            if (typedLen > 0) {
                wpm := Round((typedLen / 5) / (elapsed / 60), 1)
                
                ; Calculate accuracy
                correct := 0
                Loop Min(typedLen, StrLen(testText)) {
                    if (SubStr(typed, A_Index, 1) = SubStr(testText, A_Index, 1))
                        correct++
                }
                accuracy := Round((correct / typedLen) * 100, 1)
                
                typingGui["StatsText"].Value := Format("Time: {:.1f}s | WPM: {} | Accuracy: {}%", elapsed, wpm, accuracy)
                
                ; Check if complete
                if (typed = testText) {
                    testActive := false
                    SetTimer(UpdateStats, 0)
                    elapsed := (A_TickCount - startTime) / 1000
                    wpm := Round((StrLen(testText) / 5) / (elapsed / 60), 1)
                    MsgBox(Format("Congratulations!`nTime: {:.1f}s`nWPM: {}`nAccuracy: {}%", elapsed, wpm, accuracy), "Typing Test Complete", "OK Icon!")
                    statusBar.Text := "Typing test completed"
                }
            } else {
                typingGui["StatsText"].Value := Format("Time: {:.1f}s | WPM: 0 | Accuracy: 0%", elapsed)
            }
        }
        
        NewText(*) {
            Random(&rand, 1, texts.Length)
            testText := texts[rand]
            typingGui["TestText"].Value := testText
            testActive := false
            SetTimer(UpdateStats, 0)
            typingGui["TypedText"].Value := ""
            typingGui["StatsText"].Value := "Time: 0s | WPM: 0 | Accuracy: 0%"
            statusBar.Text := "New text loaded"
        }
        
        statusBar.Text := "Typing test opened"
    } catch as e {
        statusBar.Text := "Error opening typing test: " e.Message
    }
}

PlayMinesweeper(*) {
    try {
        ; Simple 8x8 minesweeper
        gridSize := 8
        mineCount := 10
        
        mines := []
        revealed := []
        flagged := []
        
        Loop gridSize {
            row := []
            revealedRow := []
            flaggedRow := []
            Loop gridSize {
                row.Push(false)
                revealedRow.Push(false)
                flaggedRow.Push(false)
            }
            mines.Push(row)
            revealed.Push(revealedRow)
            flagged.Push(flaggedRow)
        }
        
        ; Place mines randomly
        placed := 0
        while (placed < mineCount) {
            Random(&row, 1, gridSize)
            Random(&col, 1, gridSize)
            if (!mines[row][col]) {
                mines[row][col] := true
                placed++
            }
        }
        
        minesweeperGui := Gui("+AlwaysOnTop", "Minesweeper")
        minesweeperGui.SetFont("s10")
        
        ; Create grid
        buttons := []
        Loop gridSize {
            row := A_Index
            Loop gridSize {
                col := A_Index
                btn := minesweeperGui.Add("Button", Format("w30 h30 x{} y{} vBtn{}_{}", (col-1)*35+20, (row-1)*35+50, row, col), "")
                btn.OnEvent("Click", RevealCell)
                btn.OnEvent("RButton", FlagCell)
                buttons.Push(btn)
            }
        }
        
        minesweeperGui.Add("Text", "xm y+10 w300 Center vStatusText", "Mines: " . mineCount)
        minesweeperGui.Add("Button", "xm y+10 w80", "Reset").OnEvent("Click", ResetMinesweeper)
        minesweeperGui.Add("Button", "xp+90 yp w80", "Close").OnEvent("Click", (*) => minesweeperGui.Destroy())
        minesweeperGui.Show()
        
        CountMines(row, col) {
            count := 0
            Loop 3 {
                r := row + A_Index - 2
                Loop 3 {
                    c := col + A_Index - 2
                    if (r >= 1 && r <= gridSize && c >= 1 && c <= gridSize && mines[r][c])
                        count++
                }
            }
            return count
        }
        
        RevealCell(btn, *) {
            coords := StrSplit(StrReplace(btn.Name, "Btn", ""), "_")
            row := Integer(coords[1])
            col := Integer(coords[2])
            
            if (flagged[row][col] || revealed[row][col])
                return
            
            if (mines[row][col]) {
                ; Game over
                Loop gridSize {
                    r := A_Index
                    Loop gridSize {
                        c := A_Index
                        if (mines[r][c])
                            minesweeperGui["Btn" . r . "_" . c].Text := "💣"
                    }
                }
                minesweeperGui["StatusText"].Value := "Game Over!"
                MsgBox("You hit a mine! Game Over!", "Minesweeper", "OK Icon!")
                statusBar.Text := "Minesweeper game over"
                return
            }
            
            RevealRecursive(row, col)
            CheckWin()
        }
        
        RevealRecursive(row, col) {
            if (row < 1 || row > gridSize || col < 1 || col > gridSize || revealed[row][col])
                return
            
            revealed[row][col] := true
            count := CountMines(row, col)
            
            if (count > 0) {
                minesweeperGui["Btn" . row . "_" . col].Text := count
            } else {
                minesweeperGui["Btn" . row . "_" . col].Text := ""
                ; Reveal adjacent cells
                Loop 3 {
                    r := row + A_Index - 2
                    Loop 3 {
                        c := col + A_Index - 2
                        if (r >= 1 && r <= gridSize && c >= 1 && c <= gridSize)
                            RevealRecursive(r, c)
                    }
                }
            }
        }
        
        FlagCell(btn, *) {
            coords := StrSplit(StrReplace(btn.Name, "Btn", ""), "_")
            row := Integer(coords[1])
            col := Integer(coords[2])
            
            if (revealed[row][col])
                return
            
            flagged[row][col] := !flagged[row][col]
            minesweeperGui["Btn" . row . "_" . col].Text := flagged[row][col] ? "🚩" : ""
        }
        
        CheckWin() {
            revealedCount := 0
            Loop gridSize {
                r := A_Index
                Loop gridSize {
                    c := A_Index
                    if (revealed[r][c] && !mines[r][c])
                        revealedCount++
                }
            }
            
            if (revealedCount = (gridSize * gridSize - mineCount)) {
                MsgBox("Congratulations! You cleared all mines!", "Minesweeper", "OK Icon!")
                minesweeperGui["StatusText"].Value := "You Win!"
                statusBar.Text := "Minesweeper completed"
            }
        }
        
        ResetMinesweeper(*) {
            ; Reset and regenerate mines
            mines := []
            revealed := []
            flagged := []
            
            Loop gridSize {
                row := []
                revealedRow := []
                flaggedRow := []
                Loop gridSize {
                    row.Push(false)
                    revealedRow.Push(false)
                    flaggedRow.Push(false)
                }
                mines.Push(row)
                revealed.Push(revealedRow)
                flagged.Push(flaggedRow)
            }
            
            placed := 0
            while (placed < mineCount) {
                Random(&row, 1, gridSize)
                Random(&col, 1, gridSize)
                if (!mines[row][col]) {
                    mines[row][col] := true
                    placed++
                }
            }
            
            Loop gridSize {
                r := A_Index
                Loop gridSize {
                    c := A_Index
                    minesweeperGui["Btn" . r . "_" . c].Text := ""
                }
            }
            minesweeperGui["StatusText"].Value := "Mines: " . mineCount
            statusBar.Text := "Minesweeper reset"
        }
        
        statusBar.Text := "Minesweeper game started"
    } catch as e {
        statusBar.Text := "Error starting minesweeper: " e.Message
    }
}

PlayBlackjack(*) {
    try {
        blackjackGui := Gui("+AlwaysOnTop", "Blackjack")
        blackjackGui.SetFont("s11")
        
        deck := []
        suits := ["♠", "♥", "♦", "♣"]
        ranks := ["A", "2", "3", "4", "5", "6", "7", "8", "9", "10", "J", "Q", "K"]
        
        for suit in suits {
            for rank in ranks {
                deck.Push(rank . suit)
            }
        }
        
        playerHand := []
        dealerHand := []
        gameOver := false
        
        blackjackGui.Add("Text", "w400 Center", "Blackjack")
        blackjackGui.Add("Text", "w400 h2 0x10")
        blackjackGui.Add("Text", "w400 vDealerText", "Dealer: ")
        blackjackGui.Add("Text", "w400 vPlayerText", "Player: ")
        blackjackGui.Add("Text", "w400 h2 0x10")
        blackjackGui.Add("Text", "w400 vStatusText", "")
        blackjackGui.Add("Button", "Default w80", "Hit").OnEvent("Click", Hit)
        blackjackGui.Add("Button", "xp+90 yp w80", "Stand").OnEvent("Click", Stand)
        blackjackGui.Add("Button", "xm y+10 w80", "New Game").OnEvent("Click", NewBlackjack)
        blackjackGui.Add("Button", "xp+90 yp w80", "Close").OnEvent("Click", (*) => blackjackGui.Destroy())
        blackjackGui.Show()
        
        ShuffleDeck() {
            Loop deck.Length {
                Random(&rand1, 1, deck.Length)
                Random(&rand2, 1, deck.Length)
                temp := deck[rand1]
                deck[rand1] := deck[rand2]
                deck[rand2] := temp
            }
        }
        
        GetCardValue(card) {
            rank := SubStr(card, 1, -1)
            if (rank = "A")
                return 11
            else if (rank = "J" || rank = "Q" || rank = "K")
                return 10
            else
                return Integer(rank)
        }
        
        GetHandValue(hand) {
            value := 0
            aces := 0
            for card in hand {
                cardValue := GetCardValue(card)
                if (cardValue = 11)
                    aces++
                value += cardValue
            }
            
            ; Adjust for aces
            while (value > 21 && aces > 0) {
                value -= 10
                aces--
            }
            return value
        }
        
        DealCard(hand) {
            Random(&rand, 1, deck.Length)
            card := deck[rand]
            deck.RemoveAt(rand)
            hand.Push(card)
            return card
        }
        
        UpdateDisplay() {
            dealerDisplay := "Dealer: "
            if (gameOver) {
                for card in dealerHand {
                    dealerDisplay .= card . " "
                }
                dealerDisplay .= "(" . GetHandValue(dealerHand) . ")"
            } else {
                dealerDisplay .= dealerHand[1] . " ??"
            }
            blackjackGui["DealerText"].Value := dealerDisplay
            
            playerDisplay := "Player: "
            for card in playerHand {
                playerDisplay .= card . " "
            }
            playerDisplay .= "(" . GetHandValue(playerHand) . ")"
            blackjackGui["PlayerText"].Value := playerDisplay
        }
        
        Hit(*) {
            if (gameOver)
                return
            
            DealCard(playerHand)
            UpdateDisplay()
            
            if (GetHandValue(playerHand) > 21) {
                blackjackGui["StatusText"].Value := "Bust! You lose!"
                gameOver := true
                statusBar.Text := "Blackjack: Player bust"
            }
        }
        
        Stand(*) {
            if (gameOver)
                return
            
            gameOver := true
            
            ; Dealer draws until 17+
            while (GetHandValue(dealerHand) < 17) {
                DealCard(dealerHand)
            }
            
            UpdateDisplay()
            
            playerValue := GetHandValue(playerHand)
            dealerValue := GetHandValue(dealerHand)
            
            if (dealerValue > 21) {
                blackjackGui["StatusText"].Value := "Dealer busts! You win!"
                statusBar.Text := "Blackjack: Player wins"
            } else if (playerValue > dealerValue) {
                blackjackGui["StatusText"].Value := "You win!"
                statusBar.Text := "Blackjack: Player wins"
            } else if (playerValue < dealerValue) {
                blackjackGui["StatusText"].Value := "Dealer wins!"
                statusBar.Text := "Blackjack: Dealer wins"
            } else {
                blackjackGui["StatusText"].Value := "Push! It's a tie!"
                statusBar.Text := "Blackjack: Tie game"
            }
        }
        
        NewBlackjack(*) {
            ; Reset deck
            deck := []
            for suit in suits {
                for rank in ranks {
                    deck.Push(rank . suit)
                }
            }
            ShuffleDeck()
            
            playerHand := []
            dealerHand := []
            gameOver := false
            
            DealCard(playerHand)
            DealCard(dealerHand)
            DealCard(playerHand)
            DealCard(dealerHand)
            
            UpdateDisplay()
            blackjackGui["StatusText"].Value := ""
            statusBar.Text := "New blackjack game started"
        }
        
        NewBlackjack()
        statusBar.Text := "Blackjack game started"
    } catch as e {
        statusBar.Text := "Error starting blackjack: " e.Message
    }
}

PlayPong(*) {
    try {
        pongGui := Gui("+AlwaysOnTop -Caption", "Pong")
        pongGui.BackColor := "Black"
        pongGui.SetFont("s12 cWhite", "Consolas")
        pongGui.Add("Text", "w400 h300 vGameArea", "")
        pongGui.Show("w420 h320")
        
        ; Game state
        ballX := 200
        ballY := 150
        ballSpeedX := 2
        ballSpeedY := 2
        paddle1Y := 120
        paddle2Y := 120
        score1 := 0
        score2 := 0
        
        pongGui.OnEvent("Escape", (*) => pongGui.Destroy())
        pongGui.OnEvent("KeyDown", HandlePongKey)
        
        HandlePongKey(guiObj, vk, *) {
            if (vk = 87) && (paddle1Y > 0)  ; W
                paddle1Y -= 10
            else if (vk = 83) && (paddle1Y < 200)  ; S
                paddle1Y += 10
        }
        
        SetTimer(UpdatePong, 50)
        
        UpdatePong() {
            ; Move ball
            ballX += ballSpeedX
            ballY += ballSpeedY
            
            ; Bounce off top/bottom
            if (ballY <= 0 || ballY >= 280)
                ballSpeedY := -ballSpeedY
            
            ; Paddle collisions
            if (ballX <= 20 && ballY >= paddle1Y && ballY <= paddle1Y + 60)
                ballSpeedX := Abs(ballSpeedX)
            else if (ballX >= 380 && ballY >= paddle2Y && ballY <= paddle2Y + 60)
                ballSpeedX := -Abs(ballSpeedX)
            
            ; Simple AI for paddle 2
            if (ballY < paddle2Y + 30)
                paddle2Y -= 1
            else if (ballY > paddle2Y + 30)
                paddle2Y += 1
            
            ; Score
            if (ballX < 0) {
                score2++
                ballX := 200
                ballY := 150
                ballSpeedX := 2
                ballSpeedY := 2
            } else if (ballX > 400) {
                score1++
                ballX := 200
                ballY := 150
                ballSpeedX := -2
                ballSpeedY := 2
            }
            
            ; Draw game
            gameText := ""
            Loop 30 {
                y := A_Index * 10
                line := ""
                Loop 40 {
                    x := A_Index * 10
                    char := " "
                    
                    ; Draw paddles
                    if (x = 10 && y >= paddle1Y && y <= paddle1Y + 60)
                        char := "|"
                    else if (x = 390 && y >= paddle2Y && y <= paddle2Y + 60)
                        char := "|"
                    
                    ; Draw ball
                    if (Abs(x - ballX) < 5 && Abs(y - ballY) < 5)
                        char := "O"
                    
                    line .= char
                }
                gameText .= line . "`n"
            }
            
            pongGui["GameArea"].Value := gameText . "`nScore: " . score1 . " - " . score2 . "`nW/S to move left paddle"
            
            if (score1 >= 5 || score2 >= 5) {
                winner := score1 >= 5 ? "Player 1" : "Player 2"
                MsgBox(winner . " wins!", "Pong", "OK")
                SetTimer(UpdatePong, 0)
                pongGui.Destroy()
                statusBar.Text := "Pong game finished"
            }
        }
        
        statusBar.Text := "Pong game started - Use W/S keys"
    } catch as e {
        statusBar.Text := "Error starting pong: " e.Message
    }
}

PlaySpaceInvaders(*) {
    try {
        spaceGui := Gui("+AlwaysOnTop -Caption", "Space Invaders")
        spaceGui.BackColor := "Black"
        spaceGui.SetFont("s10 cLime", "Consolas")
        spaceGui.Add("Text", "w500 h400 vGameArea", "")
        spaceGui.Show("w520 h420")
        
        ; Game state
        playerX := 250
        invaders := []
        bullets := []
        invaderBullets := []
        score := 0
        lives := 3
        
        ; Create invaders
        Loop 5 {
            row := A_Index
            Loop 10 {
                col := A_Index
                invaders.Push([col * 40 + 20, row * 30 + 20])
            }
        }
        
        spaceGui.OnEvent("Escape", (*) => spaceGui.Destroy())
        spaceGui.OnEvent("KeyDown", HandleSpaceKey)
        
        HandleSpaceKey(guiObj, vk, *) {
            if (vk = 37) && (playerX > 0)  ; Left
                playerX -= 10
            else if (vk = 39) && (playerX < 450)  ; Right
                playerX += 10
            else if (vk = 32)  ; Space
                bullets.Push([playerX, 380])
        }
        
        SetTimer(UpdateSpaceInvaders, 100)
        
        UpdateSpaceInvaders() {
            ; Move bullets
            newBullets := []
            for bullet in bullets {
                bullet[2] -= 5
                if (bullet[2] > 0)
                    newBullets.Push(bullet)
            }
            bullets := newBullets
            
            ; Move invader bullets
            newInvaderBullets := []
            for bullet in invaderBullets {
                bullet[2] += 3
                if (bullet[2] < 400)
                    newInvaderBullets.Push(bullet)
                else if (bullet[2] >= 380 && Abs(bullet[1] - playerX) < 20) {
                    lives--
                    if (lives <= 0) {
                        MsgBox("Game Over! Score: " . score, "Space Invaders", "OK")
                        SetTimer(UpdateSpaceInvaders, 0)
                        spaceGui.Destroy()
                        statusBar.Text := "Space Invaders game over"
                        return
                    }
                }
            }
            invaderBullets := newInvaderBullets
            
            ; Check bullet collisions
            newInvaders := []
            for invader in invaders {
                hit := false
                for bullet in bullets {
                    if (Abs(bullet[1] - invader[1]) < 15 && Abs(bullet[2] - invader[2]) < 15) {
                        hit := true
                        score += 10
                        break
                    }
                }
                if (!hit)
                    newInvaders.Push(invader)
            }
            invaders := newInvaders
            
            ; Random invader shooting
            if (invaders.Length > 0) {
                Random(&rand, 1, 100)
                if (rand = 1) {
                    Random(&randIdx, 1, invaders.Length)
                    invaderBullets.Push([invaders[randIdx][1], invaders[randIdx][2]])
                }
            }
            
            ; Draw game
            gameText := ""
            Loop 40 {
                y := A_Index * 10
                line := ""
                Loop 50 {
                    x := A_Index * 10
                    char := " "
                    
                    ; Draw player
                    if (y = 380 && Abs(x - playerX) < 10)
                        char := "^"
                    
                    ; Draw invaders
                    for invader in invaders {
                        if (Abs(x - invader[1]) < 5 && Abs(y - invader[2]) < 5)
                            char := "M"
                    }
                    
                    ; Draw bullets
                    for bullet in bullets {
                        if (Abs(x - bullet[1]) < 2 && Abs(y - bullet[2]) < 2)
                            char := "|"
                    }
                    
                    ; Draw invader bullets
                    for bullet in invaderBullets {
                        if (Abs(x - bullet[1]) < 2 && Abs(y - bullet[2]) < 2)
                            char := "."
                    }
                    
                    line .= char
                }
                gameText .= line . "`n"
            }
            
            spaceGui["GameArea"].Value := gameText . "`nScore: " . score . " | Lives: " . lives . " | Left/Right arrows, Space to shoot"
            
            if (invaders.Length = 0) {
                MsgBox("You win! Score: " . score, "Space Invaders", "OK")
                SetTimer(UpdateSpaceInvaders, 0)
                spaceGui.Destroy()
                statusBar.Text := "Space Invaders completed"
            }
        }
        
        statusBar.Text := "Space Invaders started - Arrow keys and Space"
    } catch as e {
        statusBar.Text := "Error starting Space Invaders: " e.Message
    }
}

; Clean up on exit
OnExit(ExitReason, ExitCode) {
    WinSetTransparent("Off", "A")
    return 0
}

; Show help when F1 is pressed
F1:: {
    MsgBox "Ultimate Scriptlet Launcher Help`n`n"
        . "Use number keys (01-45) to run scriptlets or click the buttons.`n"
        . "Navigate between categories using the tabs at the top.`n"
        . "`nCategories:`n"
        . "1. Utilities (01-15): System tools and productivity`n"
        . "2. Development (16-25): Coding and web development tools`n"
        . "3. Fun (26-35): Entertainment and fun utilities`n"
        . "4. Games (36-45): Simple ASCII-based games`n"
        . "`nPress ESC in games to exit.", "Scriptlet Launcher Help"
}

; Show a tooltip with the script's status when hovering over the tray icon
TraySetToolTip "Ultimate Scriptlet Launcher`nPress F1 for help"
