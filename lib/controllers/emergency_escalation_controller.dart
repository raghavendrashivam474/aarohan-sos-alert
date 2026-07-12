// ============================================
// Aarohan SOS Alert
// File        : controllers/emergency_escalation_controller.dart
// Description : Emergency Escalation Workflow Coordinator
// Sprint      : 4 - Emergency Dispatch Reliability & Official Escalation
// ============================================

import 'dart:developer' as developer;
import '../models/emergency/emergency_type.dart';
import '../models/emergency/escalation_result.dart';
import '../services/emergency_agency/emergency_agency_gateway.dart';
import '../services/emergency_agency/erss_gateway.dart';

// ----------------------------
// Escalation Workflow Stages
// ----------------------------

enum EscalationStage {
  idle,
  validating,
  checkingCapability,
  preparingPreview,
  awaitingConfirmation,
  escalating,
  completed,
}

extension EscalationStageExt on EscalationStage {
  String get label {
    switch (this) {
      case EscalationStage.idle:
        return 'Idle';
      case EscalationStage.validating:
        return 'Validating request';
      case EscalationStage.checkingCapability:
        return 'Checking device capability';
      case EscalationStage.preparingPreview:
        return 'Preparing escalation preview';
      case EscalationStage.awaitingConfirmation:
        return 'Awaiting user confirmation';
      case EscalationStage.escalating:
        return 'Initiating emergency contact';
      case EscalationStage.completed:
        return 'Completed';
    }
  }
}

// ----------------------------
// Escalation Workflow Result
// ----------------------------

/// Structured result of the escalation workflow.
///
/// Wraps EscalationResult with additional workflow context.
class EscalationWorkflowResult {
  final bool success;
  final EscalationResult? escalationResult;
  final EscalationPreview? preview;
  final String? errorMessage;
  final EscalationStage failedAtStage;

  EscalationWorkflowResult({
    required this.success,
    this.escalationResult,
    this.preview,
    this.errorMessage,
    this.failedAtStage = EscalationStage.idle,
  });

  factory EscalationWorkflowResult.success({
    required EscalationResult escalationResult,
    EscalationPreview? preview,
  }) {
    return EscalationWorkflowResult(
      success: true,
      escalationResult: escalationResult,
      preview: preview,
    );
  }

  factory EscalationWorkflowResult.failure({
    required String errorMessage,
    required EscalationStage failedAtStage,
    EscalationPreview? preview,
  }) {
    return EscalationWorkflowResult(
      success: false,
      errorMessage: errorMessage,
      failedAtStage: failedAtStage,
      preview: preview,
    );
  }

  factory EscalationWorkflowResult.cancelled({
    EscalationPreview? preview,
  }) {
    return EscalationWorkflowResult(
      success: false,
      errorMessage: 'User cancelled escalation',
      failedAtStage: EscalationStage.awaitingConfirmation,
      preview: preview,
    );
  }
}

// ----------------------------
// Emergency Escalation Controller
// ----------------------------

/// Coordinates the emergency escalation workflow.
///
/// Responsibilities:
/// - Select appropriate agency gateway
/// - Prepare escalation preview for UI
/// - Validate escalation is possible
/// - Perform escalation after user confirmation
/// - Return structured result to UI
///
/// The controller does NOT:
/// - Show UI dialogs (that's the screen's job)
/// - Auto-confirm escalation
/// - Bypass agency gateway safety checks
/// - Perform contact dispatch (that's SosController's job)
///
/// This is architecturally separate from SosController because:
/// - Contact dispatch = user-configured, low institutional consequence
/// - Agency escalation = government pathway, high consequence, requires care
class EmergencyEscalationController {
  // ----------------------------
  // Singleton Setup
  // ----------------------------

  static final EmergencyEscalationController _instance =
      EmergencyEscalationController._internal();
  factory EmergencyEscalationController() => _instance;
  EmergencyEscalationController._internal() {
    _registerDefaultGateways();
  }

  // ----------------------------
  // Gateway Registry
  // ----------------------------

  final Map<EmergencyAgency, EmergencyAgencyGateway> _gateways = {};

  /// Default agency to use when none is specified.
  EmergencyAgency _defaultAgency = EmergencyAgency.erss112India;

  // ----------------------------
  // Default Registration
  // ----------------------------

  void _registerDefaultGateways() {
    registerGateway(ErssGateway());
    _log('Registered ${_gateways.length} agency gateways');
  }

  // ----------------------------
  // Gateway Registration
  // ----------------------------

  void registerGateway(EmergencyAgencyGateway gateway) {
    _gateways[gateway.agency] = gateway;
    _log('Registered gateway: ${gateway.name}');
  }

  void unregisterGateway(EmergencyAgency agency) {
    final removed = _gateways.remove(agency);
    if (removed != null) {
      _log('Unregistered gateway: ${removed.name}');
    }
  }

  EmergencyAgencyGateway? getGateway(EmergencyAgency agency) =>
      _gateways[agency];

  List<EmergencyAgencyGateway> get allGateways => _gateways.values.toList();

  // ----------------------------
  // Progress Callback
  // ----------------------------

  /// Optional callback for UI to observe workflow progress.
  void Function(EscalationStage stage)? onProgress;

  // ----------------------------
  // Preview Preparation
  // ----------------------------

