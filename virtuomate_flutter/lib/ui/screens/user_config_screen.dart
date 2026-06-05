import 'package:flutter/material.dart';
import 'package:virtuomate_flutter/services/app_service.dart';
import 'package:virtuomate_flutter/theme/virtuomate_mvp_theme.dart';
import 'package:virtuomate_flutter/ui/virtuomate_bindings.dart';
import 'package:virtuomate_flutter/ui/mvp/mvp_shell.dart';
import 'package:virtuomate_flutter/ui/mvp/mvp_widgets.dart';
import 'package:virtuomate_flutter/ui/shared/profile_avatar_thumbnail.dart';
import 'package:virtuomate_flutter/ui/shared/ui_helpers.dart';

class UserConfigScreen extends StatefulWidget {
  const UserConfigScreen({super.key});

  @override
  State<UserConfigScreen> createState() => _UserConfigScreenState();
}

class _UserConfigScreenState extends State<UserConfigScreen> {
  late final TextEditingController _name;
  late final TextEditingController _email;
  late final TextEditingController _phone;
  String _message = '';
  bool _controllersReady = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_controllersReady) return;
    final c = VirtuoMateScope.of(context);
    _name = TextEditingController(text: c.displayName);
    _email = TextEditingController(text: c.user?.email ?? '');
    _phone = TextEditingController(text: c.phone);
    _controllersReady = true;
  }

  @override
  void dispose() {
    if (_controllersReady) {
      _name.dispose();
      _email.dispose();
      _phone.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_controllersReady) {
      return const MvpShell(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    final c = VirtuoMateScope.of(context);
    final used = c.sessions.length;
    final remaining = c.isPremium
        ? 'Unlimited'
        : '${(AppService.freeSessionLimit - used).clamp(0, AppService.freeSessionLimit)} sessions remaining';

    return MvpShell(
      body: Column(
        children: [
          MvpTopBar(title: AppText.tr(context, 'profile')),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(VirtuoMvpSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppText.tr(context, 'manage_prefs'),
                    style: const TextStyle(color: VirtuoMvpColors.textMuted, fontSize: 12),
                  ),
                  const SizedBox(height: 14),
                  VCard(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            const ProfileAvatarThumbnail(
                              size: 72,
                              showOnlineDot: true,
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(c.displayName, style: const TextStyle(color: VirtuoMvpColors.text, fontWeight: FontWeight.w900, fontSize: 16)),
                                  Text(c.user?.email ?? '', style: const TextStyle(color: VirtuoMvpColors.cyan, fontSize: 12)),
                                  const SizedBox(height: 8),
                                  VButton(
                                    title: 'Change Photo',
                                    variant: VButtonVariant.ghost,
                                    height: 32,
                                    onPressed: () => Navigator.pushNamed(context, AppRoutes.avatar),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: VirtuoMvpColors.inputFill,
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.workspace_premium_outlined, color: VirtuoMvpColors.cyan, size: 20),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      c.isPremium ? 'Premium Plan' : 'Free Plan',
                                      style: const TextStyle(color: VirtuoMvpColors.text, fontWeight: FontWeight.w900, fontSize: 12),
                                    ),
                                    Text(remaining, style: const TextStyle(color: VirtuoMvpColors.textMuted, fontSize: 10)),
                                  ],
                                ),
                              ),
                              SizedBox(
                                width: 100,
                                child: GradientPrimaryButton(
                                  title: 'Upgrade',
                                  height: 36,
                                  expanded: true,
                                  onPressed: () => Navigator.pushNamed(context, AppRoutes.premium),
                                ),
                              ),
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
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Personal Information', style: TextStyle(color: VirtuoMvpColors.text, fontWeight: FontWeight.w900, fontSize: 14)),
                        const SizedBox(height: 14),
                        _fieldLabel('Full Name'),
                        VTextField(controller: _name, textCapitalization: TextCapitalization.words),
                        const SizedBox(height: 12),
                        _fieldLabel('Email Address'),
                        VTextField(controller: _email, keyboardType: TextInputType.emailAddress),
                        const SizedBox(height: 12),
                        _fieldLabel('Phone Number'),
                        VTextField(controller: _phone, keyboardType: TextInputType.phone),
                        if (_message.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Text(_message, style: TextStyle(color: _message.contains('saved') ? VirtuoMvpColors.green : VirtuoMvpColors.red, fontSize: 11)),
                        ],
                        const SizedBox(height: 16),
                        GradientPrimaryButton(
                          title: 'Save Changes',
                          onPressed: () {
                            c.saveProfile(displayName: _name.text, phone: _phone.text);
                            setState(() => _message = 'Profile saved successfully.');
                          },
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

  Widget _fieldLabel(String t) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(t, style: const TextStyle(color: VirtuoMvpColors.cyan, fontSize: 12, fontWeight: FontWeight.w700)),
    );
  }
}
