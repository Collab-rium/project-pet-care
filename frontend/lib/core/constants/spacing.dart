import 'package:flutter/material.dart';

/// Spacing constants based on 8px base unit
/// Provides consistent spacing throughout the app
class AppSpacing {
  // Base unit (8px)
  static const double base = 8.0;

  // Spacing scale (8px increments)
  static const double xs = 4.0; // 0.5x base
  static const double sm = 8.0; // 1x base
  static const double md = 16.0; // 2x base
  static const double lg = 24.0; // 3x base
  static const double xl = 32.0; // 4x base
  static const double xxl = 48.0; // 6x base
  static const double xxxl = 64.0; // 8x base

  // Component-specific spacing
  static const double cardPadding = 16.0; // md
  static const double cardPaddingLarge = 24.0; // lg
  static const double pagePadding = 16.0; // md
  static const double pageMargin = 16.0; // md
  static const double sectionSpacing = 32.0; // xl
  static const double itemSpacing = 12.0; // 1.5x base
  static const double buttonPadding = 16.0; // md

  // Border radius
  static const double radiusXs = 4.0;
  static const double radiusSm = 8.0;
  static const double radiusMd = 12.0;
  static const double radiusLg = 16.0;
  static const double radiusXl = 24.0;
  static const double radiusFull = 9999.0; // Pill shape

  // Icon sizes
  static const double iconXs = 16.0;
  static const double iconSm = 20.0;
  static const double iconMd = 24.0;
  static const double iconLg = 32.0;
  static const double iconXl = 48.0;

  // Avatar sizes
  static const double avatarSm = 32.0;
  static const double avatarMd = 48.0;
  static const double avatarLg = 64.0;
  static const double avatarXl = 96.0;

  // Button heights
  static const double buttonHeightSm = 36.0;
  static const double buttonHeightMd = 48.0;
  static const double buttonHeightLg = 56.0;

  // Input heights
  static const double inputHeight = 48.0;
  static const double inputHeightSm = 40.0;

  // Bottom navigation
  static const double bottomNavHeight = 64.0;

  // App bar
  static const double appBarHeight = 56.0;

  // FAB size
  static const double fabSize = 56.0;
  static const double fabSizeSm = 48.0;

  // Elevation (shadow depth)
  static const double elevationNone = 0.0;
  static const double elevationSm = 2.0;
  static const double elevationMd = 4.0;
  static const double elevationLg = 8.0;
  static const double elevationXl = 16.0;

  // Edge insets helpers
  static EdgeInsets all(double value) => EdgeInsets.all(value);
  static EdgeInsets horizontal(double value) =>
      EdgeInsets.symmetric(horizontal: value);
  static EdgeInsets vertical(double value) =>
      EdgeInsets.symmetric(vertical: value);
  static EdgeInsets only({
    double left = 0,
    double top = 0,
    double right = 0,
    double bottom = 0,
  }) =>
      EdgeInsets.only(left: left, top: top, right: right, bottom: bottom);

  // Predefined edge insets
  static const EdgeInsets paddingXs = EdgeInsets.all(xs);
  static const EdgeInsets paddingSm = EdgeInsets.all(sm);
  static const EdgeInsets paddingMd = EdgeInsets.all(md);
  static const EdgeInsets paddingLg = EdgeInsets.all(lg);
  static const EdgeInsets paddingXl = EdgeInsets.all(xl);

  static const EdgeInsets pageInsets = EdgeInsets.all(pagePadding);
  static const EdgeInsets cardInsets = EdgeInsets.all(cardPadding);
  static const EdgeInsets buttonInsets = EdgeInsets.all(buttonPadding);

  // Border radius helpers
  static BorderRadius radiusAll(double value) => BorderRadius.circular(value);
  static BorderRadius get borderRadiusXs => radiusAll(radiusXs);
  static BorderRadius get borderRadiusSm => radiusAll(radiusSm);
  static BorderRadius get borderRadiusMd => radiusAll(radiusMd);
  static BorderRadius get borderRadiusLg => radiusAll(radiusLg);
  static BorderRadius get borderRadiusXl => radiusAll(radiusXl);
  static BorderRadius get borderRadiusFull => radiusAll(radiusFull);

  // SizedBox helpers for spacing
  static Widget verticalSpace(double height) => SizedBox(height: height);
  static Widget horizontalSpace(double width) => SizedBox(width: width);

  static Widget get vSpaceXs => verticalSpace(xs);
  static Widget get vSpaceSm => verticalSpace(sm);
  static Widget get vSpaceMd => verticalSpace(md);
  static Widget get vSpaceLg => verticalSpace(lg);
  static Widget get vSpaceXl => verticalSpace(xl);

  static Widget get hSpaceXs => horizontalSpace(xs);
  static Widget get hSpaceSm => horizontalSpace(sm);
  static Widget get hSpaceMd => horizontalSpace(md);
  static Widget get hSpaceLg => horizontalSpace(lg);
  static Widget get hSpaceXl => horizontalSpace(xl);
}
