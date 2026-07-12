// ============================================
// Aarohan SOS Alert
// File        : services/emergency_agency/erss_gateway.dart
// Description : ERSS 112 Official Escalation Gateway
// Sprint      : 4 - Emergency Dispatch Reliability & Official Escalation
// ============================================

import 'dart:developer' as developer;
import '../../models/emergency/emergency_type.dart';
import '../../models/emergency/escalation_result.dart';
import '../dialer/dialer_gateway.dart';
import '../dialer/dialer_launch_result.dart';
import 'emergency_agency_gateway.dart';

// ----------------------------
// ERSS 112 India Gateway
// ----------------------------

/// Official escalation gateway for India's Emergency Response Support System.
///
/// STATUS: Supported citizen pathway (dialer-based)
///
/// Background:
/// - ERSS 112 is India's unified emergency response system
/// - Single number (112) for police, fire, medical, and other emergencies
/// - Operated under Ministry of Home Affairs (MHA)
/// - Official portal: https://112.gov.in
///
/// This gateway implements the officially supported citizen pathway:
/// - Opens the phone dialer with 112 pre-filled
/// - User taps call button to actually contact ERSS operator
///
/// IMPORTANT: This gateway does NOT:
/// - Send any data to ERSS via API (no public API exists for third-party apps)
/// - Bypass any official channel
/// - Simulate agency notification
/// - Auto-dial without user confirmation
///
/// The MHA describes ERSS-112 as receiving distress signals across
/// multiple channels including external signals, but that does not
/// establish a public developer API for Aarohan.
///
/// Any future integration with an official ERSS API would require:
/// - Formal MHA authorization
/// - Legal agreements
/// - Approved developer credentials
///
/// Until then, this gateway provides the safest supported pathway:
/// user-confirmed dialer launch to 112.
class ErssGateway extends EmergencyAgencyGateway {
  // ----------------------------
  // Configuration
  // ----------------------------

  final bool logToConsole;
  final DialerGateway _dialerGateway = DialerGateway();

  ErssGateway({this.logToConsole = true});

  // ----------------------------
  // Agency Properties
  // ----------------------------

  @override
  EmergencyAgency get agency => EmergencyAgency.erss112India;

  @override
  String get name => 'ERSS 112 India';

  @override
  String get emergencyNumber => '112';

  // ----------------------------
  // Capability Check
  // ----------------------------

  @override
  Future<bool> canEscalate() async {
    try {
      // ERSS escalation requires calling capability
      final canCall = await _dialerGateway.canPlaceCall();
      _log('canEscalate check: $canCall');
      return canCall;
    } catch (e) {
      _log('canEscalate error: $e');
      return false;
    }
  }

  // ----------------------------
  // Preview
  // ----------------------------

  @override
  EscalationPreview prepareEscalation(EmergencyType type) {
    return EscalationPreview(
      agency: agency,
      emergencyNumber: emergencyNumber,
      agencyName: name,
      pathwayDescription:
          'Opens your phone dialer with 112 (India\'s emergency number) '
          'pre-filled.',
      userAction:
          'Tap the call button in the dialer to speak to an ERSS operator. '
          'Describe your ${type.shortLabel.toLowerCase()} emergency clearly.',
      warnings: [
        'Use 112 only for genuine emergencies',
        'Misuse of emergency services is a punishable offence',
        'Your call will be handled by ERSS operators',
        'This app does NOT automatically notify authorities — you must complete the call',
      ],
    );
  }

  // ----------------------------
  // Core Escalation
  // ----------------------------

