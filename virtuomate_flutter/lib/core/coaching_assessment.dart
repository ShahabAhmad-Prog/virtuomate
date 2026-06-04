/// Multi-dimensional coaching assessment from VirtuoMate Intelligence Engine.
class CoachingAssessment {
  CoachingAssessment({
    required this.confidenceScore,
    required this.clarityScore,
    required this.professionalismScore,
    required this.anxietyScore,
    required this.communicationScore,
    required this.interviewReadinessScore,
    required this.emotion,
    this.avatarExpression = '',
    required this.strengths,
    required this.weaknesses,
    required this.recommendations,
    this.provider = 'linguistic',
    this.transcript = '',
    this.speakingPaceWpm,
    this.pauseFrequency,
  });

  final int confidenceScore;
  final int clarityScore;
  final int professionalismScore;
  final int anxietyScore;
  final int communicationScore;
  final int interviewReadinessScore;
  final String emotion;
  final String avatarExpression;
  final List<String> strengths;
  final List<String> weaknesses;
  final List<String> recommendations;
  final String provider;
  final String transcript;
  final double? speakingPaceWpm;
  final double? pauseFrequency;

  factory CoachingAssessment.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return CoachingAssessment.empty();
    }
    return CoachingAssessment(
      confidenceScore: _int(json['confidence_score'] ?? json['confidenceScore']),
      clarityScore: _int(json['clarity_score'] ?? json['clarityScore']),
      professionalismScore: _int(json['professionalism_score'] ?? json['professionalismScore']),
      anxietyScore: _int(json['anxiety_score'] ?? json['anxietyScore']),
      communicationScore: _int(json['communication_score'] ?? json['communicationScore']),
      interviewReadinessScore: _int(
        json['interview_readiness_score'] ?? json['interviewReadinessScore'],
      ),
      emotion: (json['emotion'] as String?) ?? 'neutral',
      avatarExpression: (json['avatar_expression'] as String?) ??
          (json['avatarExpression'] as String?) ??
          '',
      strengths: _list(json['strengths']),
      weaknesses: _list(json['weaknesses']),
      recommendations: _list(json['recommendations']),
      provider: (json['provider'] as String?) ?? 'linguistic',
      transcript: (json['transcript'] as String?) ?? '',
      speakingPaceWpm: (json['speaking_pace_wpm'] as num?)?.toDouble(),
      pauseFrequency: (json['pause_frequency'] as num?)?.toDouble(),
    );
  }

  factory CoachingAssessment.empty() {
    return CoachingAssessment(
      confidenceScore: 0,
      clarityScore: 0,
      professionalismScore: 0,
      anxietyScore: 0,
      communicationScore: 0,
      interviewReadinessScore: 0,
      emotion: 'neutral',
      avatarExpression: '',
      strengths: const [],
      weaknesses: const [],
      recommendations: const [],
    );
  }

  Map<String, dynamic> toJson() => {
        'confidence_score': confidenceScore,
        'clarity_score': clarityScore,
        'professionalism_score': professionalismScore,
        'anxiety_score': anxietyScore,
        'communication_score': communicationScore,
        'interview_readiness_score': interviewReadinessScore,
        'emotion': emotion,
        if (avatarExpression.isNotEmpty) 'avatar_expression': avatarExpression,
        'strengths': strengths,
        'weaknesses': weaknesses,
        'recommendations': recommendations,
        'provider': provider,
        if (transcript.isNotEmpty) 'transcript': transcript,
        if (speakingPaceWpm != null) 'speaking_pace_wpm': speakingPaceWpm,
        if (pauseFrequency != null) 'pause_frequency': pauseFrequency,
      };

  static int _int(dynamic v) => (v as num?)?.round() ?? 0;

  static List<String> _list(dynamic v) {
    if (v is List) return v.map((e) => e.toString()).toList();
    return const [];
  }
}
