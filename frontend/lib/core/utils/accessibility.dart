import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';

class AccessibilityHelper {
  static const double minimumTouchTargetSize = 44.0;
  static const double preferredTouchTargetSize = 48.0;

  // Semantic labels for common elements
  static const String navigationButtonLabel = 'Navigation button';
  static const String closeButtonLabel = 'Close dialog';
  static const String deleteButtonLabel = 'Delete item';
  static const String editButtonLabel = 'Edit item';
  static const String saveButtonLabel = 'Save changes';
  static const String addButtonLabel = 'Add new item';
  static const String searchFieldLabel = 'Search field';
  static const String menuButtonLabel = 'Open menu';

  // ARIA-like roles for screen readers
  static SemanticsProperties buttonSemantics({
    required String label,
    String? hint,
    bool enabled = true,
  }) {
    return SemanticsProperties(
      label: label,
      hint: hint,
      enabled: enabled,
      button: true,
    );
  }

  static SemanticsProperties inputSemantics({
    required String label,
    String? hint,
    String? value,
    bool obscured = false,
    bool multiline = false,
  }) {
    return SemanticsProperties(
      label: label,
      hint: hint,
      value: value,
      textField: true,
      obscured: obscured,
      multiline: multiline,
    );
  }

  static SemanticsProperties headingSemantics({
    required String text,
    required int level,
  }) {
    return SemanticsProperties(
      label: text,
      header: true,
    );
  }

  // Helper to ensure minimum touch target size
  static Widget ensureTouchTarget({
    required Widget child,
    double minSize = minimumTouchTargetSize,
  }) {
    return ConstrainedBox(
      constraints: BoxConstraints(
        minWidth: minSize,
        minHeight: minSize,
      ),
      child: child,
    );
  }
}

// Accessible button wrapper
class AccessibleButton extends StatelessWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final String semanticLabel;
  final String? semanticHint;
  final bool enabled;

  const AccessibleButton({
    super.key,
    required this.child,
    required this.onPressed,
    required this.semanticLabel,
    this.semanticHint,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return AccessibilityHelper.ensureTouchTarget(
      child: Semantics(
        label: semanticLabel,
        hint: semanticHint,
        enabled: enabled,
        button: true,
        child: child,
      ),
    );
  }
}

// Accessible input field wrapper
class AccessibleInput extends StatelessWidget {
  final Widget child;
  final String semanticLabel;
  final String? semanticHint;
  final String? semanticValue;
  final bool obscured;
  final bool multiline;

  const AccessibleInput({
    super.key,
    required this.child,
    required this.semanticLabel,
    this.semanticHint,
    this.semanticValue,
    this.obscured = false,
    this.multiline = false,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: semanticLabel,
      hint: semanticHint,
      value: semanticValue,
      textField: true,
      obscured: obscured,
      multiline: multiline,
      child: child,
    );
  }
}

// Accessible heading wrapper
class AccessibleHeading extends StatelessWidget {
  final Widget child;
  final String text;
  final int level;

  const AccessibleHeading({
    super.key,
    required this.child,
    required this.text,
    this.level = 1,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: text,
      header: true,
      child: child,
    );
  }
}

// Accessible navigation item
class AccessibleNavItem extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final String label;
  final bool isSelected;
  final int? index;
  final int? totalItems;

  const AccessibleNavItem({
    super.key,
    required this.child,
    required this.onTap,
    required this.label,
    this.isSelected = false,
    this.index,
    this.totalItems,
  });

  @override
  Widget build(BuildContext context) {
    String semanticLabel = label;
    if (isSelected) {
      semanticLabel += ', selected';
    }
    if (index != null && totalItems != null) {
      semanticLabel += ', tab ${index! + 1} of $totalItems';
    }

    return AccessibilityHelper.ensureTouchTarget(
      child: Semantics(
        label: semanticLabel,
        selected: isSelected,
        button: true,
        child: child,
      ),
    );
  }
}

// Accessible card with proper semantic structure
class AccessibleCard extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final String? semanticLabel;
  final String? semanticHint;

  const AccessibleCard({
    super.key,
    required this.child,
    this.onTap,
    this.semanticLabel,
    this.semanticHint,
  });

  @override
  Widget build(BuildContext context) {
    if (onTap != null) {
      return Semantics(
        label: semanticLabel,
        hint: semanticHint,
        button: true,
        child: child,
      );
    }

    return Semantics(
      label: semanticLabel,
      hint: semanticHint,
      container: true,
      child: child,
    );
  }
}

