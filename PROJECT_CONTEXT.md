# Project Context

This file serves as the foundation for understanding and iterating on the **Project Pet** application. Below is the consolidated project context distilled from existing files and configurations.

## Objective
The **Project Pet** is designed to assist pet owners in managing pet care through a Flutter-based app synced with a Firebase backend. The application aims to provide:

- **Pet Profiles**: To store and visualize pet details.
- **Task/Reminder Management**: Notifications for key dates and daily needs.
- **Dynamic User Interface**: Including themes based on pet specifics.

---

## Structure Overview
### Backend (Firebase):
- **Configuration**:
  - `firebase-config.js`: Contains Firebase API keys and app-specific settings.
  - Services initialized for database, authentication, and storage.

- **Validation**:
  - `validate-firebase.js` checks service connectivity.

### Frontend (Flutter):
- **Entry Point**:
  - `main.dart`: Initializes Material-based UI and routing.
- **Components**:
  - Navbar and themes dynamically invoked to support profiles.

---

## Workflow Notes:
### File Safety:
- Enabled the use of `trash-cli` and aliases (`rm = trash`). This ensures safe file operations by preventing permanent deletion via `rm`. Aliases available:
  - `tl` → List contents.
  - `tr` → Restore files.
  - `te` → Empty the trash.

### Git Commit Policy (Generated Files)

- Do not commit generated, machine-local, or cache artifacts.
- Files covered by `.gitignore` must stay untracked (build output, caches, logs, temporary files, local IDE state, emulator runtime files).
- Commit only source files, configuration templates, and documentation needed to reproduce builds.
- Keep lockfiles that are part of dependency reproducibility (`pubspec.lock` is tracked for app builds in this project unless team policy changes explicitly).
- If a new tool generates noisy files, add patterns to the root `.gitignore` before committing.
- Before pushing, run `git status --ignored --short` and confirm no accidental generated artifacts are staged.

---

## Logging & Error Tracking System

### Unified Project Logging Architecture

The project uses a **two-tier unified logging system** that automatically captures all events, errors, and debug information:

#### **Tier 1: In-Memory Logging** (LoggerService)
- **Location**: `frontend/lib/core/services/logger_service.dart`
- **Storage**: Last 1000 log entries stored in RAM
- **Output**: Automatically printed to console in real-time
- **Access**: Via clipboard export or on-screen `ErrorLoggerWidget`
- **Log Levels**: DEBUG, INFO, WARNING, ERROR, CRITICAL
- **Timestamp**: Every entry timestamped (HH:MM:SS.mmm)
- **Lifespan**: Cleared when app closes

#### **Tier 2: File-Based Persistent Logging** (FileLoggerService)
- **Location**: `frontend/lib/core/services/file_logger_service.dart`
- **Storage Path**: 
  - Linux: `~/Documents/pet_care_logs/`
  - macOS: `~/Library/Application Support/project_pet_care_frontend/documents/pet_care_logs/`
  - Windows: `AppData/Local/project_pet_care_frontend/documents/pet_care_logs/`
- **File Structure**:
  - `current.log` - Active log file (primary)
  - `current.log.1`, `current.log.2`, etc. - Archived files (auto-rotated when > 5MB)
  - `current.log.DATE.TIMESTAMP.zip` - Compressed archives of old logs
- **Auto-Rotation**: Triggered when file exceeds 5MB
- **Lifespan**: Persists indefinitely until manually deleted
- **Initialization**: Automatic on app startup in `main.dart`

#### **Unified Event Flow**
```
App Event
    ↓
LoggerService.log("message")    → Console output + RAM storage
    ↓
FileLoggerService.log("message") → File write + Persistent storage
    ↓
Both Tiers Update Simultaneously
```

### Where Logs Are Shown/Accessed

#### **Option 1: GUI - In-App Log Viewer**
- **Widget**: `ErrorLoggerWidget` with tabs: "Logs" & "Files"
- **Access**: Tap floating debug button (bottom-right when app running)
- **In-Memory Logs Tab**:
  - Shows last 1000 entries
  - Filter by log level (DEBUG, INFO, WARNING, ERROR, CRITICAL)
  - Search functionality
  - Copy to clipboard
  - Real-time updates
