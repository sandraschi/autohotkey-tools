#Requires AutoHotkey v2.0+
#SingleInstance Force

#Include %A_ScriptDir%\lib\ScriptletErrorHandler.ahk

; ==============================================================================
; @name: Word Games
; @version: 1.0.0
; @description: Wordle, Anagrams, Hangman. Button-based input (no Hotkey).
; @category: games
; @author: Sandra
; @hotkeys: ^!g toggle
; @tag: games, wordle, anagrams, hangman, word
; ==============================================================================

WORDS := ["about","above","abuse","actor","acute","admit","adopt","adult","after","again","agent","agree","ahead","alarm","album","alert","alien","align","alive","allow","alone","along","alter","angel","anger","angle","angry","apart","apple","apply","arena","argue","arise","armor","array","aside","asset","avoid","award","aware","awful","bacon","badge","basic","basin","basis","batch","beach","beard","beast","begin","being","below","bench","billy","birth","black","blade","blame","blank","blast","blaze","bleed","blend","bless","blind","block","blood","bloom","board","bonus","booth","bound","brain","brand","brave","bread","break","breed","brick","brief","bring","broad","broke","brook","brown","brush","buddy","build","built","bunch","burst","cabin","cable","candy","carry","catch","cause","cease","chain","chair","chalk","champ","chaos","charm","chart","chase","cheap","check","cheek","cheer","chess","chest","chief","child","chill","china","choir","civil","claim","clash","class","clean","clear","clerk","click","cliff","climb","cling","clock","close","cloth","cloud","coach","coast","color","comet","cover","craft","crane","crash","crawl","crazy","cream","crest","crime","crisp","cross","crowd","crown","crush","curve","cycle","daily","dance","debut","decay","delay","delta","demon","dense","depot","depth","derby","desk","devil","diary","dirty","ditch","dizzy","dodge","doing","donor","doubt","dough","draft","drain","drama","drank","drape","drawn","dread","dream","dress","dried","drift","drill","drink","drive","drone","drove","drunk","dryer","dying","eager","early","earth","eight","elbow","elder","elect","elite","email","empty","enemy","enjoy","enter","entry","equal","equip","error","essay","event","every","exact","exile","exist","extra","fable","facet","faith","false","fancy","fatal","fault","feast","fence","ferry","fetch","fever","fewer","fiber","field","fifth","fifty","fight","final","first","fixed","flame","flash","fleet","flesh","float","flock","flood","floor","flora","flour","fluid","flush","focal","focus","force","forge","forth","forum","found","frame","frank","fraud","fresh","front","frost","froze","fruit","fully","fungi","gauge","genre","ghost","giant","given","glad","gland","glass","gleam","glide","globe","gloom","glory","gloss","glove","going","grace","grade","grain","grand","grant","grape","graph","grasp","grass","grave","great","green","greet","grief","grill","grind","groan","groom","gross","group","grove","grown","guard","guess","guest","guide","guild","guilt","guise","gulch","gully","gumbo","gummy","happy","harsh","haste","haunt","haven","hazel","heart","heavy","hedge","hello","hence","herbs","hobby","honey","honor","horde","horse","hotel","house","human","humor","hurry","ideal","image","imply","index","indie","inner","input","irony","ivory","jelly","jewel","joint","joker","judge","juice","juicy","kebab","knack","kneel","knock","known","label","labor","large","laser","later","laugh","layer","learn","lease","leave","legal","lemon","level","lever","light","limit","linen","liver","local","lodge","logic","loose","lover","lower","loyal","lucky","lunch","lyric","magic","major","maker","manor","maple","march","marry","marsh","match","maybe","mayor","meant","media","mercy","merge","merit","merry","metal","meter","might","minor","minus","mirth","model","money","month","moral","motor","mound","mount","mourn","mouse","mouth","movie","music","nadir","naval","nerve","never","newly","night","noble","noise","north","noted","novel","nylon","occur","ocean","offer","often","olive","onset","opera","orbit","order","organ","other","ounce","outer","overt","owner","oxide","ozone","paint","panel","panic","paper","party","pasta","paste","patch","pause","peace","pearl","penny","phase","phone","photo","piano","piece","pilot","pitch","pixel","pizza","place","plain","plane","plant","plate","plaza","plead","pluck","plumb","plume","plump","plunge","point","polar","pouch","pound","power","press","price","pride","prime","print","prior","prize","probe","prone","proof","prose","proud","prove","psalm","pulse","punch","pupil","purse","queen","quest","queue","quick","quiet","quirk","quota","quote","radar","radio","raise","rally","ramen","ranch","range","rapid","ratio","reach","react","realm","rebel","recur","refer","reign","relax","relay","renal","renew","reply","rider","ridge","rifle","right","rigid","ripen","risen","risky","rival","river","roast","robin","robot","rocky","roman","rouge","rough","round","route","rover","royal","rugby","ruler","rural","sadly","saint","salad","salsa","salon","sauce","scale","scene","scent","scope","score","scout","scrap","sense","serve","setup","seven","shade","shaft","shake","shall","shame","shape","share","shark","sharp","sheer","sheet","shelf","shell","shift","shine","shirt","shock","shore","short","shout","shove","sight","sigma","silly","since","sixth","sixty","skate","skill","skull","slash","slate","slave","sleep","slice","slope","small","smart","smell","smile","smoke","snack","snake","solar","solid","solve","sorry","sound","south","space","spare","spark","speak","speed","spend","spice","spill","spine","spite","split","spoke","spoon","spray","squad","stack","staff","stage","stain","stake","stale","stall","stamp","stand","stark","start","state","stave","steady","steal","steam","steel","steep","steer","stern","stick","stiff","still","stock","stole","stone","stool","store","storm","story","stove","straw","strip","stuck","study","stuff","style","sugar","suite","sunny","super","surge","swamp","swear","sweep","sweet","swept","swift","swing","swirl","sword","swore","sworn","syrup","table","taste","tease","tempo","tense","tenth","theme","there","thick","thing","think","third","thorn","three","throw","thump","thumb","tidal","tiger","tight","timer","tired","title","toast","today","token","topic","total","touch","tough","tower","toxic","trace","track","trade","trail","train","trait","trash","treat","trend","trial","tribe","trick","tried","troop","truce","truly","trump","trunk","trust","truth","tumor","twice","twist","ultra","uncle","under","union","unite","unity","until","upper","upset","urban","usage","usual","usurp","utter","valid","valor","value","valve","vapor","vault","venom","verse","video","vigor","vinyl","viral","virus","visit","vista","vital","vivid","vocal","vodka","voice","vouch","vowel","waste","watch","water","wavey","wheat","wheel","where","which","while","white","whole","whose","wider","witch","woman","world","worry","worse","worst","worth","would","wound","wreck","wrist","write","wrong","wrote","yacht","yield","young","youth","zebra"]

