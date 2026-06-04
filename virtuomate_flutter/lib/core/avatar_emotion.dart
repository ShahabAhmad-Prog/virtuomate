/// Lightweight emotion-driven avatar states (Gemini-controlled, local asset templates).
enum AvatarEmotionState {
  idle,
  neutral,
  happy,
  thinking,
  confident,
  nervous,
  encouraging,
  speaking,
  listening,
}

abstract final class AvatarEmotionAssets {
  static const basePath = 'assets/avatars';

  static String assetFor(AvatarEmotionState state) {
    switch (state) {
      case AvatarEmotionState.idle:
        return '$basePath/neutral.png';
      case AvatarEmotionState.listening:
        return '$basePath/thinking.png';
      default:
        return '$basePath/${state.name}.png';
    }
  }

  /// Preview grid: one tile per distinct expression asset.
  static const previewStates = [
    AvatarEmotionState.idle,
    AvatarEmotionState.happy,
    AvatarEmotionState.thinking,
    AvatarEmotionState.confident,
    AvatarEmotionState.encouraging,
    AvatarEmotionState.speaking,
    AvatarEmotionState.listening,
  ];
}

/// Maps Gemini / session emotion labels to a display avatar state.
AvatarEmotionState resolveAvatarEmotion({
  required String geminiEmotion,
  bool isSpeaking = false,
  bool isListening = false,
}) {
  if (isListening) return AvatarEmotionState.listening;
  if (isSpeaking) return AvatarEmotionState.speaking;

  final e = geminiEmotion.toLowerCase().trim();
  switch (e) {
    case 'happy':
    case 'excited':
      return AvatarEmotionState.happy;
    case 'thinking':
    case 'focused':
    case 'concerned':
      return AvatarEmotionState.thinking;
    case 'confident':
    case 'professional':
      return AvatarEmotionState.confident;
    case 'nervous':
    case 'anxious':
    case 'anxiety':
      return AvatarEmotionState.encouraging;
    case 'encouraging':
    case 'supportive':
      return AvatarEmotionState.encouraging;
    case 'speaking':
      return AvatarEmotionState.speaking;
    case 'listening':
      return AvatarEmotionState.listening;
    case 'idle':
      return AvatarEmotionState.idle;
    default:
      if (e.isEmpty || e == 'neutral' || e == 'focused') {
        return AvatarEmotionState.idle;
      }
      return AvatarEmotionState.neutral;
  }
}

AvatarEmotionState avatarEmotionFromName(String? name) {
  if (name == null || name.isEmpty) return AvatarEmotionState.neutral;
  for (final s in AvatarEmotionState.values) {
    if (s.name == name.toLowerCase()) return s;
  }
  return resolveAvatarEmotion(geminiEmotion: name);
}

String avatarEmotionLabel(AvatarEmotionState state) {
  switch (state) {
    case AvatarEmotionState.idle:
      return 'Idle';
    case AvatarEmotionState.neutral:
      return 'Neutral';
    case AvatarEmotionState.happy:
      return 'Happy';
    case AvatarEmotionState.thinking:
      return 'Thinking';
    case AvatarEmotionState.confident:
      return 'Confident';
    case AvatarEmotionState.nervous:
      return 'Nervous';
    case AvatarEmotionState.encouraging:
      return 'Encouraging';
    case AvatarEmotionState.speaking:
      return 'Speaking';
    case AvatarEmotionState.listening:
      return 'Listening';
  }
}
