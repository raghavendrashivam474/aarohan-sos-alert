// ============================================
// Aarohan SOS Alert
// File        : services/dialer/dialer_gateway.dart
// Description : Dialer Resolution & Launch Gateway
// Sprint      : 4 - Emergency Dispatch Reliability & Official Escalation
// ============================================

import 'dart:developer' as developer;
import 'dart:io' show Platform;
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dialer_launch_result.dart';

// ----------------------------
// Dialer Info Model
// ----------------------------

/// Information about a dialer available on the device.
class DialerInfo {
  final String name;
  final String? packageName;
  final bool isDefault;
  final bool isSystemDialer;

  DialerInfo({
    required this.name,
    this.packageName,
    this.isDefault = false,
    this.isSystemDialer = false,
  });

  @override
  String toString() =>
      'DialerInfo(name: $name, package: $packageName, default: $isDefault)';
}

// ----------------------------
// Dialer Gateway
// ----------------------------

/// Isolates all dialer resolution and launch logic behind a clean facade.
///
/// This gateway solves the "Truecaller / Phone app chooser" friction problem
/// discovered during Sprint 3 real-device testing.
///
/// Responsibilities:
/// - Detect calling capability on device
/// - Resolve the default/preferred dialer
/// - Attempt to minimize app-chooser interaction
/// - Launch the appropriate dialer flow
/// - Return structured results
///
/// This gateway does NOT:
/// - Contain UI logic
/// - Perform actual dialing decisions
/// - Handle emergency escalation
/// - Know about specific contacts
///
/// The Android Telecom framework governs which dialer is default.
/// This gateway respects that decision — it does not override it.
class DialerGateway {
  // ----------------------------
  // Singleton Setup
  // ----------------------------

  static final DialerGateway _instance = DialerGateway._internal();
  factory DialerGateway() => _instance;
  DialerGateway._internal();

  // ----------------------------
  // Platform Channel
  // ----------------------------

  /// Method channel for native platform queries (future extensibility).
  static const _platform = MethodChannel('com.aarohan/dialer');

  // ----------------------------
  // Capability Detection
  // ----------------------------

  /// Returns true if the device supports placing phone calls at all.
  Future<bool> canPlaceCall() async {
    try {
      // Only mobile platforms support calling
      if (!Platform.isAndroid && !Platform.isIOS) {
        _log('Platform ${Platform.operatingSystem} does not support calling');
        return false;
      }

      // Verify tel: URI scheme is handleable
      final testUri = Uri(scheme: 'tel', path: '');
      final canHandle = await canLaunchUrl(testUri);

      if (!canHandle) {
        _log('tel: URI scheme not handleable on this device');
        return false;
      }

      return true;
    } catch (e) {
      _log('canPlaceCall error: $e');
      return false;
    }
  }

  // ----------------------------
  // Dialer Resolution
  // ----------------------------

  /// Attempts to identify the default dialer on the device.
  ///
  /// On Android, the Telecom framework maintains the "default dialer role".
  /// This method attempts to query it. If unavailable, returns generic info.
  Future<DialerInfo> resolveDialer() async {
    try {
      if (!Platform.isAndroid) {
        return DialerInfo(
          name: Platform.isIOS ? 'iOS Phone' : 'Unknown',
          isSystemDialer: true,
        );
      }

      // Try to query native side for default dialer info
      // Falls back gracefully if native channel is not implemented
      try {
        final dialerData = await _platform.invokeMapMethod<String, dynamic>(
          'getDefaultDialer',
        );

        if (dialerData != null) {
          return DialerInfo(
            name: dialerData['name'] as String? ?? 'System Dialer',
            packageName: dialerData['packageName'] as String?,
            isDefault: true,
            isSystemDialer: dialerData['isSystem'] as bool? ?? false,
          );
        }
      } on MissingPluginException {
        _log('Native dialer channel not implemented (using fallback)');
      } catch (e) {
        _log('Native dialer query failed: $e');
      }

      // Fallback: return generic system dialer info
      return DialerInfo(
        name: 'System Dialer',
        isDefault: true,
        isSystemDialer: true,
      );
    } catch (e) {
      _log('resolveDialer error: $e');
      return DialerInfo(name: 'Unknown Dialer');
    }
  }

