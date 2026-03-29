# PHASE 5 — Backend + Architecture Mapping

**Date:** March 29, 2026  
**Purpose:** Cross-reference APP_SPEC.md features with existing backend plan and identify gaps  
**Sources:** APP_SPEC.md, LOCAL_BACKUP_PERSISTENCE.md, 01-API_CONTRACT.md, PHASE3_GAP_ANALYSIS.md

---

## 1. Features Mapping to Existing Backend

### ✅ Features That Map Cleanly (Already Planned)

| Feature | Backend Support | API Endpoints | Status |
|---------|----------------|---------------|--------|
| **User Auth** | ✅ Implemented | POST /auth/register, /auth/login | Phase 0-3 Complete |
| **Pet Profiles** | ✅ Implemented | GET/POST/PUT/DELETE /pets | Phase 0-3 Complete |
| **Pet List** | ✅ Implemented | GET /pets (by userId) | Phase 0-3 Complete |
| **Reminders/Tasks** | ✅ Implemented | GET/POST/PUT/DELETE /reminders | Phase 0-3 Complete |
| **Dashboard Stats** | ✅ Implemented | GET /dashboard (counts by status) | Phase 0-3 Complete |
| **Settings** | ✅ Planned | GET/PUT /settings (theme, wallpaper, debug) | In LOCAL_BACKUP_PERSISTENCE.md |
| **Expenses** | ✅ Planned | POST /budget/expense, GET /budget/:petId | In LOCAL_BACKUP_PERSISTENCE.md |
| **Budget Tracking** | ✅ Planned | GET /budget/:petId | In LOCAL_BACKUP_PERSISTENCE.md |
| **Backup/Restore** | ✅ Planned | GET /backup/export, POST /backup/import | In LOCAL_BACKUP_PERSISTENCE.md |

**Summary:** Core MVP features (auth, pets, reminders, expenses, settings, backup) have backend coverage.

---

## 2. New Features Needing Backend Implementation

### 🔶 High Priority (MVP-Critical)

#### **Weight Tracking**
- **Frontend Need:** Log weight measurements, view history, visualize chart
- **Backend Required:**
  - **Table:** `CREATE TABLE weights (id, petId, weight, unit, date, notes, createdAt)`
  - **Endpoints:**
    - `POST /pets/:petId/weights` - Add weight record
    - `GET /pets/:petId/weights?startDate=X&endDate=Y` - Get weight history
    - `PUT /pets/:petId/weights/:id` - Edit weight record
    - `DELETE /pets/:petId/weights/:id` - Delete weight record
- **Data Model:** See APP_SPEC.md Section 4.1
- **Complexity:** LOW (simple CRUD)

#### **Photo Gallery**
- **Frontend Need:** Upload multiple pet photos, organize in albums, set cover photo
- **Backend Required:**
  - **Tables:**
    - `CREATE TABLE photos (id, petId, userId, imageUrl, albumId, caption, uploadedAt)`
    - `CREATE TABLE albums (id, petId, name, coverPhotoId, createdAt, updatedAt)`
  - **Endpoints:**
    - `POST /pets/:petId/photos` - Upload photo (multipart/form-data)
    - `GET /pets/:petId/photos?albumId=X` - Get photos (filter by album)
    - `DELETE /pets/:petId/photos/:id` - Delete photo
    - `POST /pets/:petId/albums` - Create album
    - `PUT /pets/:petId/albums/:id` - Update album (name, cover)
    - `DELETE /pets/:petId/albums/:id` - Delete album
  - **File Storage:** Local filesystem at `/uploads/pets/{petId}/photos/`
  - **Image Processing:** Compress to max 1920px width, 80% quality
- **Complexity:** MEDIUM (file uploads, storage management)

#### **Notification System**
- **Frontend Need:** Push notifications for reminders, overdue tasks
- **Backend Required:**
  - **Table:** `CREATE TABLE notifications (id, userId, petId, reminderId, type, title, body, read, sentAt, readAt)`
  - **Endpoints:**
    - `GET /notifications?read=false` - Get user notifications
    - `PUT /notifications/:id/read` - Mark as read
    - `POST /notifications/register-token` - Register FCM device token
  - **Background Job:** Cron job to check for due reminders and send notifications
  - **Push Service:** Firebase Cloud Messaging (FCM) or local notifications only
- **Complexity:** MEDIUM (requires background jobs, push service integration)

