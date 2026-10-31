# Scriptlet Bug Log

Living record of bugs actually found and fixed in `scriptlets/`, each with the
grep pattern used to audit the rest of the depot for the same defect.
New entry per fix. Read this before touching a scriptlet.

Format: symptom → root cause → fix → audit pattern.

---

## 1. Dead `#Include %A_ScriptDir%\lib\...` — 56 scriptlets dead at load
- **Symptom:** script exits immediately with `cannot be opened` (exit code 2).
  No window, no tray icon. The launcher "shows" them but they never start.
- **Root cause:** v1-style `%var%` in `#Include` plus `scriptlets/lib/` never
  vendored (only `ScriptletErrorHandler.ahk`, `GdipHelper.ahk`, `JSON.ahk`
  were ever referenced, none shipped).
- **Fix (2026-10-30):** recreated `scriptlets/lib/` with `ScriptletErrorHandler.ahk`
  (`ScriptletErrorHandler.Handle` class + global `LogError` wrapper) and
  `GdipHelper.ahk` (minimal GDI+ wrapper: Startup/Shutdown, solid brushes,
  `CreateBitmap`/`GraphicsFromImage`, Fill/Clear, `UpdatePicture` via BitBlt).
- **Audit:** `Select-String -Pattern '^#Include' scriptlets\*.ahk` then verify
  every target file exists.
- **Open:** `lib\JSON.ahk` still missing — `mcp_config_manager.ahk`,
  `mcp_troubleshooter.ahk` still die at load until it exists or the includes
  are removed.

## 2. Bare `gui.Add("Tab")` — tabs render empty
- **Symptom:** ScriptletLauncher showed the tab row and a black empty body.
- **Root cause:** v1 idiom. In v2 a bare `Add("Tab")` creates a *new empty*
  tab control stacked over the buttons. Tabs must be selected with
  `tabControl.UseTab(n)`, released with `UseTab(0)`.
- **Fix (2026-10-30):** `UseTab(1..4)` per section + `UseTab(0)` before the
  status bar in `ScriptletLauncher.ahk`.
- **Audit:** `\.Add\("Tab"\)` with no options — zero remaining hits after fix.

## 3. `MsgBox` argument order swapped
- **Symptom:** error dialogs show "Error" as the message with the real text
  as the title (or vice versa).
- **Root cause:** v1 `MsgBox, Title, Text` vs v2 `MsgBox(Text [, Title, Options])`.
- **Fix (2026-10-30):** `MsgBox("Script not found:`n" path, "Error", "0x10")`
  in `ScriptletLauncher.LaunchScript`.
- **Audit:** swept all `MsgBox("...", ...)` 3-arg calls fleet-wide
  (`macro_editor_pro`, `text_expander` flagged by heuristic, both verified
  correct v2 order on inspection) — ScriptletLauncher was the only instance.

## 4. `A_PID` is not a thing
- **Symptom:** `#Warn` crash at startup: "This local variable has not been
  assigned a value … A_PID" (system_monitor fallback path).
- **Root cause:** no such built-in in v1 or v2.
- **Fix (2026-10-30):** `DllCall("kernel32\GetCurrentProcessId", "UInt")`.
- **Audit:** grep `A_PID` — zero remaining hits after fix.

## 5. Case-insensitive duplicate Map keys
- **Symptom:** instant death at load: `Duplicate key` (`quick_launch.ahk`:
  `"^!d"` vs `"^!D"` in one `Map()`).
- **Root cause:** v2 Map keys compare case-insensitively by default.
  The intent was Ctrl+Alt+D vs Ctrl+Alt+Shift+D.
- **Fix (2026-10-30):** `"^!+d"` (explicit Shift) for the Downloads hotkey.
- **Audit:** no reliable grep — review any `Map(` literal with keys that
  differ only by case. Applies to hotkey strings especially.

## 6. v1 `AddText`/`AddButton`/`AddEdit`/… methods — silent dead GUIs
- **Symptom:** script stays resident (or exits) but no window ever appears;
  with the old global `OnError` swallowing it, zero diagnostics.
- **Root cause:** v2 removed the per-control `AddXXX` methods. `gui.AddText(...)`
  throws "unknown method". Must be `gui.Add("Text", ...)`.
