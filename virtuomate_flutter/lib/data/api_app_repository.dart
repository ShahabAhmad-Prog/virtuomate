import 'dart:async';
import 'package:virtuomate_flutter/core/models.dart';
import 'package:virtuomate_flutter/data/app_repository.dart';
import 'package:virtuomate_flutter/network/api_client.dart';

class ApiAppRepository implements AppRepository {
  ApiAppRepository(this._api);

  final ApiClient _api;
  UserProfile? _user;
  String _displayName = '';
  String _phone = '';
  String _avatarStyle = 'Professional';
  String _avatarImage = '';
  bool _avatarUseTemplate = true;
  String _avatarEmotionState = 'neutral';
  String _voiceProfile = 'confident-neutral';
  String _voiceGender = 'female';
  bool _isPremium = false;
  final List<SessionRecord> _sessions = [];
  int _videoCvCount = 0;
  VideoCvDraft _videoCvDraft = VideoCvDraft();
  int _missionProgress = 65;
  AppPreferences _preferences = const AppPreferences();

  Future<void> bootstrap({String? displayName, String? phone}) async {
    await _api.postJson('/user/bootstrap', {
      if (displayName != null) 'displayName': displayName,
      if (phone != null) 'phone': phone,
    });
  }

  Future<String> fetchVideoCvScript({
    required String fullName,
    required String headline,
    required String summary,
    required String skills,
    required String experience,
    required String education,
  }) async {
    final res = await _api.postJson('/video-cv/script', {
      'fullName': fullName,
      'headline': headline,
      'summary': summary,
      'skills': skills,
      'experience': experience,
      'education': education,
    });
    return (res['script'] as String?) ?? '';
  }

  Future<void> hydrate() async {
    final profile = await _api.getJson('/user/profile');
    _displayName = (profile['displayName'] as String?) ?? '';
    _phone = (profile['phone'] as String?) ?? '';
    _avatarStyle = (profile['avatarStyle'] as String?) ?? 'Professional';
    _avatarImage = (profile['avatarImageUrl'] as String?) ?? '';
    _avatarUseTemplate = (profile['avatarUseTemplate'] as bool?) ?? true;
    _avatarEmotionState = (profile['avatarEmotionState'] as String?) ?? 'neutral';
    _voiceProfile = (profile['voiceProfile'] as String?) ?? 'confident-neutral';
    _voiceGender = (profile['voiceGender'] as String?) ?? 'female';
    _videoCvCount = (profile['videoCvCount'] as num?)?.toInt() ?? 0;
    _missionProgress = (profile['missionProgress'] as num?)?.toInt() ?? 65;
    _isPremium = (profile['isPremium'] as bool?) ?? false;
    _preferences = AppPreferences.mergeFromJson(
      _preferences,
      profile['preferences'] as Map<String, dynamic>?,
    );
    final draft = profile['videoCvDraft'] as Map<String, dynamic>?;
    if (draft != null) {
      _videoCvDraft = VideoCvDraft(
        fullName: draft['fullName'] as String? ?? '',
        headline: draft['headline'] as String? ?? '',
        summary: draft['summary'] as String? ?? '',
        email: draft['email'] as String? ?? '',
        phone: draft['phone'] as String? ?? '',
        skills: draft['skills'] as String? ?? '',
        experience: draft['experience'] as String? ?? '',
        education: draft['education'] as String? ?? '',
        narrationScript: draft['narrationScript'] as String? ?? '',
        exportFormat: draft['exportFormat'] as String? ?? 'mp4',
      );
    }
    if (_user != null) {
      _user = _user!.copyWith(
        isPremium: _isPremium,
        displayName: _displayName,
        phone: _phone,
      );
    } else {
      final email = (profile['email'] as String?) ?? '';
      if (email.isNotEmpty) {
        _user = UserProfile(
          email: email,
          displayName: _displayName,
          phone: _phone,
          isPremium: _isPremium,
        );
      }
    }

    final sessionsResponse = await _api.getJson('/sessions');
    final raw = (sessionsResponse['sessions'] as List?) ?? const [];
    _sessions
      ..clear()
      ..addAll(
        raw.map((e) {
          final m = e as Map<String, dynamic>;
          return SessionRecord(
            type: (m['type'] as String?) ?? 'Conversation',
            prompt: (m['prompt'] as String?) ?? '',
            feedback: (m['feedback'] as String?) ?? '',
            emotion: (m['emotion'] as String?) ?? 'Neutral',
            confidenceScore: (m['confidenceScore'] as num?)?.toInt() ?? 0,
          );
        }),
      );
  }

