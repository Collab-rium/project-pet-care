# Backend Implementation Checklist — Project Pet Care MVP

**For**: Backend Developer  
**What**: Build REST API endpoints for pet care app  
**Timeline**: Days 1-10 (Phase 0-3)

---

## Table of Contents

1. [Phase 0: Setup](#phase-0-setup-days-1-2)
2. [Phase 1: Endpoints](#phase-1-backend-endpoints-days-3-7)
3. [Phase 2: Unit Tests](#phase-1-backend-endpoints-days-3-7)
4. [Phase 3: Integration](#phase-3-integration-testing-days-8-10)
5. [Checkpoint Summary](#checkpoints)

---

## Phase 0: Setup (Days 1-2)

### Prerequisites

- [x] Node 18+ installed
- [x] npm installed
- [x] Firebase CLI installed globally: `npm install -g firebase-tools`
- [x] Verify: `firebase --version` outputs v11+

### Initialize Firebase Emulators

- [x] Navigate to `backend/` directory
- [x] Run: `firebase init emulators`
  - Select: **Authentication**, **Firestore**, **Storage** (check these boxes)
  - Select: "Don't set up a default project"
  - Accept defaults for ports and rules files
- [x] Verify `firebase.json` created in `backend/`
- [x] **Checkpoint**: Firebase emulator config ready

Completed on March 24, 2026:
- Config written to `backend/firebase.json`
- Emulator UI enabled
- Auth, Firestore, Storage emulators selected

### Create package.json

- [x] Create `backend/package.json`:
  ```json
  {
    "name": "pet-care-backend",
    "version": "0.1.0",
    "scripts": {
      "start": "node index.js",
      "test": "jest"
    },
    "dependencies": {
      "express": "^4.18.2",
      "cors": "^2.8.5",
      "uuid": "^9.0.0",
      "dotenv": "^16.0.3"
    },
    "devDependencies": {
      "jest": "^29.5.0"
    }
  }
  ```
- [x] Run `npm install`
- [x] **Checkpoint**: Dependencies installed

### Environment Setup

- [x] Create `backend/.env.example`:
  ```
  PORT=4000
  FIRESTORE_EMULATOR_HOST=localhost:8080
  FIREBASE_AUTH_EMULATOR_HOST=localhost:9099
  # Secret used to sign JWTs for local dev (do NOT commit real secrets)
  JWT_SECRET=change_me_to_a_random_value
  ```
- [x] Create `backend/.env` (copy from example, use these values)
- [x] Add `.env` to `.gitignore`
- [ ] Set a strong local `JWT_SECRET` in `backend/.env` and restart backend

### API Contract Review

- [x] Open `docs/mvp/01-API_CONTRACT.md`
- [x] Read all endpoint signatures, request/response shapes, error codes
- [x] Flag any unclear specifications (discuss with frontend dev)
- [x] **Sign off**: You understand and agree to implement all endpoints as specified

---

## Phase 1: Backend Endpoints (Days 3-7)

### Health Check Endpoint

- [x] Implement `GET /health`
  - Returns: `{ ok: true, uptime: <seconds>, timestamp: <ISO-string> }`
  - No authentication required
  - Always available
- [x] Test locally: `curl http://localhost:4000/health`
- [x] **Pass Criteria**: Returns 200 with correct JSON

### Authentication (Simplified in-memory for MVP)

**Note**: Using in-memory store for MVP. Will switch to Firebase Auth later.

- [x] Create in-memory user store (simple object or Map)
- [x] Implement `POST /auth/register`
  - Accept: `{ email, password, name }`
  - Return: `{ user: { id, email, name, createdAt }, token: "..." }`
  - Validate: email unique, password required
  - Error: 400 if email exists, 400 if password/email missing
- [x] Implement `POST /auth/login`
  - Accept: `{ email, password }`
  - Return: `{ user: { id, email, name, createdAt }, token: "..." }`
  - Validate: correct email/password
  - Error: 401 if invalid credentials
- [x] Create auth middleware for protected routes
  - Checks `Authorization: Bearer <jwt>` header
  - Verifies JWT signature and extracts userId from JWT `sub`
  - Allows middleware to pass userId to route handlers
  - Error: 401 if token missing or invalid
- [x] Add auth edge-case validation hardening
  - Register: invalid email format rejected
  - Register: empty/whitespace-only name rejected
  - Register/Login: max length guards on email/password/name
  - Register: password strength rule (at least one letter and one number)
  - Auth responses use consistent error shape: `{ error, message }`
- [x] Test:
  ```bash
  # Register
  curl -X POST http://localhost:4000/auth/register \
    -H "Content-Type: application/json" \
    -d '{"email":"test@example.com","password":"test123","name":"Tester"}'

  # Save JWT from response
  TOKEN="eyJ..."  # JWT string

  # Login
  curl -X POST http://localhost:4000/auth/login \
    -H "Content-Type: application/json" \
    -d '{"email":"test@example.com","password":"test123"}'

  # Test protected route with token
  curl -H "Authorization: Bearer $TOKEN" http://localhost:4000/pets
  ```
- [x] **Pass Criteria**: Register creates user, login returns token, protected routes reject without token

### Pet Endpoints

- [ ] Create in-memory pet store (simple object or Map)
- [ ] Implement `GET /pets` (list pets)
  - Filter by userId from token (authenticated only)
  - Return: `{ data: [ { id, name, type, age, breed, photoUrl, createdAt } ] }`
  - Error: 401 if unauthenticated
- [ ] Implement `POST /pets` (create pet)
  - Accept: `{ name, type, age, breed }`
  - Set userId from token, generate id (UUID), set timestamps
  - Return: `{ data: { id, name, type, age, breed, photoUrl: null, createdAt } }`
  - Error: 400 if name/type missing, 401 if unauthenticated
- [ ] Implement `GET /pets/:id` (get single pet)
  - Validate user owns pet (compare userId in token with pet.ownerId)
  - Return: `{ data: { id, name, type, age, breed, photoUrl, createdAt } }`
  - Error: 404 if pet not found, 403 if user doesn't own pet
- [ ] Implement `PUT /pets/:id` (update pet)
  - Accept: partial object (e.g., `{ name: "..." }`)
  - Allow all fields to be optional
  - Return: updated pet
  - Error: 404, 403 as above
- [ ] Implement `DELETE /pets/:id` (delete pet)
  - Remove pet from store
  - Return: `{ message: "Pet deleted successfully" }`
  - Error: 404, 403 as above
- [ ] Implement `POST /pets/:id/photo` (upload photo)
  - Accept: multipart form data with `photo` field (image file)
  - Save to `backend/uploads/` folder
  - Update pet.photoUrl to file path or URL
  - Return: updated pet with photoUrl
  - Error: 400 if no file, 404/403 as above
- [ ] Test:
  ```bash
  # List pets
  curl -H "Authorization: Bearer $TOKEN" http://localhost:4000/pets
  
  # Create pet
  curl -X POST http://localhost:4000/pets \
    -H "Authorization: Bearer $TOKEN" \
    -H "Content-Type: application/json" \
    -d '{"name":"Buddy","type":"dog","age":3,"breed":"Golden"}'
  
  # Update pet
  curl -X PUT http://localhost:4000/pets/pet-id \
    -H "Authorization: Bearer $TOKEN" \
    -H "Content-Type: application/json" \
    -d '{"age":4}'
  
  # Delete pet
  curl -X DELETE http://localhost:4000/pets/pet-id \
    -H "Authorization: Bearer $TOKEN"
  ```
- [ ] **Pass Criteria**: All CRUD operations work; auth checks enforced; correct error codes

### Reminder Endpoints

- [ ] Create in-memory reminder store
- [ ] Implement `GET /reminders` (list reminders)
  - Optional filter: `?petId=...`
  - Return: `{ data: [ { id, petId, userId, type, message, scheduledTime, repeat, status, createdAt } ] }`
  - Error: 401 if unauthenticated
- [ ] Implement `POST /reminders` (create reminder)
  - Accept: `{ petId, type, message, scheduledTime, repeat }`
  - Set userId from token, generate id, set timestamps, status = "pending"
  - Validate: pet exists and user owns it
  - Return: created reminder
  - Error: 400 if required fields missing, 404 if pet not found
- [ ] Implement `GET /reminders/:id`
  - Validate user owns reminder
  - Return: reminder
  - Error: 404, 403
- [ ] Implement `PUT /reminders/:id` (update reminder)
  - Allow all fields to be optional (for marking complete via `status: "completed"`)
  - Return: updated reminder
  - Error: 404, 403
- [ ] Implement `DELETE /reminders/:id`
  - Return: `{ message: "Reminder deleted successfully" }`
  - Error: 404, 403
- [ ] Test similar to pet endpoints
- [ ] **Pass Criteria**: All CRUD operations work; ownership checks work

### Dashboard Endpoint

- [ ] Implement `GET /dashboard/today`
  - Query reminders for today's date (based on scheduledTime)
  - Calculate for each reminder: `isOverdue = (scheduledTime < now)`
  - Return:
    ```json
    {
      "data": {
        "date": "2026-03-20",
        "tasks": [ { id, petId, message, scheduledTime, isOverdue, status } ],
        "summary": {
          "total": 5,
          "completed": 2,
          "pending": 2,
          "overdue": 1
        }
      }
    }
    ```
  - Error: 401 if unauthenticated
- [ ] Test:
  ```bash
  curl -H "Authorization: Bearer $TOKEN" \
    http://localhost:4000/dashboard/today
  ```
- [ ] **Pass Criteria**: Returns correct task counts; overdue detection accurate

### Seed Data

- [ ] Create `backend/data/seed.json`:
  ```json
  {
    "users": [
      {
        "id": "user-1",
        "email": "test@example.com",
        "password": "test123",
        "name": "Test User",
        "createdAt": "2026-03-20T00:00:00Z"
      }
    ],
    "pets": [
      {
        "id": "pet-1",
        "ownerId": "user-1",
        "name": "Buddy",
        "type": "dog",
        "age": 3,
        "breed": "Golden Retriever",
        "photoUrl": null,
        "createdAt": "2026-03-20T00:00:00Z"
      }
    ],
    "reminders": [
      {
        "id": "rem-1",
        "petId": "pet-1",
        "userId": "user-1",
        "type": "feeding",
        "message": "Feed Buddy",
        "scheduledTime": "2026-03-20T08:00:00Z",
        "repeat": "daily",
        "status": "pending",
        "createdAt": "2026-03-20T00:00:00Z"
      }
    ]
  }
  ```
- [ ] Load seed data on server startup
- [ ] **Pass Criteria**: Seed data populated; API returns seed data

### Unit Tests

- [ ] Install jest: `npm install jest`
- [ ] Create `backend/tests/auth.test.js` (test register, login, token validation)
- [ ] Create `backend/tests/pets.test.js` (test all pet endpoints)
- [ ] Create `backend/tests/reminders.test.js` (test all reminder endpoints)
- [ ] Create `backend/tests/dashboard.test.js` (test dashboard, overdue detection)
- [ ] Run tests: `npm test`
- [ ] **Pass Criteria**: All tests pass; coverage >= 80%

### Server Startup

- [ ] Create `backend/index.js`:
  - Initialize Express app
  - Set up CORS (allow frontend origin)
  - Load seed data on startup
  - Register all route handlers
  - Start server on PORT from .env
- [ ] Test startup: `npm start`
- [ ] Verify: `curl http://localhost:4000/health` returns ok

### Documentation

- [ ] Add inline comments to code
- [ ] Create `backend/README.md`:
  ```markdown
  # Pet Care Backend
  
  ## Setup
  - `npm install`
  - `firebase init emulators` (select Auth, Firestore, Storage)
  - Create `.env` from `.env.example`
  
  ## Running
  - Terminal 1: `firebase emulators:start`
  - Terminal 2: `npm start`
  
  ## Testing
  - `npm test`
  
  ## API Reference
  - See `docs/mvp/01-API_CONTRACT.md`
  ```

### Checkpoint 2: Backend Endpoints Ready

- [ ] Server starts: `npm start` (no errors)
- [ ] Health check responds: `curl http://localhost:4000/health` → 200
- [ ] All endpoints implemented per `01-API_CONTRACT.md`
- [ ] Auth token validation working on protected routes
- [ ] Seed data loads on startup
- [ ] Unit tests pass: `npm test`
- [ ] Ready for frontend integration

---

## Phase 2: (Happens in parallel with frontend work)

**Frontend team** is building screens with mock API while you refine endpoints.

- [ ] Monitor GitHub issues (if frontend team opens issues)
- [ ] Be available for clarifications on API contract
- [ ] Make small fixes if endpoints don't match contract

---

## Phase 3: Integration Testing (Days 8-10)

### Full Local Stack Startup

- [ ] Terminal 1: Start emulators
  ```bash
  cd backend
  firebase emulators:start
  ```
- [ ] Terminal 2: Start backend
  ```bash
  cd backend
  npm start
  ```
- [ ] Verify: `curl http://localhost:4000/health` → 200 ok=true
- [ ] Verify: Emulator UI at http://localhost:4000/firestore (accessible)

### End-to-End Test Scenarios

**Scenario A: User Registration & Login**
- [ ] Frontend registers user via form
- [ ] Backend creates user in memory
- [ ] Frontend receives token
- [ ] Frontend logs in with same credentials
- [ ] Pass: Dashboard loads without errors

**Scenario B: Pet CRUD**
- [ ] Frontend creates pet "Buddy"
- [ ] Backend stores pet with ownerId from token
- [ ] Frontend lists pets, sees Buddy
- [ ] Frontend edits Buddy's age
- [ ] Backend updates pet
- [ ] Frontend lists pets again, sees updated age
- [ ] Pass: All operations successful

**Scenario C: Reminders & Dashboard**
- [ ] Frontend creates reminder "Feed Buddy" at 8am
- [ ] Frontend creates reminder "Bath" at 6pm (but scheduledTime = yesterday)
- [ ] Frontend views dashboard
- [ ] Dashboard shows both reminders
- [ ] Bath reminder marked as isOverdue = true
- [ ] Pass: Dashboard counts correct, overdue detection works

**Scenario D: Photo Upload**
- [ ] Frontend picks image from device
- [ ] Posts to `/pets/:id/photo` as multipart form
- [ ] Backend saves photo to uploads folder
- [ ] Backend returns pet with photoUrl set
- [ ] Frontend displays photo on pet card
- [ ] Pass: Photo uploaded, displayed, and persists

**Scenario E: Error Handling**
- [ ] Frontend tries to create pet without name
- [ ] Backend returns 400 error
- [ ] Frontend displays human-readable error message
- [ ] Pass: Error handled gracefully
- [ ] Stop backend server
- [ ] Frontend tries to load pets
- [ ] Frontend displays "offline" or "network error" message
- [ ] Pass: Network error handled

### Bug Fixes & Refinement

- [ ] Review test output for failures
- [ ] Fix any endpoint mismatches with contract
- [ ] Fix any CORS issues
- [ ] Optimize database queries if slow
- [ ] Test with seed data + lots of new records (stress test)

### Checkpoint 3: Full Stack Integration Complete

- [ ] Stack runs locally (emulators + backend + frontend working together)
- [ ] All endpoints working with real frontend
- [ ] No CORS, auth, or data mismatch errors
- [ ] End-to-end scenarios pass
- [ ] Performance acceptable (responses < 200ms)
- [ ] Ready for final QA

---

## Checkpoints Summary

| Checkpoint | Timing | Criteria |
|-----------|--------|----------|
| 1 (Setup) | Day 2 | Firebase emulators config, npm install, .env ready |
| 2 (Endpoints) | Day 7 | All endpoints working, tests pass, server starts |
| 3 (Integration) | Day 10 | Full stack working with frontend, end-to-end scenarios pass |

---

## Quick Reference

**Most important files**:
- `docs/mvp/01-API_CONTRACT.md` — Your spec (read often)
- `backend/package.json` — Your dependencies
- `backend/index.js` — Your Express server
- `backend/.env` — Your config (don't commit)
- `backend/README.md` — Setup for next developer

**Key commands**:
- `firebase emulators:start` — Start Firebase services
- `npm start` — Start backend server
- `npm test` — Run unit tests
- `curl http://localhost:4000/health` — Test server
