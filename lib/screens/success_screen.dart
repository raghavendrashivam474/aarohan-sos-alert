// ============================================
// Aarohan SOS Alert
// File        : screens/success_screen.dart
// Description : SOS Success Confirmation Screen (Sprint 4 - With Escalation)
// ============================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import '../utils/constants.dart';
import '../models/dispatch/emergency_alert.dart';
import '../models/dispatch/dispatch_result.dart';
import '../models/dispatch/strategy/strategy_result.dart';
import 'dashboard_screen.dart';
import 'emergency_escalation_screen.dart';

class SuccessScreen extends StatefulWidget {
  final EmergencyAlert alert;
  final DispatchResult? dispatchResult;
  final StrategyResult? strategyResult;

  const SuccessScreen({
    super.key,
    required this.alert,
    this.dispatchResult,
    this.strategyResult,
  });

  @override
  State<SuccessScreen> createState() => _SuccessScreenState();
}

class _SuccessScreenState extends State<SuccessScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.elasticOut,
      ),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeIn,
      ),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  // ----------------------------
  // Actions
  // ----------------------------

  Future<void> _openMap() async {
    final uri = Uri.parse(widget.alert.mapLink);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not open maps'),
          backgroundColor: primaryRed,
        ),
      );
    }
  }

  void _copyMessage() {
    Clipboard.setData(ClipboardData(text: widget.alert.message));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle, color: whiteColor),
            SizedBox(width: 8),
            Expanded(
              child: Text('Emergency message copied to clipboard'),
            ),
          ],
        ),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _returnToDashboard() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const DashboardScreen()),
      (route) => false,
    );
  }

  // ----------------------------
  // Escalation Trigger
  // ----------------------------

  Future<void> _onEscalatePressed() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EmergencyEscalationScreen(
          alertContext: widget.alert,
        ),
      ),
    );
    // No action needed on return - escalation is separate workflow
  }

  // ----------------------------
  // Status Helpers
  // ----------------------------

  bool get _isMultiChannel => widget.strategyResult != null &&
      widget.strategyResult!.totalAttempts > 1;

  bool get _isOverallSuccess {
    if (widget.strategyResult != null) {
      return widget.strategyResult!.success;
    }
    return widget.dispatchResult?.success ?? false;
  }

  Color get _statusColor {
    if (widget.strategyResult != null) {
      if (widget.strategyResult!.success) {
        if (widget.strategyResult!.status.label.contains('Partial')) {
          return Colors.orange;
        }
        return Colors.green;
      }
      return primaryRed;
    }

    final result = widget.dispatchResult;
    if (result == null) return primaryRed;

    switch (result.status) {
      case DispatchStatus.success:
        return Colors.green;
      case DispatchStatus.partialSuccess:
        return Colors.orange;
      case DispatchStatus.failed:
        return primaryRed;
      case DispatchStatus.skipped:
        return mediumGrey;
    }
  }

  IconData get _statusIcon {
    if (_isOverallSuccess) return Icons.check_circle;
    if (widget.strategyResult != null &&
        widget.strategyResult!.status.label.contains('Partial')) {
      return Icons.warning_amber_rounded;
    }
    return Icons.error_outline;
  }

  String get _statusTitle {
    if (_isMultiChannel) {
      if (_isOverallSuccess) return 'Multi-Channel Alert Sent';
      return 'Alert Dispatch Completed';
    }

    final result = widget.dispatchResult;
    if (result == null) return 'SOS Completed';

    switch (result.status) {
      case DispatchStatus.success:
        return 'SOS Alert Dispatched';
      case DispatchStatus.partialSuccess:
        return 'SOS Partially Dispatched';
      case DispatchStatus.failed:
        return 'SOS Dispatch Failed';
      case DispatchStatus.skipped:
        return 'SOS Dispatch Skipped';
    }
  }

  String get _statusSubtitle {
    if (widget.strategyResult != null) {
      return widget.strategyResult!.summary;
    }
    return widget.dispatchResult?.summary ?? 'Emergency workflow completed';
  }

  // ----------------------------
  // Build
  // ----------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryNavy,
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(
          paddingLarge,
          paddingSmall,
          paddingLarge,
          paddingLarge,
        ),
        child: SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: _returnToDashboard,
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryRed,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.home, color: whiteColor),
                SizedBox(width: 8),
                Text(
                  'Return to Dashboard',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: whiteColor,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(paddingLarge),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: paddingMedium),

                // Status Icon
                ScaleTransition(
                  scale: _scaleAnimation,
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _statusColor.withOpacity(0.15),
                      border: Border.all(color: _statusColor, width: 3),
                      boxShadow: [
                        BoxShadow(
                          color: _statusColor.withOpacity(0.3),
                          blurRadius: 30,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: Icon(
                      _statusIcon,
                      color: _statusColor,
                      size: 64,
                    ),
                  ),
                ),

                const SizedBox(height: paddingLarge),

                // Title
                Text(
                  _statusTitle,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    color: whiteColor,
                    letterSpacing: 1,
                  ),
                ),

                const SizedBox(height: paddingSmall),

                Text(
                  _statusSubtitle,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: mediumGrey.withOpacity(0.9),
                    height: 1.5,
                  ),
                ),

                const SizedBox(height: paddingXLarge),

                // ============================================
                // SPRINT 4 - ESCALATE TO 112 BUTTON
                // ============================================

                _buildEscalationCard(),

                const SizedBox(height: paddingLarge),

                // Multi-Channel Breakdown (if strategy)
                if (_isMultiChannel) _buildStrategyBreakdown(),

                if (_isMultiChannel) const SizedBox(height: paddingLarge),

                // Single Dispatch Summary (if not strategy)
                if (!_isMultiChannel && widget.dispatchResult != null)
                  _buildSingleDispatchCard(),

                if (!_isMultiChannel && widget.dispatchResult != null)
                  const SizedBox(height: paddingLarge),

                // Alert Details Card
                _buildAlertDetailsCard(),

                const SizedBox(height: paddingLarge),

                // Location Card
                _buildLocationCard(),

                const SizedBox(height: paddingLarge),

                // Message Card
                _buildMessageCard(),

                const SizedBox(height: paddingXLarge),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ----------------------------
  // NEW - Escalation Card (Sprint 4)
  // ----------------------------

  Widget _buildEscalationCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(paddingMedium),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            primaryRed.withOpacity(0.15),
            primaryRed.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: primaryRed, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
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
                  size: 18,
                ),
              ),
              const SizedBox(width: paddingMedium),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Need Official Emergency Services?',
                      style: TextStyle(
                        color: whiteColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Escalate to India\'s ERSS 112',
                      style: TextStyle(
                        color: mediumGrey,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: paddingMedium),

          // Description
          Text(
            'Contacts trusted people are notified. For police, medical, '
            'fire, or life-threatening emergencies, you can also contact '
            'official emergency services.',
            style: TextStyle(
              color: whiteColor.withOpacity(0.8),
              fontSize: 12,
              height: 1.5,
            ),
          ),

          const SizedBox(height: paddingMedium),

          // Escalate Button
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton.icon(
              onPressed: _onEscalatePressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryRed,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: const Icon(Icons.call, color: whiteColor, size: 20),
              label: const Text(
                'ESCALATE TO 112',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: whiteColor,
                  letterSpacing: 1.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ----------------------------
  // Strategy Breakdown Card
  // ----------------------------

  Widget _buildStrategyBreakdown() {
    final strategy = widget.strategyResult!;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(paddingMedium),
      decoration: BoxDecoration(
        color: lightNavy,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _statusColor.withOpacity(0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.rocket_launch, color: _statusColor, size: 18),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Multi-Channel Dispatch',
                  style: TextStyle(
                    color: whiteColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: _statusColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  strategy.status.label,
                  style: TextStyle(
                    color: _statusColor,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: paddingMedium),

          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 6,
            ),
            decoration: BoxDecoration(
              color: darkNavy,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.alt_route,
                  color: mediumGrey.withOpacity(0.6),
                  size: 14,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    strategy.config.displayName,
                    style: const TextStyle(
                      color: whiteColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: paddingMedium),

          const Text(
            'DISPATCH RESULTS',
            style: TextStyle(
              color: mediumGrey,
              fontSize: 10,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
            ),
          ),

          const SizedBox(height: paddingSmall),

          ...strategy.results.map((result) => _buildDispatchResultRow(result)),

          const SizedBox(height: paddingMedium),

          Container(
            padding: const EdgeInsets.all(paddingSmall),
            decoration: BoxDecoration(
              color: darkNavy,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _buildStatColumn(
                    'Attempts',
                    '${strategy.totalAttempts}',
                    Icons.rocket_launch,
                  ),
                ),
                Container(
                  width: 1,
                  height: 30,
                  color: mediumGrey.withOpacity(0.2),
                ),
                Expanded(
                  child: _buildStatColumn(
                    'Successful',
                    '${strategy.successfulDispatchers}',
                    Icons.check_circle,
                    color: Colors.green,
                  ),
                ),
                Container(
                  width: 1,
                  height: 30,
                  color: mediumGrey.withOpacity(0.2),
                ),
                Expanded(
                  child: _buildStatColumn(
                    'Duration',
                    '${(strategy.executionDuration.inMilliseconds / 1000).toStringAsFixed(1)}s',
                    Icons.timer,
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
  // Dispatch Result Row
  // ----------------------------

  Widget _buildDispatchResultRow(DispatchResult result) {
    Color rowColor;
    IconData rowIcon;

    switch (result.status) {
      case DispatchStatus.success:
        rowColor = Colors.green;
        rowIcon = Icons.check_circle;
        break;
      case DispatchStatus.partialSuccess:
        rowColor = Colors.orange;
        rowIcon = Icons.warning_amber_rounded;
        break;
      case DispatchStatus.failed:
        rowColor = primaryRed;
        rowIcon = Icons.error;
        break;
      case DispatchStatus.skipped:
        rowColor = mediumGrey;
        rowIcon = Icons.skip_next;
        break;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: paddingSmall),
      child: Container(
        padding: const EdgeInsets.all(paddingSmall),
        decoration: BoxDecoration(
          color: darkNavy,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: rowColor.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Icon(rowIcon, color: rowColor, size: 18),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    result.method.label,
                    style: const TextStyle(
                      color: whiteColor,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (result.errorMessage != null)
                    Text(
                      result.errorMessage!,
                      style: TextStyle(
                        color: mediumGrey.withOpacity(0.8),
                        fontSize: 10,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    )
                  else
                    Text(
                      '${result.successCount}/${result.recipientCount} recipients',
                      style: const TextStyle(
                        color: mediumGrey,
                        fontSize: 10,
                      ),
                    ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 6,
                vertical: 2,
              ),
              decoration: BoxDecoration(
                color: rowColor.withOpacity(0.15),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                result.status.label,
                style: TextStyle(
                  color: rowColor,
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatColumn(
    String label,
    String value,
    IconData icon, {
    Color? color,
  }) {
    return Column(
      children: [
        Icon(icon, color: color ?? mediumGrey, size: 16),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            color: color ?? whiteColor,
            fontSize: 13,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            color: mediumGrey,
            fontSize: 9,
          ),
        ),
      ],
    );
  }

  // ----------------------------
  // Single Dispatch Card
  // ----------------------------

  Widget _buildSingleDispatchCard() {
    final result = widget.dispatchResult!;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(paddingMedium),
      decoration: BoxDecoration(
        color: lightNavy,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _statusColor.withOpacity(0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.rocket_launch, color: _statusColor, size: 18),
              const SizedBox(width: 8),
              const Text(
                'Dispatch Summary',
                style: TextStyle(
                  color: whiteColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: _statusColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  result.status.label,
                  style: TextStyle(
                    color: _statusColor,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: paddingMedium),

          _buildSummaryRow('Method', result.method.label),
          _buildDivider(),

          _buildSummaryRow(
            'Recipients',
            '${result.successCount} of ${result.recipientCount} contacts',
          ),
          _buildDivider(),

          _buildSummaryRow(
            'Success Rate',
            '${(result.successRate * 100).toStringAsFixed(0)}%',
          ),

          if (result.errorMessage != null) ...[
            _buildDivider(),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.info_outline,
                    color: primaryRed.withOpacity(0.7),
                    size: 14,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      result.errorMessage!,
                      style: TextStyle(
                        color: primaryRed.withOpacity(0.9),
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(color: mediumGrey, fontSize: 13),
          ),
          Text(
            value,
            style: const TextStyle(
              color: whiteColor,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(color: whiteColor.withOpacity(0.05), thickness: 1);
  }

  // ----------------------------
  // Alert Details Card
  // ----------------------------

  Widget _buildAlertDetailsCard() {
    final alert = widget.alert;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(paddingMedium),
      decoration: BoxDecoration(
        color: lightNavy,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: primaryRed.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.badge, color: primaryRed, size: 18),
              SizedBox(width: 8),
              Text(
                'Alert Information',
                style: TextStyle(
                  color: whiteColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ),

          const SizedBox(height: paddingMedium),

          _buildSummaryRow('Alert ID', alert.alertId),
          _buildDivider(),
          _buildSummaryRow('User', alert.userName),
          _buildDivider(),
          _buildSummaryRow('Contacts', '${alert.contactCount}'),
          _buildDivider(),
          _buildSummaryRow('Timestamp', alert.formattedTimestamp),
        ],
      ),
    );
  }

  // ----------------------------
  // Location Card
  // ----------------------------

  Widget _buildLocationCard() {
    return GestureDetector(
      onTap: _openMap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(paddingMedium),
        decoration: BoxDecoration(
          color: lightNavy,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: primaryRed.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: primaryRed.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.map, color: primaryRed, size: 28),
            ),
            const SizedBox(width: paddingMedium),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'View on Google Maps',
                    style: TextStyle(
                      color: whiteColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    widget.alert.formattedCoordinates,
                    style: const TextStyle(
                      color: primaryRed,
                      fontSize: 11,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const Icon(Icons.open_in_new, color: primaryRed, size: 20),
          ],
        ),
      ),
    );
  }

  // ----------------------------
  // Message Card
  // ----------------------------

  Widget _buildMessageCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(paddingMedium),
      decoration: BoxDecoration(
        color: lightNavy,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: primaryRed.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.message_outlined,
                color: primaryRed,
                size: 18,
              ),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Emergency Message',
                  style: TextStyle(
                    color: whiteColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
              GestureDetector(
                onTap: _copyMessage,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: primaryRed.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: primaryRed.withOpacity(0.3)),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.copy, color: primaryRed, size: 14),
                      SizedBox(width: 4),
                      Text(
                        'Copy',
                        style: TextStyle(
                          color: primaryRed,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: paddingMedium),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(paddingMedium),
            decoration: BoxDecoration(
              color: darkNavy,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              widget.alert.message,
              style: TextStyle(
                color: whiteColor.withOpacity(0.85),
                fontSize: 13,
                height: 1.6,
              ),
            ),
          ),
        ],
      ),
    );
  }
}