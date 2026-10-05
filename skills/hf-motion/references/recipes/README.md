# hf-motion recipes

A recipe is a fixed skeleton — scenes, motion, beat grid, music structure —
whose content comes entirely from parameters. Each implemented recipe owns
three things: `templates/<recipe>/` (the project, with one `CONFIG` block),
`templates/<recipe>/recipe.mjs` (validation, scene plan, plugin assets, and
music arguments when the recipe has a music bed) and `references/recipes/<recipe>.md` (parameter table, timeline,
pitfalls). `scaffold.mjs --list` prints the implemented set from the
templates directory, so this table and that listing must agree.

| Recipe | Status | What it is |
|--------|--------|------------|
| `intro-kinetic` | **implemented** | 15 s kinetic-typography self-introduction at 120 BPM: name slam, count-ups, tools, beat flashes, three-line finale. [`intro-kinetic.md`](intro-kinetic.md) |
| `pixel-dissolve` | **implemented** | 6 s 1080x830 word swap: text A dissolves cell by cell (seeded order, accent flash) into text B. No music. [`pixel-dissolve.md`](pixel-dissolve.md) |
| `circle-pop` | **implemented** | 6 s 1080x830 scene change: a circle pops from a chosen origin, overshoots, fills the frame and becomes scene B behind text B. No music. [`circle-pop.md`](circle-pop.md) |
| `text-sandwich` | planned — not implemented | A keyword sandwiched between two moving text bands |
| `screen-dive` | **implemented** | 6 s 1080x830 camera dive: a CSS-drawn laptop, then one continuous scale+translate into its screen until the screen text is full-frame and the bezel is gone. No music. [`screen-dive.md`](screen-dive.md) |
| `letter-flythrough` | planned — not implemented | Camera flies through the letters of a word |

Planned recipes have no template, no parameters and no code. `hf-motion`
answers a request for one with "not implemented" and stops; it does not
approximate it with an implemented one. A one-off version of any of them belongs
to `hyperframes:motion-graphics`.

## Adding a recipe

1. Build and verify the video once by hand with `hyperframes:motion-graphics`.
2. Move every string and tunable into one strict-JSON `CONFIG` block in
   `templates/<name>/index.html`; make the timeline read only `CONFIG` and the
   scene windows (`data-start` / `data-duration`).
3. Write `recipe.mjs` (`validate`, `timing`, `pluginAssets`; `musicArgs` only
   with a music bed, `canvas` only when not 1920x1080 — the scaffold's
   `verify-render args:` line follows both).
4. Prove the default config reproduces the original frames (pixel diff of
   snapshots), and that an alternate config passes lint/check.
5. Add `<name>.md` here, flip the status above, extend the selfcheck.
