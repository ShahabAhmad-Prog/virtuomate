import 'package:flutter_test/flutter_test.dart';
import 'package:virtuomate_flutter/auth/auth_gateway.dart';
import 'package:virtuomate_flutter/config/demo_account_config.dart';

void main() {
  late InMemoryAuthGateway gateway;

  setUp(() {
    gateway = InMemoryAuthGateway();
  });

  test('registerWithEmail creates user profile', () async {
    final user = await gateway.registerWithEmail(
      email: 'test@example.com',
      password: 'secret12',
      displayName: 'Tester',
    );
    expect(user.email, 'test@example.com');
    expect(gateway.currentUser()?.email, 'test@example.com');
  });

  test('signInWithEmail requires non-empty credentials', () async {
    expect(
      () => gateway.signInWithEmail(email: '', password: ''),
      throwsA(isA<Exception>()),
    );
  });

  test('demo email detection', () {
    expect(DemoAccountConfig.isDemoEmail('demo@virtuomate.app'), isTrue);
    expect(DemoAccountConfig.isDemoEmail('user@gmail.com'), isFalse);
  });
}
