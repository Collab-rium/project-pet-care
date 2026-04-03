import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:math';

import '../components/atoms/app_button.dart';
import '../components/molecules/app_search_bar.dart';
import '../components/organisms/loading_widgets.dart';
import '../components/organisms/empty_states.dart';
import '../../core/constants/colors.dart';
import '../core/constants/spacing.dart';
import '../core/constants/text_styles.dart';
import '../core/models/models.dart';
import '../core/repositories/repositories.dart';
import '../core/utils/error_handler.dart';
import '../core/utils/image_compression.dart';

class PhotoGalleryScreen extends StatefulWidget {
  final Pet pet;

  const PhotoGalleryScreen({super.key, required this.pet});

  @override
  State<PhotoGalleryScreen> createState() => _PhotoGalleryScreenState();
}

class _PhotoGalleryScreenState extends State<PhotoGalleryScreen> {
  final _searchController = TextEditingController();
  
  List<Photo> _photos = [];
  List<Photo> _filteredPhotos = [];
  bool _isLoading = true;
  bool _isGridView = true;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadPhotos();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadPhotos() async {
    try {
      setState(() => _isLoading = true);
      
      // TODO: Implement photo repository
      // For now, create some mock data
      await Future.delayed(Duration(seconds: 1));
      
      setState(() {
        _photos = [];
        _filteredPhotos = [];
        _isLoading = false;
      });
    } catch (e) {
      AppErrorHandler.showErrorSnackBar(
        context,
        'Failed to load photos: ${e.toString()}',
      );
      setState(() => _isLoading = false);
    }
  }

  void _filterPhotos(String query) {
    setState(() {
      _searchQuery = query;
      if (query.isEmpty) {
        _filteredPhotos = _photos;
      } else {
        _filteredPhotos = _photos.where((photo) =>
          photo.caption?.toLowerCase().contains(query.toLowerCase()) ?? false
        ).toList();
      }
    });
  }

  String _generateId() {
    return 'photo-${DateTime.now().millisecondsSinceEpoch}-${Random().nextInt(1000)}';
  }