#### **Pet Photo Upload (Profile)**
- **Frontend Need:** Upload single profile photo per pet
- **Backend Required:**
  - **Endpoint:** `POST /pets/:petId/photo` - Upload profile photo (multipart/form-data)
  - **File Storage:** Local filesystem at `/uploads/pets/{petId}/profile.jpg`
  - **Image Processing:** Compress and create thumbnail (200x200px)
  - **Update Pet Record:** Store `photoUrl` in pets table
- **Complexity:** LOW (single file upload)

### 🔷 Medium Priority (Post-MVP Phase 1)

#### **Vaccination Tracking**
- **Frontend Need:** Log vaccinations, track due dates, attach certificates
- **Backend Required:**
  - **Table:** `CREATE TABLE vaccinations (id, petId, vaccineName, date, vetName, clinic, cost, nextDueDate, certificateUrl, notes, completed, createdAt, updatedAt)`
  - **Endpoints:**
    - `POST /pets/:petId/vaccinations` - Add vaccination record
    - `GET /pets/:petId/vaccinations` - Get vaccination history
    - `PUT /pets/:petId/vaccinations/:id` - Update vaccination
    - `DELETE /pets/:petId/vaccinations/:id` - Delete vaccination
    - `POST /pets/:petId/vaccinations/:id/certificate` - Upload certificate (PDF/image)
- **Complexity:** MEDIUM (CRUD + file upload)

#### **Service/Vet Visit Tracking**
- **Frontend Need:** Log vet visits, surgeries, checkups
- **Backend Required:**
  - **Table:** `CREATE TABLE services (id, petId, serviceType, clinicName, date, time, cost, notes, createdAt, updatedAt)`
  - **Endpoints:**
    - `POST /pets/:petId/services` - Add service record
    - `GET /pets/:petId/services?type=X` - Get service history (filter by type)
    - `PUT /pets/:petId/services/:id` - Update service
    - `DELETE /pets/:petId/services/:id` - Delete service
- **Complexity:** LOW (simple CRUD)

#### **Document Management**
- **Frontend Need:** Upload documents (PDFs, images), categorize, view/download
- **Backend Required:**
  - **Table:** `CREATE TABLE documents (id, petId, title, fileUrl, fileType, fileSizeBytes, category, uploadedAt)`
  - **Endpoints:**
    - `POST /pets/:petId/documents` - Upload document (multipart/form-data)
    - `GET /pets/:petId/documents?category=X` - Get documents (filter by category)
    - `GET /pets/:petId/documents/:id/download` - Download document
    - `DELETE /pets/:petId/documents/:id` - Delete document
  - **File Storage:** Local filesystem at `/uploads/pets/{petId}/documents/`
  - **File Size Limit:** 10MB per document
- **Complexity:** MEDIUM (file uploads, MIME type handling)

#### **Daily Logs/Journal**
- **Frontend Need:** Create daily log entries, attach photos, view timeline
- **Backend Required:**
  - **Table:** `CREATE TABLE logs (id, petId, userId, date, notes, mood, activity, createdAt, updatedAt)`
  - **Endpoints:**
    - `POST /pets/:petId/logs` - Create log entry
    - `GET /pets/:petId/logs?startDate=X&endDate=Y` - Get logs (date range)
    - `PUT /pets/:petId/logs/:id` - Update log
    - `DELETE /pets/:petId/logs/:id` - Delete log
  - **Photo Attachment:** Reuse photos table with logId reference (or separate log_photos table)
- **Complexity:** LOW-MEDIUM (CRUD + optional photo links)

### 🔵 Low Priority (Phase 2+)

#### **Multi-User Collaboration**
- **Frontend Need:** Invite users, set roles/permissions, revoke access
- **Backend Required:**
  - **Table:** `CREATE TABLE user_access (id, petId, userId, role, invitedBy, invitedAt, acceptedAt, permissions)`
  - **Endpoints:**
    - `POST /pets/:petId/users/invite` - Send invitation email
    - `GET /pets/:petId/users` - List users with access
    - `PUT /pets/:petId/users/:userId/role` - Update user role
    - `DELETE /pets/:petId/users/:userId` - Revoke access
    - `POST /invitations/:token/accept` - Accept invitation (creates user_access record)
  - **Email Service:** SendGrid, AWS SES, or SMTP for invitation emails
  - **Authorization:** Middleware to check user permissions on every pet-related endpoint
- **Complexity:** HIGH (authorization logic, email service, invitation flow)

