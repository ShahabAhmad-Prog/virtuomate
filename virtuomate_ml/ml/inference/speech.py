"""Speech → text for coaching assessment (Whisper / OpenAI)."""

from __future__ import annotations

import os
import tempfile
from pathlib import Path
from typing import BinaryIO


def transcribe_audio(
    file_obj: BinaryIO,
    filename: str = "audio.wav",
    language: str | None = "en",
) -> tuple[str, str]:
    """
    Returns (transcript, provider).
    Uses OpenAI Whisper API when OPENAI_API_KEY is set; otherwise raises with guidance.
    """
    api_key = os.environ.get("OPENAI_API_KEY", "").strip()
    if not api_key:
        raise RuntimeError(
            "Speech analysis requires OPENAI_API_KEY for Whisper transcription, "
            "or send transcript via analyze-text."
        )

    suffix = Path(filename).suffix or ".wav"
    with tempfile.NamedTemporaryFile(suffix=suffix, delete=False) as tmp:
        tmp.write(file_obj.read())
        tmp_path = tmp.name

    try:
        from openai import OpenAI

        client = OpenAI(api_key=api_key)
        with open(tmp_path, "rb") as audio_file:
            result = client.audio.transcriptions.create(
                model=os.environ.get("WHISPER_MODEL", "whisper-1"),
                file=audio_file,
                language=language,
            )
        text = (result.text or "").strip()
        return text, "openai-whisper"
    finally:
        Path(tmp_path).unlink(missing_ok=True)


def estimate_voice_prosody(transcript: str, duration_sec: float | None) -> dict[str, float | None]:
    """Approximate pace/pauses from transcript length and duration when available."""
    words = len(transcript.split())
    wpm = None
    if duration_sec and duration_sec > 0:
        wpm = round(words / (duration_sec / 60.0), 1)
    pause_frequency = None
    if "..." in transcript or "—" in transcript:
        pause_frequency = 0.3
    elif transcript.count(",") > 3:
        pause_frequency = 0.2
    return {"speaking_pace_wpm": wpm, "pause_frequency": pause_frequency}
