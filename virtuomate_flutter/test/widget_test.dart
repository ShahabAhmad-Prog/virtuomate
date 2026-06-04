import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:virtuomate_flutter/ui/shared/virtuomate_logo.dart';

void main() {
  testWidgets('VirtuoMate logo widget builds', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Center(child: VirtuoMateLogo.welcome()),
        ),
      ),
    );
    await tester.pump();
    expect(find.byType(VirtuoMateLogo), findsOneWidget);
  });
}
