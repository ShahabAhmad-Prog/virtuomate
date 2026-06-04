import 'dart:async' show Timer, unawaited;

import 'package:virtuomate_flutter/config/app_config.dart';
import 'package:virtuomate_flutter/services/app_service.dart';

/// Polls backend profile/sessions when Firestore realtime is unavailable (API mode).
class ProfileSyncService {
  ProfileSyncService(this._service, {this.interval = const Duration(seconds: 30)});

  final AppService _service;
  final Duration interval;
  Timer? _timer;
  void Function()? _onTick;

  bool get isRunning => _timer != null;

  void start(void Function() onDataChanged) {
    if (!AppConfig.useBackendApi) return;
    _onTick = onDataChanged;
    stop();
    _timer = Timer.periodic(interval, (_) => _pull());
    unawaited(_pull());
  }

  void stop() {
    _timer?.cancel();
    _timer = null;
  }

  Future<void> _pull() async {
    try {
      await _service.bootstrapUserProfile();
      _onTick?.call();
    } catch (_) {
      // Offline or token refresh — next tick retries.
    }
  }
}
