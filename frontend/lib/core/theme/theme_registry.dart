import 'config/theme_config.dart';
import 'config/themes/warm_theme.dart';
import 'config/themes/cool_theme.dart';
import 'config/themes/nature_theme.dart';

/// Central registry of all available themes
/// 
/// To add a new theme:
/// 1. Create a new theme config class extending ThemeConfig
/// 2. Add it to the _themes list below
/// 3. Done! It will automatically appear in the theme selector
class ThemeRegistry {
  /// List of all available themes
  /// To add a new theme, just add it to this list!
  static final List<ThemeConfig> _themes = [
    WarmThemeConfig(), // Default theme
    CoolThemeConfig(),
    NatureThemeConfig(),
    // Add new themes here:
    // MyCustomThemeConfig(),
  ];

  /// Get all available themes
  static List<ThemeConfig> get allThemes => List.unmodifiable(_themes);

  /// Get theme by ID
  /// Returns null if theme not found
  static ThemeConfig? getTheme(String id) {
    try {
      return _themes.firstWhere((theme) => theme.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Get default theme (first in list)
  static ThemeConfig get defaultTheme => _themes.first;

  /// Check if a theme with given ID exists
  static bool hasTheme(String id) => getTheme(id) != null;

  /// Get list of theme IDs
  static List<String> get themeIds =>
      _themes.map((theme) => theme.id).toList();

  /// Get list of theme names
  static List<String> get themeNames =>
      _themes.map((theme) => theme.name).toList();
}
