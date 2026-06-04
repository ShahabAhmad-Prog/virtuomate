import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

/// User-facing message for network / connection failures.
String friendlyConnectionError(Object error, {required String apiBaseUrl}) {
  final msg = error.toString().toLowerCase();
  final isLocal = apiBaseUrl.contains('127.0.0.1') ||
      apiBaseUrl.contains('10.0.2.2') ||
      apiBaseUrl.contains('localhost');

  if (msg.contains('timeoutexception') || msg.contains('timed out')) {
    return 'Request timed out. Video render can take 2–3 minutes — stay on Wi‑Fi and try again.';
  }

  if (msg.contains('connection refused') ||
      msg.contains('failed host lookup') ||
      msg.contains('unable to establish connection') ||
      msg.contains('socketexception') ||
      msg.contains('network is unreachable') ||
      msg.contains('connection reset')) {
    if (isLocal) {
      return 'Cannot reach local backend ($apiBaseUrl).\n'
          'In another terminal run:\n'
          'cd virtuomate_backend_firebase\n'
          'npm run dev\n'
          'Or use cloud API: .\\scripts\\run_dev.ps1 (no BACKEND_BASE_URL).';
    }
    return 'Cannot reach VirtuoMate cloud API.\n'
        'Check emulator internet (Wi‑Fi on), then run .\\scripts\\run_dev.ps1';
  }

  if (msg.contains('handshake') || msg.contains('certificate')) {
    return 'Secure connection to VirtuoMate API failed. Check device date/time and network.';
  }

  return error.toString().replaceFirst('Exception: ', '');
}
