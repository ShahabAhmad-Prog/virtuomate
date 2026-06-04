import 'package:virtuomate_flutter/network/api_client.dart';

class AdminUserRow {
  AdminUserRow({
    required this.uid,
    required this.email,
    required this.displayName,
    required this.isPremium,
    required this.videoCvCount,
    required this.missionProgress,
  });

  final String uid;
  final String email;
  final String displayName;
  final bool isPremium;
  final int videoCvCount;
  final int missionProgress;

  factory AdminUserRow.fromJson(Map<String, dynamic> json) {
    return AdminUserRow(
      uid: json['uid'] as String? ?? '',
      email: json['email'] as String? ?? '',
      displayName: json['displayName'] as String? ?? '',
      isPremium: json['isPremium'] as bool? ?? false,
      videoCvCount: (json['videoCvCount'] as num?)?.toInt() ?? 0,
      missionProgress: (json['missionProgress'] as num?)?.toInt() ?? 0,
    );
  }
}

class AdminAnalytics {
  AdminAnalytics({
    required this.totalUsers,
    required this.premiumUsers,
    required this.totalSessions,
  });

  final int totalUsers;
  final int premiumUsers;
  final int totalSessions;

  factory AdminAnalytics.fromJson(Map<String, dynamic> json) {
    return AdminAnalytics(
      totalUsers: (json['totalUsers'] as num?)?.toInt() ?? 0,
      premiumUsers: (json['premiumUsers'] as num?)?.toInt() ?? 0,
      totalSessions: (json['totalSessions'] as num?)?.toInt() ?? 0,
    );
  }
}

class AdminApiService {
  AdminApiService(this._api);

  final ApiClient _api;

  Future<List<AdminUserRow>> fetchUsers() async {
    final res = await _api.getJson('/admin/users');
    final raw = res['users'] as List? ?? [];
    return raw
        .map((e) => AdminUserRow.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<AdminAnalytics> fetchAnalytics() async {
    final res = await _api.getJson('/admin/analytics');
    return AdminAnalytics.fromJson(res);
  }
}
