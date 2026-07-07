// ============================================
// Aarohan SOS Alert
// File        : services/dispatch/strategy/parallel_strategy.dart
// Description : Parallel Multi-Channel Strategy
// Sprint      : 3 - Real Emergency Communication Layer
// ============================================

import '../../../models/dispatch/emergency_alert.dart';
import '../../../models/dispatch/dispatch_result.dart';
import '../../../models/dispatch/strategy/strategy_config.dart';
import '../../../models/dispatch/strategy/strategy_result.dart';
import '../dispatcher.dart';
import 'dispatch_strategy.dart';

// ----------------------------
// Parallel Strategy
// ----------------------------

/// Executes all dispatchers simultaneously (in parallel).
///
/// Behavior:
/// - Fires all dispatchers at the same time
/// - Waits for all to complete
/// - Aggregates results
///
/// Advantages:
/// - Fastest total execution time
/// - Maximum simultaneous reach
///
/// Trade-offs:
/// - Cannot interact with user between dispatchers
/// - Not suitable for UI-blocking dispatchers (Share, Call)
///   that need to open external apps sequentially
///
/// Best For:
/// - Background dispatchers (SMS, future Email, future API calls)
/// - Independent notification channels
/// - Speed-critical situations
class ParallelStrategy extends DispatchStrategy {
  // ----------------------------
  // Properties
  // ----------------------------

  @override
  StrategyType get type => StrategyType.parallel;

  @override
  String get name => 'Parallel Strategy';

  // ----------------------------
  // Core Execution
  // ----------------------------

  @override
  Future<StrategyResult> execute({
    required EmergencyAlert alert,
    required Map<DispatchMethod, Dispatcher> dispatchers,
    required StrategyConfig config,
  }) async {
    log('=== Parallel Strategy Started ===');
    log('Alert ID     : ${alert.alertId}');
    log('Methods      : ${config.methods.map((m) => m.label).join(" + ")}');

    // Step 1 - Pre-validation
    final validationError = runValidations(
      alert: alert,
      dispatchers: dispatchers,
      config: config,
    );
    if (validationError != null) {
      log('Validation failed: ${validationError.abortReason}');
      return validationError;
    }

    // Step 2 - Pre-execute hook
    await onBeforeExecute(alert, config);

    final startedAt = DateTime.now();
    final futures = <Future<DispatchResult>>[];

    // Step 3 - Fire all dispatchers simultaneously
    for (int i = 0; i < config.methods.length; i++) {
      final method = config.methods[i];
      final dispatcher = dispatchers[method];

      if (dispatcher == null) {
        log('Missing dispatcher for ${method.label} - adding as skipped');
        futures.add(
          Future.value(
            DispatchResult.skipped(
              method: method,
              reason: 'Dispatcher not registered',
            ),
          ),
        );
        continue;
      }

      log('[${i + 1}/${config.methods.length}] Firing ${dispatcher.name}');

      futures.add(
        safeDispatch(dispatcher: dispatcher, alert: alert),
      );
    }

    // Step 4 - Wait for all to complete
    log('Waiting for all ${futures.length} dispatchers to complete...');
    final results = await Future.wait(futures);

    // Step 5 - Build final result
    final strategyResult = StrategyResult.build(
      config: config,
      results: results,
      startedAt: startedAt,
    );

    log('=== Parallel Strategy Completed ===');
    log('Status  : ${strategyResult.status.label}');
    log('Duration: ${strategyResult.executionDuration.inMilliseconds}ms');
    log('Summary : ${strategyResult.summary}');

    // Step 6 - Post-execute hook
    await onAfterExecute(alert, strategyResult);

    return strategyResult;
  }
}