  /// Returns metadata about the resolved dialer for logging/UI display.
  Future<Map<String, dynamic>> getDialerInfo() async {
    final info = await resolveDialer();
    final canCall = await canPlaceCall();

    return {
      'canPlaceCall': canCall,
      'dialerName': info.name,
      'dialerPackage': info.packageName,
      'isDefault': info.isDefault,
      'isSystemDialer': info.isSystemDialer,
      'platform': Platform.operatingSystem,
    };
  }

  // ----------------------------
  // Launch Call
  // ----------------------------

  /// Launches the dialer for the given phone number.
  ///
  /// Strategy (in order):
  /// 1. Try launching with default dialer package explicitly (reduces chooser)
  /// 2. Fall back to ACTION_DIAL system intent
  /// 3. Fall back to generic tel: URI
  ///
  /// This never places the call automatically.
  /// User must tap the call button in the opened dialer.
  Future<DialerLaunchResult> launchCall(String number) async {
    _log('=== Launch Call Requested ===');
    _log('Number: $number');

    // Step 1 - Sanitize
    final sanitized = _sanitizePhoneNumber(number);
    if (sanitized.isEmpty) {
      _log('Invalid phone number after sanitization');
      return DialerLaunchResult.failure(
        errorCode: DialerErrorCode.invalidNumber,
        errorMessage: 'Phone number is invalid or empty',
        targetNumber: number,
      );
    }

    _log('Sanitized: $sanitized');

    // Step 2 - Check capability
    final canCall = await canPlaceCall();
    if (!canCall) {
      _log('Device cannot place calls');
      return DialerLaunchResult.noCapability();
    }

    // Step 3 - Resolve dialer info
    final dialer = await resolveDialer();
    _log('Resolved dialer: ${dialer.name}');

    // Step 4 - Attempt launch strategies in priority order
    DialerLaunchResult? result;

    // Strategy A: Try default dialer with explicit package (if known)
    if (dialer.packageName != null && Platform.isAndroid) {
      result = await _launchWithPackage(
        number: sanitized,
        packageName: dialer.packageName!,
        dialerName: dialer.name,
      );
      if (result.success) {
        _log('Launched via default dialer package');
        return result;
      }
      _log('Default dialer package launch failed, trying system dialer');
    }

    // Strategy B: Try system ACTION_DIAL intent
    result = await _launchSystemDialer(
      number: sanitized,
      dialerName: dialer.name,
    );
    if (result.success) {
      _log('Launched via system dialer intent');
      return result;
    }
    _log('System dialer failed, trying generic intent');

    // Strategy C: Fallback to generic tel: URI
    result = await _launchGenericIntent(
      number: sanitized,
      dialerName: dialer.name,
    );
    if (result.success) {
      _log('Launched via generic intent');
      return result;
    }

    _log('All launch strategies failed');
    return DialerLaunchResult.failure(
      errorCode: DialerErrorCode.intentLaunchFailed,
      errorMessage: 'All dialer launch strategies failed',
      targetNumber: sanitized,
      dialerName: dialer.name,
    );
  }

  // ----------------------------
  // Strategy A - Launch with specific package
  // ----------------------------

