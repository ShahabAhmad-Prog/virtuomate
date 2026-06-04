'use strict';

const layout = require('./video_cv_layout');

const fs = require('fs');const path = require('path');
const os = require('os');
const { promisify } = require('util');
const { execFile } = require('child_process');
const ffmpegPath = require('ffmpeg-static');

const readFile = promisify(fs.readFile);
const rm = promisify(fs.rm);

function execFfmpegToFile(args) {
  return new Promise((resolve, reject) => {
    execFile(ffmpegPath, args, { maxBuffer: 8 * 1024 * 1024 }, (err, stderr) => {
      if (err) reject(new Error(String(stderr || err.message)));
      else resolve();
    });
  });
}

/**
 * RMS loudness per video frame from narration audio (drives mouth openness).
 * @returns {Promise<number[]>} values 0..1, one per frame at [fps]
 */
async function decodeAudioEnvelope(audioPath, fps, durationSec) {
  const workDir = await fs.promises.mkdtemp(path.join(os.tmpdir(), 'vm-lip-'));
  const pcmPath = path.join(workDir, 'audio.pcm');
  const sampleRate = 16000;

  try {
    await execFfmpegToFile([
      '-y',
      '-i',
      audioPath,
      '-f',
      'f32le',
      '-ac',
      '1',
      '-ar',
      String(sampleRate),
      pcmPath,
    ]);

    const buf = await readFile(pcmPath);
    const sampleCount = Math.floor(buf.length / 4);
    const frameCount = Math.max(1, Math.ceil(durationSec * fps));
    const samplesPerFrame = sampleRate / fps;
    const raw = [];

    for (let f = 0; f < frameCount; f++) {
      let sum = 0;
      const start = Math.floor(f * samplesPerFrame);
      const end = Math.min(sampleCount, Math.floor((f + 1) * samplesPerFrame));
      const count = Math.max(1, end - start);
      for (let i = start; i < end; i++) {
        const v = buf.readFloatLE(i * 4);
        sum += v * v;
      }
      raw.push(Math.sqrt(sum / count));
    }

    const smooth = [];
    for (let i = 0; i < raw.length; i++) {
      const prev = raw[i - 1] ?? raw[i];
      const cur = raw[i];
      const next = raw[i + 1] ?? raw[i];
      smooth.push((prev + cur * 2 + next) / 4);
    }

    const peak = Math.max(...smooth.filter(Number.isFinite), 0.0001);
    let level = 0;
    const envelope = smooth.map((v) => {
      const safe = Number.isFinite(v) ? v : 0;
      const n = Math.min(1, (safe / peak) ** 0.5 * 1.1);
      const target = n < 0.04 ? 0 : n;
      const coeff = target > level ? 0.5 : 0.18;
      level += coeff * (target - level);
      return Number.isFinite(level) ? level : 0;
    });

    return envelope;
  } finally {
    await rm(workDir, { recursive: true, force: true }).catch(() => {});
  }
}

/** Derive mouth motion strength + syllable rate from audio envelope. */
function envelopeMotionParams(envelope, fps) {
  if (!envelope.length) {
    return { rate: 6.5, wAmp: 0.16, hAmp: 0.48 };
  }
  const mean = envelope.reduce((a, b) => a + b, 0) / envelope.length;
  let peaks = 0;
  for (let i = 1; i < envelope.length - 1; i++) {
    if (envelope[i] > 0.18 && envelope[i] >= envelope[i - 1] && envelope[i] > envelope[i + 1]) {
      peaks += 1;
    }
  }
  const durationSec = envelope.length / fps;
  const syllablesPerSec = durationSec > 0 ? peaks / durationSec : 4;
  const rate = Math.min(9, Math.max(4.5, syllablesPerSec * 1.15 + 2));
  const energy = Math.min(1, mean * 1.35 + 0.15);
  return {
    rate: rate.toFixed(2),
    wAmp: (0.12 + energy * 0.14).toFixed(3),
    hAmp: (0.35 + energy * 0.35).toFixed(3),
  };
}

/**
 * Proven FFmpeg graph: lower-face strip scales with eval=frame (works on looped PNG input).
 */
function buildTalkFilter({ rate, wAmp, hAmp, mouthH = layout.MOUTH_H, mouthY = layout.MOUTH_Y } = {}) {
  const feather = 18;
  const s = layout.AVATAR_SIZE;
  const motion = `abs(sin(2*PI*t*${rate}))+0.35*abs(sin(2*PI*t*${rate}*0.5))`;
  return [
    `[2:v]scale=${s}:${s}:force_original_aspect_ratio=decrease,pad=${s}:${s}:(ow-iw)/2:(oh-ih)/2,setsar=1,fps=30[av]`,
    '[av]split=2[av_static][av_mouth_src]',
    `[av_mouth_src]crop=${s}:${mouthH}:0:${mouthY}[mouth]`,
    `[mouth]scale=w='iw*(1+${wAmp}*(${motion}))':h='ih*(1+${hAmp}*(${motion}))':eval=frame[mouth_scaled]`,
    `[mouth_scaled]format=yuva420p,geq=r='r(X,Y)':g='g(X,Y)':b='b(X,Y)':a='255*min(min(Y/${feather}\\,(${mouthH}-Y)/${feather})\\,1)'[mouth_soft]`,
    `[av_static][mouth_soft]overlay=0:${mouthY}[av_talk]`,
    `[0:v][av_talk]overlay=${layout.AVATAR_X}:${layout.AVATAR_Y}[outv]`,
  ].join(';');
}

/** Lip-sync tuned from narration audio envelope (rate + amplitude). */
function buildAudioDrivenLipSyncFilter(envelope, fps, opts = {}) {
  return buildTalkFilter({ ...envelopeMotionParams(envelope, fps), ...opts });
}

/** Visible speech rhythm when audio envelope decode fails. */
function buildRhythmLipSyncFilter(opts = {}) {
  return buildTalkFilter({ rate: '6.5', wAmp: '0.16', hAmp: '0.48', ...opts });
}

module.exports = {
  decodeAudioEnvelope,
  envelopeMotionParams,
  buildTalkFilter,
  buildAudioDrivenLipSyncFilter,
  buildRhythmLipSyncFilter,
};
