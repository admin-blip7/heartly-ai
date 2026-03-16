import 'package:flutter/material.dart';

class AppTheme {
  // Colors
  static const Color primary = Color(0xFF00BFA5);
  static const Color primaryLight = Color(0xFF64FFDA);
  static const Color primaryDark = Color(0xFF00897B);
  
  static const Color secondary = Color(0xFFFF8A80);
  static const Color secondaryLight = Color(0xFFFFCCBC);
  
  static const Color accent = Color(0xFFFFD54F);
  static const Color mint = Color(0xFFA5D6A7);
  static const Color lavender = Color(0xFFB39DDB);
  
  // Scores
  static const Color scoreExcellent = Color(0xFF00BFA5);
  static const Color scoreGood = Color(0xFF66BB6A);
  static const Color scoreFair = Color(0xFFFFB74D);
  static const Color scorePoor = Color(0xFFFF8A80);
  
  // Neutrals
  static const Color background = Color(0xFFFAFAFA);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textHint = Color(0xFF9E9E9E);
  
  // Spacing
  static const double space1 = 4.0;
  static const double space2 = 8.0;
  static const double space3 = 12.0;
  static const double space4 = 16.0;
  static const double space5 = 20.0;
  static const double space6 = 24.0;
  static const double space8 = 32.0;
  static const double space10 = 40.0;
  
  // Border Radius
  static const double radiusSm = 4.0;
  static const double radiusMd = 8.0;
  static const double radiusLg = 12.0;
  static const double radiusXl = 16.0;
  
  // Light Theme
  static ThemeData light = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.light(
      primary: primary,
      secondary: secondary,
      surface: surface,
      error: scorePoor,
    ),
    scaffoldBackgroundColor: background,
    appBarTheme: const AppBarTheme(
      backgroundColor: surface,
      foregroundColor: textPrimary,
      elevation: 0,
    ),
    cardTheme: CardTheme(
      color: surface,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radiusLg),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(
          horizontal: space6,
          vertical: space4,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusMd),
        ),
      ),
    ),
    fontFamily: 'Inter',
  );
  
  // Dark Theme
  static ThemeData dark = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.dark(
      primary: primaryLight,
      secondary: secondaryLight,
      surface: const Color(0xFF1E1E1E),
      error: scorePoor,
    ),
    scaffoldBackgroundColor: const Color(0xFF121212),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF1E1E1E),
      foregroundColor: Colors.white,
      elevation: 0,
    ),
    fontFamily: 'Inter',
  );
  
  // Helper methods
  static Color getScoreColor(int score) {
    if (score >= 90) return scoreExcellent;
    if (score >= 70) return scoreGood;
    if (score >= 50) return scoreFair;
    return scorePoor;
  }
}
