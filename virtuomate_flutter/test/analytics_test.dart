import 'package:flutter_test/flutter_test.dart';
import 'package:virtuomate_flutter/auth/auth_gateway.dart';
import 'package:virtuomate_flutter/core/models.dart';
import 'package:virtuomate_flutter/data/app_repository.dart';
import 'package:virtuomate_flutter/intelligence/coach_engine.dart';
import 'package:virtuomate_flutter/external/subscription_gateway.dart';
import 'package:virtuomate_flutter/services/app_service.dart';

void main() {
  test('analytics averages confidence from saved sessions', () async {
    final repo = InMemoryAppRepository();
    final service = AppService(
      repository: repo,
      authGateway: InMemoryAuthGateway(),
      coachEngine: MockCoachEngine(),
      subscriptionGateway: DemoSubscriptionGateway(),
    );
    repo.saveSession(
      SessionRecord(
        type: 'Conversation',
        prompt: 'a',
        feedback: 'f',
        emotion: 'Confident',
        confidenceScore: 80,
      ),
    );
    repo.saveSession(
      SessionRecord(
        type: 'Conversation',
        prompt: 'b',
        feedback: 'f',
        emotion: 'Happy',
        confidenceScore: 60,
      ),
    );
    final a = service.analytics();
    expect(a.conversationSessions, 2);
    expect(a.avgConfidence, 70);
    expect(a.avgEngagement, greaterThan(0));
  });
}
