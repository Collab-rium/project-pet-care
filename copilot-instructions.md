# Copilot Instructions

This project is a Flutter Pet Care application with multi-theme support, dark mode, and comprehensive logging for error tracking and debugging.

## Project Summary

**Pet Care App** - Flutter-based pet management system
- **Frontend**: Flutter (Dart)
- **Build Targets**: Linux ✅, macOS, Windows, Android (Gradle issue), iOS
- **Theme System**: 3 themes (Cool Blue, Warm, Nature) × 2 brightness modes (Light, Dark)
- **Logging**: Dual-tier system (in-memory + file-based persistent)

## Logging System (Critical)

### Unified Two-Tier Architecture
All logging automatically writes to both tiers simultaneously:

**Tier 1: In-Memory** (LoggerService)
```dart
import 'core/services/logger_service.dart';
LoggerService.debug('msg');
LoggerService.info('msg');
LoggerService.warning('msg');
LoggerService.error('msg');
LoggerService.critical('msg');
```
- Accessed via: Floating button → "Logs" tab
- Storage: Last 1000 entries in RAM
- Lifespan: Clears on app close

**Tier 2: File-Based** (FileLoggerService)
```dart
import 'core/services/file_logger_service.dart';
await FileLoggerService.log('message');
await FileLoggerService.logError('failed', exception: e, stackTrace: st);
```
- Accessed via: Floating button → "Files" tab OR terminal
- Location: `~/Documents/pet_care_logs/current.log`
- Lifespan: Persists indefinitely
- Format: `[HH:MM:SS.mmm] [LEVEL] [ClassName] Message`

### Using Logs in Development
When debugging:
1. Use FileLoggerService for issues needing persistence
2. Use LoggerService for real-time console debugging
3. Access file logs: `tail -f ~/Documents/pet_care_logs/current.log`
4. Share logs by copying from "Files" tab in GUI

## Code Standards

### Color System (Theme-Aware)
✅ **DO**: `Theme.of(context).colorScheme.primary` (adapts to light/dark mode)
❌ **DON'T**: `AppColors.primary` (hardcoded orange, ignores theme)

Current status:
- ✅ AppButton: Uses Theme.of(context) - FIXED
- ❌ Other components: Still use hardcoded AppColors (484+ refs)

### Imports
- ✅ Correct: `import 'theme/colors.dart';`
- ❌ Wrong: `import 'AppColors.dart';` (wrong case)
- Always use lowercase with underscores

### Logging in New Code
Add logging for:
- Screen/widget initialization
- Data fetch operations
- Error conditions with stack traces
- User interactions (optional for high-frequency events)

Example:
```dart
await FileLoggerService.log('BudgetScreen: Loaded with ${pets.length} pets');
try {
  var data = await fetchBudget();
  await FileLoggerService.log('Budget fetched successfully');
} catch (e, st) {
  await FileLoggerService.logError('Budget fetch failed', exception: e, stackTrace: st);
}
```

## Known Issues & Status

### ✅ FIXED This Session
- [x] Build compilation errors (50+ fixes)
- [x] Button theming system (AppButton)
- [x] Logging module (in-memory + file-based)
- [x] Error sharing mechanism

### ⏳ PARTIAL (Phase 2 Not Complete)
- [ ] Dark mode colors (AppButton done; 483+ components remain)
- [ ] Theme color bleeding (system works; 484+ refs need updating)

### ❌ NOT YET FIXED (Deferred)
1. **Searchbars** - Remain light in dark mode
2. **Page backgrounds** - Don't adapt to dark mode
3. **Budget/Account screens** - Show light styling with gray text
4. **UI overlaps** - Elements overlap; no standardized spacing
5. **Android build** - Gradle error (non-critical)
6. **Color migration** - 484+ hardcoded AppColors → Theme system

**Root Cause**: Most widgets use hardcoded `AppColors.primary` (orange) instead of reading `Theme.of(context).colorScheme`, bypassing theme system completely.

## Build & Test

### Linux (Primary Target)
```bash
cd frontend
flutter clean && flutter pub get
flutter run -d linux          # Debug
flutter build linux --release # Release
```

### Verify Logging Works
```bash
# Terminal 1: Run app
cd frontend && flutter run -d linux

# Terminal 2: Monitor logs
tail -f ~/Documents/pet_care_logs/current.log

# In app: Tap floating button → check "Logs" and "Files" tabs
```

## File Structure (Key Files)

```
frontend/lib/
├── main.dart                              # Logger initialized here
├── core/services/
│   ├── logger_service.dart                # In-memory logging
│   ├── file_logger_service.dart           # File-based persistent logging
│   └── ...
├── core/theme/
│   ├── colors.dart                        # Color definitions
│   ├── theme_factory.dart                 # Theme creation
│   └── ...
├── components/atoms/
│   ├── app_button.dart                    # ✅ Theme-aware button (pattern to follow)
│   └── ...
├── components/organisms/
│   ├── error_logger_widget.dart           # ✅ GUI log viewers
│   └── ...
└── screens/
    ├── budget_screen.dart                 # ⏳ Needs dark mode fixes
    ├── pet_search_screen.dart             # ⏳ Needs dark mode fixes
    └── ...
```

## Documentation Files

- `PROJECT_CONTEXT.md` - Full project context with logging details
- `FILE_LOGGING_GUIDE.md` - User guide for file logging
- `LOGGER_GUIDE.md` - In-memory logger guide
- `GITHUB_COPILOT_INSTRUCTIONS.md` - Detailed development guide
- `CURRENT_STATUS.md` - Status and roadmap

## Commit Guidelines

Format:
```
[Type] Brief description

Detailed explanation if needed.

Co-authored-by: Copilot <223556219+Copilot@users.noreply.github.com>
```

Types: `feat:` `fix:` `refactor:` `docs:` `test:` `chore:`

## When to Ask User

Ask for clarification on:
- Scope decisions ("Should I fix only SearchBar or all text fields?")
- Design choices ("Use ColorTokens or Theme.of(context)?")
- Priority conflicts ("Dark mode or Android build first?")
- Testing requirements ("Test all 6 theme combinations?")

## Next Phase (Phase 2 - Dark Mode)

Priority order:
1. SearchBar components (high impact, medium effort)
2. Page backgrounds (critical impact, high effort)
3. TextFields (medium-high impact, medium effort)
4. Remaining buttons (medium impact, high effort)
5. UI overlaps (medium impact, high effort)

Reference implementation: `app_button.dart` - shows how to use `Theme.of(context).colorScheme`

## Quick Reference

- **Logs location**: `~/Documents/pet_care_logs/`
- **Check logs**: `tail -f ~/Documents/pet_care_logs/current.log`
- **Build app**: `cd frontend && flutter run -d linux`
- **View in-app logs**: Tap floating button (bottom-right)
- **Git status**: `git log --oneline -8`
- **Unfixed issues**: 484+ AppColors refs need Theme.of(context) migration
