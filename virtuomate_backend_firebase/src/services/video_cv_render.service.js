'use strict';

const fs = require('fs');
const path = require('path');
const os = require('os');
const { promisify } = require('util');
const { execFile } = require('child_process');
const ffmpegPath = require('ffmpeg-static');
const gTTS = require('gtts');
const lipSync = require('./audio_lipsync');
const layout = require('./video_cv_layout');
const { narrationAudioFilters } = require('./voice_tuning');

const writeFile = promisify(fs.writeFile);
const rm = promisify(fs.rm);
const copyFile = promisify(fs.copyFile);

function escapeDrawtextPath(filePath) {
  return filePath.replace(/\\/g, '/').replace(/:/g, '\\:').replace(/'/g, "\\'");
}

function resolveAssetPath(relativeParts) {
  const candidates = [
    path.join(__dirname, '../../', ...relativeParts),
    path.join(process.cwd(), ...relativeParts),
  ];
  for (const candidate of candidates) {
    if (fs.existsSync(candidate)) return candidate;
  }
  return null;
}

function resolveDrawtextFontPath() {
  return (
    resolveAssetPath(['assets', 'fonts', 'Arial.ttf']) ||
    resolveAssetPath(['assets', 'fonts', 'DejaVuSans.ttf'])
  );
}

function resolveSlideBackgroundPath() {
  const bg = resolveAssetPath(['assets', 'video-cv', 'slide-bg-1280x720.png']);
  if (!bg) {
    throw new Error('Missing slide background asset (assets/video-cv/slide-bg-1280x720.png)');
  }
  return bg;
}

/** Copy bundled assets into workDir so FFmpeg sees simple paths (important on Windows + Cloud). */
async function stageAssets(workDir) {
  const fontSrc = resolveDrawtextFontPath();
  const bgSrc = resolveSlideBackgroundPath();
  const bgPath = path.join(workDir, 'bg.png');
  await copyFile(bgSrc, bgPath);
  let fontPath = '';
  if (fontSrc) {
    fontPath = path.join(workDir, 'font.ttf');
    await copyFile(fontSrc, fontPath);
  }
  return { bgPath, fontPath };
}

function drawtext(fontEsc, params) {
  const prefix = fontEsc ? `fontfile='${fontEsc}':` : '';
  return `drawtext=${prefix}${params}`;
}

function sanitizeText(s, maxLen = 800) {
  return String(s || '')
    .replace(/[\r\n]+/g, ' ')
    .replace(/[^\x20-\x7E]/g, ' ')
    .trim()
    .slice(0, maxLen);
}

async function synthesizeSpeechMp3(text, outPath, { voiceProfile, voiceGender } = {}) {
  const chunk = sanitizeText(text, 3500);
  if (!chunk) throw new Error('Empty narration script');
  const rawPath = outPath.replace(/\.mp3$/i, '.raw.mp3');
  await new Promise((resolve, reject) => {
    const tts = new gTTS(chunk, 'en');
    tts.save(rawPath, (err) => (err ? reject(new Error(`TTS failed: ${err.message || err}`)) : resolve()));
  });
  try {
    const filter = narrationAudioFilters(voiceProfile, voiceGender);
    await execFfmpeg(['-y', '-i', rawPath, '-filter:a', filter, outPath]);
  } catch (err) {
    await copyFile(rawPath, outPath);
    // eslint-disable-next-line no-console
    console.warn('Voice tuning filter failed, using default gTTS audio:', err.message || err);
  } finally {
    try {
      await rm(rawPath, { force: true });
    } catch (_) {
      /* ignore */
    }
  }
}

function execFfmpeg(args) {
  return new Promise((resolve, reject) => {
    execFile(ffmpegPath, args, { maxBuffer: 24 * 1024 * 1024 }, (err, stdout, stderr) => {
      if (err) {
        const detail = stderr?.toString?.() || err.message;
        reject(new Error(detail.trim() || 'ffmpeg failed'));
        return;
      }
      resolve(stdout);
    });
  });
}

function execFfmpegStderr(args) {
  return new Promise((resolve, reject) => {
    execFile(ffmpegPath, args, { maxBuffer: 24 * 1024 * 1024 }, (err, stdout, stderr) => {
      const text = `${stderr || ''}${stdout || ''}`;
      if (err && !text.includes('Duration:')) {
        reject(new Error(text.trim() || err.message));
        return;
      }
      resolve(text);
    });
  });
}

async function probeDurationSeconds(audioPath) {
  const output = await execFfmpegStderr(['-hide_banner', '-i', audioPath]);
  const match = output.match(/Duration:\s*(\d+):(\d+):(\d+(?:\.\d+)?)/);
  if (!match) throw new Error('Could not read narration audio duration');
  const hours = Number(match[1]);
  const minutes = Number(match[2]);
  const seconds = Number(match[3]);
  const total = hours * 3600 + minutes * 60 + seconds;
  if (!Number.isFinite(total) || total <= 0) throw new Error('Invalid audio duration');
  return Math.min(Math.ceil(total) + 1, 600);
}

async function downloadAvatarImage(url, destPath) {
  if (!url || typeof url !== 'string') return false;
  const trimmed = url.trim();
  if (trimmed.startsWith('file://')) {
    const { fileURLToPath } = require('url');
    const local = fileURLToPath(trimmed);
    await copyFile(local, destPath);
    return true;
  }
  if (!/^https?:\/\//i.test(trimmed)) return false;
  const res = await fetch(trimmed, { redirect: 'follow' });
  if (!res.ok) throw new Error(`Avatar download HTTP ${res.status}`);
  const buf = Buffer.from(await res.arrayBuffer());
  if (buf.length < 200) throw new Error('Avatar image too small');
  await writeFile(destPath, buf);
  return true;
}

function buildDrawtextFilters({ fontEsc, titleEsc, headlineEsc, scriptEsc, withAvatar }) {
  if (withAvatar) {
    return [
      drawtext(fontEsc, "text='VirtuoMate Video CV':fontsize=24:fontcolor=0x3BE7FF:x=(w-text_w)/2:y=28"),
      drawtext(
        fontEsc,
        `textfile='${titleEsc}':fontsize=40:fontcolor=white:x=(w-text_w)/2:y=548:box=1:boxcolor=0x00000088:boxborderw=18`,
      ),
      drawtext(fontEsc, `textfile='${headlineEsc}':fontsize=24:fontcolor=0xCCCCCC:x=(w-text_w)/2:y=602`),
      drawtext(
        fontEsc,
        `textfile='${scriptEsc}':fontsize=18:fontcolor=white:x=(w-text_w)/2:y=636:line_spacing=4:box=1:boxcolor=0x00000066:boxborderw=12`,
      ),
    ].join(',');
  }
  const nameY = 100;
  const headlineY = 180;
  return [
    drawtext(fontEsc, "text='VirtuoMate Video CV':fontsize=26:fontcolor=0x3BE7FF:x=40:y=32"),
    drawtext(fontEsc, `textfile='${titleEsc}':fontsize=46:fontcolor=white:x=40:y=${nameY}`),
    drawtext(fontEsc, `textfile='${headlineEsc}':fontsize=26:fontcolor=0xCCCCCC:x=40:y=${headlineY}`),
    drawtext(
      fontEsc,
      `textfile='${scriptEsc}':fontsize=22:fontcolor=white:x=64:y=260:line_spacing=6:box=1:boxcolor=0x00000055:boxborderw=12`,
    ),
  ].join(',');
}

function buildCenteredDrawtextFilters({ fontEsc, titleEsc, headlineEsc, scriptEsc }) {
  return [
    drawtext(fontEsc, "text='VirtuoMate Video CV':fontsize=28:fontcolor=0x3BE7FF:x=(w-text_w)/2:y=36"),
    drawtext(fontEsc, `textfile='${titleEsc}':fontsize=52:fontcolor=white:x=(w-text_w)/2:y=100`),
    drawtext(fontEsc, `textfile='${headlineEsc}':fontsize=30:fontcolor=0xCCCCCC:x=(w-text_w)/2:y=180`),
    drawtext(
      fontEsc,
      `textfile='${scriptEsc}':fontsize=24:fontcolor=white:x=64:y=260:box=1:boxcolor=0x00000055:boxborderw=14`,
    ),
  ].join(',');
}

function mp4VideoCodecArgs() {
  return ['-c:v', 'libx264', '-preset', 'veryfast', '-crf', '23', '-c:a', 'aac', '-b:a', '128k', '-movflags', '+faststart'];
}

function webmVideoCodecArgs() {
  return ['-c:v', 'libvpx-vp9', '-b:v', '1M', '-c:a', 'libopus', '-b:a', '128k'];
}

/** Guaranteed path: background slide + narration audio only. */
async function renderMinimalVideo({ bgPath, audioPath, durSec, format, outPath }) {
  const codec = format === 'webm' ? webmVideoCodecArgs() : mp4VideoCodecArgs();
  await execFfmpeg([
    '-y',
    '-loop',
    '1',
    '-framerate',
    '30',
    '-i',
    bgPath,
    '-t',
    durSec,
    '-i',
    audioPath,
    '-pix_fmt',
    'yuv420p',
    '-shortest',
    ...codec,
    outPath,
  ]);
}

/** Avatar with audio-driven lip-sync (mouth follows TTS volume). */
async function renderWithLipSyncAvatar({ bgPath, audioPath, avatarPath, durSec, outPath }) {
  const fps = 30;
  const durationSec = Number(durSec);

  let filter;
  try {
    const envelope = await lipSync.decodeAudioEnvelope(audioPath, fps, durationSec);
    filter = lipSync.buildAudioDrivenLipSyncFilter(envelope, fps);
  } catch (envErr) {
    // eslint-disable-next-line no-console
    console.warn('Audio envelope lip-sync unavailable:', envErr.message || envErr);
    filter = lipSync.buildRhythmLipSyncFilter();
  }

  try {
    await execFfmpeg([
      '-y',
      '-loop',
      '1',
      '-framerate',
      String(fps),
      '-i',
      bgPath,
      '-t',
      durSec,
      '-i',
      audioPath,
      '-loop',
      '1',
      '-i',
      avatarPath,
      '-t',
      durSec,
      '-filter_complex',
      filter,
      '-map',
      '[outv]',
      '-map',
      '1:a',
      '-pix_fmt',
      'yuv420p',
      '-shortest',
      ...mp4VideoCodecArgs(),
      outPath,
    ]);
  } catch (ffmpegErr) {
    // eslint-disable-next-line no-console
    console.warn('Audio-driven lip-sync failed, rhythm fallback:', ffmpegErr.message || ffmpegErr);
    await execFfmpeg([
      '-y',
      '-loop',
      '1',
      '-framerate',
      String(fps),
      '-i',
      bgPath,
      '-t',
      durSec,
      '-i',
      audioPath,
      '-loop',
      '1',
      '-i',
      avatarPath,
      '-t',
      durSec,
      '-filter_complex',
      lipSync.buildRhythmLipSyncFilter(),
      '-map',
      '[outv]',
      '-map',
      '1:a',
      '-pix_fmt',
      'yuv420p',
      '-shortest',
      ...mp4VideoCodecArgs(),
      outPath,
    ]);
  }
}
async function renderWithStaticAvatar({ bgPath, audioPath, avatarPath, durSec, outPath }) {
  const s = layout.AVATAR_SIZE;
  const filter = [
    `[2:v]scale=${s}:${s}:force_original_aspect_ratio=decrease,pad=${s}:${s}:(ow-iw)/2:(oh-ih)/2[av]`,
    `[0:v][av]overlay=${layout.AVATAR_X}:${layout.AVATAR_Y}[outv]`,
  ].join(';');
  await execFfmpeg([
    '-y',
    '-loop',
    '1',
    '-framerate',
    '30',
    '-i',
    bgPath,
    '-t',
    durSec,
    '-i',
    audioPath,
    '-loop',
    '1',
    '-i',
    avatarPath,
    '-t',
    durSec,
    '-filter_complex',
    filter,
    '-map',
    '[outv]',
    '-map',
    '1:a',
    '-pix_fmt',
    'yuv420p',
    '-shortest',
    ...mp4VideoCodecArgs(),
    outPath,
  ]);
}

async function renderWithDrawtext({ inputPath, vf, format, outPath }) {
  const codec =
    format === 'webm'
      ? ['-c:v', 'libvpx-vp9', '-b:v', '1M', '-c:a', 'copy']
      : ['-preset', 'veryfast', '-crf', '23', '-c:a', 'copy', '-movflags', '+faststart', '-c:v', 'libx264'];
  await execFfmpeg([
    '-y',
    '-i',
    inputPath,
    '-vf',
    vf,
    '-pix_fmt',
    'yuv420p',
    ...codec,
    outPath,
  ]);
}

async function renderSlideVideoNoAvatar({
  workDir,
  audioPath,
  durSec,
  format,
  fontEsc,
  titleEsc,
  headlineEsc,
  scriptEsc,
  bgPath,
}) {
  const outPath = path.join(workDir, format === 'webm' ? 'output.webm' : 'output.mp4');
  const basePath = path.join(workDir, 'base.mp4');
  await renderMinimalVideo({ bgPath, audioPath, durSec, format: 'mp4', outPath: basePath });

  if (!fontEsc) return basePath;

  const vf = buildCenteredDrawtextFilters({ fontEsc, titleEsc, headlineEsc, scriptEsc });
  try {
    await renderWithDrawtext({ inputPath: basePath, vf, format, outPath });
    return outPath;
  } catch (drawErr) {
    // eslint-disable-next-line no-console
    console.warn('Video CV drawtext skipped:', drawErr.message || drawErr);
    if (format === 'mp4') return basePath;
    await renderMinimalVideo({ bgPath, audioPath, durSec, format, outPath });
    return outPath;
  }
}

async function renderSlideVideoWithAvatar({
  workDir,
  audioPath,
  durSec,
  format,
  fontEsc,
  titleEsc,
  headlineEsc,
  scriptEsc,
  avatarPath,
  bgPath,
}) {
  const outPath = path.join(workDir, format === 'webm' ? 'output.webm' : 'output.mp4');
  const composedPath = path.join(workDir, 'composed.mp4');
  try {
    await renderWithLipSyncAvatar({
      bgPath,
      audioPath,
      avatarPath,
      durSec,
      outPath: composedPath,
    });
  } catch (lipErr) {
    // eslint-disable-next-line no-console
    console.warn('Video CV lip-sync failed, using static avatar:', lipErr.message || lipErr);
    await renderWithStaticAvatar({
      bgPath,
      audioPath,
      avatarPath,
      durSec,
      outPath: composedPath,
    });
  }

  if (!fontEsc) return composedPath;

  const vf = buildDrawtextFilters({
    fontEsc,
    titleEsc,
    headlineEsc,
    scriptEsc,
    withAvatar: true,
  });
  try {
    await renderWithDrawtext({ inputPath: composedPath, vf, format, outPath });
    return outPath;
  } catch (drawErr) {
    // eslint-disable-next-line no-console
    console.warn('Video CV drawtext skipped (avatar):', drawErr.message || drawErr);
    if (format === 'mp4') return composedPath;
    await execFfmpeg([
      '-y',
      '-i',
      composedPath,
      '-c:v',
      'libvpx-vp9',
      '-b:v',
      '1M',
      '-c:a',
      'copy',
      outPath,
    ]);
    return outPath;
  }
}

/**
 * Renders MP4/WebM: dark slide + name/headline + narration audio (Google TTS).
 * Optional cartoon avatar overlay. Falls back to minimal slide+audio if filters fail.
 * @returns {Promise<string>} path to output video file
 */
async function renderVideoCv({ script, draft, format = 'mp4', voiceProfile, voiceGender }) {
  const workDir = await fs.promises.mkdtemp(path.join(os.tmpdir(), 'virtuomate-cv-'));
  const audioPath = path.join(workDir, 'narration.mp3');
  const titlePath = path.join(workDir, 'title.txt');
  const headlinePath = path.join(workDir, 'headline.txt');
  const scriptPath = path.join(workDir, 'script.txt');
  const avatarPath = path.join(workDir, 'avatar.png');

  const name = sanitizeText(draft?.fullName || 'Candidate', 80);
  const headline = sanitizeText(draft?.headline || 'Professional Profile', 120);
  const body = sanitizeText(script, 1200);

  try {
    const staged = await stageAssets(workDir);
    await writeFile(titlePath, name, 'utf8');
    await writeFile(headlinePath, headline, 'utf8');
    await writeFile(scriptPath, body, 'utf8');

    await synthesizeSpeechMp3(script, audioPath, { voiceProfile, voiceGender });
    const duration = await probeDurationSeconds(audioPath);

    const fontEsc = staged.fontPath ? escapeDrawtextPath(staged.fontPath) : '';
    const titleEsc = escapeDrawtextPath(titlePath);
    const headlineEsc = escapeDrawtextPath(headlinePath);
    const scriptEsc = escapeDrawtextPath(scriptPath);
    const durSec = String(Math.ceil(duration));

    const avatarUrl = String(draft?.avatarImageUrl || '').trim();
    let hasAvatar = false;
    if (avatarUrl) {
      try {
        hasAvatar = await downloadAvatarImage(avatarUrl, avatarPath);
      } catch (avatarErr) {
        // eslint-disable-next-line no-console
        console.warn('Video CV avatar skipped:', avatarErr.message || avatarErr);
      }
    }

    const renderArgs = {
      workDir,
      audioPath,
      durSec,
      format,
      fontEsc,
      titleEsc,
      headlineEsc,
      scriptEsc,
      bgPath: staged.bgPath,
    };

    const outPath = path.join(workDir, format === 'webm' ? 'output.webm' : 'output.mp4');
    const attempts = [];

    if (hasAvatar) {
      // eslint-disable-next-line no-console
      console.log('Video CV: rendering with avatar lip-sync');
      attempts.push(async () => renderSlideVideoWithAvatar({ ...renderArgs, avatarPath }));
    } else if (avatarUrl) {
      // eslint-disable-next-line no-console
      console.warn('Video CV: avatar URL present but download failed — no lip-sync');
    }
    attempts.push(async () => renderSlideVideoNoAvatar(renderArgs));
    attempts.push(async () => {
      await renderMinimalVideo({
        bgPath: staged.bgPath,
        audioPath,
        durSec,
        format,
        outPath,
      });
      return outPath;
    });

    let lastErr = null;
    for (const attempt of attempts) {
      try {
        const resultPath = await attempt();
        const stat = await fs.promises.stat(resultPath);
        if (stat.size >= 1000) return resultPath;
        lastErr = new Error('Rendered video file too small');
      } catch (err) {
        lastErr = err;
        // eslint-disable-next-line no-console
        console.warn('Video CV render attempt failed:', err.message || err);
      }
    }

    throw lastErr || new Error('Video render failed');
  } catch (err) {
    await rm(workDir, { recursive: true, force: true }).catch(() => {});
    throw err;
  }
}

async function cleanupWorkDirForFile(filePath) {
  if (!filePath) return;
  const dir = path.dirname(filePath);
  await rm(dir, { recursive: true, force: true }).catch(() => {});
}

module.exports = {
  renderVideoCv,
  cleanupWorkDirForFile,
  isFfmpegAvailable: () => Boolean(ffmpegPath),
  isRenderAssetsReady: () => {
    try {
      return Boolean(resolveSlideBackgroundPath() && resolveDrawtextFontPath());
    } catch (_) {
      return false;
    }
  },
};
