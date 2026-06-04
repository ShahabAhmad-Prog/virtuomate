import 'package:flutter/material.dart';
import 'package:virtuomate_flutter/theme/virtuomate_mvp_theme.dart';

/// Cyan-to-purple gradient primary button matching design mockups.
class GradientPrimaryButton extends StatelessWidget {
  const GradientPrimaryButton({
    required this.title,
    super.key,
    this.icon,
    this.onPressed,
    this.expanded = true,
    this.height = 48,
  });

  final String title;
  final IconData? icon;
  final VoidCallback? onPressed;
  final bool expanded;
  final double height;

  @override
  Widget build(BuildContext context) {
    final disabled = onPressed == null;
    final child = Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(VirtuoMvpRadii.lg),
        child: Ink(
          height: height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(VirtuoMvpRadii.lg),
            gradient: LinearGradient(
              colors: disabled
                  ? [
                      VirtuoMvpColors.cyan.withValues(alpha: 0.4),
                      VirtuoMvpColors.purple.withValues(alpha: 0.4),
                    ]
                  : [VirtuoMvpColors.cyan, VirtuoMvpColors.purple],
            ),
            border: Border.all(color: VirtuoMvpColors.stroke2),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 18, color: VirtuoMvpColors.primaryTextOnPurple),
                const SizedBox(width: 8),
              ],
              Flexible(
                child: Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: VirtuoMvpColors.primaryTextOnPurple,
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
    if (expanded) return SizedBox(width: double.infinity, child: child);
    return child;
  }
}

/// Four-step progress stepper for Video CV wizard.
class StepProgressBar extends StatelessWidget {
  const StepProgressBar({
    required this.currentStep,
    required this.totalSteps,
    super.key,
    this.icons = const [
      Icons.person_outline,
      Icons.work_outline,
      Icons.school_outlined,
      Icons.military_tech_outlined,
    ],
  });

  final int currentStep;
  final int totalSteps;
  final List<IconData> icons;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(totalSteps, (i) {
        final active = i <= currentStep;
        final isLast = i == totalSteps - 1;
        return Expanded(
          child: Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: active
                            ? VirtuoMvpColors.cyan.withValues(alpha: 0.2)
                            : VirtuoMvpColors.surface,
                        border: Border.all(
                          color: active ? VirtuoMvpColors.cyan : VirtuoMvpColors.stroke,
                          width: active ? 2 : 1,
                        ),
                        boxShadow: active
                            ? [
                                BoxShadow(
                                  color: VirtuoMvpColors.cyan.withValues(alpha: 0.35),
                                  blurRadius: 8,
                                ),
                              ]
                            : null,
                      ),
                      child: Icon(
                        i < icons.length ? icons[i] : Icons.circle,
                        size: 16,
                        color: active ? VirtuoMvpColors.cyan : VirtuoMvpColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              if (!isLast)
                Expanded(
                  flex: 2,
                  child: Container(
                    height: 2,
                    margin: const EdgeInsets.only(bottom: 18),
                    decoration: BoxDecoration(
                      border: Border(
                        top: BorderSide(
                          color: i < currentStep
                              ? VirtuoMvpColors.cyan.withValues(alpha: 0.5)
                              : VirtuoMvpColors.stroke,
                          width: 1,
                          style: BorderStyle.solid,
                        ),
                      ),
                    ),
                    child: CustomPaint(
                      painter: _DashedLinePainter(
                        color: i < currentStep
                            ? VirtuoMvpColors.cyan.withValues(alpha: 0.4)
                            : VirtuoMvpColors.stroke,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      }),
    );
  }
}

class _DashedLinePainter extends CustomPainter {
  _DashedLinePainter({required this.color});
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1;
    const dashWidth = 4.0;
    const dashSpace = 3.0;
    double start = 0;
    while (start < size.width) {
      canvas.drawLine(Offset(start, 0), Offset(start + dashWidth, 0), paint);
      start += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class EmotionBadge extends StatelessWidget {
  const EmotionBadge({required this.emotion, super.key});

  final String emotion;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        gradient: const LinearGradient(
          colors: [VirtuoMvpColors.purple, VirtuoMvpColors.cyan],
        ),
      ),
      child: Text(
        emotion,
        style: const TextStyle(
          color: VirtuoMvpColors.text,
          fontWeight: FontWeight.w900,
          fontSize: 12,
        ),
      ),
    );
  }
}

class ConfidenceBar extends StatelessWidget {
  const ConfidenceBar({required this.percent, super.key});

  final int percent;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'AI Confidence Analysis',
              style: TextStyle(
                color: VirtuoMvpColors.text,
                fontWeight: FontWeight.w900,
                fontSize: 13,
              ),
            ),
            Text(
              '$percent%',
              style: const TextStyle(
                color: VirtuoMvpColors.amber,
                fontWeight: FontWeight.w900,
                fontSize: 14,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: percent / 100,
            minHeight: 8,
            backgroundColor: VirtuoMvpColors.surface,
            color: VirtuoMvpColors.amber,
          ),
        ),
      ],
    );
  }
}

class MetricChip extends StatelessWidget {
  const MetricChip({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    super.key,
    this.expanded = true,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final bool expanded;

  @override
  Widget build(BuildContext context) {
    final chip = Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(VirtuoMvpRadii.md),
          color: VirtuoMvpColors.surface,
          border: Border.all(color: VirtuoMvpColors.stroke),
        ),
        child: Column(
          children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(height: 6),
            Text(
              value,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w900,
                fontSize: 13,
              ),
            ),
            Text(
              label,
              style: const TextStyle(
                color: VirtuoMvpColors.textMuted,
                fontSize: 10,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
    );
    if (expanded) return Expanded(child: chip);
    return chip;
  }
}
