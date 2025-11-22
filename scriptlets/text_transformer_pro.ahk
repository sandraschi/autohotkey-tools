; ==============================================================================
; Text Transformer Pro
; @name: Text Transformer Pro
; @version: 1.0.0
; @description: Advanced text manipulation with case conversion, formatting, and encoding. Transform text with multiple conversion options and encoding support.
; @description: Provides uppercase, lowercase, title case, sentence case, camelCase, PascalCase, and encoding conversions. Includes clipboard integration and bulk text processing capabilities.
; @description: Essential text processing tool for developers and writers who need quick text transformations and encoding conversions.
; @category: utilities
; @author: Sandra
; @hotkeys: ^!t, ^!u, ^!l, ^!s
; @enabled: true
; @priority: 20
; @tag: text-transformation, utilities, case-conversion, formatting, encoding, productivity, clipboard
; @cli: --transform <type> - Transform clipboard text (upper, lower, title, sentence, camel, pascal)
; @cli: --encode <encoding> - Encode text (base64, url, html)
; @cli: --help - Show CLI usage and transformation options
; @dependencies: 
; ==============================================================================

#Requires AutoHotkey v2.0+
#SingleInstance Force
#Include %A_ScriptDir%\lib\ScriptletErrorHandler.ahk


; Suppress error popups - log to file instead
OnError(LogError)


class TextTransformer {
    static Init() {
        this.CreateGUI()
    }
    
    static CreateGUI() {
        this.gui := Gui("+Resize", "Text Transformer Pro")
        
        ; Input area
        this.gui.Add("Text", "w600 h20", "Input Text:")
        this.inputArea := this.gui.Add("Edit", "w600 h150 VScroll", "")
        
        ; Transform buttons
        buttonPanel := this.gui.Add("Text", "w600 h40")
        
        upperBtn := this.gui.Add("Button", "x10 y10 w80 h25", "UPPERCASE")
        lowerBtn := this.gui.Add("Button", "x100 y10 w80 h25", "lowercase")
        titleBtn := this.gui.Add("Button", "x190 y10 w80 h25", "Title Case")
        camelBtn := this.gui.Add("Button", "x280 y10 w80 h25", "camelCase")
        snakeBtn := this.gui.Add("Button", "x370 y10 w80 h25", "snake_case")
        kebabBtn := this.gui.Add("Button", "x460 y10 w80 h25", "kebab-case")
        
        upperBtn.OnEvent("Click", this.ToUpperCase.Bind(this))
        lowerBtn.OnEvent("Click", this.ToLowerCase.Bind(this))
        titleBtn.OnEvent("Click", this.ToTitleCase.Bind(this))
        camelBtn.OnEvent("Click", this.ToCamelCase.Bind(this))
        snakeBtn.OnEvent("Click", this.ToSnakeCase.Bind(this))
        kebabBtn.OnEvent("Click", this.ToKebabCase.Bind(this))
        
        ; Advanced buttons
        advPanel := this.gui.Add("Text", "w600 h40")
        
        reverseBtn := this.gui.Add("Button", "x10 y10 w80 h25", "Reverse")
        sortBtn := this.gui.Add("Button", "x100 y10 w80 h25", "Sort Lines")
        dedupBtn := this.gui.Add("Button", "x190 y10 w80 h25", "Remove Duplicates")
        encodeBtn := this.gui.Add("Button", "x280 y10 w80 h25", "Base64 Encode")
        decodeBtn := this.gui.Add("Button", "x370 y10 w80 h25", "Base64 Decode")
        jsonBtn := this.gui.Add("Button", "x460 y10 w80 h25", "Format JSON")
        
        reverseBtn.OnEvent("Click", this.ReverseText.Bind(this))
        sortBtn.OnEvent("Click", this.SortLines.Bind(this))
        dedupBtn.OnEvent("Click", this.RemoveDuplicates.Bind(this))
        encodeBtn.OnEvent("Click", this.Base64Encode.Bind(this))
        decodeBtn.OnEvent("Click", this.Base64Decode.Bind(this))
        jsonBtn.OnEvent("Click", this.FormatJSON.Bind(this))
        
        ; Output area
        this.gui.Add("Text", "w600 h20", "Output Text:")
        this.outputArea := this.gui.Add("Edit", "w600 h150 VScroll ReadOnly", "")
        
        ; Action buttons
        actionPanel := this.gui.Add("Text", "w600 h40")
        
        copyBtn := this.gui.Add("Button", "x10 y10 w80 h25", "Copy Output")
        clearBtn := this.gui.Add("Button", "x100 y10 w80 h25", "Clear All")
        swapBtn := this.gui.Add("Button", "x190 y10 w80 h25", "Swap I/O")
        
        copyBtn.OnEvent("Click", this.CopyOutput.Bind(this))
        clearBtn.OnEvent("Click", this.ClearAll.Bind(this))
        swapBtn.OnEvent("Click", this.SwapInputOutput.Bind(this))
        
        ; Add exit handlers
        this.gui.OnEvent("Close", (*) => this.Stop())
        this.gui.OnEvent("Escape", (*) => this.Stop())
        
        this.gui.Show("w620 h450")
    }
    
