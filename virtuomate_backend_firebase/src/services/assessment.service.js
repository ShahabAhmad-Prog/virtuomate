'use strict';

const config = require('../config');
const geminiService = require('./gemini.service');

const FILLERS = /\b(um+|uh+|er+|ah+|like|you know|i mean|sort of|kind of|basically|actually)\b/gi;
const HEDGES = /\b(maybe|perhaps|i think|i guess|probably|might|could be|not sure)\b/gi;
const ACHIEVEMENT = /\b(i led|i achieved|i delivered|i improved|i increased|i reduced|we launched|result)\b/gi;
const PASSIVE = /\b(was|were|been|being)\s+\w+ed\b/gi;

function extractFeatures(text) {
  const t = String(text || '').trim();
  const words = t.match(/[a-zA-Z']+/g) || [];
  const nWords = words.length;
  const sentences = t.split(/[.!?]+/).filter((s) => s.trim());
  const nSents = Math.max(sentences.length, 1);
  const fillers = (t.match(FILLERS) || []).length;
  const hedges = (t.match(HEDGES) || []).length;
  const achievements = (t.match(ACHIEVEMENT) || []).length;
  const passive = (t.match(PASSIVE) || []).length;
  const unique = new Set(words.map((w) => w.toLowerCase()).filter((w) => w.length > 3));
  const ttr = unique.size / Math.max(nWords, 1);
  const avgSentLen = nWords / nSents;
  const flesch = Math.min(100, Math.max(0, 206.835 - 1.015 * avgSentLen - 84.6 * (5 / Math.max(nWords, 1))));

  return {
    word_count: Math.min(nWords / 200, 1),
    avg_sentence_length: Math.min(avgSentLen / 30, 1),
    flesch_reading_ease: flesch / 100,
    type_token_ratio: Math.min(ttr, 1),
    filler_rate: Math.min((fillers / Math.max(nWords, 1)) * 20, 1),
    hedge_rate: Math.min((hedges / Math.max(nWords, 1)) * 15, 1),
    achievement_rate: Math.min((achievements / Math.max(nWords, 1)) * 25, 1),
    passive_rate: Math.min((passive / Math.max(nSents, 1)) * 3, 1),
    repetition_score: 0.1,
  };
}

function featuresToScores(features, emotionHint = 'neutral') {
  const f = features;
  const clamp = (x) => Math.max(0, Math.min(100, Math.round(x)));
  let clarity = 100 * (0.35 * f.flesch_reading_ease + 0.25 * (1 - f.filler_rate) + 0.2 * f.type_token_ratio + 0.2 * (1 - Math.min(f.avg_sentence_length, 1)));
  let confidence = 100 * (0.3 * f.achievement_rate + 0.25 * (1 - f.hedge_rate) + 0.2 * f.word_count + 0.15 * (1 - f.filler_rate) + 0.1 * f.type_token_ratio);
  let professionalism = 100 * (0.35 * (1 - f.filler_rate) + 0.25 * (1 - f.hedge_rate) + 0.2 * f.type_token_ratio + 0.2 * (1 - f.passive_rate));
  let anxiety = 100 * (0.4 * f.hedge_rate + 0.35 * f.filler_rate + 0.15 * f.repetition_score + 0.1 * (1 - f.word_count));
  let communication = clarity * 0.4 + confidence * 0.35 + professionalism * 0.25;
  let interview_readiness = confidence * 0.35 + professionalism * 0.3 + clarity * 0.2 + (100 - anxiety) * 0.15;

  if (emotionHint === 'anxious') {
    anxiety = Math.min(100, anxiety + 12);
    confidence = Math.max(0, confidence - 8);
  } else if (emotionHint === 'confident') {
    confidence = Math.min(100, confidence + 10);
    anxiety = Math.max(0, anxiety - 10);
  }

  return {
    confidence_score: clamp(confidence),
    clarity_score: clamp(clarity),
    professionalism_score: clamp(professionalism),
    anxiety_score: clamp(anxiety),
    communication_score: clamp(communication),
    interview_readiness_score: clamp(interview_readiness),
  };
}

function emotionFromScores(scores, features) {
  if (scores.anxiety_score >= 65) return 'anxious';
  if (scores.confidence_score >= 75) return 'confident';
  if (features.achievement_rate > 0.2) return 'professional';
  if (scores.clarity_score >= 70) return 'focused';
  return 'neutral';
}

function strengthsWeaknesses(features, scores) {
  const strengths = [];
  const weaknesses = [];
  if (scores.confidence_score >= 70) strengths.push('Confident delivery with assertive phrasing');
  if (scores.clarity_score >= 70) strengths.push('Clear sentence structure and readable flow');
  if (features.achievement_rate > 0.15) strengths.push('Uses outcome-oriented language');
  if (features.type_token_ratio > 0.45) strengths.push('Strong vocabulary variety');
  if (features.filler_rate > 0.2) weaknesses.push('Frequent filler words reduce perceived authority');
  if (features.hedge_rate > 0.15) weaknesses.push('Hedging language signals uncertainty');
  if (scores.clarity_score < 55) weaknesses.push('Responses could be more concise and structured');
  if (scores.anxiety_score > 60) weaknesses.push('Anxiety markers detected — practice pacing and breathing');
  if (!strengths.length) strengths.push('Good foundation — keep practicing structured answers');
  if (!weaknesses.length) weaknesses.push('Fine-tune pacing and add one measurable result per answer');
  return { strengths: strengths.slice(0, 4), weaknesses: weaknesses.slice(0, 4) };
}

function recommendations(scores, weaknesses, sessionType) {
  const recs = [];
  if (scores.anxiety_score > 55) recs.push('Pause briefly before key points; practice answers aloud twice');
  if (scores.clarity_score < 65) recs.push('Use a three-part structure: context → action → result');
  if (weaknesses.some((w) => w.toLowerCase().includes('filler'))) {
    recs.push('Replace filler words with a one-second pause');
  }
  if (sessionType.includes('Interview')) {
    recs.push('Prepare two STAR stories with metrics (%, time, revenue)');
  } else if (sessionType.includes('Presentation')) {
    recs.push('Open with a hook; close with a clear call to action');
  } else {
    recs.push('Add one measurable achievement to strengthen impact');
  }
  return recs.slice(0, 5);
}

function assessTextLocally({ text, sessionType = 'Conversation', context }) {
  let t = String(text || '').trim();
  if (!t) {
    return {
      confidence_score: 0,
      clarity_score: 0,
      professionalism_score: 0,
      anxiety_score: 0,
      communication_score: 0,
      interview_readiness_score: 0,
      emotion: 'neutral',
      avatar_expression: 'neutral',
      strengths: [],
      weaknesses: ['No input provided'],
      recommendations: ['Share a specific example so the coach can assess your delivery'],
      provider: 'linguistic-local',
      transcript: '',
    };
  }
  if (context) t = `${context.trim()}\n\n${t}`;
  const features = extractFeatures(t);
  const scores = featuresToScores(features);
  const emotion = emotionFromScores(scores, features);
  const avatarExpression =
    emotion === 'anxious' || emotion === 'nervous' ? 'encouraging' : emotion;
  const { strengths, weaknesses } = strengthsWeaknesses(features, scores);
  const recs = recommendations(scores, weaknesses, sessionType);
  return {
    ...scores,
    emotion,
    avatar_expression: avatarExpression,
    strengths,
    weaknesses,
    recommendations: recs,
    provider: 'linguistic-local',
    transcript: String(text || '').trim(),
  };
}

async function assessTextRemote(payload) {
  const base = config.intelligenceEngineUrl.replace(/\/$/, '');
  const response = await fetch(`${base}/analyze-text`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({
      text: payload.text,
      session_type: payload.sessionType || 'Conversation',
      context: payload.context,
    }),
    signal: AbortSignal.timeout(20000),
  });
  if (!response.ok) {
    const err = await response.text();
    throw new Error(`Intelligence engine error: ${response.status} ${err}`);
  }
  return response.json();
}

async function assessText(payload) {
  if (config.geminiApiKey) {
    try {
      return await geminiService.assessCoachingText(payload);
    } catch (err) {
      // eslint-disable-next-line no-console
      console.warn('Gemini assessment fallback:', err.message);
      if (geminiService.isQuotaError(err)) {
        const local = assessTextLocally(payload);
        return { ...local, provider: 'gemini-quota-local-estimate' };
      }
    }
  }
  return assessTextLocally(payload);
}

function buildFeedbackFromAssessment(assessment, sessionType) {
  const emotion = assessment.emotion || 'neutral';
  const conf = assessment.confidence_score ?? 50;
  const clarity = assessment.clarity_score ?? 50;
  const comm = assessment.communication_score ?? 50;
  const strengths = (assessment.strengths || []).filter(Boolean);
  const focus = (assessment.weaknesses || []).filter(Boolean);
  const next =
    assessment.recommendations?.[0] || 'Practice one STAR example aloud with a clear result.';

  const strengthLine = strengths.length
    ? `What works well: ${strengths.slice(0, 2).join('; ')}.`
    : 'You answered with clear intent.';
  const focusLine = focus.length
    ? `To improve: ${focus.slice(0, 2).join('; ')}.`
    : 'Add one measurable outcome to strengthen your story.';

  return (
    `Thanks for your ${sessionType} practice. I sense a ${emotion} tone at about ${conf}% confidence. ` +
    `${strengthLine} ${focusLine} ` +
    `Clarity ${clarity}% · communication ${comm}%. ` +
    `Next step: ${next}`
  );
}

module.exports = {
  assessText,
  assessTextLocally,
  buildFeedbackFromAssessment,
  extractFeatures,
  featuresToScores,
};
