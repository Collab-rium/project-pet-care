const express = require('express');
const router = express.Router();
const { v4: uuidv4 } = require('uuid');

// In-memory stores (MVP)
const remindersById = new Map();
const remindersByUserId = new Map(); // userId -> Set of reminderIds
const remindersByPetId = new Map(); // petId -> Set of reminderIds

const VALID_REMINDER_TYPES = ['feeding', 'medication', 'grooming', 'exercise', 'vet_appointment', 'other'];
const VALID_REPEAT_TYPES = ['none', 'daily', 'weekly', 'monthly'];
const MAX_MESSAGE_LEN = 500;
const MAX_TYPE_LEN = 50;

function sendError(res, status, code, message, details) {
  const payload = { error: code, message };
  if (details) payload.details = details;
  return res.status(status).json(payload);
}

function validateReminderType(type) {
  if (!type || !String(type).trim()) return 'missing_type';
  const normalized = String(type).toLowerCase();
  if (!VALID_REMINDER_TYPES.includes(normalized)) {
    return 'invalid_type';
  }
  return null;
}

function validateMessage(message) {
  if (!message || !String(message).trim()) return 'missing_message';
  if (String(message).length > MAX_MESSAGE_LEN) return 'message_too_long';
  return null;
}

function validateScheduledTime(scheduledTime) {
  if (!scheduledTime) return 'missing_scheduled_time';
  const time = new Date(scheduledTime);
  if (isNaN(time.getTime())) return 'invalid_scheduled_time';
  return null;
}

function validateRepeat(repeat) {
  if (!repeat) return 'missing_repeat';
  const normalized = String(repeat).toLowerCase();
  if (!VALID_REPEAT_TYPES.includes(normalized)) return 'invalid_repeat';
  return null;
}

// GET /reminders - List reminders (optionally filtered by petId)
router.get('/', (req, res) => {
  if (!req.user || !req.user.id) {
    return sendError(res, 401, 'missing_user', 'User not authenticated');
  }

  const petId = req.query.petId ? String(req.query.petId).trim() : null;
  const userReminderIds = remindersByUserId.get(req.user.id) || new Set();
  
  let reminders = Array.from(userReminderIds)
    .map(reminderId => remindersById.get(reminderId))
    .filter(r => r);
  
  // Filter by petId if provided
  if (petId) {
    reminders = reminders.filter(r => r.petId === petId);
  }

  return res.json({ data: reminders });
});

// POST /reminders - Create reminder
router.post('/', (req, res) => {
  if (!req.user || !req.user.id) {
    return sendError(res, 401, 'missing_user', 'User not authenticated');
  }

  const { petId, type, message, scheduledTime, repeat } = req.body || {};

  // Validate required fields
  if (!petId) {
    return sendError(res, 400, 'missing_pet_id', 'petId is required');
  }

  const typeErr = validateReminderType(type);
  if (typeErr) {
    return sendError(res, 400, typeErr, `type is required and must be one of: ${VALID_REMINDER_TYPES.join(', ')}`);
  }

  const messageErr = validateMessage(message);
  if (messageErr) {
    return sendError(res, 400, messageErr, 'message is required and must be 1-500 characters');
  }

  const timeErr = validateScheduledTime(scheduledTime);
  if (timeErr) {
    return sendError(res, 400, timeErr, 'scheduledTime must be a valid ISO 8601 date');
  }

  const repeatErr = validateRepeat(repeat);
  if (repeatErr) {
    return sendError(res, 400, repeatErr, `repeat is required and must be one of: ${VALID_REPEAT_TYPES.join(', ')}`);
  }

  // Verify pet exists and belongs to user
  let petExists = false;
  if (typeof global._petsStore !== 'undefined' && global._petsStore) {
    const pet = global._petsStore.petsById.get(petId);
    if (pet && pet.ownerId === req.user.id) {
      petExists = true;
    }
  }
  
  if (!petExists) {
    return sendError(res, 404, 'pet_not_found', 'Pet not found or you do not own this pet');
  }

  const id = uuidv4();
  const now = new Date().toISOString();
  const reminder = {
    id,
    petId,
    userId: req.user.id,
    type: String(type).toLowerCase(),
    message: String(message).trim(),
    scheduledTime: String(scheduledTime),
    repeat: String(repeat).toLowerCase(),
    status: 'pending',
    sent: false,  // Track if notification was sent
    sentAt: null,
    createdAt: now,
    updatedAt: now,
  };

  remindersById.set(id, reminder);
  
  if (!remindersByUserId.has(req.user.id)) {
    remindersByUserId.set(req.user.id, new Set());
  }
  remindersByUserId.get(req.user.id).add(id);

  if (!remindersByPetId.has(petId)) {
    remindersByPetId.set(petId, new Set());
  }
  remindersByPetId.get(petId).add(id);

  return res.status(201).json({ data: reminder });
});

