// ============================================
// Aarohan SOS Alert
// File        : screens/intro_screen.dart
// Description : Introduction / Splash Screen
// ============================================

import 'package:flutter/material.dart';
import '../utils/constants.dart';
import 'user_details_screen.dart';
import 'dashboard_screen.dart';
import '../services/storage_service.dart';

class IntroScreen extends StatefulWidget {
  const IntroScreen({super.key});

  @override
  State<IntroScreen> createState() => _IntroScreenState();
}

class _IntroScreenState extends State<IntroScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  final StorageService _storageService = StorageService();

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeIn,
      ),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOut,
      ),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _onGetStarted() async {
    final isSetupDone = await _storageService.isSetupDone();
    if (!mounted) return;
    if (isSetupDone) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const DashboardScreen(),
        ),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const UserDetailsScreen(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: whiteColor,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: paddingLarge,
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: MediaQuery.of(context).size.height -
                      MediaQuery.of(context).padding.top -
                      MediaQuery.of(context).padding.bottom,
                ),
                child: IntrinsicHeight(
                  child: Column(
                    children: [
                      const Spacer(flex: 1),

                      // ----------------------------
                      // Aarohan Logo (Real Image)
                      // ----------------------------

                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: primaryRed.withOpacity(0.15),
                              blurRadius: 40,
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(24),
                          child: Image.asset(
                            'assets/images/logo.jpeg',
                            width: 280,
                            height: 280,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),

                      const SizedBox(height: paddingLarge),

                      // ----------------------------
                      // Divider
                      // ----------------------------

                      Row(
                        children: [
                          Expanded(
                            child: Divider(
                              color: primaryRed.withOpacity(0.3),
                              thickness: 1,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: paddingMedium,
                            ),
                            child: Icon(
                              Icons.shield,
                              color: primaryRed.withOpacity(0.6),
                              size: 20,
                            ),
                          ),
                          Expanded(
                            child: Divider(
                              color: primaryRed.withOpacity(0.3),
                              thickness: 1,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: paddingLarge),

                      // ----------------------------
                      // Description
                      // ----------------------------

                      Text(
                        appDescription,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          color: primaryNavy.withOpacity(0.7),
                          height: 1.6,
                        ),
                      ),

                      const SizedBox(height: paddingLarge),

                      // ----------------------------
                      // Feature Chips
                      // ----------------------------

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildFeatureChip(
                            Icons.location_on,
                            'GPS Alert',
                          ),
                          _buildFeatureChip(
                            Icons.contacts,
                            'Contacts',
                          ),
                          _buildFeatureChip(
                            Icons.flash_on,
                            'Instant',
                          ),
                        ],
                      ),

                      const Spacer(flex: 2),

                      // ----------------------------
                      // Get Started Button
                      // ----------------------------

                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: _onGetStarted,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryRed,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 4,
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Get Started',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: whiteColor,
                                  letterSpacing: 1,
                                ),
                              ),
                              SizedBox(width: 8),
                              Icon(
                                Icons.arrow_forward,
                                color: whiteColor,
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: paddingLarge),

                      // ----------------------------
                      // Version
                      // ----------------------------

                      Text(
                        'v1.0.0 MVP',
                        style: TextStyle(
                          fontSize: 12,
                          color: primaryNavy.withOpacity(0.4),
                        ),
                      ),

                      const SizedBox(height: paddingSmall),

                      // ----------------------------
                      // Attribution
                      // ----------------------------

                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: paddingLarge,
                          vertical: paddingMedium,
                        ),
                        decoration: BoxDecoration(
                          color: primaryNavy.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: primaryRed.withOpacity(0.2),
                          ),
                        ),
                        child: Column(
                          children: [
                            Text(
                              'DEVELOPED BY',
                              style: TextStyle(
                                fontSize: 10,
                                color: primaryNavy.withOpacity(0.6),
                                letterSpacing: 2,
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'Amitesh Rajput',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: primaryNavy,
                                letterSpacing: 1,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: paddingMedium),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureChip(IconData icon, String label) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: primaryRed.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: primaryRed.withOpacity(0.3),
            ),
          ),
          child: Icon(icon, color: primaryRed, size: 24),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: primaryNavy.withOpacity(0.7),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}