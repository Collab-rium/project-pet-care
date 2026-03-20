# Firebase — Overview, Billing, Emulator, and Project Setup

This document explains what Firebase is, the free vs paid plans, how to use the Firebase Emulator Suite for local development, and concrete steps to wire the backend and Flutter frontend to emulators or to the real Firebase cloud project.

---

## 1) What is Firebase (short)

- Firebase is a Google-managed platform providing backend services commonly used in mobile/web apps: Authentication, Cloud Firestore (NoSQL DB), Realtime Database, Cloud Storage, Cloud Functions, Cloud Messaging (FCM), Hosting, and more.
- You can use Firebase client SDKs in frontend apps or the Admin SDK in server code for privileged operations.

## 2) Billing: Spark vs Blaze

- Spark (Free): Suitable for development and small apps. Includes free quotas for Firestore/RealtimeDB, Authentication (email/password, anonymous), small Storage quota, and limited Functions usage. No credit card required.
- Blaze (Pay-as-you-go): Required only if you exceed Spark quotas or need Blaze-only features (e.g., higher phone-auth volumes, heavy Cloud Functions outbound networking, big Storage/egress). For early development you can stay on Spark.

Recommendation: Use Spark while developing and testing locally. Move to Blaze only when you need production scale or Blaze-only features.

## 3) Why use the Emulator Suite

- The Emulator Suite runs local instances of Firestore, Auth, Storage, Functions, etc., letting you develop and test without touching the cloud or incurring costs.
- Benefits: fast iteration, deterministic tests, no credentials sharing, safe CI usage, and easy local seeding/reset.

## 4) Install and basic emulator commands

1. Install the Firebase CLI (Node/npm required):

```bash
npm install -g firebase-tools
```

2. (Optional) Log in to Firebase (only required when interacting with real projects):

```bash
firebase login
```

3. Initialize emulators for your project (run this in the `backend/` folder):

```bash
cd backend
firebase init emulators
# Select Firestore, Auth, Storage, Functions as needed
```

4. Start emulators:

```bash
firebase emulators:start
# or start only specific emulators
firebase emulators:start --only firestore,auth,storage
```

Keep `firebase emulators:start` running while you run your backend and frontend locally.

## 5) How the backend will connect to Firebase (Emulator-first)

We will provide a minimal Node/Express server that connects to Firebase. Two common approaches:

- Client SDK in Node (for non-privileged paths) — use `firebase` package and call connect methods for emulators.
- Admin SDK in Node (for privileged server operations) — use `firebase-admin` and point it at emulator hosts when testing.

Examples:

- Client SDK (v9-ish / modular):

```js
const { initializeApp } = require('firebase/app');
const { getAuth, connectAuthEmulator } = require('firebase/auth');
const { getFirestore, connectFirestoreEmulator } = require('firebase/firestore');

const app = initializeApp({ /* client config or placeholders */ });
const auth = getAuth(app);
connectAuthEmulator(auth, 'http://localhost:9099');

const db = getFirestore(app);
connectFirestoreEmulator(db, 'localhost', 8080);
```

- Admin SDK (recommended for server privileged ops):

```js
# set env variables BEFORE initializing admin
process.env.FIRESTORE_EMULATOR_HOST = 'localhost:8080';
process.env.FIREBASE_AUTH_EMULATOR_HOST = 'localhost:9099';

const admin = require('firebase-admin');
admin.initializeApp();
const db = admin.firestore();
```

Notes:
- For the Admin SDK, setting `FIRESTORE_EMULATOR_HOST` and `FIREBASE_AUTH_EMULATOR_HOST` routes SDK calls to the local emulator.

## 6) How Flutter connects to emulators

- In Flutter, after `Firebase.initializeApp()` call the emulator methods. Important: emulator host differs when running on Android emulator.

Example (Dart):

```dart
await Firebase.initializeApp();
// For iOS / macOS / desktop and web, use 'localhost'
FirebaseFirestore.instance.useFirestoreEmulator('localhost', 8080);
FirebaseAuth.instance.useAuthEmulator('localhost', 9099);

// On Android emulator (emulator): use 10.0.2.2 as host
// FirebaseFirestore.instance.useFirestoreEmulator('10.0.2.2', 8080);
// FirebaseAuth.instance.useAuthEmulator('10.0.2.2', 9099);
```

## 7) Firebase features we'll use in this project (mapping)

- Authentication (Firebase Auth): user sign-up / sign-in (email/password, anonymous for testing). Used to map data to a user account.
- Firestore (Cloud Firestore): primary app data store for users, pets, reminders, schedules — flexible and realtime.
- Cloud Storage: store user-uploaded files (pet photos). Store metadata in Firestore.
- Cloud Functions (optional): handle scheduled reminders, push notifications (FCM) or other server-side tasks. Functions can be developed and tested with the Functions emulator.
- Cloud Messaging (FCM): push notifications for reminders. For local development, testing push flows may require real FCM tokens; emulator support is limited for device-targeted messages.

Emulator-first: develop Auth, Firestore, and Storage interactions locally; only create a real Firebase project when you need device push notifications or to demo to others.

## 8) Setting up a cloud Firebase project (when ready)

1. Open https://console.firebase.google.com and create a new project.
2. Register your Android and iOS app(s) in the project to get `google-services.json` (Android) and `GoogleService-Info.plist` (iOS).
3. For server admin access (optional), create a service account key: Console → Project Settings → Service Accounts → Generate new private key. Save the JSON to a secure location and set the env var:

```bash
export GOOGLE_APPLICATION_CREDENTIALS="/path/to/service-account.json"
```

4. Deploy rules, Cloud Functions, and other resources only after testing locally.

## 9) Env vars and config notes

- Use environment variables or a `.env` (not committed) to store any secrets or file paths. Example keys we will reference in backend templates:

- `GOOGLE_APPLICATION_CREDENTIALS` → path to service account JSON (for `firebase-admin` on cloud).
- `FIREBASE_API_KEY`, `FIREBASE_AUTH_DOMAIN`, `FIRESTORE_PROJECT_ID`, etc., are client-side config values (used in Flutter). Those values come from the project settings in the console.

## 10) Quick local dev workflow

1. Start emulators:

```bash
cd backend
firebase emulators:start
```

2. In another terminal, start backend (example):

```bash
cd backend
npm install
npm start
```

3. In another terminal, run the Flutter app (ensure emulator host adjustments if using Android emulator):

```bash
cd frontend
flutter pub get
flutter run
```

## 11) Security rules and testing

- While using emulators, define and test Firestore and Storage security rules locally. Rules can be deployed when ready.
- Always test CRUD flows with authenticated and unauthenticated users to verify your rules.

## 12) When to move to the real Firebase cloud

- When you need real device push notifications, need to test on physical devices with real FCM tokens, or when sharing a deploy demo with stakeholders.
- Before moving to cloud for production, ensure you are on Blaze if your expected usage exceeds Spark free quotas.

---

File created for local reference in the repository: `backend/firebase.md`.
