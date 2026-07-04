// ============================================
// Aarohan SOS Alert
// File        : controllers/sos_controller.dart
// Description : SOS Workflow Coordinator
// Sprint      : 2 - Emergency Dispatch Engine
// ============================================

import 'dart:developer' as developer;
import '../models/user_model.dart';
import '../models/dispatch/emergency_alert.dart';
import '../models/dispatch/dispatch_result.dart';
import '../services/storage_service.dart';
import '../services/location_service.dart';
import '../services/message_service.dart';
import '../services/dispatch/dispatch_engine.dart';

// ----------------------------
// SOS Workflow Result
// ----------------------------

class SosWorkflowResult {
  final bool success;
  final EmergencyAlert? alert;
  final DispatchResult? dispatchResult;
  final String? errorMessage;
  final SosWorkflowStage failedAtStage;

  SosWorkflowResult({
    required this.success,
    this.alert,
    this.dispatchResult,
    this.errorMessage,
    this.failedAtStage = SosWorkflowStage.none,
  });

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
/// - Delegate to DispatchEngine
/// - Return structured result to UI
///
/// The controller does NOT:
/// - Contain UI logic
/// - Contain communication logic
/// - Directly instantiate dispatchers
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
  // Main Workflow Entry Point
  // ----------------------------

  /// Executes the complete SOS emergency workflow.
  ///
  /// Optional [dispatchMethod] can override the default method.
  /// Optional [messageFormat] can customize the message style.
  Future<SosWorkflowResult> triggerSOS({
    DispatchMethod? dispatchMethod,
    MessageFormat messageFormat = MessageFormat.standard,
  }) async {
    _log('=== SOS Workflow Started ===');

    try {
      // ----------------------------
      // Stage 1 - Load User
      // ----------------------------

      _updateStage(SosWorkflowStage.loadingUser);
      final user = await _storageService.loadUserDetails();

      if (user == null) {
        return SosWorkflowResult.failure(
          errorMessage: 'User profile not found. Please complete registration.',
          failedAtStage: SosWorkflowStage.loadingUser,
        );
      }

      _log('User loaded: ${user.name}');

      // ----------------------------
      // Stage 2 - Load Contacts
      // ----------------------------

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

      // ----------------------------
      // Stage 3 - Fetch Location
      // ----------------------------

      _updateStage(SosWorkflowStage.fetchingLocation);
      final locationResult = await _locationService.getCurrentLocation();

      if (!locationResult.success) {
        return SosWorkflowResult.failure(
          errorMessage: locationResult.errorMessage ??
              'Failed to fetch current location',
          failedAtStage: SosWorkflowStage.fetchingLocation,
        );
      }

      _log('Location fetched: ${locationResult.latitude}, '
          '${locationResult.longitude}');

      // ----------------------------
      // Stage 4 - Build Message
      // ----------------------------

      _updateStage(SosWorkflowStage.buildingMessage);
      final message = _messageService.buildMessage(
        user: user,
        mapLink: locationResult.mapLink ?? '',
        format: messageFormat,
      );

      _log('Message prepared: ${message.length} chars');

      // ----------------------------
      // Stage 5 - Create Alert Object
      // ----------------------------

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

      // ----------------------------
      // Stage 6 - Dispatch
      // ----------------------------

      _updateStage(SosWorkflowStage.dispatching);
      final dispatchResult = await _dispatchEngine.dispatch(
        alert,
        method: dispatchMethod,
      );

      _log('Dispatch complete: ${dispatchResult.summary}');

      // ----------------------------
      // Stage 7 - Completed
      // ----------------------------

      _updateStage(SosWorkflowStage.completed);
      _log('=== SOS Workflow Completed ===');

      return SosWorkflowResult.success(
        alert: alert,
        dispatchResult: dispatchResult,
      );
    } catch (e, stackTrace) {
      _log('SOS Workflow error: $e');
      _log('Stack: $stackTrace');

      return SosWorkflowResult.failure(
        errorMessage: 'Unexpected error: ${e.toString()}',
        failedAtStage: SosWorkflowStage.none,
      );
    }
  }

  // ----------------------------
  // Alternative Dispatch Strategies
  // ----------------------------

  /// Triggers SOS with multiple dispatch methods in parallel.
  Future<Map<DispatchMethod, DispatchResult>> triggerSOSMultiple({
    required List<DispatchMethod> methods,
    MessageFormat messageFormat = MessageFormat.standard,
  }) async {
    final workflowResult = await _prepareAlert(messageFormat);
    if (workflowResult.alert == null) {
      return {};
    }

    return await _dispatchEngine.dispatchMultiple(
      workflowResult.alert!,
      methods: methods,
    );
  }

  /// Triggers SOS with priority-based fallback.
  Future<DispatchResult?> triggerSOSWithFallback({
    required List<DispatchMethod> priorityOrder,
    MessageFormat messageFormat = MessageFormat.standard,
  }) async {
    final workflowResult = await _prepareAlert(messageFormat);
    if (workflowResult.alert == null) {
      return DispatchResult.failure(
        method: DispatchMethod.none,
        errorMessage: workflowResult.errorMessage ?? 'Alert preparation failed',
      );
    }

    return await _dispatchEngine.dispatchWithFallback(
      workflowResult.alert!,
      priorityOrder: priorityOrder,
    );
  }

  // ----------------------------
  // Internal Alert Preparation
  // ----------------------------

  Future<SosWorkflowResult> _prepareAlert(
      MessageFormat messageFormat) async {
    _updateStage(SosWorkflowStage.loadingUser);
    final user = await _storageService.loadUserDetails();
    if (user == null) {
      return SosWorkflowResult.failure(
        errorMessage: 'User profile not found',
        failedAtStage: SosWorkflowStage.loadingUser,
      );
    }

    _updateStage(SosWorkflowStage.loadingContacts);
    final contacts = await _storageService.loadContacts();
    if (contacts.isEmpty) {
      return SosWorkflowResult.failure(
        errorMessage: 'No emergency contacts configured',
        failedAtStage: SosWorkflowStage.loadingContacts,
      );
    }

    _updateStage(SosWorkflowStage.fetchingLocation);
    final locationResult = await _locationService.getCurrentLocation();
    if (!locationResult.success) {
      return SosWorkflowResult.failure(
        errorMessage: locationResult.errorMessage ?? 'Location fetch failed',
        failedAtStage: SosWorkflowStage.fetchingLocation,
      );
    }

    _updateStage(SosWorkflowStage.buildingMessage);
    final message = _messageService.buildMessage(
      user: user,
      mapLink: locationResult.mapLink ?? '',
      format: messageFormat,
    );

    _updateStage(SosWorkflowStage.creatingAlert);
    final alert = EmergencyAlert(
      user: user,
      contacts: contacts,
      latitude: locationResult.latitude ?? 0.0,
      longitude: locationResult.longitude ?? 0.0,
      mapLink: locationResult.mapLink ?? '',
      message: message,
    );

    return SosWorkflowResult(
      success: true,
      alert: alert,
    );
  }

  // ----------------------------
  // Configuration
  // ----------------------------

  /// Sets the preferred dispatch method for future SOS triggers.
  void setPreferredDispatchMethod(DispatchMethod method) {
    _dispatchEngine.setPreferredMethod(method);
  }

  /// Returns available dispatchers.
  Future<List<String>> getAvailableDispatchers() async {
    final dispatchers = await _dispatchEngine.getAvailableDispatchers();
    return dispatchers.map((d) => d.name).toList();
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