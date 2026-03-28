// Reminder Scheduler
// Checks for due reminders every 60 seconds and sends notifications

const admin = require('firebase-admin');
const { sendToUser } = require('./notifications');

let schedulerRunning = false;

async function checkAndSendReminders() {
  try {
    const db = admin.firestore();
    const now = new Date();

    // Get all reminders that are due and not yet sent
    const remindersSnapshot = await db.collection('reminders')
      .where('sent', '==', false)
      .get();

    let notificationsSent = 0;

    for (const reminderDoc of remindersSnapshot.docs) {
      const reminder = reminderDoc.data();
      const scheduledTime = new Date(reminder.scheduledTime);

      // Check if reminder time has passed
      if (scheduledTime <= now) {
        try {
          // Send notification to user
          await sendToUser(
            reminder.userId,
            '🐾 Pet Reminder',
            reminder.message
          );

          // Mark reminder as sent
          await reminderDoc.ref.update({
            sent: true,
            sentAt: new Date(),
            notificationSentAt: new Date()
          });

          notificationsSent++;
          console.log(`✅ Notification sent for reminder: ${reminder.message}`);
        } catch (error) {
          console.error(`Error processing reminder ${reminderDoc.id}:`, error.message);
        }
      }
    }

    if (notificationsSent > 0) {
      console.log(`Scheduler: Sent ${notificationsSent} notification(s)`);
    }
  } catch (error) {
    console.error('Error in reminder scheduler:', error);
  }
}

function startScheduler() {
  if (schedulerRunning) {
    console.log('⚠️ Scheduler already running');
    return;
  }

  schedulerRunning = true;
  console.log('🟢 Reminder scheduler started (checks every 60 seconds)');

  // Check immediately
  checkAndSendReminders();

  // Then check every 60 seconds
  setInterval(checkAndSendReminders, 60000);
}

function stopScheduler() {
  schedulerRunning = false;
  console.log('🔴 Scheduler stopped');
}

module.exports = {
  startScheduler,
  stopScheduler,
  checkAndSendReminders
};