    static ToUpperCase(*) {
        text := this.inputArea.Text
        this.outputArea.Text := StrUpper(text)
    }
    
    static ToLowerCase(*) {
        text := this.inputArea.Text
        this.outputArea.Text := StrLower(text)
    }
    
    static ToTitleCase(*) {
        text := this.inputArea.Text
        words := StrSplit(text, " ")
        result := ""
        
        for word in words {
            if (StrLen(word) > 0) {
                result .= StrUpper(SubStr(word, 1, 1)) . StrLower(SubStr(word, 2)) . " "
            }
        }
        
        this.outputArea.Text := Trim(result)
    }
    
    static ToCamelCase(*) {
        text := this.inputArea.Text
        words := StrSplit(text, " ")
        result := ""
        
        for i, word in words {
            if (StrLen(word) > 0) {
                if (i = 1) {
                    result .= StrLower(word)
                } else {
                    result .= StrUpper(SubStr(word, 1, 1)) . StrLower(SubStr(word, 2))
                }
            }
        }
        
        this.outputArea.Text := result
    }
    
    static ToSnakeCase(*) {
        text := this.inputArea.Text
        text := RegExReplace(text, "([a-z])([A-Z])", "$1_$2")
        text := StrLower(text)
        text := RegExReplace(text, "[^a-z0-9_]", "_")
        text := RegExReplace(text, "_+", "_")
        this.outputArea.Text := text
    }
    
    static ToKebabCase(*) {
        text := this.inputArea.Text
        text := RegExReplace(text, "([a-z])([A-Z])", "$1-$2")
        text := StrLower(text)
        text := RegExReplace(text, "[^a-z0-9-]", "-")
        text := RegExReplace(text, "-+", "-")
        this.outputArea.Text := text
    }
    
    static ReverseText(*) {
        text := this.inputArea.Text
        reversed := ""
        Loop StrLen(text) {
            i := StrLen(text) - A_Index + 1
            reversed .= SubStr(text, i, 1)
        }
        this.outputArea.Text := reversed
    }
    
    static SortLines(*) {
        text := this.inputArea.Text
        lines := StrSplit(text, "`n")
        lines.Sort()
        this.outputArea.Text := Join(lines, "`n")
    }
    
    static RemoveDuplicates(*) {
        text := this.inputArea.Text
        lines := StrSplit(text, "`n")
        unique := []
        seen := Map()
        
        for line in lines {
            if (!seen.Has(line)) {
                seen[line] := true
                unique.Push(line)
            }
        }
        
        this.outputArea.Text := Join(unique, "`n")
    }
    
    static Base64Encode(*) {
        text := this.inputArea.Text
        try {
            encoded := Base64Encode(text)
            this.outputArea.Text := encoded
        } catch {
            this.outputArea.Text := "Error: Failed to encode"
        }
    }
    
    static Base64Decode(*) {
        text := this.inputArea.Text
        try {
            decoded := Base64Decode(text)
            this.outputArea.Text := decoded
        } catch {
            this.outputArea.Text := "Error: Failed to decode"
        }
    }
    
    static FormatJSON(*) {
        text := this.inputArea.Text
        try {
            obj := JSON.parse(text)
            formatted := JSON.stringify(obj, 4)
            this.outputArea.Text := formatted
        } catch as e {
            this.outputArea.Text := "Error: Invalid JSON - " . e.Message
        }
    }
    
    static CopyOutput(*) {
        Clipboard := this.outputArea.Text
        ToolTip("Output copied to clipboard!")
        SetTimer(() => ToolTip(), -2000)
    }
    
    static ClearAll(*) {
        this.inputArea.Text := ""
        this.outputArea.Text := ""
    }
    
    static SwapInputOutput(*) {
        input := this.inputArea.Text
        output := this.outputArea.Text
        this.inputArea.Text := output
        this.outputArea.Text := input
    }
    
    static Stop(*) {
        if (this.gui) {
            this.gui.Destroy()
            this.gui := ""
        }
    }
}

; JSON utility class for parsing and stringifying JSON
class JSON {
    static parse(jsonString) {
        if (!jsonString) {
            return {}
        }
        
        try {
            jsonString := Trim(jsonString, " `t`r`n")
            if (SubStr(jsonString, 1, 1) = "{" && SubStr(jsonString, 0) = "}") {
                obj := {}
                content := SubStr(jsonString, 2, -1)
                
                ; Simple parser for basic JSON objects
                Loop Parse, content, "," {
                    pair := StrSplit(Trim(A_LoopField), ":")
                    if (pair.Length >= 2) {
                        key := Trim(pair[1], ' `t"')
                        value := Trim(pair[2], ' `t"')
                        ; Handle numeric values
                        if (RegExMatch(value, "^\d+$") || RegExMatch(value, "^\d+\.\d+$")) {
                            obj[key] := value + 0  ; Convert to number
                        } else if (value = "true" || value = "false") {
                            obj[key] := (value = "true")
                        } else if (value = "null") {
                            obj[key] := ""
                        } else {
                            obj[key] := value
                        }
                    }
                }
                return obj
            }
            return {}
        } catch {
            return {}
        }
    }
    
