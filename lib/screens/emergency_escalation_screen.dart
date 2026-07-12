// ============================================
// Aarohan SOS Alert
// File        : screens/emergency_escalation_screen.dart
// Description : Emergency Type Selection & Escalation UI
// Sprint      : 4 - Emergency Dispatch Reliability & Official Escalation
// ============================================

import 'package:flutter/material.dart';
import '../utils/constants.dart';
import '../models/emergency/emergency_type.dart';
import '../models/emergency/escalation_result.dart';
import '../models/dispatch/emergency_alert.dart';
import '../controllers/emergency_escalation_controller.dart';
import '../services/emergency_agency/emergency_agency_gateway.dart';

class EmergencyEscalationScreen extends StatefulWidget {
  /// Optional context from a completed SOS workflow.
  /// Used to pre-fill location and user info.
  final EmergencyAlert? alertContext;

  const EmergencyEscalationScreen({
    super.key,
    this.alertContext,
  });

  @override
  State<EmergencyEscalationScreen> createState() =>
      _EmergencyEscalationScreenState();
}

class _EmergencyEscalationScreenState extends State<EmergencyEscalationScreen> {
  // ----------------------------
  // State
  // ----------------------------

  EmergencyType _selectedType = EmergencyType.threatToLife;
  bool _isLoading = false;
  String _currentStage = '';
  EscalationPreview? _preview;

  final EmergencyEscalationController _controller =
      EmergencyEscalationController();

  // ----------------------------
  // Init
  // ----------------------------

  @override
  void initState() {
    super.initState();
    _setupController();
    _loadPreview();
  }

  void _setupController() {
    _controller.onProgress = (stage) {
      if (!mounted) return;
      setState(() {
        _currentStage = stage.label;
      });
    };
  }

  Future<void> _loadPreview() async {
    final preview = await _controller.preparePreview(
      emergencyType: _selectedType,
    );
    if (!mounted) return;
    setState(() => _preview = preview);
  }

  // ----------------------------
  // Type Selection
  // ----------------------------

  void _onTypeSelected(EmergencyType type) {
    setState(() {
      _selectedType = type;
    });
    _loadPreview();
  }

  // ----------------------------
  // Escalation Trigger
  // ----------------------------

  Future<void> _onEscalatePressed() async {
    // Show confirmation dialog first
    final confirmed = await _showConfirmationDialog();
    if (!confirmed) return;

    setState(() {
      _isLoading = true;
      _currentStage = 'Initiating...';
    });

    final result = await _controller.escalate(
      emergencyType: _selectedType,
      latitude: widget.alertContext?.latitude,
      longitude: widget.alertContext?.longitude,
      userPhone: widget.alertContext?.userPhone,
    );

    setState(() {
      _isLoading = false;
      _currentStage = '';
    });

    if (!mounted) return;

    // Show result dialog
    await _showResultDialog(result.escalationResult);

    // Return to previous screen with result
    if (mounted) {
      Navigator.pop(context, result);
    }
  }

  // ----------------------------
  // Confirmation Dialog
  // ----------------------------

