# PET-CARE APP: UI REDESIGN + FEATURE COMPLETION + PERSISTENCE STRATEGY
**Last Updated:** 2025-03-28  
**Status:** Ready for implementation  
**Tech Stack:** [Frontend: React/Vue/etc] [Backend: Node.js/Express] [Database: SQLite] [Images: Local filesystem]

---

## 🎯 EXECUTIVE SUMMARY

You have a functional pet-care application that needs:
1. **UI Overhaul** – Modern, cohesive design with warm + cool color palettes
2. **Feature Completion** – Fix broken dashboard cards, add budget page, build account page
3. **Data Persistence** – Implement local backup/import with optional encryption

This document specifies ALL requirements, design decisions, and implementation approach.

---

## PART 1: DESIGN SYSTEM OVERHAUL

### 1.1 Design Reference
**Inspiration:** https://cdn.dribbble.com/userupload/45435724/file/035469a2e03139b7e9e5bb6e5313a450.png

**Design Goals:**
- Match reference image's modern, clean aesthetic
- Create consistent, reusable component library
- Support two color palettes (users toggle in Account page)
- Maintain all existing functionality (no content loss)
- Improve visual hierarchy and spacing

---

### 1.2 Color Palettes

#### 🔶 **WARM PALETTE** (default)
Suitable for: Cozy, welcoming, pet-focused feel

| Role | Color | Usage |
|------|-------|-------|
| Primary | `#FF8C42` | CTAs, active states, pet accents |
| Secondary | `#FFB380` | Hover states, lighter accents |
| Accent | `#FD6B6B` | Alerts, overdue tasks, warnings |
| Background | `#FFF9F5` | Page backgrounds, cards |
| Surface | `#FFFFFF` | Card backgrounds, input fields |
| Text Primary | `#2C2C2C` | Body text, headings |
| Text Secondary | `#7A7A7A` | Labels, secondary info |
| Success | `#52B788` | Completed tasks, confirmations |
| Border | `#E8D4C8` | Dividers, input borders |

#### 💙 **CLEAN PALETTE** (secondary)
Suitable for: Modern, minimal, focus-driven feel

| Role | Color | Usage |
|------|-------|-------|
| Primary | `#4A90E2` | CTAs, active states |
| Secondary | `#81B4E6` | Hover states, lighter accents |
| Accent | `#FF6B6B` | Alerts, overdue tasks |
| Background | `#F5F7FA` | Page backgrounds, cards |
| Surface | `#FFFFFF` | Card backgrounds, input fields |
| Text Primary | `#1A1A2E` | Body text, headings |
| Text Secondary | `#6C7A8C` | Labels, secondary info |
| Success | `#4CAF50` | Completed tasks, confirmations |
| Border | `#E2E8F0` | Dividers, input borders |

**Implementation:** Use CSS variables (`:root`) for theme switching; persist selection in localStorage + backend account settings.

---

### 1.3 Typography

- **Headings (H1-H3):** `Poppins` (600-700 weight) – bold, friendly, modern
- **Body & UI Text:** `Inter` (400-500 weight) – clean, readable, neutral
- **Monospace (if needed):** `Courier Prime` – for data/amounts

**Font Sizes:**
- H1: 2.5rem (32px) | H2: 1.75rem (28px) | H3: 1.25rem (20px)
- Body: 1rem (16px) | Small: 0.875rem (14px)

---

### 1.4 Spacing & Layout

- **Base unit:** 8px
- **Card padding:** 16px or 24px
- **Page margins:** 16px (mobile) / 24px (desktop)
- **Gap between sections:** 32px
- **Border radius:** 12px (standard), 20px (rounded cards)

---

### 1.5 Component Library (to be built)

Each component should:
- Accept a `theme` prop (or use context) for palette switching
- Use CSS variables for colors
- Include hover/active states
- Be responsive (mobile-first)

**Components needed:**
- [ ] Button (primary, secondary, icon)
- [ ] Card (with optional header, footer)
- [ ] Input fields (text, number, date, select)
- [ ] Modal/Dialog
- [ ] Tabs/Navigation
- [ ] Chart containers (for budget)
- [ ] Badge/Tag
- [ ] Avatar (for pet/user photo)

---

## PART 2: FEATURE COMPLETION

### 2.1 Dashboard Status Cards (BROKEN → FUNCTIONAL)

**Current State:** Three cards show numbers (Completed, Pending, Overdue) but are not interactive.

