import 'dart:io';

import 'package:flutter/material.dart';

import 'package:speech_to_text/speech_to_text.dart' as stt;

import 'package:virtuomate_flutter/theme/virtuomate_mvp_theme.dart';

import 'package:virtuomate_flutter/ui/virtuomate_bindings.dart';

import 'package:virtuomate_flutter/ui/mvp/mvp_shell.dart';



/// Pre-connection voice session — verifies mic/STT before active call.

class VoiceSessionScreen extends StatefulWidget {

  const VoiceSessionScreen({super.key});



  @override

  State<VoiceSessionScreen> createState() => _VoiceSessionScreenState();

}



class _VoiceSessionScreenState extends State<VoiceSessionScreen> {

  final stt.SpeechToText _speech = stt.SpeechToText();

  bool _connecting = false;

  bool _speechReady = false;

  String _status = 'Checking microphone…';



  @override

  void initState() {

    super.initState();

    _prepareConnection();

  }



  Future<void> _prepareConnection() async {

    final ready = await _speech.initialize();

    if (!mounted) return;

    setState(() {

      _speechReady = ready;

      _status = ready

          ? 'Microphone ready — tap to start voice coaching'

          : 'Speech recognition unavailable. Use text session instead.';

    });

  }



  Future<void> _startSession() async {

    if (!_speechReady) {

      setState(() => _status = 'Enable microphone permission in system settings.');

      return;

    }

    setState(() {

      _connecting = true;

      _status = 'Connecting to AI coach…';

    });

    await Future<void>.delayed(const Duration(milliseconds: 600));

    if (!mounted) return;

    Navigator.pushReplacementNamed(context, AppRoutes.voiceActive);

  }



  @override

  Widget build(BuildContext context) {

    final c = VirtuoMateScope.of(context);

    return MvpShell(

      body: Column(

        children: [

          Padding(

            padding: const EdgeInsets.fromLTRB(VirtuoMvpSpacing.lg, 12, VirtuoMvpSpacing.lg, 0),

            child: Row(

              children: [

                InkWell(

                  onTap: () => Navigator.maybePop(context),

                  child: const Row(

                    children: [

                      Icon(Icons.chevron_left, color: VirtuoMvpColors.cyan, size: 22),

                      Text('Back', style: TextStyle(color: VirtuoMvpColors.cyan, fontWeight: FontWeight.w700)),

                    ],

                  ),

                ),

                const Expanded(

                  child: Text(

                    'Voice Session',

                    textAlign: TextAlign.center,

                    style: TextStyle(color: VirtuoMvpColors.text, fontWeight: FontWeight.w900, fontSize: 16),

                  ),

                ),

                IconButton(

                  icon: const Icon(Icons.settings_outlined, color: VirtuoMvpColors.textMuted),

                  onPressed: () => Navigator.pushNamed(context, AppRoutes.settings),

                ),

              ],

            ),

          ),

          Container(

            margin: const EdgeInsets.symmetric(horizontal: VirtuoMvpSpacing.lg, vertical: 8),

            height: 1,

            color: VirtuoMvpColors.cyan.withValues(alpha: 0.3),

          ),

          Container(

            margin: const EdgeInsets.symmetric(horizontal: VirtuoMvpSpacing.lg),

            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),

            decoration: BoxDecoration(

              borderRadius: BorderRadius.circular(999),

              color: _speechReady

                  ? VirtuoMvpColors.green.withValues(alpha: 0.2)

                  : VirtuoMvpColors.surface,

              border: Border.all(

                color: _speechReady ? VirtuoMvpColors.green : VirtuoMvpColors.stroke,

              ),

            ),

            child: Row(

              mainAxisSize: MainAxisSize.min,

              children: [

                Container(

                  width: 8,

                  height: 8,

                  decoration: BoxDecoration(

                    shape: BoxShape.circle,

                    color: _speechReady ? VirtuoMvpColors.green : VirtuoMvpColors.textMuted,

                  ),

                ),

                const SizedBox(width: 8),

                Text(

                  _speechReady ? 'Ready' : 'Not ready',

                  style: TextStyle(

                    color: _speechReady ? VirtuoMvpColors.green : VirtuoMvpColors.textMuted,

                    fontWeight: FontWeight.w800,

                    fontSize: 12,

                  ),

                ),

              ],

            ),

          ),

          Expanded(

            child: Column(

              mainAxisAlignment: MainAxisAlignment.center,

              children: [

                Container(

                  width: 180,

                  height: 180,

                  decoration: BoxDecoration(

                    shape: BoxShape.circle,

                    border: Border.all(color: VirtuoMvpColors.cyan.withValues(alpha: 0.5), width: 3),

                    boxShadow: [

                      BoxShadow(

                        color: VirtuoMvpColors.cyan.withValues(alpha: 0.25),

                        blurRadius: 24,

                        spreadRadius: 2,

                      ),

                    ],

                  ),

                  child: ClipOval(

                    child: c.avatarImage.trim().isNotEmpty

                        ? (c.avatarImage.startsWith('http')

                            ? Image.network(c.avatarImage, fit: BoxFit.cover)

                            : Image.file(File(c.avatarImage), fit: BoxFit.cover))

                        : const Icon(Icons.person, size: 72, color: VirtuoMvpColors.textMuted),

                  ),

                ),

                const SizedBox(height: 24),

                Padding(

                  padding: const EdgeInsets.symmetric(horizontal: VirtuoMvpSpacing.lg),

                  child: Text(

                    _status,

                    textAlign: TextAlign.center,

                    style: const TextStyle(color: VirtuoMvpColors.textMuted, fontSize: 12),

                  ),

                ),

                const SizedBox(height: 32),

                GestureDetector(

                  onTap: _connecting ? null : _startSession,

                  child: Container(

                    width: 72,

                    height: 72,

                    decoration: BoxDecoration(

                      shape: BoxShape.circle,

                      color: _speechReady ? VirtuoMvpColors.green : VirtuoMvpColors.textMuted,

                      boxShadow: [

                        BoxShadow(

                          color: VirtuoMvpColors.green.withValues(alpha: _speechReady ? 0.4 : 0.1),

                          blurRadius: 16,

                          spreadRadius: 2,

                        ),

                      ],

                    ),

                    child: _connecting

                        ? const Padding(

                            padding: EdgeInsets.all(20),

                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),

                          )

                        : const Icon(Icons.call, color: Colors.white, size: 32),

                  ),

                ),

                const SizedBox(height: 16),

                Text(

                  _connecting ? 'Connecting…' : 'Start Voice Session',

                  style: const TextStyle(color: VirtuoMvpColors.text, fontWeight: FontWeight.w800, fontSize: 15),

                ),

              ],

            ),

          ),

        ],

      ),

    );

  }

}

