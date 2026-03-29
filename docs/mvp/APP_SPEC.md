# App Specification — Pet Care App

**Source:** Analysis of 34 reference screenshots from professional pet care app  
**Date:** March 29, 2026  
**Purpose:** Complete feature specification and data model for pet care application  
**Analysis Source:** PHASE1_UI_ANALYSIS.md

---

## 1. Full Features List

### 1.1 Core Pet Management
- **Add/Edit Pet Profile**
  - Upload pet photo (circular avatar)
  - Set pet name, gender, type (dog/cat/other), breed
  - Record birthday, color, physical traits
  - Input microchip number and blood type
  - Document allergies, diet requirements, special care needs
  - Store veterinarian name and phone number
  - Add custom notes

- **Multi-Pet Management**
  - Create profiles for multiple pets
  - View pet list with photos and basic info
  - Switch between pet contexts
  - Delete pet profiles (with confirmation)

- **Pet Photo Gallery**
  - Upload multiple photos per pet
  - Organize photos in albums
  - View photos in grid and detail mode
  - Delete photos
  - Set cover photo for pet profile

### 1.2 Health Tracking
- **Weight Tracking**
  - Record weight measurements with date
  - View weight history as timeline list
  - Visualize weight trends with line chart
  - Set weight goals/targets
  - Track weight gain/loss over time
  - Filter by date range
  - Export weight data

- **Vaccination Management**
  - Log vaccination records (vaccine name, date, vet, cost)
  - Track upcoming vaccinations
  - Attach vaccination certificates/documents
  - Set reminders for booster shots
  - View vaccination history timeline
  - Mark vaccinations as complete

- **Medical Services**
  - Record vet visits, checkups, surgeries
  - Log service type, clinic name, date, time
  - Track service costs
  - Attach documents/photos to service records
  - View service history timeline
  - Filter services by type or date

### 1.3 Task & Reminder System
- **Reminders/Tasks**
  - Create reminders with title, description, date/time
  - Set reminder frequency (once, daily, weekly, monthly, yearly)
  - Categorize reminders (medication, grooming, vet, feeding, etc.)
  - Set priority levels
  - Enable push notifications
  - Mark reminders as complete
  - View upcoming, overdue, and completed reminders
  - Snooze or reschedule reminders

### 1.4 Financial Tracking
- **Expenses/Products**
  - Log pet-related expenses (category, amount, date, notes)
  - Track product purchases (food, toys, supplies)
  - View expense history
  - Generate expense reports
  - Visualize spending with charts
  - Filter by category, date range, or pet
  - Export expense data to CSV/PDF
  - Set budget limits and track spending against budget

### 1.5 Documentation
- **Document Management**
  - Upload documents (PDFs, images)
  - Categorize documents (medical records, certificates, receipts)
  - View documents in-app
  - Download documents
  - Delete documents
  - Attach documents to specific records (services, vaccinations)

### 1.6 Daily Logs/Journal
- **Pet Journal**
  - Create daily log entries (date, notes)
  - Log activities, behaviors, observations
  - Attach photos to log entries
  - View log history timeline
  - Search and filter logs
  - Track mood/behavior patterns

### 1.7 Collaboration Features
- **Multi-User Access**
  - Invite family members or caregivers via email
  - Set user roles and permissions (owner, editor, viewer)
  - Control what each user can view/edit
  - Revoke access when needed
  - View list of users with access
  - Transfer ownership

### 1.8 Settings & Preferences
- **Account Settings**
  - Edit profile information
  - Change password
  - Set email preferences
  - Manage notification settings (push, email)
  - Choose language

- **App Preferences**
  - Toggle light/dark mode
  - Set theme colors
  - Choose measurement units (kg/lbs, cm/inches)
  - Set date/time format
  - Enable/disable specific features

- **Data Management**
  - Backup data to cloud
  - Restore from backup
  - Export all data (JSON, CSV, PDF)
  - Delete all data (with confirmation)

- **Subscription/Premium**
  - View current subscription status
  - Upgrade to premium
  - Manage billing
  - View premium features

