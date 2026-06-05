import 'dart:convert';
import 'dart:io';

import 'package:virtuomate_flutter/network/api_client.dart';

/// Selfie upload via backend `POST /storage/avatar`.
class StorageService {
  StorageService(this._api);

  final ApiClient? _api;

  Future<String> uploadAvatarImage(File file) async {
    if (_api == null) return file.path;

    final contentType = _mimeForPath(file.path);
    final fileName = file.uri.pathSegments.last;
    final bytes = await file.readAsBytes();

    final result = await _api.postJson(
      '/storage/avatar',
      {
        'fileName': fileName,
        'contentType': contentType,
        'dataBase64': base64Encode(bytes),
      },
      timeout: const Duration(minutes: 3),
    );
    final downloadUrl = result['downloadUrl'] as String?;
    final publicUrl = result['publicUrl'] as String?;
    final best = (downloadUrl != null && downloadUrl.isNotEmpty) ? downloadUrl : publicUrl;
    if (best == null || best.isEmpty) {
      throw Exception('Avatar upload did not return a URL.');
    }
    return best;
  }

  Future<String> createVroidAvatarFromPhoto(
    File file, {
    String? avatarStyle,
    String style = 'cartoon',
  }) async {
    if (_api == null) {
      throw Exception('VRoid-style avatar requires cloud backend.');
    }

    final contentType = _mimeForPath(file.path);
    final fileName = file.uri.pathSegments.last;
    final bytes = await file.readAsBytes();

    final result = await _api.postJson('/storage/avatar/vroid-from-photo', {
      'fileName': fileName,
      'contentType': contentType,
      'dataBase64': base64Encode(bytes),
      if (avatarStyle != null && avatarStyle.isNotEmpty) 'avatarStyle': avatarStyle,
      'style': style,
    });
    final downloadUrl = result['downloadUrl'] as String?;
    final publicUrl = result['publicUrl'] as String?;
    final best = (downloadUrl != null && downloadUrl.isNotEmpty) ? downloadUrl : publicUrl;
    if (best == null || best.isEmpty) {
      throw Exception('VRoid-style avatar did not return a URL.');
    }
    return best;
  }

  String _mimeForPath(String path) {
    final lower = path.toLowerCase();
    if (lower.endsWith('.png')) return 'image/png';
    if (lower.endsWith('.webp')) return 'image/webp';
    return 'image/jpeg';
  }
}
