# File-Based Logging - Complete Guide

## What This Does

### Problem Solved ✅
- Errors happen in GUI
- You see them on screen
- But can't share them easily with developers/LLMs
- **NOW**: Logs are written to FILES that you can:
  - Email to developer
  - Share on chat/Slack
  - Upload to GitHub issues
  - Give to LLMs for analysis
  - Open with text editor anytime (even after app closes)

---

## How It Works

### 1. Automatic File Logging
Every time the app runs, it automatically writes to:
```
~/Documents/pet_care_logs/current.log
```

### 2. Logs Stay After App Closes ✅
- In-memory logs: Lost when app closes ❌
- File logs: Permanent, stay forever ✅
- You can read them anytime

### 3. Auto-Archiving
When current log gets too big (5MB):
- Old log renamed to: `archive_2026-04-03.log`
- New current log started
- History preserved

---

## How to Find & Share Logs

### Option 1: In-App GUI (Easiest)
1. Run app: `flutter run -d linux`
2. Tap floating button (bottom-right)
3. Click **"Files"** tab (next to "Logs")
4. See all log files
5. Click file → "Copy Path"
6. Share the path with developer

### Option 2: Open Log Folder Directly
1. Run app
2. Tap floating button
3. Click "Files"
4. Click "Open Folder" button
5. See location like:
   ```
   /home/arslan/.local/share/project_pet_care_frontend/documents/pet_care_logs/
   ```
6. Email the entire folder or specific .log files

### Option 3: Terminal
```bash
# See all log files
ls ~/Documents/pet_care_logs/

# View current log
cat ~/Documents/pet_care_logs/current.log

# View with timestamps
tail -100 ~/Documents/pet_care_logs/current.log

# Email to developer
cat ~/Documents/pet_care_logs/current.log | mail -s "Pet Care App Logs" developer@example.com
```

---

## How to Add Logs to Code

### Simple Logging
```dart
import 'core/services/file_logger_service.dart';

// In your screen/function:
Future<void> loadPets() async {
  await FileLoggerService.log('Loading pets...');
  
  try {
    final pets = await _petService.getPets();
    await FileLoggerService.log('Loaded ${pets.length} pets');
  } catch (e, st) {
    await FileLoggerService.logError('Failed to load pets', exception: e, stackTrace: st);
  }
}
```

### Error with Stack Trace
```dart
try {
  await saveBudget(budget);
} catch (e, st) {
  await FileLoggerService.logError(
    'Failed to save budget for pet $petId',
    exception: e,
    stackTrace: st,
  );
}
```

---

## Example Workflow

### Scenario: "Budget button not showing"

#### Step 1: Add debugging logs to BudgetScreen
```dart
@override
void initState() {
  super.initState();
  _loadData();
}

Future<void> _loadData() async {
  await FileLoggerService.log('BudgetScreen: _loadData() started');
  
  try {
    final pets = await _petService.getPets();
    await FileLoggerService.log('BudgetScreen: Loaded ${pets.length} pets');
    
    setState(() {
      _pets = pets;
      _isLoading = false;
    });
    
    await FileLoggerService.log('BudgetScreen: State updated, rendering...');
  } catch (e, st) {
    await FileLoggerService.logError('BudgetScreen: Failed to load', exception: e, stackTrace: st);
  }
}
```

#### Step 2: Run the app
```bash
cd frontend && flutter run -d linux
```

#### Step 3: Trigger the action
- Go to Budget screen
- Watch for the issue

#### Step 4: Get the logs
```bash
# Quick view
tail -50 ~/Documents/pet_care_logs/current.log

# Or via GUI
# - Tap floating button
# - Click "Files"
# - Click current.log
# - See what happened
```

#### Step 5: Share with developer
```bash
# Email the logs
cat ~/Documents/pet_care_logs/current.log | mail -s "Budget Screen Debug" dev@example.com

# Or just share the path
echo "~/Documents/pet_care_logs/current.log"
```

---

## Log Files Location

Different OS, different locations:

### Linux
```
~/Documents/pet_care_logs/
```

### macOS
```
~/Library/Containers/com.example.project_pet_care_frontend/Data/Documents/pet_care_logs/
```

### Windows
```
C:\Users\YourName\AppData\Local\project_pet_care_frontend\documents\pet_care_logs\
```

---

## Features

### ✅ What Works
- [x] Automatic logging (no manual setup needed)
- [x] Persistent (survives app restart)
- [x] Auto-rotation (prevents huge files)
- [x] Easy access in GUI
- [x] Copy paths to clipboard
- [x] View file contents in app
- [x] Exception + stack trace capture
- [x] Timestamps on every log

### ⏳ Future Enhancements
- [ ] Upload to server automatically
- [ ] Compress old logs
- [ ] Email logs directly from app
- [ ] Remote logging dashboard
- [ ] Log filtering and search

---

## Troubleshooting

### "I can't find the log files"
```bash
# Check the location exists
ls ~/Documents/pet_care_logs/

# If empty, logs haven't been written yet
# Run app and trigger an action
```

### "Log file is empty"
- App just started, no errors yet
- Add some `FileLoggerService.log()` calls
- Run app again

### "Log file is huge"
- Normal - auto-rotates at 5MB
- Old logs archived to `archive_*.log`
- Latest events in `current.log`

### "I want to clear logs"
```dart
await FileLoggerService.clearAllLogs();
```

---

## Quick Commands

```bash
# View current log (last 100 lines)
tail -100 ~/Documents/pet_care_logs/current.log

# Count log entries
wc -l ~/Documents/pet_care_logs/current.log

# Search for errors
grep ERROR ~/Documents/pet_care_logs/*.log

# Save to shareable text file
cp ~/Documents/pet_care_logs/current.log ~/Downloads/pet-care-logs.txt

# Open in text editor
nano ~/Documents/pet_care_logs/current.log
```

---

## Integration Points

### Both systems work together

**In-Memory Logger** (LoggerService)
- Console output (real-time viewing)
- Clipboard copy
- Live filtering

**File Logger** (FileLoggerService)  
- Persistent storage
- For sharing
- Survive app restart
- Easy email/upload

**Use both!**
```dart
// This writes to BOTH console AND file
await LoggerService.debug('message');  // Console + memory
await FileLoggerService.log('message'); // File only
```

---

## Summary

✅ **Problem**: Errors in GUI, can't share with developers  
✅ **Solution**: Files written automatically to ~/Documents/pet_care_logs/  
✅ **Access**: GUI viewer or terminal  
✅ **Share**: Email files or share paths  
✅ **Read**: LLMs/developers can analyze log files  

**Ready to use right now!**
