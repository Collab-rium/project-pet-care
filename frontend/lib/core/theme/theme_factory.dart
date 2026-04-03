import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/colors.dart';
import 'config/theme_config.dart';
import 'config/theme_tokens.dart';

/// Factory that builds Flutter ThemeData from ThemeConfig
/// Converts our custom theme configuration into Material 3 theme data
class ThemeFactory {
  /// Build a complete ThemeData from a ThemeConfig
  static ThemeData buildTheme(ThemeConfig config, Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    final colors = isDark ? config.darkColors : config.lightColors;
    final typo = config.typography;
    final spacing = config.spacing;

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,

      // Color Scheme - Material 3 standard colors
      colorScheme: ColorScheme(
        brightness: brightness,
        primary: AppColors.primary,
        onPrimary: AppColors.textOnPrimary,
        primaryContainer: AppColors.primaryLight,
        onPrimaryContainer: AppColors.textPrimary,
        secondary: AppColors.secondary,
        onSecondary: AppColors.textPrimary,
        secondaryContainer: AppColors.secondaryLight,
        onSecondaryContainer: AppColors.textPrimary,
        tertiary: AppColors.primaryDark,
        onTertiary: AppColors.textOnPrimary,
        error: AppColors.error,
        onError: AppColors.textOnPrimary,
        errorContainer: AppColors.error,
        onErrorContainer: AppColors.textOnPrimary,
        surface: AppColors.surface,
        onSurface: AppColors.textPrimary,
        surfaceContainerHighest: AppColors.surfaceVariant,
        onSurfaceVariant: AppColors.textSecondary,
        outline: AppColors.border,
        outlineVariant: AppColors.divider,
        shadow: AppColors.shadow,
        scrim: AppColors.shadowLight,
        inverseSurface: isDark ? AppColors.surface : AppColors.background,
        onInverseSurface: AppColors.textPrimary,
        inversePrimary: AppColors.primaryDark,
      ),

      // Background
      scaffoldBackgroundColor: AppColors.background,

      // Typography - Build complete text theme
      textTheme: _buildTextTheme(typo, colors),

      // App Bar
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        elevation: spacing.elevationSm,
        centerTitle: false,
        titleTextStyle: GoogleFonts.getFont(
          typo.headingFontFamily,
          fontSize: typo.h3Size,
          fontWeight: typo.h3Weight,
          letterSpacing: typo.h3LetterSpacing,
          color: AppColors.textPrimary,
        ),
      ),

