import 'package:flutter_test/flutter_test.dart';
import 'package:virtuomate_flutter/ui/shared/form_validators.dart';

void main() {
  group('validateEmail', () {
    test('rejects empty', () {
      expect(validateEmail(''), isNotNull);
      expect(validateEmail(null), isNotNull);
    });
    test('accepts valid emails', () {
      expect(validateEmail('user@example.com'), isNull);
      expect(validateEmail('demo@virtuomate.app'), isNull);
    });
    test('rejects invalid', () {
      expect(validateEmail('not-an-email'), isNotNull);
      expect(validateEmail('@missing.com'), isNotNull);
    });
  });

  group('validatePassword', () {
    test('requires min length 6', () {
      expect(validatePassword('12345'), isNotNull);
      expect(validatePassword('123456'), isNull);
    });
  });
}
