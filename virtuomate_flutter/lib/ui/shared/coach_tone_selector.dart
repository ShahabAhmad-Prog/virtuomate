import 'package:flutter/material.dart';
import 'package:virtuomate_flutter/core/avatar_customization.dart';
import 'package:virtuomate_flutter/theme/virtuomate_mvp_theme.dart';

/// Selectable coach tone cards for avatar customization.
class CoachToneSelector extends StatelessWidget {
  const CoachToneSelector({
    required this.selectedId,
    required this.onSelected,
    super.key,
    this.tones,
    this.onPreview,
    this.previewingId,
  });

  final String selectedId;
  final ValueChanged<String> onSelected;
  final List<CoachToneOption>? tones;
  final void Function(CoachToneOption tone)? onPreview;
  final String? previewingId;

  @override
  Widget build(BuildContext context) {
    final list = tones ?? kCoachTones;
    return Column(
      children: [
        for (final tone in list) ...[
          _ToneCard(
            tone: tone,
            active: selectedId == tone.id,
            previewing: previewingId == tone.id,
            onTap: () => onSelected(tone.id),
            onPreview: onPreview == null ? null : () => onPreview!(tone),
          ),
          const SizedBox(height: 8),
        ],
      ],
    );
  }
}

class _ToneCard extends StatelessWidget {
  const _ToneCard({
    required this.tone,
    required this.active,
    required this.onTap,
    this.onPreview,
    this.previewing = false,
  });

  final CoachToneOption tone;
  final bool active;
  final bool previewing;
  final VoidCallback onTap;
  final VoidCallback? onPreview;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(VirtuoMvpRadii.lg),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(VirtuoMvpRadii.lg),
          color: active
              ? const Color.fromRGBO(139, 92, 255, 0.12)
              : VirtuoMvpColors.inputFill,
          border: Border.all(
            color: active
                ? VirtuoMvpColors.purple.withValues(alpha: 0.45)
                : VirtuoMvpColors.stroke,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tone.title,
                    style: const TextStyle(
                      color: VirtuoMvpColors.text,
                      fontWeight: FontWeight.w900,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    tone.subtitle,
                    style: const TextStyle(
                      color: VirtuoMvpColors.textMuted,
                      fontSize: 11,
                      height: 1.35,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '"${tone.sampleLine}"',
                    style: TextStyle(
                      color: VirtuoMvpColors.textFaint.withValues(alpha: 0.95),
                      fontSize: 10,
                      fontStyle: FontStyle.italic,
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
            if (onPreview != null) ...[
              const SizedBox(width: 8),
              IconButton(
                tooltip: 'Preview tone',
                onPressed: onPreview,
                icon: Icon(
                  previewing ? Icons.volume_up : Icons.play_circle_outline,
                  color: previewing ? VirtuoMvpColors.cyan : VirtuoMvpColors.textMuted,
                  size: 26,
                ),
              ),
            ],
            if (active)
              const Padding(
                padding: EdgeInsets.only(left: 4, top: 2),
                child: Icon(Icons.check_circle, color: VirtuoMvpColors.purple, size: 22),
              ),
          ],
        ),
      ),
    );
  }
}