class WordGames {
    static gui := 0
    static tabs := 0
    static wordleGrid := []
    static wordleRow := 0
    static wordleCol := 0
    static wordleTarget := ""
    static wordleKeyLabel := 0
    static wordleGuesses := []
    static anagScrambleLabel := 0
    static anagInput := 0
    static anagScoreLabel := 0
    static anagWord := ""
    static anagScrambled := ""
    static anagScore := 0
    static hangWord := ""
    static hangDisplay := 0
    static hangMsgLabel := 0
    static hangWrong := 0
    static hangMaxWrong := 6
    static hangButtons := []

    static Init() {
        this.BuildGui()
        Hotkey("^!g", (*) => this.Toggle())
    }

    static BuildGui() {
        WordGames.gui := Gui("+AlwaysOnTop +Resize +MinSize500x450", "Word Games")
        WordGames.gui.BackColor := "131320"
        WordGames.gui.SetFont("s9 c4488FF", "Segoe UI")

        WordGames.tabs := WordGames.gui.Add("Tab3", "x6 y6 w488 h430", ["Wordle", "Anagrams", "Hangman"])
        WordGames.tabs.SetFont("s9 cFFFF00", "Segoe UI")
        WordGames.tabs.UseTab(1)
        this.BuildWordle()
        WordGames.tabs.UseTab(2)
        this.BuildAnagrams()
        WordGames.tabs.UseTab(3)
        this.BuildHangman()

        WordGames.gui.OnEvent("Close", (*) => WordGames.gui.Hide())
        WordGames.gui.Show("w500 h450")
        WordGames.SetupKeyboard()
    }

