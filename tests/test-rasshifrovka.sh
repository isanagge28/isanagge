#!/usr/bin/env bash
# Проверка rasshifrovka.py. Запуск: bash tests/test-rasshifrovka.sh [модель]
set -u
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
PY=$(command -v python || command -v python3)
SCRIPT="$ROOT/plugins/isanagge/skills/rasshifrovka/rasshifrovka.py"
TMP="$ROOT/tests/tmp/rasshifrovka"; rm -rf "$TMP"; mkdir -p "$TMP/Голос с пробелом"
MODEL="${1:-small}"
fail=0

# 1) нет файла → код 2
"$PY" "$SCRIPT" "$TMP/нет-такого.ogg" >/dev/null 2>&1; code=$?
[ $code = 2 ] && echo "PASS: нет файла → код 2" || { echo "FAIL: нет файла → код $code"; fail=1; }

# 2) английская речь (Windows System.Speech) → текст
WAV="$TMP/Голос с пробелом/привет.wav"
if command -v powershell >/dev/null 2>&1; then
  WWAV=$(cygpath -w "$WAV")
  powershell -NoProfile -Command "Add-Type -AssemblyName System.Speech; \$s=New-Object System.Speech.Synthesis.SpeechSynthesizer; \$s.SetOutputToWaveFile('$WWAV'); \$s.Speak('Hello world. This is a test of the voice transcription.'); \$s.Dispose()" >/dev/null
fi
if [ -f "$WAV" ]; then
  # переводим в .ogg, как приходят голосовые из Telegram
  OGG="${WAV%.wav}.ogg"; ffmpeg -loglevel error -y -i "$WAV" -c:a libopus "$OGG"
  out=$("$PY" "$SCRIPT" "$OGG" --model "$MODEL" 2>/dev/null); code=$?
  echo "$out" | grep -qi "hello" && echo "PASS: .ogg расшифрован ($MODEL)" || { echo "FAIL: нет «hello» (код $code): $out"; fail=1; }
  [ -f "$OGG.txt" ] && echo "PASS: текст сохранён рядом" || { echo "FAIL: нет $OGG.txt"; fail=1; }
else
  echo "SKIP: нет синтеза речи (не Windows)"
fi
exit $fail
