# Data Flow Visualization - How Backend & Frontend Communicate

## 🔴 QUICK ANSWER

**Backend = Server running on YOUR laptop (port 4000)**  
**Frontend = App running on emulator/device**  
**They talk via HTTP** (like websites do)  
**Data stored = IN YOUR LAPTOP'S RAM** (temporary - resets on restart)

---

## Step 1: What Happens When You Start Development

```
STEP 1: Terminal 1 - Start Backend
$ cd backend && npm start
Server running on http://localhost:4000 ✓

STEP 2: Terminal 2 - Run Frontend
$ cd frontend && flutter run
App launches on emulator/device ✓

STEP 3: Emulator/Device connects to Server
Mobile Phone/Emulator → Network → Your Laptop
Uses IP 10.0.2.2:4000 (special emulator IP for localhost)
```

---

## Step 2: Authentication Flow

### User Registers

```
FRONTEND (Flutter App)          BACKEND (Node.js Server)
─────────────────────────────   ─────────────────────────

User clicks "Register"
    ↓
Shows form                      
(email, password, name)         
    ↓
User fills: 
- email: test@example.com
- password: MyPass123
- name: John                    
    ↓
Taps "Sign Up"
    ↓
Validates locally:
- Email format valid? ✓
- Password 6+ chars? ✓         
- Name not empty? ✓
    ↓
Sends HTTP POST:
┌─────────────────────────────────────────────┐
│ POST http://10.0.2.2:4000/auth/register    │
│                                             │
│ {                                           │
│   "email": "test@example.com",             │
│   "password": "MyPass123",                 │
│   "name": "John"                           │
│ }                                           │
└─────────────────────────────────────────────┘
    ↓ (over network)
                                Backend receives ↓
                                
                                Validates again:
                                - Email format? ✓
                                - Password strong? ✓
                                - Email unique? ✓
                                
                                ↓
                                Hashes password:
                                "MyPass123" → "bcrypt_hash_..."
                                
                                ↓
                                Creates user ID:
                                "uuid-1234-5678"
                                
                                ↓
                                Stores in RAM:
                                usersById.set(
                                  "uuid-1234",
                                  {
                                    id: "uuid-1234",
                                    email: "test@example.com",
                                    password: "bcrypt_hash_...",
                                    name: "John",
                                    createdAt: "2026-03-27..."
                                  }
                                )
                                
                                ↓
                                Generates JWT Token:
                                "eyJhbGciOiJIUzI1NiIs..."
                                (7-day expiry)
                                
                                ↓
                                Sends Response:
┌─────────────────────────────────────────────┐
│ 201 Created                                 │
│                                             │
│ {                                           │
│   "user": {                                │
│     "id": "uuid-1234-5678",                │
│     "email": "test@example.com",           │
│     "name": "John",                        │
│     "createdAt": "2026-03-27..."           │
│   },                                        │
│   "token": "eyJhbGciOiJIUzI1NiIs..."       │
│ }                                           │
└─────────────────────────────────────────────┘
    ↓ (over network)
Receives response ↓

Extracts token:
"eyJhbGciOiJIUzI1NiIs..."

↓
Stores in secure storage:
flutter_secure_storage
(encrypted on device)

↓
User logged in! ✓

↓
Navigates to Dashboard
```

---

## Step 3: Adding a Pet

```
FRONTEND (Flutter App)          BACKEND (Node.js Server)       DATA (RAM)
─────────────────────────────   ─────────────────────────      ────────────

User taps "Add Pet"
    ↓
Shows form with fields:
- Name
- Type (dog, cat, etc)
- Age
- Breed

    ↓
User enters:
- Name: "Buddy"
- Type: "dog"
- Age: 3
- Breed: "Labrador"

    ↓
Taps "Save"

    ↓
Validates locally ✓

    ↓
Sends HTTP POST:
┌──────────────────────────────────────┐
│ POST http://10.0.2.2:4000/pets       │
│                                      │
│ Header: Authorization:               │
│ Bearer eyJhbGciOiJIUzI1NiIs...      │
│                                      │
│ {                                    │
│   "name": "Buddy",                  │
│   "type": "dog",                    │
│   "age": 3,                         │
│   "breed": "Labrador"               │
│ }                                    │
└──────────────────────────────────────┘
    ↓ (over network)
                        Receives request ↓
                        
                        Extracts token ↓
                        
                        Verifies token:
                        - Signature valid? ✓
                        - Not expired? ✓
                        
                        ↓
                        Decodes token:
                        userId = "uuid-1234"
                        
                        ↓
                        Validates pet data:
                        - Name required? ✓
                        - Type valid? ✓
                        
                        ↓
                        Generates pet ID:
                        "pet-uuid-9999"
                        
                        ↓
                        Creates pet object:
                        {
                          id: "pet-uuid-9999",
                          ownerId: "uuid-1234",
                          name: "Buddy",
                          type: "dog",
                          age: 3,
                          breed: "Labrador",
                          photoUrl: null,
                          createdAt: "2026-03-27..."
                        }
                        
                        ↓
                        Stores in RAM:                   ↓
                        petsById.set(                    petsById Map:
                          "pet-uuid-9999",              {
                          petObject                       "pet-uuid-9999": {...}
                        )                                }
                        
                        ↓
                        Also tracks ownership:           petsByUserId Map:
                        petsByUserId.get(                {
                          "uuid-1234"                      "uuid-1234": Set["pet-uuid-9999"]
                        ).add("pet-uuid-9999")           }
                        
                        ↓
                        Sends Response:
┌──────────────────────────────────────┐
│ 201 Created                          │
│                                      │
│ {                                    │
│   "data": {                          │
│     "id": "pet-uuid-9999",          │
│     "ownerId": "uuid-1234",         │
│     "name": "Buddy",                │
│     "type": "dog",                  │
│     "age": 3,                       │
│     "breed": "Labrador",            │
│     "photoUrl": null,               │
│     "createdAt": "2026-03-27..."    │
│   }                                  │
│ }                                    │
└──────────────────────────────────────┘
    ↓ (over network)
Receives response ↓

Extracts pet ID:
"pet-uuid-9999"

↓
Updates UI:
Shows Buddy in pet list

↓
User can see their pet!
```