### 1.9 Discovery & Organization
- **Search & Filter**
  - Global search across all modules
  - Filter by pet, date range, category, status
  - Sort by date, name, or custom criteria
  - Save frequent searches

- **Empty States**
  - Friendly illustrations for empty modules
  - Clear CTAs to add first item
  - Onboarding guidance

---

## 2. UI Components Inventory

### 2.1 Navigation Components
- **Bottom Navigation Bar** (4-5 tabs: Home, Pets, Calendar, Settings)
- **Top App Bar** with back button, title, action icons (search, settings)
- **Floating Action Button (FAB)** for primary actions (Add)
- **Drawer/Sidebar** (if needed for additional navigation)

### 2.2 Layout Components
- **Pet Profile Card**
  - Circular pet photo
  - Pet name
  - Premium badge
  - Settings icon
  - Quick stats

- **Feature Module Grid**
  - 2-column grid layout
  - Icon cards with yellow circular backgrounds
  - Module labels
  - Card shadows

- **Timeline View**
  - Chronological list with date separators
  - Icon indicators for item type
  - Expandable detail cards

- **Card List**
  - Standard list items with cards
  - Swipe actions (edit, delete)
  - Multi-select mode

### 2.3 Form Components
- **Text Input Fields**
  - Single-line text
  - Multi-line text areas
  - Labeled fields
  - Required field indicators (*)
  - Error validation messages

- **Dropdowns/Selects**
  - Single select (breed, gender, type)
  - Multi-select (with checkboxes)
  - Search-enabled dropdowns

- **Date/Time Pickers**
  - Calendar picker
  - Time selector
  - Date range picker

- **File Upload**
  - Photo upload from camera or gallery
  - Document upload
  - Multiple file selection
  - Preview thumbnails

- **Toggle Switches**
  - Binary on/off settings
  - Enable/disable features

- **Radio Buttons & Checkboxes**
  - Single choice (radio)
  - Multiple choice (checkbox)

### 2.4 Data Display Components
- **Statistics Cards**
  - Metric title
  - Large number display
  - Trend indicator (up/down arrow)
  - Comparison text

- **Line Chart**
  - X-axis (dates)
  - Y-axis (values)
  - Data points
  - Tooltips on hover/tap
  - Zoom/pan controls

- **Bar Chart**
  - Category labels
  - Bar heights representing values
  - Color coding

- **Progress Bar/Indicator**
  - Linear progress
  - Circular progress
  - Percentage display

- **Badges**
  - Number badges (notification count)
  - Status badges (new, premium, overdue)
  - Color-coded labels

- **Avatars**
  - Circular pet photos
  - User avatars
  - Placeholder icons when no photo

### 2.5 Interactive Components
- **Buttons**
  - Primary button (filled, accent color)
  - Secondary button (outlined)
  - Text button (flat)
  - Icon button
  - FAB (floating action button)

- **Modal/Dialog**
  - Full-screen modal (forms)
  - Alert dialog (confirmations)
  - Bottom sheet (actions menu)

- **Tabs**
  - Horizontal tabs (swipeable)
  - Vertical tabs (if needed)
  - Tab indicators

- **Accordion/Expandable**
  - Collapsible sections
  - FAQ-style lists

- **Carousel**
  - Photo carousel
  - Swipeable cards

### 2.6 Feedback Components
- **Toast/Snackbar**
  - Success message
  - Error message
  - Info notification
  - Action button (undo)

- **Loading Indicators**
  - Spinner (circular)
  - Progress bar
  - Skeleton screens

- **Empty States**
  - Illustration
  - Heading
  - Description text
  - CTA button

### 2.7 Status Indicators
- **Color-Coded Status**
  - Green: Complete, Healthy, On-track
  - Yellow: Warning, Due Soon, Moderate
  - Red: Overdue, Urgent, Critical
  - Gray: Inactive, Disabled

- **Icons**
  - Checkmark (complete)
  - Clock (scheduled)
  - Exclamation (warning)
  - Bell (reminder)
  - Paw print (pet-related)

---

## 3. User Flows (Merged)

