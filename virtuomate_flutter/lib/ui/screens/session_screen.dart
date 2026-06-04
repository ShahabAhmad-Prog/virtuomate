import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:virtuomate_flutter/services/tts_speaker.dart';
import 'package:virtuomate_flutter/theme/virtuomate_mvp_theme.dart';
import 'package:virtuomate_flutter/ui/mvp/mvp_shell.dart';
import 'package:virtuomate_flutter/ui/mvp/mvp_widgets.dart';
import 'package:virtuomate_flutter/ui/shared/avatar_presence.dart';
import 'package:virtuomate_flutter/ui/shared/voice_sync_diagnostic_card.dart';
import 'package:virtuomate_flutter/core/avatar_customization.dart';
import 'package:virtuomate_flutter/ui/shared/achievement_feedback.dart';
import 'package:virtuomate_flutter/ui/virtuomate_bindings.dart';

class SessionScreen extends StatefulWidget {
  const SessionScreen({super.key});
  @override
  State<SessionScreen> createState() => _SessionScreenState();
}

class _SessionScreenState extends State<SessionScreen> {
  final _input = TextEditingController();
  final stt.SpeechToText _speech = stt.SpeechToText();
  late final TtsSpeaker _ttsSpeaker;
  String _error = '';
  bool _speechReady = false;
  bool _isListening = false;
  bool _liveVoiceMode = false;
  bool _isProcessingLive = false;

  @override
  void initState() {
    super.initState();
    _ttsSpeaker = TtsSpeaker(FlutterTts());
    _initVoiceTools();
  }

  Future<void> _initVoiceTools() async {
    final ready = await _speech.initialize();
    if (!mounted) return;
    setState(() => _speechReady = ready);
  }

  Future<void> _speakWithProfile(VirtuoMateController c, String text) async {
    await _ttsSpeaker.speak(text, c.voiceProfile, voiceGender: c.voiceGender);
  }

  Future<void> _processLiveTurn(VirtuoMateController c, String words) async {
    if (_isProcessingLive || words.trim().isEmpty) return;
    _isProcessingLive = true;
    _input.text = words;
    final ok = await c.completeConversation(words);
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
    _ttsSpeaker.stop();
    _ttsSpeaker.dispose();
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
            title: 'AI Neural Coach',
            right: InkWell(
              onTap: () {},
              child: Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: VirtuoMvpColors.surface,
                  border: Border.all(color: VirtuoMvpColors.stroke),
                ),
                child: const Icon(Icons.more_vert, size: 18, color: VirtuoMvpColors.text),
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
                  Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'Want a more natural conversation?',
                          style: TextStyle(
                            color: VirtuoMvpColors.textMuted,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      InkWell(
                        onTap: () => Navigator.pushNamed(context, AppRoutes.voiceSession),
                        borderRadius: BorderRadius.circular(999),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(999),
                            color: VirtuoMvpColors.green.withValues(alpha: 0.92),
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.call, size: 14, color: Color(0xFF07171B)),
                              SizedBox(width: 6),
                              Text(
                                'Voice Mode',
                                style: TextStyle(
                                  color: Color(0xFF07171B),
                                  fontWeight: FontWeight.w900,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Center(
                    child: Column(
                      children: [
                        ValueListenableBuilder<bool>(
                          valueListenable: _ttsSpeaker.isSpeaking,
                          builder: (context, speaking, _) {
                            return ValueListenableBuilder<double>(
                              valueListenable: _ttsSpeaker.mouthOpen,
                              builder: (context, mouth, _) {
                                return AvatarPresence(
                                  selfieUrlOrPath: c.avatarImage,
                                  useTemplate: c.avatarUseTemplate,
                                  size: 128,
                                  isSpeaking: speaking,
                                  mouthOpen: mouth,
                                  isListening: _isListening,
                                  emotion: c.latestSessionRecord?.emotion ??
                                      c.avatarEmotionState,
                                );
                              },
                            );
                          },
                        ),
                        const SizedBox(height: 10),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(999),
                            color: const Color.fromRGBO(139, 92, 255, 0.32),
                            border: Border.all(color: VirtuoMvpColors.stroke2),
                          ),
                          child: Text(
                            c.avatarStyle.isEmpty
                                ? 'Neutral'
                                : '${c.avatarStyle} · ${coachVoiceSummary(gender: c.resolvedVoice.gender, toneId: c.voiceToneId)}',
                            style: const TextStyle(
                              color: VirtuoMvpColors.text,
                              fontWeight: FontWeight.w900,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          '• Ready',
                          style: TextStyle(
                            color: VirtuoMvpColors.cyan,
                            fontWeight: FontWeight.w800,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  VoiceSyncDiagnosticCard(controller: c),
                  const SizedBox(height: 12),
                  const Text(
                    'Your prompt',
                    style: TextStyle(
                      color: VirtuoMvpColors.textMuted,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  VTextField(controller: _input, maxLines: 4, hintText: 'Ask your neural coach…'),
                  if (_error.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(_error, style: const TextStyle(color: VirtuoMvpColors.red, fontSize: 12)),
                  ],
                  const SizedBox(height: 14),
                  VButton(
                    title: 'Complete Session',
                    icon: Icons.flash_on,
                    expanded: true,
                    onPressed: () async {
                      final ok = await c.completeConversation(_input.text);
                      if (!mounted) return;
                      setState(() => _error = ok ? '' : c.errorMessage);
                      if (!ok) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(c.errorMessage)),
                        );
                        return;
                      }
                      showAchievementUnlocks(context, c.drainAchievementUnlocks());
                      await _speakWithProfile(c, c.latestFeedback);
                    },
                  ),
                  const SizedBox(height: 10),
                  VButton(
                    title: _isListening ? 'Stop Listening' : 'Speak Prompt',
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
}

