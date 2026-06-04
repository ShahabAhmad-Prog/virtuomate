import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:virtuomate_flutter/core/avatar_customization.dart';
import 'package:virtuomate_flutter/core/voice_profile_codec.dart';
import 'package:virtuomate_flutter/services/tts_lip_sync.dart';
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

  await applySystemVoiceForGender(tts, resolved.gender);
  await tts.setSpeechRate(rate);
  await tts.setPitch(pitch);
}

/// Speaks text; exposes [isSpeaking] and [mouthOpen] for avatar lip-sync (Layer 3).
class TtsSpeaker {
  TtsSpeaker(this._tts) {
    _lipSync.attach(_tts, isSpeaking: isSpeaking, mouthOpen: mouthOpen);
  }

  final FlutterTts _tts;
  final TtsLipSync _lipSync = TtsLipSync();

  final ValueNotifier<bool> isSpeaking = ValueNotifier(false);
  final ValueNotifier<double> mouthOpen = ValueNotifier(0);

  Future<void> speak(
    String text,
    String voiceProfile, {
    String? voiceGender,
  }) async {
    if (text.trim().isEmpty) return;
    await applyVoiceProfileToTts(
      _tts,
      voiceProfile,
      voiceGender: voiceGender,
    );
    await _tts.speak(text);
  }

  Future<void> stop() async {
    await _tts.stop();
    isSpeaking.value = false;
    mouthOpen.value = 0;
  }

  void dispose() {
    _lipSync.dispose();
    isSpeaking.dispose();
    mouthOpen.dispose();
  }
}
