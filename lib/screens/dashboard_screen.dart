// ============================================
// Aarohan SOS Alert
// File        : screens/dashboard_screen.dart
// Description : Main SOS Dashboard (Sprint 2 - Refactored)
// ============================================

import 'package:flutter/material.dart';
import '../utils/constants.dart';
import '../models/user_model.dart';
import '../models/dispatch/dispatch_result.dart';
import '../services/storage_service.dart';
import '../controllers/sos_controller.dart';
import '../widgets/sos_button.dart';
import 'contact_management_screen.dart';
import 'success_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  // ----------------------------
  // State
  // ----------------------------

  UserModel? _user;
  bool _isLoading = false;
  bool _isLoadingUser = true;
  String _currentStage = '';

  DispatchMethod _selectedMethod = DispatchMethod.share;

  final StorageService _storageService = StorageService();
  final SosController _sosController = SosController();

  // ----------------------------
  // Init
  // ----------------------------

  @override
  void initState() {
    super.initState();
    _loadUser();
    _setupController();
  }

  // ----------------------------
  // Setup Controller Progress Listener
  // ----------------------------

  void _setupController() {
    _sosController.onProgress = (stage) {
      if (!mounted) return;
      setState(() {
        _currentStage = stage.label;
      });
    };
  }

  // ----------------------------
  // Load User
  // ----------------------------

  Future<void> _loadUser() async {
    setState(() => _isLoadingUser = true);
    final user = await _storageService.loadUserDetails();
    setState(() {
      _user = user;
      _isLoadingUser = false;
    });
  }

  // ----------------------------
  // SOS Triggered
  // ----------------------------

  Future<void> _onSOSPressed() async {
    // Confirm before triggering
    final confirmed = await _showSOSConfirmDialog();
    if (!confirmed) return;

    setState(() {
      _isLoading = true;
      _currentStage = 'Initializing...';
    });

    // ----------------------------
    // Trigger via Controller
    // ----------------------------

    final result = await _sosController.triggerSOS(
      dispatchMethod: _selectedMethod,
    );

    setState(() {
      _isLoading = false;
      _currentStage = '';
    });

    if (!mounted) return;

    // ----------------------------
    // Handle Result
    // ----------------------------

    if (!result.success) {
      _showErrorDialog(
        result.errorMessage ?? 'SOS workflow failed',
        result.failedAtStage.label,
      );
      return;
    }

    // Navigate to success screen
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SuccessScreen(
          alert: result.alert!,
          dispatchResult: result.dispatchResult!,
        ),
      ),
    );
  }

  // ----------------------------
  // SOS Confirm Dialog
  // ----------------------------

  Future<bool> _showSOSConfirmDialog() async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: lightNavy,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: primaryRed, size: 28),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                'Send SOS Alert?',
                style: TextStyle(
                  color: whiteColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'This will send an emergency alert with your location to all your emergency contacts.',
              style: TextStyle(color: mediumGrey, height: 1.5),
            ),
            const SizedBox(height: paddingMedium),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: darkNavy,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    _selectedMethod == DispatchMethod.share
                        ? Icons.share
                        : Icons.science,
                    color: primaryRed,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Method: ${_selectedMethod.label}',
                    style: const TextStyle(
                      color: whiteColor,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text(
              'Cancel',
              style: TextStyle(color: mediumGrey),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryRed,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'YES, SEND SOS',
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
  // Error Dialog
  // ----------------------------

  void _showErrorDialog(String error, String stage) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: lightNavy,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Row(
          children: [
            Icon(Icons.error_outline, color: primaryRed),
            SizedBox(width: 8),
            Text(
              'SOS Failed',
              style: TextStyle(color: whiteColor),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 4,
              ),
              decoration: BoxDecoration(
                color: primaryRed.withOpacity(0.15),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                'Failed at: $stage',
                style: const TextStyle(
                  color: primaryRed,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: paddingMedium),
            Text(
              error,
              style: const TextStyle(color: mediumGrey),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(backgroundColor: primaryRed),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  // ----------------------------
  // Method Selector Bottom Sheet
  // ----------------------------

  void _showMethodSelector() {
    showModalBottomSheet(
      context: context,
      backgroundColor: lightNavy,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(paddingLarge),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Choose Dispatch Method',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: whiteColor,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'How would you like to send the emergency alert?',
              style: TextStyle(
                fontSize: 12,
                color: mediumGrey.withOpacity(0.8),
              ),
            ),
            const SizedBox(height: paddingLarge),

            _buildMethodTile(
              method: DispatchMethod.share,
              icon: Icons.share,
              title: 'Share Sheet',
              subtitle: 'Send via WhatsApp, SMS, Email, etc',
              available: true,
            ),

            _buildMethodTile(
              method: DispatchMethod.simulation,
              icon: Icons.science,
              title: 'Simulation',
              subtitle: 'Test mode (no message sent)',
              available: true,
            ),

            _buildMethodTile(
              method: DispatchMethod.sms,
              icon: Icons.sms,
              title: 'Direct SMS',
              subtitle: 'Coming soon',
              available: false,
            ),

            _buildMethodTile(
              method: DispatchMethod.call,
              icon: Icons.call,
              title: 'Direct Call',
              subtitle: 'Coming soon',
              available: false,
            ),

            const SizedBox(height: paddingMedium),
          ],
        ),
      ),
    );
  }

  Widget _buildMethodTile({
    required DispatchMethod method,
    required IconData icon,
    required String title,
    required String subtitle,
    required bool available,
  }) {
    final isSelected = _selectedMethod == method;

    return Padding(
      padding: const EdgeInsets.only(bottom: paddingSmall),
      child: GestureDetector(
        onTap: available
            ? () {
                setState(() => _selectedMethod = method);
                Navigator.pop(context);
              }
            : null,
        child: Container(
          padding: const EdgeInsets.all(paddingMedium),
          decoration: BoxDecoration(
            color: isSelected
                ? primaryRed.withOpacity(0.15)
                : darkNavy,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected
                  ? primaryRed
                  : (available
                      ? mediumGrey.withOpacity(0.2)
                      : mediumGrey.withOpacity(0.1)),
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: available
                      ? primaryRed.withOpacity(0.15)
                      : mediumGrey.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: available ? primaryRed : mediumGrey,
                  size: 22,
                ),
              ),
              const SizedBox(width: paddingMedium),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: available ? whiteColor : mediumGrey,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: available
                            ? mediumGrey
                            : mediumGrey.withOpacity(0.5),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              if (isSelected)
                const Icon(Icons.check_circle, color: primaryRed),
              if (!available)
                Icon(
                  Icons.lock_outline,
                  color: mediumGrey.withOpacity(0.5),
                  size: 18,
                ),
            ],
          ),
        ),
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
      body: SafeArea(
        child: _isLoadingUser
            ? const Center(
                child: CircularProgressIndicator(color: primaryRed),
              )
            : Column(
                children: [
                  _buildTopBar(),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          _buildStatusCard(),
                          const SizedBox(height: paddingMedium),

                          // Progress or Instruction
                          if (_isLoading && _currentStage.isNotEmpty)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: paddingMedium,
                                vertical: paddingSmall,
                              ),
                              margin: const EdgeInsets.symmetric(
                                horizontal: paddingLarge,
                              ),
                              decoration: BoxDecoration(
                                color: primaryRed.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: primaryRed.withOpacity(0.3),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const SizedBox(
                                    width: 14,
                                    height: 14,
                                    child: CircularProgressIndicator(
                                      color: primaryRed,
                                      strokeWidth: 2,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Text(
                                    _currentStage,
                                    style: const TextStyle(
                                      color: primaryRed,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          else
                            Text(
                              'Press SOS in Emergency',
                              style: TextStyle(
                                fontSize: 16,
                                color: whiteColor.withOpacity(0.6),
                                letterSpacing: 1,
                              ),
                            ),

                          const SizedBox(height: 40),

                          SosButton(
                            onPressed: _onSOSPressed,
                            isLoading: _isLoading,
                          ),

                          const SizedBox(height: 30),

                          // Dispatch Method Selector Button
                          _buildMethodSelectorButton(),

                          const SizedBox(height: paddingLarge),

                          _buildContactInfo(),

                          const SizedBox(height: paddingLarge),

                          _buildPrimaryContactCard(),

                          const SizedBox(height: paddingLarge),
                        ],
                      ),
                    ),
                  ),
                  _buildBottomBar(),
                ],
              ),
      ),
    );
  }

  // ----------------------------
  // Method Selector Button
  // ----------------------------

  Widget _buildMethodSelectorButton() {
    return GestureDetector(
      onTap: _isLoading ? null : _showMethodSelector,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: paddingLarge),
        padding: const EdgeInsets.symmetric(
          horizontal: paddingMedium,
          vertical: paddingSmall,
        ),
        decoration: BoxDecoration(
          color: lightNavy,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: primaryRed.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _selectedMethod == DispatchMethod.share
                  ? Icons.share
                  : Icons.science,
              color: primaryRed,
              size: 16,
            ),
            const SizedBox(width: 8),
            Text(
              'Method: ${_selectedMethod.label}',
              style: const TextStyle(
                color: whiteColor,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: 6),
            Icon(
              Icons.arrow_drop_down,
              color: mediumGrey,
              size: 18,
            ),
          ],
        ),
      ),
    );
  }

  // ----------------------------
  // Top Bar
  // ----------------------------

  Widget _buildTopBar() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: paddingMedium,
        vertical: paddingMedium,
      ),
      decoration: BoxDecoration(
        color: darkNavy,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: whiteColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: primaryRed.withOpacity(0.4),
                width: 1.5,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(11),
              child: Image.asset(
                'assets/images/logo.jpeg',
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(width: paddingMedium),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  appFullName,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: whiteColor,
                    letterSpacing: 0.5,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  'Hello, ${_user?.name ?? 'User'}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: mediumGrey,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: primaryRed.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: primaryRed.withOpacity(0.3)),
            ),
            child: const Icon(
              Icons.verified_user,
              color: primaryRed,
              size: 22,
            ),
          ),
        ],
      ),
    );
  }

  // ----------------------------
  // Status Card
  // ----------------------------

  Widget _buildStatusCard() {
    final contactCount = _user?.emergencyContacts.length ?? 0;

    return Container(
      margin: const EdgeInsets.all(paddingLarge),
      padding: const EdgeInsets.all(paddingMedium),
      decoration: BoxDecoration(
        color: lightNavy,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: primaryRed.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.green,
            ),
          ),
          const SizedBox(width: 10),
          const Text(
            'System Ready',
            style: TextStyle(
              color: Colors.green,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 4,
            ),
            decoration: BoxDecoration(
              color: contactCount > 0
                  ? Colors.green.withOpacity(0.15)
                  : primaryRed.withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: contactCount > 0
                    ? Colors.green.withOpacity(0.4)
                    : primaryRed.withOpacity(0.4),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.contacts,
                  color: contactCount > 0 ? Colors.green : primaryRed,
                  size: 14,
                ),
                const SizedBox(width: 4),
                Text(
                  '$contactCount Contact${contactCount != 1 ? 's' : ''}',
                  style: TextStyle(
                    color: contactCount > 0 ? Colors.green : primaryRed,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
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
  // Contact Info
  // ----------------------------

  Widget _buildContactInfo() {
    final contacts = _user?.emergencyContacts ?? [];

    if (contacts.isEmpty) {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: paddingLarge),
        padding: const EdgeInsets.all(paddingMedium),
        decoration: BoxDecoration(
          color: primaryRed.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: primaryRed.withOpacity(0.3)),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.warning_amber, color: primaryRed, size: 18),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                'No emergency contacts added.\nPlease add contacts before using SOS.',
                style: TextStyle(color: primaryRed, fontSize: 13),
              ),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: paddingLarge),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.notifications_active,
                color: primaryRed,
                size: 16,
              ),
              const SizedBox(width: 6),
              Text(
                'Alert will be sent to ${contacts.length} contact${contacts.length != 1 ? 's' : ''}',
                style: TextStyle(
                  fontSize: 13,
                  color: whiteColor.withOpacity(0.6),
                ),
              ),
            ],
          ),
          const SizedBox(height: paddingSmall),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: contacts.map((contact) {
              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: lightNavy,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: primaryRed.withOpacity(0.3)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 20,
                      height: 20,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: primaryRed,
                      ),
                      child: Center(
                        child: Text(
                          contact.name[0].toUpperCase(),
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: whiteColor,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      contact.name,
                      style: const TextStyle(
                        color: whiteColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  // ----------------------------
  // Primary Contact Card
  // ----------------------------

  Widget _buildPrimaryContactCard() {
    final contacts = _user?.emergencyContacts ?? [];
    if (contacts.isEmpty) return const SizedBox.shrink();

    final primary = contacts.first;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: paddingLarge),
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
            child: const Icon(Icons.star, color: primaryRed, size: 20),
          ),
          const SizedBox(width: paddingMedium),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Primary Emergency Contact',
                  style: TextStyle(
                    fontSize: 11,
                    color: mediumGrey,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  primary.name,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: whiteColor,
                  ),
                ),
                Text(
                  '${primary.relationship} • ${primary.phone}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: mediumGrey,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 8,
              vertical: 4,
            ),
            decoration: BoxDecoration(
              color: primaryRed.withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text(
              '#1',
              style: TextStyle(
                color: primaryRed,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ----------------------------
  // Bottom Bar
  // ----------------------------

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.all(paddingLarge),
      decoration: BoxDecoration(
        color: darkNavy,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SizedBox(
        width: double.infinity,
        child: OutlinedButton.icon(
          onPressed: () async {
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const ContactManagementScreen(),
              ),
            );
            _loadUser();
          },
          icon: const Icon(Icons.contacts, color: primaryRed),
          label: const Text(
            'Manage Contacts',
            style: TextStyle(color: primaryRed),
          ),
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: primaryRed),
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
    );
  }
}