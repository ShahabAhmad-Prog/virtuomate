import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rive/rive.dart';
import 'package:virtuomate_flutter/core/avatar_emotion.dart';

/// Optional Rive overlay when `assets/rive/coach_avatar.riv` exists (Layer 2 boost).
class AvatarRiveOverlay extends StatefulWidget {
  const AvatarRiveOverlay({
    required this.size,
    required this.state,
    required this.mouthOpen,
    super.key,
  });

  final double size;
  final AvatarEmotionState state;
  final double mouthOpen;

  static const assetPath = 'assets/rive/coach_avatar.riv';
  static const stateMachineName = 'Coach';

  @override
  State<AvatarRiveOverlay> createState() => _AvatarRiveOverlayState();
}

class _AvatarRiveOverlayState extends State<AvatarRiveOverlay> {
  Artboard? _artboard;
  StateMachineController? _controller;
  SMINumber? _mouthInput;
  SMIBool? _happy;
  SMIBool? _thinking;
  SMIBool? _speaking;
  bool _hasAsset = false;
  bool _initFailed = false;

  @override
  void initState() {
    super.initState();
    _probeAsset();
  }

  Future<void> _probeAsset() async {
    try {
      await rootBundle.load(AvatarRiveOverlay.assetPath);
      if (mounted) setState(() => _hasAsset = true);
    } catch (_) {
      if (mounted) setState(() => _initFailed = true);
    }
  }

  @override
  void didUpdateWidget(covariant AvatarRiveOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    _applyState();
  }

  void _onRiveInit(Artboard artboard) {
    _artboard = artboard;
    final sm = StateMachineController.fromArtboard(
      artboard,
      AvatarRiveOverlay.stateMachineName,
    );
    if (sm == null) {
      setState(() => _initFailed = true);
      return;
    }
    artboard.addController(sm);
    _controller = sm;
    _mouthInput = sm.findInput<double>('mouthOpen') as SMINumber?;
    _happy = sm.findInput<bool>('happy') as SMIBool?;
    _thinking = sm.findInput<bool>('thinking') as SMIBool?;
    _speaking = sm.findInput<bool>('speaking') as SMIBool?;
    _applyState();
  }

  void _applyState() {
    if (_controller == null) return;
    _mouthInput?.value = widget.mouthOpen.clamp(0.0, 1.0) * 100;

    void setBool(SMIBool? input, bool on) {
      if (input == null) return;
      input.value = on;
    }

    setBool(_happy, false);
    setBool(_thinking, false);
    setBool(_speaking, false);

    switch (widget.state) {
      case AvatarEmotionState.happy:
      case AvatarEmotionState.confident:
        setBool(_happy, true);
        break;
      case AvatarEmotionState.thinking:
      case AvatarEmotionState.listening:
        setBool(_thinking, true);
        break;
      case AvatarEmotionState.speaking:
        setBool(_speaking, true);
        break;
      default:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_hasAsset || _initFailed) return const SizedBox.shrink();

    return IgnorePointer(
      child: Opacity(
        opacity: _artboard != null ? 0.9 : 0,
        child: SizedBox(
          width: widget.size,
          height: widget.size,
          child: RiveAnimation.asset(
            AvatarRiveOverlay.assetPath,
            fit: BoxFit.cover,
            stateMachines: const [AvatarRiveOverlay.stateMachineName],
            onInit: _onRiveInit,
          ),
        ),
      ),
    );
  }
}
