// circle-pop recipe: validation, scene plan, plugin assets. Silent (no music).
// Read by scripts/scaffold.mjs; never copied into the project.
//
// timing() is the single source for every static timing attribute; index.html
// re-derives the two scene lengths only to refuse to build on a mismatch.

// GSAP is copied from the official hyperframes plugin at scaffold time (GreenSock
// standard license), never redistributed from this repo.
export const pluginAssets = {
  "assets/vendor/gsap.min.js": { glob: "skills/*/assets/vendor/gsap.min.js" },
};

// Bundled font (SIL OFL 1.1) shared by every recipe: templates/_shared/<path>.
export const sharedAssets = ["assets/fonts/NanumSquare_acEB.ttf", "assets/fonts/OFL.txt"];

// The dot pops 0.55 s before the cut, so scene 1 needs >= 1 s; scene 2's circle
// takes 0.6 s to open, so it gets >= 1 s too.
export const limits = { duration: [3, 10], minScene: 1 };

const HEX = /^#[0-9a-fA-F]{6}$/;
const lum = (hex) => {
  const [r, g, b] = [1, 3, 5].map((i) => parseInt(hex.slice(i, i + 2), 16) / 255)
    .map((v) => (v <= 0.03928 ? v / 12.92 : ((v + 0.055) / 1.055) ** 2.4));
  return 0.2126 * r + 0.7152 * g + 0.0722 * b;
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
  const [lo, hi] = limits.duration;
  if (!(c.duration >= lo && c.duration <= hi)) err.push(`duration must be ${lo}..${hi} s, got ${c.duration}`);
  const m = limits.minScene;
  if (!(c.switchAt >= m && c.switchAt <= c.duration - m)) {
    err.push(`switchAt must be ${m}..duration-${m} s (both scenes >= ${m} s), got ${c.switchAt}`);
  }
  for (const k of ["paper", "charcoal", "red"]) {
    if (!HEX.test(c[k] ?? "")) err.push(`${k} must be a #rrggbb colour`);
  }
  if (!err.length) {
    for (const k of ["paper", "charcoal"]) {
      const r = contrast(c.red, c[k]);
      if (r < 3) err.push(`red ${c.red} has ${r.toFixed(2)}:1 contrast on ${k} ${c[k]}; needs >= 3:1`);
    }
  }
  return err;
}

const r = (x) => +x.toFixed(6);

// { elementId: [data-start, data-duration] } in seconds.
export function timing(c) {
  const total = r(c.duration), at = r(c.switchAt);
  return {
    at: { stage: [0, total], s1: [0, at], s2: [at, r(total - at)] },
    total,
  };
}
