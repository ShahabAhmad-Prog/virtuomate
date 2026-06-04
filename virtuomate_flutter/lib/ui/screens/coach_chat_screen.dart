import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:virtuomate_flutter/config/app_config.dart';
import 'package:virtuomate_flutter/services/tts_speaker.dart';
import 'package:virtuomate_flutter/intelligence/api_coach_engine.dart';
import 'package:virtuomate_flutter/services/chat_service.dart';
import 'package:virtuomate_flutter/theme/virtuomate_mvp_theme.dart';
import 'package:virtuomate_flutter/ui/shared/achievement_feedback.dart';
import 'package:virtuomate_flutter/ui/virtuomate_bindings.dart';
import 'package:virtuomate_flutter/ui/mvp/mvp_shell.dart';
import 'package:virtuomate_flutter/ui/mvp/mvp_widgets.dart';
import 'package:virtuomate_flutter/ui/shared/avatar_presence.dart';
import 'package:virtuomate_flutter/ui/shared/typing_indicator.dart';

class _LocalMessage {
  _LocalMessage({required this.isUser, required this.text, this.emotion});
  final bool isUser;
  final String text;
  final String? emotion;
}

class CoachChatScreen extends StatefulWidget {
  const CoachChatScreen({super.key});

  @override
  State<CoachChatScreen> createState() => _CoachChatScreenState();
}

class _CoachChatScreenState extends State<CoachChatScreen> {
  final _input = TextEditingController();
  final _scroll = ScrollController();
  ChatService? _chat;
  final List<_LocalMessage> _localMessages = [
    _LocalMessage(
      isUser: false,
      text:
          "Hi! I'm your VirtuoMate coach. Ask about interviews, presentations, or career goals.",
    ),
  ];
  bool _typing = false;
  String _error = '';
  String _coachStatusBanner = '';
  late final TtsSpeaker _ttsSpeaker;

  @override
  void initState() {
    super.initState();
    _ttsSpeaker = TtsSpeaker(FlutterTts());
    if (AppConfig.useFirebase) {
      _chat = ChatService();
      _chat!.seedWelcomeIfEmpty();
    }
  }

  @override
  void dispose() {
    _ttsSpeaker.dispose();
    _input.dispose();
    _scroll.dispose();
    super.dispose();
  }

