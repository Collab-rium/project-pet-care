# Firebase Deployment Guide (Phase 5-7)

Complete guide to deploy backend to Firebase Cloud Functions and connect frontend.

---

## Prerequisites

- [ ] Google account (free)
- [ ] Completed backend code (Phase 1)
- [ ] Completed frontend code (Phase 2-3)
- [ ] Released APK built (Phase 4)
- [ ] Node.js installed locally

---

## Phase 5: Create Firebase Project

### Step 1: Create Firebase Project

1. Go to: https://console.firebase.google.com
2. Click **"Add project"**
3. Project name: `pet-care` (or your app name)
4. Click **"Continue"**
5. Disable "Enable Google Analytics" (optional)
6. Click **"Create project"**
7. Wait 1-2 minutes for setup

### Step 2: Create Firestore Database

1. In Firebase Console, left menu → **"Firestore Database"**
2. Click **"Create database"**
3. Choose **"Start in production mode"**
4. Location: **"us-central1"** (or nearest to you)
5. Click **"Create"**
6. Wait for setup to complete

### Step 3: Get Firebase Credentials

1. Left menu → **"Project Settings"** (gear icon)
2. Click **"Service Accounts"** tab
3. Click **"Generate New Private Key"**
4. File downloads: `service-account-key.json`
5. Save file to: `backend/service-account-key.json`

**IMPORTANT: Never commit this file!**

Add to `backend/.gitignore`:
```
service-account-key.json
.env
key.properties
```

### Step 4: Set Up Firestore Rules

1. In Firestore, click **"Rules"** tab
2. Replace with:

```firestore
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Authenticated users can read/write their own data
    match /users/{userId} {
      allow read, write: if request.auth.uid == userId;
    }
    
    // Pets belong to users
    match /pets/{petId} {
      allow read, write: if request.auth.uid == resource.data.ownerId;
    }
    
    // Reminders belong to users
    match /reminders/{reminderId} {
      allow read, write: if request.auth.uid == resource.data.userId;
    }
  }
}
```

3. Click **"Publish"**

---

## Phase 6: Deploy Backend to Firebase

### Step 1: Install Firebase CLI

```bash
npm install -g firebase-tools
```

### Step 2: Login to Firebase

```bash
firebase login
```

This opens browser to authenticate. Click "Allow".

### Step 3: Initialize Firebase in Backend

```bash
cd backend
firebase init functions
```

When prompted:
```
? Which file would you like to use for Cloud Functions? functions/index.js
? Do you want to install dependencies? Yes
? Do you want to use ESLint? No (optional)
```

### Step 4: Create Functions Directory Structure

```bash
# Inside backend/
mkdir -p functions/src
```

Copy your backend code to `functions/src/`:
```bash
cp index.js functions/src/index.js
cp auth.js functions/src/auth.js
cp pets.js functions/src/pets.js
cp reminders.js functions/src/reminders.js
cp dashboard.js functions/src/dashboard.js
cp notifications.js functions/src/notifications.js
cp scheduler.js functions/src/scheduler.js
cp services/ functions/src/services/
```

### Step 5: Update functions/index.js

Create `backend/functions/index.js`:

```javascript
const functions = require('firebase-functions');
const app = require('./src/index');

// Export the Express app as a Cloud Function
exports.api = functions
  .region('us-central1')
  .https.onRequest(app);
```

### Step 6: Update Backend index.js for Cloud Functions

Modify `backend/src/index.js` to export the Express app:

```javascript
// ... existing code ...

// Export for Cloud Functions
module.exports = app;
```

### Step 7: Update backend/functions/package.json

Ensure it has:
```json
{
  "dependencies": {
    "firebase-admin": "^12.0.0",
    "express": "^4.18.2",
    "cors": "^2.8.5",
    ...other dependencies...
  }
}
```

### Step 8: Deploy to Firebase

```bash
cd backend
firebase deploy --only functions
```

This uploads your backend to Firebase Cloud Functions.

### Step 9: Get Your Backend URL

After deployment completes, output shows:

```
Function URL (api):
https://us-central1-pet-care-abcd1234.cloudfunctions.net/api
```

**Save this URL!** You'll need it for the frontend.

---

## Phase 7: Connect Frontend to Production Backend

### Step 1: Update Frontend API Configuration

Edit `frontend/lib/config/api_config.dart`:

```dart
// Change FROM:
const bool useProductionBackend = false;
const String apiBaseUrlProduction = 'http://localhost:4000';

// Change TO:
const bool useProductionBackend = true;
const String apiBaseUrlProduction = 'https://us-central1-pet-care-abcd1234.cloudfunctions.net/api';
```

Use your actual Firebase URL from Step 9.

### Step 2: Update Notification Service

Edit `frontend/lib/services/notification_service.dart`:

Add your JWT token (from auth service) to the request headers:

```dart
static Future<void> saveTokenToBackend(String token) async {
  try {
    // Get JWT token from auth service
    // This assumes you have access to the auth token
    final jwtToken = await _getJWTToken();
    
    final response = await http.post(
      Uri.parse('$API_BASE_URL/device-token'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $jwtToken',
      },
      body: jsonEncode({'token': token}),
    );
    // ... rest of code
  }
}
```

### Step 3: Rebuild Release APK

```bash
cd frontend
flutter clean
flutter pub get
flutter build apk --release
```

### Step 4: Test Production Backend Locally

Before uploading to Play Store:

```bash
# Install on emulator
adb install -r build/app/outputs/flutter-app/release/app-release.apk

# Or with flutter
flutter install --release
```

Test flow:
1. Register new account
2. Login
3. Add pet
4. Add reminder
5. Wait for reminder time
6. Check if notification appears

---

## Summary: Deployment Commands

```bash
# 1. Create Firebase project (web console)
# 2. Download service-account-key.json to backend/

# 3. Install Firebase CLI
npm install -g firebase-tools

# 4. Login to Firebase
firebase login

# 5. Deploy backend
cd backend
firebase init functions
firebase deploy --only functions

# 6. Get backend URL and update frontend
# 7. Update frontend/lib/config/api_config.dart with URL

# 8. Build production APK
cd frontend
flutter build apk --release

# 9. Upload to Play Store
```

---

## Troubleshooting

### Error: "service-account-key.json not found"
- Download from Firebase Console → Project Settings → Service Accounts
- Save to `backend/service-account-key.json`

### Error: "Functions not deploying"
- Check Node.js version: `node --version` (should be 16+)
- Check Firebase CLI: `firebase --version`
- Check backend code is in `functions/src/`

### Backend returns 404
- Check URL is correct in `api_config.dart`
- Check Firestore rules are set
- Check function deployed: `firebase functions:list`

### Notifications not working
- Check device token being sent to backend
- Check Firebase Messaging enabled
- Check notification scheduler running (logs in Firebase Console)

### Cold Start Issue
- First request to Cloud Functions takes 5-10 seconds
- This is normal, improves with usage
- Can be mitigated by scheduled functions

---

## What's Working Now

✅ Backend deployed to Cloud Functions
✅ Firestore database ready
✅ Frontend connected to production backend
✅ Release APK ready for Play Store
✅ Notifications configured
✅ Automatic reminders every 60 seconds

---

## Next Steps

1. ✅ Deploy backend (Phase 6)
2. ✅ Connect frontend (Phase 7)
3. ⬜ Upload to Google Play Store
4. ⬜ Get app review
5. ⬜ Publish to store

Estimated time remaining: 1-2 hours (mostly waiting for review)

