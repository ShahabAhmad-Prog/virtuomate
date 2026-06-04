'use strict';

const path = require('path');
const os = require('os');
const ffmpegPath = require('ffmpeg-static');
const { execFileSync } = require('child_process');

const avatarPath = path.join(os.tmpdir(), 'virt-test-av.png');
const outPath = path.join(os.tmpdir(), 'virt-test-out.mp4');

execFileSync(ffmpegPath, ['-y', '-f', 'lavfi', '-i', 'color=c=0x5599FF:s=512x512', '-frames:v', '1', avatarPath], {
  stdio: 'pipe',
});

const audioPath = path.join(os.tmpdir(), 'virt-test-silence.mp3');
execFileSync(
  ffmpegPath,
  ['-y', '-f', 'lavfi', '-i', 'anullsrc=r=44100:cl=mono', '-t', '2', '-q:a', '9', audioPath],
  { stdio: 'pipe' },
);

const filters = [
  '[2:v]scale=420:420,fps=30[av];[0:v][av]overlay=820:88[composed]',
  "[2:v]scale=420:420,fps=30[av];[av]zoompan=z='1+0.06*sin(2*PI*on/30*8)':x='iw/2-(iw/zoom/2)':y='ih/2-(ih/zoom/2)':d=1:s=420x420[av2];[0:v][av2]overlay=820:88[composed]",
  "[2:v]scale=420:420,fps=30[av];[av]split[a][b];[b]crop=420:118:0:298[m];[m]scale=w='iw*(1+0.2*sin(2*PI*t*8))':h='ih':eval=frame[ma];[a][ma]overlay=0:298[v];[0:v][v]overlay=820:88[composed]",
  "[2:v]scale=420:420:force_original_aspect_ratio=decrease,pad=420:420:(ow-iw)/2:(oh-ih)/2,setsar=1,fps=30[av];[av]split[av_static][av_lip_src];[av_lip_src]crop=420:118:0:298[mouth];[mouth]scale=w='iw*(1+0.240*sin(2*PI*t*8))':h='ih*(1+0.168*sin(2*PI*t*8))':eval=frame[mouth_anim];[av_static][mouth_anim]overlay=0:298[av_lips];[av_lips]zoompan=z='1+0.080*sin(2*PI*on/30*8)':x='iw/2-(iw/zoom/2)':y='ih/2-(ih/zoom/2)':d=1:s=420x420[av_talk];[0:v][av_talk]overlay=820:88[composed]",
];

for (const fc of filters) {
  const out = outPath.replace('.mp4', `-${filters.indexOf(fc)}.mp4`);
  try {
    execFileSync(
      ffmpegPath,
      [
        '-y',
        '-f',
        'lavfi',
        '-i',
        'color=c=0x0b1220:s=1280x720:r=30',
        '-t',
        '2',
        '-i',
        audioPath,
        '-loop',
        '1',
        '-i',
        avatarPath,
        '-t',
        '2',
        '-filter_complex',
        fc,
        '-map',
        '[composed]',
        '-map',
        '1:a',
        '-t',
        '2',
        out,
      ],
      { stdio: 'pipe' },
    );
    console.log('OK', fc.slice(0, 60));
  } catch (e) {
    const msg = e.stderr?.toString() || e.message;
    console.log('FAIL', fc.slice(0, 60));
    console.log(msg.split('\n').slice(-6).join('\n'));
  }
}
