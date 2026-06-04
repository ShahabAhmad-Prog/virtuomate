import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:virtuomate_flutter/core/models.dart';
import 'package:virtuomate_flutter/data/app_repository.dart';

class FirebaseAppRepository implements AppRepository {
  FirebaseAppRepository({
    required FirebaseFirestore firestore,
    required FirebaseAuth auth,
  }) : _firestore = firestore,
       _auth = auth;

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  String _avatarStyle = 'Professional';
  String _avatarImage = '';
  bool _avatarUseTemplate = true;
  String _avatarEmotionState = 'neutral';
  String _voiceProfile = 'confident-neutral';
  String _voiceGender = 'female';
  String _displayName = '';
  String _phone = '';
  bool _isPremium = false;
  int _videoCvCount = 0;
  int _missionProgress = 0;
  VideoCvDraft _videoCvDraft = VideoCvDraft();
  AppPreferences _preferences = const AppPreferences();
  final List<SessionRecord> _sessions = [];
  bool _hydrated = false;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _sessionsSub;
  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>? _userSub;

  String _uid() {
    final uid = _auth.currentUser?.uid;
    if (uid == null) throw Exception('Not logged in.');
    return uid;
  }

  DocumentReference<Map<String, dynamic>> _userDoc() =>
      _firestore.collection('users').doc(_uid());

  CollectionReference<Map<String, dynamic>> _sessionsCol() =>
      _firestore.collection('users').doc(_uid()).collection('sessions');

  Future<void> hydrate() async {
    final doc = await _userDoc().get();
    if (doc.exists && doc.data() != null) {
      _applyUserData(doc.data()!);
    }

    final sessionsSnap = await _sessionsCol()
        .orderBy('createdAt', descending: true)
        .limit(50)
        .get();
    _sessions
      ..clear()
      ..addAll(sessionsSnap.docs.map(_sessionFromDoc));
    _hydrated = true;
  }

