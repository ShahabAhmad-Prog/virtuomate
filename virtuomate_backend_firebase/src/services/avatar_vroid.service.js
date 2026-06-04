'use strict';

const config = require('../config');

const GEMINI_IMAGE_MODELS = [
  process.env.GEMINI_IMAGE_MODEL || 'gemini-2.5-flash-image',
  'gemini-2.5-flash-image',
  'gemini-3.1-flash-image',
  'gemini-3-pro-image',
  'gemini-3.1-flash-image-preview',
];

function vroidPrompt(avatarStyle) {
  return (
    'Transform this photo into ONE front-facing 2D anime character portrait in the visual style of VRoid Studio ' +
    '(clean anime cel shading, soft professional lighting, bust shot, simple neutral gradient background). ' +
    'Preserve the person\'s apparent age, gender presentation, skin tone, hair color, and distinctive features ' +
    '(glasses, facial hair, etc.) in a stylized anime look — not photorealistic. ' +
    'Clear mouth and lips for lip-sync animation. ' +
    'No text, no watermark, no collage. Suitable as a video CV presenter avatar. ' +
    `Coaching persona: ${avatarStyle || 'Professional'}.`
  );
}

function cartoonPrompt(avatarStyle) {
  return (
    'Transform this photo into ONE front-facing 2D cartoon coach avatar portrait. ' +
    'Friendly stylized cartoon (not photorealistic): bold clean outlines, soft cel shading, expressive eyes, ' +
    'clear mouth area for lip-sync, bust shot, simple gradient background. ' +
    'Match the person\'s general look (hair, glasses, beard, skin tone) in cartoon form. ' +
    'No text, no watermark. Professional coaching app character. ' +
    `Persona: ${avatarStyle || 'Professional'}.`
  );
}

function buildAvatarPrompt(avatarStyle, style = 'cartoon') {
  const key = String(style || 'cartoon').toLowerCase();
  if (key === 'vroid' || key === 'anime') return vroidPrompt(avatarStyle);
  return cartoonPrompt(avatarStyle);
}

function extractImageFromResponse(data) {
  const parts = data?.candidates?.[0]?.content?.parts || [];
  for (const part of parts) {
    const inline = part.inlineData || part.inline_data;
    if (inline?.data) {
      const mimeType = inline.mimeType || inline.mime_type || 'image/png';
      return {
        mimeType,
        buffer: Buffer.from(inline.data, 'base64'),
      };
    }
  }
  return null;
}

async function geminiGeneratePortrait({ imageBuffer, mimeType, avatarStyle, style }) {
  if (!config.geminiApiKey) {
    throw new Error('GEMINI_API_KEY not configured');
  }

  const key = String(config.geminiApiKey).trim();
  const headers = { 'Content-Type': 'application/json' };
  if (key.startsWith('AQ.') || key.startsWith('AIza')) {
    headers['x-goog-api-key'] = key;
  } else {
    throw new Error('Invalid GEMINI_API_KEY');
  }
  const useQueryKey = key.startsWith('AIza');

  const body = {
    contents: [
      {
        role: 'user',
        parts: [
          { inline_data: { mime_type: mimeType, data: imageBuffer.toString('base64') } },
          { text: buildAvatarPrompt(avatarStyle, style) },
        ],
      },
    ],
    generationConfig: {
      responseModalities: ['IMAGE', 'TEXT'],
      temperature: 0.35,
    },
  };

  let lastErr;
  for (const model of GEMINI_IMAGE_MODELS) {
    try {
      const base = `https://generativelanguage.googleapis.com/v1beta/models/${model}:generateContent`;
      const url = useQueryKey ? `${base}?key=${encodeURIComponent(key)}` : base;
      const response = await fetch(url, {
        method: 'POST',
        headers,
        body: JSON.stringify(body),
        signal: AbortSignal.timeout(90000),
      });
      if (!response.ok) {
        const err = await response.text();
        throw new Error(`Gemini image ${response.status}: ${err.slice(0, 400)}`);
      }
      const data = await response.json();
      const image = extractImageFromResponse(data);
      if (!image?.buffer?.length) {
        throw new Error('Gemini returned no image data');
      }
      return { ...image, provider: 'gemini', model };
    } catch (err) {
      lastErr = err;
      const msg = String(err.message || err);
      if (!msg.includes('404') && !msg.includes('not found')) break;
    }
  }
  throw lastErr || new Error('Gemini image generation failed');
}

async function openAiGeneratePortrait({ imageBuffer, mimeType, avatarStyle, style }) {
  if (!config.openAiApiKey) {
    throw new Error('OPENAI_API_KEY not configured');
  }

  const FormData = global.FormData;
  const Blob = global.Blob;
  if (!FormData || !Blob) {
    throw new Error('FormData not available for OpenAI image fallback');
  }

  const pngBuffer =
    mimeType === 'image/png' ? imageBuffer : await jpegToPng(imageBuffer).catch(() => imageBuffer);

  const form = new FormData();
  form.append('model', config.openAiImageModel || 'gpt-image-1');
  form.append('prompt', buildAvatarPrompt(avatarStyle, style));
  form.append('size', '1024x1024');
  form.append('image', new Blob([pngBuffer], { type: 'image/png' }), 'photo.png');

  const response = await fetch('https://api.openai.com/v1/images/edits', {
    method: 'POST',
    headers: {
      Authorization: `Bearer ${config.openAiApiKey}`,
    },
    body: form,
    signal: AbortSignal.timeout(120000),
  });

  if (!response.ok) {
    const err = await response.text();
    throw new Error(`OpenAI image ${response.status}: ${err.slice(0, 400)}`);
  }

  const data = await response.json();
  const b64 = data?.data?.[0]?.b64_json;
  if (!b64) {
    throw new Error('OpenAI returned no image data');
  }
  return {
    buffer: Buffer.from(b64, 'base64'),
    mimeType: 'image/png',
    provider: 'openai',
    model: config.openAiImageModel,
  };
}

async function jpegToPng(buffer) {
  // Optional sharp conversion — skip if unavailable.
  try {
    // eslint-disable-next-line import/no-extraneous-dependencies, global-require
    const sharp = require('sharp');
    const out = await sharp(buffer).png().toBuffer();
    return out;
  } catch (_) {
    return buffer;
  }
}

/**
 * Selfie/photo → VRoid-style 2D portrait (Gemini image gen, OpenAI fallback).
 */
async function generateVroidStylePortrait({ imageBuffer, mimeType, avatarStyle, style = 'cartoon' }) {
  if (!imageBuffer?.length) {
    throw new Error('Photo data is empty');
  }
  const safeMime = mimeType || 'image/jpeg';

  if (config.geminiApiKey) {
    try {
      return await geminiGeneratePortrait({
        imageBuffer,
        mimeType: safeMime,
        avatarStyle,
        style,
      });
    } catch (err) {
      if (!config.openAiApiKey) throw err;
      // eslint-disable-next-line no-console
      console.warn('Gemini VRoid portrait failed, trying OpenAI:', err.message);
    }
  }

  if (config.openAiApiKey) {
    return openAiGeneratePortrait({ imageBuffer, mimeType: safeMime, avatarStyle, style });
  }

  throw new Error(
    'VRoid-style avatar requires GEMINI_API_KEY (or OPENAI_API_KEY) on Cloud Functions.',
  );
}

module.exports = {
  generateVroidStylePortrait,
  buildAvatarPrompt,
  vroidPrompt,
  cartoonPrompt,
};
