'use strict';

const express = require('express');
const cors = require('cors');
const { z } = require('zod');
const admin = require('firebase-admin');
const config = require('./config');
const { requireAuth, requireAdmin } = require('./middleware/auth');
const coachService = require('./services/coach.service');
const videoCvRenderService = require('./services/video_cv_render.service');
const fs = require('fs');
const neuralConnectivity = require('./services/neural_connectivity');
const Stripe = require('stripe');
const crypto = require('crypto');

function getStripe() {
  if (!config.stripeSecretKey) return null;
  return new Stripe(config.stripeSecretKey, { apiVersion: '2024-11-20.acacia' });
}

function createApp() {
  const db = admin.firestore();
  const app = express();
  app.use(cors({ origin: config.corsOrigin === '*' ? true : config.corsOrigin }));

  function firebaseDownloadUrl(bucketName, objectPath, token) {
    // Works with Firebase Storage download tokens (no IAM signBlob required).
    return `https://firebasestorage.googleapis.com/v0/b/${bucketName}/o/${encodeURIComponent(
      objectPath,
    )}?alt=media&token=${token}`;
  }

  app.post('/payments/webhook', express.raw({ type: 'application/json' }), async (req, res) => {
    const stripe = getStripe();
    if (!stripe || !config.stripeWebhookSecret) {
      return res.status(501).json({ error: 'Stripe webhook not configured.' });
    }
    const sig = req.headers['stripe-signature'];
    let event;
    try {
      event = stripe.webhooks.constructEvent(req.body, sig, config.stripeWebhookSecret);
    } catch (err) {
      return res.status(400).json({ error: `Webhook signature failed: ${err.message}` });
    }
    if (event.type === 'checkout.session.completed') {
      const session = event.data.object;
      const uid = session.metadata?.firebaseUid;
      const plan = session.metadata?.planId || 'annual';
      if (uid) {
        await db.collection('users').doc(uid).set(
          {
            isPremium: true,
            premiumPlan: plan,
            premiumActivatedAt: admin.firestore.FieldValue.serverTimestamp(),
            stripeCustomerId: session.customer || null,
          },
          { merge: true },
        );
      }
    }
    return res.json({ received: true });
  });

  app.use(express.json({ limit: '2mb' }));

  /** Reset or create shared demo Firebase user; returns custom token for the app. */
  app.post('/auth/demo', async (_req, res) => {
    const email = config.demoEmail;
    const password = config.demoPassword;
    const displayName = 'Demo User';
    let uid;
    try {
      try {
        const existing = await admin.auth().getUserByEmail(email);
        uid = existing.uid;
        await admin.auth().updateUser(uid, { password, displayName, emailVerified: true });
      } catch (err) {
        if (err.code !== 'auth/user-not-found') {
          throw err;
        }
        const created = await admin.auth().createUser({
          email,
          password,
          displayName,
          emailVerified: true,
        });
        uid = created.uid;
      }
      const customToken = await admin.auth().createCustomToken(uid);
      return res.json({
        customToken,
        email,
        displayName,
      });
    } catch (err) {
      return res.status(500).json({
        error: err.message || 'Demo login setup failed.',
      });
    }
  });

  app.get('/health', async (_req, res) => {
    const engineUrl = config.intelligenceEngineUrl || null;
    let intelligenceEngine = 'linguistic-local';
    if (engineUrl) {
      intelligenceEngine = await neuralConnectivity.probeIntelligenceEngine(engineUrl);
    }
    const neural = neuralConnectivity.computeNeuralConnectivity({
      engineUrl,
      intelligenceEngine,
      apiOk: true,
      geminiConfigured: Boolean(config.geminiApiKey),
    });
    let geminiStatus = 'not_configured';
    // Image avatar API is not probed on /health (saves credits). Use scripts/test-gemini-image.js.
    let geminiImageStatus = 'not_configured';
    let geminiImageProbe = 'skipped';
    if (config.geminiApiKey) {
      geminiImageStatus = 'configured';
      try {
        const geminiService = require('./services/gemini.service');
        await geminiService.healthPing();
        geminiStatus = 'ok';
      } catch (err) {
        const msg = String(err.message || err);
        if (msg.includes('API_KEY_SERVICE_BLOCKED')) {
          geminiStatus = 'api_blocked_fix_key_restrictions';
        } else if (
          msg.includes('429') ||
          msg.toLowerCase().includes('quota') ||
          msg.toLowerCase().includes('prepayment') ||
          msg.toLowerCase().includes('resource_exhausted')
        ) {
          geminiStatus = 'quota_billing_required';
        } else if (msg.includes('503') || msg.toLowerCase().includes('high demand')) {
          geminiStatus = 'high_demand_retry_later';
        } else {
          geminiStatus = 'error';
        }
      }

      if (process.env.HEALTH_PROBE_GEMINI_IMAGE === 'true') {
        geminiImageProbe = 'live';
        try {
          const avatarVroid = require('./services/avatar_vroid.service');
          const probe = await avatarVroid.generateVroidStylePortrait({
            imageBuffer: Buffer.from(
              '/9j/4AAQSkZJRgABAQEASABIAAD/2wBDAP//////////////////////////////////////////////////////////////////////////////////////2wBDAf//////////////////////////////////////////////////////////////////////////////////////wAARCAABAAEDASIAAhEBAxEB/8QAFQABAQAAAAAAAAAAAAAAAAAAAAb/xAAUEAEAAAAAAAAAAAAAAAAAAAAA/8QAFQEBAQAAAAAAAAAAAAAAAAAAAAX/xAAUEQEAAAAAAAAAAAAAAAAAAAAA/9oADAMBAAIRAxEAPwCdABmX/9k=',
              'base64',
            ),
            mimeType: 'image/jpeg',
            avatarStyle: 'Professional',
          });
          geminiImageStatus = probe?.buffer?.length ? 'ok' : 'error';
        } catch (err) {
          const msg = String(err.message || err);
          if (
            msg.includes('429') ||
            msg.toLowerCase().includes('quota') ||
            msg.toLowerCase().includes('prepayment')
          ) {
            geminiImageStatus = 'quota_billing_required';
          } else if (msg.includes('404') || msg.includes('not found')) {
            geminiImageStatus = 'model_not_available';
          } else if (msg.includes('503') || msg.toLowerCase().includes('high demand')) {
            geminiImageStatus = 'high_demand_retry_later';
          } else {
            geminiImageStatus = 'error';
          }
        }
      }
    }

    res.json({
      ok: true,
      backend: 'virtuomate-api',
      videoRenderFfmpeg: videoCvRenderService.isFfmpegAvailable(),
      videoRenderAssets: videoCvRenderService.isRenderAssetsReady?.() ?? true,
      geminiConfigured: Boolean(config.geminiApiKey),
      geminiStatus,
      geminiImageStatus,
      geminiImageProbe,
      geminiImageModel: process.env.GEMINI_IMAGE_MODEL || 'gemini-2.5-flash-image',
      vroidAvatarEndpoint: '/storage/avatar/vroid-from-photo',
      aiProvider: config.geminiApiKey
        ? 'gemini'
        : config.openAiApiKey
          ? config.aiProvider
          : 'local',
      paymentMode: config.paymentMode,
      intelligenceEngineUrl: engineUrl,
      intelligenceEngine,
      neuralConnectivity: neural,
    });
  });

  /** Ensure user document exists after registration/login */
  app.post('/user/bootstrap', requireAuth, async (req, res) => {
    const uid = req.user.uid;
    const email = req.user.email || '';
    const schema = z.object({
      displayName: z.string().max(120).optional(),
      phone: z.string().max(40).optional(),
    });
    const parsed = schema.safeParse(req.body || {});
    const extra = parsed.success ? parsed.data : {};
    const ref = db.collection('users').doc(uid);
    const existing = await ref.get();
    const displayName =
      extra.displayName || req.user.name || email.split('@')[0] || 'User';

    if (!existing.exists) {
      await ref.set({
        email,
        displayName,
        phone: extra.phone || '',
        avatarStyle: 'Professional',
        voiceProfile: 'confident-neutral',
        voiceGender: 'female',
        isPremium: false,
        videoCvCount: 0,
        missionProgress: 0,
        preferences: {
          emailNotifications: true,
          pushNotifications: true,
          sessionReminders: true,
          achievementAlerts: false,
          languageCode: 'en',
          textScale: 1,
          highContrast: false,
        },
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      });
      return res.json({ bootstrapped: true, created: true });
    }

    const patch = {
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    };
    if (email) patch.email = email;
    if (extra.displayName) patch.displayName = extra.displayName;
    if (extra.phone !== undefined) patch.phone = extra.phone;
    await ref.set(patch, { merge: true });
    return res.json({ bootstrapped: true, created: false });
  });

  app.get('/user/profile', requireAuth, async (req, res) => {
    const uid = req.user.uid;
    const doc = await db.collection('users').doc(uid).get();
    const data = doc.exists ? doc.data() : {};
    return res.json({
      uid,
      email: req.user.email || data.email || '',
      displayName: data.displayName || '',
      phone: data.phone || '',
      avatarStyle: data.avatarStyle || 'Professional',
      avatarImageUrl: data.avatarImageUrl || '',
      avatarUseTemplate: data.avatarUseTemplate !== false,
      avatarEmotionState: data.avatarEmotionState || 'neutral',
      voiceProfile: data.voiceProfile || 'confident-neutral',
      voiceGender: data.voiceGender || 'female',
      isPremium: Boolean(data.isPremium),
      premiumPlan: data.premiumPlan || null,
      videoCvCount: Number(data.videoCvCount || 0),
      missionProgress: Number(data.missionProgress || 0),
      videoCvDraft: data.videoCvDraft || null,
      preferences: data.preferences || null,
    });
  });

  app.put('/user/profile', requireAuth, async (req, res) => {
    const schema = z.object({
      displayName: z.string().min(1).max(120).optional(),
      phone: z.string().max(40).optional(),
      avatarStyle: z.string().min(2).max(64).optional(),
      avatarImageUrl: z.string().min(3).max(2000).optional(),
      avatarUseTemplate: z.boolean().optional(),
      avatarEmotionState: z.string().min(3).max(32).optional(),
      voiceProfile: z.string().min(3).max(80).optional(),
      voiceGender: z.enum(['male', 'female']).optional(),
      missionProgress: z.number().int().min(0).max(100).optional(),
      videoCvDraft: z.record(z.string(), z.unknown()).optional(),
      preferences: z.record(z.string(), z.unknown()).optional(),
    });
    const parsed = schema.safeParse(req.body || {});
    if (!parsed.success) return res.status(400).json({ error: 'Invalid payload.' });
    const uid = req.user.uid;
    // Premium flags are server-only (payments/bootstrap); never accept from client PUT.
    await db.collection('users').doc(uid).set(
      { ...parsed.data, updatedAt: admin.firestore.FieldValue.serverTimestamp() },
      { merge: true },
    );
    return res.json({ updated: true });
  });

  app.post('/sessions', requireAuth, async (req, res) => {
    const schema = z.object({
      type: z.string().min(2).max(64),
      prompt: z.string().min(1).max(4000),
      feedback: z.string().min(1).max(4000),
      emotion: z.string().max(32).optional(),
      confidenceScore: z.number().int().min(0).max(100).optional(),
      assessment: z.record(z.string(), z.unknown()).optional(),
    });
    const parsed = schema.safeParse(req.body || {});
    if (!parsed.success) return res.status(400).json({ error: 'Invalid payload.' });

    const uid = req.user.uid;
    const userDoc = await db.collection('users').doc(uid).get();
    const isPremium = Boolean(userDoc.data()?.isPremium);
    if (!isPremium) {
      const countSnap = await db
        .collection('users')
        .doc(uid)
        .collection('sessions')
        .count()
        .get();
      if (countSnap.data().count >= config.freeSessionLimit) {
        return res.status(402).json({
          error: 'Free session limit reached. Upgrade to Premium.',
          code: 'SESSION_LIMIT',
        });
      }
    }

    const ref = await db.collection('users').doc(uid).collection('sessions').add({
      ...parsed.data,
      emotion: parsed.data.emotion || coachService.detectEmotion(parsed.data.prompt),
      confidenceScore:
        parsed.data.confidenceScore ??
        coachService.estimateConfidence(parsed.data.prompt),
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
    });
    return res.status(201).json({ id: ref.id });
  });

  app.get('/sessions', requireAuth, async (req, res) => {
    const uid = req.user.uid;
    const snap = await db
      .collection('users')
      .doc(uid)
      .collection('sessions')
      .orderBy('createdAt', 'desc')
      .limit(50)
      .get();
    const sessions = snap.docs.map((d) => ({ id: d.id, ...d.data() }));
    return res.json({ sessions });
  });

  app.get('/feedback/latest', requireAuth, async (req, res) => {
    const uid = req.user.uid;
    const snap = await db
      .collection('users')
      .doc(uid)
      .collection('sessions')
      .orderBy('createdAt', 'desc')
      .limit(1)
      .get();
    if (snap.empty) return res.json({ feedback: 'No feedback yet.' });
    return res.json({ feedback: snap.docs[0].data().feedback || 'No feedback yet.' });
  });

  app.get('/analytics/user', requireAuth, async (req, res) => {
    const uid = req.user.uid;
    const userDoc = await db.collection('users').doc(uid).get();
    const user = userDoc.data() || {};
    const sessionsSnap = await db
      .collection('users')
      .doc(uid)
      .collection('sessions')
      .orderBy('createdAt', 'desc')
      .limit(100)
      .get();

    let conversations = 0;
    let rolePlay = 0;
    let interviews = 0;
    let presentations = 0;
    let confidenceSum = 0;
    let claritySum = 0;
    let communicationSum = 0;
    let count = 0;

    sessionsSnap.docs.forEach((d) => {
      const s = d.data();
      const type = String(s.type || '');
      if (type === 'Conversation' || type.includes('Voice')) conversations += 1;
      else if (type.includes('Role Play')) rolePlay += 1;
      else if (type.includes('Interview')) interviews += 1;
      else if (type.includes('Presentation')) presentations += 1;
      const a = s.assessment || {};
      const conf = Number(a.confidence_score ?? s.confidenceScore ?? 0);
      const clarity = Number(a.clarity_score ?? 0);
      const comm = Number(a.communication_score ?? 0);
      if (conf > 0 || clarity > 0) {
        confidenceSum += conf;
        claritySum += clarity || conf;
        communicationSum += comm || conf;
        count += 1;
      }
    });

    const avgConf = count > 0 ? Math.round(confidenceSum / count) : 72;
    const avgClarity = count > 0 ? Math.round(claritySum / count) : 70;
    const avgComm = count > 0 ? Math.round(communicationSum / count) : 75;

    return res.json({
      conversationSessions: conversations,
      rolePlaySessions: rolePlay,
      interviewSessions: interviews,
      presentationSessions: presentations,
      videoCvGenerated: Number(user.videoCvCount || 0),
      avgConfidence: avgConf,
      avgSentiment: avgClarity,
      avgEngagement: avgComm,
      progressPercent: Number(user.missionProgress || 0),
    });
  });

  app.post('/video-cv/generate', requireAuth, async (req, res) => {
    const uid = req.user.uid;
    const userDoc = await db.collection('users').doc(uid).get();
    const isPremium = Boolean(userDoc.data()?.isPremium);
    const count = Number(userDoc.data()?.videoCvCount || 0);
    if (!isPremium && count >= 2) {
      return res.status(402).json({ error: 'Video CV limit reached for free tier.', code: 'VIDEO_CV_LIMIT' });
    }
    await db.collection('users').doc(uid).set(
      { videoCvCount: admin.firestore.FieldValue.increment(1) },
      { merge: true },
    );
    return res.json({ queued: true, message: 'Video CV generation recorded.' });
  });

  /** FFmpeg render: TTS narration + slide video → MP4/WebM in Storage. */
  app.post('/video-cv/render-job', requireAuth, async (req, res) => {
    const schema = z.object({
      script: z.string().min(10).max(8000),
      format: z.enum(['mp4', 'webm']).optional(),
      draft: z.record(z.string(), z.unknown()).optional(),
    });
    const parsed = schema.safeParse(req.body || {});
    if (!parsed.success) return res.status(400).json({ error: 'Invalid payload.' });

    const uid = req.user.uid;
    const userDoc = await db.collection('users').doc(uid).get();
    const isPremium = Boolean(userDoc.data()?.isPremium);
    const count = Number(userDoc.data()?.videoCvCount || 0);
    if (!isPremium && count >= 2) {
      return res.status(402).json({ error: 'Video CV limit reached for free tier.', code: 'VIDEO_CV_LIMIT' });
    }

    const format = parsed.data.format || 'mp4';
    const draft = parsed.data.draft || {};
    const jobRef = db.collection('users').doc(uid).collection('videoCvJobs').doc();
    const jobId = jobRef.id;

    await jobRef.set({
      status: 'processing',
      format,
      script: parsed.data.script,
      draft,
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
    });

    const bucket = admin.storage().bucket();
    let videoDownloadUrl = null;
    let videoObjectPath = null;
    let renderError = null;
    let localVideoPath = null;

    if (videoCvRenderService.isFfmpegAvailable()) {
      try {
        const profile = userDoc.data() || {};
        localVideoPath = await videoCvRenderService.renderVideoCv({
          script: parsed.data.script,
          draft: {
            ...draft,
            avatarImageUrl: draft.avatarImageUrl || profile.avatarImageUrl || '',
          },
          format,
        });
        const ext = format === 'webm' ? 'webm' : 'mp4';
        videoObjectPath = `video-cv/${uid}/renders/${jobId}.${ext}`;
        const videoFile = bucket.file(videoObjectPath);
        const videoBuffer = await fs.promises.readFile(localVideoPath);
        const contentType = format === 'webm' ? 'video/webm' : 'video/mp4';
        await videoFile.save(videoBuffer, {
          contentType,
          metadata: { cacheControl: 'private, max-age=86400' },
        });
        const videoToken = crypto.randomUUID();
        await videoFile.setMetadata({ metadata: { firebaseStorageDownloadTokens: videoToken } });
        videoDownloadUrl = firebaseDownloadUrl(bucket.name, videoObjectPath, videoToken);
      } catch (err) {
        renderError = err.message || String(err);
        // eslint-disable-next-line no-console
        console.error('Video CV FFmpeg render failed:', renderError);
      } finally {
        if (localVideoPath) {
          await videoCvRenderService.cleanupWorkDirForFile(localVideoPath);
        }
      }
    } else {
      renderError = 'FFmpeg binary not available on server';
    }

    const objectPath = `video-cv/${uid}/renders/${jobId}.json`;
    const artifact = {
      format,
      script: parsed.data.script,
      draft,
      videoRendered: Boolean(videoDownloadUrl),
      renderError,
      generatedAt: new Date().toISOString(),
    };
    const file = bucket.file(objectPath);
    await file.save(JSON.stringify(artifact, null, 2), {
      contentType: 'application/json',
      metadata: { cacheControl: 'private, max-age=3600' },
    });
    const jsonToken = crypto.randomUUID();
    await file.setMetadata({ metadata: { firebaseStorageDownloadTokens: jsonToken } });
    const downloadUrl = firebaseDownloadUrl(bucket.name, objectPath, jsonToken);

    const htmlPath = `video-cv/${uid}/renders/${jobId}.html`;
    const html = coachService.buildVideoCvHtml({
      fullName: draft.fullName || 'Candidate',
      headline: draft.headline || '',
      summary: draft.summary || '',
      skills: draft.skills || '',
      experience: draft.experience || '',
      education: draft.education || '',
      script: parsed.data.script,
    });
    const htmlFile = bucket.file(htmlPath);
    await htmlFile.save(html, { contentType: 'text/html; charset=utf-8' });
    const htmlToken = crypto.randomUUID();
    await htmlFile.setMetadata({ metadata: { firebaseStorageDownloadTokens: htmlToken } });
    const htmlDownloadUrl = firebaseDownloadUrl(bucket.name, htmlPath, htmlToken);

    const status = videoDownloadUrl ? 'completed' : renderError ? 'failed' : 'completed';
    await jobRef.update({
      status,
      downloadUrl,
      htmlDownloadUrl,
      videoDownloadUrl,
      videoObjectPath,
      renderError,
      objectPath,
      htmlPath,
      completedAt: admin.firestore.FieldValue.serverTimestamp(),
    });
    await db.collection('users').doc(uid).set(
      { videoCvCount: admin.firestore.FieldValue.increment(1) },
      { merge: true },
    );

    if (!videoDownloadUrl && renderError) {
      return res.status(201).json({
        jobId,
        status: 'failed',
        renderError,
        detail: renderError,
        downloadUrl,
        htmlDownloadUrl,
        format,
        message: 'Video render failed on server.',
      });
    }

    return res.status(201).json({
      jobId,
      status: 'completed',
      downloadUrl,
      htmlDownloadUrl,
      videoDownloadUrl,
      format,
      message: videoDownloadUrl
        ? 'Video CV rendered with FFmpeg.'
        : 'Render package ready for download.',
    });
  });

  app.get('/video-cv/render-job/:jobId', requireAuth, async (req, res) => {
    const uid = req.user.uid;
    const jobId = req.params.jobId;
    const doc = await db.collection('users').doc(uid).collection('videoCvJobs').doc(jobId).get();
    if (!doc.exists) return res.status(404).json({ error: 'Job not found.' });
    return res.json({ jobId: doc.id, ...doc.data() });
  });

  app.post('/video-cv/script', requireAuth, async (req, res) => {
    const schema = z.object({
      fullName: z.string().min(1).max(120),
      headline: z.string().min(1).max(180),
      summary: z.string().min(1).max(1200),
      skills: z.string().min(1).max(1200),
      experience: z.string().min(1).max(1200),
      education: z.string().min(1).max(1200),
    });
    const parsed = schema.safeParse(req.body || {});
    if (!parsed.success) return res.status(400).json({ error: 'Invalid payload.' });
    const script = coachService.buildVideoCvScript(parsed.data);
    return res.json({ script });
  });

  /** Upload avatar via API (base64) — reliable on mobile; avoids client signed-URL issues. */
  app.post('/storage/avatar', requireAuth, async (req, res) => {
    const schema = z.object({
      fileName: z.string().min(3).max(200).optional(),
      contentType: z.string().min(3).max(100),
      dataBase64: z.string().min(100).max(8_000_000),
    });
    const parsed = schema.safeParse(req.body || {});
    if (!parsed.success) return res.status(400).json({ error: 'Invalid avatar payload.' });

    try {
      const uid = req.user.uid;
      const safeName = (parsed.data.fileName || 'avatar.jpg').replace(/[^a-zA-Z0-9._-]/g, '_');
      const bucket = admin.storage().bucket();
      const objectPath = `avatars/${uid}/${Date.now()}-${safeName}`;
      const buffer = Buffer.from(parsed.data.dataBase64, 'base64');
      if (buffer.length > 8 * 1024 * 1024) {
        return res.status(400).json({ error: 'Image too large (max 8MB).' });
      }
      const file = bucket.file(objectPath);
      await file.save(buffer, {
        contentType: parsed.data.contentType,
        metadata: { cacheControl: 'public, max-age=86400' },
      });
      const publicUrl = `https://storage.googleapis.com/${bucket.name}/${objectPath}`;
      const token = crypto.randomUUID();
      await file.setMetadata({ metadata: { firebaseStorageDownloadTokens: token } });
      const downloadUrl = firebaseDownloadUrl(bucket.name, objectPath, token);
      await db.collection('users').doc(uid).set(
        {
          avatarImageUrl: downloadUrl,
          avatarImageObjectPath: objectPath,
          avatarUseTemplate: false,
          updatedAt: admin.firestore.FieldValue.serverTimestamp(),
        },
        { merge: true },
      );
      return res.json({ publicUrl, downloadUrl, objectPath });
    } catch (err) {
      // eslint-disable-next-line no-console
      console.error('Avatar upload failed:', err);
      return res.status(500).json({ error: `Avatar upload failed: ${err.message}` });
    }
  });

  /** Selfie/photo → cartoon or anime 2D portrait (Gemini). Used for coach UI + Video CV lip-sync. */
  app.post('/storage/avatar/vroid-from-photo', requireAuth, async (req, res) => {
    const schema = z.object({
      fileName: z.string().min(3).max(200).optional(),
      contentType: z.string().min(3).max(100),
      dataBase64: z.string().min(100).max(8_000_000),
      avatarStyle: z.string().min(1).max(80).optional(),
      style: z.enum(['cartoon', 'vroid', 'anime']).optional(),
    });
    const parsed = schema.safeParse(req.body || {});
    if (!parsed.success) return res.status(400).json({ error: 'Invalid photo payload.' });

    try {
      const uid = req.user.uid;
      const buffer = Buffer.from(parsed.data.dataBase64, 'base64');
      if (buffer.length > 8 * 1024 * 1024) {
        return res.status(400).json({ error: 'Image too large (max 8MB).' });
      }

      const avatarVroidService = require('./services/avatar_vroid.service');
      const profileSnap = await db.collection('users').doc(uid).get();
      const profile = profileSnap.data() || {};
      const avatarStyle =
        parsed.data.avatarStyle || profile.avatarStyle || 'Professional';

      const style = parsed.data.style || 'cartoon';
      const generated = await avatarVroidService.generateVroidStylePortrait({
        imageBuffer: buffer,
        mimeType: parsed.data.contentType,
        avatarStyle,
        style,
      });

      const bucket = admin.storage().bucket();
      const objectPath = `avatars/${uid}/${style}-${Date.now()}.png`;
      const file = bucket.file(objectPath);
      await file.save(generated.buffer, {
        contentType: generated.mimeType || 'image/png',
        metadata: { cacheControl: 'public, max-age=86400' },
      });
      const publicUrl = `https://storage.googleapis.com/${bucket.name}/${objectPath}`;
      const token = crypto.randomUUID();
      await file.setMetadata({ metadata: { firebaseStorageDownloadTokens: token } });
      const downloadUrl = firebaseDownloadUrl(bucket.name, objectPath, token);

      await db.collection('users').doc(uid).set(
        {
          avatarImageUrl: downloadUrl,
          avatarImageObjectPath: objectPath,
          avatarUseTemplate: false,
          avatarVroidStyle: true,
          updatedAt: admin.firestore.FieldValue.serverTimestamp(),
        },
        { merge: true },
      );

      return res.json({
        publicUrl,
        downloadUrl,
        objectPath,
        provider: generated.provider,
        model: generated.model,
      });
    } catch (err) {
      // eslint-disable-next-line no-console
      console.error('VRoid-style avatar failed:', err);
      const msg = String(err.message || err);
      if (msg.toLowerCase().includes('quota') || msg.includes('429')) {
        return res.status(429).json({
          error:
            'AI image quota exceeded. Try again later or upload a VRoid Studio PNG manually.',
        });
      }
      return res.status(500).json({ error: `VRoid-style avatar failed: ${msg}` });
    }
  });

  app.post('/storage/upload-url', requireAuth, async (req, res) => {
    const schema = z.object({
      fileName: z.string().min(3).max(200),
      contentType: z.string().min(3).max(100),
      folder: z.enum(['avatars', 'video-cv']).optional(),
    });
    const parsed = schema.safeParse(req.body || {});
    if (!parsed.success) return res.status(400).json({ error: 'Invalid payload.' });
    try {
      // Signed URL generation requires iam.serviceAccounts.signBlob on the build/runtime service account.
      // Use /storage/avatar (server-side upload) instead for mobile.
      return res.status(501).json({
        error:
          'Signed URL upload is disabled. Use POST /storage/avatar for avatar uploads.',
      });
    } catch (err) {
      // eslint-disable-next-line no-console
      console.error('Signed URL failed:', err);
      return res.status(500).json({ error: `Could not create upload URL: ${err.message}` });
    }
  });

  app.post('/payments/subscribe', requireAuth, async (req, res) => {
    const schema = z.object({
      userEmail: z.string().email().optional(),
      plan: z.string().min(3).max(64).optional(),
      planId: z.string().min(3).max(64).optional(),
    });
    const parsed = schema.safeParse(req.body || {});
    if (!parsed.success) return res.status(400).json({ error: 'Invalid payload.' });

    const planKey = (parsed.data.planId || parsed.data.plan || 'annual').toLowerCase();
    const plan = config.plans[planKey];
    if (!plan) return res.status(400).json({ error: 'Invalid subscription plan.' });

    if (config.paymentMode === 'mock') {
      const uid = req.user.uid;
      await db.collection('users').doc(uid).set(
        {
          isPremium: true,
          premiumPlan: plan.id,
          premiumActivatedAt: admin.firestore.FieldValue.serverTimestamp(),
        },
        { merge: true },
      );
      return res.json({ success: true, plan: plan.id, gateway: 'mock' });
    }

    const stripe = getStripe();
    if (!stripe) {
      return res.status(501).json({ error: 'Stripe not configured. Set STRIPE_SECRET_KEY.' });
    }
    const priceId =
      planKey === 'monthly'
        ? config.stripePriceMonthly
        : planKey === 'annual'
          ? config.stripePriceAnnual
          : config.stripePriceLifetime;
    if (planKey === 'lifetime') {
      if (!priceId) {
        return res.status(501).json({
          error: 'Lifetime Stripe price not configured. Set STRIPE_PRICE_LIFETIME or use mock payment mode.',
        });
      }
      const uid = req.user.uid;
      const session = await stripe.checkout.sessions.create({
        mode: 'payment',
        line_items: [{ price: priceId, quantity: 1 }],
        success_url: 'https://virtuomate.app/premium/success',
        cancel_url: 'https://virtuomate.app/premium/cancel',
        metadata: { firebaseUid: uid, planId: plan.id },
        customer_email: req.user.email || parsed.data.userEmail,
      });
      return res.json({ checkoutUrl: session.url, sessionId: session.id, gateway: 'stripe' });
    }
    if (!priceId) {
      return res.status(501).json({ error: 'Stripe price IDs not configured.' });
    }
    const uid = req.user.uid;
    const session = await stripe.checkout.sessions.create({
      mode: 'subscription',
      line_items: [{ price: priceId, quantity: 1 }],
      success_url: 'https://virtuomate.app/premium/success',
      cancel_url: 'https://virtuomate.app/premium/cancel',
      metadata: { firebaseUid: uid, planId: plan.id },
      customer_email: req.user.email || parsed.data.userEmail,
    });
    return res.json({ checkoutUrl: session.url, sessionId: session.id, gateway: 'stripe' });
  });

  app.post('/ai/coach', requireAuth, async (req, res) => {
    const schema = z.object({
      sessionType: z.string().min(2).max(64),
      userInput: z.string().min(1).max(4000),
      avatarStyle: z.string().min(2).max(64).optional(),
      voiceProfile: z.string().min(3).max(80).optional(),
      emotion: z.string().max(32).optional(),
      stepIndex: z.number().int().min(0).max(10).optional(),
    });
    const parsed = schema.safeParse(req.body || {});
    if (!parsed.success) return res.status(400).json({ error: 'Invalid payload.' });

    const result = await coachService.generateCoachFeedback(parsed.data);
    return res.json({
      feedback: result.feedback,
      emotion: result.emotion,
      confidenceScore: result.confidence,
      provider: result.provider,
      assessment: result.assessment || null,
      coachHint:
        result.coachHint ||
        (result.provider !== 'gemini' && config.geminiApiKey
          ? 'Live Gemini unavailable (quota or key). Add AI Studio credits or OPENAI_API_KEY on Cloud Functions.'
          : undefined),
    });
  });

  app.post('/ai/analyze-text', requireAuth, async (req, res) => {
    const schema = z.object({
      text: z.string().min(1).max(8000),
      sessionType: z.string().min(2).max(64).optional(),
      context: z.string().max(2000).optional(),
    });
    const parsed = schema.safeParse(req.body || {});
    if (!parsed.success) return res.status(400).json({ error: 'Invalid payload.' });
    const assessment = await coachService.analyzeText(parsed.data);
    const uid = req.user.uid;
    await db.collection('users').doc(uid).collection('assessments').add({
      ...assessment,
      sessionType: parsed.data.sessionType || 'Conversation',
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
    });
    return res.json(assessment);
  });

  app.post('/ai/analyze-speech', requireAuth, async (req, res) => {
    const schema = z.object({
      transcript: z.string().min(1).max(8000),
      sessionType: z.string().min(2).max(64).optional(),
      durationSec: z.number().min(0).max(3600).optional(),
      speakingPaceWpm: z.number().optional(),
    });
    const parsed = schema.safeParse(req.body || {});
    if (!parsed.success) return res.status(400).json({ error: 'Invalid payload. Send transcript from client STT.' });
    const assessment = await coachService.analyzeText({
      text: parsed.data.transcript,
      sessionType: parsed.data.sessionType,
    });
    if (parsed.data.durationSec) {
      const words = parsed.data.transcript.trim().split(/\s+/).length;
      assessment.speaking_pace_wpm =
        parsed.data.speakingPaceWpm ??
        Math.round(words / (parsed.data.durationSec / 60));
    }
    const uid = req.user.uid;
    await db.collection('users').doc(uid).collection('assessments').add({
      ...assessment,
      inputMode: 'speech',
      sessionType: parsed.data.sessionType || 'Conversation',
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
    });
    return res.json(assessment);
  });

  app.get('/admin/users', requireAuth, requireAdmin, async (_req, res) => {
    const snap = await db.collection('users').orderBy('updatedAt', 'desc').limit(100).get();
    const users = snap.docs.map((d) => ({
      uid: d.id,
      email: d.data().email || '',
      displayName: d.data().displayName || '',
      isPremium: Boolean(d.data().isPremium),
      videoCvCount: Number(d.data().videoCvCount || 0),
      missionProgress: Number(d.data().missionProgress || 0),
    }));
    return res.json({ users });
  });

  app.get('/admin/analytics', requireAuth, requireAdmin, async (_req, res) => {
    const usersSnap = await db.collection('users').get();
    let totalSessions = 0;
    let premiumUsers = 0;
    for (const userDoc of usersSnap.docs) {
      if (userDoc.data().isPremium) premiumUsers += 1;
      const sessionsSnap = await db
        .collection('users')
        .doc(userDoc.id)
        .collection('sessions')
        .count()
        .get();
      totalSessions += sessionsSnap.data().count;
    }
    return res.json({
      totalUsers: usersSnap.size,
      premiumUsers,
      totalSessions,
    });
  });

  app.post('/user/export', requireAuth, async (req, res) => {
    const uid = req.user.uid;
    const userDoc = await db.collection('users').doc(uid).get();
    const sessionsSnap = await db
      .collection('users')
      .doc(uid)
      .collection('sessions')
      .orderBy('createdAt', 'desc')
      .get();
    return res.json({
      profile: userDoc.exists ? userDoc.data() : {},
      sessions: sessionsSnap.docs.map((d) => ({ id: d.id, ...d.data() })),
      exportedAt: new Date().toISOString(),
    });
  });

  app.delete('/user', requireAuth, async (req, res) => {
    const uid = req.user.uid;
    const sessionsSnap = await db.collection('users').doc(uid).collection('sessions').get();
    const batch = db.batch();
    sessionsSnap.docs.forEach((d) => batch.delete(d.ref));
    batch.delete(db.collection('users').doc(uid));
    await batch.commit();
    try {
      await admin.auth().deleteUser(uid);
    } catch {
      // User may already be deleted from client auth flow.
    }
    return res.json({ deleted: true });
  });

  app.use((_req, res) => {
    res.status(404).json({ error: 'Endpoint not found.' });
  });

  return app;
}

module.exports = { createApp };
