// ============================================
// Aarohan SOS Alert
// File        : controllers/sos_controller.dart
// Description : SOS Workflow Coordinator (Sprint 3 - Strategy Aware)
// ============================================

import 'dart:developer' as developer;
import '../models/user_model.dart';
import '../models/dispatch/emergency_alert.dart';
import '../models/dispatch/dispatch_result.dart';
import '../models/dispatch/strategy/strategy_config.dart';
import '../models/dispatch/strategy/strategy_result.dart';
import '../services/storage_service.dart';
import '../services/location_service.dart';
import '../services/message_service.dart';
import '../services/dispatch/dispatch_engine.dart';

// ----------------------------
// SOS Workflow Result
// ----------------------------

/// Structured result returned by the SOS Controller.
class SosWorkflowResult {
  final bool success;
  final EmergencyAlert? alert;
  final DispatchResult? dispatchResult;
  final StrategyResult? strategyResult;
  final String? errorMessage;
  final SosWorkflowStage failedAtStage;

  SosWorkflowResult({
    required this.success,
    this.alert,
    this.dispatchResult,
    this.strategyResult,
    this.errorMessage,
    this.failedAtStage = SosWorkflowStage.none,
  });

  // ----------------------------
  // Factory Constructors
  // ----------------------------

  factory SosWorkflowResult.success({
    required EmergencyAlert alert,
    required DispatchResult dispatchResult,
  }) {
    return SosWorkflowResult(
      success: true,
      alert: alert,
      dispatchResult: dispatchResult,
    );
  }

  factory SosWorkflowResult.strategySuccess({
    required EmergencyAlert alert,
    required StrategyResult strategyResult,
  }) {
    return SosWorkflowResult(
      success: strategyResult.success,
      alert: alert,
      strategyResult: strategyResult,
      dispatchResult: strategyResult.results.isNotEmpty
          ? strategyResult.results.first
          : null,
    );
  }

  factory SosWorkflowResult.failure({
    required String errorMessage,
    required SosWorkflowStage failedAtStage,
    EmergencyAlert? alert,
  }) {
    return SosWorkflowResult(
      success: false,
      errorMessage: errorMessage,
      failedAtStage: failedAtStage,
      alert: alert,
    );
  }

  // ----------------------------
  // Helpers
  // ----------------------------

  bool get isMultiChannel => strategyResult != null &&
      strategyResult!.totalAttempts > 1;

  int get totalAttempts => strategyResult?.totalAttempts ?? 1;

  int get totalSuccessful => strategyResult?.successfulDispatchers ??
      (dispatchResult?.success == true ? 1 : 0);
}

// ----------------------------
// Workflow Stages
// ----------------------------

enum SosWorkflowStage {
  none,
  loadingUser,
  loadingContacts,
  fetchingLocation,
  buildingMessage,
  creatingAlert,
  dispatching,
  completed,
}

extension SosWorkflowStageExt on SosWorkflowStage {
  String get label {
    switch (this) {
      case SosWorkflowStage.none:
        return 'Idle';
      case SosWorkflowStage.loadingUser:
        return 'Loading user information';
      case SosWorkflowStage.loadingContacts:
        return 'Loading emergency contacts';
      case SosWorkflowStage.fetchingLocation:
        return 'Fetching current location';
      case SosWorkflowStage.buildingMessage:
        return 'Preparing emergency message';
      case SosWorkflowStage.creatingAlert:
        return 'Creating emergency alert';
      case SosWorkflowStage.dispatching:
        return 'Dispatching alert';
      case SosWorkflowStage.completed:
        return 'Completed';
    }
  }
}

// ----------------------------
// SOS Controller
// ----------------------------

/// Coordinates the complete SOS emergency workflow.
///
/// Responsibilities:
/// - Load required data (user, contacts)
/// - Fetch GPS location
/// - Generate emergency message
/// - Build EmergencyAlert object
/// - Delegate to DispatchEngine (single method OR strategy)
/// - Return structured result to UI
///
/// The controller does NOT:
/// - Contain UI logic
/// - Contain communication logic
/// - Directly instantiate dispatchers or strategies
class SosController {
  // ----------------------------
  // Singleton Setup
  // ----------------------------

  static final SosController _instance = SosController._internal();
  factory SosController() => _instance;
  SosController._internal();

  // ----------------------------
  // Service Dependencies
  // ----------------------------

