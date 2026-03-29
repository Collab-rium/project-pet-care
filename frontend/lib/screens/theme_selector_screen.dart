import 'package:flutter/material.dart';

import '../components/atoms/app_button.dart';
import '../core/constants/colors.dart';
import '../core/constants/spacing.dart';
import '../core/constants/text_styles.dart';
import '../core/utils/error_handler.dart';

class ThemeSelectorScreen extends StatefulWidget {
  const ThemeSelectorScreen({super.key});

  @override
  State<ThemeSelectorScreen> createState() => _ThemeSelectorScreenState();
}

class _ThemeSelectorScreenState extends State<ThemeSelectorScreen> {
  String _selectedTheme = 'warm';

  final Map<String, ThemeData> _themes = {
    'warm': _buildWarmTheme(),
    'clean': _buildCleanTheme(),
    'golden': _buildGoldenTheme(),
  };

  final Map<String, String> _themeNames = {
    'warm': 'Warm Orange',
    'clean': 'Clean Blue',
    'golden': 'Golden Companion',
  };

  final Map<String, String> _themeDescriptions = {
    'warm': 'Vibrant orange theme with warm, friendly colors',
    'clean': 'Professional blue theme with clean, modern aesthetics',
    'golden': 'Golden yellow with cyan accents for a premium feel',
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Choose Theme',
          style: AppTextStyles.h2,
        ),
        backgroundColor: AppColors.surface,
        elevation: 0,
        actions: [
          TextButton(
            onPressed: _saveTheme,
            child: Text(
              'Apply',
              style: TextStyle(color: AppColors.primary),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: AppSpacing.pageInsets,
        children: [
          Text(
            'Select your preferred color theme. You can change this anytime in settings.',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),

          AppSpacing.vSpaceLg,

          ..._themes.keys.map((themeKey) {
            final isSelected = _selectedTheme == themeKey;
            return _buildThemeOption(
              themeKey,
              _themeNames[themeKey]!,
              _themeDescriptions[themeKey]!,
              _themes[themeKey]!,
              isSelected,
            );
          }),

          AppSpacing.vSpaceXl,

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
                _buildPreview(_themes[_selectedTheme]!),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildThemeOption(
    String themeKey,
    String name,
    String description,
    ThemeData theme,
    bool isSelected,
  ) {
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
        onTap: () => setState(() => _selectedTheme = themeKey),
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
                          color: theme.colorScheme.secondary,
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
                      name,
                      style: AppTextStyles.h4.copyWith(
                        color: isSelected ? AppColors.primary : null,
                      ),
                    ),
                    AppSpacing.vSpaceXs,
                    Text(
                      description,
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

  Widget _buildPreview(ThemeData theme) {
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

            // Sample card
            Container(
              padding: AppSpacing.cardInsets,
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: AppSpacing.borderRadiusSm,
                border: Border.all(color: theme.colorScheme.outline),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: theme.colorScheme.secondary,
                        radius: 16,
                        child: Icon(
                          Icons.pets,
                          color: theme.colorScheme.onSecondary,
                          size: 16,
                        ),
                      ),
                      AppSpacing.hSpaceSm,
                      Text(
                        'Sample Pet Card',
                        style: AppTextStyles.h4.copyWith(
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                  AppSpacing.vSpaceSm,
                  Text(
                    'This is how your content will look with the selected theme.',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _saveTheme() {
    // Here you would normally save to SharedPreferences
    // For now, just show success message
    AppErrorHandler.showSuccessSnackBar(
      context,
      'Theme "${_themeNames[_selectedTheme]}" applied successfully!',
    );
    Navigator.of(context).pop();
  }

  static ThemeData _buildWarmTheme() {
    const primaryColor = Color(0xFFFF8C42);
    const secondaryColor = Color(0xFFFF6B35);
    
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        brightness: Brightness.light,
      ).copyWith(
        primary: primaryColor,
        secondary: secondaryColor,
      ),
    );
  }

  static ThemeData _buildCleanTheme() {
    const primaryColor = Color(0xFF2196F3);
    const secondaryColor = Color(0xFF03DAC6);
    
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        brightness: Brightness.light,
      ).copyWith(
        primary: primaryColor,
        secondary: secondaryColor,
      ),
    );
  }

  static ThemeData _buildGoldenTheme() {
    const primaryColor = Color(0xFFFFB74D);
    const secondaryColor = Color(0xFF4DD0E1);
    
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        brightness: Brightness.light,
      ).copyWith(
        primary: primaryColor,
        secondary: secondaryColor,
      ),
    );
  }
}