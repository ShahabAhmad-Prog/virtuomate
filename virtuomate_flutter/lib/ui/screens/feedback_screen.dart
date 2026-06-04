import 'package:flutter/material.dart';
import 'package:virtuomate_flutter/theme/virtuomate_mvp_theme.dart';
import 'package:virtuomate_flutter/ui/mvp/mvp_shell.dart';
import 'package:virtuomate_flutter/ui/mvp/mvp_widgets.dart';
import 'package:virtuomate_flutter/ui/shared/responsive.dart';
import 'package:virtuomate_flutter/ui/virtuomate_bindings.dart';

class FeedbackScreen extends StatelessWidget {
  const FeedbackScreen({super.key});

  Widget _metric(String label, String value, Color line) {
    return Expanded(
      child: VCard(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Text(
              value,
              style: const TextStyle(
                color: VirtuoMvpColors.text,
                fontWeight: FontWeight.w900,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: const TextStyle(
                color: VirtuoMvpColors.textMuted,
                fontWeight: FontWeight.w800,
                fontSize: 11,
              ),
            ),
            const SizedBox(height: 6),
            Container(
              height: 3,
              width: 40,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(999),
                color: line,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = VirtuoMateScope.of(context);
    final a = c.analytics;
    final latest = c.latestSessionRecord;
    return MvpShell(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const MvpTopBar(title: 'Analytics & Feedback'),
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
                    'Personalized insights and next-step recommendations',
                    style: TextStyle(color: VirtuoMvpColors.textMuted, fontSize: 12),
                  ),
                  const SizedBox(height: 14),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final compact = constraints.maxWidth < VirtuoBreakpoints.compact;
                      final metrics = [
                        _metric('Sentiment', '${a.avgSentiment}%', VirtuoMvpColors.cyan),
                        _metric('Confidence', '${a.avgConfidence}%', VirtuoMvpColors.purple),
                        _metric('Engagement', '${a.avgEngagement}%', VirtuoMvpColors.green),
                      ];
                      if (compact) {
                        return Column(
                          children: [
                            Row(children: [metrics[0], const SizedBox(width: 10), metrics[1]]),
                            const SizedBox(height: 10),
                            metrics[2],
                          ],
                        );
                      }
                      return Row(
                        children: [
                          metrics[0],
                          const SizedBox(width: 10),
                          metrics[1],
                          const SizedBox(width: 10),
                          metrics[2],
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 14),
                  VCard(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.auto_awesome_outlined, color: VirtuoMvpColors.cyan, size: 18),
                            const SizedBox(width: 10),
                            const Text(
                              'AI Recommendations',
                              style: TextStyle(
                                color: VirtuoMvpColors.text,
                                fontWeight: FontWeight.w900,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        _fbBullet(
                          a.interviewSessions < 3
                              ? 'Complete more interview practice sessions to unlock advanced coaching'
                              : 'Strong interview progress — focus on executive presence next',
                        ),
                        _fbBullet(
                          a.presentationSessions < 2
                              ? 'Practice presentation skills 2–3 times this week'
                              : 'Presentation skills are improving — refine slide transitions',
                        ),
                        _fbBullet(
                          'Mission progress: ${a.progressPercent}% toward your coaching goals',
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  VCard(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Detailed Feedback',
                          style: TextStyle(
                            color: VirtuoMvpColors.text,
                            fontWeight: FontWeight.w900,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 10),
                        _fbRow(
                          'Clarity',
                          latest != null && latest.confidenceScore >= 70 ? 'Strong' : 'Developing',
                          VirtuoMvpColors.green,
                        ),
                        _fbRow(
                          'Emotion',
                          latest?.emotion ?? 'Neutral',
                          VirtuoMvpColors.cyan,
                        ),
                        _fbRow(
                          'Confidence',
                          latest != null ? '${latest.confidenceScore}%' : '—',
                          VirtuoMvpColors.yellow,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  VCard(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Latest session output',
                          style: TextStyle(
                            color: VirtuoMvpColors.text,
                            fontWeight: FontWeight.w900,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          c.latestFeedback.isEmpty
                              ? 'Complete a session to see live AI feedback here.'
                              : c.latestFeedback,
                          style: const TextStyle(
                            color: VirtuoMvpColors.textMuted,
                            fontSize: 12,
                            height: 1.45,
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
        ],
      ),
    );
  }

  Widget _fbBullet(String t) {
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 6,
            height: 6,
            margin: const EdgeInsets.only(top: 5),
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: VirtuoMvpColors.cyan,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              t,
              style: const TextStyle(
                color: VirtuoMvpColors.textMuted,
                fontWeight: FontWeight.w700,
                fontSize: 12,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _fbRow(String k, String v, Color c) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: VirtuoMvpColors.stroke),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            k,
            style: const TextStyle(
              color: VirtuoMvpColors.textMuted,
              fontWeight: FontWeight.w800,
              fontSize: 12,
            ),
          ),
          Text(
            v,
            style: TextStyle(color: c, fontWeight: FontWeight.w900, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

