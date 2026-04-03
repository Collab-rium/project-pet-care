# GitHub Copilot Instructions

This file contains instructions and context for GitHub Copilot to assist with this Pet Care Flutter application.

## Project Overview

**Pet Care App** - A Flutter-based pet management application with multi-theme support, dark mode, and file-based logging for error tracking and debugging.

**Technology Stack:**
- **Frontend**: Flutter (Dart)
- **Backend**: Firebase (previously; now local-based)
- **Build Targets**: Linux, macOS, Windows, Android, iOS
- **Current Build Status**: ✅ Linux successful | ❌ Android Gradle error (non-critical)

---

## Logging Architecture (Critical for Debugging)

### Two-Tier Unified Logging System

The app uses automatic dual-tier logging that MUST be used for all debugging:

#### **Tier 1: In-Memory Logging** - LoggerService
```dart
import 'core/services/logger_service.dart';

LoggerService.debug('msg');     // Debug level
LoggerService.info('msg');      // Info level
LoggerService.warning('msg');   // Warning level
LoggerService.error('msg');     // Error level
LoggerService.critical('msg');  // Critical level
```
- **Accessed Via**: Floating debug button → "Logs" tab
- **Storage**: Last 1000 entries in RAM
- **Lifespan**: Clears on app close
- **Output**: Automatically sent to console + RAM

#### **Tier 2: File-Based Persistent Logging** - FileLoggerService
```dart
import 'core/services/file_logger_service.dart';

await FileLoggerService.log('message');
await FileLoggerService.logError('failed', exception: e, stackTrace: st);
```
- **Accessed Via**: Floating debug button → "Files" tab OR terminal
- **Storage Location**:
  - Linux: `~/Documents/pet_care_logs/`
  - macOS: `~/Library/Application Support/project_pet_care_frontend/documents/pet_care_logs/`
  - Windows: `AppData/Local/project_pet_care_frontend/documents/pet_care_logs/`
- **File**: `current.log` (plain text, auto-rotates at 5MB)
- **Lifespan**: Persists until manually deleted
- **Format**: `[HH:MM:SS.mmm] [LEVEL] [ClassName] Message`

### Using Logs in Copilot Tasks

**When debugging**:
1. Always add logging to suspect code sections
2. Use FileLoggerService for issues that need persistence
3. Use LoggerService for real-time console debugging
4. Access logs via: Terminal → `tail -f ~/Documents/pet_care_logs/current.log`
5. Share logs by copying file path from "Files" tab to user

**Example debugging pattern**:
```dart
// In any screen/service
await FileLoggerService.log('Screen loaded: $widgetName');
try {
  var result = await fetchData();
  await FileLoggerService.log('Data fetched: ${result.length} items');
} catch (e, st) {
  await FileLoggerService.logError('Fetch failed', exception: e, stackTrace: st);
}
```

---

## Code Standards & Conventions

### Import Statements
- **Correct**: `import 'core/services/logger_service.dart';`
- **Incorrect**: `import 'AppColors.dart';` (wrong case, old naming)
- **Correct**: `import 'theme/colors.dart';`
- Always use lowercase filenames with underscores

### Color System (Theme-Aware)
- ✅ **DO USE**: `Theme.of(context).colorScheme`
- ❌ **DON'T USE**: Hardcoded `AppColors.primary`
- **Example**:
  ```dart
  // Good - adapts to dark/light mode
  color: Theme.of(context).colorScheme.primary
  
  // Bad - ignores theme/brightness
  color: AppColors.primary  // always orange
  ```

### Button Component
- **File**: `frontend/lib/components/atoms/app_button.dart`
- **Status**: Already updated to use `Theme.of(context).colorScheme`
- **When creating buttons**: Reference AppButton pattern, not direct color assignments

### Logging in New Code
- Always add logging for:
  - Screen/widget initialization
  - Data fetch operations
  - Error conditions
  - User interactions (optional for high-frequency events)
- Use appropriate log levels (debug, info, warning, error, critical)

---

## Known Issues & Status

### ✅ FIXED
- Build compilation errors (50+ fixes)
- Button theming system
- Logging module (in-memory + file-based)
- Error sharing mechanism
- On-screen debug widget

### ⏳ PARTIAL (Phase 2 - Not Yet Complete)
- **Dark mode**: Only AppButton fixed; 483+ other components need updating
- **Theme color bleeding**: Orange appears in Cool Blue theme (484+ refs need migration)
- **Description**: Many screens still use hardcoded `AppColors` instead of `Theme.of(context)`

### ❌ NOT YET FIXED (Deferred)
1. **Searchbars** - Remain light in dark mode
2. **Page backgrounds** - Don't adapt to dark mode
3. **Budget/Account/Expense screens** - Show light styling with gray text in dark mode
4. **UI overlap** - Elements overlap; needs standardized spacing
5. **Android build** - Gradle error in permission_handler_android (non-critical)
6. **Color migration** - 484+ hardcoded AppColors → Theme system

**Note**: Do NOT attempt to fix all AppColors at once. Priority screens: SearchBar, PetPage, BudgetPage, AccountPage.

### Root Cause (For Reference)
```dart
// PROBLEM: This ignores theme completely
class AppColors {
  static const Color primary = Color(0xFFFF8C42);  // Always orange
  static const Color background = Color(0xFFFAFAFA);  // Always light
}

// SOLUTION: Use theme system
Theme.of(context).colorScheme.primary  // Adapts to light/dark + theme
```

---

## Build & Test Commands

### Linux (Current Primary Target)
```bash
cd frontend
flutter clean
flutter pub get
flutter run -d linux          # Debug mode
flutter build linux --release # Release build
```

