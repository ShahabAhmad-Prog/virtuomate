import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:virtuomate_flutter/core/models.dart';
import 'package:virtuomate_flutter/theme/virtuomate_mvp_theme.dart';
import 'package:virtuomate_flutter/ui/shared/achievement_feedback.dart';
import 'package:virtuomate_flutter/ui/virtuomate_bindings.dart';
import 'package:virtuomate_flutter/ui/mvp/mvp_shell.dart';
import 'package:virtuomate_flutter/ui/mvp/mvp_widgets.dart';
import 'package:virtuomate_flutter/ui/shared/avatar_presence.dart';
import 'package:virtuomate_flutter/ui/shared/responsive.dart';
import 'package:virtuomate_flutter/ui/shared/ui_helpers.dart';

class VideoCvWizardScreen extends StatefulWidget {
  const VideoCvWizardScreen({super.key});

  @override
  State<VideoCvWizardScreen> createState() => _VideoCvWizardScreenState();
}

class _VideoCvWizardScreenState extends State<VideoCvWizardScreen> {
  int _step = 0;
  final _fullName = TextEditingController();
  final _headline = TextEditingController();
  final _summary = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  final _skills = TextEditingController();
  final _experience = TextEditingController();
  final _education = TextEditingController();
  final FlutterTts _tts = FlutterTts();
  String _error = '';

