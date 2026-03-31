import 'package:flutter/material.dart';

/// ============================================================================
/// UNIFIED STYLING CONFIG - SINGLE SOURCE OF TRUTH
/// ============================================================================
///
/// HOW TO USE THIS FILE:
///
/// 1. TO CHANGE PRIMARY COLOR: Find "PRIMARY COLOR" section below and change
///    the color value (e.g., Color(0xFFFF8C42) for orange)
///
/// 2. TO CHANGE DARK MODE COLORS: Find "DARK MODE COLORS" section
///
/// 3. TO CHANGE TEXT SIZES: Find "TEXT STYLES" section
///
/// 4. TO CHANGE SPACING: Find "SPACING" section
///
/// COLOR FORMAT: Use Color(0xFFRRGGBB) where:
/// - FF = full opacity
/// - RRGGBB = red, green, blue values in hex
/// - Example: Color(0xFFFF8C42) = orange
/// - Example: Color(0xFF2196F3) = blue
/// - Example: Color(0xFF4CAF50) = green
///
/// ============================================================================

class AppThemeConfig {
  // =========================================================================
  // PRIMARY COLOR - CHANGE THIS TO CHANGE THE MAIN APP COLOR
  // =========================================================================
  static const Color primaryColor = Color(0xFFFF8C42); // Orange
  // Other options you can try:
  // static const Color primaryColor = Color(0xFF2196F3); // Blue
  // static const Color primaryColor = Color(0xFF4CAF50); // Green
  // static const Color primaryColor = Color(0xFF9C27B0); // Purple
  // static const Color primaryColor = Color(0xFFE91E63); // Pink

  // =========================================================================
  // LIGHT MODE COLORS
  // =========================================================================
  static const Color lightBackground =
      Color(0xFFFFF9F5); // Warm white background
  static const Color lightSurface = Colors.white; // Card/surface color
  static const Color lightTextPrimary = Color(0xFF2C2C2C); // Main text color
  static const Color lightTextSecondary = Color(0xFF757575); // Secondary text
  static const Color lightTextTertiary = Color(0xFF9E9E9E); // Muted text
  static const Color lightBorder = Color(0xFFE0E0E0); // Border color
  static const Color lightDivider = Color(0xFFBDBDBD); // Divider color

  // =========================================================================
  // DARK MODE COLORS
  // =========================================================================
  static const Color darkBackground = Color(0xFF1A1A1A); // Dark background
  static const Color darkSurface = Color(0xFF2C2C2C); // Dark surface
  static const Color darkTextPrimary = Colors.white; // Main text color
  static const Color darkTextSecondary = Color(0xFFB0B0B0); // Secondary text
  static const Color darkTextTertiary = Color(0xFF808080); // Muted text
  static const Color darkBorder = Color(0xFF404040); // Border color
  static const Color darkDivider = Color(0xFF505050); // Divider color

  // =========================================================================
  // SEMANTIC COLORS (Status colors - don't change these)
  // =========================================================================
  static const Color success = Color(0xFF4CAF50); // Green - success/completed
  static const Color warning = Color(0xFFFF9800); // Orange - warning
  static const Color error = Color(0xFFF44336); // Red - error/overdue
  static const Color info = Color(0xFF2196F3); // Blue - info/pending

  // =========================================================================
  // TEXT STYLES - CHANGE FONT SIZES HERE
  // =========================================================================
  static const double fontSizeH1 = 28.0; // Largest headings
  static const double fontSizeH2 = 22.0; // Section headings
  static const double fontSizeH3 = 18.0; // Card titles
  static const double fontSizeH4 = 16.0; // Subheadings
  static const double fontSizeBody = 14.0; // Body text
  static const double fontSizeSmall = 12.0; // Small text
  static const double fontSizeTiny = 10.0; // Tiny text (badges)

  // Text styles - read-only, based on sizes above
  static TextStyle h1(bool isDark) => TextStyle(
        fontSize: fontSizeH1,
        fontWeight: FontWeight.bold,
        color: isDark ? darkTextPrimary : lightTextPrimary,
      );

