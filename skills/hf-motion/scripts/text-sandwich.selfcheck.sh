#!/usr/bin/env bash
# Self-check for scaffold.mjs + the text-sandwich recipe. Offline: a fake
# hyperframes plugin supplies GSAP; the recipe is silent (no music bed).
#
#   bash skills/hf-motion/scripts/text-sandwich.selfcheck.sh
#
# Scaffolds the default and an alternate config (with a user image passed as
# image=<path>) into temp dirs and asserts the alternate CONFIG, its static
# timing attributes, the copied image and its literal UTF-8 text all took
# effect, then exercises the refusal paths.
set -u
HERE="$(cd -- "$(dirname -- "$0")" && pwd)"
S="$HERE/scaffold.mjs"
TPL="$HERE/../templates/text-sandwich"
FAIL=0
chk() { # chk <label> <got> <want>
    if [ "$2" = "$3" ]; then echo "ok    $1"; else echo "FAIL  $1: got '$2' want '$3'"; FAIL=1; fi
}
TMP=$(mktemp -d) || exit 1
trap 'rm -rf "$TMP"' EXIT
P="$TMP/plugin"
mkdir -p "$P/skills/hyperframes/scripts" "$P/skills/demo/assets/vendor"
: > "$P/skills/hyperframes/scripts/plugin-cli.mjs"
echo '/* gsap fixture */' > "$P/skills/demo/assets/vendor/gsap.min.js"
echo '{"name":"hyperframes","version":"9.9.9"}' > "$P/plugin.json"
export HF_PLUGIN_ROOT="$P"

cfg() { # cfg <project> <js-expr over CONFIG c> -> value
    node -e 'const h=require("fs").readFileSync(process.argv[1],"utf8");
      const c=JSON.parse(h.slice(h.indexOf("/* CONFIG:BEGIN */")+18,h.indexOf("/* CONFIG:END */")));
      console.log(eval(process.argv[2]))' "$1/index.html" "$2"
}
attr() { # attr <project> <id> <attr> -> value of that attribute on the element with that id
    node -e 'const h=require("fs").readFileSync(process.argv[1],"utf8");
      const t=h.match(new RegExp("<[a-zA-Z]+\\b[^>]*\\bid=\""+process.argv[2]+"\"[^>]*>"))[0];
      console.log(t.match(new RegExp(process.argv[3]+"=\"([^\"]*)\""))[1])' "$1/index.html" "$2" "$3"
}

# 1. default: the original 6 s MOTION piece with the placeholder character
node "$S" text-sandwich "$TMP/def" >/dev/null
chk "default exit" "$?" 0
chk "default word" "$(cfg "$TMP/def" c.word)" "MOTION"
chk "default image" "$(cfg "$TMP/def" c.image)" "assets/placeholder.png"
chk "default total" "$(attr "$TMP/def" stage data-duration)" "6"
chk "default s1" "$(attr "$TMP/def" s1 data-duration)" "6"
chk "canvas 1080x830" "$(attr "$TMP/def" stage data-width)x$(attr "$TMP/def" stage data-height)" "1080x830"
chk "placeholder shipped" "$(cmp -s "$TMP/def/assets/placeholder.png" "$TPL/assets/placeholder.png" && echo y)" "y"
chk "gsap copied from plugin" "$(cat "$TMP/def/assets/vendor/gsap.min.js")" "/* gsap fixture */"
chk "font bundled" "$([ -s "$TMP/def/assets/fonts/NanumSquare_acEB.ttf" ] && [ -s "$TMP/def/assets/fonts/OFL.txt" ] && echo y)" "y"
chk "silent: no music, no sfx" "$(find "$TMP/def" -name 'music*' -o -name sfx | wc -l | tr -d ' ')" "0"
chk "recipe.mjs not copied" "$([ -e "$TMP/def/recipe.mjs" ] && echo y || echo n)" "n"
chk "package.json pins plugin version" "$(node -p 'require(process.argv[1]).scripts.render' "$TMP/def/package.json")" "npx --yes hyperframes@9.9.9 render"

# 2. alternate: Korean word, user image (path with a space), palette, length, direction
cp "$TPL/assets/placeholder.png" "$TMP/my char.png"
node "$S" text-sandwich "$TMP/alt" 'word=샌드위치' "image=$TMP/my char.png" 'duration=8' 'charHeight=500' \
    'direction=rtl' 'paper=#fff8e7' 'charcoal=#14213d' 'red=#d62828' >/dev/null
