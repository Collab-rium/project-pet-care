import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';

/// Image compression utility for optimizing photo storage
/// Compresses images to max 1920px width at 80% quality
/// Generates 200x200 thumbnails for list views
class ImageCompressionUtil {
  // Maximum image dimensions
  static const int maxWidth = 1920;
  static const int maxHeight = 1920;
  static const int thumbnailSize = 200;
  
  // Compression quality (0-100)
  static const int compressionQuality = 80;
  static const int thumbnailQuality = 85;

  /// Compress a full-size image
  /// Returns the compressed image file
  static Future<File> compressImage(File imageFile) async {
    try {
      // Read image bytes
      final bytes = await imageFile.readAsBytes();
      
      // Decode image
      final image = img.decodeImage(bytes);
      if (image == null) {
        throw Exception('Failed to decode image');
      }

      // Resize if larger than max dimensions
      img.Image resized = image;
      if (image.width > maxWidth || image.height > maxHeight) {
        // Calculate new dimensions while maintaining aspect ratio
        if (image.width > image.height) {
          resized = img.copyResize(
            image,
            width: maxWidth,
            interpolation: img.Interpolation.linear,
          );
        } else {
          resized = img.copyResize(
            image,
            height: maxHeight,
            interpolation: img.Interpolation.linear,
          );
        }
      }

      // Compress to JPEG
      final compressed = img.encodeJpg(resized, quality: compressionQuality);

      // Save to temporary file
      final tempDir = await getTemporaryDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final tempFile = File('${tempDir.path}/compressed_$timestamp.jpg');
      await tempFile.writeAsBytes(compressed);

      if (kDebugMode) {
        print('Compressed image: ${imageFile.path}');
        print('Original size: ${bytes.length} bytes');
        print('Compressed size: ${compressed.length} bytes');
        print('Compression ratio: ${(compressed.length / bytes.length * 100).toStringAsFixed(1)}%');
      }

      return tempFile;
    } catch (e) {
      if (kDebugMode) {
        print('Error compressing image: $e');
      }
      rethrow;
    }
  }

  /// Backwards-compatible helper: compress image from a file path
  static Future<File> compressImageFromPath(String path) async {
    final file = File(path);
    return await compressImage(file);
  }

  /// Create a thumbnail from an image
  /// Returns a 200x200 thumbnail file
  static Future<File> createThumbnail(
    File imageFile, {
    int size = thumbnailSize,
  }) async {
    try {
      // Read image bytes
      final bytes = await imageFile.readAsBytes();
      
      // Decode image
      final image = img.decodeImage(bytes);
      if (image == null) {
        throw Exception('Failed to decode image');
      }

      // Create square thumbnail by cropping to center
      final int cropSize = image.width < image.height ? image.width : image.height;
      final int offsetX = (image.width - cropSize) ~/ 2;
      final int offsetY = (image.height - cropSize) ~/ 2;
      
      final cropped = img.copyCrop(
        image,
        x: offsetX,
        y: offsetY,
        width: cropSize,
        height: cropSize,
      );

      // Resize to thumbnail size
      final thumbnail = img.copyResize(
        cropped,
        width: size,
        height: size,
        interpolation: img.Interpolation.linear,
      );

      // Compress
      final compressed = img.encodeJpg(thumbnail, quality: thumbnailQuality);

      // Save to temporary file
      final tempDir = await getTemporaryDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final tempFile = File('${tempDir.path}/thumb_$timestamp.jpg');
      await tempFile.writeAsBytes(compressed);

      if (kDebugMode) {
        print('Created thumbnail: ${imageFile.path}');
        print('Thumbnail size: ${compressed.length} bytes');
      }

      return tempFile;
    } catch (e) {
      if (kDebugMode) {
        print('Error creating thumbnail: $e');
      }
      rethrow;
    }
  }

  /// Compress and create thumbnail in one operation
  /// Returns both compressed image and thumbnail
  static Future<CompressedImageResult> compressWithThumbnail(
    File imageFile,
  ) async {
    final compressed = await compressImage(imageFile);
    final thumbnail = await createThumbnail(imageFile);
    
    return CompressedImageResult(
      compressed: compressed,
      thumbnail: thumbnail,
    );
  }

  /// Get image dimensions without loading full image
  static Future<ImageDimensions> getImageDimensions(File imageFile) async {
    final bytes = await imageFile.readAsBytes();
    final image = img.decodeImage(bytes);
    
    if (image == null) {
      throw Exception('Failed to decode image');
    }
    
    return ImageDimensions(
      width: image.width,
      height: image.height,
    );
  }

  /// Get file size in bytes
  static Future<int> getFileSize(File file) async {
    return await file.length();
  }

  /// Format file size for display
  static String formatFileSize(int bytes) {
    if (bytes < 1024) {
      return '$bytes B';
    } else if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    } else {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
  }
}

/// Result of compression with thumbnail
class CompressedImageResult {
  final File compressed;
  final File thumbnail;

  CompressedImageResult({
    required this.compressed,
    required this.thumbnail,
  });
}

/// Image dimensions
class ImageDimensions {
  final int width;
  final int height;

  ImageDimensions({
    required this.width,
    required this.height,
  });

  double get aspectRatio => width / height;
  
  @override
  String toString() => '${width}x$height';
}
