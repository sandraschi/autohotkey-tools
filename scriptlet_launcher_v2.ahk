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
        
        FormatTime currentTime, , "yyyy-MM-dd HH:mm:ss"
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
            FormatTime timestamp, "yyyyMMdd_HHmmss"
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

; More game and utility functions would go here...

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
