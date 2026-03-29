# Frontend Implementation Plan — Pet Care App

**Date:** March 29, 2026 (UPDATED with additional features)
**Approach:** Frontend-first with mock data → Backend follows  
**Status:** Planning complete, ready for user approval  
**Timeline:** 25-28 days frontend development (44 todos total)

---

## 🆕 New Features Added (User Request - March 29)

### 1. **Dashboard Functional Cards**
The 3 dashboard cards (Completed, Pending, Overdue) are currently non-functional placeholders. Now they will:
- Show accurate real-time counts from reminders database
- Be clickable to filter and navigate to filtered reminders view
- Highlight overdue count in red/warning color
- Update automatically when reminders change
- Show empty state when count is 0
- Animate count changes

### 2. **Enhanced Budget Page**
Transform basic budget overview into full-featured budget management:
- **Per-Pet Budget Cards:** Individual budget card for each pet showing total budget, spent amount, remaining amount, percentage used
- **Spending Breakdown:** Category-wise spending for each pet (food, vet, grooming, toys, etc.)
- **Monthly Records:** Historical spending data per pet (table + line chart)
- **Budget Statement:** Comprehensive report showing budget vs actual spending
- **Pet Selector:** Switch between pets to view their individual budgets
- **Visual Indicators:** Progress bars, percentage circles, color-coded warnings (red when over budget)
- **Budget Actions:** Add/edit budget, set alerts, export statement

