// ============================================
// Aarohan SOS Alert
// File        : services/emergency_agency/emergency_agency_gateway.dart
// Description : Abstract Emergency Agency Gateway
// Sprint      : 4 - Emergency Dispatch Reliability & Official Escalation
// ============================================

import 'dart:developer' as developer;
import '../../models/emergency/emergency_type.dart';
import '../../models/emergency/escalation_result.dart';

// ----------------------------
// Escalation Request
// ----------------------------

/// A structured request for emergency agency escalation.
///
/// This carries all context the agency gateway needs to attempt escalation.
class EscalationRequest {
  final EmergencyType emergencyType;
  final String? userDescription;
  final double? latitude;
  final double? longitude;
  final String? userPhone;
  final Map<String, dynamic> metadata;

  const EscalationRequest({
    required this.emergencyType,
    this.userDescription,
    this.latitude,
    this.longitude,
    this.userPhone,
    this.metadata = const {},
  });

  bool get hasLocation => latitude != null && longitude != null;

  Map<String, dynamic> toMap() {
    return {
      'emergencyType': emergencyType.name,
      'userDescription': userDescription,
      'latitude': latitude,
      'longitude': longitude,
      'userPhone': userPhone,
      'metadata': metadata,
    };
  }
}

// ----------------------------
// Escalation Preview
// ----------------------------

/// Preview information shown to the user BEFORE actual escalation.
///
/// This lets the UI display what will happen so the user can make
/// an informed confirmation decision.
class EscalationPreview {
  final EmergencyAgency agency;
  final String emergencyNumber;
  final String agencyName;
  final String pathwayDescription;
  final String userAction;
  final List<String> warnings;

  const EscalationPreview({
    required this.agency,
    required this.emergencyNumber,
    required this.agencyName,
    required this.pathwayDescription,
    required this.userAction,
    this.warnings = const [],
  });
}

// ----------------------------
// Emergency Agency Gateway Base
// ----------------------------

/// Abstract base for all emergency agency gateways.
///
/// This is the architectural boundary between Aarohan and official
/// emergency response systems (like India's ERSS 112).
///
/// Purpose:
/// - Isolate official escalation pathways from contact dispatch
/// - Enforce truthful communication with users
/// - Provide extensibility for future agencies
/// - Never simulate or fake agency integration
///
/// Every concrete gateway MUST:
/// - Return truthful EscalationResult (never claim unverified success)
/// - Handle platform limitations gracefully
/// - Provide fallback information (emergency number)
/// - Never bypass Android safety controls
///
/// Every concrete gateway MUST NOT:
/// - Send data to unofficial APIs claiming to be the agency
/// - Claim "agency notified" without verification
/// - Perform silent background escalation
/// - Auto-escalate without explicit user confirmation
abstract class EmergencyAgencyGateway {
  // ----------------------------
  // Required Properties
  // ----------------------------

  /// The emergency agency this gateway represents.
  EmergencyAgency get agency;

  /// Human-readable name.
  String get name;

  /// The official emergency number for this agency.
  String get emergencyNumber;

  // ----------------------------
  // Capability Check
  // ----------------------------

  /// Returns true if this gateway can escalate on the current device.
  ///
  /// Should check:
  /// - Platform support (Android/iOS)
  /// - Required capabilities (dialer, etc.)
  /// - Any device-specific constraints
  Future<bool> canEscalate();

  // ----------------------------
  // Preview
  // ----------------------------

  /// Returns preview info to show user BEFORE escalation.
  ///
  /// This helps the UI build accurate confirmation dialogs.
  EscalationPreview prepareEscalation(EmergencyType type);

  // ----------------------------
  // Core Escalation
  // ----------------------------

  /// Performs the actual escalation.
  ///
  /// This should be called ONLY after explicit user confirmation.
  ///
  /// Implementations must:
  /// - Return structured EscalationResult
  /// - Never throw unhandled exceptions
  /// - Provide truthful status (do not claim unverified success)
  /// - Include fallback number in failure cases
  Future<EscalationResult> escalate(EscalationRequest request);

  // ----------------------------
  // Metadata
  // ----------------------------

  /// Returns metadata about this gateway for logging/debugging.
  Future<Map<String, dynamic>> getGatewayInfo() async {
    final canGo = await canEscalate();
    return {
      'agency': agency.name,
      'name': name,
      'emergencyNumber': emergencyNumber,
      'canEscalate': canGo,
    };
  }

  // ----------------------------
  // Shared Validation
  // ----------------------------

  /// Validates the escalation request.
  /// Returns null if valid, or EscalationResult with failure info.
  EscalationResult? validateRequest(EscalationRequest request) {
    // Currently no strict validation required.
    // Extensible for future rules (rate limiting, cooldowns, etc.)
    return null;
  }

  // ----------------------------
  // Logging
  // ----------------------------

  void log(String message) {
    developer.log(message, name: 'AgencyGateway[$name]');
  }

  // ----------------------------
  // Description
  // ----------------------------

  @override
  String toString() {
    return 'EmergencyAgencyGateway(agency: ${agency.label}, '
        'number: $emergencyNumber)';
  }
}