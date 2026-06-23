// ============================================
// Aarohan SOS Alert
// File        : services/storage_service.dart
// Description : SharedPreferences Storage Service
// ============================================

import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../models/contact_model.dart';
import '../utils/constants.dart';

class StorageService {
  // ----------------------------
  // Singleton Setup
  // ----------------------------

  static final StorageService _instance = StorageService._internal();
  factory StorageService() => _instance;
  StorageService._internal();

  // ----------------------------
  // Save User Details
  // ----------------------------

  Future<bool> saveUserDetails(UserModel user) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      await prefs.setString(keyUserName, user.name);
      await prefs.setString(keyUserPhone, user.phone);
      await prefs.setString(keyUserAge, user.age);
      await prefs.setString(keyUserBloodGroup, user.bloodGroup);
      await prefs.setString(keyUserAddress, user.address);
      await prefs.setString(keyUserMedical, user.medicalConditions);
      await prefs.setString(keyUserAllergies, user.allergies);
      await prefs.setBool(keyIsSetupDone, true);

      return true;
    } catch (e) {
      return false;
    }
  }

  // ----------------------------
  // Load User Details
  // ----------------------------

  Future<UserModel?> loadUserDetails() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final name = prefs.getString(keyUserName);

      // If no user saved yet return null
      if (name == null || name.isEmpty) return null;

      return UserModel(
        name: prefs.getString(keyUserName) ?? '',
        phone: prefs.getString(keyUserPhone) ?? '',
        age: prefs.getString(keyUserAge) ?? '',
        bloodGroup: prefs.getString(keyUserBloodGroup) ?? '',
        address: prefs.getString(keyUserAddress) ?? '',
        medicalConditions: prefs.getString(keyUserMedical) ?? '',
        allergies: prefs.getString(keyUserAllergies) ?? '',
        emergencyContacts: await loadContacts(),
      );
    } catch (e) {
      return null;
    }
  }

  // ----------------------------
  // Save Contacts
  // ----------------------------

  Future<bool> saveContacts(List<ContactModel> contacts) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final contactListJson = contacts
          .map((contact) => json.encode(contact.toMap()))
          .toList();

      await prefs.setStringList(keyContacts, contactListJson);

      return true;
    } catch (e) {
      return false;
    }
  }

  // ----------------------------
  // Load Contacts
  // ----------------------------

  Future<List<ContactModel>> loadContacts() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final contactListJson = prefs.getStringList(keyContacts);

      if (contactListJson == null || contactListJson.isEmpty) return [];

      return contactListJson
          .map((contactJson) =>
              ContactModel.fromMap(json.decode(contactJson)))
          .toList();
    } catch (e) {
      return [];
    }
  }

  // ----------------------------
  // Add Single Contact
  // ----------------------------

  Future<bool> addContact(ContactModel contact) async {
    try {
      final contacts = await loadContacts();

      // Check max limit
      if (contacts.length >= maxContacts) return false;

      contacts.add(contact);
      return await saveContacts(contacts);
    } catch (e) {
      return false;
    }
  }

  // ----------------------------
  // Update Single Contact
  // ----------------------------

  Future<bool> updateContact(ContactModel updatedContact) async {
    try {
      final contacts = await loadContacts();

      final index = contacts.indexWhere((c) => c.id == updatedContact.id);

      if (index == -1) return false;

      contacts[index] = updatedContact;
      return await saveContacts(contacts);
    } catch (e) {
      return false;
    }
  }

  // ----------------------------
  // Delete Single Contact
  // ----------------------------

  Future<bool> deleteContact(String contactId) async {
    try {
      final contacts = await loadContacts();

      contacts.removeWhere((c) => c.id == contactId);
      return await saveContacts(contacts);
    } catch (e) {
      return false;
    }
  }

  // ----------------------------
  // Check Setup Done
  // ----------------------------

  Future<bool> isSetupDone() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(keyIsSetupDone) ?? false;
    } catch (e) {
      return false;
    }
  }

  // ----------------------------
  // Get User Name Only
  // ----------------------------

  Future<String> getUserName() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(keyUserName) ?? '';
    } catch (e) {
      return '';
    }
  }

  // ----------------------------
  // Clear All Data
  // ----------------------------

  Future<bool> clearAllData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      return true;
    } catch (e) {
      return false;
    }
  }
}