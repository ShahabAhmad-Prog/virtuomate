import 'package:flutter_test/flutter_test.dart';
import 'package:virtuomate_flutter/core/avatar_emotion.dart';

void main() {
  group('resolveAvatarEmotion', () {
    test('maps nervous to encouraging', () {
      expect(
        resolveAvatarEmotion(geminiEmotion: 'nervous'),
        AvatarEmotionState.encouraging,
      );
    });

    test('speaking overrides emotion', () {
      expect(
        resolveAvatarEmotion(geminiEmotion: 'happy', isSpeaking: true),
        AvatarEmotionState.speaking,
      );
    });

    test('listening overrides when not speaking', () {
      expect(
        resolveAvatarEmotion(
          geminiEmotion: 'happy',
          isListening: true,
        ),
        AvatarEmotionState.listening,
      );
    });

    test('neutral maps to idle', () {
      expect(
        resolveAvatarEmotion(geminiEmotion: 'neutral'),
        AvatarEmotionState.idle,
      );
    });

    test('maps avatar_expression names from Gemini', () {
      expect(
        resolveAvatarEmotion(geminiEmotion: 'thinking'),
        AvatarEmotionState.thinking,
      );
      expect(
        resolveAvatarEmotion(geminiEmotion: 'confident'),
        AvatarEmotionState.confident,
      );
    });
  });

  group('avatarEmotionFromName', () {
    test('parses stored state names', () {
      expect(
        avatarEmotionFromName('encouraging'),
        AvatarEmotionState.encouraging,
      );
    });
  });
}