**Required Behavior:**
When a user clicks a card, they should see:
- [ ] **Option A:** Filter the task list below to show only tasks in that status
- [ ] **Option B:** Navigate to a dedicated `/tasks?filter=pending` page with full task list
- [ ] **Option C:** Show a modal with summary + quick-view task list

**Recommendation:** Implement **Option A** (filters task list below) for MVP – simpler UX, no page navigation needed.

**Implementation Details:**
1. Add click handler to each card
2. Set state: `activeFilter` = "completed" | "pending" | "overdue" | null
3. Filter task list component based on `activeFilter`
4. Highlight active card with primary color
5. Add clear button or click again to deselect filter

**Data needed:**
- Total count per status (computed from tasks)
- Ability to filter tasks array by status

---

### 2.2 Budget Page (NEW – FULL PAGE)

**Route:** `/budget` or `/finances`

**Features:**

#### 2.2.1 Budget Setup per Pet
- Display list of all pets (from database)
- For each pet:
  - Show current monthly budget (or allow edit)
  - Input field to set/update budget
  - Save button

#### 2.2.2 Spending Tracker
- Show amount spent this month vs. budget for each pet
- Visual indicator (progress bar or percentage)
- Color coding:
  - Green: < 50% of budget
  - Yellow: 50-80% of budget
  - Red: > 80% of budget (warning)

#### 2.2.3 Monthly Spending History
- **Chart visualization:** Line chart (trends over time) + Bar chart (month-to-month comparison)
  - X-axis: Month (Jan–Dec or last 12 months)
  - Y-axis: Amount spent ($)
  - Multiple lines/bars per pet (different colors)
- **Table view (optional):** Month, Budget, Spent, Remaining, % Used
- **Summary stats:** Total spent, total budget, total remaining

#### 2.2.4 Budget Statement
- Month-to-month breakdown
- Optional export button (PDF or CSV)
- Timestamp of data

#### 2.2.5 Optional: Budget Alerts
- Notify user when spending exceeds 75% of monthly budget
- Notification badge on Budget tab

**Layout Suggestion:**
```
┌─ Budget / Finances Page ─────────────────┐
│                                          │
│ [Selector: Pet dropdown or all pets]    │
│                                          │
│ ┌─ Budget Setup ──────────────────────┐  │
│ │ Pet Name | Budget | Action (Edit)   │  │
│ │ Fluffy   | $200   | [Edit]          │  │
│ │ Max      | $150   | [Edit]          │  │
│ └──────────────────────────────────────┘  │
│                                          │
│ ┌─ Spending Overview ──────────────────┐  │
│ │ Pet: Fluffy | Budget: $200          │  │
│ │ Spent: $120 (60%) [Progress bar]    │  │
│ │ Remaining: $80                       │  │
│ └──────────────────────────────────────┘  │
│                                          │
│ ┌─ Monthly Trends ─────────────────────┐  │
│ │ [Line chart showing last 12 months]  │  │
│ └──────────────────────────────────────┘  │
│                                          │
│ ┌─ Month-to-Month Comparison ─────────┐  │
│ │ [Bar chart or table]                 │  │
│ └──────────────────────────────────────┘  │
│                                          │
│ [Export as PDF] [Export as CSV]        │  │
└──────────────────────────────────────────┘
```

**Data Model:**
```javascript
// Spending record
{
  id: uuid,
  petId: uuid,
  amount: number,
  category: string (e.g., "food", "vet", "toys", "other"),
  date: ISO datetime,
  description: string,
  receipt: optional file
}

// Budget
{
  petId: uuid,
  month: "YYYY-MM",
  budgetAmount: number,
  alerts: boolean
}
```

---

### 2.3 Account / Profile Page (NEW – FULL PAGE)

**Access:** Circle button fixed bottom-right on every page (or navbar option – your choice)
**Route:** `/account` or `/profile`

**Sections:**

#### 2.3.1 Profile Section
- [ ] Avatar (clickable to upload/change)
- [ ] User name (editable)
- [ ] Email (from auth)
- [ ] User since date

#### 2.3.2 Connected Accounts
- [ ] Google account (show connected status + email)
- [ ] "Connect with Google" button (if not connected)
- [ ] "Disconnect" button (if connected)

#### 2.3.3 Preferences & Settings
- [ ] **Notifications Settings**
  - Toggle: Task reminders
  - Toggle: Budget alerts
  - Toggle: Appointment reminders
  - Email: Set preferred notification email

