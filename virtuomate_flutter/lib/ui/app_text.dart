import 'package:flutter/material.dart';
import 'package:virtuomate_flutter/ui/virtuomate_scope.dart';

class AppText {
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
