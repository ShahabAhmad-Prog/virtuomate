import 'package:virtuomate_flutter/core/neural_connectivity.dart';
import 'package:virtuomate_flutter/network/api_client.dart';

class NeuralConnectivityService {
  NeuralConnectivityService(this._api);

  final ApiClient _api;

  Future<NeuralConnectivityStatus> fetchStatus() async {
    try {
      final res = await _api.getJson('/health');
      if (res['ok'] != true) {
        return NeuralConnectivityStatus(
          percent: 0,
          full: false,
          mode: 'api-error',
          layers: const [],
          errorMessage: 'API health check failed',
          lastChecked: DateTime.now(),
        );
      }
      return NeuralConnectivityStatus.fromHealthJson(res);
    } catch (e) {
      return NeuralConnectivityStatus(
        percent: 0,
        full: false,
        mode: 'unreachable',
        layers: const [],
        errorMessage: e.toString().replaceFirst('Exception: ', ''),
        lastChecked: DateTime.now(),
      );
    }
  }
}