- **Fix (2026-10-30):** mechanical `\.AddText\(` → `.Add("Text", ` etc. Done for
  games batch (`qbert_game`, `mini_games_collection`, `pacman_classic`,
  `PuzzleGame`, `chess_stockfish`; `word_games` needed only the length guard)
  plus batch 2 (`action_automation_builder_v2`, `ai_code_assistant`,
  `autohotkey_debug_helper`, `corporate_pranks`, `macro_editor_pro`,
  `macro_recorder_pro`, `mcp_config_manager`, `mcp_development_cycle`,
  `mcp_log_analyzer`, `mcp_server_scaffolding`, `mcp_troubleshooter`,
  `ollama_chatbot`) — all lint-clean, re-audit shows zero remaining hits.
  (`music_controller_pro`/`window_manager_pro` define their own custom
  `AddButton` helpers — excluded after verification.)
- **Audit:** `\.(AddText|AddButton|AddEdit|AddListView|AddPicture|AddGroupBox|AddTab|AddStatusBar|AddDropDownList|AddComboBox|AddCheckBox|AddUpDown|AddSlider|AddProgress|AddTreeView|AddDateTime|AddMonthCal|AddHotkey|AddLink)\(`.
  Special case: `AddStatusBar("Simple")` — v2 has no such option, drop the arg:
  `Add("StatusBar")`.

## 7. Anagram game unwinnable — missing `return` after recursive retry
- **Symptom:** `word_games` anagrams shows an UNSCRAMBLED word that can never
  be guessed (answer is a different word).
- **Root cause:** `if (scrambled = word) AnagNew()` without `return` — the
  recursive call picks a new word, then the outer frame overwrites the label
  with its own (unshuffled) word while `anagWord` stays the inner one.
- **Fix (2026-10-30):** `return WordGames.AnagNew()`.
- **Audit:** any recursive retry without `return` — eyeball only, no grep.

## 8. Hangman crash on letter click — BoundFunc arity
- **Symptom:** clicking any on-screen letter throws "too many parameters".
- **Root cause:** `callback.Bind(ch)` prepends the letter, then `OnEvent`
  appends `(ctrl, info)` → 3 args into a 1-param function.
- **Fix (2026-10-30):** `HangmanGuess(key, *)` variadic; on-screen keyboard
  removed entirely (physical typing via `SetupHotkeys` already existed).
- **Audit:** every `.Bind(` used as an `OnEvent` handler with a fixed-arity
  target — check arity covers (bound + event args).

