import 'package:flutter/material.dart';
import '../theme_config.dart';
import '../theme_tokens.dart';

/// "Cool Blue" theme
/// Professional and calming theme with blue tones
/// Clean and modern aesthetic
class CoolThemeConfig extends ThemeConfig {
  @override
  String get id => 'cool';

  @override
  String get name => 'Cool Blue';

  @override
  String get description => 'Professional and calming theme with cool blue tones';

  @override
  ColorPalette get lightColors => const ColorPalette(
        // Brand Colors - Cool blue palette
        primary: Color(0xFF2196F3), // Material blue
        primaryLight: Color(0xFF64B5F6), // Light blue
        primaryDark: Color(0xFF1976D2), // Dark blue
        secondary: Color(0xFF00BCD4), // Cyan
        secondaryLight: Color(0xFF4DD0E1), // Light cyan
        secondaryDark: Color(0xFF0097A7), // Dark cyan

        // Backgrounds & Surfaces
        background: Color(0xFFF5F9FC), // Cool white with blue tint
        surface: Color(0xFFFFFFFF), // Pure white
        surfaceVariant: Color(0xFFE3F2FD), // Very light blue

        // Text Colors
        textPrimary: Color(0xFF263238), // Blue-gray dark
        textSecondary: Color(0xFF546E7A), // Blue-gray medium
        textTertiary: Color(0xFF90A4AE), // Blue-gray light
        textOnPrimary: Color(0xFFFFFFFF), // White on blue

        // Semantic Colors
        success: Color(0xFF4CAF50), // Green
        warning: Color(0xFFFFA726), // Orange
        error: Color(0xFFEF5350), // Red
        info: Color(0xFF42A5F5), // Light blue

        // Borders & Dividers
        border: Color(0xFFCFD8DC), // Blue-gray border
        divider: Color(0xFFECEFF1), // Very light blue-gray

        // Utility Colors
        shadow: Color(0x1A000000), // 10% black
        overlay: Color(0x80000000), // 50% black

        // Category Colors
        categoryFood: Color(0xFFEF5350), // Red
        categoryMedical: Color(0xFF42A5F5), // Blue (theme color)
        categoryGrooming: Color(0xFF9575CD), // Purple
        categoryToys: Color(0xFF4DB6AC), // Teal
        categoryOther: Color(0xFF78909C), // Blue-gray
      );

  @override
  ColorPalette get darkColors => const ColorPalette(
        // Brand Colors
        primary: Color(0xFF2196F3), // Keep blue
        primaryLight: Color(0xFF64B5F6), // Light blue
        primaryDark: Color(0xFF1565C0), // Darker blue
        secondary: Color(0xFF00ACC1), // Darker cyan
        secondaryLight: Color(0xFF26C6DA), // Medium cyan
        secondaryDark: Color(0xFF00838F), // Dark cyan

        // Backgrounds & Surfaces
        background: Color(0xFF121212), // True dark
        surface: Color(0xFF1E1E1E), // Dark surface
        surfaceVariant: Color(0xFF263238), // Blue-black

        // Text Colors
        textPrimary: Color(0xFFECEFF1), // Light blue-gray
        textSecondary: Color(0xFFB0BEC5), // Medium blue-gray
        textTertiary: Color(0xFF78909C), // Dark blue-gray
        textOnPrimary: Color(0xFFFFFFFF), // White

        // Semantic Colors
        success: Color(0xFF4CAF50), // Green
        warning: Color(0xFFFFA726), // Orange
        error: Color(0xFFEF5350), // Red
        info: Color(0xFF42A5F5), // Light blue

        // Borders & Dividers
        border: Color(0xFF37474F), // Dark blue-gray
        divider: Color(0xFF263238), // Darker blue-gray

        // Utility Colors
        shadow: Color(0x33000000), // 20% black
        overlay: Color(0x80000000), // 50% black

        // Category Colors
        categoryFood: Color(0xFFEF5350), // Red
        categoryMedical: Color(0xFF42A5F5), // Blue
        categoryGrooming: Color(0xFF9575CD), // Purple
        categoryToys: Color(0xFF4DB6AC), // Teal
        categoryOther: Color(0xFF78909C), // Blue-gray
      );

  @override
  ThemePreview get preview => const ThemePreview(
        primaryColor: Color(0xFF2196F3),
        secondaryColor: Color(0xFF00BCD4),
        backgroundColor: Color(0xFFF5F9FC),
      );
}
