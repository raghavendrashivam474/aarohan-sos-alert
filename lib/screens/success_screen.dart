// ============================================
// Aarohan SOS Alert
// File        : screens/success_screen.dart
// Description : SOS Success Confirmation Screen
// ============================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import '../utils/constants.dart';
import 'dashboard_screen.dart';

class SuccessScreen extends StatefulWidget {
  final String message;
  final String mapLink;
  final double latitude;
  final double longitude;

  const SuccessScreen({
    super.key,
    required this.message,
    required this.mapLink,
    required this.latitude,
    required this.longitude,
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

  Future<void> _openMap() async {
    final uri = Uri.parse(widget.mapLink);
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
    Clipboard.setData(ClipboardData(text: widget.message));
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
      MaterialPageRoute(
        builder: (context) => const DashboardScreen(),
      ),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryNavy,

      // ----------------------------
      // Fixed Return Button at Bottom
      // ----------------------------

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

          // ----------------------------
          // Full Screen Scrollable
          // ----------------------------

          child: SingleChildScrollView(
            padding: const EdgeInsets.all(paddingLarge),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: paddingLarge),

                // ----------------------------
                // Success Icon
                // ----------------------------

                ScaleTransition(
                  scale: _scaleAnimation,
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.green.withOpacity(0.15),
                      border: Border.all(
                        color: Colors.green,
                        width: 3,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.green.withOpacity(0.3),
                          blurRadius: 30,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.check,
                      color: Colors.green,
                      size: 64,
                    ),
                  ),
                ),

                const SizedBox(height: paddingLarge),

                // ----------------------------
                // Title
                // ----------------------------

                const Text(
                  'SOS Alert Activated',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                    color: whiteColor,
                    letterSpacing: 1,
                  ),
                ),

                const SizedBox(height: paddingSmall),

                Text(
                  'Emergency workflow executed successfully',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: mediumGrey.withOpacity(0.8),
                  ),
                ),

                const SizedBox(height: paddingXLarge),

                // ----------------------------
                // Status Steps Card
                // ----------------------------

                _buildStatusCard(),

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

  Widget _buildStatusCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(paddingMedium),
      decoration: BoxDecoration(
        color: lightNavy,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.green.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          _buildStatusRow(
            Icons.location_on,
            'Location Retrieved',
            '${widget.latitude.toStringAsFixed(4)}, '
                '${widget.longitude.toStringAsFixed(4)}',
          ),
          _buildDivider(),
          _buildStatusRow(
            Icons.message,
            'Emergency Message Prepared',
            'Message ready to share',
          ),
          _buildDivider(),
          _buildStatusRow(
            Icons.send,
            'Emergency Workflow Executed',
            'All steps completed',
          ),
        ],
      ),
    );
  }

  Widget _buildStatusRow(IconData icon, String title, String subtitle) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: paddingSmall),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.green.withOpacity(0.15),
            ),
            child: const Icon(
              Icons.check_circle,
              color: Colors.green,
              size: 20,
            ),
          ),
          const SizedBox(width: paddingMedium),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: whiteColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: mediumGrey,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(color: whiteColor.withOpacity(0.05), thickness: 1);
  }

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
                    widget.mapLink,
                    style: const TextStyle(color: primaryRed, fontSize: 11),
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
              const Icon(Icons.message_outlined, color: primaryRed, size: 18),
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
              widget.message,
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