#### **Medication Tracking** (Gap from Phase 3)
- **Frontend Need:** Log medications, dosage, frequency, refill reminders
- **Backend Required:**
  - **Table:** `CREATE TABLE medications (id, petId, name, dosage, frequency, startDate, endDate, refillReminderDays, notes, active, createdAt, updatedAt)`
  - **Table:** `CREATE TABLE medication_logs (id, medicationId, administeredAt, administeredBy, notes)`
  - **Endpoints:**
    - `POST /pets/:petId/medications` - Add medication
    - `GET /pets/:petId/medications?active=true` - Get medications
    - `PUT /pets/:petId/medications/:id` - Update medication
    - `DELETE /pets/:petId/medications/:id` - Delete medication
    - `POST /pets/:petId/medications/:id/log` - Log medication administration
    - `GET /pets/:petId/medications/:id/logs` - Get medication history
- **Complexity:** MEDIUM (CRUD + related logs table)

#### **Emergency Contacts** (Gap from Phase 3)
- **Frontend Need:** Store emergency vet, poison control, backup contacts
- **Backend Required:**
  - **Option A:** Add JSON field to pets table: `emergencyContacts: [{name, phone, type}]`
  - **Option B:** Separate table: `CREATE TABLE emergency_contacts (id, petId, name, phone, type, notes)`
  - **Endpoints:**
    - `GET /pets/:petId/emergency-contacts` - Get contacts
    - `POST /pets/:petId/emergency-contacts` - Add contact
    - `PUT /pets/:petId/emergency-contacts/:id` - Update contact
    - `DELETE /pets/:petId/emergency-contacts/:id` - Delete contact
- **Complexity:** LOW (simple CRUD or JSON field update)

#### **Insurance Information** (Gap from Phase 3)
- **Frontend Need:** Store insurance provider, policy number, coverage details
- **Backend Required:**
  - **Option A:** Add fields to pets table: `insuranceProvider, policyNumber, coverageDetails`
  - **Option B:** Separate table: `CREATE TABLE insurance (id, petId, provider, policyNumber, coverageDetails, policyDocUrl)`
  - **Endpoints:**
    - `GET /pets/:petId/insurance` - Get insurance info
    - `PUT /pets/:petId/insurance` - Update insurance info
    - `POST /pets/:petId/insurance/document` - Upload insurance card
- **Complexity:** LOW

#### **Data Export (Enhanced)**
- **Frontend Need:** Export data to CSV, PDF, JSON (selective or full)
- **Backend Required:**
  - **Endpoints:**
    - `GET /export?format=csv&modules=weights,expenses&petId=X` - Selective export
    - `GET /export/pdf?petId=X` - Generate PDF report
  - **Libraries:** `json2csv` for CSV, `pdfkit` for PDF generation
- **Complexity:** MEDIUM (data serialization, PDF generation)

---

## 3. Features That Conflict or Overlap

### ⚠️ Reminders vs. Medication Tracking
- **Conflict:** Reference app shows separate "Reminders" and implied medication tracking
- **Current Plan:** Only generic reminders exist
- **Resolution:** 
  - **Option A:** Keep reminders generic; add optional `linkedMedicationId` field
  - **Option B:** Create separate medication module with auto-reminders
  - **Recommendation:** Option A for MVP (simpler), Option B for Phase 2

### ⚠️ Expenses vs. Budget
- **Conflict:** Expenses are logged in `expenses` table; budget is separate `budgets` table
- **Current Plan:** Both exist but need linking logic
- **Resolution:**
  - Budget endpoints should aggregate expenses: `SELECT SUM(amount) FROM expenses WHERE petId=X AND date BETWEEN start AND end`
  - Budget alerts (75%, 100%) triggered by backend logic when expenses exceed threshold
- **Recommendation:** Implement budget as calculated view over expenses, not separate data

### ⚠️ Pet Photo vs. Photos Gallery
- **Conflict:** Pet profile has single `photoUrl`; gallery has multiple photos
- **Current Plan:** Not clarified
- **Resolution:**
  - Pet profile photo (`photoUrl` in pets table) is separate from gallery
  - Gallery photos stored in `photos` table
  - User can set gallery photo as profile photo (copy URL to pets.photoUrl)
- **Recommendation:** Keep separate; allow setting gallery photo as profile

