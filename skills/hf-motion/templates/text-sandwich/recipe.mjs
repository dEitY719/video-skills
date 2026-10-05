// text-sandwich recipe: validation, scene plan, plugin assets. Silent (no
// music bed, no SFX), so there is no musicArgs.
// Read by scripts/scaffold.mjs; never copied into the project.

// GSAP is taken from the official hyperframes plugin at scaffold time, never
// redistributed from this repo (GreenSock standard license).
export const pluginAssets = {
  "assets/vendor/gsap.min.js": { glob: "skills/*/assets/vendor/gsap.min.js" },
};

// Bundled font (SIL OFL 1.1) shared by every recipe: templates/_shared/<path>.
export const sharedAssets = ["assets/fonts/NanumSquare_acEB.ttf", "assets/fonts/OFL.txt"];

// CONFIG keys whose key=value names a local file: the scaffold copies it to
// assets/<basename> and stores that relative path in CONFIG.
export const userFiles = ["image"];

export const limits = { word: [2, 10], duration: [3, 10], charHeight: [200, 800] };

const HEX = /^#[0-9a-fA-F]{6}$/;

export function validate(c) {
  const err = [];
  const n = typeof c.word === "string" ? [...c.word].length : -1;
  const [wlo, whi] = limits.word;
  if (n < wlo || n > whi) err.push(`word needs ${wlo}..${whi} characters (fits the 1080 px canvas), got ${n}`);
  else if (c.word !== c.word.trim()) err.push(`word must not start or end with a space`);
  if (typeof c.image !== "string" || !/^assets\/[^/\\]+\.png$/i.test(c.image)) {
    err.push(`image must be a .png (transparent background) copied under assets/; pass image=<path to your .png>`);
  }
  const [dlo, dhi] = limits.duration;
  if (!(c.duration >= dlo && c.duration <= dhi)) err.push(`duration must be ${dlo}..${dhi} seconds, got ${c.duration}`);
  const [hlo, hhi] = limits.charHeight;
  if (!Number.isInteger(c.charHeight) || c.charHeight < hlo || c.charHeight > hhi) err.push(`charHeight must be an integer ${hlo}..${hhi} px`);
  if (!["ltr", "rtl"].includes(c.direction)) err.push(`direction must be ltr or rtl`);
  for (const k of ["paper", "charcoal", "red"]) {
    if (!HEX.test(c[k] ?? "")) err.push(`${k} must be a #rrggbb colour`);
  }
  return err;
}

// One scene for the whole piece -> { elementId: [data-start, data-duration] }.
export function timing(c) {
  const total = +c.duration.toFixed(6);
  return { at: { stage: [0, total], s1: [0, total] }, total };
}
