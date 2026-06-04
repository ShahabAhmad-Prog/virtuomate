import 'package:flutter/material.dart';
import 'package:virtuomate_flutter/theme/virtuomate_mvp_theme.dart';

/// Three-dot typing animation for AI coach replies.
class TypingIndicator extends StatefulWidget {
  const TypingIndicator({super.key, this.label = 'AI Coach is thinking'});

  final String label;

  @override
  State<TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<TypingIndicator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          widget.label,
          style: const TextStyle(
            color: VirtuoMvpColors.textMuted,
            fontSize: 11,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(width: 8),
        AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            return Row(
              children: List.generate(3, (i) {
                final phase = (_controller.value * 3 + i) % 3;
                final opacity = phase < 1 ? 1.0 : 0.35;
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: VirtuoMvpColors.cyan.withValues(alpha: opacity),
                  ),
                );
              }),
            );
          },
        ),
      ],
    );
  }
}
