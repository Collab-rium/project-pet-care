# PHASE 6 — Implementation Roadmap

**Date:** March 29, 2026  
**Purpose:** Prioritized build plan with component breakdown and step-by-step development order  
**Approach:** Frontend-first with mock data → Confirm UX → Implement backend

---

## 1. MVP Features (Must Ship First)

### Priority Order by User Impact

| Rank | Feature | User Value | Complexity | Days (FE) | Days (BE) |
|------|---------|------------|------------|-----------|-----------|
| 1 | **Pet Profiles** | Critical | Low | 2 | ✅ Done |
| 2 | **Photo Upload** | High | Low | 1 | 1 |
| 3 | **Weight Tracking** | High | Medium | 3 | 2 |
| 4 | **Reminders/Tasks** | Critical | Medium | 3 | ✅ Done |
| 5 | **Notifications** | Critical | High | 2 | 5 |
| 6 | **Expense Logging** | Medium | Low | 2 | ✅ Planned |
| 7 | **Budget Dashboard** | Medium | Medium | 3 | ✅ Planned |
| 8 | **Settings** | Medium | Low | 2 | ✅ Planned |
| 9 | **Backup/Restore** | Medium | High | 3 | ✅ Planned |
| 10 | **Dark Mode** | Low | Low | 1 | 0 |

**Total MVP Effort:** ~22 days frontend + ~8 days backend = **30 days** (~6 weeks with 1 FE + 1 BE developer)

---

## 2. Post-MVP Features (Phase 2)

| Feature | User Value | Complexity | Days (FE) | Days (BE) |
|---------|------------|------------|-----------|-----------|
| **Photo Gallery** | High | Medium | 4 | 4 |
| **Vaccinations** | Medium | Medium | 3 | 3 |
| **Services/Vet Visits** | Medium | Low | 2 | 2 |
| **Documents** | Low | Medium | 3 | 3 |
| **Daily Logs** | Low | Low | 2 | 2 |
| **Medications** | Medium | Medium | 4 | 4 |
| **Emergency Contacts** | High | Low | 1 | 1 |

**Total Post-MVP Effort:** ~19 days frontend + ~19 days backend = **38 days** (~8 weeks)

---

## 3. Future Enhancements (Phase 3+)

| Feature | User Value | Complexity | Days (FE) | Days (BE) |
|---------|------------|------------|-----------|-----------|
| **Multi-User Collaboration** | Low | Very High | 7 | 10 |
| **Insurance Tracking** | Low | Low | 1 | 1 |
| **Data Export (Enhanced)** | Low | Medium | 2 | 3 |
| **Widgets** | Medium | Medium | 3 | 0 |
| **Cloud Sync** | Low | Very High | 5 | 14 |
| **Vet Integration** | Low | Very High | 7 | 21 |

**Total Phase 3+ Effort:** ~25 days frontend + ~49 days backend = **74 days** (~15 weeks)

---

## 4. Component Breakdown

### 4.1 Reusable UI Components (Build Once, Use Everywhere)

**Atoms (Smallest Components):**
- `Button` (primary, secondary, icon, FAB)
- `Input` (text, number, date, multiline)
- `Dropdown` (select, searchable)
- `Toggle` (switch, checkbox, radio)
- `Badge` (count, status)
- `Avatar` (pet photo, user photo, placeholder)
- `Icon` (paw, calendar, bell, camera, etc.)
- `Tag` (category labels)

**Molecules (Component Combinations):**
- `Card` (standard container with shadow)
- `FormField` (label + input + error message)
- `SearchBar` (input + search icon + clear button)
- `DateRangePicker` (start date + end date)
- `StatCard` (metric + value + trend)
- `ListItem` (icon + title + subtitle + action)
- `EmptyState` (illustration + heading + CTA button)

