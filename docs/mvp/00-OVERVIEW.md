# Project Pet Care — MVP Overview

## Project Summary

**Project Pet Care** is a Flutter mobile app that helps pet owners manage their pets through profiles, reminders, and a dashboard. The app runs on Firebase for authentication, data storage, and file uploads.

**MVP Scope**: Core pet management with reminders and a functional dashboard.

---

## MVP Features (Must Have)

1. **Authentication** — User registration and login (mock or Firebase Auth)
2. **Pet Profiles** — Add, edit, delete pets with name, age, breed, photo
3. **Reminders System** — Create reminders for feeding, medicine, baths, vet visits
4. **Dashboard** — View today's tasks, highlight missed reminders
5. **Dynamic Themes** — App theme adapts to pet type or dominant image color

---

## Why Authentication for MVP?

- **User Isolation**: Without auth, all users see all pets. Auth ties pets to owners.
- **Foundation**: Auth is needed for multi-user support (even if you mock it initially, keep the endpoints auth-aware so switching to real Firebase Auth later is seamless).
- **Data Security**: Firebase rules protect user data; auth is the gatekeeping mechanism.
- **Simple to Mock**: Frontend can mock auth locally without a real backend.

---

## Architecture

- **Backend**: Node/Express server running locally (eventually replaced by Firebase Cloud Functions or kept as middleware)
- **Firebase Services**: Firestore (database), Auth (user login), Storage (pet photos), Emulators (local dev)
- **Frontend**: Flutter app communicating with backend via REST API
- **Isolation Strategy**: Backend exposes REST endpoints; frontend uses mock API service during dev, switches to real backend at integration

---

## Timeline (Estimated)

| Phase | Duration | Deliverable |
|-------|----------|-------------|
| Setup & Planning | 1–2 days | Emulator setup, backend scaffold, API contract finalized |
| Backend Development | 5–7 days | Endpoints, seed data, tests passing |
| Frontend Development | 5–7 days | Screens, mock API integration, UI working locally |
| Integration & Testing | 2–3 days | Full-stack test, emulators connected, bug fixes |
| Refinement & Deploy | 2–3 days | Performance tuning, final QA, MVP ready |

**Total**: 2–4 weeks depending on team size and experience.

---

## Team Responsibilities

### Backend Developer
- Initialize Firebase Emulator Suite (Firestore, Auth, Storage)
- Create Node/Express server with REST endpoints (CRUD for pets, reminders, auth)
- Seed initial test data (`backend/data/seed.json`)
- Write unit tests for endpoints
- Document API contract in `01-API_CONTRACT.md`
- Provide running local server for frontend integration

### Frontend Developer
- Create Flutter screens (login, pet list, add pet, reminders, dashboard)
- Implement mock API service that matches backend contract
- Build navigation and routing
- Integrate theme system (dynamic color detection)
- Write unit tests for UI components
- At integration: switch mock API to real backend URL, test end-to-end

---

## Checkpoints & Verification

### Checkpoint 1: Setup Complete (Day 1-2)
- [ ] Backend: Firebase CLI installed, emulators initialized, `firebase.json` created
- [ ] Backend: `package.json` created with Express dependencies
- [ ] Frontend: `pubspec.yaml` created with Firebase dependencies
- [ ] API Contract: `01-API_CONTRACT.md` finalized and agreed by both teams

### Checkpoint 2: Endpoints Working (Day 5-7)
- [ ] Backend: `GET /health` returns `{ ok: true }`
- [ ] Backend: `/pets`, `/reminders`, `/auth` endpoints implemented
- [ ] Backend: Seed data loaded; unit tests passing
- [ ] Emulators UI (http://localhost:4000) shows test data in Firestore

### Checkpoint 3: Frontend Integrated (Day 10-12)
- [ ] Frontend: Auth screen works with mock login
- [ ] Frontend: Pet list screen shows mock pets from local data
- [ ] Frontend: Create pet form submits (mock)
- [ ] Frontend: Reminders screen displays mock reminders
- [ ] Frontend: Dashboard shows today's tasks

### Checkpoint 4: Full Stack Connected (Day 14-16)
- [ ] Backend + Emulators running
- [ ] Frontend points to backend at `http://localhost:4000` (or `10.0.2.2:4000` on Android)
- [ ] Create pet → saves to Firestore emulator
- [ ] Retrieve pet → shows data from emulator
- [ ] No CORS errors, no auth token errors

### Checkpoint 5: MVP Ready (Day 18-21)
- [ ] All features working end-to-end
- [ ] Bug-free on test device/emulator
- [ ] Themes switch correctly based on pet type
- [ ] Reminders appear on dashboard
- [ ] Ready for user testing or deployment

---

## Tech Stack

| Layer | Tech | Version |
|-------|------|---------|
| Frontend | Flutter | 3.x+ |
| Frontend Language | Dart | 2.17+ |
| Backend | Node.js | 18+ |
| Backend Framework | Express | 4.18+ |
| Database | Firestore (emulated locally) | — |
| Auth | Firebase Auth (emulated locally) | — |
| Storage | Firebase Storage (emulated locally) | — |
| Local Dev | Firebase Emulator Suite | 11.x+ |

---

## Quick Start (Commands)

### Backend Setup
```bash
cd backend
npm install
firebase init emulators
# select: Authentication, Firestore, Storage
firebase emulators:start
```

### Backend Server (in another terminal)
```bash
cd backend
npm start
# should log: "Backend listening on http://localhost:4000"
```

### Frontend Setup
```bash
cd frontend
flutter pub get
flutter run
# on Android emulator use 10.0.2.2:4000 to reach backend
```

---

## Files to Read Next

1. **`01-API_CONTRACT.md`** — Exact endpoints, request/response formats, error codes
2. **`02-IMPLEMENTATION_CHECKLIST.md`** — Detailed backend and frontend task lists, testing criteria

---

## Known Limitations & Notes

- **Reminders**: MVP will store reminders; push notifications are stretch goal (Firebase Cloud Messaging)
- **Photo Upload**: MVP supports upload to local Storage emulator; real Firebase Storage for prod
- **Theme Detection**: Basic color detection from image; advanced ML-based detection is stretch goal
- **Offline**: MVP assumes online; offline support is post-MVP
- **Sync**: Data syncs immediately; conflict resolution is post-MVP

---

## Questions & Escalation

- API question? Check `01-API_CONTRACT.md`
- Task unclear? Check `02-IMPLEMENTATION_CHECKLIST.md`
- Emulator not starting? Check `backend/emulators.md`
- Firebase config? Check `backend/firebase.md`

---

**Status**: Draft (awaiting team approval)
**Last Updated**: March 20, 2026
