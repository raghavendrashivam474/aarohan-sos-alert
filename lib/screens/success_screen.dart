// ============================================
// Aarohan SOS Alert
// File        : screens/success_screen.dart
// Description : SOS Success Confirmation Screen (Sprint 2)
// ============================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import '../utils/constants.dart';
import '../models/dispatch/emergency_alert.dart';
import '../models/dispatch/dispatch_result.dart';
import 'dashboard_screen.dart';

class SuccessScreen extends StatefulWidget {
  final EmergencyAlert alert;
  final DispatchResult dispatchResult;

  const SuccessScreen({
    super.key,
    required this.alert,
    required this.dispatchResult,
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
  // Status Color Helpers
  // ----------------------------

  Color get _statusColor {
    switch (widget.dispatchResult.status) {
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
    switch (widget.dispatchResult.status) {
      case DispatchStatus.success:
        return Icons.check_circle;
      case DispatchStatus.partialSuccess:
        return Icons.warning_amber_rounded;
      case DispatchStatus.failed:
        return Icons.error_outline;
      case DispatchStatus.skipped:
        return Icons.skip_next;
    }
  }

  String get _statusTitle {
    switch (widget.dispatchResult.status) {
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
    switch (widget.dispatchResult.status) {
      case DispatchStatus.success:
        return 'Emergency workflow completed successfully';
      case DispatchStatus.partialSuccess:
        return 'Some contacts could not be notified';
      case DispatchStatus.failed:
        return widget.dispatchResult.errorMessage ??
            'Dispatch operation failed';
      case DispatchStatus.skipped:
        return widget.dispatchResult.errorMessage ??
            'Dispatch was skipped';
    }
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

                // ----------------------------
                // Status Icon
                // ----------------------------

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

                // ----------------------------
                // Title + Subtitle
                // ----------------------------

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
                    color: mediumGrey.withOpacity(0.8),
                    height: 1.5,
                  ),
                ),

                const SizedBox(height: paddingXLarge),

                // ----------------------------
                // Dispatch Summary Card
                // ----------------------------

                _buildDispatchSummaryCard(),

                const SizedBox(height: paddingLarge),

                // ----------------------------
                // Alert Details Card
                // ----------------------------

                _buildAlertDetailsCard(),

                const SizedBox(height: paddingLarge),

                // ----------------------------
                // Location Card
                // ----------------------------

                _buildLocationCard(),

                const SizedBox(height: paddingLarge),

                // ----------------------------
                // Message Card
                // ----------------------------

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
  // Dispatch Summary Card
  // ----------------------------

  Widget _buildDispatchSummaryCard() {
    final result = widget.dispatchResult;

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

  Widget _buildDivider() {
    return Divider(color: whiteColor.withOpacity(0.05), thickness: 1);
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