# Logging Requirements - THE LOGGING LAW

## Mandatory Rule: Every Screen MUST Have Logging

This document establishes the **Logging Law** for the Pet Care Flutter application. Every screen, widget, service, and major operation must include comprehensive logging.

---

## 1. The Law

### Principle
> **Every screen and service that loads data or performs an operation MUST log that operation.**

### Enforcement
- ✅ **REQUIRED**: All screens must have logging
- ✅ **REQUIRED**: All services must have logging
- ✅ **REQUIRED**: All data loading must be logged
- ✅ **REQUIRED**: All errors must be logged with stack traces
- ✅ **REQUIRED**: All major operations must be logged

### Violation Consequences
Any commit that adds a new screen WITHOUT logging will be **rejected**. Code review will check:
1. Does screen have logging imports?
2. Does initState() log screen open?
3. Does _loadData() have try-catch with logging?
4. Are errors logged with stack traces?

---

## 2. Mandatory Logging Pattern for Screens

### 2.1 Import Logging Services

```dart
import 'package:flutter/material.dart';
import '../core/services/logger_service.dart';         // REQUIRED
import '../core/services/file_logger_service.dart';    // REQUIRED
```

### 2.2 Initialize Logging in initState()

```dart
@override
void initState() {
  super.initState();
  LoggerService.info('ScreenName: Screen opened');
  _loadData();
}

// REQUIRED: _loadData() method
Future<void> _loadData() async {
  try {
    LoggerService.info('ScreenName: Loading data...');
    await FileLoggerService.log('ScreenName: Screen initialized');
    
    // Your data loading code here
    final data = await fetchData();
    
    LoggerService.info('ScreenName: Data loaded successfully (${data.length} items)');
    await FileLoggerService.log('ScreenName: Loaded ${data.length} items');
    
  } catch (e, st) {
    LoggerService.error('ScreenName: Failed to load data - $e', exception: e);
    await FileLoggerService.logError('ScreenName load failed', 
      exception: e, 
      stackTrace: st
    );
  }
}
```

### 2.3 Log User Actions

```dart
void _onAddButton() {
  try {
    LoggerService.info('ScreenName: User tapped add button');
    // Action code
    LoggerService.info('ScreenName: Item created successfully');
  } catch (e, st) {
    LoggerService.error('ScreenName: Add action failed - $e');
    await FileLoggerService.logError('Add action failed', exception: e, stackTrace: st);
  }
}
```

### 2.4 Log Navigation

```dart
void _navigateTo(String screen) {
  LoggerService.info('ScreenName: Navigating to $screen');
  Navigator.pushNamed(context, screen);
}
```

---

## 3. Mandatory Logging Pattern for Services

### 3.1 Log Initialization

```dart
class MyService {
  Future<void> initialize() async {
    try {
      LoggerService.info('MyService: Initializing...');
      // initialization code
      LoggerService.info('MyService: Initialized successfully');
    } catch (e, st) {
      LoggerService.error('MyService: Initialization failed - $e');
      FileLoggerService.logError('MyService init failed', exception: e, stackTrace: st);
    }
  }
}
```

### 3.2 Log API Calls

```dart
Future<List<Pet>> getPets() async {
  try {
    LoggerService.debug('PetService: Fetching pets from API...');
    final response = await _api.get('/pets');
    final pets = PetModel.fromJsonList(response);
    
    LoggerService.info('PetService: Fetched ${pets.length} pets');
    return pets;
    
  } catch (e, st) {
    LoggerService.error('PetService: Failed to fetch pets - $e');
    FileLoggerService.logError('Fetch pets failed', exception: e, stackTrace: st);
    rethrow;
  }
}
```

---

## 4. Log Levels (Use Correctly)

| Level | Use Case | Example |
|-------|----------|---------|
| **DEBUG** | Detailed diagnostic info | `'Parsing JSON response...'` |
| **INFO** | General informational | `'Screen loaded with 5 pets'` |
| **WARNING** | Warning conditions | `'Network slow, retry in 5s'` |
| **ERROR** | Error conditions | `'Failed to save data'` |
| **CRITICAL** | Critical failures | `'Authentication failed'` |

### Example:
```dart
LoggerService.debug('PetListScreen: Rendering ${pets.length} items');  // DEBUG
LoggerService.info('PetListScreen: Screen opened');                    // INFO
LoggerService.warning('PetListScreen: Network timeout, retrying...');  // WARNING
LoggerService.error('PetListScreen: Failed to load - $e');             // ERROR
LoggerService.critical('PetListScreen: Database connection lost');     // CRITICAL
```

---

## 5. Log Format & Output

### Console Output
```
[14:25:30.123] [INFO] [ScreenName] Message details
[14:25:31.456] [ERROR] [ServiceName] Error occurred
```