## 9. `OnError(LogError)` with no `LogError` defined
- **Symptom:** the error handler itself is the crash (or the missing lib in
  #1 kills the script first).
- **Fix (2026-10-30):** lib shim provides global `LogError`; new scripts get
  an inline `_CatchBootError` that logs to a sibling `.log` file.
- **Audit:** `OnError\(` cross-checked against a same-file `LogError` def or
  the lib include. Resolved depot-wide by the lib restore.

## 10. Launcher web `fetch()` cached — stale script list
- **Symptom:** `launcher.html` shows yesterday's list despite live backend.
- **Root cause:** same-URL 10s polling with no cache directive; the browser
  serves its cache. `dashboard.html` already had `cache: 'no-store'`.
- **Fix (2026-10-30):** `cache: 'no-store'` on the `/scriptlets` + `/status`
  GETs in `launcher.html` (POSTs can't be heuristically cached).
- **Audit:** `fetch\(` without `cache:` in any fleet webapp polling loop.

## 11. Electron multi-process `WinExist` grabs a headless helper
- **Symptom:** scroll widget posted to a `opencode.exe` helper (crashpad/gpu)
  with no window — taps vanished silently.
- **Root cause:** `WinExist("ahk_exe …")` returns the first match, often a
  helper process.
- **Fix:** `FindVisibleWindow()` scans `WinGetList` and prefers a top-level
  window with a real title (ipad_scroll_widget, v1.3.3).
- **Audit:** any `WinExist("ahk_exe …")` targeting Electron/CEF apps
  (OpenCode, Discord, VS Code, Claude Desktop).

## 12. `Gui.BackColor` ignored on MenuBar/StatusBar windows
- **Symptom:** quick_notes stayed white in dark mode despite correct values
  (proven by isolated red-probe controls that worked).
- **Root cause:** on windows with MenuBar/StatusBar, the bare client area
  keeps the default face color (`F0F0F0`); `Edit.BackColor` works fine.
  (Established by same-window A/B probes, not by reading docs.)
- **Fix (2026-10-30):** full-bleed edit control (no bare client pixels left to
  paint); settings dialog left native (its labels are opaque-white Text).
- **Audit:** any dark-themed Gui with MenuBar/StatusBar relying on
  `Gui.BackColor` for the window background.

## 13. WORDS list hygiene (word_games)
- **Symptom:** "Invalid index" crash in the solver path.
- **Root cause:** 4 non-5-letter entries (`desk`, `glad`, `plunge`, `steady`)
  in an 819-word 5-letter list.
- **Fix (2026-10-30):** removed the 4 entries at source + length guard kept
  as belt-and-braces in the solver.
- **Audit:** validate word-list lengths wherever indexed access assumes them.

## 14. `OnEvent("Size", BoundMethod)` silently kills the script
- **Symptom:** script exits on launch with zero output, zero log, exit code 0.
  GUI never appears. The OnError handler logs nothing because *it* never fires
  either — the failure happens inside the bind validation.
- **Root cause:** passing a bound class method (`ClassName.Method`) directly as
  the `"Size"` event handler is rejected as "Invalid callback function"
  (verified in isolation: Close/Escape accept the same form, Size does not).
- **Fix (2026-10-30):** wrap in an arrow: `OnEvent("Size", (gui, minMax, w, h) => ClassName.OnResize(gui, minMax, w, h))`.
  Arrow is a plain Func so validation passes; verified it fires with live dims.
  Applied to: pacman, qbert, mini_games, PuzzleGame, chess, ollama,
  mcp_development_cycle, mcp_log_analyzer, mcp_server_scaffolding,
  mcp_troubleshooter, help_system_pro. (Plain functions and `ObjBindMethod`/
  pre-bound `.Bind()` forms left alone — unverified either way.)
- **Audit:** grep `OnEvent\("Size", [A-Za-z_]+(\.[A-Za-z_]+)?\s*\)` — any bare
  method reference (not wrapped, not pre-bound).

## 15b. Invalid OnEvent event names kill silently too
- **Symptom:** identical to #14 (instant silent exit, caught only via a
  Temp-copy bisect with a file-logging OnError).
- **Root cause:** `ListView.OnEvent("ItemActivate", ...)` — `ItemActivate`
  is not a valid ListView event name in this AHK build ("Parameter #1 of
  OnEvent is invalid"). Use `DoubleClick`.
- **Fix (2026-10-30):** help_system_pro Click stays, ItemActivate → DoubleClick.
- **Audit:** cross-check every `OnEvent("<Name>", ...)` against the control's
  documented event list; never assume an event name transfers from another
  control type or from v1 docs.

## 15. Local var shadows `static` class field — silent death
- **Symptom:** identical to #14 (instant silent exit, no log), but for a
  different reason: `static gui := ""` field plus a bare `gui := Gui(...)`
  local in a static method. No error is ever raised; the process just ends.
- **Root cause:** still not fully understood at the v2-spec level, but proven
  empirically three ways (minimal repro dies, rename revives, sibling scripts
  using `newGui` as the local name were never affected).
- **Fix (2026-10-30):** rename the local (`gui` → `newGui` in chess,
  matching the convention every other game script already used).
- **Audit:** inside each class, compare `static <name>` fields against bare
  `<name> :=` assignments in its static methods. Arrow-function *parameters*
  with the same name are fine (verified live).

## 16. `.Length` on a `Map` (use `.Count`)
- **Symptom:** instant silent exit; with the crash-net handler in place the log
  shows `This value of type "Map" has no property named "Length"`.
- **Root cause:** v2 `Map` has `.Count`, not `.Length` (arrays and strings have
  `.Length`). `MusicControllerPro.playlists` is a `Map` but `SeedPlaylists()`
  checked `.Length`.
- **Fix (2026-10-30):** `playlists.Count`. Verified alive after.
- **Audit 2026-10-30:** every scriptlet containing both `Map()` and `.Length`
  reviewed receiver-by-receiver (`StrSplit` results, `[]` literals, `A_Args`,
  array_typed params) — music_controller was the only real case. Review rule:
  `Map` + `.Length` never type-checks.
