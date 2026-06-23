// ============================================
// Aarohan SOS Alert
// File        : widgets/contact_card.dart
// Description : Reusable Contact Card Widget
// ============================================

import 'package:flutter/material.dart';
import '../models/contact_model.dart';
import '../utils/constants.dart';

class ContactCard extends StatelessWidget {
  // ----------------------------
  // Properties
  // ----------------------------

  final ContactModel contact;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final bool showActions;

  const ContactCard({
    super.key,
    required this.contact,
    this.onEdit,
    this.onDelete,
    this.showActions = true,
  });

  // ----------------------------
  // Build
  // ----------------------------

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: paddingMedium),
      decoration: BoxDecoration(
        color: lightNavy,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: primaryRed.withOpacity(0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(paddingMedium),
        child: Row(
          children: [
            // ----------------------------
            // Priority Badge + Avatar
            // ----------------------------

            Stack(
              children: [
                // Avatar Circle
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      colors: [primaryRed, darkRed],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: primaryRed.withOpacity(0.4),
                        blurRadius: 8,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      contact.name.isNotEmpty
                          ? contact.name[0].toUpperCase()
                          : '?',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: whiteColor,
                      ),
                    ),
                  ),
                ),

                // Priority Badge
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      color: darkNavy,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: primaryRed,
                        width: 1.5,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        '${contact.priority}',
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: primaryRed,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(width: paddingMedium),

            // ----------------------------
            // Contact Info
            // ----------------------------

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name
                  Text(
                    contact.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: whiteColor,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: 4),

                  // Relationship Badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: primaryRed.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: primaryRed.withOpacity(0.3),
                      ),
                    ),
                    child: Text(
                      contact.relationship,
                      style: const TextStyle(
                        fontSize: 11,
                        color: lightRed,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),

                  const SizedBox(height: 6),

                  // Phone Number
                  Row(
                    children: [
                      const Icon(
                        Icons.phone,
                        size: 14,
                        color: mediumGrey,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        contact.phone,
                        style: const TextStyle(
                          fontSize: 13,
                          color: mediumGrey,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // ----------------------------
            // Action Buttons
            // ----------------------------

            if (showActions)
              Column(
                children: [
                  // Edit Button
                  GestureDetector(
                    onTap: onEdit,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: lightNavy,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: mediumGrey.withOpacity(0.3),
                        ),
                      ),
                      child: const Icon(
                        Icons.edit,
                        size: 18,
                        color: mediumGrey,
                      ),
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Delete Button
                  GestureDetector(
                    onTap: onDelete,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: primaryRed.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: primaryRed.withOpacity(0.3),
                        ),
                      ),
                      child: const Icon(
                        Icons.delete,
                        size: 18,
                        color: primaryRed,
                      ),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}