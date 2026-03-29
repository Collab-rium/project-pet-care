# 📋 PET-CARE APP: FEATURE TRACKING & TESTING LOG

**Project Path:** `/home/arslan/.openclaw/workspace/project-pet-care/`  
**Last Updated:** 2025-03-28  
**Status:** Ready for Phase 1 (Design System)

---

## QUICK REFERENCE

| Phase | Status | Start Date | End Date | Notes |
|-------|--------|-----------|----------|-------|
| Phase 1: Design System | ⏳ Not Started | — | — | Colors, fonts, components |
| Phase 2: Feature Implementation | ⏳ Not Started | — | — | Dashboard, Budget, Account |
| Phase 3: Persistence & Auth | ⏳ Not Started | — | — | SQLite, JWT, Backup system |
| Phase 4: Testing & Polish | ⏳ Not Started | — | — | QA, documentation, deployment |

---

## PHASE 1: DESIGN SYSTEM

### 1.1 Color Palette Variables

**Status:** ⏳ Pending

**Task:** Create `src/styles/variables.css` with both palettes

```css
/* Warm Palette */
:root[data-theme="warm"] {
  --color-primary: #FF8C42;
  --color-secondary: #FFB380;
  --color-accent: #FD6B6B;
  --color-bg-primary: #FFF9F5;
  --color-surface: #FFFFFF;
  --color-text-primary: #2C2C2C;
  --color-text-secondary: #7A7A7A;
  --color-success: #52B788;
  --color-border: #E8D4C8;
}

/* Clean Palette */
:root[data-theme="clean"] {
  --color-primary: #4A90E2;
  --color-secondary: #81B4E6;
  --color-accent: #FF6B6B;
  --color-bg-primary: #F5F7FA;
  --color-surface: #FFFFFF;
  --color-text-primary: #1A1A2E;
  --color-text-secondary: #6C7A8C;
  --color-success: #4CAF50;
  --color-border: #E2E8F0;
}
```

- [ ] Create CSS variables file
- [ ] Test theme toggle function (localStorage + DOM update)
- [ ] Verify both palettes render correctly
- [ ] Update existing pages to use variables

**Testing:**
- [ ] Switch between warm/clean → colors update instantly
- [ ] Refresh page → theme persists (check localStorage)
- [ ] Console: `localStorage.getItem('theme')` shows 'warm' or 'clean'

---

### 1.2 Typography & Fonts

**Status:** ⏳ Pending

**Task:** Import fonts and create typography scale

- [ ] Add `@import url('https://fonts.googleapis.com/css2?family=Poppins:wght@400;600;700&family=Inter:wght@400;500&display=swap');` to global CSS
- [ ] Create font utility classes (`.heading-1`, `.body`, `.small`, etc.)
- [ ] Apply to existing pages

**Testing:**
- [ ] H1 renders at 32px in Poppins 600
- [ ] Body text renders at 16px in Inter 400
- [ ] All text is readable on mobile (min 14px)

---

### 1.3 Reusable Component Library

**Status:** ⏳ Pending

**Components to build:**

| Component | File | Status | Notes |
|-----------|------|--------|-------|
| Button | `Button.jsx` | ⏳ | primary, secondary, icon variants |
| Card | `Card.jsx` | ⏳ | with optional header, footer |
| Input | `Input.jsx` | ⏳ | text, number, date, select |
| Modal | `Modal.jsx` | ⏳ | dialog, confirmation |
| Badge | `Badge.jsx` | ⏳ | status tags |
| Avatar | `Avatar.jsx` | ⏳ | user/pet photo |
| TabsNav | `TabsNav.jsx` | ⏳ | tab navigation |
| ProgressBar | `ProgressBar.jsx` | ⏳ | for budget tracking |
| ChartContainer | `ChartContainer.jsx` | ⏳ | wrapper for charts |