### 3. **Account Page with Profile Button**
Full account management system inspired by Google's account UI:
- **Floating Circle Button:** Profile photo circle button at bottom-right of every page (like Google's account switcher)
- **Account Information Display:** Username, email (if added), profile photo, account created date
- **Navigation Menu:**
  - 🔔 Notification Settings (link to notification preferences)
  - 💳 Payments & Subscription (placeholder screen)
  - 🌓 Light/Dark Mode Toggle (functional once theme system complete)
  - 🔒 Privacy & Policy (link to privacy policy page)
  - 🚪 Log Out (clear auth and return to login)
  - 🔄 Switch Account (for future multi-account support)
- **Profile Actions:** Upload/change profile photo, edit account details
- **Design:** Clean, card-based layout matching Google account style

### 4. **Enhanced Settings Page**
Expand settings into comprehensive system preferences:
- **Account Section:** Link to account page, quick profile view
- **Notifications Section:** Link to detailed notification settings
- **Appearance Section:** Theme selector, wallpaper customization, dark mode toggle
- **Data Section:** Backup/restore, storage usage display, clear cache option
- **About Section:** Privacy policy, terms of service, app version, licenses
- **Payments Section:** Subscription management (placeholder for now)
- **Grouped Sections:** Proper categorization with icons and spacing
- **Search:** Settings search functionality (optional)

### 5. **Pet Photo as Wallpaper**
Allow users to personalize app with their pet's photo:
- **Select from Gallery:** Choose from existing pet photos
- **Upload Custom:** Upload new photo specifically for wallpaper
- **Crop & Fit:** Adjust photo to fit screen (crop, scale, position)
- **Preview:** See how wallpaper looks before applying
- **Apply Globally:** Wallpaper shows across all app screens as background
- **Reset to Default:** Option to restore default wallpaper
- **Storage:** Save wallpaper path in settings table
- **Performance:** Optimize image size for backgrounds

### 6. **Payment Placeholder Screen**
Professional placeholder for future payment features:
- **Coming Soon Message:** Clear, friendly message about upcoming feature
- **Subscription Tiers Preview:** Basic, Premium, Family plans (non-functional mockup)
- **Feature List:** What each tier will include (more pets, cloud sync, advanced analytics)
- **Notify Me Option:** Optionally capture email or just show info
- **Professional Design:** Not just text - proper card layout, icons, pricing mockup
- **Navigation:** Accessible from settings and account page

---

## 📋 Implementation Order

Based on dependencies and priority, here's the recommended order:

### **Phase 1: Foundation (Days 1-4)**

**Start with design system (NO dependencies):**
1. ✅ `fe-fonts` - Finalize fonts (Poppins + Inter)
2. ✅ `fe-colors` - Implement Golden Companion palette
3. ✅ `fe-spacing` - Define 8px base unit system
4. ✅ `fe-routing` - Set up navigation structure
5. ✅ `fe-photo-compression` - Image compression utility

**Then build component library:**
6. ✅ `fe-components-atoms` - Buttons, Inputs, Dropdowns, Toggles, etc.
7. ✅ `fe-components-molecules` - Cards, FormFields, SearchBar, etc.
8. ✅ `fe-components-organisms` - PetProfileCard, FeatureGrid, Modal, etc.

**Then navigation:**
9. ✅ `fe-bottom-nav` - Bottom navigation bar
10. ✅ `fe-top-bar` - App bar component

**Deliverable:** Design system + component library + navigation skeleton

---

---

## 📐 New Feature Specifications

### **1. Dashboard Functional Cards**

**Current State:** 3 static cards showing "Completed", "Pending", "Overdue"  
**Target State:** Interactive, real-time cards with click actions

**Implementation Details:**
```dart
// Card widget structure
class DashboardStatCard extends StatelessWidget {
  final String title;           // "Completed", "Pending", "Overdue"
  final int count;              // Real count from database
  final Color color;            // Green, Blue, Red
  final VoidCallback onTap;     // Navigate to filtered reminders
  
  // Visual states:
  // - count = 0: Show gray with "No {title} tasks"
  // - count > 0: Show colored with count
  // - Overdue: Red background, pulse animation
  // - On tap: Navigate to reminders filtered by status
}
```

**Database Query:**
```dart
// Get counts from reminders table
final completed = await db.query('reminders', where: 'status = ?', whereArgs: ['completed']);
final pending = await db.query('reminders', where: 'status = ? AND datetime >= ?', whereArgs: ['pending', DateTime.now()]);
final overdue = await db.query('reminders', where: 'status = ? AND datetime < ?', whereArgs: ['pending', DateTime.now()]);
```

**User Flow:**
1. User opens dashboard
2. Sees 3 cards with real-time counts
3. Taps "Overdue (5)" card
4. Navigates to reminders screen with overdue filter applied
5. Sees list of 5 overdue reminders

---

### **2. Enhanced Budget Page (Full-Page Layout)**

**Layout Structure:**
```
┌─────────────────────────────────────┐
│ [Pet Selector Dropdown]             │
├─────────────────────────────────────┤
│ ┌─────────┐ ┌─────────┐ ┌─────────┐│
│ │ Total   │ │ Spent   │ │Remaining││ ← Budget Cards
│ │ $500    │ │ $320    │ │ $180    ││
│ └─────────┘ └─────────┘ └─────────┘│
├─────────────────────────────────────┤
│ [Monthly Spending Chart - Line]     │ ← Spending Trend
│                                     │
├─────────────────────────────────────┤
│ Spending Breakdown (This Month)     │
│ ┌───────────────────────────────┐  │
│ │ Food        $120  ████████░░  │  │
│ │ Vet         $150  ██████████░ │  │
│ │ Grooming    $50   ███░░░░░░░ │  │ ← Category Bars
│ └───────────────────────────────┘  │
├─────────────────────────────────────┤
│ Budget Statement                    │
│ ┌───────────────────────────────┐  │
│ │ Jan: $280 / $500              │  │
│ │ Feb: $320 / $500              │  │ ← Monthly History
│ │ Mar: $450 / $500  ⚠️          │  │
│ └───────────────────────────────┘  │
├─────────────────────────────────────┤
│ [Set Budget] [Export Statement]     │ ← Action Buttons
└─────────────────────────────────────┘
```

**Components Needed:**
- `BudgetSummaryCard` (total, spent, remaining)
- `BudgetProgressBar` (visual percentage)
- `SpendingCategoryRow` (category with bar chart)
- `MonthlySpendingChart` (fl_chart line chart)
- `BudgetStatementTable` (historical data)
- `PetBudgetSelector` (switch between pets)

**Database Schema:**
```sql
CREATE TABLE budgets (
  id TEXT PRIMARY KEY,
  petId TEXT,
  totalBudget REAL,
  period TEXT,  -- 'monthly', 'yearly'
  alertAt75 INTEGER,  -- boolean
  alertAt100 INTEGER,
  createdAt TEXT
);

CREATE TABLE expenses (
  id TEXT PRIMARY KEY,
  petId TEXT,
  category TEXT,  -- 'food', 'vet', 'grooming', 'toys', 'other'
  amount REAL,
  date TEXT,
  notes TEXT,
  createdAt TEXT
);
```

---

### **3. Account Page with Floating Profile Button**

**Floating Button Design:**
```dart
// Bottom-right floating button (on EVERY screen)
Positioned(
  bottom: 16,
  right: 16,
  child: GestureDetector(
    onTap: () => Navigator.pushNamed(context, '/account'),
    child: CircleAvatar(
      radius: 28,
      backgroundImage: profilePhoto != null 
          ? FileImage(File(profilePhoto))
          : AssetImage('assets/default_avatar.png'),
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 2),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
      ),
    ),
  ),
)
```

**Account Page Layout:**
```
┌─────────────────────────────────────┐
│         ┌─────────┐                 │
│         │  Photo  │                 │ ← Profile Photo (large)
│         └─────────┘                 │
│         John Doe                    │ ← Username
│    john.doe@email.com               │ ← Email (optional)
│    Member since Jan 2024            │
├─────────────────────────────────────┤
│ ┌─────────────────────────────────┐│
│ │ 🔔 Notification Settings      > ││
│ ├─────────────────────────────────┤│
│ │ 💳 Payments & Subscription    > ││
│ ├─────────────────────────────────┤│
│ │ 🌓 Light / Dark Mode          ⚪││ ← Toggle Switch
│ ├─────────────────────────────────┤│
│ │ 🔒 Privacy & Policy           > ││
│ ├─────────────────────────────────┤│
│ │ 🚪 Log Out                    > ││
│ ├─────────────────────────────────┤│
│ │ 🔄 Switch Account             > ││
│ └─────────────────────────────────┘│
├─────────────────────────────────────┤
│ [Edit Profile] [Change Photo]       │
└─────────────────────────────────────┘
```

**Navigation Destinations:**
- **Notification Settings** → `/settings/notifications`
- **Payments & Subscription** → `/payments` (placeholder)
- **Light/Dark Mode** → Toggle in-place (no navigation)
- **Privacy & Policy** → `/privacy-policy` (static page)
- **Log Out** → Clear auth, navigate to `/login`
- **Switch Account** → `/switch-account` (future multi-account)

---

### **4. Enhanced Settings Page Structure**

**Settings Categories:**
```
┌─────────────────────────────────────┐
│ Settings                            │
├─────────────────────────────────────┤
│ 👤 ACCOUNT                          │
│ ┌─────────────────────────────────┐│
│ │ [Profile Photo] John Doe      > ││ ← Quick account view
│ │ View & edit account             ││
│ └─────────────────────────────────┘│
│                                     │
│ 🔔 NOTIFICATIONS                    │
│ ┌─────────────────────────────────┐│
│ │ Notification Preferences      > ││
│ │ Reminders, updates, alerts      ││
│ └─────────────────────────────────┘│
│                                     │
│ 🎨 APPEARANCE                       │
│ ┌─────────────────────────────────┐│
│ │ Theme                         > ││
│ │ Wallpaper                     > ││
│ │ Dark Mode                     ⚪││ ← Toggle
│ └─────────────────────────────────┘│
│                                     │
│ 💾 DATA & STORAGE                   │
│ ┌─────────────────────────────────┐│
│ │ Backup & Restore              > ││
│ │ Storage Usage      75 MB / 100  ││ ← Progress bar
│ │ Clear Cache                   > ││
│ └─────────────────────────────────┘│
│                                     │
│ 💳 PAYMENTS                         │
│ ┌─────────────────────────────────┐│
│ │ Subscription                  > ││
│ │ Free plan • Upgrade available   ││
│ └─────────────────────────────────┘│
│                                     │
│ ℹ️  ABOUT                           │
│ ┌─────────────────────────────────┐│
│ │ Privacy Policy                > ││
│ │ Terms of Service              > ││
│ │ App Version    1.0.0            ││
│ │ Open Source Licenses          > ││
│ └─────────────────────────────────┘│
└─────────────────────────────────────┘
```

**Each section is a `SettingsGroup` widget with icon, title, and list of `SettingsItem` widgets**

---

### **5. Pet Photo as Wallpaper Feature**

**User Flow:**
1. User goes to Settings → Appearance → Wallpaper
2. Sees current wallpaper preview
3. Options:
   - "Choose from Pet Photos" → Opens gallery picker
   - "Upload Custom Photo" → Opens file picker
   - "Reset to Default" → Restores default wallpaper
4. After selecting photo, opens crop/fit editor
5. User adjusts photo (zoom, pan, fit/fill)
6. Taps "Apply"
7. Wallpaper saved to settings
8. Applied across all screens as background

**Implementation:**
```dart
// Settings table
settings {
  userId: TEXT PRIMARY KEY,
  wallpaperPath: TEXT,  // Local file path
  wallpaperType: TEXT,  // 'default', 'pet', 'custom'
  wallpaperFit: TEXT,   // 'cover', 'contain', 'fill'
}

// Apply wallpaper globally
class AppBackground extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsProvider>(context);
    
    return Container(
      decoration: BoxDecoration(
        image: settings.wallpaperPath != null
            ? DecorationImage(
                image: FileImage(File(settings.wallpaperPath)),
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(
                  Colors.black.withOpacity(0.3),  // Darken for readability
                  BlendMode.darken,
                ),
              )
            : null,
        color: settings.wallpaperPath == null 
            ? Theme.of(context).backgroundColor 
            : null,
      ),
      child: child,
    );
  }
}
```

---

### **6. Payment Placeholder Screen**

**Design:**
```
┌─────────────────────────────────────┐
│ 🚀 Premium Features Coming Soon      │
├─────────────────────────────────────┤
│                                     │
│ We're working on premium features   │
│ to make your pet care even better!  │
│                                     │
│ ┌─────────────────────────────────┐│
│ │ 🆓 FREE (Current)               ││
│ │ • Up to 3 pets                  ││
│ │ • Basic reminders               ││
│ │ • Photo storage (100 MB)        ││
│ └─────────────────────────────────┘│
│                                     │
│ ┌─────────────────────────────────┐│
│ │ ⭐ PREMIUM (Coming Soon)        ││
│ │ • Unlimited pets                ││
│ │ • Cloud sync                    ││
│ │ • Advanced analytics            ││
│ │ • Priority support              ││
│ │ • 1 GB photo storage            ││
│ │ $4.99/month                     ││
│ └─────────────────────────────────┘│
│                                     │
│ ┌─────────────────────────────────┐│
│ │ 👨‍👩‍👧‍👦 FAMILY (Coming Soon)       ││
│ │ • All Premium features          ││
│ │ • Multi-user access             ││
│ │ • Shared calendar               ││
│ │ • 5 GB photo storage            ││
│ │ $9.99/month                     ││
│ └─────────────────────────────────┘│
│                                     │
│ [Notify Me When Available]          │
└─────────────────────────────────────┘
```

**Note:** All pricing and features are mockup only. Buttons are non-functional.

---

### **Phase 2: Core Screens (Days 5-11)**

**Pet Management:**
11. ✅ `fe-pet-profile` - Pet profile form (all fields)
12. ✅ `fe-pet-list` - Pet list with add FAB
13. ✅ `fe-pet-context` - Pet selector dropdown

**Weight Tracking:**
14. ✅ `fe-weight-tracking` - Weight list + chart

**Reminders:**
15. ✅ `fe-reminders-list` - Reminder list (3 tabs)
16. ✅ `fe-reminder-form` - Add/edit reminder

**Expenses & Budget:**
17. ✅ `fe-expense-list` - Expense list
18. ✅ `fe-expense-form` - Add expense
19. ✅ `fe-budget-dashboard` - Budget overview with chart

**Gallery:**
20. ✅ `fe-photo-gallery` - Photo grid + upload

**Deliverable:** All major feature screens with mock data

---

### **Phase 3: Settings & Critical Features (Days 12-16)**

**Settings:**
21. ✅ `fe-settings-page` - Settings page (grouped sections)
22. ✅ `fe-theme-selector` - Theme picker
23. ✅ `fe-wallpaper` - Wallpaper customization
24. ✅ `fe-notification-settings` - Notification preferences
25. ✅ `fe-backup-restore` - Backup/restore UI

**Dark Mode:**
26. ✅ `fe-dark-mode` - Complete dark mode

**Critical Features:**
27. ✅ `fe-storage-warnings` - Storage tracking + warnings
28. ✅ `fe-notification-permission` - Permission request flow
29. ✅ `fe-password-warning` - Password recovery warning

**Deliverable:** Complete settings + critical features implemented

---

### **Phase 4: Polish & Testing (Days 17-22)**

**UX Polish:**
30. ✅ `fe-empty-states` - Empty states for all lists
31. ✅ `fe-loading-states` - Skeleton screens
32. ✅ `fe-error-handling` - Error messages + retry
33. ✅ `fe-form-validation` - Real-time validation
34. ✅ `fe-animations` - Transitions + micro-interactions
35. ✅ `fe-accessibility` - Screen reader + contrast

**Testing:**
36. ✅ `fe-widget-tests` - Component tests
37. ✅ `fe-integration-tests` - Flow tests

**Final Polish:**
38. ✅ `fe-onboarding` - Onboarding wizard (LAST, only when everything else done)

**Deliverable:** Production-ready frontend

---

## 🎨 Design System Specifications

### Fonts (from analysis)
**Headings:** Poppins (600-700 weight)
- H1: 32px (2rem)
- H2: 28px (1.75rem)
- H3: 20px (1.25rem)

**Body:** Inter (400-500 weight)
- Body: 16px (1rem)
- Small: 14px (0.875rem)

**Implementation:**
```dart
// lib/core/constants/text_styles.dart
class AppTextStyles {
  static const h1 = TextStyle(
    fontFamily: 'Poppins',
    fontSize: 32,
    fontWeight: FontWeight.w700,
  );
  static const h2 = TextStyle(
    fontFamily: 'Poppins',
    fontSize: 28,
    fontWeight: FontWeight.w600,
  );
  static const h3 = TextStyle(
    fontFamily: 'Poppins',
    fontSize: 20,
    fontWeight: FontWeight.w600,
  );
  static const body = TextStyle(
    fontFamily: 'Inter',
    fontSize: 16,
    fontWeight: FontWeight.w400,
  );
  static const bodyBold = TextStyle(
    fontFamily: 'Inter',
    fontSize: 16,
    fontWeight: FontWeight.w500,
  );
  static const small = TextStyle(
    fontFamily: 'Inter',
    fontSize: 14,
    fontWeight: FontWeight.w400,
  );
}
```

---

### Colors (Golden Companion Palette from PHASE4)

**Primary:** Golden Yellow `#FFC107`  
**Secondary:** Cyan `#00D4D4`  
**Accents:** Purple `#9B59B6`, Pink `#FF6B9D`, Blue `#3B8BD9`

**Light Mode:**
- Background: `#FFFFFF`
- Surface: `#F5F7FA`
- Text Primary: `#1A1A1A`
- Text Secondary: `#666666`
- Border: `#E0E0E0`
- Success: `#4CAF50`
- Warning: `#FF9800`
- Error: `#F44336`

**Dark Mode:**
- Background: `#1A1A1A`
- Surface: `#2C2C2C`
- Text Primary: `#F5F5F5`
- Text Secondary: `#B0B0B0`
- Border: `#404040`
- Success: `#52B788`
- Warning: `#FFB74D`
- Error: `#EF5350`
- Primary (adjusted): `#FFD54F` (lighter for visibility)
- Secondary (adjusted): `#00E5E5` (brighter cyan)

**Implementation:**
```dart
// lib/core/constants/colors.dart
class AppColors {
  // Primary
  static const primary = Color(0xFFFFC107);
  static const primaryLight = Color(0xFFFFD54F);
  static const primaryDark = Color(0xFFFFA000);
  
  // Secondary
  static const secondary = Color(0x00D4D4);
  static const secondaryLight = Color(0x00E5E5);
  static const secondaryDark = Color(0x00A3A3);
  
  // Accents
  static const purple = Color(0xFF9B59B6);
  static const pink = Color(0xFFFF6B9D);
  static const blue = Color(0xFF3B8BD9);
  
  // Light mode
  static const lightBackground = Color(0xFFFFFFFF);
  static const lightSurface = Color(0xFFF5F7FA);
  static const lightTextPrimary = Color(0xFF1A1A1A);
  static const lightTextSecondary = Color(0xFF666666);
  static const lightBorder = Color(0xFFE0E0E0);
  
  // Dark mode
  static const darkBackground = Color(0xFF1A1A1A);
  static const darkSurface = Color(0xFF2C2C2C);
  static const darkTextPrimary = Color(0xFFF5F5F5);
  static const darkTextSecondary = Color(0xFFB0B0B0);
  static const darkBorder = Color(0xFF404040);
  
  // Status (same for both modes, adjusted in dark)
  static const success = Color(0xFF4CAF50);
  static const warning = Color(0xFFFF9800);
  static const error = Color(0xFFF44336);
}
```

---

### Spacing (8px base unit)

```dart
// lib/core/constants/spacing.dart
class AppSpacing {
  static const xs = 4.0;
  static const sm = 8.0;
  static const md = 16.0;
  static const lg = 24.0;
  static const xl = 32.0;
  static const xxl = 48.0;
  
  // Card padding
  static const cardPaddingSmall = 16.0;
  static const cardPaddingLarge = 24.0;
  
  // Page margins
  static const pageMobile = 16.0;
  static const pageDesktop = 24.0;
  
  // Border radius
  static const radiusSmall = 8.0;
  static const radiusMedium = 12.0;
  static const radiusLarge = 20.0;
}
```

---

## 🧩 Component Library Structure

### Atoms (lib/components/atoms/)
- `app_button.dart` - Primary, Secondary, Icon, FAB variants
- `app_input.dart` - Text, Number, Multiline
- `app_dropdown.dart` - Single select, searchable
- `app_toggle.dart` - Switch, Checkbox, Radio
- `app_badge.dart` - Count badge, Status badge
- `app_avatar.dart` - Pet photo, User photo, Placeholder
- `app_icon.dart` - Paw, Calendar, Bell, Camera, etc.
- `app_tag.dart` - Category labels

### Molecules (lib/components/molecules/)
- `app_card.dart` - Standard container with shadow
- `form_field.dart` - Label + Input + Error message
- `search_bar.dart` - Input with search icon + clear
- `date_range_picker.dart` - Start + End date picker
- `stat_card.dart` - Metric label + large value + trend
- `list_item.dart` - Icon + Title + Subtitle + Action
- `empty_state.dart` - Illustration + Heading + Description + CTA

### Organisms (lib/components/organisms/)
- `pet_profile_card.dart` - Photo + Name + Badges + Settings icon
- `feature_grid.dart` - 2-column grid of feature cards
- `timeline_item.dart` - Date + Icon + Content card
- `chart_card.dart` - Card with embedded chart (fl_chart)
- `app_modal.dart` - Full-screen modal with header/content/footer
- `bottom_sheet.dart` - Slide-up action menu
- `bottom_nav_bar.dart` - Bottom navigation (4-5 tabs)
- `app_bar.dart` - Top bar with back + title + actions

---

## 📱 Screen Specifications

### 1. Pet Profile Screen (`fe-pet-profile`)
**Route:** `/pets/profile` (add) or `/pets/:id/edit` (edit)

**Fields (from APP_SPEC.md):**
- Pet Photo (upload, camera or gallery)
- Name (required, text)
- Type (dropdown: Dog, Cat, Bird, Other, Custom)
- Breed (text or searchable dropdown)
- Gender (radio: Male, Female, Other)
- Birthday (date picker, optional)
- Color (text)
- Chip Number (text)
- Blood Type (text)
- Weight (number + unit picker: kg/lbs)
- Allergies (multiline text)
- Diet (multiline text)
- Special Care (multiline text)
- Vet Name (text)
- Vet Phone (phone number)
- Notes (multiline text)

**Validation:**
- Name required (max 50 chars)
- Type required
- Phone number format validation

**Save Button:** Validates → Shows success toast → Returns to pet list

---

### 2. Weight Tracking Screen (`fe-weight-tracking`)
**Route:** `/pets/:id/weights`

**Components:**
- Pet selector (if multiple pets)
- Add weight FAB
- Weight history list (timeline view)
  - Date, Weight, Unit, Notes
  - Tap to edit/delete
- Line chart (fl_chart)
  - X-axis: Dates
  - Y-axis: Weight
  - Tap data point to highlight in list
- Date range filter (last week, month, 3 months, all)

**Add Weight Modal:**
- Date picker (default: today)
- Weight input (number)
- Unit picker (kg / lbs)
- Notes (optional, text)
- Save / Cancel buttons

---

### 3. Reminders List Screen (`fe-reminders-list`)
**Route:** `/reminders`

**Tabs:**
1. Upcoming (status=pending, date >= today)
2. Overdue (status=pending, date < today)
3. Completed (status=completed)

**List Item:**
- Icon (category icon + background color)
- Title (bold)
- Pet name (if linked to pet)
- Date/Time
- Priority indicator (color-coded border)
- Checkbox (tap to mark complete)
- Swipe actions: Edit, Delete

**Add FAB:** Opens reminder form

**Filter:** By category, pet, priority

---

### 4. Budget Dashboard (`fe-budget-dashboard`)
**Route:** `/budget`

**Layout:**
- Pet selector dropdown (at top)
- Set Budget Card:
  - "Budget: $5000/year" (tap to edit)
  - Period picker (monthly/yearly)
- Overview Cards (2x2 grid):
  - Total Budget
  - Spent (with percentage)
  - Remaining
  - Alert status (OK / 75% / 100%)
- Spending Chart:
  - Line chart: spending over time
  - X-axis: dates
  - Y-axis: cumulative amount
- Spending History Table:
  - Date | Category | Amount | Notes
  - Filter by category, date range
  - Tap row to view/edit
- Add Expense FAB

**Set Budget Modal:**
- Amount input
- Period dropdown (monthly / yearly)
- Alert toggles (75% / 100%)
- Save button

---

### 5. Settings Page (`fe-settings-page`)
**Route:** `/settings`

**Sections:**

**Account**
- Username (display only)
- Change Password (tap → modal with current + new password)
- Delete Account (tap → confirmation dialog)

**Appearance**
- Theme Selector (tap → opens `fe-theme-selector`)
  - Warm (orange)
  - Clean (blue)
  - Golden Companion (yellow+cyan)
- Dark Mode Toggle
- Wallpaper (tap → opens `fe-wallpaper`)

**Notifications**
- Enable Notifications (master toggle)
- Notification Settings (tap → opens `fe-notification-settings`)

**Data**
- Backup (tap → opens `fe-backup-restore` export)
- Restore (tap → opens `fe-backup-restore` import)
- Storage Used (display only, e.g., "45 MB / 100 MB")

---

## ⚠️ Critical Features

### Photo Compression (`fe-photo-compression`)
**Requirement:** Prevent storage bloat

**Implementation:**
1. On image selection (camera or gallery):
   - Read image file
   - Resize to max 1920px width (maintain aspect ratio)
   - Compress to 80% JPEG quality
   - Generate thumbnail (200x200px) for list views
2. Store both full-size (compressed) and thumbnail
3. Use `image` package for resizing/compression

**File paths:**
- Full: `/uploads/pets/{petId}/photos/{photoId}.jpg`
- Thumb: `/uploads/pets/{petId}/photos/thumbs/{photoId}_thumb.jpg`

---

### Storage Warnings (`fe-storage-warnings`)
**Requirement:** Alert users before running out of storage

**Implementation:**
1. Track storage usage:
   - Database size (SQLite file size)
   - Photos total size (sum of all image files)
2. Calculate total used
3. Show warnings:
   - Toast at 50MB: "Storage is 50% full. Consider deleting old photos."
   - Toast at 100MB: "Storage is high (100MB+). Delete photos or export data."
   - Alert icon in settings when over 75MB
4. Settings → Storage Used → Breakdown:
   - Database: X MB
   - Photos: Y MB
   - Total: Z MB
   - Button: "Manage Storage" (opens photo gallery for deletion)

---

### Notification Permission Flow (`fe-notification-permission`)
**Requirement:** Request permissions properly, explain why

**Implementation:**
1. Trigger: When user creates first reminder OR enables notifications in settings
2. Show dialog BEFORE requesting permission:
   ```
   Enable Notifications?
   
   Notifications help you remember:
   • Pet medication times
   • Vet appointments
   • Feeding schedules
   
   [Not Now]  [Enable]
   ```
3. If "Enable" → Request system permission
4. Handle outcomes:
   - Granted: ✓ Show success toast
   - Denied: Show how to enable manually (Settings → App → Notifications)
5. Don't ask again if user denies twice

---

### Password Recovery Warning (`fe-password-warning`)
**Requirement:** Warn users about no recovery option (local-only)

**Implementation:**
1. During registration, BEFORE user sets password:
   - Show prominent warning card (yellow background):
     ```
     ⚠️ IMPORTANT: No Password Recovery
     
     This is a local-only app. If you forget your password,
     you CANNOT recover your account or data.
     
     ✓ Write it down in a safe place
     ✓ Use a password manager
     ✗ Don't forget it!
     
     [ ] I understand and will keep my password safe
     ```
   - Require checkbox to be checked before proceeding
2. During login, if user taps "Forgot Password":
   - Show dialog:
     ```
     No Password Recovery Available
     
     This app stores data locally on your device only.
     Password reset requires a server, which we don't have.
     
     If you forgot your password, you must:
     1. Uninstall the app (loses all data)
     2. Reinstall and create a new account
     
     [Cancel]  [Uninstall Instructions]
     ```

---

## 🧪 Testing Strategy

### Widget Tests (`fe-widget-tests`)
Test each component in isolation:
- Atoms: Button variants, input validation, toggle states
- Molecules: FormField error display, SearchBar filtering
- Organisms: Modal open/close, BottomSheet swipe

**Example:**
```dart
testWidgets('AppButton primary variant renders correctly', (tester) async {
  await tester.pumpWidget(MaterialApp(
    home: Scaffold(
      body: AppButton.primary(
        label: 'Test',
        onPressed: () {},
      ),
    ),
  ));
  
  expect(find.text('Test'), findsOneWidget);
  expect(find.byType(ElevatedButton), findsOneWidget);
});
```

---

### Integration Tests (`fe-integration-tests`)
Test complete user flows:
1. **Registration Flow:**
   - Enter username/password
   - See password warning
   - Check acknowledgment
   - Submit
   - Navigate to home

2. **Add Pet Flow:**
   - Tap Add Pet FAB
   - Fill form (name, type, photo)
   - Save
   - See pet in list

3. **Add Reminder Flow:**
   - Select pet
   - Tap Add Reminder FAB
   - Fill form (title, date, frequency)
   - Enable notification (permission request)
   - Save
   - See reminder in list

---

## 📦 Mock Data Structure

For frontend development with mock data:

```dart
// lib/services/mock_data_service.dart
class MockDataService {
  static final User mockUser = User(
    id: 'user-1',
    username: 'testuser',
    email: 'test@example.com',
    createdAt: DateTime.now().subtract(Duration(days: 30)),
  );
  
  static final List<Pet> mockPets = [
    Pet(
      id: 'pet-1',
      name: 'Buddy',
      type: 'Dog',
      breed: 'Golden Retriever',
      gender: 'Male',
      birthday: DateTime(2020, 5, 15),
      photoUrl: 'assets/images/mock_pet_1.jpg',
    ),
    Pet(
      id: 'pet-2',
      name: 'Whiskers',
      type: 'Cat',
      breed: 'Siamese',
      gender: 'Female',
      birthday: DateTime(2019, 8, 20),
      photoUrl: 'assets/images/mock_pet_2.jpg',
    ),
  ];
  
  static final List<Weight> mockWeights = [
    Weight(id: 'w1', petId: 'pet-1', weight: 28.5, unit: 'kg', date: DateTime(2026, 1, 1)),
    Weight(id: 'w2', petId: 'pet-1', weight: 29.0, unit: 'kg', date: DateTime(2026, 2, 1)),
    Weight(id: 'w3', petId: 'pet-1', weight: 29.5, unit: 'kg', date: DateTime(2026, 3, 1)),
  ];
  
  static final List<Reminder> mockReminders = [
    Reminder(
      id: 'r1',
      petId: 'pet-1',
      title: 'Vet Checkup',
      datetime: DateTime.now().add(Duration(days: 2)),
      frequency: 'once',
      category: 'vet',
      priority: 'high',
      status: 'pending',
    ),
    Reminder(
      id: 'r2',
      petId: 'pet-2',
      title: 'Flea Treatment',
      datetime: DateTime.now().subtract(Duration(days: 1)),
      frequency: 'monthly',
      category: 'medication',
      priority: 'medium',
      status: 'pending', // Overdue!
    ),
  ];
  
  // Similar for Expenses, Photos, etc.
}
```

---

## 🚀 Ready to Start

**First 4 todos to implement (no dependencies):**

1. **fe-fonts** → Define text styles
2. **fe-colors** → Define color palette
3. **fe-spacing** → Define spacing constants
4. **fe-routing** → Set up navigation

**Then:** Build component library (atoms → molecules → organisms)

**See plan.md for complete todo list and dependencies.**

---

**Next:** Start with `fe-fonts` (create `lib/core/constants/text_styles.dart`)
