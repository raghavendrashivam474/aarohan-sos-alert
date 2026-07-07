// ============================================
// Aarohan SOS Alert
// File        : services/dispatch/strategy/sequential_strategy.dart
// Description : Sequential Multi-Channel Strategy
// Sprint      : 3 - Real Emergency Communication Layer
// ============================================

import '../../../models/dispatch/emergency_alert.dart';
import '../../../models/dispatch/dispatch_result.dart';
import '../../../models/dispatch/strategy/strategy_config.dart';
import '../../../models/dispatch/strategy/strategy_result.dart';
import '../dispatcher.dart';
import 'dispatch_strategy.dart';

// ----------------------------
// Sequential Strategy
// ----------------------------

/// Executes dispatchers one after another in the order specified.
///
/// Behavior:
/// - Runs each dispatcher and waits for it to complete
/// - Applies configured delay between dispatchers
/// - Optionally stops on first success or first failure
/// - Aggregates all results
///
/// Best For:
/// - Users who want to maximize reach
/// - Sending via multiple channels for redundancy
/// - Example: SMS → Share → Call
class SequentialStrategy extends DispatchStrategy {
  // ----------------------------
  // Properties
  // ----------------------------

  @override
  StrategyType get type => StrategyType.sequential;

  @override
  String get name => 'Sequential Strategy';

  // ----------------------------
  // Core Execution
  // ----------------------------

  @override
  Future<StrategyResult> execute({
    required EmergencyAlert alert,
    required Map<DispatchMethod, Dispatcher> dispatchers,
    required StrategyConfig config,
  }) async {
    log('=== Sequential Strategy Started ===');
    log('Alert ID     : ${alert.alertId}');
    log('Methods      : ${config.methods.map((m) => m.label).join(" → ")}');
    log('Delay        : ${config.delayBetween.inMilliseconds}ms');

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
    final results = <DispatchResult>[];
    String? abortReason;

    // Step 3 - Execute each dispatcher in order
    for (int i = 0; i < config.methods.length; i++) {
      final method = config.methods[i];
      final dispatcher = dispatchers[method];

      if (dispatcher == null) {
        log('Skipping ${method.label}: dispatcher not found');
        results.add(
          DispatchResult.skipped(
            method: method,
            reason: 'Dispatcher not registered',
          ),
        );
        continue;
      }

      log('[${i + 1}/${config.methods.length}] Running ${dispatcher.name}');

      // Execute safely
      final result = await safeDispatch(
        dispatcher: dispatcher,
        alert: alert,
      );

      results.add(result);

      // Check stop-on-success condition
      if (config.stopOnFirstSuccess && result.success) {
        log('Stopping early: first success achieved');
        break;
      }

      // Check stop-on-failure condition
      if (config.stopOnFirstFailure && !result.success) {
        log('Stopping early: first failure encountered');
        abortReason = 'Stopped due to failure on ${method.label}';
        break;
      }

      // Apply delay before next dispatcher (except after last)
      if (i < config.methods.length - 1 &&
          config.delayBetween.inMilliseconds > 0) {
        log('Waiting ${config.delayBetween.inMilliseconds}ms before next');
        await Future.delayed(config.delayBetween);
      }
    }

    // Step 4 - Build final result
    final strategyResult = StrategyResult.build(
      config: config,
      results: results,
      startedAt: startedAt,
      abortReason: abortReason,
    );

    log('=== Sequential Strategy Completed ===');
    log('Status: ${strategyResult.status.label}');
    log('Summary: ${strategyResult.summary}');

    // Step 5 - Post-execute hook
    await onAfterExecute(alert, strategyResult);

    return strategyResult;
  }
}