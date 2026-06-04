'use strict';

const config = require('../config');
const assessmentService = require('./assessment.service');
const geminiService = require('./gemini.service');

function detectEmotion(userInput) {
  const t = String(userInput || '').toLowerCase();
  if (t.includes('nervous') || t.includes('anxious') || t.includes('worried')) return 'Anxious';
  if (t.includes('excited') || t.includes('happy') || t.includes('great')) return 'Happy';
  if (t.includes('frustrated') || t.includes('difficult')) return 'Concerned';
  if (t.trim().length < 20) return 'Neutral';
  if (t.trim().length > 120) return 'Confident';
  return 'Focused';
}

function estimateConfidence(userInput) {
  const words = String(userInput || '').trim().split(/\s+/).filter(Boolean);
  if (words.length === 0) return 35;
  let score = 50 + Math.min(words.length * 2, 30);
  const lower = String(userInput).toLowerCase();
  if (lower.includes('i led') || lower.includes('i achieved')) score += 8;
  if (lower.includes('um') || lower.includes('uh')) score -= 10;
  if (lower.includes('maybe')) score -= 5;
  return Math.max(35, Math.min(95, score));
}

function localCoachFeedback({ sessionType, userInput, avatarStyle, voiceProfile, emotion, stepIndex }) {
  const confidence = estimateConfidence(userInput);
  const trimmed = String(userInput || '').trim();
  if (!trimmed) {
    return {
      feedback: `${sessionType}: Share a specific example so your ${avatarStyle} coach can give targeted feedback.`,
      emotion: emotion || 'Neutral',
      confidence,
      provider: 'local',
    };
  }
  if (sessionType.includes('Interview')) {
    const phases = ['introduction', 'experience', 'closing'];
    const phase = phases[stepIndex] || 'interview';
    const msg = confidence < 55
      ? `Interview (${phase}) • ${emotion} at ${confidence}% confidence. Structure with opening, example, and close. Reduce filler words.`
      : `Interview (${phase}) • Strong ${confidence}% delivery (${emotion}). Add one measurable result to strengthen impact.`;
    return { feedback: msg, emotion, confidence, provider: 'local' };
  }
  if (sessionType.includes('Presentation')) {
    return {
      feedback: `Presentation • Audience engaged (${emotion}). Confidence ${confidence}%. ${confidence >= 70 ? 'Excellent pacing.' : 'Slow down and emphasize your hook.'}`,
      emotion,
      confidence,
      provider: 'local',
    };
  }

  const lower = trimmed.toLowerCase();
  if (
    sessionType.includes('Conversation') ||
    sessionType.includes('Voice')
  ) {
    if (lower.includes('interview') || lower.includes('rscs') || lower.includes('job')) {
      const org = lower.includes('rscs') ? 'RSCS' : 'your target role';
      return {
        feedback:
          `Interview prep (${org}) • ${emotion} tone, ${confidence}% clarity.\n\n` +
          '1) Research the company mission, recent projects, and role requirements.\n' +
          '2) Prepare a 60-second intro: who you are, your strength, and why this role.\n' +
          '3) Use STAR for behavioral questions (Situation, Task, Action, Result).\n' +
          '4) Prepare 3 smart questions for the panel (team culture, success metrics, growth).\n' +
          '5) Practice aloud twice — record yourself and reduce filler words.\n\n' +
          (trimmed.length < 40
            ? 'Tell me the job title and one skill they require for more tailored questions.'
            : 'Strong start — add one measurable achievement from your last project.'),
        emotion,
        confidence,
        provider: 'local',
      };
    }
    if (lower.includes('presentation') || lower.includes('present')) {
      return {
        feedback:
          `Presentation coaching • ${emotion} • ${confidence}% clarity.\n\n` +
          'Open with a hook, state 3 key points, and close with a clear call to action. ' +
          'Pause after each main point. Add one real example with numbers (time saved, revenue, users).',
        emotion,
        confidence,
        provider: 'local',
      };
    }
  }

  return {
    feedback:
      `AI Coach [${avatarStyle}/${voiceProfile}] • ${emotion} • ${confidence}% clarity.\n\n` +
      (trimmed.length > 80
        ? 'Good detail in your message. Next: add one measurable result and what you learned.'
        : 'Share more context (role, goal, or situation) so I can give step-by-step coaching.') +
      ' Keep practicing consistently.',
    emotion,
    confidence,
    provider: 'local',
  };
}

async function callOpenAi({ sessionType, userInput, avatarStyle, voiceProfile }) {
  const system = `You are VirtuoMate, an emotionally intelligent AI career coach. Avatar style: ${avatarStyle}. Voice: ${voiceProfile}. Session: ${sessionType}. Give concise, actionable feedback (3-5 sentences). Be supportive and professional.`;
  const response = await fetch('https://api.openai.com/v1/chat/completions', {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      Authorization: `Bearer ${config.openAiApiKey}`,
    },
    body: JSON.stringify({
      model: config.openAiModel,
      messages: [
        { role: 'system', content: system },
        { role: 'user', content: userInput },
      ],
      max_tokens: 400,
      temperature: 0.7,
    }),
  });
  if (!response.ok) {
    const err = await response.text();
    throw new Error(`OpenAI error: ${response.status} ${err}`);
  }
  const data = await response.json();
  const feedback = data.choices?.[0]?.message?.content?.trim();
  if (!feedback) throw new Error('Empty OpenAI response');
  const emotion = detectEmotion(userInput);
  return {
    feedback,
    emotion,
    confidence: estimateConfidence(userInput),
    provider: 'openai',
  };
}

