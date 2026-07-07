// ============================================
// Aarohan SOS Alert
// File        : services/dispatch/strategy/fallback_strategy.dart
// Description : Priority-Based Fallback Strategy
// Sprint      : 3 - Real Emergency Communication Layer
// ============================================

import '../../../models/dispatch/emergency_alert.dart';
import '../../../models/dispatch/dispatch_result.dart';
import '../../../models/dispatch/strategy/strategy_config.dart';
import '../../../models/dispatch/strategy/strategy_result.dart';
import '../dispatcher.dart';
import 'dispatch_strategy.dart';

// ----------------------------
// Fallback Strategy
// ----------------------------

/// Executes dispatchers in priority order, stopping at first success.
///
/// Behavior:
/// - Tries the first dispatcher in the list
/// - If it succeeds, stops immediately
/// - If it fails or is unavailable, tries the next
/// - Continues until success or all exhausted
///
/// This is the SMARTEST strategy:
/// - Checks availability BEFORE attempting
/// - Skips unavailable dispatchers gracefully
/// - Guarantees best-effort delivery
///
/// Best For:
/// - Reliability-critical situations
/// - When you want ONE guaranteed delivery
/// - Example: Try SMS first (silent), fall back to Share (visible)
class FallbackStrategy extends DispatchStrategy {
  // ----------------------------
  // Properties
  // ----------------------------

  @override
  StrategyType get type => StrategyType.fallback;

  @override
  String get name => 'Fallback Strategy';

  // ----------------------------
  // Core Execution
  // ----------------------------

  @override
  Future<StrategyResult> execute({
    required EmergencyAlert alert,
    required Map<DispatchMethod, Dispatcher> dispatchers,
    required StrategyConfig config,
  }) async {
    log('=== Fallback Strategy Started ===');
    log('Alert ID     : ${alert.alertId}');
    log('Priority     : ${config.methods.map((m) => m.label).join(" ⇢ ")}');

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
    bool successAchieved = false;

    // Step 3 - Try each dispatcher in priority order
    for (int i = 0; i < config.methods.length; i++) {
      final method = config.methods[i];
      final dispatcher = dispatchers[method];

      log('[Priority ${i + 1}] Trying ${method.label}');

      if (dispatcher == null) {
        log('  → Skipping: dispatcher not registered');
        results.add(
          DispatchResult.skipped(
            method: method,
            reason: 'Dispatcher not registered',
          ),
        );
        continue;
      }

      // Check availability BEFORE attempting
      final available = await dispatcher.isAvailable();
      if (!available) {
        log('  → Skipping: dispatcher not available');
        results.add(
          DispatchResult.skipped(
            method: method,
            reason: '${dispatcher.name} is not available on this device',
          ),
        );
        continue;
      }

      // Execute safely
      log('  → Executing ${dispatcher.name}');
      final result = await safeDispatch(
        dispatcher: dispatcher,
        alert: alert,
      );

      results.add(result);

      // Check for success
      if (result.success) {
        log('  ✓ SUCCESS via ${method.label}');
        log('  → Stopping fallback chain');
        successAchieved = true;
        break;
      } else {
        log('  ✗ Failed: ${result.errorMessage ?? "unknown"}');
        log('  → Trying next fallback');

        // Apply delay before next attempt
        if (i < config.methods.length - 1 &&
            config.delayBetween.inMilliseconds > 0) {
          log('  → Waiting ${config.delayBetween.inMilliseconds}ms');
          await Future.delayed(config.delayBetween);
        }
      }
    }

    // Step 4 - Determine outcome
    String? abortReason;
    if (!successAchieved && results.isEmpty) {
      abortReason = 'No dispatchers were available';
    } else if (!successAchieved) {
      log('All fallback options exhausted without success');
    }

    // Step 5 - Build final result
    final strategyResult = StrategyResult.build(
      config: config,
      results: results,
      startedAt: startedAt,
      abortReason: abortReason,
    );

    log('=== Fallback Strategy Completed ===');
    log('Status  : ${strategyResult.status.label}');
    log('Attempts: ${results.length}');
    log('Summary : ${strategyResult.summary}');

    // Step 6 - Post-execute hook
    await onAfterExecute(alert, strategyResult);

    return strategyResult;
  }
}