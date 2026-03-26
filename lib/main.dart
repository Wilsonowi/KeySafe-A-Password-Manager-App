import 'package:flutter/material.dart';
import 'screens/lock_screen.dart';
import '../services/encryption_service.dart';

void main() {
  // Initialize the encryption service
  EncryptionService();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'KeySafe',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        // ── Fix 1: dark scaffold background so no white flash ──
        scaffoldBackgroundColor: const Color(0xFF0F172A),

        // ── Fix 2: custom page transition (fade instead of slide) ──
        pageTransitionsTheme: const PageTransitionsTheme(
          builders: {
            TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
            TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          },
        ),
      ),
      home: const LockScreen(),
    );
  }
}
