# 🚀 PET-CARE APP: QUICK DECISION REFERENCE

**For when you need fast answers without reading 50 pages.**

---

## DESIGN: WHICH PALETTE TO USE?

| When | Use This |
|------|----------|
| Default / First impression | **WARM** (#FF8C42 primary) |
| User prefers modern/minimal | **CLEAN** (#4A90E2 primary) |
| Both available via toggle in Account page | ✅ Yes, implement theme toggle |

---

## DASHBOARD CARDS: WHAT HAPPENS WHEN I CLICK?

```
Click Card → Filter task list below to show only that status
Click Again → Clear filter, show all tasks
```

**Implementation:** Single state: `activeFilter = null | 'pending' | 'completed' | 'overdue'`

---

## BUDGET PAGE: WHICH CHART?

| Chart Type | When | Tools |
|-----------|------|-------|
| **Line Chart** | Show spending trends over 12 months | Recharts, Chart.js |
| **Bar Chart** | Compare Jan vs Feb vs Mar (month-to-month) | Same tools |
| **Both** | Comprehensive view (recommended) | Same tools |

**Recommendation:** Line chart (top) + Bar chart (bottom) = best overview

---

## ACCOUNT BUTTON: WHERE SHOULD IT GO?

| Location | Pro | Con |
|----------|-----|-----|
| **Fixed bottom-right** ✅ | Always accessible | Takes up screen space |
| **Navbar/Header** | Consistent with nav | Not on every page |
| **Footer** | Clean, organized | Needs scrolling on mobile |

**Recommendation:** Fixed bottom-right (circle avatar button)

**Appearance:** User's avatar photo in a circle, clickable anywhere

---

## BACKUP: ENCRYPTED OR NOT?

| Choice | For MVP | Why |
|--------|---------|-----|
| **Simple JSON (no encryption)** ✅ | Yes | Fast to implement, human-readable |
| **Encrypted JSON** | Later (Phase 2) | Nice-to-have, adds complexity |
| **SQLite export** | Optional | For power users only |

**Now:** JSON export only  
**Later:** Add encryption toggle: `[ ] Encrypt with my password`

---

## WALLPAPER: UPLOAD OR PRESETS?

| Option | For MVP |
|--------|---------|
| Upload custom pet image | ✅ Yes, priority 1 |
| Preset pet-themed wallpapers | 🟡 Optional, can add later |
| Both | Yes, if time allows |

**Quick win:** Just allow upload first. Presets can be added in Phase 2.

---

## AUTH: USERNAME OR EMAIL?

| Strategy | For MVP | Recommendation |
|----------|---------|-----------------|
| **Username + password** | ✅ Yes | Simple, standard |
| **Email + password** | 🟡 Also OK | More modern feel |
| **Password only** | ❌ No | Too ambiguous |

**Go with:** Username + password (both required)

---

## BACKUP SIZE LIMIT: HOW BIG?

```
Default cap: 100 MB (soft warning)
Hard limit: 200 MB (rejection)

Reality check: Your data will be ~5 MB. This is just protection.
```

---

## PERSISTENCE: WHAT MUST ALWAYS BE SAVED?

| Data | Must Save? | Where | When |
|------|-----------|-------|------|
| Users | ✅ YES | SQLite | On signup/update |
| Pets | ✅ YES | SQLite | On create/update |
| Tasks | ✅ YES | SQLite | On create/update |
| Spending | ✅ YES | SQLite | On create/update |
| Pet images | ✅ YES | `data/images/` + DB | On upload |
| Settings | ✅ YES | SQLite | On change |
| Theme choice | ❌ NO | localStorage | (OK if lost) |
| Thumbnails | ❌ NO | RAM cache | Regenerate on load |

---

## ENCRYPTION: TIE TO PASSWORD OR SEPARATE KEY?

| Approach | For MVP | Pro | Con |
|----------|---------|-----|-----|
| **Use account password** | ✅ Yes | Convenient | If password changes, old backups unreadable |
| **Separate recovery key** | 🟡 Later | Super safe | More complex UX |

**Now:** Password-based encryption (or no encryption)  
**Later:** Add recovery key option if needed

---

## TEST BACKUP AFTER EACH FEATURE COMPLETED?

**YES.** After finishing:
- [ ] Dashboard cards fix
- [ ] Budget page
- [ ] Account page

Do this:
```
1. Create 2-3 sample records for new feature
2. Click "Backup now" → verify in JSON
3. Delete records from DB (simulate corruption)
4. Click "Restore" → verify records return
5. Check new feature shows restored data
```

Takes 5 minutes. Worth it.

---

## WHICH COLOR HAS WHICH MEANING?

### Warm Palette
- 🟠 **#FF8C42** (Primary) → Click me! Buttons, CTAs
- 🔴 **#FD6B6B** (Accent/Alert) → Overdue, urgent, warnings
- 🟢 **#52B788** (Success) → Completed tasks
- ⚪ **#FFF9F5** (Background) → Page bg, calm
- ⚫ **#2C2C2C** (Text) → Body text, headings

### Clean Palette
- 🔵 **#4A90E2** (Primary) → Click me! Buttons, CTAs
- 🔴 **#FF6B6B** (Accent/Alert) → Overdue, urgent, warnings
- 🟢 **#4CAF50** (Success) → Completed tasks
- ⚪ **#F5F7FA** (Background) → Page bg, modern
- 🟣 **#1A1A2E** (Text) → Body text, headings

---

## FONTS TO USE

| Type | Font | Size | Weight |
|------|------|------|--------|
| Heading 1 | Poppins | 32px | 600 |
| Heading 2 | Poppins | 28px | 600 |
| Body text | Inter | 16px | 400 |
| Labels | Inter | 14px | 500 |
| Monospace (amounts) | Courier Prime | 14px | 400 |

---

## FILE STRUCTURE: WHERE DOES WHAT GO?

```
project-pet-care/
├── src/
│   ├── styles/
│   │   ├── variables.css  ← Color palettes + spacing
│   │   ├── global.css     ← Typography + resets
│   │   └── components/    ← Component-specific CSS
│   ├── components/        ← Reusable UI components
│   ├── pages/
│   │   ├── Dashboard.jsx
│   │   ├── Budget/BudgetPage.jsx
│   │   └── Account/AccountPage.jsx
│   └── services/
│       ├── authService.js
│       ├── backupService.js
│       └── apiClient.js
├── backend/
│   ├── models/
│   │   └── User.js
│   ├── routes/
│   │   ├── auth.js
│   │   ├── backup.js
│   │   └── budget.js
│   ├── middleware/
│   │   └── authToken.js
│   └── services/
│       ├── backupService.js
│       └── encryptionService.js (optional)
├── data/
│   ├── images/            ← Pet photos
│   ├── sqlite/
│   │   └── petapp.db      ← Database file
│   └── backups/           ← Backup JSONs
├── docs/mvp/
│   ├── 00-OVERVIEW.md
│   ├── 01-API_CONTRACT.md
│   ├── 02-UI_DESIGN_SYSTEM.md  (NEW)
│   ├── 03-FEATURE_SPECIFICATIONS.md (NEW)
│   ├── 04-PERSISTENCE_STRATEGY.md (NEW)
│   ├── 05-TESTING_CHECKLIST.md (NEW)
│   └── 06-DEPLOYMENT.md (NEW)
└── config/
    └── .env               ← JWT secret (NOT committed!)
```

---

## QUICK WORKFLOW: "I'M DONE WITH FEATURE X, WHAT'S NEXT?"

```
✅ Feature X is complete
   ↓
📋 Update FEATURE_TRACKING.md (mark as complete)
   ↓
🧪 Test backup/restore with new data
   ↓
✨ Polish: fix console.logs, visual tweaks
   ↓
📝 Document any learnings in FEATURE_TRACKING.md
   ↓
➡️  Move to Feature Y
```

---

## "WHAT IF X BREAKS?"

| Symptom | Likely Cause | Fix |
|---------|--------------|-----|
| Styles not applying | CSS variables not loaded | Check `variables.css` is imported in `index.css` |
| Theme doesn't toggle | localStorage not updating | Check theme hook is calling `localStorage.setItem` |
| Backup download fails | JSON is too large | Check size < 100 MB, trim image manifest |
| Restore shows "schema mismatch" | JSON structure wrong | Validate against expected schema |
| JWT keeps expiring | Token TTL too short | Check token expiry time (should be 24h for MVP) |
| Images not loading | Image path broken | Check `data/images/` folder exists, path is relative |

---

## DECISION CHECKLIST (CONFIRM THESE)

Before starting Phase 1, confirm:

- [ ] Dashboard cards: Filter task list on click ✅
- [ ] Budget charts: Both line + bar ✅
- [ ] Account button: Fixed bottom-right circle ✅
- [ ] Wallpaper: Allow upload ✅
- [ ] Backup: Simple JSON (no encryption yet) ✅
- [ ] Auth: Username + password ✅
- [ ] Theme toggle: In Account page ✅
- [ ] Backup testing: After each feature ✅

---

**Last updated:** 2025-03-28  
**Ready to code?** Start Phase 1: Design System setup.  
**Stuck?** Check corresponding section in `PET_APP_MASTER_PROMPT.md`
