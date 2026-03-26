const fs = require('fs');
const path = require('path');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');

const JWT_SECRET = process.env.JWT_SECRET || 'dev_jwt_secret_change_me';
const JWT_EXPIRY = '7d';

function loadSeedData(authStores, petsStores, remindersStores) {
  try {
    const seedPath = path.join(__dirname, '..', 'data', 'seed.json');
    if (!fs.existsSync(seedPath)) {
      console.log('No seed data file found, skipping...');
      return;
    }

    const seedData = JSON.parse(fs.readFileSync(seedPath, 'utf8'));
    let usersLoaded = 0;
    let petsLoaded = 0;
    let remindersLoaded = 0;

    // Load users
    if (seedData.users && Array.isArray(seedData.users)) {
      seedData.users.forEach(user => {
        const { id, email, password, name, createdAt } = user;
        const hashed = bcrypt.hashSync(password, 8);
        const userData = { id, email, name, createdAt, password: hashed };
        
        authStores.usersById.set(id, userData);
        authStores.usersByEmail.set(email.toLowerCase(), id);
        usersLoaded++;
      });
    }

    // Load pets
    if (seedData.pets && Array.isArray(seedData.pets)) {
      seedData.pets.forEach(pet => {
        const { id, ownerId } = pet;
        petsStores.petsById.set(id, pet);
        
        if (!petsStores.petsByUserId.has(ownerId)) {
          petsStores.petsByUserId.set(ownerId, new Set());
        }
        petsStores.petsByUserId.get(ownerId).add(id);
        petsLoaded++;
      });
    }

    // Load reminders
    if (seedData.reminders && Array.isArray(seedData.reminders)) {
      seedData.reminders.forEach(reminder => {
        const { id, userId, petId } = reminder;
        remindersStores.remindersById.set(id, reminder);
        
        if (!remindersStores.remindersByUserId.has(userId)) {
          remindersStores.remindersByUserId.set(userId, new Set());
        }
        remindersStores.remindersByUserId.get(userId).add(id);
        
        if (!remindersStores.remindersByPetId.has(petId)) {
          remindersStores.remindersByPetId.set(petId, new Set());
        }
        remindersStores.remindersByPetId.get(petId).add(id);
        remindersLoaded++;
      });
    }

    console.log(`Seed data loaded: ${usersLoaded} users, ${petsLoaded} pets, ${remindersLoaded} reminders`);
  } catch (err) {
    console.error('Error loading seed data:', err.message);
  }
}

module.exports = { loadSeedData };
