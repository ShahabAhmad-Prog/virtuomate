'use strict';

const admin = require('firebase-admin');
const config = require('../config');

async function requireAuth(req, res, next) {
  try {
    const authHeader = req.headers.authorization || '';
    const token = authHeader.startsWith('Bearer ') ? authHeader.slice(7) : null;
    if (!token) return res.status(401).json({ error: 'Missing auth token.' });
    const decoded = await admin.auth().verifyIdToken(token);
    req.user = decoded;
    return next();
  } catch {
    return res.status(401).json({ error: 'Invalid auth token.' });
  }
}

function requireAdmin(req, res, next) {
  const email = String(req.user?.email || '').toLowerCase();
  const isAdminClaim = Boolean(req.user?.admin);
  const isAdminEmail = config.adminEmails.some((a) => email === a);
  if (!isAdminClaim && !isAdminEmail) {
    return res.status(403).json({ error: 'Admin access required.' });
  }
  return next();
}

module.exports = { requireAuth, requireAdmin };
