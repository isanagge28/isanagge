#!/usr/bin/env bash
# Ищет личные данные автора и секреты во всём, что уйдёт в публикацию. Ожидание: 0 находок.
set -u
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"
PATTERNS='ai09kgz|Users[/\]ISA([/\]|$)|nurzhannat|wb312bot|45\.94\.67\.90|[Cc]ontabo|Жолдошев|RamisGit|sk-ant-[A-Za-z0-9]|ghp_[A-Za-z0-9]{20}|xox[bp]-[0-9]|AKIA[0-9A-Z]{16}|-----BEGIN [A-Z ]*PRIVATE KEY'
hits=$(git ls-files -co --exclude-standard | grep -v '^tests/scan-private.sh$' | tr '\n' '\0' | xargs -0 grep -nIE "$PATTERNS" 2>/dev/null)
if [ -n "$hits" ]; then echo "FAIL: найдено личное/секреты:"; echo "$hits"; exit 1; fi
echo "PASS: личных данных и секретов не найдено ($(git ls-files -co --exclude-standard | wc -l) файлов)"
