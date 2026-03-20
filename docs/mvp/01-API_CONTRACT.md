# API Contract — Project Pet Care MVP

**Purpose**: Define exact endpoints, request/response shapes, and error codes so backend and frontend can work in isolation and integrate cleanly.

**Status**: Final (both teams agree to this contract)
**Base URL (Local Dev)**: `http://localhost:4000`
**Base URL (Android Emulator)**: `http://10.0.2.2:4000`

---

## Data Models

### User

```json
{
  "id": "user-uuid-1",
  "email": "owner@example.com",
  "name": "Alice",
  "createdAt": "2026-03-20T10:00:00Z"
}
```

### Pet

```json
{
  "id": "pet-uuid-1",
  "ownerId": "user-uuid-1",
  "name": "Buddy",
  "type": "dog",
  "age": 3,
  "breed": "Golden Retriever",
  "photoUrl": "https://storage.example.com/pets/buddy.jpg",
  "createdAt": "2026-03-20T10:05:00Z",
  "updatedAt": "2026-03-20T10:05:00Z"
}
```

### Reminder

```json
{
  "id": "reminder-uuid-1",
  "petId": "pet-uuid-1",
  "userId": "user-uuid-1",
  "type": "feeding",
  "message": "Feed Buddy",
  "scheduledTime": "2026-03-20T08:00:00Z",
  "repeat": "daily",
  "status": "pending",
  "createdAt": "2026-03-20T10:10:00Z",
  "updatedAt": "2026-03-20T10:10:00Z"
}
```

### Task (Dashboard)

```json
{
  "id": "reminder-uuid-1",
  "petName": "Buddy",
  "message": "Feed Buddy",
  "scheduledTime": "2026-03-20T08:00:00Z",
  "status": "pending",
  "isOverdue": false
}
```

---

## Authentication

### Login / Register (Mock or Firebase Auth)

**Endpoint**: `POST /auth/register`

**Request**:
```json
{
  "email": "owner@example.com",
  "password": "securePassword123",
  "name": "Alice"
}
```

**Response (201 Created)**:
```json
{
  "user": {
    "id": "user-uuid-1",
    "email": "owner@example.com",
    "name": "Alice"
  },
  "token": "firebase-id-token-here"
}
```

---

**Endpoint**: `POST /auth/login`

**Request**:
```json
{
  "email": "owner@example.com",
  "password": "securePassword123"
}
```

**Response (200 OK)**:
```json
{
  "user": {
    "id": "user-uuid-1",
    "email": "owner@example.com",
    "name": "Alice"
  },
  "token": "firebase-id-token-here"
}
```

---

**Note**: All authenticated endpoints require the header: `Authorization: Bearer <token>`

---

## Pet Endpoints

### List All Pets (for logged-in user)

**Endpoint**: `GET /pets`

**Headers**: `Authorization: Bearer <token>`

**Response (200 OK)**:
```json
[
  {
    "id": "pet-uuid-1",
    "ownerId": "user-uuid-1",
    "name": "Buddy",
    "type": "dog",
    "age": 3,
    "breed": "Golden Retriever",
    "photoUrl": "https://...",
    "createdAt": "2026-03-20T10:05:00Z"
  }
]
```

---

### Get Single Pet

**Endpoint**: `GET /pets/:id`

**Headers**: `Authorization: Bearer <token>`

**Response (200 OK)**:
```json
{
  "id": "pet-uuid-1",
  "ownerId": "user-uuid-1",
  "name": "Buddy",
  "type": "dog",
  "age": 3,
  "breed": "Golden Retriever",
  "photoUrl": "https://...",
  "createdAt": "2026-03-20T10:05:00Z"
}
```

---

### Create Pet

**Endpoint**: `POST /pets`

**Headers**: `Authorization: Bearer <token>`, `Content-Type: application/json`

**Request**:
```json
{
  "name": "Buddy",
  "type": "dog",
  "age": 3,
  "breed": "Golden Retriever"
}
```

