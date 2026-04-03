# Logger Module - Quick Reference Guide

## Overview
The app now has a built-in logging system that captures all events, warnings, and errors. You can view logs in real-time on the screen without needing external tools.

## How to Use Logger in Code

### 1. Import the logger
```dart
import 'core/services/logger_service.dart';
```

### 2. Log at different levels

**DEBUG** - Detailed information for debugging
```dart
LoggerService.debug('User logged in: ${user.id}');
LoggerService.debug('Pet data loaded: ${pets.length} pets');
```

**INFO** - General informational messages
```dart
LoggerService.info('App started');
LoggerService.info('Syncing data with server');
```

**WARNING** - Warning that something unusual happened
```dart
LoggerService.warning('High memory usage detected');
LoggerService.warning('API response took 3 seconds');
```

**ERROR** - An error occurred but app continues
```dart
try {
  await loadPets();
} catch (e, st) {
  LoggerService.error('Failed to load pets', exception: e, stackTrace: st);
}
```

**CRITICAL** - Severe error, app may crash
```dart
LoggerService.critical('Database connection lost', exception: e);
```

## How to View Logs

### Method 1: On-Screen Debug Widget
1. Look for a small floating button in the bottom-right corner (shows error count)
2. Tap the button to open the log viewer
3. Features:
   - View all recent logs
   - Filter by log level (debug/info/warning/error/critical)
   - See timestamp, exception, and stack trace
   - Scroll through logs
   - Copy all logs to clipboard
   - View statistics (count by level)
   - Clear logs

### Method 2: Console Output (During Development)
All logs are printed to console with format:
```
[HH:MM:SS] LEVEL: message
```
Example:
```
[09:30:45] DEBUG: App initialized
[09:30:46] INFO: AuthService initialized
[09:31:02] WARNING: API response took 3s
[09:31:15] ERROR: Failed to load pets
  Exception: SocketException: Connection refused
```

### Method 3: Programmatic Access
```dart
// Get all logs
List<LogEntry> allLogs = LoggerService.getLogs();

// Get logs of specific level
List<LogEntry> errors = LoggerService.getLogsByLevel(LogLevel.error);

// Get recent logs (last N)
List<LogEntry> recent = LoggerService.getRecentLogs(count: 50);

// Get statistics
Map<String, int> stats = LoggerService.getLogStats();
// Result: {debug: 10, info: 5, warning: 2, error: 1, critical: 0}

// Export as formatted text
String logsText = LoggerService.exportLogs();
// Use this to save to file or send to backend
```

## Common Logging Patterns

### Pattern 1: Track Function Execution
```dart
void loadUserData() {
  LoggerService.debug('loadUserData() started');
  try {
    // ... load data ...
    LoggerService.info('User data loaded successfully');
  } catch (e, st) {
    LoggerService.error('Failed to load user data', exception: e, stackTrace: st);
  }
}
```

### Pattern 2: Track State Changes
```dart
setState(() {
  isLoading = true;
  LoggerService.debug('Setting isLoading=true');
  // ... make request ...
});
```

### Pattern 3: Track User Actions
```dart
ElevatedButton(
  onPressed: () {
    LoggerService.info('User tapped "Add Pet" button');
    _addPet();
  },
  child: Text('Add Pet'),
)
```

### Pattern 4: API/Network Calls
```dart
Future<List<Pet>> fetchPets() async {
  LoggerService.debug('Fetching pets from API...');
  try {
    final response = await http.get(url);
    LoggerService.debug('API response: ${response.statusCode}');
    final pets = parsePets(response.body);
    LoggerService.info('Fetched ${pets.length} pets');
    return pets;
  } catch (e) {
    LoggerService.error('API call failed', exception: e);
    rethrow;
  }
}
```

## How to Debug Using Logs

