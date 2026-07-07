// ============================================
// Aarohan SOS Alert
// File        : services/dispatch/strategy/dispatch_strategy.dart
// Description : Base Strategy Interface
// Sprint      : 3 - Real Emergency Communication Layer
// ============================================

import 'dart:developer' as developer;
import '../../../models/dispatch/emergency_alert.dart';
import '../../../models/dispatch/dispatch_result.dart';
import '../../../models/dispatch/strategy/strategy_config.dart';
import '../../../models/dispatch/strategy/strategy_result.dart';
import '../dispatcher.dart';

// ----------------------------
// Dispatch Strategy Base
// ----------------------------

/// Abstract base for all dispatch execution strategies.
///
/// Different strategies define HOW dispatchers should be executed:
/// - Sequential: one at a time, wait for each
/// - Parallel: all at once
/// - Fallback: try until one succeeds
///
/// Each strategy receives the same inputs:
/// - EmergencyAlert
/// - Available dispatchers map
/// - StrategyConfig
///
/// And returns the same output:
/// - StrategyResult (aggregate outcome)
///
/// This makes strategies interchangeable and easy to add.
abstract class DispatchStrategy {
  // ----------------------------
  // Required Properties
  // ----------------------------

  /// The strategy type this class implements.
  StrategyType get type;

  /// Human-readable name.
  String get name;

  // ----------------------------
  // Core Execution
  // ----------------------------

  /// Executes the strategy using provided dispatchers.
  ///
  /// [alert] - Emergency alert to dispatch
  /// [dispatchers] - Available dispatcher registry
  /// [config] - Strategy configuration
  ///
  /// Returns aggregate StrategyResult.
  Future<StrategyResult> execute({
    required EmergencyAlert alert,
    required Map<DispatchMethod, Dispatcher> dispatchers,
    required StrategyConfig config,
  });

  // ----------------------------
  // Shared Helpers
  // ----------------------------

  /// Validates the strategy configuration before execution.
  StrategyResult? validateConfig(StrategyConfig config) {
    if (!config.isValid) {
      return StrategyResult.empty(
        config: config,
        reason: config.validationError ?? 'Invalid strategy config',
      );
    }
    return null;
  }

  /// Validates that all required dispatchers are available.
  StrategyResult? validateDispatchers({
    required StrategyConfig config,
    required Map<DispatchMethod, Dispatcher> dispatchers,
  }) {
    final missing = <DispatchMethod>[];

    for (final method in config.methods) {
      if (!dispatchers.containsKey(method)) {
        missing.add(method);
      }
    }

    if (missing.isNotEmpty) {
      final missingLabels = missing.map((m) => m.label).join(', ');
      return StrategyResult.empty(
        config: config,
        reason: 'Missing dispatchers: $missingLabels',
      );
    }

    return null;
  }

  /// Validates the alert object.
  StrategyResult? validateAlert(EmergencyAlert alert, StrategyConfig config) {
    if (!alert.isValid) {
      return StrategyResult.empty(
        config: config,
        reason: alert.validationError ?? 'Invalid emergency alert',
      );
    }
    return null;
  }

  /// Runs all pre-execution validations.
  /// Returns null if valid, or a StrategyResult with abort reason.
  StrategyResult? runValidations({
    required EmergencyAlert alert,
    required Map<DispatchMethod, Dispatcher> dispatchers,
    required StrategyConfig config,
  }) {
    // Validate config first
    final configError = validateConfig(config);
    if (configError != null) return configError;

    // Validate dispatchers exist
    final dispatcherError = validateDispatchers(
      config: config,
      dispatchers: dispatchers,
    );
    if (dispatcherError != null) return dispatcherError;

    // Validate alert
    final alertError = validateAlert(alert, config);
    if (alertError != null) return alertError;

    return null;
  }

  // ----------------------------
  // Safe Dispatcher Execution
  // ----------------------------

  /// Executes a single dispatcher with full error handling.
  /// Never throws - always returns a DispatchResult.
  Future<DispatchResult> safeDispatch({
    required Dispatcher dispatcher,
    required EmergencyAlert alert,
  }) async {
    try {
      log('Executing dispatcher: ${dispatcher.name}');
      final result = await dispatcher.dispatch(alert);
      log('Dispatcher completed: ${result.summary}');
      return result;
    } catch (e, stackTrace) {
      log('Dispatcher error: $e');
      log('Stack: $stackTrace');
      return DispatchResult.failure(
        method: dispatcher.method,
        errorMessage: 'Dispatcher threw exception: ${e.toString()}',
        recipientCount: alert.contactCount,
      );
    }
  }

  // ----------------------------
  // Lifecycle Hooks
  // ----------------------------

  /// Called before strategy execution begins.
  Future<void> onBeforeExecute(
    EmergencyAlert alert,
    StrategyConfig config,
  ) async {
    // Default: no-op
  }

  /// Called after strategy execution completes.
  Future<void> onAfterExecute(
    EmergencyAlert alert,
    StrategyResult result,
  ) async {
    // Default: no-op
  }

  // ----------------------------
  // Logging
  // ----------------------------

  void log(String message) {
    developer.log(message, name: 'DispatchStrategy[$name]');
  }

  // ----------------------------
  // Description
  // ----------------------------

  @override
  String toString() {
    return 'DispatchStrategy(name: $name, type: ${type.label})';
  }
}