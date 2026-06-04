import 'dart:io';

import 'package:flutter/material.dart';
import 'package:virtuomate_flutter/config/app_config.dart';
import 'package:virtuomate_flutter/config/demo_account_config.dart';
import 'package:virtuomate_flutter/core/achievements.dart';
import 'package:virtuomate_flutter/core/coaching_assessment.dart';
import 'package:virtuomate_flutter/core/neural_connectivity.dart';
import 'package:virtuomate_flutter/core/models.dart';
import 'package:virtuomate_flutter/core/voice_profile_codec.dart';
import 'package:virtuomate_flutter/external/subscription_result.dart';
import 'package:virtuomate_flutter/services/admin_api_service.dart';
import 'package:virtuomate_flutter/services/app_service.dart';
import 'package:virtuomate_flutter/services/on_device_avatar_stylizer.dart';
import 'package:virtuomate_flutter/services/storage_service.dart';
import 'package:virtuomate_flutter/services/video_cv_export_service.dart';
import 'package:virtuomate_flutter/services/cloud_download_service.dart';
import 'package:virtuomate_flutter/services/video_cv_render_service.dart';

class VirtuoMateController extends ChangeNotifier {
  VirtuoMateController({
    required AppService service,
    this.firebaseAuthReady = false,
    this.bootstrapWarning,
    this.adminApi,
    this.storage,
    this.videoCvRender,
    Future<Map<String, dynamic>> Function()? onExportData,
    Future<bool> Function()? onDeleteAccount,
  }) : _service = service,
       _onExportData = onExportData,
       _onDeleteAccount = onDeleteAccount;

  final AppService _service;
  final bool firebaseAuthReady;
  final String? bootstrapWarning;
  final AdminApiService? adminApi;
  final StorageService? storage;
  final VideoCvRenderService? videoCvRender;
  final Future<Map<String, dynamic>> Function()? _onExportData;
  final Future<bool> Function()? _onDeleteAccount;
  String errorMessage = '';
  Locale _locale = const Locale('en');
  double _textScale = 1.0;
  bool _highContrast = false;

  UserProfile? get user => _service.currentUser();
  bool get isPremium => _service.isPremiumUser();
  String get displayName => _service.displayName();
  String get phone => _service.phone();
  String get avatarStyle => _service.currentAvatarStyle();
  String get avatarImage => _service.currentAvatarImage();
  bool get avatarUseTemplate => _service.currentAvatarUseTemplate();
  String get avatarEmotionState => _service.currentAvatarEmotionState();
  String get voiceProfile => _service.currentVoiceProfile();
  String get voiceGender => _service.currentVoiceGender();

  ResolvedVoiceProfile get resolvedVoice => resolveVoiceProfile(
        voiceProfile,
        fallbackGender: voiceGender,
      );

  String get voiceToneId => resolvedVoice.toneId;
  String get latestFeedback => _service.latestFeedback();
  String get lastCoachProvider => _service.lastCoachProvider;
  String get lastCoachHint => _service.lastCoachHint;
  SessionRecord? get latestSessionRecord => _service.latestSession();
  VideoCvDraft get videoCvDraft => _service.videoCvDraft();
  int get missionProgress => _service.missionProgress();
  List<AchievementStatus> get achievementStatuses => _service.achievementStatuses();
  int get unlockedAchievementCount => _service.unlockedAchievementCount();
  int get totalAchievementCount => _service.totalAchievementCount();

  NeuralConnectivityStatus get neuralConnectivity => _service.neuralConnectivity;
  bool _neuralRefreshInFlight = false;
  bool get neuralRefreshInFlight => _neuralRefreshInFlight;

  Future<void> refreshNeuralConnectivity() async {
    if (_neuralRefreshInFlight) return;
    _neuralRefreshInFlight = true;
    notifyListeners();
    try {
      await _service.refreshNeuralConnectivity();
    } finally {
      _neuralRefreshInFlight = false;
      notifyListeners();
    }
  }

  void syncAchievements() {
    _service.syncAchievements();
    notifyListeners();
  }

  List<AchievementDefinition> drainAchievementUnlocks() {
    final unlocks = _service.consumePendingAchievementUnlocks();
    if (unlocks.isNotEmpty) notifyListeners();
    return unlocks;
  }

