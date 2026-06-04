'use strict';

require('dotenv').config({ path: require('path').join(__dirname, '..', '.env') });

const fs = require('fs');
const path = require('path');

const key = (process.env.GEMINI_API_KEY || '').trim();
if (!key) {
  console.error('MISSING: GEMINI_API_KEY in .env');
  process.exit(1);
}

/** 1x1 red JPEG — minimal input for image-gen probe */
const TINY_JPEG_B64 =
  '/9j/4AAQSkZJRgABAQEASABIAAD/2wBDAP//////////////////////////////////////////////////////////////////////////////////////2wBDAf//////////////////////////////////////////////////////////////////////////////////////wAARCAABAAEDASIAAhEBAxEB/8QAFQABAQAAAAAAAAAAAAAAAAAAAAb/xAAUEAEAAAAAAAAAAAAAAAAAAAAA/8QAFQEBAQAAAAAAAAAAAAAAAAAAAAX/xAAUEQEAAAAAAAAAAAAAAAAAAAAA/9oADAMBAAIRAxEAPwCdABmX/9k=';

async function probeHealth() {
  try {
    const res = await fetch('https://us-central1-virtuomate.cloudfunctions.net/api/health');
    const data = await res.json();
    console.log('Cloud /health:', JSON.stringify({
      geminiConfigured: data.geminiConfigured,
      geminiStatus: data.geminiStatus,
      geminiImageStatus: data.geminiImageStatus,
      geminiImageProbe: data.geminiImageProbe,
      aiProvider: data.aiProvider,
    }));
  } catch (e) {
    console.warn('Cloud health unreachable:', e.message);
  }
}

async function testLocalImageGen() {
  const avatarVroid = require('../src/services/avatar_vroid.service');
  const buffer = Buffer.from(TINY_JPEG_B64, 'base64');
  console.log('Testing local VRoid-style image generation (Gemini)...');
  const result = await avatarVroid.generateVroidStylePortrait({
    imageBuffer: buffer,
    mimeType: 'image/jpeg',
    avatarStyle: 'Professional',
  });
  console.log('Image generation OK:', {
    provider: result.provider,
    model: result.model,
    bytes: result.buffer.length,
    mimeType: result.mimeType,
  });
  const out = path.join(__dirname, '..', 'tmp-gemini-image-probe.png');
  fs.writeFileSync(out, result.buffer);
  console.log('Wrote probe image:', out);
}

(async () => {
  await probeHealth();
  try {
    await testLocalImageGen();
    console.log('RESULT: Image generation is ENABLED and working locally.');
  } catch (err) {
    const msg = String(err.message || err);
    console.error('RESULT: Image generation FAILED:', msg.slice(0, 500));
    if (msg.includes('404') || msg.includes('not found')) {
      console.error(
        'HINT: Enable Generative Language API and ensure image model access in AI Studio.',
      );
    }
    if (msg.includes('429') || msg.toLowerCase().includes('quota')) {
      console.error('HINT: Add billing / credits at https://aistudio.google.com');
    }
    process.exit(1);
  }
})();