**Response (201 Created)**:
```json
{
  "id": "pet-uuid-1",
  "ownerId": "user-uuid-1",
  "name": "Buddy",
  "type": "dog",
  "age": 3,
  "breed": "Golden Retriever",
  "photoUrl": null,
  "createdAt": "2026-03-20T10:05:00Z"
}
```

---

### Update Pet

**Endpoint**: `PUT /pets/:id`

**Headers**: `Authorization: Bearer <token>`, `Content-Type: application/json`

**Request** (partial update allowed):
```json
{
  "age": 4,
  "breed": "Golden Retriever Mix"
}
```

**Response (200 OK)**:
```json
{
  "id": "pet-uuid-1",
  "ownerId": "user-uuid-1",
  "name": "Buddy",
  "type": "dog",
  "age": 4,
  "breed": "Golden Retriever Mix",
  "photoUrl": "https://...",
  "updatedAt": "2026-03-20T10:15:00Z"
}
```

---

### Delete Pet

**Endpoint**: `DELETE /pets/:id`

**Headers**: `Authorization: Bearer <token>`

**Response (204 No Content)** or **(200 OK)**:
```json
{
  "message": "Pet deleted successfully"
}
```

---

### Upload Pet Photo

**Endpoint**: `POST /pets/:id/photo`

**Headers**: `Authorization: Bearer <token>`, `Content-Type: multipart/form-data`

**Request**: Form with file field `photo` (JPEG/PNG, max 5MB)

**Response (200 OK)**:
```json
{
  "id": "pet-uuid-1",
  "photoUrl": "https://storage.example.com/pets/buddy_2026-03-20_123456.jpg"
}
```

---

## Reminder Endpoints

### List All Reminders (for logged-in user)

**Endpoint**: `GET /reminders`

**Headers**: `Authorization: Bearer <token>`

**Query Params** (optional): `?petId=pet-uuid-1` (filter by pet)

**Response (200 OK)**:
```json
[
  {
    "id": "reminder-uuid-1",
    "petId": "pet-uuid-1",
    "userId": "user-uuid-1",
    "type": "feeding",
    "message": "Feed Buddy",
    "scheduledTime": "2026-03-20T08:00:00Z",
    "repeat": "daily",
    "status": "pending",
    "createdAt": "2026-03-20T10:10:00Z"
  }
]
```

---

### Get Single Reminder

**Endpoint**: `GET /reminders/:id`

**Headers**: `Authorization: Bearer <token>`

**Response (200 OK)**:
```json
{
  "id": "reminder-uuid-1",
  "petId": "pet-uuid-1",
  "userId": "user-uuid-1",
  "type": "feeding",
  "message": "Feed Buddy",
  "scheduledTime": "2026-03-20T08:00:00Z",
  "repeat": "daily",
  "status": "pending"
}
```

---

### Create Reminder

**Endpoint**: `POST /reminders`

**Headers**: `Authorization: Bearer <token>`, `Content-Type: application/json`

**Request**:
```json
{
  "petId": "pet-uuid-1",
  "type": "feeding",
  "message": "Feed Buddy",
  "scheduledTime": "2026-03-20T08:00:00Z",
  "repeat": "daily"
}
```

**Valid Types**: `feeding`, `medicine`, `bath`, `vet`, `other`

**Valid Repeat Values**: `once`, `daily`, `weekly`, `monthly`

**Response (201 Created)**:
```json
{
  "id": "reminder-uuid-1",
  "petId": "pet-uuid-1",
  "userId": "user-uuid-1",
  "type": "feeding",
  "message": "Feed Buddy",
  "scheduledTime": "2026-03-20T08:00:00Z",
  "repeat": "daily",
  "status": "pending",
  "createdAt": "2026-03-20T10:10:00Z"
}
```

---

### Update Reminder

**Endpoint**: `PUT /reminders/:id`

**Headers**: `Authorization: Bearer <token>`, `Content-Type: application/json`

**Request** (partial update):
```json
{
  "scheduledTime": "2026-03-20T09:00:00Z",
  "status": "completed"
}
```