  Future<void> _addPhoto() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 80,
      );
      
      if (image != null) {
        final compressedFile = await ImageCompressionUtil.compressImageFromPath(
          image.path
        );
        
        final thumbnailFile = await ImageCompressionUtil.generateThumbnail(
          image.path
        );

        // Show caption dialog
        final caption = await _showCaptionDialog();
        
        // TODO: Save to database
        final newPhoto = Photo(
          id: _generateId(),
          userId: widget.pet.userId,
          petId: widget.pet.id,
          filePath: compressedFile.path,
          thumbnailPath: thumbnailFile.path,
          caption: caption,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        AppErrorHandler.showSuccessSnackBar(
          context,
          'Photo added successfully!',
        );
        
        // TODO: Refresh photos list
        _loadPhotos();
      }
    } catch (e) {
      AppErrorHandler.showErrorSnackBar(
        context,
        'Failed to add photo: ${e.toString()}',
      );
    }
  }

  Future<void> _takePhoto() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 80,
      );
      
      if (image != null) {
        final compressedFile = await ImageCompressionUtil.compressImageFromPath(
          image.path
        );
        
        final thumbnailFile = await ImageCompressionUtil.generateThumbnail(
          image.path
        );

        // Show caption dialog
        final caption = await _showCaptionDialog();
        
        // TODO: Save to database
        AppErrorHandler.showSuccessSnackBar(
          context,
          'Photo captured successfully!',
        );
        
        // TODO: Refresh photos list
        _loadPhotos();
      }
    } catch (e) {
      AppErrorHandler.showErrorSnackBar(
        context,
        'Failed to capture photo: ${e.toString()}',
      );
    }
  }

  Future<String?> _showCaptionDialog() async {
    final controller = TextEditingController();
    
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Add Caption'),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: 'Enter a caption for this photo...',
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, null),
            child: Text('Skip'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: Text('Add'),
          ),
        ],
      ),
    );
  }

  Future<void> _showPhotoOptions() async {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: AppSpacing.pageInsets,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Add Photo',
              style: AppTextStyles.h3,
            ),
            AppSpacing.vSpaceLg,
            
            Row(
              children: [
                Expanded(
                  child: AppButton.outlined(
                    text: 'Take Photo',
                    onPressed: () {
                      Navigator.pop(context);
                      _takePhoto();
                    },
                    icon: Icons.camera_alt,
                  ),
                ),
                AppSpacing.hSpaceMd,
                Expanded(
                  child: AppButton.primary(
                    text: 'From Gallery',
                    onPressed: () {
                      Navigator.pop(context);
                      _addPhoto();
                    },
                    icon: Icons.photo_library,
                  ),
                ),
              ],
            ),
            
            AppSpacing.vSpaceMd,
            
            AppButton.outlined(
              text: 'Cancel',
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          '${widget.pet.name} Photos',
          style: AppTextStyles.h2,
        ),
        
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(_isGridView ? Icons.view_list : Icons.grid_view),
            onPressed: () {
              setState(() => _isGridView = !_isGridView);
            },
          ),
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _loadPhotos,
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Container(
            color: Theme.of(context).colorScheme.surface,
            padding: AppSpacing.pageInsets.copyWith(top: 0),
            child: AppSearchBar(
              controller: _searchController,
              placeholder: 'Search photos...',
              onChanged: _filterPhotos,
              onClear: () {
                _searchController.clear();
                _filterPhotos('');
              },
            ),
          ),
          
          // Photo gallery
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredPhotos.isEmpty
                    ? _buildEmptyState()
                    : _buildPhotoGrid(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showPhotoOptions,
        backgroundColor: AppColors.primary,
        child: Icon(Icons.add_a_photo, color: AppColors.textOnPrimary),
      ),
    );
  }

  Widget _buildEmptyState() {
    if (_photos.isEmpty) {
      return EmptyPhotoGallery(onAddPhoto: _showPhotoOptions);
    } else {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 64,
              color: AppColors.textTertiary,
            ),
            AppSpacing.vSpaceMd,
            Text(
              'No photos found',
              style: AppTextStyles.h2,
            ),
            AppSpacing.vSpaceSm,
            Text(
              'Try a different search term',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            AppSpacing.vSpaceMd,
            AppButton.outlined(
              text: 'Clear Search',
              onPressed: () {
                _searchController.clear();
                _filterPhotos('');
              },
            ),
          ],
        ),
      );
    }
  }

  Widget _buildPhotoGrid() {
    if (_isGridView) {
      return GridView.builder(
        padding: AppSpacing.pageInsets,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: AppSpacing.md,
          mainAxisSpacing: AppSpacing.md,
          childAspectRatio: 1.0,
        ),
        itemCount: _filteredPhotos.length,
        itemBuilder: (context, index) {
          final photo = _filteredPhotos[index];
          return _buildPhotoGridItem(photo);
        },
      );
    } else {
      return ListView.builder(
        padding: AppSpacing.pageInsets,
        itemCount: _filteredPhotos.length,
        itemBuilder: (context, index) {
          final photo = _filteredPhotos[index];
          return _buildPhotoListItem(photo);
        },
      );
    }
  }

  Widget _buildPhotoGridItem(Photo photo) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: AppSpacing.borderRadiusMd,
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: AppSpacing.borderRadiusMd,
        child: Stack(
          children: [
            // Photo
            Container(
              width: double.infinity,
              height: double.infinity,
              color: Theme.of(context).colorScheme.surface,
              child: photo.thumbnailPath != null
                  ? Image.file(
                      File(photo.thumbnailPath!),
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return _buildPhotoPlaceholder();
                      },
                    )
                  : Image.file(
                      File(photo.filePath),
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return _buildPhotoPlaceholder();
                      },
                    ),
            ),
            
            // Caption overlay
            if (photo.caption != null)
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: EdgeInsets.all(AppSpacing.sm),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Theme.of(context).colorScheme.scrim.withOpacity(0.7),
                      ],
                    ),
                  ),
                  child: Text(
                    photo.caption!,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            
            // Tap overlay
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => _viewPhoto(photo),
                child: Container(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPhotoListItem(Photo photo) {
    return Container(
      margin: EdgeInsets.only(bottom: AppSpacing.md),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: AppSpacing.borderRadiusMd,
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _viewPhoto(photo),
          borderRadius: AppSpacing.borderRadiusMd,
          child: Padding(
            padding: AppSpacing.cardInsets,
            child: Row(
              children: [
                // Thumbnail
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    borderRadius: AppSpacing.borderRadiusSm,
                    color: Theme.of(context).scaffoldBackgroundColor,
                  ),
                  child: ClipRRect(
                    borderRadius: AppSpacing.borderRadiusSm,
                    child: photo.thumbnailPath != null
                        ? Image.file(
                            File(photo.thumbnailPath!),
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return _buildPhotoPlaceholder();
                            },
                          )
                        : Image.file(
                            File(photo.filePath),
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return _buildPhotoPlaceholder();
                            },
                          ),
                  ),
                ),
                
                AppSpacing.hSpaceMd,
                
                // Photo info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        photo.caption ?? 'Photo',
                        style: AppTextStyles.h4,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      
                      AppSpacing.vSpaceXs,
                      
                      Text(
                        '${photo.createdAt.day}/${photo.createdAt.month}/${photo.createdAt.year}',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Actions
                IconButton(
                  icon: Icon(
                    Icons.more_vert,
                    color: AppColors.textSecondary,
                    size: 20,
                  ),
                  onPressed: () => _showPhotoMenu(photo),
                  padding: EdgeInsets.all(8),
                  constraints: BoxConstraints(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPhotoPlaceholder() {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: Icon(
        Icons.photo,
        color: AppColors.textTertiary,
        size: 32,
      ),
    );
  }

  void _viewPhoto(Photo photo) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => PhotoViewScreen(photo: photo),
      ),
    );
  }

  void _showPhotoMenu(Photo photo) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: AppSpacing.pageInsets,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.edit),
              title: Text('Edit Caption'),
              onTap: () {
                Navigator.pop(context);
                _editPhotoCaption(photo);
              },
            ),
            ListTile(
              leading: Icon(Icons.delete, color: AppColors.error),
              title: Text('Delete Photo'),
              onTap: () {
                Navigator.pop(context);
                _deletePhoto(photo);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _editPhotoCaption(Photo photo) {
    AppErrorHandler.showInfoSnackBar(
      context,
      'Edit caption functionality coming soon',
    );
  }

  void _deletePhoto(Photo photo) {
    AppErrorHandler.showInfoSnackBar(
      context,
      'Delete photo functionality coming soon',
    );
  }
}

class PhotoViewScreen extends StatelessWidget {
  final Photo photo;

  const PhotoViewScreen({super.key, required this.photo});

  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.scrim,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: Theme.of(context).colorScheme.onSurface),
      ),
      body: Center(
        child: InteractiveViewer(
          child: Image.file(
            File(photo.filePath),
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                color: Theme.of(context).scaffoldBackgroundColor,
                child: Icon(
                  Icons.broken_image,
                  color: AppColors.textTertiary,
                  size: 64,
                ),
              );
            },
          ),
        ),
      ),
      bottomNavigationBar: photo.caption != null
          ? Container(
              color: Theme.of(context).colorScheme.scrim.withOpacity(0.7),
              padding: AppSpacing.pageInsets,
              child: Text(
                photo.caption!,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
                textAlign: TextAlign.center,
              ),
            )
          : null,
    );
  }
}