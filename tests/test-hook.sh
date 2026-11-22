#!/usr/bin/env bash
# Проверка хука start.sh. Запуск: bash tests/test-hook.sh
set -u
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
HOOK="$ROOT/plugins/isanagge/hooks/start.sh"
TMP="$ROOT/tests/tmp/hook"
rm -rf "$TMP"; mkdir -p "$TMP"
fail=0
check() { # имя, вывод, ожидаемая подстрока
  if printf '%s' "$2" | grep -qF -- "$3"; then echo "PASS: $1"; else echo "FAIL: $1 (нет «$3»)"; fail=1; fi
}

# а) метки нет
H1="$TMP/h1"; mkdir -p "$H1"
out=$(HOME="$H1" CLAUDE_PLUGIN_ROOT="$ROOT/plugins/isanagge" bash "$HOOK")
check "нет метки → предлагает start" "$out" "isanagge:start"
check "показывает версию" "$out" "0.1.0"

# б) метка + папка с кириллицей и пробелом
H2="$TMP/h2"; BRAIN="$TMP/Мои документы/Второй мозг"; mkdir -p "$H2/.isanagge" "$BRAIN"
printf '{"brain":"%s"}\n' "$BRAIN" > "$H2/.isanagge/config.json"
out=$(HOME="$H2" CLAUDE_PLUGIN_ROOT="$ROOT/plugins/isanagge" bash "$HOOK")
check "метка есть → путь" "$out" "$BRAIN"
check "метка есть → CLAUDE.md" "$out" "CLAUDE.md"

# в) метка есть, папки нет
H3="$TMP/h3"; mkdir -p "$H3/.isanagge"
printf '{"brain":"%s"}\n' "$TMP/нет такой папки" > "$H3/.isanagge/config.json"
out=$(HOME="$H3" CLAUDE_PLUGIN_ROOT="$ROOT/plugins/isanagge" bash "$HOOK")
check "папки нет → снова start" "$out" "isanagge:start"

exit $fail
