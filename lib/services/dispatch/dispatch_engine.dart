// ============================================
// Aarohan SOS Alert
// File        : services/dispatch/dispatch_engine.dart
// Description : Central Dispatch Engine (Sprint 3 - Strategy Aware)
// Sprint      : 3 - Real Emergency Communication Layer
// ============================================

import 'dart:developer' as developer;
import '../../models/dispatch/emergency_alert.dart';
import '../../models/dispatch/dispatch_result.dart';
import '../../models/dispatch/strategy/strategy_config.dart';
import '../../models/dispatch/strategy/strategy_result.dart';
import 'dispatcher.dart';
import 'simulation_dispatcher.dart';
import 'sms_dispatcher.dart';
import 'call_dispatcher.dart';
import 'share_dispatcher.dart';
import 'strategy/dispatch_strategy.dart';
import 'strategy/sequential_strategy.dart';
import 'strategy/parallel_strategy.dart';
import 'strategy/fallback_strategy.dart';

// ----------------------------
// Dispatch Engine
// ----------------------------

/// Central orchestrator for all emergency dispatchers and strategies.
///
/// The engine:
/// - Maintains a registry of dispatchers
/// - Maintains a registry of execution strategies
/// - Selects appropriate strategy based on config
/// - Coordinates multi-dispatcher execution
/// - Aggregates results
///
/// The UI and Controller layers interact ONLY with this engine.
/// They never directly instantiate dispatchers or strategies.
class DispatchEngine {
  // ----------------------------
  // Singleton Setup
  // ----------------------------

  static final DispatchEngine _instance = DispatchEngine._internal();
  factory DispatchEngine() => _instance;

  DispatchEngine._internal() {
    _registerDefaultDispatchers();
    _registerDefaultStrategies();
  }

  // ----------------------------
  // Registries
  // ----------------------------

  final Map<DispatchMethod, Dispatcher> _dispatchers = {};
  final Map<StrategyType, DispatchStrategy> _strategies = {};

  DispatchMethod _preferredMethod = DispatchMethod.share;
  StrategyConfig _defaultStrategy = StrategyConfig.shareOnly();

  // ----------------------------
  // Default Registration
  // ----------------------------

  void _registerDefaultDispatchers() {
    registerDispatcher(SimulationDispatcher());
    registerDispatcher(ShareDispatcher());
    registerDispatcher(SmsDispatcher());
    registerDispatcher(CallDispatcher());
    _log('Registered ${_dispatchers.length} dispatchers');
  }

  void _registerDefaultStrategies() {
    registerStrategy(SequentialStrategy());
    registerStrategy(ParallelStrategy());
    registerStrategy(FallbackStrategy());
    _log('Registered ${_strategies.length} strategies');
  }

  // ----------------------------
  // Dispatcher Registration
  // ----------------------------

  void registerDispatcher(Dispatcher dispatcher) {
    _dispatchers[dispatcher.method] = dispatcher;
    _log('Registered dispatcher: ${dispatcher.name}');
  }

  void unregisterDispatcher(DispatchMethod method) {
    final removed = _dispatchers.remove(method);
    if (removed != null) {
      _log('Unregistered dispatcher: ${removed.name}');
    }
  }

  List<Dispatcher> get allDispatchers => _dispatchers.values.toList();

  int get dispatcherCount => _dispatchers.length;

  Dispatcher? getDispatcher(DispatchMethod method) => _dispatchers[method];

  // ----------------------------
  // Strategy Registration
  // ----------------------------

  void registerStrategy(DispatchStrategy strategy) {
    _strategies[strategy.type] = strategy;
    _log('Registered strategy: ${strategy.name}');
  }

  void unregisterStrategy(StrategyType type) {
    final removed = _strategies.remove(type);
    if (removed != null) {
      _log('Unregistered strategy: ${removed.name}');
    }
  }

  List<DispatchStrategy> get allStrategies => _strategies.values.toList();

  int get strategyCount => _strategies.length;

  DispatchStrategy? getStrategy(StrategyType type) => _strategies[type];

  // ----------------------------
  // Preferred Configuration
  // ----------------------------

  void setPreferredMethod(DispatchMethod method) {
    if (!_dispatchers.containsKey(method)) {
      _log('Warning: ${method.label} not registered');
      return;
    }
    _preferredMethod = method;
    _defaultStrategy = StrategyConfig.single(method);
    _log('Preferred method set to: ${method.label}');
  }

  void setDefaultStrategy(StrategyConfig config) {
    _defaultStrategy = config;
    _log('Default strategy set to: ${config.displayName}');
  }

  DispatchMethod get preferredMethod => _preferredMethod;

  StrategyConfig get defaultStrategy => _defaultStrategy;

  // ----------------------------
  // Availability Checks
  // ----------------------------

  Future<List<Dispatcher>> getAvailableDispatchers() async {
    final available = <Dispatcher>[];
    for (final dispatcher in _dispatchers.values) {
      if (await dispatcher.isAvailable()) {
        available.add(dispatcher);
      }
    }
    return available;
  }