- [ ] **Display Settings**
  - Theme toggle: Light / Dark / Auto
  - Color Palette: Warm / Clean (radios or toggle)
  - Font size: Small / Normal / Large
  
- [ ] **Wallpaper / Background**
  - Option 1: Upload custom pet photo
  - Option 2: Select from preset pet-themed wallpapers
  - Preview window showing current selection
  - "Set as wallpaper" button
  - "Reset to default" button

#### 2.3.4 Payment & Subscription
- [ ] Subscription status (free / premium / etc.)
- [ ] Payment method on file (masked card info, or "None")
- [ ] "Update payment method" button
- [ ] Billing history (if applicable)

#### 2.3.5 Privacy & Legal
- [ ] "Privacy Policy" link (opens modal or external)
- [ ] "Terms of Service" link
- [ ] "Data & Privacy" section (explain what data is stored locally)

#### 2.3.6 Backup & Data Management
- [ ] "Backup now" button → triggers local backup
- [ ] "Restore from backup" button → file picker
- [ ] "Export data" button → download as JSON/CSV
- [ ] "Clear all data" button → confirmation modal

#### 2.3.7 Account Actions
- [ ] "Switch account" button → logout + return to login
- [ ] "Logout" button → clear session + navigate to login

**Layout Suggestion:**
```
┌─ Account Page ───────────────────────────┐
│                                          │
│ ┌─ Profile ──────────────────────────┐  │
│ │ [Avatar] Arslan                    │  │
│ │ arslan@example.com                 │  │
│ │ Member since Mar 2024              │  │
│ │ [Edit Profile] [Change Avatar]     │  │
│ └──────────────────────────────────────┘  │
│                                          │
│ ┌─ Connected Accounts ────────────────┐  │
│ │ Google: connected@gmail.com [X]    │  │
│ │ [+ Connect another account]        │  │
│ └──────────────────────────────────────┘  │
│                                          │
│ ┌─ Preferences ───────────────────────┐  │
│ │ Theme: [Light] [Dark] [Auto]       │  │
│ │ Palette: [Warm] [Clean]            │  │
│ │ Font size: [Small] [Normal] [Large]│  │
│ └──────────────────────────────────────┘  │
│                                          │
│ ┌─ Notifications ─────────────────────┐  │
│ │ ☑ Task reminders                   │  │
│ │ ☑ Budget alerts                    │  │
│ │ ☑ Appointment reminders            │  │
│ │ Email: [input field]               │  │
│ └──────────────────────────────────────┘  │
│                                          │
│ ┌─ Wallpaper ─────────────────────────┐  │
│ │ [Preview image]                    │  │
│ │ [Upload custom] [Choose preset]    │  │
│ │ [Set as wallpaper] [Reset]         │  │
│ └──────────────────────────────────────┘  │
│                                          │
│ ┌─ Payment & Subscription ────────────┐  │
│ │ Status: Free                       │  │
│ │ [Update payment method]            │  │
│ │ [View billing history]             │  │
│ └──────────────────────────────────────┘  │
│                                          │
│ ┌─ Data Management ───────────────────┐  │
│ │ [Backup now] [Restore]             │  │
│ │ [Export data] [Clear all]          │  │
│ └──────────────────────────────────────┘  │
│                                          │
│ ┌─ Privacy ───────────────────────────┐  │
│ │ [Privacy Policy] [Terms of Service]│  │
│ │ [Data & Privacy Info]              │  │
│ └──────────────────────────────────────┘  │
│                                          │
│ [Switch account] [Logout]              │  │
│                                          │
└──────────────────────────────────────────┘
```

---

## PART 3: LOCAL PERSISTENCE & BACKUP STRATEGY

### 3.1 Architecture Overview

**Goal:** Enable reliable local data persistence with optional backup/import capabilities.

**Key Decisions:**
- Database: SQLite (already mentioned in your setup)
- Image storage: External files (not in DB) in `data/images/` directory
- Backups: Optional encrypted JSON + SQLite export
- Session: JWT with local secret (short-lived: 24h)
- Password hashing: bcrypt

---

### 3.2 Authentication (Minimal but Secure)

**Setup:**
```
Users table:
├── id (PK, UUID)
├── username (UNIQUE, required)
├── email (optional, UNIQUE if provided)
├── passwordHash (bcrypt hash)
├── salt (bcrypt includes this)
├── createdAt (timestamp)
└── updatedAt (timestamp)
```