**Testing Template:**
```markdown
### Button Component
- [ ] Primary button renders with correct color
- [ ] Secondary button renders with correct color
- [ ] Hover state works (lighter shade)
- [ ] Disabled state works (grayed out)
- [ ] Icon button renders correctly
- [ ] Props work: `onClick`, `disabled`, `variant`, `size`
```

---

## PHASE 2: FEATURE IMPLEMENTATION

### 2.1 Dashboard Status Cards (Fix)

**Status:** ⏳ Pending

**File:** `src/pages/Dashboard.jsx`

- [ ] **Card 1: Completed** – Count + click handler
  - [ ] Clicking filters tasks to show only completed
  - [ ] Card highlights when active
  - [ ] Clicking again deselects filter
  
- [ ] **Card 2: Pending** – Count + click handler
  - [ ] Clicking filters tasks to show only pending
  - [ ] Card highlights when active
  - [ ] Clicking again deselects filter
  
- [ ] **Card 3: Overdue** – Count + click handler
  - [ ] Clicking filters tasks to show only overdue
  - [ ] Card highlights when active
  - [ ] Clicking again deselects filter

- [ ] Task list updates when filter changes
- [ ] Empty state message when no tasks match filter

**Testing:**
- [ ] Create 5 tasks: 2 completed, 2 pending, 1 overdue
- [ ] Click "Completed" card → verify only 2 tasks show
- [ ] Click again → verify filter deselects, all tasks show
- [ ] Repeat for Pending and Overdue

**Date:** Started: ___ | Completed: ___

---

### 2.2 Budget Page (NEW)

**Status:** ⏳ Pending

**File:** `src/pages/Budget/BudgetPage.jsx`

#### 2.2.1 Budget Setup Section
- [ ] Fetch all pets from DB
- [ ] Display table: Pet Name | Budget | Edit button
- [ ] Edit button opens modal to change budget
- [ ] Save to DB + update state

**Testing:**
- [ ] Add pet "Fluffy" with budget $200 → verify in table
- [ ] Edit budget to $250 → verify updates
- [ ] Add 3 pets → all appear in table

---

#### 2.2.2 Spending Tracker Section
- [ ] Fetch spending records for selected pet (current month)
- [ ] Calculate: Total Spent, Budget, Remaining, % Used
- [ ] Display progress bar (color: green <50%, yellow 50-80%, red >80%)

**Testing:**
- [ ] Budget $200, Spent $100 → shows 50%, yellow
- [ ] Budget $200, Spent $180 → shows 90%, red
- [ ] Budget $200, Spent $80 → shows 40%, green

---

#### 2.2.3 Monthly Trends Chart
- [ ] Fetch spending data for last 12 months
- [ ] Line chart: X-axis months, Y-axis amount
- [ ] Different color per pet (if multi-pet view)

**Library:** Use Chart.js, Recharts, or similar

**Testing:**
- [ ] Create spending records: Jan $100, Feb $120, Mar $150
- [ ] Line chart renders with correct points
- [ ] Hover shows month + amount

---

#### 2.2.4 Month-to-Month Comparison
- [ ] Bar chart: Jan | Feb | Mar | ... | Dec
- [ ] Show budget vs. actual spent
- [ ] Optional table view below chart

**Testing:**
- [ ] Bar chart renders with 12 months
- [ ] Colors distinguish budget vs. spent
- [ ] Click bar → shows summary modal (optional)

---

#### 2.2.5 Export Buttons
- [ ] "Export as PDF" → downloads `budget-{month}.pdf`
- [ ] "Export as CSV" → downloads `budget-{month}.csv`

**Testing:**
- [ ] Click export → file downloads
- [ ] Open CSV in spreadsheet → data matches page
- [ ] Open PDF → formatting looks good

**Date:** Started: ___ | Completed: ___

---

### 2.3 Account / Profile Page (NEW)

**Status:** ⏳ Pending

**File:** `src/pages/Account/AccountPage.jsx`

#### 2.3.1 Profile Section
- [ ] Display user avatar (clickable to upload)
- [ ] Show username (editable)
- [ ] Show email
- [ ] Show "Member since" date

