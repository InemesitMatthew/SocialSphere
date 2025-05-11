import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:social_sphere/core/themes/theme_provider.dart';
import 'package:social_sphere/features/auth/views/auth_wrapper.dart';
import 'package:social_sphere/features/home/home_screen.dart';
import 'package:social_sphere/features/splash/splash_screen.dart';
import 'package:social_sphere/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Initialize Hive for local storage
  await Hive.initFlutter();
  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      theme: ref.watch(themeProvider),
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/home': (context) => const HomeScreen(),
        '/auth': (context) => AuthWrapper(child: const HomeScreen()),
      },
      debugShowCheckedModeBanner: false,
    );
  }
}
