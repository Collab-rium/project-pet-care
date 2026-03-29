import 'package:flutter/material.dart';
import '../../components/atoms/app_button.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/spacing.dart';
import '../../core/constants/text_styles.dart';

/// Empty state for pet list
class EmptyPetList extends StatelessWidget {
  final VoidCallback? onAddPet;

  const EmptyPetList({super.key, this.onAddPet});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: AppSpacing.pageInsets,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.pets,
              size: 80,
              color: AppColors.textTertiary,
            ),
            AppSpacing.vSpaceLg,
            Text(
              'No Pets Yet',
              style: AppTextStyles.h2,
              textAlign: TextAlign.center,
            ),
            AppSpacing.vSpaceSm,
            Text(
              'Add your first furry friend to get started tracking their health and activities!',
              style: AppTextStyles.bodyLarge.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            if (onAddPet != null) ...[
              AppSpacing.vSpaceXl,
              AppButton.primary(
                text: 'Add Your First Pet',
                onPressed: onAddPet,
                icon: Icons.add,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Empty state for reminders
class EmptyRemindersList extends StatelessWidget {
  final VoidCallback? onAddReminder;

  const EmptyRemindersList({super.key, this.onAddReminder});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: AppSpacing.pageInsets,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.schedule,
              size: 80,
              color: AppColors.textTertiary,
            ),
            AppSpacing.vSpaceLg,
            Text(
              'No Reminders',
              style: AppTextStyles.h2,
              textAlign: TextAlign.center,
            ),
            AppSpacing.vSpaceSm,
            Text(
              'Set up reminders for feeding, medications, vet visits, and more to keep your pet healthy.',
              style: AppTextStyles.bodyLarge.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            if (onAddReminder != null) ...[
              AppSpacing.vSpaceXl,
              AppButton.primary(
                text: 'Create Reminder',
                onPressed: onAddReminder,
                icon: Icons.add_alarm,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Empty state for expenses
class EmptyExpensesList extends StatelessWidget {
  final VoidCallback? onAddExpense;

  const EmptyExpensesList({super.key, this.onAddExpense});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: AppSpacing.pageInsets,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.receipt_long,
              size: 80,
              color: AppColors.textTertiary,
            ),
            AppSpacing.vSpaceLg,
            Text(
              'No Expenses Recorded',
              style: AppTextStyles.h2,
              textAlign: TextAlign.center,
            ),
            AppSpacing.vSpaceSm,
            Text(
              'Start tracking your pet expenses to understand spending patterns and manage your budget.',
              style: AppTextStyles.bodyLarge.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            if (onAddExpense != null) ...[
              AppSpacing.vSpaceXl,
              AppButton.primary(
                text: 'Add First Expense',
                onPressed: onAddExpense,
                icon: Icons.add,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Empty state for weight tracking
class EmptyWeightList extends StatelessWidget {
  final VoidCallback? onAddWeight;

  const EmptyWeightList({super.key, this.onAddWeight});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: AppSpacing.pageInsets,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.monitor_weight,
              size: 80,
              color: AppColors.textTertiary,
            ),
            AppSpacing.vSpaceLg,
            Text(
              'No Weight Records',
              style: AppTextStyles.h2,
              textAlign: TextAlign.center,
            ),
            AppSpacing.vSpaceSm,
            Text(
              'Track your pet\'s weight over time to monitor their health and growth patterns.',
              style: AppTextStyles.bodyLarge.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            if (onAddWeight != null) ...[
              AppSpacing.vSpaceXl,
              AppButton.primary(
                text: 'Record Weight',
                onPressed: onAddWeight,
                icon: Icons.add,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Empty state for photo gallery
class EmptyPhotoGallery extends StatelessWidget {
  final VoidCallback? onAddPhoto;

  const EmptyPhotoGallery({super.key, this.onAddPhoto});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: AppSpacing.pageInsets,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.photo_library_outlined,
              size: 80,
              color: AppColors.textTertiary,
            ),
            AppSpacing.vSpaceLg,
            Text(
              'No Photos Yet',
              style: AppTextStyles.h2,
              textAlign: TextAlign.center,
            ),
            AppSpacing.vSpaceSm,
            Text(
              'Capture and save precious memories of your furry friend. Create a beautiful photo gallery!',
              style: AppTextStyles.bodyLarge.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            if (onAddPhoto != null) ...[
              AppSpacing.vSpaceXl,
              AppButton.primary(
                text: 'Add Photo',
                onPressed: onAddPhoto,
                icon: Icons.camera_alt,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Empty state for search results
class EmptySearchResults extends StatelessWidget {
  final String query;
  final VoidCallback? onClear;

  const EmptySearchResults({
    super.key,
    required this.query,
    this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: AppSpacing.pageInsets,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 80,
              color: AppColors.textTertiary,
            ),
            AppSpacing.vSpaceLg,
            Text(
              'No Results Found',
              style: AppTextStyles.h2,
              textAlign: TextAlign.center,
            ),
            AppSpacing.vSpaceSm,
            Text(
              'No results found for "$query". Try a different search term.',
              style: AppTextStyles.bodyLarge.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            if (onClear != null) ...[
              AppSpacing.vSpaceXl,
              AppButton.outlined(
                text: 'Clear Search',
                onPressed: onClear,
                icon: Icons.clear,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Generic empty state widget
class EmptyStateWidget extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final String? actionText;
  final VoidCallback? onAction;

  const EmptyStateWidget({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.actionText,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: AppSpacing.pageInsets,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 80,
              color: AppColors.textTertiary,
            ),
            AppSpacing.vSpaceLg,
            Text(
              title,
              style: AppTextStyles.h2,
              textAlign: TextAlign.center,
            ),
            AppSpacing.vSpaceSm,
            Text(
              message,
              style: AppTextStyles.bodyLarge.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            if (actionText != null && onAction != null) ...[
              AppSpacing.vSpaceXl,
              AppButton.primary(
                text: actionText!,
                onPressed: onAction,
                icon: Icons.add,
              ),
            ],
          ],
        ),
      ),
    );
  }
}