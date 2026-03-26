const express = require('express');
const router = express.Router();
const { v4: uuidv4 } = require('uuid');
const multer = require('multer');
const path = require('path');
const fs = require('fs');

// Configure multer for file uploads
const uploadsDir = path.join(__dirname, 'uploads');
const storage = multer.diskStorage({
  destination: (req, file, cb) => {
    if (!fs.existsSync(uploadsDir)) {
      fs.mkdirSync(uploadsDir, { recursive: true });
    }
    cb(null, uploadsDir);
  },
  filename: (req, file, cb) => {
    const ext = path.extname(file.originalname);
    const name = `pet-${uuidv4()}${ext}`;
    cb(null, name);
  },
});

const upload = multer({
  storage,
  limits: { fileSize: 10 * 1024 * 1024 }, // 10MB limit
  fileFilter: (req, file, cb) => {
    const allowedMimes = ['image/jpeg', 'image/png', 'image/gif', 'image/webp'];
    if (allowedMimes.includes(file.mimetype)) {
      cb(null, true);
    } else {
      cb(new Error('Invalid file type. Only JPEG, PNG, GIF, and WebP are allowed.'));
    }
  },
});

// In-memory stores (MVP)
const petsById = new Map();
const petsByUserId = new Map(); // userId -> Set of petIds

const MAX_NAME_LEN = 100;
const MAX_BREED_LEN = 100;

function sendError(res, status, code, message, details) {
  const payload = { error: code, message };
  if (details) payload.details = details;
  return res.status(status).json(payload);
}

function validatePetName(name) {
  if (!name || !String(name).trim()) return 'missing_name';
  if (String(name).length > MAX_NAME_LEN) return 'name_too_long';
  return null;
}

function validatePetType(type) {
  if (!type || !String(type).trim()) return 'missing_type';
  const validTypes = ['dog', 'cat', 'bird', 'rabbit', 'hamster', 'fish', 'other'];
  if (!validTypes.includes(String(type).toLowerCase())) return 'invalid_type';
  return null;
}

function validatePetAge(age) {
  if (age === undefined || age === null || age === '') return null; // optional
  const ageNum = Number(age);
  if (isNaN(ageNum) || ageNum < 0 || ageNum > 100) return 'invalid_age';
  return null;
}

function validatePetBreed(breed) {
  if (!breed || !String(breed).trim()) return null; // optional
  if (String(breed).length > MAX_BREED_LEN) return 'breed_too_long';
  return null;
}

// GET /pets - List user's pets
router.get('/', (req, res) => {
  if (!req.user || !req.user.id) {
    return sendError(res, 401, 'missing_user', 'User not authenticated');
  }

  const userId = req.user.id;
  const userPetIds = petsByUserId.get(userId) || new Set();
  const data = Array.from(userPetIds).map(petId => petsById.get(petId)).filter(p => p);

  return res.json({ data });
});

// POST /pets - Create pet
router.post('/', (req, res) => {
  if (!req.user || !req.user.id) {
    return sendError(res, 401, 'missing_user', 'User not authenticated');
  }

  const { name, type, age, breed } = req.body || {};

  // Validate required fields
  const nameErr = validatePetName(name);
  if (nameErr) {
    return sendError(res, 400, nameErr, 'Pet name is required and must be 1-100 characters');
  }

  const typeErr = validatePetType(type);
  if (typeErr) {
    return sendError(res, 400, typeErr, 'Pet type is required (dog, cat, bird, rabbit, hamster, fish, or other)');
  }

  // Validate optional fields
  const ageErr = validatePetAge(age);
  if (ageErr) {
    return sendError(res, 400, ageErr, 'Pet age must be a number between 0 and 100');
  }

  const breedErr = validatePetBreed(breed);
  if (breedErr) {
    return sendError(res, 400, breedErr, 'Pet breed must be 1-100 characters');
  }

  const id = uuidv4();
  const now = new Date().toISOString();
  const pet = {
    id,
    ownerId: req.user.id,
    name: String(name).trim(),
    type: String(type).toLowerCase(),
    age: age !== undefined && age !== null && age !== '' ? Number(age) : null,
    breed: breed ? String(breed).trim() : null,
    photoUrl: null,
    createdAt: now,
    updatedAt: now,
  };

  petsById.set(id, pet);
  if (!petsByUserId.has(req.user.id)) {
    petsByUserId.set(req.user.id, new Set());
  }
  petsByUserId.get(req.user.id).add(id);

  return res.status(201).json({ data: pet });
});

// GET /pets/:id - Get single pet
router.get('/:id', (req, res) => {
  if (!req.user || !req.user.id) {
    return sendError(res, 401, 'missing_user', 'User not authenticated');
  }

  const pet = petsById.get(req.params.id);
  if (!pet) {
    return sendError(res, 404, 'pet_not_found', 'Pet not found');
  }

  if (pet.ownerId !== req.user.id) {
    return sendError(res, 403, 'forbidden', 'You do not own this pet');
  }

  return res.json({ data: pet });
});

