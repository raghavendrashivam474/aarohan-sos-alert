// ============================================
// Aarohan SOS Alert
// File        : services/dispatch/call_dispatcher.dart
// Description : Call Dispatcher (Sprint 4 - Refactored to use DialerGateway)
// Sprint      : 4 - Emergency Dispatch Reliability & Official Escalation
// ============================================

import 'dart:developer' as developer;
import '../../models/dispatch/emergency_alert.dart';
import '../../models/dispatch/dispatch_result.dart';
import '../dialer/dialer_gateway.dart';
import '../dialer/dialer_launch_result.dart';
import 'dispatcher.dart';

// ----------------------------
// Call Dispatcher
// ----------------------------

/// Dispatches emergency alerts by initiating a phone call to the primary
/// emergency contact.
///
/// STATUS: Fully Implemented (Sprint 4 - Refactored)
///
/// Sprint 4 Refactor:
/// - No longer contains platform-specific calling logic
/// - Delegates all dialer resolution to DialerGateway
/// - Focuses purely on dispatch semantics
/// - Converts DialerLaunchResult → DispatchResult
///
/// This dispatcher is now a "clean" implementation of the Dispatcher contract:
/// - Validates the alert
/// - Extracts the primary contact
/// - Delegates to DialerGateway
/// - Returns structured DispatchResult
///
/// It does NOT:
/// - Handle Android platform specifics (that's DialerGateway's job)
/// - Choose which dialer to use
/// - Perform intent resolution
class CallDispatcher extends Dispatcher {
  // ----------------------------
  // Configuration
  // ----------------------------

  final bool logToConsole;
  final DialerGateway _dialerGateway = DialerGateway();

  CallDispatcher({this.logToConsole = true});

  // ----------------------------
  // Dispatcher Properties
  // ----------------------------

  @override
  DispatchMethod get method => DispatchMethod.call;

  @override
  String get name => 'Call Dispatcher';

  @override
  Future<bool> isAvailable() async {
    return await _dialerGateway.canPlaceCall();
  }

  // ----------------------------
  // Core Dispatch Logic
  // ----------------------------

  @override
  Future<DispatchResult> dispatch(EmergencyAlert alert) async {
    // Step 1 - Validate alert
    final validationError = validateAlert(alert);
    if (validationError != null) {
      _log('Validation failed: ${validationError.errorMessage}');
      return validationError;
    }

    // Step 2 - Verify primary contact exists
    final primary = alert.primaryContact;
    if (primary == null) {
      _log('No primary contact available');
      return DispatchResult.skipped(
        method: method,
        reason: 'No primary emergency contact configured',
      );
    }

    // Step 3 - Check dialer capability via gateway
    final canCall = await _dialerGateway.canPlaceCall();
    if (!canCall) {
      _log('Device cannot place calls');
      return DispatchResult.failure(
        method: method,
        errorMessage: 'This device does not support making phone calls',
        recipientCount: 1,
      );
    }

    // Step 4 - Log start
    _log('=== Call Dispatch Started ===');
    _log('Alert ID     : ${alert.alertId}');
    _log('Primary      : ${primary.name}');
    _log('Number       : ${primary.phone}');

    // Step 5 - Pre-dispatch hook
    await onBeforeDispatch(alert);

    // Step 6 - Delegate to DialerGateway
    final launchResult = await _dialerGateway.launchCall(primary.phone);

    // Step 7 - Convert DialerLaunchResult → DispatchResult
    final dispatchResult = _convertLaunchResult(
      launchResult: launchResult,
      alert: alert,
      contactName: primary.name,
    );

    _log('Call dispatch completed');
    _log('Summary: ${dispatchResult.summary}');
    _log('=============================');

    // Step 8 - Post-dispatch hook
    await onAfterDispatch(alert, dispatchResult);

    return dispatchResult;
  }

  // ----------------------------
  // Result Conversion
  // ----------------------------

  /// Converts platform-specific DialerLaunchResult into generic DispatchResult.
  ///
  /// This ensures the DispatchEngine and UI never see platform-specific types.
  DispatchResult _convertLaunchResult({
    required DialerLaunchResult launchResult,
    required EmergencyAlert alert,
    required String contactName,
  }) {
    if (launchResult.success) {
      return DispatchResult.success(
        method: method,
        recipientCount: 1,
        metadata: {
          'alertId': alert.alertId,
          'contactName': contactName,
          'contactPhone': launchResult.targetNumber,
          'dialerName': launchResult.dialerName,
          'launchMethod': launchResult.launchMethod.label,
          'requiresUserConfirmation': launchResult.requiresUserConfirmation,
          'note': launchResult.requiresUserConfirmation
              ? 'User must tap call button in dialer'
              : 'Call placed automatically',
          'timestamp': launchResult.timestamp.toIso8601String(),
          ...launchResult.metadata,
        },
      );
    }

    // Handle specific error cases
    switch (launchResult.errorCode) {
      case DialerErrorCode.userCancelled:
        return DispatchResult.skipped(
          method: method,
          reason: 'User cancelled the call',
        );

      case DialerErrorCode.noCallingCapability:
      case DialerErrorCode.platformNotSupported:
        return DispatchResult.failure(
          method: method,
          errorMessage: 'Device does not support calling',
          recipientCount: 1,
        );

      case DialerErrorCode.noCompatibleDialer:
        return DispatchResult.failure(
          method: method,
          errorMessage: 'No compatible dialer app found on this device',
          recipientCount: 1,
        );

      case DialerErrorCode.invalidNumber:
        return DispatchResult.failure(
          method: method,
          errorMessage: 'Invalid phone number for $contactName',
          recipientCount: 1,
        );

      case DialerErrorCode.intentLaunchFailed:
      case DialerErrorCode.unknown:
      default:
        return DispatchResult.failure(
          method: method,
          errorMessage:
              launchResult.errorMessage ?? 'Failed to open phone dialer',
          recipientCount: 1,
        );
    }
  }

  // ----------------------------
  // Internal Logging
  // ----------------------------

  void _log(String message) {
    if (!logToConsole) return;
    developer.log(message, name: 'CallDispatcher');
  }
}