  @override
  UserProfile? currentUser() => _user;

  @override
  void saveCurrentUser(UserProfile? profile) {
    _user = profile;
    if (profile == null) {
      _isPremium = false;
    } else if (profile.isPremium) {
      _isPremium = true;
    }
  }

  @override
  bool isPremium() => _isPremium;

  @override
  void setPremium(bool value) {
    _isPremium = value;
    if (_user != null) {
      _user = _user!.copyWith(isPremium: value);
    }
  }

  @override
  String displayName() => _displayName;

  @override
  void saveDisplayName(String name) {
    _displayName = name;
    unawaited(_api.putJson('/user/profile', {'displayName': name}));
  }

  @override
  String phone() => _phone;

  @override
  void savePhone(String phone) {
    _phone = phone;
    unawaited(_api.putJson('/user/profile', {'phone': phone}));
  }

  @override
  String avatarStyle() => _avatarStyle;

  @override
  void saveAvatarStyle(String style) {
    _avatarStyle = style;
    unawaited(_api.putJson('/user/profile', {'avatarStyle': style}));
  }

  @override
  String avatarImage() => _avatarImage;

  @override
  void saveAvatarImage(String imagePathOrUrl) {
    _avatarImage = imagePathOrUrl;
    if (imagePathOrUrl.startsWith('http')) {
      unawaited(_api.putJson('/user/profile', {'avatarImageUrl': imagePathOrUrl}));
    }
  }

  @override
  bool avatarUseTemplate() => _avatarUseTemplate;

  @override
  void saveAvatarUseTemplate(bool value) {
    _avatarUseTemplate = value;
    unawaited(_api.putJson('/user/profile', {'avatarUseTemplate': value}));
  }

  @override
  String avatarEmotionState() => _avatarEmotionState;

  @override
  void saveAvatarEmotionState(String state) {
    _avatarEmotionState = state;
    unawaited(_api.putJson('/user/profile', {'avatarEmotionState': state}));
  }

  @override
  String voiceProfile() => _voiceProfile;

  @override
  void saveVoiceProfile(String profile) {
    _voiceProfile = profile;
    unawaited(_api.putJson('/user/profile', {'voiceProfile': profile}));
  }

  @override
  String voiceGender() => _voiceGender;

  @override
  void saveVoiceGender(String gender) {
    _voiceGender = gender;
    unawaited(_api.putJson('/user/profile', {'voiceGender': gender}));
  }

  @override
  void saveSession(SessionRecord record) {
    _sessions.insert(0, record);
    unawaited(_persistSession(record));
  }

  Future<void> _persistSession(SessionRecord record) async {
    try {
      await _api.postJson('/sessions', {
        'type': record.type,
        'prompt': record.prompt,
        'feedback': record.feedback,
        'emotion': record.emotion,
        'confidenceScore': record.confidenceScore,
        if (record.assessment != null) 'assessment': record.assessment!.toJson(),
      });
    } catch (_) {
      // Session stays in local list; cloud save may fail if free tier limit hit on server.
    }
  }

  @override
  List<SessionRecord> sessions() => List.unmodifiable(_sessions);

  @override
  void incrementVideoCvCount() {
    _videoCvCount += 1;
    unawaited(_api.postJson('/video-cv/generate', {}));
  }

  @override
  int videoCvCount() => _videoCvCount;

  @override
  VideoCvDraft videoCvDraft() => _videoCvDraft;

  @override
  void saveVideoCvDraft(VideoCvDraft draft) {
    _videoCvDraft = draft;
    unawaited(_api.putJson('/user/profile', {
      'videoCvDraft': {
        'fullName': draft.fullName,
        'headline': draft.headline,
        'summary': draft.summary,
        'email': draft.email,
        'phone': draft.phone,
        'skills': draft.skills,
        'experience': draft.experience,
        'education': draft.education,
        'narrationScript': draft.narrationScript,
        'exportFormat': draft.exportFormat,
      },
    }));
  }

  @override
  int missionProgressPercent() => _missionProgress;

  @override
  void setMissionProgressPercent(int value) {
    _missionProgress = value.clamp(0, 100);
    unawaited(_api.putJson('/user/profile', {'missionProgress': _missionProgress}));
  }

  @override
  AppPreferences preferences() => _preferences;

  @override
  void savePreferences(AppPreferences preferences) {
    _preferences = preferences;
    unawaited(_api.putJson('/user/profile', {'preferences': preferences.toJson()}));
  }
}