**Organisms (Complex Components):**
- `PetProfileCard` (photo + name + badges + settings icon)
- `FeatureGrid` (2-column grid of icon cards)
- `TimelineItem` (date + icon + content + actions)
- `ChartCard` (card with embedded chart)
- `Modal` (overlay + content + header + footer)
- `BottomSheet` (slide-up action menu)
- `Navbar` (bottom nav with 4-5 tabs)
- `TopBar` (back button + title + actions)

**Templates (Page Layouts):**
- `DashboardLayout` (pet selector + stat cards + list)
- `DetailLayout` (header + scrollable content + FAB)
- `FormLayout` (header + form fields + save button)
- `ListLayout` (header + search + list + FAB)
- `SettingsLayout` (grouped list of settings)

---

### 4.2 Frontend Pages & Screens

#### **MVP Pages (10 screens)**

1. **Onboarding/Login**
   - Welcome screen
   - Login form
   - Register form
   - Forgot password (if implemented)

2. **Pet Management**
   - Pet list (if multiple pets)
   - Pet profile form (add/edit)
   - Pet dashboard (feature grid)

3. **Weight Tracking**
   - Weight list (timeline view)
   - Add weight form (modal)
   - Weight chart screen

4. **Reminders**
   - Reminder list (upcoming, overdue, completed tabs)
   - Add reminder form
   - Reminder detail/edit

5. **Expenses**
   - Expense list
   - Add expense form
   - Expense detail

6. **Budget**
   - Budget overview (cards + chart)
   - Set budget form

7. **Settings**
   - Settings list (theme, wallpaper, notifications, account)
   - Theme selector
   - Wallpaper upload
   - Account info

8. **Backup/Restore**
   - Backup screen (export button, backup history)
   - Restore screen (file picker, preview, import button)

#### **Post-MVP Pages (7 screens)**

9. **Photo Gallery**
   - Album list
   - Photo grid (by album)
   - Photo viewer (full-screen, swipe)
   - Add album form

10. **Vaccinations**
    - Vaccination list (timeline)
    - Add vaccination form
    - Vaccination detail

11. **Services**
    - Service history (timeline)
    - Add service form
    - Service detail

12. **Documents**
    - Document list (by category)
    - Document viewer
    - Upload document form

13. **Daily Logs**
    - Log list (timeline)
    - Add log form
    - Log detail

14. **Medications**
    - Active medications list
    - Add medication form
    - Medication detail + history

15. **Emergency Contacts**
    - Contact list
    - Add contact form

---

### 4.3 Backend Modules

**Existing (Phase 0-3 Complete):**
- `auth.js` - User registration, login, JWT
- `pets.js` - CRUD for pets
- `reminders.js` - CRUD for reminders
- `dashboard.js` - Aggregate stats

**New for MVP:**
- `weights.js` - CRUD for weight records
- `photos.js` - Photo upload, gallery, albums
- `notifications.js` - Push notifications, FCM integration
- `backup.js` - Export/import with encryption (already planned)
- `budget.js` - Budget + expenses (already planned)
- `settings.js` - User preferences (already planned)

**Post-MVP Modules:**
- `vaccinations.js`
- `services.js`
- `documents.js`
- `logs.js`
- `medications.js`
- `emergency-contacts.js`

---

## 5. API Contract Additions (New Endpoints)

### MVP Endpoints

```typescript
// Weight Tracking
POST   /pets/:petId/weights          → {id, petId, weight, unit, date, notes}
GET    /pets/:petId/weights          → [{id, weight, unit, date, notes}]
PUT    /pets/:petId/weights/:id      → {id, weight, unit, date, notes}
DELETE /pets/:petId/weights/:id      → {success: true}

// Photos
POST   /pets/:petId/photo            → {photoUrl}  // Profile photo
POST   /pets/:petId/photos           → {id, imageUrl, ...}  // Gallery photo
GET    /pets/:petId/photos           → [{id, imageUrl, caption, uploadedAt}]
DELETE /pets/:petId/photos/:id       → {success: true}

// Albums
POST   /pets/:petId/albums           → {id, name, coverPhotoId}
GET    /pets/:petId/albums           → [{id, name, coverPhotoId, photoCount}]
PUT    /pets/:petId/albums/:id       → {id, name, coverPhotoId}
DELETE /pets/:petId/albums/:id       → {success: true}

// Notifications
GET    /notifications?read=false     → [{id, title, body, read, sentAt}]
PUT    /notifications/:id/read       → {id, read: true, readAt}
POST   /notifications/register-token → {success: true}  // FCM token
```

