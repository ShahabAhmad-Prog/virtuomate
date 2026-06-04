import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:virtuomate_flutter/theme/virtuomate_mvp_theme.dart';
import 'package:virtuomate_flutter/ui/mvp/mvp_shell.dart';
import 'package:virtuomate_flutter/ui/mvp/mvp_widgets.dart';
import 'package:virtuomate_flutter/ui/shared/voice_sync_diagnostic_card.dart';
import 'package:virtuomate_flutter/core/avatar_customization.dart';
import 'package:virtuomate_flutter/ui/shared/achievement_feedback.dart';
import 'package:virtuomate_flutter/ui/virtuomate_bindings.dart';

class RolePlayScreen extends StatefulWidget {
  const RolePlayScreen({super.key});
  @override
  State<RolePlayScreen> createState() => _RolePlayScreenState();
}

class _RolePlayScreenState extends State<RolePlayScreen> {
  static const _scenarioTitles = [
    'Salary Negotiation',
    'Leadership Conversation',
    'Conflict Resolution',
    'Client Pitch',
  ];
  static const List<IconData> _scenarioIcons = [
    Icons.payments_outlined,
    Icons.groups_outlined,
    Icons.shield_outlined,
    Icons.business_center_outlined,
  ];
  int _scenarioIndex = 0;
  bool _sessionStarted = false;
  final _input = TextEditingController();
  final _responseSectionKey = GlobalKey();
  final stt.SpeechToText _speech = stt.SpeechToText();
  final FlutterTts _tts = FlutterTts();
  String _error = '';
  bool _speechReady = false;
  bool _isListening = false;
  bool _liveVoiceMode = false;
  bool _isProcessingLive = false;

  @override
  void initState() {
    super.initState();
    _initVoiceTools();
  }

  Future<void> _initVoiceTools() async {
    final ready = await _speech.initialize();
    if (!mounted) return;
    setState(() => _speechReady = ready);
  }

  Future<void> _speakWithProfile(VirtuoMateController c, String text) async {
    await applyVoiceProfileToTts(_tts, c.voiceProfile, voiceGender: c.voiceGender);
    await _tts.speak(text);
  }

  Future<void> _processLiveTurn(VirtuoMateController c, String words) async {
    if (_isProcessingLive || words.trim().isEmpty) return;
    _isProcessingLive = true;
    _input.text = words;
    final ok = await c.completeRolePlay(_scenarioTitles[_scenarioIndex], words);
    if (!mounted) return;
    setState(() => _error = ok ? '' : c.errorMessage);
    if (ok) {
      showAchievementUnlocks(context, c.drainAchievementUnlocks());
      await _speakWithProfile(c, c.latestFeedback);
    }
    _isProcessingLive = false;
    if (_liveVoiceMode && mounted) {
      await _speech.stop();
      await _toggleListening();
    }
  }

