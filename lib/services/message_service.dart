// ============================================
// Aarohan SOS Alert
// File        : services/message_service.dart
// Description : Emergency Message Builder Service
// Sprint      : 2 - Emergency Dispatch Engine
// ============================================

import '../models/user_model.dart';

// ----------------------------
// Message Format Types
// ----------------------------

enum MessageFormat {
  standard,
  short,
  detailed,
  medical,
}

// ----------------------------
// Message Service
// ----------------------------

class MessageService {
  // ----------------------------
  // Singleton Setup
  // ----------------------------

  static final MessageService _instance = MessageService._internal();
  factory MessageService() => _instance;
  MessageService._internal();

  // ----------------------------
  // Build Emergency Message (Main Entry Point)
  // ----------------------------

  String buildMessage({
    required UserModel user,
    required String mapLink,
    MessageFormat format = MessageFormat.standard,
  }) {
    switch (format) {
      case MessageFormat.short:
        return _buildShortMessage(user, mapLink);
      case MessageFormat.detailed:
        return _buildDetailedMessage(user, mapLink);
      case MessageFormat.medical:
        return _buildMedicalMessage(user, mapLink);
      case MessageFormat.standard:
        return _buildStandardMessage(user, mapLink);
    }
  }

  // ----------------------------
  // Standard Message Format
  // ----------------------------

  String _buildStandardMessage(UserModel user, String mapLink) {
    return '''🚨 EMERGENCY ALERT!

${user.name} needs immediate assistance.

📍 Location:
$mapLink

📞 Contact:
${user.phone}

Please respond immediately.

-- Sent via Aarohan SOS Alert --''';
  }

  // ----------------------------
  // Short Message Format
  // ----------------------------

  String _buildShortMessage(UserModel user, String mapLink) {
    return '🚨 EMERGENCY: ${user.name} needs help. Location: $mapLink';
  }

  // ----------------------------
  // Detailed Message Format
  // ----------------------------

  String _buildDetailedMessage(UserModel user, String mapLink) {
    final buffer = StringBuffer();

    buffer.writeln('🚨 EMERGENCY ALERT!');
    buffer.writeln('');
    buffer.writeln('${user.name} needs immediate assistance.');
    buffer.writeln('');

    // Personal Info
    buffer.writeln('👤 Personal Information:');
    buffer.writeln('   Name: ${user.name}');
    buffer.writeln('   Phone: ${user.phone}');

    if (user.age.isNotEmpty) {
      buffer.writeln('   Age: ${user.age}');
    }

    if (user.bloodGroup.isNotEmpty && user.bloodGroup != 'Unknown') {
      buffer.writeln('   Blood Group: ${user.bloodGroup}');
    }

    if (user.address.isNotEmpty) {
      buffer.writeln('   Address: ${user.address}');
    }

    buffer.writeln('');

    // Location
    buffer.writeln('📍 Current Location:');
    buffer.writeln('   $mapLink');
    buffer.writeln('');

    // Medical Info
    if (user.medicalConditions.isNotEmpty ||
        user.allergies.isNotEmpty) {
      buffer.writeln('⚕️ Medical Information:');

      if (user.medicalConditions.isNotEmpty) {
        buffer.writeln('   Conditions: ${user.medicalConditions}');
      }

      if (user.allergies.isNotEmpty) {
        buffer.writeln('   Allergies: ${user.allergies}');
      }

      buffer.writeln('');
    }

    buffer.writeln('⚠️ This is an automated emergency alert.');
    buffer.writeln('Please respond immediately.');
    buffer.writeln('');
    buffer.writeln('-- Sent via Aarohan SOS Alert --');

    return buffer.toString();
  }

  // ----------------------------
  // Medical Emergency Format
  // ----------------------------

  String _buildMedicalMessage(UserModel user, String mapLink) {
    final buffer = StringBuffer();

    buffer.writeln('🚨 MEDICAL EMERGENCY ALERT!');
    buffer.writeln('');
    buffer.writeln('${user.name} requires urgent medical attention.');
    buffer.writeln('');

    buffer.writeln('👤 Patient Details:');
    buffer.writeln('   Name: ${user.name}');

    if (user.age.isNotEmpty) {
      buffer.writeln('   Age: ${user.age}');
    }

    if (user.bloodGroup.isNotEmpty && user.bloodGroup != 'Unknown') {
      buffer.writeln('   Blood Group: ${user.bloodGroup}');
    }

    buffer.writeln('   Contact: ${user.phone}');
    buffer.writeln('');

    if (user.medicalConditions.isNotEmpty) {
      buffer.writeln('⚕️ Medical Conditions:');
      buffer.writeln('   ${user.medicalConditions}');
      buffer.writeln('');
    }

    if (user.allergies.isNotEmpty) {
      buffer.writeln('⚠️ Allergies:');
      buffer.writeln('   ${user.allergies}');
      buffer.writeln('');
    }

    buffer.writeln('📍 Location:');
    buffer.writeln('   $mapLink');
    buffer.writeln('');

    buffer.writeln('-- Sent via Aarohan SOS Alert --');

    return buffer.toString();
  }

  // ----------------------------
  // Build Google Maps Link
  // ----------------------------

  String buildMapLink(double latitude, double longitude) {
    return 'https://maps.google.com/?q=$latitude,$longitude';
  }

  // ----------------------------
  // Character Count (SMS Optimization)
  // ----------------------------

  int getCharacterCount(String message) => message.length;

  int getSmsSegmentCount(String message) {
    final length = message.length;
    if (length <= 160) return 1;
    return (length / 153).ceil();
  }

  // ----------------------------
  // Validation
  // ----------------------------

  bool isValidMessage(String message) {
    return message.isNotEmpty && message.length <= 1600;
  }
}