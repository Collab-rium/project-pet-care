import 'package:flutter/material.dart';
import 'color_tokens.dart';
import '../../../core/theme/theme_manager.dart';

/// Extension to get ColorTokens easily in widgets
extension ColorTokensExtension on BuildContext {
  /// Get current theme's color tokens
  ColorTokens get colorTokens {
    final themeManager = Theme.of(this).extensions[ThemeManager] as ThemeManager?;
    
    return ColorTokens(
      themeMode: MediaQuery.of(this).platformBrightness == Brightness.dark 
          ? ThemeMode.dark 
          : ThemeMode.light,
      activeThemeId: themeManager?.currentTheme.id ?? 'warm',
    );
  }

  /// Get a specific color
  Color getThemeColor(String colorName) {
    final tokens = colorTokens;
    
    switch (colorName) {
      case 'primary':
        return tokens.primary;
      case 'secondary':
        return tokens.secondary;
      case 'background':
        return tokens.background;
      case 'surface':
        return tokens.surface;
      case 'textPrimary':
        return tokens.textPrimary;
      case 'textSecondary':
        return tokens.textSecondary;
      case 'error':
        return tokens.error;
      case 'success':
        return tokens.success;
      default:
        return tokens.primary;
    }
  }
}