  Future<DialerLaunchResult> _launchWithPackage({
    required String number,
    required String packageName,
    required String dialerName,
  }) async {
    try {
      // Note: url_launcher doesn't directly support package targeting.
      // Native side could implement Intent.setPackage() for true targeting.
      // For now, this attempts native channel and falls back cleanly.
      final launched = await _platform.invokeMethod<bool>(
        'launchDialerWithPackage',
        {
          'number': number,
          'package': packageName,
        },
      );

      if (launched == true) {
        return DialerLaunchResult.success(
          targetNumber: number,
          launchMethod: DialerLaunchMethod.defaultDialer,
          dialerName: dialerName,
          requiresUserConfirmation: true,
          metadata: {'packageName': packageName},
        );
      }

      return DialerLaunchResult.failure(
        errorCode: DialerErrorCode.intentLaunchFailed,
        errorMessage: 'Package launch returned false',
        targetNumber: number,
        dialerName: dialerName,
      );
    } on MissingPluginException {
      // Native channel not implemented — this is expected in current build
      return DialerLaunchResult.failure(
        errorCode: DialerErrorCode.intentLaunchFailed,
        errorMessage: 'Native package launch not available',
        targetNumber: number,
        dialerName: dialerName,
      );
    } catch (e) {
      _log('Package launch error: $e');
      return DialerLaunchResult.failure(
        errorCode: DialerErrorCode.intentLaunchFailed,
        errorMessage: e.toString(),
        targetNumber: number,
        dialerName: dialerName,
      );
    }
  }

  // ----------------------------
  // Strategy B - System dialer intent
  // ----------------------------

  Future<DialerLaunchResult> _launchSystemDialer({
    required String number,
    required String dialerName,
  }) async {
    try {
      final telUri = Uri(scheme: 'tel', path: number);

      final canLaunch = await canLaunchUrl(telUri);
      if (!canLaunch) {
        return DialerLaunchResult.failure(
          errorCode: DialerErrorCode.noCompatibleDialer,
          errorMessage: 'No dialer app registered for tel: scheme',
          targetNumber: number,
          dialerName: dialerName,
        );
      }

      final launched = await launchUrl(
        telUri,
        mode: LaunchMode.externalApplication,
      );

      if (launched) {
        return DialerLaunchResult.success(
          targetNumber: number,
          launchMethod: DialerLaunchMethod.systemDialer,
          dialerName: dialerName,
          requiresUserConfirmation: true,
        );
      }

      return DialerLaunchResult.failure(
        errorCode: DialerErrorCode.intentLaunchFailed,
        errorMessage: 'launchUrl returned false',
        targetNumber: number,
        dialerName: dialerName,
      );
    } catch (e) {
      _log('System dialer error: $e');
      return DialerLaunchResult.failure(
        errorCode: DialerErrorCode.intentLaunchFailed,
        errorMessage: e.toString(),
        targetNumber: number,
        dialerName: dialerName,
      );
    }
  }

  // ----------------------------
  // Strategy C - Generic fallback
  // ----------------------------

  Future<DialerLaunchResult> _launchGenericIntent({
    required String number,
    required String dialerName,
  }) async {
    try {
      final telUri = Uri.parse('tel:$number');

      final launched = await launchUrl(
        telUri,
        mode: LaunchMode.platformDefault,
      );

      if (launched) {
        return DialerLaunchResult.success(
          targetNumber: number,
          launchMethod: DialerLaunchMethod.fallback,
          dialerName: dialerName,
          requiresUserConfirmation: true,
        );
      }

      return DialerLaunchResult.failure(
        errorCode: DialerErrorCode.intentLaunchFailed,
        errorMessage: 'Generic launch returned false',
        targetNumber: number,
        dialerName: dialerName,
      );
    } catch (e) {
      _log('Generic intent error: $e');
      return DialerLaunchResult.failure(
        errorCode: DialerErrorCode.intentLaunchFailed,
        errorMessage: e.toString(),
        targetNumber: number,
        dialerName: dialerName,
      );
    }
  }

  // ----------------------------
  // Phone Number Sanitization
  // ----------------------------

  String _sanitizePhoneNumber(String phone) {
    // Keep digits, +, and #
    return phone.replaceAll(RegExp(r'[^\d+#]'), '');
  }

  // ----------------------------
  // Internal Logging
  // ----------------------------

  void _log(String message) {
    developer.log(message, name: 'DialerGateway');
  }
}