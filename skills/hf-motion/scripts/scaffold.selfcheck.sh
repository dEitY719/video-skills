#!/usr/bin/env bash
# Self-check for scaffold.mjs + the intro-kinetic recipe. Offline: a fake
# hyperframes plugin supplies the copied assets, and --no-music skips numpy.
#
#   bash skills/hf-motion/scripts/scaffold.selfcheck.sh
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
mkdir -p "$P/skills/hyperframes/scripts" "$P/skills/demo/assets/vendor" "$P/skills/media-use/audio/assets/sfx"
: > "$P/skills/hyperframes/scripts/plugin-cli.mjs"
echo '/* gsap fixture */' > "$P/skills/demo/assets/vendor/gsap.min.js"
: > "$P/skills/media-use/audio/assets/sfx/impact-bass-1.mp3"
: > "$P/skills/media-use/audio/assets/sfx/whoosh-short.mp3"
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

# 1. default: timing identical to the original 15 s / 120 BPM cut
node "$S" intro-kinetic "$TMP/def" --no-music >/dev/null
chk "default exit" "$?" 0
chk "default name" "$(cfg "$TMP/def" c.name)" "윤병우"
chk "default total" "$(attr "$TMP/def" stage data-duration)" "15"
chk "default s6 start" "$(attr "$TMP/def" s6 data-start)" "11"
chk "default whoosh-4" "$(attr "$TMP/def" sfx-whoosh-4 data-start)" "8.7"
chk "gsap copied from plugin" "$(cat "$TMP/def/assets/vendor/gsap.min.js")" "/* gsap fixture */"
chk "font bundled" "$([ -s "$TMP/def/assets/fonts/NanumSquare_acEB.ttf" ] && echo y)" "y"
chk "recipe.mjs not copied" "$([ -e "$TMP/def/recipe.mjs" ] && echo y || echo n)" "n"
chk "package.json pins plugin version" "$(node -p 'require(process.argv[1]).scripts.render' "$TMP/def/package.json")" "npx --yes hyperframes@9.9.9 render"

# 2. alternate: different text, counts, palette and tempo
node "$S" intro-kinetic "$TMP/alt" --no-music 'name=홍길동' 'team=가나다팀' 'subsTarget=123000' \
    'tools=Notion Kit|Daily Log' 'flash=습관|기록|성장' 'finale=평범한 직장인이 알려주는|[돈과 시간]을 버는|[작은 습관] 하나' \
    'red=#ff5a1f' 'bpm=116' >/dev/null
chk "alt exit" "$?" 0
chk "alt name" "$(cfg "$TMP/alt" c.name)" "홍길동"
chk "alt team" "$(cfg "$TMP/alt" c.team)" "가나다팀"
chk "alt subsTarget is a number" "$(cfg "$TMP/alt" 'typeof c.subsTarget + c.subsTarget')" "number123000"
chk "alt tools list" "$(cfg "$TMP/alt" 'c.tools.join("/")')" "Notion Kit/Daily Log"
chk "alt flash count" "$(cfg "$TMP/alt" c.flash.length)" "3"
chk "alt finale comma kept inside item" "$(cfg "$TMP/alt" 'c.finale[1]')" "[돈과 시간]을 버는"
chk "alt palette" "$(cfg "$TMP/alt" c.red)" "#ff5a1f"
chk "alt untouched key keeps default" "$(cfg "$TMP/alt" c.employer)" "삼성 시니어 엔지니어"
chk "alt total = 29 beats @116" "$(attr "$TMP/alt" stage data-duration)" "15"
chk "alt s5 = 3 beats" "$(attr "$TMP/alt" s5 data-duration)" "1.551724"
chk "alt finale impact follows s6" "$(attr "$TMP/alt" sfx-impact-finale data-start)" "$(attr "$TMP/alt" s6 data-start)"
chk "alt music = total" "$(attr "$TMP/alt" music data-duration)" "15"
chk "Korean is literal UTF-8, no \\u escapes" "$(grep -c '\\u[0-9a-fA-F]\{4\}' "$TMP/alt/index.html")" \
    "$(grep -c '\\u[0-9a-fA-F]\{4\}' "$HERE/../templates/intro-kinetic/index.html")"
grep -q '"name": "홍길동"' "$TMP/alt/index.html"; chk "literal 홍길동 in CONFIG" "$?" 0

# 3. --update re-applies on top of the project's own CONFIG
node "$S" intro-kinetic "$TMP/alt" --update --no-music 'flash=하나|둘' >/dev/null
chk "update exit" "$?" 0
chk "update kept earlier override" "$(cfg "$TMP/alt" c.name)" "홍길동"
chk "update resynced s5" "$(attr "$TMP/alt" s5 data-duration)" "1.034483"

# 4. refusals
node "$S" intro-kinetic "$TMP/def" --no-music >/dev/null 2>&1; chk "non-empty dir refused" "$?" 2
node "$S" intro-kinetic "$TMP/x1" --no-music 'nmae=x' >/dev/null 2>&1; chk "unknown key refused" "$?" 2
node "$S" intro-kinetic "$TMP/x2" --no-music 'tools=a|b|c|d' >/dev/null 2>&1; chk "4 tools refused" "$?" 2
node "$S" intro-kinetic "$TMP/x3" --no-music 'bpm=fast' >/dev/null 2>&1; chk "non-numeric bpm refused" "$?" 2
node "$S" intro-kinetic "$TMP/x4" --no-music 'red=red' >/dev/null 2>&1; chk "non-hex colour refused" "$?" 2
chk "refused runs wrote nothing" "$(find "$TMP" -maxdepth 1 -name 'x*' | wc -l | tr -d ' ')" "0"
node "$S" pixel-dissolve "$TMP/x5" >/dev/null 2>&1; chk "planned recipe refused" "$?" 2
chk "--list = implemented only" "$(node "$S" --list)" "intro-kinetic"
HF_PLUGIN_ROOT="$TMP/none" node "$S" intro-kinetic "$TMP/y" --no-music >/dev/null 2>&1
chk "missing plugin stops (exit 3)" "$?" 3
chk "missing plugin wrote nothing" "$([ -e "$TMP/y" ] && echo y || echo n)" "n"
exit "$FAIL"
