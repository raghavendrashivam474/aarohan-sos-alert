// ============================================
// Aarohan SOS Alert
// File        : screens/contact_management_screen.dart
// Description : Emergency Contact Management
// ============================================

import 'package:flutter/material.dart';
import '../utils/constants.dart';
import '../models/contact_model.dart';
import '../services/storage_service.dart';
import '../widgets/contact_card.dart';

class ContactManagementScreen extends StatefulWidget {
  const ContactManagementScreen({super.key});

  @override
  State<ContactManagementScreen> createState() =>
      _ContactManagementScreenState();
}

class _ContactManagementScreenState extends State<ContactManagementScreen> {
  // ----------------------------
  // State
  // ----------------------------

  List<ContactModel> _contacts = [];
  bool _isLoading = true;
  final StorageService _storageService = StorageService();

  // ----------------------------
  // Init
  // ----------------------------

  @override
  void initState() {
    super.initState();
    _loadContacts();
  }

  // ----------------------------
  // Load Contacts
  // ----------------------------

  Future<void> _loadContacts() async {
    setState(() => _isLoading = true);
    final contacts = await _storageService.loadContacts();
    setState(() {
      _contacts = contacts;
      _isLoading = false;
    });
  }

  // ----------------------------
  // Show Add / Edit Dialog
  // ----------------------------

  void _showContactDialog({ContactModel? existingContact, int? index}) {
    final nameController = TextEditingController(
      text: existingContact?.name ?? '',
    );
    final phoneController = TextEditingController(
      text: existingContact?.phone ?? '',
    );
    String selectedRelationship =
        existingContact?.relationship ?? relationships.first;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: lightNavy,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Row(
          children: [
            Icon(
              existingContact != null ? Icons.edit : Icons.person_add,
              color: primaryRed,
              size: 24,
            ),
            const SizedBox(width: 8),
            Text(
              existingContact != null ? 'Edit Contact' : 'Add Contact',
              style: const TextStyle(
                color: whiteColor,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ],
        ),
        content: StatefulBuilder(
          builder: (context, setDialogState) {
            return SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // ----------------------------
                  // Name Field
                  // ----------------------------

                  TextField(
                    controller: nameController,
                    style: const TextStyle(color: whiteColor),
                    decoration: InputDecoration(
                      labelText: 'Contact Name *',
                      labelStyle: const TextStyle(color: mediumGrey),
                      prefixIcon: const Icon(
                        Icons.person_outline,
                        color: primaryRed,
                      ),
                      filled: true,
                      fillColor: darkNavy,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: primaryRed,
                          width: 2,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: paddingMedium),

                  // ----------------------------
                  // Phone Field
                  // ----------------------------

                  TextField(
                    controller: phoneController,
                    style: const TextStyle(color: whiteColor),
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      labelText: 'Phone Number *',
                      labelStyle: const TextStyle(color: mediumGrey),
                      prefixIcon: const Icon(
                        Icons.phone_outlined,
                        color: primaryRed,
                      ),
                      filled: true,
                      fillColor: darkNavy,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: primaryRed,
                          width: 2,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: paddingMedium),

                  // ----------------------------
                  // Relationship Dropdown
                  // ----------------------------

                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: paddingMedium,
                    ),
                    decoration: BoxDecoration(
                      color: darkNavy,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: selectedRelationship,
                        isExpanded: true,
                        dropdownColor: darkNavy,
                        style: const TextStyle(color: whiteColor),
                        icon: const Icon(
                          Icons.arrow_drop_down,
                          color: primaryRed,
                        ),
                        items: relationships.map((rel) {
                          return DropdownMenuItem(
                            value: rel,
                            child: Text(rel),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setDialogState(() {
                            selectedRelationship = value!;
                          });
                        },
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),

        // ----------------------------
        // Dialog Actions
        // ----------------------------

        actions: [
          // Cancel Button
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancel',
              style: TextStyle(color: mediumGrey),
            ),
          ),

          // Save Button
          ElevatedButton(
            onPressed: () async {
              // Validate
              if (nameController.text.trim().isEmpty ||
                  phoneController.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Name and Phone number are required'),
                    backgroundColor: primaryRed,
                  ),
                );
                return;
              }

              if (phoneController.text.trim().length < 10) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Enter a valid phone number'),
                    backgroundColor: primaryRed,
                  ),
                );
                return;
              }

              final contact = ContactModel(
                id: existingContact?.id ??
                    DateTime.now().millisecondsSinceEpoch.toString(),
                name: nameController.text.trim(),
                phone: phoneController.text.trim(),
                relationship: selectedRelationship,
                priority: index != null
                    ? index + 1
                    : _contacts.length + 1,
              );

              Navigator.pop(context);

              if (existingContact != null) {
                await _storageService.updateContact(contact);
              } else {
                await _storageService.addContact(contact);
              }

              _loadContacts();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryRed,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              existingContact != null ? 'Update' : 'Add',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: whiteColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ----------------------------
  // Delete Contact
  // ----------------------------

  void _deleteContact(ContactModel contact) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: lightNavy,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text(
          'Delete Contact',
          style: TextStyle(
            color: whiteColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          'Are you sure you want to remove ${contact.name} from your emergency contacts?',
          style: const TextStyle(
            color: mediumGrey,
            height: 1.5,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancel',
              style: TextStyle(color: mediumGrey),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await _storageService.deleteContact(contact.id);
              _loadContacts();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryRed,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Delete',
              style: TextStyle(color: whiteColor),
            ),
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
        title: const Text('Emergency Contacts'),
        backgroundColor: darkNavy,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: whiteColor),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          // Contact Count Badge
          Center(
            child: Container(
              margin: const EdgeInsets.only(right: paddingMedium),
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 4,
              ),
              decoration: BoxDecoration(
                color: primaryRed.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: primaryRed.withOpacity(0.5),
                ),
              ),
              child: Text(
                '${_contacts.length} / $maxContacts',
                style: const TextStyle(
                  color: primaryRed,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: primaryRed),
            )
          : _contacts.isEmpty
              ? _buildEmptyState()
              : _buildContactList(),

      // ----------------------------
      // FAB - Add Contact
      // ----------------------------

      floatingActionButton: _contacts.length < maxContacts
          ? FloatingActionButton.extended(
              onPressed: () => _showContactDialog(),
              backgroundColor: primaryRed,
              icon: const Icon(Icons.person_add, color: whiteColor),
              label: const Text(
                'Add Contact',
                style: TextStyle(
                  color: whiteColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            )
          : null,
    );
  }

  // ----------------------------
  // Empty State Builder
  // ----------------------------

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: lightNavy,
              border: Border.all(
                color: primaryRed.withOpacity(0.3),
              ),
            ),
            child: const Icon(
              Icons.contacts_outlined,
              size: 64,
              color: primaryRed,
            ),
          ),

          const SizedBox(height: paddingLarge),

          const Text(
            'No Emergency Contacts',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: whiteColor,
            ),
          ),

          const SizedBox(height: paddingSmall),

          Text(
            'Add at least one contact\nto use the SOS feature',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: mediumGrey.withOpacity(0.8),
              height: 1.5,
            ),
          ),

