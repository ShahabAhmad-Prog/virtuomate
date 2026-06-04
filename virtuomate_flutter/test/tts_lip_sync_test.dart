import 'package:flutter_test/flutter_test.dart';
import 'package:virtuomate_flutter/services/tts_lip_sync.dart';

void main() {
  group('mouthOpenForWord', () {
    test('vowel-heavy words open wider', () {
      expect(mouthOpenForWord('hello'), greaterThan(mouthOpenForWord('xyz')));
    });

    test('empty word is nearly closed', () {
      expect(mouthOpenForWord(''), lessThan(0.4));
    });
  });
}
