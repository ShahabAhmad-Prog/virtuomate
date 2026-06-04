'use strict';

const path = require('path');
const os = require('os');
const { execFileSync } = require('child_process');
const ffmpegPath = require('ffmpeg-static');
const { renderVideoCv, cleanupWorkDirForFile } = require('../src/services/video_cv_render.service');

const avatarPath = path.join(os.tmpdir(), 'virt-test-av.png');
execFileSync(ffmpegPath, ['-y', '-f', 'lavfi', '-i', 'color=c=0x5599FF:s=512x512', '-frames:v', '1', avatarPath], {
  stdio: 'pipe',
});

(async () => {
  const out = await renderVideoCv({
    script: 'Testing cartoon avatar lip sync on video curriculum vitae render.',
    draft: {
      fullName: 'Test',
      headline: 'Developer',
      avatarImageUrl: `file://${avatarPath.replace(/\\/g, '/')}`,
      avatarIsCartoon: true,
    },
    format: 'mp4',
  });
  const fs = require('fs');
  console.log('rendered bytes', fs.statSync(out).size);
  await cleanupWorkDirForFile(out);
})().catch((err) => {
  console.error(err.message || err);
  process.exit(1);
});
