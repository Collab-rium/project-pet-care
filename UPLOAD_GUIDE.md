# App Store Upload Guide - Step by Step

For non-technical users. This assumes you've never uploaded an app before.

---

## Phase 1: Set Up Firebase (Backend + Notifications)

### Step 1: Create Firebase Project
1. Go to: https://console.firebase.google.com
2. Click "Create a project"
3. Name: "pet-care"
4. Click "Continue"
5. Disable Google Analytics (optional)
6. Click "Create project"
7. Wait 1-2 minutes for setup

### Step 2: Get Firebase Credentials
1. In Firebase Console, go to **Project Settings** (gear icon)
2. Click **Service Accounts**
3. Click **Generate New Private Key**
4. A JSON file downloads (save it safely)
5. Copy this file to: `backend/.env` (we'll use it later)

### Step 3: Set Up Firestore Database
1. In left menu, click **Firestore Database**
2. Click **Create database**
3. Choose **Start in production mode**
4. Choose region: **us-central1** (or nearest to you)
5. Click **Create**
6. Wait for setup to complete

### Step 4: Update Backend Code
Replace in-memory storage with Firestore:

```bash
cd backend
npm install firebase-admin
```

Replace `backend/index.js` with Firestore initialization:

```javascript
const admin = require('firebase-admin');
const serviceAccount = require('./.env.json'); // Your credentials

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount)
});

const db = admin.firestore();
```

Update pet/reminder storage to use `db.collection('pets').doc()` instead of Maps.

**OR** - Email me and I'll do this part. It's code changes.

### Step 5: Get Firebase Messaging for Notifications
1. In Firebase, go to **Cloud Messaging**
2. Note the **Server API Key** (you'll need this)

---

## Phase 2: Build Release APK (Production Ready)

### Step 1: Generate Signing Key
Run this ONCE (creates your app signature - keep it safe!):

```bash
cd frontend/android/app
keytool -genkey -v -keystore upload-keystore.jks -keyalias upload-key -keyalg RSA -keysize 2048 -validity 10000
```

When prompted:
- **Keystore password**: Remember this (write it down!)
- **Key password**: Same as keystore
- **Name**: Your name or company
- **Organization**: Your company/personal
- **City/State/Country**: Any
- **Email**: Your email
- Answer "yes" at the end

**Keep `upload-keystore.jks` file safe** - you'll need it forever to update this app.

### Step 2: Configure Release Build
Create `frontend/android/key.properties`:

```
storePassword=YOUR_KEYSTORE_PASSWORD
keyPassword=YOUR_KEY_PASSWORD
keyAlias=upload-key
storeFile=upload-keystore.jks
```

Edit `frontend/android/app/build.gradle` - add before `android {`:

```gradle
def keystoreProperties = new Properties()
def keystorePropertiesFile = rootProject.file('key.properties')
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(new FileInputStream(keystorePropertiesFile))
}
```

Then in `android { buildTypes { release { ... } } }` add:

```gradle
signingConfig signingConfigs.release

signingConfigs {
    release {
        keyAlias keystoreProperties['keyAlias']
        keyPassword keystoreProperties['keyPassword']
        storeFile keystoreProperties['storeFile'] ? file(keystoreProperties['storeFile']) : null
        storePassword keystoreProperties['storePassword']
    }
}
```

### Step 3: Build Release APK
```bash
cd frontend
flutter build apk --release
```

Output: `build/app/outputs/flutter-app/release/app-release.apk`

This is your upload file.

---

## Phase 3: Update App Config

### Update Version Number
In `frontend/pubspec.yaml`:

```yaml
version: 1.0.0+1
```

Format is: `MAJOR.MINOR.PATCH+BUILD_NUMBER`
- First upload: `1.0.0+1`
- Next update: `1.0.1+2` or `1.1.0+2`

### Update API Endpoint
In `frontend/lib/config/api_config.dart`:

```dart
// CHANGE THIS:
const String API_BASE_URL = 'http://localhost:4000';

// TO THIS:
const String API_BASE_URL = 'https://your-firebase-backend.run.app';
```

Get your backend URL after deploying to Firebase (next step).

### Update Firebase Config
In `frontend/lib/services/api_service.dart`, configure Firebase:

```dart
import 'package:firebase_core/firebase_core.dart';

// Add to main.dart
await Firebase.initializeApp();
```

---

## Phase 4: Deploy Backend to Firebase

### Option 1: Firebase Cloud Functions (Simplest)
1. Install Firebase CLI:
   ```bash
   npm install -g firebase-tools
   ```

2. Login:
   ```bash
   firebase login
   ```

3. Deploy:
   ```bash
   cd backend
   firebase deploy
   ```

Your backend now runs at: `https://[project-id].run.app`

### Option 2: AWS (More Powerful)
Too complex for this guide. Read CLOUD.md.

---

## Phase 5: Add Notifications Feature

### Step 1: Get Firebase Admin SDK
Already installed. In `backend/services/notifications.js`:

```javascript
const admin = require('firebase-admin');

async function sendNotification(deviceToken, title, body) {
  const message = {
    notification: { title, body },
    token: deviceToken
  };
  
  await admin.messaging().send(message);
}

module.exports = { sendNotification };
```

### Step 2: Scheduler (Check Reminders Every Minute)
In `backend/scheduler.js`:

```javascript
setInterval(async () => {
  const reminders = await db.collection('reminders').where('due', '==', true).get();
  
  for (const doc of reminders.docs) {
    const reminder = doc.data();
    const user = await db.collection('users').doc(reminder.userId).get();
    
    if (user.data().deviceToken) {
      await sendNotification(
        user.data().deviceToken,
        'Reminder',
        reminder.message
      );
      
      await doc.ref.update({ sent: true });
    }
  }
}, 60000); // Every 60 seconds
```

### Step 3: Frontend - Collect Device Token
In `frontend/lib/services/auth_service.dart`:

```dart
import 'package:firebase_messaging/firebase_messaging.dart';

Future<void> saveDeviceToken() async {
  final token = await FirebaseMessaging.instance.getToken();
  // Send to backend: POST /api/device-token with { token }
}
```

Call this after login.

---

## Phase 6: Design & Branding

### App Icon (Required)
Create or download:
- Size: 1024 x 1024 pixels (PNG)
- No transparent background (solid color)
- Export to: `frontend/android/app/src/main/res/mipmap-xxxhdpi/ic_launcher.png`

### Logo/Screenshots (Recommended)
Need 2-4 screenshots showing:
1. Login screen
2. Dashboard with reminders
3. Add pet screen
4. Reminder notification

Tools: Use phone screenshots + simple graphics editor.

---

## Phase 7: Metadata & Store Listing

### Create Google Play Account
1. Go to: https://play.google.com/console
2. Click "Create app"
3. Accept terms
4. Fill in basic info

### App Info to Prepare

| Item | Example |
|------|---------|
| App Name | Pet Care |
| Short Description | Manage pets and reminders |
| Full Description | "Track your pet's feeding schedule, medicines, vet visits, and baths. Get reminders for everything your pet needs." |
| Category | Lifestyle |
| Content Rating | Everyone (select appropriate) |
| Privacy Policy | Link to your privacy policy (required) |
| Contact Email | your@email.com |

### Privacy Policy (Simple)
Create file `privacy_policy.md`:

```markdown
# Privacy Policy

Pet Care collects:
- Your email and name (for login)
- Pet information (name, type, age)
- Reminders (scheduling info)

We use Firebase to store this data securely.

We do NOT:
- Share data with third parties
- Sell your data
- Show ads

For questions: support@petcare.app
```

Host on a simple site or Google Docs (convert to shareable link).

---

## Phase 8: Technical Checklist

Before upload, verify:

- [ ] Release APK built (no debug code)
- [ ] Version number set (1.0.0+1)
- [ ] API_BASE_URL points to live backend
- [ ] App icon included
- [ ] No hardcoded passwords/secrets
- [ ] Minimum OS version set (Android 7.0 or higher)
- [ ] Permissions check (do you need location? camera? etc.)
- [ ] Firebase initialized in app
- [ ] Device token collection working
- [ ] Backend deployed and responding
- [ ] Database (Firestore) connected

### Check Permissions
In `frontend/android/app/src/main/AndroidManifest.xml`:

```xml
<!-- Only include what you need -->
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />
```

### Set Min SDK Version
In `frontend/android/app/build.gradle`:

```gradle
android {
    minSdkVersion 21  // Android 5.0 or higher
}
```

---

## Phase 9: Upload to Play Store

### Upload APK
1. Go to Google Play Console → Your App
2. Go to **Release** → **Production**
3. Click **Create new release**
4. Upload `app-release.apk`
5. Review and publish

### Fill Store Listing
1. Fill all required fields from Phase 7
2. Upload screenshots
3. Upload icon
4. Set content rating
5. Add privacy policy link

### Review & Publish
1. Google reviews for 24-48 hours
2. Once approved, app appears in Play Store
3. Users can download

---

## Troubleshooting

**"API key hardcoded"**
- Move keys to Firebase
- Use environment variables
- Never commit secrets

**"App crashes on startup"**
- Check Firebase initialization
- Verify API_BASE_URL correct
- Check logs in Firebase Console

**"Backend not responding"**
- Verify deployment succeeded
- Check Firebase Cloud Functions logs
- Verify Firestore has data

**"Notifications not working"**
- Check device token saved
- Verify Firebase Messaging enabled
- Check backend scheduler is running

---

## TLDR - Fastest Path

1. Create Firebase project (10 min)
2. Update code to use Firestore (30 min) - OR get help
3. Build release APK (5 min)
4. Deploy backend (5 min)
5. Add notifications (30 min)
6. Create Google Play account (5 min)
7. Upload listing & screenshots (30 min)
8. Submit to review (1 day)

**Total: ~2-3 hours work + 1 day review**

---

## Need Help?

Each step has detailed instructions. If stuck:
1. Read CLOUD.md for more details
2. Check Firebase documentation
3. Search error message online

Most issues have simple fixes.

