require('dotenv').config();
const express = require('express');
const app = express();

app.use(express.json());
const { router: authRouter, authMiddleware } = require('./auth');
app.use('/auth', authRouter);

// Minimal protected example (will be expanded in checklist)
app.get('/pets', authMiddleware, (req, res) => {
  return res.json({ data: [] });
});

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
