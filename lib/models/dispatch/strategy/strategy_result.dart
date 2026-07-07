// ============================================
// Aarohan SOS Alert
// File        : models/dispatch/strategy/strategy_result.dart
// Description : Multi-Dispatch Aggregate Result
// Sprint      : 3 - Real Emergency Communication Layer
// ============================================

import '../dispatch_result.dart';
import 'strategy_config.dart';

// ----------------------------
// Overall Strategy Status
// ----------------------------

enum StrategyStatus {
  allSucceeded,
  partiallySucceeded,
  allFailed,
  allSkipped,
  aborted,
}

extension StrategyStatusExt on StrategyStatus {
  String get label {
    switch (this) {
      case StrategyStatus.allSucceeded:
        return 'All Succeeded';
      case StrategyStatus.partiallySucceeded:
        return 'Partially Succeeded';
      case StrategyStatus.allFailed:
        return 'All Failed';
      case StrategyStatus.allSkipped:
        return 'All Skipped';
      case StrategyStatus.aborted:
        return 'Aborted';
    }
  }

  bool get isPositive =>
      this == StrategyStatus.allSucceeded ||
      this == StrategyStatus.partiallySucceeded;
}

// ----------------------------
// Strategy Result
// ----------------------------

/// Aggregate result of a multi-dispatcher strategy execution.
///
/// Contains individual DispatchResults for every attempted dispatcher,
/// plus overall status summarizing the combined outcome.
class StrategyResult {
  // ----------------------------
  // Fields
  // ----------------------------

  final StrategyConfig config;
  final List<DispatchResult> results;
  final StrategyStatus status;
  final DateTime startedAt;
  final DateTime completedAt;
  final String? abortReason;

  // ----------------------------
  // Constructor
  // ----------------------------

  StrategyResult({
    required this.config,
    required this.results,
    required this.status,
    required this.startedAt,
    required this.completedAt,
    this.abortReason,
  });

  // ----------------------------
  // Factory Constructors
  // ----------------------------

  factory StrategyResult.build({
    required StrategyConfig config,
    required List<DispatchResult> results,
    required DateTime startedAt,
    String? abortReason,
  }) {
    final status = _computeStatus(results, abortReason);

    return StrategyResult(
      config: config,
      results: results,
      status: status,
      startedAt: startedAt,
      completedAt: DateTime.now(),
      abortReason: abortReason,
    );
  }

  factory StrategyResult.empty({
    required StrategyConfig config,
    required String reason,
  }) {
    final now = DateTime.now();
    return StrategyResult(
      config: config,
      results: [],
      status: StrategyStatus.aborted,
      startedAt: now,
      completedAt: now,
      abortReason: reason,
    );
  }

  // ----------------------------
  // Status Computation
  // ----------------------------

  static StrategyStatus _computeStatus(
    List<DispatchResult> results,
    String? abortReason,
  ) {
    if (abortReason != null) return StrategyStatus.aborted;
    if (results.isEmpty) return StrategyStatus.aborted;

    final successCount =
        results.where((r) => r.status == DispatchStatus.success).length;
    final failedCount =
        results.where((r) => r.status == DispatchStatus.failed).length;
    final skippedCount =
        results.where((r) => r.status == DispatchStatus.skipped).length;
    final partialCount = results
        .where((r) => r.status == DispatchStatus.partialSuccess)
        .length;

    final positiveCount = successCount + partialCount;
    final total = results.length;

    if (positiveCount == total) return StrategyStatus.allSucceeded;
    if (positiveCount > 0) return StrategyStatus.partiallySucceeded;
    if (skippedCount == total) return StrategyStatus.allSkipped;
    if (failedCount == total) return StrategyStatus.allFailed;

    return StrategyStatus.partiallySucceeded;
  }

  // ----------------------------
  // Helpers
  // ----------------------------

  bool get success => status.isPositive;

  int get totalAttempts => results.length;

  int get successfulDispatchers =>
      results.where((r) => r.status == DispatchStatus.success).length;

  int get partialDispatchers => results
      .where((r) => r.status == DispatchStatus.partialSuccess)
      .length;

  int get failedDispatchers =>
      results.where((r) => r.status == DispatchStatus.failed).length;

  int get skippedDispatchers =>
      results.where((r) => r.status == DispatchStatus.skipped).length;

  int get totalRecipientsAttempted =>
      results.fold(0, (sum, r) => sum + r.recipientCount);

  int get totalRecipientsSucceeded =>
      results.fold(0, (sum, r) => sum + r.successCount);

  int get totalRecipientsFailed =>
      results.fold(0, (sum, r) => sum + r.failureCount);

  Duration get executionDuration => completedAt.difference(startedAt);

  List<DispatchMethod> get attemptedMethods =>
      results.map((r) => r.method).toList();

  List<DispatchMethod> get successfulMethods => results
      .where((r) => r.status == DispatchStatus.success)
      .map((r) => r.method)
      .toList();

  List<DispatchMethod> get failedMethods => results
      .where((r) => r.status == DispatchStatus.failed)
      .map((r) => r.method)
      .toList();

  // ----------------------------
  // Summary
  // ----------------------------

  String get summary {
    if (abortReason != null) {
      return 'Strategy aborted: $abortReason';
    }

    if (results.isEmpty) {
      return 'No dispatchers executed';
    }

    switch (status) {
      case StrategyStatus.allSucceeded:
        return '$successfulDispatchers of $totalAttempts channels succeeded';
      case StrategyStatus.partiallySucceeded:
        final positive = successfulDispatchers + partialDispatchers;
        return '$positive of $totalAttempts channels reached recipients';
      case StrategyStatus.allFailed:
        return 'All $totalAttempts channels failed';
      case StrategyStatus.allSkipped:
        return 'All $totalAttempts channels skipped';
      case StrategyStatus.aborted:
        return 'Strategy aborted before completion';
    }
  }

  String get detailedSummary {
    final buffer = StringBuffer();
    buffer.writeln('Strategy: ${config.displayName}');
    buffer.writeln('Status: ${status.label}');
    buffer.writeln('Duration: ${executionDuration.inMilliseconds}ms');
    buffer.writeln('Dispatchers: $totalAttempts');
    buffer.writeln('Successful: $successfulDispatchers');
    buffer.writeln('Failed: $failedDispatchers');
    buffer.writeln('Skipped: $skippedDispatchers');
    buffer.writeln('Recipients: $totalRecipientsSucceeded / $totalRecipientsAttempted');

    if (abortReason != null) {
      buffer.writeln('Abort Reason: $abortReason');
    }

    return buffer.toString();
  }

  // ----------------------------
  // Get Result For Method
  // ----------------------------

  DispatchResult? resultFor(DispatchMethod method) {
    for (final r in results) {
      if (r.method == method) return r;
    }
    return null;
  }

  // ----------------------------
  // Serialization
  // ----------------------------

  Map<String, dynamic> toMap() {
    return {
      'config': config.toMap(),
      'status': status.name,
      'results': results.map((r) => r.toMap()).toList(),
      'startedAt': startedAt.toIso8601String(),
      'completedAt': completedAt.toIso8601String(),
      'durationMs': executionDuration.inMilliseconds,
      'abortReason': abortReason,
    };
  }

  @override
  String toString() {
    return 'StrategyResult('
        'strategy: ${config.displayName}, '
        'status: ${status.label}, '
        'attempts: $totalAttempts)';
  }
}