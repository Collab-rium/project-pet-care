# Project Architecture - Complete Explanation

## 1. What is LOC?

**LOC** = **Lines of Code** — just a count of how many lines of source code exist.

- Backend LOC: ~1,500 lines (mostly Express endpoints + tests)
- Frontend LOC: ~3,000 lines (Flutter widgets + screens)
- This is just for estimation (not a quality metric)

---

## 2. How Backend & Frontend Work Together

### The Connection Flow

```
┌─────────────────────────────────────────────────────────────┐
│                      USER'S DEVICE                           │
│  ┌──────────────────────────────────────────────────────┐   │
│  │               FLUTTER APP (Frontend)                 │   │
│  │  ┌────────────────────────────────────────────────┐  │   │
│  │  │ UI Screens (login, pets, reminders, dashboard) │  │   │
│  │  └────────────────────────────────────────────────┘  │   │
│  │                       ↓                               │   │
│  │  ┌────────────────────────────────────────────────┐  │   │
│  │  │ API Service Layer (makes HTTP requests)       │  │   │
│  │  └────────────────────────────────────────────────┘  │   │
│  │                       ↓                               │   │
│  │  ┌────────────────────────────────────────────────┐  │   │
│  │  │ HTTP Client (sends JSON over internet)        │  │   │
│  │  └────────────────────────────────────────────────┘  │   │
│  └──────────────────────────────────────────────────────┘   │
│                       ↓ (HTTP)                              │
│                    network                                  │
│                       ↓                                      │
└─────────────────────────────────────────────────────────────┘
                       ↓
        ┌──────────────────────────────────┐
        │     YOUR LAPTOP (Backend Server)  │
        │  ┌────────────────────────────┐   │
        │  │  Node.js Express Server    │   │
        │  │  Running on port 4000      │   │
        │  │                            │   │
        │  │  Routes:                   │   │
        │  │  - POST /auth/register     │   │
        │  │  - POST /auth/login        │   │
        │  │  - GET /pets               │   │
        │  │  - POST /pets              │   │
        │  │  - PUT /pets/:id           │   │
        │  │  - DELETE /pets/:id        │   │
        │  │  - POST /reminders         │   │
        │  │  - GET /dashboard/today    │   │
        │  │  ... and more              │   │
        │  └────────────────────────────┘   │
        │          ↓                         │
        │  ┌────────────────────────────┐   │
        │  │  In-Memory Data Store      │   │
        │  │  (Users, Pets, Reminders)  │   │
        │  └────────────────────────────┘   │
        └──────────────────────────────────┘
```

### Step-by-Step Example: Adding a Pet

1. **User taps "Add Pet" button** in Flutter app
2. **Flutter screen** shows form (name, type, age, breed fields)
3. **User fills form** and taps "Save"
4. **Flutter validates** (name required, type valid, etc.)
5. **If valid**, Flutter makes HTTP POST request:
   ```
   POST http://10.0.2.2:4000/pets
   Header: Authorization: Bearer eyJhbGc...
   Body: {
     "name": "Buddy",
     "type": "dog",
     "age": 3,
     "breed": "Labrador"
   }
   ```
6. **Backend receives** the HTTP request on port 4000
7. **Backend validates** (checks auth token, validates fields)
8. **Backend stores** in memory: `petsById.set(petId, petData)`
9. **Backend responds**:
   ```json
   {
     "data": {
       "id": "uuid-123",
       "name": "Buddy",
       "type": "dog",
       "age": 3,
       "breed": "Labrador",
       "ownerId": "user-456",
       "createdAt": "2026-03-27T17:50:00Z"
     }
   }
   ```
10. **Flutter receives response** and updates UI
11. **Dashboard reloads** and shows "Buddy" in pet list

---

## 3. Where is the Database Stored?

### Current Setup (MVP - Testing Only)

**In-Memory Store** = RAM on your laptop

