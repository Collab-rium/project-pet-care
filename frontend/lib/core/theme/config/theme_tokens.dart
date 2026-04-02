import 'package:flutter/material.dart';

/// Color palette for a theme mode (light or dark)
/// Contains all colors needed for the app UI
class ColorPalette {
  // Brand Colors
  final Color primary;
  final Color primaryLight;
  final Color primaryDark;
  final Color secondary;
  final Color secondaryLight;
  final Color secondaryDark;

  // Backgrounds & Surfaces
  final Color background;
  final Color surface;
  final Color surfaceVariant;

  // Text Colors
  final Color textPrimary;
  final Color textSecondary;
  final Color textTertiary;
  final Color textOnPrimary;

  // Semantic Colors
  final Color success;
  final Color warning;
  final Color error;
  final Color info;

  // Borders & Dividers
  final Color border;
  final Color divider;

  // Utility Colors
  final Color shadow;
  final Color overlay;

  // Category Colors (for expenses, reminders, etc.)
  final Color categoryFood;
  final Color categoryMedical;
  final Color categoryGrooming;
  final Color categoryToys;
  final Color categoryOther;

  const ColorPalette({
    required this.primary,
    required this.primaryLight,
    required this.primaryDark,
    required this.secondary,
    required this.secondaryLight,
    required this.secondaryDark,
    required this.background,
    required this.surface,
    required this.surfaceVariant,
    required this.textPrimary,
    required this.textSecondary,
    required this.textTertiary,
    required this.textOnPrimary,
    required this.success,
    required this.warning,
    required this.error,
    required this.info,
    required this.border,
    required this.divider,
    required this.shadow,
    required this.overlay,
    required this.categoryFood,
    required this.categoryMedical,
    required this.categoryGrooming,
    required this.categoryToys,
    required this.categoryOther,
  });
}

/// Typography configuration for a theme
/// Defines font families, sizes, weights, and spacing
class TypographyConfig {
  final String headingFontFamily;
  final String bodyFontFamily;

  // Font Sizes
  final double h1Size;
  final double h2Size;
  final double h3Size;
  final double h4Size;
  final double bodyLargeSize;
  final double bodyMediumSize;
  final double bodySmallSize;
  final double captionSize;
  final double labelSize;
  final double overlineSize;

  // Font Weights
  final FontWeight h1Weight;
  final FontWeight h2Weight;
  final FontWeight h3Weight;
  final FontWeight h4Weight;
  final FontWeight bodyWeight;
  final FontWeight buttonWeight;
  final FontWeight labelWeight;

  // Letter Spacing
  final double h1LetterSpacing;
  final double h2LetterSpacing;
  final double h3LetterSpacing;
  final double h4LetterSpacing;
  final double buttonLetterSpacing;
  final double captionLetterSpacing;
  final double labelLetterSpacing;
  final double overlineLetterSpacing;

  // Line Height
  final double bodyLineHeight;
  final double captionLineHeight;

  const TypographyConfig({
    this.headingFontFamily = 'Poppins',
    this.bodyFontFamily = 'Inter',
    this.h1Size = 32.0,
    this.h2Size = 28.0,
    this.h3Size = 20.0,
    this.h4Size = 18.0,
    this.bodyLargeSize = 16.0,
    this.bodyMediumSize = 14.0,
    this.bodySmallSize = 12.0,
    this.captionSize = 12.0,
    this.labelSize = 14.0,
    this.overlineSize = 10.0,
    this.h1Weight = FontWeight.w700,
    this.h2Weight = FontWeight.w600,
    this.h3Weight = FontWeight.w600,
    this.h4Weight = FontWeight.w600,
    this.bodyWeight = FontWeight.w400,
    this.buttonWeight = FontWeight.w500,
    this.labelWeight = FontWeight.w500,
    this.h1LetterSpacing = -0.5,
    this.h2LetterSpacing = -0.3,
    this.h3LetterSpacing = -0.2,
    this.h4LetterSpacing = 0.0,
    this.buttonLetterSpacing = 0.5,
    this.captionLetterSpacing = 0.3,
    this.labelLetterSpacing = 0.1,
    this.overlineLetterSpacing = 1.5,
    this.bodyLineHeight = 1.5,
    this.captionLineHeight = 1.4,
  });
}

/// Spacing configuration for a theme
/// Uses 8px base unit for consistency
class SpacingConfig {
  // Base unit (8px)
  final double base;

  // Spacing scale
  final double xs;
  final double sm;
  final double md;
  final double lg;
  final double xl;
  final double xxl;

  // Border radius
  final double radiusXs;
  final double radiusSm;
  final double radiusMd;
  final double radiusLg;
  final double radiusXl;

  // Elevation
  final double elevationSm;
  final double elevationMd;
  final double elevationLg;

  const SpacingConfig({
    this.base = 8.0,
    this.xs = 4.0,
    this.sm = 8.0,
    this.md = 16.0,
    this.lg = 24.0,
    this.xl = 32.0,
    this.xxl = 48.0,
    this.radiusXs = 4.0,
    this.radiusSm = 8.0,
    this.radiusMd = 12.0,
    this.radiusLg = 16.0,
    this.radiusXl = 24.0,
    this.elevationSm = 2.0,
    this.elevationMd = 4.0,
    this.elevationLg = 8.0,
  });

  /// Default spacing config (8px base)
  static const SpacingConfig defaults = SpacingConfig();
}

/// Preview colors for theme selector UI
class ThemePreview {
  final Color primaryColor;
  final Color secondaryColor;
  final Color backgroundColor;
  final Color surfaceColor;

  const ThemePreview({
    required this.primaryColor,
    required this.secondaryColor,
    required this.backgroundColor,
    this.surfaceColor = Colors.white,
  });
}
