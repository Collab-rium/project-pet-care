import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/constants/colors.dart';
import '../core/constants/spacing.dart';
import '../core/constants/text_styles.dart';
import '../core/theme/theme_manager.dart';
import '../core/utils/error_handler.dart';

class ThemeSelectorScreen extends StatefulWidget {
  const ThemeSelectorScreen({super.key});

  @override
  State<ThemeSelectorScreen> createState() => _ThemeSelectorScreenState();
}

class _ThemeSelectorScreenState extends State<ThemeSelectorScreen> {
  @override
  Widget build(BuildContext context) {
    final themeManager = context.watch<ThemeManager>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Choose Theme',
          style: AppTextStyles.h2,
        ),
        backgroundColor: AppColors.surface,
        elevation: 0,
      ),
      body: ListView(
        padding: AppSpacing.pageInsets,
        children: [
          Text(
            'Select your preferred color theme. You can change this anytime.',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),

          AppSpacing.vSpaceLg,

          ...AppTheme.values.map((theme) {
            final isSelected = themeManager.currentTheme == theme;
            return _buildThemeOption(theme, isSelected);
          }),

          AppSpacing.vSpaceXl,

          // Dark mode toggle
          Container(
            padding: AppSpacing.cardInsets,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: AppSpacing.borderRadiusMd,
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                Icon(
                  themeManager.isDarkMode ? Icons.dark_mode : Icons.light_mode,
                  color: AppColors.primary,
                ),
                AppSpacing.hSpaceMd,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Dark Mode',
                        style: AppTextStyles.h4,
                      ),
                      Text(
                        themeManager.isDarkMode ? 'Enabled' : 'Disabled',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: themeManager.isDarkMode,
                  onChanged: (value) {
                    themeManager.setThemeMode(
                      value ? ThemeMode.dark : ThemeMode.light,
                    );
                  },
                  activeColor: AppColors.primary,
                ),
              ],
            ),
          ),

          AppSpacing.vSpaceLg,

          // Preview section
          Container(
            padding: AppSpacing.cardInsets,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: AppSpacing.borderRadiusMd,
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Preview',
                  style: AppTextStyles.h3,
                ),
                AppSpacing.vSpaceMd,
                _buildPreview(themeManager),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildThemeOption(AppTheme theme, bool isSelected) {
    return Container(
      margin: EdgeInsets.only(bottom: AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppSpacing.borderRadiusMd,
        border: Border.all(
          color: isSelected ? AppColors.primary : AppColors.border,
          width: isSelected ? 2 : 1,
        ),
      ),
      child: InkWell(
        onTap: () {
          context.read<ThemeManager>().setTheme(theme);
        },
        borderRadius: AppSpacing.borderRadiusMd,
        child: Padding(
          padding: AppSpacing.cardInsets,
          child: Row(
            children: [
              // Color preview
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  borderRadius: AppSpacing.borderRadiusSm,
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: theme.primaryColor,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(AppSpacing.radiusSm),
                            bottomLeft: Radius.circular(AppSpacing.radiusSm),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Color.lerp(
                              theme.primaryColor, Colors.white, 0.3)!,
                          borderRadius: BorderRadius.only(
                            topRight: Radius.circular(AppSpacing.radiusSm),
                            bottomRight: Radius.circular(AppSpacing.radiusSm),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              AppSpacing.hSpaceMd,

              // Theme details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      theme.name,
                      style: AppTextStyles.h4.copyWith(
                        color: isSelected ? AppColors.primary : null,
                      ),
                    ),
                    AppSpacing.vSpaceXs,
                    Text(
                      _getThemeDescription(theme),
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),

              AppSpacing.hSpaceMd,

              // Selection indicator
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected ? AppColors.primary : AppColors.border,
                    width: 2,
                  ),
                  color: isSelected ? AppColors.primary : Colors.transparent,
                ),
                child: isSelected
                    ? Icon(
                        Icons.check,
                        color: Colors.white,
                        size: 16,
                      )
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getThemeDescription(AppTheme theme) {
    switch (theme) {
      case AppTheme.warmOrange:
        return 'Vibrant orange theme with warm, friendly colors';
      case AppTheme.coolBlue:
        return 'Professional blue theme with clean aesthetics';
      case AppTheme.freshGreen:
        return 'Natural green theme inspired by nature';
      case AppTheme.purpleDream:
        return 'Elegant purple theme with modern vibes';
      case AppTheme.sunsetPink:
        return 'Playful pink theme with sunset warmth';
    }
  }

  Widget _buildPreview(ThemeManager themeManager) {
    final theme = themeManager.isDarkMode
        ? themeManager.getDarkTheme()
        : themeManager.getLightTheme();

    return Theme(
      data: theme,
      child: Builder(
        builder: (context) => Column(
          children: [
            // Sample app bar
            Container(
              padding: AppSpacing.cardInsets,
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: AppSpacing.borderRadiusSm,
                border: Border.all(color: theme.colorScheme.outline),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.pets,
                    color: theme.primaryColor,
                  ),
                  AppSpacing.hSpaceSm,
                  Text(
                    'Pet Care App',
                    style: AppTextStyles.h4.copyWith(
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  Spacer(),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                      vertical: AppSpacing.xs,
                    ),
                    decoration: BoxDecoration(
                      color: theme.primaryColor,
                      borderRadius: AppSpacing.borderRadiusSm,
                    ),
                    child: Text(
                      'Primary',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: theme.colorScheme.onPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            AppSpacing.vSpaceSm,

            // Sample buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {},
                    child: Text('Button'),
                  ),
                ),
                AppSpacing.hSpaceSm,
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {},
                    child: Text('Button'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
