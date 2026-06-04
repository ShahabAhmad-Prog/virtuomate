import 'package:virtuomate_flutter/core/coaching_assessment.dart';

class UserProfile {
  UserProfile({
    required this.email,
    this.displayName = '',
    this.phone = '',
    this.isPremium = false,
  });

  final String email;
  final String displayName;
  final String phone;
  final bool isPremium;

  UserProfile copyWith({
    String? email,
    String? displayName,
    String? phone,
    bool? isPremium,
  }) {
    return UserProfile(
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      phone: phone ?? this.phone,
      isPremium: isPremium ?? this.isPremium,
    );
  }
}

class SessionRecord {
  SessionRecord({
    required this.type,
    required this.prompt,
    required this.feedback,
    this.emotion = 'Neutral',
    this.confidenceScore = 0,
    this.assessment,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  final String type;
  final String prompt;
  final String feedback;
  final String emotion;
  final int confidenceScore;
  final CoachingAssessment? assessment;
  final DateTime createdAt;
}

class AnalyticsSnapshot {
  const AnalyticsSnapshot({
    required this.conversationSessions,
    required this.rolePlaySessions,
    required this.interviewSessions,
    required this.presentationSessions,
    required this.videoCvGenerated,
    this.avgConfidence = 72,
    this.avgSentiment = 75,
    this.avgEngagement = 88,
    this.progressPercent = 65,
  });

  final int conversationSessions;
  final int rolePlaySessions;
  final int interviewSessions;
  final int presentationSessions;
  final int videoCvGenerated;
  final int avgConfidence;
  final int avgSentiment;
  final int avgEngagement;
  final int progressPercent;
}

class VideoCvDraft {
  VideoCvDraft({
    this.fullName = '',
    this.headline = '',
    this.summary = '',
    this.email = '',
    this.phone = '',
    this.skills = '',
    this.experience = '',
    this.education = '',
    this.narrationScript = '',
    this.exportFormat = 'mp4',
    this.renderVideoUrl = '',
    this.durationMinutes = 2,
    this.durationSeconds = 10,
  });

  final String fullName;
  final String headline;
  final String summary;
  final String email;
  final String phone;
  final String skills;
  final String experience;
  final String education;
  final String narrationScript;
  final String exportFormat;
  final String renderVideoUrl;
  final int durationMinutes;
  final int durationSeconds;

  VideoCvDraft copyWith({
    String? fullName,
    String? headline,
    String? summary,
    String? email,
    String? phone,
    String? skills,
    String? experience,
    String? education,
    String? narrationScript,
    String? exportFormat,
    String? renderVideoUrl,
    int? durationMinutes,
    int? durationSeconds,
  }) {
    return VideoCvDraft(
      fullName: fullName ?? this.fullName,
      headline: headline ?? this.headline,
      summary: summary ?? this.summary,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      skills: skills ?? this.skills,
      experience: experience ?? this.experience,
      education: education ?? this.education,
      narrationScript: narrationScript ?? this.narrationScript,
      exportFormat: exportFormat ?? this.exportFormat,
      renderVideoUrl: renderVideoUrl ?? this.renderVideoUrl,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      durationSeconds: durationSeconds ?? this.durationSeconds,
    );
  }
}

/// Interview simulation step content.
class InterviewStep {
  const InterviewStep({
    required this.phase,
    required this.question,
    required this.tips,
  });

  final String phase;
  final String question;
  final List<String> tips;
}

/// User settings synced to Firestore/API and cached locally.
class AppPreferences {
  const AppPreferences({
    this.emailNotifications = true,
    this.pushNotifications = true,
    this.sessionReminders = true,
    this.achievementAlerts = true,
    this.languageCode = 'en',
    this.textScale = 1.0,
    this.highContrast = false,
    this.unlockedAchievementIds = const [],
  });

  final bool emailNotifications;
  final bool pushNotifications;
  final bool sessionReminders;
  final bool achievementAlerts;
  final String languageCode;
  final double textScale;
  final bool highContrast;
  final List<String> unlockedAchievementIds;

  AppPreferences copyWith({
    bool? emailNotifications,
    bool? pushNotifications,
    bool? sessionReminders,
    bool? achievementAlerts,
    String? languageCode,
    double? textScale,
    bool? highContrast,
    List<String>? unlockedAchievementIds,
  }) {
    return AppPreferences(
      emailNotifications: emailNotifications ?? this.emailNotifications,
      pushNotifications: pushNotifications ?? this.pushNotifications,
      sessionReminders: sessionReminders ?? this.sessionReminders,
      achievementAlerts: achievementAlerts ?? this.achievementAlerts,
      languageCode: languageCode ?? this.languageCode,
      textScale: textScale ?? this.textScale,
      highContrast: highContrast ?? this.highContrast,
      unlockedAchievementIds:
          unlockedAchievementIds ?? this.unlockedAchievementIds,
    );
  }

  Map<String, dynamic> toJson() => {
    'emailNotifications': emailNotifications,
    'pushNotifications': pushNotifications,
    'sessionReminders': sessionReminders,
    'achievementAlerts': achievementAlerts,
    'languageCode': languageCode,
    'textScale': textScale,
    'highContrast': highContrast,
    'unlockedAchievementIds': unlockedAchievementIds,
  };

  static AppPreferences fromJson(Map<String, dynamic>? json) {
    if (json == null) return const AppPreferences();
    final rawIds = json['unlockedAchievementIds'];
    final ids = rawIds is List
        ? rawIds.map((e) => e.toString()).where((e) => e.isNotEmpty).toList()
        : <String>[];
    return AppPreferences(
      emailNotifications: json['emailNotifications'] as bool? ?? true,
      pushNotifications: json['pushNotifications'] as bool? ?? true,
      sessionReminders: json['sessionReminders'] as bool? ?? true,
      achievementAlerts: json['achievementAlerts'] as bool? ?? true,
      languageCode: json['languageCode'] as String? ?? 'en',
      textScale: (json['textScale'] as num?)?.toDouble() ?? 1.0,
      highContrast: json['highContrast'] as bool? ?? false,
      unlockedAchievementIds: ids,
    );
  }
}

const kInterviewSteps = [
  InterviewStep(
    phase: 'Introduction',
    question: 'Tell me about yourself and your professional background.',
    tips: [
      'Keep it concise (2-3 minutes)',
      'Focus on relevant experience',
      "End with why you're interested in this role",
    ],
  ),
  InterviewStep(
    phase: 'Experience',
    question: 'Describe a challenging project and how you handled it.',
    tips: [
      'Use the STAR method (Situation, Task, Action, Result)',
      'Quantify your impact where possible',
      'Highlight collaboration and problem-solving',
    ],
  ),
  InterviewStep(
    phase: 'Closing',
    question: 'Why do you want to join our team, and what questions do you have for us?',
    tips: [
      'Connect your goals to the role',
      'Ask thoughtful questions about team and growth',
      'Express enthusiasm without overselling',
    ],
  ),
];