  Future<bool> isMethodAvailable(DispatchMethod method) async {
    final dispatcher = _dispatchers[method];
    if (dispatcher == null) return false;
    return await dispatcher.isAvailable();
  }

  Future<Map<DispatchMethod, bool>> getAvailabilityMap() async {
    final map = <DispatchMethod, bool>{};
    for (final entry in _dispatchers.entries) {
      map[entry.key] = await entry.value.isAvailable();
    }
    return map;
  }

  // ----------------------------
  // Core Dispatch Methods
  // ----------------------------

  /// Dispatches alert using a single specified method.
  /// Backward compatible with Sprint 2.
  Future<DispatchResult> dispatch(
    EmergencyAlert alert, {
    DispatchMethod? method,
  }) async {
    final selectedMethod = method ?? _preferredMethod;
    final dispatcher = _dispatchers[selectedMethod];

    _log('=== Single Dispatch ===');
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
      _log('Result: ${result.summary}');
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

  // ----------------------------
  // Strategy Execution
  // ----------------------------

  /// Executes dispatch using a full strategy configuration.
  /// This is the NEW primary entry point in Sprint 3.
  Future<StrategyResult> executeStrategy(
    EmergencyAlert alert,
    StrategyConfig config,
  ) async {
    _log('=== Strategy Execution ===');
    _log('Alert ID     : ${alert.alertId}');
    _log('Strategy     : ${config.type.label}');
    _log('Methods      : ${config.methods.map((m) => m.label).join(", ")}');

    // Validate strategy config
    if (!config.isValid) {
      _log('Invalid config: ${config.validationError}');
      return StrategyResult.empty(
        config: config,
        reason: config.validationError ?? 'Invalid strategy configuration',
      );
    }

    // Get the strategy implementation
    final strategy = _strategies[config.type];
    if (strategy == null) {
      _log('No strategy registered for ${config.type.label}');
      return StrategyResult.empty(
        config: config,
        reason: 'No strategy registered for ${config.type.label}',
      );
    }

    _log('Executing via: ${strategy.name}');

    // Execute
    try {
      final result = await strategy.execute(
        alert: alert,
        dispatchers: _dispatchers,
        config: config,
      );
      _log('Strategy completed: ${result.summary}');
      return result;
    } catch (e, stackTrace) {
      _log('Strategy execution error: $e');
      _log('Stack: $stackTrace');
      return StrategyResult.empty(
        config: config,
        reason: 'Strategy execution failed: ${e.toString()}',
      );
    }
  }

  /// Convenience: Execute using the current default strategy.
  Future<StrategyResult> executeDefaultStrategy(
    EmergencyAlert alert,
  ) async {
    return executeStrategy(alert, _defaultStrategy);
  }

  // ----------------------------
  // Legacy Multi-Dispatch (Sprint 2 API)
  // ----------------------------

  /// Legacy API from Sprint 2. Delegates to parallel strategy.
  @Deprecated('Use executeStrategy() with StrategyType.parallel instead')
  Future<Map<DispatchMethod, DispatchResult>> dispatchMultiple(
    EmergencyAlert alert, {
    required List<DispatchMethod> methods,
  }) async {
    final config = StrategyConfig(
      type: StrategyType.parallel,
      methods: methods,
    );

    final strategyResult = await executeStrategy(alert, config);

    // Convert to legacy format
    final legacyMap = <DispatchMethod, DispatchResult>{};
    for (final result in strategyResult.results) {
      legacyMap[result.method] = result;
    }
    return legacyMap;
  }

  /// Legacy API from Sprint 2. Delegates to fallback strategy.
  @Deprecated('Use executeStrategy() with StrategyType.fallback instead')
  Future<DispatchResult> dispatchWithFallback(
    EmergencyAlert alert, {
    required List<DispatchMethod> priorityOrder,
  }) async {
    final config = StrategyConfig(
      type: StrategyType.fallback,
      methods: priorityOrder,
      stopOnFirstSuccess: true,
    );

    final strategyResult = await executeStrategy(alert, config);

    // Return the successful result, or the last failure
    for (final result in strategyResult.results) {
      if (result.success) return result;
    }

    if (strategyResult.results.isNotEmpty) {
      return strategyResult.results.last;
    }

    return DispatchResult.failure(
      method: DispatchMethod.none,
      errorMessage: strategyResult.abortReason ??
          'All dispatch methods failed',
      recipientCount: alert.contactCount,
    );
  }

  // ----------------------------
  // Engine Status
  // ----------------------------

  Map<String, dynamic> getEngineStatus() {
    return {
      'dispatcherCount': _dispatchers.length,
      'strategyCount': _strategies.length,
      'preferredMethod': _preferredMethod.label,
      'defaultStrategy': _defaultStrategy.displayName,
      'registeredDispatchers':
          _dispatchers.keys.map((m) => m.label).toList(),
      'registeredStrategies':
          _strategies.keys.map((t) => t.label).toList(),
    };
  }

  // ----------------------------
  // Internal Logging
  // ----------------------------

  void _log(String message) {
    developer.log(message, name: 'DispatchEngine');
  }
}