  AnalyticsSnapshot get analytics => _service.analytics();
  List<SessionRecord> get sessions => _service.sessionHistory();
  bool get canRunConversation => _service.canRunConversation();
  bool get canRunRolePlay => _service.canRunRolePlay();
  bool get canRunInterview => _service.canRunInterview();
  bool get canRunPresentation => _service.canRunPresentation();
  Locale get locale => _locale;
  double get textScale => _textScale;
  bool get highContrast => _highContrast;
  bool get isAdmin => AppConfig.isAdminEmail(user?.email);

  bool get emailNotifications => _service.loadPreferences().emailNotifications;
  bool get pushNotifications => _service.loadPreferences().pushNotifications;
  bool get sessionReminders => _service.loadPreferences().sessionReminders;
  bool get achievementAlerts => _service.loadPreferences().achievementAlerts;

  Future<bool> signInWithGoogle() async {
    try {
      errorMessage = '';
      await _service.signInWithGoogle();
      await _service.bootstrapUserProfile(
        displayName: _service.displayName().isNotEmpty ? _service.displayName() : null,
      );
      applyStoredPreferences();
      if (!AppConfig.useBackendApi) {
        startRealtimeSync();
      }
      notifyListeners();
      return true;
    } catch (e) {
      errorMessage = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  Future<bool> loginDemo() async {
    try {
      errorMessage = '';
      await _service.signInDemo();
      await _service.bootstrapUserProfile(
        displayName: DemoAccountConfig.displayName,
      );
      applyStoredPreferences();
      if (!AppConfig.useBackendApi) {
        startRealtimeSync();
      }
      notifyListeners();
      return true;
    } catch (e) {
      errorMessage = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  Future<bool> login(String email, String password) async {
    try {
      errorMessage = '';
      await _service.signInWithEmail(email: email, password: password);
      await _service.bootstrapUserProfile();
      applyStoredPreferences();
      notifyListeners();
      return true;
    } catch (e) {
      errorMessage = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  Future<bool> register(String email, String password, {String displayName = ''}) async {
    try {
      errorMessage = '';
      await _service.registerWithEmail(
        email: email,
        password: password,
        displayName: displayName,
      );
      await _service.bootstrapUserProfile(
        displayName: displayName.isNotEmpty ? displayName : null,
      );
      applyStoredPreferences();
      notifyListeners();
      return true;
    } catch (e) {
      errorMessage = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  @Deprecated('Use login() or register()')
  Future<bool> loginOrRegister(String email, String password, {String displayName = ''}) async {
    if (displayName.trim().isNotEmpty) {
      return register(email, password, displayName: displayName);
    }
    return login(email, password);
  }

  Future<bool> completeConversation(String prompt) async {
    try {
      errorMessage = '';
      await _service.completeConversation(prompt: prompt);
      notifyListeners();
      return true;
    } catch (e) {
      errorMessage = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  Future<bool> completeRolePlay(String scenario, String prompt) async {
    try {
      errorMessage = '';
      await _service.completeRolePlay(scenario: scenario, prompt: prompt);
      notifyListeners();
      return true;
    } catch (e) {
      errorMessage = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  Future<CoachingAssessment?> previewInterviewAssessment(String text) {
    return _service.previewCoachingAssessment(
      text: text,
      sessionType: 'Interview',
    );
  }

  Future<bool> completeInterview({required int stepIndex, required String prompt}) async {
    try {
      errorMessage = '';
      await _service.completeInterview(stepIndex: stepIndex, prompt: prompt);
      notifyListeners();
      return true;
    } catch (e) {
      errorMessage = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  Future<bool> completePresentation({
    required int slideIndex,
    required int totalSlides,
    required String prompt,
  }) async {
    try {
      errorMessage = '';
      await _service.completePresentation(
        slideIndex: slideIndex,
        totalSlides: totalSlides,
        prompt: prompt,
      );
      notifyListeners();
      return true;
    } catch (e) {
      errorMessage = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  Future<bool> completeVoiceTurn(String prompt) async {
    try {
      errorMessage = '';
      await _service.completeVoiceTurn(prompt: prompt);
      notifyListeners();
      return true;
    } catch (e) {
      errorMessage = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  void saveProfile({String? displayName, String? phone}) {
    _service.saveProfile(displayName: displayName, phone: phone);
    notifyListeners();
  }

  void saveVideoCvDraft(VideoCvDraft draft) {
    _service.saveVideoCvDraft(draft);
    notifyListeners();
  }

  Future<PremiumSubscribeOutcome?> subscribeToPlan(String planId) async {
    try {
      errorMessage = '';
      final outcome = await _service.subscribeToPlan(planId);
      notifyListeners();
      return outcome;
    } catch (e) {
      errorMessage = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      return null;
    }
  }

  void saveAvatarStyle(String style) {
    _service.saveAvatar(style: style);
    notifyListeners();
  }

  void saveAvatarImage(String imagePathOrUrl) {
    _service.saveAvatarImage(imagePathOrUrl: imagePathOrUrl);
    notifyListeners();
  }

  void saveAvatarUseTemplate(bool value) {
    _service.saveAvatarUseTemplate(value: value);
    notifyListeners();
  }

  void saveAvatarEmotionState(String state) {
    _service.saveAvatarEmotionState(state);
    notifyListeners();
  }

  void saveVoiceProfile(String profile) {
    _service.saveVoiceProfile(voiceProfile: profile);
    notifyListeners();
  }

  void saveVoiceGender(String gender) {
    _service.saveVoiceGender(voiceGender: gender);
    notifyListeners();
  }

  String suggestedVoiceProfile(String style) {
    return _service.suggestVoiceProfileForStyle(style);
  }

  void generateVideoCv() {
    try {
      errorMessage = '';
      _service.generateVideoCv();
      notifyListeners();
    } catch (e) {
      errorMessage = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      rethrow;
    }
  }

  String buildVideoCvNarration({
    required String fullName,
    required String headline,
    required String summary,
    required String skills,
    required String experience,
    required String education,
  }) {
    return _service.buildVideoCvNarration(
      fullName: fullName,
      headline: headline,
      summary: summary,
      skills: skills,
      experience: experience,
      education: education,
    );
  }

  Future<String> buildVideoCvNarrationAsync({
    required String fullName,
    required String headline,
    required String summary,
    required String skills,
    required String experience,
    required String education,
  }) {
    return _service.buildVideoCvNarrationAsync(
      fullName: fullName,
      headline: headline,
      summary: summary,
      skills: skills,
      experience: experience,
      education: education,
    );
  }

  Future<String> uploadAvatarImage(File file) async {
    if (storage == null) {
      saveAvatarImage(file.path);
      saveAvatarUseTemplate(false);
      return file.path;
    }
    final url = await storage!.uploadAvatarImage(file);
    saveAvatarImage(url);
    saveAvatarUseTemplate(false);
    return url;
  }

  /// On-device photo → cartoon portrait (ML Kit + TFLite or CPU). Free, offline.
  Future<OnDeviceStylizeResult> createOnDeviceAvatarFromPhoto(File file) async {
    final stylizer = OnDeviceAvatarStylizer.instance;
    final result = await stylizer.stylize(file);
    final styled = result.file;
    saveAvatarImage(styled.path);
    saveAvatarUseTemplate(false);
    notifyListeners();

    if (storage != null) {
      try {
        final url = await storage!.uploadAvatarImage(styled);
        saveAvatarImage(url);
        notifyListeners();
        return OnDeviceStylizeResult(
          file: styled,
          engine: result.engine,
          faceDetected: result.faceDetected,
          displayPathOrUrl: url,
        );
      } catch (_) {
        return OnDeviceStylizeResult(
          file: styled,
          engine: result.engine,
          faceDetected: result.faceDetected,
          displayPathOrUrl: styled.path,
        );
      }
    }
    return OnDeviceStylizeResult(
      file: styled,
      engine: result.engine,
      faceDetected: result.faceDetected,
      displayPathOrUrl: styled.path,
    );
  }

  /// Gemini/OpenAI VRoid-style 2D portrait — same URL used for coach + Video CV.
  Future<String> createVroidAvatarFromPhoto(
    File file, {
    String? avatarStyleOverride,
    String style = 'cartoon',
  }) async {
    if (storage == null) {
      throw Exception('VRoid-style avatar requires cloud backend.');
    }
    final url = await storage!.createVroidAvatarFromPhoto(
      file,
      avatarStyle: avatarStyleOverride ?? avatarStyle,
      style: style,
    );
    saveAvatarImage(url);
    saveAvatarUseTemplate(false);
    notifyListeners();
    return url;
  }

  Future<bool> togglePremium() async {
    try {
      errorMessage = '';
      await _service.togglePremium();
      notifyListeners();
      return true;
    } catch (e) {
      errorMessage = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  void logout() {
    stopRealtimeSync();
    _service.logout();
    notifyListeners();
  }

  void applyStoredPreferences() {
    final p = _service.loadPreferences();
    _locale = Locale(p.languageCode);
    _textScale = p.textScale.clamp(0.9, 1.4);
    _highContrast = p.highContrast;
    notifyListeners();
  }

  void _persistPreferences(AppPreferences p) {
    _service.savePreferences(p);
    _locale = Locale(p.languageCode);
    _textScale = p.textScale;
    _highContrast = p.highContrast;
    notifyListeners();
  }

  void setLocale(String languageCode) {
    _persistPreferences(
      _service.loadPreferences().copyWith(languageCode: languageCode),
    );
  }

  void setTextScale(double value) {
    _persistPreferences(_service.loadPreferences().copyWith(textScale: value));
  }

  void setHighContrast(bool value) {
    _persistPreferences(_service.loadPreferences().copyWith(highContrast: value));
  }

  void setNotificationPrefs({
    bool? emailNotifications,
    bool? pushNotifications,
    bool? sessionReminders,
    bool? achievementAlerts,
  }) {
    _persistPreferences(
      _service.loadPreferences().copyWith(
        emailNotifications: emailNotifications,
        pushNotifications: pushNotifications,
        sessionReminders: sessionReminders,
        achievementAlerts: achievementAlerts,
      ),
    );
  }

  Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      errorMessage = '';
      await _service.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );
      notifyListeners();
      return true;
    } catch (e) {
      errorMessage = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  Future<void> exportVideoCv({required String format}) async {
    await VideoCvExportService.exportAndShare(
      draft: videoCvDraft,
      avatarStyle: avatarStyle,
      displayName: displayName,
      format: format,
    );
  }

  /// Cloud FFmpeg render. Returns MP4/WebM download URL when complete.
  Future<String?> submitCloudVideoCvRender() async {
    if (videoCvRender == null) return null;
    final script = videoCvDraft.narrationScript.trim();
    if (script.isEmpty) {
      throw Exception('Generate narration before cloud render.');
    }
    try {
      errorMessage = '';
      var avatarUrl = avatarImage.trim();
      if (avatarUrl.isNotEmpty &&
          !avatarUrl.startsWith('http') &&
          !avatarUseTemplate &&
          storage != null) {
        try {
          final local = File(avatarUrl);
          if (await local.exists()) {
            avatarUrl = await storage!.uploadAvatarImage(local);
            saveAvatarImage(avatarUrl);
          }
        } catch (e) {
          throw Exception(
            'Could not upload portrait for lip-sync video ($e). '
            'Check internet connection and try again.',
          );
        }
      }
      if (!avatarUseTemplate && avatarUrl.isEmpty) {
        throw Exception(
          'Add a portrait on the Avatar screen for lip-sync video, or enable template mode.',
        );
      }
      final job = await videoCvRender!.startRender(
        script: script,
        draft: videoCvDraft,
        format: videoCvDraft.exportFormat == 'webm' ? 'webm' : 'mp4',
        avatarImageUrl: avatarUseTemplate ? '' : avatarUrl,
      );
      final videoUrl = job.videoDownloadUrl;
      if (videoUrl == null || videoUrl.isEmpty) {
        final hint = job.message?.trim();
        throw Exception(
          hint != null && hint.isNotEmpty
              ? hint
              : 'Video render did not return a download URL. Restart the backend and try again.',
        );
      }
      saveVideoCvDraft(videoCvDraft.copyWith(renderVideoUrl: videoUrl));
      generateVideoCv();
      notifyListeners();
      return videoUrl ?? job.downloadUrl;
    } catch (e) {
      errorMessage = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      rethrow;
    }
  }

  Future<void> openCloudRenderPackage(String url) => CloudDownloadService.openInBrowser(url);

  /// Downloads rendered MP4/WebM into app storage for in-app preview.
  Future<CloudDownloadResult> downloadVideoCvForPreview({
    required String url,
    String format = 'mp4',
  }) {
    final ext = format == 'webm' ? 'webm' : 'mp4';
    final stamp = DateTime.now().millisecondsSinceEpoch;
    return CloudDownloadService.downloadVideoForPreview(
      url: url,
      fileName: 'virtuomate_video_cv_$stamp.$ext',
    );
  }

  Future<void> shareVideoCvFile({
    required String localPath,
    String format = 'mp4',
  }) {
    final ext = format == 'webm' ? 'webm' : 'mp4';
    return CloudDownloadService.shareLocalFile(
      localPath: localPath,
      fileName: 'virtuomate_video_cv.$ext',
      mimeType: format == 'webm' ? 'video/webm' : 'video/mp4',
    );
  }

  Future<void> downloadCloudRenderPackage(String url, {String format = 'mp4'}) {
    final isVideo = format == 'mp4' || format == 'webm';
    if (isVideo) {
      final ext = format == 'webm' ? 'webm' : 'mp4';
      return CloudDownloadService.downloadAndShare(
        url: url,
        fileName: 'virtuomate_video_cv_$ext',
        mimeType: format == 'webm' ? 'video/webm' : 'video/mp4',
      );
    }
    final ext = format == 'webm' ? 'webm.json' : 'mp4.json';
    return CloudDownloadService.downloadAndShare(
      url: url,
      fileName: 'virtuomate_render_$ext',
      mimeType: 'application/json',
    );
  }

  Future<Map<String, dynamic>> exportMyData() async {
    if (_onExportData != null) {
      return _onExportData();
    }
    return {
      'profile': {
        'email': user?.email,
        'displayName': displayName,
        'phone': phone,
        'avatarStyle': avatarStyle,
        'voiceProfile': voiceProfile,
        'isPremium': isPremium,
      },
      'preferences': _service.loadPreferences().toJson(),
      'sessions': sessions
          .map(
            (s) => {
              'type': s.type,
              'prompt': s.prompt,
              'feedback': s.feedback,
              'emotion': s.emotion,
              'confidenceScore': s.confidenceScore,
              'createdAt': s.createdAt.toIso8601String(),
            },
          )
          .toList(),
      'videoCvDraft': {
        'fullName': videoCvDraft.fullName,
        'headline': videoCvDraft.headline,
        'narrationScript': videoCvDraft.narrationScript,
      },
      'exportedAt': DateTime.now().toIso8601String(),
      'source': 'local',
    };
  }

  void refreshData() => notifyListeners();

  Future<bool> sendPasswordResetEmail(String email) async {
    try {
      errorMessage = '';
      await _service.sendPasswordReset(email);
      notifyListeners();
      return true;
    } catch (e) {
      errorMessage = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  void startRealtimeSync() {
    _service.startRealtimeSync(notifyListeners);
  }

  void stopRealtimeSync() {
    _service.stopRealtimeSync();
  }

  Future<bool> deleteMyAccount() async {
    try {
      errorMessage = '';
      if (_onDeleteAccount != null) {
        final deleted = await _onDeleteAccount();
        if (deleted) logout();
        notifyListeners();
        return deleted;
      }
      await _service.deleteAccount();
      notifyListeners();
      return true;
    } catch (e) {
      errorMessage = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      return false;
    }
  }
}

class VirtuoMateScope extends InheritedNotifier<VirtuoMateController> {
  const VirtuoMateScope({
    required super.notifier,
    required super.child,
    super.key,
  });

  static VirtuoMateController of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<VirtuoMateScope>();
    if (scope == null || scope.notifier == null) {
      throw StateError('VirtuoMateScope is not available in the widget tree.');
    }
    return scope.notifier!;
  }
}
