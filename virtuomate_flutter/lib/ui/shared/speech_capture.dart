import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

/// Reliable mic + speech-to-text for interview and coaching screens.
class SpeechCapture {
  SpeechCapture() : _speech = stt.SpeechToText();

  final stt.SpeechToText _speech;
  bool _initialized = false;
  String? _localeId;

  bool get isAvailable => _initialized;

  Future<bool> prepare() async {
    _initialized = await _speech.initialize(
      onError: (_) {},
      onStatus: (_) {},
    );
    if (!_initialized) return false;

    final locales = await _speech.locales();
    final en = locales.where((l) => l.localeId.startsWith('en')).toList();
    if (en.isNotEmpty) {
      _localeId = en.first.localeId;
    } else if (locales.isNotEmpty) {
      _localeId = locales.first.localeId;
    }
    return true;
  }

  Future<bool> ensureMicrophonePermission() async {
    if (kIsWeb) return true;
    var status = await Permission.microphone.status;
    if (status.isGranted) return true;
    status = await Permission.microphone.request();
    if (status.isGranted) return true;
    if (status.isPermanentlyDenied) {
      await openAppSettings();
    }
    return false;
  }

  Future<bool> startListening({
    required void Function(String words, bool isFinal) onWords,
    void Function(double level)? onSoundLevel,
    void Function(String message)? onError,
  }) async {
    if (!_initialized) {
      final ok = await prepare();
      if (!ok) {
        onError?.call('Speech recognition is not available on this device.');
        return false;
      }
    }

    final permitted = await ensureMicrophonePermission();
    if (!permitted) {
      onError?.call(
        'Microphone permission denied. Enable Microphone for VirtuoMate in Settings.',
      );
      return false;
    }

    if (!_speech.isNotListening) {
      await _speech.stop();
    }

    await _speech.listen(
      onResult: (result) {
        final words = result.recognizedWords.trim();
        if (words.isNotEmpty) {
          onWords(words, result.finalResult);
          return;
        }
        if (result.alternates.isNotEmpty) {
          final alt = result.alternates.first.recognizedWords.trim();
          if (alt.isNotEmpty) {
            onWords(alt, result.finalResult);
          }
        }
      },
      onSoundLevelChange: onSoundLevel,
      localeId: _localeId,
      listenOptions: stt.SpeechListenOptions(
        partialResults: true,
        cancelOnError: false,
      ),
    );
    return _speech.isListening;
  }

  Future<void> stop() => _speech.stop();

  bool get isListening => _speech.isListening;
}
