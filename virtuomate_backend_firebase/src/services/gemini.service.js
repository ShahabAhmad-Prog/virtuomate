'use strict';

const config = require('../config');

// Lighter models first; avoid retired IDs (e.g. gemini-2.0-flash).
const MODELS = [
  process.env.GEMINI_MODEL || 'gemini-2.5-flash-lite',
  'gemini-2.5-flash-lite',
  'gemini-2.0-flash-lite',
  'gemini-2.5-flash',
  'gemini-flash-latest',
];

function isQuotaError(err) {
  const m = String(err?.message || err).toLowerCase();
  return (
    m.includes('429') ||
    m.includes('quota') ||
    m.includes('prepayment') ||
    m.includes('credits are depleted') ||
    m.includes('resource_exhausted')
  );
}

const ASSESSMENT_SCHEMA =
  'Fields: confidence_score, clarity_score, professionalism_score, anxiety_score, communication_score, interview_readiness_score (integers 0-100), emotion (neutral|happy|thinking|confident|nervous|encouraging|focused|anxious|concerned), avatar_expression (neutral|happy|thinking|confident|nervous|encouraging|speaking — recommended UI avatar state), strengths, weaknesses, recommendations (string arrays, max 4 items each).';

function clampScore(n) {
  const x = Number(n);
  if (Number.isNaN(x)) return 0;
  return Math.max(0, Math.min(100, Math.round(x)));
}

function normalizeAssessment(raw, transcript) {
  const emotion = String(raw.emotion || 'neutral').toLowerCase();
  return {
    confidence_score: clampScore(raw.confidence_score),
    clarity_score: clampScore(raw.clarity_score),
    professionalism_score: clampScore(raw.professionalism_score),
    anxiety_score: clampScore(raw.anxiety_score),
    communication_score: clampScore(
      raw.communication_score ??
        (Number(raw.clarity_score) + Number(raw.confidence_score)) / 2,
    ),
    interview_readiness_score: clampScore(
      raw.interview_readiness_score ?? raw.communication_score ?? 50,
    ),
    emotion,
    avatar_expression: String(raw.avatar_expression || emotion).toLowerCase(),
    strengths: Array.isArray(raw.strengths) ? raw.strengths.slice(0, 5).map(String) : [],
    weaknesses: Array.isArray(raw.weaknesses) ? raw.weaknesses.slice(0, 5).map(String) : [],
    recommendations: Array.isArray(raw.recommendations)
      ? raw.recommendations.slice(0, 5).map(String)
      : [],
    provider: 'gemini',
    transcript: transcript || '',
  };
}

function geminiHeaders() {
  const key = String(config.geminiApiKey || '').trim();
  if (!key) throw new Error('GEMINI_API_KEY not configured');
  const headers = { 'Content-Type': 'application/json' };
  // Google AI Studio now issues AQ.* keys; legacy keys use AIzaSy.*
  if (key.startsWith('AQ.') || key.startsWith('AIza')) {
    headers['x-goog-api-key'] = key;
    return { key, headers, useQueryKey: key.startsWith('AIza') };
  }
  throw new Error(
    'GEMINI_API_KEY must be from https://aistudio.google.com/apikey (AIza... or AQ....)',
  );
}

/** Minimal text ping for /health — avoids JSON assessment + image generation. */
async function healthPing() {
  const body = {
    contents: [{ role: 'user', parts: [{ text: 'Reply with exactly: OK' }] }],
    generationConfig: { temperature: 0, maxOutputTokens: 8 },
  };
  let lastErr;
  for (const model of MODELS) {
    try {
      return (await geminiRequest(model, body)).trim();
    } catch (err) {
      lastErr = err;
      if (!String(err.message).includes('404')) break;
    }
  }
  throw lastErr;
}

async function geminiRequest(model, body) {
  const { key, headers, useQueryKey } = geminiHeaders();
  const base = `https://generativelanguage.googleapis.com/v1beta/models/${model}:generateContent`;
  const url = useQueryKey
    ? `${base}?key=${encodeURIComponent(key)}`
    : base;
  const response = await fetch(url, {
    method: 'POST',
    headers,
    body: JSON.stringify(body),
    signal: AbortSignal.timeout(35000),
  });
  if (!response.ok) {
    const err = await response.text();
    throw new Error(`Gemini error ${response.status}: ${err.slice(0, 400)}`);
  }
  const data = await response.json();
  const text = data.candidates?.[0]?.content?.parts?.[0]?.text;
  if (!text) throw new Error('Empty Gemini response');
  return text;
}