// PUT /pets/:id - Update pet
router.put('/:id', (req, res) => {
  if (!req.user || !req.user.id) {
    return sendError(res, 401, 'missing_user', 'User not authenticated');
  }

  const pet = petsById.get(req.params.id);
  if (!pet) {
    return sendError(res, 404, 'pet_not_found', 'Pet not found');
  }

  if (pet.ownerId !== req.user.id) {
    return sendError(res, 403, 'forbidden', 'You do not own this pet');
  }

  const { name, type, age, breed, photoUrl } = req.body || {};

  // Validate optional updates
  if (name !== undefined && name !== null) {
    const nameErr = validatePetName(name);
    if (nameErr) {
      return sendError(res, 400, nameErr, 'Pet name must be 1-100 characters');
    }
    pet.name = String(name).trim();
  }

  if (type !== undefined && type !== null) {
    const typeErr = validatePetType(type);
    if (typeErr) {
      return sendError(res, 400, typeErr, 'Pet type must be one of: dog, cat, bird, rabbit, hamster, fish, other');
    }
    pet.type = String(type).toLowerCase();
  }

  if (age !== undefined && age !== null) {
    const ageErr = validatePetAge(age);
    if (ageErr) {
      return sendError(res, 400, ageErr, 'Pet age must be a number between 0 and 100');
    }
    pet.age = age === '' ? null : Number(age);
  }

  if (breed !== undefined && breed !== null) {
    const breedErr = validatePetBreed(breed);
    if (breedErr) {
      return sendError(res, 400, breedErr, 'Pet breed must be 1-100 characters');
    }
    pet.breed = breed === '' ? null : String(breed).trim();
  }

  if (photoUrl !== undefined && photoUrl !== null) {
    pet.photoUrl = photoUrl === '' ? null : String(photoUrl).trim();
  }

  pet.updatedAt = new Date().toISOString();
  return res.json({ data: pet });
});

// DELETE /pets/:id - Delete pet
router.delete('/:id', (req, res) => {
  if (!req.user || !req.user.id) {
    return sendError(res, 401, 'missing_user', 'User not authenticated');
  }

  const pet = petsById.get(req.params.id);
  if (!pet) {
    return sendError(res, 404, 'pet_not_found', 'Pet not found');
  }

  if (pet.ownerId !== req.user.id) {
    return sendError(res, 403, 'forbidden', 'You do not own this pet');
  }

  petsById.delete(req.params.id);
  const userPets = petsByUserId.get(req.user.id);
  if (userPets) {
    userPets.delete(req.params.id);
  }

  return res.json({ message: 'Pet deleted successfully' });
});

// POST /pets/:id/photo - Upload pet photo
router.post('/:id/photo', (req, res, next) => {
  // Create upload middleware on the fly to catch errors
  const uploadMiddleware = upload.single('photo');
  uploadMiddleware(req, res, (err) => {
    if (err) {
      if (err instanceof multer.MulterError) {
        if (err.code === 'LIMIT_FILE_SIZE') {
          return sendError(res, 400, 'file_too_large', 'File size exceeds 10MB limit');
        }
        return sendError(res, 400, 'upload_error', err.message);
      }
      return sendError(res, 400, 'upload_error', err.message);
    }
    
    if (!req.user || !req.user.id) {
      if (req.file) {
        fs.unlinkSync(req.file.path);
      }
      return sendError(res, 401, 'missing_user', 'User not authenticated');
    }

    if (!req.file) {
      return sendError(res, 400, 'no_file', 'No photo file provided');
    }

    const pet = petsById.get(req.params.id);
    if (!pet) {
      fs.unlinkSync(req.file.path);
      return sendError(res, 404, 'pet_not_found', 'Pet not found');
    }

    if (pet.ownerId !== req.user.id) {
      fs.unlinkSync(req.file.path);
      return sendError(res, 403, 'forbidden', 'You do not own this pet');
    }

    // Delete old photo if it exists
    if (pet.photoUrl) {
      const oldPath = path.join(__dirname, pet.photoUrl.replace('/uploads/', 'uploads/'));
      if (fs.existsSync(oldPath)) {
        try {
          fs.unlinkSync(oldPath);
        } catch (e) {
          console.error('Failed to delete old photo:', e);
        }
      }
    }

    // Update pet with new photo URL
    const photoUrl = `/uploads/${req.file.filename}`;
    pet.photoUrl = photoUrl;
    pet.updatedAt = new Date().toISOString();

    return res.json({ data: pet });
  });
});

// Error handling middleware for multer errors
router.use((err, req, res, next) => {
  if (err instanceof multer.MulterError) {
    if (err.code === 'LIMIT_FILE_SIZE') {
      return sendError(res, 400, 'file_too_large', 'File size exceeds 10MB limit');
    }
    return sendError(res, 400, 'upload_error', err.message);
  } else if (err) {
    return sendError(res, 400, 'upload_error', err.message);
  }
  next();
});

module.exports = { router, _stores: { petsById, petsByUserId } };
