import 'package:virtuomate_flutter/core/models.dart';

abstract class AppRepository {
  UserProfile? currentUser();
  void saveCurrentUser(UserProfile? profile);

  bool isPremium();
  void setPremium(bool value);

  String displayName();
  void saveDisplayName(String name);
  String phone();
  void savePhone(String phone);

  String avatarStyle();
  void saveAvatarStyle(String style);
  String avatarImage();
  void saveAvatarImage(String imagePathOrUrl);
  bool avatarUseTemplate();
  void saveAvatarUseTemplate(bool value);
  String avatarEmotionState();
  void saveAvatarEmotionState(String state);
  String voiceProfile();
  void saveVoiceProfile(String profile);
  String voiceGender();
  void saveVoiceGender(String gender);

  void saveSession(SessionRecord record);
  List<SessionRecord> sessions();

  void incrementVideoCvCount();
  int videoCvCount();

  VideoCvDraft videoCvDraft();
  void saveVideoCvDraft(VideoCvDraft draft);

  int missionProgressPercent();
  void setMissionProgressPercent(int value);

  AppPreferences preferences();
  void savePreferences(AppPreferences preferences);
}

class InMemoryAppRepository implements AppRepository {
  UserProfile? _user;
  String _displayName = '';
  String _phone = '';
  String _avatarStyle = 'Professional';
  String _avatarImage = '';
  bool _avatarUseTemplate = true;
  String _avatarEmotionState = 'neutral';
  String _voiceProfile = 'confident-neutral';
  String _voiceGender = 'female';
  final List<SessionRecord> _sessions = [];
  int _videoCvCount = 0;
  VideoCvDraft _videoCvDraft = VideoCvDraft();
  int _missionProgress = 65;

  @override
  UserProfile? currentUser() => _user;

  @override
  void saveCurrentUser(UserProfile? profile) {
    _user = profile;
    if (profile != null) {
      if (_displayName.isEmpty && profile.displayName.isNotEmpty) {
        _displayName = profile.displayName;
      }
      if (_phone.isEmpty && profile.phone.isNotEmpty) {
        _phone = profile.phone;
      }
    }
  }

  @override
  bool isPremium() => _user?.isPremium ?? false;

  @override
  void setPremium(bool value) {
    if (_user != null) {
      _user = _user!.copyWith(isPremium: value);
    }
  }

  @override
  String displayName() =>
      _displayName.isNotEmpty ? _displayName : _user?.displayName ?? '';

  @override
  void saveDisplayName(String name) => _displayName = name;

  @override
  String phone() => _phone.isNotEmpty ? _phone : _user?.phone ?? '';

  @override
  void savePhone(String phone) => _phone = phone;

  @override
  String avatarStyle() => _avatarStyle;

  @override
  void saveAvatarStyle(String style) => _avatarStyle = style;

  @override
  String avatarImage() => _avatarImage;

  @override
  void saveAvatarImage(String imagePathOrUrl) => _avatarImage = imagePathOrUrl;

  @override
  bool avatarUseTemplate() => _avatarUseTemplate;

  @override
  void saveAvatarUseTemplate(bool value) => _avatarUseTemplate = value;

  @override
  String avatarEmotionState() => _avatarEmotionState;

  @override
  void saveAvatarEmotionState(String state) => _avatarEmotionState = state;

  @override
  String voiceProfile() => _voiceProfile;

  @override
  void saveVoiceProfile(String profile) => _voiceProfile = profile;

  @override
  String voiceGender() => _voiceGender;

  @override
  void saveVoiceGender(String gender) => _voiceGender = gender;

  @override
  void saveSession(SessionRecord record) => _sessions.insert(0, record);

  @override
  List<SessionRecord> sessions() => List.unmodifiable(_sessions);

  @override
  void incrementVideoCvCount() => _videoCvCount += 1;

  @override
  int videoCvCount() => _videoCvCount;

  @override
  VideoCvDraft videoCvDraft() => _videoCvDraft;

  @override
  void saveVideoCvDraft(VideoCvDraft draft) => _videoCvDraft = draft;

  @override
  int missionProgressPercent() => _missionProgress;

  @override
  void setMissionProgressPercent(int value) =>
      _missionProgress = value.clamp(0, 100);

  AppPreferences _preferences = const AppPreferences();

  @override
  AppPreferences preferences() => _preferences;

  @override
  void savePreferences(AppPreferences preferences) => _preferences = preferences;
}
