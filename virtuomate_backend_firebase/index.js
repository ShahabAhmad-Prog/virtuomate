'use strict';

// Loaded on deploy for INTELLIGENCE_ENGINE_URL and other secrets (see .env.example)
try {
  require('dotenv').config();
} catch (_) {
  /* dotenv optional for local */
}

/**
 * Gen-1 Cloud Functions HTTP API.
 * URL: https://us-central1-virtuomate.cloudfunctions.net/api/health
 *
 * Keep top-level requires minimal so Firebase deploy discovery does not time out.
 */
const functions = require('firebase-functions/v1');

const REGION = process.env.FUNCTION_REGION || 'us-central1';

let cachedApp;

function getApp() {
  if (cachedApp) return cachedApp;
  const admin = require('firebase-admin');
  const { createApp } = require('./src/app');
  if (!admin.apps.length) {
    admin.initializeApp();
  }
  cachedApp = createApp();
  return cachedApp;
}

exports.api = functions
  .region(REGION)
  .runWith({ timeoutSeconds: 300, memory: '1GB', invoker: 'public' })
  .https.onRequest((req, res) => getApp()(req, res));

if (require.main === module) {
  const config = require('./src/config');
  getApp().listen(config.port, () => {
    // eslint-disable-next-line no-console
    console.log(`VirtuoMate API listening on http://127.0.0.1:${config.port}`);
  });
}
