import 'package:flutter/material.dart';

/// App color palette - Warm theme
/// Primary: Orange #FF8C42
/// Focus on warmth and approachability for pet care
class AppColors {
  // Brand Colors - Warm Palette
  static const Color primary = Color(0xFFFF8C42); // Orange
  static const Color primaryLight = Color(0xFFFFB380); // Light orange
  static const Color primaryDark = Color(0xFFE67832); // Dark orange

  static const Color secondary = Color(0xFFFFB380); // Light orange/peach
  static const Color secondaryLight = Color(0xFFFFD4B0);
  static const Color secondaryDark = Color(0xFFFF9D5C);
  
  // Accent Colors - for variety and categories
  static const Color accent1 = Color(0xFF9C27B0); // Purple
  static const Color accent2 = Color(0xFFE91E63); // Pink
  static const Color accent3 = Color(0xFF2196F3); // Blue
  static const Color accent = accent1; // Default accent uses primary orange-red

  // Background Colors
  static const Color background = Color(0xFFFFF9F5); // Warm white
  static const Color surface = Color(0xFFFFFFFF); // Pure white
  static const Color surfaceVariant = Color(0xFFFFF4ED); // Very light orange

  // Text Colors
  static const Color textPrimary = Color(0xFF2C2C2C); // Dark gray
  static const Color textSecondary = Color(0xFF6B6B6B); // Medium gray
  static const Color textTertiary = Color(0xFF9E9E9E); // Light gray
  static const Color textOnPrimary = Color(0xFFFFFFFF); // White on orange

  // Status Colors
  static const Color success = Color(0xFF52B788); // Green
  static const Color successLight = Color(0xFF74C69D);
  static const Color warning = Color(0xFFF4A261); // Warm yellow/orange
  static const Color warningLight = Color(0xFFF8B982);
  static const Color error = Color(0xFFE63946); // Red
  static const Color errorLight = Color(0xFFFF6B6B);
  static const Color info = Color(0xFF4A90E2); // Blue
  static const Color infoLight = Color(0xFF6BA5E7);

  // Reminder Status Colors
  static const Color completed = Color(0xFF52B788); // Green
  static const Color pending = Color(0xFF4A90E2); // Blue
  static const Color overdue = Color(0xFFE63946); // Red

  // Border & Divider Colors
  static const Color border = Color(0xFFE0E0E0);
  static const Color borderLight = Color(0xFFF0F0F0);
  static const Color divider = Color(0xFFEEEEEE);

  // Shadow Colors
  static const Color shadow = Color(0x1A000000); // 10% black
  static const Color shadowLight = Color(0x0D000000); // 5% black

  // Dark Mode Colors (for when dark mode is enabled)
  static const Color darkBackground = Color(0xFF1A1A1A);
  static const Color darkSurface = Color(0xFF2C2C2C);
  static const Color darkSurfaceVariant = Color(0xFF3A3A3A);
  static const Color darkTextPrimary = Color(0xFFE8E8E8);
  static const Color darkTextSecondary = Color(0xFFB8B8B8);
  static const Color darkBorder = Color(0xFF404040);
  static const Color darkDivider = Color(0xFF333333);

  // Opacity variants (useful for overlays)
  static Color withOpacity(Color color, double opacity) {
    return color.withOpacity(opacity);
  }

  // Gradient definitions
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, primaryLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient surfaceGradient = LinearGradient(
    colors: [surface, surfaceVariant],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}
