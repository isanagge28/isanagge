#!/usr/bin/env bash
# У каждого навыка плагина: SKILL.md с name = имя папки и непустым description.
set -u
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
fail=0; n=0
for d in "$ROOT"/plugins/isanagge/skills/*/; do
  s=$(basename "$d"); f="$d/SKILL.md"; n=$((n+1))
  [ -f "$f" ] || { echo "FAIL: $s — нет SKILL.md"; fail=1; continue; }
  name=$(sed -n '2,15p' "$f" | sed -n 's/^name:[[:space:]]*//p' | head -1 | tr -d '"\r')
  desc=$(sed -n '2,30p' "$f" | grep -m1 '^description:' | sed 's/^description:[[:space:]]*//' | tr -d '\r')
  head -1 "$f" | grep -q '^---' || { echo "FAIL: $s — нет frontmatter"; fail=1; continue; }
  [ "$name" = "$s" ] || { echo "FAIL: $s — name='$name'"; fail=1; continue; }
  [ -n "$desc" ] || { echo "FAIL: $s — пустой description"; fail=1; continue; }
done
for s in "$@"; do [ -f "$ROOT/plugins/isanagge/skills/$s/SKILL.md" ] || { echo "FAIL: нет навыка $s"; fail=1; }; done
[ $fail = 0 ] && echo "PASS: $n навыков в порядке"
exit $fail