    static SetupKeyboard() {
        hwnd := WordGames.gui.Hwnd
        alphabet := ["a","b","c","d","e","f","g","h","i","j","k","l","m","n","o","p","q","r","s","t","u","v","w","x","y","z"]
        ; Wordle tab (index 1): letters type into grid
        HotIf((*) => WinActive("ahk_id " . hwnd) && WordGames.tabs.Value = 1)
        for _, ch in alphabet
            Hotkey(ch, WordGames.WordleType.Bind(ch))
        Hotkey("Backspace", (*) => WordGames.WordleUndo())
        Hotkey("Enter",     (*) => WordGames.WordleSubmit())
        ; Hangman tab (index 3): letters guess
        HotIf((*) => WinActive("ahk_id " . hwnd) && WordGames.tabs.Value = 3)
        for _, ch in alphabet
            Hotkey(ch, WordGames.HangmanGuess.Bind(ch))
        HotIf()
    }

    static Toggle() {
        if (WordGames.gui.Visible)
            WordGames.gui.Hide()
        else
            WordGames.gui.Show("NoActivate")
    }

    static MakeKeyboard(g, x, y, callback) {
        btns := []
        rows := [["q","w","e","r","t","y","u","i","o","p"],["a","s","d","f","g","h","j","k","l"],["z","x","c","v","b","n","m"]]
        for _, row in rows {
            rx := x
            for _, ch in row {
                btn := g.Add("Button", Format("x{} y{} w24 h24 cWhite Background333344", rx, y), StrUpper(ch))
                btn.OnEvent("Click", callback.Bind(ch))
                btns.Push(btn)
                rx += 28
            }
            y += 28
        }
        return btns
    }

    ; ===== WORDLE =====
    static BuildWordle() {
        g := WordGames.gui
        WordGames.wordleRow := 0
        WordGames.wordleCol := 0
        WordGames.wordleTarget := ""

        g.Add("Button", "x420 y22 w24 h22 Background333344 cFFFF00", "?").OnEvent("Click", (*) => WordGames.WordleHelp())
        for r in [1,2,3,4,5,6] {
            row := []
            for c in [1,2,3,4,5] {
                x := 160 + (c - 1) * 46
                y := 45 + (r - 1) * 46
                ctrl := g.Add("Text", Format("x{} y{} w40 h40 Background334466 cFFFFFF", x, y), "")
                ctrl.SetFont("s18 cFFFFFF w700", "Consolas")
                row.Push(ctrl)
            }
            WordGames.wordleGrid.Push(row)
        }
        g.Add("Button", "x50 y335 w120 h28 cWhite Background1a5a1a", "New Game").OnEvent("Click", (*) => WordGames.WordleNew())
        g.Add("Button", "x190 y335 w120 h28 cWhite Background333344", "Submit").OnEvent("Click", (*) => WordGames.WordleSubmit())
        g.Add("Button", "x330 y335 w50 h28 cWhite Background333344", "Undo").OnEvent("Click", (*) => WordGames.WordleUndo())
        g.Add("Button", "x390 y335 w36 h28 Background333344 cFFFF00", "C").OnEvent("Click", (*) => WordGames.WordleCheat())
        g.Add("Button", "x428 y335 w36 h28 Background333344 c00FF88", "S").OnEvent("Click", (*) => WordGames.WordleSuperCheat())
        WordGames.wordleKeyLabel := g.Add("Text", "x50 y370 w400 h30 cGray Center", "Press New Game to start")
    }

    static WordleNew() {
        idx := Random(1, WORDS.Length)
        WordGames.wordleTarget := WORDS[idx]
        WordGames.wordleGuesses := []
        WordGames.wordleRow := 0
        WordGames.wordleCol := 0
        for r in WordGames.wordleGrid {
            for ctrl in r {
                ctrl.Text := ""
                ctrl.Opt("Background334466")
            }
        }
        WordGames.wordleKeyLabel.Text := "Guess the 5-letter word. Type or click ? for rules."
    }

