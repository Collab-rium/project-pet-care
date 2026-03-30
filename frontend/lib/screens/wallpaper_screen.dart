import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import '../core/constants/colors.dart';
import '../core/constants/spacing.dart';
import '../core/constants/text_styles.dart';
import '../core/utils/error_handler.dart';

/// Screen for setting custom wallpaper
class WallpaperScreen extends StatefulWidget {
  const WallpaperScreen({super.key});

  @override
  State<WallpaperScreen> createState() => _WallpaperScreenState();
}

class _WallpaperScreenState extends State<WallpaperScreen> {
  String? _wallpaperPath;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadWallpaper();
  }

  Future<void> _loadWallpaper() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _wallpaperPath = prefs.getString('wallpaper_path');
      _isLoading = false;
    });
  }

  Future<void> _pickWallpaper() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 90,
      );

      if (image != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('wallpaper_path', image.path);
        
        setState(() {
          _wallpaperPath = image.path;
        });

        if (mounted) {
          AppErrorHandler.showSuccessSnackBar(
            context,
            'Wallpaper set successfully!',
          );
        }
      }
    } catch (e) {
      if (mounted) {
        AppErrorHandler.showErrorSnackBar(
          context,
          'Failed to set wallpaper: ${e.toString()}',
        );
      }
    }
  }

  Future<void> _removeWallpaper() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('wallpaper_path');
    
    setState(() {
      _wallpaperPath = null;
    });

    if (mounted) {
      AppErrorHandler.showInfoSnackBar(
        context,
        'Wallpaper removed',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Wallpaper', style: AppTextStyles.h2),
        backgroundColor: AppColors.surface,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: AppSpacing.pageInsets,
              children: [
                Text(
                  'Custom Wallpaper',
                  style: AppTextStyles.h3,
                ),
                AppSpacing.vSpaceSm,
                Text(
                  'Set a photo of your pet as your app background',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                
                AppSpacing.vSpaceLg,
                
                // Current wallpaper preview
                if (_wallpaperPath != null)
                  Column(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.file(
                          File(_wallpaperPath!),
                          height: 300,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),
                      AppSpacing.vSpaceMd,
                      ElevatedButton.icon(
                        onPressed: _removeWallpaper,
                        icon: const Icon(Icons.delete_outline),
                        label: const Text('Remove Wallpaper'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.error,
                        ),
                      ),
                    ],
                  )
                else
                  Container(
                    height: 300,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceVariant,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.border,
                        width: 2,
                        style: BorderStyle.solid,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.wallpaper,
                          size: 64,
                          color: AppColors.textTertiary,
                        ),
                        AppSpacing.vSpaceMd,
                        Text(
                          'No wallpaper set',
                          style: AppTextStyles.bodyLarge.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                
                AppSpacing.vSpaceLg,
                
                ElevatedButton.icon(
                  onPressed: _pickWallpaper,
                  icon: const Icon(Icons.photo_library),
                  label: Text(_wallpaperPath != null ? 'Change Wallpaper' : 'Set Wallpaper'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
                
                AppSpacing.vSpaceLg,
                
                Card(
                  child: Padding(
                    padding: AppSpacing.cardInsets,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.info_outline, color: AppColors.info),
                            AppSpacing.hSpaceSm,
                            Text('Tips', style: AppTextStyles.h4),
                          ],
                        ),
                        AppSpacing.vSpaceSm,
                        Text(
                          '• Choose a high-quality photo of your pet\n'
                          '• Lighter images work best for readability\n'
                          '• The wallpaper will be slightly dimmed for better text contrast',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
