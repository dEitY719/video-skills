# video-skills — Contributor Guidelines

This file is the AI context document for this repo. `AGENTS.md` is a symlink to
it, so Claude Code, Codex, Gemini CLI, and every other harness read the same
text. Edit `CLAUDE.md`; never replace the symlink with a second copy.

## What this repo is

A single-plugin skill marketplace. The plugin is named `video` and it owns one
axis: **repeatable, parameterized motion graphics** built on HyperFrames. Same
skeleton, swap the content.

| Skill | Starts from | Role |
|-------|-------------|------|
| `hf-motion` | A recipe name + `key=value` params | Scaffold the recipe's template, fill its one `CONFIG` block, regenerate the beat-locked music bed (recipes that have one), then lint → check → snapshot → render → verify through the official hyperframes plugin. |

Recipes live under `skills/hf-motion/templates/<recipe>/` with their contract in
`skills/hf-motion/references/recipes/`. `intro-kinetic`, `pixel-dissolve`, `circle-pop`,
`screen-dive` and `text-sandwich` are implemented; the planned ones are listed there and marked as such. **Never add a recipe without
a template, a `recipe.mjs`, a parity proof and a selfcheck case** — a name in a
table is not a recipe.

## The official hyperframes plugin is a prerequisite, not a dependency we copy

`hf-motion` composes the official `hyperframes` plugin (`heygen-com/hyperframes`
marketplace). It does not restate engine rules — those belong to
`hyperframes:hyperframes-core` and `hyperframes:motion-graphics` — and it calls
the CLI only through that plugin's launcher,
`node <plugin>/skills/hyperframes/scripts/plugin-cli.mjs <cmd>`, located by
`skills/hf-motion/scripts/find-hf-plugin.sh`. Never a bare `npx hyperframes`,
never `skills update`.

**Third-party files are copied from that plugin at scaffold time, not
committed here**: GSAP (GreenSock standard license) and the two SFX (Pixabay
Content License) are both shipped by the official plugin, and
`templates/<recipe>/recipe.mjs` names where. The one bundled binary is the
font, `NanumSquare_acEB.ttf`, under SIL OFL 1.1 with `OFL.txt` beside it
(Debian `fonts-nanum-extra` copyright, NAVER). Do not bundle anything whose
licence you have not checked the same way. A user's own image (the
`text-sandwich` character) is never committed: the recipe's `userAssets`
names the `CONFIG` key, and the scaffold copies the file in or refuses.

## Template rules

- One strict-JSON `CONFIG` block per template, between `/* CONFIG:BEGIN */`
  and `/* CONFIG:END */`. The scaffold parses and rewrites it; comments inside
  break it.
- The timeline reads `CONFIG` and the scene windows (`data-start` /
  `data-duration` from the DOM), never literal text or times.
- Root `data-duration` and every `<audio>` timing are static attributes written
  by `scaffold.mjs` from `recipe.mjs`'s `timing()`. The engine reads them before
  scripts run (the producer parses `<audio data-start>` from HTML text), so a
  script cannot set them.
- The default `CONFIG` must reproduce the original verified render. A template
  change is proved by a pixel diff of `snapshot` frames against the original
  (all zero for `intro-kinetic` at 21 instants when it was added).

## Layout: root manifests, one flat `skills/`

Same as every `dEitY719/*-skills` repo — do **not** move manifests under a
`plugins/` directory; CI fails if one exists:

```
.claude-plugin/{marketplace,plugin}.json   Claude Code
.codex-plugin/plugin.json                  Codex
.kimi-plugin/plugin.json                   Kimi CLI
.hermes-plugin/{plugin.yaml,__init__.py}   Hermes Agent
.opencode/plugins/video.js                 OpenCode
.agents/plugins/marketplace.json           Antigravity
gemini-extension.json + GEMINI.md          Gemini CLI
skills/<name>/SKILL.md                     the skills themselves
```

The OpenCode entry point's filename is load-bearing: `.opencode/plugins/video.js`,
and `package.json`'s `main` points at it.

## Shared assets live elsewhere — link, never copy

Both belong to `dEitY719/harness-skills`: the per-harness tool mappings
(`references/*-tools.md`; link
`https://github.com/dEitY719/harness-skills/blob/main/references/<harness>-tools.md`,
the condensed Kimi summary in `.kimi-plugin/plugin.json` is the one sanctioned
mirror) and the reusable CI workflow (`validate.yml` calls `skill-check.yml`
with `plugin-name: video` and nothing else).

## Rules for changing skills

- `skills/<name>/` matches the bare `name:` in its frontmatter (no `:`); prose
  writes the namespaced form `/video:hf-motion`. Cross-repo skills keep their
  own namespace (`hyperframes:motion-graphics`).
- `SKILL.md` stays at or under 100 lines; detail goes to `references/`.
- Descriptions: at most 1,024 characters each, keep the "not this, that"
  sentence (freeform video → `hyperframes:*`, planned recipe → not here).
- Plugin-root convention
  ([`harness-skills` `references/plugin-root.md`](https://github.com/dEitY719/harness-skills/blob/main/references/plugin-root.md)):
  guard `CLAUDE_PLUGIN_ROOT` with `[ -n ]`, prove the file with `[ -f ]`, and
  never splice a defaulted expansion straight into a path — CI rejects it.
- Safety contract: no render before the user confirms the parameters, no
  invented facts, three palette colours, every cut on a beat. Full list:
  `skills/hf-motion/references/constraints.md`.
- `tests/*.sh` run in CI: `tests/selfchecks.sh` (scaffold + plugin finder,
  offline with a fake plugin) and `tests/manifests.sh`.

## Version bumps

The version appears in seven manifests: `.claude-plugin/marketplace.json`
(`plugins[0].version`), `.claude-plugin/plugin.json`, `.codex-plugin/plugin.json`,
`.kimi-plugin/plugin.json`, `.hermes-plugin/plugin.yaml`,
`gemini-extension.json`, and `package.json`. CI checks that they agree — bump
all of them together.

## No emojis

Anywhere in this repo. CI flags any codepoint at or above `U+1F000`, plus
`U+FE0F`.
