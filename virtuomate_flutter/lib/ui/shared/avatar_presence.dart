import 'package:flutter/material.dart';
import 'package:virtuomate_flutter/ui/shared/avatar_coach_view.dart';

/// Coach avatar with emotion animations.
class AvatarPresence extends StatelessWidget {
  const AvatarPresence({
    super.key,
    this.selfieUrlOrPath = '',
    this.useTemplate = true,
    this.emotion = 'neutral',
    this.size = 120,
    this.isSpeaking = false,
    this.isListening = false,
    this.enableRiveOverlay = false,
  });

  final String selfieUrlOrPath;
  final bool useTemplate;
  final String emotion;
  final double size;
  final bool isSpeaking;
  final bool isListening;
  final bool enableRiveOverlay;

  @override
  Widget build(BuildContext context) {
    return AvatarCoachView(
      selfieUrlOrPath: selfieUrlOrPath,
      useTemplate: useTemplate,
      emotion: emotion,
      size: size,
      isSpeaking: isSpeaking,
      isListening: isListening,
      enableRiveOverlay: enableRiveOverlay,
    );
  }
}