### ⚠️ Cloud Sync vs. Local-First
- **Conflict:** Reference app implies cloud sync; user wants local-first
- **Current Plan:** Local SQLite + manual backup
- **Resolution:**
  - MVP: Local-only (SQLite)
  - Post-MVP: Optional cloud sync (sync local DB to backend periodically)
  - Backend exists but frontend uses it for backup/restore only, not live sync
- **Recommendation:** Start local-only; backend already built for future cloud option

---

## 4. Backend Changes Required

### 4.1 New Database Tables (SQLite)

**High Priority (MVP):**
```sql
-- Weight Tracking
CREATE TABLE weights (
  id TEXT PRIMARY KEY,
  petId TEXT NOT NULL,
  weight REAL NOT NULL,
  unit TEXT DEFAULT 'kg',
  date TEXT NOT NULL,
  notes TEXT,
  createdAt TEXT DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (petId) REFERENCES pets(id) ON DELETE CASCADE
);

-- Photos
CREATE TABLE photos (
  id TEXT PRIMARY KEY,
  petId TEXT NOT NULL,
  userId TEXT NOT NULL,
  imageUrl TEXT NOT NULL,
  albumId TEXT,
  caption TEXT,
  uploadedAt TEXT DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (petId) REFERENCES pets(id) ON DELETE CASCADE,
  FOREIGN KEY (userId) REFERENCES users(id) ON DELETE CASCADE,
  FOREIGN KEY (albumId) REFERENCES albums(id) ON DELETE SET NULL
);

-- Albums
CREATE TABLE albums (
  id TEXT PRIMARY KEY,
  petId TEXT NOT NULL,
  name TEXT NOT NULL,
  coverPhotoId TEXT,
  createdAt TEXT DEFAULT CURRENT_TIMESTAMP,
  updatedAt TEXT DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (petId) REFERENCES pets(id) ON DELETE CASCADE,
  FOREIGN KEY (coverPhotoId) REFERENCES photos(id) ON DELETE SET NULL
);

-- Notifications
CREATE TABLE notifications (
  id TEXT PRIMARY KEY,
  userId TEXT NOT NULL,
  petId TEXT,
  reminderId TEXT,
  type TEXT NOT NULL, -- 'reminder', 'overdue', 'invitation', 'system'
  title TEXT NOT NULL,
  body TEXT,
  read INTEGER DEFAULT 0,
  sentAt TEXT DEFAULT CURRENT_TIMESTAMP,
  readAt TEXT,
  FOREIGN KEY (userId) REFERENCES users(id) ON DELETE CASCADE,
  FOREIGN KEY (petId) REFERENCES pets(id) ON DELETE CASCADE,
  FOREIGN KEY (reminderId) REFERENCES reminders(id) ON DELETE CASCADE
);
```

**Medium Priority (Post-MVP Phase 1):**
```sql
-- Vaccinations
CREATE TABLE vaccinations (
  id TEXT PRIMARY KEY,
  petId TEXT NOT NULL,
  vaccineName TEXT NOT NULL,
  date TEXT NOT NULL,
  vetName TEXT,
  clinic TEXT,
  cost REAL,
  nextDueDate TEXT,
  certificateUrl TEXT,
  notes TEXT,
  completed INTEGER DEFAULT 0,
  createdAt TEXT DEFAULT CURRENT_TIMESTAMP,
  updatedAt TEXT DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (petId) REFERENCES pets(id) ON DELETE CASCADE
);

-- Services
CREATE TABLE services (
  id TEXT PRIMARY KEY,
  petId TEXT NOT NULL,
  serviceType TEXT NOT NULL, -- 'checkup', 'surgery', 'grooming', 'dental', 'other'
  clinicName TEXT,
  date TEXT NOT NULL,
  time TEXT,
  cost REAL,
  notes TEXT,
  createdAt TEXT DEFAULT CURRENT_TIMESTAMP,
  updatedAt TEXT DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (petId) REFERENCES pets(id) ON DELETE CASCADE
);

-- Documents
CREATE TABLE documents (
  id TEXT PRIMARY KEY,
  petId TEXT NOT NULL,
  title TEXT NOT NULL,
  fileUrl TEXT NOT NULL,
  fileType TEXT NOT NULL, -- 'image', 'pdf', 'other'
  fileSizeBytes INTEGER,
  category TEXT, -- 'medical', 'certificate', 'receipt', 'other'
  uploadedAt TEXT DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (petId) REFERENCES pets(id) ON DELETE CASCADE
);

-- Logs
CREATE TABLE logs (
  id TEXT PRIMARY KEY,
  petId TEXT NOT NULL,
  userId TEXT NOT NULL,
  date TEXT NOT NULL,
  notes TEXT NOT NULL,
  mood TEXT, -- 'happy', 'sad', 'anxious', 'playful', 'other'
  activity TEXT,
  createdAt TEXT DEFAULT CURRENT_TIMESTAMP,
  updatedAt TEXT DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (petId) REFERENCES pets(id) ON DELETE CASCADE,
  FOREIGN KEY (userId) REFERENCES users(id) ON DELETE CASCADE
);
```

