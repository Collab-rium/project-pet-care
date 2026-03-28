require('dotenv').config();
const express = require('express');
const app = express();

// Firebase Admin (optional, only if credentials available)
let admin;
let db;
const USE_FIRESTORE = process.env.USE_FIRESTORE === 'true';

if (USE_FIRESTORE) {
  try {
    admin = require('firebase-admin');
    const serviceAccount = require('./service-account-key.json');
    
    admin.initializeApp({
      credential: admin.credential.cert(serviceAccount)
    });
    
    db = admin.firestore();
    console.log('✅ Firebase initialized');
  } catch (error) {
    console.warn('⚠️ Firebase not configured, using in-memory storage');
    USE_FIRESTORE = false;
  }
}

app.use(express.json());
// Serve uploaded files
app.use('/uploads', express.static('uploads'));

const { router: authRouter, authMiddleware, _stores: authStores } = require('./auth');
const { router: petsRouter, _stores: petsStores } = require('./pets');
const { router: remindersRouter, _stores: remindersStores } = require('./reminders');
const { router: dashboardRouter } = require('./dashboard');
const { loadSeedData } = require('./services/load-seed');

// Make stores globally available
global._petsStore = petsStores;
global._remindersStore = remindersStores;
global._db = db;
global._USE_FIRESTORE = USE_FIRESTORE;

// Load seed data on startup (in-memory mode only)
if (!USE_FIRESTORE) {
  loadSeedData(authStores, petsStores, remindersStores);
}

// Start notification scheduler if using Firestore
if (USE_FIRESTORE) {
  const { startScheduler } = require('./scheduler');
  startScheduler();
}

app.use('/auth', authRouter);
app.use('/pets', authMiddleware, petsRouter);
app.use('/reminders', authMiddleware, remindersRouter);
app.use('/dashboard', authMiddleware, dashboardRouter);

// Device token endpoint (for notifications)
if (USE_FIRESTORE && db) {
  app.post('/device-token', authMiddleware, async (req, res) => {
    try {
      const { token } = req.body;
      const userId = req.user.id;

      if (!token) {
        return res.status(400).json({ error: 'Device token required' });
      }

      await db.collection('users').doc(userId).update({
        deviceToken: token,
        updatedAt: new Date()
      });

      res.json({ success: true, message: 'Device token saved' });
    } catch (error) {
      res.status(500).json({ error: error.message });
    }
  });
}

const port = process.env.PORT || 4000;

app.get('/health', (req, res) => {
  const uptime = Math.floor(process.uptime());
  const timestamp = new Date().toISOString();
  const storage = USE_FIRESTORE ? 'Firestore' : 'In-Memory';
  res.json({ ok: true, uptime, timestamp, storage });
});

app.get('/', (req, res) => res.send('pet-care-backend'));

const server = app.listen(port, () => {
  const mode = USE_FIRESTORE ? '☁️ Firestore' : '💾 In-Memory';
  console.log(`Server listening on port ${port} (${mode})`);
});

app.post('/shutdown', (req, res) => {
  res.json({ shutting: 'ok' });
  server.close(() => process.exit(0));
});

process.on('SIGINT', () => {
  server.close(() => process.exit(0));
});
