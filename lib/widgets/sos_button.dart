// ============================================
// Aarohan SOS Alert
// File        : widgets/sos_button.dart
// Description : Reusable SOS Button Widget
// ============================================

import 'package:flutter/material.dart';
import '../utils/constants.dart';

class SosButton extends StatefulWidget {
  // ----------------------------
  // Properties
  // ----------------------------

  final VoidCallback onPressed;
  final bool isLoading;

  const SosButton({
    super.key,
    required this.onPressed,
    this.isLoading = false,
  });

  @override
  State<SosButton> createState() => _SosButtonState();
}

class _SosButtonState extends State<SosButton>
    with SingleTickerProviderStateMixin {
  // ----------------------------
  // Animation Controllers
  // ----------------------------

  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _pulseAnimation;

  // ----------------------------
  // Init
  // ----------------------------

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.08,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );

    _pulseAnimation = Tween<double>(
      begin: 0.85,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
  }

  // ----------------------------
  // Dispose
  // ----------------------------

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  // ----------------------------
  // Build
  // ----------------------------

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Stack(
          alignment: Alignment.center,
          children: [
            // ----------------------------
            // Outer Pulse Ring
            // ----------------------------

            Transform.scale(
              scale: _scaleAnimation.value * 1.25,
              child: Container(
                width: sosBtnSize,
                height: sosBtnSize,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: primaryRed.withOpacity(
                    0.15 * _pulseAnimation.value,
                  ),
                ),
              ),
            ),

            // ----------------------------
            // Middle Pulse Ring
            // ----------------------------

            Transform.scale(
              scale: _scaleAnimation.value * 1.12,
              child: Container(
                width: sosBtnSize,
                height: sosBtnSize,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: primaryRed.withOpacity(
                    0.25 * _pulseAnimation.value,
                  ),
                ),
              ),
            ),

            // ----------------------------
            // Main SOS Button
            // ----------------------------

            GestureDetector(
              onTap: widget.isLoading ? null : widget.onPressed,
              child: Transform.scale(
                scale: _scaleAnimation.value,
                child: Container(
                  width: sosBtnSize,
                  height: sosBtnSize,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const RadialGradient(
                      colors: [
                        lightRed,
                        primaryRed,
                        darkRed,
                      ],
                      stops: [0.0, 0.6, 1.0],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: primaryRed.withOpacity(0.6),
                        blurRadius: 30,
                        spreadRadius: 5,
                      ),
                    ],
                  ),

                  // ----------------------------
                  // Button Content
                  // ----------------------------

                  child: widget.isLoading
                      ? const Center(
                          child: CircularProgressIndicator(
                            color: whiteColor,
                            strokeWidth: 4,
                          ),
                        )
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // SOS Text
                            const Text(
                              'SOS',
                              style: TextStyle(
                                fontSize: 52,
                                fontWeight: FontWeight.w900,
                                color: whiteColor,
                                letterSpacing: 4,
                                shadows: [
                                  Shadow(
                                    color: darkRed,
                                    blurRadius: 8,
                                    offset: Offset(2, 2),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 4),

                            // Sub Text
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: darkRed.withOpacity(0.4),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Text(
                                'PRESS & HOLD',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: whiteColor,
                                  letterSpacing: 2,
                                ),
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}