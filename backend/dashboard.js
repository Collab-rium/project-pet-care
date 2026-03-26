const express = require('express');
const router = express.Router();

function sendError(res, status, code, message, details) {
  const payload = { error: code, message };
  if (details) payload.details = details;
  return res.status(status).json(payload);
}

// GET /dashboard/today - Get today's tasks with aggregation
router.get('/today', (req, res) => {
  if (!req.user || !req.user.id) {
    return sendError(res, 401, 'missing_user', 'User not authenticated');
  }

  if (!global._remindersStore) {
    return res.json({
      data: {
        date: new Date().toISOString().split('T')[0],
        tasks: [],
        summary: { total: 0, completed: 0, pending: 0, overdue: 0 },
      },
    });
  }

  const now = new Date();
  const todayStart = new Date(now.getFullYear(), now.getMonth(), now.getDate());
  const todayEnd = new Date(todayStart.getTime() + 24 * 60 * 60 * 1000);

  // Get all reminders for this user
  const reminderIds = global._remindersStore.remindersByUserId.get(req.user.id) || new Set();
  const reminders = Array.from(reminderIds)
    .map(id => global._remindersStore.remindersById.get(id))
    .filter(r => r);

  // Filter reminders for today (based on scheduledTime)
  const tasks = reminders
    .map(reminder => {
      const scheduledTime = new Date(reminder.scheduledTime);
      const isOverdue = scheduledTime < now;
      
      return {
        id: reminder.id,
        petId: reminder.petId,
        message: reminder.message,
        scheduledTime: reminder.scheduledTime,
        status: reminder.status,
        isOverdue,
        type: reminder.type,
        repeat: reminder.repeat,
      };
    })
    .filter(task => {
      const scheduledTime = new Date(task.scheduledTime);
      // Include tasks from today and overdue tasks
      return scheduledTime >= todayStart && scheduledTime < todayEnd || task.isOverdue;
    })
    .sort((a, b) => new Date(a.scheduledTime) - new Date(b.scheduledTime));

  // Calculate summary
  const summary = {
    total: tasks.length,
    completed: tasks.filter(t => t.status === 'completed').length,
    pending: tasks.filter(t => t.status === 'pending').length,
    overdue: tasks.filter(t => t.isOverdue && t.status !== 'completed').length,
  };

  return res.json({
    data: {
      date: now.toISOString().split('T')[0],
      tasks,
      summary,
    },
  });
});

module.exports = { router };
