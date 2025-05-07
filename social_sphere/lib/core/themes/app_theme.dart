import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  // App trademark color
  static const Color primary = Color(0xFF000A22);
  static const Color secondary = Color(0xFF153075);
  static const Color accent = Color(0xFFF9B023);
  static const Color textDark = Color(0xFF1E222B);
  static const Color textLight = Color(0xFFF8F9FB);

  // Optional primary swatch (for Material widgets using swatches)
  static const MaterialColor primarySwatch = MaterialColor(
    0xFF000A22,
    <int, Color>{
      50: Color(0xFFE5E6E8),
      100: Color(0xFFB2B5BC),
      200: Color(0xFF7F8490),
      300: Color(0xFF545B6B),
      400: Color(0xFF2A3246),
      500: Color(0xFF000A22),
      600: Color(0xFF00091E),
      700: Color(0xFF00081B),
      800: Color(0xFF000717),
      900: Color(0xFF000614),
    },
  );
}

// Light theme
final ThemeData lightMode = ThemeData(
  brightness: Brightness.light,
  primarySwatch: AppColors.primarySwatch,
  colorScheme: ColorScheme.light(
    primary: AppColors.primary,
    secondary: AppColors.accent,
    surface: Colors.grey.shade200, // Light surface color
    // background: Colors.white,        // General background
    onPrimary: Colors.white,
    onSecondary: AppColors.textDark,
    onSurface: AppColors.textDark,
    error: Colors.red,
    onError: Colors.white,
  ),
);

// Dark theme
final ThemeData darkMode = ThemeData(
  brightness: Brightness.dark,
  primarySwatch: AppColors.primarySwatch,
  colorScheme: ColorScheme.dark(
    primary: AppColors.primary,
    secondary: AppColors.accent,
    // surface: const Color(0xFF121212), // Dark surface color
    surface: const Color(0xFF000A22), // Dark background matches primary
    onPrimary: Colors.white,
    onSecondary: AppColors.textLight,
    onSurface: AppColors.textLight,
    error: Colors.red.shade400,
    onError: Colors.black,
  ),
);

class AppTextStyles {
  static TextStyle heading1 = GoogleFonts.manrope(
    fontSize: 28,
    fontWeight: FontWeight.w800,
  );

  static TextStyle bodyText = GoogleFonts.manrope(
    fontSize: 16,
    height: 1.5,
  );
  
  // Add more text styles as needed
}
