'use strict';

require('dotenv').config({ path: require('path').join(__dirname, '..', '.env') });

const key = (process.env.GEMINI_API_KEY || '').trim();
if (!key) {
  console.error('MISSING GEMINI_API_KEY');
  process.exit(1);
}

const headers = { 'Content-Type': 'application/json', 'x-goog-api-key': key };
const useQuery = key.startsWith('AIza');

async function listModels() {
  const base = 'https://generativelanguage.googleapis.com/v1beta/models';
  const url = useQuery ? `${base}?key=${encodeURIComponent(key)}` : base;
  const res = await fetch(url, { headers });
  const text = await res.text();
  if (!res.ok) {
    console.error('ListModels failed:', res.status, text.slice(0, 400));
    process.exit(1);
  }
  const data = JSON.parse(text);
  const imageModels = (data.models || []).filter((m) => {
    const name = m.name || '';
    const methods = m.supportedGenerationMethods || [];
    return (
      methods.includes('generateContent') &&
      (name.includes('image') || name.includes('imagen') || name.includes('flash'))
    );
  });
  console.log('Image-capable / flash models:');
  for (const m of imageModels) {
    console.log(` - ${m.name} [${(m.supportedGenerationMethods || []).join(', ')}]`);
  }
}

listModels().catch((e) => {
  console.error(e.message);
  process.exit(1);
});