**Flow:**
1. User enters username + password on login screen
2. App queries DB for user record by username
3. Compare input password vs. passwordHash using bcrypt.compare()
4. If match → generate JWT signed with local secret key (stored in `config/.env`, NOT committed)
5. Store JWT in localStorage or sessionStorage (short-lived: 24 hours)
6. On each request, include JWT in Authorization header
7. Middleware verifies JWT signature; if invalid/expired, redirect to login

**Recommendations:**
- Username + password (both required) is the minimal sensible setup
- Alternative: email-based login (more modern, same security)
- For MVP: skip Google auth integration (add later)
- Bcrypt cost factor: 10 (good balance of speed/security for local app)

---

### 3.3 Data Persistence Tiers

| Data | Must Persist? | Where | Frequency |
|------|---------------|-------|-----------|
| Users | ✅ YES | SQLite | On create/update |
| Pets | ✅ YES | SQLite | On create/update |
| Tasks/Reminders | ✅ YES | SQLite | On create/update |
| Spending records | ✅ YES | SQLite | On create/update |
| Account settings | ✅ YES | SQLite | On update |
| Pet images | ✅ YES | Filesystem (`data/images/`) | On upload |
| UI state (collapsed sidebars, etc.) | ❌ NO | localStorage | Auto (React state) |
| Thumbnails/cache | ❌ NO | In-memory or temp | Auto (clear on restart) |

---

### 3.4 Backup & Import System

**Design:** Three-tier approach (pick what you want)

#### 3.4.1 **TIER 1: Simple JSON Export** (Recommended for MVP)
- No encryption
- Exports all tables as JSON + list of image file paths
- User can inspect it
- Easy to restore

```json
{
  "version": "1.0",
  "exportedAt": "2025-03-28T14:30:00Z",
  "data": {
    "users": [...],
    "pets": [...],
    "tasks": [...],
    "spending": [...],
    "settings": [...]
  },
  "imageManifest": [
    "data/images/pet-fluffy-avatar.jpg",
    "data/images/pet-max-avatar.jpg"
  ]
}
```

**Pros:** Simple, human-readable, debuggable  
**Cons:** No encryption, larger file size

---

#### 3.4.2 **TIER 2: Encrypted JSON Export** (Optional enhancement)
- Encrypt JSON using account password (via crypto.subtle or Node.js crypto)
- Include salt + IV in backup file header
- More secure if backup is shared

```json
{
  "version": "1.0",
  "encrypted": true,
  "algorithm": "AES-256-GCM",
  "salt": "...",
  "iv": "...",
  "authTag": "...",
  "data": "..."
}
```

**Pros:** Encrypted, password-protected  
**Cons:** More complex, if password changes old backups need re-encryption or recovery key

---

#### 3.4.3 **TIER 3: SQLite Snapshot** (Optional)
- Direct SQLite file export (no transformation)
- User can back it up to cloud storage, version control, etc.
- Smallest file size

**Pros:** Full DB snapshot, smallest file  
**Cons:** Not human-readable, requires SQLite tool to inspect

---

### 3.5 Implementation Approach for MVP

**Recommend: TIER 1 + optional TIER 2**

1. **Backup creation:**
   - User clicks "Backup now" in Account page
   - App queries all tables from SQLite
   - App lists all image files in `data/images/`
   - Bundle into JSON file
   - (Optional) Encrypt using account password
   - Download as `petapp-backup-2025-03-28.json` (or `.json.encrypted`)

2. **Import / Restore:**
   - User clicks "Restore from backup" in Account page
   - File picker → select backup JSON file
   - (If encrypted) Prompt for password, decrypt
   - Validate JSON structure (schema check)
   - Ask: "Overwrite existing data?" (yes/no confirmation)
   - Insert all records into SQLite, copy images from backup
   - Reload app state

3. **Testing during development:**
   - After each feature addition, create a test backup
   - Delete/corrupt some data
   - Test restore
   - Verify data integrity
   - Document in `TESTING_CHECKLIST.md`

---

### 3.6 Backup File Structure (on disk)

```
project-pet-care/
├── data/
│   ├── images/
│   │   ├── pet-fluffy-avatar.jpg
│   │   ├── pet-max-profile.png
│   │   └── ...
│   ├── sqlite/
│   │   └── petapp.db (SQLite database file)
│   └── backups/
│       ├── petapp-backup-2025-03-28.json
│       ├── petapp-backup-2025-03-27.json
│       └── ...
├── config/
│   ├── .env (local secret, NOT committed)
│   └── database.js
└── ...
```

---

