import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:virtuomate_flutter/ui/app.dart';

/// Device smoke: launch → login screen → demo login → dashboard.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('device smoke: demo login reaches dashboard', (tester) async {
    await tester.pumpWidget(const VirtuoMateRoot());
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle(const Duration(seconds: 45));

    // Welcome or login (if session restored)
    if (find.text('Initialize System').evaluate().isNotEmpty) {
      await tester.tap(find.text('Initialize System'));
      await tester.pumpAndSettle(const Duration(seconds: 15));
    }

    if (find.text('Try demo login').evaluate().isNotEmpty) {
      await tester.tap(find.text('Try demo login').first);
      await tester.pumpAndSettle(const Duration(seconds: 60));
    }

    // Dashboard markers
    expect(
      find.text('Your AI Coach').evaluate().isNotEmpty ||
          find.text('Initialize AI Session').evaluate().isNotEmpty ||
          find.text('Open Coach Chat').evaluate().isNotEmpty,
      isTrue,
      reason: 'Expected dashboard after demo login',
    );
  });
}
