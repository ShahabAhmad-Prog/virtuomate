import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:virtuomate_flutter/services/tts_speaker.dart';
import 'package:virtuomate_flutter/theme/virtuomate_mvp_theme.dart';
import 'package:virtuomate_flutter/ui/shared/achievement_feedback.dart';
import 'package:virtuomate_flutter/ui/virtuomate_bindings.dart';
import 'package:virtuomate_flutter/ui/mvp/mvp_shell.dart';
import 'package:virtuomate_flutter/ui/shared/avatar_presence.dart';
import 'package:virtuomate_flutter/ui/shared/responsive.dart';
import 'package:virtuomate_flutter/ui/shared/ui_helpers.dart';

/// Active voice coaching session with emotion detection and history.
class VoiceActiveScreen extends StatefulWidget {
  const VoiceActiveScreen({super.key});

  @override
  State<VoiceActiveScreen> createState() => _VoiceActiveScreenState();
}

class _VoiceActiveScreenState extends State<VoiceActiveScreen> {
  final stt.SpeechToText _speech = stt.SpeechToText();
  final _textFallback = TextEditingController();
  late final TtsSpeaker _ttsSpeaker;
  bool _speechReady = false;
  bool _isListening = false;
  bool _micOn = true;
  bool _audioOn = true;
  bool _coachBusy = false;
  String _emotion = 'Happy';
  String _error = '';
  final List<_HistoryItem> _history = [];

  @override
  void initState() {
    super.initState();
    _ttsSpeaker = TtsSpeaker(FlutterTts());
    _initSpeech();
    _history.add(const _HistoryItem(
      sender: 'AI Coach',
      text: "Hello! I'm ready to assist you with voice coaching. How can I help you today?",
      duration: '5s',
    ));
  }

  Future<void> _initSpeech() async {
    final ready = await _speech.initialize();
    if (mounted) setState(() => _speechReady = ready);
  }

  Future<void> _speak(VirtuoMateController c, String text) async {
    if (!_audioOn) return;
    await _ttsSpeaker.speak(text, c.voiceProfile, voiceGender: c.voiceGender);
  }

  Future<void> _submitText(VirtuoMateController c) async {
    final words = _textFallback.text.trim();
    if (words.isEmpty || _coachBusy) return;
    setState(() {
      _coachBusy = true;
      _error = '';
      _isListening = false;
    });
    if (_isListening) await _speech.stop();
    final ok = await c.completeVoiceTurn(words);
    if (!mounted) return;
    if (!ok) {
      setState(() {
        _coachBusy = false;
        _error = c.errorMessage;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(c.errorMessage)),
      );
      return;
    }
    showAchievementUnlocks(context, c.drainAchievementUnlocks());
    final session = c.latestSessionRecord;
    final reply = session?.feedback ?? c.latestFeedback;
    setState(() {
      _coachBusy = false;
      _emotion = session?.emotion ?? 'Focused';
      _textFallback.clear();
      _history.insert(0, _HistoryItem(sender: 'You', text: words, duration: '3s'));
      _history.insert(0, _HistoryItem(sender: 'AI Coach', text: reply, duration: '5s'));
    });
    await _speak(c, reply);
  }