### Post-MVP Endpoints

```typescript
// Vaccinations
POST   /pets/:petId/vaccinations     → {id, vaccineName, date, ...}
GET    /pets/:petId/vaccinations     → [{id, vaccineName, date, nextDueDate}]
PUT    /pets/:petId/vaccinations/:id → {id, ...}
DELETE /pets/:petId/vaccinations/:id → {success: true}
POST   /pets/:petId/vaccinations/:id/certificate → {certificateUrl}

// Services
POST   /pets/:petId/services         → {id, serviceType, clinicName, date, ...}
GET    /pets/:petId/services         → [{id, serviceType, date, cost}]
PUT    /pets/:petId/services/:id     → {id, ...}
DELETE /pets/:petId/services/:id     → {success: true}

// Documents
POST   /pets/:petId/documents        → {id, title, fileUrl, fileType, ...}
GET    /pets/:petId/documents        → [{id, title, fileType, category, uploadedAt}]
GET    /pets/:petId/documents/:id/download → File download
DELETE /pets/:petId/documents/:id    → {success: true}

// Logs
POST   /pets/:petId/logs             → {id, date, notes, mood, activity}
GET    /pets/:petId/logs             → [{id, date, notes, mood}]
PUT    /pets/:petId/logs/:id         → {id, ...}
DELETE /pets/:petId/logs/:id         → {success: true}

// Medications
POST   /pets/:petId/medications      → {id, name, dosage, frequency, ...}
GET    /pets/:petId/medications?active=true → [{id, name, dosage, active}]
PUT    /pets/:petId/medications/:id  → {id, ...}
DELETE /pets/:petId/medications/:id  → {success: true}
POST   /pets/:petId/medications/:id/log → {id, administeredAt, administeredBy}
GET    /pets/:petId/medications/:id/logs → [{id, administeredAt, administeredBy}]

// Emergency Contacts
GET    /pets/:petId/emergency-contacts → [{id, name, phone, type}]
POST   /pets/:petId/emergency-contacts → {id, name, phone, type, notes}
PUT    /pets/:petId/emergency-contacts/:id → {id, ...}
DELETE /pets/:petId/emergency-contacts/:id → {success: true}
```

---

## 6. Step-by-Step Development Order

### Phase 0: Project Setup (Days 1-2)

**Frontend:**
1. ✅ Create Flutter project
2. ✅ Set up folder structure (lib/components, lib/pages, lib/services, lib/models)
3. ✅ Install dependencies (http, provider, fl_chart, image_picker, flutter_local_notifications)
4. ✅ Set up theme (colors, typography, spacing constants)
5. ✅ Create basic navigation (bottom nav bar)
6. ✅ Build component library (Button, Input, Card, etc.)

**Backend:**
1. ✅ Already complete (Phase 0-3 done)

**Deliverable:** Project structure + component library + navigation skeleton

---

### Phase 1: Core Features (Days 3-12) — **MVP Sprint 1**

#### Week 1: Pet Profiles + Weight Tracking

**Day 3-4: Pet Profile Page (Frontend)**
- Build pet profile form (all fields from spec)
- Profile photo upload UI (camera + gallery picker)
- Mock data service for testing
- Validate required fields
- Save to local state

**Day 5: Weight Tracking List (Frontend)**
- Timeline view of weight entries
- Add weight form (modal)
- Chart component (use fl_chart)
- Filter by date range
- Mock weight data

**Day 6: Weight Tracking Chart (Frontend)**
- Line chart with weight over time
- Zoom/pan controls (optional)
- Tap data point to see details
- Empty state when no data

