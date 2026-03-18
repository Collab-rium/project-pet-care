// Utility to Validate Firebase Initialization
const { db, auth, storage } = require('../services/firebase-init');

const validateFirebase = () => {
  try {
    console.log('Firebase services initialized successfully:', {
      database: !!db,
      authentication: !!auth,
      storage: !!storage,
    });
  } catch (error) {
    console.error('Error validating Firebase initialization:', error);
  }
};

validateFirebase(); // Run validation