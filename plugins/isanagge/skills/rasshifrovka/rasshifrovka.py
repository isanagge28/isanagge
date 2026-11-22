#!/usr/bin/env python3
"""Isana: расшифровка голосовых, аудио и видео в текст через Whisper (faster-whisper).

Бесплатно, работает на своём компьютере. Интернет нужен только один раз —
скачать модель (small ≈ 0,5 ГБ, large-v3 ≈ 3 ГБ).

Запуск:  python rasshifrovka.py <файл> [--model auto|tiny|base|small|medium|large-v3] [--language ru]
Вывод:   текст в stdout; копия в <файл>.txt рядом.
Коды:    0 — готово; 2 — нет файла; 3 — не установлен faster-whisper; 4 — не удалось расшифровать.
"""
import argparse
import os
import sys


def say(msg: str) -> None:
    print(msg, file=sys.stderr)


def pick_device(model_arg: str):
    """Вернуть список вариантов (модель, устройство, точность) по порядку попыток."""
    cuda = False
    try:
        import ctranslate2
        cuda = ctranslate2.get_cuda_device_count() > 0
    except Exception:
        cuda = False
    if model_arg == "auto":
        tries = []
        if cuda:
            tries.append(("large-v3", "cuda", "float16"))
        tries.append(("small", "cpu", "int8"))
        return tries
    tries = []
    if cuda:
        tries.append((model_arg, "cuda", "float16"))
    tries.append((model_arg, "cpu", "int8"))
    return tries


def main() -> int:
    for stream in (sys.stdout, sys.stderr):
        try:
            stream.reconfigure(encoding="utf-8")
        except Exception:
            pass

    p = argparse.ArgumentParser(description="Расшифровка голосовых в текст (Whisper)")
    p.add_argument("file", help="голосовое/аудио/видео: .ogg .oga .opus .mp3 .m4a .wav .mp4 .webm …")
    p.add_argument("--model", default="auto", help="auto (по умолчанию), tiny, base, small, medium, large-v3")
    p.add_argument("--language", default=None, help="язык, например ru; по умолчанию определяется сам")
    args = p.parse_args()

    path = os.path.abspath(args.file)
    if not os.path.isfile(path):
        say(f"Файл не найден: {path}")
        return 2

    try:
        from faster_whisper import WhisperModel
    except ImportError:
        say("Не установлен faster-whisper. Поставь: python -m pip install faster-whisper")
        return 3

    last_err = None
    for model_name, device, compute in pick_device(args.model):
        try:
            model = WhisperModel(model_name, device=device, compute_type=compute)
            segments, info = model.transcribe(
                path, language=args.language, beam_size=5, vad_filter=True
            )
            text = " ".join(s.text.strip() for s in segments).strip()
            break
        except Exception as e:  # нет видеокарты/драйверов, нет интернета для первой загрузки и т. п.
            last_err = e
            continue
    else:
        say(f"Не удалось расшифровать: {last_err}")
        return 4

    with open(path + ".txt", "w", encoding="utf-8") as f:
        f.write(text + "\n")
    print(text)
    return 0


if __name__ == "__main__":
    sys.exit(main())