**Testing:**
- [ ] Upload new avatar → image updates on page + persists
- [ ] Edit username → updates in DB + header
- [ ] All fields display correctly

---

#### 2.3.2 Connected Accounts
- [ ] Show Google connection status
- [ ] "Connect with Google" button (if not connected)
- [ ] "Disconnect" button (if connected)

**Testing:**
- [ ] Status shows "Not connected"
- [ ] Disconnect button appears after connecting
- [ ] Clicking disconnect → status updates

---

#### 2.3.3 Display Preferences
- [ ] Theme toggle: Light / Dark
- [ ] Palette toggle: Warm / Clean
- [ ] Font size: Small / Normal / Large

**Testing:**
- [ ] Toggle theme → page updates instantly
- [ ] Toggle palette → colors change
- [ ] Change font size → text resizes
- [ ] Refresh page → preferences persist

---

#### 2.3.4 Notifications Settings
- [ ] Toggle: Task reminders
- [ ] Toggle: Budget alerts
- [ ] Toggle: Appointment reminders
- [ ] Email input for notifications

**Testing:**
- [ ] Toggle each → state updates
- [ ] Save email address → persists in DB
- [ ] Disable reminders → no alerts show

---

#### 2.3.5 Wallpaper / Background
- [ ] Preview of current wallpaper
- [ ] "Upload custom" button → file picker
- [ ] "Choose preset" button → modal with pet themes
- [ ] "Set as wallpaper" button
- [ ] "Reset to default" button

**Testing:**
- [ ] Upload custom pet image → preview updates
- [ ] Select preset → preview updates
- [ ] Click "Set as wallpaper" → background changes on dashboard
- [ ] Refresh → wallpaper persists

---

#### 2.3.6 Payment & Subscription
- [ ] Display subscription status (Free / Premium / etc.)
- [ ] Show payment method on file
- [ ] "Update payment method" button

**Testing:**
- [ ] Status displays correctly
- [ ] Payment method shows masked info
- [ ] Button opens payment modal

---

#### 2.3.7 Data Management (CRITICAL for Backup Testing)
- [ ] "Backup now" button → downloads backup file
- [ ] "Restore from backup" button → file picker + restore
- [ ] "Export data" button → downloads JSON/CSV
- [ ] "Clear all data" button → confirmation modal

**Testing:** See Section 3 (Persistence & Backup)

---

#### 2.3.8 Account Actions
- [ ] "Switch account" button → logout + go to login
- [ ] "Logout" button → clear session + go to login

**Testing:**
- [ ] Click logout → session cleared, redirected to login
- [ ] Try to access dashboard → redirected to login
- [ ] Login with different user → correct user data loads

**Date:** Started: ___ | Completed: ___

---

## PHASE 3: PERSISTENCE & AUTHENTICATION

### 3.1 Authentication Setup

**Status:** ⏳ Pending

**Files:**
- `backend/models/User.js`
- `backend/routes/auth.js`
- `backend/middleware/authToken.js`
- `src/services/authService.js`

#### 3.1.1 User Model
```javascript
// Users table
{
  id: UUID,
  username: string (UNIQUE),
  email: string (UNIQUE, optional),
  passwordHash: string (bcrypt),
  salt: string (bcrypt includes),
  createdAt: timestamp,
  updatedAt: timestamp
}
```

- [ ] Create Users table in SQLite
- [ ] Add indexes on username, email

---

#### 3.1.2 Password Hashing (bcrypt)
- [ ] Install bcrypt: `npm install bcrypt`
- [ ] Hash password on signup (cost: 10)
- [ ] Compare password on login

**Testing:**
```bash
# Signup
POST /api/auth/signup
{ username: "arslan", password: "secret123" }
# Returns: { userId, token, message }

# Login
POST /api/auth/login
{ username: "arslan", password: "secret123" }
# Returns: { userId, token, message }

# Login with wrong password
POST /api/auth/login
{ username: "arslan", password: "wrong" }
# Returns: 401 Unauthorized
```

