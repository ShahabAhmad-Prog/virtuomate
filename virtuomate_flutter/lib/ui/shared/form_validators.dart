String? validateEmail(String? value) {
  final v = (value ?? '').trim();
  if (v.isEmpty) return 'Email is required.';
  final ok = RegExp(r'^[\w.\-+]+@[\w.\-]+\.[A-Za-z]{2,}$').hasMatch(v);
  if (!ok) return 'Enter a valid email address.';
  return null;
}

String? validatePassword(String? value, {int minLength = 6}) {
  final v = value ?? '';
  if (v.isEmpty) return 'Password is required.';
  if (v.length < minLength) {
    return 'Password must be at least $minLength characters.';
  }
  return null;
}

String? validateRequired(String? value, String label) {
  if ((value ?? '').trim().isEmpty) return '$label is required.';
  return null;
}
