import 'package:virtuomate_flutter/config/demo_account_config.dart';
import 'package:virtuomate_flutter/core/achievements.dart';
import 'package:virtuomate_flutter/core/avatar_customization.dart';
import 'package:virtuomate_flutter/core/models.dart';
import 'package:virtuomate_flutter/core/voice_profile_codec.dart';
import 'package:virtuomate_flutter/auth/auth_gateway.dart';
import 'package:virtuomate_flutter/data/app_repository.dart';
import 'package:virtuomate_flutter/external/subscription_gateway.dart';
import 'package:virtuomate_flutter/external/subscription_result.dart';
import 'package:virtuomate_flutter/data/api_app_repository.dart';
import 'package:virtuomate_flutter/data/firebase_app_repository.dart';
import 'package:virtuomate_flutter/core/coaching_assessment.dart';
import 'package:virtuomate_flutter/core/neural_connectivity.dart';
import 'package:virtuomate_flutter/intelligence/api_coach_engine.dart';
import 'package:virtuomate_flutter/intelligence/coach_engine.dart';
import 'package:virtuomate_flutter/services/neural_connectivity_service.dart';

class AppService {
  AppService({
    required AuthGateway authGateway,
    required AppRepository repository,
    required CoachEngine coachEngine,
    required SubscriptionGateway subscriptionGateway,
    NeuralConnectivityService? neuralConnectivity,
    NeuralConnectivityStatus? initialNeuralStatus,
  }) : _authGateway = authGateway,
       _repository = repository,
       _coachEngine = coachEngine,
       _subscriptionGateway = subscriptionGateway,
       _neuralConnectivity = neuralConnectivity,
       _neuralStatus = initialNeuralStatus ??
           (neuralConnectivity != null
               ? NeuralConnectivityStatus.offline
               : NeuralConnectivityStatus.localMode());

  final AuthGateway _authGateway;
  final AppRepository _repository;
  final CoachEngine _coachEngine;
  final SubscriptionGateway _subscriptionGateway;
  final NeuralConnectivityService? _neuralConnectivity;
  NeuralConnectivityStatus _neuralStatus;
  String lastCoachProvider = '';
  String lastCoachHint = '';

  NeuralConnectivityStatus get neuralConnectivity => _neuralStatus;

  void setNeuralConnectivity(NeuralConnectivityStatus status) {
    _neuralStatus = status;
  }

  Future<NeuralConnectivityStatus> refreshNeuralConnectivity() async {
    if (_neuralConnectivity == null) {
      _neuralStatus = NeuralConnectivityStatus.localMode();
      return _neuralStatus;
    }
    _neuralStatus = await _neuralConnectivity!.fetchStatus();
    return _neuralStatus;
  }

  static const int freeSessionLimit = 20;

  final List<AchievementDefinition> _pendingAchievementUnlocks = [];

  UserProfile? currentUser() {
    final authUser = _authGateway.currentUser();
    final repoUser = _repository.currentUser();
    if (authUser == null && repoUser == null) return null;
    if (repoUser == null) return authUser;
    if (authUser == null) return repoUser;
    return authUser.copyWith(
      displayName: repoUser.displayName.isNotEmpty ? repoUser.displayName : authUser.displayName,
      phone: repoUser.phone.isNotEmpty ? repoUser.phone : authUser.phone,
      isPremium: _repository.isPremium(),
    );
  }
  String currentAvatarStyle() => _repository.avatarStyle();
  String currentAvatarImage() => _repository.avatarImage();
  bool currentAvatarUseTemplate() => _repository.avatarUseTemplate();
  String currentAvatarEmotionState() => _repository.avatarEmotionState();
  String currentVoiceProfile() => _repository.voiceProfile();
  String currentVoiceGender() => _repository.voiceGender();
  String displayName() {
    final n = _repository.displayName();
    if (n.isNotEmpty) return n;
    final email = currentUser()?.email ?? '';
    final i = email.indexOf('@');
    return i > 0 ? email.substring(0, i) : 'Guest';
  }

  String phone() => _repository.phone();
  VideoCvDraft videoCvDraft() => _repository.videoCvDraft();
  int missionProgress() => _repository.missionProgressPercent();

  Future<void> signInWithGoogle() async {
    final user = await _authGateway.signInWithGoogle();
    _repository.saveCurrentUser(user);
    if (user.displayName.isNotEmpty) {
      _repository.saveDisplayName(user.displayName);
    }
  }

