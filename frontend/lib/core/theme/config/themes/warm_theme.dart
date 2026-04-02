import 'package:flutter/material.dart';
import '../theme_config.dart';
import '../theme_tokens.dart';

/// Default "Warm Orange" theme
/// Friendly and energetic theme with warm orange tones
/// Perfect for pet care - approachable and playful
class WarmThemeConfig extends ThemeConfig {
  @override
  String get id => 'warm';

  @override
  String get name => 'Warm Orange';

  @override
  String get description =>
      'Friendly and energetic theme with warm orange tones';

  @override
  ColorPalette get lightColors => const ColorPalette(
        // Brand Colors - Warm orange palette
        primary: Color(0xFFFF8C42), // Warm orange
        primaryLight: Color(0xFFFFB380), // Light peach
        primaryDark: Color(0xFFE67832), // Dark orange
        secondary: Color(0xFFFFB380), // Light peach (complementary)
        secondaryLight: Color(0xFFFFD4B0), // Very light peach
        secondaryDark: Color(0xFFFF9D5C), // Medium peach

        // Backgrounds & Surfaces
        background: Color(0xFFFFF9F5), // Warm white
        surface: Color(0xFFFFFFFF), // Pure white
        surfaceVariant: Color(0xFFFFF4ED), // Very light orange tint

        // Text Colors
        textPrimary: Color(0xFF2C2C2C), // Dark gray
        textSecondary: Color(0xFF6B6B6B), // Medium gray
        textTertiary: Color(0xFF9E9E9E), // Light gray
        textOnPrimary: Color(0xFFFFFFFF), // White on orange

        // Semantic Colors - Status indicators
        success: Color(0xFF52B788), // Green
        warning: Color(0xFFF4A261), // Warm yellow-orange
        error: Color(0xFFE63946), // Red
        info: Color(0xFF4A90E2), // Blue

        // Borders & Dividers
        border: Color(0xFFE0E0E0), // Light gray border
        divider: Color(0xFFEEEEEE), // Very light gray divider

        // Utility Colors
        shadow: Color(0x1A000000), // 10% black shadow
        overlay: Color(0x80000000), // 50% black overlay

        // Category Colors - For expenses, reminders, etc.
        categoryFood: Color(0xFFFF6B6B), // Red
        categoryMedical: Color(0xFF4ECDC4), // Teal
        categoryGrooming: Color(0xFFFFA07A), // Coral
        categoryToys: Color(0xFF95E1D3), // Mint
        categoryOther: Color(0xFFB39DDB), // Purple
      );

  @override
  ColorPalette get darkColors => const ColorPalette(
        // Brand Colors - Same primary, adjusted secondary for dark mode
        primary: Color(0xFFFF8C42), // Keep warm orange
        primaryLight: Color(0xFFFFB380), // Light peach
        primaryDark: Color(0xFFE67832), // Dark orange
        secondary: Color(0xFFE67929), // Darker peach for dark mode
        secondaryLight: Color(0xFFFF9D5C), // Medium peach
        secondaryDark: Color(0xFFD66820), // Even darker peach

        // Backgrounds & Surfaces
        background: Color(0xFF1A1A1A), // True black tint
        surface: Color(0xFF2C2C2C), // Light black
        surfaceVariant: Color(0xFF3A3A3A), // Lighter surface variant

        // Text Colors
        textPrimary: Color(0xFFE8E8E8), // Off-white
        textSecondary: Color(0xFFB8B8B8), // Light gray
        textTertiary: Color(0xFF808080), // Medium gray
        textOnPrimary: Color(0xFFFFFFFF), // White on orange

        // Semantic Colors - Same as light mode for consistency
        success: Color(0xFF52B788), // Green
        warning: Color(0xFFF4A261), // Warm yellow-orange
        error: Color(0xFFE63946), // Red
        info: Color(0xFF4A90E2), // Blue

        // Borders & Dividers
        border: Color(0xFF404040), // Dark gray border
        divider: Color(0xFF333333), // Darker divider

        // Utility Colors
        shadow: Color(0x33000000), // 20% black shadow (darker for dark mode)
        overlay: Color(0x80000000), // 50% black overlay

        // Category Colors - Same as light mode
        categoryFood: Color(0xFFFF6B6B), // Red
        categoryMedical: Color(0xFF4ECDC4), // Teal
        categoryGrooming: Color(0xFFFFA07A), // Coral
        categoryToys: Color(0xFF95E1D3), // Mint
        categoryOther: Color(0xFFB39DDB), // Purple
      );

  @override
  TypographyConfig get typography => const TypographyConfig(
        headingFontFamily: 'Poppins',
        bodyFontFamily: 'Inter',
      );

  @override
  ThemePreview get preview => const ThemePreview(
        primaryColor: Color(0xFFFF8C42),
        secondaryColor: Color(0xFFFFB380),
        backgroundColor: Color(0xFFFFF9F5),
        surfaceColor: Color(0xFFFFFFFF),
      );
}
