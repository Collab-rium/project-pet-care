# Pet-Care Application: UI Redesign & Feature Implementation Prompt

## OVERVIEW
Redesign the frontend of an existing pet-care application to match modern design standards, fix broken features, and implement missing functionality. **No context/logic changes** — only UI/UX improvements and feature completion.

---

## 🎨 DESIGN SYSTEM

### Design Reference
- **Visual Style Guide:** https://cdn.dribbble.com/userupload/45435724/file/035469a2e03139b7e9e5bb6e5313a450.png
- **Objective:** Match the aesthetic, layout patterns, and interaction flow shown in the reference

### Color Palettes (User-Selectable)

#### Warm Palette
- Primary: Warm coral/orange (#FF6B5B or similar)
- Secondary: Soft peach/cream (#FFD4C4 or similar)
- Accent: Gold/warm amber (#FFB84D or similar)
- Background: Off-white/cream (#FFFBF5 or similar)
- Text: Dark brown (#3D2817 or similar)
- **Mood:** Cozy, welcoming, playful — suits pet theme

#### Clean/Light Palette
- Primary: Soft blue (#5B9BD5 or similar)
- Secondary: Mint green (#A8D5BA or similar)
- Accent: Light lavender (#D4C5E2 or similar)
- Background: Off-white (#F8FAFB or similar)
- Text: Charcoal (#2C3E50 or similar)
- **Mood:** Fresh, clean, modern — professional yet pet-friendly

### Design Principles
- Clean whitespace and clear hierarchy
- Rounded corners (8-16px) for soft, pet-friendly feel
- Smooth transitions and micro-interactions
- Responsive design (mobile-first)
- Accessibility: WCAG AA compliant

---

## ✨ FEATURE REQUIREMENTS

### 1. DASHBOARD STATUS CARDS (Fix - Currently Broken)

**Current Issue:** Cards display numbers but are non-functional

**Expected Behavior After Fix:**
When user clicks a status card ("Completed," "Pending," or "Overdue"), **ALL of the following** should work:

#### Option A: Filter Task List Below Cards
- Dashboard shows task list below status cards
- Clicking a card filters the list to show only tasks in that status
- Visual indicator (highlight/border) shows which card is active
- Clear all filters button appears when filter is active

#### Option B: Navigate to Dedicated Status Page
- Clicking a card navigates to a detail page (e.g., `/tasks/pending`)
- Shows full task list for that status with more details
- Breadcrumb or back button for navigation
- Page title reflects the status (e.g., "Pending Tasks")

#### Option C: Modal/Popup with Summary
- Clicking a card opens a modal showing:
  - Total count for that status
  - Task list in modal
  - Quick actions (edit, delete, complete tasks)
  - Close button or click outside to dismiss

#### Implementation:**
- **Recommended:** Implement **A + C** (filter below + modal for quick view)
- Clicking the number/card opens modal (C)
- Clicking "View All" navigates to filtered list (A)
- Active state styling on selected card

---

### 2. BUDGET PAGE (New Full Page)

**Route:** `/budget` (accessible from main navigation)

**Layout:** Full-page dashboard with the following sections:

#### A. Pet Selection Dropdown
- List of all pets
- User can switch between pet budgets
- Shows which pet is currently selected

#### B. Budget Setup Section
- **Total Budget Input:** User enters annual/monthly budget for selected pet
- Display format: Clear indication of budget period (Monthly / Yearly)
- Edit button to update budget

#### C. Spending Overview Cards
- **Total Budget:** Display set budget amount
- **Total Spent:** Sum of all expenses for selected pet
- **Remaining:** Budget - Spent (with color indicator: green if positive, red if negative)
- **Spent Percentage:** Visual progress bar (0-100%)

#### D. Spending History / Monthly Records
- **Table or Timeline View** showing:
  - Month / Date
  - Category (Vet, Food, Grooming, etc.)
  - Amount spent
  - Notes/description
  - Action buttons (Edit, Delete)
- Sortable by date, amount, or category
- Filter options by category or date range

#### E. Chart Visualization (Optional/Toggleable)
- **Toggle in Settings:** User can choose to show/hide charts
- **Chart Options (if enabled):**
  - Line chart: Monthly spending trend over time
  - Bar chart: Month-to-month comparison
  - Pie chart: Spending by category breakdown
- Charts should be responsive and clean

#### F. Budget Statement/Summary Section
- Visual summary of:
  - Total spent this month
  - Average monthly spending
  - Highest spending month
  - Spending by category (breakdown)
- Export button (PDF/CSV) of budget statement

#### G. Monthly Budget Alerts (Optional/Toggleable)
- **Toggle in Account Settings:** User can enable/disable alerts
- **Alert Conditions:**
  - Alert when spending reaches 75% of budget
  - Alert when spending exceeds 100% of budget
- **Display:** Toast notification or inline warning banner
- Visual indicator on pet card if budget exceeded

---

### 3. ACCOUNT / PROFILE PAGE (New Full Page)

**Access Point:** Floating circle button (fixed position, bottom-right corner)
- Visible on all pages consistently
- Icon: Profile icon or user avatar
- Click to open account page or modal

**Route:** `/account` or modal at `/` with account modal open

**Page Sections:**

#### A. Profile Information
- User avatar/profile picture (editable, upload or choose preset)
- Display name (editable)
- Email address
- Account creation date

#### B. Google Account Integration
- Status indicator: "Connected" / "Not Connected"
- Button to connect/disconnect Google account
- If connected: Display Google email
- Use case: Sign-in with Google, data sync, etc.

#### C. Settings Menu (Organized Sections)

##### Account Settings
- [ ] Edit profile information
- [ ] Change password (if applicable)
- [ ] Two-factor authentication toggle

##### Preferences
- [ ] **Light/Dark Mode Toggle** (with persistent state)
- [ ] Notification settings (toggle for different notification types)
- [ ] **Wallpaper/Theme Customization** (see section D below)
- [ ] Display language (if multi-language support exists)

##### Financial
- [ ] **Payment Methods** - Add/edit/remove payment cards
- [ ] **Subscription Management** - View active subscription, billing cycle, upgrade/downgrade
- [ ] Billing history/invoices

##### Privacy & Security
- [ ] Privacy Policy link (opens in new tab or modal)
- [ ] Terms of Service link
- [ ] Data export/download option
- [ ] Delete account option (with confirmation)

##### Other
- [ ] **Switch Account** - Logout and switch to another account / Multi-account support
- [ ] **Logout** - Sign out of application
- [ ] Help/Support link
- [ ] App version and feedback option

---

### 4. WALLPAPER / BACKGROUND CUSTOMIZATION

**Access:** Via Account Page → Preferences → Wallpaper Settings

#### Features:

##### A. Preset Pet-Themed Wallpapers
- Provide 8-12 curated wallpaper options
- Categories: Dogs, Cats, Birds, Exotic Pets, Scenic/Nature, Abstract Pets
- Each wallpaper shows thumbnail preview
- One-click apply
- Responsive (adapts to mobile/tablet/desktop)

##### B. Custom Upload
- User can upload their own pet photo as wallpaper
- File type: JPG, PNG (max 5MB)
- Image cropping/positioning tool:
  - Preview how image looks as background
  - Adjust zoom, pan, position
  - Save preferred crop
- Validation: Show error if file too large or wrong format

##### C. Wallpaper Preview
- Real-time preview showing how wallpaper looks:
  - Desktop view
  - Mobile view
- Show selected wallpaper on account page or dashboard
- Opacity/brightness adjustment slider (optional) to ensure text readability

##### D. Persistence
- Selected wallpaper saved to user profile
- Loads automatically on each session
- Show current wallpaper with "Change" button

##### E. Delete/Reset
- Option to remove custom wallpaper
- Return to default or select different preset

---

## 🛠️ TECHNICAL NOTES

### Component Structure
```
- Dashboard (existing, fix cards)
  ├── StatusCards (Completed, Pending, Overdue) → functional
  ├── TaskList (filtered based on active card)
  └── TaskDetailModal (opens when card clicked)

- Budget Page (new)
  ├── PetSelector
  ├── BudgetSetup
  ├── SpendingOverview (cards)
  ├── SpendingHistory (table/timeline)
  ├── ChartVisualization (toggle-able)
  ├── BudgetStatement
  └── AlertSettings

- Account Page (new)
  ├── ProfileSection
  ├── GoogleIntegration
  ├── SettingsMenu
  │   ├── AccountSettings
  │   ├── Preferences (Light/Dark, Wallpaper)
  │   ├── Financial (Payments, Subscription)
  │   ├── Privacy
  │   └── Other (Logout, Switch Account)
  └── WallpaperCustomizer (modal/page)

- Floating Account Button (global)
  └── Fixed position bottom-right on all pages
```

### State Management
- Dashboard card filters should persist during session
- Wallpaper selection should persist across sessions (localStorage/database)
- Theme (light/dark) should persist across sessions
- Budget alerts should be real-time (if feature enabled)

### Data Flow
- Budget page filters by selected pet
- Spending history queried from backend or state
- Monthly records aggregated from transaction history
- Chart data computed from spending records

### Key Interactions
- Smooth transitions between pages
- Loading states for async data (budget calculations)
- Confirmation dialogs for destructive actions (delete wallpaper, logout)
- Toast notifications for alerts and success messages

---

## 📱 RESPONSIVE DESIGN

- **Desktop (1024px+):** Full layout with all sidebars, charts side-by-side
- **Tablet (768px-1023px):** Adjusted spacing, stacked sections as needed
- **Mobile (< 768px):** 
  - Floating button adjusted to avoid interference with mobile chrome
  - Charts become single-column or carousel
  - Dropdown for pet selection
  - Collapsible menu sections

---

## 🎯 ACCEPTANCE CRITERIA

### Dashboard Cards
- ✅ Cards are clickable and functionally distinct
- ✅ Filtering works without page reload
- ✅ Modal or detail page loads task data
- ✅ Visual feedback on selected card

### Budget Page
- ✅ Budget setup works (save/update budget)
- ✅ Spending calculations accurate
- ✅ Monthly history displays correctly
- ✅ Charts toggle on/off via settings
- ✅ Alerts function when enabled
- ✅ Export/download works

### Account Page
- ✅ All menu items functional
- ✅ Light/Dark mode toggle persists
- ✅ Google integration works
- ✅ Logout clears session
- ✅ Payment/subscription pages load

### Wallpaper Feature
- ✅ Presets display with thumbnails
- ✅ Custom upload accepts valid images
- ✅ Image cropping tool works
- ✅ Selection persists across sessions
- ✅ Wallpaper displays on dashboard/account page

### Floating Account Button
- ✅ Visible on all pages in bottom-right
- ✅ Doesn't overlap critical content
- ✅ Smooth animation on click
- ✅ Consistent styling across pages

---

## 🚀 IMPLEMENTATION PRIORITY

**Phase 1 (Critical):**
1. Update color palettes and apply to all pages
2. Fix Dashboard status cards
3. Create floating account button

**Phase 2 (Important):**
4. Build Budget page (without charts initially)
5. Build Account page with all menu items

**Phase 3 (Polish):**
6. Add Budget charts with toggle
7. Implement Wallpaper customization
8. Refine responsive design

---

## 📋 NOTES FOR DEVELOPER

- Keep all existing business logic intact
- Only update UI/UX and add missing features
- Ensure color palette is easily themeable (CSS variables recommended)
- Test responsiveness on actual devices, not just browser DevTools
- Consider accessibility: sufficient color contrast, keyboard navigation
- Add loading states and error handling for async operations
- Test data: Ensure mock data exists for budget scenarios with and without alerts
