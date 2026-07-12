// ============================================
// Aarohan SOS Alert
// File        : models/emergency/escalation_result.dart
// Description : Emergency Escalation Result Model
// Sprint      : 4 - Emergency Dispatch Reliability & Official Escalation
// ============================================

import 'emergency_type.dart';

// ----------------------------
// Escalation Status Enum
// ----------------------------

/// The outcome of an official emergency escalation attempt.
enum EscalationStatus {
  /// Escalation pathway was successfully initiated (dialer opened, etc.)
  initiated,

  /// User cancelled the escalation at confirmation step.
  cancelledByUser,

  /// Escalation was aborted before reaching the agency gateway.
  aborted,

  /// Platform or system prevented escalation launch.
  failed,

  /// Agency escalation is not supported on this device/platform.
  unsupported,
}

extension EscalationStatusExt on EscalationStatus {
  String get label {
    switch (this) {
      case EscalationStatus.initiated:
        return 'Initiated';
      case EscalationStatus.cancelledByUser:
        return 'Cancelled';
      case EscalationStatus.aborted:
        return 'Aborted';
      case EscalationStatus.failed:
        return 'Failed';
      case EscalationStatus.unsupported:
        return 'Unsupported';
    }
  }

  bool get isPositive => this == EscalationStatus.initiated;
}

// ----------------------------
// Agency Enum
// ----------------------------

/// The official emergency agency involved in the escalation.
///
/// Currently supports India's ERSS 112. Future values may include
/// state-specific agencies or campus security systems.
enum EmergencyAgency {
  /// India's Emergency Response Support System (unified 112).
  erss112India,

  /// No specific agency (generic emergency contact).
  none,
}

extension EmergencyAgencyExt on EmergencyAgency {
  String get label {
    switch (this) {
      case EmergencyAgency.erss112India:
        return 'ERSS 112 (India)';
      case EmergencyAgency.none:
        return 'None';
    }
  }

  String get shortLabel {
    switch (this) {
      case EmergencyAgency.erss112India:
        return '112 India';
      case EmergencyAgency.none:
        return 'None';
    }
  }

  String get emergencyNumber {
    switch (this) {
      case EmergencyAgency.erss112India:
        return '112';
      case EmergencyAgency.none:
        return '';
    }
  }

  String get description {
    switch (this) {
      case EmergencyAgency.erss112India:
        return 'India\'s unified emergency response system for police, '
            'fire, and medical emergencies.';
      case EmergencyAgency.none:
        return 'No official agency configured.';
    }
  }
}

// ----------------------------
// Escalation Result Model
// ----------------------------

/// Structured result of an emergency escalation attempt.
///
/// This isolates escalation outcomes from platform specifics and provides
/// truthful data for UI display.
///
/// IMPORTANT: This result reflects only what actually happened technically.
/// - `initiated` means the pathway (e.g., dialer) was opened
/// - It does NOT mean the agency was notified
/// - It does NOT mean help is on the way
///
/// The user must complete the action (e.g., tap call button) for actual
/// agency contact to occur.
class EscalationResult {
  // ----------------------------
  // Fields
  // ----------------------------

  final bool success;
  final EscalationStatus status;
  final EmergencyAgency agency;
  final EmergencyType emergencyType;
  final String? emergencyNumber;
  final String? pathwayDescription;
  final String? errorMessage;
  final DateTime timestamp;
  final Map<String, dynamic> metadata;

  // ----------------------------
  // Constructor
  // ----------------------------

  EscalationResult({
    required this.success,
    required this.status,
    required this.agency,
    required this.emergencyType,
    this.emergencyNumber,
    this.pathwayDescription,
    this.errorMessage,
    DateTime? timestamp,
    this.metadata = const {},
  }) : timestamp = timestamp ?? DateTime.now();

  // ----------------------------
  // Factory Constructors
  // ----------------------------

