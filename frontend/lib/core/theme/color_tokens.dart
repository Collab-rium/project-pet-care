import 'package:flutter/material.dart';

/// Centralized color tokens that adapt to theme and brightness
/// This replaces the hardcoded AppColors static class
class ColorTokens {
  final ThemeMode themeMode;
  final String activeThemeId;

  ColorTokens({
    required this.themeMode,
    required this.activeThemeId,
  });

  // ==================== BRAND COLORS ====================
  
  /// Primary color - changes per theme
  /// Warm: Orange, Cool: Blue, Nature: Green
  Color get primary {
    switch (activeThemeId) {
      case 'cool':
        return Color(0xFF2196F3); // Blue
      case 'nature':
        return Color(0xFF4CAF50); // Green
      default: // warm
        return Color(0xFFFF8C42); // Orange
    }
  }

  Color get primaryLight {
    switch (activeThemeId) {
      case 'cool':
        return Color(0xFF64B5F6);
      case 'nature':
        return Color(0x66BB6A);
      default:
        return Color(0xFFFFAD70);
    }
  }

  Color get primaryDark {
    switch (activeThemeId) {
      case 'cool':
        return Color(0xFF1976D2);
      case 'nature':
        return Color(0xFF388E3C);
      default:
        return Color(0xFFE67832);
    }
  }

  // ==================== SECONDARY COLORS ====================
  
  Color get secondary {
    switch (activeThemeId) {
      case 'cool':
        return Color(0xFF00BCD4);
      case 'nature':
        return Color(0xFF00BCD4);
      default:
        return Color(0xFF00D4D4);
    }
  }

  Color get secondaryLight {
    switch (activeThemeId) {
      case 'cool':
        return Color(0xFF4DD0E1);
      case 'nature':
        return Color(0xFF4DD0E1);
      default:
        return Color(0xFF4DFFFF);
    }
  }

  // ==================== BACKGROUNDS & SURFACES ====================
  
  Color get background {
    if (themeMode == ThemeMode.dark) {
      return Color(0xFF121212);
    } else {
      switch (activeThemeId) {
        case 'cool':
          return Color(0xFFF5F9FC); // Cool white with blue tint
        case 'nature':
          return Color(0xFFF1F8F4); // Cool white with green tint
        default:
          return Color(0xFFFFF9F5); // Warm white
      }
    }
  }

  Color get surface {
    if (themeMode == ThemeMode.dark) {
      return Color(0xFF1E1E1E);
    } else {
      return Color(0xFFFFFFFF); // Pure white in light mode
    }
  }

  Color get surfaceVariant {
    if (themeMode == ThemeMode.dark) {
      return Color(0xFF2C2C2C);
    } else {
      switch (activeThemeId) {
        case 'cool':
          return Color(0xFFE3F2FD); // Light blue
        case 'nature':
          return Color(0xFFE8F5E9); // Light green
        default:
          return Color(0xFFFFF4ED); // Light orange
      }
    }
  }

  // ==================== TEXT COLORS ====================
  
  Color get textPrimary {
    return themeMode == ThemeMode.dark 
        ? Color(0xFFFFFFFF)
        : Color(0xFF2C2C2C);
  }

  Color get textSecondary {
    return themeMode == ThemeMode.dark 
        ? Color(0xFFB0B0B0)
        : Color(0xFF6B6B6B);
  }

  Color get textTertiary {
    return themeMode == ThemeMode.dark 
        ? Color(0xFF757575)
        : Color(0xFF9E9E9E);
  }

  Color get textOnPrimary => Color(0xFFFFFFFF);

  // ==================== SEMANTIC COLORS ====================
  
  Color get success => Color(0xFF4CAF50);
  Color get warning => Color(0xFFFFC107);
  Color get error => Color(0xFFF44336);
  Color get info => Color(0xFF2196F3);

  // ==================== BORDERS & DIVIDERS ====================
  
  Color get border {
    return themeMode == ThemeMode.dark 
        ? Color(0xFF404040)
        : Color(0xFFE0E0E0);
  }

  Color get divider {
    return themeMode == ThemeMode.dark 
        ? Color(0xFF2C2C2C)
        : Color(0xFFF0F0F0);
  }

  // ==================== UTILITY COLORS ====================
  
  Color get shadow {
    return themeMode == ThemeMode.dark 
        ? Color(0x33000000)
        : Color(0x1A000000);
  }

  Color get overlay {
    return Color(0x80000000);
  }

  // ==================== CATEGORY COLORS ====================
  
  Color get categoryFood => Color(0xFFEF5350); // Red
  Color get categoryMedical => Color(0xFF42A5F5); // Blue
  Color get categoryGrooming => Color(0xFF9575CD); // Purple
  Color get categoryToys => Color(0xFF4DB6AC); // Teal
  Color get categoryOther {
    return themeMode == ThemeMode.dark 
        ? Color(0xFF78909C)
        : Color(0xFF9E9E9E);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ColorTokens &&
          runtimeType == other.runtimeType &&
          themeMode == other.themeMode &&
          activeThemeId == other.activeThemeId;

  @override
  int get hashCode => themeMode.hashCode ^ activeThemeId.hashCode;
}