### 3.7 Persistence Enforcement Matrix

| Component | Enforce? | How | Notes |
|-----------|----------|-----|-------|
| User login | ✅ YES | Session/JWT check on every route | Redirect to login if missing |
| Pet data save | ✅ YES | Write to SQLite before returning success | Prevent orphaned data |
| Image upload | ✅ YES | Write to disk + DB record in same transaction | Link must always exist |
| Settings change | ✅ YES | Batch update SQLite | Auto-save or explicit save button |
| Task completion toggle | ✅ YES | Update in SQLite | Immediately reflect in UI |
| UI preferences (theme) | ❌ NO | localStorage (or DB optional) | OK if lost on browser clear |
| Thumbnails | ❌ NO | In-memory, regenerate on demand | Cache for performance, not critical |

---

## PART 4: IMPLEMENTATION ROADMAP

### Phase 1: Design System (Week 1)
- [ ] Create CSS variables for both color palettes
- [ ] Build reusable component library (Button, Card, Input, etc.)
- [ ] Apply styling to existing pages
- [ ] Implement theme toggle in Account page

### Phase 2: Feature Fixes (Week 2)
- [ ] Make dashboard cards functional (filter tasks)
- [ ] Build Budget page with charts + spending tracker
- [ ] Build Account page with all settings

### Phase 3: Authentication & Persistence (Week 2-3)
- [ ] Implement bcrypt password hashing
- [ ] Create JWT session management
- [ ] Build backup/import system (Tier 1 + optional Tier 2)
- [ ] Add Account page data management buttons

### Phase 4: Testing & Polish (Week 3-4)
- [ ] Test backup/restore cycle
- [ ] Test theme switching
- [ ] Test all feature interactions
- [ ] Document in `/docs/mvp/`

---

## PART 5: DOCUMENTATION & TESTING

### 5.1 Files to Create/Update

```
docs/mvp/
├── 00-OVERVIEW.md (existing – update with this plan)
├── 01-API_CONTRACT.md (existing – add new endpoints)
├── 02-UI_DESIGN_SYSTEM.md (NEW – colors, components, layouts)
├── 03-FEATURE_SPECIFICATIONS.md (NEW – detailed specs for each feature)
├── 04-PERSISTENCE_STRATEGY.md (NEW – backup, auth, data tiers)
├── 05-TESTING_CHECKLIST.md (NEW – QA steps, edge cases)
└── 06-DEPLOYMENT.md (NEW – how to run locally)
```

### 5.2 Testing Checklist

```markdown
## Backup / Restore Testing

- [ ] Create new user, add 3 pets
- [ ] Create tasks, spending records
- [ ] Click "Backup now", verify JSON downloads
- [ ] Delete a pet from DB manually (simulate corruption)
- [ ] Click "Restore", select backup, verify all data restored
- [ ] Test with encryption enabled (if implementing Tier 2)
- [ ] Test import with corrupted backup file (should show error)
- [ ] Test overwrite confirmation (cancel vs. confirm)

## Dashboard Cards Testing

- [ ] Cards display correct counts
- [ ] Clicking "Pending" card filters task list
- [ ] Clicking card again deselects filter
- [ ] Filter persists if navigating away and back (or resets – decide)

## Budget Page Testing

- [ ] Can set budget for each pet
- [ ] Spending tracking shows correct amount
- [ ] Progress bar changes color based on % used
- [ ] Charts render with sample data
- [ ] Export to PDF/CSV works

## Theme / Wallpaper Testing

- [ ] Toggle between Warm and Clean palettes
- [ ] Upload custom pet image as wallpaper
- [ ] Wallpaper persists after page reload
- [ ] Select preset wallpaper option works
- [ ] Reset to default removes wallpaper
```

---

## PART 6: ANSWERS TO YOUR SPECIFIC QUESTIONS

### Q1: Require username + password, or password-only?
**Answer:** **Username + password (both required)** is the minimal sensible approach, especially if you want distinct multi-user support or account management later. If it's single-user only, password-only could work, but username is still useful for future expansion.

**Setup for MVP:**
```javascript
// Users table
{ id, username (UNIQUE), passwordHash, salt, createdAt }

// Login
POST /api/auth/login { username, password }
// Returns JWT if valid
```

---

