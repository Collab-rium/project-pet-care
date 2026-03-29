# FRONTEND MASTER PLAN - Pet Care App
**Date:** 2026-03-29  
**Approach:** Frontend first → confirm → backend follows  
**Timeline:** 2-3 weeks for MVP

---

## DESIGN SYSTEM

### Color Palettes (User Toggle in Settings)

**Warm Palette** (Default):
- Primary: `#FF8C42` | Secondary: `#FFB380` | Accent: `#FD6B6B` 
- Background: `#FFF9F5` | Text: `#2C2C2C` | Success: `#52B788`

**Clean Palette**:
- Primary: `#4A90E2` | Secondary: `#81B4E6` | Accent: `#FF6B6B`
- Background: `#F5F7FA` | Text: `#1A1A2E` | Success: `#4CAF50`

### Typography
- Headings: `Poppins` (600-700) | H1: 32px, H2: 28px, H3: 20px
- Body: `Inter` (400-500) | Body: 16px, Small: 14px

### Spacing
- Base: 8px | Card padding: 16-24px | Border radius: 12px

---

## PAGES & FEATURES

### 1. DASHBOARD (Fix Existing)
**What's broken:** Status cards show numbers but don't do anything

**Fix:**
- Click card → filter task list below (show only that status)
- Active card gets highlight border
- Click again → clear filter

**Components needed:**
- StatusCard (clickable)
- TaskList (filterable)
- FilterIndicator

---

### 2. BUDGET PAGE (New)
**Route:** `/budget`

**Layout:**
```
┌─────────────────────────────────────┐
│ Pet Selector Dropdown               │
├─────────────────────────────────────┤
│ Budget Setup: $5000/year [Edit]    │
├─────────────────────────────────────┤
│ Overview Cards:                     │
│ [Total: $5000] [Spent: $3200]      │
│ [Remaining: $1800] [64% used]      │
├─────────────────────────────────────┤
│ Spending History Table:             │
│ Date | Category | Amount | Notes   │
│ 03/28 | Vet | $150 | Checkup      │
│ ...                                 │
├─────────────────────────────────────┤
│ Chart: Spending Over Time           │
│ (Simple line chart)                 │
└─────────────────────────────────────┘
```

**Components needed:**
- PetSelector
- BudgetSetup
- SpendingOverviewCards
- SpendingHistoryTable
- SpendingChart (use Chart.js or Recharts)
- AddExpenseButton + Modal

**Features:**
- Filter by category/date
- Export to CSV
- Alert when >75% spent (optional)

---

### 3. ACCOUNT PAGE (New)
**Route:** `/account`  
**Access:** Floating circle button (bottom-right, all pages)

**Layout:**
```
┌─────────────────────────────────────┐
│ Profile                             │
│ [Avatar] Username                   │
│ Email: user@email.com               │
├─────────────────────────────────────┤
│ Settings:                           │
│ - Change Password                   │
│ - Theme Toggle (Warm/Clean)        │
│ - Wallpaper Settings               │
│ - Backup & Restore →               │
├─────────────────────────────────────┤
│ Payment & Subscription              │
│ [Upgrade to Pro] ← Shows "Coming Soon"│
├─────────────────────────────────────┤
│ Data Management                     │
│ - Storage Used: 12 MB               │
│ - Clear Cache                       │
│ - Export Data                       │
├─────────────────────────────────────┤
│ Other                               │
│ - Privacy Policy                    │
│ - Terms of Service                  │
│ - Logout                            │
└─────────────────────────────────────┘
```

**Components needed:**
- ProfileSection
- SettingsMenu
- PaymentPlaceholder (shows modal: "Coming Soon - Cloud Pro")
- DataManagement
- LogoutButton

---

### 4. BACKUP & RESTORE PAGE (New)
**Route:** `/backup`

**Layout:**
```
┌─────────────────────────────────────┐
│ Export Data                         │
│ [x] Include images in backup        │
│ [Export Now] → Downloads .pcbackup  │
│ Estimated size: 8 MB                │
├─────────────────────────────────────┤
│ Import Data                         │
│ [Choose File] my-backup.pcbackup    │
│ Password: [••••••••]                │
│ [Preview] → Shows counts            │
│                                     │
│ Preview:                            │
│ - Created: 2026-03-28               │
│ - Pets: 3, Reminders: 12           │
│                                     │
│ ⚠️ WARNING: Will overwrite data     │
│ [x] I understand                    │
│ [Import] ← Disabled until checked   │
└─────────────────────────────────────┘
```

