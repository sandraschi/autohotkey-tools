# AutoHotkey Limitations - What It CAN'T Do

AutoHotkey is powerful, but it is not magic. Knowing the boundaries
keeps you from building on sand - and from being fooled by scripts
that pretend to do the impossible.

## No sandbox, no memory safety

- A script runs with YOUR user rights. It can read, write, delete,
  upload, and execute - anything you can do, it can do.
- There is no permission prompt, no sandbox, no "this script wants
  access to your files?" dialog. Running a script IS granting access.
- AHK has no memory-safe strings/buffers in the C sense to worry
  about, but DllCall with wrong types WILL crash or corrupt.

## Antivirus will flag your scripts

- Freshly compiled `.exe` scriptlets are unsigned and often packed.
  Windows Defender / SmartScreen flag these as untrusted.
- This is usually a false positive - but treat every flag as guilty
  until YOU have read the source and rebuilt it yourself.
- Never disable AV to run a script you did not write and read.

## UAC and elevation boundaries

- A script CANNOT click through or bypass a UAC consent prompt.
- A non-elevated script CANNOT drive windows owned by an elevated
  process (UIPI blocks it). If your automation "can't see" an admin
  window, that is Windows protecting you - run elevated deliberately
  or not at all.
- `Run *RunAs` triggers a real UAC prompt. That prompt is the OS
  asking YOU, not the script.

## Compiled scripts are NOT protected

- `Ahk2Exe` output can be unpacked; strings, hotkeys, URLs, and
  embedded "secrets" can be extracted in minutes.
- NEVER embed passwords, API keys, or tokens in a script, compiled
  or not. Use environment variables or the Windows Credential
  Manager instead.

## GUI automation is brittle

- Pixel/image search breaks on resolution, scaling, theme, and
  language changes. Control-based automation (window text, control
  IDs) is sturdier but still breaks when the target app updates.
- Timing flakiness (`Sleep` guessing) is the #1 cause of "works on
  my machine" automation. Wait on window/control state, not on
  fixed sleeps, wherever possible.

## Platform limits

- Windows only. No macOS, no Linux, no iOS, no Android.
- No kernel drivers, no bypassing OS security boundaries, no
  "undetectable" anything - if a script claims that, it is lying
  or malware.
- Games with anti-cheat WILL detect and ban automation. That is
  their system working as designed.
