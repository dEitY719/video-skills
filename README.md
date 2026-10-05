# video-skills

Repeatable, parameterized motion graphics on
[HyperFrames](https://hyperframes.heygen.com). A single-plugin marketplace: the
plugin is `video`, and its one skill, `hf-motion`, turns a named **recipe** plus
`key=value` parameters into a verified MP4. Same skeleton, swap the content.

## Skills

| Skill | Invoke | What it does |
|-------|--------|--------------|
| `hf-motion` | `/video:hf-motion <recipe> [key=value ...] [--out <dir>]` | Scaffold the recipe's template, fill its `CONFIG` block from the parameters, regenerate the beat-locked music bed, then lint → check → snapshot → (after you confirm) render → verify. |

### Recipes

| Recipe | Status | Result |
|--------|--------|--------|
| `intro-kinetic` | implemented | 15 s kinetic-typography self-introduction, 1920x1080 @ 30 fps, 120 BPM: name slam, count-ups, tools, beat flashes, finale |
| `pixel-dissolve` | implemented | 6 s 1080x830 word swap: text A dissolves cell by cell (seeded order) into text B; no music |
| `circle-pop` | implemented | 6 s 1080x830 scene change: a circle pops, overshoots, fills the frame and becomes scene B; no music |
| `screen-dive` | implemented | 6 s 1080x830 camera dive into a CSS-drawn laptop's screen until the screen text is full-frame; no music |
| `text-sandwich`, `letter-flythrough` | planned — not implemented | — |

Parameters, limits and timelines: one file per recipe under
[`skills/hf-motion/references/recipes/`](skills/hf-motion/references/recipes/).

```
/video:hf-motion intro-kinetic name=홍길동 team=가나다팀 years=12 subsTarget=123000 \
  'tools=Notion Kit|Daily Log' 'flash=습관|기록|성장' bpm=116 \
  'finale=평범한 직장인이 알려주는|[돈과 시간]을 버는|[작은 습관] 하나'
```

With no parameters, `intro-kinetic` reproduces the original verified video
frame for frame (its defaults are the original author's own values).

## Requirements

| Need | Why |
|------|-----|
| The official **hyperframes** plugin (`heygen-com/hyperframes` marketplace) | Every CLI call goes through its launcher `skills/hyperframes/scripts/plugin-cli.mjs`; GSAP and the SFX are copied from it at scaffold time. Missing → the skill stops at step 2 with install instructions. |
| `node` 22+ with `npx` | Scaffold script; the launcher fetches the pinned `hyperframes` CLI once. |
| `python3` + `numpy`, `ffmpeg`, `ffprobe` | Music bed synthesis and the post-render gate. |

## Install

### Claude Code

```
/plugin marketplace add heygen-com/hyperframes
/plugin install hyperframes@hyperframes
/plugin marketplace add dEitY719/video-skills
/plugin install video@video-skills
```

### Codex

```
codex plugin install dEitY719/video-skills
```

### Kimi CLI

```
kimi plugin install dEitY719/video-skills
```

### Hermes Agent

```
hermes plugins install dEitY719/video-skills
```

### OpenCode

See [`.opencode/INSTALL.md`](.opencode/INSTALL.md).

### Gemini CLI / Antigravity

```
gemini extensions install https://github.com/dEitY719/video-skills
```

Antigravity (`agy`) shares `~/.gemini`, so it inherits the install.

On every harness but Claude Code, export `CLAUDE_PLUGIN_ROOT` to this plugin's
install directory and `HF_PLUGIN_ROOT` to the official hyperframes plugin's.

## Harness support

Every step is a shell command (Node scaffold, Python synth, the hyperframes
CLI) plus reading PNG snapshots, so the work ports cleanly. What differs is
loading the engine-rule skills the recipe delegates to and asking the user to
confirm. Per-harness tool names and gaps:
[`harness-skills/references/`](https://github.com/dEitY719/harness-skills/tree/main/references).

| Skill | Claude Code | Codex | Kimi | Gemini / Antigravity | Hermes | OpenCode |
|-------|:-----------:|:-----:|:----:|:--------------------:|:------:|:--------:|
| `hf-motion` | full | read engine skills as files, confirm in chat | full (`AskUserQuestion`) | read engine skills as files (Antigravity: confirm in chat) | confirm in chat | confirm in chat |

## Safety contract

- No render before you confirm the parameter table.
- No invented facts: every on-screen string and number comes from a parameter.
- Exactly three palette colours; every cut on a beat.
- The CLI only through the official plugin launcher; never a bare
  `npx hyperframes`, never `skills update`.

Full list: [`skills/hf-motion/references/constraints.md`](skills/hf-motion/references/constraints.md).

## Licensing of bundled and copied assets

- `NanumSquare_acEB.ttf` — SIL Open Font License 1.1 (NAVER Corporation);
  licence text in `skills/hf-motion/templates/intro-kinetic/assets/fonts/OFL.txt`.
- GSAP and the two SFX are **not** in this repo: the scaffold copies them from
  the installed official hyperframes plugin (GSAP standard license; Pixabay
  Content License).
- Everything else: MIT.

## Layout

```
video-skills/
├── skills/hf-motion/
│   ├── SKILL.md + references/ (help, constraints, verification, recipes/)
│   ├── scripts/   scaffold.mjs · find-hf-plugin.sh · verify-render.py · *.selfcheck.sh
│   ├── templates/intro-kinetic/   index.html (CONFIG) · recipe.mjs · scripts/make_music.py · assets/fonts/
│   └── evals/trigger-eval.json
├── .claude-plugin/{marketplace,plugin}.json   Claude Code
├── .codex-plugin/plugin.json                  Codex
├── .kimi-plugin/plugin.json                   Kimi CLI
├── .hermes-plugin/{plugin.yaml,__init__.py}   Hermes Agent
├── .opencode/plugins/video.js + INSTALL.md    OpenCode
├── .agents/plugins/marketplace.json           Antigravity
├── gemini-extension.json + GEMINI.md          Gemini CLI
├── package.json · CLAUDE.md + AGENTS.md -> CLAUDE.md · README.md · LICENSE
├── tests/   selfchecks.sh · manifests.sh
└── .github/workflows/   validate.yml · board-sync.yml
```

## CI

`.github/workflows/validate.yml` calls the reusable `skill-check` workflow in
[`harness-skills`](https://github.com/dEitY719/harness-skills) with
`plugin-name: video`: manifest parsing, version and name agreement, frontmatter
name = directory, `SKILL.md` <= 100 lines, description budget, shellcheck, no
emoji, no caller-controlled path defaults, and every `tests/*.sh`.

## License

MIT. See [`LICENSE`](LICENSE).
