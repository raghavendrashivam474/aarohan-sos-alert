// ============================================
// Aarohan SOS Alert
// File        : services/dispatch/simulation_dispatcher.dart
// Description : MVP Simulation Dispatcher
// Sprint      : 2 - Emergency Dispatch Engine
// ============================================

import 'dart:developer' as developer;
import '../../models/dispatch/emergency_alert.dart';
import '../../models/dispatch/dispatch_result.dart';
import 'dispatcher.dart';

// ----------------------------
// Simulation Dispatcher
// ----------------------------

/// Simulates emergency alert dispatch for MVP demonstration.
///
/// This dispatcher does NOT perform any external communication.
/// It logs the dispatch activity and returns a successful result.
///
/// Used for:
/// - MVP demonstrations
/// - Development and testing
/// - Environments where real dispatch is not available
class SimulationDispatcher extends Dispatcher {
  // ----------------------------
  // Configuration
  // ----------------------------

  final Duration simulatedDelay;
  final bool logToConsole;

  SimulationDispatcher({
    this.simulatedDelay = const Duration(milliseconds: 800),
    this.logToConsole = true,
  });

  // ----------------------------
  // Dispatcher Properties
  // ----------------------------

  @override
  DispatchMethod get method => DispatchMethod.simulation;

  @override
  String get name => 'Simulation Dispatcher';

  @override
  Future<bool> isAvailable() async {
    // Simulation is always available
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

    // Step 3 - Log dispatch initiation
    _log('=== Emergency Dispatch Simulation ===');
    _log('Alert ID     : ${alert.alertId}');
    _log('User         : ${alert.userName}');
    _log('User Phone   : ${alert.userPhone}');
    _log('Coordinates  : ${alert.formattedCoordinates}');
    _log('Map Link     : ${alert.mapLink}');
    _log('Timestamp    : ${alert.formattedTimestamp}');
    _log('Contacts     : ${alert.contactCount}');

    for (int i = 0; i < alert.contacts.length; i++) {
      final contact = alert.contacts[i];
      _log(
        '  ${i + 1}. ${contact.name} (${contact.relationship}) - ${contact.phone}',
      );
    }

    _log('Message Preview:');
    _log('---');
    for (final line in alert.message.split('\n')) {
      _log('  $line');
    }
    _log('---');

    // Step 4 - Simulate network delay
    if (simulatedDelay.inMilliseconds > 0) {
      await Future.delayed(simulatedDelay);
    }

    // Step 5 - Build success result
    final result = DispatchResult.success(
      method: method,
      recipientCount: alert.contactCount,
      metadata: {
        'alertId': alert.alertId,
        'simulated': true,
        'simulationDelayMs': simulatedDelay.inMilliseconds,
        'timestamp': alert.timestamp.toIso8601String(),
        'coordinates': alert.formattedCoordinates,
      },
    );

    _log('Dispatch simulation complete');
    _log('Result: ${result.summary}');
    _log('=====================================');

    // Step 6 - Post-dispatch hook
    await onAfterDispatch(alert, result);

    return result;
  }

  // ----------------------------
  // Internal Logging
  // ----------------------------

  void _log(String message) {
    if (!logToConsole) return;
    developer.log(message, name: 'SimulationDispatcher');
  }
}