# Quick Reference Guide

## Your Questions Answered 🎯

### Q1: What is LOC?

**LOC = Lines of Code** (just a count)

- Backend: ~1,500 lines (Express server + tests)
- Frontend: ~3,000 lines (Flutter widgets + screens)
- This is how big the projects are (not quality indicator)

---

### Q2: How Do Backend & Frontend Work Together?

**Like a Restaurant**:
- **Frontend** = Customer (orders food)
- **Backend** = Kitchen (prepares food)
- **HTTP** = Menu/order tickets (communication)

**Technical Flow**:
```
User taps button in Flutter app
    ↓
Flutter makes HTTP POST/GET/PUT request
    ↓
Backend receives on port 4000
    ↓
Backend processes (validate, store, retrieve)
    ↓
Backend sends JSON response
    ↓
Flutter receives & updates UI
```

**Example: Add a Pet**
1. User fills form in app
2. Taps "Save"
3. App sends: `POST http://10.0.2.2:4000/pets` with pet data
4. Backend stores in RAM
5. Backend sends back pet ID + data
6. App shows pet in list

---

### Q3: Where is Database Stored?

**RIGHT NOW (Development)**:
- **Location**: Your laptop's RAM
- **During**: While server is running
- **After restart**: GONE (data resets to seed.json)

**Visual**:
```
┌─ Your Laptop ─────────────────┐
│  RAM (Memory):                │
│  - Users Map (in memory)      │
│  - Pets Map (in memory)       │
│  - Reminders Map (in memory)  │
│                               │
│  ⚠️  Resets on server restart! │
└───────────────────────────────┘
```

**FOR PRODUCTION (Phase 4)**:
- PostgreSQL on AWS (permanent disk)
- Or Firebase Firestore (cloud database)
- Data persists forever (unless deleted)

---

### Q4: Is It Only Debug APK?

**YES - Debug APK Only** ✅

- **Debug APK** (147 MB)
  - Current: `app-debug.apk`
  - For: Development & testing
  - Perfect for: Android Studio debugging
  - Issue: Cannot submit to Play Store
  - Size: Large (147 MB)

- **Release APK** (Not built yet)
  - Would be: `app-release.apk`
  - For: Production / Play Store
  - Size: Smaller (~50 MB)
  - Build when: Ready to publish

**Current Status**: 
- ✅ Debug APK ready for testing
- ❌ Release APK not needed yet (build when shipping)

---

### Q5: Why Docs in Root?

**Two-Tier Documentation System**:

**Tier 1 (Root Directory)** - Quick Reference:
```
- MVP_PROJECT_COMPLETE.md          → Project summary
- FINAL_VERIFICATION.md             → Status check
- ARCHITECTURE_EXPLANATION.md        → How it works
- DATA_FLOW_EXPLAINED.md            → Data flow diagrams
- PROJECT_CONTEXT.md                → Unified context
```

**Tier 2 (docs/ folder)** - Detailed Specs:
```
docs/mvp/
├── 01-API_CONTRACT.md              → All endpoint details
├── backend/02-BACKEND_CHECKLIST.md → Backend requirements
└── frontend/02-FRONTEND_CHECKLIST.md → Frontend requirements
```

**Why?**
- Root docs = What you need NOW (quick answers)
- docs/ folder = What you need LATER (detailed reference)
- Makes project easy to understand at a glance

---

## Quick Commands

### Start Backend
```bash
cd backend
npm install    # First time only
npm start      # Starts on port 4000
# In another terminal:
curl http://localhost:4000/health  # Verify it's running
```

### Run Frontend
```bash
cd frontend
flutter pub get  # First time only
flutter run     # Runs on emulator/device
```

### Run Tests
```bash
cd backend
npm test  # Should see: 39/39 tests passing
```

### Build Debug APK
```bash
cd frontend
flutter build apk --debug
# Output: build/app/outputs/flutter-apk/app-debug.apk (147 MB)
```

### Build Release APK (when ready)
```bash
cd frontend
flutter build apk --release
# Output: build/app/outputs/flutter-apk/app-release.apk (~50 MB)
```

---

## Architecture Summary

