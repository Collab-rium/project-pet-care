import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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
        primary: colors.primary,
        onPrimary: colors.textOnPrimary,
        primaryContainer: colors.primaryLight,
        onPrimaryContainer: colors.textPrimary,
        secondary: colors.secondary,
        onSecondary: colors.textPrimary,
        secondaryContainer: colors.secondaryLight,
        onSecondaryContainer: colors.textPrimary,
        tertiary: colors.primaryDark,
        onTertiary: colors.textOnPrimary,
        error: colors.error,
        onError: colors.textOnPrimary,
        errorContainer: colors.error,
        onErrorContainer: colors.textOnPrimary,
        surface: colors.surface,
        onSurface: colors.textPrimary,
        surfaceContainerHighest: colors.surfaceVariant,
        onSurfaceVariant: colors.textSecondary,
        outline: colors.border,
        outlineVariant: colors.divider,
        shadow: colors.shadow,
        scrim: colors.overlay,
        inverseSurface: isDark ? colors.surface : colors.background,
        onInverseSurface: colors.textPrimary,
        inversePrimary: colors.primaryDark,
      ),

      // Background
      scaffoldBackgroundColor: colors.background,

      // Typography - Build complete text theme
      textTheme: _buildTextTheme(typo, colors),

      // App Bar
      appBarTheme: AppBarTheme(
        backgroundColor: colors.surface,
        foregroundColor: colors.textPrimary,
        elevation: spacing.elevationSm,
        centerTitle: false,
        titleTextStyle: GoogleFonts.getFont(
          typo.headingFontFamily,
          fontSize: typo.h3Size,
          fontWeight: typo.h3Weight,
          letterSpacing: typo.h3LetterSpacing,
          color: colors.textPrimary,
        ),
      ),

      // Cards
      cardTheme: CardThemeData(
        color: colors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(spacing.radiusMd),
        ),
        margin: EdgeInsets.only(bottom: spacing.sm),
      ),

      // Bottom Navigation
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: colors.surface,
        indicatorColor: colors.primary.withOpacity(0.2),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return GoogleFonts.getFont(
              typo.bodyFontFamily,
              fontSize: 12,
              fontWeight: typo.labelWeight,
              color: colors.primary,
            );
          }
          return GoogleFonts.getFont(
            typo.bodyFontFamily,
            fontSize: 12,
            color: colors.textSecondary,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return IconThemeData(color: colors.primary, size: 24);
          }
          return IconThemeData(color: colors.textSecondary, size: 24);
        }),
      ),

      // Bottom Navigation Bar (legacy style)
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: colors.surface,
        selectedItemColor: colors.primary,
        unselectedItemColor: colors.textSecondary,
        type: BottomNavigationBarType.fixed,
        elevation: spacing.elevationMd,
      ),

      // Floating Action Button
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: colors.primary,
        foregroundColor: colors.textOnPrimary,
        elevation: spacing.elevationMd,
      ),

      // Input Fields
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark ? colors.surfaceVariant : colors.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(spacing.radiusMd),
          borderSide: BorderSide(color: colors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(spacing.radiusMd),
          borderSide: BorderSide(color: colors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(spacing.radiusMd),
          borderSide: BorderSide(color: colors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(spacing.radiusMd),
          borderSide: BorderSide(color: colors.error, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(spacing.radiusMd),
          borderSide: BorderSide(color: colors.error, width: 2),
        ),
        contentPadding: EdgeInsets.all(spacing.md),
      ),

      // Elevated Button
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colors.primary,
          foregroundColor: colors.textOnPrimary,
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
          backgroundColor: colors.primary,
          foregroundColor: colors.textOnPrimary,
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
          foregroundColor: colors.primary,
          side: BorderSide(color: colors.primary, width: 1.5),
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
          foregroundColor: colors.primary,
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
          foregroundColor: colors.primary,
        ),
      ),

      // Switches & Toggles
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return colors.primary;
          return null;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return colors.primary.withOpacity(0.3);
          }
          return null;
        }),
      ),

      // Checkbox
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return colors.primary;
          return null;
        }),
      ),

      // Radio
      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return colors.primary;
          return null;
        }),
      ),

      // Dividers
      dividerTheme: DividerThemeData(
        color: colors.divider,
        thickness: 1,
        space: spacing.md,
      ),

      // Chips
      chipTheme: ChipThemeData(
        backgroundColor: colors.surfaceVariant,
        selectedColor: colors.primary.withOpacity(0.2),
        labelStyle: GoogleFonts.getFont(
          typo.bodyFontFamily,
          fontSize: typo.bodySmallSize,
          color: colors.textPrimary,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(spacing.radiusSm),
        ),
      ),

      // Dialogs
      dialogTheme: DialogThemeData(
        backgroundColor: colors.surface,
        elevation: spacing.elevationLg,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(spacing.radiusLg),
        ),
      ),

      // Snackbar
      snackBarTheme: SnackBarThemeData(
        backgroundColor: colors.surface,
        contentTextStyle: GoogleFonts.getFont(
          typo.bodyFontFamily,
          fontSize: typo.bodyMediumSize,
          color: colors.textPrimary,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(spacing.radiusMd),
        ),
        behavior: SnackBarBehavior.floating,
      ),

      // Progress Indicators
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: colors.primary,
      ),

      // List Tiles
      listTileTheme: ListTileThemeData(
        textColor: colors.textPrimary,
        iconColor: colors.textSecondary,
        tileColor: colors.surface,
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
        color: colors.textPrimary,
      ),
      displayMedium: GoogleFonts.getFont(
        typo.headingFontFamily,
        fontSize: typo.h2Size,
        fontWeight: typo.h2Weight,
        letterSpacing: typo.h2LetterSpacing,
        color: colors.textPrimary,
      ),
      displaySmall: GoogleFonts.getFont(
        typo.headingFontFamily,
        fontSize: typo.h3Size,
        fontWeight: typo.h3Weight,
        letterSpacing: typo.h3LetterSpacing,
        color: colors.textPrimary,
      ),

      // Headline styles
      headlineLarge: GoogleFonts.getFont(
        typo.headingFontFamily,
        fontSize: typo.h1Size,
        fontWeight: typo.h1Weight,
        letterSpacing: typo.h1LetterSpacing,
        color: colors.textPrimary,
      ),
      headlineMedium: GoogleFonts.getFont(
        typo.headingFontFamily,
        fontSize: typo.h2Size,
        fontWeight: typo.h2Weight,
        letterSpacing: typo.h2LetterSpacing,
        color: colors.textPrimary,
      ),
      headlineSmall: GoogleFonts.getFont(
        typo.headingFontFamily,
        fontSize: typo.h3Size,
        fontWeight: typo.h3Weight,
        letterSpacing: typo.h3LetterSpacing,
        color: colors.textPrimary,
      ),

      // Title styles
      titleLarge: GoogleFonts.getFont(
        typo.headingFontFamily,
        fontSize: typo.h3Size,
        fontWeight: typo.h3Weight,
        letterSpacing: typo.h3LetterSpacing,
        color: colors.textPrimary,
      ),
      titleMedium: GoogleFonts.getFont(
        typo.headingFontFamily,
        fontSize: typo.h4Size,
        fontWeight: typo.h4Weight,
        letterSpacing: typo.h4LetterSpacing,
        color: colors.textPrimary,
      ),
      titleSmall: GoogleFonts.getFont(
        typo.headingFontFamily,
        fontSize: typo.bodyLargeSize,
        fontWeight: typo.h4Weight,
        color: colors.textPrimary,
      ),

      // Body styles
      bodyLarge: GoogleFonts.getFont(
        typo.bodyFontFamily,
        fontSize: typo.bodyLargeSize,
        fontWeight: typo.bodyWeight,
        height: typo.bodyLineHeight,
        color: colors.textPrimary,
      ),
      bodyMedium: GoogleFonts.getFont(
        typo.bodyFontFamily,
        fontSize: typo.bodyMediumSize,
        fontWeight: typo.bodyWeight,
        height: typo.bodyLineHeight,
        color: colors.textPrimary,
      ),
      bodySmall: GoogleFonts.getFont(
        typo.bodyFontFamily,
        fontSize: typo.bodySmallSize,
        fontWeight: typo.bodyWeight,
        height: typo.captionLineHeight,
        color: colors.textSecondary,
      ),

      // Label styles (buttons, tabs)
      labelLarge: GoogleFonts.getFont(
        typo.bodyFontFamily,
        fontSize: typo.bodyLargeSize,
        fontWeight: typo.buttonWeight,
        letterSpacing: typo.buttonLetterSpacing,
        color: colors.textPrimary,
      ),
      labelMedium: GoogleFonts.getFont(
        typo.bodyFontFamily,
        fontSize: typo.labelSize,
        fontWeight: typo.labelWeight,
        letterSpacing: typo.labelLetterSpacing,
        color: colors.textPrimary,
      ),
      labelSmall: GoogleFonts.getFont(
        typo.bodyFontFamily,
        fontSize: typo.captionSize,
        fontWeight: typo.labelWeight,
        letterSpacing: typo.captionLetterSpacing,
        color: colors.textSecondary,
      ),
    );
  }
}