- [ ] Signup creates user with hashed password
- [ ] Login with correct password → returns JWT
- [ ] Login with wrong password → 401 error
- [ ] Verify bcrypt cost is 10 (takes ~100ms per hash)

---

#### 3.1.3 JWT Session Management
- [ ] Create JWT on login (secret from `.env`)
- [ ] Store JWT in localStorage
- [ ] Include JWT in Authorization header on all requests
- [ ] Middleware verifies JWT signature
- [ ] Refresh token endpoint (optional, for MVP skip)

**Testing:**
- [ ] Login → localStorage contains token
- [ ] Make request without token → 401 Unauthorized
- [ ] Make request with token → request succeeds
- [ ] Token expires after 24h (or test with shorter duration)
- [ ] Log out → token removed from localStorage

---

#### 3.1.4 Session Persistence
- [ ] On app load, check for token in localStorage
- [ ] Verify token is valid (not expired)
- [ ] If valid → load user data, stay logged in
- [ ] If invalid/missing → redirect to login

**Testing:**
- [ ] Login, refresh page → still logged in
- [ ] Close browser, reopen → still logged in (if token valid)
- [ ] Token expires → redirect to login

**Date:** Started: ___ | Completed: ___

---

### 3.2 Backup System

**Status:** ⏳ Pending

**Files:**
- `backend/routes/backup.js`
- `backend/services/backupService.js`
- `src/services/backupService.js` (frontend)

#### 3.2.1 Backup Creation (JSON Export)
```
POST /api/backup/create
Returns: { filename, size, createdAt, data: {...} }
Frontend: triggers download
```

- [ ] Query all tables from SQLite
- [ ] List all image files in `data/images/`
- [ ] Bundle into JSON structure:
  ```json
  {
    "version": "1.0",
    "exportedAt": "...",
    "userId": "...",
    "data": {
      "users": [...],
      "pets": [...],
      "tasks": [...],
      "spending": [...],
      "settings": [...]
    },
    "imageManifest": ["path/to/image1.jpg", "path/to/image2.jpg"]
  }
  ```
- [ ] Validate JSON structure
- [ ] Check total size (warn if > 100 MB)

**Testing:**
- [ ] Create 3 pets, 10 tasks, 20 spending records
- [ ] Click "Backup now" → JSON file downloads
- [ ] Open JSON in editor → verify all data present
- [ ] `imageManifest` lists all images from `data/images/`

---

#### 3.2.2 Backup Restoration (JSON Import)
```
POST /api/backup/restore
Body: { file (JSON), overwrite: boolean }
Returns: { status, imported: { users, pets, tasks, ... } }
```

- [ ] Accept JSON file from frontend
- [ ] Validate schema (check required fields)
- [ ] (Optional) Check size (reject if > 200 MB)
- [ ] Ask user: "Overwrite existing data?" (confirmation)
- [ ] If yes:
  - Delete existing data (or backup first?)
  - Insert records from JSON into SQLite
  - Copy images from backup manifest to `data/images/`
- [ ] Return success message + counts

**Testing:** (**CRITICAL**)
- [ ] Create backup of initial state (users, pets, tasks)
- [ ] Delete some data from DB manually
- [ ] Restore backup → verify all data restored
- [ ] Test with corrupted JSON (missing field) → error message
- [ ] Test with oversized backup → error or warning
- [ ] Restore to different machine → data transfers correctly

---

#### 3.2.3 Encrypted Backup (Optional, Tier 2)
- [ ] Toggle: "Encrypt backup with password"
- [ ] On create: encrypt JSON using bcrypt-derived key
- [ ] On restore: prompt for password, decrypt
- [ ] Store encrypted data + salt + IV in file header

**Testing (if implementing):**
- [ ] Create encrypted backup → downloads `.json.encrypted`
- [ ] Try to restore without password → error
- [ ] Restore with correct password → works
- [ ] Restore with wrong password → error

**Decision:** Skip for MVP, add later if needed.