// Accessible list with proper announcements
class AccessibleList extends StatelessWidget {
  final List<Widget> children;
  final String? semanticLabel;
  final Axis scrollDirection;

  const AccessibleList({
    super.key,
    required this.children,
    this.semanticLabel,
    this.scrollDirection = Axis.vertical,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: semanticLabel ?? 'List with ${children.length} items',
      list: true,
      child: ListView(
        scrollDirection: scrollDirection,
        children: children.asMap().entries.map((entry) {
          final index = entry.key;
          final child = entry.value;
          
          return Semantics(
            sortKey: OrdinalSortKey(index.toDouble()),
            child: child,
          );
        }).toList(),
      ),
    );
  }
}

// Focus management utilities
class FocusHelper {
  static void requestFocus(BuildContext context, FocusNode focusNode) {
    Future.microtask(() {
      if (context.mounted) {
        focusNode.requestFocus();
      }
    });
  }

  static void clearFocus(BuildContext context) {
    FocusScope.of(context).unfocus();
  }

  static void nextFocus(BuildContext context) {
    FocusScope.of(context).nextFocus();
  }

  static void previousFocus(BuildContext context) {
    FocusScope.of(context).previousFocus();
  }
}

// Screen reader announcement helper
class AnnouncementHelper {
  static void announce(BuildContext context, String message) {
    SemanticsService.announce(message, TextDirection.ltr);
  }

  static void announceSuccess(BuildContext context, String message) {
    announce(context, 'Success: $message');
  }

  static void announceError(BuildContext context, String message) {
    announce(context, 'Error: $message');
  }

  static void announceLoading(BuildContext context, String message) {
    announce(context, 'Loading: $message');
  }
}

// High contrast detection and color utilities
class AccessibilityColors {
  static bool isHighContrast(BuildContext context) {
    final platformBrightness = MediaQuery.of(context).platformBrightness;
    final accessibilityFeatures = MediaQuery.of(context).accessibleNavigation;
    return accessibilityFeatures;
  }

  static double getContrastRatio(Color foreground, Color background) {
    final fgLuminance = foreground.computeLuminance();
    final bgLuminance = background.computeLuminance();
    
    final lighter = fgLuminance > bgLuminance ? fgLuminance : bgLuminance;
    final darker = fgLuminance > bgLuminance ? bgLuminance : fgLuminance;
    
    return (lighter + 0.05) / (darker + 0.05);
  }

  static bool meetsWCAGAA(Color foreground, Color background) {
    return getContrastRatio(foreground, background) >= 4.5;
  }

  static bool meetsWCAGAAA(Color foreground, Color background) {
    return getContrastRatio(foreground, background) >= 7.0;
  }
}

// Font scaling support
class AccessibilityText {
  static TextStyle scaleTextStyle(BuildContext context, TextStyle style) {
    final textScaleFactor = MediaQuery.of(context).textScaleFactor;
    final maxScale = 2.0; // Limit maximum scaling for layout stability
    final clampedScale = textScaleFactor.clamp(1.0, maxScale);
    
    return style.copyWith(
      fontSize: (style.fontSize ?? 14.0) * clampedScale,
    );
  }

  static bool isLargeTextScale(BuildContext context) {
    return MediaQuery.of(context).textScaleFactor > 1.3;
  }
}

// Accessibility testing helpers for development
class AccessibilityDebug {
  static void logContrastRatio(String label, Color foreground, Color background) {
    final ratio = AccessibilityColors.getContrastRatio(foreground, background);
    final meetsAA = AccessibilityColors.meetsWCAGAA(foreground, background);
    final meetsAAA = AccessibilityColors.meetsWCAGAAA(foreground, background);
    
    print('$label: Contrast ratio ${ratio.toStringAsFixed(2)} (AA: $meetsAA, AAA: $meetsAAA)');
  }

  static void checkTouchTargetSize(String label, Size size) {
    final meetsMinimum = size.width >= AccessibilityHelper.minimumTouchTargetSize &&
                        size.height >= AccessibilityHelper.minimumTouchTargetSize;
    
    print('$label: Size ${size.width}x${size.height} (Meets minimum: $meetsMinimum)');
  }
}