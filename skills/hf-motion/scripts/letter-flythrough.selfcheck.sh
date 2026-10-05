#!/usr/bin/env bash
# Self-check for scaffold.mjs + the letter-flythrough recipe. Offline: a fake
# hyperframes plugin supplies GSAP; the recipe is silent, --no-music is a no-op.
#
#   bash skills/hf-motion/scripts/letter-flythrough.selfcheck.sh
#
# Scaffolds the default and an alternate config into temp dirs and asserts the
# alternate CONFIG, its static timing attributes and its literal UTF-8 text all
# took effect, then exercises the refusal paths.
set -u
HERE="$(cd -- "$(dirname -- "$0")" && pwd)"
S="$HERE/scaffold.mjs"
R=letter-flythrough
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

# 1. default: the original 6 s cut, 1080x830
node "$S" "$R" "$TMP/def" --no-music >/dev/null
chk "default exit" "$?" 0
chk "default word" "$(cfg "$TMP/def" c.word)" "AI"
chk "default next" "$(cfg "$TMP/def" c.next)" "프롬프트 한 줄"
chk "default total" "$(attr "$TMP/def" stage data-duration)" "6"
chk "default canvas" "$(attr "$TMP/def" stage data-width)x$(attr "$TMP/def" stage data-height)" "1080x830"
chk "default scene window" "$(attr "$TMP/def" scene data-start)+$(attr "$TMP/def" scene data-duration)" "0+6"
chk "default landing window" "$(attr "$TMP/def" s2 data-start)+$(attr "$TMP/def" s2 data-duration)" "4+2"
chk "gsap copied from plugin" "$(cat "$TMP/def/assets/vendor/gsap.min.js")" "/* gsap fixture */"
chk "font bundled" "$([ -s "$TMP/def/assets/fonts/NanumSquare_acEB.ttf" ] && [ -s "$TMP/def/assets/fonts/OFL.txt" ] && echo y)" "y"
chk "silent: no audio element" "$(grep -c '<audio' "$TMP/def/index.html")" "0"
chk "silent: no sfx/music copied" "$([ -e "$TMP/def/assets/sfx" ] || [ -e "$TMP/def/assets/music.wav" ] && echo y || echo n)" "n"
chk "recipe.mjs not copied" "$([ -e "$TMP/def/recipe.mjs" ] && echo y || echo n)" "n"
chk "package.json pins plugin version" "$(node -p 'require(process.argv[1]).scripts.render' "$TMP/def/package.json")" "npx --yes hyperframes@9.9.9 render"

# 2. alternate: Hangul word, other text, longer cut, other palette
node "$S" "$R" "$TMP/alt" --no-music 'word=한글' 'next=다음 장면 시작' 'target=0' \
    'duration=8' 'diveStart=2' 'diveLength=3' 'paper=#fbf7ee' 'charcoal=#14213d' 'red=#d62828' >/dev/null
chk "alt exit" "$?" 0
chk "alt word" "$(cfg "$TMP/alt" c.word)" "한글"
chk "alt next" "$(cfg "$TMP/alt" c.next)" "다음 장면 시작"
chk "alt duration is a number" "$(cfg "$TMP/alt" 'typeof c.duration + c.duration')" "number8"
chk "alt palette" "$(cfg "$TMP/alt" '[c.paper,c.charcoal,c.red].join(" ")')" "#fbf7ee #14213d #d62828"
chk "alt total" "$(attr "$TMP/alt" stage data-duration)" "8"
chk "alt scene = total" "$(attr "$TMP/alt" scene data-duration)" "8"
chk "alt landing = dive end" "$(attr "$TMP/alt" s2 data-start)+$(attr "$TMP/alt" s2 data-duration)" "5+3"
chk "Korean is literal UTF-8, no \\u escapes" "$(grep -c '\\u[0-9a-fA-F]\{4\}' "$TMP/alt/index.html")" \
    "$(grep -c '\\u[0-9a-fA-F]\{4\}' "$HERE/../templates/$R/index.html")"
grep -q '"next": "다음 장면 시작"' "$TMP/alt/index.html"; chk "literal 다음 장면 시작 in CONFIG" "$?" 0

# 3. --update re-applies on top of the project's own CONFIG
node "$S" "$R" "$TMP/alt" --update --no-music 'diveLength=2.5' >/dev/null
chk "update exit" "$?" 0
chk "update kept earlier override" "$(cfg "$TMP/alt" c.word)" "한글"
chk "update resynced landing" "$(attr "$TMP/alt" s2 data-start)+$(attr "$TMP/alt" s2 data-duration)" "4.5+3.5"

# 4. refusals
node "$S" "$R" "$TMP/def" --no-music >/dev/null 2>&1; chk "non-empty dir refused" "$?" 2
node "$S" "$R" "$TMP/x1" --no-music 'wrod=x' >/dev/null 2>&1; chk "unknown key refused" "$?" 2
node "$S" "$R" "$TMP/x2" --no-music 'word=ABCDEFG' >/dev/null 2>&1; chk "7-letter word refused" "$?" 2
node "$S" "$R" "$TMP/x3" --no-music 'target=1' >/dev/null 2>&1; chk "counterless target (I) refused" "$?" 2
node "$S" "$R" "$TMP/x4" --no-music 'target=2' >/dev/null 2>&1; chk "target past the word refused" "$?" 2
node "$S" "$R" "$TMP/x5" --no-music 'duration=11' >/dev/null 2>&1; chk "duration 11 refused" "$?" 2
node "$S" "$R" "$TMP/x6" --no-music 'duration=long' >/dev/null 2>&1; chk "non-numeric duration refused" "$?" 2
node "$S" "$R" "$TMP/x7" --no-music 'diveStart=4' >/dev/null 2>&1; chk "dive past the landing refused" "$?" 2
node "$S" "$R" "$TMP/x8" --no-music 'diveStart=0.2' >/dev/null 2>&1; chk "dive before the word lands refused" "$?" 2
node "$S" "$R" "$TMP/x9" --no-music 'next=이 줄은 열여섯 글자를 훌쩍 넘깁니다' >/dev/null 2>&1; chk "17+ char next refused" "$?" 2
node "$S" "$R" "$TMP/xa" --no-music 'red=red' >/dev/null 2>&1; chk "non-hex colour refused" "$?" 2
chk "refused runs wrote nothing" "$(find "$TMP" -maxdepth 1 -name 'x*' | wc -l | tr -d ' ')" "0"
chk "--list includes $R" "$(node "$S" --list | grep -cx "$R")" "1"
HF_PLUGIN_ROOT="$TMP/none" node "$S" "$R" "$TMP/y" --no-music >/dev/null 2>&1
chk "missing plugin stops (exit 3)" "$?" 3
chk "missing plugin wrote nothing" "$([ -e "$TMP/y" ] && echo y || echo n)" "n"
exit "$FAIL"
