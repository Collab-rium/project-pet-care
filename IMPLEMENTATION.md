# Implementation Guide - Code Changes Needed

For developers who need to make the actual code changes.

---

## 1. Firestore Integration (Backend)

### Install Firebase Admin
```bash
cd backend
npm install firebase-admin
```

### Update backend/index.js
Replace the in-memory storage:

**BEFORE (current in-memory):**
```javascript
const usersById = new Map();
const petsById = new Map();
const remindersById = new Map();
```

**AFTER (Firestore):**
```javascript
const admin = require('firebase-admin');
const serviceAccount = require('./service-account-key.json');

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount)
});

const db = admin.firestore();

// Collections instead of Maps
// Access with: db.collection('users').doc(userId)
```

### Update User Endpoints
Replace Map operations with Firestore:

**BEFORE:**
```javascript
usersById.set(userId, user);
```

**AFTER:**
```javascript
await db.collection('users').doc(userId).set(user);
```

**BEFORE:**
```javascript
const user = usersById.get(userId);
```

**AFTER:**
```javascript
const userDoc = await db.collection('users').doc(userId).get();
const user = userDoc.data();
```

### Update Pet Endpoints
Same pattern for pets collection:

```javascript
// Create
await db.collection('pets').doc(petId).set(petData);

// Read
const pet = (await db.collection('pets').doc(petId).get()).data();

// Update
await db.collection('pets').doc(petId).update(changes);

// Delete
await db.collection('pets').doc(petId).delete();

// List all for user
const pets = await db.collection('pets')
  .where('userId', '==', userId)
  .get();
```

### Update Reminder Endpoints
Same pattern for reminders:

```javascript
// List reminders due today
const today = new Date().toDateString();
const reminders = await db.collection('reminders')
  .where('userId', '==', userId)
  .where('scheduledDate', '==', today)
  .get();
```

---

## 2. Notifications Feature (Backend)

### Create backend/notifications.js

```javascript
const admin = require('firebase-admin');

async function sendNotification(deviceToken, title, body) {
  try {
    const message = {
      notification: {
        title: title,
        body: body
      },
      token: deviceToken
    };

    const response = await admin.messaging().send(message);
    console.log('Notification sent:', response);
    return response;
  } catch (error) {
    console.error('Error sending notification:', error);
    throw error;
  }
}

module.exports = { sendNotification };
```

### Create backend/scheduler.js

```javascript
const admin = require('firebase-admin');
const { sendNotification } = require('./notifications');

async function checkReminders() {
  const db = admin.firestore();
  const now = new Date();

  try {
    // Get all reminders not yet sent
    const remindersSnapshot = await db.collection('reminders')
      .where('sent', '==', false)
      .get();

    for (const reminderDoc of remindersSnapshot.docs) {
      const reminder = reminderDoc.data();
      const scheduledTime = new Date(reminder.scheduledTime);

      // If reminder time has passed
      if (scheduledTime <= now) {
        // Get user's device token
        const userDoc = await db.collection('users')
          .doc(reminder.userId)
          .get();
        
        const deviceToken = userDoc.data().deviceToken;

        if (deviceToken) {
          // Send notification
          await sendNotification(
            deviceToken,
            'Pet Reminder',
            reminder.message
          );

          // Mark as sent
          await reminderDoc.ref.update({
            sent: true,
            sentAt: new Date()
          });
        }
      }
    }
  } catch (error) {
    console.error('Error checking reminders:', error);
  }
}

// Run every 60 seconds
setInterval(checkReminders, 60000);

module.exports = { checkReminders };
```

### Add to backend/index.js

```javascript
// At the top
require('./scheduler');

// This starts the scheduler when server starts
```

### Add Device Token Endpoint

```javascript
app.post('/api/device-token', authenticateToken, async (req, res) => {
  try {
    const { token } = req.body;
    const userId = req.user.userId;

    await db.collection('users').doc(userId).update({
      deviceToken: token,
      updatedAt: new Date()
    });

    res.json({ success: true });
  } catch (error) {
    res.status(400).json({ error: error.message });
  }
});
```

---

## 3. Firebase Messaging (Frontend)

### Install Dependencies
```bash
cd frontend
flutter pub add firebase_messaging
```

### Update frontend/lib/main.dart

```dart
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  await Firebase.initializeApp();
  
  // Request notification permission
  await FirebaseMessaging.instance.requestPermission();
  
  runApp(const MyApp());
}
```

### Create frontend/lib/services/notification_service.dart

