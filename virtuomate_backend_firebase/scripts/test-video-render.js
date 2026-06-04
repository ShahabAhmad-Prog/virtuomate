'use strict';

const render = require('../src/services/video_cv_render.service');

async function main() {
  console.log('ffmpeg available:', render.isFfmpegAvailable());
  const out = await render.renderVideoCv({
    script:
      'Hello, I am a software engineer with five years of experience building mobile apps, APIs, and cloud backends.',
    draft: { fullName: 'Test User', headline: 'Software Engineer' },
    format: 'mp4',
  });
  console.log('render ok:', out);
}

main().catch((err) => {
  console.error('render failed:', err.message || err);
  process.exit(1);
});