**Day 7-8: Weight Tracking Backend**
- Create `weights` table in SQLite
- Implement CRUD endpoints
- Test with Postman/Insomnia
- Connect frontend to backend
- Test end-to-end flow

**Day 9: Pet Profile Photo Backend**
- Implement photo upload endpoint (multer)
- Image compression (sharp)
- File storage setup
- Update pets table with photoUrl
- Connect frontend to backend

**Deliverable:** Working pet profiles + weight tracking (full stack)

---

#### Week 2: Reminders + Notifications

**Day 10-11: Reminders UI (Frontend)**
- Reminder list (3 tabs: upcoming, overdue, completed)
- Add reminder form
- Edit reminder form
- Mark complete action
- Connect to existing backend (already done)

**Day 12-14: Notification System (Backend)**
- Create `notifications` table
- Background job (node-cron) to check for due reminders
- Create notification records
- FCM integration (optional for MVP)
- Local notification fallback

**Day 15: Notification UI (Frontend)**
- Notification list screen
- Mark as read action
- Tap notification → open reminder detail
- Badge count on nav icon

**Deliverable:** Working reminders + notifications

---

### Phase 2: Financial Features (Days 13-18) — **MVP Sprint 2**

**Day 16-17: Expense Logging (Frontend)**
- Expense list view
- Add expense form (category, amount, date, notes)
- Filter by category and date range
- Mock expense data
- Connect to backend (already planned)

**Day 18-19: Budget Dashboard (Frontend)**
- Budget overview cards (total, spent, remaining, percentage)
- Set budget form
- Spending chart (line or bar chart)
- Alert indicators (75%, 100% thresholds)
- Connect to backend (already planned)

**Day 20: Budget/Expenses Backend**
- Verify existing implementation from LOCAL_BACKUP_PERSISTENCE.md
- Test budget calculation logic
- Connect frontend to backend
- End-to-end testing

**Deliverable:** Working expense tracking + budget dashboard

---

### Phase 3: Settings & Backup (Days 19-24) — **MVP Sprint 3**

**Day 21-22: Settings Page (Frontend)**
- Settings list (grouped sections)
- Theme toggle (light/dark mode)
- Color palette selector (Warm/Clean/Golden)
- Wallpaper upload
- Notification settings
- Account info display
- Connect to backend (already planned)

**Day 23-24: Backup/Restore (Frontend)**
- Backup screen (export button)
- Restore screen (file picker)
- Progress indicators
- Success/error messages
- Encryption password prompt (if implemented)
- Connect to backend (already planned)

**Day 25: Settings/Backup Backend**
- Verify existing implementation
- Test backup encryption/decryption
- Test import/export flow
- Handle edge cases (corrupted files, missing data)

**Deliverable:** Working settings + backup/restore

---

### Phase 4: Polish & Testing (Days 25-30) — **MVP Sprint 4**

**Day 26-27: UI Polish**
- Implement dark mode fully
- Add loading states (skeletons)
- Add error states
- Add empty states (illustrations + copy)
- Smooth animations and transitions
- Accessibility improvements

**Day 28-29: Testing & Bug Fixes**
- Manual testing of all features
- Fix critical bugs
- Test on multiple devices (iOS + Android)
- Test offline behavior
- Test backup/restore with real data

**Day 30: Final Polish & Deployment Prep**
- Performance optimization
- Code cleanup
- Update documentation
- Prepare release notes
- Build release APK

**Deliverable:** MVP ready for testing/launch

---

### Phase 5: Post-MVP (Weeks 7-14)

**Week 7-8: Photo Gallery**
- Album management UI
- Photo grid view
- Photo viewer (full-screen)
- Backend: photos + albums tables + file uploads

**Week 9-10: Health Modules (Vaccinations + Services)**
- Vaccination list + form
- Service history list + form
- Backend: vaccinations + services tables

**Week 11-12: Documents + Logs**
- Document upload + viewer
- Daily log entries
- Backend: documents + logs tables

