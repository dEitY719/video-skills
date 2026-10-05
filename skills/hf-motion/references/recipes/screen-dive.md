# Recipe: screen-dive

A 6 s silent screen dive, 1080x830 @ 30 fps: a laptop drawn from plain CSS
shapes (lid, bezel, display, deck, hinge notch, camera dot) in the three
palette colours, then a camera push into the display until the on-screen
scene - one title line over a red bar - is the whole frame. No images, no
music, no SFX. Default `CONFIG` reproduces the original verified render frame
for frame.

## Parameters

Every key is a top-level `CONFIG` key; pass it as `key=value`.

| Key | Type | Default | Limit / note |
|-----|------|---------|--------------|
| `screenText` | text | `모션 그래픽` | the on-screen scene and the final full frame; **1..12 characters**, one line, 56 px on the laptop (about 143 px full frame), shrinks to fit 360 px |
| `caption` | text | empty | optional line under the laptop, gone as the dive starts; **0..30 characters**; empty = no caption |
| `duration` | number (s) | `6` | **3..10**; root and `s1` window |
| `diveStart` | number (s) | `1.5` | camera starts pushing; **>= 1.0** (the laptop intro) |
| `diveDur` | number (s) | `1.6` | length of the push, **0.8..3**; `diveStart + diveDur + 0.5 <= duration` |
| `paper` | `#rrggbb` | `#f2eee6` | background and display |
| `charcoal` | `#rrggbb` | `#1e1e1e` | laptop body and text; >= 4.5:1 against `paper` |
| `red` | `#rrggbb` | `#e5322d` | bar and camera dot; >= 3:1 against both others |

`recipe.mjs` refuses anything outside these limits, including the contrast
ratios, before writing a file.

## Timeline (seconds; `D` = `diveStart`, `V` = `diveDur`)

| At | What |
|----|------|
| 0.0-0.6 | laptop rises 40 px and fades in |
| 0.35-0.85 | title slides up inside its mask on the display |
| 0.5-0.9 | caption (if any) rises in under the laptop |
| 0.6-1.0 | red bar draws from the centre |
| D-D+0.3 | caption fades out |
| D-D+V | camera push, `power3.inOut`: scale to cover the frame (+2 % so no bezel edge survives) and translate the display centre to the frame centre |
| D+V-D+V+0.4 | title settles from 1.06 to 1 (the landing) |
| to `duration` | hold on the full-frame scene |

Default: dive 1.5-3.1 s, hold 2.9 s. The camera scale and translation are
measured from the display box at load, not hard-coded. The display keeps the
canvas aspect (432:332 = 1080:830) so it covers the frame exactly.

## Verification

Same gates as `verification.md`. Snapshot times for the default:
`0.6,1.2,2.0,2.5,3.1,5.9` (intro, on-screen scene, mid-dive x2, landing,
final hold); for another `diveStart` / `diveDur` / `duration` shift them the
same way. The final frame must show only the display content: no charcoal
bezel at any edge. `verify-render.py` does not apply (no audio stream, no
beat grid); check with `ffprobe` instead: one `h264`, `1080x830`,
`r_frame_rate=30/1`, duration `duration` +-0.05 s.

Accepted lint warning: `nested_structure_needs_subcomposition` on `s1` (one
file on purpose so one `CONFIG` drives everything).

## Known pitfalls (from the original build)

- **Text sharpness at full frame.** The camera tween uses `force3D: false`
  so it stays a 2D transform and the text is laid out at its scaled size
  rather than risking an upscaled 3D layer; the final snapshot is sharp.
- **Bezel at the frame edge.** The push overshoots the exact 2.5x cover by
  2 % so rounding can never leave a charcoal line at an edge; the rendered
  last frame's edge pixels are all paper.
- **Width fit is estimated**, not measured (per-glyph em widths, shrink only).
  The 12-character cap keeps the floor legible; a wide Latin string near the
  cap still needs a look at the snapshot.
- **The fade-in is a tween, not a fourth colour.** Mid-fade pixels blend
  charcoal into paper for 0.6 s; that is the only non-palette value on screen.
- **Root `data-duration` is static.** The scaffold writes it and the `s1`
  window from `duration`; the composition throws at load if they disagree.