### 3.1 Onboarding Flow
1. Launch app → Marketing/splash screen
2. Create account or login
3. Add first pet → Fill profile form → Upload photo → Save
4. Tour of feature modules (optional)
5. Land on dashboard

### 3.2 Add Pet Flow
1. From pet list → Tap FAB (+)
2. Add Pet form opens
3. Fill required fields: name, type, gender
4. Optional: Upload photo, add birthday, breed, etc.
5. Tap Save
6. Return to pet list with new pet visible

### 3.3 Track Weight Flow
1. Pet Dashboard → Tap "Weights" card
2. Weight history list opens
3. Tap FAB (+) to add weight
4. Enter weight value and date
5. Save
6. View updated chart and timeline

### 3.4 Schedule Reminder Flow
1. Pet Dashboard → Tap "Reminders" card
2. Reminders list opens
3. Tap FAB (+) to add reminder
4. Fill form: title, date/time, frequency, category
5. Enable push notification (toggle)
6. Save
7. Reminder appears in upcoming list

### 3.5 Log Service/Vet Visit Flow
1. Pet Dashboard → Tap "Services" card
2. Services history opens
3. Tap FAB (+) to log visit
4. Fill form: service type, clinic, date, cost
5. Attach photos/documents (optional)
6. Save
7. Service appears in timeline

### 3.6 View Expense Report Flow
1. Pet Dashboard → Tap "Products" or "Expenses" card
2. Expense list opens
3. Tap filter/sort icon
4. Select date range, category filters
5. View filtered list and chart
6. Tap export icon → Choose format (CSV/PDF)
7. Share or download file

### 3.7 Invite User Flow
1. Settings → Users/Sharing
2. User list opens
3. Tap "Invite User" button
4. Enter email address
5. Set role (viewer, editor, owner)
6. Send invitation
7. User receives email with invite link
8. User accepts → Gains access

### 3.8 Backup Data Flow
1. Settings → Data Management
2. Tap "Backup Now" button
3. Choose backup location (cloud service)
4. Confirm backup
5. Progress indicator shows backup status
6. Success message with timestamp

### 3.9 Switch Between Pets Flow
1. From any screen with pet context
2. Tap pet name/photo at top
3. Pet selector dropdown opens
4. Tap different pet
5. Context switches to selected pet
6. Dashboard/modules update for new pet

### 3.10 Search Flow
1. From dashboard or list screen
2. Tap search icon (top bar)
3. Search field appears
4. Enter search query
5. Results appear in real-time
6. Tap result to view detail
7. Or apply filters to refine search

---

## 4. Inferred Data Model

### 4.1 Core Entities

#### User
```
id: UUID (primary key)
username: String (unique)
email: String (unique)
passwordHash: String
profilePhoto: String (URL/path)
createdAt: Timestamp
updatedAt: Timestamp
preferences: JSON {
  theme: "light" | "dark"
  colorPalette: "warm" | "clean"
  units: "metric" | "imperial"
  language: "en" | "es" | ...
  notificationsEnabled: Boolean
}
subscriptionStatus: "free" | "premium"
subscriptionExpiry: Timestamp
```

#### Pet
```
id: UUID (primary key)
ownerId: UUID (foreign key → User)
name: String
type: "dog" | "cat" | "bird" | "other"
breed: String (optional)
gender: "male" | "female" | "other"
birthday: Date (optional)
color: String (optional)
chipNumber: String (optional)
bloodType: String (optional)
weight: Float (current weight, optional)
allergies: Text (optional)
diet: Text (optional)
specialCare: Text (optional)
vetName: String (optional)
vetPhone: String (optional)
notes: Text (optional)
photoUrl: String (primary photo)
createdAt: Timestamp
updatedAt: Timestamp
isActive: Boolean (soft delete)
```

#### Weight
```
id: UUID (primary key)
petId: UUID (foreign key → Pet)
weight: Float (required)
unit: "kg" | "lbs"
date: Date (required)
notes: Text (optional)
createdAt: Timestamp
```

