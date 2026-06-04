import 'package:flutter/material.dart';
import 'package:virtuomate_flutter/core/achievements.dart';
import 'package:virtuomate_flutter/theme/virtuomate_mvp_theme.dart';
import 'package:virtuomate_flutter/ui/mvp/mvp_shell.dart';
import 'package:virtuomate_flutter/ui/mvp/mvp_widgets.dart';
import 'package:virtuomate_flutter/ui/virtuomate_bindings.dart';

class AchievementsScreen extends StatelessWidget {
  const AchievementsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = VirtuoMateScope.of(context);
    c.syncAchievements();
    final statuses = c.achievementStatuses;
    final unlocked = c.unlockedAchievementCount;
    final total = c.totalAchievementCount;

    final byCategory = <AchievementCategory, List<AchievementStatus>>{};
    for (final status in statuses) {
      byCategory.putIfAbsent(status.definition.category, () => []).add(status);
    }

    return MvpShell(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          MvpTopBar(
            title: 'Achievements',
            right: Text(
              '$unlocked/$total',
              style: const TextStyle(
                color: VirtuoMvpColors.cyan,
                fontWeight: FontWeight.w900,
                fontSize: 13,
              ),
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(
                VirtuoMvpSpacing.lg,
                0,
                VirtuoMvpSpacing.lg,
                VirtuoMvpSpacing.lg,
              ),
              children: [
                VCard(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Task badges',
                        style: TextStyle(
                          color: VirtuoMvpColors.text,
                          fontWeight: FontWeight.w900,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Complete coaching tasks to unlock achievements. '
                        '${total - unlocked} remaining.',
                        style: const TextStyle(
                          color: VirtuoMvpColors.textMuted,
                          fontSize: 12,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: LinearProgressIndicator(
                          value: total == 0 ? 0 : unlocked / total,
                          minHeight: 8,
                          backgroundColor: VirtuoMvpColors.surface,
                          color: VirtuoMvpColors.purple,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                for (final category in AchievementCategory.values) ...[
                  if ((byCategory[category] ?? []).isNotEmpty) ...[
                    Text(
                      categoryLabel(category),
                      style: const TextStyle(
                        color: VirtuoMvpColors.text,
                        fontWeight: FontWeight.w900,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...byCategory[category]!.map((s) => _AchievementTile(status: s)),
                    const SizedBox(height: 12),
                  ],
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AchievementTile extends StatelessWidget {
  const _AchievementTile({required this.status});

  final AchievementStatus status;

  @override
  Widget build(BuildContext context) {
    final def = status.definition;
    final done = status.unlocked;
    final accent = done ? def.accent : VirtuoMvpColors.textMuted;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Opacity(
        opacity: done ? 1.0 : 0.72,
        child: VCard(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: accent.withValues(alpha: 0.15),
                  border: Border.all(color: accent.withValues(alpha: 0.35)),
                ),
                child: Icon(def.icon, color: accent, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            def.title,
                            style: TextStyle(
                              color: done
                                  ? VirtuoMvpColors.text
                                  : VirtuoMvpColors.textMuted,
                              fontWeight: FontWeight.w900,
                              fontSize: 13,
                            ),
                          ),
                        ),
                        if (done)
                          const Icon(
                            Icons.check_circle,
                            color: VirtuoMvpColors.green,
                            size: 20,
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      def.description,
                      style: const TextStyle(
                        color: VirtuoMvpColors.textFaint,
                        fontSize: 11,
                        height: 1.35,
                      ),
                    ),
                    if (!done && def.target > 1) ...[
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: status.progressFraction,
                          minHeight: 5,
                          backgroundColor: VirtuoMvpColors.surface,
                          color: VirtuoMvpColors.cyan,
                        ),
                      ),
                    ],
                    const SizedBox(height: 4),
                    Text(
                      status.progressLabel,
                      style: const TextStyle(
                        color: VirtuoMvpColors.textMuted,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
