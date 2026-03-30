import 'package:flutter/material.dart';

/// App color palette - Warm theme inspired by Golden Companion
/// Primary: Warm Orange for pet care warmth
/// Secondary: Teal/Cyan for health and vitality
/// Accents: Purple, Pink, Blue for variety
class AppColors {
  // Primary Colors
  static const Color primary = Color(0xFFFF8C42); // Warm Orange
  static const Color primaryLight = Color(0xFFFFAD70);
  static const Color primaryDark = Color(0xFFE67929);
  
  // Secondary Colors
  static const Color secondary = Color(0xFF00D4D4); // Cyan
  static const Color secondaryLight = Color(0xFF4DFFFF);
  static const Color secondaryDark = Color(0xFF00A0A0);
  
  // Accent Colors
  static const Color accent1 = Color(0xFF9C27B0); // Purple
  static const Color accent2 = Color(0xFFE91E63); // Pink
  static const Color accent3 = Color(0xFF2196F3); // Blue
  
  // Neutral Colors (Light Mode)
  static const Color backgroundLight = Color(0xFFFAFAFA);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color cardLight = Color(0xFFFFFFFF);
  
  // Neutral Colors (Dark Mode)
  static const Color backgroundDark = Color(0xFF121212);
  static const Color surfaceDark = Color(0xFF1E1E1E);
  static const Color cardDark = Color(0xFF2C2C2C);
  
  // Text Colors (Light Mode)
  static const Color textPrimaryLight = Color(0xFF212121);
  static const Color textSecondaryLight = Color(0xFF757575);
  static const Color textDisabledLight = Color(0xFFBDBDBD);
  
  // Text Colors (Dark Mode)
  static const Color textPrimaryDark = Color(0xFFFFFFFF);
  static const Color textSecondaryDark = Color(0xFFB0B0B0);
  static const Color textDisabledDark = Color(0xFF616161);
  
  // Semantic Colors
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFFC107);
  static const Color error = Color(0xFFF44336);
  static const Color info = Color(0xFF2196F3);
  
  // Functional Colors
  static const Color divider = Color(0xFFE0E0E0);
  static const Color dividerDark = Color(0xFF424242);
  static const Color shadow = Color(0x1A000000);
  static const Color overlay = Color(0x80000000);
  
  // Category Colors (for expenses, reminders, etc.)
  static const Color categoryFood = Color(0xFFFF6B6B);
  static const Color categoryMedical = Color(0xFF4ECDC4);
  static const Color categoryGrooming = Color(0xFFFFA07A);
  static const Color categoryToys = Color(0xFF95E1D3);
  static const Color categoryOther = Color(0xFFB39DDB);
}
