# MVP Documentation Guide — Project Pet Care

**Welcome!** This folder contains the complete plan for building the Pet Care MVP. This guide explains what each file is and how to use them.

---

## Folder Structure

```
docs/mvp/
  GUIDE.md                          <- START HERE (you are here)
  
  00-OVERVIEW.md                    <- For EVERYONE: Big picture, timeline, features
  01-API_CONTRACT.md                <- For EVERYONE: Exact API endpoints & data shapes
  
  backend/
    02-BACKEND_CHECKLIST.md         <- For BACKEND DEV: Tasks, checkpoints, endpoints
    
  frontend/
    02-FRONTEND_CHECKLIST.md        <- For FRONTEND DEV: Tasks, checkpoints, screens
```

---

## Quick Navigation

### I'm the Backend Developer
1. Start here: [01-API_CONTRACT.md](01-API_CONTRACT.md) — Read endpoint specs (30 min)
2. Then: Read [backend/02-BACKEND_CHECKLIST.md](backend/02-BACKEND_CHECKLIST.md) (60 min)
3. Start coding Phase 0 (Setup) on **Day 1**

### I'm the Frontend Developer
1. Start here: [01-API_CONTRACT.md](01-API_CONTRACT.md) — Understand API shapes (30 min)
2. Then: Read [frontend/02-FRONTEND_CHECKLIST.md](frontend/02-FRONTEND_CHECKLIST.md) (60 min)
3. Start coding Phase 0 (Setup) on **Day 1**

### I'm the Product Owner / Stakeholder
1. Read [00-OVERVIEW.md](00-OVERVIEW.md) — Features, timeline, checkpoints (15 min)
2. Reference as needed for progress updates

### I'm New to the Project
1. Read [00-OVERVIEW.md](00-OVERVIEW.md) first — Get the big picture
2. Read this guide you're reading now
3. Then dive into your role's checklist (backend or frontend)

---

## File Descriptions

### 00-OVERVIEW.md

**What**: High-level MVP plan  
**For**: Everyone  
**Length**: 10 min read  
**Topics**:
- MVP features (Auth, Pets, Reminders, Dashboard)
- Why we're doing this (business goals)
- Team structure (who does what)
- Timeline: 2-4 weeks, 5 checkpoints
- Quick start commands
- Tech stack recap

**When to read**: First thing, to understand the vision  
**When to reference**: Weekly checkpoints, to track progress

**Key takeaway**: 
> We're building a pet management app for one user to manage multiple pets' reminders. Both teams work independently using an API contract, then integrate at the end.

---

### 01-API_CONTRACT.md

