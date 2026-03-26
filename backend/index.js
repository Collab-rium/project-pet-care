require('dotenv').config();
const express = require('express');
const app = express();

app.use(express.json());
// Serve uploaded files
app.use('/uploads', express.static('uploads'));

const { router: authRouter, authMiddleware } = require('./auth');
const { router: petsRouter, _stores: petsStores } = require('./pets');
const { router: remindersRouter, _stores: remindersStores } = require('./reminders');
const { router: dashboardRouter } = require('./dashboard');

// Make stores globally available
global._petsStore = petsStores;
global._remindersStore = remindersStores;

app.use('/auth', authRouter);
app.use('/pets', authMiddleware, petsRouter);
app.use('/reminders', authMiddleware, remindersRouter);
app.use('/dashboard', authMiddleware, dashboardRouter);

const port = process.env.PORT || 3000;

app.get('/health', (req, res) => {
  const uptime = Math.floor(process.uptime());
  const timestamp = new Date().toISOString();
  res.json({ ok: true, uptime, timestamp });
});

app.get('/', (req, res) => res.send('pet-care-backend'));

const server = app.listen(port, () => {
  console.log(`Server listening on ${port}`);
});

app.post('/shutdown', (req, res) => {
  res.json({ shutting: 'ok' });
  server.close(() => process.exit(0));
});

process.on('SIGINT', () => {
  server.close(() => process.exit(0));
});
