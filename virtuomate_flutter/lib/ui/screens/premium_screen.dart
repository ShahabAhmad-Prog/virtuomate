import 'package:flutter/material.dart';
import 'package:virtuomate_flutter/external/subscription_result.dart';
import 'package:virtuomate_flutter/services/app_service.dart';
import 'package:virtuomate_flutter/theme/virtuomate_mvp_theme.dart';
import 'package:virtuomate_flutter/ui/mvp/mvp_shell.dart';
import 'package:virtuomate_flutter/ui/mvp/mvp_widgets.dart';
import 'package:virtuomate_flutter/ui/virtuomate_bindings.dart';

class PremiumScreen extends StatefulWidget {
  const PremiumScreen({super.key});

  @override
  State<PremiumScreen> createState() => _PremiumScreenState();
}

class _PremiumScreenState extends State<PremiumScreen> {
  String? _busyPlan;

  Future<void> _selectPlan(String title) async {
    final planId = title.toLowerCase();
    setState(() => _busyPlan = planId);
    final c = VirtuoMateScope.of(context);
    final outcome = await c.subscribeToPlan(planId);
    if (!mounted) return;
    setState(() => _busyPlan = null);

    final message = switch (outcome) {
      PremiumSubscribeOutcome.activated => 'Premium activated ($title plan)',
      PremiumSubscribeOutcome.alreadyPremium => 'You already have Premium active',
      PremiumSubscribeOutcome.checkoutOpened =>
        'Complete payment in your browser to activate Premium',
      null => c.errorMessage.isNotEmpty ? c.errorMessage : 'Could not activate Premium',
      PremiumSubscribeOutcome.failed => c.errorMessage.isNotEmpty
          ? c.errorMessage
          : 'Could not activate Premium',
    };

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
    if (outcome == PremiumSubscribeOutcome.activated ||
        outcome == PremiumSubscribeOutcome.alreadyPremium) {
      setState(() {});
    }
  }

  Widget _priceCard(
    BuildContext context,
    String title,
    String price,
    String suffix, {
    String? badge,
    bool highlight = false,
  }) {
    final planId = title.toLowerCase();
    final busy = _busyPlan == planId;

    return VCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: VirtuoMvpColors.text,
                  fontWeight: FontWeight.w900,
                  fontSize: 14,
                ),
              ),
              if (badge != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(999),
                    color: const Color.fromRGBO(139, 92, 255, 0.35),
                    border: Border.all(color: VirtuoMvpColors.stroke2),
                  ),
                  child: Text(
                    badge,
                    style: const TextStyle(
                      color: VirtuoMvpColors.text,
                      fontWeight: FontWeight.w900,
                      fontSize: 10,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                price,
                style: const TextStyle(
                  color: VirtuoMvpColors.cyan,
                  fontWeight: FontWeight.w900,
                  fontSize: 28,
                ),
              ),
              const SizedBox(width: 6),
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  suffix,
                  style: const TextStyle(
                    color: VirtuoMvpColors.textMuted,
                    fontWeight: FontWeight.w800,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          VButton(
            title: busy ? 'Activating…' : 'Select',
            variant: highlight ? VButtonVariant.primary : VButtonVariant.outline,
            expanded: true,
            onPressed: _busyPlan != null ? null : () => _selectPlan(title),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = VirtuoMateScope.of(context);
    return MvpShell(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const MvpTopBar(title: 'Upgrade Neural Access'),
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
                    'Unlock unlimited AI potential',
                    style: TextStyle(color: VirtuoMvpColors.textMuted, fontSize: 12),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    c.isPremium ? 'Status: Premium active' : 'Status: Free tier',
                    style: const TextStyle(
                      color: VirtuoMvpColors.cyan,
                      fontWeight: FontWeight.w800,
                      fontSize: 12,
                    ),
                  ),
                  if (!c.isPremium) ...[
                    const SizedBox(height: 8),
                    const Text(
                      'Tap Select on a plan. Mock billing activates instantly on the server; '
                      'Stripe opens checkout in your browser when configured.',
                      style: TextStyle(
                        color: VirtuoMvpColors.textFaint,
                        fontSize: 10,
                        height: 1.35,
                      ),
                    ),
                  ],
                  const SizedBox(height: 14),
                  _priceCard(context, 'Monthly', r'$29', 'per month'),
                  const SizedBox(height: 12),
                  Container(
                    decoration: highlightDecoration(),
                    child: _priceCard(
                      context,
                      'Annual',
                      r'$249',
                      'per year',
                      badge: 'Most Popular',
                      highlight: true,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _priceCard(context, 'Lifetime', r'$499', 'one-time'),
                  const SizedBox(height: 14),
                  VCard(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Neural Features Comparison',
                          style: TextStyle(
                            color: VirtuoMvpColors.text,
                            fontWeight: FontWeight.w900,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          'Basic Access',
                          style: TextStyle(
                            color: VirtuoMvpColors.textMuted,
                            fontWeight: FontWeight.w900,
                            fontSize: 12,
                          ),
                        ),
                        _premBullet('${AppService.freeSessionLimit} coaching sessions (free tier)', false),
                        _premBullet('Basic avatar customization', false),
                        _premBullet('Standard feedback', false),
                        _premBullet('Community support', false),
                        const SizedBox(height: 12),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(VirtuoMvpRadii.lg),
                            color: const Color.fromRGBO(139, 92, 255, 0.18),
                            border: Border.all(color: VirtuoMvpColors.stroke),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Premium Neural Access',
                                style: TextStyle(
                                  color: VirtuoMvpColors.text,
                                  fontWeight: FontWeight.w900,
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(height: 8),
                              _premBullet('Unlimited coaching sessions', true),
                              _premBullet('Advanced avatar customization', true),
                              _premBullet('AI-powered detailed feedback', true),
                              _premBullet('Priority support 24/7', true),
                              _premBullet('Video CV creator', true),
                              _premBullet('Advanced analytics', true),
                              _premBullet('Custom role-play scenarios', true),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  VCard(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        const Text(
                          '30-Day Money Back Guarantee',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: VirtuoMvpColors.green,
                            fontWeight: FontWeight.w900,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Try premium risk-free. Full refund if you are not satisfied.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: VirtuoMvpColors.textMuted,
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
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

  BoxDecoration highlightDecoration() {
    return BoxDecoration(
      borderRadius: BorderRadius.circular(VirtuoMvpRadii.lg),
      border: Border.all(color: const Color.fromRGBO(59, 231, 255, 0.22)),
      color: const Color.fromRGBO(59, 231, 255, 0.06),
    );
  }

  Widget _premBullet(String t, bool premium) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.check,
            size: 14,
            color: premium ? VirtuoMvpColors.cyan : VirtuoMvpColors.textMuted,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              t,
              style: TextStyle(
                color: premium ? VirtuoMvpColors.text : VirtuoMvpColors.textMuted,
                fontWeight: FontWeight.w700,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
