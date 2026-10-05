# Recipe: pixel-dissolve

A silent 6 s two-word transition, 1080x830 @ 30 fps: the `from` word on
paper, a grid of accent cells flips on over it in seeded random order, the cut
happens under the full cover at `switchAt`, then the cells flip off in a
second order to reveal the `to` word on charcoal with an accent rule beneath.
Paper / charcoal / one accent colour, one Korean display face (NanumSquare ac
ExtraBold). Default `CONFIG` reproduces the verified hand-built render
frame for frame (pixel diff 0 at 16 instants).

## Parameters

Every key is a top-level `CONFIG` key; pass it as `key=value`.

| Key | Type | Default | Limit / note |
|-----|------|---------|--------------|
| `from` | text | `어제의 나` | scene A, 190 px charcoal on paper; shrinks to fit 920 px |
| `to` | text | `오늘의 나` | scene B, 190 px paper on charcoal; shrinks to fit 920 px |
| `duration` | number (s) | `6` | **3..10**; root `data-duration` |
| `switchAt` | number (s) | `3` | dissolve midpoint = the cut; **1..duration-1** |
| `cols` | integer | `24` | **4..60** grid columns (cells are 1080 / cols px wide) |
| `rows` | integer | `18` | **4..60** grid rows (cells are 830 / rows px tall) |
| `paper` | `#rrggbb` | `#f2eee6` | light; must keep 4.5:1 against `charcoal` |
| `charcoal` | `#rrggbb` | `#1e1e1e` | dark |
| `red` | `#rrggbb` | `#e5322d` | accent (cells + rule); must keep 3:1 on both others |

The scaffold refuses a palette that misses either contrast floor, before it
writes anything.

## Timeline (seconds; `S = switchAt`, `D = duration`, `H = 0.6`)

| Clip | Window | What happens |
|------|--------|--------------|
| `sA` | 0 .. S | `from` word settles from 1.08x to 1x over 0.8 s |
| `dz` | S-H .. S+H | phase 1: every cell switches on at its own seeded time in S-H .. S-1 frame; phase 2: every cell switches off in S+1 frame .. S+H-1 frame |
| `sB` | S .. D | `to` word settles 1.06x -> 1x over 0.8 s; accent rule grows at S+H+0.1 (0.3 s) |

The frame on the cut (S) is a solid accent frame. Cell order comes from a
mulberry32 PRNG with a fixed seed, so every seek, snapshot and render shows
the same cells. No `Math.random`, no music, no SFX: the MP4 has no audio
stream.

Verification snapshot times (default): `0,1.5,2.6,2.8,3.0,3.2,3.45,4.2,5.9`.
For other values use `0`, `S-0.4`, `S-0.2`, `S`, `S+0.2`, `S+0.45`, `S+1.2`,
`D-0.1`.

## Adapting

- Text, length, switch point, grid density and palette are parameters; the
  scaffold rewrites the `sA` / `sB` / `dz` windows and the root length.
- The dissolve length (`H`, 0.6 s each side) and the seed are part of the
  skeleton (`recipe.mjs` `HALF` and `index.html`); changing them is a template
  change in this repo, and the default parity proof must be redone.
- Never hand-edit `data-start` / `data-duration`: the composition throws at
  load when they disagree with `CONFIG`; run `scaffold.mjs --update`.

## Known pitfalls (from the original build)

- **Seams between cells.** Fractional cell sizes (830 / 18) antialias into
  hairlines that let scene A show through the full cover. Cell edges are
  rounded to whole pixels from the grid lines, so neighbours share an edge.
- **Lint warnings accepted:** `nested_structure_needs_subcomposition` on `sA`
  and `sB` (single file on purpose, one `CONFIG`).
- **Check info accepted:** `text_occluded #sB-word inside #dz` at the cut;
  covering the text is the effect. Any warning or contrast failure is not.
- **No audio.** `verify-render.py` expects one `aac` stream and a beat grid,
  so it does not apply here; check with `ffprobe` instead: one `h264`,
  `1080x830`, `30/1`, duration `D` +-0.05 s, 30 x `D` frames.
- **Width fit is estimated** (same per-glyph table as `intro-kinetic`) and
  only shrinks; long `to` text still needs a look at the snapshot.