    static WordleType(key) {
        if (WordGames.wordleCol >= 5 || WordGames.wordleRow >= 6)
            return
        ctrl := WordGames.wordleGrid[WordGames.wordleRow + 1][WordGames.wordleCol + 1]
        ctrl.Text := StrUpper(key)
        WordGames.wordleCol++
        if (WordGames.wordleCol < 5) {
            WordGames.wordleGrid[WordGames.wordleRow + 1][WordGames.wordleCol + 1]
        }
    }

    static WordleSubmit(*) {
        if (WordGames.wordleCol < 5) {
            WordGames.wordleKeyLabel.Text := "Not enough letters"
            return
        }
        target := WordGames.wordleTarget
        guess := ""
        for ctrl in WordGames.wordleGrid[WordGames.wordleRow + 1]
            guess .= ctrl.Text
        guess := StrLower(guess)
        tChars := StrSplit(target)
        gChars := StrSplit(guess)
        used := [false, false, false, false, false]
        result := ["", "", "", "", ""]

        ; Green: exact match
        for i in [1,2,3,4,5] {
            if (gChars[i] = tChars[i]) {
                c := WordGames.wordleGrid[WordGames.wordleRow + 1][i]
                c.Opt("Background145214")
                c.Redraw()
                used[i] := true
                result[i] := "G"
            }
        }
        ; Yellow: letter exists elsewhere
        for i in [1,2,3,4,5] {
            if (result[i] != "")
                continue
            for j in [1,2,3,4,5] {
                if (used[j])
                    continue
                if (gChars[i] = tChars[j]) {
                    c := WordGames.wordleGrid[WordGames.wordleRow + 1][i]
                    c.Opt("Background6b6b14")
                    c.Redraw()
                    used[j] := true
                    result[i] := "Y"
                    break
                }
            }
        }
        ; Gray: not in word
        for i in [1,2,3,4,5] {
            if (result[i] = "") {
                c := WordGames.wordleGrid[WordGames.wordleRow + 1][i]
                c.Opt("Background2a2a2a")
                c.Redraw()
                result[i] := "X"
            }
        }
        WordGames.wordleGuesses.Push({letters: gChars, colors: result})
        if (guess = target) {
            WordGames.wordleKeyLabel.Text := "Correct! Press New Game"
            return
        }
        WordGames.wordleRow++
        WordGames.wordleCol := 0
        if (WordGames.wordleRow >= 6) {
            WordGames.wordleKeyLabel.Text := "Word was: " . StrUpper(target) . " — New Game"
        } else {
            WordGames.wordleKeyLabel.Text := "Guess " . (WordGames.wordleRow + 1) . " of 6"
        }
    }

    static WordleUndo(*) {
        if (WordGames.wordleCol <= 0)
            return
        WordGames.wordleCol--
        ctrl := WordGames.wordleGrid[WordGames.wordleRow + 1][WordGames.wordleCol + 1]
        ctrl.Text := ""
    }

    static WordleHelp(*) {
        MsgBox(
            "Wordle: Guess the hidden 5-letter word in 6 tries.`n`n"
            . "Green box  = correct letter, correct position`n"
            . "Yellow box = correct letter, wrong position`n"
            . "Gray box   = letter not in the word`n`n"
            . "Type letters on your keyboard. Backspace to undo. Enter to submit.",
            "Wordle Help", "Iconi"
        )
    }

