// ============================================
// Aarohan SOS Alert
// File        : models/dispatch/strategy/strategy_config.dart
// Description : Strategy Configuration Model
// Sprint      : 3 - Real Emergency Communication Layer
// ============================================

import '../dispatch_result.dart';

// ----------------------------
// Strategy Type Enum
// ----------------------------

enum StrategyType {
  single,
  sequential,
  parallel,
  fallback,
}

extension StrategyTypeExt on StrategyType {
  String get label {
    switch (this) {
      case StrategyType.single:
        return 'Single Channel';
      case StrategyType.sequential:
        return 'Sequential Multi-Channel';
      case StrategyType.parallel:
        return 'Parallel Multi-Channel';
      case StrategyType.fallback:
        return 'Priority Fallback';
    }
  }

  String get description {
    switch (this) {
      case StrategyType.single:
        return 'Uses one dispatch method';
      case StrategyType.sequential:
        return 'Executes each method one after another';
      case StrategyType.parallel:
        return 'Executes all methods simultaneously';
      case StrategyType.fallback:
        return 'Tries next method if previous fails';
    }
  }
}

// ----------------------------
// Strategy Configuration
// ----------------------------

/// Configures how the DispatchEngine should execute dispatchers.
///
/// Supports multiple execution patterns:
/// - Single: One dispatcher only
/// - Sequential: Run all in order, wait for each
/// - Parallel: Run all at same time
/// - Fallback: Try in priority order until one succeeds
class StrategyConfig {
  // ----------------------------
  // Fields
  // ----------------------------

  final StrategyType type;
  final List<DispatchMethod> methods;
  final Duration delayBetween;
  final bool stopOnFirstSuccess;
  final bool stopOnFirstFailure;
  final Map<String, dynamic> metadata;

  // ----------------------------
  // Constructor
  // ----------------------------

  const StrategyConfig({
    required this.type,
    required this.methods,
    this.delayBetween = Duration.zero,
    this.stopOnFirstSuccess = false,
    this.stopOnFirstFailure = false,
    this.metadata = const {},
  });

  // ----------------------------
  // Factory Presets
  // ----------------------------

  /// Single channel dispatch using specified method.
  factory StrategyConfig.single(DispatchMethod method) {
    return StrategyConfig(
      type: StrategyType.single,
      methods: [method],
    );
  }

  /// Simulation only (for testing).
  factory StrategyConfig.simulation() {
    return StrategyConfig.single(DispatchMethod.simulation);
  }

  /// Share sheet only.
  factory StrategyConfig.shareOnly() {
    return StrategyConfig.single(DispatchMethod.share);
  }

  /// SMS only.
  factory StrategyConfig.smsOnly() {
    return StrategyConfig.single(DispatchMethod.sms);
  }

  /// Call only.
  factory StrategyConfig.callOnly() {
    return StrategyConfig.single(DispatchMethod.call);
  }

  /// SMS followed by Call (sequential).
  factory StrategyConfig.smsThenCall() {
    return const StrategyConfig(
      type: StrategyType.sequential,
      methods: [DispatchMethod.sms, DispatchMethod.call],
      delayBetween: Duration(seconds: 2),
    );
  }

  /// SMS followed by Share (sequential).
  factory StrategyConfig.smsThenShare() {
    return const StrategyConfig(
      type: StrategyType.sequential,
      methods: [DispatchMethod.sms, DispatchMethod.share],
    );
  }

  /// Full sequential: SMS → Share → Call.
  factory StrategyConfig.allSequential() {
    return const StrategyConfig(
      type: StrategyType.sequential,
      methods: [
        DispatchMethod.sms,
        DispatchMethod.share,
        DispatchMethod.call,
      ],
      delayBetween: Duration(seconds: 1),
    );
  }

  /// Fallback: try SMS first, fall back to Share.
  factory StrategyConfig.smsFallbackShare() {
    return const StrategyConfig(
      type: StrategyType.fallback,
      methods: [DispatchMethod.sms, DispatchMethod.share],
      stopOnFirstSuccess: true,
    );
  }

  /// Fallback: try Call first, fall back to SMS, then Share.
  factory StrategyConfig.callFallbackAll() {
    return const StrategyConfig(
      type: StrategyType.fallback,
      methods: [
        DispatchMethod.call,
        DispatchMethod.sms,
        DispatchMethod.share,
      ],
      stopOnFirstSuccess: true,
    );
  }

  /// Parallel: fire SMS and Share at the same time.
  factory StrategyConfig.smsAndShareParallel() {
    return const StrategyConfig(
      type: StrategyType.parallel,
      methods: [DispatchMethod.sms, DispatchMethod.share],
    );
  }

  // ----------------------------
  // Validation
  // ----------------------------

  bool get isValid {
    if (methods.isEmpty) return false;
    if (type == StrategyType.single && methods.length != 1) return false;
    return true;
  }

  String? get validationError {
    if (methods.isEmpty) return 'Strategy must have at least one method';
    if (type == StrategyType.single && methods.length != 1) {
      return 'Single strategy must have exactly one method';
    }
    return null;
  }

  // ----------------------------
  // Description
  // ----------------------------

  String get displayName {
    if (methods.isEmpty) return 'Empty Strategy';
    if (methods.length == 1) return methods.first.label;

    switch (type) {
      case StrategyType.sequential:
        return methods.map((m) => m.label).join(' → ');
      case StrategyType.parallel:
        return methods.map((m) => m.label).join(' + ');
      case StrategyType.fallback:
        return methods.map((m) => m.label).join(' ⇢ ');
      case StrategyType.single:
        return methods.first.label;
    }
  }

  // ----------------------------
  // Copy With
  // ----------------------------

  StrategyConfig copyWith({
    StrategyType? type,
    List<DispatchMethod>? methods,
    Duration? delayBetween,
    bool? stopOnFirstSuccess,
    bool? stopOnFirstFailure,
    Map<String, dynamic>? metadata,
  }) {
    return StrategyConfig(
      type: type ?? this.type,
      methods: methods ?? this.methods,
      delayBetween: delayBetween ?? this.delayBetween,
      stopOnFirstSuccess: stopOnFirstSuccess ?? this.stopOnFirstSuccess,
      stopOnFirstFailure: stopOnFirstFailure ?? this.stopOnFirstFailure,
      metadata: metadata ?? this.metadata,
    );
  }

  // ----------------------------
  // Serialization
  // ----------------------------

  Map<String, dynamic> toMap() {
    return {
      'type': type.name,
      'methods': methods.map((m) => m.name).toList(),
      'delayBetweenMs': delayBetween.inMilliseconds,
      'stopOnFirstSuccess': stopOnFirstSuccess,
      'stopOnFirstFailure': stopOnFirstFailure,
      'metadata': metadata,
    };
  }

  @override
  String toString() {
    return 'StrategyConfig('
        'type: ${type.label}, '
        'methods: [${methods.map((m) => m.label).join(", ")}], '
        'delay: ${delayBetween.inMilliseconds}ms)';
  }
}