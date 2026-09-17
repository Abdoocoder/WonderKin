// Text Styles - Arabic-friendly, readable for kids
import 'package:flutter/material.dart';
import 'colors.dart';

class AppTextStyles {
  // Display styles (large titles)
  static const TextStyle displayLarge = TextStyle(
    fontFamily: 'Cairo',
    fontSize: 57,
    fontWeight: FontWeight.w700,
    height: 1.12,
    letterSpacing: -0.25,
    color: AppColors.onSurface,
  );
  
  static const TextStyle displayMedium = TextStyle(
    fontFamily: 'Cairo',
    fontSize: 45,
    fontWeight: FontWeight.w700,
    height: 1.16,
    letterSpacing: 0,
    color: AppColors.onSurface,
  );
  
  static const TextStyle displaySmall = TextStyle(
    fontFamily: 'Cairo',
    fontSize: 36,
    fontWeight: FontWeight.w600,
    height: 1.22,
    letterSpacing: 0,
    color: AppColors.onSurface,
  );
  
  // Headline styles
  static const TextStyle headlineLarge = TextStyle(
    fontFamily: 'Cairo',
    fontSize: 32,
    fontWeight: FontWeight.w700,
    height: 1.25,
    letterSpacing: 0,
    color: AppColors.onSurface,
  );
  
  static const TextStyle headlineMedium = TextStyle(
    fontFamily: 'Cairo',
    fontSize: 28,
    fontWeight: FontWeight.w600,
    height: 1.29,
    letterSpacing: 0,
    color: AppColors.onSurface,
  );
  
  static const TextStyle headlineSmall = TextStyle(
    fontFamily: 'Cairo',
    fontSize: 24,
    fontWeight: FontWeight.w600,
    height: 1.33,
    letterSpacing: 0,
    color: AppColors.onSurface,
  );
  
  // Title styles
  static const TextStyle titleLarge = TextStyle(
    fontFamily: 'Cairo',
    fontSize: 22,
    fontWeight: FontWeight.w600,
    height: 1.27,
    letterSpacing: 0,
    color: AppColors.onSurface,
  );
  
  static const TextStyle titleMedium = TextStyle(
    fontFamily: 'Cairo',
    fontSize: 18,
    fontWeight: FontWeight.w500,
    height: 1.50,
    letterSpacing: 0.15,
    color: AppColors.onSurface,
  );
  
  static const TextStyle titleSmall = TextStyle(
    fontFamily: 'Cairo',
    fontSize: 14,
    fontWeight: FontWeight.w500,
    height: 1.43,
    letterSpacing: 0.1,
    color: AppColors.onSurface,
  );
  
  // Body styles
  static const TextStyle bodyLarge = TextStyle(
    fontFamily: 'Cairo',
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.50,
    letterSpacing: 0.5,
    color: AppColors.onSurface,
  );
  
  static const TextStyle bodyMedium = TextStyle(
    fontFamily: 'Cairo',
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.43,
    letterSpacing: 0.25,
    color: AppColors.onSurfaceVariant,
  );
  
  static const TextStyle bodySmall = TextStyle(
    fontFamily: 'Cairo',
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 1.33,
    letterSpacing: 0.4,
    color: AppColors.onSurfaceVariant,
  );
  
  // Label styles
  static const TextStyle labelLarge = TextStyle(
    fontFamily: 'Cairo',
    fontSize: 14,
    fontWeight: FontWeight.w500,
    height: 1.43,
    letterSpacing: 0.1,
    color: AppColors.onSurface,
  );
  
  static const TextStyle labelMedium = TextStyle(
    fontFamily: 'Cairo',
    fontSize: 12,
    fontWeight: FontWeight.w500,
    height: 1.33,
    letterSpacing: 0.5,
    color: AppColors.onSurfaceVariant,
  );
  
  static const TextStyle labelSmall = TextStyle(
    fontFamily: 'Cairo',
    fontSize: 11,
    fontWeight: FontWeight.w500,
    height: 1.45,
    letterSpacing: 0.5,
    color: AppColors.onSurfaceVariant,
  );
  
  // Special kid-friendly styles
  static const TextStyle kidTitle = TextStyle(
    fontFamily: 'Cairo',
    fontSize: 28,
    fontWeight: FontWeight.w700,
    height: 1.3,
    letterSpacing: 0.5,
    color: AppColors.onSurface,
    shadows: [
      Shadow(
        offset: Offset(0, 2),
        blurRadius: 4,
        color: AppColors.shadow,
      ),
    ],
  );
  
  static const TextStyle kidBody = TextStyle(
    fontFamily: 'Cairo',
    fontSize: 18,
    fontWeight: FontWeight.w400,
    height: 1.6,
    letterSpacing: 0.3,
    color: AppColors.onSurface,
  );
  
  static const TextStyle kidButton = TextStyle(
    fontFamily: 'Cairo',
    fontSize: 18,
    fontWeight: FontWeight.w600,
    height: 1.4,
    letterSpacing: 0.5,
    color: AppColors.onPrimary,
  );
  
  static const TextStyle kidNumber = TextStyle(
    fontFamily: 'Cairo',
    fontSize: 48,
    fontWeight: FontWeight.w700,
    height: 1.2,
    letterSpacing: 0,
    color: AppColors.primary,
  );
  
  // Arabic-optimized styles (using Amiri for traditional feel)
  static const TextStyle arabicTitle = TextStyle(
    fontFamily: 'Amiri',
    fontSize: 32,
    fontWeight: FontWeight.w700,
    height: 1.5,
    letterSpacing: 0,
    color: AppColors.onSurface,
  );
  
  static const TextStyle arabicBody = TextStyle(
    fontFamily: 'Amiri',
    fontSize: 20,
    fontWeight: FontWeight.w400,
    height: 1.8,
    letterSpacing: 0,
    color: AppColors.onSurface,
  );
  
  static const TextStyle arabicButton = TextStyle(
    fontFamily: 'Cairo',
    fontSize: 20,
    fontWeight: FontWeight.w600,
    height: 1.4,
    letterSpacing: 0.5,
    color: AppColors.onPrimary,
  );
  
  // Helper methods for RTL
  static TextStyle rtl(TextStyle style) {
    return style.copyWith(
      fontFamily: 'Cairo', // Cairo supports RTL well
    );
  }
}