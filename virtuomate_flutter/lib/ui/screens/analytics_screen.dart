import 'package:flutter/material.dart';
import 'package:virtuomate_flutter/theme/virtuomate_mvp_theme.dart';
import 'package:virtuomate_flutter/ui/mvp/mvp_shell.dart';
import 'package:virtuomate_flutter/ui/mvp/mvp_widgets.dart';
import 'package:virtuomate_flutter/ui/virtuomate_bindings.dart';

class _ChartDot extends StatelessWidget {
  const _ChartDot();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 10,
      height: 10,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: VirtuoMvpColors.cyan,
      ),
    );
  }
}

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  Widget _statCard(String title, String value, String delta, IconData icon) {
    return Expanded(
      child: VCard(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: VirtuoMvpColors.cyan),
            const SizedBox(height: 6),
            Text(
              value,
              style: const TextStyle(
                color: VirtuoMvpColors.text,
                fontWeight: FontWeight.w900,
                fontSize: 18,
              ),
            ),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: VirtuoMvpColors.textMuted,
                fontWeight: FontWeight.w800,
                fontSize: 11,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              delta,
              style: const TextStyle(
                color: VirtuoMvpColors.green,
                fontWeight: FontWeight.w900,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _smallTile(String value, String label) {
    return Expanded(
      child: VCard(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              value,
              style: const TextStyle(
                color: VirtuoMvpColors.text,
                fontWeight: FontWeight.w900,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                color: VirtuoMvpColors.textMuted,
                fontWeight: FontWeight.w800,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final a = VirtuoMateScope.of(context).analytics;
    final total = a.conversationSessions + a.rolePlaySessions;
    return MvpShell(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const MvpTopBar(title: 'Neural Analytics'),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(
                VirtuoMvpSpacing.lg,
                0,
                VirtuoMvpSpacing.lg,
                VirtuoMvpSpacing.lg,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Track your AI-powered growth metrics',
                    style: TextStyle(color: VirtuoMvpColors.textMuted, fontSize: 12),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      _statCard('Avg Score', '${a.avgConfidence}%', '+12%', Icons.podcasts_outlined),
                      const SizedBox(width: 10),
                      _statCard('Sessions', '$total', '+${a.conversationSessions}', Icons.calendar_today_outlined),
                      const SizedBox(width: 10),
                      _statCard('Achievements', '${a.videoCvGenerated + a.interviewSessions}', '+${a.rolePlaySessions}', Icons.military_tech_outlined),
                    ],
                  ),
                  const SizedBox(height: 14),
                  const Text(
                    'Real-time AI Analysis',
                    style: TextStyle(
                      color: VirtuoMvpColors.text,
                      fontWeight: FontWeight.w900,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      _smallTile('${a.avgSentiment}%', 'Sentiment'),
                      const SizedBox(width: 10),
                      _smallTile('${a.avgConfidence}%', 'Confidence'),
                      const SizedBox(width: 10),
                      _smallTile('${a.avgEngagement}%', 'Engagement'),
                    ],
                  ),
                  const SizedBox(height: 14),
                  const Text(
                    'Progress Over Time',
                    style: TextStyle(
                      color: VirtuoMvpColors.text,
                      fontWeight: FontWeight.w900,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 10),
                  VCard(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        SizedBox(
                          height: 160,
                          child: Stack(
                            children: [
                              Positioned(
                                left: 0,
                                right: 0,
                                top: 80,
                                child: Container(height: 1, color: VirtuoMvpColors.stroke),
                              ),
                              const Positioned(left: 24, top: 88, child: _ChartDot()),
                              const Positioned(left: 88, top: 72, child: _ChartDot()),
                              const Positioned(left: 152, top: 61, child: _ChartDot()),
                              const Positioned(left: 216, top: 45, child: _ChartDot()),
                            ],
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: ['Week 1', 'Week 2', 'Week 3', 'Week 4']
                              .map(
                                (w) => Text(
                                  w,
                                  style: const TextStyle(
                                    color: VirtuoMvpColors.textFaint,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              )
                              .toList(),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  const Text(
                    'Weekly Activity',
                    style: TextStyle(
                      color: VirtuoMvpColors.text,
                      fontWeight: FontWeight.w900,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 10),
                  VCard(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: List.generate(5, (i) {
                        final h = 20.0 + [2, 3, 1, 4, 2][i] * 18.0;
                        return Expanded(
                          child: Column(
                            children: [
                              Container(
                                height: h,
                                width: 22,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  color: const Color.fromRGBO(139, 92, 255, 0.9),
                                  border: Border.all(color: VirtuoMvpColors.stroke2),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                ['Mon', 'Tue', 'Wed', 'Thu', 'Fri'][i],
                                style: const TextStyle(
                                  color: VirtuoMvpColors.textFaint,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                    ),
                  ),
                  const SizedBox(height: 14),
                  const Text(
                    'Skills Assessment',
                    style: TextStyle(
                      color: VirtuoMvpColors.text,
                      fontWeight: FontWeight.w900,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 10),
                  VCard(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        SizedBox(
                          height: 200,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Container(
                                width: 160,
                                height: 160,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(color: VirtuoMvpColors.stroke),
                                ),
                              ),
                              Container(
                                width: 120,
                                height: 120,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: const Color.fromRGBO(59, 231, 255, 0.18),
                                  border: Border.all(color: Color.fromRGBO(59, 231, 255, 0.22)),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 10),
                        ...[
                          'Communication',
                          'Leadership',
                          'Problem Solving',
                          'Presentation',
                          'Interview Skills',
                        ].map(
                          (t) => Padding(
                            padding: const EdgeInsets.only(bottom: 4),
                            child: Text(
                              t,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: VirtuoMvpColors.textMuted,
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  VCard(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Recorded counts',
                          style: TextStyle(
                            color: VirtuoMvpColors.text,
                            fontWeight: FontWeight.w900,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Conversations: ${a.conversationSessions} • Role-play: ${a.rolePlaySessions} • Video CV: ${a.videoCvGenerated}',
                          style: const TextStyle(color: VirtuoMvpColors.textMuted, fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

