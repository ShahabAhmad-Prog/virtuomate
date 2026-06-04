'use strict';

const assert = require('assert');
const assessment = require('../src/services/assessment.service');

const sample =
  'I am nervous about my interview tomorrow. I led a team of five and delivered on deadline.';

const result = assessment.assessTextLocally({
  text: sample,
  sessionType: 'Conversation',
});

assert.ok(result.confidence_score >= 0 && result.confidence_score <= 100, 'confidence in range');
assert.ok(result.clarity_score >= 0 && result.clarity_score <= 100, 'clarity in range');
assert.ok(result.professionalism_score >= 0 && result.professionalism_score <= 100, 'professionalism');
assert.ok(result.emotion, 'emotion set');
assert.ok(Array.isArray(result.strengths) && result.strengths.length > 0, 'strengths');
assert.ok(Array.isArray(result.recommendations) && result.recommendations.length > 0, 'recommendations');
assert.strictEqual(result.provider, 'linguistic-local');

const feedback = assessment.buildFeedbackFromAssessment(result, 'Conversation');
assert.ok(feedback.includes('Conversation'), 'feedback mentions session');
assert.ok(!feedback.startsWith('Conversation •'), 'no legacy bullet template');

console.log('assessment.local.test.js: PASS');
console.log('  emotion:', result.emotion, 'confidence:', result.confidence_score);