  @override
  Future<EscalationResult> escalate(EscalationRequest request) async {
    _log('=== ERSS 112 Escalation Started ===');
    _log('Emergency Type: ${request.emergencyType.label}');
    _log('Has Location  : ${request.hasLocation}');
    _log('User Phone    : ${request.userPhone ?? 'not provided'}');

    // Step 1 - Validate request
    final validationError = validateRequest(request);
    if (validationError != null) {
      _log('Validation failed: ${validationError.errorMessage}');
      return validationError;
    }

    // Step 2 - Check capability
    final canGo = await canEscalate();
    if (!canGo) {
      _log('ERSS escalation not supported on this device');
      return EscalationResult.unsupported(
        agency: agency,
        emergencyType: request.emergencyType,
        reason: 'This device does not support calling. '
            'Please dial $emergencyNumber manually from another phone.',
      );
    }

    try {
      // Step 3 - Launch dialer with 112
      _log('Launching dialer for $emergencyNumber');
      final launchResult = await _dialerGateway.launchCall(emergencyNumber);

      // Step 4 - Convert launch result to escalation result
      final escalationResult = _convertLaunchResult(
        launchResult: launchResult,
        request: request,
      );

      _log('ERSS escalation completed');
      _log('Result: ${escalationResult.truthfulSummary}');
      _log('===================================');

      return escalationResult;
    } catch (e, stackTrace) {
      _log('ERSS escalation error: $e');
      _log('Stack: $stackTrace');

      return EscalationResult.failed(
        agency: agency,
        emergencyType: request.emergencyType,
        errorMessage: 'Failed to initiate escalation: ${e.toString()}',
        emergencyNumber: emergencyNumber,
      );
    }
  }

  // ----------------------------
  // Result Conversion
  // ----------------------------

  /// Converts DialerLaunchResult into EscalationResult.
  ///
  /// This ensures truthful reporting:
  /// - "initiated" only if dialer actually opened
  /// - "failed" with fallback number if dialer failed
  EscalationResult _convertLaunchResult({
    required DialerLaunchResult launchResult,
    required EscalationRequest request,
  }) {
    if (launchResult.success) {
      return EscalationResult.initiated(
        agency: agency,
        emergencyType: request.emergencyType,
        emergencyNumber: emergencyNumber,
        pathwayDescription:
            '$emergencyNumber dialer opened via ${launchResult.dialerName ?? 'system dialer'}',
        metadata: {
          'launchMethod': launchResult.launchMethod.label,
          'dialerName': launchResult.dialerName,
          'requiresUserConfirmation': launchResult.requiresUserConfirmation,
          'hasLocation': request.hasLocation,
          'emergencyType': request.emergencyType.name,
          'timestamp': launchResult.timestamp.toIso8601String(),
        },
      );
    }

    // Handle specific dialer errors
    switch (launchResult.errorCode) {
      case DialerErrorCode.userCancelled:
        return EscalationResult.cancelled(
          agency: agency,
          emergencyType: request.emergencyType,
        );

      case DialerErrorCode.noCallingCapability:
      case DialerErrorCode.platformNotSupported:
        return EscalationResult.unsupported(
          agency: agency,
          emergencyType: request.emergencyType,
          reason: 'Device does not support calling. '
              'Please dial $emergencyNumber from another phone.',
        );

      case DialerErrorCode.noCompatibleDialer:
        return EscalationResult.failed(
          agency: agency,
          emergencyType: request.emergencyType,
          errorMessage: 'No dialer app available. '
              'Please dial $emergencyNumber manually.',
          emergencyNumber: emergencyNumber,
        );

      case DialerErrorCode.intentLaunchFailed:
      case DialerErrorCode.invalidNumber:
      case DialerErrorCode.unknown:
      default:
        return EscalationResult.failed(
          agency: agency,
          emergencyType: request.emergencyType,
          errorMessage: launchResult.errorMessage ??
              'Failed to open dialer. Please dial $emergencyNumber manually.',
          emergencyNumber: emergencyNumber,
        );
    }
  }

  // ----------------------------
  // Additional Info
  // ----------------------------

  @override
  Future<Map<String, dynamic>> getGatewayInfo() async {
    final baseInfo = await super.getGatewayInfo();
    return {
      ...baseInfo,
      'country': 'India',
      'operatingAuthority': 'Ministry of Home Affairs',
      'officialPortal': 'https://112.gov.in',
      'coverageArea': 'Pan-India (all states and UTs)',
      'servicesHandled': [
        'Police',
        'Fire',
        'Medical',
        'Women\'s Safety',
        'Disaster Response',
      ],
      'pathwayType': 'user-confirmed dialer',
      'apiIntegration': false,
      'apiIntegrationNote':
          'No public developer API available. Uses citizen dialer pathway.',
    };
  }

  // ----------------------------
  // Internal Logging
  // ----------------------------

  void _log(String message) {
    if (!logToConsole) return;
    developer.log(message, name: 'ErssGateway');
  }
}