**Low Priority (Phase 2+):**
```sql
-- Multi-User Access
CREATE TABLE user_access (
  id TEXT PRIMARY KEY,
  petId TEXT NOT NULL,
  userId TEXT NOT NULL,
  role TEXT DEFAULT 'viewer', -- 'owner', 'editor', 'viewer'
  invitedBy TEXT NOT NULL,
  invitedAt TEXT DEFAULT CURRENT_TIMESTAMP,
  acceptedAt TEXT,
  permissions TEXT, -- JSON string
  FOREIGN KEY (petId) REFERENCES pets(id) ON DELETE CASCADE,
  FOREIGN KEY (userId) REFERENCES users(id) ON DELETE CASCADE,
  FOREIGN KEY (invitedBy) REFERENCES users(id) ON DELETE CASCADE
);

-- Medications
CREATE TABLE medications (
  id TEXT PRIMARY KEY,
  petId TEXT NOT NULL,
  name TEXT NOT NULL,
  dosage TEXT,
  frequency TEXT, -- 'daily', 'twice_daily', 'weekly', etc.
  startDate TEXT NOT NULL,
  endDate TEXT,
  refillReminderDays INTEGER DEFAULT 7,
  notes TEXT,
  active INTEGER DEFAULT 1,
  createdAt TEXT DEFAULT CURRENT_TIMESTAMP,
  updatedAt TEXT DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (petId) REFERENCES pets(id) ON DELETE CASCADE
);

CREATE TABLE medication_logs (
  id TEXT PRIMARY KEY,
  medicationId TEXT NOT NULL,
  administeredAt TEXT DEFAULT CURRENT_TIMESTAMP,
  administeredBy TEXT, -- userId
  notes TEXT,
  FOREIGN KEY (medicationId) REFERENCES medications(id) ON DELETE CASCADE
);

-- Emergency Contacts
CREATE TABLE emergency_contacts (
  id TEXT PRIMARY KEY,
  petId TEXT NOT NULL,
  name TEXT NOT NULL,
  phone TEXT NOT NULL,
  type TEXT, -- 'vet', 'emergency_vet', 'poison_control', 'friend', 'other'
  notes TEXT,
  FOREIGN KEY (petId) REFERENCES pets(id) ON DELETE CASCADE
);

-- Insurance
CREATE TABLE insurance (
  id TEXT PRIMARY KEY,
  petId TEXT NOT NULL UNIQUE,
  provider TEXT NOT NULL,
  policyNumber TEXT NOT NULL,
  coverageDetails TEXT,
  policyDocUrl TEXT,
  FOREIGN KEY (petId) REFERENCES pets(id) ON DELETE CASCADE
);
```

### 4.2 New API Endpoints

**High Priority (MVP):**
```javascript
// Weight Tracking
POST   /pets/:petId/weights          // Add weight
GET    /pets/:petId/weights          // Get weight history (with date range query params)
PUT    /pets/:petId/weights/:id      // Update weight
DELETE /pets/:petId/weights/:id      // Delete weight

// Photo Gallery
POST   /pets/:petId/photos           // Upload photo (multipart)
GET    /pets/:petId/photos           // Get photos (optional albumId query param)
DELETE /pets/:petId/photos/:id       // Delete photo
POST   /pets/:petId/albums           // Create album
GET    /pets/:petId/albums           // Get albums
PUT    /pets/:petId/albums/:id       // Update album
DELETE /pets/:petId/albums/:id       // Delete album

// Profile Photo
POST   /pets/:petId/photo            // Upload profile photo (multipart)

// Notifications
GET    /notifications                // Get user notifications (optional read query param)
PUT    /notifications/:id/read       // Mark notification as read
POST   /notifications/register-token // Register FCM device token
```

