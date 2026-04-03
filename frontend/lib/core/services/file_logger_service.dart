import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/foundation.dart';

/// File-based logging service for persistent error tracking
/// Writes logs to files that can be easily shared with developers
/// 
/// Files are stored in app documents directory:
/// - logs/current.log (today's logs)
/// - logs/archive_YYYY-MM-DD.log (previous days)
class FileLoggerService {
  static final FileLoggerService _instance = FileLoggerService._internal();
  
  factory FileLoggerService() {
    return _instance;
  }
  
  FileLoggerService._internal();

  late Directory _logsDirectory;
  late File _currentLogFile;
  bool _initialized = false;
  final int _maxFileSizeBytes = 5 * 1024 * 1024; // 5MB per file

  /// Initialize file logger
  static Future<void> initialize() async {
    await _instance._init();
  }

  Future<void> _init() async {
    if (_initialized) return;
    
    try {
      final docDir = await getApplicationDocumentsDirectory();
      _logsDirectory = Directory('${docDir.path}/pet_care_logs');
      
      // Create logs directory if it doesn't exist
      if (!_logsDirectory.existsSync()) {
        _logsDirectory.createSync(recursive: true);
      }
      
      // Create or get current log file
      _currentLogFile = File('${_logsDirectory.path}/current.log');
      
      // If current log is too large, archive it
      if (_currentLogFile.existsSync()) {
        if (_currentLogFile.lengthSync() > _maxFileSizeBytes) {
          await _archiveCurrentLog();
        }
      }
      
      _initialized = true;
      _writeToFile('═══ LOG SESSION STARTED ═══ ${DateTime.now()}');
    } catch (e) {
      if (kDebugMode) print('FileLoggerService init error: $e');
    }
  }

  /// Write a message to log file
  static Future<void> log(String message, {String level = 'INFO'}) async {
    if (!_instance._initialized) {
      await _instance._init();
    }
    
    final timestamp = DateTime.now().toString();
    final logEntry = '[$timestamp] $level: $message';
    await _instance._writeToFile(logEntry);
  }

  /// Log an error with exception and stack trace
  static Future<void> logError(
    String message, {
    dynamic exception,
    StackTrace? stackTrace,
  }) async {
    if (!_instance._initialized) {
      await _instance._init();
    }
    
    final timestamp = DateTime.now().toString();
    final buffer = StringBuffer();
    buffer.writeln('[$timestamp] ERROR: $message');
    
    if (exception != null) {
      buffer.writeln('  Exception: $exception');
    }
    if (stackTrace != null) {
      buffer.writeln('  StackTrace:');
      buffer.writeln(stackTrace.toString());
    }
    
    await _instance._writeToFile(buffer.toString());
  }

  /// Write to file
  Future<void> _writeToFile(String message) async {
    try {
      // Check if file needs rotation
      if (_currentLogFile.existsSync()) {
        if (_currentLogFile.lengthSync() > _maxFileSizeBytes) {
          await _archiveCurrentLog();
        }
      }
      
      // Append to current log file
      await _currentLogFile.writeAsString(
        '$message\n',
        mode: FileMode.append,
      );
    } catch (e) {
      if (kDebugMode) print('Error writing to log file: $e');
    }
  }

  /// Archive current log file (rotate)
  Future<void> _archiveCurrentLog() async {
    try {
      final now = DateTime.now();
      final dateStr = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
      final archiveFile = File('${_logsDirectory.path}/archive_$dateStr.log');
      
      // If archive exists, append to it; otherwise create new
      if (_currentLogFile.existsSync()) {
        final content = _currentLogFile.readAsStringSync();
        await archiveFile.writeAsString(
          content + '\n--- ROTATED ---\n',
          mode: FileMode.append,
        );
        
        // Clear current log
        await _currentLogFile.writeAsString('');
      }
    } catch (e) {
      if (kDebugMode) print('Error archiving log: $e');
    }
  }

  /// Get current log file path (for sharing)
  static Future<String> getLogFilePath() async {
    if (!_instance._initialized) {
      await _instance._init();
    }
    return _instance._currentLogFile.path;
  }

  /// Get all log files
  static Future<List<File>> getAllLogFiles() async {
    if (!_instance._initialized) {
      await _instance._init();
    }
    
    try {
      final files = _instance._logsDirectory
          .listSync()
          .whereType<File>()
          .where((f) => f.path.endsWith('.log'))
          .toList();
      
      // Sort by modification time (newest first)
      files.sort((a, b) => b.lastModifiedSync().compareTo(a.lastModifiedSync()));
      return files;
    } catch (e) {
      if (kDebugMode) print('Error getting log files: $e');
      return [];
    }
  }

  /// Get current log content as string
  static Future<String> getCurrentLogContent() async {
    if (!_instance._initialized) {
      await _instance._init();
    }
    
    try {
      if (_instance._currentLogFile.existsSync()) {
        return _instance._currentLogFile.readAsStringSync();
      }
      return 'No logs yet';
    } catch (e) {
      return 'Error reading logs: $e';
    }
  }

  /// Get logs directory path (for sharing entire folder)
  static Future<String> getLogsDirPath() async {
    if (!_instance._initialized) {
      await _instance._init();
    }
    return _instance._logsDirectory.path;
  }

  /// Clear all logs (use with caution)
  static Future<void> clearAllLogs() async {
    if (!_instance._initialized) {
      await _instance._init();
    }
    
    try {
      final files = _instance._logsDirectory.listSync();
      for (var file in files) {
        if (file is File && file.path.endsWith('.log')) {
          await file.delete();
        }
      }
      _instance._currentLogFile = File('${_instance._logsDirectory.path}/current.log');
    } catch (e) {
      if (kDebugMode) print('Error clearing logs: $e');
    }
  }

  /// Get formatted summary of all logs
  static Future<String> getLogsSummary() async {
    final files = await getAllLogFiles();
    final buffer = StringBuffer();
    
    buffer.writeln('╔════════════════════════════════════════╗');
    buffer.writeln('║       PET CARE APP - LOG SUMMARY       ║');
    buffer.writeln('╚════════════════════════════════════════╝\n');
    
    buffer.writeln('Log Files: ${files.length}');
    buffer.writeln('Location: ${await getLogsDirPath()}\n');
    
    for (var file in files) {
      final size = file.lengthSync();
      final modified = file.lastModifiedSync();
      final name = file.path.split('/').last;
      final sizeStr = (size / 1024).toStringAsFixed(2) + ' KB';
      
      buffer.writeln('📄 $name');
      buffer.writeln('   Size: $sizeStr');
      buffer.writeln('   Modified: $modified\n');
    }
    
    return buffer.toString();
  }
}
