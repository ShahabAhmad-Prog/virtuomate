import 'package:flutter_test/flutter_test.dart';
import 'package:virtuomate_flutter/core/coaching_assessment.dart';

void main() {
  test('fromJson maps snake_case API fields', () {
    final a = CoachingAssessment.fromJson({
      'confidence_score': 76,
      'clarity_score': 85,
      'professionalism_score': 80,
      'anxiety_score': 30,
      'communication_score': 83,
      'interview_readiness_score': 78,
      'emotion': 'confident',
      'strengths': ['Clear structure'],
      'weaknesses': ['Add metrics'],
      'recommendations': ['Use STAR format'],
      'provider': 'linguistic-local',
    });
    expect(a.confidenceScore, 76);
    expect(a.clarityScore, 85);
    expect(a.emotion, 'confident');
    expect(a.strengths, ['Clear structure']);
    expect(a.provider, 'linguistic-local');
  });

  test('fromJson handles camelCase', () {
    final a = CoachingAssessment.fromJson({
      'confidenceScore': 50,
      'clarityScore': 60,
      'professionalismScore': 55,
      'anxietyScore': 40,
      'communicationScore': 58,
      'interviewReadinessScore': 52,
      'emotion': 'neutral',
    });
    expect(a.confidenceScore, 50);
    expect(a.communicationScore, 58);
  });

  test('empty json returns zeroed assessment', () {
    final a = CoachingAssessment.fromJson(null);
    expect(a.confidenceScore, 0);
    expect(a.strengths, isEmpty);
  });
}
