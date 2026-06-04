import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:virtuomate_flutter/config/app_config.dart';
import 'package:virtuomate_flutter/core/models.dart';

/// Firebase + Google Sign-In flow (Android/iOS/Web).
class GoogleAuthHelper {
  GoogleAuthHelper(this._auth);

  final FirebaseAuth _auth;
  GoogleSignIn? _instance;

  GoogleSignIn get _googleSignIn {
    _instance ??= GoogleSignIn(
      scopes: const ['email', 'profile'],
      clientId: kIsWeb ? AppConfig.googleWebClientId : null,
      serverClientId: !kIsWeb ? AppConfig.googleServerClientId : null,
    );
    return _instance!;
  }

  Future<UserProfile> signIn() async {
    if (AppConfig.googleWebClientId == null) {
      if (kIsWeb) {
        throw Exception(
          'Web Google Sign-In needs GOOGLE_WEB_CLIENT_ID. '
          'See docs/GOOGLE_SIGNIN.md.',
        );
      }
      if (defaultTargetPlatform == TargetPlatform.android &&
          AppConfig.googleServerClientId == null) {
        throw Exception(
          'Android Google Sign-In needs GOOGLE_WEB_CLIENT_ID (Web OAuth client) '
          'for Firebase id tokens. See docs/GOOGLE_SIGNIN.md.',
        );
      }
    }

    final account = await _googleSignIn.signIn();
    if (account == null) {
      throw Exception('Google sign-in was cancelled.');
    }

    final googleAuth = await account.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    final result = await _auth.signInWithCredential(credential);
    final user = result.user;
    if (user == null) {
      throw Exception('Google authentication failed.');
    }

    return UserProfile(
      email: user.email ?? account.email,
      displayName: user.displayName ?? account.displayName ?? '',
    );
  }

  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
    } catch (_) {
      // Ignore — user may not have used Google on this device.
    }
  }
}
