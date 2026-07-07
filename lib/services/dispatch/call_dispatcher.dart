// ============================================
// Aarohan SOS Alert
// File        : services/dispatch/call_dispatcher.dart
// Description : Call Dispatcher (Real Implementation)
// Sprint      : 3 - Real Emergency Communication Layer
// ============================================

import 'dart:developer' as developer;
import 'dart:io' show Platform;
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/dispatch/emergency_alert.dart';
import '../../models/dispatch/dispatch_result.dart';
import '../permission/permission_service.dart';
import 'dispatcher.dart';

// ----------------------------
// Call Mode
// ----------------------------

enum CallMode {
  /// Directly initiates the call. Requires CALL_PHONE permission.
  direct,

  /// Opens the dialer with number pre-filled. No permission needed.
  /// User must tap the call button.
  dialer,
}

// ----------------------------
// Call Dispatcher
// ----------------------------

/// Dispatches emergency alerts by initiating a phone call to the primary
/// emergency contact.
///
/// STATUS: Fully Implemented (Sprint 3)
///
/// Supports two modes:
/// - [CallMode.direct] - Immediately calls (requires permission)
/// - [CallMode.dialer] - Opens dialer with number (safer, no permission)
///
/// Default mode is [CallMode.dialer] for Play Store safety.
///
/// User Flow (Dialer Mode - default):
/// 1. Dispatcher extracts primary contact phone number
/// 2. Android dialer opens with number pre-filled
/// 3. User taps the green call button
/// 4. Call initiated
///
/// User Flow (Direct Mode):
/// 1. Dispatcher requests CALL_PHONE permission
/// 2. Call is placed immediately without user tap
/// 3. Android takes over the call UI
class CallDispatcher extends Dispatcher {
  // ----------------------------
  // Configuration
  // ----------------------------

  final bool logToConsole;
  final CallMode mode;

  CallDispatcher({
    this.logToConsole = true,
    this.mode = CallMode.dialer,
  });

  final PermissionService _permissionService = PermissionService();

  // ----------------------------
  // Dispatcher Properties
  // ----------------------------

  @override
  DispatchMethod get method => DispatchMethod.call;

  @override
  String get name => 'Call Dispatcher';

  @override
  Future<bool> isAvailable() async {
    try {
      // Only Android and iOS supported
      if (!Platform.isAndroid && !Platform.isIOS) {
        _log('Call not supported on this platform');
        return false;
      }
      return true;
    } catch (e) {
      _log('Availability check failed: $e');
      return false;
    }
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

    // Step 3 - Check platform
    if (!Platform.isAndroid && !Platform.isIOS) {
      return DispatchResult.failure(
        method: method,
        errorMessage: 'Call is only supported on Android and iOS',
        recipientCount: 1,
      );
    }

    // Step 4 - Log start
    _log('=== Call Dispatch Started ===');
    _log('Alert ID     : ${alert.alertId}');
    _log('Mode         : ${mode.name}');
    _log('Primary      : ${primary.name}');
    _log('Number       : ${primary.phone}');

    // Step 5 - Pre-dispatch hook
    await onBeforeDispatch(alert);

    try {
      // Step 6 - Execute based on mode
      DispatchResult result;

      if (mode == CallMode.direct) {
        result = await _executeDirectCall(alert, primary.phone, primary.name);
      } else {
        result = await _executeDialerCall(alert, primary.phone, primary.name);
      }

      _log('Call dispatch completed');
      _log('Summary: ${result.summary}');
      _log('=============================');

      // Step 7 - Post-dispatch hook
      await onAfterDispatch(alert, result);

      return result;
    } catch (e, stackTrace) {
      _log('Call dispatch error: $e');
      _log('Stack: $stackTrace');

      return DispatchResult.failure(
        method: method,
        errorMessage: 'Call failed: ${e.toString()}',
        recipientCount: 1,
      );
    }
  }

  // ----------------------------
  // Direct Call (Requires Permission)
  // ----------------------------

  Future<DispatchResult> _executeDirectCall(
    EmergencyAlert alert,
    String phone,
    String contactName,
  ) async {
    _log('Attempting direct call...');

    // Request phone permission
    final permResult = await _permissionService.requestPhone();

    if (!permResult.granted) {
      _log('Phone permission denied');

      // Automatically fall back to dialer mode
      _log('Falling back to dialer mode');
      return _executeDialerCall(alert, phone, contactName);
    }

    // Execute direct call
    final callSuccess = await FlutterPhoneDirectCaller.callNumber(phone);

    if (callSuccess == true) {
      _log('Direct call initiated successfully');
      return DispatchResult.success(
        method: method,
        recipientCount: 1,
        metadata: {
          'alertId': alert.alertId,
          'mode': 'direct',
          'contactName': contactName,
          'contactPhone': phone,
          'timestamp': DateTime.now().toIso8601String(),
        },
      );
    } else {
      _log('Direct call failed');
      return DispatchResult.failure(
        method: method,
        errorMessage: 'Failed to initiate direct call to $contactName',
        recipientCount: 1,
      );
    }
  }

  // ----------------------------
  // Dialer Call (No Permission Needed)
  // ----------------------------

  Future<DispatchResult> _executeDialerCall(
    EmergencyAlert alert,
    String phone,
    String contactName,
  ) async {
    _log('Opening dialer with pre-filled number...');

    // Sanitize phone number
    final sanitized = _sanitizePhoneNumber(phone);
    final telUri = Uri(scheme: 'tel', path: sanitized);

    _log('Tel URI: $telUri');

    // Check if URL can be launched
    final canLaunch = await canLaunchUrl(telUri);
    if (!canLaunch) {
      _log('Cannot launch dialer');
      return DispatchResult.failure(
        method: method,
        errorMessage: 'Cannot open phone dialer on this device',
        recipientCount: 1,
      );
    }

    // Launch dialer
    final launched = await launchUrl(
      telUri,
      mode: LaunchMode.externalApplication,
    );

    if (launched) {
      _log('Dialer opened successfully');
      return DispatchResult.success(
        method: method,
        recipientCount: 1,
        metadata: {
          'alertId': alert.alertId,
          'mode': 'dialer',
          'contactName': contactName,
          'contactPhone': phone,
          'note': 'User must tap call button to initiate',
          'timestamp': DateTime.now().toIso8601String(),
        },
      );
    } else {
      _log('Failed to open dialer');
      return DispatchResult.failure(
        method: method,
        errorMessage: 'Failed to open phone dialer',
        recipientCount: 1,
      );
    }
  }

  // ----------------------------
  // Phone Number Sanitization
  // ----------------------------

  String _sanitizePhoneNumber(String phone) {
    // Keep only digits, +, and #
    return phone.replaceAll(RegExp(r'[^\d+#]'), '');
  }

  // ----------------------------
  // Internal Logging
  // ----------------------------

  void _log(String message) {
    if (!logToConsole) return;
    developer.log(message, name: 'CallDispatcher');
  }
}