```dart
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class NotificationService {
  static final _messaging = FirebaseMessaging.instance;

  static Future<void> initialize() async {
    // Get device token
    final token = await _messaging.getToken();
    print('Device Token: $token');

    // Send token to backend
    await sendTokenToBackend(token!);

    // Handle foreground notifications
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Got a message while in the foreground!');
      print('Message data: ${message.data}');
      print('Message title: ${message.notification?.title}');
      print('Message body: ${message.notification?.body}');
    });
  }

  static Future<void> sendTokenToBackend(String token) async {
    try {
      final response = await http.post(
        Uri.parse('https://your-firebase-backend.run.app/api/device-token'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer YOUR_JWT_TOKEN'
        },
        body: jsonEncode({'token': token})
      );

      if (response.statusCode == 200) {
        print('Token sent to backend');
      }
    } catch (e) {
      print('Error sending token: $e');
    }
  }
}
```

### Update frontend/lib/services/auth_service.dart

```dart
import 'package:firebase_messaging/firebase_messaging.dart';

// After successful login
Future<void> login(String email, String password) async {
  // ... existing login code ...
  
  // After login succeeds:
  final token = await FirebaseMessaging.instance.getToken();
  if (token != null) {
    await NotificationService.sendTokenToBackend(token);
  }
}
```

---

## 4. Update Configuration

### frontend/lib/config/api_config.dart

```dart
// Change this:
const String API_BASE_URL = 'http://localhost:4000';

// To your Firebase Cloud Function URL:
const String API_BASE_URL = 'https://your-project-id-a1b2c3d.run.app';
```

Get the URL after deploying to Firebase.

### frontend/pubspec.yaml

```yaml
# Increment version
version: 1.0.0+1

# Add Firebase
dependencies:
  firebase_core: ^latest
  firebase_messaging: ^latest
```

---

## 5. Permissions

### frontend/android/app/src/main/AndroidManifest.xml

```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
    
    <!-- Required for app to work -->
    <uses-permission android:name="android.permission.INTERNET" />
    <uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />
    
    <!-- For notifications -->
    <uses-permission android:name="android.permission.POST_NOTIFICATIONS" />
    
    <!-- For image picker -->
    <uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />
```

---

## 6. Min SDK Version

### frontend/android/app/build.gradle

```gradle
android {
    compileSdkVersion 33
    
    defaultConfig {
        minSdkVersion 21  // Android 5.0 or higher
        targetSdkVersion 33
    }
}
```

---

## Testing Locally

### 1. Start Backend
```bash
cd backend
npm start
```

Should see: "Server running on port 4000"

### 2. Start Frontend
```bash
cd frontend
flutter run
```

### 3. Test Flow
1. Register account
2. Login
3. Open app console - should see device token
4. Add pet & reminder
5. Backend scheduler checks every 60 seconds
6. When time passes, notification should appear

### 4. Check Logs
Backend: `npm start` output
Frontend: `flutter run` output
Firebase: Console → Functions → Logs

---

## Deploy to Firebase

### 1. Install Firebase CLI
```bash
npm install -g firebase-tools
firebase login
```

### 2. Initialize Firebase
```bash
cd backend
firebase init functions
```

Choose:
- Use existing project
- Use TypeScript or JavaScript
- Continue defaults

### 3. Deploy
```bash
firebase deploy --only functions
```

Your backend is now live!

---

## Troubleshooting

**Error: "Credential not found"**
- Make sure service-account-key.json is in backend folder
- Check file path in code

**"Firestore rules deny access"**
- In Firebase Console → Firestore → Rules
- Change to:
```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /{document=**} {
      allow read, write: if request.auth != null;
    }
  }
}
```

**"Notifications not working"**
- Device token not saved?
- Firebase Messaging not initialized?
- Check backend scheduler is running

**"Backend URL not responding"**
- Verify Cloud Functions deployed
- Check logs in Firebase Console
- Try URL directly in browser

---

## Timeline

| Phase | Time |
|-------|------|
| Set up Firestore | 15 min |
| Update backend to Firestore | 60 min |
| Add notifications | 45 min |
| Update frontend for Firebase | 30 min |
| Deploy to Firebase | 5 min |
| Test everything | 20 min |
| **Total** | **175 min (3 hours)** |

---

## Questions?

- Read UPLOAD_GUIDE.md for user-friendly version
- Check CLOUD.md for Firebase details
- Search Firebase documentation
- Post error message online

Most issues have simple fixes!