chk "alt exit" "$?" 0
chk "alt word" "$(cfg "$TMP/alt" c.word)" "샌드위치"
chk "alt image path in CONFIG" "$(cfg "$TMP/alt" c.image)" "assets/my char.png"
chk "alt image copied" "$(cmp -s "$TMP/alt/assets/my char.png" "$TMP/my char.png" && echo y)" "y"
chk "alt charHeight is a number" "$(cfg "$TMP/alt" 'typeof c.charHeight + c.charHeight')" "number500"
chk "alt direction" "$(cfg "$TMP/alt" c.direction)" "rtl"
chk "alt palette" "$(cfg "$TMP/alt" '[c.paper,c.charcoal,c.red].join(" ")')" "#fff8e7 #14213d #d62828"
chk "alt total" "$(attr "$TMP/alt" stage data-duration)" "8"
chk "alt s1" "$(attr "$TMP/alt" s1 data-duration)" "8"
chk "Korean is literal UTF-8, no \\u escapes" "$(grep -c '\\u[0-9a-fA-F]\{4\}' "$TMP/alt/index.html")" \
    "$(grep -c '\\u[0-9a-fA-F]\{4\}' "$TPL/index.html")"
grep -q '"word": "샌드위치"' "$TMP/alt/index.html"; chk "literal 샌드위치 in CONFIG" "$?" 0

# 3. --update re-applies on top of the project's own CONFIG
node "$S" text-sandwich "$TMP/alt" --update 'duration=4' >/dev/null
chk "update exit" "$?" 0
chk "update kept word" "$(cfg "$TMP/alt" c.word)" "샌드위치"
chk "update kept image" "$(cfg "$TMP/alt" c.image)" "assets/my char.png"
chk "update resynced total" "$(attr "$TMP/alt" stage data-duration)" "4"
chk "update resynced s1" "$(attr "$TMP/alt" s1 data-duration)" "4"

# 4. refusals (exit 2, nothing written)
: > "$TMP/notes.txt"
node "$S" text-sandwich "$TMP/def" >/dev/null 2>&1; chk "non-empty dir refused" "$?" 2
node "$S" text-sandwich "$TMP/x1" "image=$TMP/missing.png" >/dev/null 2>&1; chk "missing image refused" "$?" 2
node "$S" text-sandwich "$TMP/x2" "image=$TMP/notes.txt" >/dev/null 2>&1; chk "non-png image refused" "$?" 2
node "$S" text-sandwich "$TMP/x3" 'word=ABCDEFGHIJK' >/dev/null 2>&1; chk "11-char word refused" "$?" 2
node "$S" text-sandwich "$TMP/x4" 'word=A' >/dev/null 2>&1; chk "1-char word refused" "$?" 2
node "$S" text-sandwich "$TMP/x5" 'duration=11' >/dev/null 2>&1; chk "duration 11 refused" "$?" 2
node "$S" text-sandwich "$TMP/x6" 'duration=long' >/dev/null 2>&1; chk "non-numeric duration refused" "$?" 2
node "$S" text-sandwich "$TMP/x7" 'direction=up' >/dev/null 2>&1; chk "bad direction refused" "$?" 2
node "$S" text-sandwich "$TMP/x8" 'charHeight=900' >/dev/null 2>&1; chk "charHeight 900 refused" "$?" 2
node "$S" text-sandwich "$TMP/x9" 'red=red' >/dev/null 2>&1; chk "non-hex colour refused" "$?" 2
node "$S" text-sandwich "$TMP/xa" 'wrod=x' >/dev/null 2>&1; chk "unknown key refused" "$?" 2
chk "refused runs wrote nothing" "$(find "$TMP" -maxdepth 1 -name 'x*' | wc -l | tr -d ' ')" "0"
chk "--list includes text-sandwich" "$(node "$S" --list | grep -cx text-sandwich)" "1"
HF_PLUGIN_ROOT="$TMP/none" node "$S" text-sandwich "$TMP/y" >/dev/null 2>&1
chk "missing plugin stops (exit 3)" "$?" 3
chk "missing plugin wrote nothing" "$([ -e "$TMP/y" ] && echo y || echo n)" "n"
exit "$FAIL"