  /// Successful escalation - pathway opened for user to complete.
  factory EscalationResult.initiated({
    required EmergencyAgency agency,
    required EmergencyType emergencyType,
    required String emergencyNumber,
    String? pathwayDescription,
    Map<String, dynamic> metadata = const {},
  }) {
    return EscalationResult(
      success: true,
      status: EscalationStatus.initiated,
      agency: agency,
      emergencyType: emergencyType,
      emergencyNumber: emergencyNumber,
      pathwayDescription: pathwayDescription ??
          '$emergencyNumber calling pathway opened',
      metadata: metadata,
    );
  }

  /// User cancelled at confirmation step.
  factory EscalationResult.cancelled({
    required EmergencyAgency agency,
    required EmergencyType emergencyType,
  }) {
    return EscalationResult(
      success: false,
      status: EscalationStatus.cancelledByUser,
      agency: agency,
      emergencyType: emergencyType,
      errorMessage: 'User cancelled the escalation',
    );
  }

  /// Escalation failed due to platform or technical issue.
  factory EscalationResult.failed({
    required EmergencyAgency agency,
    required EmergencyType emergencyType,
    required String errorMessage,
    String? emergencyNumber,
  }) {
    return EscalationResult(
      success: false,
      status: EscalationStatus.failed,
      agency: agency,
      emergencyType: emergencyType,
      emergencyNumber: emergencyNumber,
      errorMessage: errorMessage,
    );
  }

  /// Escalation is not supported on this platform/device.
  factory EscalationResult.unsupported({
    required EmergencyAgency agency,
    required EmergencyType emergencyType,
    required String reason,
  }) {
    return EscalationResult(
      success: false,
      status: EscalationStatus.unsupported,
      agency: agency,
      emergencyType: emergencyType,
      errorMessage: reason,
    );
  }

  /// Escalation aborted before reaching the agency gateway.
  factory EscalationResult.aborted({
    required EmergencyAgency agency,
    required EmergencyType emergencyType,
    required String reason,
  }) {
    return EscalationResult(
      success: false,
      status: EscalationStatus.aborted,
      agency: agency,
      emergencyType: emergencyType,
      errorMessage: reason,
    );
  }

  // ----------------------------
  // Truthful Summary
  // ----------------------------

  /// Returns a truthful summary of what actually happened.
  ///
  /// This deliberately avoids claiming "notified" or "dispatched" since
  /// we can only verify the pathway was opened, not that help was received.
  String get truthfulSummary {
    switch (status) {
      case EscalationStatus.initiated:
        return '${agency.shortLabel} contact pathway opened. '
            'Complete the call to speak to the operator.';

      case EscalationStatus.cancelledByUser:
        return 'Escalation cancelled by user';

      case EscalationStatus.aborted:
        return 'Escalation aborted: ${errorMessage ?? 'Unknown reason'}';

      case EscalationStatus.failed:
        return 'Escalation could not be initiated. '
            'Please dial ${emergencyNumber ?? agency.emergencyNumber} manually.';

      case EscalationStatus.unsupported:
        return 'Emergency escalation not supported on this device';
    }
  }

  /// Returns the emergency number user should call if escalation fails.
  ///
  /// Used to show fallback number in error dialogs.
  String get fallbackNumber => emergencyNumber ?? agency.emergencyNumber;

  // ----------------------------
  // Serialization
  // ----------------------------

  Map<String, dynamic> toMap() {
    return {
      'success': success,
      'status': status.name,
      'agency': agency.name,
      'emergencyType': emergencyType.name,
      'emergencyNumber': emergencyNumber,
      'pathwayDescription': pathwayDescription,
      'errorMessage': errorMessage,
      'timestamp': timestamp.toIso8601String(),
      'metadata': metadata,
    };
  }

  @override
  String toString() {
    return 'EscalationResult('
        'success: $success, '
        'status: ${status.label}, '
        'agency: ${agency.shortLabel}, '
        'type: ${emergencyType.label})';
  }
}