**Week 13-14: Medications + Emergency Contacts**
- Medication tracking + reminders
- Medication administration log
- Emergency contacts list
- Backend: medications + emergency_contacts tables

**Deliverable:** Full-featured app (all core modules complete)

---

## 7. Folder Structure (Frontend)

```
lib/
├── main.dart
├── app.dart (theme, routes)
├── core/
│   ├── constants/
│   │   ├── colors.dart
│   │   ├── text_styles.dart
│   │   └── spacing.dart
│   ├── utils/
│   │   ├── date_formatter.dart
│   │   ├── validators.dart
│   │   └── helpers.dart
│   └── services/
│       ├── api_service.dart
│       ├── storage_service.dart (SQLite)
│       ├── auth_service.dart
│       └── notification_service.dart
├── models/
│   ├── user.dart
│   ├── pet.dart
│   ├── reminder.dart
│   ├── weight.dart
│   ├── expense.dart
│   ├── notification.dart
│   └── ...
├── components/
│   ├── atoms/
│   │   ├── button.dart
│   │   ├── input.dart
│   │   ├── dropdown.dart
│   │   ├── toggle.dart
│   │   ├── badge.dart
│   │   ├── avatar.dart
│   │   └── icon.dart
│   ├── molecules/
│   │   ├── card.dart
│   │   ├── form_field.dart
│   │   ├── search_bar.dart
│   │   ├── date_range_picker.dart
│   │   ├── stat_card.dart
│   │   ├── list_item.dart
│   │   └── empty_state.dart
│   ├── organisms/
│   │   ├── pet_profile_card.dart
│   │   ├── feature_grid.dart
│   │   ├── timeline_item.dart
│   │   ├── chart_card.dart
│   │   ├── modal.dart
│   │   ├── bottom_sheet.dart
│   │   ├── navbar.dart
│   │   └── top_bar.dart
│   └── templates/
│       ├── dashboard_layout.dart
│       ├── detail_layout.dart
│       ├── form_layout.dart
│       ├── list_layout.dart
│       └── settings_layout.dart
├── pages/
│   ├── auth/
│   │   ├── login_page.dart
│   │   ├── register_page.dart
│   │   └── forgot_password_page.dart
│   ├── pets/
│   │   ├── pet_list_page.dart
│   │   ├── pet_form_page.dart
│   │   └── pet_dashboard_page.dart
│   ├── weights/
│   │   ├── weight_list_page.dart
│   │   ├── weight_form_page.dart
│   │   └── weight_chart_page.dart
│   ├── reminders/
│   │   ├── reminder_list_page.dart
│   │   ├── reminder_form_page.dart
│   │   └── reminder_detail_page.dart
│   ├── expenses/
│   │   ├── expense_list_page.dart
│   │   └── expense_form_page.dart
│   ├── budget/
│   │   ├── budget_dashboard_page.dart
│   │   └── budget_form_page.dart
│   ├── settings/
│   │   ├── settings_page.dart
│   │   ├── theme_page.dart
│   │   ├── wallpaper_page.dart
│   │   └── account_page.dart
│   ├── backup/
│   │   ├── backup_page.dart
│   │   └── restore_page.dart
│   └── notifications/
│       └── notification_list_page.dart
└── providers/ (if using Provider state management)
    ├── auth_provider.dart
    ├── pet_provider.dart
    ├── reminder_provider.dart
    └── theme_provider.dart
```

---

## 8. Folder Structure (Backend)

