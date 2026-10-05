# video — skill index

One skill for one job: turning a named recipe plus parameters into a rendered
HyperFrames motion graphic. It lives in this extension's `skills/` directory
and is explicitly invoked, never ambient: read its `SKILL.md` when the user
asks for a recipe video, then follow it.

| Skill | Read | Use when |
|-------|------|----------|
| `hf-motion` | `@./skills/hf-motion/SKILL.md` | The user wants a video from a named recipe (today: `intro-kinetic`, a 15 s kinetic-typography self-intro; `pixel-dissolve` and `circle-pop`, 6 s scene changes; `screen-dive`, a 6 s dive into a laptop screen) with their own text, counts, palette or tempo. Scaffolds, verifies and renders through the official hyperframes plugin. |

A one-off or freeform video is not this skill — that is the official
hyperframes plugin's `motion-graphics` / `general-video`. A planned recipe
(text-sandwich, letter-flythrough) is not implemented: say so and stop.

The skill's `references/` directory holds the detail it loads on demand.
`SKILL.md` says which file to read and when — do not read `references/` up
front.

## What it needs

- The official HyperFrames plugin (`heygen-com/hyperframes`). Outside Claude
  Code, export `HF_PLUGIN_ROOT` to the directory holding
  `skills/hyperframes/scripts/plugin-cli.mjs`; read that plugin's
  `skills/hyperframes-core/SKILL.md` and `skills/motion-graphics/SKILL.md` as
  files, since Gemini CLI has no skill-invocation tool.
- `CLAUDE_PLUGIN_ROOT` exported to this extension's directory — the skill's
  shell blocks guard it and stop rather than guess.
- `node` 22+, `python3` with `numpy`, `ffmpeg`, `ffprobe`.

## Tool mapping for Gemini CLI

- "Read a file" -> `read_file` (also how you look at snapshot PNGs)
- "Create a file" / "edit a file" -> `write_file`, `replace`
- "Run a shell command" -> `run_shell_command` (scaffold, lint, check,
  snapshot, render, verify)
- "Search file contents" -> `grep_search`; "Find files by name" -> `glob`
- "Ask the user" -> `ask_user`

The full mapping, including every capability gap, lives in the sibling repo:
`https://github.com/dEitY719/harness-skills/blob/main/references/gemini-tools.md`.
On Antigravity read `antigravity-tools.md` there instead — `agy` has no
`ask_user`, so confirm the parameters in the conversation.

## Safety rules

- **Never render before the user confirms the parameter table.**
- Never invent a name, number or claim; every on-screen string comes from a
  parameter.
- Exactly three palette colours; every cut on a beat.
- Call the HyperFrames CLI only through the plugin launcher — no bare
  `npx hyperframes`, no `skills update`.
