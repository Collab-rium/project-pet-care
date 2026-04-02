import 'package:flutter/material.dart';
import '../theme_config.dart';
import '../theme_tokens.dart';

/// "Nature Green" theme
/// Fresh and organic theme with green tones
/// Healthy and natural aesthetic
class NatureThemeConfig extends ThemeConfig {
  @override
  String get id => 'nature';

  @override
  String get name => 'Nature Green';

  @override
  String get description => 'Fresh and organic theme with natural green tones';

  @override
  ColorPalette get lightColors => const ColorPalette(
        // Brand Colors - Nature green palette
        primary: Color(0xFF4CAF50), // Material green
        primaryLight: Color(0xFF81C784), // Light green
        primaryDark: Color(0xFF388E3C), // Dark green
        secondary: Color(0xFF8BC34A), // Light green
        secondaryLight: Color(0xFFAED581), // Very light green
        secondaryDark: Color(0xFF689F38), // Medium green

        // Backgrounds & Surfaces
        background: Color(0xFFF1F8F4), // Very light green-white
        surface: Color(0xFFFFFFFF), // Pure white
        surfaceVariant: Color(0xFFE8F5E9), // Very light green

        // Text Colors
        textPrimary: Color(0xFF1B5E20), // Dark green
        textSecondary: Color(0xFF558B2F), // Medium green
        textTertiary: Color(0xFF9E9E9E), // Gray
        textOnPrimary: Color(0xFFFFFFFF), // White on green

        // Semantic Colors
        success: Color(0xFF66BB6A), // Green (theme color)
        warning: Color(0xFFFFB74D), // Orange
        error: Color(0xFFE57373), // Red
        info: Color(0xFF4FC3F7), // Light blue

        // Borders & Dividers
        border: Color(0xFFC8E6C9), // Light green border
        divider: Color(0xFFE0F2F1), // Very light teal

        // Utility Colors
        shadow: Color(0x1A000000), // 10% black
        overlay: Color(0x80000000), // 50% black

        // Category Colors
        categoryFood: Color(0xFFFF8A65), // Orange (food)
        categoryMedical: Color(0xFF66BB6A), // Green (health - theme)
        categoryGrooming: Color(0xFF7986CB), // Indigo
        categoryToys: Color(0xFFFFD54F), // Amber
        categoryOther: Color(0xFF90A4AE), // Blue-gray
      );

  @override
  ColorPalette get darkColors => const ColorPalette(
        // Brand Colors
        primary: Color(0xFF4CAF50), // Keep green
        primaryLight: Color(0xFF81C784), // Light green
        primaryDark: Color(0xFF2E7D32), // Darker green
        secondary: Color(0xFF7CB342), // Darker light green
        secondaryLight: Color(0xFF9CCC65), // Medium green
        secondaryDark: Color(0xFF558B2F), // Dark green

        // Backgrounds & Surfaces
        background: Color(0xFF121212), // True dark
        surface: Color(0xFF1E1E1E), // Dark surface
        surfaceVariant: Color(0xFF263238), // Dark blue-gray

        // Text Colors
        textPrimary: Color(0xFFC8E6C9), // Light green tint
        textSecondary: Color(0xFFA5D6A7), // Medium green tint
        textTertiary: Color(0xFF81C784), // Green-gray
        textOnPrimary: Color(0xFFFFFFFF), // White

        // Semantic Colors
        success: Color(0xFF66BB6A), // Green
        warning: Color(0xFFFFB74D), // Orange
        error: Color(0xFFE57373), // Red
        info: Color(0xFF4FC3F7), // Light blue

        // Borders & Dividers
        border: Color(0xFF2E7D32), // Dark green border
        divider: Color(0xFF1B5E20), // Darker green

        // Utility Colors
        shadow: Color(0x33000000), // 20% black
        overlay: Color(0x80000000), // 50% black

        // Category Colors
        categoryFood: Color(0xFFFF8A65), // Orange
        categoryMedical: Color(0xFF66BB6A), // Green
        categoryGrooming: Color(0xFF7986CB), // Indigo
        categoryToys: Color(0xFFFFD54F), // Amber
        categoryOther: Color(0xFF90A4AE), // Blue-gray
      );

  @override
  ThemePreview get preview => const ThemePreview(
        primaryColor: Color(0xFF4CAF50),
        secondaryColor: Color(0xFF8BC34A),
        backgroundColor: Color(0xFFF1F8F4),
      );
}
