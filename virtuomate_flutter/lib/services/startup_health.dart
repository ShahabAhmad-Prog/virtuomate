import 'package:virtuomate_flutter/core/neural_connectivity.dart';
import 'package:virtuomate_flutter/network/api_client.dart';
import 'package:virtuomate_flutter/services/neural_connectivity_service.dart';

/// Verifies the deployed Cloud Functions API and returns neural stack status.
Future<NeuralConnectivityStatus> verifyBackendHealth(ApiClient client) async {
  try {
    final status = await NeuralConnectivityService(client).fetchStatus();
    if (status.errorMessage != null && status.percent == 0) {
      throw Exception(status.errorMessage);
    }
    return status;
  } catch (e) {
    final msg = e.toString();
    if (msg.contains('SocketException') || msg.contains('Failed host lookup')) {
      throw Exception(
        'Cannot reach VirtuoMate cloud API. Check your internet connection.',
      );
    }
    if (e is Exception && !msg.contains('SocketException')) {
      rethrow;
    }
    throw Exception(
      'VirtuoMate API is unavailable. Ensure Cloud Functions are deployed.',
    );
  }
}
