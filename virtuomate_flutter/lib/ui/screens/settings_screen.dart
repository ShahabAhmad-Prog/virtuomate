import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:virtuomate_flutter/theme/virtuomate_mvp_theme.dart';
import 'package:virtuomate_flutter/ui/mvp/mvp_shell.dart';
import 'package:virtuomate_flutter/ui/mvp/mvp_widgets.dart';
import 'package:virtuomate_flutter/ui/shared/neural_connectivity_card.dart';
import 'package:virtuomate_flutter/ui/shared/profile_avatar_thumbnail.dart';
import 'package:virtuomate_flutter/ui/virtuomate_bindings.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      VirtuoMateScope.of(context).refreshNeuralConnectivity();
    });
  }

  void _pickLanguage(VirtuoMateController c, String code) {
    if (c.locale.languageCode == code) return;
    c.setLocale(code);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppText.tr(context, 'language_changed'))),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: VirtuoMateScope.of(context),
      builder: (context, _) {
        final c = VirtuoMateScope.of(context);
        final email = c.user?.email ?? AppText.tr(context, 'not_logged_in');
        final lang = c.locale.languageCode;

        return MvpShell(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          MvpTopBar(title: AppText.tr(context, 'settings')),
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
                  Text(
                    AppText.tr(context, 'manage_prefs'),
                    style: const TextStyle(color: VirtuoMvpColors.textMuted, fontSize: 12),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    AppText.tr(context, 'profile'),
                    style: const TextStyle(
                      color: VirtuoMvpColors.text,
                      fontWeight: FontWeight.w900,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                  VCard(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const ProfileAvatarThumbnail(size: 64, borderWidth: 2),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    c.displayName,
                                    style: const TextStyle(
                                      color: VirtuoMvpColors.text,
                                      fontWeight: FontWeight.w900,
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    email,
                                    style: const TextStyle(
                                      color: VirtuoMvpColors.cyan,
                                      fontWeight: FontWeight.w800,
                                      fontSize: 11,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  VButton(
                                    title: AppText.tr(context, 'edit_profile'),
                                    variant: VButtonVariant.outline,
                                    onPressed: () => Navigator.pushNamed(context, AppRoutes.userConfig),
                                  ),
                                  const SizedBox(height: 8),
                                  VButton(
                                    title: AppText.tr(context, 'change_photo'),
                                    variant: VButtonVariant.ghost,
                                    height: 36,
                                    onPressed: () => Navigator.pushNamed(context, AppRoutes.avatar),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(VirtuoMvpRadii.lg),
                            color: VirtuoMvpColors.inputFill,
                            border: Border.all(color: VirtuoMvpColors.stroke),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.workspace_premium_outlined, size: 16, color: VirtuoMvpColors.textMuted),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      AppText.tr(context, 'plan'),
                                      style: const TextStyle(
                                        color: VirtuoMvpColors.text,
                                        fontWeight: FontWeight.w900,
                                        fontSize: 12,
                                      ),
                                    ),
                                    const Text(
                                      'Premium / Free — manage on Premium screen',
                                      style: TextStyle(
                                        color: VirtuoMvpColors.textMuted,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 11,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              VButton(
                                title: AppText.tr(context, 'upgrade'),
                                onPressed: () => Navigator.pushNamed(context, AppRoutes.premium),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  NeuralConnectivityCard(
                    status: c.neuralConnectivity,
                    onRefresh: () => c.refreshNeuralConnectivity(),
                    refreshing: c.neuralRefreshInFlight,
                  ),
                  const SizedBox(height: 14),
                  VCard(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppText.tr(context, 'accessibility_localization'),
                          style: const TextStyle(
                            color: VirtuoMvpColors.text,
                            fontWeight: FontWeight.w900,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          AppText.tr(context, 'language'),
                          style: const TextStyle(
                            color: VirtuoMvpColors.textMuted,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: _LanguageChip(
                                label: AppText.tr(context, 'english'),
                                selected: lang == 'en',
                                onTap: () => _pickLanguage(c, 'en'),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _LanguageChip(
                                label: AppText.tr(context, 'urdu'),
                                selected: lang == 'ur',
                                onTap: () => _pickLanguage(c, 'ur'),
                              ),
                            ),
                          ],
                        ),
                        if (AppText.isUrdu(c.locale)) ...[
                          const SizedBox(height: 10),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              color: VirtuoMvpColors.amber.withValues(alpha: 0.12),
                              border: Border.all(
                                color: VirtuoMvpColors.amber.withValues(alpha: 0.4),
                              ),
                            ),
                            child: Text(
                              AppText.tr(context, 'language_partial_note'),
                              style: const TextStyle(
                                color: VirtuoMvpColors.amber,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                height: 1.4,
                              ),
                            ),
                          ),
                        ],
                        const SizedBox(height: 12),
                        _settingsToggle(
                          AppText.tr(context, 'high_contrast'),
                          'Increase contrast for readability',
                          c.highContrast,
                          c.setHighContrast,
                        ),
                        Text(
                          'Text size scale: ${c.textScale.toStringAsFixed(1)}x',
                          style: const TextStyle(color: VirtuoMvpColors.textMuted, fontSize: 12),
                        ),
                        Slider(
                          min: 0.9,
                          max: 1.4,
                          divisions: 5,
                          value: c.textScale,
                          activeColor: VirtuoMvpColors.cyan,
                          onChanged: c.setTextScale,
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
                          'Notifications',
                          style: TextStyle(
                            color: VirtuoMvpColors.text,
                            fontWeight: FontWeight.w900,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 10),
                        _notifRow(
                          'Email Notifications',
                          'Receive updates via email',
                          c.emailNotifications,
                          (v) => c.setNotificationPrefs(emailNotifications: v),
                        ),
                        _notifRow(
                          'Push Notifications',
                          'Get notified on your device',
                          c.pushNotifications,
                          (v) => c.setNotificationPrefs(pushNotifications: v),
                        ),
                        _notifRow(
                          'Session Reminders',
                          'Remind me to practice',
                          c.sessionReminders,
                          (v) => c.setNotificationPrefs(sessionReminders: v),
                        ),
                        _notifRow(
                          'Achievement Alerts',
                          'Notify when I earn badges',
                          c.achievementAlerts,
                          (v) => c.setNotificationPrefs(achievementAlerts: v),
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
                          'Security & Privacy',
                          style: TextStyle(
                            color: VirtuoMvpColors.text,
                            fontWeight: FontWeight.w900,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 10),
                        _settingsRowTile(
                          Icons.lock_outline,
                          'Change Password',
                          onTap: () => _showChangePasswordDialog(context, c),
                        ),
                        const SizedBox(height: 10),
                        _settingsRowTile(
                          Icons.shield_outlined,
                          'Privacy Settings',
                          onTap: () => _showPrivacyDialog(context),
                        ),
                        const SizedBox(height: 10),
                        _settingsRowTile(
                          Icons.payment_outlined,
                          'Payment Methods',
                          onTap: () => Navigator.pushNamed(context, AppRoutes.premium),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    AppText.tr(context, 'privacy_data'),
                    style: const TextStyle(
                      color: VirtuoMvpColors.text,
                      fontWeight: FontWeight.w900,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 10),
                  VButton(
                    title: AppText.tr(context, 'export_data'),
                    variant: VButtonVariant.outline,
                    icon: Icons.download_outlined,
                    expanded: true,
                    onPressed: () async {
                      try {
                        final data = await c.exportMyData();
                        if (!context.mounted) return;
                        final pretty = const JsonEncoder.withIndent('  ').convert(data);
                        if (kIsWeb) {
                          await Share.share(pretty, subject: 'VirtuoMate data export');
                        } else {
                          final dir = await getTemporaryDirectory();
                          final file = File(
                            '${dir.path}/virtuomate_export_${DateTime.now().millisecondsSinceEpoch}.json',
                          );
                          await file.writeAsString(pretty);
                          await Share.shareXFiles(
                            [XFile(file.path, mimeType: 'application/json')],
                            subject: 'VirtuoMate data export',
                          );
                        }
                      } catch (e) {
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
                      }
                    },
                  ),
                  const SizedBox(height: 10),
                  VButton(
                    title: AppText.tr(context, 'logout'),
                    variant: VButtonVariant.outline,
                    icon: Icons.logout,
                    expanded: true,
                    onPressed: () {
                      c.logout();
                      Navigator.pushNamedAndRemoveUntil(context, AppRoutes.welcome, (_) => false);
                    },
                  ),
                  const SizedBox(height: 10),
                  VButton(
                    title: AppText.tr(context, 'delete_account'),
                    variant: VButtonVariant.outline,
                    icon: Icons.delete_outline,
                    expanded: true,
                    onPressed: () async {
                      final shouldDelete = await showDialog<bool>(
                        context: context,
                        builder: (dialogContext) => AlertDialog(
                          title: Text(AppText.tr(context, 'delete_account')),
                          content: Text(AppText.tr(context, 'confirm_delete')),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(dialogContext).pop(false),
                              child: Text(AppText.tr(context, 'cancel')),
                            ),
                            FilledButton(
                              onPressed: () => Navigator.of(dialogContext).pop(true),
                              child: Text(AppText.tr(context, 'confirm')),
                            ),
                          ],
                        ),
                      );
                      if (shouldDelete != true) return;
                      try {
                        final deleted = await c.deleteMyAccount();
                        if (!context.mounted) return;
                        if (deleted) {
                          Navigator.pushNamedAndRemoveUntil(context, AppRoutes.welcome, (_) => false);
                        }
                      } catch (e) {
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
      },
    );
  }

  Widget _settingsToggle(String title, String sub, bool value, ValueChanged<bool> onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: VirtuoMvpColors.text,
                    fontWeight: FontWeight.w900,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  sub,
                  style: const TextStyle(
                    color: VirtuoMvpColors.textMuted,
                    fontWeight: FontWeight.w700,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: VirtuoMvpColors.cyan,
            activeTrackColor: VirtuoMvpColors.blue.withValues(alpha: 0.6),
          ),
        ],
      ),
    );
  }

  Future<void> _showChangePasswordDialog(BuildContext context, VirtuoMateController c) async {
    final current = TextEditingController();
    final next = TextEditingController();
    final confirm = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Change password'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: current,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Current password'),
            ),
            TextField(
              controller: next,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'New password'),
            ),
            TextField(
              controller: confirm,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Confirm new password'),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Update')),
        ],
      ),
    );
    if (ok != true || !context.mounted) return;
    if (next.text != confirm.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('New passwords do not match.')),
      );
      return;
    }
    final success = await c.changePassword(
      currentPassword: current.text,
      newPassword: next.text,
    );
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(success ? 'Password updated.' : c.errorMessage)),
    );
  }

  void _showPrivacyDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Privacy'),
        content: const SingleChildScrollView(
          child: Text(
            'VirtuoMate stores your profile, coaching sessions, and preferences in Firebase. '
            'We use your data only to deliver AI coaching and analytics. '
            'You can export or delete your account from Settings. '
            'Contact admin@virtuomate.app for data requests.',
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Close')),
        ],
      ),
    );
  }

  Widget _notifRow(String title, String sub, bool value, ValueChanged<bool> onChanged) {
    return Container(
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: VirtuoMvpColors.stroke)),
      ),
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: VirtuoMvpColors.text,
                    fontWeight: FontWeight.w900,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  sub,
                  style: const TextStyle(
                    color: VirtuoMvpColors.textMuted,
                    fontWeight: FontWeight.w700,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: VirtuoMvpColors.cyan,
            activeTrackColor: VirtuoMvpColors.blue.withValues(alpha: 0.6),
          ),
        ],
      ),
    );
  }

  Widget _settingsRowTile(IconData icon, String title, {VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(VirtuoMvpRadii.lg),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(VirtuoMvpRadii.lg),
          color: VirtuoMvpColors.inputFill,
          border: Border.all(color: VirtuoMvpColors.stroke),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(icon, size: 16, color: VirtuoMvpColors.textMuted),
                const SizedBox(width: 10),
                Text(
                  title,
                  style: const TextStyle(
                    color: VirtuoMvpColors.text,
                    fontWeight: FontWeight.w800,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            const Icon(Icons.chevron_right, size: 16, color: VirtuoMvpColors.textFaint),
          ],
        ),
      ),
    );
  }
}

class _LanguageChip extends StatelessWidget {
  const _LanguageChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(VirtuoMvpRadii.lg),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(VirtuoMvpRadii.lg),
            color: selected
                ? VirtuoMvpColors.cyan.withValues(alpha: 0.15)
                : VirtuoMvpColors.inputFill,
            border: Border.all(
              color: selected ? VirtuoMvpColors.cyan : VirtuoMvpColors.stroke,
              width: selected ? 1.5 : 1,
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              color: selected ? VirtuoMvpColors.cyan : VirtuoMvpColors.text,
              fontWeight: FontWeight.w800,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }
}

