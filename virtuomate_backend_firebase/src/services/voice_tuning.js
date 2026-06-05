/** Mirrors Flutter coach tones for cloud Video CV narration (post-process after gTTS). */
const COACH_TONES = {
  'confident-neutral': { speechRate: 0.45, pitch: 1.0 },
  'warm-coach': { speechRate: 0.47, pitch: 1.05 },
  'formal-mentor': { speechRate: 0.42, pitch: 0.95 },
  'authoritative-lead': { speechRate: 0.4, pitch: 0.88 },
  'energetic-guide': { speechRate: 0.52, pitch: 1.08 },
  'calm-reassuring': { speechRate: 0.43, pitch: 1.02 },
  'conversational-peer': { speechRate: 0.48, pitch: 1.0 },
  'empathetic-listener': { speechRate: 0.44, pitch: 0.98 },
};

function parseVoiceProfile(voiceProfile, voiceGender) {
  let gender = voiceGender === 'male' ? 'male' : 'female';
  let toneId = 'confident-neutral';
  const raw = String(voiceProfile || '').trim();
  if (raw.includes('|')) {
    const i = raw.indexOf('|');
    const prefix = raw.slice(0, i).toLowerCase();
    const tone = raw.slice(i + 1).trim();
    if (prefix === 'male' || prefix === 'female') gender = prefix;
    if (tone) toneId = tone;
  } else if (raw) {
    toneId = raw;
  }
  return { gender, toneId };
}

function narrationAudioFilters(voiceProfile, voiceGender) {
  const { gender, toneId } = parseVoiceProfile(voiceProfile, voiceGender);
  const tone = COACH_TONES[toneId] || COACH_TONES['confident-neutral'];
  let pitchMul = tone.pitch;
  if (gender === 'male') pitchMul *= 0.78;
  else pitchMul *= 1.05;
  const atempo = Math.min(1.35, Math.max(0.72, 0.45 / tone.speechRate));
  const asetrate = Math.round(44100 * pitchMul);
  return `asetrate=${asetrate},aresample=44100,atempo=${atempo.toFixed(3)}`;
}

module.exports = {
  COACH_TONES,
  parseVoiceProfile,
  narrationAudioFilters,
};