  Future<void> _toggleListen() async {
    if (!_speechReady || !_micOn || _coachBusy) return;
    if (_isListening) {
      await _speech.stop();
      setState(() => _isListening = false);
      return;
    }
    await _speech.listen(
      onResult: (r) async {
        if (!r.finalResult || r.recognizedWords.trim().isEmpty) return;
        setState(() {
          _coachBusy = true;
          _isListening = false;
        });
        final c = VirtuoMateScope.of(context);
        final ok = await c.completeVoiceTurn(r.recognizedWords);
        if (!mounted) return;
        if (!ok) {
          setState(() {
            _coachBusy = false;
            _error = c.errorMessage;
          });
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(c.errorMessage)),
            );
          }
          return;
        }
        showAchievementUnlocks(context, c.drainAchievementUnlocks());
        final session = c.latestSessionRecord;
        setState(() {
          _coachBusy = false;
          _error = '';
          _emotion = session?.emotion ?? 'Focused';
          _history.insert(0, _HistoryItem(sender: 'You', text: r.recognizedWords, duration: '3s'));
          _history.insert(0, _HistoryItem(sender: 'AI Coach', text: session?.feedback ?? c.latestFeedback, duration: '5s'));
        });
        await _speak(c, session?.feedback ?? c.latestFeedback);
      },
    );
    setState(() => _isListening = true);
  }

  @override
  void dispose() {
    _speech.stop();
    _ttsSpeaker.stop();
    _ttsSpeaker.dispose();
    _textFallback.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = VirtuoMateScope.of(context);
    final avatarSize = isCompactWidth(context) ? 96.0 : 120.0;
    return MvpShell(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
            responsiveHorizontalPadding(context),
            16,
            responsiveHorizontalPadding(context),
            VirtuoMvpSpacing.lg,
          ),
          child: Column(
            children: [
              ValueListenableBuilder<bool>(
                valueListenable: _ttsSpeaker.isSpeaking,
                builder: (context, speaking, _) {
                  return ValueListenableBuilder<double>(
                    valueListenable: _ttsSpeaker.mouthOpen,
                    builder: (context, mouth, _) {
                      return Stack(
                        alignment: Alignment.bottomCenter,
                        children: [
                          AvatarPresence(
                            selfieUrlOrPath: c.avatarImage,
                            useTemplate: c.avatarUseTemplate,
                            size: avatarSize,
                            isSpeaking: speaking,
                            mouthOpen: mouth,
                            isListening: _isListening,
                            emotion: _emotion.isNotEmpty
                                ? _emotion
                                : c.avatarEmotionState,
                          ),
                          Positioned(
                            bottom: 0,
                            child: EmotionBadge(emotion: _emotion),
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
              const SizedBox(height: 16),
              LayoutBuilder(
                builder: (context, constraints) {
                  final compact = constraints.maxWidth < VirtuoBreakpoints.compact;
                  final chips = [
                    MetricChip(
                      icon: Icons.hub_outlined,
                      label: 'Neural Link',
                      value: c.neuralConnectivity.full
                          ? '100%'
                          : '${c.neuralConnectivity.percent}%',
                      color: c.neuralConnectivity.full
                          ? VirtuoMvpColors.green
                          : VirtuoMvpColors.cyan,
                      expanded: false,
                    ),
                    const MetricChip(
                      icon: Icons.graphic_eq,
                      label: 'Quality',
                      value: 'HD',
                      color: VirtuoMvpColors.green,
                      expanded: false,
                    ),
                    MetricChip(
                      icon: Icons.wifi_tethering,
                      label: 'Coach',
                      value: _coachBusy ? 'Busy' : 'Ready',
                      color: _coachBusy ? VirtuoMvpColors.yellow : VirtuoMvpColors.cyan,
                      expanded: false,
                    ),
                  ];
                  if (compact) {
                    return Wrap(spacing: 8, runSpacing: 8, children: chips);
                  }
                  return Row(children: chips);
                },
              ),
              const SizedBox(height: 24),
              GestureDetector(
                onTap: () => Navigator.pushNamedAndRemoveUntil(context, AppRoutes.dashboard, (_) => false),
                child: Container(
                  width: 72,
                  height: 72,
                  decoration: const BoxDecoration(shape: BoxShape.circle, color: VirtuoMvpColors.red),
                  child: const Icon(Icons.mic_off, color: Colors.white, size: 28),
                ),
              ),
              const SizedBox(height: 8),
              const Text('End Voice Session', style: TextStyle(color: VirtuoMvpColors.textMuted, fontSize: 12)),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _ctrlBtn(Icons.mic, _isListening ? 'Listening…' : 'Hold to Talk', VirtuoMvpColors.surface, _toggleListen),
                  const SizedBox(width: 16),
                  _ctrlBtn(Icons.mic, 'Mic On', _micOn ? Colors.white : VirtuoMvpColors.surface, () => setState(() => _micOn = !_micOn), darkIcon: _micOn),
                  const SizedBox(width: 16),
                  _ctrlBtn(Icons.volume_up, 'Audio On', _audioOn ? VirtuoMvpColors.blue : VirtuoMvpColors.surface, () => setState(() => _audioOn = !_audioOn)),
                ],
              ),
              if (_coachBusy)
                const Padding(
                  padding: EdgeInsets.only(top: 12),
                  child: SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2)),
                ),
              if (_error.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: Text(_error, style: const TextStyle(color: VirtuoMvpColors.red, fontSize: 11)),
                ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                child: Text(
                  _speechReady
                      ? 'Tap the mic and speak, or type below (works on emulator).'
                      : 'Microphone unavailable — type your message below.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: VirtuoMvpColors.textMuted, fontSize: 11),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _textFallback,
                        enabled: !_coachBusy,
                        style: const TextStyle(color: VirtuoMvpColors.text, fontSize: 13),
                        decoration: InputDecoration(
                          hintText: 'Type to coach…',
                          hintStyle: TextStyle(color: VirtuoMvpColors.textMuted.withValues(alpha: 0.8)),
                          filled: true,
                          fillColor: VirtuoMvpColors.surface,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: VirtuoMvpColors.stroke),
                          ),
                        ),
                        onSubmitted: (_) => _submitText(c),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      onPressed: _coachBusy ? null : () => _submitText(c),
                      icon: const Icon(Icons.send_rounded, color: VirtuoMvpColors.cyan),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(VirtuoMvpRadii.lg),
                  color: VirtuoMvpColors.surface,
                  border: Border.all(color: VirtuoMvpColors.stroke),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Conversation History (${_history.length})',
                      style: const TextStyle(color: VirtuoMvpColors.text, fontWeight: FontWeight.w900, fontSize: 12),
                    ),
                    const SizedBox(height: 10),
                    if (_history.isNotEmpty)
                      ..._history.take(5).map((h) => Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(h.sender, style: const TextStyle(color: VirtuoMvpColors.cyan, fontWeight: FontWeight.w800, fontSize: 11)),
                                      Text(h.text, maxLines: 3, overflow: TextOverflow.ellipsis, style: const TextStyle(color: VirtuoMvpColors.textMuted, fontSize: 11)),
                                    ],
                                  ),
                                ),
                                Text(h.duration, style: const TextStyle(color: VirtuoMvpColors.textFaint, fontSize: 10)),
                              ],
                            ),
                          )),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _ctrlBtn(IconData icon, String label, Color bg, VoidCallback onTap, {bool darkIcon = false}) {
    return Column(
      children: [
        GestureDetector(
          onTap: onTap,
          child: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(shape: BoxShape.circle, color: bg, border: Border.all(color: VirtuoMvpColors.stroke)),
            child: Icon(icon, color: darkIcon ? VirtuoMvpColors.bg0 : VirtuoMvpColors.text, size: 22),
          ),
        ),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(color: VirtuoMvpColors.textFaint, fontSize: 9)),
      ],
    );
  }
}

class _HistoryItem {
  const _HistoryItem({required this.sender, required this.text, required this.duration});
  final String sender;
  final String text;
  final String duration;
}