  Future<void> _startRolePlay(VirtuoMateController c) async {
    if (!c.canRunRolePlay) {
      setState(() => _error = 'Free tier limit reached for role-play. Upgrade to Premium.');
      return;
    }
    final scenario = _scenarioTitles[_scenarioIndex];
    setState(() {
      _sessionStarted = true;
      _error = '';
      _input.clear();
    });
    final opener =
        'Scenario: $scenario. You are the candidate. Open with a confident introduction and your first move in this situation.';
    await _speakWithProfile(c, opener);
    if (_speechReady && !_isListening) {
      await _toggleListening();
    }
    if (!mounted) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final ctx = _responseSectionKey.currentContext;
      if (ctx == null) return;
      Scrollable.ensureVisible(
        ctx,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOut,
      );
    });
  }

  Future<void> _toggleListening() async {
    if (!_speechReady) {
      setState(() => _error = 'Speech recognition not available on this device.');
      return;
    }
    if (_isListening) {
      await _speech.stop();
      if (!mounted) return;
      setState(() => _isListening = false);
      return;
    }
    await _speech.listen(
      onResult: (result) {
        if (!mounted) return;
        setState(() {
          _input.text = result.recognizedWords;
          _input.selection = TextSelection.fromPosition(
            TextPosition(offset: _input.text.length),
          );
        });
        if (_liveVoiceMode && result.finalResult) {
          final c = VirtuoMateScope.of(context);
          _processLiveTurn(c, result.recognizedWords);
        }
      },
    );
    if (!mounted) return;
    setState(() => _isListening = true);
  }

  @override
  void dispose() {
    _speech.stop();
    _tts.stop();
    _input.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = VirtuoMateScope.of(context);
    return MvpShell(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          MvpTopBar(
            title: 'Role Play Simulation',
            right: const Text(
              '1/3',
              style: TextStyle(
                color: VirtuoMvpColors.cyan,
                fontWeight: FontWeight.w900,
                fontSize: 12,
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
                  const Text(
                    'Practice real-world scenarios with an AI coach and get adaptive feedback.',
                    style: TextStyle(color: VirtuoMvpColors.textMuted, fontSize: 12),
                  ),
                  const SizedBox(height: 14),
                  VoiceSyncDiagnosticCard(controller: c),
                  const SizedBox(height: 12),
                  Text(
                    'Coach voice: ${coachVoiceSummary(gender: c.resolvedVoice.gender, toneId: c.voiceToneId)}',
                    style: const TextStyle(color: VirtuoMvpColors.textMuted, fontSize: 12),
                  ),
                  const SizedBox(height: 14),
                  VCard(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Choose a scenario',
                          style: TextStyle(
                            color: VirtuoMvpColors.text,
                            fontWeight: FontWeight.w900,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 10),
                        for (var i = 0; i < _scenarioTitles.length; i++)
                          Padding(
                            padding: const EdgeInsets.only(top: 10),
                            child: InkWell(
                              onTap: () => setState(() => _scenarioIndex = i),
                              borderRadius: BorderRadius.circular(VirtuoMvpRadii.lg),
                              child: Container(
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(VirtuoMvpRadii.lg),
                                  color: VirtuoMvpColors.inputFill,
                                  border: Border.all(
                                    color: i == _scenarioIndex
                                        ? const Color.fromRGBO(59, 231, 255, 0.22)
                                        : VirtuoMvpColors.stroke,
                                  ),
                                ),
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
                                      child: Icon(_scenarioIcons[i], size: 18, color: VirtuoMvpColors.text),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            _scenarioTitles[i],
                                            style: const TextStyle(
                                              color: VirtuoMvpColors.text,
                                              fontWeight: FontWeight.w900,
                                              fontSize: 12,
                                            ),
                                          ),
                                          const Text(
                                            'Role-play',
                                            style: TextStyle(
                                              color: VirtuoMvpColors.textMuted,
                                              fontWeight: FontWeight.w700,
                                              fontSize: 11,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    if (i == _scenarioIndex)
                                      const Icon(Icons.check, color: VirtuoMvpColors.cyan, size: 18),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        const SizedBox(height: 12),
                        VButton(
                          title: _sessionStarted ? 'Session in progress' : 'Start Role-play',
                          icon: Icons.play_arrow,
                          expanded: true,
                          onPressed: _sessionStarted
                              ? null
                              : () => _startRolePlay(c),
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
                          'What you’ll get',
                          style: TextStyle(
                            color: VirtuoMvpColors.text,
                            fontWeight: FontWeight.w900,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 10),
                        _rpBullet('Live coaching prompts based on your replies'),
                        _rpBullet('Emotion-aware tone adjustments from your coach'),
                        _rpBullet('Performance insights & recommendations'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  KeyedSubtree(
                    key: _responseSectionKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _sessionStarted ? 'Live role-play — respond below' : 'Your response',
                          style: const TextStyle(
                            color: VirtuoMvpColors.textMuted,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 8),
                        VTextField(controller: _input, maxLines: 4, hintText: 'Speak or type your reply…'),
                      ],
                    ),
                  ),
                  if (_error.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(_error, style: const TextStyle(color: VirtuoMvpColors.red, fontSize: 12)),
                  ],
                  const SizedBox(height: 14),
                  VButton(
                    title: 'Complete Simulation',
                    icon: Icons.flash_on,
                    expanded: true,
                    onPressed: () async {
                      final ok = await c.completeRolePlay(_scenarioTitles[_scenarioIndex], _input.text);
                      if (!mounted) return;
                      setState(() => _error = ok ? '' : c.errorMessage);
                      if (ok) {
                        showAchievementUnlocks(context, c.drainAchievementUnlocks());
                        await _speakWithProfile(c, c.latestFeedback);
                      }
                    },
                  ),
                  const SizedBox(height: 10),
                  VButton(
                    title: _isListening ? 'Stop Listening' : 'Speak Response',
                    variant: VButtonVariant.outline,
                    icon: _isListening ? Icons.mic_off_outlined : Icons.mic_none_outlined,
                    expanded: true,
                    onPressed: _toggleListening,
                  ),
                  const SizedBox(height: 10),
                  VButton(
                    title: _liveVoiceMode ? 'Stop Live Voice Call' : 'Start Live Voice Call',
                    variant: VButtonVariant.outline,
                    icon: _liveVoiceMode ? Icons.call_end_outlined : Icons.call_outlined,
                    expanded: true,
                    onPressed: () async {
                      setState(() => _liveVoiceMode = !_liveVoiceMode);
                      if (_liveVoiceMode) {
                        await _toggleListening();
                      } else if (_isListening) {
                        await _speech.stop();
                        if (mounted) setState(() => _isListening = false);
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
  }

  Widget _rpBullet(String t) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• ', style: TextStyle(color: VirtuoMvpColors.cyan, fontWeight: FontWeight.w900)),
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
}

