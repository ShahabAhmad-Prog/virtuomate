import 'dart:async';

import 'package:flutter/material.dart';

import 'package:flutter_tts/flutter_tts.dart';

import 'package:speech_to_text/speech_to_text.dart' as stt;

import 'package:virtuomate_flutter/theme/virtuomate_mvp_theme.dart';

import 'package:virtuomate_flutter/ui/mvp/mvp_shell.dart';

import 'package:virtuomate_flutter/ui/shared/achievement_feedback.dart';
import 'package:virtuomate_flutter/ui/virtuomate_bindings.dart';

import 'package:virtuomate_flutter/ui/mvp/mvp_widgets.dart';

import 'package:virtuomate_flutter/ui/shared/ui_helpers.dart';



class PresentationScreen extends StatefulWidget {

  const PresentationScreen({super.key});



  @override

  State<PresentationScreen> createState() => _PresentationScreenState();

}



class _PresentationScreenState extends State<PresentationScreen> {

  static const _totalSlides = 5;

  static const _slideTitles = [

    'Introduction',

    'Problem Statement',

    'Solution Overview',

    'Results & Impact',

    'Conclusion',

  ];

  static const _prompts = [

    'Introduce yourself and the topic.',

    'Explain the core problem your audience faces.',

    'Present your solution clearly and confidently.',

    'Share measurable results and outcomes.',

    'Summarize key points and invite questions.',

  ];



  int _slide = 0;

  int _seconds = 0;

  Timer? _timer;

  String _audienceFeedback = 'Audience is engaged and interested.';

  String _error = '';

  final _speechInput = TextEditingController();

  final stt.SpeechToText _speech = stt.SpeechToText();

  final FlutterTts _tts = FlutterTts();

  bool _speechReady = false;

  bool _isListening = false;



  @override

  void initState() {

    super.initState();

    _timer = Timer.periodic(const Duration(seconds: 1), (_) {

      if (mounted) setState(() => _seconds++);

    });

    _initSpeech();

  }



  Future<void> _initSpeech() async {

    final ready = await _speech.initialize();

    if (!mounted) return;

    setState(() => _speechReady = ready);

  }



  @override

  void dispose() {

    _timer?.cancel();

    _speech.stop();

    _tts.stop();

    _speechInput.dispose();

    super.dispose();

  }



  String _formatTime(int s) {

    final m = (s ~/ 60).toString().padLeft(2, '0');

    final sec = (s % 60).toString().padLeft(2, '0');

    return '$m:$sec';

  }



  Future<void> _toggleListening() async {

    if (!_speechReady) {

      setState(() => _error = 'Speech recognition not available.');

      return;

    }

    if (_isListening) {

      await _speech.stop();

      if (mounted) setState(() => _isListening = false);

      return;

    }

    await _speech.listen(

      onResult: (result) {

        if (!mounted) return;

        setState(() => _speechInput.text = result.recognizedWords);

      },

    );

    if (mounted) setState(() => _isListening = true);

  }



  Future<void> _nextSlide() async {

    final c = VirtuoMateScope.of(context);

    final spoken = _speechInput.text.trim();

    if (spoken.isEmpty) {

      setState(() => _error = 'Speak or type your presentation for this slide first.');

      return;

    }

    final combined =

        'Slide: ${_slideTitles[_slide]}. Prompt: ${_prompts[_slide]}. User presentation: $spoken';

    final ok = await c.completePresentation(

      slideIndex: _slide,

      totalSlides: _totalSlides,

      prompt: combined,

    );

    if (!mounted) return;

    if (!ok) {

      setState(() => _error = c.errorMessage);

      return;

    }

    showAchievementUnlocks(context, c.drainAchievementUnlocks());
    final session = c.latestSessionRecord;

    setState(() {

      _error = '';

      _audienceFeedback = session?.feedback.split('•').last.trim() ?? _audienceFeedback;

      _speechInput.clear();

    });

    if (_slide < _totalSlides - 1) {

      setState(() => _slide++);

      await applyVoiceProfileToTts(_tts, c.encodedVoiceProfile);

      await _tts.speak('Next slide: ${_slideTitles[_slide]}. ${_prompts[_slide]}');

    } else {

      await applyVoiceProfileToTts(_tts, c.encodedVoiceProfile);

      await _tts.speak('Presentation complete. Great work.');

      if (mounted) Navigator.pushNamed(context, AppRoutes.feedback);

    }

  }



  @override

