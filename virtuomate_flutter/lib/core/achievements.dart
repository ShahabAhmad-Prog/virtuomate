import 'package:flutter/material.dart';

enum AchievementCategory {
  gettingStarted,
  sessions,
  mastery,
  premium,
}

/// User stats used to evaluate task-based achievements.
class UserAchievementStats {
  const UserAchievementStats({
    required this.totalSessions,
    required this.conversationSessions,
    required this.rolePlaySessions,
    required this.interviewSessions,
    required this.presentationSessions,
    required this.voiceSessions,
    required this.videoCvCount,
    required this.maxConfidence,
    required this.missionProgress,
    required this.isPremium,
    required this.hasAvatarImage,
  });

  final int totalSessions;
  final int conversationSessions;
  final int rolePlaySessions;
  final int interviewSessions;
  final int presentationSessions;
  final int voiceSessions;
  final int videoCvCount;
  final int maxConfidence;
  final int missionProgress;
  final bool isPremium;
  final bool hasAvatarImage;
}

class AchievementDefinition {
  const AchievementDefinition({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.icon,
    required this.target,
    required this.progressOf,
    this.accent = const Color(0xFF3BE7FF),
  });

  final String id;
  final String title;
  final String description;
  final AchievementCategory category;
  final IconData icon;
  final int target;
  final int Function(UserAchievementStats stats) progressOf;
  final Color accent;
}

class AchievementStatus {
  const AchievementStatus({
    required this.definition,
    required this.unlocked,
    required this.current,
    required this.target,
  });

  final AchievementDefinition definition;
  final bool unlocked;
  final int current;
  final int target;

  double get progressFraction =>
      target <= 0 ? 1.0 : (current / target).clamp(0.0, 1.0);

  String get progressLabel => unlocked
      ? 'Completed'
      : target <= 1
          ? (current >= target ? 'Ready' : 'Not started')
          : '$current / $target';
}

