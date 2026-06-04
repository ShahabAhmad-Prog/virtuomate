import 'package:virtuomate_flutter/core/avatar_customization.dart';

/// Resolved coach voice: gender + tone id.
class ResolvedVoiceProfile {
  const ResolvedVoiceProfile({
    required this.gender,
    required this.toneId,
  });

  final String gender;
  final String toneId;
}

/// Persist as `male|confident-neutral` so gender is never lost on sync.
String encodeVoiceProfile(String gender, String toneId) => '$gender|$toneId';

ResolvedVoiceProfile resolveVoiceProfile(
  String voiceProfile, {
  String? fallbackGender,
}) {
  final trimmed = voiceProfile.trim();
  if (trimmed.contains('|')) {
    final i = trimmed.indexOf('|');
    final prefix = trimmed.substring(0, i).toLowerCase();
    final toneId = trimmed.substring(i + 1).trim();
    if ((prefix == kVoiceGenderMale || prefix == kVoiceGenderFemale) &&
        toneId.isNotEmpty) {
      return ResolvedVoiceProfile(gender: prefix, toneId: toneId);
    }
  }
  return ResolvedVoiceProfile(
    gender: fallbackGender ?? kVoiceGenderFemale,
    toneId: trimmed.isEmpty ? 'confident-neutral' : trimmed,
  );
}