**Components needed:**
- ExportSection
- ImportSection
- BackupPreview
- ConfirmationCheckbox

**Debug Mode:** If enabled in settings, show "Export as JSON (unencrypted)"

---

### 5. WALLPAPER SETTINGS (In Account Page)
**Route:** `/account/wallpaper` or modal

**Layout:**
```
┌─────────────────────────────────────┐
│ Current Wallpaper:                  │
│ [Preview Image]                     │
│ [Change] [Remove]                   │
├─────────────────────────────────────┤
│ Preset Wallpapers (8-12 options)    │
│ [🐶] [🐱] [🐦] [🐰] [🌿] [🎨]      │
├─────────────────────────────────────┤
│ Upload Custom                       │
│ [Choose Image] → Max 5MB            │
│ Crop/Position tool                  │
│ [Save]                              │
└─────────────────────────────────────┘
```

**Components needed:**
- WallpaperPreview
- PresetGrid
- ImageUpload + Cropper
- OpacitySlider (optional, for text readability)

---

## COMPONENT LIBRARY (Reusable)

Build once, use everywhere:

| Component | Props | Usage |
|-----------|-------|-------|
| Button | `variant, size, onClick` | primary, secondary, icon |
| Card | `header, children, footer` | wraps content |
| Input | `type, label, value, onChange` | text, number, date |
| Modal | `isOpen, onClose, children` | dialogs |
| Avatar | `src, size` | user/pet photos |
| Badge | `text, color` | status tags |
| ProgressBar | `value, max` | budget tracking |
| Dropdown | `options, value, onChange` | pet selector |

---

## STATE MANAGEMENT

Use React Context or Redux (your choice):

**Global State:**
- `auth` - currentUser, token
- `pets` - list of pets
- `reminders` - list of reminders
- `budget` - expenses, budgets
- `settings` - theme, wallpaper, preferences

**Local State:**
- Dashboard filter (which card clicked)
- Forms (controlled inputs)
- Modals (open/closed)

---

## API CONTRACTS (What Backend Needs to Provide)

Frontend will call these endpoints:

### Auth
- `POST /auth/login` → token
- `POST /auth/register` → user
- `POST /auth/logout` → success

### Pets
- `GET /pets` → array
- `POST /pets` → new pet
- `PUT /pets/:id` → updated pet
- `DELETE /pets/:id` → success

### Reminders
- `GET /reminders` → array
- `POST /reminders` → new reminder
- `PUT /reminders/:id` → updated
- `DELETE /reminders/:id` → success

### Dashboard
- `GET /dashboard/today` → {completed, pending, overdue, tasks[]}

### Budget (NEW)
- `GET /budget/:petId` → {totalBudget, spent, remaining, expenses[]}
- `POST /budget/expense` → new expense
- `PUT /budget/:petId` → update budget amount
- `GET /budget/export/:petId` → CSV file

### Backup (NEW)
- `GET /backup/export?includeImages=true` → .pcbackup file (encrypted)
- `POST /backup/preview` → manifest preview
- `POST /backup/import` → success/error

### Settings (NEW)
- `GET /settings` → {theme, wallpaper, debugMode}
- `PUT /settings` → updated settings

---

## MOCK DATA (For Frontend Development)

Use this to build frontend before backend ready:

```javascript
// Mock pets
const mockPets = [
  {id: '1', name: 'Max', type: 'dog', breed: 'Golden Retriever', imageUrl: '/images/pets/max.jpg'},
  {id: '2', name: 'Luna', type: 'cat', breed: 'Siamese', imageUrl: '/images/pets/luna.jpg'}
];

// Mock expenses
const mockExpenses = [
  {id: '1', petId: '1', category: 'Vet', amount: 150, date: '2026-03-28', notes: 'Annual checkup'},
  {id: '2', petId: '1', category: 'Food', amount: 50, date: '2026-03-25', notes: 'Dog food 10kg'}
];

// Mock budget
const mockBudget = {
  petId: '1',
  totalBudget: 5000,
  totalSpent: 3200,
  remaining: 1800,
  percentage: 64,
  expenses: mockExpenses
};
```

---

## DEVELOPMENT PHASES

### Phase 1: Design System (2-3 days)
- [ ] Set up CSS variables for both palettes
- [ ] Import fonts (Poppins, Inter)
- [ ] Build component library (Button, Card, Input, etc.)
- [ ] Test theme toggle

