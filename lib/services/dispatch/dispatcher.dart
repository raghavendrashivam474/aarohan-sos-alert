// ============================================
// Aarohan SOS Alert
// File        : services/dispatch/dispatcher.dart
// Description : Base Dispatcher Interface
// Sprint      : 2 - Emergency Dispatch Engine
// ============================================

import '../../models/dispatch/emergency_alert.dart';
import '../../models/dispatch/dispatch_result.dart';

// ----------------------------
// Base Dispatcher Interface
// ----------------------------

abstract class Dispatcher {
  // ----------------------------
  // Required Properties
  // ----------------------------

  /// The dispatch method this dispatcher implements
  DispatchMethod get method;

  /// Human-readable name of this dispatcher
  String get name;

  /// Whether this dispatcher is currently available and ready to use
  Future<bool> isAvailable();

  // ----------------------------
  // Core Dispatch Method
  // ----------------------------

  /// Dispatches the emergency alert to configured recipients.
  ///
  /// Every implementation MUST:
  /// - Validate the alert before attempting dispatch
  /// - Return a structured DispatchResult
  /// - Never throw unhandled exceptions
  Future<DispatchResult> dispatch(EmergencyAlert alert);

  // ----------------------------
  // Shared Validation Helpers
  // ----------------------------

  /// Validates that the alert has minimum required data
  DispatchResult? validateAlert(EmergencyAlert alert) {
    if (!alert.isValid) {
      return DispatchResult.failure(
        method: method,
        errorMessage: alert.validationError ?? 'Invalid emergency alert',
      );
    }

    if (!alert.hasContacts) {
      return DispatchResult.skipped(
        method: method,
        reason: 'No emergency contacts to notify',
      );
    }

    return null;
  }

  // ----------------------------
  // Lifecycle Hooks (Optional Override)
  // ----------------------------

  /// Called before dispatch begins. Override to add pre-dispatch logic.
  Future<void> onBeforeDispatch(EmergencyAlert alert) async {
    // Default: no-op
  }

  /// Called after dispatch completes. Override to add cleanup logic.
  Future<void> onAfterDispatch(
    EmergencyAlert alert,
    DispatchResult result,
  ) async {
    // Default: no-op
  }

  // ----------------------------
  // Description
  // ----------------------------

  @override
  String toString() {
    return 'Dispatcher(name: $name, method: ${method.label})';
  }
}