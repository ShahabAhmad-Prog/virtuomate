'use strict';
const path = require('path');
const os = require('os');
const fs = require('fs');
const { execFileSync, execFile } = require('child_process');
const ffmpeg = require('ffmpeg-static');
const lip = require('../src/services/audio_lipsync');

async function tryFilter(name, filter) {
  const wd = await fs.promises.mkdtemp(path.join(os.tmpdir(), 'lip-'));
  const avatar = path.join(wd, 'av.png');
  const bg = path.join(wd, 'bg.png');
  const out = path.join(wd, 'out.mp4');
  execFileSync(ffmpeg, ['-y', '-f', 'lavfi', '-i', 'color=c=0x222222:s=1280x720', '-frames:v', '1', bg], { stdio: 'pipe' });
  execFileSync(
    ffmpeg,
    ['-y', '-f', 'lavfi', '-i', 'gradients=s=512x512', '-vf', 'drawbox=x=0:y=260:w=512:h=100:color=black@1:t=fill', '-frames:v', '1', avatar],
    { stdio: 'pipe' },
  );
  try {
    await new Promise((res, rej) =>
      execFile(
        ffmpeg,
        ['-y', '-loop', '1', '-framerate', '30', '-i', bg, '-t', '4', '-f', 'lavfi', '-i', 'anullsrc', '-t', '4', '-loop', '1', '-i', avatar, '-t', '4', '-filter_complex', filter, '-map', '[outv]', '-map', '1:a', '-pix_fmt', 'yuv420p', '-shortest', '-c:v', 'libx264', '-preset', 'veryfast', out],
        (e, _s, o) => (e ? rej(new Error(String(o).slice(-400))) : res()),
      ),
    );
    const f1 = path.join(wd, 'f1.png');
    const f2 = path.join(wd, 'f2.png');
    execFileSync(ffmpeg, ['-y', '-ss', '0.2', '-i', out, '-vframes', '1', f1], { stdio: 'pipe' });
    execFileSync(ffmpeg, ['-y', '-ss', '1.5', '-i', out, '-vframes', '1', f2], { stdio: 'pipe' });
    const same = fs.readFileSync(f1).equals(fs.readFileSync(f2));
    console.log(name, 'OK animated=', !same);
  } catch (e) {
    console.log(name, 'FAIL', e.message.slice(0, 120));
  }
}

(async () => {
  await tryFilter('rhythm', lip.buildRhythmLipSyncFilter());
  const env = new Array(120).fill(0).map((_, i) => 0.2 + 0.7 * Math.abs(Math.sin(i / 8)));
  await tryFilter('audio', lip.buildAudioDrivenLipSyncFilter(env, 30));
})();