  Future<bool> _showConfirmationDialog() async {
    if (_preview == null) return false;

    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: lightNavy,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Row(
          children: [
            Icon(
              Icons.warning_amber_rounded,
              color: primaryRed,
              size: 28,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                EscalationWording.confirmationTitle(_selectedType),
                style: const TextStyle(
                  color: whiteColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Agency Info Box
              Container(
                padding: const EdgeInsets.all(paddingMedium),
                decoration: BoxDecoration(
                  color: primaryRed.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: primaryRed.withOpacity(0.4)),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: primaryRed,
                      ),
                      child: const Text(
                        '112',
                        style: TextStyle(
                          color: whiteColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    const SizedBox(width: paddingMedium),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _preview!.agencyName,
                            style: const TextStyle(
                              color: whiteColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                          Text(
                            _preview!.pathwayDescription,
                            style: const TextStyle(
                              color: mediumGrey,
                              fontSize: 11,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: paddingMedium),

              // What You Need To Do
              const Text(
                'WHAT YOU NEED TO DO',
                style: TextStyle(
                  color: primaryRed,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                _preview!.userAction,
                style: const TextStyle(
                  color: whiteColor,
                  fontSize: 13,
                  height: 1.5,
                ),
              ),

              const SizedBox(height: paddingMedium),

              // Warnings
              if (_preview!.warnings.isNotEmpty) ...[
                const Text(
                  'IMPORTANT',
                  style: TextStyle(
                    color: primaryRed,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 6),
                ..._preview!.warnings.map((warning) => Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            '• ',
                            style: TextStyle(
                              color: primaryRed,
                              fontSize: 12,
                            ),
                          ),
                          Expanded(
                            child: Text(
                              warning,
                              style: const TextStyle(
                                color: mediumGrey,
                                fontSize: 11,
                                height: 1.4,
                              ),
                            ),
                          ),
                        ],
                      ),
                    )),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text(
              'CANCEL',
              style: TextStyle(color: mediumGrey),
            ),
          ),
          ElevatedButton.icon(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryRed,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            icon: const Icon(Icons.call, color: whiteColor, size: 18),
            label: const Text(
              'CONTACT 112',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: whiteColor,
              ),
            ),
          ),
        ],
      ),
    );

    return result ?? false;
  }

  // ----------------------------
  // Result Dialog
  // ----------------------------

  Future<void> _showResultDialog(EscalationResult? result) async {
    if (result == null) return;

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: lightNavy,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Row(
          children: [
            Icon(
              result.success
                  ? Icons.check_circle
                  : Icons.error_outline,
              color: result.success ? Colors.green : primaryRed,
              size: 28,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                EscalationWording.launchStatus(result.success),
                style: const TextStyle(
                  color: whiteColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              result.truthfulSummary,
              style: const TextStyle(
                color: mediumGrey,
                height: 1.5,
              ),
            ),

            if (!result.success && result.fallbackNumber.isNotEmpty) ...[
              const SizedBox(height: paddingMedium),
              Container(
                padding: const EdgeInsets.all(paddingMedium),
                decoration: BoxDecoration(
                  color: primaryRed.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: primaryRed.withOpacity(0.4)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'DIAL MANUALLY',
                      style: TextStyle(
                        color: primaryRed,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      result.fallbackNumber,
                      style: const TextStyle(
                        color: whiteColor,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryRed,
            ),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  // ----------------------------
  // Build
  // ----------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryNavy,
      appBar: AppBar(
        backgroundColor: darkNavy,
        title: const Text(
          'Emergency Escalation',
          style: TextStyle(
            color: whiteColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(color: whiteColor),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(paddingLarge),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Warning Banner
              _buildWarningBanner(),

              const SizedBox(height: paddingLarge),

              // Section Label
              const Text(
                'SELECT EMERGENCY TYPE',
                style: TextStyle(
                  color: primaryRed,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: paddingSmall),
              Text(
                'Choose the category that best describes your situation',
                style: TextStyle(
                  fontSize: 12,
                  color: mediumGrey.withOpacity(0.8),
                ),
              ),

              const SizedBox(height: paddingMedium),

              // Type Selection Grid
              ...EmergencyTypeExt.allByPriority.map(
                (type) => _buildTypeTile(type),
              ),

              const SizedBox(height: paddingLarge),

              // Agency Info Card
              if (_preview != null) _buildAgencyInfoCard(),

              const SizedBox(height: paddingLarge),

              // Progress Indicator
              if (_isLoading) _buildProgressIndicator(),

              const SizedBox(height: paddingLarge),

              // Escalate Button
              _buildEscalateButton(),

              const SizedBox(height: paddingMedium),

              // Truthfulness Note
              _buildTruthfulnessNote(),

              const SizedBox(height: paddingLarge),
            ],
          ),
        ),
      ),
    );
  }

  // ----------------------------
  // Warning Banner
  // ----------------------------

  Widget _buildWarningBanner() {
    return Container(
      padding: const EdgeInsets.all(paddingMedium),
      decoration: BoxDecoration(
        color: primaryRed.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: primaryRed.withOpacity(0.5)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: primaryRed,
            ),
            child: const Icon(
              Icons.priority_high,
              color: whiteColor,
              size: 20,
            ),
          ),
          const SizedBox(width: paddingMedium),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Official Emergency Services',
                  style: TextStyle(
                    color: whiteColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'This contacts India\'s ERSS 112 emergency response system.',
                  style: TextStyle(
                    color: mediumGrey,
                    fontSize: 11,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ----------------------------
  // Type Tile
  // ----------------------------

  Widget _buildTypeTile(EmergencyType type) {
    final isSelected = _selectedType == type;

    return Padding(
      padding: const EdgeInsets.only(bottom: paddingSmall),
      child: GestureDetector(
        onTap: _isLoading ? null : () => _onTypeSelected(type),
        child: Container(
          padding: const EdgeInsets.all(paddingMedium),
          decoration: BoxDecoration(
            color: isSelected ? primaryRed.withOpacity(0.2) : lightNavy,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? primaryRed : mediumGrey.withOpacity(0.2),
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: primaryRed.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Text(
                    type.emoji,
                    style: const TextStyle(fontSize: 22),
                  ),
                ),
              ),
              const SizedBox(width: paddingMedium),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      type.label,
                      style: const TextStyle(
                        color: whiteColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      type.description,
                      style: TextStyle(
                        color: mediumGrey.withOpacity(0.9),
                        fontSize: 11,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
              if (isSelected)
                const Icon(Icons.check_circle, color: primaryRed, size: 24),
            ],
          ),
        ),
      ),
    );
  }

  // ----------------------------
  // Agency Info Card
  // ----------------------------

  Widget _buildAgencyInfoCard() {
    return Container(
      padding: const EdgeInsets.all(paddingMedium),
      decoration: BoxDecoration(
        color: lightNavy,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: primaryRed.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.info_outline, color: primaryRed, size: 18),
              const SizedBox(width: 8),
              const Text(
                'What Will Happen',
                style: TextStyle(
                  color: whiteColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ],
          ),
          const SizedBox(height: paddingSmall),
          Text(
            _preview!.pathwayDescription,
            style: TextStyle(
              color: mediumGrey.withOpacity(0.9),
              fontSize: 12,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            _preview!.userAction,
            style: const TextStyle(
              color: whiteColor,
              fontSize: 12,
              height: 1.5,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // ----------------------------
  // Progress Indicator
  // ----------------------------

  Widget _buildProgressIndicator() {
    return Container(
      padding: const EdgeInsets.all(paddingMedium),
      decoration: BoxDecoration(
        color: primaryRed.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: primaryRed.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
              color: primaryRed,
              strokeWidth: 2,
            ),
          ),
          const SizedBox(width: paddingMedium),
          Expanded(
            child: Text(
              _currentStage,
              style: const TextStyle(
                color: primaryRed,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ----------------------------
  // Escalate Button
  // ----------------------------

  Widget _buildEscalateButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton.icon(
        onPressed: _isLoading || _preview == null ? null : _onEscalatePressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryRed,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        icon: const Icon(Icons.call, color: whiteColor),
        label: const Text(
          'ESCALATE TO 112',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: whiteColor,
            letterSpacing: 1.5,
          ),
        ),
      ),
    );
  }

  // ----------------------------
  // Truthfulness Note
  // ----------------------------

  Widget _buildTruthfulnessNote() {
    return Container(
      padding: const EdgeInsets.all(paddingMedium),
      decoration: BoxDecoration(
        color: darkNavy,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: mediumGrey.withOpacity(0.2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.info_outline,
            color: mediumGrey.withOpacity(0.6),
            size: 16,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Aarohan does not automatically notify emergency services. '
              'You must complete the call for authorities to be contacted. '
              'This app helps you initiate the call quickly.',
              style: TextStyle(
                color: mediumGrey.withOpacity(0.8),
                fontSize: 11,
                height: 1.5,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ],
      ),
    );
  }
}