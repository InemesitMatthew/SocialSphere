import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:social_sphere/core/constants/route_constants.dart';
import 'package:social_sphere/core/themes/components/theme_toggle.dart';
import 'package:social_sphere/features/auth/controllers/auth_controller.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  Future<void> _signOut(BuildContext context, WidgetRef ref) async {
    try {
      // Show loading indicator
      final scaffoldMessenger = ScaffoldMessenger.of(context);
      final navigator = Navigator.of(context);

      // Optional loading indicator
      scaffoldMessenger.showSnackBar(
        const SnackBar(
          content: Text('Signing out...'),
          duration: Duration(seconds: 1),
        ),
      );

      // Perform sign out
      await ref.read(authControllerProvider.notifier).signOut();

      // Navigate to login screen after successful sign out
      if (context.mounted) {
        navigator.pushReplacementNamed(RouteConstants.login);
      }
    } catch (e) {
      // Handle errors gracefully
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to sign out: ${e.toString()}'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: const Text('Home'),
        actions: [
          const ThemeToggle(),
          IconButton(
            icon: const Icon(Icons.logout_outlined),
            tooltip: 'Sign out',
            onPressed: () => _signOut(context, ref),
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Welcome to Social Sphere!'),
          ],
        ),
      ),
    );
  }
}