---

#### 3.2.4 Testing Checklist (Per Feature Addition)

After each feature (e.g., after completing Budget page):

```markdown
## Backup/Restore Test for [Feature Name]

- [ ] Add 2-3 new spending records
- [ ] Click "Backup now" → JSON downloads
- [ ] Check JSON contains new spending records
- [ ] Delete spending records from DB (manual SQL)
- [ ] Click "Restore backup" → select JSON
- [ ] Verify spending records restored
- [ ] Check UI shows restored data
- [ ] Run "Backup now" again → verify latest backup includes all data
```

**Date:** Started: ___ | Completed: ___

---

### 3.3 Data Persistence Verification

**Status:** ⏳ Pending

- [ ] **Users persist:** Add user → refresh → user still there
- [ ] **Pets persist:** Add pet → restart app → pet still there
- [ ] **Tasks persist:** Add task → logout/login → task still there
- [ ] **Spending records persist:** Add record → refresh → record still there
- [ ] **Images persist:** Upload image → check `data/images/` → file exists
- [ ] **Settings persist:** Change theme → refresh → theme saved

**Date:** Started: ___ | Completed: ___

---

## PHASE 4: TESTING & POLISH

### 4.1 Comprehensive Feature Testing

| Feature | Test Case | Status |
|---------|-----------|--------|
| Theme Toggle | Switch Warm ↔ Clean | ⏳ |
| Dashboard Cards | Click each → filters work | ⏳ |
| Budget Page | Set budget, add spending, view charts | ⏳ |
| Account Page | All settings functional | ⏳ |
| Backup/Restore | Create, restore, verify data | ⏳ |
| Authentication | Signup, login, logout | ⏳ |
| Multi-pet | Add 5 pets, verify tracking works | ⏳ |

**Date:** Started: ___ | Completed: ___

---

### 4.2 Documentation

- [ ] Create `/docs/mvp/02-UI_DESIGN_SYSTEM.md`
- [ ] Create `/docs/mvp/03-FEATURE_SPECIFICATIONS.md`
- [ ] Create `/docs/mvp/04-PERSISTENCE_STRATEGY.md`
- [ ] Create `/docs/mvp/05-TESTING_CHECKLIST.md`
- [ ] Update `/docs/mvp/01-API_CONTRACT.md` with new endpoints
- [ ] Create `/docs/mvp/06-DEPLOYMENT.md` (how to run locally)

**Date:** Started: ___ | Completed: ___

---

### 4.3 Polishing

- [ ] Remove console.logs
- [ ] Fix any visual glitches
- [ ] Mobile responsiveness check
- [ ] Performance: check bundle size, optimize if needed
- [ ] Accessibility: keyboard navigation, screen reader compat

**Date:** Started: ___ | Completed: ___

---

## NOTES & LEARNINGS

Add observations as you implement:

```
## 2025-03-28
- Started design system setup
- Poppins font loaded successfully
- CSS variables working in both palettes

## [Date]
- [Note]
```

---

## QUICK COMMANDS

```bash
# Run local SQLite backup test
npm run backup:test

# Check database schema
npm run db:schema

# Reset database (dev only!)
npm run db:reset

# Export current state
npm run export:json

# View backup files
ls -la data/backups/
```

---

## FILES TO UPDATE AS YOU PROGRESS

- [x] Create this file: `FEATURE_TRACKING.md`
- [ ] Create: `/docs/mvp/02-UI_DESIGN_SYSTEM.md`
- [ ] Create: `/docs/mvp/03-FEATURE_SPECIFICATIONS.md`
- [ ] Create: `/docs/mvp/04-PERSISTENCE_STRATEGY.md`
- [ ] Create: `/docs/mvp/05-TESTING_CHECKLIST.md`
- [ ] Update: `/docs/mvp/01-API_CONTRACT.md`
- [ ] Create: `/docs/mvp/06-DEPLOYMENT.md`

---

**Questions? Issues? Update this file and ping me.**
