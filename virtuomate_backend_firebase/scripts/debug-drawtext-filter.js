'use strict';

const path = require('path');
const os = require('os');
const fs = require('fs');
const { execFileSync } = require('child_process');
const ffmpegPath = require('ffmpeg-static');

const avatarPath = path.join(os.tmpdir(), 'virt-test-av.png');
const audioPath = path.join(os.tmpdir(), 'virt-test-silence.mp3');
const work = fs.mkdtempSync(path.join(os.tmpdir(), 'virt-dt-'));
const titlePath = path.join(work, 'title.txt');
const headlinePath = path.join(work, 'headline.txt');
const scriptPath = path.join(work, 'script.txt');
fs.writeFileSync(titlePath, 'Test User');
fs.writeFileSync(headlinePath, 'Engineer');
fs.writeFileSync(scriptPath, 'Hello world script line.');

function escapeDrawtextPath(filePath) {
  return filePath.replace(/\\/g, '/').replace(/:/g, '\\:').replace(/'/g, "\\'");
}

const titleEsc = escapeDrawtextPath(titlePath);
const headlineEsc = escapeDrawtextPath(headlinePath);
const scriptEsc = escapeDrawtextPath(scriptPath);

const avatarChain = [
  '[2:v]scale=420:420:force_original_aspect_ratio=decrease',
  'pad=420:420:(ow-iw)/2:(oh-ih)/2',
  'setsar=1,fps=30[av]',
  '[av]split[av_static][av_lip_src]',
  '[av_lip_src]crop=420:118:0:298[mouth]',
  "[mouth]scale=w='iw*(1+0.240*sin(2*PI*t*8))':h='ih*(1+0.168*sin(2*PI*t*8))':eval=frame[mouth_anim]",
  '[av_static][mouth_anim]overlay=0:298[av_lips]',
  "[av_lips]zoompan=z='1+0.080*sin(2*PI*on/30*8)':x='iw/2-(iw/zoom/2)':y='ih/2-(ih/zoom/2)':d=1:s=420x420[av_talk]",
  '[0:v][av_talk]overlay=820:88[composed]',
].join(';');

const drawtext = [
  "drawtext=text='VirtuoMate Video CV':fontsize=26:fontcolor=0x3BE7FF:x=40:y=32",
  `drawtext=textfile='${titleEsc}':fontsize=46:fontcolor=white:x=40:y=90`,
  `drawtext=textfile='${headlineEsc}':fontsize=26:fontcolor=0xCCCCCC:x=40:y=150`,
  `drawtext=textfile='${scriptEsc}':fontsize=22:fontcolor=white:x=40:y=220:line_spacing=6:box=1:boxcolor=0x00000055:boxborderw=12`,
].join(',');

const filterComplex = `${avatarChain};[composed]${drawtext}[vout]`;
console.log(filterComplex);

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
      filterComplex,
      '-map',
      '[vout]',
      '-map',
      '1:a',
      '-t',
      '2',
      path.join(work, 'out.mp4'),
    ],
    { stdio: 'pipe' },
  );
  console.log('OK drawtext+avatar');
} catch (e) {
  console.log(e.stderr?.toString().split('\n').slice(-12).join('\n'));
}