  Future<void> signInWithEmail({
    required String email,
    required String password,
  }) async {
    final user = await _authGateway.signInWithEmail(
      email: email.trim(),
      password: password,
    );
    _repository.saveCurrentUser(user);
    if (user.displayName.isNotEmpty) {
      _repository.saveDisplayName(user.displayName);
    }
  }

  Future<void> registerWithEmail({
    required String email,
    required String password,
    String displayName = '',
  }) async {
    final user = await _authGateway.registerWithEmail(
      email: email.trim(),
      password: password,
      displayName: displayName,
    );
    _repository.saveCurrentUser(user);
    final name = displayName.isNotEmpty
        ? displayName
        : (user.displayName.isNotEmpty ? user.displayName : '');
    if (name.isNotEmpty) {
      _repository.saveDisplayName(name);
    }
  }

  Future<void> signInDemo() async {
    final user = await _authGateway.signInDemo();
    _repository.saveCurrentUser(user);
    _repository.saveDisplayName(
      user.displayName.isNotEmpty
          ? user.displayName
          : DemoAccountConfig.displayName,
    );
  }

  void logout() {
    _repository.setPremium(false);
    _repository.saveCurrentUser(null);
    _authGateway.signOut();
  }

  void saveProfile({String? displayName, String? phone}) {
    if (displayName != null) _repository.saveDisplayName(displayName);
    if (phone != null) _repository.savePhone(phone);
    final user = _repository.currentUser();
    if (user != null) {
      _repository.saveCurrentUser(
        user.copyWith(
          displayName: displayName ?? user.displayName,
          phone: phone ?? user.phone,
        ),
      );
    }
  }

  void saveAvatar({required String style}) {
    _repository.saveAvatarStyle(style);
    syncAchievements();
  }

  void saveAvatarImage({required String imagePathOrUrl}) {
    _repository.saveAvatarImage(imagePathOrUrl);
    syncAchievements();
  }

  void saveAvatarUseTemplate({required bool value}) {
    _repository.saveAvatarUseTemplate(value);
    syncAchievements();
  }

  void saveAvatarEmotionState(String state) {
    _repository.saveAvatarEmotionState(state);
  }
  void saveVoiceProfile({required String voiceProfile}) =>
      _repository.saveVoiceProfile(voiceProfile);
  void saveVoiceGender({required String voiceGender}) =>
      _repository.saveVoiceGender(voiceGender);
  void saveVideoCvDraft(VideoCvDraft draft) => _repository.saveVideoCvDraft(draft);

  String suggestVoiceProfileForStyle(String style) =>
      defaultToneForPersona(style);

  bool isPremiumUser() => _repository.isPremium();

  AppPreferences loadPreferences() => _repository.preferences();

  void savePreferences(AppPreferences preferences) =>
      _repository.savePreferences(preferences);

  UserAchievementStats achievementStats() {
    final sessions = _repository.sessions();
    var maxConf = 0;
    for (final s in sessions) {
      if (s.confidenceScore > maxConf) maxConf = s.confidenceScore;
    }
    return UserAchievementStats(
      totalSessions: sessions.length,
      conversationSessions: conversationCount(),
      rolePlaySessions: rolePlayCount(),
      interviewSessions: interviewCount(),
      presentationSessions: presentationCount(),
      voiceSessions: sessions.where((s) => s.type.contains('Voice')).length,
      videoCvCount: videoCvCount(),
      maxConfidence: maxConf,
      missionProgress: missionProgress(),
      isPremium: isPremiumUser(),
      hasAvatarImage: currentAvatarImage().trim().isNotEmpty,
    );
  }

  List<AchievementStatus> achievementStatuses() {
    final unlocked = loadPreferences().unlockedAchievementIds.toSet();
    return buildAchievementStatuses(
      stats: achievementStats(),
      unlockedIds: unlocked,
    );
  }

  int unlockedAchievementCount() =>
      achievementStatuses().where((s) => s.unlocked).length;

  int totalAchievementCount() => kAllAchievements.length;

  /// Re-evaluates tasks and persists any newly earned badges.
  void syncAchievements() {
    final stats = achievementStats();
    final previous = loadPreferences().unlockedAchievementIds.toSet();
    final earned = newlyEarnedAchievements(
      stats: stats,
      previouslyUnlocked: previous,
    );
    if (earned.isEmpty) return;

    final merged = <String>{...previous, ...earned.map((e) => e.id)}.toList();
    savePreferences(
      loadPreferences().copyWith(unlockedAchievementIds: merged),
    );
    if (loadPreferences().achievementAlerts) {
      _pendingAchievementUnlocks.addAll(earned);
    }
  }

