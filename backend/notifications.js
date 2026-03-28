// Notifications Service
// Handles sending push notifications via Firebase Cloud Messaging

const admin = require('firebase-admin');

async function sendNotification(deviceToken, title, message) {
  try {
    if (!deviceToken) {
      console.log('No device token for notification');
      return;
    }

    const messagePayload = {
      notification: {
        title: title,
        body: message
      },
      token: deviceToken
    };

    const response = await admin.messaging().send(messagePayload);
    console.log('✅ Notification sent:', response);
    return response;
  } catch (error) {
    console.error('❌ Error sending notification:', error.message);
    throw error;
  }
}

async function sendToUser(userId, title, message) {
  try {
    const db = admin.firestore();
    const userDoc = await db.collection('users').doc(userId).get();

    if (!userDoc.exists) {
      console.log('User not found:', userId);
      return;
    }

    const deviceToken = userDoc.data().deviceToken;
    if (!deviceToken) {
      console.log('No device token for user:', userId);
      return;
    }

    return await sendNotification(deviceToken, title, message);
  } catch (error) {
    console.error('Error sending notification to user:', error);
    throw error;
  }
}

module.exports = {
  sendNotification,
  sendToUser
};
