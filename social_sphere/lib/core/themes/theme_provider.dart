import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:social_sphere/core/themes/app_theme.dart';

/// A [StateNotifierProvider] that exposes the current [ThemeData]
/// and allows toggling between light and dark themes.
final themeProvider = StateNotifierProvider<ThemeNotifier, ThemeData>((ref) {
  return ThemeNotifier();
});

class ThemeNotifier extends StateNotifier<ThemeData> {
  ThemeNotifier() : super(darkMode); // Start in dark mode

  /// Toggles between light and dark themes.
  void toggleTheme() {
    state = state.brightness == Brightness.dark ? lightMode : darkMode;
  }
}
