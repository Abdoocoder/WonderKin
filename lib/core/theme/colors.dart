// App Colors - Child-friendly, high contrast, accessible
import 'package:flutter/material.dart';

class AppColors {
  // Primary - Warm, friendly orange
  static const Color primary = Color(0xFFFF8C42);
  static const Color primaryLight = Color(0xFFFFB36B);
  static const Color primaryDark = Color(0xFFE67300);
  static const Color primaryContainer = Color(0xFFFFE5D0);
  
  // Secondary - Calm teal
  static const Color secondary = Color(0xFF26A69A);
  static const Color secondaryLight = Color(0xFF4FC3B7);
  static const Color secondaryDark = Color(0xFF00776D);
  static const Color secondaryContainer = Color(0xFFE0F2F1);
  
  // Tertiary - Playful purple
  static const Color tertiary = Color(0xFF9C27B0);
  static const Color tertiaryLight = Color(0xFFBA68C8);
  static const Color tertiaryDark = Color(0xFF7B1FA2);
  static const Color tertiaryContainer = Color(0xFFF3E5F5);
  
  // Success - Green
  static const Color success = Color(0xFF4CAF50);
  static const Color successLight = Color(0xFF81C784);
  static const Color successContainer = Color(0xFFE8F5E9);
  
  // Warning - Amber
  static const Color warning = Color(0xFFFFC107);
  static const Color warningContainer = Color(0xFFFFF8E1);
  
  // Error - Red (softer for kids)
  static const Color error = Color(0xFFE57373);
  static const Color errorContainer = Color(0xFFEF9A9A);
  
  // Surface colors
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF5F5F5);
  static const Color surfaceContainer = Color(0xFFEEEEEE);
  
  // Background
  static const Color background = Color(0xFFFAFAFA);
  
  // Text
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color onSecondary = Color(0xFFFFFFFF);
  static const Color onTertiary = Color(0xFFFFFFFF);
  static const Color onSurface = Color(0xFF1C1B1F);
  static const Color onSurfaceVariant = Color(0xFF49454F);
  static const Color onBackground = Color(0xFF1C1B1F);
  static const Color onError = Color(0xFFFFFFFF);
  
  // Outline
  static const Color outline = Color(0xFF79747E);
  static const Color outlineVariant = Color(0xFFCAC4D0);
  
  // Shadow
  static const Color shadow = Color(0x33000000);
  
  // Special kid-friendly colors
  static const Color starGold = Color(0xFFFFD600);
  static const Color starGoldGlow = Color(0xFFFFEB3B);
  static const Color confettiPink = Color(0xFFF06292);
  static const Color confettiBlue = Color(0xFF64B5F6);
  static const Color confettiGreen = Color(0xFF81C784);
  static const Color confettiOrange = Color(0xFFFFB74D);
  static const Color confettiPurple = Color(0xFFBA68C8);
  
  // Gradient presets
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, primaryLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient successGradient = LinearGradient(
    colors: [success, successLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient celebrationGradient = LinearGradient(
    colors: [confettiPink, confettiBlue, confettiGreen, confettiOrange, confettiPurple],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  // Dark theme colors
  static const Color darkPrimary = Color(0xFFFFB36B);
  static const Color darkSecondary = Color(0xFF4FC3B7);
  static const Color darkTertiary = Color(0xFFBA68C8);
  static const Color darkSurface = Color(0xFF1E1E1E);
  static const Color darkSurfaceVariant = Color(0xFF2D2D2D);
  static const Color darkBackground = Color(0xFF121212);
  static const Color darkOnSurface = Color(0xFFE6E1E5);
  static const Color darkOnSurfaceVariant = Color(0xFFCAC4D0);
  static const Color darkOutline = Color(0xFF938F99);
}