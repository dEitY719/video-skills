# Recipe: text-sandwich

A silent 6 s text-sandwich shot, 1080x830 @ 30 fps: one big word, a character
image walking across it, and the character passing **between** the letters —
behind the 2nd, 4th, ... letters and in front of the 1st, 3rd, .... Paper /
charcoal / one accent colour, one display face (NanumSquare ac ExtraBold,
Latin + Hangul). Default `CONFIG` = the original hand-built render (`MOTION`
with a generic placeholder silhouette) and reproduces it frame for frame.

## Layers

| z | Layer | What it is |
|---|-------|------------|
| 1 | back word | the whole word, charcoal with a red offset shadow, plus the red underline bar |
| 2 | character | `CONFIG.image`, `charHeight` px tall, centred vertically, walks across |
| 3 | front word | a pixel-identical copy of the word; 1st, 3rd, ... letters hidden; 2nd, 4th, ... drawn over the character |

## Parameters

Every key is a top-level `CONFIG` key; pass it as `key=value`.

| Key | Type | Default | Limit / note |
|-----|------|---------|--------------|
| `word` | text | `MOTION` | **2..10** characters, no leading/trailing space; 260 px, shrinks to fit 960 px (estimate) |
| `image` | file | `assets/placeholder.png` | pass `image=<path to your .png>`: the scaffold copies it to `assets/<basename>` and stores that path; missing file -> exit 2, nothing written |
| `duration` | number | `6` | **3..10** seconds |
| `charHeight` | integer | `600` | **200..800** px; width follows the image's aspect ratio |
| `direction` | `ltr` \| `rtl` | `ltr` | walk direction; the image is never mirrored |
| `paper` | `#rrggbb` | `#f2eee6` | background |
| `charcoal` | `#rrggbb` | `#1e1e1e` | the word |
| `red` | `#rrggbb` | `#e5322d` | shadow + underline bar; must keep 3:1 contrast on both others |

The default image is a placeholder silhouette made for this repo. It is not
the user's character: ask for their file and pass it with `image=`.

## Timeline (`D = duration`, one scene `#s1` = 0..D)

| Time | What happens |
|------|--------------|
| 0.1 + 0.07 i | letter i rises 90 px and fades in (0.45 s, back and front copies together) |
| 0.9 -> D - 1.2 | the character walks fully across the frame (off-left to off-right for `ltr`), linear, with a 16 px bob every 0.25 s |
| D - 1.2 | red underline bar wipes in under the word (0.5 s) |
| -> D | hold |

Root `data-duration` and `#s1` timing are static attributes the scaffold
writes from `duration`; never edit them by hand (`scaffold.mjs --update`).
The timeline is registered only after the image decodes, so no frame is
captured without the character.

## Verification specifics

- Snapshot times for the default: `0.3,1.5,2.4,3.3,4.2,5.5` (entrance, walk
  x4, hold). For another `duration` keep 0.3 and D - 0.5 and spread the rest
  over 0.9 .. D - 1.2. In the walk frames, confirm the character covers a
  1st/3rd/... letter and is covered by a 2nd/4th/... one.
- Accepted lint warning: `nested_structure_needs_subcomposition` on `#s1`
  (single-file by design, as `intro-kinetic`).
- The piece is **silent**: no `<audio>`, no music bed, so `verify-render.py`
  (which requires an aac stream and a kick grid) does not apply. Check with
  `ffprobe`: one `h264` stream, `1080x830`, `30/1`, duration = `duration`
  +-0.05 s.

## Image requirements and pitfalls

- **PNG with a real alpha channel.** A JPEG, or a PNG with a baked-in
  white/checkerboard background, renders as a rectangle sliding over the word
  and the sandwich illusion is gone. Only `.png` is accepted.
- **Trim the canvas.** Height is fixed to `charHeight`; transparent padding
  around the figure makes it look small. Crop to the figure; 600-1200 px tall
  is plenty (it is drawn at 200-800 px).
- **Portrait-ish figures work best.** A very wide image (wider than ~1.5x its
  height) covers several letters at once and the in-front/behind alternation
  is hard to read; lower `charHeight`.
- **The image's own colours are exempt** from the three-colour rule (it is
  the user's content), but a figure drawn mostly in the `charcoal` colour
  hides the front letters: `check` then reports a 1:1 contrast warning on a
  front letter, which is a failure. Change `charcoal` or use another image.
- **Layering is waived per letter.** Each letter span carries
  `data-layout-allow-overlap` and `data-layout-allow-occlusion`: the two copies
  share one box and the character covers back letters by design. Any other
  `content_overlap` / `text_occluded` is a real defect.
- **Width fit is estimated**, not measured (Hangul 0.95 em, capitals and
  digits 0.72 em, space 0.3 em, other 0.6 em), and only shrinks. Long
  lowercase words still need a look at the snapshot.
- **Single-letter words are refused**: with one letter there is nothing for
  the character to pass in front of.
