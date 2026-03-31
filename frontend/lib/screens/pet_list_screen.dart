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

      final pets =
          await _petRepository.getUserPets('user-1'); // TODO: Get from auth

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
        _filteredPets = _pets
            .where((pet) =>
                pet.name.toLowerCase().contains(query.toLowerCase()) ||
                pet.species.toLowerCase().contains(query.toLowerCase()) ||
                (pet.breed?.toLowerCase().contains(query.toLowerCase()) ??
                    false))
            .toList();
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

  Future<void> _deletePet(Pet pet) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Pet'),
        content: Text('Are you sure you want to delete ${pet.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _petRepository.deletePet(pet.id);
        _loadPets(); // Refresh the list
        AppErrorHandler.showSuccessSnackBar(
          context,
          '${pet.name} deleted successfully',
        );
      } catch (e) {
        AppErrorHandler.showErrorSnackBar(
          context,
          'Failed to delete pet: ${e.toString()}',
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: Text(
          'My Pets',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        backgroundColor: Theme.of(context).colorScheme.surface,
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
            color: Theme.of(context).colorScheme.surface,
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
        child: Icon(Icons.add, color: AppColors.textOnPrimary),
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
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: () => _navigateToEditPet(pet),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Pet photo
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  border: Border.all(
                    color:
                        Theme.of(context).colorScheme.outline.withOpacity(0.3),
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

              const SizedBox(width: 12),

              // Pet info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      pet.name,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _buildPetSubtitle(pet),
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        fontSize: 13,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.cake,
                          size: 12,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          pet.ageText,
                          style: TextStyle(
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                            fontSize: 12,
                          ),
                        ),
                        if (pet.weight != null) ...[
                          const SizedBox(width: 12),
                          Icon(
                            Icons.monitor_weight,
                            size: 12,
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${pet.weight} kg',
                            style: TextStyle(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),

              // Actions
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.edit_outlined,
                      size: 20,
                    ),
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    onPressed: () => _navigateToEditPet(pet),
                    constraints:
                        const BoxConstraints(minWidth: 32, minHeight: 32),
                    padding: EdgeInsets.zero,
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.delete_outline,
                      size: 20,
                    ),
                    color: Theme.of(context).colorScheme.error,
                    onPressed: () => _deletePet(pet),
                    constraints:
                        const BoxConstraints(minWidth: 32, minHeight: 32),
                    padding: EdgeInsets.zero,
                  ),
                ],
              ),
            ],
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
