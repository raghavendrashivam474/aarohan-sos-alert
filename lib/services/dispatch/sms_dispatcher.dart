// ============================================
// Aarohan SOS Alert
// File        : services/dispatch/sms_dispatcher.dart
// Description : SMS Dispatcher (Permission-Free URL Scheme)
// Sprint      : 3 - Real Emergency Communication Layer
// ============================================

import 'dart:developer' as developer;
import 'dart:io' show Platform;
import 'package:url_launcher/url_launcher.dart';
import '../../models/dispatch/emergency_alert.dart';
import '../../models/dispatch/dispatch_result.dart';
import 'dispatcher.dart';

// ----------------------------
// SMS Dispatcher
// ----------------------------

/// Dispatches emergency alerts via SMS using the sms: URL scheme.
///
/// STATUS: Fully Implemented (Sprint 3)
///
/// Uses the native SMS URI scheme (like tel: for calls):
/// - Opens the device's SMS app with recipients + message pre-filled
/// - Works on both Android and iOS
/// - Does NOT require SMS permission
/// - Play Store safe
///
/// User Flow:
/// 1. Dispatcher builds sms: URI with all contacts + message
/// 2. SMS app opens with everything pre-filled
/// 3. User taps SEND
/// 4. SMS delivered to all recipients
class SmsDispatcher extends Dispatcher {
  // ----------------------------
  // Configuration
  // ----------------------------

  final bool logToConsole;

  SmsDispatcher({this.logToConsole = true});

  // ----------------------------
  // Dispatcher Properties
  // ----------------------------

  @override
  DispatchMethod get method => DispatchMethod.sms;

  @override
  String get name => 'SMS Dispatcher';

  @override
  Future<bool> isAvailable() async {
    try {
      // Only Android and iOS supported
      if (!Platform.isAndroid && !Platform.isIOS) {
        _log('SMS not supported on this platform');
        return false;
      }

      // Check if sms: URI can be launched
      final testUri = Uri(scheme: 'sms', path: '');
      return await canLaunchUrl(testUri);
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

    // Step 2 - Check platform
    if (!Platform.isAndroid && !Platform.isIOS) {
      return DispatchResult.failure(
        method: method,
        errorMessage: 'SMS is only supported on Android and iOS devices',
        recipientCount: alert.contactCount,
      );
    }

    _log('=== SMS Dispatch Started ===');
    _log('Alert ID     : ${alert.alertId}');
    _log('Contacts     : ${alert.contactCount}');

    // Step 3 - Pre-dispatch hook
    await onBeforeDispatch(alert);

    try {
      // Step 4 - Extract and sanitize phone numbers
      final recipients = alert.contactPhones
          .map((phone) => _sanitizePhoneNumber(phone))
          .join(',');

      _log('Recipients: $recipients');

      // Step 5 - Build sms: URI with pre-filled message
      final smsUri = Uri(
        scheme: 'sms',
        path: recipients,
        queryParameters: {'body': alert.message},
      );

      _log('SMS URI: $smsUri');

      // Step 6 - Check if URI can be launched
      final canLaunch = await canLaunchUrl(smsUri);
      if (!canLaunch) {
        _log('Cannot launch SMS URI');
        return DispatchResult.failure(
          method: method,
          errorMessage: 'No SMS app available on this device',
          recipientCount: alert.contactCount,
        );
      }

      // Step 7 - Launch SMS app
      _log('Opening SMS composer...');
      final launched = await launchUrl(
        smsUri,
        mode: LaunchMode.externalApplication,
      );

      if (!launched) {
        _log('Failed to open SMS app');
        return DispatchResult.failure(
          method: method,
          errorMessage: 'Failed to open SMS app',
          recipientCount: alert.contactCount,
        );
      }

      // Step 8 - Build success result
      final result = DispatchResult.success(
        method: method,
        recipientCount: alert.contactCount,
        metadata: {
          'alertId': alert.alertId,
          'recipientPhones': alert.contactPhones,
          'method': 'sms_uri_scheme',
          'timestamp': DateTime.now().toIso8601String(),
          'note': 'User must tap SEND in SMS app to actually send',
        },
      );

      _log('SMS dispatch completed');
      _log('Summary: ${result.summary}');
      _log('===========================');

      // Step 9 - Post-dispatch hook
      await onAfterDispatch(alert, result);

      return result;
    } catch (e, stackTrace) {
      _log('SMS dispatch error: $e');
      _log('Stack: $stackTrace');

      return DispatchResult.failure(
        method: method,
        errorMessage: 'SMS sending failed: ${e.toString()}',
        recipientCount: alert.contactCount,
      );
    }
  }

  // ----------------------------
  // Phone Number Sanitization
  // ----------------------------

  String _sanitizePhoneNumber(String phone) {
    // Keep only digits and +
    return phone.replaceAll(RegExp(r'[^\d+]'), '');
  }

  // ----------------------------
  // Internal Logging
  // ----------------------------

  void _log(String message) {
    if (!logToConsole) return;
    developer.log(message, name: 'SmsDispatcher');
  }
}