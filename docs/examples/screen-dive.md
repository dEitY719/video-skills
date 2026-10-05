# screen-dive example

A drawn laptop shows "새로운 화면" on a darker brick-red screen; from 1.5 s the camera dives in over 3 s until the screen is the whole frame and the bezel is gone.

## Preview

[![screen-dive poster](media/screen-dive.png)](media/screen-dive.mp4)

[media/screen-dive.mp4](media/screen-dive.mp4): 1080x830, 30 fps, 6.0 s, 744 KB, no audio (the recipe has no music bed or SFX). Poster: the snapshot at 3.0 s (`T + 0.5D`, mid-dive, bezel still visible).

## Command

(a) Slash form:

```text
/video:hf-motion screen-dive 'screenText=새로운 화면' diveAt=1.5 diveDur=3 'red=#c0392b'
```

(b) Plain CLI (exactly what was run, with `./out` as the work dir):

```sh
HFM="$PWD/skills/hf-motion"
PLUGIN=$(bash "$HFM/scripts/find-hf-plugin.sh") || exit 1
node "$HFM/scripts/scaffold.mjs" screen-dive ./out 'screenText=새로운 화면' 'diveAt=1.5' 'diveDur=3' 'red=#c0392b'
# -> [OK] screen-dive scaffolded at ./out (6s, no music)
# -> verify-render args: --duration 6 --width 1080 --height 830
cd out
node "$PLUGIN/skills/hyperframes/scripts/plugin-cli.mjs" lint .
node "$PLUGIN/skills/hyperframes/scripts/plugin-cli.mjs" check .
node "$PLUGIN/skills/hyperframes/scripts/plugin-cli.mjs" snapshot . --at 1,1.5,2.25,3,3.75,4.5,5.9 --no-end --describe false
node "$PLUGIN/skills/hyperframes/scripts/plugin-cli.mjs" render . -q high -o ./renders/video.mp4
python3 "$HFM/scripts/verify-render.py" renders/video.mp4 --duration 6 --width 1080 --height 830
```

## Parameters used

| Key | Value | What it changes on screen | Limit |
|-----|-------|---------------------------|-------|
| `screenText` | `새로운 화면` | the screen's text: 85 px inside the laptop, 170 px at full screen | text, one line; shrinks to fit 920 px |
| `diveAt` | `1.5` | camera starts 0.5 s earlier than the default 2 | 1..4.5 |
| `diveDur` | `3` | slower dive than the default 2.5 | 0.5..4; `diveAt + diveDur <= 5.5` |
| `deviceStyle` | `laptop` (default) | the drawn device | `laptop` only |
| `red` | `#c0392b` | the screen colour (darker than the default `#e5322d`) | `#rrggbb`; paper text on it must pass contrast |
| `paper` / `charcoal` | defaults `#f2eee6` / `#1e1e1e` | background + screen text / laptop body | `#rrggbb` |

## Timeline for these params

`T = 1.5`, `D = 3`, total fixed at 6 s. Scaffold wrote `device 0 / 4.5`, `screen 0 / 6` (start / duration).

| Phase | Window (s) | What happens |
|-------|------------|--------------|
| entrance | 0.0-1.0 | lid + base rise in (y 40 -> 0, fade); text appears at 0.4 |
| hold | 1.0-1.5 | the whole laptop on paper |
| dive | 1.5-4.5 | one `power3.inOut` move of x/y/scale on both layers, identity -> scale 2 onto the glass |
| device leaves | 4.5 | `#device` window ends (already off-canvas) |
| full-screen hold | 4.5-6.0 | screen only, slow 4 % push, 1.5 s |

## What to expect when you verify

lint: `◇  0 error(s), 2 warning(s)`, both `nested_structure_needs_subcomposition` (`#device`, `#screen`), accepted.

check (as printed):

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

Snapshots (`Fonts: 1 loaded`):

| Time | Should show |
|------|-------------|
| 1.0 | the whole laptop, no edge clipped, `새로운 화면` paper on `#c0392b` |
| 1.5 (`T`) | same frame, camera not yet moving |
| 2.25 (`T+0.25D`) | laptop slightly larger (slow ease-in start) |
| 3.0 (`T+0.5D`) | laptop filling most of the frame, base cut at the bottom |
| 3.75 (`T+0.75D`) | screen almost full frame, a thin charcoal bezel band on the border |
| 4.5 (`T+D`) | screen colour on every border pixel (measured: all `#c0392b`), no bezel |
| 5.9 | same, text slightly larger from the push |

## Variations (scaffold-verified, not rendered)

Each printed `[OK] screen-dive scaffolded ... (6s, no music)` and passed `check` (Contrast all pass).

```sh
# mixed Latin/Hangul, long dive (the recipe's own alternate proof config)
node "$HFM/scripts/scaffold.mjs" screen-dive ./out-hello 'screenText=Hello 새로운 화면' 'diveAt=1.2' 'diveDur=3.5' 'red=#c0392b'
# late, short dive on a navy screen with a slate laptop
node "$HFM/scripts/scaffold.mjs" screen-dive ./out-navy 'screenText=지금 시작하기' 'diveAt=3.5' 'diveDur=2' 'charcoal=#2b2d42' 'red=#1d3557'
```

## Pitfalls

Each refusal exits 2 and writes nothing.

Dive leaves no full-screen hold (`diveAt=4 diveDur=2`):

```text
[hf-motion] invalid parameters:
  - diveAt + diveDur must leave a 0.5s full-screen hold (<= 5.5), got 6
```

Device not implemented (`deviceStyle=phone`):

```text
[hf-motion] invalid parameters:
  - deviceStyle must be one of laptop, got phone
```

Dive too short (`diveDur=0.3`):

```text
[hf-motion] invalid parameters:
  - diveDur must be 0.5..4, got 0.3
```

The screen text is always paper on `red`; a bright accent such as `#ff5a1f` is not refused by the scaffold but fails `check`'s contrast gate (2.69:1 per the recipe reference). Pick a darker accent, as this example does.
