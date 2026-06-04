import 'package:virtuomate_flutter/config/demo_account_config.dart';
import 'package:virtuomate_flutter/core/models.dart';

abstract class AuthGateway {
  UserProfile? currentUser();
  Future<UserProfile> signInWithEmail({
    required String email,
    required String password,
  });
  Future<UserProfile> registerWithEmail({
    required String email,
    required String password,
    String displayName = '',
  });
  Future<void> signOut();
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  });

  Future<void> sendPasswordResetEmail(String email);

  Future<UserProfile> signInWithGoogle();

  /// One-tap demo access with fixed credentials (and cloud reset when available).
  Future<UserProfile> signInDemo();
}

class InMemoryAuthGateway implements AuthGateway {
  UserProfile? _user;

  @override
  UserProfile? currentUser() => _user;

  @override
  Future<UserProfile> signInWithEmail({
    required String email,
    required String password,
  }) async {
    if (email.trim().isEmpty || password.trim().isEmpty) {
      throw Exception('Email and password are required.');
    }
    _user = UserProfile(email: email.trim());
    return _user!;
  }

  @override
  Future<UserProfile> registerWithEmail({
    required String email,
    required String password,
    String displayName = '',
  }) async {
    return signInWithEmail(email: email, password: password);
  }

  @override
  Future<void> signOut() async {
    _user = null;
  }

  @override
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    if (_user == null) throw Exception('Not logged in.');
    if (newPassword.length < 6) {
      throw Exception('New password must be at least 6 characters.');
    }
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    if (email.trim().isEmpty) {
      throw Exception('Enter your email address first.');
    }
  }

  @override
  Future<UserProfile> signInWithGoogle() async {
    throw Exception(
      'Google Sign-In needs Firebase. Restart with:\n'
      'flutter run --dart-define=USE_FIREBASE=true --dart-define=USE_BACKEND_API=true '
      '--dart-define=GOOGLE_WEB_CLIENT_ID=your-web-client-id',
    );
  }

  @override
  Future<UserProfile> signInDemo() async {
    _user = UserProfile(
      email: DemoAccountConfig.email,
      displayName: DemoAccountConfig.displayName,
    );
    return _user!;
  }
}
