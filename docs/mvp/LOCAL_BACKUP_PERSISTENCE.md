LOCAL BACKUP & PERSISTENCE — PetCare

**SQLite Schema (add these tables):**
```sql
CREATE TABLE budgets (id TEXT PRIMARY KEY, userId TEXT, petId TEXT, totalBudget REAL, period TEXT, alertAt75 BOOLEAN, alertAt100 BOOLEAN, createdAt TEXT, updatedAt TEXT);
CREATE TABLE expenses (id TEXT PRIMARY KEY, userId TEXT, petId TEXT, category TEXT, amount REAL, date TEXT, notes TEXT, createdAt TEXT);
CREATE TABLE settings (userId TEXT PRIMARY KEY, theme TEXT DEFAULT 'warm', wallpaper TEXT, debugMode BOOLEAN DEFAULT 0);
```

**Backend API (add to existing routes):**
- GET /backup/export?format=zip&includeImages=true → returns encrypted .pcbackup file
- POST /backup/preview (file+password) → returns manifest preview
- POST /backup/import (file+password) → overwrites user data
- GET /budget/:petId → budget info + expenses
- POST /budget/expense → add expense
- GET /settings → user settings (theme, wallpaper)
- PUT /settings → update settings

**Encryption:** AES-256-GCM with PBKDF2 (user account password, 100k iterations)

**Frontend Pages to Add:**
1. Backup & Restore page (/backup) - export/import UI
2. Budget page (/budget) - spending table + line chart
3. Wallpaper settings (in Account page) - upload + preview

**Payment Button:** Shows "Coming Soon - Cloud Pro Features" modal

**Implementation:**
1. Add SQLite tables to backend
2. Create backend/backup.js (export/import/encrypt)
3. Add budget endpoints
4. Build frontend backup UI
5. Build budget page with chart
6. Add wallpaper upload
7. Test backup → import flow

Timeline: 7-10 days