**Response (200 OK)**:
```json
{
  "id": "reminder-uuid-1",
  "petId": "pet-uuid-1",
  "userId": "user-uuid-1",
  "type": "feeding",
  "message": "Feed Buddy",
  "scheduledTime": "2026-03-20T09:00:00Z",
  "repeat": "daily",
  "status": "completed",
  "updatedAt": "2026-03-20T10:12:00Z"
}
```

---

### Delete Reminder

**Endpoint**: `DELETE /reminders/:id`

**Headers**: `Authorization: Bearer <token>`

**Response (204 No Content)** or **(200 OK)**:
```json
{
  "message": "Reminder deleted successfully"
}
```

---

## Dashboard Endpoint

### Get Today's Tasks

**Endpoint**: `GET /dashboard/today`

**Headers**: `Authorization: Bearer <token>`

**Response (200 OK)**:
```json
{
  "date": "2026-03-20",
  "tasks": [
    {
      "id": "reminder-uuid-1",
      "petName": "Buddy",
      "message": "Feed Buddy",
      "scheduledTime": "2026-03-20T08:00:00Z",
      "status": "pending",
      "isOverdue": false
    },
    {
      "id": "reminder-uuid-2",
      "petName": "Max",
      "message": "Give medicine",
      "scheduledTime": "2026-03-19T18:00:00Z",
      "status": "pending",
      "isOverdue": true
    }
  ],
  "summary": {
    "total": 2,
    "completed": 0,
    "pending": 1,
    "overdue": 1
  }
}
```

---

## Health Check Endpoint

**Endpoint**: `GET /health`

**No Auth Required**

**Response (200 OK)**:
```json
{
  "ok": true,
  "uptime": 1234.56,
  "timestamp": "2026-03-20T10:20:00Z"
}
```

---

## Error Handling

All errors follow this format:

```json
{
  "error": true,
  "code": "ERROR_CODE",
  "message": "Human-readable error message",
  "details": {}
}
```

### Common Error Codes

| Status | Code | Example |
|--------|------|---------|
| 400 | `INVALID_REQUEST` | Missing required field |
| 401 | `UNAUTHORIZED` | Missing or invalid token |
| 403 | `FORBIDDEN` | User doesn't own this pet |
| 404 | `NOT_FOUND` | Pet doesn't exist |
| 409 | `CONFLICT` | Email already registered |
| 500 | `INTERNAL_ERROR` | Server error |

### Example Error Response

```json
{
  "error": true,
  "code": "NOT_FOUND",
  "message": "Pet not found",
  "details": {
    "petId": "pet-uuid-1"
  }
}
```

---

## CORS & Headers

- **CORS Origins** (local dev): `http://localhost:*`, `http://10.0.2.2:*`
- **Content-Type**: `application/json` (except file upload: `multipart/form-data`)
- **Response Headers**: Include `Access-Control-Allow-Origin`, `Content-Type`, `Cache-Control`

---

## Summary Table

| Method | Endpoint | Auth | Purpose |
|--------|----------|------|---------|
| POST | `/auth/register` | No | User sign-up |
| POST | `/auth/login` | No | User login |
| GET | `/pets` | Yes | List user's pets |
| GET | `/pets/:id` | Yes | Get pet detail |
| POST | `/pets` | Yes | Create pet |
| PUT | `/pets/:id` | Yes | Update pet |
| DELETE | `/pets/:id` | Yes | Delete pet |
| POST | `/pets/:id/photo` | Yes | Upload pet photo |
| GET | `/reminders` | Yes | List reminders |
| GET | `/reminders/:id` | Yes | Get reminder detail |
| POST | `/reminders` | Yes | Create reminder |
| PUT | `/reminders/:id` | Yes | Update reminder |
| DELETE | `/reminders/:id` | Yes | Delete reminder |
| GET | `/dashboard/today` | Yes | Today's tasks |
| GET | `/health` | No | Health check |

---

**Status**: Final (ready for implementation)
**Last Updated**: March 20, 2026
