# hf-motion recipes

A recipe is a fixed skeleton — scenes, motion, beat grid, music structure —
whose content comes entirely from parameters. Each implemented recipe owns
three things: `templates/<recipe>/` (the project, with one `CONFIG` block),
`templates/<recipe>/recipe.mjs` (validation, scene plan, plugin assets, music
arguments) and `references/recipes/<recipe>.md` (parameter table, timeline,
pitfalls). `scaffold.mjs --list` prints the implemented set from the
templates directory, so this table and that listing must agree.

| Recipe | Status | What it is |
|--------|--------|------------|
| `intro-kinetic` | **implemented** | 15 s kinetic-typography self-introduction at 120 BPM: name slam, count-ups, tools, beat flashes, three-line finale. [`intro-kinetic.md`](intro-kinetic.md) |
| `pixel-dissolve` | **implemented** | 6 s `from` word dissolving into a `to` word through a seeded pixel grid, 1080x830, silent. [`pixel-dissolve.md`](pixel-dissolve.md) |
| `circle-pop` | **implemented** | 6 s circle pop: a red circle grows to cover the frame and a charcoal circle pops out with the next scene, 1080x830, silent. [`circle-pop.md`](circle-pop.md) |
| `text-sandwich` | **implemented** | 6 s big word with a character PNG passing between its letters (back layer, character, front letters), 1080x830, silent. Needs `image=<png>`. [`text-sandwich.md`](text-sandwich.md) |
| `screen-dive` | **implemented** | 6 s camera dive into a CSS laptop until the screen scene fills the frame, 1080x830, silent. [`screen-dive.md`](screen-dive.md) |
| `letter-flythrough` | **implemented** | 6 s camera zoom through the counter of a letter (default `AI`) into the next line, vector-sharp, 1080x830, silent. [`letter-flythrough.md`](letter-flythrough.md) |

A recipe listed as planned (none right now) has no template, no parameters and no code. `hf-motion`
answers a request for one with "not implemented" and stops; it does not
approximate it with `intro-kinetic`. A one-off version of any of them belongs
to `hyperframes:motion-graphics`.

## Adding a recipe

1. Build and verify the video once by hand with `hyperframes:motion-graphics`.
2. Move every string and tunable into one strict-JSON `CONFIG` block in
   `templates/<name>/index.html`; make the timeline read only `CONFIG` and the
   scene windows (`data-start` / `data-duration`).
3. Write `recipe.mjs` (`validate`, `timing`, `pluginAssets`, `musicArgs`).
4. Prove the default config reproduces the original frames (pixel diff of
   snapshots), and that an alternate config passes lint/check.
5. Add `<name>.md` here, flip the status above, extend the selfcheck.
