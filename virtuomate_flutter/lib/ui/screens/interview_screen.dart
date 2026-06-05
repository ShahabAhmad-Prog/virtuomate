import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:virtuomate_flutter/core/models.dart';
import 'package:virtuomate_flutter/ui/shared/speech_capture.dart';
import 'package:virtuomate_flutter/theme/virtuomate_mvp_theme.dart';
import 'package:virtuomate_flutter/ui/virtuomate_bindings.dart';
import 'package:virtuomate_flutter/ui/mvp/mvp_shell.dart';
import 'package:virtuomate_flutter/ui/mvp/mvp_widgets.dart';
import 'package:virtuomate_flutter/ui/shared/achievement_feedback.dart';
import 'package:virtuomate_flutter/ui/shared/ui_helpers.dart';

class InterviewScreen extends StatefulWidget {
  const InterviewScreen({super.key});

  @override
  State<InterviewScreen> createState() => _InterviewScreenState();
}

class _InterviewScreenState extends State<InterviewScreen> {
  int _step = 0;
  final _input = TextEditingController();
  final SpeechCapture _voice = SpeechCapture();
  final FlutterTts _tts = FlutterTts();
  int _confidence = 72;
  String _analysisCaption =
      'Live scoring starts when you type or speak (Intelligence Engine on cloud).';
  bool _liveFromEngine = false;
  bool _analysisBusy = false;
  String _error = '';
  bool _speechReady = false;
  bool _isListening = false;
  bool _heardMicLevel = false;
  double _soundLevel = 0;
  String _lastRecognizedWords = '';
  Timer? _previewDebounce;

  @override
  void initState() {
    super.initState();
    _input.addListener(() {
      if (!mounted) return;
      setState(() {});
      _scheduleLiveAnalysis(_input.text);
    });
    _voice.prepare().then((r) {
      if (!mounted) return;
      setState(() {
        _speechReady = r;
        if (r) _error = '';
      });
    });
  }

  @override
  void dispose() {
    _previewDebounce?.cancel();
    _voice.stop();
    _tts.stop();
    _input.dispose();
    super.dispose();
  }

  void _scheduleLiveAnalysis(String text) {
    _previewDebounce?.cancel();
    final trimmed = text.trim();
    if (trimmed.length < 12) {
      if (mounted) {
        setState(() {
          _liveFromEngine = false;
          _analysisBusy = false;
          _confidence = 72;
          _analysisCaption =
              'Add a few more words for live Intelligence Engine scoring.';
        });
      }
      return;
    }

    _previewDebounce = Timer(const Duration(milliseconds: 1100), () async {
      final c = VirtuoMateScope.of(context);
      if (c.user == null) return;
      if (mounted) setState(() => _analysisBusy = true);
      final assessment = await c.previewInterviewAssessment(trimmed);
      if (!mounted) return;
      if (assessment == null) {
        setState(() {
          _analysisBusy = false;
          _liveFromEngine = false;
          _confidence = c.sessions.isNotEmpty
              ? (c.latestSessionRecord?.confidenceScore ?? 72)
              : _confidence;
          _analysisCaption = 'Live preview unavailable — full score after Submit.';
        });
        return;
      }
      setState(() {
        _analysisBusy = false;
        _liveFromEngine = true;
        _confidence = assessment.confidenceScore;
        _analysisCaption =
            'Live · Intelligence Engine · clarity ${assessment.clarityScore}% · '
            '${assessment.emotion}';
      });
    });
  }

  void _applyRecognizedWords(String words) {
    final trimmed = words.trim();
    if (trimmed.isEmpty) return;
    _lastRecognizedWords = trimmed;
    _input.value = TextEditingValue(
      text: trimmed,
      selection: TextSelection.collapsed(offset: trimmed.length),
    );
    _scheduleLiveAnalysis(trimmed);
  }

  Future<String> _answerTextForSubmit() async {
    if (_isListening) {
      await _voice.stop();
      if (mounted) setState(() => _isListening = false);
      await Future<void>.delayed(const Duration(milliseconds: 600));
    }
    final typed = _input.text.trim();
    final spoken = _lastRecognizedWords.trim();
    if (typed.isNotEmpty) return typed;
    return spoken;
  }