```
┌─────────────────────────────────────────────┐
│        Node.js Process Memory (RAM)         │
│  ┌─────────────────────────────────────┐    │
│  │  usersById Map:                     │    │
│  │    uuid-1 → {id, email, name, ...}  │    │
│  │    uuid-2 → {id, email, name, ...}  │    │
│  │    uuid-3 → {id, email, name, ...}  │    │
│  ├─────────────────────────────────────┤    │
│  │  petsById Map:                      │    │
│  │    pet-1 → {id, ownerId, name, ...} │    │
│  │    pet-2 → {id, ownerId, name, ...} │    │
│  │    ...                              │    │
│  ├─────────────────────────────────────┤    │
│  │  remindersById Map:                 │    │
│  │    reminder-1 → {...}               │    │
│  │    reminder-2 → {...}               │    │
│  │    ...                              │    │
│  └─────────────────────────────────────┘    │
└─────────────────────────────────────────────┘
     ↓
  LOST when server stops!
```

### Why In-Memory for MVP?

✅ **Good for MVP/Testing**:
- No database setup needed
- Fast (everything in RAM)
- Simple to understand
- Perfect for phase testing

❌ **Bad for Production**:
- Data lost when server restarts
- Not shared across servers
- No persistence
- Limited to available RAM

### When Server Restarts

```
Server starts → seed.json loads → Data resets to seed state
```

**Example**: If you add 10 pets then restart server, you have 0 custom pets (back to seed state).

### Production Database (Phase 4)

When you're ready for real deployment, you'd use:

```
┌──────────────────────────────┐
│   PostgreSQL Database        │
│   (stored on disk)           │
├──────────────────────────────┤
│  /var/lib/postgresql/data/   │
│  - users table               │
│  - pets table                │
│  - reminders table           │
│  - persistent across         │
│    server restarts           │
└──────────────────────────────┘
```

Or in cloud:

```
┌──────────────────────────────┐
│   AWS RDS PostgreSQL         │
│   (or Firebase Firestore)    │
├──────────────────────────────┤
│  - Fully managed             │
│  - Scales automatically      │
│  - Backed up automatically   │
│  - Accessible from anywhere  │
└──────────────────────────────┘
```

---

## 4. Debug APK vs Release APK

### What You Have Now (Debug APK)

```
frontend/build/app/outputs/flutter-apk/app-debug.apk (147 MB)
```

**Debug APK Characteristics**:
- ✅ **Includes debugging symbols** (easier to trace crashes)
- ✅ **Larger file size** (147 MB vs ~50MB release)
- ✅ **Can connect to debugger** (view logs, breakpoints)
- ✅ **Not optimized** (slower startup, more RAM)
- ✅ **Perfect for development/testing**
- ❌ **Cannot publish to Play Store**
- ❌ **Not for end users**

### Release APK (for Production)