```
┌─────────────────────────────┐
│   FLUTTER APP (Your Phone)  │
│                             │
│  ┌───────────────────────┐  │
│  │ UI Screens            │  │
│  │ - Login               │  │
│  │ - Pets List           │  │
│  │ - Reminders           │  │
│  │ - Dashboard           │  │
│  └───────────────────────┘  │
│           ↓                  │
│  ┌───────────────────────┐  │
│  │ API Service Layer     │  │
│  │ - Makes HTTP requests │  │
│  └───────────────────────┘  │
└──────────────┬──────────────┘
               ↓
        Network/HTTP
               ↓
┌──────────────────────────────────────┐
│   NODE.JS SERVER (Your Laptop)       │
│   Port: 4000                         │
│                                      │
│  ┌────────────────────────────────┐  │
│  │ Express Routes                 │  │
│  │ - /auth/register, /login       │  │
│  │ - /pets (CRUD)                 │  │
│  │ - /reminders (CRUD)            │  │
│  │ - /dashboard/today             │  │
│  └────────────────────────────────┘  │
│           ↓                           │
│  ┌────────────────────────────────┐  │
│  │ Data Store (RAM)               │  │
│  │ - usersById Map                │  │
│  │ - petsById Map                 │  │
│  │ - remindersById Map            │  │
│  │ ⚠️  Temporary (resets on stop)  │  │
│  └────────────────────────────────┘  │
└──────────────────────────────────────┘
```

---

## Network Details

### Emulator Connection
- Emulator IP: `10.0.2.2:4000`
- (Special IP that means "localhost on host machine")

### Physical Device Connection
- Same network as laptop: `192.168.x.x:4000`
- Or: `<laptop-ip>:4000`

### Localhost Connection
- Your laptop: `localhost:4000`

---

## Testing the Connection

### Backend Health Check
```bash
curl http://localhost:4000/health
# Expected: {"ok":true,"uptime":123,"timestamp":"2026-03-27..."}
```

### Register User (Test)
```bash
curl -X POST http://localhost:4000/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test@example.com",
    "password": "TestPass123",
    "name": "Test User"
  }'
# Expected: {"user":{...}, "token":"..."}
```

### Get Pets (Test)
```bash
# First get token from above, then:
curl http://localhost:4000/pets \
  -H "Authorization: Bearer <token from register>"
# Expected: {"data":[...]}
```

---

## File Locations You Need to Know

| What | Where |
|------|-------|
| Backend Server | `backend/index.js` |
| Endpoints | `backend/{auth,pets,reminders,dashboard}.js` |
| Tests | `backend/tests/*.test.js` |
| Seed Data | `backend/data/seed.json` |
| Frontend App | `frontend/lib/main.dart` |
| Screens | `frontend/lib/screens/` |
| API Service | `frontend/lib/services/` |
| Config | `frontend/lib/config/api_config.dart` |
| APK Built | `frontend/build/app/outputs/flutter-apk/` |

---

## Toggle Between Mock & Real API

### Use Mock API (No Backend Needed)
```dart
// frontend/lib/config/api_config.dart
const bool useMockApi = true;  // ← Mock data
```

### Use Real Backend
```dart
// frontend/lib/config/api_config.dart
const bool useMockApi = false;  // ← Real backend on 10.0.2.2:4000
```

Then start backend: `npm start`

---

## Troubleshooting

### "Cannot connect to backend"
- Is backend running? (`npm start`)
- Is port 4000 free? 
- Using correct IP (10.0.2.2 for emulator)?
- Firewall blocking? (unlikely on localhost)

### "Token expired"
- JWT tokens last 7 days
- Log in again to get new token
- Check token in flutter_secure_storage

### "Database is empty"
- Server just restarted? Data lost (normal)
- Reload seed.json by restarting backend
- Data persists during server uptime only

### "Tests failing"
- Run: `npm test` from backend/
- Should see: 39 tests passing
- If failing: Check npm version, Node version

---

## Production Checklist (When Ready)

- [ ] Build release APK: `flutter build apk --release`
- [ ] Deploy backend to AWS/Heroku
- [ ] Set up PostgreSQL database (or Firestore)
- [ ] Update API_BASE_URL for production
- [ ] Test end-to-end on production server
- [ ] Submit to Google Play Store
- [ ] Monitor for crashes (Sentry or Crashlytics)

