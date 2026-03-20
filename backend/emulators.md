# Firebase Emulator Suite — Guide for Project Pet Care

This file explains what the Firebase Emulator Suite is, why it's useful, which emulators to run for this project, step-by-step installation and commands, how to connect the backend and Flutter frontend to the emulators, and common troubleshooting tips.

## What is the Firebase Emulator Suite?

- The Emulator Suite runs local instances of Firebase services (Firestore, Auth, Storage, Functions, Realtime Database, Pub/Sub) on your machine. It lets you develop and test your app locally without deploying to the cloud or using production credentials.
- Emulators are isolated from your real Firebase projects and are ideal for iterative development and automated tests.

## Why use emulators for this project?

- Faster iterative development and debugging.
- No cloud billing or credential risks while developing.
- Ability to seed, reset, and inspect data locally.
- Reproducible integration tests and CI usage.

## Which emulators to run for Project Pet Care

- Recommended: **Authentication**, **Firestore**, **Storage** — your backend initializes these services in `backend/services/firebase-init.js`.
- Optional: **Functions** — if you implement scheduled reminders or server logic that you want to test locally. Add later if needed.
- Not needed (for now): Realtime Database, Hosting, Pub/Sub — unless you add features that require them.

## Install the Firebase CLI (once)

Requires Node.js and npm.

```bash
npm install -g firebase-tools
# verify
firebase --version
```

Note: npm may show warnings about deprecated subpackages or Node engine mismatches; these are usually non-fatal for the CLI.

## Initialize emulators for this repo (one-time per project)

Run from the `backend/` folder:

```bash
cd backend
firebase init emulators
```

Prompts and recommended answers:
- Associate with Firebase project? → **Don't set up a default project** (for local-only development). If you have an existing cloud Firebase project and want to link, choose that instead.
- Which emulators? → select **Authentication**, **Firestore**, **Storage** (and **Functions** if you plan to use them).
- Ports / files: accept the defaults (you can change later in `firebase.json`).

This will create `firebase.json` and any rules files such as `firestore.rules` and `storage.rules` in the `backend/` folder.

## Start the emulators

From `backend/`:

```bash
firebase emulators:start
```

- The command launches the selected emulators and a local Emulator UI (usually on http://localhost:4000). Leave this terminal open while working locally.

## How to connect the backend Node app to the emulators

Two server-side patterns:

1) `firebase-admin` (server/admin SDK) — recommended for privileged backend operations.

Set these environment variables before starting your Node process (recommended for local development):

```bash
export FIRESTORE_EMULATOR_HOST=localhost:8080
export FIREBASE_AUTH_EMULATOR_HOST=localhost:9099
export FIREBASE_STORAGE_EMULATOR_HOST=localhost:9199
# then start your server
node index.js
```

2) Client SDK in Node (less common for privileged ops) — call connect methods in code after initialize.

Example snippets are in `backend/firebase.md` and `backend/services/firebase-init.js`.

## How to connect Flutter to the emulators

In your Flutter app, after `await Firebase.initializeApp()` set emulator hosts. Important: Android emulator maps `localhost` to the host machine via `10.0.2.2`.

Example (Dart):

```dart
await Firebase.initializeApp();
// On iOS / macOS / desktop / web:
FirebaseFirestore.instance.useFirestoreEmulator('localhost', 8080);
FirebaseAuth.instance.useAuthEmulator('localhost', 9099);

// On Android emulator (AVD) use 10.0.2.2:
// FirebaseFirestore.instance.useFirestoreEmulator('10.0.2.2', 8080);
// FirebaseAuth.instance.useAuthEmulator('10.0.2.2', 9099);
```

If you run `flutter run` on a physical device, use the host machine IP address (e.g., `192.168.1.100`) instead of `localhost`.

## Seeding and exporting emulator data

- You can export emulator state for repeatable tests:

```bash
firebase emulators:export ./emulator-data
# start and load from export
firebase emulators:start --import=./emulator-data
```

## Emulator UI

- When emulators run, open the Emulator UI (default http://localhost:4000) to view Firestore documents, Auth users, and Storage files.

## Common errors and troubleshooting

- `firebase: command not found` — ensure `npm install -g firebase-tools` completed and your PATH includes npm global bin.
- Port conflicts — change ports in `firebase.json` or stop the process using the port.
- SDK mismatch errors — ensure `firebase-tools` version is reasonably recent; warnings about deprecated packages are usually safe.
- Flutter can't reach emulator on Android — remember to use `10.0.2.2` or the machine IP for physical devices.

## Quick local workflow (recommended)

1. Start emulators:

```bash
cd backend
firebase emulators:start
```

2. In another terminal, start backend server:

```bash
cd backend
npm install
node index.js   # or `npm start` after package.json scaffold
```

3. In another terminal, run frontend:

```bash
cd frontend
flutter pub get
flutter run
```

## Files in the repo that reference these services

- `backend/services/firebase-init.js` — initializes `app`, `db`, `auth`, `storage`.
- `backend/config/firebase-config.js` — client config placeholder for frontend values.
- `backend/utils/validate-firebase.js` — simple validation script.
- `backend/firebase.md` — higher-level Firebase guide (contains cloud setup notes).

## Next steps for me (if you want)
- I can patch `backend/services/firebase-init.js` to auto-connect to emulators when `FIRESTORE_EMULATOR_HOST` or other emulator env vars are detected.
- I can scaffold `backend/package.json` and `backend/index.js` to provide `npm start` and a small Express health endpoint.

---

File created: `backend/emulators.md` — a guide for local emulator usage.
