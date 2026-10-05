# Recipe: letter-flythrough

A 6 s letter fly-through, 1080x830 @ 30 fps, silent. A big word lands, the
camera dives into the counter (the enclosed hole) of one of its letters until
the hole fills the frame, and the next line, which sat inside that hole all
along, is what the camera lands on. Paper / charcoal / one accent colour, one
Korean display face (NanumSquare ac ExtraBold). Default `CONFIG` = the
original hand-built cut and reproduces it frame for frame.

## Parameters

Every key is a top-level `CONFIG` key; pass it as `key=value`.

| Key | Type | Default | Limit / note |
|-----|------|---------|--------------|
| `word` | text | `AI` | **1..6** characters, one line; fitted to 900 x 620 px (max 640 px) |
| `next` | text | `프롬프트 한 줄` | **1..16** characters, one line; the landing line, fitted to 80% of the end frame |
| `target` | integer | `0` | index into `word` of the letter to fly through; it is drawn in the accent and must have a closed counter (see pitfalls) |
| `duration` | seconds | `6` | **3..10**; root `data-duration` |
| `diveStart` | seconds | `1.6` | >= 0.6 (the word's entrance is 0.5 s) |
| `diveLength` | seconds | `2.4` | **1..4**; `diveStart + diveLength <= duration - 0.6` |
| `paper` | `#rrggbb` | `#f2eee6` | background and the inside of the hole |
| `charcoal` | `#rrggbb` | `#1e1e1e` | the other letters and the landing line |
| `red` | `#rrggbb` | `#e5322d` | accent: the target letter and the rule; must keep 3:1 contrast on both others |

For a 3 s cut, shorten the dive too: `duration=3 diveStart=0.6 diveLength=1.8`.

## Timeline (seconds; D = `duration`, S = `diveStart`, L = `diveLength`)

| Element | Window | What happens |
|---------|--------|--------------|
| `#scene` | 0 .. D | the SVG camera; holds everything that zooms |
| word entrance | 0 .. 0.5 | the word rises 60 px and fades in |
| dive | S .. S + L | zoom `power3.inOut`, exponential in scale, the hole's best point slides to frame centre; the next line fades in over 0.35L .. 0.75L of the dive |
| `#s2` | S + L .. D | landing: the accent rule draws under the line (0.4 s), then hold |

Default: word 0-0.5, hold to 1.6, dive 1.6-4.0, rule 4.0-4.4, hold to 6.0.
Only `#stage`, `#scene` and `#s2` carry timing attributes; the scaffold
writes all three from `timing()`. No audio, so no beat grid: constraint 4
(cuts on a beat) has nothing to bind to here, and `verify-render.py`'s audio
and kick-grid checks do not apply. Verify the render with `ffprobe` alone
(`h264`, `1080x830`, `30/1`, duration = D, no audio stream).

Snapshot times for the default: `0.3,1.0,2.4,2.8,3.0,3.3,3.6,4.2,5.5` (entrance,
hold, dive start, the hole opening, the deepest zoom, landing, rule, hold).
For other timings place two in the hold, three across the dive's second half
and two after `S + L`.

## How the zoom stays sharp

The camera is the `viewBox` of one inline SVG; the glyphs are `<text>`, so
every frame re-rasterises vector outlines at the current scale. Nothing is a
bitmap or a CSS `scale()` of a raster layer, and the deepest frames (zoom
about 25x on `A`, more on small counters like `e`) stay crisp; check them in
the snapshots anyway.

The hole is found at runtime, after the bundled face loads: the word is drawn
once to an offscreen canvas (2x), the outside is flood-filled from the border,
the remaining enclosed background regions are labelled, and the largest one
whose centre lies in the target letter's advance wins. The camera ends on 86%
of the largest frame-shaped (1080:830) rectangle inside it, and the next line
is laid out in world units inside that rectangle. That raster only steers the
camera; what is drawn stays vector.

## Known pitfalls (from the original build)

- **Which letters have a hole.** NanumSquare ac ExtraBold, measured by flood
  fill: `A B D O P Q R a b d e g o p q 0 6 8 9`. `I`, `C`, `4` (open in this
  face) and the rest have none; `recipe.mjs` refuses an ASCII target outside
  that set. Non-ASCII targets are checked at runtime: Hangul syllables with
  `ㅇ`, `ㅁ`, `ㅂ`, `ㅎ` work (`한` flies through the `ㅇ`); one without a closed
  shape (`가`) makes `check` fail with `'가' has no closed counter`.
  Pick another `target`.
- **Small holes mean big zoom.** `e`, `g`, `a` have small counters; the end
  scale is larger and the hole edge passes faster. Still vector-sharp, but
  look at the dive frames.
- **Do not drive the camera from `onUpdate`.** The runtime seeks with events
  suppressed, so a timeline callback left a stale `viewBox` (shifted frames in
  snapshots). The camera is a setter on a proxy object that GSAP tweens.
- **Intentional overlap.** The next line sits inside the target letter's
  bounding box; both texts carry `data-layout-allow-overlap`, otherwise
  `check` reports `content_overlap`.
- **CDN GSAP fails behind the corporate proxy.** The template loads
  `assets/vendor/gsap.min.js`; the scaffold copies it from the official
  hyperframes plugin. Never switch back to a CDN URL.
- **Korean tofu.** The face is bundled (`assets/fonts/NanumSquare_acEB.ttf`,
  SIL OFL 1.1, licence beside it). The hole search and the layout both measure
  that face, so a fallback font would also put the camera in the wrong place.
- **Lint warnings accepted** (see `verification.md`): two
  `nested_structure_needs_subcomposition` (`#scene`, `#s2`); single file on
  purpose so one `CONFIG` drives everything.
- **Opacity fades** (word entrance, next line) briefly blend palette colours;
  that is the fade, not a fourth colour.
