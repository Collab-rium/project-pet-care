# Pet Care Backend

A REST API backend for the Project Pet Care MVP application. Built with Node.js, Express, and in-memory data stores for development.

## Overview

This backend provides REST API endpoints for:
- User authentication (register/login)
- Pet management (CRUD operations with photo uploads)
- Reminders/tasks (CRUD operations with filtering)
- Dashboard/aggregation (daily tasks with overdue detection)

## Prerequisites

- Node 18+ 
- npm 8+
- Firebase CLI (for emulators, optional)

## Setup

### 1. Install Dependencies

```bash
cd backend
npm install
```

### 2. Configure Environment

Create `.env` from `.env.example`:

```bash
cp .env.example .env
```

Edit `.env` and set a strong `JWT_SECRET`:

```
PORT=4000
JWT_SECRET=your_random_secret_here_min_32_chars
```

### 3. Running the Server

**Development (with seed data)**:
```bash
npm start
```

Server listens on `http://localhost:4000`

**With output**:
```bash
npm start 2>&1
```

## API Endpoints

### Authentication

#### Register User
```
POST /auth/register
Content-Type: application/json

{
  "email": "user@example.com",
  "password": "password123",
  "name": "User Name"
}

Response (201):
{
  "user": { "id": "...", "email": "...", "name": "...", "createdAt": "..." },
  "token": "eyJ..."
}
```

#### Login
```
POST /auth/login
Content-Type: application/json

{
  "email": "user@example.com",
  "password": "password123"
}

Response (200):
{
  "user": { "id": "...", "email": "...", "name": "...", "createdAt": "..." },
  "token": "eyJ..."
}
```

### Pets

All pet endpoints require `Authorization: Bearer <token>` header.

#### List Pets
```
GET /pets

Response (200):
{
  "data": [
    {
      "id": "...",
      "ownerId": "...",
      "name": "Buddy",
      "type": "dog",
      "age": 3,
      "breed": "Golden Retriever",
      "photoUrl": "/uploads/pet-uuid.png",
      "createdAt": "...",
      "updatedAt": "..."
    }
  ]
}
```

#### Create Pet
```
POST /pets
Content-Type: application/json

{
  "name": "Buddy",
  "type": "dog",
  "age": 3,
  "breed": "Golden Retriever"
}

Response (201):
{ "data": { ... } }
```

#### Get Pet
```
GET /pets/:id

Response (200):
{ "data": { ... } }
```

#### Update Pet
```
PUT /pets/:id
Content-Type: application/json

{
  "age": 4,
  "breed": "Updated Breed"
}

Response (200):
{ "data": { ... } }
```

#### Delete Pet
```
DELETE /pets/:id

Response (200):
{ "message": "Pet deleted successfully" }
```

#### Upload Pet Photo
```
POST /pets/:id/photo
Content-Type: multipart/form-data

photo: <image file>

Response (200):
{ "data": { ..., "photoUrl": "/uploads/pet-uuid.jpg" } }
```

**Supported image types**: JPEG, PNG, GIF, WebP  
**Size limit**: 10MB

### Reminders

All reminder endpoints require `Authorization: Bearer <token>` header.

#### List Reminders
```
GET /reminders
GET /reminders?petId=<petId>

Response (200):
{
  "data": [
    {
      "id": "...",
      "petId": "...",
      "userId": "...",
      "type": "feeding",
      "message": "Feed Buddy",
      "scheduledTime": "2026-03-26T08:00:00Z",
      "repeat": "daily",
      "status": "pending",
      "createdAt": "...",
      "updatedAt": "..."
    }
  ]
}
```

#### Create Reminder
```
POST /reminders
Content-Type: application/json

{
  "petId": "...",
  "type": "feeding",
  "message": "Feed Buddy",
  "scheduledTime": "2026-03-26T08:00:00Z",
  "repeat": "daily"
}

Response (201):
{ "data": { ... } }
```

**Valid types**: feeding, medication, grooming, exercise, vet_appointment, other  
**Valid repeats**: none, daily, weekly, monthly  
**Valid statuses**: pending, completed, skipped

#### Get Reminder
```
GET /reminders/:id

Response (200):
{ "data": { ... } }
```

