import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:virtuomate_flutter/core/avatar_customization.dart';
import 'package:virtuomate_flutter/core/voice_profile_codec.dart';
import 'package:virtuomate_flutter/services/tts_voice_picker.dart';

Future<void> applyVoiceProfileToTts(
  FlutterTts tts,
  String profile, {
  String? voiceGender,
}) async {
  final resolved = resolveVoiceProfile(profile, fallbackGender: voiceGender);
  final tone = coachToneById(resolved.toneId);
  final rate = tone?.speechRate ?? 0.45;
  final pitch = pitchForGender(tone?.pitch ?? 1.0, resolved.gender);

  await tts.setSpeechRate(rate);
  await tts.setPitch(pitch);
  // Apply system voice last — some engines reset voice when pitch/rate change.
  await applySystemVoiceForGender(tts, resolved.gender);
}

/// Speaks text and exposes [isSpeaking] for avatar emotion states.
class TtsSpeaker {
  TtsSpeaker(this._tts) {
    _tts.setStartHandler(() => isSpeaking.value = true);
    _tts.setCompletionHandler(() => isSpeaking.value = false);
    _tts.setCancelHandler(() => isSpeaking.value = false);
    _tts.setProgressHandler((String text, int start, int end, String word) {
      if (!isSpeaking.value) isSpeaking.value = true;
    });
  }

  final FlutterTts _tts;
  final ValueNotifier<bool> isSpeaking = ValueNotifier(false);

  Future<void> speak(
    String text,
    String voiceProfile, {
    String? voiceGender,
  }) async {
    if (text.trim().isEmpty) return;
    final resolved = resolveVoiceProfile(voiceProfile, fallbackGender: voiceGender);
    await applyVoiceProfileToTts(
      _tts,
      encodeVoiceProfile(resolved.gender, resolved.toneId),
    );
    await _tts.speak(text);
  }

  Future<void> stop() async {
    await _tts.stop();
    isSpeaking.value = false;
  }

  void dispose() {
    isSpeaking.dispose();
  }
}