  Widget build(BuildContext context) {

    final progress = (_slide + 1) / _totalSlides;

    return MvpShell(

      body: Column(

        children: [

          MvpTopBar(

            title: 'Presentation Practice',

            right: Text(

              _formatTime(_seconds),

              style: const TextStyle(color: VirtuoMvpColors.cyan, fontWeight: FontWeight.w900, fontSize: 12),

            ),

          ),

          Padding(

            padding: const EdgeInsets.symmetric(horizontal: VirtuoMvpSpacing.lg),

            child: Row(

              mainAxisAlignment: MainAxisAlignment.spaceBetween,

              children: [

                Text('Slide ${_slide + 1} of $_totalSlides', style: const TextStyle(color: VirtuoMvpColors.textMuted, fontSize: 11)),

                Text('${(progress * 100).round()}%', style: const TextStyle(color: VirtuoMvpColors.cyan, fontWeight: FontWeight.w800, fontSize: 11)),

              ],

            ),

          ),

          Padding(

            padding: const EdgeInsets.fromLTRB(VirtuoMvpSpacing.lg, 6, VirtuoMvpSpacing.lg, 0),

            child: ClipRRect(

              borderRadius: BorderRadius.circular(4),

              child: LinearProgressIndicator(

                value: progress,

                minHeight: 6,

                backgroundColor: VirtuoMvpColors.surface2,

                color: VirtuoMvpColors.cyan,

              ),

            ),

          ),

          Expanded(

            child: SingleChildScrollView(

              padding: const EdgeInsets.all(VirtuoMvpSpacing.lg),

              child: Column(

                children: [

                  VCard(

                    padding: const EdgeInsets.all(16),

                    child: Column(

                      children: [

                        const Row(

                          mainAxisAlignment: MainAxisAlignment.center,

                          children: [

                            Icon(Icons.visibility_outlined, color: VirtuoMvpColors.cyan, size: 14),

                            SizedBox(width: 6),

                            Text('Virtual Audience', style: TextStyle(color: VirtuoMvpColors.text, fontWeight: FontWeight.w900, fontSize: 12)),

                          ],

                        ),

                        const SizedBox(height: 12),

                        Container(

                          width: double.infinity,

                          padding: const EdgeInsets.all(14),

                          decoration: BoxDecoration(

                            borderRadius: BorderRadius.circular(12),

                            color: VirtuoMvpColors.inputFill,

                          ),

                          child: Row(

                            children: [

                              const Text('😊', style: TextStyle(fontSize: 24)),

                              const SizedBox(width: 12),

                              Expanded(

                                child: Text(_audienceFeedback, style: const TextStyle(color: VirtuoMvpColors.textMuted, fontSize: 12)),

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

                        Row(

                          children: [

                            const Icon(Icons.description_outlined, color: VirtuoMvpColors.cyan, size: 16),

                            const SizedBox(width: 8),

                            Text(_slideTitles[_slide], style: const TextStyle(color: VirtuoMvpColors.text, fontWeight: FontWeight.w900, fontSize: 14)),

                          ],

                        ),

                        const SizedBox(height: 10),

                        Container(

                          padding: const EdgeInsets.all(12),

                          decoration: BoxDecoration(

                            borderRadius: BorderRadius.circular(10),

                            color: VirtuoMvpColors.cyan.withValues(alpha: 0.08),

                            border: Border.all(color: VirtuoMvpColors.cyan.withValues(alpha: 0.2)),

                          ),

                          child: Column(

                            crossAxisAlignment: CrossAxisAlignment.start,

                            children: [

                              const Text('Speaking Prompt:', style: TextStyle(color: VirtuoMvpColors.cyan, fontWeight: FontWeight.w800, fontSize: 11)),

                              const SizedBox(height: 4),

                              Text(_prompts[_slide], style: const TextStyle(color: VirtuoMvpColors.text, fontSize: 12)),

                            ],

                          ),

                        ),

                        const SizedBox(height: 12),

                        const Text('Your presentation (speak or type)', style: TextStyle(color: VirtuoMvpColors.textMuted, fontSize: 11, fontWeight: FontWeight.w700)),

                        const SizedBox(height: 8),

                        VTextField(controller: _speechInput, maxLines: 4, hintText: 'Deliver this slide aloud…'),

                        const SizedBox(height: 8),

                        VButton(

                          title: _isListening ? 'Stop microphone' : 'Speak this slide',

                          variant: VButtonVariant.outline,

                          icon: _isListening ? Icons.mic_off_outlined : Icons.mic_none_outlined,

                          expanded: true,

                          onPressed: _toggleListening,

                        ),

                      ],

                    ),

                  ),

                  if (_error.isNotEmpty) ...[

                    const SizedBox(height: 8),

                    Text(_error, style: const TextStyle(color: VirtuoMvpColors.red, fontSize: 11)),

                  ],

                  const SizedBox(height: 16),

                  GradientPrimaryButton(

                    title: _slide < _totalSlides - 1 ? 'Next Slide' : 'Finish Presentation',

                    icon: Icons.arrow_forward,

                    onPressed: _nextSlide,

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