#### Vaccination
```
id: UUID (primary key)
petId: UUID (foreign key → Pet)
vaccineName: String (required)
date: Date (required)
vetName: String (optional)
clinic: String (optional)
cost: Float (optional)
nextDueDate: Date (optional)
certificateUrl: String (document path, optional)
notes: Text (optional)
completed: Boolean
createdAt: Timestamp
updatedAt: Timestamp
```

#### Service
```
id: UUID (primary key)
petId: UUID (foreign key → Pet)
serviceType: "checkup" | "surgery" | "grooming" | "dental" | "other"
clinicName: String (optional)
date: Date (required)
time: Time (optional)
cost: Float (optional)
notes: Text (optional)
createdAt: Timestamp
updatedAt: Timestamp
```

#### Reminder
```
id: UUID (primary key)
petId: UUID (foreign key → Pet)
title: String (required)
description: Text (optional)
datetime: Timestamp (required)
frequency: "once" | "daily" | "weekly" | "monthly" | "yearly"
category: "medication" | "grooming" | "vet" | "feeding" | "other"
priority: "low" | "medium" | "high"
completed: Boolean
completedAt: Timestamp (optional)
notificationEnabled: Boolean
createdAt: Timestamp
updatedAt: Timestamp
```

#### Expense
```
id: UUID (primary key)
petId: UUID (foreign key → Pet)
userId: UUID (foreign key → User)
category: "food" | "vet" | "toys" | "grooming" | "supplies" | "other"
amount: Float (required)
currency: String (default: "USD")
date: Date (required)
description: Text (optional)
receiptUrl: String (optional)
createdAt: Timestamp
updatedAt: Timestamp
```

#### Document
```
id: UUID (primary key)
petId: UUID (foreign key → Pet)
title: String (required)
fileUrl: String (required)
fileType: "image" | "pdf" | "other"
fileSizeBytes: Integer
category: "medical" | "certificate" | "receipt" | "other"
uploadedAt: Timestamp
```

#### Log
```
id: UUID (primary key)
petId: UUID (foreign key → Pet)
userId: UUID (foreign key → User)
date: Date (required)
notes: Text (required)
mood: "happy" | "sad" | "anxious" | "playful" | "other" (optional)
activity: String (optional)
createdAt: Timestamp
updatedAt: Timestamp
```

#### Photo
```
id: UUID (primary key)
petId: UUID (foreign key → Pet)
userId: UUID (foreign key → User)
imageUrl: String (required)
albumId: UUID (foreign key → Album, optional)
caption: Text (optional)
uploadedAt: Timestamp
```

#### Album
```
id: UUID (primary key)
petId: UUID (foreign key → Pet)
name: String (required)
coverPhotoId: UUID (foreign key → Photo, optional)
createdAt: Timestamp
updatedAt: Timestamp
```

#### UserAccess (for multi-user collaboration)
```
id: UUID (primary key)
petId: UUID (foreign key → Pet)
userId: UUID (foreign key → User)
role: "owner" | "editor" | "viewer"
invitedBy: UUID (foreign key → User)
invitedAt: Timestamp
acceptedAt: Timestamp (null if pending)
permissions: JSON {
  canEdit: Boolean
  canDelete: Boolean
  canInvite: Boolean
  canViewExpenses: Boolean
}
```

#### Budget (optional, for future)
```
id: UUID (primary key)
petId: UUID (foreign key → Pet)
amount: Float (required)
period: "monthly" | "yearly"
alertAt75Percent: Boolean
alertAt100Percent: Boolean
createdAt: Timestamp
updatedAt: Timestamp
```

#### Notification (for push notifications)
```
id: UUID (primary key)
userId: UUID (foreign key → User)
petId: UUID (foreign key → Pet, optional)
reminderId: UUID (foreign key → Reminder, optional)
type: "reminder" | "overdue" | "invitation" | "system"
title: String
body: Text
read: Boolean
sentAt: Timestamp
readAt: Timestamp (optional)
```

### 4.2 Relationships