  SessionRecord _sessionFromDoc(QueryDocumentSnapshot<Map<String, dynamic>> d) {
    final m = d.data();
    return SessionRecord(
      type: m['type'] as String? ?? 'Conversation',
      prompt: m['prompt'] as String? ?? '',
      feedback: m['feedback'] as String? ?? '',
      emotion: m['emotion'] as String? ?? 'Neutral',
      confidenceScore: (m['confidenceScore'] as num?)?.toInt() ?? 0,
      createdAt: (m['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  @override
  UserProfile? currentUser() {
    final u = _auth.currentUser;
    if (u == null) return null;
    return UserProfile(
      email: u.email ?? '',
      displayName: _displayName.isNotEmpty ? _displayName : (u.displayName ?? ''),
      phone: _phone,
      isPremium: _isPremium,
    );
  }

  @override
  void saveCurrentUser(UserProfile? profile) {
    if (profile == null) return;
    _displayName = profile.displayName;
    _phone = profile.phone;
    if (profile.isPremium) {
      _isPremium = true;
    }
    _userDoc().set({
      'email': profile.email,
      'displayName': profile.displayName,
      'phone': profile.phone,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  @override
  String displayName() => _displayName;

  @override
  void saveDisplayName(String name) {
    _displayName = name;
    _userDoc().set({'displayName': name, 'updatedAt': FieldValue.serverTimestamp()}, SetOptions(merge: true));
  }

  @override
  String phone() => _phone;

  @override
  void savePhone(String phone) {
    _phone = phone;
    _userDoc().set({'phone': phone, 'updatedAt': FieldValue.serverTimestamp()}, SetOptions(merge: true));
  }

  @override
  String avatarStyle() => _avatarStyle;

  @override
  void saveAvatarStyle(String style) {
    _avatarStyle = style;
    _userDoc().set({'avatarStyle': style, 'updatedAt': FieldValue.serverTimestamp()}, SetOptions(merge: true));
  }

  @override
  String avatarImage() => _avatarImage;

  @override
  void saveAvatarImage(String imagePathOrUrl) {
    _avatarImage = imagePathOrUrl;
    if (imagePathOrUrl.startsWith('http')) {
      _userDoc().set(
        {'avatarImageUrl': imagePathOrUrl, 'updatedAt': FieldValue.serverTimestamp()},
        SetOptions(merge: true),
      );
    }
  }

  @override
  bool avatarUseTemplate() => _avatarUseTemplate;

  @override
  void saveAvatarUseTemplate(bool value) {
    _avatarUseTemplate = value;
    _userDoc().set(
      {'avatarUseTemplate': value, 'updatedAt': FieldValue.serverTimestamp()},
      SetOptions(merge: true),
    );
  }

  @override
  String avatarEmotionState() => _avatarEmotionState;

  @override
  void saveAvatarEmotionState(String state) {
    _avatarEmotionState = state;
    _userDoc().set(
      {'avatarEmotionState': state, 'updatedAt': FieldValue.serverTimestamp()},
      SetOptions(merge: true),
    );
  }

  @override
  String voiceProfile() => _voiceProfile;

  @override
  void saveVoiceProfile(String profile) {
    _voiceProfile = profile;
    _userDoc().set({'voiceProfile': profile, 'updatedAt': FieldValue.serverTimestamp()}, SetOptions(merge: true));
  }

  @override
  String voiceGender() => _voiceGender;

  @override
  void saveVoiceGender(String gender) {
    _voiceGender = gender;
    _userDoc().set({'voiceGender': gender, 'updatedAt': FieldValue.serverTimestamp()}, SetOptions(merge: true));
  }

  @override
  void saveSession(SessionRecord record) {
    _sessions.insert(0, record);
    _sessionsCol().add({
      'type': record.type,
      'prompt': record.prompt,
      'feedback': record.feedback,
      'emotion': record.emotion,
      'confidenceScore': record.confidenceScore,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  List<SessionRecord> sessions() => List.unmodifiable(_sessions);

  @override
  void incrementVideoCvCount() {
    _videoCvCount += 1;
    _userDoc().set({
      'videoCvCount': FieldValue.increment(1),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  @override
  int videoCvCount() => _videoCvCount;

  @override
  VideoCvDraft videoCvDraft() => _videoCvDraft;

  @override
  void saveVideoCvDraft(VideoCvDraft draft) {
    _videoCvDraft = draft;
    _userDoc().set({
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
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  @override
  int missionProgressPercent() => _missionProgress;

  @override
  void setMissionProgressPercent(int value) {
    _missionProgress = value.clamp(0, 100);
    _userDoc().set({
      'missionProgress': _missionProgress,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  @override
  AppPreferences preferences() => _preferences;

  @override
  void savePreferences(AppPreferences preferences) {
    _preferences = preferences;
    _userDoc().set({
      'preferences': preferences.toJson(),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  bool get isHydrated => _hydrated;

  void _applyUserData(Map<String, dynamic> data) {
    _displayName = data['displayName'] as String? ?? '';
    _phone = data['phone'] as String? ?? '';
    _avatarStyle = data['avatarStyle'] as String? ?? 'Professional';
    _avatarImage = data['avatarImageUrl'] as String? ?? '';
    _avatarUseTemplate = data['avatarUseTemplate'] as bool? ?? true;
    _avatarEmotionState = data['avatarEmotionState'] as String? ?? 'neutral';
    _voiceProfile = data['voiceProfile'] as String? ?? 'confident-neutral';
    _voiceGender = data['voiceGender'] as String? ?? 'female';
    _isPremium = data['isPremium'] as bool? ?? false;
    _videoCvCount = (data['videoCvCount'] as num?)?.toInt() ?? 0;
    _missionProgress = (data['missionProgress'] as num?)?.toInt() ?? 0;
    final draft = data['videoCvDraft'] as Map<String, dynamic>?;
    _preferences = AppPreferences.fromJson(
      data['preferences'] as Map<String, dynamic>?,
    );
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
  }

  /// Live Firestore sync for profile + sessions (call once after login).
  void startRealtimeSync(void Function() onChanged) {
    stopRealtimeSync();
    _userSub = _userDoc().snapshots().listen((snap) {
      if (snap.exists && snap.data() != null) {
        _applyUserData(snap.data()!);
        onChanged();
      }
    });
    _sessionsSub = _sessionsCol()
        .orderBy('createdAt', descending: true)
        .limit(50)
        .snapshots()
        .listen((snap) {
      _sessions
        ..clear()
        ..addAll(snap.docs.map(_sessionFromDoc));
      onChanged();
    });
  }

  void stopRealtimeSync() {
    _userSub?.cancel();
    _sessionsSub?.cancel();
    _userSub = null;
    _sessionsSub = null;
  }

  /// Deletes Firestore user data, sessions, and Firebase Auth account.
  Future<void> deleteAllUserData() async {
    final sessions = await _sessionsCol().get();
    final batch = _firestore.batch();
    for (final doc in sessions.docs) {
      batch.delete(doc.reference);
    }
    batch.delete(_userDoc());
    await batch.commit();
    final user = _auth.currentUser;
    if (user != null) {
      await user.delete();
    }
    stopRealtimeSync();
    _sessions.clear();
    _hydrated = false;
  }

  void setPremiumLocal(bool value) => setPremium(value);

  @override
  bool isPremium() => _isPremium;

  @override
  void setPremium(bool value) => _isPremium = value;
}
