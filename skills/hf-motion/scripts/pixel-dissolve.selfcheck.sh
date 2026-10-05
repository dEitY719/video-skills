#!/usr/bin/env bash
# Self-check for scaffold.mjs + the pixel-dissolve recipe. Offline: a fake
# hyperframes plugin supplies GSAP, and --no-music is passed (the recipe is
# silent anyway, so it must not need numpy either way).
#
#   bash skills/hf-motion/scripts/pixel-dissolve.selfcheck.sh
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

# 1. default: the original 6 s cut, switch at 3 s, 1080x830
node "$S" pixel-dissolve "$TMP/def" --no-music >/dev/null
chk "default exit" "$?" 0
chk "default from" "$(cfg "$TMP/def" c.from)" "어제의 나"
chk "default to" "$(cfg "$TMP/def" c.to)" "오늘의 나"
chk "default total" "$(attr "$TMP/def" stage data-duration)" "6"
chk "canvas width" "$(attr "$TMP/def" stage data-width)" "1080"
chk "canvas height" "$(attr "$TMP/def" stage data-height)" "830"
chk "default sA ends at switch" "$(attr "$TMP/def" sA data-duration)" "3"
chk "default sB start" "$(attr "$TMP/def" sB data-start)" "3"
chk "default dissolve start" "$(attr "$TMP/def" dz data-start)" "2.4"
chk "default dissolve length" "$(attr "$TMP/def" dz data-duration)" "1.2"
chk "gsap copied from plugin" "$(cat "$TMP/def/assets/vendor/gsap.min.js")" "/* gsap fixture */"
chk "font bundled" "$([ -s "$TMP/def/assets/fonts/NanumSquare_acEB.ttf" ] && echo y)" "y"
chk "font licence bundled" "$([ -s "$TMP/def/assets/fonts/OFL.txt" ] && echo y)" "y"
chk "silent: no audio element" "$(grep -c '<audio' "$TMP/def/index.html")" "0"
chk "silent: no music file" "$(ls "$TMP/def/assets" | tr '\n' ' ')" "fonts vendor "
chk "no Math.random in template" "$(grep -c 'Math.random' "$TMP/def/index.html")" "0"
chk "recipe.mjs not copied" "$([ -e "$TMP/def/recipe.mjs" ] && echo y || echo n)" "n"
chk "package.json pins plugin version" "$(node -p 'require(process.argv[1]).scripts.render' "$TMP/def/package.json")" "npx --yes hyperframes@9.9.9 render"

# 2. alternate: different text, length, switch point, grid and palette
node "$S" pixel-dissolve "$TMP/alt" --no-music 'from=Before' 'to=작년 겨울의 나는 없다' \
    'duration=8' 'switchAt=4' 'cols=16' 'rows=12' 'paper=#fff8e7' 'charcoal=#0b132b' 'red=#e85d04' >/dev/null
chk "alt exit" "$?" 0
chk "alt from" "$(cfg "$TMP/alt" c.from)" "Before"
chk "alt to" "$(cfg "$TMP/alt" c.to)" "작년 겨울의 나는 없다"
chk "alt duration is a number" "$(cfg "$TMP/alt" 'typeof c.duration + c.duration')" "number8"
chk "alt grid" "$(cfg "$TMP/alt" 'c.cols + "x" + c.rows')" "16x12"
chk "alt palette" "$(cfg "$TMP/alt" 'c.paper + c.charcoal + c.red')" "#fff8e7#0b132b#e85d04"
chk "alt total" "$(attr "$TMP/alt" stage data-duration)" "8"
chk "alt sA = 0..4" "$(attr "$TMP/alt" sA data-start)+$(attr "$TMP/alt" sA data-duration)" "0+4"
chk "alt sB = 4..8" "$(attr "$TMP/alt" sB data-start)+$(attr "$TMP/alt" sB data-duration)" "4+4"
chk "alt dissolve centred on switch" "$(attr "$TMP/alt" dz data-start)" "3.4"
chk "Korean is literal UTF-8, no \\u escapes" "$(grep -c '\\u[0-9a-fA-F]\{4\}' "$TMP/alt/index.html")" "0"
grep -q '"to": "작년 겨울의 나는 없다"' "$TMP/alt/index.html"; chk "literal text in CONFIG" "$?" 0

# 3. --update re-applies on top of the project's own CONFIG
node "$S" pixel-dissolve "$TMP/alt" --update --no-music 'switchAt=5.5' >/dev/null
chk "update exit" "$?" 0
chk "update kept earlier override" "$(cfg "$TMP/alt" c.from)" "Before"
chk "update resynced sB" "$(attr "$TMP/alt" sB data-start)+$(attr "$TMP/alt" sB data-duration)" "5.5+2.5"
chk "update resynced dz" "$(attr "$TMP/alt" dz data-start)" "4.9"

# 4. refusals (exit 2, nothing written)
node "$S" pixel-dissolve "$TMP/def" --no-music >/dev/null 2>&1; chk "non-empty dir refused" "$?" 2
node "$S" pixel-dissolve "$TMP/x1" --no-music 'form=x' >/dev/null 2>&1; chk "unknown key refused" "$?" 2
node "$S" pixel-dissolve "$TMP/x2" --no-music 'duration=11' >/dev/null 2>&1; chk "duration > 10 refused" "$?" 2
node "$S" pixel-dissolve "$TMP/x3" --no-music 'switchAt=5.5' >/dev/null 2>&1; chk "switchAt past duration-1 refused" "$?" 2
node "$S" pixel-dissolve "$TMP/x4" --no-music 'cols=12.5' >/dev/null 2>&1; chk "non-integer cols refused" "$?" 2
node "$S" pixel-dissolve "$TMP/x5" --no-music 'red=red' >/dev/null 2>&1; chk "non-hex colour refused" "$?" 2
node "$S" pixel-dissolve "$TMP/x6" --no-music 'red=#fca311' >/dev/null 2>&1; chk "red under 3:1 on paper refused" "$?" 2
node "$S" pixel-dissolve "$TMP/x7" --no-music 'from= ' >/dev/null 2>&1; chk "blank text refused" "$?" 2
chk "refused runs wrote nothing" "$(find "$TMP" -maxdepth 1 -name 'x*' | wc -l | tr -d ' ')" "0"
chk "--list includes pixel-dissolve" "$(node "$S" --list | grep -cx pixel-dissolve)" "1"
HF_PLUGIN_ROOT="$TMP/none" node "$S" pixel-dissolve "$TMP/y" --no-music >/dev/null 2>&1
chk "missing plugin stops (exit 3)" "$?" 3
chk "missing plugin wrote nothing" "$([ -e "$TMP/y" ] && echo y || echo n)" "n"
exit "$FAIL"