  final StorageService _storageService = StorageService();
  final LocationService _locationService = LocationService();
  final MessageService _messageService = MessageService();
  final DispatchEngine _dispatchEngine = DispatchEngine();

  // ----------------------------
  // Progress Callback
  // ----------------------------

  /// Optional callback for UI to observe workflow progress.
  void Function(SosWorkflowStage stage)? onProgress;

  // ----------------------------
  // Main Workflow (Single Method) - Backward Compatible
  // ----------------------------

  /// Executes SOS workflow using a single dispatch method.
  /// Backward compatible with Sprint 2 API.
  Future<SosWorkflowResult> triggerSOS({
    DispatchMethod? dispatchMethod,
    MessageFormat messageFormat = MessageFormat.standard,
  }) async {
    _log('=== SOS Workflow Started (Single Method) ===');

    final preparationResult = await _prepareAlert(messageFormat);
    if (!preparationResult.success) {
      return preparationResult;
    }

    _updateStage(SosWorkflowStage.dispatching);

    final dispatchResult = await _dispatchEngine.dispatch(
      preparationResult.alert!,
      method: dispatchMethod,
    );

    _log('Dispatch complete: ${dispatchResult.summary}');

    _updateStage(SosWorkflowStage.completed);
    _log('=== SOS Workflow Completed ===');

    return SosWorkflowResult.success(
      alert: preparationResult.alert!,
      dispatchResult: dispatchResult,
    );
  }

  // ----------------------------
  // Strategy Workflow (New in Sprint 3)
  // ----------------------------

  /// Executes SOS workflow using a full strategy configuration.
  /// This is the recommended way for multi-channel dispatch.
  Future<SosWorkflowResult> triggerSOSWithStrategy(
    StrategyConfig strategyConfig, {
    MessageFormat messageFormat = MessageFormat.standard,
  }) async {
    _log('=== SOS Workflow Started (Strategy) ===');
    _log('Strategy: ${strategyConfig.displayName}');

    // Validate strategy
    if (!strategyConfig.isValid) {
      return SosWorkflowResult.failure(
        errorMessage: strategyConfig.validationError ??
            'Invalid strategy configuration',
        failedAtStage: SosWorkflowStage.none,
      );
    }

    // Prepare alert
    final preparationResult = await _prepareAlert(messageFormat);
    if (!preparationResult.success) {
      return preparationResult;
    }

    // Execute strategy
    _updateStage(SosWorkflowStage.dispatching);

    final strategyResult = await _dispatchEngine.executeStrategy(
      preparationResult.alert!,
      strategyConfig,
    );

    _log('Strategy complete: ${strategyResult.summary}');

    _updateStage(SosWorkflowStage.completed);
    _log('=== SOS Workflow Completed ===');

    return SosWorkflowResult.strategySuccess(
      alert: preparationResult.alert!,
      strategyResult: strategyResult,
    );
  }

  // ----------------------------
  // Legacy Multi-Method (Sprint 2 API)
  // ----------------------------

  /// Triggers SOS with multiple dispatch methods in parallel.
  /// @deprecated Use triggerSOSWithStrategy() with ParallelStrategy.
  @Deprecated('Use triggerSOSWithStrategy() with StrategyConfig instead')
  Future<Map<DispatchMethod, DispatchResult>> triggerSOSMultiple({
    required List<DispatchMethod> methods,
    MessageFormat messageFormat = MessageFormat.standard,
  }) async {
    final config = StrategyConfig(
      type: StrategyType.parallel,
      methods: methods,
    );

    final workflowResult = await triggerSOSWithStrategy(
      config,
      messageFormat: messageFormat,
    );

    final map = <DispatchMethod, DispatchResult>{};
    if (workflowResult.strategyResult != null) {
      for (final result in workflowResult.strategyResult!.results) {
        map[result.method] = result;
      }
    }
    return map;
  }

  /// Triggers SOS with priority-based fallback.
  /// @deprecated Use triggerSOSWithStrategy() with FallbackStrategy.
  @Deprecated('Use triggerSOSWithStrategy() with StrategyConfig instead')
  Future<DispatchResult?> triggerSOSWithFallback({
    required List<DispatchMethod> priorityOrder,
    MessageFormat messageFormat = MessageFormat.standard,
  }) async {
    final config = StrategyConfig(
      type: StrategyType.fallback,
      methods: priorityOrder,
      stopOnFirstSuccess: true,
    );

    final workflowResult = await triggerSOSWithStrategy(
      config,
      messageFormat: messageFormat,
    );

    if (workflowResult.strategyResult == null) return null;

    // Return the first successful result
    for (final result in workflowResult.strategyResult!.results) {
      if (result.success) return result;
    }

    if (workflowResult.strategyResult!.results.isNotEmpty) {
      return workflowResult.strategyResult!.results.last;
    }

    return null;
  }