  Future<void> _toggleVoiceInput() async {
    setState(() => _error = '');
    if (_isListening) {
      await _voice.stop();
      if (mounted) setState(() => _isListening = false);
      return;
    }

    setState(() {
      _heardMicLevel = false;
      _soundLevel = 0;
    });

    final started = await _voice.startListening(
      onWords: (words, isFinal) {
        if (!mounted) return;
        _applyRecognizedWords(words);
        setState(() {});
        if (isFinal && words.trim().isNotEmpty) {
          _error = '';
        }
      },
      onSoundLevel: (level) {
        if (!mounted) return;
        setState(() {
          _soundLevel = level;
          if (level > 0.02) _heardMicLevel = true;
        });
      },
      onError: (message) {
        if (!mounted) return;
        setState(() {
          _isListening = false;
          _error = message;
        });
      },
    );
    if (!mounted) return;
    if (!started) {
      if (_error.isEmpty) {
        setState(() => _error =
            'Could not start voice input. Check microphone permission or use a physical device.');
      }
      return;
    }
    setState(() => _isListening = true);
  }

  Future<void> _submit() async {
    final c = VirtuoMateScope.of(context);
    final answer = await _answerTextForSubmit();
    if (answer.isEmpty) {
      setState(() {
        if (_heardMicLevel && _lastRecognizedWords.isEmpty) {
          _error =
              'Microphone is working but speech was not recognized. Speak louder, use English, or type your answer.';
        } else if (!_heardMicLevel && _isListening == false && _speechReady) {
          _error =
              'No speech heard. On emulator: Extended Controls → Microphone → Virtual mic. On phone: allow Microphone for VirtuoMate.';
        } else {
          _error = 'Type or speak your answer before submitting.';
        }
      });
      return;
    }
    if (c.user == null) {
      setState(() => _error = 'Please sign in to use interview coaching.');
      return;
    }
    setState(() {
      _error = '';
    });
    final ok = await c.completeInterview(stepIndex: _step, prompt: answer);
    if (!mounted) return;
    if (!ok) {
      setState(() => _error = c.errorMessage);
      return;
    }
    showAchievementUnlocks(context, c.drainAchievementUnlocks());
    final session = c.latestSessionRecord;
    setState(() {
      _error = '';
      _confidence = session?.confidenceScore ??
          session?.assessment?.confidenceScore ??
          72;
      _liveFromEngine = session?.assessment != null;
      _analysisCaption = _liveFromEngine
          ? 'Final score from Intelligence Engine (saved with session).'
          : 'Score from coach session.';
    });
    await applyVoiceProfileToTts(_tts, c.encodedVoiceProfile);
    await _tts.speak(session?.feedback ?? c.latestFeedback);
    if (_step < kInterviewSteps.length - 1) {
      setState(() {
        _step += 1;
        _input.clear();
        _lastRecognizedWords = '';
        _confidence = 72;
        _liveFromEngine = false;
        _analysisCaption =
            'Live scoring starts when you type or speak (Intelligence Engine on cloud).';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final step = kInterviewSteps[_step];
    final progress = (_step + 1) / kInterviewSteps.length;

    return MvpShell(
      body: Column(
        children: [
          MvpTopBar(
            title: 'Interview Simulation',
            right: Text(
              '${_step + 1}/${kInterviewSteps.length}',
              style: const TextStyle(color: VirtuoMvpColors.cyan, fontWeight: FontWeight.w900, fontSize: 12),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: VirtuoMvpSpacing.lg),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 4,
                backgroundColor: VirtuoMvpColors.surface2,
                color: VirtuoMvpColors.cyan,
              ),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(VirtuoMvpSpacing.lg),
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
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: VirtuoMvpColors.surface,
                                border: Border.all(color: VirtuoMvpColors.stroke),
                              ),
                              child: const Icon(Icons.memory, color: VirtuoMvpColors.cyan, size: 22),
                            ),
                            const SizedBox(width: 12),
                            const Expanded(
                              child: Text('AI Interviewer v3.0', style: TextStyle(color: VirtuoMvpColors.text, fontWeight: FontWeight.w900)),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(999),
                                color: VirtuoMvpColors.magenta.withValues(alpha: 0.25),
                              ),
                              child: Text(step.phase, style: const TextStyle(color: VirtuoMvpColors.magenta, fontWeight: FontWeight.w800, fontSize: 10)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: List.generate(3, (i) => Container(
                                margin: const EdgeInsets.only(right: 4),
                                width: 4 + (i * 3).toDouble(),
                                height: 16 + (i * 6).toDouble(),
                                decoration: BoxDecoration(
                                  color: VirtuoMvpColors.green,
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              )),
                        ),
                        const SizedBox(height: 12),
                        Text(step.question, style: const TextStyle(color: VirtuoMvpColors.text, fontSize: 13, height: 1.4)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  VCard(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ConfidenceBar(percent: _confidence),
                        const SizedBox(height: 8),
                        Text(
                          _analysisBusy
                              ? 'Analyzing with Intelligence Engine…'
                              : _analysisCaption,
                          style: const TextStyle(color: VirtuoMvpColors.textFaint, fontSize: 10),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Your Response', style: TextStyle(color: VirtuoMvpColors.text, fontWeight: FontWeight.w900, fontSize: 13)),
                      VButton(
                        title: _isListening ? 'Stop listening' : 'Voice Input',
                        variant: VButtonVariant.outline,
                        icon: _isListening ? Icons.mic_off : Icons.mic,
                        height: 36,
                        onPressed: _speechReady ? _toggleVoiceInput : null,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    !_speechReady
                        ? 'Voice input unavailable on this device/emulator.'
                        : _isListening
                            ? _heardMicLevel
                                ? 'Listening… mic active (${_soundLevel.toStringAsFixed(1)}). Speak, then Submit.'
                                : 'Listening… if level stays 0, check mic permission or emulator virtual mic.'
                            : 'Tap Voice Input, speak, then Submit.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: _speechReady
                          ? VirtuoMvpColors.textMuted
                          : VirtuoMvpColors.amber.withValues(alpha: 0.95),
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if (_lastRecognizedWords.isNotEmpty && _isListening) ...[
                    const SizedBox(height: 6),
                    Text(
                      'Heard: $_lastRecognizedWords',
                      style: const TextStyle(color: VirtuoMvpColors.cyan, fontSize: 11, height: 1.3),
                    ),
                  ],
                  const SizedBox(height: 8),
                  VTextField(
                    controller: _input,
                    maxLines: 5,
                    hintText: 'Type your answer here or use voice input...',
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('${_input.text.length} chars', style: const TextStyle(color: VirtuoMvpColors.textFaint, fontSize: 10)),
                      const Text('~1 min', style: TextStyle(color: VirtuoMvpColors.textFaint, fontSize: 10)),
                    ],
                  ),
                  if (_error.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(_error, style: const TextStyle(color: VirtuoMvpColors.red, fontSize: 11)),
                  ],
                  const SizedBox(height: 14),
                  VCard(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.lightbulb_outline, color: VirtuoMvpColors.purple, size: 16),
                            SizedBox(width: 8),
                            Text('AI Strategy Suggestions', style: TextStyle(color: VirtuoMvpColors.text, fontWeight: FontWeight.w900, fontSize: 12)),
                          ],
                        ),
                        ...step.tips.map((t) => Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('• ', style: TextStyle(color: VirtuoMvpColors.purple)),
                                  Expanded(child: Text(t, style: const TextStyle(color: VirtuoMvpColors.textMuted, fontSize: 11))),
                                ],
                              ),
                            )),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  GradientPrimaryButton(
                    title: _step < kInterviewSteps.length - 1 ? 'Submit & Next' : 'Complete Interview',
                    icon: Icons.flash_on,
                    onPressed: _submit,
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
