const express = require('express');
const router = express.Router();
const { v4: uuidv4 } = require('uuid');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');

// In-memory stores (MVP)
const usersById = new Map();
const usersByEmail = new Map();

const JWT_SECRET = process.env.JWT_SECRET || 'dev_jwt_secret_change_me';
const JWT_EXPIRY = '7d';
const EMAIL_REGEX = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
const MAX_EMAIL_LEN = 254;
const MAX_NAME_LEN = 80;
const MAX_PASSWORD_LEN = 128;

function sanitizeEmail(e){ return String(e||'').trim().toLowerCase(); }
function sanitizeName(n){ return String(n || '').trim(); }

function sendError(res, status, code, message, details){
  const payload = { error: code, message };
  if (details) payload.details = details;
  return res.status(status).json(payload);
}

function validateEmail(email){
  if (!email) return 'missing_email';
  if (email.length > MAX_EMAIL_LEN) return 'email_too_long';
  if (!EMAIL_REGEX.test(email)) return 'invalid_email_format';
  return null;
}

function validatePassword(password){
  if (!password) return 'missing_password';
  if (password.length < 6) return 'password_too_short';
  if (password.length > MAX_PASSWORD_LEN) return 'password_too_long';
  if (!/[A-Za-z]/.test(password) || !/[0-9]/.test(password)) return 'password_weak';
  return null;
}

function validateName(name){
  if (!name || !name.trim()) return 'invalid_name';
  if (name.length > MAX_NAME_LEN) return 'name_too_long';
  return null;
}

router.post('/register', (req, res) => {
  const { email, password, name } = req.body || {};
  if (!email || !password || !name) {
    return sendError(res, 400, 'missing_fields', 'Required fields: email, password, name');
  }

  const norm = sanitizeEmail(email);
  const cleanName = sanitizeName(name);
  const pass = String(password);

  const emailErr = validateEmail(norm);
  if (emailErr === 'invalid_email_format') {
    return sendError(res, 400, emailErr, 'Please provide a valid email address');
  }
  if (emailErr === 'email_too_long') {
    return sendError(res, 400, emailErr, 'Email is too long');
  }
  if (usersByEmail.has(norm)) return sendError(res, 400, 'email_exists', 'Email already registered');

  const nameErr = validateName(cleanName);
  if (nameErr === 'invalid_name') {
    return sendError(res, 400, nameErr, 'Name cannot be empty or whitespace');
  }
  if (nameErr === 'name_too_long') {
    return sendError(res, 400, nameErr, 'Name is too long');
  }

  const passwordErr = validatePassword(pass);
  if (passwordErr === 'password_too_short') {
    return sendError(res, 400, passwordErr, 'Password must be at least 6 characters');
  }
  if (passwordErr === 'password_too_long') {
    return sendError(res, 400, passwordErr, 'Password is too long');
  }
  if (passwordErr === 'password_weak') {
    return sendError(res, 400, passwordErr, 'Password must include at least one letter and one number');
  }

  const id = uuidv4();
  const hashed = bcrypt.hashSync(pass, 8);
  const createdAt = new Date().toISOString();
  const user = { id, email: norm, name: cleanName, createdAt };
  usersById.set(id, { ...user, password: hashed });
  usersByEmail.set(norm, id);

  const token = jwt.sign({ sub: id, email: norm }, JWT_SECRET, { expiresIn: JWT_EXPIRY });
  return res.status(201).json({ user, token });
});

router.post('/login', (req, res) => {
  const { email, password } = req.body || {};
  if (!email || !password) {
    return sendError(res, 400, 'missing_fields', 'Required fields: email, password');
  }

  const norm = sanitizeEmail(email);
  const emailErr = validateEmail(norm);
  if (emailErr === 'invalid_email_format') {
    return sendError(res, 400, emailErr, 'Please provide a valid email address');
  }

  if (String(password).length > MAX_PASSWORD_LEN) {
    return sendError(res, 400, 'password_too_long', 'Password is too long');
  }

  const id = usersByEmail.get(norm);
  if (!id) return sendError(res, 401, 'invalid_credentials', 'Email or password is incorrect');
  const stored = usersById.get(id);
  if (!stored) return sendError(res, 401, 'invalid_credentials', 'Email or password is incorrect');
  const ok = bcrypt.compareSync(String(password), stored.password);
  if (!ok) return sendError(res, 401, 'invalid_credentials', 'Email or password is incorrect');

  const token = jwt.sign({ sub: id, email: norm }, JWT_SECRET, { expiresIn: JWT_EXPIRY });
  const { password: _p, ...user } = stored;
  return res.json({ user, token });
});

// Middleware to protect routes
function authMiddleware(req, res, next){
  const h = req.get('authorization') || '';
  const m = h.match(/^Bearer\s+(.+)$/i);
  if (!m) return sendError(res, 401, 'missing_token', 'Authorization Bearer token is required');
  const token = m[1];
  try {
    const decoded = jwt.verify(token, JWT_SECRET);
    const userId = decoded && decoded.sub;
    if (!userId) return sendError(res, 401, 'invalid_token', 'Token is invalid or expired');
    const stored = usersById.get(userId);
    if (!stored) return sendError(res, 401, 'invalid_token', 'Token is invalid or expired');
    req.user = { id: stored.id, email: stored.email, name: stored.name };
    next();
  } catch (err) {
    return sendError(res, 401, 'invalid_token', 'Token is invalid or expired');
  }
}

module.exports = { router, authMiddleware, _stores: { usersById, usersByEmail } };