      // Cards
      cardTheme: CardThemeData(
        color: AppColors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(spacing.radiusMd),
        ),
        margin: EdgeInsets.only(bottom: spacing.sm),
      ),

      // Bottom Navigation
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.surface,
        indicatorColor: AppColors.primary.withOpacity(0.2),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return GoogleFonts.getFont(
              typo.bodyFontFamily,
              fontSize: 12,
              fontWeight: typo.labelWeight,
              color: AppColors.primary,
            );
          }
          return GoogleFonts.getFont(
            typo.bodyFontFamily,
            fontSize: 12,
            color: AppColors.textSecondary,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return IconThemeData(color: AppColors.primary, size: 24);
          }
          return IconThemeData(color: AppColors.textSecondary, size: 24);
        }),
      ),

      // Bottom Navigation Bar (legacy style)
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: AppColors.surface,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textSecondary,
        type: BottomNavigationBarType.fixed,
        elevation: spacing.elevationMd,
      ),

      // Floating Action Button
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textOnPrimary,
        elevation: spacing.elevationMd,
      ),

      // Input Fields
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark ? AppColors.surfaceVariant : AppColors.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(spacing.radiusMd),
          borderSide: BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(spacing.radiusMd),
          borderSide: BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(spacing.radiusMd),
          borderSide: BorderSide(color: AppColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(spacing.radiusMd),
          borderSide: BorderSide(color: AppColors.error, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(spacing.radiusMd),
          borderSide: BorderSide(color: AppColors.error, width: 2),
        ),
        contentPadding: EdgeInsets.all(spacing.md),
      ),

      // Elevated Button
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.textOnPrimary,
          elevation: spacing.elevationSm,
          padding: EdgeInsets.symmetric(
            horizontal: spacing.lg,
            vertical: spacing.md,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(spacing.radiusMd),
          ),
          textStyle: GoogleFonts.getFont(
            typo.bodyFontFamily,
            fontSize: typo.bodyLargeSize,
            fontWeight: typo.buttonWeight,
            letterSpacing: typo.buttonLetterSpacing,
          ),
        ),
      ),

      // Filled Button
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.textOnPrimary,
          padding: EdgeInsets.symmetric(
            horizontal: spacing.lg,
            vertical: spacing.md,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(spacing.radiusMd),
          ),
        ),
      ),

      // Outlined Button
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          side: BorderSide(color: AppColors.primary, width: 1.5),
          padding: EdgeInsets.symmetric(
            horizontal: spacing.lg,
            vertical: spacing.md,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(spacing.radiusMd),
          ),
        ),
      ),

      // Text Button
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          padding: EdgeInsets.symmetric(
            horizontal: spacing.lg,
            vertical: spacing.md,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(spacing.radiusMd),
          ),
        ),
      ),

      // Icon Button
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          foregroundColor: AppColors.primary,
        ),
      ),

      // Switches & Toggles
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return AppColors.primary;
          return null;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.primary.withOpacity(0.3);
          }
          return null;
        }),
      ),

      // Checkbox
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return AppColors.primary;
          return null;
        }),
      ),

      // Radio
      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return AppColors.primary;
          return null;
        }),
      ),

      // Dividers
      dividerTheme: DividerThemeData(
        color: AppColors.divider,
        thickness: 1,
        space: spacing.md,
      ),

      // Chips
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.surfaceVariant,
        selectedColor: AppColors.primary.withOpacity(0.2),
        labelStyle: GoogleFonts.getFont(
          typo.bodyFontFamily,
          fontSize: typo.bodySmallSize,
          color: AppColors.textPrimary,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(spacing.radiusSm),
        ),
      ),

      // Dialogs
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.surface,
        elevation: spacing.elevationLg,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(spacing.radiusLg),
        ),
      ),

      // Snackbar
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.surface,
        contentTextStyle: GoogleFonts.getFont(
          typo.bodyFontFamily,
          fontSize: typo.bodyMediumSize,
          color: AppColors.textPrimary,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(spacing.radiusMd),
        ),
        behavior: SnackBarBehavior.floating,
      ),

      // Progress Indicators
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: AppColors.primary,
      ),

      // List Tiles
      listTileTheme: ListTileThemeData(
        textColor: AppColors.textPrimary,
        iconColor: AppColors.textSecondary,
        tileColor: AppColors.surface,
      ),
    );
  }

  /// Build complete text theme with Google Fonts
  static TextTheme _buildTextTheme(
      TypographyConfig typo, ColorPalette colors) {
    return TextTheme(
      // Display styles (largest)
      displayLarge: GoogleFonts.getFont(
        typo.headingFontFamily,
        fontSize: typo.h1Size,
        fontWeight: typo.h1Weight,
        letterSpacing: typo.h1LetterSpacing,
        color: AppColors.textPrimary,
      ),
      displayMedium: GoogleFonts.getFont(
        typo.headingFontFamily,
        fontSize: typo.h2Size,
        fontWeight: typo.h2Weight,
        letterSpacing: typo.h2LetterSpacing,
        color: AppColors.textPrimary,
      ),
      displaySmall: GoogleFonts.getFont(
        typo.headingFontFamily,
        fontSize: typo.h3Size,
        fontWeight: typo.h3Weight,
        letterSpacing: typo.h3LetterSpacing,
        color: AppColors.textPrimary,
      ),

      // Headline styles
      headlineLarge: GoogleFonts.getFont(
        typo.headingFontFamily,
        fontSize: typo.h1Size,
        fontWeight: typo.h1Weight,
        letterSpacing: typo.h1LetterSpacing,
        color: AppColors.textPrimary,
      ),
      headlineMedium: GoogleFonts.getFont(
        typo.headingFontFamily,
        fontSize: typo.h2Size,
        fontWeight: typo.h2Weight,
        letterSpacing: typo.h2LetterSpacing,
        color: AppColors.textPrimary,
      ),
      headlineSmall: GoogleFonts.getFont(
        typo.headingFontFamily,
        fontSize: typo.h3Size,
        fontWeight: typo.h3Weight,
        letterSpacing: typo.h3LetterSpacing,
        color: AppColors.textPrimary,
      ),

      // Title styles
      titleLarge: GoogleFonts.getFont(
        typo.headingFontFamily,
        fontSize: typo.h3Size,
        fontWeight: typo.h3Weight,
        letterSpacing: typo.h3LetterSpacing,
        color: AppColors.textPrimary,
      ),
      titleMedium: GoogleFonts.getFont(
        typo.headingFontFamily,
        fontSize: typo.h4Size,
        fontWeight: typo.h4Weight,
        letterSpacing: typo.h4LetterSpacing,
        color: AppColors.textPrimary,
      ),
      titleSmall: GoogleFonts.getFont(
        typo.headingFontFamily,
        fontSize: typo.bodyLargeSize,
        fontWeight: typo.h4Weight,
        color: AppColors.textPrimary,
      ),

      // Body styles
      bodyLarge: GoogleFonts.getFont(
        typo.bodyFontFamily,
        fontSize: typo.bodyLargeSize,
        fontWeight: typo.bodyWeight,
        height: typo.bodyLineHeight,
        color: AppColors.textPrimary,
      ),
      bodyMedium: GoogleFonts.getFont(
        typo.bodyFontFamily,
        fontSize: typo.bodyMediumSize,
        fontWeight: typo.bodyWeight,
        height: typo.bodyLineHeight,
        color: AppColors.textPrimary,
      ),
      bodySmall: GoogleFonts.getFont(
        typo.bodyFontFamily,
        fontSize: typo.bodySmallSize,
        fontWeight: typo.bodyWeight,
        height: typo.captionLineHeight,
        color: AppColors.textSecondary,
      ),

      // Label styles (buttons, tabs)
      labelLarge: GoogleFonts.getFont(
        typo.bodyFontFamily,
        fontSize: typo.bodyLargeSize,
        fontWeight: typo.buttonWeight,
        letterSpacing: typo.buttonLetterSpacing,
        color: AppColors.textPrimary,
      ),
      labelMedium: GoogleFonts.getFont(
        typo.bodyFontFamily,
        fontSize: typo.labelSize,
        fontWeight: typo.labelWeight,
        letterSpacing: typo.labelLetterSpacing,
        color: AppColors.textPrimary,
      ),
      labelSmall: GoogleFonts.getFont(
        typo.bodyFontFamily,
        fontSize: typo.captionSize,
        fontWeight: typo.labelWeight,
        letterSpacing: typo.captionLetterSpacing,
        color: AppColors.textSecondary,
      ),
    );
  }
}
