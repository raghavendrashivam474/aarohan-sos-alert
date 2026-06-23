// ============================================
// Aarohan SOS Alert
// File        : main.dart
// Description : App Entry Point
// ============================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'utils/constants.dart';
import 'screens/intro_screen.dart';

void main() async {
  // ----------------------------
  // Ensure Flutter Initialized
  // ----------------------------

  WidgetsFlutterBinding.ensureInitialized();

  // ----------------------------
  // Lock Orientation to Portrait
  // ----------------------------

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // ----------------------------
  // Set System UI Style
  // ----------------------------

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
  ),
  );

  runApp(const AarohanApp());
}

class AarohanApp extends StatelessWidget {
  const AarohanApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // ----------------------------
      // App Config
      // ----------------------------

      title: appName,
      debugShowCheckedModeBanner: false,

      // ----------------------------
      // Theme
      // ----------------------------

      theme: appTheme(),

      // ----------------------------
      // Entry Screen
      // ----------------------------

      home: const IntroScreen(),
    );
  }
}
