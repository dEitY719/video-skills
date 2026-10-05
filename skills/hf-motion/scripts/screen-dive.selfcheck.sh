#!/usr/bin/env bash
# Self-check for scaffold.mjs + the screen-dive recipe. Offline: a fake
# hyperframes plugin supplies GSAP, and --no-music is passed for symmetry
# (the recipe is silent and has no music bed).
#
#   bash skills/hf-motion/scripts/screen-dive.selfcheck.sh
#
# Scaffolds the default and an alternate config into temp dirs and asserts the
# alternate CONFIG, its static timing attributes and its literal UTF-8 text all
# took effect, then exercises the refusal paths.
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

# 1. default: the original 6 s, 1080x830 cut
node "$S" screen-dive "$TMP/def" --no-music >/dev/null
chk "default exit" "$?" 0
chk "default screenText" "$(cfg "$TMP/def" c.screenText)" "모션 그래픽"
chk "default total" "$(attr "$TMP/def" stage data-duration)" "6"
chk "default s1 window" "$(attr "$TMP/def" s1 data-start)/$(attr "$TMP/def" s1 data-duration)" "0/6"
chk "canvas 1080x830" "$(attr "$TMP/def" stage data-width)x$(attr "$TMP/def" stage data-height)" "1080x830"
chk "gsap copied from plugin" "$(cat "$TMP/def/assets/vendor/gsap.min.js")" "/* gsap fixture */"
chk "font from _shared" "$([ -s "$TMP/def/assets/fonts/NanumSquare_acEB.ttf" ] && [ -s "$TMP/def/assets/fonts/OFL.txt" ] && echo y)" "y"
chk "silent: no audio element" "$(grep -c '<audio' "$TMP/def/index.html")" "0"
chk "silent: no sfx copied" "$([ -e "$TMP/def/assets/sfx" ] && echo y || echo n)" "n"
chk "recipe.mjs not copied" "$([ -e "$TMP/def/recipe.mjs" ] && echo y || echo n)" "n"
chk "package.json pins plugin version" "$(node -p 'require(process.argv[1]).scripts.render' "$TMP/def/package.json")" "npx --yes hyperframes@9.9.9 render"

# 2. alternate: different text, caption, length, dive timing and palette
node "$S" screen-dive "$TMP/alt" --no-music 'screenText=화면 속으로' 'caption=노트북, 그리고 그 안' \
    'duration=8' 'diveStart=2' 'diveDur=2.2' 'paper=#ffffff' 'charcoal=#102030' 'red=#d4202a' >/dev/null
chk "alt exit" "$?" 0
chk "alt screenText" "$(cfg "$TMP/alt" c.screenText)" "화면 속으로"
chk "alt caption keeps comma" "$(cfg "$TMP/alt" c.caption)" "노트북, 그리고 그 안"
chk "alt duration is a number" "$(cfg "$TMP/alt" 'typeof c.duration + c.duration')" "number8"
chk "alt diveDur" "$(cfg "$TMP/alt" c.diveDur)" "2.2"
chk "alt palette" "$(cfg "$TMP/alt" 'c.paper+c.charcoal+c.red')" "#ffffff#102030#d4202a"
chk "alt total" "$(attr "$TMP/alt" stage data-duration)" "8"
chk "alt s1 = total" "$(attr "$TMP/alt" s1 data-duration)" "8"
chk "Korean is literal UTF-8, no \\u escapes" "$(grep -c '\\u[0-9a-fA-F]\{4\}' "$TMP/alt/index.html")" "0"
grep -q '"screenText": "화면 속으로"' "$TMP/alt/index.html"; chk "literal 화면 속으로 in CONFIG" "$?" 0

# 3. --update re-applies on top of the project's own CONFIG
node "$S" screen-dive "$TMP/alt" --update --no-music 'duration=5' 'diveStart=1.2' 'diveDur=1' >/dev/null
chk "update exit" "$?" 0
chk "update kept earlier override" "$(cfg "$TMP/alt" c.screenText)" "화면 속으로"
chk "update resynced total" "$(attr "$TMP/alt" stage data-duration)/$(attr "$TMP/alt" s1 data-duration)" "5/5"

# 4. refusals
node "$S" screen-dive "$TMP/def" --no-music >/dev/null 2>&1; chk "non-empty dir refused" "$?" 2
node "$S" screen-dive "$TMP/x1" --no-music 'title=x' >/dev/null 2>&1; chk "unknown key refused" "$?" 2
node "$S" screen-dive "$TMP/x2" --no-music 'screenText=가나다라마바사아자차카타파' >/dev/null 2>&1; chk "13-char screenText refused" "$?" 2
node "$S" screen-dive "$TMP/x3" --no-music 'screenText= ' >/dev/null 2>&1; chk "blank screenText refused" "$?" 2
node "$S" screen-dive "$TMP/x4" --no-music 'duration=11' >/dev/null 2>&1; chk "duration 11 refused" "$?" 2
node "$S" screen-dive "$TMP/x5" --no-music 'duration=long' >/dev/null 2>&1; chk "non-numeric duration refused" "$?" 2
node "$S" screen-dive "$TMP/x6" --no-music 'diveStart=0.5' >/dev/null 2>&1; chk "dive before intro refused" "$?" 2
node "$S" screen-dive "$TMP/x7" --no-music 'duration=3' >/dev/null 2>&1; chk "dive + hold past end refused" "$?" 2
node "$S" screen-dive "$TMP/x8" --no-music 'red=red' >/dev/null 2>&1; chk "non-hex colour refused" "$?" 2
node "$S" screen-dive "$TMP/x9" --no-music 'red=#e8e4dc' >/dev/null 2>&1; chk "low-contrast red refused" "$?" 2
chk "refused runs wrote nothing" "$(find "$TMP" -maxdepth 1 -name 'x*' | wc -l | tr -d ' ')" "0"
chk "--list includes screen-dive" "$(node "$S" --list | grep -cx screen-dive)" "1"
HF_PLUGIN_ROOT="$TMP/none" node "$S" screen-dive "$TMP/y" --no-music >/dev/null 2>&1
chk "missing plugin stops (exit 3)" "$?" 3
chk "missing plugin wrote nothing" "$([ -e "$TMP/y" ] && echo y || echo n)" "n"
exit "$FAIL"