**Medium Priority (Post-MVP Phase 1):**
```javascript
// Vaccinations
POST   /pets/:petId/vaccinations     // Add vaccination
GET    /pets/:petId/vaccinations     // Get vaccinations
PUT    /pets/:petId/vaccinations/:id // Update vaccination
DELETE /pets/:petId/vaccinations/:id // Delete vaccination
POST   /pets/:petId/vaccinations/:id/certificate // Upload certificate

// Services
POST   /pets/:petId/services         // Add service
GET    /pets/:petId/services         // Get services (optional type query param)
PUT    /pets/:petId/services/:id     // Update service
DELETE /pets/:petId/services/:id     // Delete service

// Documents
POST   /pets/:petId/documents        // Upload document (multipart)
GET    /pets/:petId/documents        // Get documents (optional category query param)
GET    /pets/:petId/documents/:id/download // Download document
DELETE /pets/:petId/documents/:id    // Delete document

// Logs
POST   /pets/:petId/logs             // Create log
GET    /pets/:petId/logs             // Get logs (optional date range query params)
PUT    /pets/:petId/logs/:id         // Update log
DELETE /pets/:petId/logs/:id         // Delete log
```

**Low Priority (Phase 2+):**
```javascript
// Multi-User
POST   /pets/:petId/users/invite     // Invite user
GET    /pets/:petId/users            // List users
PUT    /pets/:petId/users/:userId/role // Update role
DELETE /pets/:petId/users/:userId    // Revoke access
POST   /invitations/:token/accept    // Accept invitation

// Medications
POST   /pets/:petId/medications      // Add medication
GET    /pets/:petId/medications      // Get medications
PUT    /pets/:petId/medications/:id  // Update medication
DELETE /pets/:petId/medications/:id  // Delete medication
POST   /pets/:petId/medications/:id/log // Log administration
GET    /pets/:petId/medications/:id/logs // Get logs

// Emergency Contacts
GET    /pets/:petId/emergency-contacts    // Get contacts
POST   /pets/:petId/emergency-contacts    // Add contact
PUT    /pets/:petId/emergency-contacts/:id // Update contact
DELETE /pets/:petId/emergency-contacts/:id // Delete contact

// Insurance
GET    /pets/:petId/insurance        // Get insurance
PUT    /pets/:petId/insurance        // Update insurance
POST   /pets/:petId/insurance/document // Upload insurance card
```

### 4.3 Existing Endpoints to Enhance

**Pets Endpoints:**
- `GET /pets/:id` - Add query param `?include=weights,vaccinations,photos` to return related data in single request (reduces API calls)

**Reminders Endpoints:**
- `GET /reminders` - Add filtering: `?status=pending&overdue=true&petId=X`
- Add reminder notifications: Background job to check for due reminders and create notification records

**Expenses Endpoints:**
- `GET /budget/:petId` - Calculate total spent vs. budget, percentage used, alert status
- Add query params: `?startDate=X&endDate=Y&category=food`

**Backup Endpoints:**
- `GET /backup/export` - Add `?modules=pets,reminders,expenses` for selective export
- `POST /backup/preview` - Show what will be imported before actually importing

---

## 5. High-Risk / High-Complexity Areas

### 🔴 Critical Risk Areas

#### **1. File Upload & Storage Management**
- **Risk:** Uncontrolled file uploads can fill storage, crash app
- **Complexity:** MEDIUM-HIGH
- **Mitigation:**
  - Implement file size limits (10MB per document, 5MB per photo)
  - Compress images on upload (max 1920px, 80% quality)
  - Implement storage quotas per user (100MB for free tier)
  - Clean up orphaned files when records deleted
  - Validate file types (images: jpg/png, documents: pdf only)
  - Sanitize filenames to prevent path traversal attacks

#### **2. Notification Delivery Reliability**
- **Risk:** Reminders fail to fire, users miss critical medication times
- **Complexity:** HIGH
- **Mitigation:**
  - Use reliable background job scheduler (node-cron or BullMQ)
  - Implement retry logic for failed notifications
  - Log all notification attempts for debugging
  - Allow users to test notifications in settings
  - Gracefully degrade if FCM unavailable (show in-app alerts)
  - Handle timezone changes (store reminders in UTC)

#### **3. Data Sync Conflicts (Local-First Architecture)**
- **Risk:** User makes changes offline, syncs later, overwrites other changes
- **Complexity:** VERY HIGH
- **Mitigation:**
  - Implement conflict detection (compare timestamps)
  - Use "last write wins" for MVP (simpler)
  - Log conflicts for manual review
  - Defer full CRDT-based sync to Phase 2+
  - Backup before sync (allow rollback)

