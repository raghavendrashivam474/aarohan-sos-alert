// ============================================
// Aarohan SOS Alert
// File        : services/dispatch/dispatch_engine.dart
// Description : Central Dispatch Engine
// Sprint      : 2 - Emergency Dispatch Engine
// ============================================

import 'dart:developer' as developer;
import '../../models/dispatch/emergency_alert.dart';
import '../../models/dispatch/dispatch_result.dart';
import 'dispatcher.dart';
import 'simulation_dispatcher.dart';
import 'sms_dispatcher.dart';
import 'call_dispatcher.dart';
import 'share_dispatcher.dart';

// ----------------------------
// Dispatch Engine
// ----------------------------

/// Central orchestrator for all emergency dispatchers.
///
/// The engine:
/// - Maintains a registry of available dispatchers
/// - Selects appropriate dispatcher based on request
/// - Coordinates single or multi-dispatcher dispatch
/// - Aggregates results
///
/// The UI and Controller layers interact ONLY with this engine.
/// They never directly instantiate or call individual dispatchers.
class DispatchEngine {
  // ----------------------------
  // Singleton Setup
  // ----------------------------

  static final DispatchEngine _instance = DispatchEngine._internal();
  factory DispatchEngine() => _instance;

  DispatchEngine._internal() {
    _registerDefaultDispatchers();
  }

  // ----------------------------
  // Dispatcher Registry
  // ----------------------------

  final Map<DispatchMethod, Dispatcher> _dispatchers = {};

  DispatchMethod _preferredMethod = DispatchMethod.simulation;

  // ----------------------------
  // Default Registration
  // ----------------------------

  void _registerDefaultDispatchers() {
    register(SimulationDispatcher());
    register(ShareDispatcher());
    register(SmsDispatcher());
    register(CallDispatcher());

    _log('Dispatch Engine initialized with ${_dispatchers.length} dispatchers');
  }

  // ----------------------------
  // Registration Management
  // ----------------------------

  /// Registers a dispatcher with the engine.
  /// Existing dispatcher for the same method will be replaced.
  void register(Dispatcher dispatcher) {
    _dispatchers[dispatcher.method] = dispatcher;
    _log('Registered: ${dispatcher.name}');
  }

  /// Unregisters a dispatcher for the given method.
  void unregister(DispatchMethod method) {
    final removed = _dispatchers.remove(method);
    if (removed != null) {
      _log('Unregistered: ${removed.name}');
    }
  }

  /// Returns all registered dispatchers.
  List<Dispatcher> get allDispatchers => _dispatchers.values.toList();

  /// Returns count of registered dispatchers.
  int get dispatcherCount => _dispatchers.length;

  // ----------------------------
  // Preferred Method Configuration
  // ----------------------------

  /// Sets the preferred dispatch method used when no explicit method is passed.
  void setPreferredMethod(DispatchMethod method) {
    if (!_dispatchers.containsKey(method)) {
      _log('Warning: Preferred method ${method.label} is not registered');
      return;
    }
    _preferredMethod = method;
    _log('Preferred method set to: ${method.label}');
  }

  DispatchMethod get preferredMethod => _preferredMethod;

  // ----------------------------
  // Availability Checks
  // ----------------------------

  /// Returns list of dispatchers that are currently available.
  Future<List<Dispatcher>> getAvailableDispatchers() async {
    final available = <Dispatcher>[];

    for (final dispatcher in _dispatchers.values) {
      if (await dispatcher.isAvailable()) {
        available.add(dispatcher);
      }
    }

    return available;
  }

  /// Checks if a specific dispatch method is available.
  Future<bool> isMethodAvailable(DispatchMethod method) async {
    final dispatcher = _dispatchers[method];
    if (dispatcher == null) return false;
    return await dispatcher.isAvailable();
  }

  // ----------------------------
  // Core Dispatch Methods
  // ----------------------------

  /// Dispatches alert using the specified method.
  /// If method not provided, uses the preferred method.
  Future<DispatchResult> dispatch(
    EmergencyAlert alert, {
    DispatchMethod? method,
  }) async {
    final selectedMethod = method ?? _preferredMethod;
    final dispatcher = _dispatchers[selectedMethod];

    _log('=== Engine Dispatch Request ===');
    _log('Method       : ${selectedMethod.label}');
    _log('Alert ID     : ${alert.alertId}');

    if (dispatcher == null) {
      _log('No dispatcher registered for ${selectedMethod.label}');
      return DispatchResult.failure(
        method: selectedMethod,
        errorMessage: 'No dispatcher registered for ${selectedMethod.label}',
      );
    }

    _log('Dispatcher   : ${dispatcher.name}');

    try {
      final result = await dispatcher.dispatch(alert);
      _log('Dispatch completed: ${result.summary}');
      return result;
    } catch (e, stackTrace) {
      _log('Unexpected error: $e');
      _log('Stack: $stackTrace');
      return DispatchResult.failure(
        method: selectedMethod,
        errorMessage: 'Engine error: ${e.toString()}',
        recipientCount: alert.contactCount,
      );
    }
  }

  /// Dispatches alert through multiple methods in parallel.
  /// Returns individual result for each attempted method.
  Future<Map<DispatchMethod, DispatchResult>> dispatchMultiple(
    EmergencyAlert alert, {
    required List<DispatchMethod> methods,
  }) async {
    _log('=== Multi-Method Dispatch ===');
    _log('Methods      : ${methods.map((m) => m.label).join(", ")}');

    final results = <DispatchMethod, DispatchResult>{};
    final futures = <Future<void>>[];

    for (final method in methods) {
      futures.add(
        dispatch(alert, method: method).then((result) {
          results[method] = result;
        }),
      );
    }

    await Future.wait(futures);

    _log('Multi-dispatch complete: ${results.length} results');
    return results;
  }

  /// Dispatches alert using the first available dispatcher from the priority list.
  /// Falls back to next dispatcher if current one fails or is unavailable.
  Future<DispatchResult> dispatchWithFallback(
    EmergencyAlert alert, {
    required List<DispatchMethod> priorityOrder,
  }) async {
    _log('=== Fallback Dispatch ===');
    _log('Priority     : ${priorityOrder.map((m) => m.label).join(" → ")}');

    for (final method in priorityOrder) {
      final dispatcher = _dispatchers[method];

      if (dispatcher == null) {
        _log('Skipping ${method.label}: not registered');
        continue;
      }

      final available = await dispatcher.isAvailable();
      if (!available) {
        _log('Skipping ${method.label}: not available');
        continue;
      }

      _log('Trying ${method.label}...');
      final result = await dispatcher.dispatch(alert);

      if (result.success) {
        _log('Fallback dispatch succeeded via ${method.label}');
        return result;
      }

      _log('${method.label} failed, trying next...');
    }

    _log('All fallback options exhausted');
    return DispatchResult.failure(
      method: DispatchMethod.none,
      errorMessage: 'All dispatch methods failed or unavailable',
      recipientCount: alert.contactCount,
    );
  }

  // ----------------------------
  // Engine Status
  // ----------------------------

  Map<String, dynamic> getEngineStatus() {
    return {
      'dispatcherCount': _dispatchers.length,
      'preferredMethod': _preferredMethod.label,
      'registeredMethods':
          _dispatchers.keys.map((m) => m.label).toList(),
    };
  }

  // ----------------------------
  // Internal Logging
  // ----------------------------

  void _log(String message) {
    developer.log(message, name: 'DispatchEngine');
  }
}