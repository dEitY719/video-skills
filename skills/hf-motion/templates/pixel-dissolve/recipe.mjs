// pixel-dissolve recipe: validation, scene plan, plugin assets.
// Read by scripts/scaffold.mjs; never copied into the project.
//
// Silent by design: no music bed, no SFX, so no musicArgs export.

// GSAP is taken from the official hyperframes plugin at scaffold time, never
// redistributed from this repo (GreenSock standard license).
export const pluginAssets = {
  "assets/vendor/gsap.min.js": { glob: "skills/*/assets/vendor/gsap.min.js" },
};

// Bundled font (SIL OFL 1.1) shared by every recipe: templates/_shared/<path>.
export const sharedAssets = ["assets/fonts/NanumSquare_acEB.ttf", "assets/fonts/OFL.txt"];

export const limits = { duration: [3, 10], grid: [4, 60] };
export const HALF = 0.6; // seconds per dissolve phase (cover, then reveal); index.html uses the same

const HEX = /^#[0-9a-fA-F]{6}$/;
const lum = (hex) => {
  const ch = [1, 3, 5].map((i) => parseInt(hex.slice(i, i + 2), 16) / 255)
    .map((v) => (v <= 0.03928 ? v / 12.92 : ((v + 0.055) / 1.055) ** 2.4));
  return 0.2126 * ch[0] + 0.7152 * ch[1] + 0.0722 * ch[2];
};
const contrast = (a, b) => {
  const [hi, lo] = [lum(a), lum(b)].sort((x, y) => y - x);
  return (hi + 0.05) / (lo + 0.05);
};

export function validate(c) {
  const err = [];
  for (const k of ["from", "to"]) {
    if (typeof c[k] !== "string" || !c[k].trim()) err.push(`${k} must be a non-empty string`);
  }
  const [dlo, dhi] = limits.duration;
  if (!(c.duration >= dlo && c.duration <= dhi)) err.push(`duration must be ${dlo}..${dhi} s, got ${c.duration}`);
  if (!(c.switchAt >= 1 && c.switchAt <= c.duration - 1)) {
    err.push(`switchAt must be 1..duration-1 (the dissolve takes ${HALF} s each side), got ${c.switchAt}`);
  }
  const [glo, ghi] = limits.grid;
  for (const k of ["cols", "rows"]) {
    if (!Number.isInteger(c[k]) || c[k] < glo || c[k] > ghi) err.push(`${k} must be an integer ${glo}..${ghi}, got ${c[k]}`);
  }
  let hexOk = true;
  for (const k of ["paper", "charcoal", "red"]) {
    if (!HEX.test(c[k] ?? "")) { err.push(`${k} must be a #rrggbb colour`); hexOk = false; }
  }
  if (hexOk) {
    if (contrast(c.paper, c.charcoal) < 4.5) err.push(`paper/charcoal contrast ${contrast(c.paper, c.charcoal).toFixed(2)} < 4.5`);
    for (const k of ["paper", "charcoal"]) {
      const r = contrast(c.red, c[k]);
      if (r < 3) err.push(`red on ${k} contrast ${r.toFixed(2)} < 3`);
    }
  }
  return err;
}

const r = (x) => +x.toFixed(6);

// Scene plan -> { elementId: [data-start, data-duration] } in seconds.
export function timing(c) {
  const total = r(c.duration);
  return {
    total,
    at: {
      stage: [0, total],
      sA: [0, r(c.switchAt)],
      sB: [r(c.switchAt), r(c.duration - c.switchAt)],
      dz: [r(c.switchAt - HALF), r(2 * HALF)],
    },
  };
}