### Test Build
```bash
cd frontend && flutter run -d linux
# App loads → Tap floating button (bottom-right)
# Verify "Logs" tab shows messages
# Verify "Files" tab shows log files at ~/.local/share/...
```

### Logging Test
```bash
# While app is running, check logs in real-time
tail -f ~/Documents/pet_care_logs/current.log
```

### Android (Known Issue)
```bash
# Currently has Gradle error - non-critical for Linux development
flutter run -d android  # May fail until plugin compatibility fixed
```

---

## File Structure (Key Files Only)

```
frontend/
├── lib/
│   ├── main.dart                           # App entry point (logger initialized here)
│   ├── core/
│   │   ├── services/
│   │   │   ├── logger_service.dart         # ✅ In-memory logging
│   │   │   ├── file_logger_service.dart    # ✅ File-based persistent logging
│   │   │   └── ...
│   │   ├── theme/
│   │   │   ├── colors.dart                 # ✅ Color definitions (theme-aware)
│   │   │   ├── theme_factory.dart          # ✅ Theme creation
│   │   │   └── ...
│   │   └── ...
│   ├── components/
│   │   ├── atoms/
│   │   │   ├── app_button.dart             # ✅ Theme-aware button
│   │   │   └── ...
│   │   ├── organisms/
│   │   │   ├── error_logger_widget.dart    # ✅ GUI log viewers (in-memory + files)
│   │   │   └── ...
│   │   └── ...
│   ├── screens/
│   │   ├── budget_screen.dart              # ⏳ Needs dark mode fixes
│   │   ├── pet_search_screen.dart          # ⏳ Needs dark mode fixes
│   │   ├── account_screen.dart             # ⏳ Needs dark mode fixes
│   │   └── ...
│   └── ...
├── pubspec.yaml
└── ...

PROJECT_ROOT/
├── PROJECT_CONTEXT.md                  # ✅ Updated with logging info
├── FILE_LOGGING_GUIDE.md               # ✅ User guide for file logging
├── LOGGER_GUIDE.md                     # ✅ In-memory logger guide
├── CURRENT_STATUS.md                   # ✅ Status & roadmap
├── GITHUB_COPILOT_INSTRUCTIONS.md      # This file
└── ...
```

---

## Commit Guidelines

### Commit Format
```
[Type] Brief description

Detailed explanation if needed.

Fixes: #issue-number (if applicable)
Related: Feature or module name

Co-authored-by: Copilot <223556219+Copilot@users.noreply.github.com>
```

### Commit Types
- `feat:` - New feature
- `fix:` - Bug fix
- `refactor:` - Code restructuring (no logic change)
- `docs:` - Documentation only
- `test:` - Tests only
- `chore:` - Build, CI/CD, dependencies

### Example
```
fix: Update dark mode colors in BudgetScreen

- Changed searchbar background to use Theme.of(context)
- Fixed text color for visibility in dark mode
- Added logging for debugging color application

Fixes: #42
Related: Dark mode migration

Co-authored-by: Copilot <223556219+Copilot@users.noreply.github.com>
```

### Branches
- `main` - Production-ready code
- `develop` - Integration branch (if used)
- Feature branches: `feature/name`, `fix/name`, `docs/name`

---

## When to Ask the User

Ask for clarification when:
1. **Scope ambiguity**: "Should I fix only SearchBar or all text input fields?"
2. **Design decision**: "Use ColorTokens system vs Theme.of(context)?"
3. **Priority conflicts**: "Fix dark mode or Android build first?"
4. **Testing requirements**: "Should I test all 6 theme combinations?"
5. **Data/assumptions**: "Can I assume current dark mode preference?"

**Example**: "I can fix the BudgetScreen dark mode. Should I also fix ExpenseScreen while I'm in that area?"

---

## Logging for This Project Specifically

### When Starting Any Task
1. Initialize logging at task start: `await FileLoggerService.log('Task: <name> started');`
2. Log major milestones
3. Log all errors with stack traces
4. Log completion: `await FileLoggerService.log('Task: <name> completed');`

### Example Task Flow
```dart
// In task implementation
await FileLoggerService.log('TASK: Fixing BudgetScreen dark mode - started');

try {
  // Make changes
  await FileLoggerService.log('Updated searchbar to use Theme.of(context)');
  
  // Test
  await FileLoggerService.log('Testing dark mode - no visual issues observed');
  
} catch (e, st) {
  await FileLoggerService.logError('Task failed', exception: e, stackTrace: st);
}

await FileLoggerService.log('TASK: Fixing BudgetScreen dark mode - completed');
```

User can then check logs to see exactly what happened:
```bash
grep "TASK:" ~/Documents/pet_care_logs/current.log
```

---

## Session & Commit Summary

**Sessions so far**: Multiple (see git log)
**Total commits this project**: 97
**Commits this session**: 7
- `6904960` - Fix button theming and app build issues
- `7256982` - Add logging module and error reporting widget  
- `2413c03` - Add comprehensive documentation for logging and current status
- `b5c9f0e` - Add action checklist and next steps guide
- `8b86a9b` - Add file-based logging for persistent error tracking
- `7858061` - Add file-based logging user guide
- `a73c9cf` - Add final session summary for file-based logging

---

## For Next Session / Future Developers

1. **Logging is ready to use** - Start any debugging task by checking `current.log`
2. **Dark mode migration** is the priority (Phase 2)
3. **Don't try to fix all 484 AppColors** - Focus on user-facing screens first
4. **Always use Theme.of(context)** for new color assignments
5. **Test with `flutter run -d linux`** - Android has known issue, not blocking

---

Last updated: 2026-04-03
Next action: Phase 2 - Dark Mode Migration
