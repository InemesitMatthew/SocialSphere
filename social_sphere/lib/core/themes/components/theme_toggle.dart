import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:social_sphere/core/themes/theme_provider.dart';

/// A widget that shows an icon button to toggle the app's theme between light and dark modes.
///
/// Uses Riverpod to read the current ThemeData and to trigger toggling.
class ThemeToggle extends ConsumerWidget {
  const ThemeToggle({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the current theme data from the provider
    final theme = ref.watch(themeProvider);
    // Get the notifier to call toggleTheme()
    final themeNotifier = ref.read(themeProvider.notifier);

    // Determine which icon to display:
    // If the current theme is dark, display sun icon (to switch to light),
    // otherwise display moon icon (to switch to dark).
    final isDarkMode = theme.brightness == Brightness.dark;
    final icon =
        isDarkMode ? Icons.wb_sunny_rounded : Icons.nights_stay_rounded;

    return IconButton(
      icon: Icon(icon),
      onPressed: () {
        // Toggle theme when the button is pressed
        themeNotifier.toggleTheme();
      },
      tooltip: isDarkMode ? 'Switch to light mode' : 'Switch to dark mode',
    );
  }
}
