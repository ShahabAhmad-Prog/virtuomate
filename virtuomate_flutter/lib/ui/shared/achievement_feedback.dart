import 'package:flutter/material.dart';
import 'package:virtuomate_flutter/core/achievements.dart';
import 'package:virtuomate_flutter/theme/virtuomate_mvp_theme.dart';

void showAchievementUnlocks(
  BuildContext context,
  List<AchievementDefinition> unlocks,
) {
  if (unlocks.isEmpty) return;
  final messenger = ScaffoldMessenger.maybeOf(context);
  if (messenger == null) return;

  for (final achievement in unlocks) {
    messenger.showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: VirtuoMvpColors.bg1,
        duration: const Duration(seconds: 4),
        content: Row(
          children: [
            Icon(achievement.icon, color: achievement.accent, size: 22),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Achievement unlocked',
                    style: TextStyle(
                      color: VirtuoMvpColors.cyan,
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  Text(
                    achievement.title,
                    style: const TextStyle(
                      color: VirtuoMvpColors.text,
                      fontWeight: FontWeight.w900,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
