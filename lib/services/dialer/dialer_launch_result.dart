// ============================================
// Aarohan SOS Alert
// File        : services/dialer/dialer_launch_result.dart
// Description : Structured Dialer Launch Result
// Sprint      : 4 - Emergency Dispatch Reliability & Official Escalation
// ============================================

// ----------------------------
// Launch Method Enum
// ----------------------------

/// The method used to launch the dialer.
enum DialerLaunchMethod {
  /// Launched using the device's default dialer package explicitly.
  defaultDialer,

  /// Launched via ACTION_DIAL system intent.
  systemDialer,

  /// Launched via generic tel: URI (no specific package targeting).
  genericIntent,

  /// Fallback method when preferred approaches fail.
  fallback,

  /// No launch attempted.
  none,
}

extension DialerLaunchMethodExt on DialerLaunchMethod {
  String get label {
    switch (this) {
      case DialerLaunchMethod.defaultDialer:
        return 'Default Dialer';
      case DialerLaunchMethod.systemDialer:
        return 'System Dialer';
      case DialerLaunchMethod.genericIntent:
        return 'Generic Intent';
      case DialerLaunchMethod.fallback:
        return 'Fallback';
      case DialerLaunchMethod.none:
        return 'None';
    }
  }
}

// ----------------------------
// Error Code Enum
// ----------------------------

/// Structured error codes for dialer launch failures.
enum DialerErrorCode {
  none,
  noCallingCapability,
  noCompatibleDialer,
  intentLaunchFailed,
  invalidNumber,
  platformNotSupported,
  userCancelled,
  unknown,
}

extension DialerErrorCodeExt on DialerErrorCode {
  String get label {
    switch (this) {
      case DialerErrorCode.none:
        return 'No Error';
      case DialerErrorCode.noCallingCapability:
        return 'No Calling Capability';
      case DialerErrorCode.noCompatibleDialer:
        return 'No Compatible Dialer';
      case DialerErrorCode.intentLaunchFailed:
        return 'Intent Launch Failed';
      case DialerErrorCode.invalidNumber:
        return 'Invalid Number';
      case DialerErrorCode.platformNotSupported:
        return 'Platform Not Supported';
      case DialerErrorCode.userCancelled:
        return 'User Cancelled';
      case DialerErrorCode.unknown:
        return 'Unknown Error';
    }
  }
}

// ----------------------------
// Dialer Launch Result
// ----------------------------

/// Structured result of a dialer launch attempt.
///
/// This isolates platform-specific outcomes behind a clean data model
/// so upstream components (CallDispatcher, UI) never handle raw exceptions.
class DialerLaunchResult {
  // ----------------------------
  // Fields
  // ----------------------------

  final bool success;
  final String? dialerName;
  final String? targetNumber;
  final DialerLaunchMethod launchMethod;
  final bool requiresUserConfirmation;
  final DialerErrorCode errorCode;
  final String? errorMessage;
  final DateTime timestamp;
  final Map<String, dynamic> metadata;

  // ----------------------------
  // Constructor
  // ----------------------------

  DialerLaunchResult({
    required this.success,
    this.dialerName,
    this.targetNumber,
    this.launchMethod = DialerLaunchMethod.none,
    this.requiresUserConfirmation = true,
    this.errorCode = DialerErrorCode.none,
    this.errorMessage,
    DateTime? timestamp,
    this.metadata = const {},
  }) : timestamp = timestamp ?? DateTime.now();

  // ----------------------------
  // Factory Constructors
  // ----------------------------

  factory DialerLaunchResult.success({
    required String targetNumber,
    required DialerLaunchMethod launchMethod,
    String? dialerName,
    bool requiresUserConfirmation = true,
    Map<String, dynamic> metadata = const {},
  }) {
    return DialerLaunchResult(
      success: true,
      targetNumber: targetNumber,
      launchMethod: launchMethod,
      dialerName: dialerName,
      requiresUserConfirmation: requiresUserConfirmation,
      metadata: metadata,
    );
  }

  factory DialerLaunchResult.failure({
    required DialerErrorCode errorCode,
    required String errorMessage,
    String? targetNumber,
    String? dialerName,
  }) {
    return DialerLaunchResult(
      success: false,
      targetNumber: targetNumber,
      dialerName: dialerName,
      errorCode: errorCode,
      errorMessage: errorMessage,
    );
  }

  factory DialerLaunchResult.cancelled({
    String? targetNumber,
    String? dialerName,
  }) {
    return DialerLaunchResult(
      success: false,
      targetNumber: targetNumber,
      dialerName: dialerName,
      errorCode: DialerErrorCode.userCancelled,
      errorMessage: 'User cancelled dialer launch',
    );
  }

  factory DialerLaunchResult.noCapability() {
    return DialerLaunchResult(
      success: false,
      errorCode: DialerErrorCode.noCallingCapability,
      errorMessage: 'Device does not support calling',
    );
  }

  // ----------------------------
  // Summary
  // ----------------------------

  String get summary {
    if (success) {
      final via = dialerName ?? launchMethod.label;
      return 'Dialer launched via $via for $targetNumber';
    }
    return errorMessage ?? 'Dialer launch failed: ${errorCode.label}';
  }

  // ----------------------------
  // Serialization
  // ----------------------------

  Map<String, dynamic> toMap() {
    return {
      'success': success,
      'dialerName': dialerName,
      'targetNumber': targetNumber,
      'launchMethod': launchMethod.name,
      'requiresUserConfirmation': requiresUserConfirmation,
      'errorCode': errorCode.name,
      'errorMessage': errorMessage,
      'timestamp': timestamp.toIso8601String(),
      'metadata': metadata,
    };
  }

  @override
  String toString() {
    return 'DialerLaunchResult('
        'success: $success, '
        'method: ${launchMethod.label}, '
        'dialer: ${dialerName ?? 'unknown'}, '
        'error: ${errorCode.label})';
  }
}