  List<AchievementDefinition> consumePendingAchievementUnlocks() {
    if (_pendingAchievementUnlocks.isEmpty) return const [];
    final copy = List<AchievementDefinition>.from(_pendingAchievementUnlocks);
    _pendingAchievementUnlocks.clear();
    return copy;
  }

  /// Live preview via `/ai/analyze-text` (Cloud Run ML) when API mode is on.
  Future<CoachingAssessment?> previewCoachingAssessment({
    required String text,
    String sessionType = 'Interview',
  }) async {
    final trimmed = text.trim();
    if (trimmed.length < 12) return null;

    if (_coachEngine is ApiCoachEngine) {
      try {
        return await (_coachEngine as ApiCoachEngine).analyzeText(
          text: trimmed,
          sessionType: sessionType,
        );
      } catch (_) {
        return null;
      }
    }

    final emotion = _coachEngine.detectEmotion(trimmed);
    final conf = _coachEngine.estimateConfidence(trimmed);
    return CoachingAssessment(
      confidenceScore: conf,
      clarityScore: conf,
      professionalismScore: conf,
      anxietyScore: (100 - conf).clamp(0, 100),
      communicationScore: conf,
      interviewReadinessScore: conf,
      emotion: emotion.toLowerCase(),
      strengths: const [],
      weaknesses: const [],
      recommendations: const [],
      provider: 'local-preview',
    );
  }

  int conversationCount() =>
      _repository.sessions().where((s) => s.type == 'Conversation').length;
  int rolePlayCount() =>
      _repository.sessions().where((s) => s.type.contains('Role Play')).length;
  int interviewCount() =>
      _repository.sessions().where((s) => s.type.contains('Interview')).length;
  int presentationCount() =>
      _repository.sessions().where((s) => s.type.contains('Presentation')).length;
  int videoCvCount() => _repository.videoCvCount();

  /// Matches backend: POST /sessions limits total saved sessions per user (not per type).
  int totalSessionCount() => _repository.sessions().length;

  bool canRunConversation() => isPremiumUser() || totalSessionCount() < freeSessionLimit;
  bool canRunRolePlay() => isPremiumUser() || totalSessionCount() < freeSessionLimit;
  bool canRunInterview() => isPremiumUser() || totalSessionCount() < freeSessionLimit;
  bool canRunPresentation() => isPremiumUser() || totalSessionCount() < freeSessionLimit;
  bool canGenerateVideoCv() => isPremiumUser() || videoCvCount() < 2;

  String sessionLimitMessage(String module) =>
      'Free tier limit reached for $module. Upgrade to Premium for unlimited access.';

  Future<SessionRecord> _completeSession({
    required String type,
    required String prompt,
    String? emotionOverride,
    int? stepIndex,
  }) async {
    var emotion = emotionOverride ?? _coachEngine.detectEmotion(prompt);
    var confidence = _coachEngine.estimateConfidence(prompt);
    String feedback;
    CoachingAssessment? assessment;

    if (_coachEngine is ApiCoachEngine) {
      final apiCoach = _coachEngine;
      final result = await apiCoach.generateFeedbackDetailed(
        sessionType: type,
        userInput: prompt,
        avatarStyle: currentAvatarStyle(),
        voiceProfile: currentVoiceProfile(),
        emotion: emotion,
        stepIndex: stepIndex,
      );
      feedback = result.feedback;
      emotion = result.emotion;
      confidence = result.confidence;
      assessment = result.assessment;
      lastCoachProvider = result.provider;
      lastCoachHint = result.coachHint;
    } else {
      lastCoachProvider = 'local';
      lastCoachHint = '';
      feedback = await _coachEngine.generateFeedback(
        sessionType: type,
        userInput: prompt,
        avatarStyle: currentAvatarStyle(),
        voiceProfile: currentVoiceProfile(),
        emotion: emotion,
        stepIndex: stepIndex,
      );
    }

    final record = SessionRecord(
      type: type,
      prompt: prompt,
      feedback: feedback,
      emotion: emotion,
      confidenceScore: confidence,
      assessment: assessment,
    );
    _repository.saveSession(record);
    final avatarExpression = assessment?.avatarExpression;
    if (avatarExpression != null && avatarExpression.isNotEmpty) {
      _repository.saveAvatarEmotionState(avatarExpression);
    } else if (emotion.isNotEmpty) {
      _repository.saveAvatarEmotionState(emotion.toLowerCase());
    }
    syncAchievements();
    return record;
  }

