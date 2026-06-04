import 'package:url_launcher/url_launcher.dart';
import 'package:virtuomate_flutter/external/subscription_gateway.dart';
import 'package:virtuomate_flutter/external/subscription_result.dart';
import 'package:virtuomate_flutter/network/api_client.dart';

class ApiSubscriptionGateway implements SubscriptionGateway {
  ApiSubscriptionGateway(this._api);

  final ApiClient _api;

  @override
  Future<PremiumSubscribeOutcome> activateSubscription({
    required String userEmail,
    String planId = 'annual',
  }) async {
    final response = await _api.postJson('/payments/subscribe', {
      'userEmail': userEmail,
      'planId': planId,
    });
    final checkoutUrl = response['checkoutUrl'] as String?;
    if (checkoutUrl != null && checkoutUrl.isNotEmpty) {
      final uri = Uri.parse(checkoutUrl);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
      return PremiumSubscribeOutcome.checkoutOpened;
    }
    if (response['success'] == true) {
      return PremiumSubscribeOutcome.activated;
    }
    return PremiumSubscribeOutcome.failed;
  }
}
