import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'dart:math';

import '../components/atoms/app_button.dart';
import '../components/atoms/app_input.dart';
import '../components/atoms/app_dropdown.dart';
import '../components/molecules/app_form_field.dart';
import '../components/organisms/loading_widgets.dart';
import '../core/constants/colors.dart';
import '../core/constants/spacing.dart';
import '../core/constants/text_styles.dart';
import '../core/models/models.dart';
import '../core/repositories/repositories.dart';
import '../core/utils/error_handler.dart';
import '../core/utils/validators.dart';
import '../core/utils/image_compression.dart';

class PetProfileScreen extends StatefulWidget {
  final Pet? pet;
  final bool isEditing;

  const PetProfileScreen({
    super.key,
    this.pet,
    this.isEditing = false,
  });

  @override
  State<PetProfileScreen> createState() => _PetProfileScreenState();
}

class _PetProfileScreenState extends State<PetProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _petRepository = PetRepository();
  
  late TextEditingController _nameController;
  late TextEditingController _breedController;
  late TextEditingController _weightController;
  late TextEditingController _notesController;
  
  String _selectedSpecies = 'Dog';
  String _selectedGender = 'Male';
  DateTime? _birthDate;
  File? _selectedImage;
  String? _existingPhotoUrl;
  
  bool _isLoading = false;
  bool _showCustomSpecies = false;
  String? _customSpecies;

  final List<String> _commonSpecies = [
    'Dog',
    'Cat',
    'Bird',
    'Fish',
    'Rabbit',
    'Hamster',
    'Guinea Pig',
    'Reptile',
    'Other',
  ];

  final List<String> _genderOptions = ['Male', 'Female', 'Unknown'];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.pet?.name ?? '');
    _breedController = TextEditingController(text: widget.pet?.breed ?? '');
    _weightController = TextEditingController(
      text: widget.pet?.weight?.toString() ?? ''
    );
    _notesController = TextEditingController(text: widget.pet?.notes ?? '');
    
    if (widget.pet != null) {
      _selectedSpecies = widget.pet!.species;
      _selectedGender = widget.pet!.gender ?? 'Male';
      _birthDate = widget.pet!.birthDate;
      _existingPhotoUrl = widget.pet!.photoUrl;
      
      if (!_commonSpecies.contains(_selectedSpecies)) {
        _showCustomSpecies = true;
        _customSpecies = _selectedSpecies;
        _selectedSpecies = 'Other';
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _breedController.dispose();
    _weightController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
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
        setState(() {
          _selectedImage = compressedFile;
        });
      }
    } catch (e) {
      AppErrorHandler.showErrorSnackBar(
        context,
        'Failed to pick image: ${e.toString()}',
      );
    }
  }

  Future<void> _selectBirthDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _birthDate ?? DateTime.now().subtract(Duration(days: 365)),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    
    if (picked != null) {
      setState(() {
        _birthDate = picked;
      });
    }
  }

  String _generateId() {
    return 'pet-${DateTime.now().millisecondsSinceEpoch}-${Random().nextInt(1000)}';
  }

  Future<void> _savePet() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final species = _showCustomSpecies ? _customSpecies! : _selectedSpecies;
      final weight = _weightController.text.isNotEmpty 
          ? double.tryParse(_weightController.text) 
          : null;

      final now = DateTime.now();
      Pet petToSave;

      if (widget.pet != null) {
        // Update existing pet
        petToSave = widget.pet!.copyWith(
          name: _nameController.text.trim(),
          species: species,
          breed: _breedController.text.trim().isEmpty ? null : _breedController.text.trim(),
          birthDate: _birthDate,
          weight: weight,
          gender: _selectedGender,
          notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
          photoUrl: _selectedImage?.path ?? _existingPhotoUrl,
        );
        
        await _petRepository.updatePet(petToSave);
      } else {
        // Create new pet
        petToSave = Pet(
          id: _generateId(),
          userId: 'user-1', // TODO: Get from auth service
          name: _nameController.text.trim(),
          species: species,
          breed: _breedController.text.trim().isEmpty ? null : _breedController.text.trim(),
          birthDate: _birthDate,
          weight: weight,
          gender: _selectedGender,
          notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
          photoUrl: _selectedImage?.path,
          createdAt: now,
          updatedAt: now,
        );
        
        await _petRepository.createPet(petToSave);
      }

      if (mounted) {
        Navigator.of(context).pop(petToSave);
        AppErrorHandler.showSuccessSnackBar(
          context,
          widget.pet != null ? 'Pet updated successfully!' : 'Pet added successfully!',
        );
      }
    } catch (e) {
      AppErrorHandler.showErrorSnackBar(
        context,
        'Failed to save pet: ${e.toString()}',
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Widget _buildPhotoSection() {
    return Center(
      child: Column(
        children: [
          GestureDetector(
            onTap: _pickImage,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.surface,
                border: Border.all(
                  color: AppColors.border,
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.shadow,
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: ClipOval(
                child: _selectedImage != null
                    ? Image.file(
                        _selectedImage!,
                        fit: BoxFit.cover,
                        width: 120,
                        height: 120,
                      )
                    : _existingPhotoUrl != null
                        ? Image.file(
                            File(_existingPhotoUrl!),
                            fit: BoxFit.cover,
                            width: 120,
                            height: 120,
                            errorBuilder: (context, error, stackTrace) {
                              return _buildPhotoPlaceholder();
                            },
                          )
                        : _buildPhotoPlaceholder(),
              ),
            ),
          ),
          AppSpacing.vSpaceSm,
          Text(
            'Tap to ${_selectedImage != null || _existingPhotoUrl != null ? 'change' : 'add'} photo',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhotoPlaceholder() {
    return Container(
      width: 120,
      height: 120,
      color: AppColors.background,
      child: Icon(
        Icons.pets,
        size: 48,
        color: AppColors.textTertiary,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          widget.pet != null ? 'Edit Pet' : 'Add Pet',
          style: AppTextStyles.h2,
        ),
        backgroundColor: AppColors.surface,
        elevation: 0,
        actions: [
          if (widget.pet != null)
            IconButton(
              icon: Icon(Icons.delete, color: AppColors.error),
              onPressed: () async {
                final confirmed = await AppErrorHandler.showConfirmDialog(
                  context,
                  'Delete Pet',
                  'Are you sure you want to delete this pet? All associated data will be lost.',
                );
                
                if (confirmed == true) {
                  try {
                    await _petRepository.deletePet(widget.pet!.id);
                    if (mounted) {
                      Navigator.of(context).pop('deleted');
                      AppErrorHandler.showSuccessSnackBar(
                        context,
                        'Pet deleted successfully',
                      );
                    }
                  } catch (e) {
                    AppErrorHandler.showErrorSnackBar(
                      context,
                      'Failed to delete pet: ${e.toString()}',
                    );
                  }
                }
              },
            ),
        ],
      ),
      body: LoadingOverlay(
        isLoading: _isLoading,
        message: 'Saving pet...',
        child: Form(
          key: _formKey,
          child: ListView(
            padding: AppSpacing.pageInsets,
            children: [
              _buildPhotoSection(),
              AppSpacing.vSpaceLg,

              AppFormField(
                label: 'Pet Name',
                isRequired: true,
                child: AppInput(
                  controller: _nameController,
                  placeholder: 'Enter your pet\'s name',
                  validator: AppValidators.required,
                ),
              ),

              AppFormField(
                label: 'Species',
                isRequired: true,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppDropdown(
                      value: _selectedSpecies,
                      items: _commonSpecies,
                      onChanged: (value) {
                        setState(() {
                          _selectedSpecies = value ?? _selectedSpecies;
                          _showCustomSpecies = value == 'Other';
                        });
                      },
                    ),
                    if (_showCustomSpecies) ...[
                      AppSpacing.vSpaceSm,
                      AppInput(
                        placeholder: 'Specify species',
                        initialValue: _customSpecies,
                        validator: AppValidators.required,
                        onChanged: (value) => _customSpecies = value,
                      ),
                    ],
                  ],
                ),
              ),

              AppFormField(
                label: 'Breed',
                child: AppInput(
                  controller: _breedController,
                  placeholder: 'Enter breed (optional)',
                ),
              ),

              AppFormField(
                label: 'Gender',
                child: AppDropdown(
                  value: _selectedGender,
                  items: _genderOptions,
                  onChanged: (value) {
                    setState(() {
                      _selectedGender = value ?? _selectedGender;
                    });
                  },
                ),
              ),

              AppFormField(
                label: 'Birth Date',
                child: GestureDetector(
                  onTap: _selectBirthDate,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.sm + 4,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.border),
                      borderRadius: AppSpacing.borderRadiusSm,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _birthDate != null 
                              ? '${_birthDate!.day}/${_birthDate!.month}/${_birthDate!.year}'
                              : 'Select birth date',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: _birthDate != null 
                                ? AppColors.textPrimary
                                : AppColors.textSecondary,
                          ),
                        ),
                        Icon(
                          Icons.calendar_today,
                          color: AppColors.textSecondary,
                          size: 20,
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              AppFormField(
                label: 'Weight (kg)',
                child: AppInput(
                  controller: _weightController,
                  placeholder: 'Enter weight',
                  keyboardType: TextInputType.number,
                  validator: AppValidators.positiveNumber,
                ),
              ),

              AppFormField(
                label: 'Notes',
                child: AppInput(
                  controller: _notesController,
                  placeholder: 'Any additional notes about your pet...',
                  maxLines: 3,
                ),
              ),

              AppSpacing.vSpaceXl,
              
              AppButton.primary(
                text: widget.pet != null ? 'Update Pet' : 'Add Pet',
                onPressed: _savePet,
                isLoading: _isLoading,
              ),
              
              AppSpacing.vSpaceMd,
              
              AppButton.outlined(
                text: 'Cancel',
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}