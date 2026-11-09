# AI Safety with AutoHotkey - Critical Warnings

`autohotkey-mcp` can generate scriptlets from a sentence. That is
wonderful and exactly as dangerous as it sounds: natural language
is not a security boundary.

## Generated code is untrusted code

- Everything the AI writes lands in `scriptlets/ai_generated/`
  (sandboxed, never live). Promotion is a HUMAN decision after
  review, lint, and a standalone test run.
- No file is written at all if validation fails - but validation
  checks syntax and shape, NOT intent. A syntactically perfect
  script can still `FileDelete` your documents.
- Review checklist for every generated scriptlet:
  - [ ] I can explain what every `Run`, `Download`, `RegWrite`,
        `FileDelete`, and `DllCall` line does
  - [ ] No network calls I did not ask for
  - [ ] No credential or browser-profile paths touched
  - [ ] Hotkeys do not collide with existing ones (promote
        blocks on collisions - do not `force=True` blindly)
  - [ ] `just lint-ahk` is clean
  - [ ] Tested standalone before wiring into the dashboard

## Prompt injection is real

- Scriptlets that process untrusted text (clipboard managers,
  text expanders, chat-fed automations) must NEVER execute that
  text: no `Eval`-style dynamic runs, no building `Run` lines
  from it, no feeding it to privileged actions without parsing.
- Treat clipboard/web/chat content like web-form input: data,
  not instructions.

## Keep the human in the loop

- Never let an agent auto-promote, auto-run elevated, or
  auto-dismiss lint errors. `force=True` exists for scripts YOU
  have read, not for making warnings go away.
- Sampling (MCP `ctx.sample`) and local-LLM generation are
  conveniences, not reviewers. The reviewer is you.
- If a generated script surprises you, stop and re-read the
  prompt you gave - vague prompts breed vague, risky code.
