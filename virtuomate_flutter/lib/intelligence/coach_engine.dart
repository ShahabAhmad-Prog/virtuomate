abstract class CoachEngine {
  Future<String> generateFeedback({
    required String sessionType,
    required String userInput,
    required String avatarStyle,
    required String voiceProfile,
    String? emotion,
    int? stepIndex,
  });

  String detectEmotion(String userInput);
  int estimateConfidence(String userInput);
}

class MockCoachEngine implements CoachEngine {
  @override
  String detectEmotion(String userInput) {
    final t = userInput.toLowerCase();
    if (t.contains('nervous') || t.contains('anxious') || t.contains('worried')) {
      return 'Anxious';
    }
    if (t.contains('excited') || t.contains('happy') || t.contains('great')) {
      return 'Happy';
    }
    if (t.contains('frustrated') || t.contains('difficult') || t.contains('hard')) {
      return 'Concerned';
    }
    if (userInput.trim().length < 20) return 'Neutral';
    if (userInput.trim().length > 120) return 'Confident';
    return 'Focused';
  }

  @override
  int estimateConfidence(String userInput) {
    final words = userInput.trim().split(RegExp(r'\s+')).where((w) => w.isNotEmpty);
    final count = words.length;
    if (count == 0) return 35;
    var score = 50 + (count * 2).clamp(0, 30);
    final lower = userInput.toLowerCase();
    if (lower.contains('i led') || lower.contains('i achieved')) score += 8;
    if (lower.contains('um') || lower.contains('uh')) score -= 10;
    if (lower.contains('maybe') || lower.contains('i think')) score -= 5;
    return score.clamp(35, 95);
  }

  @override
  Future<String> generateFeedback({
    required String sessionType,
    required String userInput,
    required String avatarStyle,
    required String voiceProfile,
    String? emotion,
    int? stepIndex,
  }) async {
    final detected = emotion ?? detectEmotion(userInput);
    final confidence = estimateConfidence(userInput);
    final trimmed = userInput.trim();

    if (trimmed.isEmpty) {
      return _emptyPromptFeedback(sessionType, avatarStyle);
    }

    if (sessionType.contains('Interview')) {
      return _interviewFeedback(trimmed, detected, confidence, stepIndex ?? 0);
    }
    if (sessionType.contains('Presentation')) {
      return _presentationFeedback(trimmed, detected, confidence);
    }
    if (sessionType.contains('Role Play')) {
      return _rolePlayFeedback(trimmed, detected, confidence, avatarStyle);
    }
    if (sessionType.contains('Voice')) {
      return _voiceFeedback(trimmed, detected, confidence, voiceProfile);
    }

    return _conversationFeedback(trimmed, detected, confidence, avatarStyle);
  }

  String _emptyPromptFeedback(String sessionType, String style) {
    return '$sessionType: Share a specific example so your $style coach can give targeted feedback. '
        'Try describing one situation, what you did, and the outcome.';
  }

  String _interviewFeedback(String input, String emotion, int confidence, int step) {
    final steps = ['introduction', 'experience', 'closing'];
    final phase = step < steps.length ? steps[step] : 'interview';
    if (confidence < 55) {
      return 'Interview ($phase) • Detected $emotion tone at $confidence% confidence. '
          'Structure your answer with a clear opening, one concrete example, and a confident close. '
          'Practice speaking in shorter sentences to reduce filler words.';
    }
    return 'Interview ($phase) • Strong delivery at $confidence% confidence ($emotion detected). '
        'Your response shows good substance — add one measurable result to make it even more compelling. '
        'Maintain eye contact and pause briefly before your closing statement.';
  }

  String _presentationFeedback(String input, String emotion, int confidence) {
    return 'Presentation practice • Audience sentiment: engaged ($emotion). '
        'Confidence score: $confidence%. '
        '${confidence >= 70 ? 'Excellent pacing and clarity. Vary your tone on key points.' : 'Slow down slightly and emphasize your opening hook. Use shorter sentences for clarity.'}';
  }

  String _rolePlayFeedback(String input, String emotion, int confidence, String style) {
    return 'Role-play [$style] • $emotion emotional cue • $confidence% clarity. '
        'Reframe your main point with assertive language ("I recommend…" vs "I think…"). '
        'Acknowledge the other party\'s concern before presenting your solution.';
  }

  String _voiceFeedback(String input, String emotion, int confidence, String voice) {
    return 'Voice session [$voice] • $emotion • $confidence% neural clarity. '
        '${input.length > 80 ? 'Good detail in your response.' : 'Expand with one specific example.'} '
        'Your coach adapts tone to support confident, natural delivery.';
  }

  String _conversationFeedback(String input, String emotion, int confidence, String style) {
    final lower = input.toLowerCase();
    if (lower.contains('interview') || lower.contains('rscs') || lower.contains('job')) {
      final org = lower.contains('rscs') ? 'RSCS' : 'your target company';
      return 'Interview prep ($org) • $emotion tone, $confidence% clarity.\n\n'
          '1) Research the company and role requirements.\n'
          '2) Prepare a 60-second introduction.\n'
          '3) Practice STAR answers for behavioral questions.\n'
          '4) Prepare 3 questions to ask the interviewer.\n'
          '5) Rehearse aloud and cut filler words.\n\n'
          '${input.length < 40 ? 'Share the job title for tailored practice questions.' : 'Add one achievement with numbers for a stronger answer.'}';
    }
    return 'AI Coach [$style] • Emotion: $emotion • Confidence: $confidence%.\n\n'
        '${confidence >= 70 ? 'Well-structured message.' : 'Add a concrete example and quantify your impact.'} '
        'Share your goal (interview, presentation, role-play) for step-by-step coaching.';
  }
}