### Scenario: "Budget button not showing"
1. Open log viewer (tap floating button)
2. Look for entries with "BudgetScreen"
3. Search for messages like:
   - `isLoading=false` (loading is complete)
   - `petsCount=0` (no pets → button won't show)
   - `selectedPet=null` (no pet selected)
4. **Solution**: Add a pet first, then button appears

### Scenario: "Dark mode colors wrong"
1. Filter logs to show all messages
2. Look for theme-related logs:
   - `Theme changed to: dark`
   - `Theme changed to: cool`
3. Check if background colors are being set
4. Use `LoggerService.debug()` to add tracking to color assignments

### Scenario: "App crashes"
1. Open log viewer immediately
2. Look for ERROR or CRITICAL messages
3. Read the exception and stack trace
4. Share the full log export with developer

## Configuration

### In main.dart (already set up)
```dart
LoggerService.init(
  enableFileLogging: true,
  minLevel: LogLevel.debug,  // Capture all levels
);
```

### To change minimum level (debug only)
```dart
// After init, in development
LoggerService.init(minLevel: LogLevel.warning);  // Only warn/error/critical
```

### To clear logs
```dart
LoggerService.clearLogs();
```

## Best Practices

1. **Use appropriate levels**
   - DEBUG for detailed info
   - INFO for important events
   - WARNING for unusual but recoverable situations
   - ERROR for failed operations
   - CRITICAL for fatal errors

2. **Include context**
   ```dart
   // ✅ Good
   LoggerService.debug('Loading budget for pet: $petId');
   
   // ❌ Bad
   LoggerService.debug('Loading...');
   ```

3. **Don't log passwords or sensitive data**
   ```dart
   // ✅ Good
   LoggerService.info('User logged in: ${user.email}');
   
   // ❌ Bad
   LoggerService.debug('Password: ${password}');
   ```

4. **Always catch and log errors**
   ```dart
   try {
     // operation
   } catch (e, st) {
     LoggerService.error('Operation failed', exception: e, stackTrace: st);
   }
   ```

## Export and Share Logs

### To Copy Logs to Clipboard
1. Open error logger widget
2. Click "Copy Logs" button
3. Paste in email, chat, or file

### To Save Logs to File (future feature)
```dart
// Not yet implemented, but will be added
final logsText = LoggerService.exportLogs();
// Save logsText to file
```

## Troubleshooting

### "I don't see the floating button"
- App might have no errors/warnings yet (button still exists)
- Try tapping bottom-right corner where it should be
- Or open Settings → Debug → View Logs (if available)

### "Logs are lost when app restarts"
- This is expected (in-memory storage)
- Export before closing app if needed
- Future: Will add persistent file storage

### "Logger is slowing down the app"
- Shouldn't impact performance (minimal overhead)
- Logging is async and non-blocking
- Memory capped at 1000 entries
- Can reduce by setting minLevel to LogLevel.error

---

## Real Examples

### Example 1: Budget Screen Bug
```dart
// In budget_screen.dart
@override
void initState() {
  super.initState();
  LoggerService.debug('BudgetScreen: initState()');
  _loadData();
}

Future<void> _loadData() async {
  LoggerService.debug('Loading budget data...');
  try {
    final pets = await _petService.getPets();
    LoggerService.debug('Loaded ${pets.length} pets');
    setState(() {
      _pets = pets;
      _isLoading = false;
      LoggerService.debug('State updated: _pets=${_pets.length}, _isLoading=false');
    });
  } catch (e, st) {
    LoggerService.error('Failed to load pets', exception: e, stackTrace: st);
  }
}
```

Output in logs:
```
[09:45:30] DEBUG: BudgetScreen: initState()
[09:45:30] DEBUG: Loading budget data...
[09:45:31] DEBUG: Loaded 0 pets
[09:45:31] DEBUG: State updated: _pets=0, _isLoading=false
```

**Insight**: No pets in system → button won't show

### Example 2: Dark Mode Issue
```dart
// In theme_manager.dart
void switchTheme(String themeId) {
  LoggerService.info('Switching theme from $_currentTheme to $themeId');
  _currentTheme = themeId;
  notifyListeners();
  LoggerService.info('Theme switched and listeners notified');
}

void toggleDarkMode() {
  LoggerService.info('Toggling dark mode: $isDarkMode → ${!isDarkMode}');
  _isDarkMode = !isDarkMode;
  notifyListeners();
  LoggerService.info('Dark mode toggled and listeners notified');
}
```

Check logs to see if theme change is actually happening.

---

**Last Updated**: April 3, 2026
