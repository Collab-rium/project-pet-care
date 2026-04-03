import 'package:flutter/foundation.dart';

/// Severity levels for logging
enum LogLevel {
  debug,
  info,
  warning,
  error,
  critical,
}

/// A simple, easy-to-use logging service for the Pet Care app
/// 
/// Usage:
///   LoggerService.debug('App initialized');
///   LoggerService.error('Failed to load pets', exception: e, stackTrace: st);
///   LoggerService.warning('API response delayed');
class LoggerService {
  static final List<LogEntry> _logs = [];
  static final int _maxLogs = 1000; // Keep last 1000 logs in memory
  static bool _enableFileLogging = true;
  static LogLevel _minLevel = LogLevel.debug;

  /// Initialize logger with optional file logging
  static void init({
    bool enableFileLogging = true,
    LogLevel minLevel = LogLevel.debug,
  }) {
    _enableFileLogging = enableFileLogging;
    _minLevel = minLevel;
    if (kDebugMode) {
      print('LoggerService initialized - fileLogging: $_enableFileLogging');
    }
  }

  /// Log a debug message
  static void debug(String message, {dynamic exception, StackTrace? stackTrace}) {
    _log(LogLevel.debug, message, exception, stackTrace);
  }

  /// Log an info message
  static void info(String message, {dynamic exception, StackTrace? stackTrace}) {
    _log(LogLevel.info, message, exception, stackTrace);
  }

  /// Log a warning message
  static void warning(String message, {dynamic exception, StackTrace? stackTrace}) {
    _log(LogLevel.warning, message, exception, stackTrace);
  }

  /// Log an error message
  static void error(String message, {dynamic exception, StackTrace? stackTrace}) {
    _log(LogLevel.error, message, exception, stackTrace);
  }

  /// Log a critical error
  static void critical(String message, {dynamic exception, StackTrace? stackTrace}) {
    _log(LogLevel.critical, message, exception, stackTrace);
  }

  /// Internal logging method
  static void _log(
    LogLevel level,
    String message, [
    dynamic exception,
    StackTrace? stackTrace,
  ]) {
    if (level.index < _minLevel.index) return;

    final timestamp = DateTime.now();
    final entry = LogEntry(
      timestamp: timestamp,
      level: level,
      message: message,
      exception: exception,
      stackTrace: stackTrace,
    );

    // Store in memory
    _logs.add(entry);
    if (_logs.length > _maxLogs) {
      _logs.removeAt(0); // Keep only last _maxLogs entries
    }

    // Print to console
    _printToConsole(entry);
  }

  /// Print log entry to console
  static void _printToConsole(LogEntry entry) {
    if (!kDebugMode) return;

    final levelStr = entry.level.toString().split('.').last.toUpperCase();
    final timestamp = '${entry.timestamp.hour.toString().padLeft(2, '0')}:${entry.timestamp.minute.toString().padLeft(2, '0')}:${entry.timestamp.second.toString().padLeft(2, '0')}';
    
    final output = '[$timestamp] $levelStr: ${entry.message}';
    print(output);

    if (entry.exception != null) {
      print('  Exception: ${entry.exception}');
    }
    if (entry.stackTrace != null) {
      print('  StackTrace:\n${entry.stackTrace}');
    }
  }

  /// Get all logs
  static List<LogEntry> getLogs() => List.unmodifiable(_logs);

  /// Get logs filtered by level
  static List<LogEntry> getLogsByLevel(LogLevel level) {
    return _logs.where((log) => log.level == level).toList();
  }

  /// Clear all logs
  static void clearLogs() {
    _logs.clear();
  }

  /// Export logs as formatted string (useful for debugging)
  static String exportLogs({LogLevel? minLevel}) {
    final buffer = StringBuffer();
    buffer.writeln('=== Pet Care App Logs ===');
    buffer.writeln('Generated: ${DateTime.now()}');
    buffer.writeln('');

    final logsToExport = minLevel != null
        ? _logs.where((log) => log.level.index >= minLevel.index).toList()
        : _logs;

    for (final entry in logsToExport) {
      buffer.writeln(entry.toString());
    }

    return buffer.toString();
  }

  /// Get recent logs (last N entries)
  static List<LogEntry> getRecentLogs({int count = 50}) {
    return _logs.length > count
        ? _logs.sublist(_logs.length - count)
        : List.from(_logs);
  }

  /// Get statistics about logs
  static Map<String, int> getLogStats() {
    final stats = <String, int>{};
    for (final level in LogLevel.values) {
      stats[level.toString().split('.').last] =
          _logs.where((log) => log.level == level).length;
    }
    return stats;
  }
}

/// A single log entry
class LogEntry {
  final DateTime timestamp;
  final LogLevel level;
  final String message;
  final dynamic exception;
  final StackTrace? stackTrace;

  LogEntry({
    required this.timestamp,
    required this.level,
    required this.message,
    this.exception,
    this.stackTrace,
  });

  @override
  String toString() {
    final levelStr = level.toString().split('.').last.toUpperCase();
    final time = '${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}:${timestamp.second.toString().padLeft(2, '0')}.${timestamp.millisecond.toString().padLeft(3, '0')}';
    
    final buffer = StringBuffer();
    buffer.write('[$time] $levelStr: $message');
    
    if (exception != null) {
      buffer.write('\n  Exception: $exception');
    }
    
    return buffer.toString();
  }
}
