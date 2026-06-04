import 'package:virtuomate_flutter/external/subscription_result.dart';

abstract class SubscriptionGateway {
  Future<PremiumSubscribeOutcome> activateSubscription({
    required String userEmail,
    String planId = 'annual',
  });
}

class DemoSubscriptionGateway implements SubscriptionGateway {
  @override
  Future<PremiumSubscribeOutcome> activateSubscription({
    required String userEmail,
    String planId = 'annual',
  }) async {
    if (userEmail.isEmpty) return PremiumSubscribeOutcome.failed;
    return PremiumSubscribeOutcome.activated;
  }
}