async function geminiJsonRequest(systemInstruction, userPrompt) {
  const body = {
    systemInstruction: { parts: [{ text: systemInstruction }] },
    contents: [{ role: 'user', parts: [{ text: userPrompt }] }],
    generationConfig: {
      temperature: 0.35,
      maxOutputTokens: 1200,
      responseMimeType: 'application/json',
    },
  };
  let lastErr;
  for (const model of MODELS) {
    try {
      const text = await geminiRequest(model, body);
      return JSON.parse(text);
    } catch (err) {
      lastErr = err;
      if (!String(err.message).includes('404')) break;
    }
  }
  throw lastErr;
}

async function assessCoachingText({ text, sessionType = 'Conversation', context }) {
  const transcript = String(text || '').trim();
  if (!transcript) {
    return normalizeAssessment(
      {
        emotion: 'neutral',
        strengths: [],
        weaknesses: ['No input provided'],
        recommendations: ['Share a specific example for assessment'],
      },
      '',
    );
  }
  const system = `You are VirtuoMate AI Coaching Assessment Engine for ${sessionType} practice.
Evaluate professional communication. ${ASSESSMENT_SCHEMA}`;
  const user = context
    ? `Context:\n${context}\n\nCandidate response:\n${transcript}`
    : `Candidate response:\n${transcript}`;
  const raw = await geminiJsonRequest(system, user);
  return normalizeAssessment(raw, transcript);
}

/** One Gemini call: scores + coaching paragraph (saves quota vs 2 calls). */
async function generateCoachPackage({
  text,
  sessionType = 'Conversation',
  context,
  avatarStyle = 'Professional',
  voiceProfile = 'confident-neutral',
}) {
  const transcript = String(text || '').trim();
  if (!transcript) {
    throw new Error('Empty input');
  }
  const system = `You are VirtuoMate, an emotionally intelligent career coach.
Session: ${sessionType}. Avatar: ${avatarStyle}. Voice: ${voiceProfile}.
Return ONLY valid JSON (no markdown) with:
${ASSESSMENT_SCHEMA}
feedback_text: string, 3-5 sentences of warm actionable coaching (not a bullet list).`;
  const user = context
    ? `Context:\n${context}\n\nCandidate:\n${transcript}`
    : `Candidate:\n${transcript}`;
  const raw = await geminiJsonRequest(system, user);
  const assessment = normalizeAssessment(raw, transcript);
  const feedbackText = String(raw.feedback_text || raw.feedback || '').trim();
  if (!feedbackText) {
    throw new Error('Gemini returned no feedback_text');
  }
  return { assessment, feedback: feedbackText };
}

async function generateCoachFeedbackText({
  sessionType,
  userInput,
  avatarStyle,
  voiceProfile,
  assessment,
}) {
  const system = `You are VirtuoMate, an emotionally intelligent career coach. Avatar: ${avatarStyle}. Voice: ${voiceProfile}. Session: ${sessionType}. Reply in 3-5 sentences. Be supportive, specific, and actionable. Do not use JSON.`;
  const user = `User message:\n${userInput}\n\nAssessment scores — confidence ${assessment.confidence_score}, clarity ${assessment.clarity_score}, emotion ${assessment.emotion}.\nKey focus: ${(assessment.weaknesses || []).join('; ') || 'general improvement'}.\nGive coaching feedback.`;
  const body = {
    systemInstruction: { parts: [{ text: system }] },
    contents: [{ role: 'user', parts: [{ text: user }] }],
    generationConfig: { temperature: 0.7, maxOutputTokens: 500 },
  };
  let lastErr;
  for (const model of MODELS) {
    try {
      return (await geminiRequest(model, body)).trim();
    } catch (err) {
      lastErr = err;
      if (!String(err.message).includes('404')) break;
    }
  }
  throw lastErr;
}

module.exports = {
  assessCoachingText,
  generateCoachPackage,
  generateCoachFeedbackText,
  normalizeAssessment,
  isQuotaError,
  healthPing,
};
