'use strict';

function readIntelligenceEngineUrl() {
  const fromEnv = process.env.INTELLIGENCE_ENGINE_URL;
  if (fromEnv && String(fromEnv).trim()) {
    return String(fromEnv).trim();
  }

  for (const raw of [process.env.FIREBASE_CONFIG, process.env.CLOUD_RUNTIME_CONFIG]) {
    if (!raw) continue;
    try {
      const parsed = JSON.parse(raw);
      const url = parsed?.intelligence?.engine_url;
      if (url) return String(url).trim();
    } catch (_) {
      /* ignore */
    }
  }

  try {
    const functions = require('firebase-functions/v1');
    const url = functions.config()?.intelligence?.engine_url;
    if (url) return String(url).trim();
  } catch (_) {
    /* local / tests */
  }

  return '';
}

const PLANS = {
  monthly: { id: 'monthly', priceUsd: 29, label: 'Monthly' },
  annual: { id: 'annual', priceUsd: 249, label: 'Annual' },
  lifetime: { id: 'lifetime', priceUsd: 499, label: 'Lifetime' },
};

const config = {
  demoEmail: process.env.DEMO_ACCOUNT_EMAIL || 'demo@virtuomate.app',
  demoPassword: process.env.DEMO_ACCOUNT_PASSWORD || 'VirtuoDemo2026!',
  port: Number(process.env.PORT || 8080),
  region: process.env.FUNCTION_REGION || 'us-central1',
  openAiApiKey: process.env.OPENAI_API_KEY || '',
  openAiModel: process.env.OPENAI_MODEL || 'gpt-4o-mini',
  openAiImageModel: process.env.OPENAI_IMAGE_MODEL || 'gpt-image-1',
  geminiApiKey: process.env.GEMINI_API_KEY || '',
  aiProvider: process.env.AI_PROVIDER || 'openai', // openai | gemini | local
  paymentMode: process.env.PAYMENT_MODE || 'mock', // mock | stripe
  stripeSecretKey: process.env.STRIPE_SECRET_KEY || '',
  stripeWebhookSecret: process.env.STRIPE_WEBHOOK_SECRET || '',
  stripePriceMonthly: process.env.STRIPE_PRICE_MONTHLY || '',
  stripePriceAnnual: process.env.STRIPE_PRICE_ANNUAL || '',
  stripePriceLifetime: process.env.STRIPE_PRICE_LIFETIME || '',
  freeSessionLimit: Number(process.env.FREE_SESSION_LIMIT || 20),
  corsOrigin: process.env.CORS_ORIGIN || '*',
  adminEmails: (process.env.ADMIN_EMAILS || 'admin@virtuomate.app')
    .split(',')
    .map((e) => e.trim().toLowerCase())
    .filter(Boolean),
  plans: PLANS,
};

Object.defineProperty(config, 'intelligenceEngineUrl', {
  get: readIntelligenceEngineUrl,
  enumerable: true,
});

module.exports = config;
