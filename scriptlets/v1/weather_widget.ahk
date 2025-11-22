#NoEnv
#SingleInstance Force
#Persistent
#SingleInstance ignore
SetWorkingDir %A_ScriptDir%
SetBatchLines -1

; Configuration
apiKey := "YOUR_API_KEY"  ; You'll need to get an API key from OpenWeatherMap
city := "Vienna"
countryCode := "AT"
units := "metric"  ; or "imperial" for Fahrenheit
updateInterval := 900000  ; 15 minutes in milliseconds

; Create the GUI
Gui, +AlwaysOnTop -Caption +ToolWindow +LastFound
Gui, Color, F0F0F0
Gui, Font, s10, Segoe UI

; Weather icon
Gui, Add, Picture, x10 y10 w64 h64 vWeatherIcon, 

; Temperature and description
Gui, Add, Text, x80 y10 w200 h30 vTemperature, Loading...
Gui, Add, Text, x80 y35 w200 h20 vDescription, 

; Additional info
Gui, Add, Text, x10 y80 w260 h20 vLocation, %city%, %countryCode%
Gui, Add, Text, x10 y105 w130 h20 vHumidity, 
Gui, Add, Text, x150 y105 w130 h20 vWind, 
Gui, Add, Text, x10 y130 w130 h20 vFeelsLike, 
Gui, Add, Text, x150 y130 w130 h20 vPressure, 

; Update button
Gui, Add, Button, x10 y160 w80 h25 vUpdateBtn gUpdateWeather, &Update

; Close button (X)
Gui, Add, Text, x260 y5 w20 h20 gGuiClose X, X

; Make window draggable
Gui, Show, w280 h190, Weather Widget
OnMessage(0x201, "WM_LBUTTONDOWN")

; Initial update
GoSub, UpdateWeather
SetTimer(UpdateWeather,  %updateInterval%
return

UpdateWeather:
    ; Get weather data
    url := "http://api.openweathermap.org/data/2.5/weather?q=" . city . "," . countryCode . "&units=" . units . "&appid=" . apiKey
    
    whr := ComObjCreate("WinHttp.WinHttpRequest.5.1")
    try {
        whr.Open("GET", url, false)
        whr.Send()
        
        if (whr.Status = 200) {
            data := JSON.Load(whr.ResponseText)
            
            ; Update GUI with weather data
            temp := Round(data.main.temp)
            desc := data.weather[1].description
            humidity := data.main.humidity
            windSpeed := data.wind.speed
            windDeg := data.wind.deg
            feelsLike := Round(data.main.feels_like)
            pressure := data.main.pressure
            iconCode := data.weather[1].icon
            
            ; Get wind direction
            windDir := GetWindDirection(windDeg)
            
            ; Update GUI
            GuiControl,, Temperature, %temp%°C
            GuiControl,, Description, %desc%
            GuiControl,, Humidity, 💧 %humidity%`%
            GuiControl,, Wind, 🌬️ %windSpeed% m/s %windDir%
            GuiControl,, FeelsLike, 🌡️ Feels like: %feelsLike%°C
            GuiControl,, Pressure, ⬇️ %pressure% hPa
            
            ; Download and set weather icon
            iconUrl := "http://openweathermap.org/img/wn/" . iconCode . "@2x.png"
            iconPath := A_Temp . "\weather_icon.png"
            UrlDownloadToFile, %iconUrl%, %iconPath%
            if (FileExist(iconPath)) {
                GuiControl,, WeatherIcon, %iconPath%
            }
            
            ; Update window title with temperature
            Gui, Show,, %city%: %temp%°C
        } else {
            GuiControl,, Temperature, Error: %whr.Status%
        }
    } catch e {
        GuiControl,, Temperature, Error: %e%
    }
return

GetWindDirection(degrees) {
    dirs := ["N", "NNE", "NE", "ENE", "E", "ESE", "SE", "SSE", "S", "SSW", "SW", "WSW", "W", "WNW", "NW", "NNW"]
    index := Mod(round(degrees / 22.5), 16) + 1
    return dirs[index]
}

; JSON parsing function (simple implementation)
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

; Make window draggable
WM_LBUTTONDOWN() {
    PostMessage, 0xA1, 2
}

; Hotkey to show/hide the widget
^!W::  ; Ctrl+Alt+W
    if (WinExist("Weather Widget")) {
        if (WinActive("Weather Widget")) {
            WinHide, Weather Widget
        } else {
            WinShow, Weather Widget
            WinActivate, Weather Widget
        }
    }
return

GuiClose:
ExitApp