```
backend/
├── server.js (Express app entry point)
├── config/
│   ├── database.js (SQLite connection)
│   └── firebase.js (FCM config, optional)
├── middleware/
│   ├── auth.js (JWT verification)
│   ├── upload.js (Multer config)
│   └── error-handler.js
├── routes/
│   ├── auth.js
│   ├── pets.js
│   ├── reminders.js
│   ├── weights.js
│   ├── photos.js
│   ├── albums.js
│   ├── notifications.js
│   ├── expenses.js
│   ├── budget.js
│   ├── settings.js
│   ├── backup.js
│   └── ... (post-MVP routes)
├── controllers/
│   ├── authController.js
│   ├── petController.js
│   ├── reminderController.js
│   ├── weightController.js
│   ├── photoController.js
│   ├── notificationController.js
│   └── ... (post-MVP controllers)
├── services/
│   ├── imageService.js (compression, thumbnails)
│   ├── backupService.js (encryption, export/import)
│   ├── notificationService.js (FCM, scheduling)
│   └── emailService.js (for future invitations)
├── jobs/
│   └── notification-cron.js (background job for reminders)
├── utils/
│   ├── helpers.js
│   ├── validators.js
│   └── crypto.js (encryption utilities)
├── uploads/ (file storage)
│   ├── pets/
│   │   └── {petId}/
│   │       ├── profile.jpg
│   │       └── photos/
│   │           └── {photoId}.jpg
│   ├── documents/
│   │   └── {petId}/
│   └── backups/
│       └── {userId}/
├── database/
│   ├── petcare.db (SQLite database file)
│   └── migrations/
│       ├── 001_initial_schema.sql
│       ├── 002_add_weights.sql
│       └── ...
├── tests/ (optional)
│   ├── auth.test.js
│   ├── pets.test.js
│   └── ...
├── package.json
└── .env (environment variables)
```

---

## 9. Key Decisions & Trade-offs

### Frontend-First Approach
- ✅ **Pro:** Validate UX early; iterate on design without backend dependency
- ✅ **Pro:** Parallel development (frontend mocks while backend builds)
- ⚠️ **Con:** Mock data might not match real API; refactor when integrating
- **Mitigation:** Define API contract upfront (already in 01-API_CONTRACT.md)

### Local-First Architecture
- ✅ **Pro:** Offline-first; no server downtime affects users
- ✅ **Pro:** Fast performance (no network latency)
- ⚠️ **Con:** Multi-device sync harder to implement later
- ⚠️ **Con:** Backup/restore is manual (user friction)
- **Mitigation:** Plan for optional cloud sync in Phase 3+

### Flutter for Frontend
- ✅ **Pro:** Single codebase for iOS + Android
- ✅ **Pro:** Fast development with hot reload
- ⚠️ **Con:** Larger app size than native
- ⚠️ **Con:** Some platform-specific features harder to implement
- **Mitigation:** Use platform channels for native features if needed

### SQLite for Database
- ✅ **Pro:** Zero-config; embedded; fast for local data
- ✅ **Pro:** Supports complex queries; ACID transactions
- ⚠️ **Con:** Not ideal for multi-user concurrent writes
- ⚠️ **Con:** File-based (harder to scale to cloud later)
- **Mitigation:** Use PostgreSQL for cloud backend in Phase 3+

