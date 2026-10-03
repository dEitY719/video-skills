#!/usr/bin/env bash
# Runs every skills/*/scripts/*.selfcheck.sh, so the scaffold and the plugin
# finder are gated by CI rather than by remembering to run them by hand. Each
# is offline: a fake hyperframes plugin, no numpy, no render.
#
# CI entry point: `.github/workflows/validate.yml` calls the reusable workflow
# dEitY719/harness-skills/.github/workflows/skill-check.yml, whose "Repo
# self-checks pass (tests/)" step runs every tracked `tests/*.sh`.
set -euo pipefail
cd -- "$(dirname -- "$0")/.."
shopt -s nullglob
n=0
for f in skills/*/scripts/*.selfcheck.sh; do
    echo "== $f"
    bash "$f"
    n=$((n + 1))
done
[ "$n" -ge 2 ] || { echo "FAIL  only $n selfcheck(s) found - discovery is broken"; exit 1; }
