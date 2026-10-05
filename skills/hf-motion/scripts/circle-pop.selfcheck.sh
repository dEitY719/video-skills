#!/usr/bin/env bash
# Self-check for scaffold.mjs + the circle-pop recipe. Offline: a fake
# hyperframes plugin supplies GSAP, and --no-music is passed for symmetry
# (circle-pop is silent anyway).
#
#   bash skills/hf-motion/scripts/circle-pop.selfcheck.sh
#
# Scaffolds the default and an alternate config into temp dirs and asserts the
# CONFIG, the static timing attributes and the literal UTF-8 text, then
# exercises the refusal paths.
set -u
HERE="$(cd -- "$(dirname -- "$0")" && pwd)"
S="$HERE/scaffold.mjs"
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

# 1. default: the original 6 s cut at 3 s
node "$S" circle-pop "$TMP/def" --no-music >/dev/null
chk "default exit" "$?" 0
chk "default from" "$(cfg "$TMP/def" c.from)" "아이디어"
chk "default to" "$(cfg "$TMP/def" c.to)" "완성된 영상"
chk "default total" "$(attr "$TMP/def" stage data-duration)" "6"
chk "default canvas" "$(attr "$TMP/def" stage data-width)x$(attr "$TMP/def" stage data-height)" "1080x830"
chk "default s1 window" "$(attr "$TMP/def" s1 data-start)/$(attr "$TMP/def" s1 data-duration)" "0/3"
chk "default s2 window" "$(attr "$TMP/def" s2 data-start)/$(attr "$TMP/def" s2 data-duration)" "3/3"
chk "gsap copied from plugin" "$(cat "$TMP/def/assets/vendor/gsap.min.js")" "/* gsap fixture */"
chk "font copied from _shared" "$([ -s "$TMP/def/assets/fonts/NanumSquare_acEB.ttf" ] && [ -s "$TMP/def/assets/fonts/OFL.txt" ] && echo y)" "y"
chk "no audio element (silent)" "$(grep -c '<audio' "$TMP/def/index.html")" "0"
chk "no music generated" "$([ -e "$TMP/def/assets/music.wav" ] && echo y || echo n)" "n"
chk "recipe.mjs not copied" "$([ -e "$TMP/def/recipe.mjs" ] && echo y || echo n)" "n"
chk "package.json pins plugin version" "$(node -p 'require(process.argv[1]).scripts.render' "$TMP/def/package.json")" "npx --yes hyperframes@9.9.9 render"

# 2. alternate: different text, length, cut and palette
node "$S" circle-pop "$TMP/alt" --no-music 'from=초안' 'to=Final Cut' 'duration=8' 'switchAt=4' \
    'paper=#ffffff' 'charcoal=#102030' 'red=#d94a00' >/dev/null
chk "alt exit" "$?" 0
chk "alt from" "$(cfg "$TMP/alt" c.from)" "초안"
chk "alt to keeps space" "$(cfg "$TMP/alt" c.to)" "Final Cut"
chk "alt duration is a number" "$(cfg "$TMP/alt" 'typeof c.duration + c.duration')" "number8"
chk "alt palette" "$(cfg "$TMP/alt" '[c.paper,c.charcoal,c.red].join(",")')" "#ffffff,#102030,#d94a00"
chk "alt total" "$(attr "$TMP/alt" stage data-duration)" "8"
chk "alt s1 window" "$(attr "$TMP/alt" s1 data-start)/$(attr "$TMP/alt" s1 data-duration)" "0/4"
chk "alt s2 window" "$(attr "$TMP/alt" s2 data-start)/$(attr "$TMP/alt" s2 data-duration)" "4/4"
chk "Korean is literal UTF-8, no \\u escapes" "$(grep -c '\\u[0-9a-fA-F]\{4\}' "$TMP/alt/index.html")" "0"
grep -q '"from": "초안"' "$TMP/alt/index.html"; chk "literal 초안 in CONFIG" "$?" 0

# 3. --update re-applies on top of the project's own CONFIG
node "$S" circle-pop "$TMP/alt" --update --no-music 'switchAt=2.5' >/dev/null
chk "update exit" "$?" 0
chk "update kept earlier override" "$(cfg "$TMP/alt" c.from)" "초안"
chk "update resynced s2" "$(attr "$TMP/alt" s2 data-start)/$(attr "$TMP/alt" s2 data-duration)" "2.5/5.5"

# 4. refusals (exit 2, nothing written)
node "$S" circle-pop "$TMP/def" --no-music >/dev/null 2>&1; chk "non-empty dir refused" "$?" 2
node "$S" circle-pop "$TMP/x1" --no-music 'form=x' >/dev/null 2>&1; chk "unknown key refused" "$?" 2
node "$S" circle-pop "$TMP/x2" --no-music 'duration=12' >/dev/null 2>&1; chk "duration > 10 refused" "$?" 2
node "$S" circle-pop "$TMP/x3" --no-music 'switchAt=5.5' >/dev/null 2>&1; chk "scene 2 < 1 s refused" "$?" 2
node "$S" circle-pop "$TMP/x4" --no-music 'switchAt=soon' >/dev/null 2>&1; chk "non-numeric switchAt refused" "$?" 2
node "$S" circle-pop "$TMP/x5" --no-music 'red=red' >/dev/null 2>&1; chk "non-hex colour refused" "$?" 2
node "$S" circle-pop "$TMP/x6" --no-music 'red=#e0e0e0' >/dev/null 2>&1; chk "low-contrast red refused" "$?" 2
node "$S" circle-pop "$TMP/x7" --no-music 'to= ' >/dev/null 2>&1; chk "blank text refused" "$?" 2
chk "refused runs wrote nothing" "$(find "$TMP" -maxdepth 1 -name 'x*' | wc -l | tr -d ' ')" "0"
chk "--list includes circle-pop" "$(node "$S" --list | grep -cx circle-pop)" "1"
HF_PLUGIN_ROOT="$TMP/none" node "$S" circle-pop "$TMP/y" --no-music >/dev/null 2>&1
chk "missing plugin stops (exit 3)" "$?" 3
chk "missing plugin wrote nothing" "$([ -e "$TMP/y" ] && echo y || echo n)" "n"
exit "$FAIL"