### Manual Backup/Restore
- ✅ **Pro:** User control; no cloud dependency; privacy-friendly
- ✅ **Pro:** Simpler implementation than auto-sync
- ⚠️ **Con:** Users forget to backup; data loss if device lost
- ⚠️ **Con:** Manual process is friction (users won't do it regularly)
- **Mitigation:** Remind users to backup monthly; auto-backup to device storage

---

## 10. Success Metrics

### MVP Launch Goals (Week 6)

**Technical Metrics:**
- ✅ All MVP features functional (10/10 features working)
- ✅ No critical bugs (P0/P1 bugs = 0)
- ✅ App loads in <2 seconds on mid-range device
- ✅ Backup/restore tested with 100+ records (success rate >95%)
- ✅ Notifications fire within 1 minute of scheduled time

**User Metrics (post-launch):**
- 📈 10+ pets created in first week
- 📈 50+ reminders set
- 📈 20+ weight entries logged
- 📈 5+ backups exported
- 📈 User retention: >40% return after 1 week

### Post-MVP Goals (Week 14)

**Feature Adoption:**
- 📸 50% of users upload at least 1 photo to gallery
- 💉 30% of users log at least 1 vaccination
- 📄 20% of users upload at least 1 document

**Engagement:**
- 📊 Average 3 feature modules used per user
- 🔔 Notification open rate >60%
- 💾 Backup used by >50% of users at least once

---

## 11. Risk Mitigation Plan

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| **Scope creep** | High | High | Strict MVP scope; defer features to Phase 2 |
| **Backend delays** | Medium | Medium | Frontend mocks allow parallel development |
| **Notification failures** | Medium | High | Extensive testing; fallback to local notifications |
| **File upload bugs** | Medium | Medium | Validate file types; compress images; limit sizes |
| **Data loss** | Low | Very High | Automatic backups; soft deletes; undo functionality |
| **Performance issues** | Low | Medium | Pagination; lazy loading; image compression |
| **User forgets password** | High | High | Email recovery OR prominent warning about data loss |

---

## 12. Go-Live Checklist

### Pre-Launch (Week 6)

- [ ] All MVP features tested end-to-end
- [ ] Dark mode fully implemented and tested
- [ ] Performance optimized (load time <2s)
- [ ] Backup/restore tested with real data
- [ ] Critical bugs fixed (P0/P1 = 0)
- [ ] Error handling and empty states complete
- [ ] Accessibility tested (screen reader, font sizes)
- [ ] Privacy policy and terms of service written
- [ ] App store listing prepared (description, screenshots, icon)
- [ ] Release APK built and signed
- [ ] Beta testing with 5-10 users completed
- [ ] Feedback from beta incorporated
- [ ] Crash reporting configured (Firebase Crashlytics or Sentry)
- [ ] Analytics configured (optional)

### Launch Day

- [ ] Submit to Google Play Store (Android)
- [ ] Submit to Apple App Store (iOS)
- [ ] Monitor crash reports closely
- [ ] Respond to user reviews within 24 hours
- [ ] Track key metrics (downloads, retention, crashes)

### Post-Launch (Week 7-8)

- [ ] Fix any critical bugs reported by users (hotfix release)
- [ ] Gather user feedback (in-app survey or email)
- [ ] Prioritize post-MVP features based on feedback
- [ ] Begin development of Phase 2 features

---

## 13. Summary

### Timeline Overview

| Phase | Duration | Deliverable |
|-------|----------|-------------|
| **Phase 0: Setup** | 2 days | Project structure + components |
| **Phase 1: Core** | 10 days | Pet profiles + weight + reminders + notifications |
| **Phase 2: Finance** | 6 days | Expenses + budget |
| **Phase 3: Settings** | 6 days | Settings + backup/restore |
| **Phase 4: Polish** | 6 days | UI polish + testing + deployment prep |
| **Total MVP** | **30 days** | **Functional MVP ready for launch** |
| **Phase 5: Post-MVP** | 38 days | Gallery + vaccinations + services + documents + logs + meds |
| **Grand Total** | **68 days** | **Full-featured app (reference parity)** |

### Recommended Team

**MVP (Weeks 1-6):**
- 1 Frontend Developer (Flutter)
- 1 Backend Developer (Node.js + SQLite)
- 1 Designer (part-time, for assets and polish)

**Post-MVP (Weeks 7-14):**
- Same team; can add 1 more developer to speed up

### Final Recommendation

**SHIP THE MVP FIRST.** Get user feedback. Validate demand. Then invest in post-MVP features.

The reference app is impressive but took years to build. Start small, launch fast, iterate based on real user needs.

---

**End of Phase 6 — Implementation Roadmap**

**All 6 Phases Complete:**
1. ✅ UI Analysis (PHASE1_UI_ANALYSIS.md)
2. ✅ App Specification (APP_SPEC.md)
3. ✅ Gap Analysis (PHASE3_GAP_ANALYSIS.md)
4. ✅ Color Analysis (PHASE4_COLOR_ANALYSIS.md)
5. ✅ Backend Mapping (PHASE5_BACKEND_MAPPING.md)
6. ✅ Implementation Roadmap (PHASE6_IMPLEMENTATION_ROADMAP.md)

**Ready to start building!** 🚀
