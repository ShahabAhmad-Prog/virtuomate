import 'dart:io';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:virtuomate_flutter/config/app_config.dart';
import 'package:virtuomate_flutter/core/avatar_emotion.dart';
import 'package:virtuomate_flutter/theme/virtuomate_mvp_theme.dart';
import 'package:virtuomate_flutter/ui/shared/avatar_rive_overlay.dart';

/// Coach avatar with emotion transitions.
class AvatarCoachView extends StatefulWidget {
  const AvatarCoachView({
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

  String _resolveImageRef(String raw) {
    var path = raw.trim();
    if (path.isEmpty) return path;
    if (path.startsWith('file://')) {
      if (kIsWeb) return '';
      try {
        path = Uri.parse(path).toFilePath(windows: Platform.isWindows);
      } catch (_) {
        return '';
      }
    }
    if (path.startsWith('http://') || path.startsWith('https://')) return path;
    if (path.startsWith('/')) {
      final base = AppConfig.backendBaseUrl.trim();
      if (base.isNotEmpty) {
        return Uri.parse(base).resolve(path).toString();
      }
    }
    return path;
  }

  Widget _placeholderFace() {
    final side = widget.size;
    return ColoredBox(
      color: VirtuoMvpColors.surface,
      child: Icon(Icons.face_retouching_natural, size: side * 0.42, color: VirtuoMvpColors.cyan),
    );
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
      errorBuilder: (context, error, stackTrace) => _placeholderFace(),
    );
  }

  Widget _portraitBody() {
    final path = _resolveImageRef(widget.selfieUrlOrPath);
    if (path.isEmpty) return _animatedTemplateBody();
    final side = widget.size;
    Widget img;
    if (path.startsWith('http://') || path.startsWith('https://')) {
      final bust = path.contains('?') ? '$path&' : '$path?';
      img = Image.network(
        '${bust}v=${path.hashCode.abs()}',
        width: side,
        height: side,
        fit: BoxFit.cover,
        key: ValueKey(path),
        gaplessPlayback: true,
        loadingBuilder: (context, child, progress) {
          if (progress == null) return child;
          return ColoredBox(
            color: VirtuoMvpColors.surface,
            child: Center(
              child: SizedBox(
                width: side * 0.28,
                height: side * 0.28,
                child: const CircularProgressIndicator(
                  strokeWidth: 2,
                  color: VirtuoMvpColors.cyan,
                ),
              ),
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) => _animatedTemplateBody(),
      );
    } else if (!kIsWeb) {
      final file = File(path);
      img = file.existsSync()
          ? Image.file(
              file,
              width: side,
              height: side,
              fit: BoxFit.cover,
              key: ValueKey(path),
              errorBuilder: (context, error, stackTrace) => _animatedTemplateBody(),
            )
          : _animatedTemplateBody();
    } else {
      return _animatedTemplateBody();
    }
    return img;
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

  Widget _body() {
    final path = _resolveImageRef(widget.selfieUrlOrPath);
    if (!widget.useTemplate && path.isNotEmpty) return _portraitBody();
    return _animatedTemplateBody();
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
            ? 1.02
            : (listening ? 1.0 + _listenPulse.value * 0.02 : 1.0);

        final ringPad = listenRing + 2;
        return Padding(
          padding: EdgeInsets.all(ringPad),
          child: Transform.scale(
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
                    ),
                ],
              ),
            ),
          ),
        ),
        );
      },
    );
  }
}