To build release (when you're ready):
```bash
cd frontend
flutter build apk --release
# Output: app-release.apk (~50 MB)
```

**Release APK Characteristics**:
- ✅ **Optimized code** (minified, obfuscated)
- ✅ **Smaller file** (~50 MB vs 147 MB)
- ✅ **Faster startup**
- ✅ **Less RAM usage**
- ✅ **Can publish to Play Store**
- ❌ **Harder to debug if crashes occur**

### Current Status

✅ **Debug APK**: Ready for testing and development
- Perfect for your emulator/test device
- Can connect to Android Studio debugger
- Use for QA and bug testing

❌ **Release APK**: Not yet built
- Build when you're ready for App Store submission
- Not needed for Phase 3 testing

---

## 5. Documentation Files in Root

### Current Structure

```
project-pet-care/
├── docs/                    ← Organized docs
│   └── mvp/
│       ├── 01-API_CONTRACT.md
│       ├── backend/02-BACKEND_CHECKLIST.md
│       └── frontend/02-FRONTEND_CHECKLIST.md
│
├── MVP_PROJECT_COMPLETE.md      ← In root (HIGH LEVEL)
├── PHASE_3_INTEGRATION_COMPLETE.md
├── PHASE_2_COMPLETION.md
├── FINAL_VERIFICATION.md
├── PROJECT_CONTEXT.md           ← Unified context (for external tools)
│
├── backend/                 ← Implementation
├── frontend/                ← Implementation
└── README.md               ← Main entry point
```

### Why Documentation in Root?

1. **Quick Access**: MVP docs at top level (you see them first)
2. **Organized**: Detailed docs in `docs/mvp/` (for reference)
3. **Context**: PROJECT_CONTEXT.md is portable (use with other tools)

This is intentional - gives you a **two-tier system**:
- **Tier 1 (Root)**: Quick references & current status
- **Tier 2 (docs/)**: Detailed specs & checklists

---

## 6. Complete Communication Flow (Detailed)

### User Registration Flow

```
Frontend (Flutter)          Backend (Node.js)      Data Store (RAM)
    │                            │                        │
    ├─ User taps Register        │                        │
    │                            │                        │
    ├─ Show form (email,pass)    │                        │
    │                            │                        │
    ├─ User enters data          │                        │
    │                            │                        │
    ├─ Validate locally (email format, password length)   │
    │                            │                        │
    ├─ Valid? Send to backend:   │                        │
    │  POST /auth/register       │                        │
    │  {email, password, name}   │                        │
    │─────────────────────────→  │                        │
    │                            ├─ Validate again       │
    │                            ├─ Hash password        │
    │                            ├─ Generate UUID        │
    │                            ├─ Store user           │
    │                            ├─────────────────→ Save in usersById
    │                            ├─ Generate JWT token   │
    │  Response:                 │                        │
    │  {user, token}             │                        │
    │←─────────────────────────  │                        │
    │                            │                        │
    ├─ Save token securely (flutter_secure_storage)      │
    ├─ Navigate to Dashboard    │                        │
    │                            │                        │
```

### Getting Pet List

```
Frontend (Flutter)          Backend (Node.js)      Data Store (RAM)
    │                            │                        │
    ├─ User navigates to Pets    │                        │
    │                            │                        │
    ├─ Load pets list:           │                        │
    │  GET /pets                 │                        │
    │  Header: Bearer <token>    │                        │
    │─────────────────────────→  │                        │
    │                            ├─ Check token valid     │
    │                            ├─ Get userId from token │
    │                            ├─ Query pets            │
    │                            ├─────────────────→ Look up petsById
    │                            ├─ Filter by userId     │
    │                            ├─ Return list          │
    │  Response:                 │                        │
    │  {data: [{id, name, ...}]} │                        │
    │←─────────────────────────  │                        │
    │                            │                        │
    ├─ Display pets in ListView  │                        │
    │                            │                        │
```

---

## Summary: How It All Works

| Layer | What It Does | Location |
|-------|-------------|----------|
| **UI Layer** | Buttons, forms, screens | Flutter app on your phone/emulator |
| **API Service** | Makes HTTP requests | Flutter HttpApiService class |
| **HTTP** | Sends/receives JSON over internet | Network (internet connection) |
| **Backend Server** | Processes requests, validates | Node.js on port 4000 (your laptop) |
| **Data Store** | Stores users/pets/reminders | RAM (your laptop's memory) |

**Data Flow**: 
UI → API Service → HTTP → Backend → Data Store (and back)

**For Testing**:
- ✅ All on your machine (no cloud needed)
- ✅ Backend on localhost:4000
- ✅ Frontend connects to 10.0.2.2:4000 (Android emulator special IP)
- ✅ Data in RAM (fresh on each restart)

**For Production**:
- Backend → AWS/Heroku (cloud)
- Database → AWS RDS/PostgreSQL (cloud storage)
- Frontend → Google Play Store (user's device)

