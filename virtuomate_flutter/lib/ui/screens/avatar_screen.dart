import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:virtuomate_flutter/config/app_config.dart';
import 'package:virtuomate_flutter/core/avatar_customization.dart';
import 'package:virtuomate_flutter/core/avatar_emotion.dart';
import 'package:virtuomate_flutter/core/voice_profile_codec.dart';
import 'package:virtuomate_flutter/network/api_error_message.dart';
import 'package:virtuomate_flutter/theme/virtuomate_mvp_theme.dart';
import 'package:virtuomate_flutter/ui/mvp/mvp_shell.dart';
import 'package:virtuomate_flutter/ui/mvp/mvp_widgets.dart';
import 'package:virtuomate_flutter/ui/shared/avatar_presence.dart';
import 'package:virtuomate_flutter/services/tts_voice_picker.dart';
import 'package:virtuomate_flutter/ui/shared/achievement_feedback.dart';
import 'package:virtuomate_flutter/ui/shared/coach_tone_selector.dart';
import 'package:virtuomate_flutter/ui/virtuomate_bindings.dart';

class AvatarScreen extends StatefulWidget {
  const AvatarScreen({super.key});
  @override
  State<AvatarScreen> createState() => _AvatarScreenState();
}

class _AvatarScreenState extends State<AvatarScreen> {
  String _selected = 'Professional';
  String _voiceSelected = 'confident-neutral';
  String _voiceGender = kVoiceGenderFemale;
  final _previewTts = FlutterTts();
  String? _previewingToneId;
  String _lastPreviewVoiceName = '';
  final _picker = ImagePicker();
  String _imagePathOrUrl = '';
  String _sourcePhotoPath = '';
  bool _useTemplate = true;
  AvatarEmotionState _previewEmotion = AvatarEmotionState.neutral;
  bool _uploading = false;
  bool _generatingVroid = false;
  bool _stylizingOnDevice = false;
  String _uploadNote = '';
  int _avatarPreviewKey = 0;

  @override
  void dispose() {
    _previewTts.stop();
    super.dispose();
  }

