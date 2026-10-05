# video:hf-motion — Verification gates

Run from the scaffolded project directory, with `PLUGIN` bound by
`find-hf-plugin.sh` (SKILL.md Step 2). `HF` below is shorthand for
`node "$PLUGIN/skills/hyperframes/scripts/plugin-cli.mjs"`.

## 1. lint — 0 errors

```sh
HF lint .
```

Pass: `0 error(s)`. Accepted warnings for every recipe (single-file
composition by design; splitting into sub-compositions would change nothing
on screen):

- `nested_structure_needs_subcomposition` (one per scene clip)
- `composition_file_too_large`
- `timeline_track_too_dense`

Anything else is a failure.

## 2. check — passes

```sh
HF check .
```

Pass: the last line reads `Check passed`, Runtime 0 errors, Layout 0 errors /
0 warnings, Contrast all pass. Accepted `info` lines: `text_box_overflow` /
`container_overflow` on a `.mask` child while it slides in (the mask reveal
is the effect) and on the finale lines before their beat. A `content_overlap`,
`text_occluded` warning or a contrast failure is not accepted. `pixel-dissolve`
and `circle-pop` pass with Layout `0 issues`: their A/B overlap during the
change is marked in the template, never accepted ad hoc.

A runtime error `intro-kinetic: #sN lasts ...s but CONFIG implies ...s` (or
`pixel-dissolve: timing attributes disagree with CONFIG`) means
the timing attributes are stale: run `scaffold.mjs <recipe> <dir> --update`.

## 3. snapshot — look at every frame

```sh
HF snapshot . --at <times> --no-end --describe false
```

`intro-kinetic` at 120 BPM: `0.9,3.3,5.7,8.3,10.2,12.3,14.0` (one per scene,
inside its hold). For another tempo scale by `120 / bpm` and shift scenes 4-6
by the tool/flash count change. `pixel-dissolve`: `1.0`, `T`, `T+0.3D`,
`T+0.5D`, `T+0.8D`, `T+D`, `5.9` (`T = transitionAt`, `D = transitionDur`;
default `1,3,3.3,3.5,3.8,4,5.9`) — `T` must still be pure A, `T+D` pure B with
no accent cell left. `circle-pop`: `1.0`, `T`, `T+0.2`, `T+0.4`, `T+0.55`,
`T+0.7`, `T+0.9`, `5.9` (default `1,3,3.2,3.4,3.55,3.7,3.9,5.9`) — `T` pure A,
`T+0.2` the circle larger than at `T+0.4` (the overshoot), `T+0.9` pop colour
edge to edge with text B on it. Read every PNG in `snapshots/` and check:

- every string matches the confirmed parameters exactly;
- no tofu (empty boxes) — the bundled NanumSquare ac ExtraBold covers Hangul
  and Latin; a missing glyph means a character outside it;
- nothing clipped at the frame edge, no line wrapping that was not intended;
- only the three palette colours.

## 4. render

```sh
HF render . -q high -o ./renders/video.mp4
```

## 5. verify-render.py — all [OK]

```sh
python3 "$HFM/scripts/verify-render.py" renders/video.mp4 <verify-args>
```

`<verify-args>` is the scaffold's `verify-render args:` line verbatim. A
recipe without a music bed (`pixel-dissolve`, `circle-pop`) has no `--bpm` there: the
audio rows below print `[SKIP]` and only the video rows gate.

| Check | Expectation |
|-------|-------------|
| video stream | one `h264`, `--width`x`--height` (default `1920x1080`), `r_frame_rate=30/1` |
| audio stream | one `aac` |
| duration | `<total>` from the scaffold line, +-0.05 s |
| audio peak | -6 .. -0.1 dBFS (bed is normalised to -1 dBFS; SFX sit on top) |
| kick grid | median low-band (<150 Hz) onset ratio at beat times >= 10 and >= 5x the half-beat median |

The kick-grid thresholds were measured on the reference renders: on-beat
median 44.6 (120 BPM) / 49.5 (116 BPM) against half-beat 1.4 / 2.0, while a
wrong `--bpm` drops the on-beat median below 1. A FAIL there means the music
bed and the declared tempo disagree — regenerate with `--update`.

Manual equivalents, if the script cannot run:

```sh
ffprobe -v error -show_entries stream=codec_name,width,height,r_frame_rate -show_entries format=duration -of compact renders/video.mp4
ffmpeg -hide_banner -i renders/video.mp4 -af volumedetect -vn -f null - 2>&1 | grep max_volume
```
