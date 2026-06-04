import 'package:firebase_auth/firebase_auth.dart';
import 'package:virtuomate_flutter/auth/auth_gateway.dart';
import 'package:virtuomate_flutter/auth/google_auth_helper.dart';
import 'package:virtuomate_flutter/config/demo_account_config.dart';
import 'package:virtuomate_flutter/core/models.dart';
import 'package:virtuomate_flutter/network/api_client.dart';

class FirebaseAuthGateway implements AuthGateway {
  FirebaseAuthGateway(this._auth, {ApiClient? demoApiClient})
      : _google = GoogleAuthHelper(_auth),
        _demoApiClient = demoApiClient;

  final FirebaseAuth _auth;
  final GoogleAuthHelper _google;
  final ApiClient? _demoApiClient;

  @override
  UserProfile? currentUser() {
    final u = _auth.currentUser;
    if (u == null) return null;
    return UserProfile(
      email: u.email ?? DemoAccountConfig.email,
      displayName: u.displayName ?? '',
    );
  }

  @override
  Future<UserProfile> signInWithEmail({
    required String email,
    required String password,
  }) async {
    if (DemoAccountConfig.isDemoEmail(email)) {
      return signInDemo();
    }

    try {
      final cred = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      final u = cred.user;
      if (u == null) throw Exception('Auth failed.');
      return UserProfile(
        email: u.email ?? email,
        displayName: u.displayName ?? '',
      );
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        throw Exception(
          'No account with this email. Tap Register to create one.',
        );
      }
      throw Exception(_friendlyAuthError(e));
    }
  }

  @override
  Future<UserProfile> registerWithEmail({
    required String email,
    required String password,
    String displayName = '',
  }) async {
    final trimmedEmail = email.trim();
    if (DemoAccountConfig.isDemoEmail(trimmedEmail)) {
      throw Exception('Use “Try demo login” for the demo account.');
    }
    if (password.length < 6) {
      throw Exception('Password is too weak. Use at least 6 characters.');
    }

    try {
      final cred = await _auth.createUserWithEmailAndPassword(
        email: trimmedEmail,
        password: password,
      );
      final u = cred.user;
      if (u == null) throw Exception('Registration failed.');
      final name = displayName.trim();
      if (name.isNotEmpty && (u.displayName ?? '').isEmpty) {
        await u.updateDisplayName(name);
      }
      return UserProfile(
        email: u.email ?? trimmedEmail,
        displayName: name.isNotEmpty ? name : (u.displayName ?? ''),
      );
    } on FirebaseAuthException catch (e) {
      throw Exception(_friendlyAuthError(e));
    }
  }

  @override
  Future<UserProfile> signInDemo() async {
    if (_demoApiClient != null) {
      try {
        return await _signInDemoViaBackend();
      } catch (_) {
        // Fall through to client email/password flow.
      }
    }
    return _signInDemoWithEmailPassword();
  }

  Future<UserProfile> _signInDemoViaBackend() async {
    final client = _demoApiClient!;
    final res = await client.postJsonUnauthenticated('/auth/demo', {});
    final token = res['customToken'] as String?;
    if (token == null || token.isEmpty) {
      throw Exception('Demo login failed: no token from server.');
    }
    final cred = await _auth.signInWithCustomToken(token);
    final u = cred.user;
    if (u == null) throw Exception('Demo login failed.');
    final name = DemoAccountConfig.displayName;
    if ((u.displayName ?? '').isEmpty) {
      await u.updateDisplayName(name);
    }
    return UserProfile(
      email: u.email ?? DemoAccountConfig.email,
      displayName: name,
    );
  }

  Future<UserProfile> _signInDemoWithEmailPassword() async {
    const email = DemoAccountConfig.email;
    const name = DemoAccountConfig.displayName;

    FirebaseAuthException? lastError;
    for (final password in DemoAccountConfig.passwordsToTry) {
      try {
        final cred = await _auth.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
        final u = cred.user;
        if (u == null) throw Exception('Demo login failed.');
        if ((u.displayName ?? '').isEmpty) {
          await u.updateDisplayName(name);
        }
        return UserProfile(email: u.email ?? email, displayName: name);
      } on FirebaseAuthException catch (e) {
        if (e.code == 'user-not-found') {
          return _createDemoUser(email: email, password: password, name: name);
        }
        if (e.code == 'wrong-password' || e.code == 'invalid-credential') {
          lastError = e;
          continue;
        }
        throw Exception(_friendlyAuthError(e));
      }
    }

    if (lastError != null) {
      throw Exception(
        'Demo account exists with an old password. '
        'Redeploy the API and try again, or in Firebase Console delete user '
        '${DemoAccountConfig.email} and tap Try demo login again.',
      );
    }

    return _createDemoUser(
      email: email,
      password: DemoAccountConfig.password,
      name: name,
    );
  }

  Future<UserProfile> _createDemoUser({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      final cred = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final u = cred.user;
      if (u == null) throw Exception('Could not create demo account.');
      await u.updateDisplayName(name);
      return UserProfile(email: u.email ?? email, displayName: name);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        throw Exception(
          'Demo account already exists with a different password. '
          'Delete ${DemoAccountConfig.email} in Firebase Authentication, '
          'or redeploy the backend and try again.',
        );
      }
      throw Exception(_friendlyAuthError(e));
    }
  }

  @override
  Future<void> signOut() async {
    await _google.signOut();
    await _auth.signOut();
  }

  @override
  Future<UserProfile> signInWithGoogle() async {
    try {
      return await _google.signIn();
    } on FirebaseAuthException catch (e) {
      throw Exception(_friendlyAuthError(e));
    }
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    final trimmed = email.trim();
    if (trimmed.isEmpty) {
      throw Exception('Enter your email address first.');
    }
    try {
      await _auth.sendPasswordResetEmail(email: trimmed);
    } on FirebaseAuthException catch (e) {
      throw Exception(_friendlyAuthError(e));
    }
  }

  @override
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final user = _auth.currentUser;
    if (user == null || user.email == null) {
      throw Exception('Not logged in.');
    }
    final credential = EmailAuthProvider.credential(
      email: user.email!,
      password: currentPassword,
    );
    await user.reauthenticateWithCredential(credential);
    await user.updatePassword(newPassword);
  }

  static String _friendlyAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'wrong-password':
      case 'invalid-credential':
        return 'Incorrect email or password.';
      case 'email-already-in-use':
        return 'An account with this email already exists. Try signing in.';
      case 'weak-password':
        return 'Password is too weak. Use at least 6 characters.';
      case 'invalid-email':
        return 'Enter a valid email address.';
      case 'too-many-requests':
        return 'Too many attempts. Wait a moment and try again.';
      default:
        return e.message ?? 'Authentication failed (${e.code}).';
    }
  }
}