  bool _loaded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_loaded) return;
    _loaded = true;
    final draft = VirtuoMateScope.of(context).videoCvDraft;
    _fullName.text = draft.fullName;
    _headline.text = draft.headline;
    _summary.text = draft.summary;
    _email.text = draft.email;
    _phone.text = draft.phone;
    _skills.text = draft.skills;
    _experience.text = draft.experience;
    _education.text = draft.education;
  }

  @override
  void dispose() {
    _tts.stop();
    _fullName.dispose();
    _headline.dispose();
    _summary.dispose();
    _email.dispose();
    _phone.dispose();
    _skills.dispose();
    _experience.dispose();
    _education.dispose();
    super.dispose();
  }

  VideoCvDraft _currentDraft() => VideoCvDraft(
        fullName: _fullName.text,
        headline: _headline.text,
        summary: _summary.text,
        email: _email.text,
        phone: _phone.text,
        skills: _skills.text,
        experience: _experience.text,
        education: _education.text,
      );

  void _saveDraft() {
    VirtuoMateScope.of(context).saveVideoCvDraft(_currentDraft());
  }

  Future<void> _next() async {
    _saveDraft();
    if (_step < 3) {
      setState(() => _step++);
      return;
    }
    final c = VirtuoMateScope.of(context);
    try {
      final script = await c.buildVideoCvNarrationAsync(
        fullName: _fullName.text,
        headline: _headline.text,
        summary: _summary.text,
        skills: _skills.text,
        experience: _experience.text,
        education: _education.text,
      );
      c.saveVideoCvDraft(_currentDraft().copyWith(narrationScript: script));
      c.generateVideoCv();
      if (!mounted) return;
      showAchievementUnlocks(context, c.drainAchievementUnlocks());
      Navigator.pushNamed(context, AppRoutes.videoCvPreview);
    } catch (e) {
      setState(() => _error = e.toString().replaceFirst('Exception: ', ''));
    }
  }

  Widget _label(String t, {bool required = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: RichText(
        text: TextSpan(
          style: const TextStyle(color: VirtuoMvpColors.cyan, fontSize: 12, fontWeight: FontWeight.w700),
          children: [
            TextSpan(text: t),
            if (required) const TextSpan(text: ' *', style: TextStyle(color: VirtuoMvpColors.red)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = VirtuoMateScope.of(context);
    return MvpShell(
      body: Column(
        children: [
          MvpTopBar(
            title: 'AI Video CV Creator',
            right: Text('Step ${_step + 1}/4', style: const TextStyle(color: VirtuoMvpColors.textMuted, fontWeight: FontWeight.w900, fontSize: 12)),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: VirtuoMvpSpacing.lg),
            child: StepProgressBar(currentStep: _step, totalSteps: 4),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(VirtuoMvpSpacing.lg),
              child: VCard(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_step == 0) ...[
                      _avatarPreview(),
                      const SizedBox(height: 14),
                      _label('Full Name', required: true),
                      VTextField(controller: _fullName, hintText: 'John Doe', textCapitalization: TextCapitalization.words),
                      const SizedBox(height: 12),
                      _label('Professional Title', required: true),
                      VTextField(controller: _headline, hintText: 'Senior Software Engineer'),
                      const SizedBox(height: 12),
                      _label('Professional Summary', required: true),
                      VTextField(controller: _summary, maxLines: 4, hintText: 'A brief summary of your professional background...'),
                      const SizedBox(height: 12),
                      LayoutBuilder(
                        builder: (context, constraints) {
                          final emailField = Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _label('Email'),
                              VTextField(controller: _email, hintText: 'john@example.com', keyboardType: TextInputType.emailAddress),
                            ],
                          );
                          final phoneField = Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _label('Phone'),
                              VTextField(controller: _phone, hintText: '+1 234 567 8900', keyboardType: TextInputType.phone),
                            ],
                          );
                          if (constraints.maxWidth < VirtuoBreakpoints.compact) {
                            return Column(
                              children: [
                                emailField,
                                const SizedBox(height: 12),
                                phoneField,
                              ],
                            );
                          }
                          return Row(
                            children: [
                              Expanded(child: emailField),
                              const SizedBox(width: 10),
                              Expanded(child: phoneField),
                            ],
                          );
                        },
                      ),
                    ] else if (_step == 1) ...[
                      _label('Work Experience', required: true),
                      VTextField(controller: _experience, maxLines: 6, hintText: 'Describe your roles, achievements, and impact...'),
                    ] else if (_step == 2) ...[
                      _label('Education', required: true),
                      VTextField(controller: _education, maxLines: 5, hintText: 'Degrees, certifications, institutions...'),
                    ] else ...[
                      _label('Key Skills & Achievements'),
                      VTextField(controller: _skills, maxLines: 5, hintText: 'Leadership, technical skills, awards...'),
                      const SizedBox(height: 14),
                      VCard(
                        padding: const EdgeInsets.all(12),
                        child: FutureBuilder<String>(
                          future: c.buildVideoCvNarrationAsync(
                            fullName: _fullName.text,
                            headline: _headline.text,
                            summary: _summary.text,
                            skills: _skills.text,
                            experience: _experience.text,
                            education: _education.text,
                          ),
                          builder: (context, snap) => Text(
                            snap.data ?? 'Generating preview…',
                            style: const TextStyle(color: VirtuoMvpColors.textMuted, fontSize: 11, height: 1.4),
                          ),
                        ),
                      ),
                    ],
                    if (_error.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(_error, style: const TextStyle(color: VirtuoMvpColors.red, fontSize: 11)),
                    ],
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        if (_step > 0)
                          Expanded(
                            child: VButton(
                              title: 'Back',
                              variant: VButtonVariant.outline,
                              onPressed: () => setState(() => _step--),
                            ),
                          ),
                        if (_step > 0) const SizedBox(width: 10),
                        Expanded(
                          flex: 2,
                          child: GradientPrimaryButton(
                            title: _step < 3 ? 'Continue' : 'Generate Video CV',
                            icon: Icons.movie_creation_outlined,
                            onPressed: _next,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _avatarPreview() {
    final c = VirtuoMateScope.of(context);
    final hasPortrait = c.avatarImage.isNotEmpty && !c.avatarUseTemplate;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: VirtuoMvpColors.inputFill,
        border: Border.all(color: VirtuoMvpColors.stroke),
      ),
      child: Row(
        children: [
          if (hasPortrait)
            AvatarPresence(
              selfieUrlOrPath: c.avatarImage,
              useTemplate: false,
              size: 52,
              emotion: c.avatarEmotionState,
            )
          else
            Stack(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: VirtuoMvpColors.surface,
                    border: Border.all(color: VirtuoMvpColors.stroke),
                  ),
                  child: const Icon(Icons.person_outline, color: VirtuoMvpColors.text),
                ),
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    width: 10,
                    height: 10,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: VirtuoMvpColors.green,
                    ),
                  ),
                ),
              ],
            ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Your AI Avatar',
                  style: TextStyle(
                    color: VirtuoMvpColors.text,
                    fontWeight: FontWeight.w900,
                    fontSize: 13,
                  ),
                ),
                Text(
                  hasPortrait
                      ? 'VRoid-style portrait · lip-sync in video'
                      : 'Create avatar in Customize Avatar first',
                  style: TextStyle(
                    color: hasPortrait ? VirtuoMvpColors.cyan : VirtuoMvpColors.textMuted,
                    fontWeight: FontWeight.w800,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
