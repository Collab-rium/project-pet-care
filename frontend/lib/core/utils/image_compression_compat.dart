import 'dart:io';
import 'image_compression.dart';

class ImageCompressionCompat {
  static Future<File> compressImageFromPath(String path) async {
    final file = File(path);
    return await ImageCompressionUtil.compressImage(file);
  }
}
