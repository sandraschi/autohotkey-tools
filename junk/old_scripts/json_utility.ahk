; ==============================================================================
; JSON Utility Class - Simple JSON handling for AutoHotkey v2
; ==============================================================================

class JSON {
    static stringify(obj) {
        if (IsObject(obj)) {
            if (obj is Array) {
                items := []
                for item in obj {
                    items.Push(this.stringify(item))
                }
                return "[" . this.Join(items, ",") . "]"
            } else if (obj is Map) {
                items := []
                for key, value in obj {
                    items.Push('"' . this.Escape(key) . '":' . this.stringify(value))
                }
                return "{" . this.Join(items, ",") . "}"
            } else {
                ; Regular object
                items := []
                for prop in obj.OwnProps() {
                    try {
                        items.Push('"' . this.Escape(prop) . '":' . this.stringify(obj.%prop%))
                    } catch {
                        ; Skip properties that can't be accessed
                        continue
                    }
                }
                return "{" . this.Join(items, ",") . "}"
            }
        } else if (IsNumber(obj)) {
            return String(obj)
        } else if (obj = true || obj = false) {
            return obj ? "true" : "false"
        } else {
            return '"' . this.Escape(String(obj)) . '"'
        }
    }
    
    static Escape(str) {
        ; Escape JSON special characters
        str := StrReplace(str, '\', '\\')
        str := StrReplace(str, '"', '\"')
        str := StrReplace(str, '`n', '\n')
        str := StrReplace(str, '`r', '\r')
        str := StrReplace(str, '`t', '\t')
        return str
    }
    
    static Join(arr, delimiter) {
        result := ""
        for i, item in arr {
            result .= (i > 1 ? delimiter : "") . item
        }
        return result
    }
}