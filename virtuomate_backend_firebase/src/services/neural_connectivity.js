'use strict';

/**
 * Computes 0–100% neural stack connectivity from API + Intelligence Engine health.
 * Four layers × 25%: cloud API, engine link, DeBERTa checkpoint, speech (Whisper).
 */
function layer(label, ok, detail) {
  return { id: label.toLowerCase().replace(/\s+/g, '_'), label, ok: Boolean(ok), detail: detail || '' };
}

function computeNeuralConnectivity({
  engineUrl,
  intelligenceEngine,
  apiOk = true,
  geminiConfigured = false,
}) {
  const layers = [];
  layers.push(
    layer(
      'Cloud API',
      apiOk,
      apiOk ? 'VirtuoMate API reachable' : 'API health check failed',
    ),
  );

  const urlConfigured = Boolean(engineUrl && String(engineUrl).trim());
  layers.push(
    layer(
      'Engine link',
      urlConfigured,
      urlConfigured ? String(engineUrl).trim() : 'Set INTELLIGENCE_ENGINE_URL on Firebase Functions',
    ),
  );

  let engine = intelligenceEngine;
  if (typeof engine === 'string') {
    engine = { status: engine, neural_checkpoint: false, whisper: false };
  }

  const engineOk =
    engine &&
    typeof engine === 'object' &&
    (engine.status === 'ok' || engine.engine === 'virtuomate-intelligence');

  const neuralOk =
    geminiConfigured || (engineOk && Boolean(engine.neural_checkpoint));
  layers.push(
    layer(
      'Neural model',
      neuralOk,
      geminiConfigured
        ? 'Gemini coaching assessment engine active'
        : engineOk && engine.neural_checkpoint
          ? 'DeBERTa multi-task checkpoint loaded'
          : engineOk
            ? 'Linguistic engine only'
            : 'Set GEMINI_API_KEY on Cloud Functions for demo AI',
    ),
  );

  const whisperOk = engineOk && Boolean(engine.whisper);
  layers.push(
    layer(
      'Speech AI',
      whisperOk,
      whisperOk
        ? 'Whisper transcription available'
        : 'Text coaching works · add OPENAI_API_KEY on Cloud Run for speech',
    ),
  );

  const percent = layers.filter((l) => l.ok).length * 25;
  const full = percent >= 100;

  let mode = 'offline';
  if (full) mode = 'neural-full';
  else if (engineOk && engine.neural_checkpoint) mode = 'neural-partial';
  else if (urlConfigured && engineOk) mode = 'linguistic-remote';
  else if (urlConfigured) mode = 'engine-unreachable';
  else mode = 'local-only';

  return {
    percent,
    full,
    mode,
    layers,
    intelligenceEngineUrl: urlConfigured ? String(engineUrl).trim() : null,
    engine: engineOk ? engine : null,
  };
}

async function probeIntelligenceEngine(engineUrl) {
  if (!engineUrl) return null;
  try {
    const base = String(engineUrl).replace(/\/$/, '');
    const r = await fetch(`${base}/health`, { signal: AbortSignal.timeout(8000) });
    if (!r.ok) {
      return { status: 'error', httpStatus: r.status };
    }
    return r.json();
  } catch (err) {
    return { status: 'unreachable', error: err.message };
  }
}

module.exports = {
  computeNeuralConnectivity,
  probeIntelligenceEngine,
};
