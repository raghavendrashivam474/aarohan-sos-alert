// ============================================
// Aarohan SOS Alert
// File        : screens/dashboard_screen.dart
// Description : Main SOS Dashboard
// ============================================

import 'package:flutter/material.dart';
import '../utils/constants.dart';
import '../models/user_model.dart';
import '../services/storage_service.dart';
import '../services/location_service.dart';
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

  final StorageService _storageService = StorageService();
  final LocationService _locationService = LocationService();

  // ----------------------------
  // Init
  // ----------------------------

  @override
  void initState() {
    super.initState();
    _loadUser();
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
    final confirmed = await _showSOSConfirmDialog();
    if (!confirmed) return;

    setState(() => _isLoading = true);

    final locationResult = await _locationService.getCurrentLocation();

    setState(() => _isLoading = false);

    if (!mounted) return;

    if (!locationResult.success) {
      _showLocationErrorDialog(
        locationResult.errorMessage ?? 'Unknown error',
      );
      return;
    }

    final message = buildEmergencyMessage(
      _user?.name ?? 'User',
      locationResult.mapLink ?? '',
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SuccessScreen(
          message: message,
          mapLink: locationResult.mapLink ?? '',
          latitude: locationResult.latitude ?? 0.0,
          longitude: locationResult.longitude ?? 0.0,
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
        content: const Text(
          'This will send an emergency alert with your location to all your emergency contacts.',
          style: TextStyle(color: mediumGrey, height: 1.5),
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
  // Location Error Dialog
  // ----------------------------

  void _showLocationErrorDialog(String error) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: lightNavy,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Row(
          children: [
            Icon(Icons.location_off, color: primaryRed),
            SizedBox(width: 8),
            Text(
              'Location Error',
              style: TextStyle(color: whiteColor),
            ),
          ],
        ),
        content: Text(
          error,
          style: const TextStyle(color: mediumGrey),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _locationService.openLocationSettings();
            },
            child: const Text(
              'Open Settings',
              style: TextStyle(color: primaryRed),
            ),
          ),
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
                  // ----------------------------
                  // Top Bar
                  // ----------------------------

                  _buildTopBar(),

                  // ----------------------------
                  // Scrollable Body
                  // ----------------------------

                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          // Status Card
                          _buildStatusCard(),

                          const SizedBox(height: paddingMedium),

                          // Instruction Text
                          Text(
                            'Press SOS in Emergency',
                            style: TextStyle(
                              fontSize: 16,
                              color: whiteColor.withOpacity(0.6),
                              letterSpacing: 1,
                            ),
                          ),

                          const SizedBox(height: 40),

                          // SOS Button
                          SosButton(
                            onPressed: _onSOSPressed,
                            isLoading: _isLoading,
                          ),

                          const SizedBox(height: 40),

                          // Emergency Contacts Info
                          _buildContactInfo(),

                          const SizedBox(height: paddingLarge),

                          // Primary Contact Card
                          _buildPrimaryContactCard(),

                          const SizedBox(height: paddingLarge),
                        ],
                      ),
                    ),
                  ),

                  // ----------------------------
                  // Bottom Bar
                  // ----------------------------

                  _buildBottomBar(),
                ],
              ),
      ),
    );
  }

  // ----------------------------
  // Top Bar Builder (With Real Logo)
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
          // ----------------------------
          // Mini Logo Image
          // ----------------------------

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

          // ----------------------------
          // App Name + Greeting
          // ----------------------------

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

          // ----------------------------
          // Shield Status Icon
          // ----------------------------

          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: primaryRed.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: primaryRed.withOpacity(0.3),
              ),
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
  // Status Card Builder
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
          // Status Dot
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

          // Contact Count Badge
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
  // Contact Info Builder
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
          // Header
          Row(
            children: [
              const Icon(Icons.notifications_active,
                  color: primaryRed, size: 16),
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

          // Contact Chips
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
  // Primary Contact Card Builder
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
          // Icon
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: primaryRed.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.star, color: primaryRed, size: 20),
          ),

          const SizedBox(width: paddingMedium),

          // Info
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

          // Priority Badge
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
  // Bottom Bar Builder
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