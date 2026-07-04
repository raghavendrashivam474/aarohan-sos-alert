// ============================================
// Aarohan SOS Alert
// File        : services/dispatch/share_dispatcher.dart
// Description : Share Sheet Dispatcher (Real Implementation)
// Sprint      : 2 - Emergency Dispatch Engine
// ============================================

import 'dart:developer' as developer;
import 'package:share_plus/share_plus.dart';
import '../../models/dispatch/emergency_alert.dart';
import '../../models/dispatch/dispatch_result.dart';
import 'dispatcher.dart';

// ----------------------------
// Share Dispatcher
// ----------------------------

/// Dispatches emergency alerts via the native Android Share Sheet.
///
/// STATUS: Fully Implemented
///
/// This dispatcher opens the native Android share sheet, allowing
/// the user to send the emergency message through:
/// - WhatsApp
/// - SMS
/// - Telegram
/// - Email
/// - Any other installed app that accepts text
///
/// Advantages:
/// - No special permissions required
/// - Uses installed communication apps
/// - Universal compatibility
/// - Play Store friendly
///
/// Trade-offs:
/// - Requires one manual user tap on share sheet
/// - User must select which app to use
class ShareDispatcher extends Dispatcher {
  // ----------------------------
  // Configuration
  // ----------------------------

  final bool logToConsole;
  final String shareSubject;

  ShareDispatcher({
    this.logToConsole = true,
    this.shareSubject = '🚨 EMERGENCY ALERT - Aarohan SOS',
  });

  // ----------------------------
  // Dispatcher Properties
  // ----------------------------

  @override
  DispatchMethod get method => DispatchMethod.share;

  @override
  String get name => 'Share Dispatcher';

  @override
  Future<bool> isAvailable() async {
    // Share sheet is available on all Android and iOS devices
    return true;
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

    // Step 2 - Pre-dispatch hook
    await onBeforeDispatch(alert);

    try {
      _log('=== Share Dispatch Initiated ===');
      _log('Alert ID     : ${alert.alertId}');
      _log('User         : ${alert.userName}');
      _log('Contacts     : ${alert.contactCount}');
      _log('Message Size : ${alert.message.length} chars');
      _log('Opening native share sheet...');

      // Step 3 - Launch native share sheet
      final shareResult = await Share.share(
        alert.message,
        subject: shareSubject,
      );

      _log('Share sheet closed');
      _log('Status: ${shareResult.status.name}');

      // Step 4 - Build result based on share sheet outcome
      DispatchResult result;

      switch (shareResult.status) {
        case ShareResultStatus.success:
          result = DispatchResult.success(
            method: method,
            recipientCount: alert.contactCount,
            metadata: {
              'alertId': alert.alertId,
              'sharedApp': shareResult.raw,
              'timestamp': DateTime.now().toIso8601String(),
            },
          );
          _log('Share dispatched via: ${shareResult.raw}');
          break;

        case ShareResultStatus.dismissed:
          result = DispatchResult.skipped(
            method: method,
            reason: 'User dismissed the share sheet',
          );
          _log('User dismissed share sheet');
          break;

        case ShareResultStatus.unavailable:
          result = DispatchResult.failure(
            method: method,
            errorMessage: 'Share sheet unavailable on this device',
            recipientCount: alert.contactCount,
          );
          _log('Share sheet unavailable');
          break;
      }

      _log('Result: ${result.summary}');
      _log('================================');

      // Step 5 - Post-dispatch hook
      await onAfterDispatch(alert, result);

      return result;
    } catch (e, stackTrace) {
      _log('Share dispatch error: $e');
      _log('Stack: $stackTrace');

      final result = DispatchResult.failure(
        method: method,
        errorMessage: 'Failed to open share sheet: ${e.toString()}',
        recipientCount: alert.contactCount,
      );

      await onAfterDispatch(alert, result);
      return result;
    }
  }

  // ----------------------------
  // Internal Logging
  // ----------------------------

  void _log(String message) {
    if (!logToConsole) return;
    developer.log(message, name: 'ShareDispatcher');
  }
}