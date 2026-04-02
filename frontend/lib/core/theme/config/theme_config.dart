import 'theme_tokens.dart';

/// Base interface that all theme configurations must implement
/// 
/// To create a new theme:
/// 1. Create a new file in config/themes/
/// 2. Extend this class
/// 3. Define light and dark color palettes
/// 4. Register in ThemeRegistry
/// 
/// Example:
/// ```dart
/// class MyThemeConfig extends ThemeConfig {
///   @override
///   String get id => 'my-theme';
///   
///   @override
///   String get name => 'My Theme';
///   
///   @override
///   ColorPalette get lightColors => ColorPalette(...);
///   
///   @override
///   ColorPalette get darkColors => ColorPalette(...);
/// }
/// ```
abstract class ThemeConfig {
  /// Unique identifier for this theme (e.g., 'warm', 'cool', 'nature')
  /// Used for persistence and theme selection
  String get id;

  /// Display name shown in theme selector UI
  String get name;

  /// Description of the theme for users
  String get description;

  /// Color palette for light mode
  ColorPalette get lightColors;

  /// Color palette for dark mode
  ColorPalette get darkColors;

  /// Typography configuration
  /// Defaults to Poppins (headings) + Inter (body)
  TypographyConfig get typography => const TypographyConfig();

  /// Spacing configuration
  /// Defaults to 8px base unit system
  SpacingConfig get spacing => SpacingConfig.defaults;

  /// Preview colors for theme selector
  ThemePreview get preview;
}
