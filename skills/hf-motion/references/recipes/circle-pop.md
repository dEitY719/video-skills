# Recipe: circle-pop

A short two-word circle-pop transition, 1080x830 @ 30 fps, silent. Scene 1
shows `from` on paper. A red dot pops in the centre, then grows to fill the
frame exactly on the cut. Scene 2 opens on red, and a charcoal circle pops out
of the centre with `to` inside it. Paper / charcoal / one accent colour, one
Korean display face (NanumSquare ac ExtraBold). The default `CONFIG` is the
original hand-built values and reproduces its frames pixel for pixel (21
instants, max diff 0).

## Parameters

Every key is a top-level `CONFIG` key. Pass it as `key=value`.

| Key | Type | Default | Limit / note |
|-----|------|---------|--------------|
| `from` | text | `아이디어` | scene 1 word, 170 px; shrinks to fit 920 px |
| `to` | text | `완성된 영상` | scene 2 word, 170 px; shrinks to fit 920 px |
| `duration` | number (s) | `6` | **3..10** |
| `switchAt` | number (s) | `3` | the cut; **1..duration-1** (each scene >= 1 s) |
| `paper` | `#rrggbb` | `#f2eee6` | scene 1 background, scene 2 text |
| `charcoal` | `#rrggbb` | `#1e1e1e` | scene 1 text, scene 2 circle |
| `red` | `#rrggbb` | `#e5322d` | dot, underline bars, scene 2 base; the scaffold refuses it below 3:1 contrast on `paper` or `charcoal` |

## Timeline (`S = switchAt`, `D = duration`)

| Clip | Window | What happens |
|------|--------|--------------|
| `s1` | 0 .. S | 0 `from` pops in (scale 0.6->1, `back.out(2)`, 0.5 s) · 0.3 red bar draws (0.4 s) · S-0.55 red dot pops (scale 0->1, `back.out(3)`, 0.3 s) · S-0.25 dot grows x12 to cover the frame (`power3.in`), full red at S |
| `s2` | S .. D | S charcoal circle opens (clip-path radius 0->720 px, `back.out(1.6)`, 0.6 s) with `to` scaling 0.5->1 inside it · S+0.35 red bar draws · hold to D |

The cut lands on `switchAt`, and the red cover ends on it. Tween lengths and
offsets are fixed in seconds. They are part of the skeleton, not parameters.
There is no music bed and no SFX (`recipe.mjs` exports no `musicArgs`), so the
render has no audio stream.

## Verification

- Accepted lint warnings: `nested_structure_needs_subcomposition` on `s1`
  and `s2` (one-file template on purpose). Anything else is a failure.
- `check`: Layout 0 issues, Contrast 4/4 pass.
- Snapshot times: `0.5, S-0.45, S-0.05, S+0.05, S+0.15, S+1, D-0.1`. Look at
  each: the dot is visible before the cut, the frame is fully red at `S`, and
  the circle frames `to` just after `S`.
- `verify-render.py` assumes an audio stream and a beat grid. Neither exists
  here, so check the render with the manual `ffprobe` line in
  `verification.md`: one `h264`, `1080x830`, `30/1`, duration `D` +-0.05 s.

## Known pitfalls (from the original build)

- **The dot must cover the corners.** The half-diagonal of 1080x830 is 681 px,
  and 120 px x12 = 1440 px diameter clears it. A larger canvas needs a larger
  scale, which is a template change.
- **The clip-path circle ends at 720 px**, also above 681, so the
  `back.out` overshoot never shows a corner after the reveal settles.
- **Width fit is estimated**, not measured (per-glyph em widths, the same as
  `intro-kinetic`), and it only shrinks. Check the snapshot for very long
  words.
- **GSAP and the font are local.** GSAP is copied from the official plugin and
  the font from `templates/_shared`. Never switch to a CDN.
