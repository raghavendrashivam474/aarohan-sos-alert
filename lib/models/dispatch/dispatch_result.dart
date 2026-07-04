// ============================================
// Aarohan SOS Alert
// File        : models/dispatch/dispatch_result.dart
// Description : Dispatch Result Data Model
// Sprint      : 2 - Emergency Dispatch Engine
// ============================================

// ----------------------------
// Dispatch Method Enum
// ----------------------------

enum DispatchMethod {
  simulation,
  sms,
  call,
  share,
  none,
}

extension DispatchMethodExt on DispatchMethod {
  String get label {
    switch (this) {
      case DispatchMethod.simulation:
        return 'Simulation';
      case DispatchMethod.sms:
        return 'SMS';
      case DispatchMethod.call:
        return 'Call';
      case DispatchMethod.share:
        return 'Share';
      case DispatchMethod.none:
        return 'None';
    }
  }
}

// ----------------------------
// Dispatch Status Enum
// ----------------------------

enum DispatchStatus {
  success,
  partialSuccess,
  failed,
  skipped,
}

extension DispatchStatusExt on DispatchStatus {
  String get label {
    switch (this) {
      case DispatchStatus.success:
        return 'Success';
      case DispatchStatus.partialSuccess:
        return 'Partial Success';
      case DispatchStatus.failed:
        return 'Failed';
      case DispatchStatus.skipped:
        return 'Skipped';
    }
  }

  bool get isPositive =>
      this == DispatchStatus.success ||
      this == DispatchStatus.partialSuccess;
}

// ----------------------------
// Dispatch Result Model
// ----------------------------

class DispatchResult {
  final bool success;
  final DispatchMethod method;
  final DispatchStatus status;
  final int recipientCount;
  final int successCount;
  final int failureCount;
  final String? errorMessage;
  final DateTime timestamp;
  final Map<String, dynamic> metadata;

  DispatchResult({
    required this.success,
    required this.method,
    required this.status,
    this.recipientCount = 0,
    this.successCount = 0,
    this.failureCount = 0,
    this.errorMessage,
    DateTime? timestamp,
    this.metadata = const {},
  }) : timestamp = timestamp ?? DateTime.now();

  // ----------------------------
  // Factory Constructors
  // ----------------------------

  factory DispatchResult.success({
    required DispatchMethod method,
    required int recipientCount,
    Map<String, dynamic> metadata = const {},
  }) {
    return DispatchResult(
      success: true,
      method: method,
      status: DispatchStatus.success,
      recipientCount: recipientCount,
      successCount: recipientCount,
      failureCount: 0,
      metadata: metadata,
    );
  }

  factory DispatchResult.failure({
    required DispatchMethod method,
    required String errorMessage,
    int recipientCount = 0,
  }) {
    return DispatchResult(
      success: false,
      method: method,
      status: DispatchStatus.failed,
      recipientCount: recipientCount,
      successCount: 0,
      failureCount: recipientCount,
      errorMessage: errorMessage,
    );
  }

  factory DispatchResult.partial({
    required DispatchMethod method,
    required int recipientCount,
    required int successCount,
    required int failureCount,
    String? errorMessage,
  }) {
    return DispatchResult(
      success: successCount > 0,
      method: method,
      status: DispatchStatus.partialSuccess,
      recipientCount: recipientCount,
      successCount: successCount,
      failureCount: failureCount,
      errorMessage: errorMessage,
    );
  }

  factory DispatchResult.skipped({
    required DispatchMethod method,
    required String reason,
  }) {
    return DispatchResult(
      success: false,
      method: method,
      status: DispatchStatus.skipped,
      errorMessage: reason,
    );
  }

  // ----------------------------
  // Helpers
  // ----------------------------

  double get successRate {
    if (recipientCount == 0) return 0.0;
    return successCount / recipientCount;
  }

  String get summary {
    if (status == DispatchStatus.skipped) {
      return 'Dispatch skipped: ${errorMessage ?? 'Unknown reason'}';
    }
    if (status == DispatchStatus.failed) {
      return 'Dispatch failed: ${errorMessage ?? 'Unknown error'}';
    }
    return '${method.label} sent to $successCount of $recipientCount contact${recipientCount != 1 ? 's' : ''}';
  }

  Map<String, dynamic> toMap() {
    return {
      'success': success,
      'method': method.name,
      'status': status.name,
      'recipientCount': recipientCount,
      'successCount': successCount,
      'failureCount': failureCount,
      'errorMessage': errorMessage,
      'timestamp': timestamp.toIso8601String(),
      'metadata': metadata,
    };
  }

  @override
  String toString() {
    return 'DispatchResult(method: ${method.label}, '
        'status: ${status.label}, '
        'success: $successCount/$recipientCount)';
  }
}