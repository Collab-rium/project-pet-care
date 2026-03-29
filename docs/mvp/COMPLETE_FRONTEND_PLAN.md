# Complete Frontend Implementation Plan
## Pet Care App - Production Ready

**Date:** March 29, 2026  
**Status:** ✅ Planning Complete - Awaiting User Approval  
**Total Features:** 44 todos (6 newly added)  
**Estimated Timeline:** 25-28 days  
**Approach:** Frontend-first with SQLite mock data → Backend implementation → Production

---

## 🎯 Implementation Strategy

### Confirmed Decisions:
1. **Fonts:** Google Fonts package (Poppins + Inter)
2. **Testing:** Test as we go + comprehensive testing phase at end
3. **Git Commits:** One commit per todo completion
4. **Dark Mode:** Button present from day 1, fully functional once theme system complete
5. **Color Palette:** Warm (Orange #FF8C42)
6. **Mock Data:** SQLite with seed data (production-like)
7. **Existing Code:** Build on top of Phase 0-3 Flutter code

---

## 🆕 6 New Features Added

### 1. Dashboard Functional Cards (`fe-dashboard-cards`)
**Current:** 3 static placeholder cards  
**Target:** Interactive cards with real-time data

**Features:**
- ✅ Show accurate counts (Completed, Pending, Overdue) from reminders database
- ✅ Clickable cards navigate to filtered reminders view
- ✅ Overdue count highlighted in red with pulse animation
- ✅ Real-time updates when reminders change
- ✅ Empty state when count is 0
- ✅ Smooth count animation when values change

**Implementation:**
```dart
// Dashboard cards query reminders table
Completed: WHERE status = 'completed'
Pending:   WHERE status = 'pending' AND datetime >= NOW()
Overdue:   WHERE status = 'pending' AND datetime < NOW()

// On tap: Navigate with filter parameter
Navigator.pushNamed(context, '/reminders', arguments: {'filter': 'overdue'});
```

---

### 2. Enhanced Budget Page (`fe-budget-full-page`)
**Current:** Basic budget overview with simple chart  
**Target:** Comprehensive budget management system

**Full-Page Layout:**
```
┌───────────────────────────────────┐
│ [Pet Selector: Max ▼]            │
├───────────────────────────────────┤
│ ┌─────┐ ┌─────┐ ┌──────────┐    │
│ │Total│ │Spent│ │ Remaining│    │ Budget Summary Cards
│ │$500 │ │$320 │ │   $180   │    │
│ └─────┘ └─────┘ └──────────┘    │
├───────────────────────────────────┤
│ Monthly Spending Trend            │
│ [Line Chart: Jan-Dec]             │ fl_chart
├───────────────────────────────────┤
│ Spending Breakdown (This Month)   │
│ Food     $120 ████████░░  60%    │
│ Vet      $150 ██████████░ 75%    │ Category Bars
│ Grooming  $50 ███░░░░░░░ 25%    │
├───────────────────────────────────┤
│ Budget Statement                  │
│ Jan: $280/$500 ✓                 │
│ Feb: $320/$500 ✓                 │ Monthly Table
│ Mar: $450/$500 ⚠️                │
├───────────────────────────────────┤
│ [Set Budget] [Export Statement]   │
└───────────────────────────────────┘
```

**Database Schema:**
```sql
budgets: id, petId, totalBudget, period, alertAt75, alertAt100, createdAt
expenses: id, petId, category, amount, date, notes, createdAt
```

**Components:**
- `BudgetSummaryCard` (3 cards: total, spent, remaining)
- `BudgetProgressBar` (visual percentage with color)
- `SpendingCategoryRow` (category name + amount + bar)
- `MonthlySpendingChart` (fl_chart line chart)
- `BudgetStatementTable` (historical monthly data)
- `PetBudgetSelector` (dropdown to switch pets)

---

### 3. Account Page with Floating Button (`fe-account-page`)
**Inspired by:** Google account UI  
**Location:** Floating circle button at bottom-right of EVERY screen

**Floating Button Design:**
- 56x56px circle avatar with profile photo
- White border (2px) with shadow
- Always visible (z-index top)
- Taps to open account page

**Account Page Layout:**
```
┌─────────────────────────────────┐
│      ┌─────────┐                │
│      │  Photo  │                │ Large Profile Photo
│      └─────────┘                │
│      John Doe                   │
│  john.doe@email.com             │
│  Member since Jan 2024          │
├─────────────────────────────────┤
│ ┌───────────────────────────┐  │
│ │ 🔔 Notification Settings >│  │
│ ├───────────────────────────┤  │
│ │ 💳 Payments & Subs.     >│  │
│ ├───────────────────────────┤  │
│ │ 🌓 Light/Dark Mode      ⚪│  │ Toggle
│ ├───────────────────────────┤  │
│ │ 🔒 Privacy & Policy     >│  │
│ ├───────────────────────────┤  │
│ │ 🚪 Log Out              >│  │
│ ├───────────────────────────┤  │
│ │ 🔄 Switch Account       >│  │
│ └───────────────────────────┘  │
├─────────────────────────────────┤
│ [Edit Profile] [Change Photo]   │
└─────────────────────────────────┘
```

**Navigation:**
- Notification Settings → `/settings/notifications`
- Payments & Subscription → `/payments` (placeholder)
- Light/Dark Mode → Toggle theme in-place
- Privacy & Policy → `/privacy-policy`
- Log Out → Clear auth, navigate to `/login`
- Switch Account → `/switch-account` (future)

---

### 4. Enhanced Settings Page (`fe-settings-enhanced`)
**Transform settings into comprehensive system preferences**

**Structure (Grouped Sections):**
```
Settings
├─ 👤 ACCOUNT
│  └─ Profile view + link to account page
├─ 🔔 NOTIFICATIONS
│  └─ Preferences, reminders, alerts
├─ 🎨 APPEARANCE
│  ├─ Theme selector
│  ├─ Wallpaper customization
│  └─ Dark mode toggle
├─ 💾 DATA & STORAGE
│  ├─ Backup & Restore
│  ├─ Storage usage (progress bar)
│  └─ Clear cache
├─ 💳 PAYMENTS
│  └─ Subscription (placeholder)
└─ ℹ️  ABOUT
   ├─ Privacy policy
   ├─ Terms of service
   ├─ App version
   └─ Open source licenses
```

**Each section:**
- Icon + section title
- List of settings items
- Arrow (>) for navigation or toggle switch
- Proper spacing between groups

---

### 5. Pet Photo as Wallpaper (`fe-wallpaper-pet-photo`)
**Allow users to set their pet's photo as app background**

**User Flow:**
1. Settings → Appearance → Wallpaper
2. See current wallpaper preview
3. Choose option:
   - "Choose from Pet Photos" → Gallery picker
   - "Upload Custom Photo" → File picker
   - "Reset to Default" → Restore default
4. After selection → Crop/fit editor opens
5. User adjusts (zoom, pan, fit/fill/cover)
6. Tap "Apply"
7. Wallpaper saved to settings
8. Applied globally across all screens

**Implementation:**
```dart
// settings table
settings {
  userId: TEXT PRIMARY KEY,
  wallpaperPath: TEXT,      // Local file path
  wallpaperType: TEXT,      // 'default', 'pet', 'custom'
  wallpaperFit: TEXT,       // 'cover', 'contain', 'fill'
}

// Global background wrapper
Container(
  decoration: BoxDecoration(
    image: wallpaperPath != null
        ? DecorationImage(
            image: FileImage(File(wallpaperPath)),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
              Colors.black.withOpacity(0.3),  // Darken for readability
              BlendMode.darken,
            ),
          )
        : null,
  ),
  child: actualScreen,
)
```

---

### 6. Payment Placeholder Screen (`fe-payment-placeholder`)
**Professional placeholder for future premium features**

**Design:**
```
┌─────────────────────────────────┐
│ 🚀 Premium Features Coming Soon  │
├─────────────────────────────────┤
│ We're working on premium features│
│ to make your pet care even better│
│                                  │
│ ┌───────────────────────────┐   │
│ │ 🆓 FREE (Current)         │   │
│ │ • Up to 3 pets            │   │
│ │ • Basic reminders         │   │
│ │ • Photo storage (100 MB)  │   │
│ └───────────────────────────┘   │
│                                  │
│ ┌───────────────────────────┐   │
│ │ ⭐ PREMIUM (Coming Soon)  │   │
│ │ • Unlimited pets          │   │
│ │ • Cloud sync              │   │
│ │ • Advanced analytics      │   │
│ │ • Priority support        │   │
│ │ • 1 GB photo storage      │   │
│ │ $4.99/month               │   │
│ └───────────────────────────┘   │
│                                  │
│ ┌───────────────────────────┐   │
│ │ 👨‍👩‍👧‍👦 FAMILY (Coming Soon) │   │
│ │ • All Premium features    │   │
│ │ • Multi-user access       │   │
│ │ • Shared calendar         │   │
│ │ • 5 GB photo storage      │   │
│ │ $9.99/month               │   │
│ └───────────────────────────┘   │
│                                  │
│ [Notify Me When Available]       │
└─────────────────────────────────┘
```

**Note:** All buttons non-functional. This is UI-only.

---

## 📊 Complete Todo List (44 todos)

### Phase 1: Foundation (Days 1-4) - 10 todos
1. `fe-fonts` - Text styles (Poppins + Inter)
2. `fe-colors` - Warm color palette
3. `fe-spacing` - 8px spacing system
4. `fe-routing` - Navigation routes
5. `fe-photo-compression` - Image utility
6. `fe-components-atoms` - 7 atomic components
7. `fe-components-molecules` - 6 molecule components
8. `fe-components-organisms` - 6 organism components
9. `fe-bottom-nav` - Bottom navigation (4 tabs)
10. `fe-top-bar` - App bar component

### Phase 2: Core Screens (Days 5-12) - 12 todos
11. `fe-pet-profile` - Pet form
12. `fe-pet-list` - Pet list
13. `fe-pet-context` - Pet selector
14. `fe-dashboard-cards` - **NEW** Functional dashboard cards
15. `fe-weight-tracking` - Weight + chart
16. `fe-reminders-list` - Reminders (3 tabs)
17. `fe-reminder-form` - Reminder form
18. `fe-expense-list` - Expense list
19. `fe-expense-form` - Expense form
20. `fe-budget-dashboard` - Budget overview (basic)
21. `fe-budget-full-page` - **NEW** Enhanced budget page
22. `fe-photo-gallery` - Photo gallery

### Phase 3: Account, Settings, Critical (Days 13-19) - 13 todos
23. `fe-account-page` - **NEW** Account page + floating button
24. `fe-payment-placeholder` - **NEW** Payment placeholder
25. `fe-settings-page` - Settings base
26. `fe-settings-enhanced` - **NEW** Enhanced settings
27. `fe-theme-selector` - Theme picker
28. `fe-notification-settings` - Notification prefs
29. `fe-backup-restore` - Backup/restore UI
30. `fe-wallpaper` - Wallpaper basic
31. `fe-wallpaper-pet-photo` - **NEW** Pet photo wallpaper
32. `fe-dark-mode` - Dark mode (full)
33. `fe-storage-warnings` - Storage tracking
34. `fe-notification-permission` - Permission flow
35. `fe-password-warning` - Password warning

### Phase 4: Polish & Testing (Days 20-28) - 9 todos
36. `fe-empty-states` - Empty states
37. `fe-loading-states` - Skeleton screens
38. `fe-error-handling` - Error handling
39. `fe-form-validation` - Validation
40. `fe-animations` - Animations
41. `fe-accessibility` - Accessibility
42. `fe-widget-tests` - Unit tests
43. `fe-integration-tests` - Integration tests
44. `fe-onboarding` - Onboarding wizard (LAST)

---

## 🗄️ Database Schema (SQLite)

```sql
-- User authentication
CREATE TABLE users (
  id TEXT PRIMARY KEY,
  username TEXT UNIQUE NOT NULL,
  passwordHash TEXT NOT NULL,
  email TEXT,
  profilePhoto TEXT,
  createdAt TEXT
);

-- Pets
CREATE TABLE pets (
  id TEXT PRIMARY KEY,
  userId TEXT NOT NULL,
  name TEXT NOT NULL,
  species TEXT,
  breed TEXT,
  dob TEXT,
  photoUrl TEXT,
  createdAt TEXT,
  FOREIGN KEY (userId) REFERENCES users(id)
);

-- Reminders
CREATE TABLE reminders (
  id TEXT PRIMARY KEY,
  userId TEXT NOT NULL,
  petId TEXT,
  title TEXT NOT NULL,
  datetime TEXT NOT NULL,
  status TEXT DEFAULT 'pending',  -- 'pending', 'completed'
  frequency TEXT,  -- 'once', 'daily', 'weekly', 'monthly'
  notes TEXT,
  createdAt TEXT,
  FOREIGN KEY (userId) REFERENCES users(id),
  FOREIGN KEY (petId) REFERENCES pets(id)
);

-- Weight tracking
CREATE TABLE weights (
  id TEXT PRIMARY KEY,
  petId TEXT NOT NULL,
  weight REAL NOT NULL,
  unit TEXT DEFAULT 'kg',
  date TEXT NOT NULL,
  notes TEXT,
  createdAt TEXT,
  FOREIGN KEY (petId) REFERENCES pets(id)
);

-- Expenses
CREATE TABLE expenses (
  id TEXT PRIMARY KEY,
  userId TEXT NOT NULL,
  petId TEXT,
  category TEXT,  -- 'food', 'vet', 'grooming', 'toys', 'other'
  amount REAL NOT NULL,
  date TEXT NOT NULL,
  notes TEXT,
  createdAt TEXT,
  FOREIGN KEY (userId) REFERENCES users(id),
  FOREIGN KEY (petId) REFERENCES pets(id)
);

-- Budgets
CREATE TABLE budgets (
  id TEXT PRIMARY KEY,
  userId TEXT NOT NULL,
  petId TEXT,
  totalBudget REAL NOT NULL,
  period TEXT DEFAULT 'monthly',  -- 'monthly', 'yearly'
  alertAt75 INTEGER DEFAULT 1,
  alertAt100 INTEGER DEFAULT 1,
  createdAt TEXT,
  FOREIGN KEY (userId) REFERENCES users(id),
  FOREIGN KEY (petId) REFERENCES pets(id)
);

-- Photos
CREATE TABLE photos (
  id TEXT PRIMARY KEY,
  petId TEXT NOT NULL,
  userId TEXT NOT NULL,
  imageUrl TEXT NOT NULL,
  albumId TEXT,
  caption TEXT,
  uploadedAt TEXT,
  FOREIGN KEY (petId) REFERENCES pets(id),
  FOREIGN KEY (userId) REFERENCES users(id)
);

-- Albums
CREATE TABLE albums (
  id TEXT PRIMARY KEY,
  petId TEXT NOT NULL,
  name TEXT NOT NULL,
  coverPhotoId TEXT,
  createdAt TEXT,
  FOREIGN KEY (petId) REFERENCES pets(id)
);

-- Settings
CREATE TABLE settings (
  userId TEXT PRIMARY KEY,
  theme TEXT DEFAULT 'warm',  -- 'warm', 'clean', 'custom'
  darkMode INTEGER DEFAULT 0,
  wallpaperPath TEXT,
  wallpaperType TEXT,  -- 'default', 'pet', 'custom'
  wallpaperFit TEXT DEFAULT 'cover',
  notificationsEnabled INTEGER DEFAULT 1,
  FOREIGN KEY (userId) REFERENCES users(id)
);
```

---

## 📦 Dependencies (pubspec.yaml)

```yaml
dependencies:
  flutter:
    sdk: flutter
  # Existing
  http: ^1.1.0
  image_picker: ^1.0.4
  flutter_secure_storage: ^9.0.0
  shared_preferences: ^2.2.2
  intl: ^0.18.1
  provider: ^6.1.1
  firebase_core: ^2.24.0
  firebase_messaging: ^14.7.0
  
  # NEW - Added
  sqflite: ^2.3.0              # SQLite database
  path_provider: ^2.1.1        # File paths
  path: ^1.8.3                 # Path utilities
  image: ^4.1.3                # Image compression
  fl_chart: ^0.65.0            # Charts
  file_picker: ^6.1.1          # File picker
  permission_handler: ^11.1.0  # Permissions
  google_fonts: ^6.1.0         # Fonts
```

---

## 🎨 Design System

### Colors (Warm Palette)
```dart
primary:    #FF8C42  // Orange
secondary:  #FFB380  // Light orange
accent:     #FD6B6B  // Red/pink
background: #FFF9F5  // Warm white
text:       #2C2C2C  // Dark gray
success:    #52B788  // Green
warning:    #F4A261  // Warm yellow
error:      #E63946  // Red
```

### Typography
```dart
Headings: Poppins (600-700 weight)
  H1: 32px
  H2: 28px
  H3: 20px

Body: Inter (400-500 weight)
  Body: 16px
  Small: 14px
  Caption: 12px
```

### Spacing (8px base)
```dart
xs:  4px
sm:  8px
md:  16px
lg:  24px
xl:  32px
xxl: 48px
```

---

## 🚀 Implementation Workflow

### Per-Todo Process:
1. **Read todo description** from SQL database
2. **Implement feature** following specifications
3. **Test as you go** (manual testing during dev)
4. **Commit when done**: `git commit -m "feat: [todo-id] - [description]"`
5. **Update todo status**: `UPDATE todos SET status='done' WHERE id='...'`
6. **Move to next ready todo**

### Commit Message Format:
```
feat: fe-fonts - Add Poppins and Inter text styles
feat: fe-dashboard-cards - Make dashboard cards functional
feat: fe-account-page - Add account page with floating button
```

### Testing Strategy:
- **During Development:** Test each component in isolation
- **Phase 4:** Comprehensive testing (widget + integration tests)
- **Both approaches:** Test as you go + formal testing phase

---

## ✅ Ready to Start?

**Current State:**
- ✅ All 44 todos defined in SQL database
- ✅ Dependencies identified
- ✅ Design system specified
- ✅ Database schema designed
- ✅ Component structure planned
- ✅ User flows documented
- ✅ All new features detailed

**Next Steps:**
1. User approves this plan
2. Install dependencies (`flutter pub get`)
3. Start with `fe-fonts` (Day 1, Todo 1)
4. Work systematically through all 44 todos
5. Commit after each todo completion
6. Test comprehensively in Phase 4
7. Complete frontend in 25-28 days

**Waiting for your approval to begin! 🚀**

---

## 📝 Questions?

If you have any questions about:
- Feature specifications
- Implementation approach
- Timeline estimates
- Design decisions
- Database schema
- Component structure

**Ask now before we start!**