---

## Step 4: Getting Pet List

```
FRONTEND (Flutter App)          BACKEND (Node.js Server)       DATA (RAM)
─────────────────────────────   ─────────────────────────      ────────────

User navigates to "Pets" tab
    ↓
Sends HTTP GET:
┌──────────────────────────────────────┐
│ GET http://10.0.2.2:4000/pets        │
│                                      │
│ Header: Authorization:               │
│ Bearer eyJhbGciOiJIUzI1NiIs...      │
└──────────────────────────────────────┘
    ↓ (over network)
                        Receives request ↓
                        
                        Verifies token ✓
                        userId = "uuid-1234"
                        
                        ↓
                        Looks up user's pets:              ↓
                        petsByUserId.get(                  petsByUserId:
                          "uuid-1234"                      {
                        )                                    "uuid-1234": 
                        = Set["pet-uuid-9999", ...]         Set[
                                                              "pet-uuid-9999",
                        ↓                                     "pet-uuid-8888"
                        For each pet ID,                   ]
                        look up in petsById:              }
                        petsById.get("pet-uuid-9999")
                        petsById.get("pet-uuid-8888")     petsById:
                                                          {
                        ↓                                   "pet-uuid-9999": {...},
                        Builds response:                   "pet-uuid-8888": {...}
                                                          }
                        Sends Response:
┌──────────────────────────────────────┐
│ 200 OK                               │
│                                      │
│ {                                    │
│   "data": [                          │
│     {                                │
│       "id": "pet-uuid-9999",        │
│       "name": "Buddy",              │
│       "type": "dog",                │
│       "age": 3                       │
│     },                               │
│     {                                │
│       "id": "pet-uuid-8888",        │
│       "name": "Fluffy",             │
│       "type": "cat",                │
│       "age": 2                       │
│     }                                │
│   ]                                  │
│ }                                    │
└──────────────────────────────────────┘
    ↓ (over network)
Receives response ↓

Parses JSON:
pets = [
  {id: "pet-uuid-9999", name: "Buddy", ...},
  {id: "pet-uuid-8888", name: "Fluffy", ...}
]

↓
Updates UI:
Shows ListView with:
- Buddy (dog, 3)
- Fluffy (cat, 2)

↓
User sees their pets!
```

---

## 🔴 KEY CONCEPT: Where Data Lives

### During Execution (Server Running)

```
┌─────────────────────────────────────────────────────┐
│                  YOUR LAPTOP'S RAM                   │
│                                                     │
│  Node.js Process:                                   │
│  ┌───────────────────────────────────────────────┐  │
│  │ usersById: Map                                │  │
│  │   {                                           │  │
│  │     "uuid-1234": {user object}               │  │
│  │   }                                           │  │
│  │                                               │  │
│  │ petsById: Map                                 │  │
│  │   {                                           │  │
│  │     "pet-uuid-9999": {pet object}            │  │
│  │     "pet-uuid-8888": {pet object}            │  │
│  │   }                                           │  │
│  │                                               │  │
│  │ remindersById: Map                            │  │
│  │   {                                           │  │
│  │     "reminder-uuid-1": {reminder object}     │  │
│  │   }                                           │  │
│  └───────────────────────────────────────────────┘  │
│                                                     │
│  ⚠️  All data LOST when:                           │
│  - Server stops (Ctrl+C)                           │
│  - Laptop restarts                                 │
│  - Process crashes                                 │
│                                                     │
│  Restarting loads seed.json:                       │
│  - 3 users (always same)                           │
│  - 8 pets (always same)                            │
│  - 12 reminders (always same)                      │
│  - Any changes you made = GONE                     │
└─────────────────────────────────────────────────────┘
```

### After Server Restarts

```
Step 1: npm start
    ↓
Step 2: Load seed.json
    ↓
Step 3: Reset all data to seed state
    ↓
Fresh start (all custom pets/users gone)
```

---

## Production vs Development

### Development (What You Have Now)

```
Frontend (Flutter)          Backend (RAM)
Device/Emulator    ←HTTP→   Your Laptop:4000
                              ↓
                           In-memory store
                           (temporary)
```

**Data Persistence**: 0 days (lost on restart)

### Production (Phase 4)

```
Frontend (Flutter)          Backend (Cloud)
Play Store App     ←HTTP→   AWS/Heroku:4000
                              ↓
                           PostgreSQL Database
                           (permanent disk storage)
```

**Data Persistence**: Forever (unless deleted)

---

## Summary

| Aspect | Value |
|--------|-------|
| **Backend Location** | Your laptop, port 4000 |
| **Frontend Location** | Emulator/device |
| **Communication** | HTTP REST API |
| **Data Storage** | RAM (your laptop's memory) |
| **Data Persistence** | 0 days (lost on server restart) |
| **Perfect For** | Development, testing, learning |
| **NOT Suitable For** | Production (real users) |
| **Emulator IP** | 10.0.2.2:4000 (special IP) |
| **Device IP** | localhost:4000 or 192.168.x.x:4000 |

