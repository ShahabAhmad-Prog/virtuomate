import 'package:flutter/material.dart';
import 'package:virtuomate_flutter/ui/virtuomate_scope.dart';

class AppText {
  static const String languageEnglish = 'en';
  static const String languageUrdu = 'ur';

  /// Urdu is partially translated; keep LTR shell so mixed EN/UR layouts stay stable.
  static bool isUrdu(Locale locale) => locale.languageCode == languageUrdu;

  static TextDirection textDirectionFor(Locale locale) => TextDirection.ltr;

  static const Map<String, Map<String, String>> _strings = {
    'en': {
      'app_name': 'VirtuoMate',
      'login': 'Login',
      'register': 'Register',
      'dashboard': 'Home Dashboard',
      'avatar_builder': 'Avatar Builder',
      'conversational_session': 'Conversational Session',
      'role_play': 'Role Play',
      'video_cv': 'Video CV',
      'feedback': 'Feedback',
      'premium': 'Premium',
      'analytics': 'Analytics',
      'settings': 'Settings',
      'logout': 'Logout',
      'admin_user_mgmt': 'Admin: User Management',
      'admin_training_analytics': 'Admin: Training Session Analytics',
      'accessibility_localization': 'Accessibility & Localization',
      'language': 'Language',
      'high_contrast': 'High contrast mode',
      'not_logged_in': 'Not logged in',
      'last_updated': 'Last updated',
      'privacy_data': 'Privacy & Data Controls',
      'export_data': 'Export My Data',
      'delete_account': 'Delete My Account',
      'confirm_delete': 'Are you sure you want to permanently delete your account?',
      'cancel': 'Cancel',
      'confirm': 'Confirm',
      'welcome_subtitle':
          'SRS aligned Flutter frontend for coaching, avatar, and video CV modules.',
      'language_partial_note':
          'Urdu translation is partial. Coaching, voice, and Video CV stay in English for now.',
      'language_changed': 'Language updated',
      'profile': 'Profile',
      'edit_profile': 'Edit Profile',
      'change_photo': 'Change Photo',
      'manage_prefs': 'Manage your neural interface preferences',
      'english': 'English',
      'urdu': 'Urdu',
      'plan': 'Plan',
      'upgrade': 'Upgrade',
    },
    'ur': {
      'app_name': 'ورچو میٹ',
      'login': 'لاگ ان',
      'register': 'رجسٹر',
      'dashboard': 'ہوم ڈیش بورڈ',
      'avatar_builder': 'اوتار بلڈر',
      'conversational_session': 'گفتگو سیشن',
      'role_play': 'رول پلے',
      'video_cv': 'ویڈیو سی وی',
      'feedback': 'فیڈبیک',
      'premium': 'پریمیم',
      'analytics': 'تجزیات',
      'settings': 'سیٹنگز',
      'logout': 'لاگ آؤٹ',
      'admin_user_mgmt': 'ایڈمن: صارف مینجمنٹ',
      'admin_training_analytics': 'ایڈمن: ٹریننگ تجزیات',
      'accessibility_localization': 'رسائی اور زبان',
      'language': 'زبان',
      'high_contrast': 'ہائی کنٹراسٹ موڈ',
      'not_logged_in': 'لاگ ان نہیں',
      'last_updated': 'آخری اپڈیٹ',
      'privacy_data': 'رازداری اور ڈیٹا کنٹرول',
      'export_data': 'میرا ڈیٹا ایکسپورٹ کریں',
      'delete_account': 'میرا اکاؤنٹ حذف کریں',
      'confirm_delete': 'کیا آپ واقعی اپنا اکاؤنٹ مستقل طور پر حذف کرنا چاہتے ہیں؟',
      'cancel': 'منسوخ',
      'confirm': 'تصدیق',
      'welcome_subtitle':
          'ایس آر ایس کے مطابق کوچنگ، اوتار اور ویڈیو سی وی ماڈیولز کے لیے فلٹر فرنٹ اینڈ۔',
      'language_partial_note':
          'اردو ترجمہ جزوی ہے۔ کوچنگ، آواز اور ویڈیو سی وی فی الحال انگریزی میں ہیں۔',
      'language_changed': 'زبان اپڈیٹ ہو گئی',
      'profile': 'پروفائل',
      'edit_profile': 'پروفائل میں ترمیم',
      'change_photo': 'تصویر بدلیں',
      'manage_prefs': 'اپنی ترجیحات منظم کریں',
      'english': 'English',
      'urdu': 'اردو',
      'plan': 'پلان',
      'upgrade': 'اپ گریڈ',
    },
  };

  static String tr(BuildContext context, String key) {
    final locale = VirtuoMateScope.of(context).locale.languageCode;
    final localized = _strings[locale]?[key];
    if (localized != null) return localized;
    return _strings['en']?[key] ?? key;
  }

  static String formatDateTime(BuildContext context, DateTime value) {
    final locale = VirtuoMateScope.of(context).locale.languageCode;
    if (locale == 'ur') {
      return '${value.day.toString().padLeft(2, '0')}/${value.month.toString().padLeft(2, '0')}/${value.year} ${value.hour.toString().padLeft(2, '0')}:${value.minute.toString().padLeft(2, '0')}';
    }
    return '${value.year}-${value.month.toString().padLeft(2, '0')}-${value.day.toString().padLeft(2, '0')} ${value.hour.toString().padLeft(2, '0')}:${value.minute.toString().padLeft(2, '0')}';
  }
}