  static TextStyle h2(bool isDark) => TextStyle(
        fontSize: fontSizeH2,
        fontWeight: FontWeight.bold,
        color: isDark ? darkTextPrimary : lightTextPrimary,
      );

  static TextStyle h3(bool isDark) => TextStyle(
        fontSize: fontSizeH3,
        fontWeight: FontWeight.w600,
        color: isDark ? darkTextPrimary : lightTextPrimary,
      );

  static TextStyle h4(bool isDark) => TextStyle(
        fontSize: fontSizeH4,
        fontWeight: FontWeight.w600,
        color: isDark ? darkTextPrimary : lightTextPrimary,
      );

  static TextStyle body(bool isDark) => TextStyle(
        fontSize: fontSizeBody,
        color: isDark ? darkTextPrimary : lightTextPrimary,
      );

  static TextStyle bodySmall(bool isDark) => TextStyle(
        fontSize: fontSizeSmall,
        color: isDark ? darkTextSecondary : lightTextSecondary,
      );

  // =========================================================================
  // SPACING - CHANGE GAPS AND PADDINGS HERE
  // =========================================================================
  static const double spacingXs = 4.0;
  static const double spacingSm = 8.0;
  static const double spacingMd = 16.0;
  static const double spacingLg = 24.0;
  static const double spacingXl = 32.0;

  static const double borderRadiusSm = 8.0;
  static const double borderRadiusMd = 12.0;
  static const double borderRadiusLg = 16.0;

  // =========================================================================
  // BUILD COMPLETE THEME - INTERNAL USE
  // =========================================================================

  static ThemeData get lightTheme => _buildTheme(Brightness.light);
  static ThemeData get darkTheme => _buildTheme(Brightness.dark);

  static ThemeData _buildTheme(Brightness brightness) {
    final isDark = brightness == Brightness.dark;

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      primaryColor: primaryColor,

      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        brightness: brightness,
        primary: primaryColor,
        secondary: Color.lerp(primaryColor, Colors.white, 0.3)!,
        surface: isDark ? darkSurface : lightSurface,
        error: error,
      ),

      // Background
      scaffoldBackgroundColor: isDark ? darkBackground : lightBackground,

      // App Bar
      appBarTheme: AppBarTheme(
        backgroundColor: isDark ? darkSurface : lightSurface,
        foregroundColor: isDark ? darkTextPrimary : lightTextPrimary,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: h3(isDark),
      ),

      // Cards
      cardTheme: CardThemeData(
        color: isDark ? darkSurface : lightSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadiusMd),
        ),
        margin: EdgeInsets.only(bottom: spacingSm),
      ),

      // Bottom Navigation
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: isDark ? darkSurface : lightSurface,
        indicatorColor: primaryColor.withOpacity(0.2),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return TextStyle(
                fontSize: 12, fontWeight: FontWeight.w600, color: primaryColor);
          }
          return TextStyle(
              fontSize: 12,
              color: isDark ? darkTextSecondary : lightTextSecondary);
        }),
      ),

      // Floating Action Button
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
      ),

      // Input Fields
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark ? Color(0xFF3A3A3A) : Color(0xFFF5F5F5),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadiusMd),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadiusMd),
          borderSide: BorderSide(color: primaryColor, width: 2),
        ),
        contentPadding: EdgeInsets.all(spacingMd),
      ),

      // Buttons
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          padding:
              EdgeInsets.symmetric(horizontal: spacingLg, vertical: spacingMd),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadiusMd),
          ),
        ),
      ),

      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          padding:
              EdgeInsets.symmetric(horizontal: spacingLg, vertical: spacingMd),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadiusMd),
          ),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryColor,
        ),
      ),

      // Switches & Checkboxes
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return primaryColor;
          return null;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected))
            return primaryColor.withOpacity(0.3);
          return null;
        }),
      ),

      // Dividers
      dividerTheme: DividerThemeData(
        color: isDark ? darkDivider : lightDivider,
        thickness: 1,
      ),
    );
  }
}
