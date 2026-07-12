// ============================================
// Aarohan SOS Alert
// File        : models/emergency/emergency_type.dart
// Description : Emergency Category Model
// Sprint      : 4 - Emergency Dispatch Reliability & Official Escalation
// ============================================

// ----------------------------
// Emergency Type Enum
// ----------------------------

/// Categorizes the nature of an emergency.
///
/// This is used primarily during official escalation to help route
/// the emergency to the appropriate response context.
///
/// Note: The specific emergency category does not automatically dispatch
/// to different agencies. India's ERSS 112 handles all emergency types
/// through a single unified number.
enum EmergencyType {
  /// Unspecified or general emergency situation.
  general,

  /// Medical emergency requiring ambulance or medical response.
  medical,

  /// Police response required (crime, threat, harassment).
  police,

  /// Fire emergency requiring fire brigade response.
  fire,

  /// Immediate threat to life (accident, assault, life-threatening).
  threatToLife,
}

// ----------------------------
// Extensions
// ----------------------------

extension EmergencyTypeExt on EmergencyType {
  /// Human-readable label for UI display.
  String get label {
    switch (this) {
      case EmergencyType.general:
        return 'General Emergency';
      case EmergencyType.medical:
        return 'Medical';
      case EmergencyType.police:
        return 'Police';
      case EmergencyType.fire:
        return 'Fire';
      case EmergencyType.threatToLife:
        return 'Immediate Threat';
    }
  }

  /// Short label for compact display (chips, badges).
  String get shortLabel {
    switch (this) {
      case EmergencyType.general:
        return 'General';
      case EmergencyType.medical:
        return 'Medical';
      case EmergencyType.police:
        return 'Police';
      case EmergencyType.fire:
        return 'Fire';
      case EmergencyType.threatToLife:
        return 'Threat';
    }
  }

  /// Description for user education.
  String get description {
    switch (this) {
      case EmergencyType.general:
        return 'Unspecified emergency requiring immediate assistance';
      case EmergencyType.medical:
        return 'Illness, injury, or medical crisis requiring ambulance';
      case EmergencyType.police:
        return 'Crime, harassment, theft, or safety threat requiring police';
      case EmergencyType.fire:
        return 'Fire, gas leak, or hazard requiring fire brigade';
      case EmergencyType.threatToLife:
        return 'Immediate danger to life or serious accident';
    }
  }

  /// Emoji indicator for visual identification.
  String get emoji {
    switch (this) {
      case EmergencyType.general:
        return '🚨';
      case EmergencyType.medical:
        return '🏥';
      case EmergencyType.police:
        return '👮';
      case EmergencyType.fire:
        return '🔥';
      case EmergencyType.threatToLife:
        return '⚠️';
    }
  }

  /// Priority order (lower = higher priority).
  /// Used for sorting or default selection.
  int get priorityOrder {
    switch (this) {
      case EmergencyType.threatToLife:
        return 1;
      case EmergencyType.medical:
        return 2;
      case EmergencyType.fire:
        return 3;
      case EmergencyType.police:
        return 4;
      case EmergencyType.general:
        return 5;
    }
  }

  /// Serialization to string (for storage / JSON).
  String get code => name;

  /// Deserialization from string.
  static EmergencyType fromCode(String? code) {
    if (code == null) return EmergencyType.general;
    return EmergencyType.values.firstWhere(
      (t) => t.name == code,
      orElse: () => EmergencyType.general,
    );
  }

  /// Returns all types sorted by priority.
  static List<EmergencyType> get allByPriority {
    final list = List<EmergencyType>.from(EmergencyType.values);
    list.sort((a, b) => a.priorityOrder.compareTo(b.priorityOrder));
    return list;
  }
}

// ----------------------------
// Escalation Wording Helper
// ----------------------------

/// Provides truthful UI wording for escalation based on emergency type.
///
/// IMPORTANT: This class enforces truthful wording per Sprint 4 principle.
/// It never claims "notified" or "dispatched" — only what actually happened.
class EscalationWording {
  /// Returns the confirmation dialog title for the given type.
  static String confirmationTitle(EmergencyType type) {
    switch (type) {
      case EmergencyType.medical:
        return 'Contact Emergency Services (Medical)?';
      case EmergencyType.police:
        return 'Contact Emergency Services (Police)?';
      case EmergencyType.fire:
        return 'Contact Emergency Services (Fire)?';
      case EmergencyType.threatToLife:
        return 'Contact Emergency Services (Urgent)?';
      case EmergencyType.general:
        return 'Contact Emergency Services?';
    }
  }

  /// Returns the confirmation dialog body.
  ///
  /// Always emphasizes that this initiates contact, not automatic dispatch.
  static String confirmationBody(EmergencyType type) {
    return 'This will open the official 112 emergency contact pathway. '
        'Use 112 only for genuine emergencies. '
        '\n\nYou will need to describe your ${type.shortLabel.toLowerCase()} '
        'emergency to the operator.';
  }

  /// Returns the post-launch status message.
  ///
  /// Truthful wording: Only says what actually happened.
  static String launchStatus(bool success) {
    if (success) {
      return '112 calling pathway opened';
    }
    return 'Emergency contact could not be initiated';
  }

  /// Returns detailed post-launch description.
  static String launchDescription(bool success) {
    if (success) {
      return 'The dialer has been opened with 112. '
          'Tap the call button to speak to the emergency operator.';
    }
    return 'Please dial 112 manually from your phone to contact emergency services.';
  }
}