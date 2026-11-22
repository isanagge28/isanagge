#!/usr/bin/env bash
# Isana: подсказка Claude при старте сессии.
# Только читает. Ничего не пишет, не ставит и не ходит в интернет.
ROOT="${CLAUDE_PLUGIN_ROOT:-$(cd "$(dirname "$0")/.." && pwd)}"
VER=$(sed -n 's/.*"version"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' "$ROOT/.claude-plugin/plugin.json" 2>/dev/null | head -1)
CFG="$HOME/.isanagge/config.json"
BRAIN=""
if [ -f "$CFG" ]; then
  BRAIN=$(sed -n 's/.*"brain"[[:space:]]*:[[:space:]]*"\(.*\)".*/\1/p' "$CFG" | head -1 | sed 's/\\\\/\\/g')
fi

echo "[Isana ${VER:-?}] Плагин isanagge (Второй мозг) включён. На вопрос «какая версия Isana» отвечай: ${VER:-?}."
if [ -n "$BRAIN" ] && [ -d "$BRAIN" ]; then
  echo "Второй мозг человека лежит здесь: $BRAIN"
  echo "Перед работой прочитай $BRAIN/CLAUDE.md и $BRAIN/index.md. Новые проекты создавай в $BRAIN/Проекты/ (навык isanagge:novyy-proekt). Уроки и ошибки записывай в $BRAIN/feedback.md. Удачный приём предложи сохранить навыком (isanagge:zapomni-priem). Голосовые и аудио расшифровывай навыком isanagge:rasshifrovka."
else
  echo "Второго мозга у человека ещё нет. В первом ответе поздоровайся и предложи создать папку «Второй мозг» — вызови навык isanagge:start. Ничего не создавай без согласия."
fi
exit 0
