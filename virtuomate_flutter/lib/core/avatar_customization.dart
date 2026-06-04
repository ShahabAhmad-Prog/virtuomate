const kVoiceGenderMale = 'male';
const kVoiceGenderFemale = 'female';

/// Persona (visual / cartoon) and coach tone (voice + delivery) for avatar builder.
class AvatarPersonaOption {  const AvatarPersonaOption({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.defaultToneId,
  });

  final String id;
  final String title;
  final String subtitle;
  final String defaultToneId;
}

class CoachToneOption {
  const CoachToneOption({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.sampleLine,
    required this.speechRate,
    required this.pitch,
  });

  final String id;
  final String title;
  final String subtitle;
  final String sampleLine;
  final double speechRate;
  final double pitch;
}

const kAvatarPersonas = <AvatarPersonaOption>[
  AvatarPersonaOption(
    id: 'Professional',
    title: 'Professional',
    subtitle: 'Business-casual look · polished, trustworthy coach',
    defaultToneId: 'formal-mentor',
  ),
  AvatarPersonaOption(
    id: 'Friendly',
    title: 'Friendly',
    subtitle: 'Warm smile · approachable peer-to-peer coaching',
    defaultToneId: 'warm-coach',
  ),
  AvatarPersonaOption(
    id: 'Executive',
    title: 'Executive',
    subtitle: 'Sharp formal presence · boardroom-ready delivery',
    defaultToneId: 'authoritative-lead',
  ),
  AvatarPersonaOption(
    id: 'Creative',
    title: 'Creative',
    subtitle: 'Expressive style · energetic, modern mentor',
    defaultToneId: 'energetic-guide',
  ),
];

const kCoachTones = <CoachToneOption>[
  CoachToneOption(
    id: 'confident-neutral',
    title: 'Balanced & natural',
    subtitle: 'Clear, steady pace — feels like a real 1:1 coach',
    sampleLine:
        'That was a solid start. Let me suggest one small change to make your answer land even better.',
    speechRate: 0.45,
    pitch: 1.0,
  ),
  CoachToneOption(
    id: 'warm-coach',
    title: 'Warm & encouraging',
    subtitle: 'Friendly uplift — great for interviews and first sessions',
    sampleLine:
        'You are doing well. Take a breath, then try that opening line once more with confidence.',
    speechRate: 0.47,
    pitch: 1.05,
  ),
  CoachToneOption(
    id: 'formal-mentor',
    title: 'Polished & professional',
    subtitle: 'Measured and precise — suits corporate and client-facing roles',
    sampleLine:
        'Structure your response in three parts: context, your action, and the measurable outcome.',
    speechRate: 0.42,
    pitch: 0.95,
  ),
  CoachToneOption(
    id: 'authoritative-lead',
    title: 'Clear & executive',
    subtitle: 'Lower pitch, deliberate pace — leadership and negotiations',
    sampleLine:
        'Lead with your recommendation. Support it with one fact, then pause for impact.',
    speechRate: 0.4,
    pitch: 0.9,
  ),
  CoachToneOption(
    id: 'energetic-guide',
    title: 'Upbeat & motivating',
    subtitle: 'Brighter delivery — presentations and pitch practice',
    sampleLine:
        'Strong energy. Now sharpen the hook in your first ten seconds to pull the audience in.',
    speechRate: 0.52,
    pitch: 1.1,
  ),
  CoachToneOption(
    id: 'calm-reassuring',
    title: 'Calm & reassuring',
    subtitle: 'Slower, softer — reduces anxiety before high-stakes moments',
    sampleLine:
        'There is no rush. Focus on one idea at a time, and speak as if you are explaining to a colleague.',
    speechRate: 0.38,
    pitch: 0.92,
  ),
  CoachToneOption(
    id: 'conversational-peer',
    title: 'Conversational peer',
    subtitle: 'Casual rhythm — role-play and everyday dialogue practice',
    sampleLine:
        'Okay, I hear you. How would you respond if they pushed back on your timeline?',
    speechRate: 0.48,
    pitch: 1.02,
  ),
  CoachToneOption(
    id: 'empathetic-listener',
    title: 'Empathetic listener',
    subtitle: 'Gentle and reflective — emotional intelligence and soft skills',
    sampleLine:
        'It sounds like that was challenging. What would you want them to understand about your perspective?',
    speechRate: 0.44,
    pitch: 0.98,
  ),
];

AvatarPersonaOption? avatarPersonaById(String id) {
  for (final p in kAvatarPersonas) {
    if (p.id == id) return p;
  }
  return null;
}

CoachToneOption? coachToneById(String id) {
  for (final t in kCoachTones) {
    if (t.id == id) return t;
  }
  return null;
}

String coachToneDisplayTitle(String id) =>
    coachToneById(id)?.title ?? id.replaceAll('-', ' ');

String defaultToneForPersona(String personaId) =>
    avatarPersonaById(personaId)?.defaultToneId ?? 'confident-neutral';

/// Tones commonly paired with a deeper male-presenting coach voice.
const kMaleCoachToneIds = <String>[
  'confident-neutral',
  'formal-mentor',
  'authoritative-lead',
  'energetic-guide',
  'conversational-peer',
];

/// Tones commonly paired with a warmer female-presenting coach voice.
const kFemaleCoachToneIds = <String>[
  'warm-coach',
  'calm-reassuring',
  'empathetic-listener',
  'confident-neutral',
  'conversational-peer',
];

List<CoachToneOption> coachTonesForGender(String gender) {
  final ids = gender == kVoiceGenderMale ? kMaleCoachToneIds : kFemaleCoachToneIds;
  return [
    for (final id in ids)
      if (coachToneById(id) != null) coachToneById(id)!,
  ];
}

double pitchForGender(double basePitch, String gender) {
  // Android TTS only accepts pitch 0.5–2.0; lower values are ignored silently.
  if (gender == kVoiceGenderMale) {
    return (basePitch * 0.78).clamp(0.5, 0.82);
  }
  if (gender == kVoiceGenderFemale) {
    return (basePitch * 1.05).clamp(0.85, 1.2);
  }
  return basePitch.clamp(0.5, 2.0);
}

String voiceGenderDisplayLabel(String gender) {
  switch (gender) {
    case kVoiceGenderMale:
      return 'Male';
    case kVoiceGenderFemale:
      return 'Female';
    default:
      return gender;
  }
}

String coachVoiceSummary({
  required String gender,
  required String toneId,
}) =>
    '${voiceGenderDisplayLabel(gender)} · ${coachToneDisplayTitle(toneId)}';