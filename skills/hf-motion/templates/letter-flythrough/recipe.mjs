// letter-flythrough recipe: validation, scene plan, plugin assets.
// Read by scripts/scaffold.mjs; never copied into the project.
//
// Silent recipe: no music bed, no SFX, so no musicArgs and no beat grid.
// index.html re-derives the same windows only to refuse to build when the
// static attributes and CONFIG disagree.

// GSAP is taken from the official hyperframes plugin at scaffold time (its own
// standard license), never redistributed from this repo.
export const pluginAssets = {
  "assets/vendor/gsap.min.js": { glob: "skills/*/assets/vendor/gsap.min.js" },
};

// Bundled font (SIL OFL 1.1) shared by every recipe: templates/_shared/<path>.
export const sharedAssets = ["assets/fonts/NanumSquare_acEB.ttf", "assets/fonts/OFL.txt"];

export const limits = { word: [1, 6], next: [1, 16], duration: [3, 10], diveLength: [1, 4] };

// Latin/digit glyphs of NanumSquare ac ExtraBold with a closed counter (hole),
// measured by flood-filling each glyph ('4' is open in this face).
// Anything outside ASCII (Hangul etc.) is checked at runtime by the template.
export const COUNTER_LETTERS = "ABDOPQRabdegopq0689";

const HEX = /^#[0-9a-fA-F]{6}$/;
const INTRO = 0.6; // word entrance must finish before the dive
const LAND = 0.6; // rule draw + a beat of hold after the dive

export function validate(c) {
  const err = [];
  for (const k of ["word", "next"]) {
    const [lo, hi] = limits[k];
    const n = typeof c[k] === "string" ? Array.from(c[k].trim()).length : -1;
    if (n < lo || n > hi) err.push(`${k} needs ${lo}..${hi} characters, got ${n}`);
    else if (/[\n\r\t]/.test(c[k])) err.push(`${k} must be a single line`);
  }
  const chars = Array.from(c.word ?? "");
  if (!Number.isInteger(c.target) || c.target < 0 || c.target >= chars.length) {
    err.push(`target must be a letter index 0..${Math.max(chars.length - 1, 0)} of word`);
  } else {
    const ch = chars[c.target];
    if (ch.charCodeAt(0) < 128 && !COUNTER_LETTERS.includes(ch)) {
      err.push(`target letter '${ch}' has no closed counter; use one of ${COUNTER_LETTERS}`);
    }
  }
  const [dlo, dhi] = limits.duration;
  if (!(c.duration >= dlo && c.duration <= dhi)) err.push(`duration must be ${dlo}..${dhi} s, got ${c.duration}`);
  const [llo, lhi] = limits.diveLength;
  if (!(c.diveLength >= llo && c.diveLength <= lhi)) err.push(`diveLength must be ${llo}..${lhi} s, got ${c.diveLength}`);
  if (!(c.diveStart >= INTRO)) err.push(`diveStart must be >= ${INTRO} s (after the word lands), got ${c.diveStart}`);
  if (!(c.diveStart + c.diveLength <= c.duration - LAND + 1e-9)) {
    err.push(`diveStart + diveLength must be <= duration - ${LAND} s, got ${c.diveStart} + ${c.diveLength} with duration ${c.duration}`);
  }
  for (const k of ["paper", "charcoal", "red"]) {
    if (!HEX.test(c[k] ?? "")) err.push(`${k} must be a #rrggbb colour`);
  }
  return err;
}

const r = (x) => +x.toFixed(6);

// Scene plan -> { elementId: [data-start, data-duration] } in seconds.
export function timing(c) {
  const total = r(c.duration);
  const land = r(c.diveStart + c.diveLength);
  return { total, at: { stage: [0, total], scene: [0, total], s2: [land, r(total - land)] } };
}
