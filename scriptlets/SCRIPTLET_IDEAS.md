# Scriptlet ideas (suggestions)

Suggestions for new scriptlets that leverage AHK and feel surprising or high-leverage. Plus the **Prompt Snippets Bank** (done).

---

## Done

- **prompt_snippets_bank.ahk** — Bank of text snippets for IDE/AI: new MCP server, FastMCP 3.1 upgrade, PR template, commit message, Cursor rules, code review, refactor+test, PowerShell-only. Hotkey ^!p, ASCII table, copy to clipboard.

---

## Surprising / full-fat integrations

| Idea | What | Why surprising |
|------|------|----------------|
| **Local LLM launcher** | Hotkey opens small UI: select Ollama/LM Studio model, optional system prompt, then “Paste selection to chat” or “Send to Cursor”. Calls local API (e.g. Ollama) or just prepares a block of text for pasting. | AHK as glue between “selection in IDE” and “local model” without a full app. |
| **Voice-to-snippet** | Hold hotkey, speak a snippet name (or number), release: paste predefined text. Uses Windows Speech Recognition or a minimal recognizer. | Hands stay on keyboard; voice as index into your snippet bank. |
| **Regex playground** | Small window: pattern + test string; live match/highlight and list capture groups. Optional “copy as AHK RegEx” or “copy as Python re”. | AHK’s RegEx in a tiny, always-available scratchpad. |
| **Hex/Base64 scratch** | Paste text → show hex and base64; paste hex or base64 → decode to text. One hotkey, small ASCII panel. | Quick encoding/decoding without leaving the editor. |
| **Process sniper** | List top N by CPU or memory; hotkey to kill by name or PID. Compact table, no admin UAC. | “Something is slow” → see who and kill from one hotkey. |
| **Clipboard diff** | Store “previous” and “current” clipboard; hotkey shows a simple diff (line-by-line or character) in ASCII. | Compare two copies without opening a diff tool. |
| **Timer / pomodoro** | Minimal tray + hotkey: start 25/5/15, countdown in tray tooltip, optional sound or notification. Log sessions to a CSV. | AHK as a single, reliable timer. |
| **Window layout saver** | Save current positions/sizes of a set of windows (by title/class); hotkey to restore. One “save” and one “restore” hotkey. | Recreate a “working layout” in one key. |

---

## Games / fun (like chess + Stockfish)

| Idea | What | Why it fits |
|------|------|-------------|
| **Go / Weiqi** | 9x9 or 13x13 board, two-player; optional “hint” by calling a small engine (e.g. GnuGo) or fixed heuristics. | Same pattern as chess: AHK UI + external engine. |
| **Roguelike terminal** | Tiny ASCII dungeon: @ moves, bump to attack, simple items. One script, no assets. | Pure AHK, very compact, nostalgic. |
| **Typing drill** | Show random words/lines; measure WPM and accuracy; store high scores in a file. | Improves typing; AHK is good at key timing. |
| **Memory cards** | Flip cards (pairs): question/answer or term/definition. Load from a text file (e.g. `term\tdefinition` per line). | Study aid; file format is trivial. |

---

## Dev / IDE helpers

| Idea | What |
|------|------|
| **Branch name from ticket** | Hotkey: get ticket id from clipboard or selection (e.g. PROJ-123), paste branch name `feature/PROJ-123-short-desc` (user types short-desc). |
| **Env switcher** | Tray menu or hotkey: switch env vars (e.g. .env.prod / .env.dev) and optionally restart a watched process. |
| **Log tail** | Hotkey opens a small window tailing a log file (e.g. last 100 lines), auto-refresh; optional “copy last N lines”. |
| **Port killer** | “Kill process on port 10746” — resolve port to PID (e.g. netstat), then taskkill. One hotkey, one port (or a small list). |

---

## Format / data

| Idea | What |
|------|------|
| **JSON minify/beautify** | Selection or clipboard: if valid JSON, toggle minified vs pretty; paste back. |
| **Markdown table from CSV** | Paste CSV → convert to markdown table; copy result. |
| **UUID / nanoid** | Hotkey: generate UUID or nanoid-style id, paste at cursor or copy. |

---

## UI constraint

- **ASCII-only, compact, hotkey-driven** works well for “bank of prompts” and for many of the ideas above: table or list, one main action (copy, run, paste), escape to close.

---

## GitHub repos worth mining

AHK is niche and often dismissed as "weird," but there are still solid v2 repos with patterns we can reuse or adapt.

| Repo | Stars | What to leverage |
|------|-------|------------------|
| [iseahound/ImagePut](https://github.com/iseahound/ImagePut) | ~220 | **Images in AHK:** load/save/display, screenshot, pixel search, GDI/bitmap. Use for: screen-capture scriptlet, image-to-clipboard, simple OCR preprocess (crop then paste into OCR tool). |
| [kdalanon/LLM-AutoHotkey-Assistant](https://github.com/kdalanon/LLM-AutoHotkey-Assistant) | ~110 | **LLM in workflow:** hotkey to send selection/clipboard to OpenRouter (or swap to local Ollama). Custom prompts, multi-model. Direct fit for "Local LLM launcher" / "selection to AI" scriptlet. |
| [jNizM/ahk-scripts-v2](https://github.com/jNizM/ahk-scripts-v2) | ~140 | **Useful v2 snippets:** registry, files, strings, system. Mine for: port to PID, process list, window enumeration, clipboard helpers. |
| [Jvcon/AHK2Manager](https://github.com/Jvcon/AHK2Manager) | ~77 | **Control AHK from AHK:** list/kill/reload running AHK processes. Useful for "scriptlet manager" or "kill AHK on port" style tools. |
| [thqby/vscode-autohotkey2-lsp](https://github.com/thqby/vscode-autohotkey2-lsp) | ~290 | **AHK v2 LSP:** language server (TypeScript). Not a scriptlet; keeps v2 editing with good diagnostics. |
| [slyfox1186/script-repo](https://github.com/slyfox1186/script-repo) | ~130 | **Multi-language script dump:** AHK v1+v2, PowerShell, Python. Scan for: registry, JSON, Windows APIs from AHK. |
| [AutoHotkey-V2](https://github.com/AutoHotkey-V2) (org) | — | **log4ahk**, **DateParse**, **GdipC** (GDI+), **callstack.ahk**. Small libs for logging, dates, graphics, debug. |

**Takeaway:** ImagePut for any image/screen idea; LLM-AutoHotkey-Assistant for the "selection to AI" pattern; jNizM/slyfox for Windows/process/registry tricks. Ecosystem is small but not dead.