### Q2: Is password-only sufficient for a local app?
**Answer:** For a truly **single-user, fully local app** (no cloud, no sharing), password-only *could* work, but I'd still recommend username because:
- Better UX (clearer what you're logging in as)
- Aligns with standard auth patterns
- Future-proofs for multi-user or family sharing

---

### Q3: Backup size limit – necessary?
**Answer:** **Yes, set a cap of 100 MB (soft), 200 MB (hard limit).** Even though your data will be small (few MB), enforcing a limit:
- Prevents accidental runaway backups (e.g., if someone adds 1000 images)
- Protects app memory during export
- Keeps exports manageable for sharing

**Implementation:**
```javascript
const MAX_BACKUP_SIZE = 100 * 1024 * 1024; // 100 MB
if (backupSize > MAX_BACKUP_SIZE) {
  throw new Error('Backup too large. Please delete old images or data.');
}
```

---

### Q4: Tie encryption to account password?
**Answer:** **Yes, for MVP**, but with a caveat:

- **Pro:** Convenient, no separate recovery key to manage
- **Con:** If password changes, old backups become unreadable

**Recommendation for MVP:**
- Use account password to encrypt by default
- Offer optional separate "Backup Recovery Key" (user can generate once, store separately)
- If user changes password, show warning: "Old encrypted backups will need recovery key to restore"

**For simplicity, you could skip encryption entirely in MVP**, offer it as an opt-in checkbox:
```
[ ] Encrypt backup with my password (recommended for security)
```

---

### Q5: Am I over-engineering this?
**Answer:** **Somewhat, but justified.** Here's the breakdown:

**Keep (worth it):**
- SQLite persistence (reliable, lightweight)
- JWT sessions (standard, secure)
- Bcrypt password hashing (industry best practice)
- Image file separation (cleaner than storing BLOBs)
- JSON export/import (debugging, manual restore)

**Simplify / Skip (for MVP):**
- Cloud backups (skip – local only)
- Encrypted backups (make optional, not default)
- Complex merge rules (overwrite only, for now)
- Multi-user permissions (single user, simple auth)
- Google OAuth (add later, password auth is fine)

**Verdict:** Your current plan is **reasonable for a real app**. It's not overkill; it's just proper engineering. Don't feel bad about it.

---

### Q6: What should I keep vs. simplify?
**Answer:**

| Feature | Keep? | Reason |
|---------|-------|--------|
| SQLite persistence | ✅ Keep | Lightweight, reliable, standard |
| Bcrypt hashing | ✅ Keep | Non-negotiable for security |
| JWT sessions | ✅ Keep | Standard web app pattern |
| Image files external to DB | ✅ Keep | Cleaner, easier to backup |
| JSON export/import | ✅ Keep | Essential for debugging, manual restore |
| Encrypted backups | 🟡 Optional | Nice-to-have, can add later |
| Cloud sync | ❌ Skip | Out of scope for MVP |
| Multi-user auth | ❌ Skip | Single user for now |
| Google OAuth | ❌ Skip | Password auth sufficient |
| Complex merge logic | ❌ Skip | Overwrite behavior is fine |

---

### Q7: Where enforce persistence vs. relax?
**Answer:**

**ENFORCE Persistence:**
- Users table (must exist)
- Pets table (cannot lose)
- Tasks/Reminders (core feature)
- Spending records (for budget tracking)
- Account settings (preferences)
- Image files (must link to pet records)

**RELAX Persistence:**
- UI state (collapsed menus, scroll position) → localStorage is OK
- Cached thumbnails → regenerate on demand
- Temporary upload files → auto-delete after processing
- Session state → expires after 24h (OK to lose)
- Analytics/logs → log to file, but not critical if lost

**Example transaction pattern:**
```javascript
// When user uploads pet image
try {
  await writeImageToFile(file); // Persist image first
  await saveImageRecordToDB(petId, filename); // Then DB
} catch (err) {
  // If DB fails, delete image file (rollback)
  await deleteImageFile(filename);
  throw err;
}
```

---

## FINAL CHECKLIST: READY TO CODE?

- [ ] All questions answered
- [ ] Color palettes approved
- [ ] Feature specs reviewed
- [ ] Backup strategy clear
- [ ] File structure planned
- [ ] Testing approach defined
- [ ] Documentation outline created

**Next Steps:**
1. Review this document with your team/yourself
2. Confirm the three questions (dashboard cards, budget charts, account button placement)
3. Start Phase 1: Design System setup
4. Create `/docs/mvp/02-UI_DESIGN_SYSTEM.md` with CSS variables
5. Build component library
6. Iterate on dashboard, budget, account pages

---

**Questions? Ambiguities?** Reply with clarifications and I'll refine further.
