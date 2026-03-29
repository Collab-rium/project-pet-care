import 'package:flutter/material.dart';
import 'dart:io';

import '../components/atoms/app_button.dart';
import '../components/molecules/app_search_bar.dart';
import '../components/organisms/loading_widgets.dart';
import '../components/organisms/empty_states.dart';
import '../core/constants/colors.dart';
import '../core/constants/spacing.dart';
import '../core/constants/text_styles.dart';
import '../core/models/models.dart';
import '../core/repositories/repositories.dart';
import '../core/utils/error_handler.dart';
import 'pet_profile_screen.dart';

class PetListScreen extends StatefulWidget {
  const PetListScreen({super.key});

  @override
  State<PetListScreen> createState() => _PetListScreenState();
}

class _PetListScreenState extends State<PetListScreen> {
  final _petRepository = PetRepository();
  final _searchController = TextEditingController();
  
  List<Pet> _pets = [];
  List<Pet> _filteredPets = [];
  bool _isLoading = true;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadPets();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadPets() async {
    try {
      setState(() => _isLoading = true);
      
      final pets = await _petRepository.getUserPets('user-1'); // TODO: Get from auth
      
      setState(() {
        _pets = pets;
        _filteredPets = pets;
        _isLoading = false;
      });
    } catch (e) {
      AppErrorHandler.showErrorSnackBar(
        context,
        'Failed to load pets: ${e.toString()}',
      );
      setState(() => _isLoading = false);
    }
  }

  void _filterPets(String query) {
    setState(() {
      _searchQuery = query;
      if (query.isEmpty) {
        _filteredPets = _pets;
      } else {
        _filteredPets = _pets.where((pet) =>
          pet.name.toLowerCase().contains(query.toLowerCase()) ||
          pet.species.toLowerCase().contains(query.toLowerCase()) ||
          (pet.breed?.toLowerCase().contains(query.toLowerCase()) ?? false)
        ).toList();
      }
    });
  }

  Future<void> _navigateToAddPet() async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const PetProfileScreen(),
      ),
    );
    
    if (result is Pet) {
      _loadPets(); // Refresh the list
    }
  }

  Future<void> _navigateToEditPet(Pet pet) async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => PetProfileScreen(
          pet: pet,
          isEditing: true,
        ),
      ),
    );
    
    if (result != null) {
      _loadPets(); // Refresh the list
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'My Pets',
          style: AppTextStyles.h1,
        ),
        backgroundColor: AppColors.surface,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _loadPets,
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Container(
            color: AppColors.surface,
            padding: AppSpacing.pageInsets.copyWith(top: 0),
            child: AppSearchBar(
              controller: _searchController,
              placeholder: 'Search pets...',
              onChanged: _filterPets,
              onClear: () {
                _searchController.clear();
                _filterPets('');
              },
            ),
          ),
          
          // Pet list
          Expanded(
            child: _isLoading
                ? const PetListLoadingSkeleton()
                : _filteredPets.isEmpty
                    ? _buildEmptyState()
                    : _buildPetList(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToAddPet,
        backgroundColor: AppColors.primary,
        child: Icon(Icons.add, color: AppColors.onPrimary),
      ),
    );
  }

  Widget _buildEmptyState() {
    if (_pets.isEmpty) {
      return EmptyPetList(onAddPet: _navigateToAddPet);
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
              'No pets found',
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
                _filterPets('');
              },
            ),
          ],
        ),
      );
    }
  }

  Widget _buildPetList() {
    return ListView.builder(
      padding: AppSpacing.pageInsets,
      itemCount: _filteredPets.length,
      itemBuilder: (context, index) {
        final pet = _filteredPets[index];
        return _buildPetCard(pet);
      },
    );
  }

  Widget _buildPetCard(Pet pet) {
    return Container(
      margin: EdgeInsets.only(bottom: AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
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
          onTap: () => _navigateToEditPet(pet),
          borderRadius: AppSpacing.borderRadiusMd,
          child: Padding(
            padding: AppSpacing.cardInsets,
            child: Row(
              children: [
                // Pet photo
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.background,
                    border: Border.all(
                      color: AppColors.border,
                      width: 1,
                    ),
                  ),
                  child: ClipOval(
                    child: pet.photoUrl != null
                        ? Image.file(
                            File(pet.photoUrl!),
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return _buildPetAvatar(pet);
                            },
                          )
                        : _buildPetAvatar(pet),
                  ),
                ),
                
                AppSpacing.hSpaceMd,
                
                // Pet info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        pet.name,
                        style: AppTextStyles.h3,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      
                      AppSpacing.vSpaceXs,
                      
                      Text(
                        _buildPetSubtitle(pet),
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      
                      AppSpacing.vSpaceXs,
                      
                      Text(
                        pet.ageText,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textTertiary,
                        ),
                      ),
                      
                      if (pet.weight != null) ...[
                        AppSpacing.vSpaceXs,
                        Row(
                          children: [
                            Icon(
                              Icons.monitor_weight,
                              size: 14,
                              color: AppColors.textTertiary,
                            ),
                            SizedBox(width: 4),
                            Text(
                              '${pet.weight} kg',
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.textTertiary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                
                // Actions
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(
                        Icons.edit,
                        color: AppColors.primary,
                        size: 20,
                      ),
                      onPressed: () => _navigateToEditPet(pet),
                      padding: EdgeInsets.all(8),
                      constraints: BoxConstraints(),
                    ),
                    
                    Icon(
                      Icons.chevron_right,
                      color: AppColors.textTertiary,
                      size: 20,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPetAvatar(Pet pet) {
    return Container(
      width: 64,
      height: 64,
      color: AppColors.background,
      child: Icon(
        _getPetIcon(pet.species),
        size: 32,
        color: AppColors.textTertiary,
      ),
    );
  }

  IconData _getPetIcon(String species) {
    switch (species.toLowerCase()) {
      case 'dog':
        return Icons.pets;
      case 'cat':
        return Icons.pets;
      case 'bird':
        return Icons.flutter_dash;
      case 'fish':
        return Icons.tsunami;
      case 'rabbit':
        return Icons.cruelty_free;
      default:
        return Icons.pets;
    }
  }

  String _buildPetSubtitle(Pet pet) {
    final parts = <String>[];
    
    if (pet.breed != null && pet.breed!.isNotEmpty) {
      parts.add('${pet.breed} ${pet.species}');
    } else {
      parts.add(pet.species);
    }
    
    if (pet.gender != null) {
      parts.add(pet.gender!);
    }
    
    return parts.join(' • ');
  }
}