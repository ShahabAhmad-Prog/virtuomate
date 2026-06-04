/// Shared demo credentials (Firebase + local mock).
class DemoAccountConfig {
  DemoAccountConfig._();

  static const String email = 'demo@virtuomate.app';

  /// Current demo password (Firebase requires 6+ chars).
  static const String password = 'VirtuoDemo2026!';

  /// Older builds used this password; still tried for existing Firebase users.
  static const String legacyPassword = 'virtuomate-demo';

  static const String displayName = 'Demo User';

  static const List<String> passwordsToTry = [password, legacyPassword];

  static bool isDemoEmail(String value) {
    final e = value.trim().toLowerCase();
    return e == email ||
        e == 'demo.demo@virtuomate.app' ||
        e.startsWith('demo.') && e.endsWith('@virtuomate.app');
  }
}
