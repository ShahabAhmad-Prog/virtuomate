'use strict';
const path = require('path');
const os = require('os');
const fs = require('fs');
const { execFileSync, execFile } = require('child_process');
const ffmpeg = require('ffmpeg-static');

(async () => {
  const wd = await fs.promises.mkdtemp(path.join(os.tmpdir(), 'lip-'));
  const avatar = path.join(wd, 'av.png');
  const bg = path.join(wd, 'bg.png');
  const cmd = path.join(wd, 'cmd.txt');
  const out = path.join(wd, 'out.mp4');
  execFileSync(ffmpeg, ['-y', '-f', 'lavfi', '-i', 'color=c=0x222222:s=1280x720', '-frames:v', '1', bg], { stdio: 'pipe' });
  execFileSync(
    ffmpeg,
    ['-y', '-f', 'lavfi', '-i', 'gradients=s=512x512', '-vf', 'drawbox=x=0:y=260:w=512:h=100:color=black@1:t=fill', '-frames:v', '1', avatar],
    { stdio: 'pipe' },
  );
  const lines = [];
  for (let i = 0; i < 120; i++) {
    const t = (i / 30).toFixed(3);
    const o = 0.2 + 0.7 * Math.abs(Math.sin(i / 6));
    lines.push(`${t} [mouthscale] reinit w iw*${(1 + o * 0.2).toFixed(4)} h ih*${(1 + o * 0.5).toFixed(4)};`);
  }
  await fs.promises.writeFile(cmd, lines.join('\n'));
  const cmdEsc = cmd.replace(/\\/g, '/').replace(/:/g, '\\:').replace(/'/g, "\\'");
  const filter = [
    '[2:v]scale=420:420:force_original_aspect_ratio=decrease,pad=420:420:(ow-iw)/2:(oh-ih)/2,setsar=1,fps=30[av]',
    '[av]split=2[av_static][av_mouth_src]',
    '[av_mouth_src]crop=420:112:0:218[mouth]',
    `[mouth]scale@mouthscale=w=iw:h=ih:flags=bilinear,sendcmd=f='${cmdEsc}'[mouth_scaled]`,
    `[mouth_scaled]format=yuva420p,geq=r='r(X,Y)':g='g(X,Y)':b='b(X,Y)':a='255*min(min(Y/18\\,(112-Y)/18)\\,1)'[mouth_soft]`,
    '[av_static][mouth_soft]overlay=0:218[av_talk]',
    '[0:v][av_talk]overlay=820:88[outv]',
  ].join(';');
  await new Promise((res, rej) =>
    execFile(
      ffmpeg,
      ['-y', '-loop', '1', '-framerate', '30', '-i', bg, '-t', '4', '-f', 'lavfi', '-i', 'anullsrc', '-t', '4', '-loop', '1', '-i', avatar, '-t', '4', '-filter_complex', filter, '-map', '[outv]', '-map', '1:a', '-pix_fmt', 'yuv420p', '-shortest', '-c:v', 'libx264', '-preset', 'veryfast', out],
      (e, _s, o) => (e ? rej(new Error(String(o).slice(-500))) : res()),
    ),
  );
  const f1 = path.join(wd, 'f1.png');
  const f2 = path.join(wd, 'f2.png');
  execFileSync(ffmpeg, ['-y', '-ss', '0.2', '-i', out, '-vframes', '1', f1], { stdio: 'pipe' });
  execFileSync(ffmpeg, ['-y', '-ss', '1.5', '-i', out, '-vframes', '1', f2], { stdio: 'pipe' });
  console.log('sendcmd OK animated=', !fs.readFileSync(f1).equals(fs.readFileSync(f2)));
})().catch((e) => console.error('FAIL', e.message));