#### **4. Backup/Restore Data Integrity**
- **Risk:** Corrupted backup files, partial imports, data loss
- **Complexity:** MEDIUM-HIGH
- **Mitigation:**
  - Validate backup file structure before import
  - Implement checksum verification
  - Backup current data before restore (allow undo)
  - Test import with preview mode first
  - Handle missing referenced files (orphaned photoUrls)
  - Version backup format for forward compatibility

#### **5. Authentication & Password Recovery (Local-Only)**
- **Risk:** User forgets password, no email recovery possible
- **Complexity:** HIGH (UX problem more than technical)
- **Mitigation:**
  - **Option A:** Require email for account creation (enable reset via email)
  - **Option B:** Security questions for recovery (less secure)
  - **Option C:** Accept data loss if password forgotten (warn user prominently)
  - **Recommendation:** Option A if possible; Option C if truly local-only
  - Show password strength meter during registration
  - Suggest password manager integration

### 🟡 Moderate Risk Areas

#### **6. Image Processing Performance**
- **Risk:** Large images slow down upload/display
- **Complexity:** MEDIUM
- **Mitigation:**
  - Process images asynchronously (queue for background processing)
  - Generate thumbnails (200x200) for list views
  - Lazy load images in galleries
  - Cache compressed versions
  - Use progressive image formats (WebP with JPEG fallback)

#### **7. Database Schema Migrations**
- **Risk:** App updates break old databases, data loss
- **Complexity:** MEDIUM
- **Mitigation:**
  - Version database schema (user_version pragma in SQLite)
  - Write migration scripts for each version bump
  - Backup database before migration
  - Test migrations on copy of production data
  - Rollback capability if migration fails

#### **8. Search Performance at Scale**
- **Risk:** Search slows down with 1000+ records
- **Complexity:** MEDIUM
- **Mitigation:**
  - Add database indexes on searchable columns (pet.name, reminder.title)
  - Implement pagination (load 50 results at a time)
  - Debounce search input (wait 300ms after user stops typing)
  - Use FTS (Full-Text Search) extension in SQLite for complex queries
  - Limit search scope (e.g., last 6 months by default)

---

## 6. Integration Points & Dependencies

### External Services

| Service | Purpose | Priority | Alternative |
|---------|---------|----------|-------------|
| **Firebase Cloud Messaging (FCM)** | Push notifications | High | Local notifications only |
| **SendGrid / AWS SES** | Invitation emails | Low (Phase 2+) | Skip multi-user for MVP |
| **Cloudinary / AWS S3** | Cloud photo storage | Low (future sync) | Local filesystem for MVP |
| **Google OAuth** | Social login | Low (deferred) | Username/password only |

### Libraries & Dependencies

| Library | Purpose | Priority | Notes |
|---------|---------|----------|-------|
| **multer** | File upload middleware | High | For photo/document uploads |
| **sharp** | Image processing | High | Compress, resize, thumbnail generation |
| **node-cron** | Background jobs | High | Reminder notifications |
| **bcrypt** | Password hashing | High | Already in use |
| **jsonwebtoken** | JWT auth | High | Already in use |
| **better-sqlite3** | SQLite driver | High | Already in use |
| **crypto (Node.js)** | Backup encryption | Medium | AES-256-GCM for backups |
| **json2csv** | CSV export | Low | Data export feature |
| **pdfkit** | PDF generation | Low | PDF reports |

---

## 7. Effort Estimation

### Backend Development Effort (for new features)

| Feature | Priority | Effort | Developer Days |
|---------|----------|--------|----------------|
| Weight tracking (table + CRUD endpoints) | High | Low | 1-2 days |
| Photo gallery (tables + file uploads + CRUD) | High | Medium | 3-4 days |
| Notification system (table + cron jobs + FCM) | High | Medium-High | 4-5 days |
| Profile photo upload | High | Low | 1 day |
| Vaccinations module | Medium | Medium | 2-3 days |
| Services module | Medium | Low | 2 days |
| Documents module | Medium | Medium | 2-3 days |
| Logs/Journal module | Medium | Low-Medium | 2-3 days |
| Medications module | Low | Medium | 3-4 days |
| Multi-user collaboration | Low | High | 7-10 days |
| Emergency contacts | Low | Low | 1 day |
| Insurance info | Low | Low | 1 day |
| Enhanced data export | Low | Medium | 2-3 days |