- **Files Tab**:
  - Browse all log files
  - See file size, creation date, last modified
  - View file contents directly
  - Copy file path to clipboard
  - Open folder location in file manager

#### **Option 2: Terminal/Command Line**
```bash
# View current log file
tail -50 ~/Documents/pet_care_logs/current.log

# Follow logs in real-time
tail -f ~/Documents/pet_care_logs/current.log

# Search for errors
grep "ERROR\|CRITICAL" ~/Documents/pet_care_logs/current.log

# View all archived logs
ls -lah ~/Documents/pet_care_logs/
```

#### **Option 3: Manual File Browser**
- Navigate to log directory (see paths above)
- Open `current.log` in any text editor
- Plain text format (readable by any editor, LLMs, etc.)

### How to Use in Code

#### **Simple Logging**
```dart
import 'core/services/logger_service.dart';
import 'core/services/file_logger_service.dart';

// Log to both in-memory and file
LoggerService.debug('Debug message');
LoggerService.info('Info message');
LoggerService.warning('Warning message');
LoggerService.error('Error occurred');
LoggerService.critical('Critical issue');

// Async file logging
await FileLoggerService.log('This will be saved to file');
```

#### **Error Logging with Stack Traces**
```dart
try {
  // some operation
} catch (e, st) {
  LoggerService.error('Operation failed: $e');
  await FileLoggerService.logError('Operation failed', exception: e, stackTrace: st);
}
```

#### **Export Logs for Sharing**
```dart
// Export in-memory logs to clipboard
String logs = LoggerService.exportLogs();

// Get all file logs
List<File> files = await FileLoggerService.getAllLogFiles();

// Get current log content
String content = await FileLoggerService.getCurrentLogContent();

// Get logs summary
Map<String, dynamic> summary = await FileLoggerService.getLogsSummary();
```

### Log Format

All logs follow this standardized format:
```
[HH:MM:SS.mmm] [LEVEL] [ClassName] Message details
[14:23:45.123] [ERROR] [BudgetScreen] Failed to load budget data
[14:23:46.456] [INFO] [PetService] Pet 'Buddy' created successfully
[14:23:47.789] [CRITICAL] [FirebaseService] Database connection lost
```

### Important Notes

- **Automatic Initialization**: Logs are automatically initialized in `main.dart` before any screens load
- **No Performance Impact**: Logging is asynchronous and non-blocking
- **Log Persistence**: File logs survive app restart; in-memory logs do not
- **Privacy**: No sensitive data should be logged (passwords, API keys, PII)
- **Sharing**: Logs can be easily shared via email, GitHub issues, or sent to LLMs for debugging

---

## Current Issues Status

### ✅ FIXED (This Session)
- [x] Build compilation errors (50+ import/syntax fixes)
- [x] Button theming (AppButton now uses Theme.of(context))
- [x] No way to see GUI errors (Added logging + on-screen widget)
- [x] No file-based logging (Added FileLoggerService)
- [x] No error sharing mechanism (Added log files & GUI export)

### ⏳ PARTIAL FIXES
- [ ] Dark mode colors (AppButton fixed; 483+ other components remain using hardcoded AppColors)
- [ ] Theme color bleeding (System works but 484+ references bypass it)

### ❌ NOT YET FIXED
- [ ] Searchbars remain light in dark mode
- [ ] Page backgrounds don't adapt to dark mode
- [ ] Budget/Account/Expense screens show light mode styling with gray text in dark mode
- [ ] Elements overlap due to inconsistent spacing system
- [ ] Android build Gradle error (permission_handler_android plugin compatibility)
- [ ] 484+ hardcoded AppColors references throughout codebase still need migration

### 🔄 DEFERRED (Phase 2-3)
- Complete dark mode migration across all screens
- Full theme system overhaul (all 484 AppColors → Theme system)
- Fix overlapping UI elements with standardized spacing
- Android build compatibility
- Server log upload enhancement

---
Changes or further insights should document their rationale directly within this file. This ensures all adjustments are traceable.