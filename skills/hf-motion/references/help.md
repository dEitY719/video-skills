# video:hf-motion — Help

Render a parameterized HyperFrames motion graphic from a named recipe. Same
skeleton, swap the content: the recipe fixes the scenes, motion and beat grid;
the parameters supply every word, number and colour.

## Arguments

| # | Name | Default | Description |
|---|------|---------|-------------|
| 1 | `<recipe>` or `-h`/`--help`/`help` | — | Recipe name. Omitted: list recipes and ask. Implemented: `intro-kinetic` only (15 s kinetic-typography self-intro). Planned, not implemented (`pixel-dissolve` and others): see `references/recipes/README.md` |
| 2.. | `key=value` | recipe defaults | Overrides one top-level key of the recipe's `CONFIG` block. Numbers parse as numbers; lists split on `\|` (commas are legal inside an item); `[word]` inside a label or finale line marks the accent colour. Unknown keys are rejected. Per-recipe keys and limits: `references/recipes/<recipe>.md` |
| - | `--out <dir>` | `./<recipe>` | Project directory to create. Must not exist or be empty |

With no `key=value` at all, `intro-kinetic` reproduces the original verified
video (the original author's own values). Use that only for the author; for
anyone else every fact must come from them.

## Usage

- `/video:hf-motion` — list recipes (implemented and planned) and ask which one.
- `/video:hf-motion intro-kinetic name=홍길동 team=가나다팀 years=12` — fill
  three keys, keep the rest, confirm the full table, then scaffold → verify → render.
- `/video:hf-motion intro-kinetic 'tools=Notion Kit|Daily Log' 'flash=습관|기록|성장' 'finale=평범한 직장인이 알려주는|[돈과 시간]을 버는|[작은 습관] 하나' bpm=116`
  — variable counts; scene lengths and the total follow (29 beats at 116 BPM = 15.0 s).
- `/video:hf-motion intro-kinetic --out ~/videos/hong-intro subsTarget=123000` —
  custom project dir; the counter lands on `12만 3천`.
- `/video:hf-motion -h` — print this help.

## The scripts it runs

| Script | Does |
|--------|------|
| `scripts/find-hf-plugin.sh` | Prints the official hyperframes plugin root (the dir holding `skills/hyperframes/scripts/plugin-cli.mjs`); exit 1 with install instructions when absent |
| `scripts/scaffold.mjs <recipe> <dir> [k=v ...] [--update] [--no-music]` | Copies the template, rewrites `CONFIG`, writes the static timing attributes, copies GSAP + SFX from the hyperframes plugin, writes `package.json` / `meta.json`, generates the music bed. `--list` prints implemented recipes |
| `scripts/verify-render.py <mp4> --duration S --bpm N` | Post-render gate: h264 1920x1080 @ 30 fps + aac, duration, audio peak, kick grid |

## Environment

| Variable | Default | Effect |
|---|---|---|
| `HF_PLUGIN_ROOT` | unset | Explicit official-plugin root. When set and wrong, discovery fails rather than falling through |
| `CLAUDE_CONFIG_DIR` | unset | Searched first: `$CLAUDE_CONFIG_DIR/plugins/cache/hyperframes/hyperframes/<newest>` |
| `CLAUDE_PLUGIN_ROOT` | set by Claude Code | This plugin's root. Other harnesses: export it (see SKILL.md Prologue) |

Tools needed on `PATH`: `node` 22+ (with `npx`), `python3` + `numpy`, `ffmpeg`,
`ffprobe`. The first CLI call downloads the pinned `hyperframes` package via
`npx`, so network access is required once per version.

## What this skill will NOT do

- Render before you confirm the parameter table.
- Invent a name, number, employer or claim. Missing facts are asked for.
- Run a planned recipe, or bend `intro-kinetic` into one.
- Call `npx hyperframes` directly or run `skills update` — the official plugin
  launcher pins the CLI to the installed plugin version.
