import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image/image.dart' as img;

import '../components/atoms/app_button.dart';
import '../core/constants/colors.dart';
import '../core/constants/spacing.dart';
import '../core/constants/text_styles.dart';
import '../core/models/models.dart';
import '../core/repositories/repositories.dart';
import '../core/utils/error_handler.dart';

class WallpaperCustomizationScreen extends StatefulWidget {
  const WallpaperCustomizationScreen({super.key});

  @override
  State<WallpaperCustomizationScreen> createState() => _WallpaperCustomizationScreenState();
}

class _WallpaperCustomizationScreenState extends State<WallpaperCustomizationScreen> {
  final _photoRepository = PhotoRepository();
  final _petRepository = PetRepository();
  
  String? _currentWallpaper;
  List<Photo> _petPhotos = [];
  List<Pet> _pets = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      setState(() => _isLoading = true);
      
      final photos = await _photoRepository.getAllPhotos('user-1');
      final pets = await _petRepository.getUserPets('user-1');
      
      // Load current wallpaper from storage (placeholder)
      _currentWallpaper = null; // Would load from SharedPreferences
      
      setState(() {
        _petPhotos = photos;
        _pets = pets;
        _isLoading = false;
      });
    } catch (e) {
      AppErrorHandler.showErrorSnackBar(
        context,
        'Failed to load data: ${e.toString()}',
      );
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Wallpaper',
          style: AppTextStyles.h2,
        ),
        
        elevation: 0,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView(
              padding: AppSpacing.pageInsets,
              children: [
                // Current wallpaper preview
                _buildCurrentWallpaperSection(),
                
                AppSpacing.vSpaceLg,
                
                // Default options
                _buildDefaultWallpapersSection(),
                
                AppSpacing.vSpaceLg,
                
                // Pet photos section
                _buildPetPhotosSection(),
                
                AppSpacing.vSpaceLg,
                
                // Custom upload
                _buildCustomUploadSection(),
              ],
            ),
    );
  }

  Widget _buildCurrentWallpaperSection() {
    return Container(
      padding: AppSpacing.cardInsets,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: AppSpacing.borderRadiusMd,
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Current Wallpaper',
            style: AppTextStyles.h3,
          ),
          AppSpacing.vSpaceMd,
          Container(
            width: double.infinity,
            height: 200,
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              borderRadius: AppSpacing.borderRadiusSm,
              border: Border.all(color: AppColors.border),
              image: _currentWallpaper != null
                  ? DecorationImage(
                      image: FileImage(File(_currentWallpaper!)),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: _currentWallpaper == null
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.wallpaper,
                          size: 48,
                          color: AppColors.textTertiary,
                        ),
                        AppSpacing.vSpaceSm,
                        Text(
                          'Default Background',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  )
                : null,
          ),
          if (_currentWallpaper != null) ...[
            AppSpacing.vSpaceMd,
            AppButton.outlined(
              text: 'Reset to Default',
              onPressed: _resetToDefault,
              icon: Icons.restore,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDefaultWallpapersSection() {
    final defaultWallpapers = [
      {'name': 'Gradient Blue', 'asset': 'assets/wallpapers/gradient_blue.png'},
      {'name': 'Pet Pattern', 'asset': 'assets/wallpapers/pet_pattern.png'},
      {'name': 'Minimalist', 'asset': 'assets/wallpapers/minimalist.png'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Default Wallpapers',
          style: AppTextStyles.h3,
        ),
        AppSpacing.vSpaceMd,
        GridView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: AppSpacing.md,
            mainAxisSpacing: AppSpacing.md,
            childAspectRatio: 1.5,
          ),
          itemCount: defaultWallpapers.length,
          itemBuilder: (context, index) {
            final wallpaper = defaultWallpapers[index];
            return _buildWallpaperOption(
              wallpaper['name']!,
              wallpaper['asset']!,
              () => _setDefaultWallpaper(wallpaper['asset']!),
              isAsset: true,
            );
          },
        ),
      ],
    );
  }

  Widget _buildPetPhotosSection() {
    if (_petPhotos.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Pet Photos',
            style: AppTextStyles.h3,
          ),
          AppSpacing.vSpaceMd,
          Container(
            padding: AppSpacing.cardInsets,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: AppSpacing.borderRadiusMd,
              border: Border.all(color: AppColors.border),
            ),
            child: Center(
              child: Column(
                children: [
                  Icon(
                    Icons.photo_camera,
                    size: 48,
                    color: AppColors.textTertiary,
                  ),
                  AppSpacing.vSpaceSm,
                  Text(
                    'No pet photos available',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  AppSpacing.vSpaceXs,
                  Text(
                    'Add photos to your pets to use them as wallpapers',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textTertiary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Pet Photos',
          style: AppTextStyles.h3,
        ),
        AppSpacing.vSpaceMd,
        GridView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: AppSpacing.md,
            mainAxisSpacing: AppSpacing.md,
            childAspectRatio: 1,
          ),
          itemCount: _petPhotos.length,
          itemBuilder: (context, index) {
            final photo = _petPhotos[index];
            final pet = _pets.firstWhere(
              (p) => p.id == photo.petId,
              orElse: () => Pet(
                id: '',
                name: 'Unknown Pet',
                species: '',
                breed: '',
                birthDate: DateTime.now(),
                userId: '',
                createdAt: DateTime.now(),
                updatedAt: DateTime.now(),
              ),
            );

            return _buildPetPhotoOption(photo, pet);
          },
        ),
      ],
    );
  }

  Widget _buildCustomUploadSection() {
    return Container(
      padding: AppSpacing.cardInsets,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: AppSpacing.borderRadiusMd,
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Custom Wallpaper',
            style: AppTextStyles.h3,
          ),
          AppSpacing.vSpaceMd,
          Text(
            'Upload your own image to use as wallpaper',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          AppSpacing.vSpaceMd,
          AppButton.outlined(
            text: 'Upload Image',
            onPressed: _uploadCustomWallpaper,
            icon: Icons.upload,
          ),
        ],
      ),
    );
  }

  Widget _buildWallpaperOption(
    String name,
    String imagePath,
    VoidCallback onSelect, {
    bool isAsset = false,
  }) {
    return GestureDetector(
      onTap: onSelect,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: AppSpacing.borderRadiusSm,
          border: Border.all(color: AppColors.border),
          image: DecorationImage(
            image: isAsset 
                ? AssetImage(imagePath) as ImageProvider
                : FileImage(File(imagePath)),
            fit: BoxFit.cover,
          ),
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: AppSpacing.borderRadiusSm,
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.transparent,
                Theme.of(context).colorScheme.scrim.withOpacity(0.7),
              ],
            ),
          ),
          child: Align(
            alignment: Alignment.bottomLeft,
            child: Padding(
              padding: AppSpacing.cardInsets,
              child: Text(
                name,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: Theme.of(context).colorScheme.onScrim,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPetPhotoOption(Photo photo, Pet pet) {
    return GestureDetector(
      onTap: () => _setPetPhotoAsWallpaper(photo),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: AppSpacing.borderRadiusSm,
          border: Border.all(color: AppColors.border),
          image: DecorationImage(
            image: FileImage(File(photo.filePath)),
            fit: BoxFit.cover,
          ),
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: AppSpacing.borderRadiusSm,
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.transparent,
                Theme.of(context).colorScheme.scrim.withOpacity(0.7),
              ],
            ),
          ),
          child: Align(
            alignment: Alignment.bottomLeft,
            child: Padding(
              padding: AppSpacing.cardInsets,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    pet.name,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: Theme.of(context).colorScheme.onScrim,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (photo.description != null)
                    Text(
                      photo.description!,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: Theme.of(context).colorScheme.onScrim.withOpacity(0.8),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _uploadCustomWallpaper() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
      );

      if (result != null && result.files.single.path != null) {
        final imagePath = result.files.single.path!;
        await _processAndSetWallpaper(imagePath);
      }
    } catch (e) {
      AppErrorHandler.showErrorSnackBar(
        context,
        'Failed to upload wallpaper: ${e.toString()}',
      );
    }
  }

  Future<void> _processAndSetWallpaper(String imagePath) async {
    try {
      // Load and process the image
      final imageFile = File(imagePath);
      final imageBytes = await imageFile.readAsBytes();
      final image = img.decodeImage(imageBytes);
      
      if (image == null) {
        throw Exception('Invalid image file');
      }

      // Resize image to screen dimensions for better performance
      final screenSize = MediaQuery.of(context).size;
      final resized = img.copyResize(
        image,
        width: (screenSize.width * 2).toInt(), // 2x for high DPI
        height: (screenSize.height * 2).toInt(),
        interpolation: img.Interpolation.cubic,
      );

      // Save processed image
      final appDir = '/storage/emulated/0/Android/data/com.example.petcare/files/wallpapers';
      final processedFile = File('$appDir/wallpaper_${DateTime.now().millisecondsSinceEpoch}.jpg');
      await processedFile.parent.create(recursive: true);
      await processedFile.writeAsBytes(img.encodeJpg(resized, quality: 90));

      // Set as current wallpaper
      setState(() => _currentWallpaper = processedFile.path);
      
      // Save to storage (placeholder for SharedPreferences)
      // await SharedPreferences.getInstance().setString('wallpaper_path', processedFile.path);

      AppErrorHandler.showSuccessSnackBar(
        context,
        'Wallpaper set successfully!',
      );
    } catch (e) {
      AppErrorHandler.showErrorSnackBar(
        context,
        'Failed to process wallpaper: ${e.toString()}',
      );
    }
  }

  Future<void> _setPetPhotoAsWallpaper(Photo photo) async {
    await _processAndSetWallpaper(photo.filePath);
  }

  Future<void> _setDefaultWallpaper(String assetPath) async {
    setState(() => _currentWallpaper = null);
    
    // Save default selection (placeholder)
    // await SharedPreferences.getInstance().remove('wallpaper_path');
    
    AppErrorHandler.showSuccessSnackBar(
      context,
      'Default wallpaper set successfully!',
    );
  }

  Future<void> _resetToDefault() async {
    setState(() => _currentWallpaper = null);
    
    // Remove from storage (placeholder)
    // await SharedPreferences.getInstance().remove('wallpaper_path');
    
    AppErrorHandler.showSuccessSnackBar(
      context,
      'Wallpaper reset to default!',
    );
  }
}