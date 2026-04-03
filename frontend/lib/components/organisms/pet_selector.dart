import 'package:flutter/material.dart';

import '../core/constants/colors.dart';
import '../core/constants/spacing.dart';
import '../core/constants/text_styles.dart';
import '../core/models/models.dart';
import '../core/repositories/repositories.dart';
import '../core/utils/error_handler.dart';

class PetSelector extends StatefulWidget {
  final Pet? selectedPet;
  final Function(Pet?) onPetSelected;
  final bool includeAllPets;

  const PetSelector({
    super.key,
    this.selectedPet,
    required this.onPetSelected,
    this.includeAllPets = false,
  });

  @override
  State<PetSelector> createState() => _PetSelectorState();
}

class _PetSelectorState extends State<PetSelector> {
  final _petRepository = PetRepository();
  List<Pet> _pets = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPets();
  }

  Future<void> _loadPets() async {
    try {
      final pets = await _petRepository.getUserPets('user-1');
      setState(() {
        _pets = pets;
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

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Container(
        height: 48,
        child: Center(
          child: SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      );
    }

    if (_pets.isEmpty) {
      return Container(
        padding: AppSpacing.cardInsets,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: AppSpacing.borderRadiusSm,
          border: Border.all(color: AppColors.border),
        ),
        child: Text(
          'No pets available',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      );
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: AppSpacing.borderRadiusSm,
        border: Border.all(color: AppColors.border),
      ),
      child: DropdownButton<Pet?>(
        value: widget.selectedPet,
        isExpanded: true,
        underline: SizedBox.shrink(),
        hint: Text(
          'Select a pet',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        items: [
          if (widget.includeAllPets)
            DropdownMenuItem<Pet?>(
              value: null,
              child: Text(
                'All Pets',
                style: AppTextStyles.bodyMedium,
              ),
            ),
          ..._pets.map((pet) => DropdownMenuItem<Pet?>(
            value: pet,
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: AppSpacing.borderRadiusFull,
                  ),
                  child: Icon(
                    _getPetIcon(pet.species),
                    color: AppColors.primary,
                    size: 16,
                  ),
                ),
                AppSpacing.hSpaceSm,
                Text(
                  pet.name,
                  style: AppTextStyles.bodyMedium,
                ),
              ],
            ),
          )),
        ],
        onChanged: widget.onPetSelected,
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
}

class PetContextProvider extends ChangeNotifier {
  Pet? _selectedPet;
  List<Pet> _pets = [];

  Pet? get selectedPet => _selectedPet;
  List<Pet> get pets => _pets;

  void setPets(List<Pet> pets) {
    _pets = pets;
    if (_selectedPet != null && !pets.any((p) => p.id == _selectedPet!.id)) {
      _selectedPet = null;
    }
    notifyListeners();
  }

  void selectPet(Pet? pet) {
    _selectedPet = pet;
    notifyListeners();
  }

  void clearSelection() {
    _selectedPet = null;
    notifyListeners();
  }
}

// Widget for showing current pet context at the top of screens
class CurrentPetHeader extends StatelessWidget {
  final Pet? selectedPet;
  final VoidCallback? onTap;

  const CurrentPetHeader({
    super.key,
    this.selectedPet,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    if (selectedPet == null) return SizedBox.shrink();

    return Container(
      color: AppColors.primary.withOpacity(0.1),
      padding: AppSpacing.pageInsets.copyWith(
        top: AppSpacing.sm,
        bottom: AppSpacing.sm,
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.2),
              borderRadius: AppSpacing.borderRadiusFull,
            ),
            child: Icon(
              _getPetIcon(selectedPet!.species),
              color: AppColors.primary,
              size: 20,
            ),
          ),
          AppSpacing.hSpaceMd,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Viewing data for',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                Text(
                  selectedPet!.name,
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
          if (onTap != null)
            GestureDetector(
              onTap: onTap,
              child: Container(
                padding: EdgeInsets.all(AppSpacing.sm),
                child: Icon(
                  Icons.swap_horiz,
                  color: AppColors.primary,
                  size: 20,
                ),
              ),
            ),
        ],
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
}