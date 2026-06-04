import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:virtuomate_flutter/core/avatar_customization.dart';

typedef _VoiceMap = Map<String, String>;

/// Known Google/Android male voice name fragments (exact [setVoice] match).
const _androidMaleVoiceCandidates = <String>[
  'en-us-x-sfg#male_1-local',
  'en-us-x-sfg#male_2-local',
  'en-us-x-iom-local',
  'en-us-x-iom-network',
  'en-gb-x-rjs#male_1-local',
  'en-gb-x-rjs#male_2-local',
  'en-au-x-aua-local',
];

bool _ttsEngineReady = false;

Future<void> _ensureAndroidGoogleEngine(FlutterTts tts) async {
  if (!Platform.isAndroid || _ttsEngineReady) return;
  try {
    final engines = await tts.getEngines;
    if (engines is List) {
      for (final raw in engines) {
        final id = raw.toString();
        if (id.contains('google')) {
          await tts.setEngine('com.google.android.tts');
          await Future<void>.delayed(const Duration(milliseconds: 400));
          break;
        }
      }
    }
    _ttsEngineReady = true;
  } catch (_) {
    _ttsEngineReady = true;
  }
}

/// Picks a system TTS voice for [voiceGender] from [FlutterTts.getVoices].
Future<String?> applySystemVoiceForGender(FlutterTts tts, String voiceGender) async {
  if (kIsWeb) return null;

  if (Platform.isAndroid) {
    await _ensureAndroidGoogleEngine(tts);
  }

  try {
    await tts.setLanguage('en-US');
  } catch (_) {}

  try {
    final raw = await tts.getVoices;
    if (raw is! List || raw.isEmpty) return null;

    final voices = raw.whereType<Map>().map((v) {
      return Map<String, String>.from(
        v.map((key, value) => MapEntry(key.toString(), value.toString())),
      );
    }).toList();

    final english = voices.where((v) {
      final locale = (v['locale'] ?? v['name'] ?? '').toLowerCase();
      return locale.startsWith('en');
    }).toList();
    final pool = english.isNotEmpty ? english : voices;

    final chosen = _pickBestVoice(pool, voiceGender);
    if (chosen == null || (chosen['name'] ?? '').isEmpty) return null;

    final payload = <String, String>{
      'name': chosen['name']!,
      'locale': chosen['locale'] ?? 'en-US',
    };
    final id = chosen['identifier']?.trim();
    if (id != null && id.isNotEmpty) {
      payload['identifier'] = id;
    }

    await tts.setVoice(payload);
    return chosen['name'];
  } catch (_) {
    return null;
  }
}

_VoiceMap? _pickBestVoice(List<_VoiceMap> pool, String voiceGender) {
  if (pool.isEmpty) return null;

  if (voiceGender == kVoiceGenderMale) {
    for (final candidate in _androidMaleVoiceCandidates) {
      for (final voice in pool) {
        if ((voice['name'] ?? '') == candidate) return voice;
      }
    }
  }

  for (final voice in pool) {
    if (_platformGender(voice) == voiceGender) return voice;
  }

  _VoiceMap? best;
  var bestScore = -999999;
  for (final voice in pool) {
    final score = _scoreVoice(voice, voiceGender);
    if (score > bestScore) {
      bestScore = score;
      best = voice;
    }
  }

  if (voiceGender == kVoiceGenderMale) {
    if (bestScore >= 50 && best != null) return best;
    for (final voice in pool) {
      if (!_isFemaleVoice(voice)) return voice;
    }
    return null;
  }

  if (voiceGender == kVoiceGenderFemale) {
    if (bestScore >= 50 && best != null) return best;
    for (final voice in pool) {
      if (_isFemaleVoice(voice)) return voice;
    }
  }

  return bestScore > 0 ? best : null;
}

String? _platformGender(_VoiceMap voice) {
  final g = (voice['gender'] ?? '').toLowerCase();
  if (g.contains('female')) return kVoiceGenderFemale;
  if (g.contains('male')) return kVoiceGenderMale;
  return null;
}

int _scoreVoice(_VoiceMap voice, String voiceGender) {
  final platform = _platformGender(voice);
  if (platform == voiceGender) return 500;

  final features = (voice['features'] ?? '').toLowerCase();
  if (voiceGender == kVoiceGenderMale) {
    if (_isFemaleVoice(voice)) return -1000;
    var score = 0;
    if (features.contains('male') && !features.contains('female')) score += 300;
    final blob = _voiceBlob(voice);
    if (blob.contains('#male')) score += 200;
    if (RegExp(r'male[_\d-]').hasMatch(blob)) score += 150;
    for (final hint in _maleNameHints) {
      if (blob.contains(hint)) score += 40;
    }
    return score;
  }

  if (voiceGender == kVoiceGenderFemale) {
    if (_isMaleVoice(voice)) return -1000;
    var score = 0;
    if (features.contains('female')) score += 300;
    final blob = _voiceBlob(voice);
    if (blob.contains('#female')) score += 200;
    for (final hint in _femaleNameHints) {
      if (blob.contains(hint)) score += 40;
    }
    return score;
  }

  return 0;
}

String _voiceBlob(_VoiceMap voice) =>
    '${voice['name'] ?? ''} ${voice['locale'] ?? ''} ${voice['identifier'] ?? ''}'
        .toLowerCase();

bool _isFemaleVoice(_VoiceMap voice) {
  final platform = _platformGender(voice);
  if (platform == kVoiceGenderFemale) return true;
  if (platform == kVoiceGenderMale) return false;

  final features = (voice['features'] ?? '').toLowerCase();
  if (features.contains('female')) return true;
  if (features.contains('male') && !features.contains('female')) return false;

  final blob = _voiceBlob(voice);
  if (blob.contains('#male') ||
      blob.contains('male_') ||
      RegExp(r'male\d').hasMatch(blob)) {
    return false;
  }
  if (blob.contains('#female') ||
      blob.contains('female_') ||
      RegExp(r'female\d').hasMatch(blob)) {
    return true;
  }
  for (final hint in _femaleNameHints) {
    if (blob.contains(hint)) return true;
  }
  return false;
}

bool _isMaleVoice(_VoiceMap voice) {
  final platform = _platformGender(voice);
  if (platform == kVoiceGenderMale) return true;
  if (platform == kVoiceGenderFemale) return false;

  final features = (voice['features'] ?? '').toLowerCase();
  if (features.contains('male') && !features.contains('female')) return true;

  if (_isFemaleVoice(voice)) return false;
  final blob = _voiceBlob(voice);
  return blob.contains('#male') ||
      blob.contains('male_') ||
      RegExp(r'male\d').hasMatch(blob);
}

const _maleNameHints = <String>[
  'microsoft david',
  'microsoft mark',
  'microsoft george',
  'microsoft guy',
  'microsoft ryan',
  'daniel',
  'james',
  'david',
  'aaron',
  'arthur',
  'fred',
  'gordon',
  'martin',
  'rjs',
];

const _femaleNameHints = <String>[
  'microsoft zira',
  'microsoft aria',
  'microsoft jenny',
  'microsoft susan',
  'samantha',
  'karen',
  'zira',
  'victoria',
  'moira',
  'tessa',
  'fis',
];