  // ----------------------------
  // Internal Alert Preparation
  // ----------------------------

  Future<SosWorkflowResult> _prepareAlert(
    MessageFormat messageFormat,
  ) async {
    try {
      // Stage 1 - Load User
      _updateStage(SosWorkflowStage.loadingUser);
      final user = await _storageService.loadUserDetails();
      if (user == null) {
        return SosWorkflowResult.failure(
          errorMessage:
              'User profile not found. Please complete registration.',
          failedAtStage: SosWorkflowStage.loadingUser,
        );
      }
      _log('User loaded: ${user.name}');

      // Stage 2 - Load Contacts
      _updateStage(SosWorkflowStage.loadingContacts);
      final contacts = await _storageService.loadContacts();
      if (contacts.isEmpty) {
        return SosWorkflowResult.failure(
          errorMessage: 'No emergency contacts configured. '
              'Please add at least one contact.',
          failedAtStage: SosWorkflowStage.loadingContacts,
        );
      }
      _log('Contacts loaded: ${contacts.length}');

      // Stage 3 - Fetch Location
      _updateStage(SosWorkflowStage.fetchingLocation);
      final locationResult = await _locationService.getCurrentLocation();
      if (!locationResult.success) {
        return SosWorkflowResult.failure(
          errorMessage: locationResult.errorMessage ??
              'Failed to fetch current location',
          failedAtStage: SosWorkflowStage.fetchingLocation,
        );
      }
      _log('Location fetched: '
          '${locationResult.latitude}, ${locationResult.longitude}');

      // Stage 4 - Build Message
      _updateStage(SosWorkflowStage.buildingMessage);
      final message = _messageService.buildMessage(
        user: user,
        mapLink: locationResult.mapLink ?? '',
        format: messageFormat,
      );
      _log('Message prepared: ${message.length} chars');

      // Stage 5 - Create Alert
      _updateStage(SosWorkflowStage.creatingAlert);
      final alert = EmergencyAlert(
        user: user,
        contacts: contacts,
        latitude: locationResult.latitude ?? 0.0,
        longitude: locationResult.longitude ?? 0.0,
        mapLink: locationResult.mapLink ?? '',
        message: message,
        metadata: {
          'messageFormat': messageFormat.name,
          'triggeredAt': DateTime.now().toIso8601String(),
        },
      );
      _log('Alert created: ${alert.alertId}');

      return SosWorkflowResult(
        success: true,
        alert: alert,
      );
    } catch (e, stackTrace) {
      _log('Preparation error: $e');
      _log('Stack: $stackTrace');
      return SosWorkflowResult.failure(
        errorMessage: 'Unexpected error: ${e.toString()}',
        failedAtStage: SosWorkflowStage.none,
      );
    }
  }

  // ----------------------------
  // Configuration
  // ----------------------------

  /// Sets the preferred single dispatch method.
  void setPreferredDispatchMethod(DispatchMethod method) {
    _dispatchEngine.setPreferredMethod(method);
  }

  /// Sets the default strategy to use when no config is provided.
  void setDefaultStrategy(StrategyConfig config) {
    _dispatchEngine.setDefaultStrategy(config);
  }

  /// Returns available dispatchers.
  Future<List<String>> getAvailableDispatchers() async {
    final dispatchers = await _dispatchEngine.getAvailableDispatchers();
    return dispatchers.map((d) => d.name).toList();
  }

  /// Returns availability map for all dispatchers.
  Future<Map<DispatchMethod, bool>> getAvailabilityMap() async {
    return await _dispatchEngine.getAvailabilityMap();
  }

  // ----------------------------
  // Progress Update Helper
  // ----------------------------

  void _updateStage(SosWorkflowStage stage) {
    _log('Stage: ${stage.label}');
    onProgress?.call(stage);
  }

  // ----------------------------
  // Internal Logging
  // ----------------------------

  void _log(String message) {
    developer.log(message, name: 'SosController');
  }
}