# letter-flythrough example

The big Hangul word "오늘" stands on paper with the hole of "오" filled in blue; the camera flies into that hole until "새로운 시작", sitting inside it all along, fills the frame.

## Preview

[![letter-flythrough poster](media/letter-flythrough.png)](media/letter-flythrough.mp4)

[media/letter-flythrough.mp4](media/letter-flythrough.mp4): 1080x830, 30 fps, 6.0 s, 832 KB, no audio (the recipe has no music bed or SFX). Poster: the snapshot at 3.0 s (`T + 0.5D`), the camera halfway into the `ㅇ` of "오".

## Command

(a) Slash form:

```text
/video:hf-motion letter-flythrough letters=오늘 'nextText=새로운 시작' diveAt=1.5 diveDur=3 'red=#2b59c3'
```

(b) Plain CLI (exactly what was run, with `./out` as the work dir; run from the repo root):

```sh
HFM="$PWD/skills/hf-motion"
PLUGIN=$(bash "$HFM/scripts/find-hf-plugin.sh") || exit 1
node "$HFM/scripts/scaffold.mjs" letter-flythrough ./out 'letters=오늘' 'nextText=새로운 시작' 'diveAt=1.5' 'diveDur=3' 'red=#2b59c3'
# -> verify-render args: --duration 6 --width 1080 --height 830
cd out
node "$PLUGIN/skills/hyperframes/scripts/plugin-cli.mjs" lint .
node "$PLUGIN/skills/hyperframes/scripts/plugin-cli.mjs" check .
node "$PLUGIN/skills/hyperframes/scripts/plugin-cli.mjs" snapshot . --at 1,1.5,2.25,3,3.75,4.2,4.5,5.9 --no-end --describe false
node "$PLUGIN/skills/hyperframes/scripts/plugin-cli.mjs" render . -q high -o ./renders/video.mp4
python3 "$HFM/scripts/verify-render.py" renders/video.mp4 --duration 6 --width 1080 --height 830
```

The scaffold also generates `out/glyphs.js` (the outlines of "오늘" read from the bundled font, the hole of "오" and the landing rectangle). Never edit it by hand; change `letters` and re-run with `--update`.

## Parameters used

| Key | Value | What it changes on screen | Limit |
|-----|-------|---------------------------|-------|
| `letters` | `오늘` | the big outlined word (default `AI`) | 1..6 characters, all in the bundled font; fitted to 920x600 |
| `targetGlyphIndex` | `0` (default) | flies into "오", whose `ㅇ` is the counter | 0-based index; that glyph must have an enclosed hole |
| `nextText` | `새로운 시작` | the text inside the hole and on the final full-screen scene | one line, 150 px, shrinks to fit 920 px |
| `diveAt` | `1.5` | the camera starts 0.5 s earlier than the default | 1..4.5 |
| `diveDur` | `3` | a slower 3 s dive (default 2) | 0.5..4; `diveAt + diveDur <= 5.5` |
| `red` | `#2b59c3` | the hole and the final background: blue instead of red | `#rrggbb`; paper text on it must pass contrast |
| `paper` | `#f2eee6` (default) | background and the next-scene text | `#rrggbb` |
| `charcoal` | `#1e1e1e` (default) | the letters | `#rrggbb` |

## Timeline for these params

`T = 1.5`, `D = 3`, total fixed at 6 s. Scaffold wrote `data-duration="4.5"` on `#letters` (0 .. T + D) and `6` on `#next` and the root.

| Element | Window (s) | What happens |
|---------|------------|--------------|
| `letters` entrance | 0.0-1.0 | outlines rise in (y 40 -> 0) and fade in |
| hold | 1.0-1.5 | "오늘" still, the hole blue, the next text already in it (faint) |
| dive | 1.5-4.5 | the SVG viewBox zooms (`power2.inOut`) into the hole of "오"; the next text fades in over 1.5-3.0 |
| `letters` | ends 4.5 | the outlines leave the timeline; the hole fill becomes the background |
| full-screen hold | 4.5-6.0 | blue frame, "새로운 시작" in paper colour, slow 4 % push |

## What to expect when you verify

lint: `◇  0 error(s), 2 warning(s)`, both `nested_structure_needs_subcomposition` (`#letters`, `#next`), accepted by `references/verification.md`.

check (summary lines as printed):

```text
  0 error(s), 2 warning(s), 0 info(s)
Runtime   ◇ 0 errors, 0 warnings
Layout    ◇ 0 issues across 9 sample(s)
Motion    ◇ 0 errors, 0 warnings
Contrast  ◇ 4/4 text checks pass WCAG AA
◇  Check passed
```

verify-render:

```text
[OK]   video h264 1080x830 @ 30/1
[OK]   duration 6.000s (want 6.0s)
[SKIP] audio: no --bpm, recipe has no music bed
```

Extra check run on the render: the frame at 4.5 s has every border pixel within 4 (of 255) of `#2b59c3`, i.e. no ink left at the edge.

| Time | Should show |
|------|-------------|
| 1.0 | "오늘" whole, the `ㅇ` hole filled blue |
| 1.5 (`T`) | same, camera not moved yet |
| 2.25 (`T+0.25D`) | slight zoom; "새로운 시작" visible small and faint inside the hole |
| 3.0 (`T+0.5D`) | the `ㅇ` ring fills most of the frame, text in the hole readable (poster) |
| 3.75 (`T+0.75D`) | almost all blue; slivers of the charcoal ring at the corners |
| 4.2 (`T+0.9D`) | blue edge to edge, text near full size |
| 4.5 (`T+D`), 5.9 | blue on every border pixel, "새로운 시작" full size, no ink |

## Variations (scaffold-verified, not rendered)

Each was scaffolded into a throwaway dir and printed `[OK] letter-flythrough scaffolded ... (6s, no music)`.

```sh
# Latin word, fly into the first "O" (index 1), the contrast-safe red from the reference
node "$HFM/scripts/scaffold.mjs" letter-flythrough ./out-book 'letters=BOOK' 'targetGlyphIndex=1' 'nextText=다음 장' 'red=#c0392b'
# digits: fly into the "0" of 2026, with the longest allowed dive (1 + 4 = 5)
node "$HFM/scripts/scaffold.mjs" letter-flythrough ./out-2026 'letters=2026' 'targetGlyphIndex=1' 'nextText=새해 계획' 'diveAt=1' 'diveDur=4'
```

## Pitfalls

Each refusal exits 2 and writes nothing.

Target glyph with no hole (`letters=오늘 targetGlyphIndex=1`, i.e. "늘"):

```text
[hf-motion] invalid parameters:
  - letters: '늘' (targetGlyphIndex 1) has no counter to fly into; target a glyph with an enclosed hole (A B D O P Q R, a e o, 0 6 8 9, or Hangul with ㅇ ㅁ ㅂ ㅎ)
```

Too many letters (`letters=ABCDEFG`):

```text
[hf-motion] invalid parameters:
  - letters must be at most 6 characters (big letters), got 7
```

No room for the final hold (`diveAt=4 diveDur=2`):

```text
[hf-motion] invalid parameters:
  - diveAt + diveDur must leave a 0.5s full-screen hold (<= 5.5), got 6
```

Small holes zoom far: "오" here is a large `ㅇ`, so the push stays smooth; the recipe reference notes a six-syllable word can need 43x. Fewer letters give bigger holes.