#### Update Reminder
```
PUT /reminders/:id
Content-Type: application/json

{
  "status": "completed"
}

Response (200):
{ "data": { ... } }
```

#### Delete Reminder
```
DELETE /reminders/:id

Response (200):
{ "message": "Reminder deleted successfully" }
```

### Dashboard

#### Get Today's Tasks
```
GET /dashboard/today

Response (200):
{
  "data": {
    "date": "2026-03-26",
    "tasks": [
      {
        "id": "...",
        "petId": "...",
        "message": "Feed Buddy",
        "scheduledTime": "2026-03-26T08:00:00Z",
        "status": "pending",
        "isOverdue": false,
        "type": "feeding",
        "repeat": "daily"
      }
    ],
    "summary": {
      "total": 5,
      "completed": 2,
      "pending": 2,
      "overdue": 1
    }
  }
}
```

### Health Check

```
GET /health

Response (200):
{
  "ok": true,
  "uptime": 123,
  "timestamp": "2026-03-26T17:00:00Z"
}
```

## Testing

### Run All Tests
```bash
npm test
```

### Run Specific Test
```bash
npm test -- tests/api.test.js
```

### Test Coverage
- 27 unit tests
- Auth: register, login, validation
- Pets: CRUD operations, ownership checks
- Reminders: CRUD operations, filtering, ownership
- Dashboard: aggregation, overdue detection
- Authorization: token validation

## Data Storage

### In-Memory Stores (Development)

- **Users**: `usersById` and `usersByEmail` maps
- **Pets**: `petsById` and `petsByUserId` maps
- **Reminders**: `remindersById`, `remindersByUserId`, and `remindersByPetId` maps
- **Photos**: Stored in `backend/uploads/` directory (available at `/uploads/*`)

### Seed Data

On startup, the server loads seed data from `backend/data/seed.json`:
- 2 demo users
- 3 demo pets
- 4 demo reminders

**Demo credentials**:
- Email: `demo@example.com`
- Password: `demo1234`

## Error Handling

All error responses follow the same format:

```json
{
  "error": "error_code",
  "message": "Human-readable message",
  "details": {} // optional
}
```

### Common HTTP Status Codes

- **200**: Success
- **201**: Created
- **400**: Bad Request (validation error)
- **401**: Unauthorized (missing/invalid token)
- **403**: Forbidden (ownership violation)
- **404**: Not Found
- **500**: Server Error

## Architecture

```
backend/
├── index.js                 # Express app entry point
├── auth.js                  # Authentication routes & middleware
├── pets.js                  # Pet CRUD routes
├── reminders.js             # Reminder CRUD routes
├── dashboard.js             # Dashboard aggregation routes
├── services/
│   └── load-seed.js         # Seed data loader
├── data/
│   └── seed.json            # Seed data
├── uploads/                 # User-uploaded photos
├── tests/
│   └── api.test.js          # Unit tests
├── .env.example             # Example environment config
└── package.json             # Dependencies
```

## Development Notes

### Authentication

- Uses JWT (JSON Web Tokens) for stateless authentication
- Token expires in 7 days
- Include token in `Authorization: Bearer <token>` header

### Ownership Validation

- All pets/reminders are scoped to authenticated user
- Users can only access their own data
- Endpoints return 403 Forbidden if user doesn't own resource

### Validation

- Email format and uniqueness
- Password strength (minimum 6 chars, at least 1 letter & 1 number)
- Pet and reminder field requirements
- File type and size for photo uploads

## Debugging

### Enable Detailed Logging
```bash
npm start 2>&1 | grep -E "Seed|Server|Error"
```

### Check Seed Data Loading
```bash
npm start 2>&1 | head -5
```

Look for: `Seed data loaded: X users, Y pets, Z reminders`

### Test Server Connectivity
```bash
curl http://localhost:4000/health
```

## Future Enhancements

- [ ] Firebase Firestore integration (replace in-memory stores)
- [ ] Firebase Authentication (replace JWT)
- [ ] Photo caching and CDN
- [ ] Webhook notifications
- [ ] Advanced filtering and pagination
- [ ] Rate limiting
- [ ] API versioning

## Support

See `docs/mvp/01-API_CONTRACT.md` for complete API specification.
