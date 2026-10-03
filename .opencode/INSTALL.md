# Installing video for OpenCode

## Prerequisites

- [OpenCode.ai](https://opencode.ai) installed
- Node.js 22+ with `npx`, `python3` with `numpy`, and `ffmpeg` / `ffprobe` on
  `PATH`. The scaffold is Node, the music bed is numpy, the render gate is
  ffprobe.
- The official HyperFrames plugin from the `heygen-com/hyperframes`
  marketplace. `hf-motion` drives its CLI through
  `skills/hyperframes/scripts/plugin-cli.mjs` and copies GSAP and two SFX from
  it, so it stops at the first step without it. Outside Claude Code, point
  `HF_PLUGIN_ROOT` at the directory holding that launcher.

## Installation

Add the plugin to the `plugin` array in your `opencode.json` (global or
project-level):

```json
{
  "plugin": ["video-skills@git+https://github.com/dEitY719/video-skills.git"]
}
```

Restart OpenCode. The plugin installs through OpenCode's plugin manager and
registers every skill under `./skills/`.

OpenCode uses its own plugin install. If you also use Claude Code, Codex, or
another harness, install this plugin separately for each one.

## Usage

Use OpenCode's native `skill` tool:

```
use skill tool to list skills
use skill tool to load hf-motion
```

OpenCode does not set `CLAUDE_PLUGIN_ROOT`. Export it to this plugin's install
directory before the skill runs its scripts; the skill's shell blocks guard the
variable and stop with a message rather than guess a path.

## Tool mapping

The authoritative OpenCode tool mapping for every `dEitY719/*-skills` repo lives
in the sibling repo `harness-skills`, at
[`references/opencode-tools.md`](https://github.com/dEitY719/harness-skills/blob/main/references/opencode-tools.md).
This repo owns no copy - one tool rename must stay one edit. Read it when a
skill names a tool you do not recognise. Short version:

- "Read a file" -> `read` (also how you look at snapshot PNGs)
- "Create a file" / "edit a file" -> `apply_patch`
- "Run a shell command" -> `bash` (scaffold, lint, check, snapshot, render)
- "Search file contents" / "find files by name" -> `grep`, `glob`
- "Create a todo" -> `todowrite`
- "Invoke a skill" -> OpenCode's native `skill` tool

One gap matters here: OpenCode has no structured question tool, and
`hf-motion` must confirm the parameters before it renders. Ask in the
conversation and wait for a real answer.

## Safety contracts

- Never render before the parameters are confirmed. All on-screen text comes
  from parameters; never invent names, numbers or claims.
- Call the HyperFrames CLI only through the plugin launcher, never a bare
  `npx hyperframes`, and never run `skills update`.
- A recipe listed as planned is not implemented; say so instead of
  improvising it.

## Troubleshooting

### Plugin not loading

1. Check logs: `opencode run --print-logs "hello" 2>&1 | grep -i video`
2. Verify the plugin line in your `opencode.json`
3. Make sure you are running a recent version of OpenCode

### `official HyperFrames plugin not found`

Install the official plugin, or export `HF_PLUGIN_ROOT` to the directory that
holds `skills/hyperframes/scripts/plugin-cli.mjs`.

## Getting Help

Report issues: https://github.com/dEitY719/video-skills/issues
