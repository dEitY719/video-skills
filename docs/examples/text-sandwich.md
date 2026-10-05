# text-sandwich example

The Korean word "점심 메뉴" rises in over a green base line, then a cartoon character walks right-to-left *between* its letters (in front of 점 and 메, behind 심 and 뉴).

## Preview

[![text-sandwich poster](media/text-sandwich.png)](media/text-sandwich.mp4)

[media/text-sandwich.mp4](media/text-sandwich.mp4): 1080x830, 30 fps, 6.0 s, 424 KB, no audio (the recipe has no music bed or SFX). Poster: the snapshot at 2.7 s (`T + 0.5D`).

## Command

The character is [`assets/character.png`](assets/character.png), a 400x600 transparent PNG (4 KB) drawn for this example with Python PIL. Substitute your own image: the scaffold copies it into the project as `assets/character.png`; it is never committed to the recipe. The path is relative to the directory you run the scaffold from, so run these from the repo root.

(a) Slash form:

```text
/video:hf-motion text-sandwich 'word=점심 메뉴' characterImage=docs/examples/assets/character.png direction=rtl passAt=1.2 passDur=3 'charcoal=#22303c' 'red=#1f7a5c'
```

(b) Plain CLI (exactly what was run, with `./out` as the work dir):

```sh
HFM="$PWD/skills/hf-motion"
PLUGIN=$(bash "$HFM/scripts/find-hf-plugin.sh") || exit 1
node "$HFM/scripts/scaffold.mjs" text-sandwich ./out 'word=점심 메뉴' 'characterImage=docs/examples/assets/character.png' 'direction=rtl' 'passAt=1.2' 'passDur=3' 'charcoal=#22303c' 'red=#1f7a5c'
# -> verify-render args: --duration 6 --width 1080 --height 830
cd out
node "$PLUGIN/skills/hyperframes/scripts/plugin-cli.mjs" lint .
node "$PLUGIN/skills/hyperframes/scripts/plugin-cli.mjs" check .
node "$PLUGIN/skills/hyperframes/scripts/plugin-cli.mjs" snapshot . --at 1,1.2,1.95,2.7,3.45,4.2,5.9 --no-end --describe false
node "$PLUGIN/skills/hyperframes/scripts/plugin-cli.mjs" render . -q high -o ./renders/video.mp4
python3 "$HFM/scripts/verify-render.py" renders/video.mp4 --duration 6 --width 1080 --height 830
```

## Parameters used

| Key | Value | What it changes on screen | Limit |
|-----|-------|---------------------------|-------|
| `word` | `점심 메뉴` | the big word (4 syllables + space; the space is skipped when counting front letters) | 1..12 characters, one line; shrinks to fit 960 px |
| `characterImage` | `docs/examples/assets/character.png` | the figure that crosses; contain-fit into a 420x620 box | `.png`/`.webp`/`.jpg`/`.gif`, readable; SVG refused |
| `direction` | `rtl` | the character enters from the right edge and exits left | `ltr` / `rtl` |
| `passAt` | `1.2` | the crossing starts 0.3 s earlier than the default | 1..4.5 |
| `passDur` | `3` | a slower crossing (default 2.5) | 0.5..4; `passAt + passDur <= 5.5` |
| `charcoal` | `#22303c` | the word: a blue-tinted charcoal | `#rrggbb`; front letters must pass contrast over the image |
| `red` | `#1f7a5c` | the base line: green instead of red | `#rrggbb` |
| `paper` | `#f2eee6` (default) | background | `#rrggbb` |

## Timeline for these params

`T = 1.2`, `D = 3`, total fixed at 6 s. Scaffold wrote `data-start="1.2" data-duration="3"` on `#character`, `0 / 6` on `#back` and `#front`.

| Element | Window (s) | What happens |
|---------|------------|--------------|
| `back` | 0.0-6.0 | letters rise in (0.06 s stagger from 0.1 s), base line draws from 0.3 s; slow 3 % push from 4.2 s |
| `character` | 1.2-4.2 | image box moves linearly from fully off the right edge to fully off the left |
| `front` | 0.0-6.0 | same word, same tweens; only letters 2 and 4 (심, 뉴) visible, so they sit in front of the character |
| hold | 4.2-6.0 | word alone with the push (1.8 s) |

## What to expect when you verify

lint: `◇  0 error(s), 3 warning(s)`, all three `nested_structure_needs_subcomposition` (`#back`, `#character`, `#front`), which `references/verification.md` accepts.

check (summary lines as printed):

```text
  0 error(s), 3 warning(s), 0 info(s)
Runtime   ◇ 0 errors, 0 warnings
Layout    ◇ 0 issues across 9 sample(s)
Motion    ◇ 0 errors, 0 warnings
Contrast  ◇ 9/9 text checks pass WCAG AA
◇  Check passed
```

verify-render:

```text
[OK]   video h264 1080x830 @ 30/1
[OK]   duration 6.000s (want 6.0s)
[SKIP] audio: no --bpm, recipe has no music bed
```

Snapshots (`snapshot` reported `Fonts: 1 loaded`):

| Time | Should show |
|------|-------------|
| 1.0 | the whole word risen in, green line drawn, no character |
| 1.2 (`T`) | same; the character is just off the right edge |
| 1.95 (`T+0.25D`) | character entering from the right over 뉴, with 뉴 drawn in front of its body |
| 2.7 (`T+0.5D`) | the sandwich: 심 drawn over the character's arm, 메 hidden behind its body |
| 3.45 (`T+0.75D`) | character covering 점, 심 still in front at its right |
| 4.2 (`T+D`) | no character left, word whole |
| 5.9 | no character, word slightly larger (push) |

## Variations (scaffold-verified, not rendered)

Each was scaffolded into a throwaway dir and printed `[OK] text-sandwich scaffolded ... (6s, no music)`.

```sh
# Latin word, left-to-right, short late pass
node "$HFM/scripts/scaffold.mjs" text-sandwich ./out-hello 'word=HELLO' 'characterImage=docs/examples/assets/character.png' 'direction=ltr' 'passAt=2' 'passDur=2'
# longest allowed crossing (1.5 + 4 = 5.5) on a warmer paper
node "$HFM/scripts/scaffold.mjs" text-sandwich ./out-weekend 'word=주말 계획' 'characterImage=docs/examples/assets/character.png' 'passAt=1.5' 'passDur=4' 'paper=#fff8e7'
```

## Pitfalls

Each refusal exits 2 and writes nothing.

Pass too long (`passAt=3 passDur=3`):

```text
[hf-motion] invalid parameters:
  - passAt + passDur must leave a 0.5s hold (<= 5.5), got 6
```

Image path that does not exist (`characterImage=docs/examples/assets/missing.png`):

```text
[hf-motion] characterImage: cannot read '<repo>/docs/examples/assets/missing.png'. Pass characterImage=<path to your image>; it is copied to assets/character.png (nothing is bundled). Nothing was written.
```

Word over 12 characters (`word=오늘의 점심 메뉴는 국밥`, spaces count):

```text
[hf-motion] invalid parameters:
  - word must be 1..12 characters, got 13
```

Not a scaffold refusal but a `check` gate: a dark character makes the charcoal front letters fail contrast. This example uses light fills (pale blue, peach, lavender) on purpose; with a dark image pick a lighter image or a darker `charcoal`.
