import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app_theme_config.dart';

/// Theme manager that uses unified AppThemeConfig
class ThemeManager extends ChangeNotifier {
  static const String _themeModeKey = 'theme_mode';

  ThemeMode _themeMode = ThemeMode.light;

  ThemeMode get themeMode => _themeMode;
  bool get isDarkMode => _themeMode == ThemeMode.dark;

  /// Initialize and load saved preferences
  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();

    final themeModeName = prefs.getString(_themeModeKey);
    if (themeModeName != null) {
      _themeMode = ThemeMode.values.firstWhere(
        (m) => m.name == themeModeName,
        orElse: () => ThemeMode.light,
      );
    }

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

  /// Get light theme from unified config
  ThemeData getLightTheme() {
    return AppThemeConfig.lightTheme;
  }

  /// Get dark theme from unified config
  ThemeData getDarkTheme() {
    return AppThemeConfig.darkTheme;
  }
}