### File Output
```
~/Documents/pet_care_logs/current.log
[2026-04-03 14:25:30.123456] INFO: ScreenName: Message details
[2026-04-03 14:25:31.456789] ERROR: ServiceName: Error occurred
```

---

## 6. Checklist for New Screens

Before committing a new screen:

- [ ] **Imports**: Added logging imports at top?
- [ ] **initState()**: Logs when screen opens?
- [ ] **_loadData()**: Has try-catch with logging?
- [ ] **Error Handling**: All errors logged with stack traces?
- [ ] **User Actions**: Major actions logged?
- [ ] **Navigation**: Navigation logged?
- [ ] **Test**: Run app and check ~/Documents/pet_care_logs/current.log for entries?

---

## 7. Current Status (This Session)

### ✅ Logging Added to All 28 Screens

| # | Screen | Status |
|---|--------|--------|
| 1 | account_screen.dart | ✅ |
| 2 | add_expense_screen.dart | ✅ |
| 3 | add_pet_screen.dart | ✅ |
| 4 | add_reminder_screen.dart | ✅ |
| 5 | backup_restore_screen.dart | ✅ |
| 6 | budget_screen.dart | ✅ |
| 7 | dashboard_screen.dart | ✅ |
| 8 | enhanced_settings_screen.dart | ✅ |
| 9 | expense_form_screen.dart | ✅ |
| 10 | expense_list_screen.dart | ✅ |
| 11 | home_screen.dart | ✅ |
| 12 | login_screen.dart | ✅ |
| 13 | notification_settings_screen.dart | ✅ |
| 14 | onboarding_screen.dart | ✅ |
| 15 | payment_subscription_screen.dart | ✅ |
| 16 | pet_detail_screen.dart | ✅ |
| 17 | pet_list_screen.dart | ✅ |
| 18 | pet_profile_screen.dart | ✅ |
| 19 | photo_gallery_screen.dart | ✅ |
| 20 | register_screen.dart | ✅ |
| 21 | reminder_form_screen.dart | ✅ |
| 22 | reminders_list_screen.dart | ✅ |
| 23 | reminders_screen.dart | ✅ |
| 24 | tasks_screen.dart | ✅ |
| 25 | theme_selector_screen.dart | ✅ |
| 26 | wallpaper_customization_screen.dart | ✅ (done earlier) |
| 27 | wallpaper_screen.dart | ✅ |
| 28 | weight_tracking_screen.dart | ✅ |

---

## 8. How to Verify Logging Works

```bash
# 1. Run the app
cd frontend && flutter run -d linux

# 2. Open terminal and follow logs
tail -f ~/Documents/pet_care_logs/current.log

# 3. Navigate between screens in app
# You should see log entries like:
# [timestamp] INFO: ScreenName: Screen opened
# [timestamp] INFO: ScreenName: Loading data...
# [timestamp] INFO: ScreenName: Data loaded successfully
```

---

## 9. CI/CD Pipeline Rule

### Pre-Commit Hook (Recommended)

When new code is committed, check:
```bash
# Verify all screens have logging
grep -r "FileLoggerService\|LoggerService" lib/screens/*.dart

# If new screen added without logging, reject commit
if [[ new_screen_added ]] && ! grep -q "FileLoggerService\|LoggerService" new_screen.dart; then
  echo "❌ ERROR: New screen must include logging!"
  exit 1
fi
```

---

## 10. Future Enhancements

- [ ] Automatic stack trace collection on app crash
- [ ] Log rotation and compression
- [ ] Remote log upload to server
- [ ] Log analytics dashboard
- [ ] Performance profiling via logs
- [ ] Automatic log cleanup (older than 30 days)

---

## 11. Questions & Answers

**Q: Do I need to log every method call?**
A: No. Log major operations (screen open, data load, user actions, errors). Don't log tiny helpers.

**Q: Can I use different logging patterns?**
A: No. Follow the mandatory pattern exactly. Consistency is key for debugging.

**Q: What if logging causes performance issues?**
A: FileLoggerService is async by design. It won't block UI. If still slow, log less frequently.

**Q: Can logs contain sensitive data?**
A: NO. Never log passwords, API keys, credit card numbers, or personal data.

---

## Summary

> **Every line of meaningful app behavior should be visible in the logs.**

The logging system exists to:
1. ✅ Debug issues easily
2. ✅ Track user behavior
3. ✅ Identify performance bottlenecks
4. ✅ Understand error patterns
5. ✅ Share debugging info with developers/LLMs

**The Logging Law is mandatory and non-negotiable.**

---

**Established**: 2026-04-03  
**Last Updated**: 2026-04-03  
**Enforced By**: Code Review & Automated Checks
