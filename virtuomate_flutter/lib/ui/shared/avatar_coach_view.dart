import 'dart:io';

import 'package:flutter/material.dart';
import 'package:virtuomate_flutter/core/avatar_emotion.dart';
import 'package:virtuomate_flutter/theme/virtuomate_mvp_theme.dart';
import 'package:virtuomate_flutter/ui/shared/avatar_rive_overlay.dart';

/// Layer 2 (emotion transitions) + Layer 3 (TTS lip-sync) coach avatar.
class AvatarCoachView extends StatefulWidget {
  const AvatarCoachView({
    super.key,
    this.selfieUrlOrPath = '',
    this.useTemplate = true,
    this.emotion = 'neutral',
    this.size = 120,
    this.isSpeaking = false,
    this.isListening = false,
    this.mouthOpen = 0,
    this.enableRiveOverlay = true,
  });

  final String selfieUrlOrPath;
  final bool useTemplate;
  final String emotion;
  final double size;
  final bool isSpeaking;
  final bool isListening;
  final double mouthOpen;
  final bool enableRiveOverlay;

  @override
  State<AvatarCoachView> createState() => _AvatarCoachViewState();
}

class _AvatarCoachViewState extends State<AvatarCoachView>
    with TickerProviderStateMixin {
  late final AnimationController _idleBreath;
  late final AnimationController _emotionFade;
  late final AnimationController _listenPulse;

  AvatarEmotionState? _shownState;
  AvatarEmotionState? _previousState;

  @override
  void initState() {
    super.initState();
    _idleBreath = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat(reverse: true);

    _emotionFade = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 320),
    );

    _listenPulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    );

    _shownState = _resolveDisplayState();
    _previousState = _shownState;
    _syncListenPulse();
  }

  @override
  void didUpdateWidget(covariant AvatarCoachView oldWidget) {
    super.didUpdateWidget(oldWidget);
    final next = _resolveDisplayState();
    if (next != _shownState) {
      _previousState = _shownState;
      _shownState = next;
      _emotionFade.forward(from: 0);
    }
    _syncListenPulse();
  }

  void _syncListenPulse() {
    if (widget.isListening && !widget.isSpeaking) {
      if (!_listenPulse.isAnimating) _listenPulse.repeat(reverse: true);
    } else {
      _listenPulse.stop();
      _listenPulse.value = 0;
    }
  }

  AvatarEmotionState _resolveDisplayState() => resolveAvatarEmotion(
        geminiEmotion: widget.emotion,
        isSpeaking: widget.isSpeaking,
        isListening: widget.isListening,
      );

  @override
  void dispose() {
    _idleBreath.dispose();
    _emotionFade.dispose();
    _listenPulse.dispose();
    super.dispose();
  }

  Color _ringColor(AvatarEmotionState state) {
    switch (state) {
      case AvatarEmotionState.happy:
      case AvatarEmotionState.confident:
        return VirtuoMvpColors.green;
      case AvatarEmotionState.thinking:
      case AvatarEmotionState.listening:
        return VirtuoMvpColors.purple;
      case AvatarEmotionState.nervous:
      case AvatarEmotionState.encouraging:
        return VirtuoMvpColors.yellow;
      case AvatarEmotionState.speaking:
        return VirtuoMvpColors.cyan;
      case AvatarEmotionState.idle:
      case AvatarEmotionState.neutral:
        return VirtuoMvpColors.cyan;
    }
  }

  Widget _imageForState(AvatarEmotionState state) {
    final dpr = MediaQuery.devicePixelRatioOf(context);
    final side = widget.size;
    return Image.asset(
      AvatarEmotionAssets.assetFor(state),
      fit: BoxFit.cover,
      width: side,
      height: side,
      cacheHeight: (side * dpr).round(),
      cacheWidth: (side * dpr).round(),
      filterQuality: FilterQuality.medium,
      errorBuilder: (_, __, ___) => ColoredBox(
        color: VirtuoMvpColors.surface,
        child: Icon(Icons.smart_toy_outlined, size: side * 0.45),
      ),
    );
  }

  Widget _portraitBody() {
    final path = widget.selfieUrlOrPath.trim();
    if (path.isEmpty) return _animatedTemplateBody();
    Widget img;
    if (path.startsWith('http')) {
      final bust = path.contains('?') ? '$path&' : '$path?';
      img = Image.network(
        '${bust}v=${path.hashCode}',
        fit: BoxFit.cover,
        key: ValueKey(path),
      );
    } else {
      final file = File(path);
      img = file.existsSync()
          ? Image.file(file, fit: BoxFit.cover, key: ValueKey(path))
          : _animatedTemplateBody();
    }
    return Stack(
      fit: StackFit.expand,
      children: [
        img,
        if (widget.isSpeaking && widget.mouthOpen > 0.05) _lipOverlay(),
      ],
    );
  }

  Widget _animatedTemplateBody() {
    final current = _shownState ?? AvatarEmotionState.idle;
    final previous = _previousState ?? current;

    return AnimatedBuilder(
      animation: Listenable.merge([_emotionFade, _idleBreath]),
      builder: (context, _) {
        final breath = 1.0 + (_idleBreath.value * 0.018);
        final fade = _emotionFade.value;
        return Transform.scale(
          scale: breath,
          child: Stack(
            fit: StackFit.expand,
            children: [
              Opacity(
                opacity: 1 - fade,
                child: _imageForState(previous),
              ),
              Opacity(
                opacity: fade,
                child: _imageForState(current),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _lipOverlay() {
    final open = widget.mouthOpen.clamp(0.0, 1.0);
    final w = widget.size * (0.22 + open * 0.08);
    final h = widget.size * (0.035 + open * 0.065);
    return Positioned(
      left: (widget.size - w) / 2,
      bottom: widget.size * 0.26,
      child: Container(
        width: w,
        height: h,
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.28 + open * 0.12),
          borderRadius: BorderRadius.vertical(
            top: Radius.elliptical(w * 0.45, h * 0.42),
            bottom: Radius.elliptical(w * 0.4, h * 0.58),
          ),
        ),
      ),
    );
  }

  Widget _body() {
    if (widget.useTemplate || widget.selfieUrlOrPath.trim().isEmpty) {
      return _animatedTemplateBody();
    }
    return _portraitBody();
  }

  @override
  Widget build(BuildContext context) {
    final state = _shownState ?? _resolveDisplayState();
    final tint = _ringColor(state);
    final speaking = widget.isSpeaking;
    final listening = widget.isListening && !speaking;

    return AnimatedBuilder(
      animation: _listenPulse,
      builder: (context, child) {
        final listenRing = listening ? 2.5 + _listenPulse.value * 2.5 : 2.0;
        final scale = speaking
            ? 1.0 + (widget.mouthOpen * 0.04)
            : (listening ? 1.0 + _listenPulse.value * 0.02 : 1.0);

        return Transform.scale(
          scale: scale,
          child: Container(
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: tint.withValues(
                  alpha: speaking || listening ? 0.88 : 0.45,
                ),
                width: listenRing,
              ),
              boxShadow: speaking || listening
                  ? [
                      BoxShadow(
                        color: tint.withValues(alpha: 0.28),
                        blurRadius: 10 + (listening ? _listenPulse.value * 6 : 4),
                      ),
                    ]
                  : null,
            ),
            child: ClipOval(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  _body(),
                  if (widget.enableRiveOverlay)
                    AvatarRiveOverlay(
                      size: widget.size,
                      state: state,
                      mouthOpen: widget.mouthOpen,
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
