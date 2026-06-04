'use strict';

require('dotenv').config({ path: require('path').join(__dirname, '..', '.env') });

const key = (process.env.GEMINI_API_KEY || '').trim();
if (!key) {
  console.error('MISSING: set GEMINI_API_KEY in .env');
  process.exit(1);
}
if (!key.startsWith('AIza') && !key.startsWith('AQ.')) {
  console.error('INVALID: key must start with AIza or AQ. (from Google AI Studio)');
  process.exit(1);
}

function fail(msg) {
  console.error(msg);
  process.exit(1);
}

const headers = { 'Content-Type': 'application/json', 'x-goog-api-key': key };
const model = process.env.GEMINI_MODEL || 'gemini-2.5-flash-lite';
const base = `https://generativelanguage.googleapis.com/v1beta/models/${model}:generateContent`;
const url = key.startsWith('AIza')
  ? `${base}?key=${encodeURIComponent(key)}`
  : base;

async function ping() {
  const response = await fetch(url, {
    method: 'POST',
    headers,
    body: JSON.stringify({ contents: [{ parts: [{ text: 'Say OK' }] }] }),
  });
  const text = await response.text();
  if (
    text.includes('UNAUTHENTICATED') ||
    text.includes('API key not valid') ||
    text.includes('API_KEY_INVALID')
  ) {
    fail('INVALID KEY');
  }
  if (text.includes('API_KEY_SERVICE_BLOCKED') || text.includes('PERMISSION_DENIED')) {
    fail(
      'BLOCKED: enable Generative Language API in Cloud Library; use Dont restrict on the key.',
    );
  }
  if (response.status === 429 || text.includes('prepayment') || text.toLowerCase().includes('quota')) {
    fail(
      'QUOTA/BILLING: this project has no Gemini credits left. Create a NEW project at https://aistudio.google.com/apikey or add billing — a new key in the same project will not help.',
    );
  }
  if (!response.ok) {
    fail(`Ping failed (${response.status}): ${text.slice(0, 200)}`);
  }
}

async function coachProbe() {
  const gemini = require('../src/services/gemini.service');
  const pkg = await gemini.generateCoachPackage({
    text: 'I am nervous about my interview tomorrow. I led a team of five on a deadline.',
    sessionType: 'Conversation',
  });
  if (pkg.assessment?.provider !== 'gemini' || !pkg.feedback?.trim()) {
    fail('Coach probe returned empty or invalid package');
  }
  return pkg.feedback.slice(0, 120);
}

(async () => {
  await ping();
  console.log('Ping OK — testing full coach call (same as the app)...');
  try {
    const sample = await coachProbe();
    console.log('Key works — Gemini coach is ready.');
    console.log(`Sample: ${sample}...`);
  } catch (err) {
    const msg = String(err?.message || err);
    if (
      msg.includes('429') ||
      msg.toLowerCase().includes('quota') ||
      msg.toLowerCase().includes('prepayment')
    ) {
      fail(
        'QUOTA/BILLING: ping passed but coach failed — project credits exhausted. Use a NEW AI Studio project + new key, or enable billing at https://aistudio.google.com',
      );
    }
    fail(`Coach probe failed: ${msg.slice(0, 300)}`);
  }
})().catch((e) => {
  fail(e.message || String(e));
});
