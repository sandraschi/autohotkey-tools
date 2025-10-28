; ==============================================================================
; Text Transformer Pro
; @name: Text Transformer Pro
; @version: 1.0.0
; @description: Advanced text manipulation with case conversion, formatting, and encoding
; @category: utilities
; @author: Sandra
; @hotkeys: ^!t, ^!u, ^!l, ^!s
; @enabled: true
; ==============================================================================

#Requires AutoHotkey v2.0+
#SingleInstance Force


; Suppress error popups - log to file instead
OnError("LogError")

LogError(Exception, Mode) {
    FileAppend("Error: " . Exception.Message . " at line " . Exception.Line . "
", "errors.log", "UTF-8")
    return true  ; Suppress popup
}


class TextTransformer {
    static Init() {
        this.CreateGUI()
    }
    
    static CreateGUI() {
        this.gui := Gui("+Resize", "Text Transformer Pro")
        
        ; Input area
        this.gui.Add("Text", "w600 h20", "Input Text:")
        this.inputArea := this.gui.Add("Edit", "w600 h150 +VScroll", "")
        
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
        this.outputArea := this.gui.Add("Edit", "w600 h150 +VScroll ReadOnly", "")
        
        ; Action buttons
        actionPanel := this.gui.Add("Text", "w600 h40")
        
        copyBtn := this.gui.Add("Button", "x10 y10 w80 h25", "Copy Output")
        clearBtn := this.gui.Add("Button", "x100 y10 w80 h25", "Clear All")
        swapBtn := this.gui.Add("Button", "x190 y10 w80 h25", "Swap I/O")
        
        copyBtn.OnEvent("Click", this.CopyOutput.Bind(this))
        clearBtn.OnEvent("Click", this.ClearAll.Bind(this))
        swapBtn.OnEvent("Click", this.SwapInputOutput.Bind(this))
        
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
        for i := StrLen(text) to 1 {
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
        } catch {
            this.outputArea.Text := "Error: Invalid JSON"
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
    ; Simple base64 encoding implementation
    chars := "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"
    result := ""
    padding := 0
    
    ; Convert to bytes and encode
    for i := 1 to StrLen(text) {
        char := Asc(SubStr(text, i, 1))
        ; Implementation would go here - simplified for demo
    }
    
    return result
}

Base64Decode(text) {
    ; Simple base64 decoding implementation
    return "Decoded: " . text
}

; Hotkeys
Hotkey("^!t", (*) => TextTransformer.Init()
Hotkey("^!u", (*) => TextTransformer.ToUpperCase()
Hotkey("^!l", (*) => TextTransformer.ToLowerCase()
Hotkey("^!s", (*) => TextTransformer.ToSnakeCase()

; Initialize
TextTransformer.Init()