final kAllAchievements = <AchievementDefinition>[
  AchievementDefinition(
    id: 'first_session',
    title: 'First Steps',
    description: 'Complete your first AI coaching session.',
    category: AchievementCategory.gettingStarted,
    icon: Icons.flag_outlined,
    target: 1,
    progressOf: (s) => s.totalSessions,
    accent: Color(0xFF3BE7FF),
  ),
  AchievementDefinition(
    id: 'conversation_starter',
    title: 'Conversation Starter',
    description: 'Finish a text conversation with your AI coach.',
    category: AchievementCategory.gettingStarted,
    icon: Icons.chat_bubble_outline,
    target: 1,
    progressOf: (s) => s.conversationSessions,
  ),
  AchievementDefinition(
    id: 'voice_pioneer',
    title: 'Voice Pioneer',
    description: 'Complete a live voice coaching turn.',
    category: AchievementCategory.gettingStarted,
    icon: Icons.mic_outlined,
    target: 1,
    progressOf: (s) => s.voiceSessions,
    accent: Color(0xFF8B5CF6),
  ),
  AchievementDefinition(
    id: 'avatar_creator',
    title: 'Avatar Creator',
    description: 'Upload or save a custom AI coach avatar.',
    category: AchievementCategory.gettingStarted,
    icon: Icons.face_retouching_natural_outlined,
    target: 1,
    progressOf: (s) => s.hasAvatarImage ? 1 : 0,
    accent: Color(0xFFE879F9),
  ),
  AchievementDefinition(
    id: 'role_player',
    title: 'Role Player',
    description: 'Complete a role-play simulation.',
    category: AchievementCategory.sessions,
    icon: Icons.groups_outlined,
    target: 1,
    progressOf: (s) => s.rolePlaySessions,
  ),
  AchievementDefinition(
    id: 'interview_rookie',
    title: 'Interview Rookie',
    description: 'Submit an answer in interview simulation.',
    category: AchievementCategory.sessions,
    icon: Icons.work_outline,
    target: 1,
    progressOf: (s) => s.interviewSessions,
  ),
  AchievementDefinition(
    id: 'stage_presence',
    title: 'Stage Presence',
    description: 'Practice at least one presentation slide.',
    category: AchievementCategory.sessions,
    icon: Icons.slideshow_outlined,
    target: 1,
    progressOf: (s) => s.presentationSessions,
  ),
  AchievementDefinition(
    id: 'session_five',
    title: 'Consistent Learner',
    description: 'Complete 5 coaching sessions.',
    category: AchievementCategory.sessions,
    icon: Icons.auto_graph_outlined,
    target: 5,
    progressOf: (s) => s.totalSessions,
  ),
  AchievementDefinition(
    id: 'session_ten',
    title: 'Session Veteran',
    description: 'Complete 10 coaching sessions.',
    category: AchievementCategory.sessions,
    icon: Icons.military_tech_outlined,
    target: 10,
    progressOf: (s) => s.totalSessions,
    accent: Color(0xFFFBBF24),
  ),
  AchievementDefinition(
    id: 'confidence_70',
    title: 'Confidence Boost',
    description: 'Reach 70% clarity on any session.',
    category: AchievementCategory.mastery,
    icon: Icons.trending_up,
    target: 70,
    progressOf: (s) => s.maxConfidence,
    accent: Color(0xFF22C55E),
  ),
  AchievementDefinition(
    id: 'confidence_85',
    title: 'Clarity Master',
    description: 'Reach 85% clarity on any session.',
    category: AchievementCategory.mastery,
    icon: Icons.emoji_events_outlined,
    target: 85,
    progressOf: (s) => s.maxConfidence,
    accent: Color(0xFFFBBF24),
  ),
  AchievementDefinition(
    id: 'mission_complete',
    title: 'Interview Graduate',
    description: 'Complete the full interview mission (100%).',
    category: AchievementCategory.mastery,
    icon: Icons.school_outlined,
    target: 100,
    progressOf: (s) => s.missionProgress,
    accent: Color(0xFF8B5CF6),
  ),
  AchievementDefinition(
    id: 'avatar_selfie',
    title: 'Avatar Portrait',
    description: 'Create or upload your coach / Video CV portrait.',
    category: AchievementCategory.mastery,
    icon: Icons.face_retouching_natural_outlined,
    target: 1,
    progressOf: (s) => s.hasAvatarImage ? 1 : 0,
    accent: Color(0xFFE879F9),
  ),
  AchievementDefinition(
    id: 'video_cv',
    title: 'Video CV Pro',
    description: 'Generate an AI Video CV.',
    category: AchievementCategory.mastery,
    icon: Icons.videocam_outlined,
    target: 1,
    progressOf: (s) => s.videoCvCount,
  ),
  AchievementDefinition(
    id: 'premium_member',
    title: 'Premium Member',
    description: 'Activate VirtuoMate Premium.',
    category: AchievementCategory.premium,
    icon: Icons.diamond_outlined,
    target: 1,
    progressOf: (s) => s.isPremium ? 1 : 0,
    accent: Color(0xFF22C55E),
  ),
];

String categoryLabel(AchievementCategory category) {
  switch (category) {
    case AchievementCategory.gettingStarted:
      return 'Getting started';
    case AchievementCategory.sessions:
      return 'Sessions';
    case AchievementCategory.mastery:
      return 'Mastery';
    case AchievementCategory.premium:
      return 'Premium';
  }
}

List<AchievementStatus> buildAchievementStatuses({
  required UserAchievementStats stats,
  required Set<String> unlockedIds,
}) {
  return [
    for (final def in kAllAchievements)
      () {
        final current = def.progressOf(stats).clamp(0, def.target);
        final earned = current >= def.target;
        return AchievementStatus(
          definition: def,
          unlocked: unlockedIds.contains(def.id) || earned,
          current: current,
          target: def.target,
        );
      }(),
  ];
}

List<AchievementDefinition> newlyEarnedAchievements({
  required UserAchievementStats stats,
  required Set<String> previouslyUnlocked,
}) {
  final fresh = <AchievementDefinition>[];
  for (final def in kAllAchievements) {
    if (previouslyUnlocked.contains(def.id)) continue;
    final current = def.progressOf(stats);
    if (current >= def.target) fresh.add(def);
  }
  return fresh;
}
