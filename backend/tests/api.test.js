const request = require('supertest');
const express = require('express');
require('dotenv').config();

// Create a test app (similar to index.js)
function createTestApp() {
  const app = express();
  app.use(express.json());
  app.use('/uploads', express.static('uploads'));

  const { router: authRouter, authMiddleware, _stores: authStores } = require('../auth');
  const { router: petsRouter, _stores: petsStores } = require('../pets');
  const { router: remindersRouter, _stores: remindersStores } = require('../reminders');
  const { router: dashboardRouter } = require('../dashboard');

  // Make stores globally available
  global._petsStore = petsStores;
  global._remindersStore = remindersStores;

  app.use('/auth', authRouter);
  app.use('/pets', authMiddleware, petsRouter);
  app.use('/reminders', authMiddleware, remindersRouter);
  app.use('/dashboard', authMiddleware, dashboardRouter);

  return app;
}

describe('Pet Care Backend API', () => {
  let app;
  let token;
  let userId;
  let petId;
  let reminderId;

  beforeAll(() => {
    app = createTestApp();
  });

  // Auth Tests
  describe('Authentication', () => {
    it('should register a new user', async () => {
      const res = await request(app)
        .post('/auth/register')
        .send({
          email: 'test@example.com',
          password: 'test1234',
          name: 'Test User',
        });

      expect(res.status).toBe(201);
      expect(res.body.user).toHaveProperty('id');
      expect(res.body.user).toHaveProperty('email', 'test@example.com');
      expect(res.body).toHaveProperty('token');
      
      token = res.body.token;
      userId = res.body.user.id;
    });

    it('should reject duplicate email', async () => {
      const res = await request(app)
        .post('/auth/register')
        .send({
          email: 'test@example.com',
          password: 'test1234',
          name: 'Another User',
        });

      expect(res.status).toBe(400);
      expect(res.body.error).toBe('email_exists');
    });

    it('should reject weak password', async () => {
      const res = await request(app)
        .post('/auth/register')
        .send({
          email: 'weak@example.com',
          password: 'test',
          name: 'Test User',
        });

      expect(res.status).toBe(400);
      expect(res.body.error).toMatch(/password/);
    });

    it('should login successfully', async () => {
      const res = await request(app)
        .post('/auth/login')
        .send({
          email: 'test@example.com',
          password: 'test1234',
        });

      expect(res.status).toBe(200);
      expect(res.body).toHaveProperty('token');
      expect(res.body.user.email).toBe('test@example.com');
    });

    it('should reject invalid credentials', async () => {
      const res = await request(app)
        .post('/auth/login')
        .send({
          email: 'test@example.com',
          password: 'wrongpassword',
        });

      expect(res.status).toBe(401);
      expect(res.body.error).toBe('invalid_credentials');
    });
  });

  // Pet Tests
  describe('Pets', () => {
    it('should list pets (empty initially)', async () => {
      const res = await request(app)
        .get('/pets')
        .set('Authorization', `Bearer ${token}`);

      expect(res.status).toBe(200);
      expect(res.body.data).toEqual([]);
    });

    it('should create a pet', async () => {
      const res = await request(app)
        .post('/pets')
        .set('Authorization', `Bearer ${token}`)
        .send({
          name: 'Buddy',
          type: 'dog',
          age: 3,
          breed: 'Golden Retriever',
        });

      expect(res.status).toBe(201);
      expect(res.body.data).toHaveProperty('id');
      expect(res.body.data.name).toBe('Buddy');
      expect(res.body.data.type).toBe('dog');
      expect(res.body.data.age).toBe(3);

      petId = res.body.data.id;
    });

    it('should list pets (with data)', async () => {
      const res = await request(app)
        .get('/pets')
        .set('Authorization', `Bearer ${token}`);

      expect(res.status).toBe(200);
      expect(res.body.data.length).toBe(1);
      expect(res.body.data[0].name).toBe('Buddy');
    });

    it('should get a single pet', async () => {
      const res = await request(app)
        .get(`/pets/${petId}`)
        .set('Authorization', `Bearer ${token}`);

      expect(res.status).toBe(200);
      expect(res.body.data.id).toBe(petId);
      expect(res.body.data.name).toBe('Buddy');
    });

    it('should update a pet', async () => {
      const res = await request(app)
        .put(`/pets/${petId}`)
        .set('Authorization', `Bearer ${token}`)
        .send({
          age: 4,
          breed: 'Golden Retriever Mix',
        });

      expect(res.status).toBe(200);
      expect(res.body.data.age).toBe(4);
      expect(res.body.data.breed).toBe('Golden Retriever Mix');
    });

    it('should delete a pet', async () => {
      const res = await request(app)
        .delete(`/pets/${petId}`)
        .set('Authorization', `Bearer ${token}`);

      expect(res.status).toBe(200);
      expect(res.body).toHaveProperty('message', 'Pet deleted successfully');
    });

    it('should return 404 for deleted pet', async () => {
      const res = await request(app)
        .get(`/pets/${petId}`)
        .set('Authorization', `Bearer ${token}`);

      expect(res.status).toBe(404);
      expect(res.body.error).toBe('pet_not_found');
    });

    it('should reject missing required fields', async () => {
      const res = await request(app)
        .post('/pets')
        .set('Authorization', `Bearer ${token}`)
        .send({
          name: 'Buddy',
          // missing type
        });

      expect(res.status).toBe(400);
    });
  });

  // Reminder Tests
  describe('Reminders', () => {
    let reminderId2;

    beforeAll(async () => {
      // Create a pet for reminders
      const petRes = await request(app)
        .post('/pets')
        .set('Authorization', `Bearer ${token}`)
        .send({
          name: 'ReminderPet',
          type: 'dog',
        });
      petId = petRes.body.data.id;
    });

    it('should list reminders (empty initially)', async () => {
      const res = await request(app)
        .get('/reminders')
        .set('Authorization', `Bearer ${token}`);

      expect(res.status).toBe(200);
      expect(res.body.data).toEqual([]);
    });

    it('should create a reminder', async () => {
      const res = await request(app)
        .post('/reminders')
        .set('Authorization', `Bearer ${token}`)
        .send({
          petId,
          type: 'feeding',
          message: 'Feed the pet',
          scheduledTime: '2026-03-26T08:00:00Z',
          repeat: 'daily',
        });

      expect(res.status).toBe(201);
      expect(res.body.data).toHaveProperty('id');
      expect(res.body.data.message).toBe('Feed the pet');
      expect(res.body.data.status).toBe('pending');

      reminderId = res.body.data.id;
    });

    it('should list reminders (with data)', async () => {
      const res = await request(app)
        .get('/reminders')
        .set('Authorization', `Bearer ${token}`);

      expect(res.status).toBe(200);
      expect(res.body.data.length).toBe(1);
    });

    it('should filter reminders by petId', async () => {
      const res = await request(app)
        .get(`/reminders?petId=${petId}`)
        .set('Authorization', `Bearer ${token}`);

      expect(res.status).toBe(200);
      expect(res.body.data.length).toBe(1);
      expect(res.body.data[0].petId).toBe(petId);
    });

    it('should get a single reminder', async () => {
      const res = await request(app)
        .get(`/reminders/${reminderId}`)
        .set('Authorization', `Bearer ${token}`);

      expect(res.status).toBe(200);
      expect(res.body.data.id).toBe(reminderId);
    });

    it('should update a reminder', async () => {
      const res = await request(app)
        .put(`/reminders/${reminderId}`)
        .set('Authorization', `Bearer ${token}`)
        .send({
          status: 'completed',
        });

      expect(res.status).toBe(200);
      expect(res.body.data.status).toBe('completed');
    });

    it('should delete a reminder', async () => {
      const res = await request(app)
        .delete(`/reminders/${reminderId}`)
        .set('Authorization', `Bearer ${token}`);

      expect(res.status).toBe(200);
      expect(res.body).toHaveProperty('message', 'Reminder deleted successfully');
    });

    it('should return 404 for deleted reminder', async () => {
      const res = await request(app)
        .get(`/reminders/${reminderId}`)
        .set('Authorization', `Bearer ${token}`);

      expect(res.status).toBe(404);
      expect(res.body.error).toBe('reminder_not_found');
    });
  });

  // Dashboard Tests
  describe('Dashboard', () => {
    beforeAll(async () => {
      // Create a pet
      const petRes = await request(app)
        .post('/pets')
        .set('Authorization', `Bearer ${token}`)
        .send({
          name: 'DashboardPet',
          type: 'cat',
        });
      petId = petRes.body.data.id;

      // Create reminders for today and overdue
      const today = new Date().toISOString().split('T')[0];
      const yesterday = new Date(Date.now() - 86400000).toISOString();

      // Today pending
      await request(app)
        .post('/reminders')
        .set('Authorization', `Bearer ${token}`)
        .send({
          petId,
          type: 'feeding',
          message: 'Feed today',
          scheduledTime: `${today}T08:00:00Z`,
          repeat: 'daily',
        });

      // Overdue
      await request(app)
        .post('/reminders')
        .set('Authorization', `Bearer ${token}`)
        .send({
          petId,
          type: 'grooming',
          message: 'Groom (overdue)',
          scheduledTime: yesterday,
          repeat: 'none',
        });
    });

    it('should get dashboard today', async () => {
      const res = await request(app)
        .get('/dashboard/today')
        .set('Authorization', `Bearer ${token}`);

      expect(res.status).toBe(200);
      expect(res.body.data).toHaveProperty('date');
      expect(res.body.data).toHaveProperty('tasks');
      expect(res.body.data).toHaveProperty('summary');
    });

    it('should include overdue tasks', async () => {
      const res = await request(app)
        .get('/dashboard/today')
        .set('Authorization', `Bearer ${token}`);

      const overdueTasks = res.body.data.tasks.filter(t => t.isOverdue);
      expect(overdueTasks.length).toBeGreaterThan(0);
    });

    it('should calculate summary correctly', async () => {
      const res = await request(app)
        .get('/dashboard/today')
        .set('Authorization', `Bearer ${token}`);

      const { summary } = res.body.data;
      expect(summary.total).toBeGreaterThan(0);
      expect(summary.pending + summary.completed).toBe(summary.total);
    });
  });

  // Authorization Tests
  describe('Authorization', () => {
    it('should reject requests without token', async () => {
      const res = await request(app).get('/pets');

      expect(res.status).toBe(401);
      expect(res.body.error).toBe('missing_token');
    });

    it('should reject invalid token', async () => {
      const res = await request(app)
        .get('/pets')
        .set('Authorization', 'Bearer invalid.token.here');

      expect(res.status).toBe(401);
      expect(res.body.error).toBe('invalid_token');
    });

    it('should allow access with valid token', async () => {
      const res = await request(app)
        .get('/pets')
        .set('Authorization', `Bearer ${token}`);

      expect(res.status).toBe(200);
    });
  });
});