- **User → Pet**: One-to-Many (one user owns many pets)
- **Pet → Weight**: One-to-Many (one pet has many weight records)
- **Pet → Vaccination**: One-to-Many
- **Pet → Service**: One-to-Many
- **Pet → Reminder**: One-to-Many
- **Pet → Expense**: One-to-Many
- **Pet → Document**: One-to-Many
- **Pet → Log**: One-to-Many
- **Pet → Photo**: One-to-Many
- **Pet → Album**: One-to-Many
- **Album → Photo**: One-to-Many
- **Pet → UserAccess**: One-to-Many (one pet can have many users with access)
- **User → UserAccess**: One-to-Many (one user can have access to many pets)

### 4.3 File Storage Structure

```
/uploads/
  /users/
    /{userId}/
      avatar.jpg
  /pets/
    /{petId}/
      profile.jpg
      /photos/
        {photoId}.jpg
      /documents/
        {documentId}.pdf
      /certificates/
        {certId}.jpg
  /receipts/
    /{expenseId}.jpg
```

---

## 5. Design Notes

### 5.1 Brand Identity
- **Primary Color:** Bright yellow (#FFD700 range)
- **Accent Colors:** Warm oranges, soft pinks for secondary elements
- **Theme:** Friendly, approachable, pet-focused
- **Visual Motifs:** Paw prints, pet illustrations, rounded shapes

### 5.2 Typography Recommendations
- **Headings:** Poppins (600-700 weight) for modern, friendly feel
- **Body Text:** Inter (400-500 weight) for readability
- **Sizes:** H1=32px, H2=28px, H3=20px, Body=16px, Small=14px

### 5.3 Layout Patterns
- **Spacing:** 8px base unit, 16-24px card padding
- **Border Radius:** 12px standard, 20px for prominent cards
- **Grid:** 2-column for feature cards on mobile
- **Shadows:** Subtle elevation for cards (2-4dp)

### 5.4 Color Modes
- **Light Mode:**
  - Background: #FFF9F5 (warm) or #F5F7FA (clean)
  - Surface: #FFFFFF
  - Text: #2C2C2C (dark gray)
  - Primary: Yellow (#FFD700 or #FF8C42)
  
- **Dark Mode:**
  - Background: #1A1A1A
  - Surface: #2C2C2C
  - Text: #F5F5F5 (light gray)
  - Primary: Yellow (#FFD700) - maintains brand visibility

### 5.5 Accessibility Considerations
- **Contrast Ratios:** Ensure WCAG AA compliance (4.5:1 for text)
- **Touch Targets:** Minimum 44x44dp for buttons and interactive elements
- **Font Sizes:** Minimum 14px for body text, scalable for accessibility
- **Color Independence:** Don't rely solely on color for status (use icons too)

### 5.6 Responsive Design
- **Mobile-First:** Design for mobile, scale up for tablet/desktop
- **Breakpoints:** 
  - Mobile: 320-767px
  - Tablet: 768-1023px
  - Desktop: 1024px+
- **Navigation:** Bottom bar on mobile, sidebar on desktop

### 5.7 Animations & Micro-interactions
- **Page Transitions:** Slide or fade (200-300ms)
- **Button Press:** Scale down slightly (0.95) with haptic feedback
- **Card Expand:** Smooth height transition (300ms ease-in-out)
- **Loading:** Skeleton screens preferred over spinners
- **Success Actions:** Brief celebration animation (confetti, checkmark)

### 5.8 Performance Considerations
- **Image Optimization:** Compress photos to 80% quality, max 1920px width
- **Lazy Loading:** Load images as user scrolls
- **Pagination:** 20-50 items per page for lists
- **Caching:** Cache pet profiles and recent data locally
- **Offline Support:** Queue actions when offline, sync when back online

### 5.9 Error Handling Patterns
- **Validation:** Real-time field validation with clear error messages
- **Network Errors:** Friendly message with retry button
- **Empty States:** Encouraging copy with clear CTA
- **Confirmation Dialogs:** For destructive actions (delete, logout)

### 5.10 Notable UX Patterns from Reference App
- **Breadcrumb Pet Context:** Pet name/photo always visible showing current context
- **FAB for Primary Actions:** Consistent (+) button placement for adding items
- **Timeline Views:** Effective for chronological data (services, logs, vaccinations)
- **Swipe Actions:** Quick access to edit/delete without entering detail view
- **Color-Coded Status:** Immediate visual understanding of urgency/completion
- **Empty State Illustrations:** Makes empty modules feel intentional and friendly
- **Premium Badge Visibility:** Subtle but clear indication of subscription status

---

## 6. Complexity Assessment & Recommendations

### 6.1 Complexity Level: MODERATE TO HIGH

This reference app is a **comprehensive pet management system**, not a simple tracker. Key complexity drivers:

**Technical Complexity:**
- 9 major feature modules requiring separate UI and data logic
- Multi-user collaboration with role-based access control
- Real-time synchronization across users
- File storage and management system
- Push notification infrastructure
- Data export functionality
- Premium subscription management
- Advanced data visualization (charts, reports)

**Data Complexity:**
- 14+ database tables with complex relationships
- Photo/document file management
- Recurring reminder logic with various frequencies
- Cross-module search and filtering
- Data integrity across user permissions

**UX Complexity:**
- Multi-pet context switching
- Consistent navigation across modules
- Empty states for all modules
- Error handling for all operations
- Offline support and sync

### 6.2 Development Estimate

| Scope | Timeline | Team Size | Features Included |
|-------|----------|-----------|-------------------|
| **MVP** | 3-4 months | 2-3 developers | Single pet, profile, 2-3 tracking modules, basic lists |
| **Standard** | 6-9 months | 3-4 developers | Multi-pet, all tracking modules, basic collaboration, export |
| **Full-Featured** | 9-12 months | 4-5 developers | Everything in reference app including premium features |

### 6.3 MVP Recommendation

**For initial launch, focus on:**

✅ **MUST HAVE (MVP):**
1. User authentication (username + password)
2. Single pet profile management
3. Pet photo upload
4. Weight tracking with basic chart
5. Reminder/task system with notifications
6. Basic expense logging (no reports yet)
7. Light/dark mode toggle
8. Local SQLite persistence
9. Manual backup/restore (unencrypted to start)

⚠️ **NICE TO HAVE (Post-MVP Phase 1):**
1. Multi-pet management
2. Vaccination tracking
3. Service/vet visit logging
4. Document uploads
5. Photo gallery with albums
6. Daily log/journal
7. Expense reports with charts
8. Data export (CSV)

❌ **SKIP FOR NOW (Phase 2+):**
1. Multi-user collaboration
2. Role-based permissions
3. User invitations via email
4. Cloud backup/sync
5. Premium subscriptions
6. Advanced search across modules
7. Complex data analytics

### 6.4 Architecture Recommendations

**For MVP:**
- **Frontend:** Flutter (cross-platform mobile)
- **Backend:** Node.js/Express (RESTful API) OR local-only SQLite
- **Database:** SQLite (local-first approach)
- **File Storage:** Local device storage
- **Auth:** Simple JWT-based authentication
- **Notifications:** Local notifications (flutter_local_notifications)

**For Post-MVP:**
- **Backend:** Add cloud sync (Firebase, Supabase, or custom backend)
- **File Storage:** Cloud storage (S3, Cloudinary) for sync across devices
- **Auth:** Add OAuth options (Google, Apple)
- **Notifications:** Add push notifications (FCM)
- **Analytics:** Add usage tracking (Firebase Analytics, Mixpanel)

### 6.5 Key Architectural Decisions Needed

1. **Local-first vs Cloud-first?**
   - Local-first: Simpler MVP, no server costs, faster initial launch
   - Cloud-first: Better multi-device support, easier collaboration features
   - **Recommendation:** Start local-first, add cloud sync in Phase 2

2. **Encryption for backups?**
   - Adds complexity and potential for user lockout if password forgotten
   - **Recommendation:** Optional encryption in settings, default unencrypted

3. **Multi-user now or later?**
   - Complex feature requiring careful permission design
   - **Recommendation:** Phase 2+ feature

4. **Premium/subscription model?**
   - Requires payment integration, feature gating, subscription management
   - **Recommendation:** Ship free MVP first, validate demand before adding payments

---

**End of App Specification**

*This document serves as the source of truth for Phases 3-6 of the analysis pipeline.*
