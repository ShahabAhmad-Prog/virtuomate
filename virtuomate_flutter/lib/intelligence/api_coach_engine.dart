import 'package:flutter/foundation.dart';
import 'package:virtuomate_flutter/core/coaching_assessment.dart';
import 'package:virtuomate_flutter/intelligence/coach_engine.dart';
import 'package:virtuomate_flutter/network/api_client.dart';

class CoachFeedbackResult {
  CoachFeedbackResult({
    required this.feedback,
    required this.emotion,
    required this.confidence,
    this.assessment,
    this.provider = '',
    this.coachHint = '',
  });

  final String feedback;
  final String emotion;
  final int confidence;
  final CoachingAssessment? assessment;
  final String provider;
  final String coachHint;

  static bool isLiveProvider(String provider) {
    return provider == 'gemini' ||
        provider == 'openai' ||
        provider.startsWith('openai');
  }

  bool get isLiveAi => isLiveProvider(provider);
}

class ApiCoachEngine implements CoachEngine {
  ApiCoachEngine(this._api);

  final ApiClient _api;
  final MockCoachEngine _fallback = MockCoachEngine();

  @override
  String detectEmotion(String userInput) => _fallback.detectEmotion(userInput);

  @override
  int estimateConfidence(String userInput) => _fallback.estimateConfidence(userInput);

  @override
  Future<String> generateFeedback({
    required String sessionType,
    required String userInput,
    required String avatarStyle,
    required String voiceProfile,
    String? emotion,
    int? stepIndex,
  }) async {
    final result = await generateFeedbackDetailed(
      sessionType: sessionType,
      userInput: userInput,
      avatarStyle: avatarStyle,
      voiceProfile: voiceProfile,
      emotion: emotion,
      stepIndex: stepIndex,
    );
    return result.feedback;
  }

  Future<CoachFeedbackResult> generateFeedbackDetailed({
    required String sessionType,
    required String userInput,
    required String avatarStyle,
    required String voiceProfile,
    String? emotion,
    int? stepIndex,
  }) async {
    try {
      final response = await _api.postJson('/ai/coach', {
        'sessionType': sessionType,
        'userInput': userInput,
        'avatarStyle': avatarStyle,
        'voiceProfile': voiceProfile,
        if (emotion != null) 'emotion': emotion,
        if (stepIndex != null) 'stepIndex': stepIndex,
      });
      final assessmentJson = response['assessment'] as Map<String, dynamic>?;
      final provider = (response['provider'] as String?) ?? '';
      final coachHint = (response['coachHint'] as String?) ?? '';
      final feedback = (response['feedback'] as String?) ?? 'No feedback available.';
      if (!CoachFeedbackResult.isLiveProvider(provider)) {
        debugPrint(
          'ApiCoachEngine: fallback provider=$provider hint=$coachHint',
        );
      }
      return CoachFeedbackResult(
        feedback: feedback,
        emotion: (response['emotion'] as String?) ?? detectEmotion(userInput),
        confidence: (response['confidenceScore'] as num?)?.toInt() ??
            estimateConfidence(userInput),
        assessment: assessmentJson != null
            ? CoachingAssessment.fromJson(assessmentJson)
            : null,
        provider: provider,
        coachHint: coachHint,
      );
    } catch (e, st) {
      debugPrint('ApiCoachEngine: /ai/coach failed ($e)');
      debugPrint('$st');
      throw Exception(_friendlyCoachError(e));
    }
  }

  static String _friendlyCoachError(Object e) {
    final s = e.toString().toLowerCase();
    if (s.contains('401') || s.contains('unauthorized')) {
      return 'Please sign in to use the AI coach.';
    }
    if (s.contains('402') || s.contains('session_limit') || s.contains('session limit')) {
      return 'Free session limit reached. Upgrade to Premium to continue.';
    }
    if (s.contains('socketexception') ||
        s.contains('failed host lookup') ||
        s.contains('network')) {
      return 'No internet connection. Check your network and try again.';
    }
    if (s.contains('timeout')) {
      return 'Coach request timed out. Try again in a moment.';
    }
    return 'AI coach unavailable. Run the app with cloud API enabled and stay signed in.';
  }

  /// Direct call to Intelligence Engine (text).
  Future<CoachingAssessment> analyzeText({
    required String text,
    String sessionType = 'Conversation',
    String? context,
  }) async {
    final response = await _api.postJson('/ai/analyze-text', {
      'text': text,
      'sessionType': sessionType,
      if (context != null) 'context': context,
    });
    return CoachingAssessment.fromJson(response);
  }

  /// Speech path: client sends STT transcript + optional duration.
  Future<CoachingAssessment> analyzeSpeech({
    required String transcript,
    String sessionType = 'Conversation',
    double? durationSec,
  }) async {
    final response = await _api.postJson('/ai/analyze-speech', {
      'transcript': transcript,
      'sessionType': sessionType,
      if (durationSec != null) 'durationSec': durationSec,
    });
    return CoachingAssessment.fromJson(response);
  }
}