          const SizedBox(height: paddingXLarge),

          ElevatedButton.icon(
            onPressed: () => _showContactDialog(),
            icon: const Icon(Icons.person_add, color: whiteColor),
            label: const Text(
              'Add First Contact',
              style: TextStyle(
                color: whiteColor,
                fontWeight: FontWeight.bold,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryRed,
              padding: const EdgeInsets.symmetric(
                horizontal: 32,
                vertical: 14,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ----------------------------
  // Contact List Builder
  // ----------------------------

  Widget _buildContactList() {
    return ListView(
      padding: const EdgeInsets.all(paddingLarge),
      children: [
        // ----------------------------
        // Info Banner
        // ----------------------------

        Container(
          padding: const EdgeInsets.all(paddingMedium),
          margin: const EdgeInsets.only(bottom: paddingLarge),
          decoration: BoxDecoration(
            color: lightNavy,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: primaryRed.withOpacity(0.2),
            ),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.info_outline,
                color: primaryRed,
                size: 20,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Contacts are alerted in priority order during SOS',
                  style: TextStyle(
                    fontSize: 12,
                    color: mediumGrey.withOpacity(0.9),
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        ),

        // ----------------------------
        // Contact Cards
        // ----------------------------

        ..._contacts.asMap().entries.map((entry) {
          final index = entry.key;
          final contact = entry.value;
          return ContactCard(
            contact: contact,
            onEdit: () => _showContactDialog(
              existingContact: contact,
              index: index,
            ),
            onDelete: () => _deleteContact(contact),
          );
        }),

        const SizedBox(height: 80),
      ],
    );
  }
}