  Widget _coachAvatar(
    VirtuoMateController c, {
    required String emotion,
    required double avatarSize,
  }) {
    return ValueListenableBuilder<bool>(
      valueListenable: _ttsSpeaker.isSpeaking,
      builder: (context, speaking, _) {
        return ValueListenableBuilder<double>(
          valueListenable: _ttsSpeaker.mouthOpen,
          builder: (context, mouth, _) {
            return AvatarPresence(
              selfieUrlOrPath: c.avatarImage,
              useTemplate: c.avatarUseTemplate,
              size: avatarSize,
              isSpeaking: speaking || _typing,
              mouthOpen: mouth,
              emotion: emotion,
            );
          },
        );
      },
    );
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scroll.hasClients) return;
      _scroll.animateTo(
        _scroll.position.maxScrollExtent,
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOut,
      );
    });
  }

  Future<void> _send() async {
    final text = _input.text.trim();
    if (text.isEmpty || _typing) return;
    setState(() {
      _error = '';
      _typing = true;
      _input.clear();
      if (_chat == null) {
        _localMessages.add(_LocalMessage(isUser: true, text: text));
      }
    });

    try {
      await _chat?.addUserMessage(text);
    } catch (e) {
      if (mounted) {
        setState(() {
          _typing = false;
          _error = e.toString();
        });
      }
      return;
    }
    _scrollToBottom();

    final c = VirtuoMateScope.of(context);
    final ok = await c.completeConversation(text);
    if (!mounted) return;

    if (!ok) {
      setState(() {
        _typing = false;
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
    final reply = session?.feedback ?? c.latestFeedback;
    final emotion = session?.emotion;
    final provider = c.lastCoachProvider;
    final hint = c.lastCoachHint.trim();
    String banner = '';
    if (!AppConfig.useBackendApi) {
      banner =
          'Offline coach templates only. Run the app with USE_BACKEND_API=true and sign in for live AI.';
    } else if (!CoachFeedbackResult.isLiveProvider(provider)) {
      banner = hint.isNotEmpty
          ? hint
          : 'Live Gemini is unavailable. Add credits at aistudio.google.com (project: virtuomate).';
    }

    try {
      await _chat?.addCoachMessage(reply, emotion: emotion);
    } catch (_) {
      /* session still saved */
    }

    if (mounted) {
      setState(() {
        _typing = false;
        _coachStatusBanner = banner;
        if (_chat == null) {
          _localMessages.add(_LocalMessage(isUser: false, text: reply, emotion: emotion));
        }
      });
    }
    _scrollToBottom();

    if (mounted && reply.trim().isNotEmpty) {
      await _ttsSpeaker.speak(
        reply,
        c.voiceProfile,
        voiceGender: c.voiceGender,
      );
    }
  }

  Widget _bubble({
    required bool isUser,
    required String text,
    required double maxWidth,
  }) {
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        constraints: BoxConstraints(maxWidth: maxWidth),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          color: isUser
              ? VirtuoMvpColors.cyan.withValues(alpha: 0.15)
              : VirtuoMvpColors.surface,
          border: Border.all(
            color: isUser
                ? VirtuoMvpColors.cyan.withValues(alpha: 0.35)
                : VirtuoMvpColors.stroke,
          ),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: isUser ? VirtuoMvpColors.text : VirtuoMvpColors.textMuted,
            fontSize: 12,
            height: 1.4,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = VirtuoMateScope.of(context);
    final keyboardOpen = MediaQuery.viewInsetsOf(context).bottom > 0;
    final maxW = MediaQuery.sizeOf(context).width * 0.82;
    final avatarSize = keyboardOpen ? 48.0 : 72.0;

    Widget buildList({
      required int messageCount,
      required Widget Function(int index) itemBuilder,
    }) {
      final count = messageCount + (_typing ? 1 : 0);
      return ListView.builder(
        controller: _scroll,
        padding: const EdgeInsets.fromLTRB(
          VirtuoMvpSpacing.lg,
          8,
          VirtuoMvpSpacing.lg,
          8,
        ),
        itemCount: count,
        itemBuilder: (context, index) {
          if (_typing && index == messageCount) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: TypingIndicator(),
            );
          }
          return itemBuilder(index);
        },
      );
    }

    return MvpShell(
      body: Column(
        children: [
          const MvpTopBar(title: 'AI Coach Chat'),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: VirtuoMvpSpacing.lg),
            child: _chat != null
                ? StreamBuilder<List<ChatMessage>>(
                    stream: _chat!.watchMessages(),
                    builder: (context, snap) {
                      final msgs = snap.data ?? const [];
                      final emotion = msgs.isNotEmpty && !msgs.last.isUser
                          ? (msgs.last.emotion ?? 'Focused')
                          : 'Neutral';
                      return _coachAvatar(
                        c,
                        emotion: emotion,
                        avatarSize: avatarSize,
                      );
                    },
                  )
                : _coachAvatar(
                    c,
                    avatarSize: avatarSize,
                    emotion: _localMessages.isNotEmpty && !_localMessages.last.isUser
                        ? (_localMessages.last.emotion ?? 'neutral')
                        : c.avatarEmotionState,
                  ),
          ),
          SizedBox(height: keyboardOpen ? 4 : 8),
          if (_coachStatusBanner.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(
                VirtuoMvpSpacing.lg,
                0,
                VirtuoMvpSpacing.lg,
                8,
              ),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: VirtuoMvpColors.amber.withValues(alpha: 0.12),
                  border: Border.all(color: VirtuoMvpColors.amber.withValues(alpha: 0.45)),
                ),
                child: Text(
                  _coachStatusBanner,
                  style: const TextStyle(
                    color: VirtuoMvpColors.amber,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    height: 1.35,
                  ),
                ),
              ),
            ),
          Expanded(
            child: _chat != null
                ? StreamBuilder<List<ChatMessage>>(
                    stream: _chat!.watchMessages(),
                    builder: (context, snap) {
                      if (snap.connectionState == ConnectionState.waiting &&
                          !snap.hasData) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      final messages = snap.data ?? const [];
                      if (messages.isNotEmpty) {
                        WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
                      }
                      return buildList(
                        messageCount: messages.length,
                        itemBuilder: (i) => _bubble(
                          isUser: messages[i].isUser,
                          text: messages[i].text,
                          maxWidth: maxW,
                        ),
                      );
                    },
                  )
                : buildList(
                    messageCount: _localMessages.length,
                    itemBuilder: (i) {
                      final m = _localMessages[i];
                      return _bubble(isUser: m.isUser, text: m.text, maxWidth: maxW);
                    },
                  ),
          ),
          if (_error.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: VirtuoMvpSpacing.lg),
              child: Text(
                _error,
                style: const TextStyle(color: VirtuoMvpColors.red, fontSize: 11),
              ),
            ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                VirtuoMvpSpacing.lg,
                6,
                VirtuoMvpSpacing.lg,
                VirtuoMvpSpacing.sm,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: VTextField(
                      controller: _input,
                      hintText: 'Message your coach…',
                      maxLines: keyboardOpen ? 2 : 3,
                    ),
                  ),
                  const SizedBox(width: 10),
                  VButton(
                    title: 'Send',
                    icon: Icons.send_rounded,
                    height: 44,
                    onPressed: _typing ? null : _send,
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