  Future<SessionRecord> completeConversation({required String prompt}) async {
    if (prompt.trim().isEmpty) {
      throw Exception('Type a message or prompt before sending.');
    }
    if (!canRunConversation()) throw Exception(sessionLimitMessage('sessions'));
    return _completeSession(type: 'Conversation', prompt: prompt.trim());
  }

  Future<SessionRecord> completeRolePlay({
    required String scenario,
    required String prompt,
  }) async {
    if (!canRunRolePlay()) throw Exception(sessionLimitMessage('role-play'));
    return _completeSession(type: 'Role Play ($scenario)', prompt: prompt);
  }

  Future<SessionRecord> completeInterview({
    required int stepIndex,
    required String prompt,
  }) async {
    if (!canRunInterview()) throw Exception(sessionLimitMessage('interview practice'));
    final step = kInterviewSteps[stepIndex.clamp(0, kInterviewSteps.length - 1)];
    final record = await _completeSession(
      type: 'Interview (${step.phase})',
      prompt: prompt,
      stepIndex: stepIndex,
    );
    final progress = ((stepIndex + 1) / kInterviewSteps.length * 100).round();
    _repository.setMissionProgressPercent(progress.clamp(0, 100));
    return record;
  }

  Future<SessionRecord> completePresentation({
    required int slideIndex,
    required int totalSlides,
    required String prompt,
  }) async {
    if (!canRunPresentation()) {
      throw Exception(sessionLimitMessage('presentation practice'));
    }
    return _completeSession(
      type: 'Presentation (Slide ${slideIndex + 1}/$totalSlides)',
      prompt: prompt,
    );
  }

  Future<SessionRecord> completeVoiceTurn({required String prompt}) async {
    if (prompt.trim().isEmpty) {
      throw Exception('Say something or type your message first.');
    }
    if (!canRunConversation()) throw Exception(sessionLimitMessage('sessions'));
    return _completeSession(type: 'Voice Session', prompt: prompt.trim());
  }

  void generateVideoCv() {
    if (!canGenerateVideoCv()) {
      throw Exception(sessionLimitMessage('video CV generation'));
    }
    _repository.incrementVideoCvCount();
    syncAchievements();
  }

  Future<String> buildVideoCvNarrationAsync({
    required String fullName,
    required String headline,
    required String summary,
    required String skills,
    required String experience,
    required String education,
  }) async {
    if (_repository is ApiAppRepository) {
      final script = await _repository.fetchVideoCvScript(
        fullName: fullName,
        headline: headline,
        summary: summary,
        skills: skills,
        experience: experience,
        education: education,
      );
      if (script.isNotEmpty) return script;
    }
    return buildVideoCvNarration(
      fullName: fullName,
      headline: headline,
      summary: summary,
      skills: skills,
      experience: experience,
      education: education,
    );
  }

  String buildVideoCvNarration({
    required String fullName,
    required String headline,
    required String summary,
    required String skills,
    required String experience,
    required String education,
  }) {
    final name = fullName.trim().isEmpty ? 'Candidate' : fullName.trim();
    final h = headline.trim().isEmpty ? 'Professional Profile' : headline.trim();
    final s = summary.trim().isEmpty
        ? 'A motivated and growth-oriented professional.'
        : summary.trim();
    final sk = skills.trim().isEmpty
        ? 'Communication, teamwork, and problem solving.'
        : skills.trim();
    final ex = experience.trim().isEmpty
        ? 'Hands-on project experience with measurable impact.'
        : experience.trim();
    final ed = education.trim().isEmpty
        ? 'Relevant academic background and continuous learning mindset.'
        : education.trim();
    return 'Hello, I am $name. $h. $s. My key skills include $sk. '
        'In terms of experience, $ex. My education includes $ed. '
        'Thank you for reviewing my profile.';
  }

  SessionRecord? _newestSession() {
    final sessions = _repository.sessions();
    if (sessions.isEmpty) return null;
    return sessions.first;
  }

  String latestFeedback() {
    return _newestSession()?.feedback ?? 'No feedback yet.';
  }

  SessionRecord? latestSession() => _newestSession();