**Total Estimated Backend Effort:**
- **MVP (High Priority):** 10-12 developer days (~2 weeks)
- **Post-MVP Phase 1 (Medium Priority):** 8-11 developer days (~2 weeks)
- **Phase 2+ (Low Priority):** 14-19 developer days (~3-4 weeks)

**Note:** Estimates assume 1 backend developer working full-time. Adjust for team size and experience.

---

## 8. Recommendations

### For MVP Launch (Phase 1)

✅ **MUST IMPLEMENT:**
1. Weight tracking (users expect this)
2. Photo gallery (visual appeal, engagement)
3. Notification system (reminders are useless without notifications)
4. Profile photo upload (basic feature)

⚠️ **DEFER TO POST-MVP:**
- Vaccinations (nice-to-have, not critical)
- Services (can track in reminders for MVP)
- Documents (can store in device gallery for MVP)
- Logs/Journal (users rarely use journaling features)

❌ **SKIP ENTIRELY FOR MVP:**
- Multi-user collaboration (complex, niche use case)
- Medications module (can use reminders + notes for MVP)
- Advanced reports/exports (users rarely export data)

### Architecture Recommendations

1. **Start Truly Local-First:**
   - Use SQLite for all data (no backend API calls for MVP)
   - Implement backend endpoints but don't require server for app to function
   - Backup/restore is only time app talks to server (or export to file)

2. **Optimize for Offline-First:**
   - Queue actions when offline, sync when online
   - Show cached data immediately, refresh in background
   - Clear "Syncing..." indicators for user feedback

3. **Keep Backend Stateless:**
   - No session storage (JWT for auth)
   - No WebSocket connections (use polling for notifications)
   - Easy to deploy on serverless (AWS Lambda, Vercel)

4. **Plan for Migration:**
   - Version all API responses (`{version: "1.0", data: {...}}`)
   - Version database schema (SQLite user_version)
   - Write migration scripts before schema changes

### API Design Principles

1. **RESTful & Predictable:**
   - `GET /pets/:id/weights` - Get all weights for pet
   - `POST /pets/:id/weights` - Add new weight
   - `PUT /pets/:id/weights/:weightId` - Update weight
   - `DELETE /pets/:id/weights/:weightId` - Delete weight

2. **Consistent Response Format:**
   ```json
   {
     "success": true,
     "data": {...},
     "error": null,
     "timestamp": "2026-03-29T10:00:00Z"
   }
   ```

3. **Use Query Params for Filtering:**
   - `/pets/:id/weights?startDate=2026-01-01&endDate=2026-03-01`
   - `/reminders?status=pending&overdue=true`

4. **Support Batch Operations (if needed later):**
   - `POST /pets/:id/weights/batch` - Add multiple weights at once
   - Reduces API calls, improves performance

---

## 9. Summary

### Clean Mappings (Already Covered)
- ✅ Auth, pets, reminders, dashboard → Implemented (Phase 0-3 complete)
- ✅ Expenses, budget, settings, backup → Planned (LOCAL_BACKUP_PERSISTENCE.md)

### New Features to Add (MVP)
- 🔶 Weight tracking (1-2 days)
- 🔶 Photo gallery (3-4 days)
- 🔶 Notifications (4-5 days)
- 🔶 Profile photo (1 day)
- **Total: ~10-12 days backend work**

### Conflicts Resolved
- ⚠️ Reminders vs. Medications → Keep generic for MVP
- ⚠️ Budget vs. Expenses → Budget is calculated view over expenses
- ⚠️ Profile photo vs. Gallery → Keep separate, allow setting gallery photo as profile

### High-Risk Areas to Watch
- 🔴 File uploads (storage limits, compression, validation)
- 🔴 Notifications (reliability, timezone handling, offline queueing)
- 🔴 Backup integrity (validation, conflict detection, rollback)
- 🔴 Password recovery (no recovery = bad UX if local-only)

### Total Backend Effort
- **MVP:** 2 weeks
- **Post-MVP Phase 1:** 2 weeks
- **Phase 2+:** 3-4 weeks
- **Total for full feature parity with reference app:** 7-8 weeks backend work

---

**Next Phase:** Implementation Roadmap (Phase 6) - Convert everything into a prioritized build plan with component breakdown and step-by-step development order.
