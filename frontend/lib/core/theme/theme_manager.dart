import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Available color themes
enum AppTheme {
  warmOrange('Warm Orange', Color(0xFFFF8C42)),
  coolBlue('Cool Blue', Color(0xFF2196F3)),
  freshGreen('Fresh Green', Color(0xFF4CAF50)),
  purpleDream('Purple Dream', Color(0xFF9C27B0)),
  sunsetPink('Sunset Pink', Color(0xFFE91E63));

  const AppTheme(this.name, this.primaryColor);
  final String name;
  final Color primaryColor;
}

/// Manages app theme and persists user preference
class ThemeManager extends ChangeNotifier {
  static const String _themeKey = 'app_theme';
  static const String _themeModeKey = 'theme_mode';
  
  AppTheme _currentTheme = AppTheme.warmOrange;
  ThemeMode _themeMode = ThemeMode.light;
  
  AppTheme get currentTheme => _currentTheme;
  ThemeMode get themeMode => _themeMode;
  bool get isDarkMode => _themeMode == ThemeMode.dark;
  
  /// Initialize and load saved preferences
  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Load theme
    final themeName = prefs.getString(_themeKey);
    if (themeName != null) {
      _currentTheme = AppTheme.values.firstWhere(
        (t) => t.name == themeName,
        orElse: () => AppTheme.warmOrange,
      );
    }
    
    // Load theme mode
    final themeModeName = prefs.getString(_themeModeKey);
    if (themeModeName != null) {
      _themeMode = ThemeMode.values.firstWhere(
        (m) => m.name == themeModeName,
        orElse: () => ThemeMode.light,
      );
    }
    
    notifyListeners();
  }
  
  /// Change theme
  Future<void> setTheme(AppTheme theme) async {
    _currentTheme = theme;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themeKey, theme.name);
    notifyListeners();
  }
  
  /// Toggle between light and dark mode
  Future<void> toggleThemeMode() async {
    _themeMode = _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
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
  
  /// Get theme data for current theme
  ThemeData getLightTheme() {
    return _buildTheme(_currentTheme, Brightness.light);
  }
  
  ThemeData getDarkTheme() {
    return _buildTheme(_currentTheme, Brightness.dark);
  }
  
  /// Build theme data
  ThemeData _buildTheme(AppTheme theme, Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    final primary = theme.primaryColor;
    final primaryLight = Color.lerp(primary, Colors.white, 0.3)!;
    final primaryDark = Color.lerp(primary, Colors.black, 0.2)!;
    
    return ThemeData(
      brightness: brightness,
      primaryColor: primary,
      primaryColorLight: primaryLight,
      primaryColorDark: primaryDark,
      
      colorScheme: ColorScheme.fromSeed(
        seedColor: primary,
        brightness: brightness,
        primary: primary,
        secondary: primaryLight,
      ),
      
      scaffoldBackgroundColor: isDark ? const Color(0xFF1A1A1A) : const Color(0xFFFFF9F5),
      
      appBarTheme: AppBarTheme(
        backgroundColor: isDark ? const Color(0xFF2C2C2C) : Colors.white,
        foregroundColor: isDark ? Colors.white : const Color(0xFF2C2C2C),
        elevation: 0,
        centerTitle: false,
      ),
      
      cardTheme: CardThemeData(
        color: isDark ? const Color(0xFF2C2C2C) : Colors.white,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: primary,
        foregroundColor: Colors.white,
      ),
      
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        selectedItemColor: primary,
        unselectedItemColor: isDark ? Colors.grey[600] : Colors.grey[400],
        backgroundColor: isDark ? const Color(0xFF2C2C2C) : Colors.white,
        type: BottomNavigationBarType.fixed,
      ),
      
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark ? const Color(0xFF3A3A3A) : const Color(0xFFFFF4ED),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: primary, width: 2),
        ),
      ),
      
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primary,
        ),
      ),
      
      switchTheme: SwitchThemeData(
        thumbColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return primary;
          }
          return null;
        }),
        trackColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return primaryLight;
          }
          return null;
        }),
      ),
      
      useMaterial3: true,
    );
  }
}
