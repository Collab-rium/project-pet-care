/// App spacing constants based on 8px base unit system
class AppSpacing {
  // Base unit
  static const double unit = 8.0;
  
  // Spacing scale (multiples of base unit)
  static const double xs = unit * 0.5;  // 4px
  static const double sm = unit * 1;    // 8px
  static const double md = unit * 2;    // 16px
  static const double lg = unit * 3;    // 24px
  static const double xl = unit * 4;    // 32px
  static const double xxl = unit * 6;   // 48px
  static const double xxxl = unit * 8;  // 64px
  
  // Common use cases
  static const double padding = md;           // Default padding: 16px
  static const double paddingHorizontal = md; // Horizontal padding: 16px
  static const double paddingVertical = md;   // Vertical padding: 16px
  static const double gap = sm;               // Default gap: 8px
  static const double margin = md;            // Default margin: 16px
  
  // Component-specific
  static const double buttonPadding = md;
  static const double cardPadding = md;
  static const double listItemPadding = md;
  static const double inputPadding = md;
  
  // Layout
  static const double screenPadding = md;     // Screen edge padding: 16px
  static const double sectionSpacing = xl;    // Between sections: 32px
  static const double itemSpacing = md;       // Between items: 16px
  
  // Border radius
  static const double radiusXs = 4.0;
  static const double radiusSm = 8.0;
  static const double radiusMd = 12.0;
  static const double radiusLg = 16.0;
  static const double radiusXl = 24.0;
  static const double radiusRound = 9999.0;   // Fully rounded
}
