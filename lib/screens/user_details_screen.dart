// ============================================
// Aarohan SOS Alert
// File        : screens/user_details_screen.dart
// Description : User Registration Screen
// ============================================

import 'package:flutter/material.dart';
import '../utils/constants.dart';
import '../models/user_model.dart';
import '../models/contact_model.dart';
import '../services/storage_service.dart';
import 'dashboard_screen.dart';

class UserDetailsScreen extends StatefulWidget {
  const UserDetailsScreen({super.key});

  @override
  State<UserDetailsScreen> createState() => _UserDetailsScreenState();
}

class _UserDetailsScreenState extends State<UserDetailsScreen> {
  // ----------------------------
  // Form Key
  // ----------------------------

  final _formKey = GlobalKey<FormState>();

  // ----------------------------
  // Controllers
  // ----------------------------

  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _ageController = TextEditingController();
  final _addressController = TextEditingController();
  final _medicalController = TextEditingController();
  final _allergiesController = TextEditingController();

  // ----------------------------
  // State
  // ----------------------------

  String _selectedBloodGroup = 'Unknown';
  List<ContactModel> _contacts = [];
  bool _isSaving = false;
  final StorageService _storageService = StorageService();

  // ----------------------------
  // Dispose
  // ----------------------------

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _ageController.dispose();
    _addressController.dispose();
    _medicalController.dispose();
    _allergiesController.dispose();
    super.dispose();
  }

  // ----------------------------
  // Add Contact Dialog
  // ----------------------------

  void _showAddContactDialog({ContactModel? existingContact, int? index}) {
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
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          existingContact != null ? 'Edit Contact' : 'Add Contact',
          style: const TextStyle(
            color: whiteColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: StatefulBuilder(
          builder: (context, setDialogState) {
            return SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Name Field
                  TextField(
                    controller: nameController,
                    style: const TextStyle(color: whiteColor),
                    decoration: InputDecoration(
                      labelText: 'Contact Name *',
                      labelStyle: const TextStyle(color: mediumGrey),
                      prefixIcon: const Icon(
                        Icons.person,
                        color: primaryRed,
                      ),
                      filled: true,
                      fillColor: darkNavy,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),

                  const SizedBox(height: paddingMedium),

                  // Phone Field
                  TextField(
                    controller: phoneController,
                    style: const TextStyle(color: whiteColor),
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      labelText: 'Phone Number *',
                      labelStyle: const TextStyle(color: mediumGrey),
                      prefixIcon: const Icon(
                        Icons.phone,
                        color: primaryRed,
                      ),
                      filled: true,
                      fillColor: darkNavy,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),

                  const SizedBox(height: paddingMedium),

                  // Relationship Dropdown
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
        actions: [
          // Cancel
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancel',
              style: TextStyle(color: mediumGrey),
            ),
          ),

          // Save
          ElevatedButton(
            onPressed: () {
              if (nameController.text.trim().isEmpty ||
                  phoneController.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Name and Phone are required'),
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

              setState(() {
                if (index != null) {
                  _contacts[index] = contact;
                } else {
                  _contacts.add(contact);
                }
              });

              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryRed,
            ),
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  // ----------------------------
  // Delete Contact
  // ----------------------------

  void _deleteContact(int index) {
    setState(() {
      _contacts.removeAt(index);
      // Reassign priorities
      for (int i = 0; i < _contacts.length; i++) {
        _contacts[i] = _contacts[i].copyWith(priority: i + 1);
      }
    });
  }

  // ----------------------------
  // Save and Continue
  // ----------------------------

  Future<void> _saveAndContinue() async {
    if (!_formKey.currentState!.validate()) return;

    if (_contacts.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please add at least one emergency contact'),
          backgroundColor: primaryRed,
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    final user = UserModel(
      name: _nameController.text.trim(),
      phone: _phoneController.text.trim(),
      age: _ageController.text.trim(),
      bloodGroup: _selectedBloodGroup,
      address: _addressController.text.trim(),
      medicalConditions: _medicalController.text.trim(),
      allergies: _allergiesController.text.trim(),
      emergencyContacts: _contacts,
    );

    await _storageService.saveUserDetails(user);
    await _storageService.saveContacts(_contacts);

    setState(() => _isSaving = false);

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const DashboardScreen(),
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
        title: const Text('Your Details'),
        backgroundColor: darkNavy,
        automaticallyImplyLeading: false,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(paddingLarge),
          children: [
            // ----------------------------
            // Section - Personal Info
            // ----------------------------

            _buildSectionHeader(
              Icons.person,
              'Personal Information',
            ),

            const SizedBox(height: paddingMedium),

            // Full Name
            _buildTextFormField(
              controller: _nameController,
              label: 'Full Name *',
              icon: Icons.person_outline,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Full name is required';
                }
                return null;
              },
            ),

            const SizedBox(height: paddingMedium),

            // Mobile Number
            _buildTextFormField(
              controller: _phoneController,
              label: 'Mobile Number *',
              icon: Icons.phone_outlined,
              keyboardType: TextInputType.phone,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Mobile number is required';
                }
                if (value.trim().length < 10) {
                  return 'Enter a valid mobile number';
                }
                return null;
              },
            ),

            const SizedBox(height: paddingMedium),

            // Age
            _buildTextFormField(
              controller: _ageController,
              label: 'Age (Optional)',
              icon: Icons.cake_outlined,
              keyboardType: TextInputType.number,
            ),

            const SizedBox(height: paddingMedium),

            // Blood Group Dropdown
            _buildBloodGroupDropdown(),

            const SizedBox(height: paddingMedium),

            // Address
            _buildTextFormField(
              controller: _addressController,
              label: 'Address (Optional)',
              icon: Icons.home_outlined,
              maxLines: 2,
            ),

            const SizedBox(height: paddingLarge),

            // ----------------------------
            // Section - Medical Info
            // ----------------------------

            _buildSectionHeader(
              Icons.medical_services,
              'Medical Information',
            ),

            const SizedBox(height: paddingMedium),

            // Medical Conditions
            _buildTextFormField(
              controller: _medicalController,
              label: 'Medical Conditions (Optional)',
              icon: Icons.health_and_safety_outlined,
              maxLines: 2,
            ),

            const SizedBox(height: paddingMedium),

            // Allergies
            _buildTextFormField(
              controller: _allergiesController,
              label: 'Allergies (Optional)',
              icon: Icons.warning_amber_outlined,
              maxLines: 2,
            ),

            const SizedBox(height: paddingLarge),

            // ----------------------------
            // Section - Emergency Contacts
            // ----------------------------

            _buildSectionHeader(
              Icons.contacts,
              'Emergency Contacts',
            ),

            const SizedBox(height: paddingSmall),

            Text(
              'Add up to $maxContacts contacts (minimum 1 required)',
              style: TextStyle(
                fontSize: 12,
                color: mediumGrey.withOpacity(0.8),
              ),
            ),

            const SizedBox(height: paddingMedium),

            // Contact List
            ..._contacts.asMap().entries.map((entry) {
              final index = entry.key;
              final contact = entry.value;
              return _buildContactTile(contact, index);
            }),

            // Add Contact Button
            if (_contacts.length < maxContacts)
              GestureDetector(
                onTap: () => _showAddContactDialog(),
                child: Container(
                  padding: const EdgeInsets.all(paddingMedium),
                  decoration: BoxDecoration(
                    color: lightNavy,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: primaryRed.withOpacity(0.5),
                      style: BorderStyle.solid,
                    ),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.add_circle_outline,
                        color: primaryRed,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Add Emergency Contact',
                        style: TextStyle(
                          color: primaryRed,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            const SizedBox(height: paddingXLarge),

            // ----------------------------
            // Save Button
            // ----------------------------

            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _saveAndContinue,
                child: _isSaving
                    ? const CircularProgressIndicator(color: whiteColor)
                    : const Text(
                        'Save & Continue',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),

            const SizedBox(height: paddingLarge),
          ],
        ),
      ),
    );
  }

  // ----------------------------
  // Section Header Builder
  // ----------------------------

  Widget _buildSectionHeader(IconData icon, String title) {
    return Row(
      children: [
        Icon(icon, color: primaryRed, size: 22),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: whiteColor,
          ),
        ),
      ],
    );
  }

  // ----------------------------
  // Text Form Field Builder
  // ----------------------------

  Widget _buildTextFormField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      style: const TextStyle(color: whiteColor),
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: primaryRed),
      ),
    );
  }

  // ----------------------------
  // Blood Group Dropdown Builder
  // ----------------------------

  Widget _buildBloodGroupDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: paddingMedium,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: lightNavy,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.bloodtype, color: primaryRed),
          const SizedBox(width: paddingMedium),
          Expanded(
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedBloodGroup,
                isExpanded: true,
                dropdownColor: lightNavy,
                style: const TextStyle(color: whiteColor),
                hint: const Text(
                  'Blood Group (Optional)',
                  style: TextStyle(color: mediumGrey),
                ),
                icon: const Icon(
                  Icons.arrow_drop_down,
                  color: primaryRed,
                ),
                items: bloodGroups.map((group) {
                  return DropdownMenuItem(
                    value: group,
                    child: Text(group),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedBloodGroup = value!;
                  });
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ----------------------------
  // Contact Tile Builder
  // ----------------------------

  Widget _buildContactTile(ContactModel contact, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: paddingMedium),
      padding: const EdgeInsets.all(paddingMedium),
      decoration: BoxDecoration(
        color: lightNavy,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: primaryRed.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 48,
            height: 48,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: primaryRed,
            ),
            child: Center(
              child: Text(
                contact.name[0].toUpperCase(),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: whiteColor,
                ),
              ),
            ),
          ),

          const SizedBox(width: paddingMedium),

          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  contact.name,
                  style: const TextStyle(
                    color: whiteColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${contact.relationship} • ${contact.phone}',
                  style: const TextStyle(
                    color: mediumGrey,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),

          // Edit
          IconButton(
            icon: const Icon(Icons.edit, color: mediumGrey, size: 20),
            onPressed: () => _showAddContactDialog(
              existingContact: contact,
              index: index,
            ),
          ),

          // Delete
          IconButton(
            icon: const Icon(Icons.delete, color: primaryRed, size: 20),
            onPressed: () => _deleteContact(index),
          ),
        ],
      ),
    );
  }
}
