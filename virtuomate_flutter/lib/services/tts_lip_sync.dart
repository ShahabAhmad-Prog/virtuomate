import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';

/// Drives [mouthOpen] (0.0–1.0) from TTS word progress + fallback pulse while speaking.
class TtsLipSync {
  Timer? _pulseTimer;
  double _pulsePhase = 0;

  void attach(
    FlutterTts tts, {
    required ValueNotifier<bool> isSpeaking,
    required ValueNotifier<double> mouthOpen,
  }) {
    tts.setStartHandler(() {
      isSpeaking.value = true;
      mouthOpen.value = 0.35;
      _startFallbackPulse(mouthOpen);
    });

    tts.setCompletionHandler(() {
      _stopPulse();
      isSpeaking.value = false;
      mouthOpen.value = 0;
    });

    tts.setCancelHandler(() {
      _stopPulse();
      isSpeaking.value = false;
      mouthOpen.value = 0;
    });

    tts.setProgressHandler((
      String text,
      int start,
      int end,
      String word,
    ) {
      if (!isSpeaking.value) isSpeaking.value = true;
      mouthOpen.value = mouthOpenForWord(word);
    });
  }

  void _startFallbackPulse(ValueNotifier<double> mouthOpen) {
    _stopPulse();
    _pulseTimer = Timer.periodic(const Duration(milliseconds: 90), (_) {
      _pulsePhase += 0.55;
      final wave = (0.32 + 0.28 * (1 + math.sin(_pulsePhase)) / 2).clamp(0.2, 0.85);
      if (mouthOpen.value < 0.5) {
        mouthOpen.value = wave;
      }
    });
  }

  void _stopPulse() {
    _pulseTimer?.cancel();
    _pulseTimer = null;
    _pulsePhase = 0;
  }

  void dispose() {
    _stopPulse();
  }
}

/// Vowel-heavy words open the mouth more (viseme-style heuristic).
double mouthOpenForWord(String word) {
  final w = word.trim().toLowerCase();
  if (w.isEmpty) return 0.25;
  const vowels = 'aeiou';
  var vowelCount = 0;
  for (var i = 0; i < w.length; i++) {
    if (vowels.contains(w[i])) vowelCount++;
  }
  final ratio = vowelCount / w.length;
  if (ratio > 0.55) return 0.92;
  if (ratio > 0.35) return 0.72;
  if (ratio > 0.15) return 0.48;
  return 0.32;
}
