import 'package:flutter/material.dart';
import 'package:virtuomate_flutter/theme/virtuomate_mvp_theme.dart';
import 'package:virtuomate_flutter/ui/mvp/mvp_shell.dart';
import 'package:virtuomate_flutter/ui/mvp/mvp_widgets.dart';
import 'package:virtuomate_flutter/ui/shared/responsive.dart';
import 'package:virtuomate_flutter/core/models.dart';
import 'package:virtuomate_flutter/services/app_service.dart';
import 'package:virtuomate_flutter/ui/shared/achievement_feedback.dart';
import 'package:virtuomate_flutter/ui/shared/neural_connectivity_card.dart';
import 'package:virtuomate_flutter/ui/virtuomate_bindings.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final c = VirtuoMateScope.of(context);
      c.syncAchievements();
      c.refreshNeuralConnectivity();
      showAchievementUnlocks(context, c.drainAchievementUnlocks());
    });
  }

  @override
  Widget build(BuildContext context) {
    final c = VirtuoMateScope.of(context);
    final a = c.analytics;
    final sessions = c.sessions.take(2).toList();
    final neural = c.neuralConnectivity;
    final missionPct = c.missionProgress / 100.0;
    final totalSessions = c.sessions.length;
    final freeSessionsLeft =
        (AppService.freeSessionLimit - totalSessions).clamp(0, AppService.freeSessionLimit);
    final atConversationLimit = !c.canRunConversation && !c.isPremium;

    return MvpShell(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            VirtuoMvpSpacing.lg,
            20,
            VirtuoMvpSpacing.lg,
            VirtuoMvpSpacing.lg,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'SYSTEM ACTIVE',
                          style: TextStyle(
                            color: VirtuoMvpColors.cyan,
                            fontSize: 11,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.2,
                          ),
                        ),
                        if (c.isPremium) ...[
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(999),
                              color: VirtuoMvpColors.green.withValues(alpha: 0.2),
                              border: Border.all(color: VirtuoMvpColors.green.withValues(alpha: 0.5)),
                            ),
                            child: const Text(
                              'PREMIUM · Unlimited sessions',
                              style: TextStyle(
                                color: VirtuoMvpColors.green,
                                fontSize: 10,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 0.6,
                              ),
                            ),
                          ),
                        ],
                        const SizedBox(height: 6),
                        Text(
                          c.displayName,
                          style: const TextStyle(
                            color: VirtuoMvpColors.text,
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      _dashIconBtn(context, Icons.settings_outlined, () {
                        Navigator.pushNamed(context, AppRoutes.settings);
                      }),
                      const SizedBox(width: 10),
                      _dashIconBtn(context, Icons.person_outline, () {
                        Navigator.pushNamed(context, AppRoutes.userConfig);
                      }),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 14),
              VCard(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: VirtuoMvpColors.surface,
                            border: Border.all(color: VirtuoMvpColors.stroke),
                          ),
                          child: const Icon(Icons.psychology_outlined, size: 26, color: VirtuoMvpColors.text),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Your AI Coach',
                                style: TextStyle(
                                  color: VirtuoMvpColors.text,
                                  fontWeight: FontWeight.w900,
                                  fontSize: 16,
                                ),
                              ),
                              Text(
                                neural.modeLabel,
                                style: TextStyle(
                                  color: neural.full
                                      ? VirtuoMvpColors.green
                                      : VirtuoMvpColors.cyan,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const SizedBox(height: 10),
                              NeuralConnectivityCard(status: neural, compact: true),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    if (atConversationLimit)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Text(
                          'Free tier limit reached (${AppService.freeSessionLimit} sessions). '
                          'Open Premium to continue, or review past sessions below.',
                          style: TextStyle(
                            color: VirtuoMvpColors.amber.withValues(alpha: 0.95),
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            height: 1.35,
                          ),
                        ),
                      )
                    else if (c.isPremium)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Text(
                          'Premium active — unlimited coaching sessions',
                          style: TextStyle(
                            color: VirtuoMvpColors.green.withValues(alpha: 0.95),
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      )
                    else if (!c.isPremium)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Text(
                          '$freeSessionsLeft free session${freeSessionsLeft == 1 ? '' : 's'} remaining',
                          style: const TextStyle(
                            color: VirtuoMvpColors.textMuted,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    VButton(
                      title: 'Initialize AI Session',
                      icon: Icons.flash_on,
                      expanded: true,
                      onPressed: () {
                        Navigator.pushNamed(context, AppRoutes.session);
                      },
                    ),
                    const SizedBox(height: 10),
                    VButton(
                      title: 'Open Coach Chat',
                      variant: VButtonVariant.outline,
                      icon: Icons.chat_bubble_outline,
                      expanded: true,
                      onPressed: () {
                        Navigator.pushNamed(context, AppRoutes.coachChat);
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              LayoutBuilder(
                builder: (context, constraints) {
                  final compact = constraints.maxWidth < VirtuoBreakpoints.compact;
                  final stats = [
                    _miniStatBox(
                      Icons.schedule_outlined,
                      '${a.conversationSessions + a.rolePlaySessions}',
                      'Sessions',
                    ),
                    _miniStatBox(Icons.trending_up_outlined, '${a.progressPercent}%', 'Progress'),
                    _miniStatBox(
                      Icons.military_tech_outlined,
                      '${c.unlockedAchievementCount}/${c.totalAchievementCount}',
                      'Achievements',
                    ),
                  ];
                  if (compact) {
                    return Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: stats
                          .map(
                            (s) => SizedBox(
                              width: (constraints.maxWidth - 10) / 2,
                              child: s,
                            ),
                          )
                          .toList(),
                    );
                  }
                  return Row(
                    children: [
                      Expanded(child: stats[0]),
                      const SizedBox(width: 10),
                      Expanded(child: stats[1]),
                      const SizedBox(width: 10),
                      Expanded(child: stats[2]),
                    ],
                  );
                },
              ),
              const SizedBox(height: 14),
              VCard(
                padding: const EdgeInsets.all(14),
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        color: VirtuoMvpColors.purple.withValues(alpha: 0.2),
                        border: Border.all(
                          color: VirtuoMvpColors.purple.withValues(alpha: 0.4),
                        ),
                      ),
                      child: const Icon(
                        Icons.emoji_events_outlined,
                        color: VirtuoMvpColors.purple,
                        size: 26,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${c.unlockedAchievementCount} of ${c.totalAchievementCount} unlocked',
                            style: const TextStyle(
                              color: VirtuoMvpColors.text,
                              fontWeight: FontWeight.w900,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Complete sessions and missions to earn badges.',
                            style: TextStyle(
                              color: VirtuoMvpColors.textMuted,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                    VButton(
                      title: 'View',
                      height: 34,
                      variant: VButtonVariant.outline,
                      onPressed: () =>
                          Navigator.pushNamed(context, AppRoutes.achievements),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              const Text(
                'Active Mission',
                style: TextStyle(
                  color: VirtuoMvpColors.text,
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 10),
              VCard(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color: VirtuoMvpColors.surface,
                            border: Border.all(color: VirtuoMvpColors.stroke),
                          ),
                          child: const Icon(Icons.radio_button_checked_outlined, size: 18, color: VirtuoMvpColors.text),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Interview Preparation',
                                style: TextStyle(
                                  color: VirtuoMvpColors.text,
                                  fontWeight: FontWeight.w900,
                                  fontSize: 14,
                                ),
                              ),
                              Text(
                                neural.full
                                    ? 'Neural stack fully linked'
                                    : 'Complete sessions to grow mission progress',
                                style: const TextStyle(
                                  color: VirtuoMvpColors.textMuted,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 10),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(6),
                                child: LinearProgressIndicator(
                                  value: missionPct,
                                  minHeight: 8,
                                  backgroundColor: VirtuoMvpColors.surface,
                                  color: VirtuoMvpColors.purple,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '${c.missionProgress}% mission complete',
                                style: const TextStyle(
                                  color: VirtuoMvpColors.textFaint,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    VButton(
                      title: 'Resume Mission',
                      variant: VButtonVariant.outline,
                      icon: Icons.play_arrow_outlined,
                      expanded: true,
                      onPressed: () => Navigator.pushNamed(context, AppRoutes.interview),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              const Text(
                'Session History',
                style: TextStyle(
                  color: VirtuoMvpColors.text,
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 10),
              VCard(
                padding: EdgeInsets.zero,
                child: sessions.isEmpty
                    ? const Padding(
                        padding: EdgeInsets.all(16),
                        child: Text(
                          'No sessions yet. Start an AI session to populate history.',
                          style: TextStyle(color: VirtuoMvpColors.textMuted, fontSize: 12),
                        ),
                      )
                    : Column(
                        children: [
                          for (var i = 0; i < sessions.length; i++) ...[
                            if (i > 0)
                              Container(height: 1, color: VirtuoMvpColors.stroke),
                            _sessionTile(context, sessions[i]),
                          ],
                        ],
                      ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: VButton(
                      title: 'Customize AI',
                      variant: VButtonVariant.ghost,
                      icon: Icons.tune_outlined,
                      onPressed: () => Navigator.pushNamed(context, AppRoutes.avatar),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: VButton(
                      title: 'Neural Analytics',
                      variant: VButtonVariant.ghost,
                      icon: Icons.analytics_outlined,
                      onPressed: () => Navigator.pushNamed(context, AppRoutes.analytics),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: VButton(
                      title: 'Video CV',
                      variant: VButtonVariant.ghost,
                      icon: Icons.videocam_outlined,
                      onPressed: () => Navigator.pushNamed(context, AppRoutes.videoCv),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: VButton(
                      title: 'Voice Session',
                      variant: VButtonVariant.ghost,
                      icon: Icons.call_outlined,
                      onPressed: () => Navigator.pushNamed(context, AppRoutes.voiceSession),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: VButton(
                      title: 'Interview Prep',
                      variant: VButtonVariant.ghost,
                      icon: Icons.psychology_outlined,
                      onPressed: () => Navigator.pushNamed(context, AppRoutes.interview),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: VButton(
                      title: 'Presentation',
                      variant: VButtonVariant.ghost,
                      icon: Icons.groups_outlined,
                      onPressed: () => Navigator.pushNamed(context, AppRoutes.presentation),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              VButton(
                title: 'Upgrade Neural Access',
                variant: VButtonVariant.outline,
                icon: Icons.diamond_outlined,
                expanded: true,
                onPressed: () => Navigator.pushNamed(context, AppRoutes.premium),
              ),
              const SizedBox(height: 10),
              VButton(
                title: 'Feedback & Recommendations',
                variant: VButtonVariant.outline,
                icon: Icons.auto_awesome_outlined,
                expanded: true,
                onPressed: () => Navigator.pushNamed(context, AppRoutes.feedback),
              ),
              const SizedBox(height: 10),
              VButton(
                title: 'Role Play Simulation',
                variant: VButtonVariant.outline,
                icon: Icons.people_outline,
                expanded: true,
                onPressed: () => Navigator.pushNamed(context, AppRoutes.rolePlay),
              ),
              if (c.isAdmin) ...[
                const SizedBox(height: 14),
                const Text(
                  'Institutional Console',
                  style: TextStyle(
                    color: VirtuoMvpColors.text,
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: VButton(
                        title: AppText.tr(context, 'admin_user_mgmt'),
                        variant: VButtonVariant.outline,
                        icon: Icons.admin_panel_settings_outlined,
                        onPressed: () => Navigator.pushNamed(context, AppRoutes.adminUsers),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: VButton(
                        title: 'Training Analytics',
                        variant: VButtonVariant.outline,
                        icon: Icons.insights_outlined,
                        onPressed: () =>
                            Navigator.pushNamed(context, AppRoutes.adminTrainingAnalytics),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _dashIconBtn(BuildContext context, IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: VirtuoMvpColors.surface,
          border: Border.all(color: VirtuoMvpColors.stroke),
        ),
        child: Icon(icon, size: 20, color: VirtuoMvpColors.text),
      ),
    );
  }

  Widget _miniStatBox(IconData icon, String value, String label) {
    return Container(
      height: 96,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(VirtuoMvpRadii.lg),
        color: VirtuoMvpColors.surface,
        border: Border.all(color: VirtuoMvpColors.stroke),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 16, color: VirtuoMvpColors.cyan),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              color: VirtuoMvpColors.text,
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
          Text(
            label,
            style: const TextStyle(
              color: VirtuoMvpColors.textMuted,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _sessionTile(BuildContext context, SessionRecord s) {
    final isRole = s.type.contains('Role');
    return InkWell(
      onTap: () => Navigator.pushNamed(
        context,
        isRole ? AppRoutes.rolePlay : AppRoutes.session,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: VirtuoMvpColors.surface,
                border: Border.all(color: VirtuoMvpColors.stroke),
              ),
              child: Icon(
                isRole ? Icons.forum_outlined : Icons.play_arrow_outlined,
                size: 16,
                color: VirtuoMvpColors.text,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    s.type,
                    style: const TextStyle(
                      color: VirtuoMvpColors.text,
                      fontWeight: FontWeight.w900,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    s.prompt.length > 48 ? '${s.prompt.substring(0, 48)}…' : s.prompt,
                    style: const TextStyle(
                      color: VirtuoMvpColors.textMuted,
                      fontWeight: FontWeight.w700,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(999),
                color: const Color.fromRGBO(139, 92, 255, 0.25),
                border: Border.all(color: VirtuoMvpColors.stroke),
              ),
              child: Text(
                isRole ? 'Role-play' : 'Session',
                style: const TextStyle(
                  color: VirtuoMvpColors.text,
                  fontWeight: FontWeight.w900,
                  fontSize: 10,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