    static WordleCheat(*) {
        if (WordGames.wordleGuesses.Length = 0 or WordGames.wordleRow >= 6) {
            WordGames.wordleKeyLabel.Text := "Make a guess first, then cheat!"
            return
        }
        ; Build constraints from all completed guesses
        exact := ["", "", "", "", ""]
        present := Map()
        absent := Map()
        wrongPos := Map()
        for guess in WordGames.wordleGuesses {
            for i in [1,2,3,4,5] {
                ch := guess.letters[i]
                clr := guess.colors[i]
                if (clr = "G") {
                    exact[i] := ch
                } else if (clr = "Y") {
                    present[ch] := true
                    if (!wrongPos.Has(ch))
                        wrongPos[ch] := []
                    wrongPos[ch].Push(i)
                } else {
                    if (!present.Has(ch) && exact[1] != ch && exact[2] != ch && exact[3] != ch && exact[4] != ch && exact[5] != ch)
                        absent[ch] := true
                }
            }
        }
        ; Filter WORDS
        valid := []
        for _, w in WORDS {
            wChars := StrSplit(w)
            ok := true
            ; Check exact matches
            for i in [1,2,3,4,5] {
                if (exact[i] != "" && wChars[i] != exact[i]) {
                    ok := false
                    break
                }
            }
            if (!ok)
                continue
            ; Check present letters
            for ch, _ in present {
                if (!InStr(w, ch)) {
                    ok := false
                    break
                }
            }
            if (!ok)
                continue
            ; Check absent letters
            for ch, _ in absent {
                if (InStr(w, ch)) {
                    ok := false
                    break
                }
            }
            if (!ok)
                continue
            ; Check wrong positions
            for ch, positions in wrongPos {
                for _, pos in positions {
                    if (wChars[pos] = ch) {
                        ok := false
                        break
                    }
                }
                if (!ok)
                    break
            }
            if (!ok)
                continue
            valid.Push(w)
        }
        if (valid.Length = 0) {
            WordGames.wordleKeyLabel.Text := "No valid words found!"
            return
        }
        ; Fill current row with first valid word
        word := valid[1]
        row := WordGames.wordleRow
        for i in [1,2,3,4,5] {
            ctrl := WordGames.wordleGrid[row + 1][i]
            ctrl.Text := StrUpper(SubStr(word, i, 1))
        }
        WordGames.wordleCol := 5
        WordGames.wordleKeyLabel.Text := "Cheated: " . word . " (" . valid.Length . " candidates)"
    }

    static WordleSuperCheat(*) {
        if (WordGames.wordleGuesses.Length = 0 && WordGames.wordleCol = 0) {
            WordGames.wordleKeyLabel.Text := "Make a guess first to seed the solver"
            return
        }
        maxTries := 6 - WordGames.wordleRow
        loop maxTries {
            WordGames.WordleCheat()
            if (WordGames.wordleCol < 5)
                return
            WordGames.WordleSubmit()
            if (InStr(WordGames.wordleKeyLabel.Text, "Correct"))
                return
            if (WordGames.wordleRow >= 6)
                break
        }
        WordGames.wordleKeyLabel.Text := "Super cheat done"
    }

    ; ===== ANAGRAMS =====
    static BuildAnagrams() {
        g := WordGames.gui
        g.Add("Text", "x50 y12 w400 h20 cAAAAAA Center", "Unscramble the word shown in yellow. Type the answer into the box and click Guess.")
        g.Add("Text", "x50 y50 w400 h30 cWhite Center", "Unscramble the word!")
        WordGames.anagScrambleLabel := g.Add("Text", "x50 y90 w400 h40 cFFBF00 Center", "")
        WordGames.anagScrambleLabel.SetFont("s22 cFFFF00", "Consolas")
        WordGames.anagInput := g.Add("Edit", "x100 y140 w300 h28 Center -WantTab", "")
        g.Add("Button", "x140 y180 w110 h28 cWhite Background1a5a1a", "Guess").OnEvent("Click", (*) => WordGames.AnagGuess())
        g.Add("Button", "x270 y180 w110 h28 cWhite Background333344", "Skip").OnEvent("Click", (*) => WordGames.AnagNew())
        scoreLabel := g.Add("Text", "x50 y230 w400 h30 cGray Center", "Score: 0")
        scoreLabel.SetFont("s12 c4488FF", "Segoe UI")
        WordGames.anagScoreLabel := scoreLabel
    }

    static AnagNew() {
        idx := Random(1, WORDS.Length)
        WordGames.anagWord := WORDS[idx]
        chars := StrSplit(WordGames.anagWord)
        len := chars.Length
        Loop len - 1 {
            i := len - A_Index + 1
            r := Random(1, i)
            tmp := chars[i]
            chars[i] := chars[r]
            chars[r] := tmp
        }
        WordGames.anagScrambled := JoinChars(chars)
        if (WordGames.anagScrambled = WordGames.anagWord)
            WordGames.AnagNew()
        WordGames.anagScrambleLabel.Text := StrUpper(WordGames.anagScrambled)
        WordGames.anagInput.Value := ""
    }

