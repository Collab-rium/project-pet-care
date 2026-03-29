import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

/// Service for tracking and managing storage usage
class StorageService {
  // Storage thresholds
  static const int warningThresholdMB = 50;
  static const int criticalThresholdMB = 100;

  /// Get current storage information
  static Future<StorageInfo> getStorageInfo() async {
    try {
      // Get database size
      final dbPath = await getDatabasesPath();
      final dbFile = File('$dbPath/pet_care.db');
      final dbSize = await dbFile.exists() ? await dbFile.length() : 0;

      // Get photos directory size
      final appDir = await getApplicationDocumentsDirectory();
      final photosDir = Directory('${appDir.path}/photos');
      int photosSize = 0;

      if (await photosDir.exists()) {
        await for (var file in photosDir.list(recursive: true)) {
          if (file is File) {
            try {
              photosSize += await file.length();
            } catch (e) {
              if (kDebugMode) {
                print('Error reading file size: $e');
              }
            }
          }
        }
      }

      // Get cache size
      final cacheDir = await getTemporaryDirectory();
      int cacheSize = 0;
      
      if (await cacheDir.exists()) {
        await for (var file in cacheDir.list(recursive: true)) {
          if (file is File) {
            try {
              cacheSize += await file.length();
            } catch (e) {
              if (kDebugMode) {
                print('Error reading cache file size: $e');
              }
            }
          }
        }
      }

      final totalBytes = dbSize + photosSize;
      final totalMB = totalBytes / (1024 * 1024);

      return StorageInfo(
        databaseBytes: dbSize,
        photosBytes: photosSize,
        cacheBytes: cacheSize,
        totalBytes: totalBytes,
        databaseMB: dbSize / (1024 * 1024),
        photosMB: photosSize / (1024 * 1024),
        cacheMB: cacheSize / (1024 * 1024),
        totalMB: totalMB,
        needsWarning: totalMB > warningThresholdMB,
        isCritical: totalMB > criticalThresholdMB,
      );
    } catch (e) {
      if (kDebugMode) {
        print('Error getting storage info: $e');
      }
      rethrow;
    }
  }

  /// Clear cache directory
  static Future<void> clearCache() async {
    try {
      final cacheDir = await getTemporaryDirectory();
      if (await cacheDir.exists()) {
        await for (var file in cacheDir.list()) {
          try {
            await file.delete(recursive: true);
          } catch (e) {
            if (kDebugMode) {
              print('Error deleting cache file: $e');
            }
          }
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error clearing cache: $e');
      }
      rethrow;
    }
  }

  /// Format bytes to human-readable string
  static String formatBytes(int bytes) {
    if (bytes < 1024) {
      return '$bytes B';
    } else if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    } else if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    } else {
      return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
    }
  }

  /// Get storage usage percentage (0.0 to 1.0)
  static double getUsagePercentage(StorageInfo info) {
    return info.totalMB / criticalThresholdMB;
  }
}

/// Storage information model
class StorageInfo {
  final int databaseBytes;
  final int photosBytes;
  final int cacheBytes;
  final int totalBytes;
  final double databaseMB;
  final double photosMB;
  final double cacheMB;
  final double totalMB;
  final bool needsWarning;
  final bool isCritical;

  StorageInfo({
    required this.databaseBytes,
    required this.photosBytes,
    required this.cacheBytes,
    required this.totalBytes,
    required this.databaseMB,
    required this.photosMB,
    required this.cacheMB,
    required this.totalMB,
    required this.needsWarning,
    required this.isCritical,
  });

  String get formattedTotal => StorageService.formatBytes(totalBytes);
  String get formattedDatabase => StorageService.formatBytes(databaseBytes);
  String get formattedPhotos => StorageService.formatBytes(photosBytes);
  String get formattedCache => StorageService.formatBytes(cacheBytes);
}