async function generateCoachFeedback(payload) {
  const stepIndex = payload.stepIndex ?? 0;
  const sessionType = payload.sessionType || 'Conversation';
  const userInput = payload.userInput || '';
  const avatarStyle = payload.avatarStyle || 'Professional';
  const voiceProfile = payload.voiceProfile || 'confident-neutral';

  const base = {
    sessionType,
    userInput,
    avatarStyle,
    voiceProfile,
    emotion: payload.emotion || detectEmotion(userInput),
    stepIndex,
  };

  if (config.geminiApiKey && userInput.trim()) {
    try {
      const pack = await geminiService.generateCoachPackage({
        text: userInput,
        sessionType,
        context: payload.context,
        avatarStyle,
        voiceProfile,
      });
      const assessment = pack.assessment;
      const emotion = payload.emotion || assessment.emotion || detectEmotion(userInput);
      return {
        feedback: pack.feedback,
        emotion,
        confidence: assessment.confidence_score ?? estimateConfidence(userInput),
        assessment,
        provider: 'gemini',
      };
    } catch (err) {
      // eslint-disable-next-line no-console
      console.error('Gemini coach error:', err.message);
      const billing = geminiService.isQuotaError(err);

      if (config.openAiApiKey) {
        try {
          const openAi = await callOpenAi(base);
          const local = assessmentService.assessTextLocally({
            text: userInput,
            sessionType,
          });
          return {
            feedback: openAi.feedback,
            emotion: openAi.emotion,
            confidence: openAi.confidence,
            assessment: { ...local, provider: 'openai-gemini-fallback' },
            provider: 'openai',
            coachHint: billing
              ? 'Gemini quota exhausted — using OpenAI for this reply.'
              : undefined,
          };
        } catch (openErr) {
          // eslint-disable-next-line no-console
          console.warn('OpenAI coach fallback failed:', openErr.message);
        }
      }

      const local = assessmentService.assessTextLocally({
        text: userInput,
        sessionType,
      });
      return {
        feedback: assessmentService.buildFeedbackFromAssessment(local, sessionType),
        emotion: payload.emotion || local.emotion,
        confidence: local.confidence_score,
        assessment: local,
        provider: billing ? 'gemini-quota' : 'linguistic-local',
        coachHint: billing
          ? 'Gemini credits depleted. Add billing at https://aistudio.google.com or set OPENAI_API_KEY on Cloud Functions.'
          : 'Cloud AI unavailable — using on-device coaching templates.',
      };
    }
  }

  let assessment;
  try {
    assessment = await assessmentService.assessText({
      text: userInput,
      sessionType,
      context: payload.context,
    });
  } catch (err) {
    assessment = assessmentService.assessTextLocally({ text: userInput, sessionType });
  }

  const emotion = payload.emotion || assessment.emotion || detectEmotion(userInput);
  const confidence = assessment.confidence_score ?? estimateConfidence(userInput);
  base.emotion = emotion;

  if (config.openAiApiKey && config.aiProvider === 'openai') {
    try {
      const openAi = await callOpenAi(base);
      return {
        ...openAi,
        emotion,
        confidence,
        assessment,
        provider: openAi.provider,
      };
    } catch (err) {
      // eslint-disable-next-line no-console
      console.warn('OpenAI fallback:', err.message);
    }
  }

  const local = localCoachFeedback(base);
  return {
    ...local,
    emotion,
    confidence,
    feedback: assessmentService.buildFeedbackFromAssessment(
      { ...assessment, emotion },
      sessionType,
    ),
    assessment,
    provider: assessment.provider || local.provider,
  };
}

async function analyzeText(payload) {
  return assessmentService.assessText({
    text: payload.text || payload.userInput,
    sessionType: payload.sessionType || 'Conversation',
    context: payload.context,
  });
}

function buildVideoCvScript(data) {
  const name = data.fullName?.trim() || 'Candidate';
  const headline = data.headline?.trim() || 'Professional Profile';
  const summary = data.summary?.trim() || 'A motivated professional ready to contribute.';
  const skills = data.skills?.trim() || 'communication and teamwork';
  const experience = data.experience?.trim() || 'relevant hands-on experience';
  const education = data.education?.trim() || 'a strong educational foundation';
  return `Hello, I am ${name}. ${headline}. ${summary}. My key skills include ${skills}. In terms of experience, ${experience}. My education includes ${education}. Thank you for reviewing my profile.`;
}

function esc(s) {
  return String(s || '')
    .replace(/&/g, '&amp;')
    .replace(/</g, '&lt;')
    .replace(/>/g, '&gt;');
}

function buildVideoCvHtml(data) {
  const name = esc(data.fullName?.trim() || 'Candidate');
  const script = esc(data.script || buildVideoCvScript(data));
  return `<!DOCTYPE html><html lang="en"><head><meta charset="UTF-8"/><title>VirtuoMate Video CV — ${name}</title>
<style>body{font-family:system-ui,sans-serif;background:#0b1220;color:#e8eef7;padding:24px;max-width:720px;margin:auto}
h1{color:#3be7ff}.card{background:#141c2e;border:1px solid #2a3550;border-radius:12px;padding:16px;margin:12px 0}
.script{white-space:pre-wrap;line-height:1.6}</style></head><body>
<h1>${name}</h1><p>${esc(data.headline)}</p>
<div class="card"><h3>Summary</h3><p>${esc(data.summary)}</p></div>
<div class="card"><h3>Skills</h3><p>${esc(data.skills)}</p></div>
<div class="card"><h3>Experience</h3><p>${esc(data.experience)}</p></div>
<div class="card"><h3>Education</h3><p>${esc(data.education)}</p></div>
<div class="card"><h3>Narration</h3><p class="script">${script}</p></div>
</body></html>`;
}

module.exports = {
  detectEmotion,
  estimateConfidence,
  generateCoachFeedback,
  analyzeText,
  buildVideoCvScript,
  buildVideoCvHtml,
};