**What**: The rulebook for how backend and frontend communicate  
**For**: Both backend and frontend developers (equally important for both)  
**Length**: 20 min read (but you'll reference it constantly)  
**Topics**:
- All REST API endpoints (URLs, HTTP methods)
- Request JSON shapes (what data to send)
- Response JSON shapes (what data you'll receive)
- HTTP error codes (401, 404, 500, etc.)
- Auth header format (`Authorization: Bearer <token>`)
- CORS setup
- Data models (User, Pet, Reminder, Task)

**When to read**:
- Day 1-2: Read all endpoints and understand the spec
- During coding: Reference constantly when writing endpoints (backend) or calling endpoints (frontend)

**Important**: If endpoint behavior is unclear, clarify with your team before building. Don't guess.

**Example**:
```json
Backend implements:   POST /pets { name, type, age, breed }
Frontend expects:     { data: { id, name, type, age, breed, photoUrl, createdAt } }
```

---

### backend/02-BACKEND_CHECKLIST.md

**What**: Step-by-step backend implementation checklist  
**For**: Backend developer ONLY  
**Length**: Detailed reference (not a quick read)  
**Sections**:
- Phase 0: Setup (Days 1-2) — Firebase emulators, npm packages, .env
- Phase 1: Endpoints (Days 3-7) — Auth, Pet CRUD, Reminder CRUD, Dashboard
- Phase 3: Integration (Days 8-10) — Test with real frontend

**How to use**:
1. Check off items as you complete them
2. Each section has pass/fail criteria
3. Check the Checkpoint Summary table for deliverables

**Expected timeline**: 10 days (Days 1-10)  
**Checkpoint 2 (by Day 7)**: All endpoints built and tested  
**Checkpoint 3 (by Day 10)**: Full-stack working with frontend

---

### frontend/02-FRONTEND_CHECKLIST.md

**What**: Step-by-step frontend implementation checklist  
**For**: Frontend developer ONLY  
**Length**: Detailed reference (not a quick read)  
**Sections**:
- Phase 0: Setup (Days 1-2) — Flutter projects, folders, pubspec.yaml
- Phase 1: Screens (Days 3-7) — Auth screens, Pet screens, Dashboard, Mock API
- Phase 3: Integration (Days 8-10) — Switch from mock API → real backend

**How to use**:
1. Check off items as you complete them
2. Each section has pass/fail criteria
3. Mock API service is the key to working in parallel with backend

**Expected timeline**: 10 days (Days 1-10)  
**Checkpoint 2 (by Day 7)**: All screens built, mock API ready, tests pass  
**Checkpoint 3 (by Day 10)**: Real backend connected, end-to-end works

---

## Timeline Overview (2-4 Weeks)

```
Days 1-2:  BOTH teams: Setup (Firebase emulators, Flutter, Node.js, .env)
            Sign off on API contract

Days 3-7:  PARALLEL work:
            Backend: Build all endpoints
            Frontend: Build all screens with MOCK API
            
Days 8-10: INTEGRATION:
            Frontend: Switch from mock → real backend
            End-to-end testing
            Bug fixes
            
Days 11-14: REFINEMENT:
            Polish UI
            Performance optimization
            Final QA
            Handoff ready

Checkpoint Verification (weekly):
- Day 7:   Backend endpoints done, Frontend screens done
- Day 10:  Full stack integrated, no critical bugs
- Day 14:  MVP ready for release
```

---

## Checkpoints (5 Total)

| # | Day | Checkpoint | Criteria |
|---|-----|-----------|----------|
| 1 | 2 | Setup Complete | Emulators running, Flutter project ready, npm install done |
| 2 | 7 | Backend & Frontend Ready | All endpoints built, all screens built with mock API, tests passing |
| 3 | 10 | Integration Complete | Real backend + frontend working together, E2E scenarios passing |
| 4 | 14 | MVP Polished | No crashes, all error handling working, performance good |
| 5 | 14 | Ready for Release | Code committed, docs updated, new dev can build from scratch |

---

## What Each Developer Does

### Backend Developer

**Building**:
- Express.js server with REST endpoints
- Auth (register, login, token validation)
- Pet CRUD (create, read, update, delete)
- Reminder CRUD
- Dashboard endpoint (today's tasks)
- Unit tests
- Seed data for testing

**Using**:
- Node.js 18+
- Express 4.18+
- Firebase Emulator Suite (local Firestore, Auth, Storage)
- In-memory data store (MVP only; will move to Firestore later)

**Timeline**: Days 1-10  
**Check off**: [backend/02-BACKEND_CHECKLIST.md](backend/02-BACKEND_CHECKLIST.md)

### Frontend Developer

**Building**:
- Flutter app with 4 main screens (Dashboard, Pet List, Reminders, Auth)
- Mock API service (fake data matching contract)
- Real HTTP API service (switch to this after backend ready)
- Navigation & routing
- Auth flow (register, login, logout)
- Dynamic themes
- Widget tests

**Using**:
- Flutter 3.x
- Dart 2.17+
- dart http package (for calling backend API)
- Mock data (first 7 days), then real backend API (last 3 days)

**Timeline**: Days 1-10  
**Check off**: [frontend/02-FRONTEND_CHECKLIST.md](frontend/02-FRONTEND_CHECKLIST.md)

---

## How They Synchronize (Without Blocking Each Other)

**The API contract is the bridge.**

```
Backend Dev (independent):
  - Reads 01-API_CONTRACT.md
  - Implements endpoints exactly as specified
  - Tests with curl or Postman
  - [No dependency on frontend]

Frontend Dev (independent):
  - Reads 01-API_CONTRACT.md
  - Creates mock API that matches contract
  - Builds UI screens using mock data
  - Tests all screens
  - [No dependency on backend being done]

Integration (Days 8-10):
  - Frontend flips a config flag: USE_MOCK_API = false
  - Frontend now calls real backend instead of mock
  - Both run together, test E2E scenarios
  - Fix any mismatches
  - Done!
```

**Key**: Both teams read the same contract. Backend implements it. Frontend consumes it (via mock first, then real). No surprises at integration.

---

## Critical Files (Bookmark These)

🔗 **For Backend Dev**:
- [01-API_CONTRACT.md](01-API_CONTRACT.md) — Reference constantly
- [backend/02-BACKEND_CHECKLIST.md](backend/02-BACKEND_CHECKLIST.md) — Your task list

🔗 **For Frontend Dev**:
- [01-API_CONTRACT.md](01-API_CONTRACT.md) — Reference constantly  
- [frontend/02-FRONTEND_CHECKLIST.md](frontend/02-FRONTEND_CHECKLIST.md) — Your task list

🔗 **For Everyone**:
- [00-OVERVIEW.md](00-OVERVIEW.md) — Big picture
- This file (GUIDE.md) — Navigation

---

## Question: Which file should I read?

**"I want to know what we're building"** → [00-OVERVIEW.md](00-OVERVIEW.md)

**"I need to know the exact API endpoint for users"** → [01-API_CONTRACT.md](01-API_CONTRACT.md)

**"I'm the backend dev and need tasks"** → [backend/02-BACKEND_CHECKLIST.md](backend/02-BACKEND_CHECKLIST.md)

**"I'm the frontend dev and need tasks"** → [frontend/02-FRONTEND_CHECKLIST.md](frontend/02-FRONTEND_CHECKLIST.md)

**"I'm lost and don't know where to start"** → You're reading it (GUIDE.md), good! Then read [00-OVERVIEW.md](00-OVERVIEW.md) next.

---

## Success Criteria (How do we know it's done?)

**MVP is done when**:
1. All checkboxes in your checklist are checked
2. No critical bugs
3. All E2E scenarios pass (from [01-API_CONTRACT.md](01-API_CONTRACT.md))
4. Performance acceptable (responses < 200ms, no crashes)
5. Code committed to git
6. New developer can build from scratch following README

---

## If You Get Stuck

**Backend issue?** Check [backend/02-BACKEND_CHECKLIST.md](backend/02-BACKEND_CHECKLIST.md) troubleshooting section or reference [../backend/emulators.md](../backend/emulators.md)

**Frontend issue?** Check [frontend/02-FRONTEND_CHECKLIST.md](frontend/02-FRONTEND_CHECKLIST.md) or reference [../backend/firebase.md](../backend/firebase.md)

**API contract unclear?** Ask the other developer, update [01-API_CONTRACT.md](01-API_CONTRACT.md), and notify the team

---

## Checklist: Are You Ready to Start?

- [ ] I've read [00-OVERVIEW.md](00-OVERVIEW.md)
- [ ] I've read [01-API_CONTRACT.md](01-API_CONTRACT.md)
- [ ] I've read my role's checklist ([backend/02-BACKEND_CHECKLIST.md](backend/02-BACKEND_CHECKLIST.md) or [frontend/02-FRONTEND_CHECKLIST.md](frontend/02-FRONTEND_CHECKLIST.md))
- [ ] I understand the timeline (14 days, 5 checkpoints)
- [ ] I understand my tasks (Phase 0: Setup)
- [ ] I have all tools installed (Node/npm or Flutter/Dart)

**If all checked**: You're ready! Start Phase 0 on your checklist.

---

**Last Updated**: March 20, 2026  
**Status**: Ready for implementation