### Phase 2: Dashboard Fix (1 day)
- [ ] Make status cards clickable
- [ ] Add filter logic to task list
- [ ] Add active state styling
- [ ] Test filter clear

### Phase 3: Budget Page (3-4 days)
- [ ] Build page layout
- [ ] Pet selector dropdown
- [ ] Spending overview cards
- [ ] Expense history table
- [ ] Add expense form
- [ ] Line chart integration
- [ ] Use mock data to test

### Phase 4: Account Page (2-3 days)
- [ ] Profile section
- [ ] Settings menu
- [ ] Theme toggle
- [ ] Payment placeholder (modal: "Coming Soon")
- [ ] Data management section
- [ ] Floating account button (all pages)

### Phase 5: Backup & Restore (2-3 days)
- [ ] Export section (download mock .pcbackup)
- [ ] Import section (file picker + preview)
- [ ] Password input
- [ ] Confirmation checkbox
- [ ] Warning messages

### Phase 6: Wallpaper (2-3 days)
- [ ] Preset grid (find 8-12 pet images)
- [ ] Upload + crop tool
- [ ] Preview
- [ ] Save to localStorage (for now)
- [ ] Apply wallpaper to background

### Phase 7: Polish & Testing (3-4 days)
- [ ] Responsive design (mobile/tablet/desktop)
- [ ] Error handling (toast notifications)
- [ ] Loading states
- [ ] Form validation
- [ ] Cross-browser testing
- [ ] Accessibility check

**Total:** 15-21 days for frontend

---

## BACKEND REQUIREMENTS (To Build After Frontend)

When frontend confirmed and working with mocks, backend needs:

### Database (SQLite)
```sql
CREATE TABLE users (id, username, passwordHash, email, createdAt, updatedAt);
CREATE TABLE pets (id, userId, name, type, breed, imageUrl, createdAt, updatedAt);
CREATE TABLE reminders (id, userId, petId, title, scheduledTime, sent, sentAt, createdAt, updatedAt);
CREATE TABLE expenses (id, userId, petId, category, amount, date, notes, createdAt);
CREATE TABLE budgets (id, userId, petId, totalBudget, period, alertAt75, alertAt100, createdAt, updatedAt);
CREATE TABLE settings (userId, theme, wallpaper, debugMode);
```

### Backend Modules
- `backend/db.js` - SQLite connection + helpers
- `backend/backup.js` - Export/import with AES-256-GCM encryption
- `backend/budget.js` - Budget calculations + expense CRUD
- `backend/settings.js` - Settings CRUD

### Authentication
- JWT tokens (24h expiry)
- bcrypt password hashing (cost 10)

### File Storage
- Images: `backend/uploads/{userId}/pets/{petId}.jpg`
- Wallpapers: `backend/uploads/{userId}/wallpaper.jpg`

---

## NOTES

**Payment Button:** 
- Shows in Account page
- Clicking opens modal: "Cloud Pro Features Coming Soon! We're working on multi-device sync, cloud backups, and more. Stay tuned!"
- Just UI placeholder, no backend needed

**Google OAuth:**
- NOT included in MVP
- Can be added later as optional cloud sync feature
- Document separately if/when needed

**Auto-Backup:**
- NOT included
- Manual only for MVP

**Charts:**
- Just one line chart for spending over time
- Use Chart.js (simple) or Recharts (React-friendly)

---

## SUCCESS CRITERIA

Frontend is "done" when:
- [ ] All pages render correctly
- [ ] Navigation works (routing)
- [ ] Forms validate input
- [ ] Theme toggle works (persists in localStorage)
- [ ] Mock data displays in all pages
- [ ] Responsive on mobile/tablet/desktop
- [ ] No console errors
- [ ] User can complete full flow with mocks

Then backend implementation begins.

---

## FILES TO CLEAN UP

After consolidating into this file, remove:
- `files.zip` (already extracted)
- `PET_APP_DETAILED_QA.md` (merged here)
- `PET_APP_QUICK_REFERENCE.md` (merged here)
- `FEATURE_TRACKING.md` (use this file instead)

Keep only:
- `FRONTEND_MASTER_PLAN.md` (this file)
- `02-FRONTEND_CHECKLIST.md` (for task tracking)
- `PET_APP_MASTER_PROMPT.md` (reference if needed)