  AnalyticsSnapshot analytics() {
    final sessions = _repository.sessions();
    var confidenceSum = 0;
    var sentimentSum = 0;
    var count = 0;
    for (final s in sessions) {
      if (s.confidenceScore > 0) {
        confidenceSum += s.confidenceScore;
        count++;
      }
      sentimentSum += s.emotion == 'Happy' || s.emotion == 'Confident' ? 85 : 70;
    }
    final avgConf = count > 0 ? (confidenceSum / count).round() : 72;
    final avgSent = count > 0 ? (sentimentSum / count).round() : 75;
    return AnalyticsSnapshot(
      conversationSessions: conversationCount(),
      rolePlaySessions: rolePlayCount(),
      interviewSessions: interviewCount(),
      presentationSessions: presentationCount(),
      videoCvGenerated: videoCvCount(),
      avgConfidence: avgConf,
      avgSentiment: avgSent,
      avgEngagement: (avgConf + avgSent) ~/ 2,
      progressPercent: missionProgress(),
    );
  }

  Future<void> bootstrapUserProfile({String? displayName, String? phone}) async {
    if (_repository is ApiAppRepository) {
      await _repository.bootstrap(displayName: displayName, phone: phone);
      await _repository.hydrate();
      _syncAuthUserToRepository();
      syncAchievements();
      return;
    }
    if (_repository is FirebaseAppRepository) {
      if (displayName != null && displayName.isNotEmpty) {
        _repository.saveDisplayName(displayName);
      }
      if (phone != null && phone.isNotEmpty) {
        _repository.savePhone(phone);
      }
      await _repository.hydrate();
      _syncAuthUserToRepository();
      syncAchievements();
    }
  }

  void _syncAuthUserToRepository() {
    if (_repository.currentUser() != null) return;
    final authUser = _authGateway.currentUser();
    if (authUser != null) {
      _repository.saveCurrentUser(authUser);
    }
  }

  List<SessionRecord> sessionHistory() => _repository.sessions();

  Future<PremiumSubscribeOutcome> subscribeToPlan(String planId) async {
    _syncAuthUserToRepository();
    final user = currentUser();
    if (user == null) throw Exception('Please login first.');
    if (_repository.isPremium()) return PremiumSubscribeOutcome.alreadyPremium;

    final outcome = await _subscriptionGateway.activateSubscription(
      userEmail: user.email,
      planId: planId,
    );
    if (outcome == PremiumSubscribeOutcome.failed) {
      throw Exception('Subscription activation failed.');
    }
    if (outcome == PremiumSubscribeOutcome.checkoutOpened) {
      return PremiumSubscribeOutcome.checkoutOpened;
    }

    _repository.setPremium(true);
    syncAchievements();

    if (_repository is ApiAppRepository) {
      await _repository.hydrate();
      if (!_repository.isPremium()) {
        _repository.setPremium(true);
      }
      return PremiumSubscribeOutcome.activated;
    }
    if (_repository is FirebaseAppRepository) {
      _repository.setPremium(true);
      return PremiumSubscribeOutcome.activated;
    }
    _repository.saveCurrentUser(user.copyWith(isPremium: true));
    return PremiumSubscribeOutcome.activated;
  }

  void startRealtimeSync(void Function() onChanged) {
    if (_repository is FirebaseAppRepository) {
      _repository.startRealtimeSync(onChanged);
    }
  }

  void stopRealtimeSync() {
    if (_repository is FirebaseAppRepository) {
      _repository.stopRealtimeSync();
    }
  }

  Future<void> deleteAccount() async {
    if (_repository is FirebaseAppRepository) {
      await _repository.deleteAllUserData();
      await _authGateway.signOut();
      _repository.saveCurrentUser(null);
      return;
    }
    if (_repository is ApiAppRepository) {
      throw Exception('Use API delete from controller callback.');
    }
    _repository.saveCurrentUser(null);
    await _authGateway.signOut();
  }

  Future<void> sendPasswordReset(String email) async {
    await _authGateway.sendPasswordResetEmail(email);
  }

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    if (newPassword.length < 6) {
      throw Exception('New password must be at least 6 characters.');
    }
    await _authGateway.changePassword(
      currentPassword: currentPassword,
      newPassword: newPassword,
    );
  }

  Future<void> togglePremium() async {
    final user = _repository.currentUser();
    if (user == null) throw Exception('Please login first.');
    if (user.isPremium) {
      throw Exception('Premium is managed by your subscription. Use Premium plans to change billing.');
    }
    final outcome = await subscribeToPlan('annual');
    if (outcome == PremiumSubscribeOutcome.failed) {
      throw Exception('Subscription activation failed.');
    }
  }
}
