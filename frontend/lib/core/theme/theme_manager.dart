import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'theme_registry.dart';
import 'theme_factory.dart';
import 'config/theme_config.dart';
import 'config/theme_tokens.dart';

/// Enhanced theme manager with support for multiple themes
/// Manages both theme selection (warm, cool, nature, etc.) and mode (light/dark)
class ThemeManager extends ChangeNotifier {
  static const String _themeIdKey = 'selected_theme_id';
  static const String _themeModeKey = 'theme_mode';

  String _currentThemeId = 'warm'; // Default to warm theme
  ThemeMode _themeMode = ThemeMode.light;

  /// Get current theme configuration
  ThemeConfig get currentTheme =>
      ThemeRegistry.getTheme(_currentThemeId) ?? ThemeRegistry.defaultTheme;

  /// Get current theme mode
  ThemeMode get themeMode => _themeMode;

  /// Check if dark mode is active
  bool get isDarkMode => _themeMode == ThemeMode.dark;

  /// Get current theme ID
  String get currentThemeId => _currentThemeId;

  /// Get list of all available themes
  List<ThemeConfig> get availableThemes => ThemeRegistry.allThemes;

  /// Initialize and load saved preferences
  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();

    // Load saved theme ID
    _currentThemeId = prefs.getString(_themeIdKey) ?? 'warm';

    // Verify theme exists, fallback to default if not
    if (!ThemeRegistry.hasTheme(_currentThemeId)) {
      _currentThemeId = ThemeRegistry.defaultTheme.id;
    }

    // Load saved theme mode
    final themeModeName = prefs.getString(_themeModeKey);
    if (themeModeName != null) {
      _themeMode = ThemeMode.values.firstWhere(
        (m) => m.name == themeModeName,
        orElse: () => ThemeMode.light,
      );
    }

    notifyListeners();
  }

  /// Switch to a different theme
  Future<void> setTheme(String themeId) async {
    if (!ThemeRegistry.hasTheme(themeId)) {
      debugPrint('Theme "$themeId" not found, keeping current theme');
      return;
    }

    _currentThemeId = themeId;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themeIdKey, themeId);
    notifyListeners();
  }

  /// Toggle between light and dark mode
  Future<void> toggleThemeMode() async {
    _themeMode =
        _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themeModeKey, _themeMode.name);
    notifyListeners();
  }

  /// Set specific theme mode
  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themeModeKey, mode.name);
    notifyListeners();
  }

  /// Get light theme for current theme
  ThemeData getLightTheme() {
    return ThemeFactory.buildTheme(currentTheme, Brightness.light);
  }

  /// Get dark theme for current theme
  ThemeData getDarkTheme() {
    return ThemeFactory.buildTheme(currentTheme, Brightness.dark);
  }

  /// Get current colors (respects light/dark mode)
  ColorPalette get currentColors =>
      isDarkMode ? currentTheme.darkColors : currentTheme.lightColors;
}