// GET /reminders/:id - Get single reminder
router.get('/:id', (req, res) => {
  if (!req.user || !req.user.id) {
    return sendError(res, 401, 'missing_user', 'User not authenticated');
  }

  const reminder = remindersById.get(req.params.id);
  if (!reminder) {
    return sendError(res, 404, 'reminder_not_found', 'Reminder not found');
  }

  if (reminder.userId !== req.user.id) {
    return sendError(res, 403, 'forbidden', 'You do not own this reminder');
  }

  return res.json({ data: reminder });
});

// PUT /reminders/:id - Update reminder
router.put('/:id', (req, res) => {
  if (!req.user || !req.user.id) {
    return sendError(res, 401, 'missing_user', 'User not authenticated');
  }

  const reminder = remindersById.get(req.params.id);
  if (!reminder) {
    return sendError(res, 404, 'reminder_not_found', 'Reminder not found');
  }

  if (reminder.userId !== req.user.id) {
    return sendError(res, 403, 'forbidden', 'You do not own this reminder');
  }

  const { type, message, scheduledTime, repeat, status } = req.body || {};

  // Validate optional updates
  if (type !== undefined && type !== null) {
    const typeErr = validateReminderType(type);
    if (typeErr) {
      return sendError(res, 400, typeErr, `type must be one of: ${VALID_REMINDER_TYPES.join(', ')}`);
    }
    reminder.type = String(type).toLowerCase();
  }

  if (message !== undefined && message !== null) {
    const messageErr = validateMessage(message);
    if (messageErr) {
      return sendError(res, 400, messageErr, 'message must be 1-500 characters');
    }
    reminder.message = String(message).trim();
  }

  if (scheduledTime !== undefined && scheduledTime !== null) {
    const timeErr = validateScheduledTime(scheduledTime);
    if (timeErr) {
      return sendError(res, 400, timeErr, 'scheduledTime must be a valid ISO 8601 date');
    }
    reminder.scheduledTime = String(scheduledTime);
  }

  if (repeat !== undefined && repeat !== null) {
    const repeatErr = validateRepeat(repeat);
    if (repeatErr) {
      return sendError(res, 400, repeatErr, `repeat must be one of: ${VALID_REPEAT_TYPES.join(', ')}`);
    }
    reminder.repeat = String(repeat).toLowerCase();
  }

  if (status !== undefined && status !== null) {
    const validStatuses = ['pending', 'completed', 'skipped'];
    if (!validStatuses.includes(String(status).toLowerCase())) {
      return sendError(res, 400, 'invalid_status', `status must be one of: ${validStatuses.join(', ')}`);
    }
    reminder.status = String(status).toLowerCase();
  }

  reminder.updatedAt = new Date().toISOString();
  return res.json({ data: reminder });
});

// DELETE /reminders/:id - Delete reminder
router.delete('/:id', (req, res) => {
  if (!req.user || !req.user.id) {
    return sendError(res, 401, 'missing_user', 'User not authenticated');
  }

  const reminder = remindersById.get(req.params.id);
  if (!reminder) {
    return sendError(res, 404, 'reminder_not_found', 'Reminder not found');
  }

  if (reminder.userId !== req.user.id) {
    return sendError(res, 403, 'forbidden', 'You do not own this reminder');
  }

  remindersById.delete(req.params.id);
  
  const userReminders = remindersByUserId.get(req.user.id);
  if (userReminders) {
    userReminders.delete(req.params.id);
  }

  const petReminders = remindersByPetId.get(reminder.petId);
  if (petReminders) {
    petReminders.delete(req.params.id);
  }

  return res.json({ message: 'Reminder deleted successfully' });
});

module.exports = { router, _stores: { remindersById, remindersByUserId, remindersByPetId } };
