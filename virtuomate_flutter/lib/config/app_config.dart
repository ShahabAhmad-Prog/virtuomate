import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:virtuomate_flutter/config/google_oauth_config.dart';

/// Central app configuration for dev/staging/production builds.
class AppConfig {
  AppConfig._();

  static const String productionApiUrl =
      'https://us-central1-virtuomate.cloudfunctions.net/api';

  static bool get useFirebase {
    const v = String.fromEnvironment('USE_FIREBASE', defaultValue: '');
    if (v == 'true') return true;
    if (v == 'false') return false;
    // Cloud-first app: enable Firebase in debug unless explicitly disabled.
    return true;
  }

  static bool get useBackendApi {
    if (!useFirebase) return false;
    const v = String.fromEnvironment('USE_BACKEND_API', defaultValue: '');
    if (v == 'true') return true;
    if (v == 'false') return false;
    return kReleaseMode;
  }

  static String get backendBaseUrl {
    const url = String.fromEnvironment('BACKEND_BASE_URL');
    final resolved = url.isNotEmpty
        ? url
        : (useBackendApi
            ? productionApiUrl
            : (kReleaseMode ? productionApiUrl : 'http://127.0.0.1:8080'));
    return _androidEmulatorHostLoopback(resolved);
  }

  /// Android emulator cannot reach the PC via 127.0.0.1 — use the host alias 10.0.2.2.
  static String _androidEmulatorHostLoopback(String url) {
    if (kIsWeb) return url;
    try {
      if (!Platform.isAndroid) return url;
    } catch (_) {
      return url;
    }
    final uri = Uri.tryParse(url);
    if (uri == null || uri.host.isEmpty) return url;
    if (uri.host != '127.0.0.1' && uri.host != 'localhost') return url;
    return uri.replace(host: '10.0.2.2').toString();
  }

  /// Web OAuth client ID (Firebase Authentication → Google → Web SDK configuration).
  /// Used for Flutter web `clientId` and Android `serverClientId` (id token for Firebase Auth).
  /// Pass at build time: --dart-define=GOOGLE_WEB_CLIENT_ID=xxx.apps.googleusercontent.com
  static String? get googleWebClientId {
    const v = String.fromEnvironment('GOOGLE_WEB_CLIENT_ID');
    if (v.isNotEmpty) return v;
    if (useFirebase) return kDefaultGoogleWebClientId;
    return null;
  }

  /// Android/iOS: Web client ID for [GoogleSignIn.serverClientId]. Defaults to [googleWebClientId].
  static String? get googleServerClientId {
    const v = String.fromEnvironment('GOOGLE_SERVER_CLIENT_ID');
    if (v.isNotEmpty) return v;
    return googleWebClientId;
  }

  /// Comma-separated admin emails (must match backend ADMIN_EMAILS).
  /// --dart-define=ADMIN_EMAILS=admin@virtuomate.app,other@example.com
  static Set<String> get adminEmails {
    const v = String.fromEnvironment('ADMIN_EMAILS', defaultValue: 'admin@virtuomate.app');
    return v
        .split(',')
        .map((e) => e.trim().toLowerCase())
        .where((e) => e.isNotEmpty)
        .toSet();
  }

  static bool isAdminEmail(String? email) {
    if (email == null || email.isEmpty) return false;
    return adminEmails.contains(email.trim().toLowerCase());
  }
}