    static stringify(obj, indent := 0) {
        if (!IsObject(obj)) {
            if (obj = "") {
                return '""'
            } else if (obj is String) {
                escaped := StrReplace(obj, "\", "\\")
                escaped := StrReplace(escaped, '"', '\"')
                escaped := StrReplace(escaped, "`n", "\n")
                escaped := StrReplace(escaped, "`r", "\r")
                escaped := StrReplace(escaped, "`t", "\t")
                return '"' . escaped . '"'
            } else {
                return obj
            }
        }
        
        indentStr := ""
        if (indent > 0) {
            indentStr := "`n"
            loop indent {
                indentStr .= " "
            }
        }
        
        result := "{"
        first := true
        
        for key, value in obj {
            if (!first) {
                result .= ","
            }
            if (indent > 0) {
                result .= indentStr
            }
            result .= '"' . key . '": '
            
            if (IsObject(value)) {
                if (indent > 0) {
                    result .= this.stringify(value, indent)
                } else {
                    result .= this.stringify(value, 0)
                }
            } else if (value is String) {
                escaped := StrReplace(value, "\", "\\")
                escaped := StrReplace(escaped, '"', '\"')
                escaped := StrReplace(escaped, "`n", "\n")
                escaped := StrReplace(escaped, "`r", "\r")
                escaped := StrReplace(escaped, "`t", "\t")
                result .= '"' . escaped . '"'
            } else if (value is Number) {
                result .= value
            } else if (value = true) {
                result .= "true"
            } else if (value = false) {
                result .= "false"
            } else {
                result .= 'null'
            }
            first := false
        }
        
        if (indent > 0) {
            result .= "`n"
        }
        result .= "}"
        return result
    }
}

; Helper functions
Join(array, delimiter) {
    result := ""
    for i, item in array {
        result .= item
        if (i < array.Length) {
            result .= delimiter
        }
    }
    return result
}

Base64Encode(text) {
    ; Base64 encoding using Windows API
    try {
        ; Convert text to UTF-8 bytes
        textBuf := Buffer(StrPut(text, "UTF-8"))
        StrPut(text, textBuf, "UTF-8")
        
        ; Get required buffer size for Base64 string
        if !DllCall("crypt32\CryptBinaryToString", "Ptr", textBuf.Ptr, "UInt", textBuf.Size - 1, "UInt", 0x1, "Ptr", 0, "UInt*", &size := 0)
            throw Error("Failed to get buffer size")
        
        ; Encode to Base64
        encoded := Buffer(size * 2)
        if !DllCall("crypt32\CryptBinaryToString", "Ptr", textBuf.Ptr, "UInt", textBuf.Size - 1, "UInt", 0x1, "Ptr", encoded.Ptr, "UInt*", &size)
            throw Error("Failed to encode")
        
        result := StrGet(encoded, "UTF-16")
        ; Remove CRLF line breaks that Windows API adds
        result := StrReplace(result, "`r`n", "")
        result := StrReplace(result, "`r", "")
        result := StrReplace(result, "`n", "")
        return result
    } catch as e {
        throw Error("Base64 encoding failed: " . e.Message)
    }
}

Base64Decode(text) {
    ; Base64 decoding using Windows API
    try {
        ; Get required buffer size for decoded binary
        if !DllCall("crypt32\CryptStringToBinary", "Str", text, "UInt", 0, "UInt", 0x1, "Ptr", 0, "UInt*", &size := 0, "Ptr", 0, "Ptr", 0)
            throw Error("Invalid Base64 string")
        
        ; Decode from Base64
        buf := Buffer(size)
        if !DllCall("crypt32\CryptStringToBinary", "Str", text, "UInt", 0, "UInt", 0x1, "Ptr", buf.Ptr, "UInt*", &size, "Ptr", 0, "Ptr", 0)
            throw Error("Decode failed")
        
        decoded := StrGet(buf, size, "UTF-8")
        return decoded
    } catch as e {
        throw Error("Base64 decoding failed: " . e.Message)
    }
}

; Hotkeys
Hotkey("^!t", (*) => TextTransformer.Init())
Hotkey("^!u", (*) => TextTransformer.ToUpperCase())
Hotkey("^!l", (*) => TextTransformer.ToLowerCase())
Hotkey("^!s", (*) => TextTransformer.ToSnakeCase())

; Register exit handler
OnExit((*) => TextTransformer.Stop())

; Initialize
TextTransformer.Init()


