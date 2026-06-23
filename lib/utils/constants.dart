// ============================================
// Aarohan SOS Alert
// File        : utils/constants.dart
// Description : App Constants and Theme Colors
// ============================================

import 'package:flutter/material.dart';

// ----------------------------
// App Info
// ----------------------------

const String appName = 'Aarohan';
const String appFullName = 'Aarohan SOS Alert';
const String appTagline = 'Help. Anytime. Anywhere.';
const String appDescription =
    'Aarohan SOS Alert helps users quickly notify trusted contacts during emergencies through instant alerts and location sharing.';

// ----------------------------
// Theme Colors
// ----------------------------

const Color primaryRed = Color(0xFFD32F2F);
const Color darkRed = Color(0xFFB71C1C);
const Color lightRed = Color(0xFFEF5350);

const Color primaryNavy = Color(0xFF0D1B2A);
const Color darkNavy = Color(0xFF050D14);
const Color lightNavy = Color(0xFF1B2E45);

const Color whiteColor = Color(0xFFFFFFFF);
const Color lightGrey = Color(0xFFF5F5F5);
const Color mediumGrey = Color(0xFF9E9E9E);
const Color darkGrey = Color(0xFF424242);

// ----------------------------
// Text Styles
// ----------------------------

const TextStyle headingStyle = TextStyle(
  fontSize: 28,
  fontWeight: FontWeight.bold,
  color: whiteColor,
  letterSpacing: 1.2,
);

const TextStyle subHeadingStyle = TextStyle(
  fontSize: 18,
  fontWeight: FontWeight.w600,
  color: whiteColor,
  letterSpacing: 0.8,
);

const TextStyle bodyStyle = TextStyle(
  fontSize: 14,
  fontWeight: FontWeight.normal,
  color: whiteColor,
);

const TextStyle taglineStyle = TextStyle(
  fontSize: 16,
  fontWeight: FontWeight.w400,
  color: lightRed,
  letterSpacing: 1.5,
  fontStyle: FontStyle.italic,
);

// ----------------------------
// Spacing
// ----------------------------

const double paddingSmall = 8.0;
const double paddingMedium = 16.0;
const double paddingLarge = 24.0;
const double paddingXLarge = 32.0;

// ----------------------------
// SOS Button
// ----------------------------

const double sosBtnSize = 200.0;
const double sosBtnInnerSize = 160.0;

// ----------------------------
// Contact Limits
// ----------------------------

const int maxContacts = 5;
const int minContacts = 1;

// ----------------------------
// SharedPreferences Keys
// ----------------------------

const String keyUserName = 'user_name';
const String keyUserPhone = 'user_phone';
const String keyUserAge = 'user_age';
const String keyUserBloodGroup = 'user_blood_group';
const String keyUserAddress = 'user_address';
const String keyUserMedical = 'user_medical';
const String keyUserAllergies = 'user_allergies';
const String keyContacts = 'emergency_contacts';
const String keyIsSetupDone = 'is_setup_done';

// ----------------------------
// Blood Group Options
// ----------------------------

const List<String> bloodGroups = [
  'A+', 'A-',
  'B+', 'B-',
  'AB+', 'AB-',
  'O+', 'O-',
  'Unknown',
];

// ----------------------------
// Relationship Options
// ----------------------------

const List<String> relationships = [
  'Father',
  'Mother',
  'Spouse',
  'Sibling',
  'Friend',
  'Relative',
  'Colleague',
  'Neighbor',
  'Doctor',
  'Other',
];

// ----------------------------
// Emergency Message Template
// ----------------------------

String buildEmergencyMessage(String userName, String locationLink) {
  return '''🚨 EMERGENCY ALERT!

$userName needs immediate assistance.

📍 Location:
$locationLink

Please contact immediately.

-- Sent via Aarohan SOS Alert --''';
}

// ----------------------------
// Google Maps Link Builder
// ----------------------------

String buildMapLink(double latitude, double longitude) {
  return 'https://maps.google.com/?q=$latitude,$longitude';
}

// ----------------------------
// App Theme
// ----------------------------

ThemeData appTheme() {
  return ThemeData(
    primaryColor: primaryRed,
    scaffoldBackgroundColor: primaryNavy,
    fontFamily: 'Roboto',
    appBarTheme: const AppBarTheme(
      backgroundColor: darkNavy,
      foregroundColor: whiteColor,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: whiteColor,
        letterSpacing: 1.0,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryRed,
        foregroundColor: whiteColor,
        padding: const EdgeInsets.symmetric(
          horizontal: 32,
          vertical: 14,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.0,
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: lightNavy,
      labelStyle: const TextStyle(color: mediumGrey),
      hintStyle: const TextStyle(color: mediumGrey),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: lightNavy),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: primaryRed, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: lightRed),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: primaryRed, width: 2),
      ),
    ),
    colorScheme: const ColorScheme.dark(
      primary: primaryRed,
      secondary: lightRed,
      surface: lightNavy,
      error: lightRed,
    ),
  );
}