import 'package:shared_preferences/shared_preferences.dart';

/// Device-local language choice so profile sync cannot reset Urdu ↔ English.
class LocaleStorage {
  static const _key = 'virtuomate_language_code';

  static Future<String?> read() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString(_key);
    if (code == 'ur' || code == 'en') return code;
    return null;
  }

  static Future<void> write(String languageCode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, languageCode == 'ur' ? 'ur' : 'en');
  }
}
