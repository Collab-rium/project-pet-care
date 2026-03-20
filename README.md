# Project Pet Care (Puppy)

Manage pets with profiles (name, age, breed, photo), reminders for meals, medicines, baths, and vet visits.

---

## Quick Navigation

### For MVP Planning & Execution (Recommended Start)
- **[MVP Guide](docs/mvp/GUIDE.md)** — High-level navigation of all MVP docs (start here if building the MVP)
- **[MVP Overview](docs/mvp/00-OVERVIEW.md)** — Big picture: features, timeline, checkpoints (5 min read)
- **[API Contract](docs/mvp/01-API_CONTRACT.md)** — Exact API endpoints & data shapes (for both backend & frontend)
- **Backend Tasks**: [Backend Checklist](docs/mvp/backend/02-BACKEND_CHECKLIST.md)
- **Frontend Tasks**: [Frontend Checklist](docs/mvp/frontend/02-FRONTEND_CHECKLIST.md)

### Educational Guides
- **[Firebase Guide](backend/firebase.md)** — What is Firebase, Spark vs Blaze billing, Emulator Suite
- **[Emulator Setup](backend/emulators.md)** — Step-by-step guide to configure local Firebase emulators

### Project Documentation
- **[Project Context](PROJECT_CONTEXT.md)** — Problem statement, goals, scope
- **[Tech Stack](docs/TECH_STACK.md)** — Technologies and frameworks used
- **[Project Log](docs/PROJECT_LOG.md)** — Development history and decisions

---

## Project Structure

```
project-pet-care/
  README.md (you are here)
  PROJECT_CONTEXT.md
  
  backend/
    firebase.md              <- What is Firebase & billing guide
    emulators.md             <- Firebase Emulator setup steps
    config/
    services/
    utils/
    
  frontend/
    lib/
      main.dart
      components/
      screens/
      services/
      styles/
    assets/
    
  docs/
    mvp/                     <- MVP Planning & Execution
      GUIDE.md               <- Start here for MVP
      00-OVERVIEW.md         <- Big picture
      01-API_CONTRACT.md     <- API spec (shared by both teams)
      backend/
        02-BACKEND_CHECKLIST.md
      frontend/
        02-FRONTEND_CHECKLIST.md
    
    PROJECT_LAWS.md
    PROJECT_LOG.md
    TECH_STACK.md
    mvp_plan.md (legacy)
    
  task-reminders/
  testing-feedback/
```

---

## Core Idea

---

## Minimum Requirements for MVP
### Core Features:
1. **Pet Profiles**: Add pet details (name, age, breed, photo).
2. **Reminders**: Set and receive push notifications for meals, medicines, baths, and vet visits.
3. **Dashboard**: View daily tasks. Highlight missed or overdue reminders.
4. **Dynamic Themes**: Automatically adjust app theme based on pet type or uploaded image.

---

## Plan
### Step-by-Step:
1. **Setup**: Initialize Flutter front-end and Firebase backend (authentication, database).
2. **Build Core Features**:
   - Pet Profiles and Reminders.
   - Core functionality of Dashboard with simple missed task handling.
3. **Introduce Dynamic Themes**:
   - Extend UI reactions to uploaded images.

---

## Hurdles and Questions
1. **Open Questions**:
   - How complex should dynamic themes be (basic vs stretch goal)?
   - What design style should the reminders follow (cards, lists, modal alerts)?
2. **Challenges**:
   - Leveraging free tools for dynamic themes and reminders efficiently.
   - Testing Firebase notification limits while on the free tier.

This minimum viable product will focus on achieving these requirements while ensuring zero-cost usage! Further updates will refine components and constraints as needed.

---

## Quick Start (MVP Development)

**New to this project?** Follow these steps:

1. **Read the docs** (15 min total)
   - [MVP Guide](docs/mvp/GUIDE.md) — Where to start
   - [MVP Overview](docs/mvp/00-OVERVIEW.md) — Timeline and checkpoints
   - [API Contract](docs/mvp/01-API_CONTRACT.md) — What backend/frontend will build

2. **Setup Phase 0** (Day 1-2)
   - Backend dev: Follow [Backend Checklist Phase 0](docs/mvp/backend/02-BACKEND_CHECKLIST.md#phase-0-setup-days-1-2)
   - Frontend dev: Follow [Frontend Checklist Phase 0](docs/mvp/frontend/02-FRONTEND_CHECKLIST.md#phase-0-setup-days-1-2)

3. **Develop in parallel** (Day 3-7)
   - Backend: Implement endpoints per API contract
   - Frontend: Build screens with mock API

4. **Integrate** (Day 8-10)
   - Frontend connects to real backend
   - Test end-to-end scenarios

5. **Polish** (Day 11-14)
   - Bug fixes, performance, final QA

**Key files you'll use**:
- Backend: `docs/mvp/backend/02-BACKEND_CHECKLIST.md`
- Frontend: `docs/mvp/frontend/02-FRONTEND_CHECKLIST.md`
- Both: `docs/mvp/01-API_CONTRACT.md` (reference constantly)

**Need help setting up Firebase emulators?** See [Emulator Setup](backend/emulators.md)

---

## Support & Resources

- **Firebase Questions?** → [Firebase Guide](backend/firebase.md)
- **Emulator Issues?** → [Emulator Setup](backend/emulators.md)
- **API Unclear?** → [API Contract](docs/mvp/01-API_CONTRACT.md)
- **Timeline/Checkpoints?** → [MVP Overview](docs/mvp/00-OVERVIEW.md)
- **Lost or confused?** → Start with [MVP Guide](docs/mvp/GUIDE.md)