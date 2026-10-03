#!/usr/bin/env bash
# Guards the seven manifests that carry the version (CLAUDE.md "Version
# bumps") plus the plugin name and the two loaders' skills/ wiring. The shared
# skill-check workflow checks version agreement too; this copy runs offline
# with no PyYAML and also pins what that workflow does not: both loaders must
# register ./skills and the hermes sentinel must name a real skill.
set -euo pipefail
cd -- "$(dirname -- "$0")/.."
fail=0
say() { printf '%s\n' "$*"; }
ver() { node -p "const j=require('./$1'); $2" ; }
declare -A v=(
    [.claude-plugin/marketplace.json]="$(ver .claude-plugin/marketplace.json 'j.plugins[0].version')"
    [.claude-plugin/plugin.json]="$(ver .claude-plugin/plugin.json j.version)"
    [.codex-plugin/plugin.json]="$(ver .codex-plugin/plugin.json j.version)"
    [.kimi-plugin/plugin.json]="$(ver .kimi-plugin/plugin.json j.version)"
    [gemini-extension.json]="$(ver gemini-extension.json j.version)"
    [package.json]="$(ver package.json j.version)"
    [.hermes-plugin/plugin.yaml]="$(sed -n 's/^version:[[:space:]]*//p' .hermes-plugin/plugin.yaml)"
)
want=${v[package.json]}
for f in "${!v[@]}"; do
    if [ "${v[$f]}" = "$want" ]; then say "ok    $f $want"; else say "FAIL  $f has '${v[$f]}', package.json has '$want'"; fail=1; fi
done
[ "${#v[@]}" -eq 7 ] || { say "FAIL  expected 7 versioned manifests, saw ${#v[@]}"; fail=1; }

for f in .claude-plugin/plugin.json .codex-plugin/plugin.json .kimi-plugin/plugin.json gemini-extension.json; do
    [ "$(ver "$f" j.name)" = video ] && say "ok    $f name video" || { say "FAIL  $f name"; fail=1; }
done
grep -q "path.resolve(__dirname, '../../skills')" .opencode/plugins/video.js &&
    say "ok    opencode loader registers ./skills" || { say "FAIL  opencode loader"; fail=1; }
[ "$(node -p "require('./package.json').main")" = .opencode/plugins/video.js ] &&
    say "ok    package.json main -> opencode loader" || { say "FAIL  package.json main"; fail=1; }
sentinel=$(sed -n 's/^_SENTINEL = ("\([^"]*\)", "SKILL.md")$/\1/p' .hermes-plugin/__init__.py)
[ -n "$sentinel" ] && [ -f "skills/$sentinel/SKILL.md" ] &&
    say "ok    hermes sentinel skills/$sentinel/SKILL.md exists" || { say "FAIL  hermes sentinel '$sentinel'"; fail=1; }
exit "$fail"