    static AnagGuess(*) {
        guess := Trim(WordGames.anagInput.Value)
        if (guess = "")
            return
        if (StrLower(guess) = WordGames.anagWord) {
            WordGames.anagScore += StrLen(WordGames.anagWord)
            WordGames.anagScoreLabel.Text := "Score: " . WordGames.anagScore
            WordGames.AnagNew()
        } else {
            WordGames.anagInput.Value := ""
            WordGames.anagInput.BackColor := "3a1010"
            SetTimer((*) => (WordGames.anagInput.BackColor := "131320", WordGames.anagInput.Redraw()), -300)
        }
    }

    ; ===== HANGMAN =====
    static BuildHangman() {
        g := WordGames.gui
        WordGames.hangDisplay := g.Add("Edit", "x60 y40 w380 h40 Center ReadOnly Background1a1a2e cWhite Border", "")
        WordGames.hangDisplay.SetFont("s18 cWhite", "Consolas")
        WordGames.hangMsgLabel := g.Add("Text", "x60 y90 w380 h20 cGray Center", "")
        gallows := g.Add("Text", "x190 y120 w120 h120 cWhite Center", Chr(0x250C) Chr(0x2500) Chr(0x2500) Chr(0x2510) "`n" Chr(0x2502) "  O  " Chr(0x2502) "`n" Chr(0x2502) " /|\ " Chr(0x2502) "`n" Chr(0x2502) " / \ " Chr(0x2502) "`n" Chr(0x2514) Chr(0x2500) Chr(0x2500) Chr(0x2518))
        gallows.SetFont("s7 cWhite", "Consolas")
        WordGames.hangButtons := WordGames.MakeKeyboard(g, 60, 260, WordGames.HangmanGuess)
        g.Add("Button", "x60 y340 w120 h26 cWhite Background1a5a1a", "New Game").OnEvent("Click", (*) => WordGames.HangmanNew())
    }

    static HangmanNew() {
        idx := Random(1, WORDS.Length)
        WordGames.hangWord := WORDS[idx]
        WordGames.hangWrong := 0
        WordGames.hangGuesses := ""
        for btn in WordGames.hangButtons
            btn.Enabled := true
        WordGames.hangMsgLabel.Text := ""
        WordGames.HangmanRedraw()
    }

    static HangmanRedraw() {
        display := ""
        for ch in StrSplit(WordGames.hangWord) {
            if (InStr(WordGames.hangGuesses, ch))
                display .= StrUpper(ch) . " "
            else
                display .= "_ "
        }
        WordGames.hangDisplay.Value := Trim(display)
    }

    static HangmanGuess(btn) {
        key := btn
        if (InStr(WordGames.hangGuesses, key) || WordGames.hangWrong >= WordGames.hangMaxWrong)
            return
        for b in WordGames.hangButtons {
            if (b.Text = StrUpper(key))
                b.Enabled := false
        }
        WordGames.hangGuesses .= key
        if (!InStr(WordGames.hangWord, key)) {
            WordGames.hangWrong++
            WordGames.hangMsgLabel.Text := "Wrong! (" . WordGames.hangWrong . "/" . WordGames.hangMaxWrong . ")"
            if (WordGames.hangWrong >= WordGames.hangMaxWrong) {
                WordGames.hangMsgLabel.Text := "Lost! Word: " . StrUpper(WordGames.hangWord)
                for b in WordGames.hangButtons
                    b.Enabled := false
                return
            }
        }
        WordGames.HangmanRedraw()
        won := true
        for ch in StrSplit(WordGames.hangWord) {
            if (!InStr(WordGames.hangGuesses, ch)) {
                won := false
                break
            }
        }
        if (won) {
            WordGames.hangMsgLabel.Text := "You won! New Game to play again"
            for b in WordGames.hangButtons
                b.Enabled := false
        }
    }
}

JoinChars(arr) {
    s := ""
    for ch in arr
        s .= ch
    return s
}

WordGames.Init()
