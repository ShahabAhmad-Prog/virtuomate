import 'package:flutter/material.dart';
import 'package:virtuomate_flutter/services/admin_api_service.dart';
import 'package:virtuomate_flutter/theme/virtuomate_mvp_theme.dart';
import 'package:virtuomate_flutter/ui/virtuomate_bindings.dart';
import 'package:virtuomate_flutter/ui/mvp/mvp_shell.dart';
import 'package:virtuomate_flutter/ui/mvp/mvp_widgets.dart';

class AdminUserManagementScreen extends StatefulWidget {
  const AdminUserManagementScreen({super.key});

  @override
  State<AdminUserManagementScreen> createState() => _AdminUserManagementScreenState();
}

class _AdminUserManagementScreenState extends State<AdminUserManagementScreen> {
  List<AdminUserRow> _users = [];
  String _error = '';
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final c = VirtuoMateScope.of(context);
    if (c.adminApi == null) {
      setState(() {
        _loading = false;
        _error = 'Admin API requires backend mode.';
        _users = c.user != null
            ? [
                AdminUserRow(
                  uid: 'local',
                  email: c.user!.email,
                  displayName: c.displayName,
                  isPremium: c.isPremium,
                  videoCvCount: c.analytics.videoCvGenerated,
                  missionProgress: c.missionProgress,
                ),
              ]
            : [];
      });
      return;
    }
    try {
      final users = await c.adminApi!.fetchUsers();
      if (mounted) setState(() { _users = users; _loading = false; _error = ''; });
    } catch (e) {
      if (mounted) setState(() { _error = e.toString(); _loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MvpShell(
      body: Column(
        children: [
          MvpTopBar(title: AppText.tr(context, 'admin_user_mgmt')),
          if (_loading)
            const Expanded(child: Center(child: CircularProgressIndicator()))
          else if (_error.isNotEmpty)
            Expanded(
              child: Center(
                child: Text(_error, style: const TextStyle(color: VirtuoMvpColors.red, fontSize: 12)),
              ),
            )
          else
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.all(VirtuoMvpSpacing.lg),
                itemCount: _users.length,
                separatorBuilder: (context, index) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final u = _users[index];
                  return VCard(
                    padding: const EdgeInsets.all(14),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                u.displayName.isNotEmpty ? u.displayName : u.email,
                                style: const TextStyle(color: VirtuoMvpColors.text, fontWeight: FontWeight.w900),
                              ),
                              Text(u.email, style: const TextStyle(color: VirtuoMvpColors.textMuted, fontSize: 11)),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(999),
                            color: u.isPremium
                                ? VirtuoMvpColors.cyan.withValues(alpha: 0.2)
                                : VirtuoMvpColors.surface,
                          ),
                          child: Text(
                            u.isPremium ? 'Premium' : 'Free',
                            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}

class AdminTrainingAnalyticsScreen extends StatefulWidget {
  const AdminTrainingAnalyticsScreen({super.key});

  @override
  State<AdminTrainingAnalyticsScreen> createState() => _AdminTrainingAnalyticsScreenState();
}

class _AdminTrainingAnalyticsScreenState extends State<AdminTrainingAnalyticsScreen> {
  AdminAnalytics? _analytics;
  String _error = '';
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final c = VirtuoMateScope.of(context);
    if (c.adminApi == null) {
      setState(() { _loading = false; _error = 'Connect backend API for institutional analytics.'; });
      return;
    }
    try {
      final a = await c.adminApi!.fetchAnalytics();
      if (mounted) setState(() { _analytics = a; _loading = false; });
    } catch (e) {
      if (mounted) setState(() { _error = e.toString(); _loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = VirtuoMateScope.of(context);
    final a = _analytics;
    return MvpShell(
      body: Column(
        children: [
          MvpTopBar(title: AppText.tr(context, 'admin_training_analytics')),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(VirtuoMvpSpacing.lg),
              children: [
                if (_loading)
                  const Center(child: CircularProgressIndicator())
                else if (_error.isNotEmpty)
                  Text(_error, style: const TextStyle(color: VirtuoMvpColors.red))
                else if (a != null) ...[
                  Row(
                    children: [
                      _stat('Users', '${a.totalUsers}'),
                      const SizedBox(width: 8),
                      _stat('Premium', '${a.premiumUsers}'),
                      const SizedBox(width: 8),
                      _stat('Sessions', '${a.totalSessions}'),
                    ],
                  ),
                  const SizedBox(height: 14),
                  const Text('Recent user sessions', style: TextStyle(color: VirtuoMvpColors.text, fontWeight: FontWeight.w900)),
                  const SizedBox(height: 10),
                  ...c.sessions.reversed.take(8).map(
                        (s) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: VCard(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(s.type, style: const TextStyle(color: VirtuoMvpColors.cyan, fontWeight: FontWeight.w800, fontSize: 11)),
                                Text(s.prompt, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(color: VirtuoMvpColors.textMuted, fontSize: 11)),
                              ],
                            ),
                          ),
                        ),
                      ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _stat(String label, String value) {
    return Expanded(
      child: VCard(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Text(value, style: const TextStyle(color: VirtuoMvpColors.text, fontWeight: FontWeight.w900, fontSize: 20)),
            Text(label, style: const TextStyle(color: VirtuoMvpColors.textMuted, fontSize: 11)),
          ],
        ),
      ),
    );
  }
}