  /// Prepares an escalation preview for the given emergency type.
  ///
  /// This is called BEFORE user confirmation to show what will happen.
  /// Does NOT perform actual escalation.
  Future<EscalationPreview?> preparePreview({
    required EmergencyType emergencyType,
    EmergencyAgency? agency,
  }) async {
    _updateStage(EscalationStage.preparingPreview);

    final selectedAgency = agency ?? _defaultAgency;
    final gateway = _gateways[selectedAgency];

    if (gateway == null) {
      _log('No gateway registered for ${selectedAgency.label}');
      return null;
    }

    // Check capability before showing preview
    final canGo = await gateway.canEscalate();
    if (!canGo) {
      _log('Gateway ${gateway.name} cannot escalate on this device');
      return null;
    }

    _log('Preview prepared for ${emergencyType.label} via ${gateway.name}');
    return gateway.prepareEscalation(emergencyType);
  }

  // ----------------------------
  // Main Escalation Workflow
  // ----------------------------

  /// Executes the escalation workflow.
  ///
  /// IMPORTANT: This should be called AFTER user confirms escalation.
  /// The controller assumes confirmation has occurred at UI level.
  ///
  /// Optional [agency] overrides the default agency.
  Future<EscalationWorkflowResult> escalate({
    required EmergencyType emergencyType,
    String? userDescription,
    double? latitude,
    double? longitude,
    String? userPhone,
    EmergencyAgency? agency,
  }) async {
    _log('=== Escalation Workflow Started ===');
    _log('Emergency Type: ${emergencyType.label}');

    try {
      // Stage 1 - Validate
      _updateStage(EscalationStage.validating);

      final selectedAgency = agency ?? _defaultAgency;
      final gateway = _gateways[selectedAgency];

      if (gateway == null) {
        _log('No gateway registered for ${selectedAgency.label}');
        return EscalationWorkflowResult.failure(
          errorMessage:
              'Emergency escalation gateway not available: ${selectedAgency.label}',
          failedAtStage: EscalationStage.validating,
        );
      }

      _log('Using gateway: ${gateway.name}');

      // Stage 2 - Check capability
      _updateStage(EscalationStage.checkingCapability);
      final canGo = await gateway.canEscalate();
      if (!canGo) {
        _log('Gateway cannot escalate on this device');
        return EscalationWorkflowResult.failure(
          errorMessage: 'Emergency escalation is not supported on this device. '
              'Please dial ${gateway.emergencyNumber} manually.',
          failedAtStage: EscalationStage.checkingCapability,
        );
      }

      // Stage 3 - Prepare preview (for logging)
      _updateStage(EscalationStage.preparingPreview);
      final preview = gateway.prepareEscalation(emergencyType);
      _log('Preview: ${preview.pathwayDescription}');

      // Stage 4 - Build escalation request
      final request = EscalationRequest(
        emergencyType: emergencyType,
        userDescription: userDescription,
        latitude: latitude,
        longitude: longitude,
        userPhone: userPhone,
        metadata: {
          'controllerVersion': '1.0',
          'triggeredAt': DateTime.now().toIso8601String(),
        },
      );

      // Stage 5 - Perform escalation
      _updateStage(EscalationStage.escalating);
      _log('Performing escalation via ${gateway.name}');
      final result = await gateway.escalate(request);
      _log('Escalation result: ${result.truthfulSummary}');

      // Stage 6 - Complete
      _updateStage(EscalationStage.completed);
      _log('=== Escalation Workflow Completed ===');

      return EscalationWorkflowResult.success(
        escalationResult: result,
        preview: preview,
      );
    } catch (e, stackTrace) {
      _log('Escalation workflow error: $e');
      _log('Stack: $stackTrace');

      return EscalationWorkflowResult.failure(
        errorMessage: 'Unexpected error during escalation: ${e.toString()}',
        failedAtStage: EscalationStage.escalating,
      );
    }
  }

  // ----------------------------
  // Configuration
  // ----------------------------

  /// Sets the default agency to use when none is specified.
  void setDefaultAgency(EmergencyAgency agency) {
    if (!_gateways.containsKey(agency)) {
      _log('Warning: ${agency.label} not registered');
      return;
    }
    _defaultAgency = agency;
    _log('Default agency set to: ${agency.label}');
  }

  EmergencyAgency get defaultAgency => _defaultAgency;

  // ----------------------------
  // Availability Checks
  // ----------------------------

  /// Returns availability map for all registered gateways.
  Future<Map<EmergencyAgency, bool>> getAvailabilityMap() async {
    final map = <EmergencyAgency, bool>{};
    for (final entry in _gateways.entries) {
      map[entry.key] = await entry.value.canEscalate();
    }
    return map;
  }

  /// Returns true if at least one gateway can escalate.
  Future<bool> hasAnyAvailableGateway() async {
    for (final gateway in _gateways.values) {
      if (await gateway.canEscalate()) return true;
    }
    return false;
  }

  // ----------------------------
  // Progress Update Helper
  // ----------------------------

  void _updateStage(EscalationStage stage) {
    _log('Stage: ${stage.label}');
    onProgress?.call(stage);
  }

  // ----------------------------
  // Internal Logging
  // ----------------------------

  void _log(String message) {
    developer.log(message, name: 'EscalationController');
  }
}