// screen-dive recipe: validation, scene plan, plugin assets. Silent (no music,
// no SFX), so there is no musicArgs. Read by scripts/scaffold.mjs; never
// copied into the project.

// GSAP ships under its own standard license inside the official hyperframes
// plugin; it is copied from there at scaffold time, never redistributed here.
export const pluginAssets = {
  "assets/vendor/gsap.min.js": { glob: "skills/*/assets/vendor/gsap.min.js" },
};

// Bundled font (SIL OFL 1.1) shared by every recipe: templates/_shared/<path>.
export const sharedAssets = ["assets/fonts/NanumSquare_acEB.ttf", "assets/fonts/OFL.txt"];

// screenText / caption are in characters (code points): 12 keeps the title at
// >= ~31 px on the laptop and >= ~79 px full frame; 30 fits the caption line.
export const limits = { duration: [3, 10], diveDur: [0.8, 3], diveStartMin: 1.0, hold: 0.5, screenText: 12, caption: 30 };

const HEX = /^#[0-9a-fA-F]{6}$/;

// WCAG relative luminance / contrast ratio of two #rrggbb colours.
const lum = (hex) => {
  const [r, g, b] = [1, 3, 5].map((i) => {
    const v = parseInt(hex.slice(i, i + 2), 16) / 255;
    return v <= 0.03928 ? v / 12.92 : ((v + 0.055) / 1.055) ** 2.4;
  });
  return 0.2126 * r + 0.7152 * g + 0.0722 * b;
};
const contrast = (a, b) => {
  const [hi, lo] = [lum(a), lum(b)].sort((x, y) => y - x);
  return (hi + 0.05) / (lo + 0.05);
};

export function validate(c) {
  const err = [];
  const len = (s) => [...s].length;
  if (typeof c.screenText !== "string" || !c.screenText.trim()) err.push("screenText must be a non-empty string");
  else if (len(c.screenText) > limits.screenText) err.push(`screenText must be at most ${limits.screenText} characters (fits the laptop screen), got ${len(c.screenText)}`);
  if (typeof c.caption !== "string") err.push("caption must be a string (empty = no caption)");
  else if (len(c.caption) > limits.caption) err.push(`caption must be at most ${limits.caption} characters, got ${len(c.caption)}`);
  const [dlo, dhi] = limits.duration;
  if (!(c.duration >= dlo && c.duration <= dhi)) err.push(`duration must be ${dlo}..${dhi} s, got ${c.duration}`);
  const [vlo, vhi] = limits.diveDur;
  if (!(c.diveDur >= vlo && c.diveDur <= vhi)) err.push(`diveDur must be ${vlo}..${vhi} s, got ${c.diveDur}`);
  if (!(c.diveStart >= limits.diveStartMin)) err.push(`diveStart must be >= ${limits.diveStartMin} s (the laptop intro), got ${c.diveStart}`);
  else if (c.diveStart + c.diveDur + limits.hold > c.duration) {
    err.push(`diveStart + diveDur + ${limits.hold} s hold must fit in duration (${c.diveStart} + ${c.diveDur} + ${limits.hold} > ${c.duration})`);
  }
  for (const k of ["paper", "charcoal", "red"]) {
    if (!HEX.test(c[k] ?? "")) err.push(`${k} must be a #rrggbb colour`);
  }
  if (!err.some((e) => e.includes("colour"))) {
    for (const k of ["paper", "charcoal"]) {
      const cr = contrast(c.red, c[k]);
      if (cr < 3) err.push(`red ${c.red} has ${cr.toFixed(2)}:1 contrast on ${k} ${c[k]}; needs >= 3:1`);
    }
    const tc = contrast(c.paper, c.charcoal);
    if (tc < 4.5) err.push(`paper/charcoal contrast is ${tc.toFixed(2)}:1; the title needs >= 4.5:1`);
  }
  return err;
}

const r = (x) => +x.toFixed(6);

// One clip for the whole shot; the dive itself is timed from CONFIG inside it.
export function timing(c) {
  const total = r(c.duration);
  return { at: { stage: [0, total], s1: [0, total] }, total };
}