  Future<void> _previewTone(CoachToneOption tone, String gender) async {
    setState(() {
      _previewingToneId = tone.id;
      _voiceGender = gender;
      _lastPreviewVoiceName = '';
    });
    await _previewTts.stop();
    final voiceName = await applySystemVoiceForGender(_previewTts, gender);
    await applyVoiceProfileToTts(
      _previewTts,
      encodeVoiceProfile(gender, tone.id),
    );
    await _previewTts.speak(tone.sampleLine);
    if (!mounted) return;
    setState(() {
      _previewingToneId = null;
      _lastPreviewVoiceName = voiceName ?? '';
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _selected = VirtuoMateScope.of(context).avatarStyle;
    final avatarImage = VirtuoMateScope.of(context).avatarImage;
    _imagePathOrUrl = avatarImage;
    if (avatarImage.isNotEmpty && !avatarImage.startsWith('http')) {
      _sourcePhotoPath = avatarImage;
    }
    _useTemplate = VirtuoMateScope.of(context).avatarUseTemplate;
    _previewEmotion = avatarEmotionFromName(
      VirtuoMateScope.of(context).avatarEmotionState,
    );
    final resolved = resolveVoiceProfile(
      VirtuoMateScope.of(context).voiceProfile,
      fallbackGender: VirtuoMateScope.of(context).voiceGender,
    );
    _voiceSelected = resolved.toneId;
    _voiceGender = resolved.gender;
  }

  @override
  Widget build(BuildContext context) {
    final c = VirtuoMateScope.of(context);
    return MvpShell(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          MvpTopBar(
            title: 'Avatar Builder',
            right: TextButton(
              onPressed: () => Navigator.maybePop(context),
              child: const Text(
                'Save',
                style: TextStyle(
                  color: VirtuoMvpColors.cyan,
                  fontWeight: FontWeight.w800,
                  fontSize: 12,
                ),
              ),
            ),
          ),
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
                  VCard(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 56,
                              height: 56,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(28),
                                color: VirtuoMvpColors.surface,
                                border: Border.all(color: VirtuoMvpColors.stroke),
                              ),
                              child: const Icon(Icons.psychology_outlined, color: VirtuoMvpColors.text, size: 28),
                            ),
                            const SizedBox(width: 14),
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'AI Neural Coach',
                                    style: TextStyle(
                                      color: VirtuoMvpColors.text,
                                      fontWeight: FontWeight.w900,
                                      fontSize: 16,
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    'Visual & voice linked to sessions',
                                    style: TextStyle(
                                      color: VirtuoMvpColors.textMuted,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        VButton(
                          title: 'Start Conversation with AI Coach',
                          icon: Icons.chat_bubble_outline,
                          expanded: true,
                          onPressed: () => Navigator.pushNamed(context, AppRoutes.session),
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
                          'Persona & attire',
                          style: TextStyle(
                            color: VirtuoMvpColors.text,
                            fontWeight: FontWeight.w900,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Select your coaching presence style.',
                          style: TextStyle(color: VirtuoMvpColors.textMuted, fontSize: 12),
                        ),
                        const SizedBox(height: 12),
                        ...kAvatarPersonas.map((persona) {
                          final active = _selected == persona.id;
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: InkWell(
                              onTap: () => setState(() {
                                _selected = persona.id;
                                _voiceSelected = c.suggestedVoiceProfile(persona.id);
                              }),
                              borderRadius: BorderRadius.circular(VirtuoMvpRadii.lg),
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(VirtuoMvpRadii.lg),
                                  color: active
                                      ? const Color.fromRGBO(59, 231, 255, 0.08)
                                      : VirtuoMvpColors.inputFill,
                                  border: Border.all(
                                    color: active
                                        ? const Color.fromRGBO(59, 231, 255, 0.22)
                                        : VirtuoMvpColors.stroke,
                                  ),
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            persona.title,
                                            style: const TextStyle(
                                              color: VirtuoMvpColors.text,
                                              fontWeight: FontWeight.w900,
                                              fontSize: 13,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            persona.subtitle,
                                            style: const TextStyle(
                                              color: VirtuoMvpColors.textMuted,
                                              fontSize: 11,
                                              height: 1.35,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    if (active)
                                      const Icon(Icons.check, color: VirtuoMvpColors.cyan, size: 20),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }),
                        const SizedBox(height: 12),
                        _genderToneSection(
                          title: 'Male coach tones',
                          subtitle:
                              'Deeper voice · requires Google TTS male pack on device (Settings → Text-to-speech)',
                          gender: kVoiceGenderMale,
                          accent: VirtuoMvpColors.cyan,
                          icon: Icons.record_voice_over,
                        ),
                        if (_lastPreviewVoiceName.isNotEmpty) ...[
                          const SizedBox(height: 6),
                          Text(
                            'Last preview engine voice: $_lastPreviewVoiceName',
                            style: const TextStyle(
                              color: VirtuoMvpColors.green,
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                        const SizedBox(height: 16),
                        _genderToneSection(
                          title: 'Female coach tones',
                          subtitle: 'Warmer voice · encouragement, calm practice, empathy',
                          gender: kVoiceGenderFemale,
                          accent: VirtuoMvpColors.magenta,
                          icon: Icons.mic,
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Coach avatar',
                          style: TextStyle(
                            color: VirtuoMvpColors.text,
                            fontWeight: FontWeight.w900,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Templates = built-in coach. Portrait = tap Create 2D cartoon avatar '
                          'for a real cartoon (Gemini). Offline sketch is a simple flat filter only. '
                          'Same portrait is used in coach sessions and Video CV.',
                          style: TextStyle(
                            color: VirtuoMvpColors.textMuted,
                            fontSize: 11,
                            height: 1.35,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Center(
                          child: AvatarPresence(
                            key: ValueKey('avatar-preview-$_avatarPreviewKey'),
                            selfieUrlOrPath: _imagePathOrUrl,
                            useTemplate: _useTemplate,
                            size: 140,
                            emotion: _previewEmotion.name,
                            isSpeaking: _previewEmotion == AvatarEmotionState.speaking,
                            mouthOpen: _previewEmotion == AvatarEmotionState.speaking
                                ? 0.75
                                : 0,
                            isListening:
                                _previewEmotion == AvatarEmotionState.listening,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          alignment: WrapAlignment.center,
                          spacing: 8,
                          runSpacing: 6,
                          children: [
                            _chip(
                              _useTemplate ? 'Template mode' : 'Portrait mode',
                              VirtuoMvpColors.cyan,
                            ),
                            _chip(
                              avatarEmotionLabel(_previewEmotion),
                              VirtuoMvpColors.purple,
                            ),
                            _chip(_selected, VirtuoMvpColors.green),
                          ],
                        ),
                        if (_uploading || _generatingVroid || _stylizingOnDevice)
                          const Padding(
                            padding: EdgeInsets.only(top: 8),
                            child: LinearProgressIndicator(minHeight: 3),
                          ),
                        if (_uploadNote.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              _uploadNote,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: _uploadNote.contains('failed')
                                    ? VirtuoMvpColors.amber
                                    : VirtuoMvpColors.green,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: VButton(
                                title: 'Templates',
                                variant: _useTemplate
                                    ? VButtonVariant.primary
                                    : VButtonVariant.outline,
                                icon: Icons.smart_toy_outlined,
                                onPressed: () => setState(() => _useTemplate = true),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: VButton(
                                title: 'My portrait',
                                variant: !_useTemplate
                                    ? VButtonVariant.primary
                                    : VButtonVariant.outline,
                                icon: Icons.face_outlined,
                                onPressed: () => setState(() => _useTemplate = false),
                              ),
                            ),
                          ],
                        ),
                        if (!_useTemplate) ...[
                          const SizedBox(height: 10),
                          _vroidPortraitHint(),
                          const SizedBox(height: 10),
                          if (AppConfig.useBackendApi)
                            VButton(
                              title: _generatingVroid
                                  ? 'Creating 2D cartoon avatar…'
                                  : 'Create 2D cartoon avatar (recommended)',
                              icon: Icons.auto_awesome,
                              variant: VButtonVariant.primary,
                              expanded: true,
                              onPressed: (_generatingVroid || _uploading || _stylizingOnDevice)
                                  ? null
                                  : (!_hasPortraitSource()
                                      ? null
                                      : () => _generateStyledAvatar('cartoon')),
                            )
                          else
                            VButton(
                              title: _stylizingOnDevice
                                  ? 'Creating 2D avatar…'
                                  : 'Create 2D avatar (offline)',
                              icon: Icons.brush_outlined,
                              variant: VButtonVariant.primary,
                              expanded: true,
                              onPressed: (_generatingVroid || _uploading || _stylizingOnDevice)
                                  ? null
                                  : (!_hasPortraitSource()
                                      ? null
                                      : _createOnDeviceAvatar),
                            ),
                          if (AppConfig.useBackendApi) ...[
                            const SizedBox(height: 8),
                            VButton(
                              title: _stylizingOnDevice
                                  ? 'Offline filter…'
                                  : 'Offline flat sketch (no AI credits)',
                              icon: Icons.phone_android,
                              variant: VButtonVariant.outline,
                              expanded: true,
                              onPressed: (_generatingVroid || _uploading || _stylizingOnDevice)
                                  ? null
                                  : (!_hasPortraitSource()
                                      ? null
                                      : _createOnDeviceAvatar),
                            ),
                          ],
                        ],
                        const SizedBox(height: 12),
                        const Text(
                          'Preview expressions',
                          style: TextStyle(
                            color: VirtuoMvpColors.textFaint,
                            fontWeight: FontWeight.w800,
                            fontSize: 11,
                          ),
                        ),
                        const SizedBox(height: 8),
                        LayoutBuilder(
                          builder: (context, constraints) {
                            final cols = constraints.maxWidth >= 520 ? 4 : 3;
                            return GridView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: cols,
                                mainAxisSpacing: 8,
                                crossAxisSpacing: 8,
                                childAspectRatio: 1,
                              ),
                              itemCount: AvatarEmotionAssets.previewStates.length,
                              itemBuilder: (context, index) {
                                final state = AvatarEmotionAssets.previewStates[index];
                                final active = _previewEmotion == state;
                                return InkWell(
                                  onTap: () => setState(() => _previewEmotion = state),
                                  borderRadius: BorderRadius.circular(12),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: active
                                            ? VirtuoMvpColors.cyan
                                            : VirtuoMvpColors.stroke,
                                        width: active ? 2 : 1,
                                      ),
                                    ),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Expanded(
                                          child: Padding(
                                            padding: const EdgeInsets.all(6),
                                            child: Image.asset(
                                              AvatarEmotionAssets.assetFor(state),
                                              fit: BoxFit.contain,
                                            ),
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.only(bottom: 6),
                                          child: Text(
                                            avatarEmotionLabel(state),
                                            style: TextStyle(
                                              color: active
                                                  ? VirtuoMvpColors.cyan
                                                  : VirtuoMvpColors.textMuted,
                                              fontSize: 9,
                                              fontWeight: FontWeight.w800,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: VButton(
                                title: 'Gallery',
                                variant: VButtonVariant.outline,
                                icon: Icons.photo_library_outlined,
                                onPressed: _uploading
                                    ? null
                                    : () => _pickAvatar(ImageSource.gallery),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: VButton(
                                title: 'Camera',
                                variant: VButtonVariant.outline,
                                icon: Icons.photo_camera_outlined,
                                onPressed: _uploading
                                    ? null
                                    : () => _pickAvatar(ImageSource.camera),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        VButton(
                          title: 'Save Avatar Configuration',
                          icon: Icons.flash_on,
                          expanded: true,
                          onPressed: () {
                            c.saveAvatarStyle(_selected);
                            c.saveAvatarUseTemplate(_useTemplate);
                            c.saveAvatarEmotionState(_previewEmotion.name);
                            c.saveVoiceProfile(
                              encodeVoiceProfile(_voiceGender, _voiceSelected),
                            );
                            c.saveVoiceGender(_voiceGender);
                            if (_imagePathOrUrl.isNotEmpty) {
                              c.saveAvatarImage(_imagePathOrUrl);
                            }
                            showAchievementUnlocks(context, c.drainAchievementUnlocks());
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Avatar saved')),
                            );
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

  Widget _genderToneSection({
    required String title,
    required String subtitle,
    required String gender,
    required Color accent,
    required IconData icon,
  }) {
    final activeGender = _voiceGender == gender;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: accent, size: 18),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: accent,
                      fontWeight: FontWeight.w900,
                      fontSize: 13,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: VirtuoMvpColors.textMuted,
                      fontSize: 11,
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        CoachToneSelector(
          tones: coachTonesForGender(gender),
          selectedId: activeGender ? _voiceSelected : '',
          previewingId: _previewingToneId,
          onSelected: (id) => setState(() {
            _voiceGender = gender;
            _voiceSelected = id;
          }),
          onPreview: (tone) => _previewTone(tone, gender),
        ),
      ],
    );
  }

  Widget _vroidPortraitHint() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(VirtuoMvpRadii.lg),
        color: VirtuoMvpColors.inputFill,
        border: Border.all(color: VirtuoMvpColors.stroke),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'From your photo (recommended)',
            style: TextStyle(
              color: VirtuoMvpColors.text,
              fontWeight: FontWeight.w800,
              fontSize: 11,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'For a true 2D cartoon coach portrait, tap Create 2D cartoon avatar '
            '(Gemini — needs sign-in + API). Offline sketch is a simple flat filter only.\n\n'
            'Or upload a ready-made cartoon PNG from Gallery.',
            style: TextStyle(
              color: VirtuoMvpColors.textMuted,
              fontSize: 10,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 8),
          TextButton.icon(
            onPressed: _openVroidStudioPage,
            icon: const Icon(Icons.open_in_new, size: 14),
            label: const Text('Get VRoid Studio'),
            style: TextButton.styleFrom(
              foregroundColor: VirtuoMvpColors.cyan,
              padding: EdgeInsets.zero,
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _openVroidStudioPage() async {
    final uri = Uri.parse('https://vroid.com/en/studio');
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open VRoid Studio website')),
      );
    }
  }

  Widget _chip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: color.withValues(alpha: 0.15),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Text(
        label,
        style: TextStyle(color: color, fontWeight: FontWeight.w800, fontSize: 10),
      ),
    );
  }

  Future<void> _pickAvatar(ImageSource source) async {
    final picked = await _picker.pickImage(source: source, imageQuality: 75);
    if (picked == null || !mounted) return;

    final localPath = picked.path;
    final c = VirtuoMateScope.of(context);

    // Show your photo immediately (local file) — do not wait for cloud upload.
    setState(() {
      _imagePathOrUrl = localPath;
      _sourcePhotoPath = localPath;
      _useTemplate = false;
      _uploading = true;
      _uploadNote = 'Uploading original photo…';
    });
    c.saveAvatarImage(localPath);

    try {
      final url = await c.uploadAvatarImage(File(localPath));
      if (!mounted) return;
      setState(() {
        _imagePathOrUrl = url;
        _uploading = false;
        _uploadNote = 'Photo saved. Tap Create 2D cartoon avatar (recommended) for a real cartoon look.';
      });
    } catch (e) {
      if (!mounted) return;
      final msg = friendlyApiError(e);
      setState(() {
        _uploading = false;
        _uploadNote = 'Saved on this device only. Cloud upload failed: $msg';
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Photo saved locally. Tap "Save Avatar Configuration" — '
            'redeploy backend for cloud sync. ($msg)',
          ),
        ),
      );
    }
  }

  bool _hasPortraitSource() {
    final path = _imagePathOrUrl.trim();
    if (path.isEmpty) return false;
    if (path.startsWith('http')) return true;
    final source = _sourcePhotoPath.trim();
    if (source.isNotEmpty && File(source).existsSync()) return true;
    return File(path).existsSync();
  }

  void _onCreateVroidDisabledTap(BuildContext context) {
    if (_uploading) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Wait for photo upload to finish.')),
      );
      return;
    }
    if (!AppConfig.useBackendApi) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'VRoid-style generation needs cloud API. Run with USE_BACKEND_API=true and sign in.',
          ),
        ),
      );
      return;
    }
    if (!_hasPortraitSource()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pick a selfie from Gallery or Camera first.'),
        ),
      );
    }
  }

  Future<File?> _resolveSourcePhotoFile() async {
    final source = _sourcePhotoPath.trim();
    if (source.isNotEmpty) {
      final file = File(source);
      if (file.existsSync()) return file;
    }

    final path = _imagePathOrUrl.trim();
    if (path.isEmpty) return null;

    if (!path.startsWith('http')) {
      final file = File(path);
      return file.existsSync() ? file : null;
    }

    try {
      final response = await http.get(Uri.parse(path));
      if (response.statusCode != 200) return null;
      final dir = await getTemporaryDirectory();
      final out = File(
        '${dir.path}/vroid-source-${DateTime.now().millisecondsSinceEpoch}.jpg',
      );
      await out.writeAsBytes(response.bodyBytes);
      return out;
    } catch (_) {
      return null;
    }
  }

  Future<void> _createOnDeviceAvatar() async {
    final c = VirtuoMateScope.of(context);
    final sourceFile = await _resolveSourcePhotoFile();
    if (!mounted) return;
    if (sourceFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pick a photo from Gallery or Camera first.'),
        ),
      );
      return;
    }

    setState(() {
      _stylizingOnDevice = true;
      _useTemplate = false;
      _uploadNote = 'Detecting face and stylizing on device…';
    });

    try {
      c.saveAvatarStyle(_selected);
      final result = await c.createOnDeviceAvatarFromPhoto(sourceFile);
      if (!mounted) return;
      final display = result.displayPathOrUrl.isNotEmpty
          ? result.displayPathOrUrl
          : result.file.path;
      setState(() {
        _imagePathOrUrl = display;
        _avatarPreviewKey++;
        _sourcePhotoPath = result.file.path;
        _stylizingOnDevice = false;
        final engineLabel = result.engine == 'tflite' ? 'AI model' : 'cartoon filter';
        final faceNote = result.faceDetected ? '' : ' (face not detected — full image styled)';
        _uploadNote =
            'Offline flat 2D sketch ($engineLabel)$faceNote. '
            'For a real cartoon portrait, use Create 2D cartoon avatar (recommended).';
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            result.engine == 'tflite'
                ? 'Cartoon avatar created (TFLite)'
                : 'Cartoon avatar created — stronger filter applied',
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      final msg = e.toString().replaceFirst('Exception: ', '');
      setState(() {
        _stylizingOnDevice = false;
        _uploadNote = 'On-device stylize failed: $msg';
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('On-device avatar failed: $msg')),
      );
    }
  }

  Future<void> _generateStyledAvatar(String style) async {
    final c = VirtuoMateScope.of(context);
    final sourceFile = await _resolveSourcePhotoFile();
    if (!mounted) return;
    if (sourceFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Pick a photo from Gallery or Camera first, then cartoonize or create anime style.',
          ),
        ),
      );
      return;
    }

    final label = style == 'vroid' ? 'anime' : 'cartoon';
    setState(() {
      _generatingVroid = true;
      _useTemplate = false;
      _uploadNote = 'Creating $label avatar (20–60s)…';
    });

    try {
      c.saveAvatarStyle(_selected);
      final url = await c.createVroidAvatarFromPhoto(
        sourceFile,
        avatarStyleOverride: _selected,
        style: style,
      );
      if (!mounted) return;
      setState(() {
        _imagePathOrUrl = url;
        _avatarPreviewKey++;
        _generatingVroid = false;
        _uploadNote =
            '2D cartoon avatar ready — used in coach sessions and Video CV.';
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$label avatar created')),
      );
    } catch (e) {
      if (!mounted) return;
      final msg = friendlyApiError(e);
      setState(() {
        _generatingVroid = false;
        _uploadNote = 'Generation failed: $msg';
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$label avatar failed: $msg')),
      );
    }
  }
}

