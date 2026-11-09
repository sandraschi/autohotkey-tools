# Security Best Practices - Safe AutoHotkey Usage

Rules that keep a helpful automation habit from becoming an
incident. Print-worthy short version: read everything, run as
little as possible, as yourself, never as admin, never blind.

## 1. Read before you run

- Read EVERY script before running it - including ones from this
  depot, including ones an AI wrote for you. `.ahk` is plaintext;
  there is no excuse for running blind.
- AI-generated scripts land in `scriptlets/ai_generated/` for a
  reason. Review, lint (`just lint-ahk`), test standalone, THEN
  promote with `scriptlet_ops(promote)`.
- Red flags in any script: `Download`, `URLDownloadToFile`,
  `Run` with a URL, registry writes outside HKCU, credential
  access, `FileDelete` on broad paths, obfuscated strings,
  Base64 blobs you cannot explain.

## 2. Least privilege, always

- Run scripts as your normal user. Elevate only the specific
  scriptlet that needs it, deliberately, per launch.
- Prefer per-user locations (HKCU, `%APPDATA%`) over machine-wide
  ones (HKLM, `C:\Program Files`, Task Scheduler as SYSTEM).
- A scriptlet that "needs admin" should be able to tell you WHY
  in its description. If it cannot, do not elevate it.

## 3. Write defensively

- Start scripts with `#Requires AutoHotkey v2.0+`,
  `#SingleInstance Force`, and an `OnError` handler that logs to
  a file instead of popping dialogs (see
  `lib/ScriptletErrorHandler.ahk`).
- Never build `Run` / command lines from untrusted text
  (clipboard, web, chat). Quote paths; validate inputs; treat
  automation input the way you would treat a web form.
- Keep an emergency brake: a global hotkey that suspends or kills
  your scriptlets, and keep the tray icon visible so you can see
  what is running.

## 4. Secrets do not belong in scripts

- No passwords, tokens, or API keys in `.ahk` files - not even
  "temporarily". Git never forgets.
- Compiled exes leak strings just as fast. Use environment
  variables or Credential Manager; pass secrets at runtime.

## 5. Keep the depot trustworthy

- Keep `autohotkey-tools` in git. Review diffs before pulling.
- Pin versions of shared `lib/` helpers; do not auto-update them
  from strangers.
- After any incident, rotate credentials that were typed or
  stored while the suspicious script was alive.
