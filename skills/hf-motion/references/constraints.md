# video:hf-motion — Hard rules

These are acceptance criteria, not style advice. A run that breaks one is a
failed run even if an MP4 came out.

## 1. Render only after the parameters are confirmed

Show the complete parameter table (every key, defaults marked as such) and get
an explicit yes. Scaffolding, lint, check and snapshots may run before that to
preview; `render` may not. A change after confirmation means a new table and a
new yes.

## 2. Never invent facts — all text comes from parameters

Names, team, employer, years, subscriber counts, tool names, slogans: every
on-screen string and number is either supplied by the user or an untouched
default they explicitly accepted. Do not "improve" a number, round a count,
translate a name or write a catchier finale. If a fact is missing, ask. The
defaults are one real person's facts; reusing them for anyone else is
inventing.

## 3. Palette: exactly the three given colours

`paper`, `charcoal`, `red` (the accent) — nothing else on screen. No
gradients, no extra tints, no per-scene colour. A palette change is three
`#rrggbb` parameters, and `check`'s contrast gate must still pass (accent text
over `charcoal` and `paper`).

## 4. Every cut lands on a beat

Applies to recipes with a `bpm` (`intro-kinetic`). Silent recipes have no beat
grid; their cut time is the `switchAt` / `diveStart` parameter instead.

Scene lengths are whole beats (`beat = 60 / bpm`); transition covers end on
the cut, not after it; the music bed is regenerated for the same `bpm` and
total. Never hand-edit `data-start` / `data-duration` — change `CONFIG` and
run `scaffold.mjs --update`. The composition throws at load when the
attributes and `CONFIG` disagree; treat that error as a stop, not a nuisance.

## 5. Verification gates, in order, none skipped

1. `lint` — 0 errors.
2. `check` — passes (0 errors in every section).
3. `snapshot` at the recipe's times — every frame looked at.
4. `render`.
5. `verify-render.py` — all `[OK]`.

A failure at gate n stops the run there. Fix the cause and restart from the
scaffold (`--update`), not from the failing gate. The accepted warnings are
listed in `verification.md`; any other warning is a failure.

## 6. Engine rules belong upstream

Anything about the HyperFrames runtime (clips, timelines, determinism, media)
comes from `hyperframes:hyperframes-core` / `hyperframes:motion-graphics`. If
a recipe needs a structural change, read those first and change the template
in this repo; never patch a scaffolded project's script and call it the recipe.

## 7. The launcher, never bare npx

`node "$PLUGIN/skills/hyperframes/scripts/plugin-cli.mjs" <cmd>` only. No
`npx hyperframes`, no `skills update`, no `npx skills add`.
